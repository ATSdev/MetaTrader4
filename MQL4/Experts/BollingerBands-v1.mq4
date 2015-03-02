#include <stderror.mqh>
#include <stdlib.mqh>

#property copyright "ATSdev"
#property link      "http://www.meetup.com/Toronto-Automated-Trading-Strategies-Deve"
#property version   "1.00"
#property strict

input int      BBPeriod    = 20;
input int      BBStdDev    = 2;
input int      StopLoss    = 50;
input int      TakeProfit  = 250;
input float    Lot         = 0.1;
input bool     PrintDebug  = false;
input bool     PrintOrders = false;

      int      stopLossAdj = 10;

int OnInit() {
   stopLossAdj = StopLoss;
   // avoiding "Minimum StopLoss = 10 points"
   double stopLossMin = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (stopLossAdj < stopLossMin) {
      printf("RESETTING_STOP_LOSS_TO_MINIMAL_ACCEPTED stopLoss[%f] => stopLossMin[%f]", StopLoss, stopLossMin);
      stopLossAdj = stopLossMin;
   }
   return(INIT_SUCCEEDED);
}

void OnTick() {
   int barSerno = Bars;
	int barToWait = BBPeriod - barSerno;
	if (barToWait > 0) {
	   Print("barToWait=",barToWait);
	   return;
	}
	int ordersPendingOrOpen = OrdersTotal();
	if (ordersPendingOrOpen != 0) {
	   if (PrintDebug) Print("ordersPendingOrOpen=",ordersPendingOrOpen);
	   return;
	}

   double bbValueUpper = iBands(NULL,0,BBPeriod,BBStdDev,0,PRICE_CLOSE,MODE_UPPER,0);
   double bbValueLower = iBands(NULL,0,BBPeriod,BBStdDev,0,PRICE_CLOSE,MODE_LOWER,0);
   // 1.567478987566 => 1.56748 if our broker provides 5 digits after the decimal point
   bbValueUpper   = NormalizeDouble(bbValueUpper,Digits);
   bbValueLower   = NormalizeDouble(bbValueLower,Digits);

  
   bool signal_buy   = Close[0] < bbValueLower;
   bool signal_sell  = Close[0] > bbValueUpper;
   bool signal_error = signal_buy && signal_sell;

   string signal_buy_str = "";
   if (signal_buy)   signal_buy_str = "BUY";
   
   string signal_sell_str = "";
   if (signal_sell)  signal_sell_str = "SELL";
   
   if (PrintDebug || signal_error) {
      printf("[%s] [%f]...[%f] %s %s", TimeToString(Time[0],TIME_SECONDS)
         , bbValueLower, bbValueUpper, signal_buy_str, signal_sell_str);
   }
   
   if (signal_error) {
      Print("I_REFUSE_TO_PROCESS_BOTH signal_buy && signal_sell");
      return;
   }
   
   if (signal_buy)   buy();
   if (signal_sell)  sell();
}


// taken from MQL4 Reference / Trade Functions / OrderSend 
void buy() {
   double price=Ask;
   //--- calculated SL and TP prices must be normalized
   double stoploss   =NormalizeDouble(Bid-stopLossAdj*Point,Digits);
   double takeprofit =NormalizeDouble(Bid+TakeProfit*Point,Digits);
   //--- place market order to buy 1 lot
   string orderComment = "buy@" + price + " TP:" + takeprofit + " SL" + stoploss;
   if (PrintOrders) Print(orderComment);
   int ticket=OrderSend(Symbol(),OP_BUY,Lot,price,3,stoploss,takeprofit,orderComment,16384,0,clrGreen);
   if(ticket<0) {
      int err = GetLastError();
      printf("buy() OrderSend failed with error #%d %s", err, ErrorDescription(err));
   } else {
      Print("buy() OrderSend placed successfully");
   }
}

// buy() inversed
void sell() {
   double price=Bid;
   //--- calculated SL and TP prices must be normalized
   double stoploss   =NormalizeDouble(Ask+stopLossAdj*Point,Digits);
   double takeprofit =NormalizeDouble(Ask-TakeProfit*Point,Digits);
   //--- place market order to buy 1 lot
   string orderComment = "sell@" + price + " TP:" + takeprofit + " SL" + stoploss;
   if (PrintOrders) Print(orderComment);
   int ticket=OrderSend(Symbol(),OP_SELL,Lot,price,3,stoploss,takeprofit,orderComment,16384,0,clrOrangeRed);
   if(ticket<0) {
      int err = GetLastError();
      printf("sell() OrderSend failed with error #%d %s", err, ErrorDescription(err));
   } else {
      Print("sell() OrderSend placed successfully");
   }
}



//double  iBands(
//   string       symbol,           // symbol
//   int          timeframe,        // timeframe
//   int          period,           // averaging period
//   double       deviation,        // standard deviations
//   int          bands_shift,      // bands shift
//   int          applied_price,    // applied price
//   int          mode,             // line index
//   int          shift             // shift
//   );


//int  OrderSend(
//   string   symbol,              // symbol
//   int      cmd,                 // operation
//   double   volume,              // volume
//   double   price,               // price
//   int      slippage,            // slippage
//   double   stoploss,            // stop loss
//   double   takeprofit,          // take profit
//   string   comment=NULL,        // comment
//   int      magic=0,             // magic number
//   datetime expiration=0,        // pending order expiration
//   color    arrow_color=clrNONE  // color
//   );
 

string	ea_name = "EA-OR_breakout-v1";

extern 	bool	orb_open_apply			= true;
extern 	bool	orb_close_apply			= true;
extern 	bool	orb_close_FIBO1			= true;
extern 	bool	orb_close_eod			= true;


// copy of OpeningRange.mq4 indicator parameters
extern	string	ea_calledfrom		= "EA_ORb-v1";
		string	ea_onchart			= "CHART";

extern	int		bars2wait					= 52;		// EUSUSD 15 min: 17:00(MSK) = 8:00am(NYC) = 1:00pm(GMT) = 4*13 = 52
extern	int		bars2watch					= 6;		// EUSUSD 15 min: 1:30 = 4 + 2 = 6
extern	int		bars2trade					= 48;		// EUSUSD 15 min: 18:30(MSK) = 9:30am(NYC) = 2:30pm(GMT) = 4*14 + 2 = 58
extern	int		friday_force_close_time		= 2030;		// 0=disabled; GMT but depends on the broker (check the chart first)
		bool	leave_saturday_empty		= true;
		bool	leave_sunday_empty			= true;

extern	double	fibo_target1				= 161.8;
extern	double	fibo_target2				= 261.8;

extern	bool	onchart_draw					= false;
extern	bool	onchart_annotate				= false;
extern	bool	onchart_annotate_prefix_session = false;
extern	bool	onchart_setbg					= false;

extern	int		max_bars_back_ea					= 100;
extern	int		max_bars_back_onchart				= 100;
		int		max_bars_back						= 1000;
extern	int		max_bars_4objects					= 480;
extern	int		indicator_recent_limit_backgrs		= 480;
extern	int		indicator_recent_limit_lines		= 100;
extern	int		indicator_recent_limit_bartext		= 100;
extern	bool	indicator_lines_bartext_create		= false;

extern	bool	debug_calculate_bar_state			= false;
extern	bool	debug_calculate_breakout_levels		= false;
extern	bool	debug_neutralize_friday_night		= false;

extern	bool	annotate_bar_month_year				= true;
// /copy of OpeningRange.mq4 indicator parameters



extern	int		stoploss_pips				= 30;
extern	int		takeprofit_pips				= 60;
		double	onepip_afterdecimal			= 0.0001;

		bool	stop_onfail_emergencypips	= true;
		int		stoploss_emergencypips		= 10;

		bool	stop_moveaway_allow			= true;	// true - set stops far from price even if manual stop were more tight
		int 	simuni_positions_open		= 1;
		int 	on_simuni_remove_tp			= 0;
extern	int		open_both0_long1_short2		= 0;

		int		first_ticks_to_skip				= 0;
		int		invoke_everyTick0_oncePerBar1	= 1;

		int		debug_open			= 0;
		int		debug_stoploss		= 0;
		int		debug_modify		= 0;
		int		debug_close			= 0;

		int		debug_orb			= 1;


extern	double	lots_fixed 	= 0.01;		// default lot size if mm_maxrisk_apply = 0


double	takeprofit_0	= 0;
double	stop_0			= 0;
//double	trailingstop	= 0;

int	slippage		= 3;
int magic			= 8833063;


bool long_orb_open = false;
bool short_orb_open = false;
bool long_orb_close = false;
bool short_orb_close = false;



bool signal_open_long = false;
bool signal_open_short = false;
bool signal_close_long = false;
bool signal_close_short = false;


static datetime processed_datetime = 0;

static int ticket_long_current = 0;
static int ticket_short_current = 0;

static int long_ticket_array[];
static int short_ticket_array[];
static int open_orders_qnty = 0;

string order_open_reason = "";
string order_open_message = "";
string order_close_reason = "";
string order_close_message = "";
string order_stop_reason = "";
string order_stop_message = "";
string order_takeprofit_reason = "";
string order_takeprofit_message = "";

static int bars_ago_position_open = 0;


string	globalvar_prefix = "GP-OR_breakout-v1";
#include "libraries/common_lib2.mq4"



int		stats_corner = 3;
int		stats_xdis = 10;
int		stats_ydis = 10;
string	stats_font = "Lucida Console";
int		stats_fontSize = 8;
color	stats_fontColor = Gold;


int init() {
	init_common();
	return(0);
}


int deinit() {
	deinit_common();

	int globals_deleted = GlobalVariablesDeleteAll(globalvar_prefix);
	log("deinit(" + globalvar_prefix + "): " + globals_deleted + " globals deleted");

	return(0);
}


static datetime opentime_lastbar = 0;
static datetime opentime_lastbar_roundminute = 0;

int start() {
	//if (once_per_bar(first_ticks_to_skip) == false) return(0);	
	
//	if (opentime_lastbar == 0) opentime_lastbar = Time[i];
	bool first_tick_of_new_bar = false;
	if ((Time[0] > opentime_lastbar)
//			&& (IsTesting() == true)
		) {
		first_tick_of_new_bar = true;
		opentime_lastbar = Time[0];
	}


	if (first_tick_of_new_bar == true) {
	//	log("start(" + TimeToStr(Time[bar], TIME_DATE) + " " + TimeToStr(Time[bar], TIME_SECONDS) + ")"
	//		+ " bar[" + bar + "]/[" + not_counted + "]:[" + max_bars_back  + "]"
	//		+ " IndicatorCounted[" + IndicatorCounted() + "]/[" + Bars + "]"
	//	);
	}

	if (first_tick_of_new_bar == false) {
		return(0);
	}

	start_common();

	if (orb_open_apply == true) {
	 	orb_signals(0);
		if (ticket_long_current == 0 && long_orb_open == true) {
			signal_open_long = true;
			if (debug_open == 1) log("start(open_signals): signal_open_long=[" + signal_open_short + "]"
				+ " reason=[" + order_open_reason + "]");
		}
		
		if (ticket_short_current == 0 && short_orb_open == true) {
			signal_open_short = true;
			if (debug_open == 1) log("start(open_signals): signal_open_short=[" + signal_open_short + "]"
				+ " reason=[" + order_open_reason + "]");
		}
	}

	if (orb_close_apply == true) {
	 	orb_signals(1);
		if (ticket_long_current != 0 && long_orb_close == true) {
			signal_close_long = true;
			if (debug_close == 1) log("start(close_signals): signal_close_long=[" + signal_close_long + "]"
				+ " reason=[" + order_close_reason + "]");
		}
		
		if (ticket_short_current != 0 && short_orb_close == true) {
			signal_close_short = true;
			if (debug_close == 1) log("start(close_signals): signal_close_short=[" + signal_close_short + "]"
				+ " reason=[" + order_close_reason + "]");
		}
	}

	processing_close_stop_open();
}

/*
extern	int		bars2wait		= 52;		// EUSUSD 15 min: 17:00(MSK) = 8:00am(NYC) = 1:00pm(GMT) = 4*13 = 52
extern	int		bars2watch		= 6;		// EUSUSD 15 min: 1:30 = 4 + 2 = 6
extern	int		bars2trade		= 13;		// EUSUSD 15 min: 18:30(MSK) = 9:30am(NYC) = 2:30pm(GMT) = 4*14 + 2 = 58

extern	double	fibo_target1		= 161.8;
extern	double	fibo_target2		= 261.8;

extern	string	ea_calledfrom	= "CHART";
		string	ea_onchart		= "CHART";

extern	bool	onchart_draw		= true;
extern	bool	onchart_annotate	= false;
extern	bool	onchart_annotate_prefix_session = true;
extern	bool	onchart_setbg		= false;

extern	int		max_bars_back_ea					= 10000;
extern	int		max_bars_back_onchart				= 10000;
		int		max_bars_back						= 10000;
extern	int		max_bars_4objects					= 480;
extern	int		indicator_recent_limit_backgrs		= 480;
extern	int		indicator_recent_limit_lines		= 100;
extern	int		indicator_recent_limit_bartext		= 100;
extern	bool	indicator_lines_bartext_create		= false;
*/

void orb_signals(int open0_or_close1 = 0) {
	double OpeningRange_session1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 0, 1);

	double OpeningRange_state1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 1, 1);

	double OpeningRange_state2 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 1, 2);

	double OpeningRange_upper1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 2, 1);

	double OpeningRange_lower1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 3, 1);

	double OpeningRange_FIBO1_upper1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 4, 1);

	double OpeningRange_FIBO1_lower1 = iCustom(NULL, 0, "OpeningRange-v1"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, debug_neutralize_friday_night, annotate_bar_month_year
		, 5, 1);


	OpeningRange_session1			= empty2zero(OpeningRange_session1);
	OpeningRange_state1				= empty2zero(OpeningRange_state1);
	OpeningRange_state2				= empty2zero(OpeningRange_state2);
	OpeningRange_upper1				= empty2zero(OpeningRange_upper1);
	OpeningRange_lower1				= empty2zero(OpeningRange_lower1);
	OpeningRange_FIBO1_upper1		= empty2zero(OpeningRange_FIBO1_upper1);
	OpeningRange_FIBO1_lower1		= empty2zero(OpeningRange_FIBO1_lower1);


	string OpeningRange_session1_str		= double_to_str(OpeningRange_session1,		-1);
	string OpeningRange_state1_str			= double_to_str(OpeningRange_state1,		-1);
	string OpeningRange_upper1_str			= double_to_str(OpeningRange_upper1,		indicator_precision);
	string OpeningRange_lower1_str			= double_to_str(OpeningRange_lower1,		indicator_precision);
	string OpeningRange_FIBO1_upper1_str	= double_to_str(OpeningRange_FIBO1_upper1,	indicator_precision);
	string OpeningRange_FIBO1_lower1_str	= double_to_str(OpeningRange_FIBO1_lower1,	indicator_precision);
	string Close1_str						= double_to_str(Close[1], indicator_precision);

	if (debug_orb == 1) {
		log("orb_signals(open0_or_close1=" + open0_or_close1 + "): "
			//+ " [" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "]"
			+ " sesson1=["			+ OpeningRange_session1_str + "]"
			+ " state1=["			+ OpeningRange_state1_str + "]"
			//+ " state2=["			+ OpeningRange_state2, -1) + "]"
			+ " Close1=["			+ Close1_str + "]"
			+ " upper1=["			+ OpeningRange_upper1_str + "]"
			+ " lower_1=["			+ OpeningRange_lower1_str + "]"
			+ " FIBO1_upper1=["		+ OpeningRange_FIBO1_upper1_str + "]"
			+ " FIBO1_lower_1=["	+ OpeningRange_FIBO1_lower1_str + "]"
			);
	}
	
	
	if (open0_or_close1 == 0) {
		if (OpeningRange_state1	!= 5) return(0);	//ntd0wait1st2wtch3end4trd5eod6
		
		long_orb_open = false;
		short_orb_open = false;

		if (ticket_long_current == 0) {
			if (Close[1] >= OpeningRange_upper1) {
				long_orb_open = true;
				order_open_reason = order_open_reason + "ORBU";
				order_open_message = ""
					+ " OpeningRange_upper1[" + OpeningRange_upper1_str + "]>Close1[" + Close1_str + "]"
					+ " OpeningRange_session1=[" + OpeningRange_session1_str + "]==5"
					;

				if (debug_orb == 1) log("orb_signals(open_long): long_orb_open=[" + long_orb_open + "] " + order_open_message);
				bartext_append(ea_name, "", "OL-ORBU", 0);
			}
		}

		if (ticket_short_current == 0) {
			if (Close[1] <= OpeningRange_lower1) {
				short_orb_open = true;
				order_open_reason = order_open_reason + "ORBL";
				order_open_message = ""
					+ " Close1[" + Close1_str + "]<OpeningRange_lower1[" + OpeningRange_lower1_str + "]"
					+ " OpeningRange_session1=[" + OpeningRange_session1_str + "]==5"
					;

				if (debug_orb == 1) log("orb_signals(open_short): short_orb_open=[" + short_orb_open + "] " + order_open_message);
				bartext_append(ea_name, "", "OS-ORBL", 1);
			}
		}
	
		return(0);
	}	

	if (open0_or_close1 == 1) {
		long_orb_close = false;
		short_orb_close = false;

		if (orb_close_eod == true && OpeningRange_state1 == 6) {
			if (ticket_long_current > 0) {
				long_orb_close = true;
				order_close_reason = order_close_reason + "LC_EOD";
				order_close_message = " OpeningRange_session1=[" + OpeningRange_session1_str + "]==6/eod";
				log("orb_signals(close_long): " + order_close_message);
				bartext_append(ea_name, "", "CL-EOD", 0);
			}
			if (ticket_short_current > 0) {
				short_orb_close = true;
				order_close_reason = order_close_reason + "SC_EOD";
				order_close_message = " OpeningRange_session1=[" + OpeningRange_session1_str + "]==6/eod";
				log("orb_signals(close_short): " + order_close_message);
				bartext_append(ea_name, "", "CS-EOD", 0);
			}
		}

		if (orb_close_FIBO1 == true) {
			if (ticket_long_current > 0) {
				if (Close[1] >= OpeningRange_FIBO1_upper1) {
					long_orb_close = true;
					order_close_reason = order_close_reason + "ORU_FIBO1";
					order_close_message = ""
						+ " Close1[" + Close1_str + "]>=OpeningRange_FIBO1_upper1[" + OpeningRange_FIBO1_upper1_str + "]"
						+ " OpeningRange_session1=[" + OpeningRange_session1_str + "]==5"
						;

					log("orb_signals(close_long): " + order_close_message);
					bartext_append(ea_name, "", "CL-F1", 0);
				}
			}

			if (ticket_short_current > 0) {
				if (Close[1] <= OpeningRange_FIBO1_lower1) {
					short_orb_close = true;
					order_close_reason = order_close_reason + "ORL_FIBO1";
					order_close_message = ""
						+ " Close1[" + Close1_str + "]<=OpeningRange_FIBO1_lower1[" + OpeningRange_FIBO1_lower1_str + "]"
						+ " OpeningRange_session1=[" + OpeningRange_session1_str + "]==5"
						;

					log("orb_signals(close_short): " + order_close_message);
					bartext_append(ea_name, "", "CS-F1", 1);
				}
			}

			//log("orb_signals(open0_or_close1=1): DONT CHECK HERE FOR CLOSING SIGNALS; SET SL&TP INSTEAD");
			return(0);
		}
	}
}





void processing_close_stop_open() {
	int i, ticket, orders_qnty;

	bool just_opened_long = false;
	bool just_opened_short = false;
	bool just_closed_long = false;
	bool just_closed_short = false;
	bool order_modified = false;

	if (Bars < 100) {
		Print("bars less than 100");
		return(0);  
	}


	static datetime processed_datetime = 0;
	if (processed_datetime == Time[0]) return(0);
	processed_datetime = Time[0];

//	stop_0 = StrToDouble(DoubleToStr(stop_0, Digits));
	stop_0 = NormalizeDouble(stop_0, Digits);


	// process opened orders: close on signals and adjust stop loss for still-alive
	orders_qnty = OrdersTotal();
	if (orders_qnty > 0) {
		for (i=0; i<orders_qnty; i++) {
			bool order_selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
			if (order_selected == false) {
				log("!!! processing_close_stop_open#1(): cant select order; " + get_error());
				continue;
			} else {
				if (debug_open == 1) OrderPrint();
//				log("processing_close_stop_open(): previous logrecord was about order selected " + i);
			}

			if (OrderCloseTime() != 0) continue;

			if (OrderSymbol() != Symbol()) {
//				log("processing_close_stop_open(" + i + "/" + orders_qnty + "): OrderSymbol[" + OrderSymbol() + "] != Symbol[" + Symbol() + "]; skipping");
				continue;
			}

			double order_lots_current = OrderLots();
			double order_open_price_current = NormalizeDouble(OrderOpenPrice(), Digits);
			double order_stop_loss_current = NormalizeDouble(OrderStopLoss(), Digits);
			double stop_01_delta = stop_0 - order_stop_loss_current;
			double order_takeprofit_current = NormalizeDouble(OrderTakeProfit(), Digits);
			double order_profit_current = OrderProfit();
			double takeprofit_01_delta = 0;

			string tp_first_or_change_msg = "";

			
			switch (OrderType()) {
				case OP_BUY:
					if (signal_close_long == true) {
						log("LONG_CLOSE_" + order_close_reason + "[" + OrderTicket() + "]"
//							+ " cur_profit=[$" + DoubleToStr((Ask - order_open_price_current)*order_lots_current/Point, 2) + "]"
//							+ ": ???profit " + DoubleToStr(order_profit_current, 2)
							+ " " + order_close_message
							);
						order_modified = OrderClose(OrderTicket(), order_lots_current, Bid, slippage, Violet);
						if (order_modified == FALSE) {
							log("LONG_CLOSE_" + order_close_reason + "[" + OrderTicket() + "] failed : " + stop_01_delta
								+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
								+ get_error());
						} else {
							just_closed_long = true;
							ticket_long_current = 0;
							bars_ago_position_open = 0;
						}
					}

					// adjust stoploss to current value
					if (stop_0 != 0 && order_stop_loss_current != stop_0 && just_closed_long == false
//							&& (IsTesting() && stop_0 <= Close[0])
						) {

						if (stop_0 < order_stop_loss_current && stop_moveaway_allow == false) {
							mark_stop(stop_0, Red);
							order_stop_reason = order_stop_reason + "_NOT_MOVED_AWAY_"
//								+ DoubleToStr(order_stop_loss_current, Digits) + "->"
								+ DoubleToStr(stop_0, Digits)
								+ "_-$" + DoubleToStr((stop_0 - order_stop_loss_current)*order_lots_current/Point, 2)
								;
						}

						if (stop_0 > order_stop_loss_current		// don't modify the same when when (stop_0 == order_stop_loss_current)
								|| order_stop_loss_current == 0		// on the previous bars we got 130//Invalid stops => try it again?
							) {
							order_modified = OrderModify(OrderTicket(), order_open_price_current, stop_0, order_takeprofit_current, 0, Green);
							if (order_modified == false) {
								log("LONG_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "] failed :  " + DoubleToStr(stop_01_delta, Digits)
									+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
									+ get_error());
							} else {
								order_stop_loss_current = stop_0;	// for printing correct locked_profit, log() right below
							}
						}

						log("LONG_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "]:"
							+ " locked_profit=[$" + DoubleToStr((order_stop_loss_current - order_open_price_current)*order_lots_current/Point, 2) + "]"
							+ " cur_profit=[$" + DoubleToStr((Bid - order_open_price_current)*order_lots_current/Point, 2) + "]"
							+ " cur_risk=[$" + DoubleToStr((Bid - stop_0)*order_lots_current/Point, 2) + "]"
//							+ " < $" + DoubleToStr((Ask - order_stop_loss_current)*order_lots_current/Point, 2)
//							+ " diff=["+ DoubleToStr(stop_01_delta, Digits) + "]"
							+ "=[" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "]"
							);
					}

					// adjust takeprofit to current value
//					log("takeprofit_0=" + DoubleToStr(takeprofit_0, Digits) + " order_takeprofit_current=" + DoubleToStr(order_takeprofit_current, Digits) + " just_closed_long=" + just_closed_long);
					if (takeprofit_0 != 0 && order_takeprofit_current != takeprofit_0 && just_closed_long == false) {
//						if (takeprofit_0 < order_takeprofit_current) {
							takeprofit_01_delta = takeprofit_0 - order_takeprofit_current;

							tp_first_or_change_msg = " FIRST_TIME [" + DoubleToStr(takeprofit_0, Digits) + "]";
							if (order_takeprofit_current != 0) {
								tp_first_or_change_msg = ""
									+ " diff=[" + DoubleToStr(takeprofit_01_delta, Digits) + "]"
									+ " [" + DoubleToStr(order_takeprofit_current, Digits) + " > " + DoubleToStr(takeprofit_0, Digits) + "] "
									;
							}

							log("LONG_TAKEPROFIT" + "" + "[" + OrderTicket() + "]:"
								+ tp_first_or_change_msg
								+ " expected_profit=[$" + DoubleToStr((order_open_price_current - takeprofit_0)*order_lots_current/Point, 2) + "]"
								+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Ask)*order_lots_current/Point, 2) + "]"
								);

							order_modified = OrderModify(OrderTicket(), order_open_price_current, order_stop_loss_current, takeprofit_0, 0, Green);
							if (order_modified == false) {
								log("LONG_TAKEPROFIT" + "" + "[" + OrderTicket() + "] failed :  " + DoubleToStr(takeprofit_01_delta, Digits)
									+ " [" + DoubleToStr(order_takeprofit_current, Digits) + " > " + DoubleToStr(takeprofit_0, Digits) + "] "
									+ get_error());
							} else {
								bool order_selected2 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
								if (order_selected2 == false) {
									log("!!! 2processing_close_stop_open(): continue; " + get_error());
								}
//								OrderPrint();
								order_takeprofit_current = takeprofit_0;
							}
//						}
					}


					break;

				
				case OP_SELL:
					if (signal_close_short == true) {
						log("SHORT_CLOSE_" + order_close_reason + "[" + OrderTicket() + "]"
//							+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Bid)*order_lots_current/Point, 2) + "]"
//							+ "]: ???profit " + DoubleToStr(order_profit_current, 2)
							+ " " + order_close_message
							);
						order_modified = OrderClose(OrderTicket(), order_lots_current, Ask, slippage, Violet);
						if (order_modified == FALSE) {
							log("SHORT_CLOSE_" + order_close_reason + "[" + OrderTicket() + "] failed : " + get_error());
						} else {
							just_closed_short = true;
							ticket_short_current = 0;
							bars_ago_position_open = 0;
						}
					}

					// adjust stoploss to current value
					if (stop_0 != 0 && order_stop_loss_current != stop_0 && just_closed_short == false
//							&& (IsTesting() && stop_0 >= Close[0])
						) {


						if (stop_0 > order_stop_loss_current && stop_moveaway_allow == false) {
							mark_stop(stop_0, Red);
							order_stop_reason = order_stop_reason + "_NOT_MOVED_AWAY_"
//								+ DoubleToStr(order_stop_loss_current, Digits) + "->"
								+ DoubleToStr(stop_0, Digits)
								+ "_-$" + DoubleToStr((stop_0 - order_stop_loss_current)*order_lots_current/Point, 2)
								;


						}

						if (stop_0 < order_stop_loss_current		// don't modify the same when when (stop_0 == order_stop_loss_current)
								|| order_stop_loss_current == 0		// on the previous bars we got 130//Invalid stops => try it again?
							) {
							order_modified = OrderModify(OrderTicket(), order_open_price_current, stop_0, order_takeprofit_current, 0, Green);
							if (order_modified == false) {
								log("SHORT_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "] failed :  " + DoubleToStr(stop_01_delta, Digits)
									+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
									+ get_error());
							} else {
								order_stop_loss_current = stop_0;	// for printing correct locked_profit, log() right below
							}
						}

						log("SHORT_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "]:"
							+ " locked_profit=[$" + DoubleToStr((order_open_price_current - order_stop_loss_current)*order_lots_current/Point, 2) + "]"
							+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Ask)*order_lots_current/Point, 2) + "]"
							+ " cur_risk=[$" + DoubleToStr((stop_0 - Ask)*order_lots_current/Point, 2) + "]"
//							+ " < $" + DoubleToStr((order_stop_loss_current - Bid)*order_lots_current/Point, 2)
//							+ " diff=[" + DoubleToStr(stop_01_delta, Digits) + "]"
							+ "=[" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "]"
							);
					}


					// adjust takeprofit to current value
//					log("takeprofit_0=" + DoubleToStr(takeprofit_0, Digits) + " order_takeprofit_current=" + DoubleToStr(order_takeprofit_current, Digits) + " just_closed_short=" + just_closed_short);
					if (takeprofit_0 != 0 && order_takeprofit_current != takeprofit_0 && just_closed_short == false) {
//						if (takeprofit_0 < order_takeprofit_current) {
							takeprofit_01_delta = order_takeprofit_current - takeprofit_0;

							tp_first_or_change_msg = " FIRST_TIME [" + DoubleToStr(takeprofit_0, Digits) + "]";
							if (order_takeprofit_current != 0) {
								tp_first_or_change_msg = ""
									+ " diff=[" + DoubleToStr(takeprofit_01_delta, Digits) + "]"
									+ " [" + DoubleToStr(order_takeprofit_current, Digits) + " > " + DoubleToStr(takeprofit_0, Digits) + "] "
									;
							}

							log("SHORT_TAKEPROFIT" + "" + "[" + OrderTicket() + "]:"
								+ tp_first_or_change_msg
								+ " expected_profit=[$" + DoubleToStr((order_open_price_current - takeprofit_0)*order_lots_current/Point, 2) + "]"
								+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Ask)*order_lots_current/Point, 2) + "]"
								);

							order_modified = OrderModify(OrderTicket(), order_open_price_current, order_stop_loss_current, takeprofit_0, 0, Green);
							if (order_modified == false) {
								log("SHORT_TAKEPROFIT" + "" + "[" + OrderTicket() + "] failed :  " + DoubleToStr(takeprofit_01_delta, Digits)
									+ " [" + DoubleToStr(order_takeprofit_current, Digits) + " > " + DoubleToStr(takeprofit_0, Digits) + "] "
									+ get_error());
							} else {
								bool order_selected3 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
								if (order_selected3 == false) {
									log("!!! 3processing_close_stop_open(): continue; " + get_error());
								}
//								OrderPrint();
								order_takeprofit_current = takeprofit_0;
							}
//						}
					}

					break;

			} //switch
		} // for (i=0; i<orders_qnty; i++) {
	} // process opened orders


	RefreshRates();
   	// open positions
	orders_qnty = OrdersTotal();
	
//	if (orders_qnty < 10) {		//can limit only 1 open order at once, but for for EURUSD + USDCAD should be 2 etc

	int ordersopen_forsymbol = 0;
	for (i=0; i<orders_qnty; i++) {
		bool order_selected4 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
		if (order_selected4 == false) {
			log("!!! processing_close_stop_open#2(): cant select order; " + get_error());
			continue;
		}

		if (OrderCloseTime() != 0) continue;
		if (OrderSymbol() == Symbol()) ordersopen_forsymbol++;
	}
	


/*

void bartext_append(string objname_prefix = "", string objname_suffix = "", string bartext = ""
			, int below0_above1 = 0, int bar = 0, double y_coordinate = 0
			, int recent_limit = 100, bool bartext_create = true) {
void mark_line(int bar_start, double y_coordinate_start, int bar_end = 0, double y_coordinate_end = 0
		, color line_color = Gold, color line_width = 1, color line_style = STYLE_DOT
		, bool bartext_create = true, int below0_above1 = 0
		, bool delete = 0) {
*/


	if (ordersopen_forsymbol >= simuni_positions_open) {
		if (signal_open_long == true && ticket_long_current > 0) {
			bartext_append(ea_name, "", "+" + (ordersopen_forsymbol+1) + "L", 0);
			mark_line(0, Ask, 0, 0, DarkTurquoise, 5, STYLE_DOT, false);
			log("+" + ordersopen_forsymbol + "_MORE_LONG_OPEN_" + order_open_reason
				+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
				+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
				);
		}

		if (signal_open_short == true && ticket_short_current > 0) {
			bartext_append(ea_name, "", "+" + (ordersopen_forsymbol+1) + "S", 1);
			mark_line(0, Bid, 0, 0, DarkTurquoise, 5, STYLE_DOT, false);
			log("+" + ordersopen_forsymbol + "_MORE_SHORT_OPEN_" + order_open_reason
				+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
				+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
				);
		}
	}

	if (on_simuni_remove_tp == 1) {
		double takeprofit_before_reset = 0;
		if (signal_open_long == true && ticket_short_current > 0) {
			if (OrderSelect(ticket_short_current, SELECT_BY_TICKET, MODE_TRADES)) {
				takeprofit_before_reset = OrderTakeProfit();
				OrderModify(ticket_short_current, OrderOpenPrice(), OrderStopLoss(), 0, 0, Green);
				log("SHORT_TAKEPROFIT_CANCELLED_SIMUNI[" + ticket_short_current + "]"
					+ " stop[" + DoubleToStr(OrderStopLoss(), Digits) + "]"
					+ " tp[" + DoubleToStr(takeprofit_before_reset, Digits) + "]"
					+ " => [" + DoubleToStr(OrderOpenPrice(), Digits) + "]"
				);
			}
		}

		if (signal_open_short == true && ticket_long_current > 0) {
			if (OrderSelect(ticket_long_current, SELECT_BY_TICKET, MODE_TRADES)) {
				takeprofit_before_reset = OrderTakeProfit();
				OrderModify(ticket_long_current, OrderOpenPrice(), OrderStopLoss(), 0, 0, Green);
				log("LONG_TAKEPROFIT_CANCELLED_SIMUNI[" + ticket_short_current + "]"
					+ " stop[" + DoubleToStr(OrderStopLoss(), Digits) + "]"
					+ " tp[" + DoubleToStr(takeprofit_before_reset, Digits) + "]"
					+ " => [" + DoubleToStr(OrderOpenPrice(), Digits) + "]"
				);
			}
		}
	}



	if (ordersopen_forsymbol < simuni_positions_open) {		//can limit only 1 open order at once for 1 chart (how much multiple positions)
		if(AccountFreeMargin() < (1000*5)) {		//1000*lots
			Print("We have no money. Free Margin = ", AccountFreeMargin());
			return(0);  
		}


		double open_loss = 0;
		double lots = 0;

		// open long
		if (signal_open_long == true) {
			if (open_both0_long1_short2 == 0 || open_both0_long1_short2 == 1) {
				lots = lots_fixed;
			
				log("LONG_OPEN_" + order_open_reason
//					+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
					+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
					+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
					+ " lots=" + DoubleToStr(lots, 1)
					+ " risk=$" + DoubleToStr((Bid - stop_0)*lots/Point, 2)
//					+ " order_stop_message={" + order_stop_message + "}"
//					+ " order_takeprofit_message{" + order_takeprofit_message + "}"
//					+ " order_open_message{" + order_open_message + "}"
//					+ " Ask=" + DoubleToStr(Ask, Digits) //+ " stop_0=" + DoubleToStr(stop_0, Digits)
//					+ " Low[0]=" + DoubleToStr(Low[0], Digits) + " Close[1]=" + DoubleToStr(Close[1], Digits)
					);

//				ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, stop_0, takeprofit_0, order_open_reason + "_long", magic, 0, Green);
				ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, 0, 0, order_open_reason + "_long", magic, 0, Green);
				if (ticket > 0) {
					ticket_long_current = ticket;
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
						if (stop_0 != 0) {
							order_modified =OrderModify(ticket, OrderOpenPrice(), stop_0, takeprofit_0, 0, Green);
							if (order_modified == FALSE) {
								log("LONG_MODIFIED[" + ticket + "]/[" + OrderTicket() + "] failed: " + get_error());
								OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
								OrderPrint();

								if (stop_onfail_emergencypips == true) {
									double stop_0_el = pips_stop_calculation(stoploss_emergencypips, 0);
									bool order_modified_el = OrderModify(ticket, OrderOpenPrice(), stop_0_el, takeprofit_0, 0, Red);
									if (order_modified_el == FALSE) {
										mark_stop(stop_0_el, Orange);
										log("LONG_MODIFIED_EMERGENCY[" + ticket + "]/[" + OrderTicket() + "] failed: " + get_error());
										OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
										OrderPrint();
									} else {
										mark_stop(stop_0_el, Brown);
										if (debug_modify == 1) {
											log("LONG_MODIFIED_EMERGENCY[" + ticket + "]"
												+ " STOP_EMERGENCY_FIXEDPIPS" + stoploss_pips + "=" + DoubleToStr(stop_0_el, Digits)
												+ ":OrderStopLoss=" + DoubleToStr(OrderStopLoss(), Digits)
												+ " TP=" + DoubleToStr(takeprofit_0, Digits)
												+ ":OrderTakeProfit=" + DoubleToStr(OrderTakeProfit(), Digits)
												+ " risk=$" + DoubleToStr(open_loss*lots/Point, 2)
												+ " OrderOpenPrice=" + DoubleToStr(OrderOpenPrice(), Digits)
												);
										}
									}
								}
							} else {
								OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
								open_loss = OrderOpenPrice() - OrderStopLoss();
								if (debug_modify == 1) {
									log("LONG_MODIFIED[" + ticket + "]"
										+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
										+ ":OrderStopLoss=" + DoubleToStr(OrderStopLoss(), Digits)
										+ " TP=" + DoubleToStr(takeprofit_0, Digits)
										+ ":OrderTakeProfit=" + DoubleToStr(OrderTakeProfit(), Digits)
										+ " risk=$" + DoubleToStr(open_loss*lots/Point, 2)
										+ " OrderOpenPrice=" + DoubleToStr(OrderOpenPrice(), Digits)
										);
								}
							}
						}
					}
				} else {
					Print("Error opening BUY order : ", get_error());
				}
			} else {
				log("LONG_OPEN_" + order_open_reason
//					+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
					+ " WAS NOT OPEN because (open_both0_long1_short2=" + open_both0_long1_short2 + ")"
					+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
					+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
					);
			}

			return(0);
		} // open long


		// open short
		if (signal_open_short == true) {
			if (open_both0_long1_short2 == 0 || open_both0_long1_short2 == 2) {
				lots = lots_fixed;
				log("SHORT_OPEN_" + order_open_reason
//					+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
					+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
					+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
					+ " lots=" + DoubleToStr(lots, 1)
					+ " risk=$" + DoubleToStr((stop_0 - Ask)*lots/Point, 2)
//					+ " order_stop_message={" + order_stop_message + "}"
//					+ " order_takeprofit_message{" + order_takeprofit_message + "}"
//					+ " order_open_message{" + order_open_message + "}"
//					+ " Bid=" + DoubleToStr(Bid, Digits) //+ " stop_0=" + DoubleToStr(stop_0, Digits)
//					+ " High[0]=" + DoubleToStr(High[0], Digits) + " Close[1]=" + DoubleToStr(Close[1], Digits)
					);

//				ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, stop_0, takeprofit_0, order_open_reason + "_short", magic, 0, Red);
				ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, 0, 0, order_open_reason + "_short", magic, 0, Red);
				if (ticket > 0) {
					ticket_short_current = ticket;
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
						if (stop_0 != 0) {
							order_modified = OrderModify(ticket, OrderOpenPrice(), stop_0, takeprofit_0, 0, Red);
							if (order_modified == FALSE) {
								log("SHORT_MODIFIED[" + ticket + "]/[" + OrderTicket() + "]"
									+ " failed : " + get_error());
								OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
								OrderPrint();
								
								if (stop_onfail_emergencypips == true) {
									double stop_0_es = pips_stop_calculation(stoploss_emergencypips, 1);
									bool order_modified_es = OrderModify(ticket, OrderOpenPrice(), stop_0_es, takeprofit_0, 0, Red);
									if (order_modified_es == FALSE) {
										mark_stop(stop_0_es, Orange);
										log("SHORT_MODIFIED_EMERGENCY[" + ticket + "]/[" + OrderTicket() + "]"
											+ " failed : " + get_error());
										OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
										OrderPrint();
									} else {
										mark_stop(stop_0_es, Brown);
										if (debug_modify == 1) {
											log("SHORT_MODIFIED_EMERGENCY[" + ticket + "]"
												+ " STOP_EMERGENCY_FIXEDPIPS" + stoploss_pips + "=" + DoubleToStr(stop_0_es, Digits)
												+ ":OrderStopLoss=" + DoubleToStr(OrderStopLoss(), Digits)
												+ " TP=" + DoubleToStr(takeprofit_0, Digits)
												+ ":OrderTakeProfit=" + DoubleToStr(OrderTakeProfit(), Digits)
												+ " risk=$" + DoubleToStr(open_loss*lots/Point, 2)
												+ " OrderOpenPrice=" + DoubleToStr(OrderOpenPrice(), Digits)
												);
										}
									}
								}
							} else {
								OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
								open_loss = OrderStopLoss() - OrderOpenPrice();
								if (debug_modify == 1) {
									log("SHORT_MODIFIED[" + ticket + "]"
										+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
										+ ":OrderStopLoss=" + DoubleToStr(OrderStopLoss(), Digits)
										+ " TP=" + DoubleToStr(takeprofit_0, Digits)
										+ ":OrderTakeProfit=" + DoubleToStr(OrderTakeProfit(), Digits)
										+ " risk=$" + DoubleToStr(open_loss*lots/Point, 2)
										+ " OrderOpenPrice=" + DoubleToStr(OrderOpenPrice(), Digits)
										);
								}
							}
						}
					}
				} else {
					Print("Error opening SELL order : ", get_error());
				}
			} else {
				log("SHORT_OPEN_" + order_open_reason
//					+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
					+ " WAS NOT OPEN because (open_both0_long1_short2=" + open_both0_long1_short2 + ")"
					+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
					+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
					);
			}

			return(0); 
		} // open short

	} // open positions if (orders_qnty < 10)

} // order_processing




void invalidate_tickets_closedbystop() {
	static datetime follow_open_last_checked;

	bool selected = false;
	int orders_qnty = OrdersHistoryTotal();

//	if (orders_qnty == 0) {
//		ticket_long_current = 0;
//		ticket_short_current = 0;
//		return (0);
//	}

	selected = OrderSelect(ticket_long_current, SELECT_BY_TICKET, MODE_HISTORY);
//	log("ticket_long_current[" + ticket_long_current + "]: selected=" + selected
//		+ "; OrderCloseTime=" +  TimeToStr(OrderCloseTime(), TIME_MINUTES)
//		);
	if (selected == true && OrderCloseTime() != 0) {
		log("ticket_long_current[" + ticket_long_current + "]: invalidated"
			+ "; profit=$" + DoubleToStr(OrderProfit(), 2)
			);
		ticket_long_current = 0;
	}

	selected = OrderSelect(ticket_short_current, SELECT_BY_TICKET, MODE_HISTORY);
//	log("ticket_short_current[" + ticket_short_current + "]: selected=" + selected
//		+ "; OrderCloseTime=" +  TimeToStr(OrderCloseTime(), TIME_MINUTES)
//		);
	if (selected == true && OrderCloseTime() != 0) {
		log("ticket_short_current[" + ticket_short_current + "]: invalidated"
			+ "; profit=$" + DoubleToStr(OrderProfit(), 2)
			);
		ticket_short_current = 0;
	}

}



double pips_stop_calculation(int stoploss_pips = 0, int long0_or_short1 = 0) {
	double stop_0 = 0;

	if (long0_or_short1 == 0) {
		stop_0 = NormalizeDouble(Bid - stoploss_pips * onepip_afterdecimal, Digits);
		order_stop_reason = "PIPS-" + stoploss_pips;
		order_stop_message = "stop_0=[" + DoubleToStr(stop_0, Digits) + "]"
			+ " stoploss_pips=[" + stoploss_pips + "]"
			+ " Ask=[" + DoubleToStr(Ask, Digits) + "]"
			+ " Point=[" + DoubleToStr(Point, Digits) + "]"
			;
//		log("dumb_trailing_stop_calculation(" + ticket + "): LONG new STOP=" + DoubleToStr(trail_stop, Digits));
		return(stop_0);
	}
	
	if (long0_or_short1 == 1) {
		stop_0 = NormalizeDouble(Ask + stoploss_pips * onepip_afterdecimal, Digits);
		order_stop_reason = "PIPS-" + stoploss_pips;
		order_stop_message = "stop_0=[" + DoubleToStr(stop_0, Digits) + "]"
			+ " stoploss_pips=[" + stoploss_pips + "]"
			+ " Ask=[" + DoubleToStr(Ask, Digits) + "]"
			+ " Point=[" + DoubleToStr(Point, Digits) + "]"
			;
//		log("dumb_trailing_stop_calculation(" + ticket + "): LONG new STOP=" + DoubleToStr(trail_stop, Digits));
		return(stop_0);
	}	
}


double pips_takeprofit_calculation(int takeprofit_pips = 0, int long0_or_short1 = 0) {
	double takeprofit_0 = 0;

	if (long0_or_short1 == 0) {
		takeprofit_0 = NormalizeDouble(Ask + takeprofit_pips * onepip_afterdecimal, Digits);
		order_takeprofit_reason = "LONG_TAKEPROFIT_PIPS-" + stoploss_pips;
		order_takeprofit_message = "takeprofit_0=[" + DoubleToStr(takeprofit_0, Digits) + "]"
			+ " takeprofit_pips=[" + takeprofit_pips + "]"
			+ " Ask=[" + DoubleToStr(Ask, Digits) + "]"
			+ " Point=[" + DoubleToStr(Point, Digits) + "]"
			;
//		log("dumb_trailing_stop_calculation(" + ticket + "): LONG new STOP=" + DoubleToStr(trail_stop, Digits));
		return(takeprofit_0);
	}
	
	if (long0_or_short1 == 1) {
		takeprofit_0 = NormalizeDouble(Bid - takeprofit_pips * onepip_afterdecimal, Digits);
		order_takeprofit_reason = "SHORT_TAKEPROFIT_PIPS-" + stoploss_pips;
		order_takeprofit_message = "takeprofit_0=[" + DoubleToStr(takeprofit_0, Digits) + "]"
			+ " takeprofit_pips=[" + takeprofit_pips + "]"
			+ " Ask=[" + DoubleToStr(Ask, Digits) + "]"
			+ " Point=[" + DoubleToStr(Point, Digits) + "]"
			;
//		log("dumb_trailing_stop_calculation(" + ticket + "): LONG new STOP=" + DoubleToStr(trail_stop, Digits));
		return(takeprofit_0);
	}
}




void show_stats() {
	string ret = "";
	string text_key = "LockedProfit_" + Symbol();

	int orders_qnty = OrdersTotal();

	if (orders_qnty == 0) {
		ObjectDelete(text_key);
		return(0);
	}
	
	int this_chart_orders = 0;
	for (int i=0; i<orders_qnty; i++) {
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() != Symbol()) continue;
		if (OrderCloseTime() != 0) continue;
		this_chart_orders++;
	
		double order_lots_current = OrderLots();
		double order_open_price_current = OrderOpenPrice();
		double order_stop_loss_current = OrderStopLoss();
		double order_takeprofit_current = OrderTakeProfit();
		double order_profit_current = OrderProfit();
		datetime order_open_time = OrderOpenTime();
	
		if (ret != "") ret = ret + " | ";
		ret = ret + DoubleToStr(order_lots_current, 1) // + " lot"
			// + "@" + TimeToStr(order_open_time, TIME_MINUTES)
			;
	
		switch (OrderType()) {
			case OP_BUY:
					if (order_stop_loss_current > order_open_price_current) {
						ret = ret + " $locked +"
							+ DoubleToStr((order_stop_loss_current - order_open_price_current)*order_lots_current/Point, 2);	// profit from SL
					} else {
						ret = ret + " $risk -"
							+ DoubleToStr((order_open_price_current - order_stop_loss_current)*order_lots_current/Point, 2);
					}

					if (order_takeprofit_current > 0) {
						ret = ret + ".."
							+ DoubleToStr((order_takeprofit_current - order_open_price_current)*order_lots_current/Point, 2);						
					}
	
					ret = ret + " / "
//						+ DoubleToStr((Ask - order_open_price_current - (Ask-Bid))*order_lots_current/Point, 2);
						+ DoubleToStr((Bid - order_open_price_current)*order_lots_current/Point, 2);
	
					break;
	
	
			case OP_SELL:
					if (order_stop_loss_current < order_open_price_current) {
						ret = ret + " $locked +"
							+ DoubleToStr((order_open_price_current - order_stop_loss_current)*order_lots_current/Point, 2);	// profit from SL
					} else {
						ret = ret + " $risk -"
							+ DoubleToStr((order_stop_loss_current - order_open_price_current)*order_lots_current/Point, 2);		// risk
					}

					if (order_takeprofit_current > 0) {
						ret = ret + ".."
							+ DoubleToStr((order_open_price_current - order_takeprofit_current)*order_lots_current/Point, 2);						
					}
	
					ret = ret + " / "
//						+ DoubleToStr((order_open_price_current - Bid - (Ask-Bid))*order_lots_current/Point, 2);
						+ DoubleToStr((order_open_price_current - Ask)*order_lots_current/Point, 2);
	
					break;
	
				default:
					break;
	
		}
	}
	
	if (this_chart_orders == 0) ObjectDelete(text_key);

	if (ret != "") {
//		log (stats_locked_profit_text);
		ObjectCreate(text_key, OBJ_LABEL, 0, 0, 0);
		ObjectSet   (text_key, OBJPROP_CORNER, stats_corner);
		ObjectSet   (text_key, OBJPROP_XDISTANCE, stats_xdis);
		ObjectSet   (text_key, OBJPROP_YDISTANCE, stats_ydis);
		ObjectSetText(text_key, ret, stats_fontSize, stats_font, stats_fontColor);
	}
}


bool skip_first_rest_ticks(int first_ticks_to_skip=0, int invoke_everyTick0_oncePerBar1=1) {
	static datetime curbar_datetime = 0;
//	if (curbar_datetime != Time[0]) {
//		curbar_datetime = Time[0];
//	}

	static int ticks_after_new_bar = 0;
	static int ticks_in_prev_bar = 0;
	static int first_tick_of_new_bar = 0;

	if (curbar_datetime == Time[0]) {
		ticks_after_new_bar ++;
		return(true);	// yes skip all the ticks
	}
//	everything below will be activated from first tick of new bar till 10th tick

	if (curbar_datetime != Time[0]) {
		curbar_datetime = Time[0];
		ticks_in_prev_bar = ticks_after_new_bar;
		//log("new bar: ticks_in_prev_bar =" + ticks_after_new_bar);
		ticks_after_new_bar = 0;
	}

	ticks_after_new_bar ++;

	if (ticks_after_new_bar < first_ticks_to_skip) {
		return(true);	// yes skip all the ticks
	}

	return(false);		// no don't skip and continue main algo
}


void start_common() {
//	log("start(" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "): ticks_after_new_bar=" + ticks_after_new_bar
//		+ " ticks_in_prev_bar=" + ticks_in_prev_bar);


	RefreshRates();

	invalidate_tickets_closedbystop();
	show_stats();
	print_current_settings();
	
	signal_open_long = false;
	signal_open_short = false;
	signal_close_long = false;
	signal_close_short = false;

	stop_0 = 0;
	takeprofit_0 = 0;

	order_open_reason = "";
	order_open_message = "";

	order_close_reason = "";
	order_close_message = "";

	order_stop_reason = "";
	order_stop_message = "";

	order_takeprofit_reason = "";
	order_takeprofit_message = "";
	
}


int set_global_as_external(int overwrite = 1) {
	int ret = 0;
	datetime set_datetime = 99;

	if (ret == 0) {
		set_datetime = GlobalVariableSet(globalvar_prefix + "bars2wait", bars2wait);
		if (set_datetime == 0) ret = GetLastError();
	}

	if (ret == 0) {
		set_datetime = GlobalVariableSet(globalvar_prefix + "bars2watch", bars2watch);
		if (set_datetime == 0) ret = GetLastError();
	}


	if (ret == 0) {
		set_datetime = GlobalVariableSet(globalvar_prefix + "bars2trade", bars2trade);
		if (set_datetime == 0) ret = GetLastError();
	}


	if (ret != 0) {
		log ("set_global_as_external(): " + get_error());
	}
	
}

void print_current_settings() {
	string ret = "";

	string orb_names_array[] = {
		"bars2wait",
		"bars2watch",
		"bars2trade"
	};
	
	string sltp_names_array[] = {
		"stoploss_pips",
		"takeprofit_pips"
	};	
	
	ret = ret + concat_global_values(orb_names_array,	"orb ", "\n");
	ret = ret + concat_global_values(sltp_names_array,	"SL/TP ");

	Comment(ea_name + "\n" + ret
		//+ "start() " + " | " + 
//		+ TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS)
		);

}



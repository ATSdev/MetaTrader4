		string	common_lib_objprefix = "lib_common-v2";

		string	ea_name				= "CHART";	// indicator shouln'd worry about ea's stuff
		string	ea_onchart			= "CHART";
		string	short_name			= "";

		// reinit in init() of an indicator or adviser
		string	indicator_objprefix = "indicator_objprefix_UNINITIALIZED";
		string	indicator_logprefix = "indicator_logprefix_UNINITIALIZED::";
		string	globalvar_prefix	= "globalvar_objprefix_UNINITIALIZED";

		bool	debug_delobj					= false;
		bool	debug_bartext_append			= false;
		bool	debug_mark_line					= false;
		bool	debug_mark_line_create			= false;
		bool	debug_mark_rectangle			= false;
		bool	debug_mark_rectangle_create		= false;
		int		debug_was_trade_long1_short2	= 1;


// both EA and indicator
static	datetime	opentime_lastbar = 0;
static	datetime	opentime_lastbar_roundminute 	= 0;
		
extern	int		invoke_everyTick0_oncePerBar1	= 1;
extern	int		first_ticks_to_skip				= 0;
extern	int		debug_skip_first_ticks			= 0;

		int		indicator_precision = 4;


// EA
extern	string	lib_comment					= "==== Position Support settings below";

		int		slippage					= 3;
		int		magic						= 8833063;

extern	int		tradeable_monday			= 1;
extern	int		tradeable_tuesday			= 1;
extern	int		tradeable_wednesday			= 1;
extern	int		tradeable_thursday			= 1;
extern	int		tradeable_friday			= 1;
		int 	tradeable_saturday			= 0;
		int 	tradeable_sunday			= 0;

extern	bool 	debug_non_tradeable			= true;
extern	bool 	mark_non_tradeable			= true;

		int		dow_tradeable[]				= {0,0,0,0,0,0,0};		// 7 days all non-tradeable; initialized in init_common()
		string	dow_param_names[]			= {"XXX-SUN", "tradeable_monday", "tradeable_tuesday", "tradeable_wednesday", "tradeable_thursday", "tradeable_friday", "XXX-SAT"};
		string	dow_human_names[]			= {"SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};
		string	dow_short_names[]			= {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};
		string	dow_tradeable_eacomment		= "";


extern	int		stoploss_pips				= 30;
extern	int		stoploss_pips_apply			= 1;
extern	bool	stoploss_mark				= true;
		color	stoploss_color				= Red;
extern	int		stop_moveaway_allow			= 1;	// 1 - set stops far from price even if manual stop were more tight
extern	bool	stop_moveaway_mark			= false;
		bool	stop_onfail_emergencypips	= true;
		int		stoploss_emergencypips		= 10;

extern	int		takeprofit_pips				= 100;
extern	int		takeprofit_pips_apply		= 1;
extern	bool	takeprofit_mark				= true;
		color	takeprofit_color			= Green;

extern	int		broker_onopen_sl_tp			= 1;


		double	onepip_afterdecimal			= 0.0001;
		int 	simuni_positions_open		= 1;
		int 	on_simuni_remove_tp			= 0;
extern	int		open_both0_long1_short2		= 0;

extern	double	lots_fixed 					= 0.01;		// default lot size if mm_maxrisk_apply = 0


extern	int		debug_open					= 0;
extern	int		debug_stoploss				= 0;
extern	int		debug_modify				= 0;
extern	int		debug_close					= 0;



		double	takeprofit_0	= 0;
		double	stop_0			= 0;
	//	double	trailingstop	= 0;

static	datetime	processed_datetime = 0;

		bool	signal_open_long = false;
		bool	signal_open_short = false;
		bool	signal_close_long = false;
		bool	signal_close_short = false;

		string	order_open_reason = "";
		string	order_open_message = "";
		string	order_close_reason = "";
		string	order_close_message = "";
		string	order_stop_reason = "";
		string	order_stop_message = "";
		string	order_takeprofit_reason = "";
		string	order_takeprofit_message = "";


static	int		ticket_long_current = 0;
static	int		ticket_short_current = 0;

static	int		long_ticket_array[];
static	int		short_ticket_array[];
static	int		open_orders_qnty = 0;
static	int		bars_ago_position_open = 0;


		int		stats_corner = 3;
		int		stats_xdis = 10;
		int		stats_ydis = 10;
		string	stats_font = "Lucida Console";
		int		stats_fontSize = 8;
		color	stats_fontColor = Gold;




string period_as_string(int period_analyzed_current0 = 0) {
	int period_analyzed = Period();
	if (period_analyzed_current0 != 0) period_analyzed = period_analyzed_current0;
	
	switch(period_analyzed) {
		case PERIOD_M1:		return("M1"); break;
		case PERIOD_M5:		return("M5"); break;
		case PERIOD_M15:	return("M15"); break;
		case PERIOD_M30:	return("M30"); break;
		case PERIOD_H1:		return("H1"); break;
		case PERIOD_H4:		return("H4"); break;
		case PERIOD_D1:		return("D1"); break;
		case PERIOD_W1:		return("W1"); break;
		case PERIOD_MN1:	return("MN1"); break;
	}
}



int deinit_common() {
	log("deinit_common():"
		+ " ea_calledfrom[" + ea_calledfrom + "]"
		+ " IsVisualMode()=" + IsVisualMode() + " IsTesting()=" + IsTesting() + " IsExpertEnabled()=" + IsExpertEnabled()
		+ " IsConnected()=" + IsConnected() + " IsDemo()=" + IsDemo() + " IsOptimization()=" + IsOptimization()
		);

/*	int obects_deleted = 0;
	int total=ObjectsTotal();
	for(int i=total-1; i>=0; i--) {
		string name=ObjectName(i);
		if (StringFind(name, common_lib_objprefix) == 0) {
			ObjectDelete(name);
			obects_deleted++;
		}
	}
	log("deinit_common(): Deleted objects: " + obects_deleted);
*/

	ObjectDelete("LockedProfit");

	int globals_deleted = GlobalVariablesDeleteAll(globalvar_prefix);
	log("deinit(" + globalvar_prefix + "): " + globals_deleted + " globals deleted");

	log("deinit_common(): " + get_deinit_reason());
	return(0);
}


/*
double ticket_profit(int ticket, int bars_back = 0) {
	double ret = 0;

	if (ticket > 0) {
		bool selected = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
		if (selected == true) {
			if (bars_back == 0) {
				ret = OrderProfit();
			} else {

				switch(OrderType()) {
					case OP_BUY:
						ret = Close[bars_back] - OrderOpenPrice();
//						log ("ticket_profit(" + ticket + ", " + bars_back + "): "
//							 + " Close[" + bars_back + "]=[" + DoubleToStr(Close[bars_back], 2)+ "]"
//							 + " OrderOpenPrice()=[" + DoubleToStr(OrderOpenPrice(), 2)+ "]"
//							);
						break;

					case OP_SELL:
						ret = OrderOpenPrice() - Close[bars_back];
//						log ("ticket_profit(" + ticket + ", " + bars_back + "): "
//							 + " Close[" + bars_back + "]=[" + DoubleToStr(Close[bars_back], 2)+ "]"
//							 + " OrderOpenPrice()=[" + DoubleToStr(OrderOpenPrice(), 2)+ "]"
//							);
						break;
					
					default:
						log ("ticket_profit(" + ticket + ", " + bars_back + "): CAN NOT calculate profit for OrderType != OP_SELL or OP_BUY");
				}
			
			}

//			log ("ticket_profit(" + ticket + ", " + bars_back + ") = " + DoubleToStr(ret, 2)
//				+ "; OrderProfit() = " + DoubleToStr(OrderProfit(), 2));

		}
	}
		
	return(ret);
}
*/


/*
double stop_4ticket(int ticket) {
	double ret = 0;

	if (ticket > 0) {
		bool selected = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
		if (selected == true) {
			ret = OrderStopLoss();
		}
	}
		
	return(ret);
}
*/

string concat_global_values(string names_array[]
		, string title = "", string newline_or_space = "\n", int precision = 0, string separator = ","
		, string prefix = " (", string suffix = ")", bool print_name = false
		, string msg_not_exists = "!exs", string msg_error_get = "!!-get", string varname_specials_token = ":") {

	string ret = "";

	separator = separator + " ";		//	if (precision > 0) 

	for (int i=0; i<ArraySize(names_array); i++) {
		string globalvar_name = names_array[i];
		if (globalvar_name == "") continue;		//happens when array("a", "b", "c", ) - last is ""

		string globalvar_string = "";
		string globalvar_beforetext = "";
		int globalvar_precision = precision;
		string globalvar_spec_precision_str = 0;
		double globalvar_double = 0;

//		"atr_stop_k:1",
//		"atr_stop_afterprofit:1:>$",

// first is precision
		int globalvar_spec_precision_index = StringFind(globalvar_name, varname_specials_token);
		if (globalvar_spec_precision_index > 0) {

 			int globalvar_spec_precision_len = StringLen(globalvar_name) - globalvar_spec_precision_index;

			int globalvar_spec_prefix_index = StringFind(globalvar_name, varname_specials_token, globalvar_spec_precision_index + 1);
			if (globalvar_spec_prefix_index > 0) {
				globalvar_beforetext = StringSubstr(globalvar_name, globalvar_spec_prefix_index + 1, StringLen(globalvar_name));
//				log ("globalvar_name[" + globalvar_name + "] "
//					+ "globalvar_spec_prefix_index[" + globalvar_spec_prefix_index + "] "
//					+ "globalvar_beforetext[" + globalvar_beforetext + "] "
//					);
				globalvar_spec_precision_len = globalvar_spec_precision_len - StringLen(globalvar_beforetext) - 2;
			}

			globalvar_spec_precision_str = StringSubstr(globalvar_name
					, globalvar_spec_precision_index + 1, globalvar_spec_precision_len);
//			log ("globalvar_name[" + globalvar_name + "] "
//				+ "globalvar_spec_precision_str[" + globalvar_spec_precision_str + "] "
//				);
			if (StrToInteger(globalvar_spec_precision_str) > 0) {
				globalvar_precision = StrToInteger(globalvar_spec_precision_str);
			}


			globalvar_name = StringSubstr(globalvar_name, 0, globalvar_spec_precision_index);
//			log ("globalvar_name[" + globalvar_name + "] "
//				+ "globalvar_spec_prefix_index[" + globalvar_spec_prefix_index + "] "
//				+ "globalvar_beforetext[" + globalvar_beforetext + "] "
//				+ "globalvar_spec_precision_index[" + globalvar_spec_precision_index + "] "
//				+ "globalvar_precision[" + globalvar_precision + "] "
//				);

		}

		 
		globalvar_name = globalvar_prefix + globalvar_name;
		if (GlobalVariableCheck(globalvar_name) == TRUE) {
//			log(globalvar_name);
			globalvar_double = GlobalVariableGet(globalvar_name);
//			if (GetLastError() == 0) {
				if (ret != "") ret = ret + separator;
			
				if (print_name == true)	ret = ret + globalvar_name + "[";
				globalvar_string = DoubleToStr(globalvar_double, globalvar_precision);
				ret = ret + globalvar_beforetext + globalvar_string;
				if (print_name == true)	ret = ret + "]";

//			} else {
//				if (ret != "") ret = ret + separator;
//				ret = ret + globalvar_name
//					+ "[" + msg_error_get + "]"
////					+ get_error()
//				;
//			}

		} else {
			if (ret != "") ret = ret + separator;
			ret = ret + globalvar_name
				+ "[" + msg_not_exists + "]"
//				+ GetLastError()
				+ get_error()
				;
		}


//		} else {
//			ret = ret + globalvar_name;

	}

	ret = title + prefix + ret + suffix + newline_or_space;
	return(ret);
}



		int lib_max_bars_4objects = 100;
		int lib_dots_recent_limit = 20;
		int lib_lines_recent_limit = 100;
		int lib_bartext_recent_limit = 100;
		int lib_lines_bartext_create = true;
		int lib_backgrounds_recent_limit = 150;


void mark_stop(int bar, int bar_start = 0, double y_coordinate_start = 0
		, color line_color = Gold, color line_width = 5, color line_style = STYLE_DOT
		, string objname_prefix = "", string objname_suffix = "") {

	mark_line(bar, bar_start, y_coordinate_start, bar_start, y_coordinate_start
		, line_color, line_width, line_style
		, objname_prefix, objname_suffix);
// double printing, with bartext_create = visualize labels on multiple pcatr dots on same bar - for debugging indicator
//	mark_line(bar_start, y_coordinate_start, bar_start, y_coordinate_start, line_color, line_width, line_style, bartext_create, below0_above1);
}

void mark_line(int bar, int bar_start, double y_coordinate_start, int bar_end = -999, double y_coordinate_end = 0
		, color line_color = Gold, color line_width = 1, color line_style = STYLE_SOLID
		, string objname_prefix = "", string objname_suffix = ""
		, bool bartext_create = false, int below0_above1 = 0, bool delete = 0) {

	static int lines_created = 0;

	if (objname_prefix == "")	objname_prefix = ea_name;
	if (objname_suffix == "")	objname_suffix = bar_timestamp(0);	// why not bar_timestamp(bar)?

	string line_type = "-line";
	if (line_style == STYLE_DOT) line_type = "-dot";

	string lines_cleanup_prefix = objname_prefix + line_type;
	string line_name = lines_cleanup_prefix + objname_suffix;
	//line_name = line_name + zeroes_prefixed(lines_created);

//	if (delete) ObjectDelete(line_name);
	if (bar_start > lib_max_bars_4objects) return(0);

	if (y_coordinate_start == 0) return(0);
	if (y_coordinate_end == 0) y_coordinate_end = y_coordinate_start;
	if (bar_end == -999) bar_end = bar_start+1;

	if (ObjectFind(line_name) == -1) {
		ObjectCreate(line_name, OBJ_TREND, 0, Time[bar_start], y_coordinate_start, Time[bar_end], y_coordinate_end);

		if (debug_mark_line_create) {
			log("mark_line(" + format_datetime(Time[bar_start], "bar_start", true) + ", " + DoubleToStr(y_coordinate_start, Digits)
			 	+ ", " + format_datetime(Time[bar_end], "bar_start", true) + ", " + DoubleToStr(y_coordinate_end, Digits) + ")");
		}

		int recent_limit = lib_lines_recent_limit;
		if (line_style == STYLE_DOT) recent_limit = lib_dots_recent_limit;
		delobj_prefixedby_overlimit(lines_cleanup_prefix, recent_limit, OBJ_TREND);
		
//		bartext_append(line_name_prefix, line_name_dt, lines_created, below0_above1
//			, bar_start, y_coordinate_start, recent_limit, bartext_create);

// imitation of positioning same lib_dot on same bar
//		bartext_append(line_name_prefix, line_name_dt, lines_created, below0_above1
//			, bar_start, y_coordinate_start, recent_limit);

		lines_created++;
	} else {
		bool dot_needs_tobe_moved = false;

		double prev_time1 = ObjectGet(line_name, OBJPROP_TIME1);
		double prev_price1 = ObjectGet(line_name, OBJPROP_PRICE1);
		double prev_time2 = ObjectGet(line_name, OBJPROP_TIME2);
		double prev_price2 = ObjectGet(line_name, OBJPROP_PRICE2);

		if (prev_time1	!= Time[bar_start])		dot_needs_tobe_moved = true;
		if (prev_price1 != y_coordinate_start)	dot_needs_tobe_moved = true;
		if (prev_time2	!= Time[bar_end])		dot_needs_tobe_moved = true;
		if (prev_price2 != y_coordinate_end)	dot_needs_tobe_moved = true;

		if (dot_needs_tobe_moved == true) {
			ObjectMove(line_name, 0, Time[bar_start],	y_coordinate_start);
			ObjectMove(line_name, 1, Time[bar_end],	y_coordinate_end);
			if (debug_mark_line) {
				log("mark_line(" + format_datetime_4bar(bar, "bar", true) + ", " + line_name //+ ", " + line_name_text
						 	+ ") ObjectMoved " + TimeToStr(Time[bar_start], TIME_DATE) + ":"
					+ " time1[" + TimeToStr(prev_time1, TIME_SECONDS) + ">" + TimeToStr(Time[bar_start], TIME_SECONDS) + "]"
					+ " price1[" + DoubleToStr(prev_price1, Digits) + ">" + DoubleToStr(y_coordinate_start, Digits) + "]"
					+ " time2[" + TimeToStr(prev_time2, TIME_SECONDS) + ">" + TimeToStr(Time[bar_end], TIME_SECONDS) + "]"
					+ " price2[" + DoubleToStr(prev_price2, Digits) + ">" + DoubleToStr(y_coordinate_end, Digits) + "]"
					);
			}
		} else {
			if (debug_mark_line) {
				log("mark_line(" + format_datetime_4bar(bar, "bar", true) + ", " + line_name //+ ", " + line_name_text
							+ ") NoNeedToMove " + TimeToStr(Time[bar_start], TIME_DATE) + ":"
					+ " time1[" + TimeToStr(Time[bar_start], TIME_SECONDS) + "]"
					+ " price1[" + DoubleToStr(y_coordinate_start, Digits) + "]"
					+ " time2[" + TimeToStr(Time[bar_end], TIME_SECONDS) + "]"
					+ " price2[" + DoubleToStr(y_coordinate_end, Digits) + "]"
			 		);
			}
		}

//		ObjectMove(line_name, 0, Time[bar_start], y_coordinate_start);
//		ObjectMove(line_name, 1, Time[bar_end], y_coordinate_end);
//		log("mark_line-ObjectMove(" + Time[bar_start] + ", " + DoubleToStr(y_coordinate_start, Digits)
//		 	+ ", " + Time[bar_end] + ", " + DoubleToStr(y_coordinate_end, Digits) + ")");

	}

	ObjectSet(line_name, OBJPROP_COLOR,	line_color);
	ObjectSet(line_name, OBJPROP_WIDTH,	line_width);
	ObjectSet(line_name, OBJPROP_STYLE,	line_style);
	ObjectSet(line_name, OBJPROP_RAY,		false);
}

void mark_background(int bar, color rectangle_color = LightSlateGray, string objname_prefix = "", string objname_suffix = ""
		, int bar_start = 0, double y_coordinate_start = 0, int bar_end = 0, double y_coordinate_end = 0, int recent_limit = 0) {
		
	static int rectangles_created = 0;

	if (objname_prefix == "")	objname_prefix = ea_name;
	if (objname_suffix == "")	objname_suffix = bar_timestamp(0);	// why not bar_timestamp(bar)?

	string rectangle_name = objname_prefix + objname_suffix;
	rectangle_name = rectangle_name + "_bg";		// + "_" + zeroes_prefixed(rectangles_created)

	if (bar_start > lib_max_bars_4objects) return(0);

	if (y_coordinate_start	== 0)	y_coordinate_start	= Low[1];
	if (y_coordinate_end	== 0)	y_coordinate_end	= High[1];
	if (bar_start			== 0)	bar_start			= bar;
	if (bar_end				== 0)	bar_end				= bar_start - 1;
	if (recent_limit		== 0)	recent_limit		= lib_backgrounds_recent_limit;

	if (ObjectFind(rectangle_name) == -1) {
		ObjectCreate(rectangle_name, OBJ_RECTANGLE, 0
			, Time[bar_start], y_coordinate_start, Time[bar_end], y_coordinate_end);

		if (debug_mark_rectangle_create == true) {
			log("mark_background(" + format_datetime_4bar(bar, "bar", true) + ", " + rectangle_name + "): "
				+        format_datetime_4bar(bar_start,	"start"	, true)	+ "/" + format_double(y_coordinate_start)
		 		+ ", " + format_datetime_4bar(bar_end,		"end"	, true)		+ "/" + format_double(y_coordinate_end));
		}

		ObjectSet(rectangle_name, OBJPROP_BACK, true);

		//delobj_prefixedby_overlimit(objname_prefix, recent_limit, OBJ_RECTANGLE);
		
		rectangles_created++;
	} else {
		bool rectangle_needs_tobe_moved = false;

		double prev_time1	= ObjectGet(rectangle_name, OBJPROP_TIME1);
		double prev_price1	= ObjectGet(rectangle_name, OBJPROP_PRICE1);
		double prev_time2	= ObjectGet(rectangle_name, OBJPROP_TIME2);
		double prev_price2	= ObjectGet(rectangle_name, OBJPROP_PRICE2);

		//if (prev_time1	!= Time[bar_start])		rectangle_needs_tobe_moved = true;
		//if (prev_price1 > y_coordinate_start) 	rectangle_needs_tobe_moved = true;
		//if (prev_price2 > y_coordinate_end)		rectangle_needs_tobe_moved = true;
		if (prev_price1 != y_coordinate_start) 	rectangle_needs_tobe_moved = true;
		if (prev_price2 != y_coordinate_end)	rectangle_needs_tobe_moved = true;
		if (prev_time2	!= Time[bar_end])		rectangle_needs_tobe_moved = true;

		if (rectangle_needs_tobe_moved == true) {
			//ObjectMove(rectangle_name, 0, prev_time1, MathMin(prev_price1, y_coordinate_start));
			//ObjectMove(rectangle_name, 1, Time[bar_end], MathMax(prev_price2, y_coordinate_end));
			ObjectMove(rectangle_name, 0, prev_time1, y_coordinate_start);
			ObjectMove(rectangle_name, 1, Time[bar_end], y_coordinate_end);
			if (debug_mark_rectangle) {
				log("mark_background(" + format_datetime_4bar(bar, "bar", true) + ", " + rectangle_name //+ ", " + mark_background_name_text
						 	+ ") ObjectMoved " + TimeToStr(Time[bar_start], TIME_DATE) + ":"
	//				+ " time1[" + TimeToStr(prev_time1, TIME_SECONDS) + ">" + TimeToStr(Time[bar_start], TIME_SECONDS) + "]"
					+ " price1[" + DoubleToStr(prev_price1, Digits) + ">" + DoubleToStr(y_coordinate_start, Digits) + "]"
					+ " time2[" + TimeToStr(prev_time2, TIME_SECONDS) + ">" + TimeToStr(Time[bar_end], TIME_SECONDS) + "]"
					+ " price2[" + DoubleToStr(prev_price2, Digits) + ">" + DoubleToStr(y_coordinate_end, Digits) + "]"
					);
			}
		} else {
			if (debug_mark_rectangle) {
				log("mark_background(" + format_datetime_4bar(bar, "bar", true) + ", " + rectangle_name //+ ", " + mark_background_name_text
							+ ") NoNeedToMove " + TimeToStr(Time[bar_start], TIME_DATE) + ":"
					+ " time1[" + TimeToStr(Time[bar_start], TIME_SECONDS) + "]"
					+ " price1[" + DoubleToStr(y_coordinate_start, Digits) + "]"
					+ " time2[" + TimeToStr(Time[bar_end], TIME_SECONDS) + "]"
					+ " price2[" + DoubleToStr(y_coordinate_end, Digits) + "]"
		 			);
		 	}
		}

	}

	ObjectSet(rectangle_name, OBJPROP_COLOR, rectangle_color);
}




void bartext_append(int bar = 0, string bartext = "", int below0_above1 = 0
			, string objname_prefix = "", string objname_suffix = "", bool append_counter = true
			, color text_color = Gold, double y_coordinate = 0, bool bartext_create = true) {

	static int texts_created = 0;
	
	if (bartext_create == false) return;
	if (lib_lines_bartext_create == false) return;

	if (objname_prefix == "") objname_prefix = ea_name;
	if (objname_suffix == "") objname_suffix = bar_timestamp(0);

	string bartext_name = objname_prefix + objname_suffix;
	if (append_counter == true) {
		bartext_name = bartext_name + "_" + zeroes_prefixed(texts_created) + "_text";
	}
	if (bartext == "") bartext = objname_prefix;
//	bartext = bartext + "_" + texts_created;

	if (y_coordinate == 0) {
		y_coordinate = Low[bar];
		if (below0_above1 == 1) y_coordinate = High[bar];

		// on current bar High=Low=Open, so we get the previous completed bar
		if (bar == 0) {
			y_coordinate = Low[bar+1];
			if (below0_above1 == 1) y_coordinate = High[bar+1];
		}
	}

	y_coordinate = y_coordinate + mark_spacer(below0_above1, objname_prefix + objname_suffix, bar, OBJ_TEXT);

	if (ObjectFind(bartext_name) == -1) {
		ObjectCreate(bartext_name, OBJ_TEXT, 0, Time[bar], y_coordinate);
		ObjectSetText(bartext_name, bartext, 9, "Courier New", text_color);
		texts_created++;

		//log("bartext_append(objname_prefix[" + objname_prefix + "] => bartext_name[" + bartext_name + "]): "
		//	+ " " + format_datetime_4bar(bar, "bar", true)
		//	+ " " + format_double(y_coordinate, "y_coordinate"));

	} else {
		bool text_needs_tobe_moved = false;

		double prev_time = ObjectGet(bartext_name, OBJPROP_TIME1);
		double prev_price = ObjectGet(bartext_name, OBJPROP_PRICE1);

		if (prev_time	!= Time[bar])		text_needs_tobe_moved = true;
		if (prev_price	!= y_coordinate)	text_needs_tobe_moved = true;


		if (text_needs_tobe_moved == true) {
			ObjectMove(bartext_name, 0, Time[bar], y_coordinate);
			if (debug_bartext_append == true) {
				log("common_lib::bartext_append(" + bartext_name //+ ", " + bartext
						+ ") ObjectMove " + TimeToStr(Time[bar], TIME_DATE) + ":"
					+ " time[" + TimeToStr(prev_time, TIME_SECONDS) + ">" + TimeToStr(Time[bar], TIME_SECONDS) + "]"
					+ " price[" + DoubleToStr(prev_price, Digits) + ">" + DoubleToStr(y_coordinate, Digits) + "]"
					);
			}
		} else {
			if (debug_bartext_append == true) {
				log("common_lib::bartext_append(" + bartext_name //+ ", " + bartext
						+ ") NoNeedToMove " + TimeToStr(Time[bar], TIME_DATE) + ":"
					+ " time[" + TimeToStr(Time[bar], TIME_SECONDS) + "]"
					+ " price[" + DoubleToStr(y_coordinate, Digits) + "]"
					);
			}
		}


//		ObjectMove(bartext_name, 0, Time[bar], y_coordinate);
	}

	int recent_limit = lib_bartext_recent_limit;
	if (recent_limit > 0 && !IsTesting()) delobj_prefixedby_overlimit(objname_prefix, recent_limit, OBJ_TEXT);
}

/*
int smaller_period() {
	int ret = 0;
	
	switch(Period()) {
		case PERIOD_M1:		ret = 0; break;
		case PERIOD_M5:		ret = PERIOD_M1; break;
		case PERIOD_M15:	ret = PERIOD_M5; break;
		case PERIOD_M30:	ret = PERIOD_M15; break;
		case PERIOD_H1:		ret = PERIOD_M30; break;
		case PERIOD_H4:		ret = PERIOD_H1; break;
		case PERIOD_D1:		ret = PERIOD_H4; break;
		case PERIOD_W1:		ret = PERIOD_D1; break;
		case PERIOD_MN1:	ret = PERIOD_W1; break;
	}

	return (ret);
}
*/

// on M30, larger_period(3) should return D1
int larger_period(int shift_larger = 1, int current_period = 0) {
	int ret = 0;
	if (current_period == 0) current_period = Period();
	
	for (int i=1; i<=shift_larger; i++) {
		switch(current_period) {
			case PERIOD_M1:		ret = PERIOD_M5; break;
			case PERIOD_M5:		ret = PERIOD_M15; break;
			case PERIOD_M15:	ret = PERIOD_M30; break;
			case PERIOD_M30:	ret = PERIOD_H1; break;
			case PERIOD_H1:		ret = PERIOD_H4; break;
			case PERIOD_H4:		ret = PERIOD_D1; break;
			case PERIOD_D1:		ret = PERIOD_W1; break;
			case PERIOD_W1:		ret = PERIOD_MN1; break;
			case PERIOD_MN1:	ret = 0; break;
		}
		
		current_period = ret;
	}
	
	return (ret);
}



double mark_spacer(int below0_above1 = 0, string objname_prefix = "", int bar = 0, int objtype = EMPTY) {
	double ret = 0;

	switch(Period()) {
		case PERIOD_M1:		ret = 5; break;
		case PERIOD_M5:		ret = 10; break;
		case PERIOD_M15:	ret = 15; break;
		case PERIOD_M30:	ret = 20; break;
		case PERIOD_H1:		ret = 30; break;
		case PERIOD_H4:		ret = 40; break;
		case PERIOD_D1:		ret = 80; break;
		case PERIOD_W1:		ret = 150; break;
		case PERIOD_MN1:	ret = 200; break;
	}

/* v1
	double font_height = 8;
	double multiplier = 6*Point;
	double initial_indent = 6*Point;
	ret *= multiplier;
   	ret += initial_indent;

	if (below0_above1 == 0) {
		ret = -ret;
     	ret -= font_height*multiplier;	// in points ~=font height
	}
*/

	double font_height = 8;
	double multiplier = Point*font_height*1.3;
	double initial_indent = Point*font_height*15;

	ret *= multiplier;

	if (below0_above1 == 0) {
		ret = -ret;
     	ret += font_height*multiplier;	// in points ~=font height
	}
	
	
	double spacefor_repeatedobjects = 0;
	if (objname_prefix != "") {
		int objects_for_bar = objects_for_bar(objname_prefix, bar, objtype);

		spacefor_repeatedobjects = initial_indent;
		spacefor_repeatedobjects += font_height*multiplier * objects_for_bar;

		if (below0_above1 == 0) {
     		ret -= spacefor_repeatedobjects;
		} else {
     		ret += spacefor_repeatedobjects;
		}
	}

	return(ret);
}


int objects_for_bar(string objname_prefix = "", int bar = 0, int objtype = EMPTY) {
	int ret = 0;

	for (int i=ObjectsTotal()-1; i>=0; i--) {
		if (StringFind(ObjectName(i), objname_prefix) == -1) continue;
		if (objtype != EMPTY && ObjectType(ObjectName(i)) != objtype) continue;
		if (GetLastError() == 4202) {
//			log ("GetLastError() == 4202 after ObjectName(" + i + ")");
//			log ("GetLastError() == 4202 after ObjectType(" + i + ":" + ObjectName(i) + ")");
			continue;
		}
		
		datetime object_datetime = ObjectGet(ObjectName(i), OBJPROP_TIME1);
		datetime bar_datetime = iTime(NULL, 0, bar);
//		log("object_datetime=[" + object_datetime + "]" + " bar_datetime=[" + bar_datetime + "]");

		if (object_datetime != bar_datetime) continue;

		ret++;
	}

	return(ret);
}





int delobj_prefixedby_overlimit(string objname_prefix = "", int recent_limit = -1, int objtype2delete = EMPTY) {
	int ret = 0;

	int objcnt_found = 0;
//	int objtotal = ObjectsTotal();
//	log("delobj_prefixedby_overlimit(" + objname_prefix + ", " + recent_limit + ", " + objtype + ") objtotal=" + objtotal);

	if (recent_limit == -1) {
		log("delobj_prefixedby_overlimit(" + objname_prefix + ", " + recent_limit + ", " + objtype2delete + ") recent_limit=" + recent_limit + "; old objects not deleted");
		return(ret);
	}

	for (int i=ObjectsTotal()-1; i>=0; i--) {
		if (StringFind(ObjectName(i), objname_prefix) == -1) {
			if (debug_delobj) {
				log("objname_prefix=[" + objname_prefix + "] not found for ObjectName(" + i + ")=[" + ObjectName(i) + "]");
			}
			continue;
		}
		if (objtype2delete != EMPTY && ObjectType(ObjectName(i)) != objtype2delete) {
			//if (debug_delobj) {
			//	log("ObjectType=[" + ObjectType(ObjectName(i)) + "] != objtype2delete=[" + objtype2delete + "]");
			//}
			continue;
		}
		if (GetLastError() == 4202) {
//			log ("GetLastError() == 4202 after ObjectName(" + i + ")");
//			log ("GetLastError() == 4202 after ObjectType(" + i + ":" + ObjectName(i) + ")");
			continue;
		}
		
		objcnt_found++;

		if (debug_delobj) {
			log("DELETING ObjectName=[" + ObjectName(i) + "], of objtype2delete=[" + objtype2delete + "]=" + ObjectType(ObjectName(i))
				+ " i=[" + i + "] objcnt_found=[" + objcnt_found + "]>recent_limit=[" + recent_limit + "]"
				);
		}

		if (objcnt_found > recent_limit) {
			bool deleted = ObjectDelete(ObjectName(i));
			if (deleted == TRUE) ret++;
			if (debug_delobj) {
				log("DELETED[" + deleted + "] ObjectName=[" + ObjectName(i) + "], of objtype2delete=[" + objtype2delete + "]=" + ObjectType(ObjectName(i))
					+ " i=[" + i + "] objcnt_found=[" + objcnt_found + "]>recent_limit=[" + recent_limit + "]"
					);
			}
		}
	}
	
	if (debug_delobj) {
		//if (ret > 0) 
		log("delobj_prefixedby_overlimit('" + objname_prefix + "', " + recent_limit + ", " + objtype2delete + ") objects_deleted=" + ret);
	}
	return(ret);
}


int delete_chart_objects(string objprefix="delete_chart_objects(): objprefix MUST_BE_PASSED") {
	int obects_found = 0;
	int obects_deleted = 0;
	int total=ObjectsTotal();
	string deleted_names = "";

	for(int i=total-1; i>=0; i--) {
		string name = ObjectName(i);
		int deleted = false;
		if (StringFind(name, objprefix) == 0) {
			obects_found++;
			deleted = ObjectDelete(name);
			if (deleted == TRUE) {
				obects_deleted++;
				if (deleted_names != "") deleted_names = deleted_names  + ",";
				deleted_names = deleted_names  + name;
			}

			if (GetLastError() == 4202) {
				log ("deinit()"
					+ " after StringFind(" + name + ")"
					+ " GetLastError() == 4202 after ObjectDelete(" + name + "); obj_index=" + i);
				continue;
			}
		}

	}

	string log_msg = "delete_chart_objects(): Deleted objects: " + obects_deleted + " of " + obects_found + " found [" + objprefix + "*]";
	if (obects_deleted <= 10) log_msg = log_msg + "[" + deleted_names + "]";

	log(log_msg);

	return(0);
}





string MonthName(int month = 0, int short0_long1 = 0) {
	string ret = "UNKNOWN_MONTH";

	string month_names_long_array[] = {"ZeroMonth", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
	string month_names_short_array[] = {"ZeroMonth", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
	
	string month_names_array[];// = month_names_short_array;
	ArrayCopy(month_names_array, month_names_short_array);
//	if (short0_long1 == 1) month_names_array = month_names_long_array;
	if (short0_long1 == 1) ArrayCopy(month_names_array, month_names_long_array);

	ret = month_names_array[month];
	return(ret);
}

string zeroes_prefixed(double value = 0, int zeroed_length = 3, int double_precision = 0, string zero_char = "0") {
	string ret = DoubleToStr(value, double_precision);
	while (StringLen(ret) < zeroed_length) ret = zero_char + ret;
	return (ret);
}

string bar_timestamp(int bar = 0, string prefix="@") {
	string ret = "";
	datetime bar_datetime = iTime(NULL, 0, bar);
	ret = prefix + MonthName(TimeMonth(bar_datetime)) + "/" + zeroes_prefixed(TimeDay(bar_datetime), 2)
			+ " " + zeroes_prefixed(TimeHour(bar_datetime), 2) + ":" + zeroes_prefixed(TimeMinute(bar_datetime), 2);
	return(ret);
}


string hourmin_timestamp(int hour, int min) {
	string ret = "";
	ret = "@" + zeroes_prefixed(TimeDay(TimeCurrent()), 2) + MonthName(TimeMonth(TimeCurrent()))
			+ zeroes_prefixed(hour, 2) + ":" + zeroes_prefixed(min, 2)
			;
	return(ret);
}


double empty2zero(double val) {
	if (val == EMPTY_VALUE) val = 0;
	return (val);
}

string double_to_str(double val, int indicator_precision=0) {
	if (val == EMPTY_VALUE) return("[EMPTY]");
	if (val == 0) return("0");
	if (indicator_precision == -1) return (DoubleToStr(round(val, 0), 0));
	if (indicator_precision == 0) indicator_precision = Digits;
	return (DoubleToStr(val, indicator_precision));
}

double round(double value, int precision = 4) {
	int multiplier = MathPow(10, precision);
	value *= multiplier;
	value = MathRound(value);
	value /= multiplier;
	return(value);
}

string format_double(double double_value, string prefix="", int indicator_precision=0, bool wrap_in_brackets = true) {
	string ret = double_to_str(double_value, indicator_precision);
	if (wrap_in_brackets == true) ret = "[" + ret + "]";
	if (prefix != "") ret = prefix + "=" + ret;
	return(ret);
}

string format_datetime(datetime extract_time_from, string prefix="", bool append_month_day = false, bool wrap_in_brackets = true) {
	string ret = "";
	if (extract_time_from == 0) {
		ret = ret + "NULL";
	} else {
		ret = ret + zeroes_prefixed(TimeHour(extract_time_from), 2) + ":" + zeroes_prefixed(TimeMinute(extract_time_from), 2);
		if (append_month_day == true) ret = MonthName(TimeMonth(extract_time_from)) + "/" + zeroes_prefixed(TimeDay(extract_time_from), 2) + "th " + ret;
	}
	if (wrap_in_brackets == true) ret = "[" + ret + "]";
	if (prefix != "") ret = prefix + "=" + ret;
//	ret = ret + extract_time_from + ":";
	return(ret);
}


string format_datetime_4bar(int bar, string prefix="", bool append_month_day=false, bool substract_day_for_negative=false, bool wrap_in_brackets = true) {
	//if (bar >= Bars && bar < 0) {
		if (bar < 0 && substract_day_for_negative == true) bar = bar + bars_in_whole_day();
		datetime date_existing = Time[bar];
		return(format_datetime(date_existing, prefix, append_month_day, wrap_in_brackets));
	//} else {
	//	string failure_reason = "<0";
	//	if (bar >= Bars) failure_reason = ">Bars[" + Bars + "]";
	//	string errormsg = prefix + "=[" + bar + "]" + failure_reason;
	//	log("\r\n\t\t !!! " + errormsg);
	//	return(errormsg);
	//}
}


int bars_in_whole_day() {
	switch(Period()) {
		case PERIOD_M1:		return(60*24);
		case PERIOD_M5:		return(12*24);
		case PERIOD_M15:	return(4*24);
		case PERIOD_M30:	return(2*24);
		case PERIOD_H1:		return(24);
		case PERIOD_H4:		return(6);
		case PERIOD_D1:		return(1);
		default:			return(0);
	}
}





string get_deinit_reason() {
	string deinit_reason_string;
	int deinit_reason = UninitializeReason();
	
	switch (deinit_reason) {
		case 0: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Script finished its execution independently");	break;
		case REASON_REMOVE: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Expert removed from chart");	break;
		case REASON_RECOMPILE: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Expert recompiled");	break;
		case REASON_CHARTCHANGE: deinit_reason_string = StringConcatenate("[", deinit_reason, "] symbol or timeframe changed on the chart");	break;
		case REASON_CHARTCLOSE: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Chart closed");	break;
		case REASON_PARAMETERS: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Inputs parameters was changed by user");	break;
		case REASON_ACCOUNT: deinit_reason_string = StringConcatenate("[", deinit_reason, "] Other account activated");	break;
		default:   deinit_reason_string = StringConcatenate("[", deinit_reason, "] UNKNOWN_deinit_REASON");
	}
	return(deinit_reason_string);
}


int log(string msg, bool print_zero_bar=false, bool print_ea_name=true) {
	if (print_zero_bar == true) {
		msg = format_datetime_4bar(0, "bar", true) + " " + msg;
	}
	
	if (print_ea_name == true) {
		msg = "{" + ea_name + "} " + msg;
	}
	
	if (!IsOptimization()
//		&& !IsTesting()
		) {
		Print(msg);
	}
}

int log_file(string msg, string indicator_logprefix, string abspath="C:/Program Files/FXCM MT4 powered by BT/experts/files/") {
//	if (!IsOptimization()
//		&& !IsTesting()
//		) {
//		Print(msg);
//	}

	msg = indicator_logprefix + msg;	

	string fname = indicator_logprefix + ".log";
	int handle;
	
	handle = FileOpen(abspath + fname, FILE_READ | FILE_WRITE | FILE_CSV);

	if (handle < 1) {
		Print("File [" + abspath + fname + "] not found, the last error is ", GetLastError());
		return(false);
    } else {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle, msg, "\n");
		FileClose(handle);
		handle=0;
	}

}









#include <stderror.mqh>
#include <stdlib.mqh>

string get_error() {
	string error_string;
	int error_code = GetLastError();
	return (ErrorDescription(error_code));

	switch(error_code) {
		//---- Коды, возвращаемые торговым сервером
		case    0:	break;
		case    1: error_string = StringConcatenate("[", error_code, "] Нет ошибок");                                                  break;
		case    2: error_string = StringConcatenate("[", error_code, "] Общая ошибка");                                                break;
		case    3: error_string = StringConcatenate("[", error_code, "] Неправильные торговые параметры");                             break;
		case    4: error_string = StringConcatenate("[", error_code, "] Торговый сервер занят");                                       break;
		case    5: error_string = StringConcatenate("[", error_code, "] Версия клиентского терминала устарела");                       break;
		case    6: error_string = StringConcatenate("[", error_code, "] Нет соединения с торговым сервером");                          break;
		case    7: error_string = StringConcatenate("[", error_code, "] Недостаточно прав");                                           break;
		case    8: error_string = StringConcatenate("[", error_code, "] Слишком частые запросы на торговый сервер");                   break;
		case    9: error_string = StringConcatenate("[", error_code, "] Недопустимая операция, нарушающая функционирование сервера");  break;
		case   64: error_string = StringConcatenate("[", error_code, "] Счет заблокирован");                                           break;
		case   65: error_string = StringConcatenate("[", error_code, "] Неправильный номер счета");                                    break;
		case  128: error_string = StringConcatenate("[", error_code, "] Истек срок ожидания совершения сделки");                       break;
		case  129: error_string = StringConcatenate("[", error_code, "] Инвалидная цена");                                             break;
		case  130: error_string = StringConcatenate("[", error_code, "] Инвалидный стоп");                                             break;
		case  131: error_string = StringConcatenate("[", error_code, "] Инвалидный торговый объём");                                   break;
		case  132: error_string = StringConcatenate("[", error_code, "] Рынок закрыт");                                                break;
		case  133: error_string = StringConcatenate("[", error_code, "] Торговля запрещена");                                          break;
		case  134: error_string = StringConcatenate("[", error_code, "] Недостаточно денег для совершения операции");                  break;
		case  135: error_string = StringConcatenate("[", error_code, "] Цена изменилась");                                             break;
		case  136: error_string = StringConcatenate("[", error_code, "] Нет цен");                                                     break;
		case  137: error_string = StringConcatenate("[", error_code, "] Брокер занят");                                                break;
		case  138: error_string = StringConcatenate("[", error_code, "] Новые цены");                                                  break;
		case  139: error_string = StringConcatenate("[", error_code, "] Ордер заблокирован и уже обрабатывается");                     break;
		case  140: error_string = StringConcatenate("[", error_code, "] Разрешена только покупка");                                    break;
		case  141: error_string = StringConcatenate("[", error_code, "] Слишком много запросов");                                      break;
		case  145: error_string = StringConcatenate("[", error_code, "] Модификация запрещена, так как ордер слишком близок к рынку"); break;
		case  146: error_string = StringConcatenate("[", error_code, "] Подсистема торговли занята");                                  break;
		case  147: error_string = StringConcatenate("[", error_code, "] Использование даты истечения ордера запрещено брокером");      break;   
		case  148: error_string = StringConcatenate("Код ошибки = ", error_code,
		                                       ". Количество открытых и отложенных ордеров достигло предела, установленного брокером"); break;
		case  149: error_string = StringConcatenate("Код ошибки = ", error_code,
		                                      ". Попытка открыть противоположную позицию к уже существующей! Хеджирование запрещено!"); break;
		
		//---- MQL4 ошибки 
		case 4000: error_string = StringConcatenate("[", error_code, "] нет ошибки");                                                  break;
		case 4001: error_string = StringConcatenate("[", error_code, "] Неправильный указатель функции");                              break;
		case 4002: error_string = StringConcatenate("[", error_code, "] индекс массива не соответствует его размеру");                 break;
		case 4003: error_string = StringConcatenate("[", error_code, "] Нет памяти для стека функций");                                break;
		case 4004: error_string = StringConcatenate("[", error_code, "] Переполнение стека после рекурсивного вызова");                break;
		case 4005: error_string = StringConcatenate("[", error_code, "] На стеке нет памяти для передачи параметров");                 break;
		case 4006: error_string = StringConcatenate("[", error_code, "] Нет памяти для строкового параметра");                         break;
		case 4007: error_string = StringConcatenate("[", error_code, "] Нет памяти для временной строки");                             break;
		case 4008: error_string = StringConcatenate("[", error_code, "] Неинициализированная строка");                                 break;
		case 4009: error_string = StringConcatenate("[", error_code, "] Неинициализированная строка в массиве");                       break;
		case 4010: error_string = StringConcatenate("[", error_code, "] Нет памяти для строкового массива");                           break;
		case 4011: error_string = StringConcatenate("[", error_code, "] Слишком длинная строка");                                      break;
		case 4012: error_string = StringConcatenate("[", error_code, "] Остаток от деления на ноль");                                  break;
		case 4013: error_string = StringConcatenate("[", error_code, "] Деление на ноль");                                             break;
		case 4014: error_string = StringConcatenate("[", error_code, "] Неизвестная команда");                                         break;
		case 4015: error_string = StringConcatenate("[", error_code, "] Неправильный переход (never generated error)");                break;
		case 4016: error_string = StringConcatenate("[", error_code, "] Неинициализированный массив");                                 break;
		case 4017: error_string = StringConcatenate("[", error_code, "] Вызовы DLL не разрешены");                                     break;
		case 4018: error_string = StringConcatenate("[", error_code, "] Невозможно загрузить библиотеку");                             break;
		case 4019: error_string = StringConcatenate("[", error_code, "] Невозможно вызвать функцию");                                  break;
		case 4020: error_string = StringConcatenate("[", error_code, "] Вызовы внешних библиотечных функций не разрешены");            break;
		case 4021: error_string = StringConcatenate("[", error_code, "] Недостаточно памяти для строки, возвращаемой из функции");     break;
		case 4022: error_string = StringConcatenate("[", error_code, "] Система занята (never generated error)");                      break;
		case 4050: error_string = StringConcatenate("[", error_code, "] Неправильное количество параметров функции");                  break;
		case 4051: error_string = StringConcatenate("[", error_code, "] Недопустимое значение параметра функции");                     break;
		case 4052: error_string = StringConcatenate("[", error_code, "] Внутренняя ошибка строковой функции");                         break;
		case 4053: error_string = StringConcatenate("[", error_code, "] Ошибка массива");                                              break;
		case 4054: error_string = StringConcatenate("[", error_code, "] Неправильное использование массива-таймсерии");                break;
		case 4055: error_string = StringConcatenate("[", error_code, "] Ошибка пользовательского индикатора");                         break;
		case 4056: error_string = StringConcatenate("[", error_code, "] Массивы несовместимы");                                        break;
		case 4057: error_string = StringConcatenate("[", error_code, "] Ошибка обработки глобальныех переменных");                     break;
		case 4058: error_string = StringConcatenate("[", error_code, "] Глобальная переменная не обнаружена");                         break;
		case 4059: error_string = StringConcatenate("[", error_code, "] Функция не разрешена в тестовом режиме");                      break;
		case 4060: error_string = StringConcatenate("[", error_code, "] Функция не подтверждена");                                     break;
		case 4061: error_string = StringConcatenate("[", error_code, "] Ошибка отправки почты");                                       break;
		case 4062: error_string = StringConcatenate("[", error_code, "] Ожидается параметр типа string");                              break;
		case 4063: error_string = StringConcatenate("[", error_code, "] Ожидается параметр типа integer");                             break;
		case 4064: error_string = StringConcatenate("[", error_code, "] Ожидается параметр типа double");                              break;
		case 4065: error_string = StringConcatenate("[", error_code, "] В качестве параметра ожидается массив");                       break;
		case 4066: error_string = StringConcatenate("[", error_code, "] Запрошенные исторические данные в состоянии обновления");      break;
		case 4067: error_string = StringConcatenate("[", error_code, "] Ошибка при выполнении торговой операции");                     break;
		case 4099: error_string = StringConcatenate("[", error_code, "] Конец файла");                                                 break;
		case 4100: error_string = StringConcatenate("[", error_code, "] Ошибка при работе с файлом");                                  break;
		case 4101: error_string = StringConcatenate("[", error_code, "] Неправильное имя файла");                                      break;
		case 4102: error_string = StringConcatenate("[", error_code, "] Слишком много открытых файлов");                               break;
		case 4103: error_string = StringConcatenate("[", error_code, "] Невозможно открыть файл");                                     break;
		case 4104: error_string = StringConcatenate("[", error_code, "] Несовместимый режим доступа к файлу");                         break;
		case 4105: error_string = StringConcatenate("[", error_code, "] Ни один ордер не выбран");                                     break;
		case 4106: error_string = StringConcatenate("[", error_code, "] Неизвестный символ");                                          break;
		case 4107: error_string = StringConcatenate("[", error_code, "] Неправильный параметр цены для торговой функции");             break;
		case 4108: error_string = StringConcatenate("[", error_code, "] Неверный номер тикета");                                       break;
		case 4109: error_string = StringConcatenate("[", error_code, "] Торговля не разрешена");                                       break;
		case 4110: error_string = StringConcatenate("[", error_code, "] Длинные позиции не разрешены");                                break;
		case 4111: error_string = StringConcatenate("[", error_code, "] Короткие позиции не разрешены");                               break;
		case 4200: error_string = StringConcatenate("[", error_code, "] Объект уже существует");                                       break;
		case 4201: error_string = StringConcatenate("[", error_code, "] Запрошено неизвестное свойство объекта");                      break;
		case 4202: error_string = StringConcatenate("[", error_code, "] Объект не существует");                                        break;
		case 4203: error_string = StringConcatenate("[", error_code, "] Неизвестный тип объекта");                                     break;
		case 4204: error_string = StringConcatenate("[", error_code, "] Нет имени объекта");                                           break;
		case 4205: error_string = StringConcatenate("[", error_code, "] Ошибка координат объекта");                                    break;
		case 4206: error_string = StringConcatenate("[", error_code, "] Не найдено указанное подокно");                                break;
		case 4207: error_string = StringConcatenate("[", error_code, "] Ошибка при работе с объектом");                                break;
		default:   error_string = StringConcatenate("[", error_code, "] неизвестная ошибка");
	}
	return(error_string);
}



#property link      "jujik@yahoo.com"

// EA


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
						if (debug_close > 0) {
							log("LONG_CLOSE_" + order_close_reason + "[" + OrderTicket() + "]"
							//	+ " cur_profit=[$" + DoubleToStr((Ask - order_open_price_current)*order_lots_current/Point, 2) + "]"
							//	+ ": ???profit " + DoubleToStr(order_profit_current, 2)
								+ " " + order_close_message
								);
						}
						order_modified = OrderClose(OrderTicket(), order_lots_current, Bid, slippage, Violet);
						if (order_modified == FALSE) {
							if (debug_close > 0) {
								log("LONG_CLOSE_" + order_close_reason + "[" + OrderTicket() + "] failed : " + stop_01_delta
									+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
									+ get_error());
							}
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

						if (stop_0 < order_stop_loss_current && stop_moveaway_allow == 0) {
							if (stop_moveaway_mark == true) mark_stop(0, 0, stop_0, DeepPink);
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
								if (debug_stoploss > 0) {
									log("LONG_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "] failed :  " + DoubleToStr(stop_01_delta, Digits)
										+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
										+ get_error());
								}
							} else {
								order_stop_loss_current = NormalizeDouble(OrderStopLoss(), Digits);		//stop_0;	// for printing correct locked_profit, log() right below
								if (stoploss_mark == 1) mark_stop(0, 0, order_stop_loss_current, stoploss_color);
							}
						}

						if (debug_stoploss > 0) {
							log("LONG_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "]:"
								+ " locked_profit=[$" + DoubleToStr((order_stop_loss_current - order_open_price_current)*order_lots_current/Point, 2) + "]"
								+ " cur_profit=[$" + DoubleToStr((Bid - order_open_price_current)*order_lots_current/Point, 2) + "]"
								+ " cur_risk=[$" + DoubleToStr((Bid - stop_0)*order_lots_current/Point, 2) + "]"
							//	+ " < $" + DoubleToStr((Ask - order_stop_loss_current)*order_lots_current/Point, 2)
							//	+ " diff=["+ DoubleToStr(stop_01_delta, Digits) + "]"
								+ "=[" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "]"
								);
						}
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
								order_takeprofit_current = NormalizeDouble(OrderTakeProfit(), Digits);
								if (takeprofit_mark == 1) mark_stop(0, 0, order_takeprofit_current, takeprofit_color);
							}
//						}
					}


					break;

				
				case OP_SELL:
					if (signal_close_short == true) {
						if (debug_close > 0) {
							log("SHORT_CLOSE_" + order_close_reason + "[" + OrderTicket() + "]"
							//	+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Bid)*order_lots_current/Point, 2) + "]"
							//	+ "]: ???profit " + DoubleToStr(order_profit_current, 2)
								+ " " + order_close_message
								);
						}
						order_modified = OrderClose(OrderTicket(), order_lots_current, Ask, slippage, Violet);
						if (order_modified == FALSE) {
							if (debug_close > 0) {
								log("SHORT_CLOSE_" + order_close_reason + "[" + OrderTicket() + "] failed : " + get_error());
							}
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


						if (stop_0 > order_stop_loss_current && stop_moveaway_allow == 0) {
							if (stop_moveaway_mark == true) mark_stop(1, 0, stop_0, DeepPink);
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
								if (debug_stoploss > 0) {
									log("SHORT_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "] failed :  " + DoubleToStr(stop_01_delta, Digits)
										+ " [" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "] "
										+ get_error());
								}
							} else {
								order_stop_loss_current = NormalizeDouble(OrderStopLoss(), Digits);		//stop_0;	// for printing correct locked_profit, log() right below
								if (stoploss_mark == 1) mark_stop(1, 0, order_stop_loss_current, stoploss_color);
							}
						}

						if (debug_stoploss > 0) {
							log("SHORT_TRAIL_" + order_stop_reason + "[" + OrderTicket() + "]:"
								+ " locked_profit=[$" + DoubleToStr((order_open_price_current - order_stop_loss_current)*order_lots_current/Point, 2) + "]"
								+ " cur_profit=[$" + DoubleToStr((order_open_price_current - Ask)*order_lots_current/Point, 2) + "]"
								+ " cur_risk=[$" + DoubleToStr((stop_0 - Ask)*order_lots_current/Point, 2) + "]"
							//	+ " < $" + DoubleToStr((order_stop_loss_current - Bid)*order_lots_current/Point, 2)
							//	+ " diff=[" + DoubleToStr(stop_01_delta, Digits) + "]"
								+ "=[" + DoubleToStr(order_stop_loss_current, Digits) + " > " + DoubleToStr(stop_0, Digits) + "]"
								);
						}
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
								//order_takeprofit_current = takeprofit_0;
								order_takeprofit_current = NormalizeDouble(OrderTakeProfit(), Digits);
								if (takeprofit_mark == 1) mark_stop(1, 0, order_takeprofit_current, takeprofit_color);
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

	if (signal_open_long == true || signal_open_short == true) {
		string mark_prefix = "!L-NTDOW_";
		if (signal_open_short == true) mark_prefix = "!S-NTDOW_";
		
		int dow_today = TimeDayOfWeek(Time[0]);
		int dow_today_tradeable = dow_tradeable[dow_today];
	
		if (dow_today_tradeable == 0) {
			string dow_today_human_name = dow_human_names[dow_today];
			string dow_today_param_name = dow_param_names[dow_today];
			
			if (mark_non_tradeable == true) {
				//void bartext_append(int bar = 0, string bartext = "", int below0_above1 = 0
				//	, string objname_prefix = "", string objname_suffix = "", bool append_counter = true
				//	, color text_color = Gold, double y_coordinate = 0, bool bartext_create = true) {

				bartext_append(0, mark_prefix + dow_today_human_name, 1);
			}

			if (debug_non_tradeable == true) {
				log("processing_close_stop_open(): NON_TRADING_DAY_OF_WEEK: " + dow_today_human_name
					+ " (" + dow_today_param_name + "=0)"
					+ format_datetime(Time[0], " now", true));
			}

			return(0);
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
				if (debug_open > 0) {
					log("LONG_OPEN_" + order_open_reason
					//	+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
						+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
						+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
						+ " lots=" + DoubleToStr(lots, 1)
						+ " risk=$" + DoubleToStr((Bid - stop_0)*lots/Point, 2)
					//	+ " order_stop_message={" + order_stop_message + "}"
					//	+ " order_takeprofit_message{" + order_takeprofit_message + "}"
					//	+ " order_open_message{" + order_open_message + "}"
					//	+ " Ask=" + DoubleToStr(Ask, Digits) //+ " stop_0=" + DoubleToStr(stop_0, Digits)
					//	+ " Low[0]=" + DoubleToStr(Low[0], Digits) + " Close[1]=" + DoubleToStr(Close[1], Digits)
						);
				}

				if (broker_onopen_sl_tp == 1) {
					ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, stop_0, takeprofit_0, order_open_reason + "_long", magic, 0, Green);
				} else {
					ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, 0, 0, order_open_reason + "_long", magic, 0, Green);
				}
				
				if (ticket > 0) {
					ticket_long_current = ticket;
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
						if (broker_onopen_sl_tp == 0 && stop_0 != 0) {
							order_modified = OrderModify(ticket, OrderOpenPrice(), stop_0, takeprofit_0, 0, Green);
							if (order_modified == FALSE) {
								log("LONG_MODIFIED[" + ticket + "]/[" + OrderTicket() + "] failed: " + get_error());
								OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
								OrderPrint();

								if (stop_onfail_emergencypips == true) {
									double stop_0_el = pips_stop_calculation(stoploss_emergencypips, 0);
									bool order_modified_el = OrderModify(ticket, OrderOpenPrice(), stop_0_el, takeprofit_0, 0, Red);
									if (order_modified_el == FALSE) {
										mark_stop(1, 0, stop_0_el, Orange);
										log("LONG_MODIFIED_EMERGENCY[" + ticket + "]/[" + OrderTicket() + "] failed: " + get_error());
										OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
										OrderPrint();
									} else {
										mark_stop(1, 0, stop_0_el, Brown);
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
					log("LONG_OPEN_" + order_open_reason + " ERROR opening BUY order: " + get_error(), true);
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
				if (debug_open > 0) {
					log("SHORT_OPEN_" + order_open_reason
					//	+ " [" + TimeToStr(processed_datetime, TIME_DATE | TIME_SECONDS) + "]:"
						+ " STOP_" + order_stop_reason + "=" + DoubleToStr(stop_0, Digits)
						+ " TAKEPROFIT=" + DoubleToStr(takeprofit_0, Digits)
						+ " lots=" + DoubleToStr(lots, 1)
						+ " risk=$" + DoubleToStr((stop_0 - Ask)*lots/Point, 2)
					//	+ " order_stop_message={" + order_stop_message + "}"
					//	+ " order_takeprofit_message{" + order_takeprofit_message + "}"
					//	+ " order_open_message{" + order_open_message + "}"
					//	+ " Bid=" + DoubleToStr(Bid, Digits) //+ " stop_0=" + DoubleToStr(stop_0, Digits)
					//	+ " High[0]=" + DoubleToStr(High[0], Digits) + " Close[1]=" + DoubleToStr(Close[1], Digits)
						);
				}

				if (broker_onopen_sl_tp == 1) {
					ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, stop_0, takeprofit_0, order_open_reason + "_short", magic, 0, Red);
				} else {
					ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, 0, 0, order_open_reason + "_short", magic, 0, Red);
				}
				
				if (ticket > 0) {
					ticket_short_current = ticket;
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
						if (broker_onopen_sl_tp == 0 && stop_0 != 0) {
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
										mark_stop(1, 0, stop_0_es, Orange);
										log("SHORT_MODIFIED_EMERGENCY[" + ticket + "]/[" + OrderTicket() + "]"
											+ " failed : " + get_error());
										OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
										OrderPrint();
									} else {
										mark_stop(1, 0, stop_0_es, Brown);
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
					log("SHORT_OPEN_" + order_open_reason + " ERROR opening SELL order: " + get_error(), true);
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

	stop_0 = 0;
	takeprofit_0 = 0;
}



int midnight_bar_from_bar(int bar) {
	int midnight_bar = -1;
	
	int tmp_prev_minute	= 0;	// in case if bar is missing
	int tmp_prev_hour	= 0;

	// (4950+96) = 5046/skip, 5045/skip, 5044/skip, 5043/skip ... 4980/none, 4980/none ... 4965/midnight! break ... (4950/end)
	for (int i=bar+bars_in_whole_day(); i>=0; i--) {
		if (	   tmp_prev_hour   >  TimeHour(Time[i])  		// 23 > 00
				&& tmp_prev_minute >= TimeMinute(Time[i])		// 50 > 00 (M1, M5, M10, M15, M30) or 00 == 00 (H1, H4)
				) {
			midnight_bar = i;	// if current=0:15 and previous=23:10 then 0:15 is definitely a "midnight bar"
			break;
		}

		tmp_prev_hour	= TimeHour(Time[i]);
		tmp_prev_minute	= TimeMinute(Time[i]);
	}
	return(midnight_bar);
}


int was_trade_long1_short2(int bar, datetime session_started_datetime) {
	int ret = 0;
	bool selected = false;
	int orders_qnty = OrdersHistoryTotal();

	for (int i=orders_qnty-1; i>=0; i--) {	// backward order !!! OrderSelect(10) is more recent than OrderSelect(9)
		bool order_selected = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);		// closed and cancelled
		if (order_selected == false) {
			log("!!! was_trade_long1_short2(" + i + "/" + orders_qnty + "): OrderSelect()=false error[" + get_error() + "];"
				+ " " + format_datetime(session_started_datetime, "session_started_datetime", true)
				);
			continue;
		} else {
			//if (debug_was_trade_long1_short2 == 1) OrderPrint();
			//log("was_trade_long1_short2(): previous logrecord was about order selected " + i + "/" + orders_qnty);
		}

		if (OrderSymbol() != Symbol()) {
			log("!!! was_trade_long1_short2(" + i + "/" + orders_qnty + "): OrderSymbol[" + OrderSymbol() + "] != Symbol[" + Symbol() + "]; skipping");
			continue;
		}
		
		if (debug_was_trade_long1_short2 > 1) {
			log("was_trade_long1_short2("
				+ format_datetime_4bar(bar, "bar", true) + ", "
				+ format_datetime(session_started_datetime, "since", true)
				+ "): "
				+ "OrderHistory[" + i + "/" + orders_qnty + "]"
				+ " " + format_datetime(OrderCloseTime(), "CloseTime", true)
				+ " " + format_datetime(session_started_datetime, "midnight", true)
				+ " " + format_double(OrderClosePrice(), "ClosePrice")
				);
		}
		
		if (OrderClosePrice() == 0) continue;	// get rid of cancelled order here... which property???
		if (OrderCloseTime() < session_started_datetime) continue;

		if (OrderType() == OP_BUY)	ret = 1;		// only BUY or SELL are searched
		if (OrderType() == OP_SELL)	ret = 2;
		if (ret > 0) break; 
	}

	if (debug_was_trade_long1_short2 > 2) {
		log("was_trade_long1_short2(" + i + "/" + orders_qnty + "): ret=" + ret);
	}
	
	return(ret);
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
	//if (IsTesting()) return();

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

int start_common() {
	RefreshRates();

	invalidate_tickets_closedbystop();
	show_stats();

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

	return(0);
}


bool skip_this_tick(int bar, int invoke_everyTick0_oncePerBar1=1, int first_ticks_to_skip=0) {
	static datetime	curbar_datetime		= 0;
	static int		ticks_since_new_bar	= 0;
	static int		ticks_in_prev_bar	= 0;

	string func_params = "once/bar, skip" + first_ticks_to_skip;
	if (invoke_everyTick0_oncePerBar1 == 0) func_params = "everyTick, skip0";
	string caller_str = "skip_this_tick(" + func_params + " "
		+ format_datetime(Time[bar], "Time[" + bar + "]", true)
		+ "/" + ticks_since_new_bar + "): ";

	if (curbar_datetime != Time[bar]) {
		curbar_datetime = Time[bar];
		ticks_in_prev_bar = ticks_since_new_bar;
		ticks_since_new_bar = 0;
		if (debug_skip_first_ticks >= 2) log(caller_str + "new bar");
	}

	ticks_since_new_bar++;

	if (invoke_everyTick0_oncePerBar1 == 0) {
		if (debug_skip_first_ticks >= 3) log(caller_str + "; invoking indicator/EA code");
		return(false);	// don't skip this tick
	}

	if (ticks_since_new_bar-1 <= first_ticks_to_skip) {
		if (debug_skip_first_ticks >= 1) log(caller_str + "ONCE/bar is now; invoking EA code");
		return(false);	// don't skip this tick
	}
	
	if (debug_skip_first_ticks >= 3) log(caller_str + "skipping this tick");
	return(true);	// skip this tick
}



void init_common() {
	log("init_common():"
		);

	indicator_precision	= Digits;
	onepip_afterdecimal	= Point;

	if (IsTesting() == true) {		// && !IsOptimization()
		globalvar_prefix = "TEST-" + ea_name + "-";
	} else {
		globalvar_prefix = ea_name + "-" + Symbol() + ":" + period_as_string() + "-";
	}


	dow_tradeable[0]	= tradeable_sunday;
	dow_tradeable[1]	= tradeable_monday;
	dow_tradeable[2]	= tradeable_tuesday;
	dow_tradeable[3]	= tradeable_wednesday;
	dow_tradeable[4]	= tradeable_thursday;
	dow_tradeable[5]	= tradeable_friday;
	dow_tradeable[6]	= tradeable_sunday;

	dow_tradeable_eacomment = "";
	for (int i=0; i<ArraySize(dow_tradeable); i++) {
		if (dow_tradeable[i] == 1) {
			if (dow_tradeable_eacomment != "") dow_tradeable_eacomment = dow_tradeable_eacomment + ", ";
			dow_tradeable_eacomment = dow_tradeable_eacomment + dow_short_names[i];
		}
	}

//	if (!IsVisualMode() && ea_calledfrom != ea_onchart) {
	//log("init_common(): EA!IsVisualMode() so all paint/draw/debug output is turned off");

	if (IsOptimization()) {
		debug_delobj					= false;
		debug_bartext_append			= false;
		debug_mark_rectangle			= false;
		debug_mark_rectangle_create		= false;
		debug_was_trade_long1_short2	= 0;
		debug_skip_first_ticks			= 0;
		
		debug_open						= 0;
		debug_stoploss					= 0;
		debug_modify					= 0;
		debug_close						= 0;
	}


	int globals_deleted = GlobalVariablesDeleteAll(globalvar_prefix);
	log("init_common(" + globalvar_prefix + "):"
		+ " ea_calledfrom[" + ea_calledfrom + "]"
		+ " dow_tradeable_eacomment=" + dow_tradeable_eacomment
		+ " globals_deleted=" + globals_deleted
	);
	log("init_common(" + globalvar_prefix + "):"
		+ " IsVisualMode()=" + IsVisualMode() + " IsTesting()=" + IsTesting() + " IsExpertEnabled()=" + IsExpertEnabled()
		+ " IsConnected()=" + IsConnected() + " IsDemo()=" + IsDemo() + " IsOptimization()=" + IsOptimization()
	);
}



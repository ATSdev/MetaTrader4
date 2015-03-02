string	ea_calledfrom	= "EA-OR_breakout-v3";

#include "libraries/lib_common-v2.mq4"
#include "libraries/lib_OpeningRange-v2.mq4"

extern	string	ORb_comment							= "==== OR_breakout-v3 settings below";

extern	int		orb_open_apply						= 1;
extern	int		orb_close_apply						= 1;
extern	int		orb_takeprofit_FIBO_apply			= 1;
extern	int		orb_close_eod						= 1;
extern	int		second_mustbe_opposite_to_first		= 1;

		bool	long_orb_open		= false;
		bool	short_orb_open		= false;
		bool	long_orb_close		= false;
		bool	short_orb_close		= false;

extern	int		debug_orb			= 0;



int init() {
	ea_name				= "EA-ORb-v3";
	ea_calledfrom		= "EA_ORb-v3";
	indicator_objprefix = "ORb_EA";
//	indicator_logprefix = "ORb_EA::";
	
	init_common();
	
	set_global_as_external();
	init_OpeningRange_v2();
	return(0);
}

int deinit() {
	deinit_OpeningRange_v2();
	deinit_common();

	return(0);
}


int start() {
	print_current_settings();

	start_common();
	//start_OpeningRange_v2();

	int bar, counted_bars = IndicatorCounted();

	int not_counted = 0;
	if (counted_bars > 0)  not_counted = Bars - counted_bars - 1;	// without -1 previous bar is not fixed
	//if (counted_bars < 0)  return(-1);		// skip ticks
	if (counted_bars == 0) not_counted = Bars - 1;

	
	if (ea_calledfrom == ea_onchart) {
		if (not_counted > max_bars_back_onchart) {
			max_bars_back = max_bars_back_onchart;
			not_counted = max_bars_back;
		}
	} else {
		if (not_counted > max_bars_back_ea) {
			max_bars_back = max_bars_back_ea;
			not_counted = max_bars_back;
		}
		//log("start_OpeningRange_v2(" + format_datetime(Time[0], "Time[0]", true) + "): TICK IN THE MIDDLE"
		//	+ " max_bars_back[" + max_bars_back + "] not_counted[" + not_counted + "]"
		//	+ " Bars[" + Bars + "] IndicatorCounted[" + IndicatorCounted() + "]"
		//);
	}


    for (bar = not_counted; bar >= 0; bar--) {
    	if (skip_this_tick(invoke_everyTick0_oncePerBar1, first_ticks_to_skip) == true) return(-1);

		OpeningRange_v2_calculate(bar);
		//log(format_double(upper_boundary_price, "upper_boundary_price"));
		
		if (ntd0wait1st2wtch3end4trd5eod6 == 5 || ntd0wait1st2wtch3end4trd5eod6 == 6) {
			if (orb_open_apply == 1) {
				//session_started_midnight_bar is updated on every single OpeningRange_v2_calculate()
				int last_trade_long1_short2 = was_trade_long1_short2(bar, session_started_datetime);
				//log("was_trade_long1_short2(" 
				//	+ format_datetime_4bar(bar, "bar", true) + ", "
				//	+ format_datetime(session_started_datetime, "session_started_datetime", true)
				//	+ ")=" + last_trade_long1_short2);

	 			orb_signals(0);
				if (ticket_long_current == 0 && long_orb_open == true) {
					if (second_mustbe_opposite_to_first == 1 && last_trade_long1_short2 == 1) {
						signal_open_long = false;
						if (debug_was_trade_long1_short2 == 1) log("start(open_signals):"
							+ " !openlong: (last_trade=long && second_only_opposite)"
							+ " reason=[" + order_open_reason + "]");
					} else {
						signal_open_long = true;
						if (debug_open == 1) log("start(open_signals): signal_open_long=[" + signal_open_short + "]"
							+ " reason=[" + order_open_reason + "]");
					}
				}
		
				if (ticket_short_current == 0 && short_orb_open == true) {
					if (second_mustbe_opposite_to_first == 1 && last_trade_long1_short2 == 2) {
						signal_open_short = false;
						if (debug_was_trade_long1_short2 == 1) log("start(open_signals):"
							+ " !openshort: (last_trade=short && second_only_opposite)"
							+ " reason=[" + order_open_reason + "]");
					} else {
						signal_open_short = true;
						if (debug_open == 1) log("start(open_signals): signal_open_short=[" + signal_open_short + "]"
							+ " reason=[" + order_open_reason + "]");
					}
				}
			}

			if (orb_close_apply == 1) {
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

			if (stoploss_pips_apply == 1) {
				if (ticket_long_current > 0 || signal_open_long == true) {
					stop_0 = pips_stop_calculation(stoploss_pips, 0);
					//if (stop_0 > 0) mark_stop(1, stop_0, Red);
				}

				if (ticket_short_current > 0 || signal_open_short == true) {
					stop_0 = pips_stop_calculation(stoploss_pips, 1);
					//if (stop_0 > 0) mark_stop(1, stop_0, Red);
				}
			}
	
			if (takeprofit_pips_apply == 1) {
				if (signal_open_long == true) {
					takeprofit_0 = pips_takeprofit_calculation(takeprofit_pips, 0);
				}

				if (signal_open_short == true) {
					takeprofit_0 = pips_takeprofit_calculation(takeprofit_pips, 1);
				}
			}
			if (orb_takeprofit_FIBO_apply == 1) {
				if (signal_open_long == true) {
					takeprofit_0 = pips_takeprofit_calculation(takeprofit_pips, 0);
					if (Close[1] < FIBO2_upper_target &&
							(FIBO2_upper_target < takeprofit_0 || takeprofit_0 == 0)
							) {
						takeprofit_0 = FIBO2_upper_target;
						takeprofit_color = DarkOliveGreen;
					}
					if (Close[1] < FIBO1_upper_target && 
							(FIBO1_upper_target < takeprofit_0 || takeprofit_0 == 0)
							) {
						takeprofit_0 = FIBO1_upper_target;
						takeprofit_color = PaleGreen;
					}
				}

				if (signal_open_short == true) {
					takeprofit_0 = pips_takeprofit_calculation(takeprofit_pips, 1);
					if (Close[1] > FIBO2_upper_target &&
							(FIBO2_upper_target > takeprofit_0 || takeprofit_0 == 0)
							) {
						takeprofit_0 = FIBO2_upper_target;
						takeprofit_color = DarkOliveGreen;
					}
					if (Close[1] > FIBO1_upper_target && 
							(FIBO1_upper_target > takeprofit_0 && takeprofit_0 == 0)
							) {
						takeprofit_0 = FIBO1_upper_target;
						takeprofit_color = PaleGreen;
					}
				}
			}

			//if (takeprofit_0 > 0) mark_stop(1, takeprofit_0, tp_color);

		}

		processing_close_stop_open();
	}
}

void orb_signals(int open0_or_close1 = 0) {
/*	double OpeningRange_session1		= bar_session_buffer[1];
	double OpeningRange_state1			= bar_state_buffer[1];
	double OpeningRange_state2			= bar_state_buffer[2];
	double OpeningRange_upper1			= OR_upper_buffer[1];
	double OpeningRange_lower1			= OR_lower_buffer[1];
	double OpeningRange_FIBO1_upper1	= FIBO1_upper_buffer[1];
	double OpeningRange_FIBO1_lower1	= FIBO1_lower_buffer[1];
*/	
	
	double OpeningRange_session1		= session_serno;
	double OpeningRange_state1			= ntd0wait1st2wtch3end4trd5eod6;
	double OpeningRange_state2			= -1;
	double OpeningRange_upper1			= upper_boundary_price;
	double OpeningRange_lower1			= lower_boundary_price;
	double OpeningRange_FIBO1_upper1	= FIBO1_upper_target;
	double OpeningRange_FIBO1_lower1	= FIBO1_lower_target;
	double OpeningRange_FIBO2_upper1	= FIBO2_upper_target;
	double OpeningRange_FIBO2_lower1	= FIBO2_lower_target;


	OpeningRange_session1			= empty2zero(OpeningRange_session1);
	OpeningRange_state1				= empty2zero(OpeningRange_state1);
	OpeningRange_state2				= empty2zero(OpeningRange_state2);
	OpeningRange_upper1				= empty2zero(OpeningRange_upper1);
	OpeningRange_lower1				= empty2zero(OpeningRange_lower1);
	OpeningRange_FIBO1_upper1		= empty2zero(OpeningRange_FIBO1_upper1);
	OpeningRange_FIBO1_lower1		= empty2zero(OpeningRange_FIBO1_lower1);
	OpeningRange_FIBO2_upper1		= empty2zero(OpeningRange_FIBO2_upper1);
	OpeningRange_FIBO2_lower1		= empty2zero(OpeningRange_FIBO2_lower1);


	string OpeningRange_session1_str		= double_to_str(OpeningRange_session1,		-1);
	string OpeningRange_state1_str			= double_to_str(OpeningRange_state1,		-1);
	string OpeningRange_upper1_str			= double_to_str(OpeningRange_upper1,		indicator_precision);
	string OpeningRange_lower1_str			= double_to_str(OpeningRange_lower1,		indicator_precision);
	string OpeningRange_FIBO1_upper1_str	= double_to_str(OpeningRange_FIBO1_upper1,	indicator_precision);
	string OpeningRange_FIBO1_lower1_str	= double_to_str(OpeningRange_FIBO1_lower1,	indicator_precision);
	string OpeningRange_FIBO2_upper1_str	= double_to_str(OpeningRange_FIBO2_upper1,	indicator_precision);
	string OpeningRange_FIBO2_lower1_str	= double_to_str(OpeningRange_FIBO2_lower1,	indicator_precision);
	string Close1_str						= double_to_str(Close[1], indicator_precision);

	if (debug_orb > 1 && open0_or_close1 == 0) {
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
			+ " FIBO2_upper1=["		+ OpeningRange_FIBO2_upper1_str + "]"
			+ " FIBO2_lower_1=["	+ OpeningRange_FIBO2_lower1_str + "]"
			);
	}
	
	
	if (open0_or_close1 == 0) {
		if (OpeningRange_state1	!= 5) return(0);	//ntd0wait1st2wtch3end4trd5eod6
		
		long_orb_open = false;
		short_orb_open = false;

		if (ticket_long_current == 0) {
			if (Close[1] >= OpeningRange_upper1 && Close[2] < OpeningRange_upper1) {
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
			if (Close[1] <= OpeningRange_lower1 && Close[2] > OpeningRange_lower1) {
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

		if (orb_close_eod == 1 && OpeningRange_state1 == 6) {
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
/*
		if (orb_close_FIBO == 1) {
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
*/
	}
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

	if (ret == 0) {
		set_datetime = GlobalVariableSet(globalvar_prefix + "second_mustbe_opposite_to_first", second_mustbe_opposite_to_first);
		if (set_datetime == 0) ret = GetLastError();
	}


	if (ret == 0) {
		int stoploss_pips_local = stoploss_pips;
		if (stoploss_pips_apply == 0) stoploss_pips_local = 0;
		
		set_datetime = GlobalVariableSet(globalvar_prefix + "stoploss_pips", stoploss_pips_local);
		if (set_datetime == 0) ret = GetLastError();
	}

	if (ret == 0) {
		int takeprofit_pips_local = takeprofit_pips;
		if (takeprofit_pips_apply == 0) stoploss_pips_local = 0;
		
		set_datetime = GlobalVariableSet(globalvar_prefix + "takeprofit_pips", stoploss_pips_local);
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
		"bars2trade",
		"second_mustbe_opposite_to_first"
	};
	
	string sltp_names_array[] = {
		"stoploss_pips",
		"takeprofit_pips"
	};	
	
	ret = ret + concat_global_values(orb_names_array,	"ORb", " ");
	ret = ret + concat_global_values(sltp_names_array,	"SL/TP", " ");
	if (dow_tradeable_eacomment != "") ret = ret + "trade(" + dow_tradeable_eacomment + ")";

	Comment(ea_name + " " + short_name
		+ "\n" + ret
		+ "\n" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS)
		);

}



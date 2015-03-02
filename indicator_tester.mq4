
#include "libraries/lib_common-v2.mq4"
extern	string	ea_comment		= "==== EA settings below";
extern	string	ea_calledfrom	= "EA_indicator_tester";


// copy from OpeningRange.mq4
extern	int		bars2wait					= 52;		// EUSUSD 15 min: 17:00(MSK) = 8:00am(NYC) = 1:00pm(GMT) = 4*13 = 52
extern	int		bars2watch					= 6;		// EUSUSD 15 min: 1:30 = 4 + 2 = 6
extern	int		bars2trade					= 48;		// EUSUSD 15 min: 18:30(MSK) = 9:30am(NYC) = 2:30pm(GMT) = 4*14 + 2 = 58
extern	int		friday_force_close_time		= 2030;		// 0=disabled; GMT but depends on the broker (check the chart first)
		bool	leave_saturday_empty		= true;
		bool	leave_sunday_empty			= true;

extern	double	fibo_target1				= 161.8;
extern	double	fibo_target2				= 261.8;

extern	bool	onchart_draw					= true;
extern	bool	onchart_annotate				= true;
extern	bool	onchart_annotate_prefix_session = true;
extern	bool	onchart_setbg					= true;

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


int init() {
	init_common();

	ea_name				= "EA_NAME-indicator_tester";
	globalvar_prefix	= "indicator_tester_global_prefix";

	//set_global_as_external();
	return(0);
}


int deinit() {
	deinit_common();

	int globals_deleted = GlobalVariablesDeleteAll(globalvar_prefix);
	log("deinit(" + globalvar_prefix + "): " + globals_deleted + " globals deleted");

	return(0);
}


int start() {
	//if (once_per_bar(first_ticks_to_skip) == false) return(0);
	
	
//		if (opentime_lastbar == 0) opentime_lastbar = Time[i];
		bool first_tick_of_new_bar = false;
		if ((Time[0] > opentime_lastbar)
//				&& (IsTesting() == true)
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

	
	double OpeningRange_session1 = 0;

	/*
	OpeningRange_session1 = iCustom(NULL, 0, "OpeningRange"
		, ea_calledfrom, bars2wait, bars2watch, bars2trade, fibo_target1, fibo_target2
		, onchart_draw, onchart_annotate, onchart_annotate_prefix_session, onchart_setbg
		, max_bars_back_ea, max_bars_back_onchart, max_bars_4objects, indicator_recent_limit_backgrs, indicator_recent_limit_lines, indicator_recent_limit_bartext, false
		, debug_calculate_bar_state, debug_calculate_breakout_levels, annotate_bar_month_year
		, 0, 1);
*/	

/*
	double OpeningRange_state = iCustom(NULL, 0, "OpeningRange"
		, 3, 8, 8, 161.8
		, ea_name, true, true, true, false
		, 30, 40, 480, 480, 100, 100, false
		, 1, 0);

	double OpeningRange_upper = iCustom(NULL, 0, "OpeningRange"
		, 3, 8, 8, 161.8
		, ea_name, true, true, true, false
		, 30, 40, 480, 480, 100, 100, false
		, 2, 0);

	double OpeningRange_lower = iCustom(NULL, 0, "OpeningRange"
		, 3, 8, 8, 161.8
		, ea_name, true, true, true, false
		, 30, 40, 480, 480, 100, 100, false
		, 3, 0);

	double FIBO_upper = iCustom(NULL, 0, "OpeningRange"
		, 3, 8, 8, 161.8
		, ea_name, true, true, true, false
		, 30, 40, 480, 480, 100, 100, false
		, 4, 0);

	double FIBO_lower = iCustom(NULL, 0, "OpeningRange"
		, 3, 8, 8, 161.8
		, ea_name, true, true, true, false
		, 30, 40, 480, 480, 100, 100, false
		, 5, 0);
*/
	log("start():"
		+ " OpeningRange_session=[" + double_to_str(OpeningRange_session1, -1) + "]"
/*		+ " OpeningRange_state=[" + double_to_str(OpeningRange_state, -1) + "]"
		+ " OpeningRange_upper=[" + double_to_str(OpeningRange_upper) + "]"
		+ " OpeningRange_lower=[" + double_to_str(OpeningRange_lower) + "]"
		+ " FIBO_upper=[" + double_to_str(FIBO_upper) + "]"
		+ " FIBO_lower=[" + double_to_str(FIBO_lower) + "]"
*/		);

}	



#property copyright "Copyright © 20010, Pavel Chuchkalov"
#property link      "jujik@yahoo.com"
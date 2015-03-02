/* template for an indicator:
#property indicator_chart_window
extern	string	ea_calledfrom		= "CHART";
#include "../libraries/lib_common-v2.mq4"
#include "../libraries/lib_OpeningRange-v2.mq4"
*/


extern	string	OpeningRangev2_comment		= "==== Indicator settings below";


extern	int		bars2wait							= 55;		// EUSUSD 15 min: 17:00(MSK) = 8:00am(NYC) = 1:00pm(GMT) = 4*13 = 52
extern	int		bars2watch							= 26;		// EUSUSD 15 min: 1:30 = 4 + 2 = 6
extern	int		bars2trade							= 46;		// EUSUSD 15 min: 18:30(MSK) = 9:30am(NYC) = 2:30pm(GMT) = 4*14 + 2 = 58
extern	int		friday_force_close_time				= 2030;		// 0=disabled; GMT but depends on the broker (check the chart first)
		bool	leave_saturday_empty				= false;
		bool	leave_sunday_empty					= false;


extern	double	fibo_target1						= 161.8;
extern	double	fibo_target2						= 261.8;

extern	bool	onchart_draw						= true;
extern	bool	onchart_annotate					= true;
extern	bool	onchart_annotate_prefix_session 	= true;
extern	bool	onchart_setbg						= true;

extern	int		max_bars_back_ea					= 100;
extern	int		max_bars_back_onchart				= 400;
		int		max_bars_back						= 1000;
extern	int		max_bars_4objects					= 480;
extern	int		indicator_recent_limit_backgrs		= 480;
extern	int		indicator_recent_limit_lines		= 100;
extern	int		indicator_recent_limit_bartext		= 100;
extern	bool	indicator_lines_bartext_create		= false;

extern	bool	debug_calculate_bar_state			= false;
extern	bool	debug_calculate_breakout_levels		= false;
extern	bool	debug_neutralize_friday_night		= true;

extern	bool	annotate_bar_month_year				= true;


		int		session_serno					= 0;
		int		ntd0wait1st2wtch3end4trd5eod6	= -1;
		int		 session_started_bar			= -1;
		datetime session_started_datetime		= -1;
		
		// WARNING!!! DONT TAKE Time[watch_start_bar], Time[watch_end_bar], Time[eod_bar]: these bars are in the future sometimes
		int			watch_start_bar			= -999;
		int			watch_end_bar			= -999;
		int			eod_bar					= -999;
		int			prev_watch_start_bar	= -999;
		int			prev_watch_end_bar		= -999;
		int			prev_eod_bar			= -999;

		int			upper_boundary_bar		= 0;
		double		upper_boundary_price	= 0;
		int			lower_boundary_bar		= 0;
		double		lower_boundary_price	= 0;

		double		FIBO1_upper_target	= 0;
		double		FIBO1_lower_target	= 0;
		double		FIBO2_upper_target	= 0;
		double		FIBO2_lower_target	= 0;


		double	bar_session_buffer[];
		double	bar_state_buffer[];
		double	OR_upper_buffer[];
		double	OR_lower_buffer[];
		double	FIBO1_upper_buffer[];
		double	FIBO1_lower_buffer[];
		double	FIBO2_upper_buffer[];
		double	FIBO2_lower_buffer[];

		int		painted_bars_prior_to_max_back = 0;



int start_OpeningRange_v2() {
	int bar, counted_bars = IndicatorCounted();

	int not_counted = 0;
	if (counted_bars > 0)  not_counted = Bars - counted_bars - 1;	// without -1 previous bar is not fixed
	//if (counted_bars < 0)  return(-1);
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
	}

	//log("start_OpeningRange_v2(" + TimeToStr(Time[0], TIME_SECONDS) + "):"
	//	+ " max_bars_back[" + max_bars_back + "] not_counted[" + not_counted + "]"
	//	+ " IndicatorCounted()=" + IndicatorCounted()
	//	+ " Bars=" + Bars
	//);

    for (bar = not_counted; bar >= 0; bar--) {
		//log("start_OpeningRange_v2(" + TimeToStr(Time[bar], TIME_SECONDS) + "): skip_this_tick()?"
		//	+ TimeToStr(Time[bar], TIME_SECONDS) + ")"
		//	+ " bar[" + bar + "]/not_counted[" + not_counted + "]"
		//);
    	if (skip_this_tick(bar, invoke_everyTick0_oncePerBar1, first_ticks_to_skip) == true) continue;
		OpeningRange_v2_calculate(bar);
	} // for every uncounted bar

    return(0);
}


void OpeningRange_v2_calculate(int bar) {
	ntd0wait1st2wtch3end4trd5eod6 = calculate_bar_state(bar);

	//if (ntd0wait1st2wtch3end4trd5eod6 == 4) {
		calculate_breakout_levels(bar, watch_start_bar, watch_end_bar, eod_bar);
	//}
	if (ntd0wait1st2wtch3end4trd5eod6 >= 4) {
		draw_breakout_levels(bar);
	}

	paint_bar_state_background(bar, ntd0wait1st2wtch3end4trd5eod6);
	
	/*if (session_serno == 1 && watch_start_bar > not_counted && painted_bars_prior_to_max_back == 0) {
		for (int bar_prior_to_max_bars_back=watch_start_bar; bar_prior_to_max_bars_back>=not_counted; bar_prior_to_max_bars_back--) {
			if (bar_prior_to_max_bars_back >= Bars-1) continue;
			//log("paint_bar_state_background(" + bar_prior_to_max_bars_back + "): watch_start_bar=" + watch_start_bar + " not_counted=" + not_counted);
			paint_bar_state_background(bar_prior_to_max_bars_back, calculate_bar_state(bar_prior_to_max_bars_back));
			painted_bars_prior_to_max_back++;
		}
	}*/
	
	if (prev_watch_start_bar != 0 && short_name == "") {
		short_name = ""
			+ " " + format_datetime_4bar(prev_watch_start_bar	, "") + "/" + bars2wait
			+ " " + format_datetime_4bar(prev_watch_end_bar		, "") + "/" + bars2watch
			+ " " + format_datetime_4bar(prev_eod_bar			, "") + "/" + bars2trade
			+ " " + friday_force_close_time
			;
		log("on_bar(" + format_datetime_4bar(bar, "bar", true) + "): " + format_datetime_4bar(prev_watch_start_bar, "watch_start") + " short_name=[" + short_name + "]");
		IndicatorShortName(short_name);
		Comment(short_name);
	}
}


int init_OpeningRange_v2() {
//	if (!IsVisualMode() && ea_calledfrom != ea_onchart) {
//		log("init_OpeningRange_v2(): EA!IsVisualMode so all paint/draw/debug output is turned off");

	if (IsOptimization()) {
		onchart_draw						= false;
		onchart_annotate					= false;
		onchart_annotate_prefix_session 	= false;
		onchart_setbg						= false;

		debug_calculate_bar_state			= false;
		debug_calculate_breakout_levels		= false;
		debug_neutralize_friday_night		= false;
	}

//	if (IsVisualMode()) {
//		delobj_prefixedby_overlimit();
//		log("init(): IsVisualMode()");
//	} else {
//		log("init(): nothing");
//	}


	takeprofit_mark						= false;

	string msg_init = " ea_calledfrom=[" + ea_calledfrom + "] ea_onchart=[" + ea_onchart + "]";
	if (ea_calledfrom != ea_onchart) {
		ea_name = ea_calledfrom;
	}

	log("init_OpeningRange_v2(): " + msg_init);
	return(0);
}


int deinit_OpeningRange_v2() {
//	log("deinit(): nothing");

	string msg_objdelete = "";
	if (ea_calledfrom == ea_onchart) {
		//delete_indicator_objects(indicator_objprefix);
		int deleted_trends		= delobj_prefixedby_overlimit(indicator_objprefix, 0, OBJ_TREND);
		int deleted_texts		= delobj_prefixedby_overlimit(indicator_objprefix, 0, OBJ_TEXT);
		int deleted_backgrounds	= delobj_prefixedby_overlimit(indicator_objprefix, 0, OBJ_RECTANGLE);
		msg_objdelete = "deleted_trends=[" + deleted_trends + "] deleted_texts=[" + deleted_texts + "] deleted_backgrounds=[" + deleted_backgrounds + "] ";
	}

	log("deinit_OpeningRange_v2(): REASON=[" + get_deinit_reason() + "] CLEANUP=[" + msg_objdelete + "]");
}







int calculate_bar_state(int bar) {
	if (leave_saturday_empty	== true && TimeDayOfWeek(Time[bar]) == 6) return(0);	//0=Sunday
	if (leave_sunday_empty		== true && TimeDayOfWeek(Time[bar]) == 0) return(0);	//0=Sunday

	int ret = -1;	//ntd0wait1st2wtch3end4trd5eod6

	static datetime prev_midnight_datetime = 0;
	static datetime prev_midnight_bar = -1;

	int	midnight_bar = midnight_bar_from_bar(bar);
	if (prev_midnight_bar != -1) midnight_bar = prev_midnight_bar;

	if ((bar > 0 && eod_bar > 0 && bar < eod_bar)	// past history prior to indicator was dropped
		|| bar == 0									// real-time & tester bar-by-bar invocation
		|| midnight_bar == -1						// initialization, very first entry to here
		) {

		midnight_bar = midnight_bar_from_bar(bar);
		
		if (midnight_bar == -1) {
			log("calculate_bar_state(" + format_datetime_4bar(bar, "bar", true) + "/" + bar + "): couldnt find midnight bar ("
				+ (bar+bars_in_whole_day()) + "..." + Bars + ")");
			return(ret);
		} else {
			//if (debug_calculate_bar_state) {
			//	log("calculate_bar_state(" + format_datetime_4bar(bar, "bar", true) + "/" + bar + "): found @"
			//		+ format_datetime_4bar(midnight_bar, "midnight_bar", true) + "/" + midnight_bar);
			//}
		}
		
		// non-counted=0; bar-by-bar testing/realtime
		if (bar == 0 && eod_bar < 0 && prev_midnight_datetime != Time[midnight_bar]) {
			midnight_bar += bars_in_whole_day();
		}

		if (prev_midnight_datetime != Time[midnight_bar]) {
			prev_midnight_datetime	= Time[midnight_bar];
			prev_midnight_bar		= 	   midnight_bar;
			session_serno++;

			prev_watch_start_bar	= watch_start_bar;
			prev_watch_end_bar		= watch_end_bar;
			prev_eod_bar			= eod_bar;
		}
		
		watch_start_bar =    midnight_bar - bars2wait;		// greater bar numbers occured earlier; 10=past, 0=present, -6=future
		watch_end_bar	= watch_start_bar - bars2watch;
		eod_bar			=   watch_end_bar - bars2trade;

		eod_bar			= safely_neutralize_friday_night(bar, eod_bar, friday_force_close_time);

		session_started_bar			= watch_end_bar;
		session_started_datetime	= Time[watch_end_bar];
	}

	if (bar  <   	   eod_bar) ret = 1;	// ntd0wait1st2wtch3end4trd5eod6
	if (bar ==		   eod_bar) ret = 6;
	if (bar  <   watch_end_bar && bar > eod_bar) ret = 5;
	if (bar ==   watch_end_bar) ret = 4;
	if (bar  < watch_start_bar && bar > watch_end_bar) ret = 3;
	if (bar == watch_start_bar) ret = 2;
	if (bar  > watch_start_bar) ret = 1;

	if (debug_calculate_bar_state) {
		log("calculate_bar_state(" + format_datetime_4bar(bar, "bar", true) + "/" + session_serno + ":" +  bar + ")"
			+ "=" + state_as_str(ret)
			//+ " " + format_datetime(prev_midnight_datetime,	"prev_MNight",	true) + "/" + prev_midnight_bar
			+ " " + format_datetime_4bar(midnight_bar,		"midnight",		true) + "/" + midnight_bar
			+ " " + format_datetime_4bar(watch_start_bar,	"watch_start",	true) + "/" + watch_start_bar
			+ " " + format_datetime_4bar(watch_end_bar,		"watch_end",	true) + "/" + watch_end_bar
			+ " " + format_datetime_4bar(eod_bar,			"eod",			true, false) + "/" + eod_bar
			);
	}

	bar_session_buffer[bar] = session_serno;
	bar_state_buffer  [bar] = ret;

	return(ret);
}

void reset_at_eod() {
	watch_start_bar			= -999;
	watch_end_bar			= -999;
	eod_bar					= -999;
	prev_watch_start_bar	= -999;
	prev_watch_end_bar		= -999;
	prev_eod_bar			= -999;

	upper_boundary_bar		= -999;
	upper_boundary_price	= 0;
	lower_boundary_bar		= -999;
	lower_boundary_price	= 0;
}
	
int safely_neutralize_friday_night(int bar, int eod_bar, int friday_force_close_time) {
	if (friday_force_close_time == 0) return(eod_bar);

	int ret = -999;
	int eod_bar_not_in_the_future	= eod_bar;
	int eod_past0_future1			= 0;

	if (eod_bar_not_in_the_future < 0) {
		eod_bar_not_in_the_future += bars_in_whole_day();
		eod_past0_future1 = 1;
	}

	int day_of_week_friday		= 5;	//(0 means Sunday,1,2,3,4,5,6)
	int day_of_week_saturday	= 6;	//(0 means Sunday,1,2,3,4,5,6)
	int day_of_week_sunday		= 0;	//(0 means Sunday,1,2,3,4,5,6)
	if (	TimeDayOfWeek(Time[eod_bar_not_in_the_future]) == day_of_week_friday
		||	TimeDayOfWeek(Time[eod_bar_not_in_the_future]) == day_of_week_saturday
		||	TimeDayOfWeek(Time[eod_bar_not_in_the_future]) == day_of_week_sunday
		) {
		int friday_force_close_hour		= friday_force_close_time / 100;
		int friday_force_close_minute	= friday_force_close_time % 100;

//		log("safely_neutralize_friday_night(" + format_datetime_4bar(eod_bar_not_in_the_future, "eod_bar_not_in_the_future", true) + "/" + eod_bar_not_in_the_future
//			+ ", " + friday_force_close_hour + ":" + friday_force_close_minute + "): today is Friday! eod_past0_future1=" + eod_past0_future1);

		if (	eod_past0_future1 == 1
			||		TimeHour(  Time[eod_bar_not_in_the_future]) >  friday_force_close_hour
			||	(	TimeHour(  Time[eod_bar_not_in_the_future]) == friday_force_close_hour
				&&	TimeMinute(Time[eod_bar_not_in_the_future]) >  friday_force_close_minute)
			)  {

			//log("safely_neutralize_friday_night(" + format_datetime_4bar(bar, "bar", true) + "/"  +  bar
			//		+ ", " + format_datetime_4bar(eod_bar, "eod_bar", true) + "/" + eod_bar
			//		+ ", " + friday_force_close_hour + ":" + friday_force_close_minute + "):"
			//	+ " will neutralize this Friday!"
			//	+ " eod_past0_future1=" + eod_past0_future1
			//	);

			for (int i=eod_bar_not_in_the_future; i<eod_bar_not_in_the_future+bars_in_whole_day(); i++) {
				//log("!! " + format_datetime_4bar(i, "i", true) + "/" + i
				//	+ " " + format_datetime_4bar(eod_bar_not_in_the_future, "eod_bar_not_in_the_future", true) + "/" + eod_bar_not_in_the_future
				//	+ " " + format_datetime_4bar(eod_bar_not_in_the_future+bars_in_whole_day(), "eod_bar_not_in_the_future+bars_in_whole_day()", true) + "/" + eod_bar_not_in_the_future+bars_in_whole_day()
				//	);

				if (	(	TimeHour(  Time[i]) == friday_force_close_hour
						&&	TimeMinute(Time[i]) == friday_force_close_minute)
					||	(	TimeHour(  Time[i]) == friday_force_close_hour
						&&	TimeMinute(Time[i]) <  friday_force_close_minute)
//					||	(	TimeHour(  Time[eod_bar_not_in_the_future]) < friday_force_close_hour)
					)  {
					ret = i;
					break;	
				}
			}
			
		}
		
		if (ret == -999) {
			/*log("safely_neutralize_friday_night(" + format_datetime_4bar(bar, "bar", true) + "/"  +  bar
					+ ", " + format_datetime_4bar(eod_bar, "eod_bar", true) + "/" + eod_bar
					+ ", " + friday_force_close_time + "):"
				+ " VERY WEIRD"
				+ " eod_past0_future1=" + eod_past0_future1
				+ " " + format_datetime_4bar(eod_bar_not_in_the_future, "EOD", true) + "/" + eod_bar_not_in_the_future
				+ " is on Friday, but friday_force_close_time=[" + friday_force_close_time + "] not found"
				);*/
		} else {
			//if (bar < ret-bars_in_whole_day()) {
				if (debug_neutralize_friday_night == true) {
					string today_tomorrow = format_datetime_4bar(ret, "NEUTRALIZED TODAY", true) + "/" + ret;
					if (eod_past0_future1 == 1) today_tomorrow = format_datetime_4bar(ret-bars_in_whole_day(), "NEUTRALIZED via YESTERDAY",	true) + "/" + (ret-bars_in_whole_day());

					log("safely_neutralize_friday_night(" + format_datetime_4bar(bar, "bar", true) + "/"  +  bar
							+ ", " + format_datetime_4bar(eod_bar_not_in_the_future, "eod_bar", true) + "/" + eod_bar
							+ ", " + friday_force_close_hour + ":" + friday_force_close_minute + "):"
						//+ " " + format_datetime_4bar(i, "i", true) + "/" + i
						+ " " + today_tomorrow
						);
				}
			//}

			if (eod_past0_future1 == 1) ret -= bars_in_whole_day();
		}
		
	} else {
		//log("safely_neutralize_friday_night(" + format_datetime_4bar(eod_bar_not_in_the_future, "eod_bar_not_in_the_future", true) + "/" + eod_bar_not_in_the_future
		//	+ ", " + friday_force_close_hour + ":" + friday_force_close_minute + "): THIS DAY IS NOT Friday!"
		//	+ " TimeDayOfWeek(" + Time[eod_bar_not_in_the_future] + ")=[" + TimeDayOfWeek(Time[eod_bar_not_in_the_future]) + "] != day_of_week_friday[" + day_of_week_friday + "]"
		//	);
	}
	
	if (ret == -999) ret = eod_bar;
	return(ret);
}

void paint_bar_state_background(int bar, int ntd0wait1st2wtch3end4trd5eod6) {
	string session_levels_objsuffix = "~" + session_serno + ":" + bar_timestamp(watch_end_bar, "");
	
	switch (ntd0wait1st2wtch3end4trd5eod6) {
		case 0:
			//_SetBackgroundColor(bar, LightSlateGray);
			break;

		case 1:
			_GrowingRectangle(bar, LightSlateGray,	eod_bar, session_serno + ":waiting",		upper_boundary_price, lower_boundary_price);
			break;

		case 2:
			//_SetBackgroundColor(bar, DarkSlateGray);
			_GrowingRectangle(bar, Sienna, watch_start_bar, session_serno + ":watch_start");
			_AnnotateBar("startBar", watch_start_bar, true, LightCyan, session_serno + ":watch_start");
			break;
		
		case 3:
			//_SetBackgroundColor(bar, Bisque);
			_GrowingRectangle(bar, Bisque, watch_start_bar, session_serno + ":watching",		upper_boundary_price, lower_boundary_price);
			//log("paint_bar_state_background(" + format_datetime_4bar(bar, "bar", true) + "/"  +  bar + "):"
			//	+ " session=" + session_serno
			//	+ " bar_state=" + state_as_str(ntd0wait1st2wtch3end4trd5eod6)
			//	+ " " + format_double(upper_boundary_price,	"upper_boundary_price")
			//	+ " " + format_double(lower_boundary_price,	"lower_boundary_price")
			//	);
			break;
		
		case 4:
			//_SetBackgroundColor(bar, LightGreen);
			_AnnotateBar("endBar", watch_end_bar, true, LightCyan, session_serno + ":watch_end");
			//_GrowingRectangle(bar, Bisque,	watch_start_bar+4, session_serno + ":watching",		upper_boundary_price, lower_boundary_price);
			_GrowingRectangle(bar, LightGreen,	watch_end_bar, session_serno + ":watch_end",	upper_boundary_price, lower_boundary_price);


			mark_line(bar, watch_end_bar, FIBO1_upper_target, watch_start_bar, FIBO1_upper_target, PaleGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO1-upper");
			mark_line(bar, watch_end_bar, FIBO1_lower_target, watch_start_bar, FIBO1_lower_target, PaleGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO1-lower");

			mark_line(bar, watch_end_bar, FIBO2_upper_target, watch_start_bar, FIBO2_upper_target, LimeGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO2-upper");
			mark_line(bar, watch_end_bar, FIBO2_lower_target, watch_start_bar, FIBO2_lower_target, LimeGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO2-lower");

			break;
		
		case 5:
			//_SetBackgroundColor(bar, LightSeaGreen);
			// _GrowingRectangle(int bar, color background_color, int initial_bar_growfrom=0, double upper_border=0, double lower_border=0)
			_GrowingRectangle(bar, MidnightBlue, watch_end_bar, session_serno + ":trading",		upper_boundary_price, lower_boundary_price);

			mark_line(bar, bar, FIBO1_upper_target, watch_start_bar, FIBO1_upper_target, PaleGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO1-upper");
			mark_line(bar, bar, FIBO1_lower_target, watch_start_bar, FIBO1_lower_target, PaleGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO1-lower");

			mark_line(bar, bar, FIBO2_upper_target, watch_start_bar, FIBO2_upper_target, LimeGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO2-upper");
			mark_line(bar, bar, FIBO2_lower_target, watch_start_bar, FIBO2_lower_target, LimeGreen, 2, STYLE_DOT, indicator_objprefix, session_levels_objsuffix + ":FIBO2-lower");

			break;
		
		case 6:
			//_SetBackgroundColor(bar, LightGray);
			_AnnotateBar("eodBar", eod_bar, true, LightCyan, session_serno + ":eod");
			_GrowingRectangle(bar, LightGray, eod_bar, session_serno + ":eod");
			break;
		
		default:
			break;
	}
}

void calculate_breakout_levels(int bar, int watch_start_bar, int watch_end_bar, int eod_bar) {
	if (ntd0wait1st2wtch3end4trd5eod6 < 2) return;

	upper_boundary_bar		=		watch_start_bar;
	upper_boundary_price	=  High[watch_start_bar];
	lower_boundary_bar		=		watch_start_bar;
	lower_boundary_price	=   Low[watch_start_bar];

	int last_existing_before_watch_end = watch_end_bar;
	if (watch_end_bar < 0) last_existing_before_watch_end = 0;		//watch_end_bar is in the future and last=0

	for (int i=watch_start_bar; i>last_existing_before_watch_end; i--) {
		if (High[i] > upper_boundary_price) {
			upper_boundary_bar = i;
			upper_boundary_price = High[i];
		}

		if (Low[i] < lower_boundary_price) {
			lower_boundary_bar = i;
			lower_boundary_price = Low[i];
		}

		/*if (debug_calculate_breakout_levels) {
			log("calculate_breakout_levels():"
				+ " lower_boundary_price=" + double_to_str(lower_boundary_price)
				+ " Low[" + i + "]=" + double_to_str(Low[i])
				+ " upper_boundary_price=" + double_to_str(upper_boundary_price)
				+ " High[" + i + "]=" + double_to_str(High[i])
			);
		}*/
		
	}

	double OR_boundaries_difference = (upper_boundary_price-lower_boundary_price);
	FIBO1_upper_target = upper_boundary_price + OR_boundaries_difference * (fibo_target1-100)/100;
	FIBO1_lower_target = lower_boundary_price - OR_boundaries_difference * (fibo_target1-100)/100;
	FIBO2_upper_target = upper_boundary_price + OR_boundaries_difference * (fibo_target2-100)/100;
	FIBO2_lower_target = lower_boundary_price - OR_boundaries_difference * (fibo_target2-100)/100;

	i = bar;
	   OR_upper_buffer[i] = upper_boundary_price;
	   OR_lower_buffer[i] = lower_boundary_price;
	FIBO1_upper_buffer[i] = FIBO1_upper_target;
	FIBO1_lower_buffer[i] = FIBO1_lower_target;
	FIBO2_upper_buffer[i] = FIBO2_upper_target;
	FIBO2_lower_buffer[i] = FIBO2_lower_target;

	/*
	int last_existing_before_eod = MathMin(bar, eod_bar);
	if (last_existing_before_eod < 0) last_existing_before_eod = 0;
	
	for (i=watch_start_bar; i>=last_existing_before_eod; i--) {
		   OR_upper_buffer[i] = upper_boundary_price;
		   OR_lower_buffer[i] = lower_boundary_price;
		FIBO1_upper_buffer[i] = upper_fibo_target1;
		FIBO1_lower_buffer[i] = lower_fibo_target1;
		FIBO2_upper_buffer[i] = upper_fibo_target2;
		FIBO2_lower_buffer[i] = lower_fibo_target2;
	}
	*/
		
	if (debug_calculate_breakout_levels) {
		log("calculate_breakout_levels(watch_start=" + watch_start_bar + format_datetime_4bar(bar, "bar") + "/" + bar + " eod_bar=" + eod_bar + "):"
			+ " ntd0wait1st2wtch3end4trd5eod6=" + ntd0wait1st2wtch3end4trd5eod6
			+ " OR_upper_buffer[" + format_datetime_4bar(upper_boundary_bar, "") + "]=" + double_to_str(OR_upper_buffer[bar])
			+ " OR_lower_buffer[" + format_datetime_4bar(lower_boundary_bar, "") + "]=" + double_to_str(OR_lower_buffer[bar])
			);
	}
	
	
}


void draw_breakout_levels(int bar) {
	if (ntd0wait1st2wtch3end4trd5eod6 == 4) {
		//_DrawLine(PricePane, upper_boundary_bar, upper_boundary_price, watch_end_bar, upper_boundary_price, Color.Red, LineStyle.Solid, 3);
		//_DrawLine(PricePane, lower_boundary_bar, lower_boundary_price, watch_end_bar, lower_boundary_price, Color.Red, LineStyle.Solid, 3);

		//_AnnotateBar(format_datetime_4bar(upper_boundary_bar, "Highest", upper_boundary_bar), upper_boundary_bar, true, Color.DarkCyan);
		//_AnnotateBar(format_datetime_4bar(lower_boundary_bar,  "Lowest", lower_boundary_bar), lower_boundary_bar, true, Color.DarkCyan);
		_AnnotateBar("Highest", upper_boundary_bar, true, DarkGoldenrod, session_serno + ":Highest");
		_AnnotateBar( "Lowest", lower_boundary_bar, false, DarkGoldenrod, session_serno + ":Lowest");
	} else {
		//_DrawLine(PricePane, bar, upper_boundary_price, (bar>=Bars.Count-1) ? bar : bar+1, upper_boundary_price, Color.Red, LineStyle.Solid, 3);
		//_DrawLine(PricePane, bar, lower_boundary_price, (bar>=Bars.Count-1) ? bar : bar+1, lower_boundary_price, Color.Red, LineStyle.Solid, 3);
	}
}



string state_as_str(int ntd0wait1st2wtch3end4trd5eod6) {
	switch (ntd0wait1st2wtch3end4trd5eod6) {
		case 0: return("0/NTD");
		case 1: return("1/WAITING");
		case 2: return("2/WATCH_START");
		case 3: return("3/WATCH_START");
		case 4: return("4/WATCH_END");
		case 5: return("5/TRADING");
		case 6: return("6/EOD");
	}
}

void _SetBackgroundColor(int bar, color background_color) {
	if (onchart_setbg == false) return;

	string text = format_datetime(Time[bar], text, annotate_bar_month_year);
	mark_background(bar, indicator_objprefix, text
		, bar+1, High[bar]+0.05, bar, Low[bar]-0.05
		, 200, background_color);
}

void _GrowingRectangle(int bar, color background_color, int initial_bar_growfrom=0, string initial_bar_objsuffix = ""
		, double upper_border=0, double lower_border=0) {
	if (onchart_setbg == false) return;

	double distance_simulate_background = 0.03;
	if (initial_bar_growfrom	== 0) initial_bar_growfrom	= bar;
	if (initial_bar_objsuffix  == "") initial_bar_objsuffix	= "&stay";
	if (upper_border			== 0) upper_border			= High[bar]	+ distance_simulate_background;
	if (lower_border			== 0) lower_border			= Low[bar]	- distance_simulate_background;
	
	string initial_bar_growfrom_str = format_datetime(Time[initial_bar_growfrom], ":growfrom", true);
	
	//void mark_background(int bar, color rectangle_color = LightSlateGray, string objname_prefix = "", string objname_suffix = ""
	//	, int bar_start = 0, double y_coordinate_start = 0, int bar_end = 0, double y_coordinate_end = 0, int recent_limit = 0) {

	mark_background(bar, background_color, indicator_objprefix + initial_bar_growfrom_str, initial_bar_objsuffix
		, bar+1, upper_border, bar, lower_border, 0);
}

//void bartext_append(string objname_prefix = "", string objname_suffix = "", string bartext = ""
//			, int below0_above1 = 0, int bar = 0, double y_coordinate = 0
//			, int recent_limit = 200, bool bartext_create = true) {

void _AnnotateBar(string text, int bar, bool aboveBar, color text_color, string annotation_objsuffix = "") {
	if (onchart_annotate == false) return;
	
	text = format_datetime(Time[bar], text, annotate_bar_month_year);
	if (onchart_annotate_prefix_session == true) text = session_serno + "." + text;
	int below0_above1 = 0;
	if (aboveBar) below0_above1 = 1;
	
	string annotation_accesskey = "@" + format_datetime(Time[bar], "", true)  + annotation_objsuffix;

	//void bartext_append(int bar = 0, string bartext = "", int below0_above1 = 0
	//			, string objname_prefix = "", string objname_suffix = "", bool append_counter = true
	//			, color text_color = Gold, double y_coordinate = 0, bool bartext_create = true) {

	bartext_append(bar, text, below0_above1
			, indicator_objprefix, annotation_accesskey, false, text_color);

}




#property link      "jujik@yahoo.com"


/*
	int bar, counted_bars = IndicatorCounted();
	if (counted_bars < 0)  return(-1);
	int not_counted = (Bars-1);
	if (counted_bars > 0) not_counted = (Bars-counted_bars-1);

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
	}


    // 5000, 4999, 4998 ... 1
    for (bar = not_counted; bar >= 0; bar--) {
		if (once_per_bar(first_ticks_to_skip) == false) return(0);

		log("start(" + TimeToStr(Time[bar], TIME_DATE) + " " + TimeToStr(Time[bar], TIME_SECONDS) + ")"
			+ " bar[" + bar + "]/[" + not_counted + "]:[" + max_bars_back  + "]"
			+ " IndicatorCounted[" + IndicatorCounted() + "]/[" + Bars + "]"
			);

*/

	
	/*if (bar == 0) {		// on last bar of the day (WealthLab port, can't say why it's here)
		watch_start_bar			= 0;
		watch_end_bar			= 0;
		eod_bar					= 0;
		upper_boundary_bar		= 0;
		upper_boundary_price	= 0;
		lower_boundary_bar		= 0;
		lower_boundary_price	= 0;
	}*/
	
	//if (!isDateTimeTradeable(Time[bar])) return 0;	// ntd0wait1st2wtch3end4trd5eod6


//if (IsTesting() || IsVisualMode()) max_bars_back = 20;


	
/*		

		private void calculate_open_triggers(int bar) {
			if (ntd0wait1st2wtch3end4trd5eod6 != 5) return;
			if (bar == 0) return; 
			
			if (both0_long1_short2 == 0 || both0_long1_short2 == 1) {
				if (Close[bar-1] <= upper_boundary_price && Close[bar] > upper_boundary_price) {
					long_open_trigger = true;
					long_open_trigger_reason = "BreakUp";
					_AnnotateBar("BU", bar, false, LightCyan);
				}
			}
			
			if (both0_long1_short2 == 0 || both0_long1_short2 == 2) {
				if (Close[bar-1] >= lower_boundary_price && Close[bar] < lower_boundary_price) {
					short_open_trigger = true;
					short_open_trigger_reason = "BreakDown";
					_AnnotateBar("BD", bar, true, LightCyan);
				}
			}
			
			if (debug_open_triggers) {
				log(bar, "calculate_open_triggers():"
					+  " long open: [" +  long_open_trigger_reason + "]"
					+ " short open: [" + short_open_trigger_reason + "]");
			}
		}
*/


#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 SeaGreen
#property indicator_color6 SeaGreen
#property indicator_color7 SteelBlue
#property indicator_color8 SteelBlue

#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_DASH
#property indicator_style6 STYLE_DASH
#property indicator_style7 STYLE_DOT
#property indicator_style8 STYLE_DOT

#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1



extern	string	ea_calledfrom		= "CHART";

#include "../libraries/lib_common-v2.mq4"
#include "../libraries/lib_OpeningRange-v2.mq4"

int start() {
	return(start_OpeningRange_v2());
}

int init() {
	init_common();

	indicator_objprefix = "ORi";
//	indicator_logprefix = "ORi::";
	globalvar_prefix	= "ORi";

	init_OpeningRange_v2();
	

	SetIndexStyle(0, DRAW_NONE);
	SetIndexStyle(1, DRAW_NONE);
	SetIndexStyle(2, DRAW_LINE);
	SetIndexStyle(3, DRAW_LINE);
	SetIndexStyle(4, DRAW_LINE);
	SetIndexStyle(5, DRAW_LINE);
	SetIndexStyle(6, DRAW_LINE);
	SetIndexStyle(7, DRAW_LINE);

	SetIndexBuffer(0, bar_session_buffer);
	SetIndexBuffer(1, bar_state_buffer);
	SetIndexBuffer(2, OR_upper_buffer);
	SetIndexBuffer(3, OR_lower_buffer);
	SetIndexBuffer(4, FIBO1_upper_buffer);
	SetIndexBuffer(5, FIBO1_lower_buffer);
	SetIndexBuffer(6, FIBO2_upper_buffer);
	SetIndexBuffer(7, FIBO2_lower_buffer);

	SetIndexLabel(0, "session");
	SetIndexLabel(1, "ntd0wait1st2wtch3end4trd5eod6");
	SetIndexLabel(2, "OR_upper");
	SetIndexLabel(3, "OR_lower");
	SetIndexLabel(4, "FIBO-" + double_to_str(fibo_target1, 1) + "_upper");
	SetIndexLabel(5, "FIBO-" + double_to_str(fibo_target1, 1) + "_lower");
	SetIndexLabel(6, "FIBO-" + double_to_str(fibo_target2, 1) + "_upper");
	SetIndexLabel(7, "FIBO-" + double_to_str(fibo_target2, 1) + "_lower");
	
	return(0);
}


int deinit() {
	deinit_common();
	deinit_OpeningRange_v2();
}


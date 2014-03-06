//+------------------------------------------------------------------+
//|                                                       atr2ja.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot atr_high
#property indicator_label1  "atr_high"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot atr_low
#property indicator_label2  "atr_low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      atr_time_frame=PERIOD_H12;
input int      avg_period=10;
//--- indicator buffers
double         atr_highBuffer[];
double         atr_lowBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,atr_highBuffer);
   SetIndexBuffer(1,atr_lowBuffer);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit=rates_total-prev_calculated-1;
//--- main loop
   for(int i=limit; i>=0; i--)
     {
      //--- ma_shift set to 0 because SetIndexShift called abowe
      double iatr=iATR(NULL,PERIOD_H4,avg_period,i);
      double medianPrice=0.5*(high[i]+low[i]);
      atr_highBuffer[i]= medianPrice+iatr*0.5;
      atr_lowBuffer[i] = medianPrice-iatr*0.5;
      Print(" iatr[i] = ",iatr);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                       DOUBLE BOLINGER SIGNAL.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--labels
#property indicator_label1  "Bol_ FastUp"
#property indicator_label2  "Bol_ FastDown"
#property indicator_label3  "Bol_ SlowUp"
#property indicator_label4  "Bol_ SlowDown"

#define SIGNAL_TOP 1
#define SIGNAL_TOP_SELL 2
#define SIGNAL_NOTHING  0
#define SIGNAL_BOTTOM -1
#define SIGNAL_BOTTOM_BUY -2

extern int iBand_Fast = 20;
extern int iBand_Slow = 175;
extern int deviation = 1;

//--- indicator buffers
double         bFast_up[];
double         bFast_down[];
double         bSlow_up[];
double         bSlow_down[];

string arrowOBJname="ArrowNameObject";
/*
double         arrow_down_buffer[];
double         arrow_up_buffer[];
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_Previous;
int UPobjCount = 0;
int DNobjCount = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   IndicatorBuffers(4);

//drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1,clrGray);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,clrGray);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1,clrGray);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1,clrGray);

/*
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,SYMBOL_ARROWDOWN);
   SetIndexLabel(4,"SELL");

   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,SYMBOL_ARROWUP);
   SetIndexLabel(5,"BUY");
*/
   IndicatorDigits(Digits+2);

//--- indicator buffers mapping
   SetIndexBuffer(0,bFast_up);
   SetIndexBuffer(1,bFast_down);
   SetIndexBuffer(2,bSlow_up);
   SetIndexBuffer(3,bSlow_down);
/*
   SetIndexBuffer(4,arrow_down_buffer);
   SetIndexBuffer(5,arrow_up_buffer);
*/
//----

   IndicatorShortName("DOUBLE BOLLINGER");

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+

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
   int i,limit;

   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(i=0; i<limit; i++)
     {
      //---CALCULATE INDICATOR LINES
      bFast_up[i]=iBands(NULL,0,iBand_Fast,deviation,0,PRICE_CLOSE,MODE_UPPER,i);
      bFast_down[i]=iBands(NULL,0,iBand_Fast,deviation,0,PRICE_CLOSE,MODE_LOWER,i);
      bSlow_up[i]=iBands(NULL,0,iBand_Slow,2,deviation,PRICE_CLOSE,MODE_UPPER,i);
      bSlow_down[i]=iBands(NULL,0,iBand_Slow,deviation,0,PRICE_CLOSE,MODE_LOWER,i);

      //--CALCULATE BUY/SELL SIGNAL LINES
      // DrawSignalArrows(i);

     }

   DrawSignalArrows();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void deinit()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

bool AreInOrder(double min,double mid,double max)
  {
   if(min < mid && mid < max) return(true);
   return(false);
  }
//+------------------------------------------------------------------+

//--GET PRICE VALUE WHERE TO DRAW THE BUY/SELL ARROWS
int GetSignal()
  {

   int i=0;
   int ret=SIGNAL_NOTHING;

   double dPrice=Close[1];

   if(AreInOrder(bSlow_up[i], bFast_up[i], dPrice)) ret=SIGNAL_TOP;
   if(AreInOrder(bSlow_up[i], dPrice, bFast_up[i])) ret=SIGNAL_TOP_SELL;

   if(AreInOrder(dPrice, bFast_down[i], bSlow_down[i])) ret=SIGNAL_BOTTOM;
   if(AreInOrder(bFast_down[i], dPrice, bSlow_down[i])) ret=SIGNAL_BOTTOM_BUY;

   return(ret);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DrawSignalArrows()

  {

   int a=GetSignal();

//sample only

   string ObjName=StringConcatenate(arrowOBJname,IntegerToString(DNobjCount));
/*
   ObjectCreate(ObjName,OBJ_ARROW,0,Time[1],High[1]);
   ObjectSet(ObjName,OBJPROP_ARROWCODE,SYMBOL_ARROWDOWN);
   ObjectSet(ObjName,OBJPROP_COLOR,clrYellow);
   ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(ObjName,OBJPROP_SCALE,3.0);
   DNobjCount++;
*/
//--- draw signal -----

   if(a==SIGNAL_TOP_SELL && Signal_Previous==SIGNAL_TOP)
     {
      if(!ObjectCreate(ObjName,OBJ_ARROW,0,Time[1],High[1]))
        {
         Print("error: can't create upArrow object! code #",GetLastError());
         return(0);

        }
      ObjectSet(ObjName,OBJPROP_ARROWCODE,SYMBOL_ARROWDOWN);
      //object stles
      ObjectSet(ObjName,OBJPROP_COLOR,clrYellow);
      ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(ObjName,OBJPROP_SCALE,10.0);

      DNobjCount++;
      Alert("SHORT SIGNAL !!!");
     }

   if(a==SIGNAL_BOTTOM_BUY && Signal_Previous==SIGNAL_BOTTOM)
     {
      if(!ObjectCreate(ObjName,OBJ_ARROW,0,Time[1],Low[1]))
        {
         Print("error: can't create upArrow object! code #",GetLastError());
         return(0);
        }
      ObjectSet(ObjName,OBJPROP_ARROWCODE,SYMBOL_ARROWUP);
      ObjectSet(ObjName,OBJPROP_COLOR,clrYellow);
      ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(ObjName,OBJPROP_SCALE,3.0);
      DNobjCount++;
      Alert("BUY SIGNAL !!!");

     }

   Signal_Previous=a;

   return (1);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

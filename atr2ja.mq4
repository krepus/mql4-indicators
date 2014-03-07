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
#property indicator_buffers 4
#property indicator_plots   4 
//--- plot atr_high
#property indicator_label1  "atr_high"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkKhaki
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- plot atr_low
#property indicator_label2  "atr_low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkKhaki
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot TrendUp
#property indicator_label3  "TrendUp"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot TrendDown
#property indicator_label4  "TrendDown"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2 
////---plot UpSignal
//#property indicator_label5  "Up Signal"
//#property indicator_type5   DRAW_ARROW
//#property indicator_color5  clrBlue
//#property indicator_style5  STYLE_SOLID
//#property indicator_width5  1
////---plot DownSignal
//#property indicator_label6  "Down Signal"
//#property indicator_type6   DRAW_ARROW
//#property indicator_color6  clrRed
//#property indicator_style6  STYLE_SOLID
//#property indicator_width6  1

//--- input parameters 
input int      avg_period=10;//number of H4 bars to average
input double   Multiplier=1.0;//multiplier, leave as default
//--- indicator buffers
double         atr_highBuffer[];
double         atr_lowBuffer[];
double         TrendUp[];
double         TrendDown[];
//double         UpBuffer[];
//double         DnBuffer[];

int changeOfTrend;
string arrowOBJname="ArrowNameObject";
int DNobjCount=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,atr_highBuffer);
   SetIndexBuffer(1,atr_lowBuffer);
   SetIndexBuffer(2,TrendUp);
   SetIndexBuffer(3,TrendDown);
//   SetIndexBuffer(4,UpBuffer);
//   SetIndexBuffer(5,DnBuffer);
//
//   PlotIndexSetInteger(4,PLOT_ARROW,159);
//   PlotIndexSetInteger(5,PLOT_ARROW,159);
//
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

   int  flag,flagh,trend[];
   double up[],dn[];
   int size=ArraySize(TrendUp);
   ArrayResize(trend,size);
   ArrayResize(up,size);
   ArrayResize(dn,size);

   int limit=rates_total-prev_calculated-2;
//--- main loop
   for(int j=limit; j>0; j--)
     {
      //--- ma_shift set to 0 because SetIndexShift called abowe
      double iatr=iATR(NULL,PERIOD_H4,avg_period,j);
      double    medianPrice=0.5*(high[j]+low[j]);
      atr_highBuffer[j]= medianPrice+iatr*0.5;
      atr_lowBuffer[j] = medianPrice-iatr*0.5;
      //Print(" iatr[i] = ",iatr);

      int i=j;
      TrendUp[i]=EMPTY_VALUE;
      TrendDown[i]=EMPTY_VALUE;
      //iatr=iATR(NULL,0,Nbr_Periods,i);
      //Print("atr: "+atr[i]);
      medianPrice=(high[i]+low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(Multiplier*iatr);

      //Print("up: "+up[i]);
      dn[i]=medianPrice-(Multiplier*iatr);
      //lowerATR[i]=dn[i];
      //Print("dn: "+dn[i]);
      trend[i]=1;

      if(Close[i]>up[i+1])
        {
         trend[i]=1;
         if(trend[i+1]==-1) changeOfTrend=1;
         //Print("trend: "+trend[i]);

        }
      else if(Close[i]<dn[i+1])
        {
         trend[i]=-1;
         if(trend[i+1]==1) changeOfTrend=1;
         //Print("trend: "+trend[i]);
        }
      else if(trend[i+1]==1)
        {
         trend[i]=1;
         changeOfTrend=0;
        }
      else if(trend[i+1]==-1)
        {
         trend[i]=-1;
         changeOfTrend=0;
        }

      if(trend[i]<0 && trend[i+1]>0)
        {
         flag=1;
         //Print("flag: "+flag);
        }
      else
        {
         flag=0;
         //Print("flagh: "+flag);
        }

      if(trend[i]>0 && trend[i+1]<0)
        {
         flagh=1;
         //Print("flagh: "+flagh);
        }
      else
        {
         flagh=0;
         //Print("flagh: "+flagh);
        }

      if(trend[i]>0 && dn[i]<dn[i+1])
         dn[i]=dn[i+1];

      if(trend[i]<0 && up[i]>up[i+1])
         up[i]=up[i+1];

      if(flag==1)
         up[i]=medianPrice+(Multiplier*iatr);

      if(flagh==1)
         dn[i]=medianPrice-(Multiplier*iatr);

      //-- Draw the indicator
      if(trend[i]==1)
        {
         TrendUp[i]=dn[i];
         if(changeOfTrend==1)
           {
            TrendUp[i+1] = TrendDown[i+1];
            changeOfTrend= 0;
           }
        }
      else if(trend[i]==-1)
        {
         TrendDown[i]=up[i];
         if(changeOfTrend==1)
           {
            TrendDown[i+1]= TrendUp[i+1];
            changeOfTrend = 0;
           }

        }
      if(trend[i]==1 && trend[i+1]==-1)
        {
         //UpBuffer[i]=low[i];
         //DnBuffer[i] = EMPTY_VALUE;
         drawLongArrow(i);

        }
      if(trend[i]==-1 && trend[i+1]==1)
        {
         //UpBuffer[i] = EMPTY_VALUE;
         //DnBuffer[i]=high[i];
         drawShortArrow(i);
        }
      //Print("low[i] = ",low[i]);
      //Print("high[i] = ",high[i]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLongArrow(int i)
  {
   string ObjName=StringConcatenate(arrowOBJname,IntegerToString(DNobjCount));
   if(!ObjectCreate(ObjName,OBJ_ARROW,0,Time[i],Low[i]))
     {
      Print("error: can't create upArrow object! code #",GetLastError());
      return;
     }
   ObjectSet(ObjName,OBJPROP_ARROWCODE,233);
   ObjectSet(ObjName,OBJPROP_COLOR,clrBlue);
   DNobjCount++;
   SendNotification("LONG SIGNAL COMING UP!!!");
   Alert("BUY SIGNAL !!!");

  }
//+------------------------------------------------------------------+
void drawShortArrow(int i)
  {
   string ObjName=StringConcatenate(arrowOBJname,IntegerToString(DNobjCount));
   if(!ObjectCreate(ObjName,OBJ_ARROW,0,Time[i],High[i]))
     {
      Print("error: can't create upArrow object! code #",GetLastError());
      return;

     }
   ObjectSet(ObjName,OBJPROP_ARROWCODE,234);//wingdings
                                            //object stles
   ObjectSet(ObjName,OBJPROP_COLOR,clrRed);
//ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID); 

   DNobjCount++;
   SendNotification("SHORT SIGNAL COMING UP!!!");
   Alert("SHORT SIGNAL !!!");
   
  }
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
  }
//+------------------------------------------------------------------+

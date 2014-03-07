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


//#property indicator_color1 Blue
//#property indicator_color2 Red
//#property indicator_width1 1
//#property indicator_width2 1
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width3 1
#property indicator_width4 1
#property indicator_buffers 6


double TrendUp[],TrendDown[];
double UpBuffer[];
double DnBuffer[];

//additional buffers
double upperATR[];//upper range
double lowerATR[];//lower range

int changeOfTrend;
extern int iATR_time_frame=720; //time frame in minutes, 0=current
extern int Nbr_Periods=10;
extern double Multiplier=4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

//---- indicators
   SetIndexBuffer(0,TrendUp);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,2,clrBlue);
   SetIndexLabel(0,"Trend Up");

   SetIndexBuffer(1,TrendDown);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,2,clrOrangeRed);
   SetIndexLabel(1,"Trend Down");

   SetIndexBuffer(2,UpBuffer);
   SetIndexStyle(2,DRAW_ARROW,EMPTY);
   SetIndexArrow(2,233);
   SetIndexLabel(2,"Up Signal");

   SetIndexStyle(3,DRAW_ARROW,EMPTY);
   SetIndexBuffer(3,DnBuffer);
   SetIndexArrow(3,234);
   SetIndexLabel(3,"Down Signal");

//additional buffers
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT,1,clrGray);
   SetIndexBuffer(4,upperATR);
   SetIndexLabel(4,"upper range");

   SetIndexStyle(5,DRAW_LINE,STYLE_DOT,1,clrGray);
   SetIndexBuffer(5,lowerATR);
   SetIndexLabel(5,"Lower range");

   return(0);
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

   double ClosePrice=Close[0];

//   

   int i,flag,flagh,trend[];
   double up[],dn[],medianPrice,atr;
//double medianPrice,atr;

//int counted_bars=IndicatorCounted();
//   int counted_bars=prev_calculated;
//   if(counted_bars < 0)  return(-1);
//   if(counted_bars>0) counted_bars--;
//   int limit=rates_total-counted_bars;
//   if(counted_bars==0) limit-=1+1;

//Print(limit);

   int size=ArraySize(TrendUp);
   ArrayResize(trend,size);
   ArrayResize(up,size);
   ArrayResize(dn,size);
//----
   int limit=rates_total-prev_calculated-1;
   for(i=limit-1; i>=0; i--)
     {

      TrendUp[i]=EMPTY_VALUE;
      TrendDown[i]=EMPTY_VALUE;
      atr=iATR(NULL,0,Nbr_Periods,i);
      //Print("atr: "+atr[i]);
      medianPrice=(high[i]+low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(Multiplier*atr);

      //Print("up: "+up[i]);
      dn[i]=medianPrice-(Multiplier*atr);
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
         up[i]=medianPrice+(Multiplier*atr);

      if(flagh==1)
         dn[i]=medianPrice-(Multiplier*atr);

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
         UpBuffer[i] = iLow(Symbol(),0,i)-(3*Point);
         DnBuffer[i] = EMPTY_VALUE;

        }
      if(trend[i]==-1 && trend[i+1]==1)
        {
         UpBuffer[i] = EMPTY_VALUE;
         DnBuffer[i] = iHigh(Symbol(),0,i)+(3*Point);
        }

      //additional buffers
      double iatr=iATR(NULL,PERIOD_H4,Nbr_Periods,i);
      upperATR[i]=medianPrice + iatr;
      lowerATR[i]=medianPrice-iatr;
      // Print(StringConcatenate("i = ",i,"iatr = ",DoubleToStr(iatr)));

      //end additional buffers

     }
//WindowRedraw();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void deinit()
  {
//ObjectsDeleteAll(0,OBJ_ARROW);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

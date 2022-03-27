//+------------------------------------------------------------------+
//|                                           BB Keltner Squeeze.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#property indicator_chart_window


#property indicator_separate_window

//#property indicator_buffers 4
#property indicator_buffers 2

//#property indicator_color1 Lime
//#property indicator_color2 Red
//#property indicator_color3 Magenta
//#property indicator_color4 Aqua

#property indicator_color1 Magenta
#property indicator_color2 Aqua

#property indicator_minimum -2
#property indicator_maximum 2


//---- input parameters
input int       bolPrd=20;
input double    bolDev=2.0;
input int       keltPrd=20;
input double    keltFactor=1.5;
input int       momPrd=12;

//---- buffers
//double upLR[];
//double loLR[];
double upBbKeltSqueeze[];
double loBbKeltSqueeze[];

int i,j,slippage=3;
double breakpoint=0.0;
double ema=0.0;
int peakf=0;
int peaks=0;
int valleyf=0;
int valleys=0; // , limit=0;
double ccis[61],ccif[61];
double delta=0;
double ugol=0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//   SetIndexStyle(0,DRAW_HISTOGRAM);
//   SetIndexBuffer(0,upLR);
//   SetIndexEmptyValue(0,EMPTY_VALUE);
//   SetIndexStyle(1,DRAW_HISTOGRAM);
//   SetIndexBuffer(1,loLR);
//   SetIndexEmptyValue(1,EMPTY_VALUE);
//
//   SetIndexStyle(2,DRAW_ARROW);
//   SetIndexBuffer(2,upBbKeltSqueeze);
//   SetIndexEmptyValue(2,EMPTY_VALUE);
//   SetIndexArrow(2,159);
//   SetIndexStyle(3,DRAW_ARROW);
//   SetIndexBuffer(3,loBbKeltSqueeze);
//   SetIndexEmptyValue(3,EMPTY_VALUE);
//   SetIndexArrow(3,159);


   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,upBbKeltSqueeze);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexArrow(0,159);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,loBbKeltSqueeze);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexArrow(1,159);


   
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
//---
   
   
   
   int counted_bars= IndicatorCounted(); // rates_total-2; // prev_calculated-1; // rates_total-1; // IndicatorCounted();
   int shift,limit;
   double diff,d,std,bbs;
   
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-31;
   if(counted_bars>=31) limit=Bars-counted_bars-1;

   for (shift=limit;shift>=0;shift--)   {
      //d=iMomentum(NULL,0,momPrd,PRICE_CLOSE,shift);
      //d=LinearRegressionValue(bolPrd,shift);
      //if(d>0) {
      //   upLR[shift]=d;
      //   loLR[shift]=0;
      //} else {
      //   upLR[shift]=0;
      //   loLR[shift]=d;
      //}
		diff = iATR(NULL,0,keltPrd,shift)*keltFactor;
		std = iStdDev(NULL,0,bolPrd,MODE_SMA,0,PRICE_CLOSE,shift);
		bbs = bolDev * std / diff;
      if(bbs<1) {
         upBbKeltSqueeze[shift]=0;
         loBbKeltSqueeze[shift]=EMPTY_VALUE;
      } else {
         loBbKeltSqueeze[shift]=0;
         upBbKeltSqueeze[shift]=EMPTY_VALUE;
      }
   }
   
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+






//+------------------------------------------------------------------+
//double LinearRegressionValue(int Len,int shift) {
//   double SumBars = 0;
//   double SumSqrBars = 0;
//   double SumY = 0;
//   double Sum1 = 0;
//   double Sum2 = 0;
//   double Slope = 0;
//
//   SumBars = Len * (Len-1) * 0.5;
//   SumSqrBars = (Len - 1) * Len * (2 * Len - 1)/6;
//
//  for (int x=0; x<=Len-1;x++) {
//   double HH = Low[x+shift];
//   double LL = High[x+shift];
//   for (int y=x; y<=(x+Len)-1; y++) {
//     HH = MathMax(HH, High[y+shift]);
//     LL = MathMin(LL, Low[y+shift]);
//   }
//    Sum1 += x* (Close[x+shift]-((HH+LL)/2 + iMA(NULL,0,Len,0,MODE_EMA,PRICE_CLOSE,x+shift))/2);
//    SumY += (Close[x+shift]-((HH+LL)/2 + iMA(NULL,0,Len,0,MODE_EMA,PRICE_CLOSE,x+shift))/2);
//  }
//  Sum2 = SumBars * SumY;
//  double Num1 = Len * Sum1 - Sum2;
//  double Num2 = SumBars * SumBars-Len * SumSqrBars;
//
//  if (Num2 != 0.0)  { 
//    Slope = Num1/Num2; 
//  } else { 
//    Slope = 0; 
//  }
//
//  double Intercept = (SumY - Slope*SumBars) /Len;
//  //debugPrintln(Intercept+" : "+Slope);
//  double LinearRegValue = Intercept+Slope * (Len - 1);
//
//  return (LinearRegValue);
//
//}


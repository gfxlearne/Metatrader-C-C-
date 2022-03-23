//+------------------------------------------------------------------+
//|                                                   Z_Donchian.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
//#property strict
//#property indicator_chart_window



//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3//3
#property indicator_color1 Green
#property indicator_color2 Red
//#property indicator_color3 DarkKhaki
#property  indicator_width1 2
#property  indicator_width2 2
//#property  indicator_width3 1
//---- indicator parameters
extern int periods=50;
//extern int distance=200;
//extern bool fixed=false;
//---- indicator buffers
double upper[];
double lower[];
//double middle[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//=   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
//---- indicator buffers mapping
   SetIndexBuffer(0,upper);
   SetIndexBuffer(1,lower);
//   SetIndexBuffer(2,middle);
//---- name for DataWindow and indicator subwindow label

   SetIndexLabel(0,"Upper");
   SetIndexLabel(1,"Lower");
//   SetIndexLabel(2,"Middle");

   IndicatorShortName("Limited Donchian Chanel("+IntegerToString(periods)+")");

//---- initialization done



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
/*
   if(prev_calculated<1)
     {
      for(int j=0; j<periods; j++)
        {
         upper[j]=EMPTY_VALUE;
         lower[j]=EMPTY_VALUE;
         //ExtLowerBuffer[i]=EMPTY_VALUE;
        }
     }
*/

   if(IsNewCandle())  // Profit_Target NOT reach
   {  
//Print("Current_P_L @@@@@@@@@@@@@@@============== ", Current_P_L);     
      UpdateIndicator();
   }







   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



void UpdateIndicator() 
{
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int i = Bars - counted_bars;
   if(counted_bars==0) i-=1+1;
  
   while(i>=0)
      {
      double u=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,periods,i));
      double l=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,periods,i));
      
      
//Print("llllllllllllllllllllllllll = ", l);      

         if(upper[i]>u)
         {
            upper[i]=u;
         }
         else
         { 
            upper[i]=upper[i+1];
         } 

         if(lower[i]>l)
         {
            lower[i]=l;
         }
         else
         { 
            lower[i]=lower[i+1];
         } 
               
      i--;
      }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Check if new Candle                                             |
//+------------------------------------------------------------------+
bool IsNewCandle ()
{
    static datetime saved_candle_time;
    if(Time[0]==saved_candle_time)
       return false;
    else
       saved_candle_time = Time[0];
    return true;
    
/*    
   static int BarsOnChart=0;
   if (Bars == BarsOnChart)  
       return (false);
    else
       BarsOnChart = Bars;
    return (true);
*/          
    
}   
//+------------------------------------------------------------------+


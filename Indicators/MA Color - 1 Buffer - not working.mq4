//+------------------------------------------------------------------+
//|                                                     MA Color.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#property indicator_separate_window
#property indicator_chart_window

#property indicator_buffers 3 // MA up, MA down, MA from up->down or from down->up

#property indicator_color1 clrYellow
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrTomato

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

//#property indicator_levelstyle STYLE_DASH
//#property indicator_levelcolor clrRed


// created 22-2-2022
// need to check why when there is a change of trend, I need to use the sideway buffer in-order for it to show(draw) on chart.

//External setting
input int MAPeriod = 50; // MA Period 
//input int SlowPeriod = 26; // Slow Period 
//input int SignalPeriod = 9; // Signal Period 

input ENUM_MA_METHOD     MAMethod    = MODE_SMA; // MA Method
input ENUM_APPLIED_PRICE MAAppliedTo = PRICE_CLOSE; // MA Applied To...
input int                MAShift     = 0; // MA Shift
//input ENUM_MA_METHOD SlowMethod = MODE_EMA; // Slow Method
//input ENUM_APPLIED_PRICE SlowAppliedTo = PRICE_CLOSE; // Slow Applied To...
//input ENUM_MA_METHOD SignalMethod = MODE_SMA; // Signal Method
//input int SignalShift = 0; // Signal Shift
//input double levels = 0.002;

double MAtrend[];
//double Downtrend[];
//=double Sideway[];
//double MacdBuffer[];




//extern string s3; // Alarm Settings.
//input bool SoundAlert = false; // Sound an alert?
//input bool SendEmail = false; // Send an email?
//input bool Sendnotification = false; // Send a notification?





//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   IndicatorBuffers(3); // 
   
//--- indicator buffers mapping

   SetIndexBuffer(0,MAtrend); // associated array with buffer   
   SetIndexStyle(0,DRAW_LINE);  
   SetIndexLabel(0,"Sideway MA");   
  
//   SetIndexBuffer(1,Uptrend); // associated array with buffer   
//   SetIndexStyle(1,DRAW_LINE);
//   SetIndexLabel(1,"Uptrend MA");
//
//   SetIndexBuffer(2,Downtrend); // associated array with buffer   
//   SetIndexStyle(2,DRAW_LINE);
//   SetIndexLabel(2,"Downtrend MA");
         
   IndicatorShortName("ZRND - MA COLOR (" + (string)MAPeriod + "," +  ")" );
   
   
   
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

   int limit = rates_total-prev_calculated; // usually equal to 0, unless first tick of new bar(equal to 1). and unless the first time we drop the indicator on the chart      
 
// calculate Green/Red MA 
//----since we chekcing i+1 , for the first drop ont he indicator , we need to run 1 less bar to check(to prevent array out of range), so we decrement limit once again by 1 
   if(prev_calculated==0) // first time we drop the indicator on the chart   , (!prev_calculated)  
      limit = limit-1;// added -1 because to prevent array out of range (because we check i in the for loop)  
   
   //for(int i=0;i<limit;i++) // calculate Green/Red histogram
   for(int i=limit-1;i>=0;i--) // calculate Green/Red histogram  (for ease of logic thinking) 
   {
      double current = iMA(Symbol(),Period(),MAPeriod,MAShift,MAMethod,MAAppliedTo,i);
      double previous = iMA(Symbol(),Period(),MAPeriod,MAShift,MAMethod,MAAppliedTo,i+1);
      
      
      if(current<previous) // MA is decreasing
      {
         SetIndexEmptyValue(0,0.0);
         SetIndexStyle(0,DRAW_LINE,NULL,2,clrTomato);         
         //Downtrend[i]=current; // Red Histogram(above the zero line)
         //Uptrend[i] = EMPTY_VALUE; // since we updating real-time and a candle can start Growing but than Shrinking, we need to update to EMPTY_VALUE
         //Sideway[i] = current;
      }
      
      else if(current>=previous) // MA is increasing 
      {
         SetIndexEmptyValue(0,0.0);
         SetIndexStyle(0,DRAW_LINE,NULL,5,clrDodgerBlue);         
         SetIndexStyle(0,DRAW_LINE,NULL,2,clrTomato); 
         SetIndexStyle(0,DRAW_LINE,NULL,5,clrWhite);         
         
         //Uptrend[i]=current; // Green Histogram(above the zero line)
         //Downtrend[i] = EMPTY_VALUE;            
         //Sideway[i] = current;
      }
                                 
      MAtrend[i] = current;   
   
   }     
              
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

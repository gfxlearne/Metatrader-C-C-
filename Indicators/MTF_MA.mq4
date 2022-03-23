//+------------------------------------------------------------------+
//|                                                       MTF_MA.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// https://www.youtube.com/watch?v=dP4VrC_nhJA&ab_channel=OrchardForex

#property indicator_chart_window
#property indicator_buffers   1
#property indicator_color1    clrYellowGreen
#property indicator_width1    4


input ENUM_TIMEFRAMES    InpTimeFrame    = PERIOD_D1;    // Select higher timeframe
input int                InpMAPeriod     = 50;           // Moving average period
input ENUM_MA_METHOD     InpMethod       = MODE_SMA;     // MA Method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;  // Applied price


double BufferMA[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(InpTimeFrame<Period()) // check that it is indeed higher TF
   {
      PrintFormat("You must select a timeframe higher than the current chart. Current=%s, selected");
      return(INIT_PARAMETERS_INCORRECT);
   }  
   
   SetIndexBuffer(0, BufferMA);
    
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
      
   int limit = rates_total-prev_calculated; // how many bars to calculte


//=====checking that there is data from the gigher TF====
   static int waitCount=10; // 10 tries to get the data (to prevent infinite loop)
   if (prev_calculated==0)  // first time (and therefore need to check that there is data from higher TF)
   {
      if(waitCount>0) // you can still try to get the data
      {
         datetime t = iTime(Symbol(), InpTimeFrame, 0); // geting the data from higher TF
         int err = GetLastError(); // get the error only 1 time, even if the error still exists(that the reasong why we don't use the err in this code)
         if(t==0) // no data from the higher TF
         {
            waitCount--;
            PrintFormat("Waiting for data");
            return(prev_calculated);  // in this way we will return to the loop next time-> and than tries to get the data again(since prev_calculated==0)                   
         }
         PrintFormat("Data is now available");      
      }
      else // more than 10 tries to get data
      {
         Print("Can't wait for data any longer");
      }   
   }
//=================================================================



   
   //if(prev_calculated>0) limit++; // last bar need to recaculate every event

//=======this code is becaus ewe need to recalculte the MA not just for the last bar but for a number of bars since it is recalculate for higher TF
   if(prev_calculated>0)
   {
      if (limit<int(InpTimeFrame/Period()))  limit = int(InpTimeFrame/Period()); // there are number of bars to recaculate(when we are at the right side of the chart)
      if (limit>ArraySize(time))             limit = ArraySize(time); // to check that we do not exceed the size of data avaiable
   }
//===========================================
      
   
   for (int i=limit-1; i>0; i--)
   {
      int mtfBar = iBarShift(Symbol(), InpTimeFrame, time[i], false); // caculate the relevant bar to the higher TF
      BufferMA[i] = iMA(Symbol(), InpTimeFrame, InpMAPeriod, 0, InpMethod, InpAppliedPrice,mtfBar);   
   }   
 
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

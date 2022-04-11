//+------------------------------------------------------------------+
//|                                                   PeakFinder.mq4 |
//|                                                               ZB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ZB"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


// https://www.youtube.com/watch?v=3-yKhOQlWvc&ab_channel=OrchardForex


void OnStart()
{

   // find 2 peaks and connet a line
   
   int shoulder = 5; // 5 bars to the left , 5 bars to the right
   int bar1;
   int bar2;

// find the highs     
   bar1 = FindPeak(MODE_HIGH, shoulder, 0);
   bar2 = FindPeak(MODE_HIGH, shoulder, bar1+1); // after we found the peak of bar1, we search for the next highest begining bar1+1
 
 
   // draw the line over the highs  
   ObjectDelete(0, "upper");
   ObjectCreate(0, "upper", OBJ_TREND, 0, iTime(Symbol(), Period(), bar2), iHigh(Symbol(), Period(), bar2), iTime(Symbol(), Period(), bar1), iHigh(Symbol(), Period(), bar1));
   ObjectSetInteger(0, "upper", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "upper", OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, "upper", OBJPROP_RAY_RIGHT, true); // the line will continue to the right
  
  
  
// find the lows  
   bar1 = FindPeak(MODE_LOW, shoulder, 0);
   bar2 = FindPeak(MODE_LOW, shoulder, bar1+1); // after we found the peak of bar1, we search for the next lowest begining bar1+1
 
 
   // draw the line over the lows  
   ObjectDelete(0, "lower");
   ObjectCreate(0, "lower", OBJ_TREND, 0, iTime(Symbol(), Period(), bar2), iLow(Symbol(), Period(), bar2), iTime(Symbol(), Period(), bar1), iLow(Symbol(), Period(), bar1));
   ObjectSetInteger(0, "lower", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "lower", OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, "lower", OBJPROP_RAY_RIGHT, true); // the line will continue to the right
  
   
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
int FindPeak(int mode, int count, int startBar)
{

   if (mode!=MODE_HIGH && mode!=MODE_LOW) return(-1); // return not a valid bar number
   
   int currentBar = startBar; // currentBar is the counter that will go through the bars (and will be the reurn value , the peak)
   int foundBar = FindNextPeak(mode, count*2+1, currentBar-count);
  
   while (foundBar!=currentBar) // we did not find the peak bar yet(need to keep searcing)
   {
      // we know currentBar was not the peak, so we step 1 to the left to check if this is the peak 
      currentBar = FindNextPeak(mode, count, currentBar+1); // since this time we are only looking to the left we only pass count(and not count*2+1)
      foundBar = FindNextPeak(mode, count*2+1, currentBar-count); // exactly the same code as before the while loop (to check if there is a bar to is peakest than yje currentBar)      
   }
   
   return currentBar;
   
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
// almost same as iHighest/iLowest (returns the bar number)
int FindNextPeak(int mode, int count, int startBar) 
{
   // count is the number of bars to find the highest/lowest
   
   if(startBar<0)
   {
      count += startBar; // refuce the size of count
      startBar = 0; // to know that we start at least at bar 0
   }
   
   return(  (mode==MODE_HIGH) ?
            iHighest(Symbol(), Period(), (ENUM_SERIESMODE)mode, count, startBar) :
            iLowest(Symbol(), Period(), (ENUM_SERIESMODE)mode, count, startBar) 
         );   

}
//+------------------------------------------------------------------+

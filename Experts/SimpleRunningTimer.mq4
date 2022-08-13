//+------------------------------------------------------------------+
//|                                           SimpleRunningTimer.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


datetime CurrentTime;
datetime StartTime;
datetime PassedTimeInSeconds;

string CurrentTimeWithSeconds;
string StartTimeWithSeconds;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

   // if start time has no value (when the ea is forst strated)
   if(StartTime==0)
   {
      // set it to local time of the computer
      StartTime = TimeLocal();
      
      // create readable format
      //StartTimeWithSeconds = TimeToStr(StartTime, TIME_DATE|TIME_SECONDS);   
      StartTimeWithSeconds = TimeToStr(StartTime, TIME_SECONDS);
   }
   
   // calculate current time
   CurrentTime = TimeLocal();
   //CurrentTime = TimeLocal() - __DATE__;
   
   // create readable format
   //CurrentTimeWithSeconds = TimeToStr(CurrentTime, TIME_DATE|TIME_SECONDS);
   CurrentTimeWithSeconds = TimeToStr(CurrentTime, TIME_SECONDS);

   // calculate passed seconds
   PassedTimeInSeconds = CurrentTime - StartTime;
         
   //create chart output
   Comment (
               "\n",               
               "Start Time With Seconds (string):        ", StartTimeWithSeconds, "\n",
               "Current Time With Seconds (string):        ", CurrentTimeWithSeconds, "\n", 
               "\n",  
               "Start Time (datetime):        ", StartTime, "\n",      
               "Current Time (datetime):        ", CurrentTime, "\n",  
               "\n",
               "Passed Time in Seconds:        ", PassedTimeInSeconds, "\n",                            
               "Passed Time in Minutes:        ", PassedTimeInSeconds/60, "\n",                                              
               "Passed Time in Hours:        ", PassedTimeInSeconds/3600, "\n"
               , "\n", TimeToString (TimeLocal(),TIME_SECONDS) 
               , "\n", __DATE__
               , "\n", __DATETIME__ - __DATE__,                             
               "\n",
               "\n",
               "Passed Time in Seconds:        ", PassedTimeInSeconds, "\n",  
               "TimeToStr:               ", TimeToStr(PassedTimeInSeconds,TIME_SECONDS), "\n",                                         
               "FuncTion TimeToStringWithoutDate:          ", TimeToStringWithoutDate(PassedTimeInSeconds)

               
            );                                                 
}
//+------------------------------------------------------------------+




string TimeToStringWithoutDate(datetime when)
{

  string FullDate = TimeToStr(when,TIME_SECONDS);              // "yyyy.mm.dd hh:mi"
return FullDate;  
  
  //string withOut = StringSubstr(withSep,  0, 4)  // yyyy
  //               + StringSubstr(withSep,  5, 2)  // mm
  //               + StringSubstr(withSep,  8, 5)  // dd hh
  //               + StringSubstr(withSep, 14, 3); // mi
                 
   string timeOnly = StringSubstr(FullDate, 11, 8);                 
   
  return(timeOnly);                               // "yyyymmdd hhmi"
}
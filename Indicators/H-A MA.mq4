//+------------------------------------------------------------------+
//|                                                       H-A MA.mq4 |
//|                   Copyright 2006-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2006-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "We recommend next chart settings (press F8 or select menu 'Charts'->'Properties...'):"
#property description " - on 'Color' Tab select 'Black' for 'Line Graph'"
#property description " - on 'Common' Tab disable 'Chart on Foreground' checkbox and select 'Line Chart' radiobutton"
#property strict


// HA MA that based on the original HA indicator




#property indicator_chart_window
#property indicator_buffers 5 // Changed from 4 to add 1 for MA
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3



//------added----------------------------
// The MA properties
#property indicator_color5    clrWhite
#property indicator_type5     DRAW_LINE
#property indicator_style5    STYLE_SOLID
#property indicator_width5    4

enum ENUM_HA_BUFFERS
{
   HA_BUFFER_LOWHIGH = 0,     // Low/High
   HA_BUFFER_HIGHLOW = 1,     // High/Low
   HA_BUFFER_OPEN    = 2,     // Open
   HA_BUFFER_CLOSE   = 3     // Close
};
//---------------------------------------


//---
input color ExtColor1 = Red;    // Shadow of bear candlestick
input color ExtColor2 = White;  // Shadow of bull candlestick
input color ExtColor3 = Red;    // Bear candlestick body
input color ExtColor4 = White;  // Bull candlestick body

input color ExtColor5 = White;  // MA




//------added----------------------------
input int               InpPeriods     =  10;               // Periods
input ENUM_MA_METHOD    InpMethod      =  MODE_SMA;         // MA Method
input ENUM_HA_BUFFERS   InpBuffer      =  HA_BUFFER_CLOSE;  // MA on HA Buffer?
//---------------------------------------



//--- buffers
double ExtLowHighBuffer[];
double ExtHighLowBuffer[];
double ExtOpenBuffer[];
double ExtCloseBuffer[];

//------added----------------------------
double ExtMA[];   // Moving average buffer
//---------------------------------------



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
void OnInit(void)
  {
   IndicatorShortName("Heiken Ashi");
   IndicatorDigits(Digits);
//--- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,ExtColor1);
   SetIndexBuffer(0,ExtLowHighBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,ExtColor2);
   SetIndexBuffer(1,ExtHighLowBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,ExtColor3);
   SetIndexBuffer(2,ExtOpenBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,ExtColor4);
   SetIndexBuffer(3,ExtCloseBuffer);
//---
   SetIndexLabel(0,"Low/High");
   SetIndexLabel(1,"High/Low");
   SetIndexLabel(2,"Open");
   SetIndexLabel(3,"Close");
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLowHighBuffer);
   SetIndexBuffer(1,ExtHighLowBuffer);
   SetIndexBuffer(2,ExtOpenBuffer);
   SetIndexBuffer(3,ExtCloseBuffer);
   
   
//------added----------------------------
   // Just do the same as above for the MA that added to chart
   SetIndexLabel(4,"MA");
   SetIndexDrawBegin(4,10);
   SetIndexBuffer(4,ExtMA);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,4,ExtColor5);   
//---------------------------------------
   
   
   
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Heiken Ashi                                                      |
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
   int    i,pos;
//------added----------------------------   
   int ipos;   // Used for the ma calculation loop
//---------------------------------------
   
   double haOpen,haHigh,haLow,haClose;
//---
   if(rates_total<=10)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtLowHighBuffer,false);
   ArraySetAsSeries(ExtHighLowBuffer,false);
   ArraySetAsSeries(ExtOpenBuffer,false);
   ArraySetAsSeries(ExtCloseBuffer,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
     {
      //--- set first candle
      if(open[0]<close[0])
        {
         ExtLowHighBuffer[0]=low[0];
         ExtHighLowBuffer[0]=high[0];
        }
      else
        {
         ExtLowHighBuffer[0]=high[0];
         ExtHighLowBuffer[0]=low[0];
        }
      ExtOpenBuffer[0]=open[0];
      ExtCloseBuffer[0]=close[0];
      //---
      pos=1;
     }
//--- main loop of calculations
   for(i=pos; i<rates_total; i++)
     {
      haOpen=(ExtOpenBuffer[i-1]+ExtCloseBuffer[i-1])/2;
      haClose=(open[i]+high[i]+low[i]+close[i])/4;
      haHigh=MathMax(high[i],MathMax(haOpen,haClose));
      haLow=MathMin(low[i],MathMin(haOpen,haClose));
      if(haOpen<haClose)
        {
         ExtLowHighBuffer[i]=haLow;
         ExtHighLowBuffer[i]=haHigh;
        }
      else
        {
         ExtLowHighBuffer[i]=haHigh;
         ExtHighLowBuffer[i]=haLow;
        }
      ExtOpenBuffer[i]=haOpen;
      ExtCloseBuffer[i]=haClose;
     }
//--- done





//------added- The MA calculation----------------------------  
      // Now just calculate the MA using iMAOnArray
      // Separate loop due to direction of calculation and performance
      int limit = rates_total - prev_calculated - 1;
      if (prev_calculated>0) limit++;
             
      for(ipos=limit; ipos>=0; ipos--)
      {
         int range = ((rates_total-ipos)<InpPeriods) ? (rates_total-ipos) : InpPeriods;
         
         switch (InpBuffer)
         {
            case HA_BUFFER_CLOSE    :  ExtMA[ipos] = iMAOnArray(ExtCloseBuffer, 0, range, 0, InpMethod, ipos); break;
            case HA_BUFFER_OPEN     :  ExtMA[ipos] = iMAOnArray(ExtOpenBuffer, 0, range, 0, InpMethod, ipos); break;
            case HA_BUFFER_HIGHLOW  :  ExtMA[ipos] = iMAOnArray(ExtHighLowBuffer, 0, range, 0, InpMethod, ipos); break;
            case HA_BUFFER_LOWHIGH  :  ExtMA[ipos] = iMAOnArray(ExtLowHighBuffer, 0, range, 0, InpMethod, ipos); break;                                          
         }    
      }
//---------------------------------------



   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                   Arrow - Ver3 - with Buffer.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

// updated 21-12-2021 (added buffers to hold value, instead of drawrrow function)
#property indicator_buffers 2
#property indicator_color1 clrOrange
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2

// https://www.youtube.com/watch?v=hxnI0ahEbJ8&t=851s&ab_channel=OrchardForex


// Some inputs
// MACD
input int                   InpMACDFastPeriod   =   12;           // MACD Fast Period
input int                   InpMACDSlowPeriod   =   26;           // MACD Slow Period
input int                   InpMACDSignalPeriod =   9;            // MACD Signal Period
input ENUM_APPLIED_PRICE    InpMACDAppliedPrice =   PRICE_CLOSE;  // MACD Applied Price

// Stochastics
input int                   InpStochKPeriod     =   70;           // Stochastics K Period
input int                   InpStochDPeriod     =   10;           // Stochastics D Period
input int                   InpStochSlowPeriod  =   10;           // Stochastics Slowing Period


double upArrow[];
double downArrow[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {


   SetIndexBuffer(0,upArrow); // associated array with buffer   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233); // drawing wingding 233
   SetIndexLabel(0,"Stochastics OverSold + Hook on Osma.");
   
   SetIndexBuffer(1,downArrow); // associated array with buffer
   SetIndexStyle(1,DRAW_ARROW);   
   SetIndexArrow(1,234); // drawing wingding 234   
   SetIndexLabel(1,"Stochastics OverBought + Hook on Osma.");      


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+



void OnDeinit (const int reason)  
{
   cleanup();
//===
//ObjectDelete("Down"+Bars); // clean the arrrow at bars_back
//=ObjectDelete("Down"); // clean the arrrow at bars_back

//====

}



void cleanup() 
{


   string objName;
   for (int i = ObjectsTotal() - 1; i >= 0; i--) 
   {
      objName = ObjectName(i);
      if (StringFind(objName, "IB_Flag_") == 0) ObjectDelete(objName);
      if (StringFind(objName, "IB_Arrow_") == 0) ObjectDelete(objName);
   }
}






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


//=====25-9-2021====
// https://www.youtube.com/watch?v=8gRtm5xH-gQ&t=773s&ab_channel=Jimdandy1958

   int total = (prev_calculated==0) ? (rates_total-3) : (rates_total-prev_calculated); // prev_calculated==0 only one time, when indicator is dropped on chart(on first tick).    (rates_total-3) so we don't get array out of range.      (rates_total-prev_calculated) == 1 only on first tick of new candle otherwise (rates_total-prev_calculated) == 0
   
   //total = (total>1) ? total : total; // total>1 meaning it is not realtime, or it is not new candle(=0)


   for (int i=total; i>0; i--) // in real time, if it is NOT new candle total=0 and the loop will not run
   {
      int conditions = CheckConditions(i);
      
      //if (high[i+1]>high[i+2] || low[i+1]<low[i+2])  continue; // return(rates_total); // Not inside bar
         
      if (conditions == 1) // Buying trend
      {
         upArrow[i]=Low[i]; 
         //DrawArrow("Open", time[i+0], low[i+0], clrOrange, "Up"); // DrawFlag("Open", time[i+1], low[i+2], clrRed);                  
      }   
      else if (conditions == -1) // Rare cases where price=ma(not draw anything in that case)
      {
         downArrow[i]=High[i]; 
         //DrawArrow("Open", time[i+0], high[i+0], clrRed, "Down"); // DrawFlag("Open", time[i+1], high[i+2], clrGreen);           
      }
            
   }

//==============


//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+




int CheckConditions(int barNum)
{
   
   int value = 0;

   double macd1 = iMACD(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, barNum+0);
   double macd2 = iMACD(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, MODE_MAIN, barNum+1);   
  
   double stoch = iStochastic(Symbol(), Period(), InpStochKPeriod, InpStochDPeriod, InpStochSlowPeriod, MODE_SMA, 0, MODE_MAIN, barNum+0);
 
   double osma1 = iOsMA(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, barNum+0);
   double osma2 = iOsMA(Symbol(), Period(), InpMACDFastPeriod, InpMACDSlowPeriod, InpMACDSignalPeriod, InpMACDAppliedPrice, barNum+1);   
 
 
 
Print(__FUNCTION__,"Candle num: " , barNum, "   macd1 =", macd1,"    macd2 =", macd2, "   stoch =", stoch);
   
   if(osma2<0 && osma1>0 // Buy Arrow
      && stoch<20
      )
   {
      value = 1;
   }      

   if(osma2>0 && osma1<0 // Sell Arrow
      && stoch>80
      )
   {
      value = -1;
   }      

/*
   if(macd2<0 && macd1>0 // Buy Arrow
      && stoch<20
      )
   {
Print("value = 1",__FUNCTION__,"   macd1 =", macd1,"    macd2 =", macd2, "   stoch =", stoch);   
      value = 1;
   }      

   if(macd2>0 && macd1<0 // Sell Arrow
      && stoch>80
      )
   {
Print("value = --1",__FUNCTION__,"   macd1 =", macd1,"    macd2 =", macd2, "   stoch =", stoch);   
      value = -1;
   }      
*/


   return value;

}


/*
//+------------------------------------------------------------------+

void DrawFlag(string tag, datetime time, double price, color clr)
{

   string name = "IB_Flag_" + tag + time ;
   
   ObjectCreate(0, name, OBJ_ARROW_LEFT_PRICE, 0, time, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);

}


//+------------------------------------------------------------------+



void DrawArrow(string tag, datetime time, double price, color clr, string direction)
{

   string name = "IB_Arrow_" + tag + time + direction ;
   
   // Create the object if it doesn't already exist
  // if (ObjectFind(0, name)<0)
   //{
   
   ENUM_OBJECT   object_type;
   if (direction == "Up")
   {
      object_type = OBJ_ARROW_UP; // OBJ_ARROW_BUY; // OBJ_ARROW_UP;
   }
   else if (direction == "Down")
   {
      object_type = OBJ_ARROW_DOWN; // OBJ_ARROW_SELL; // OBJ_ARROW_DOWN;
   }
   
   
   
   ObjectCreate(0, name, object_type, 0, time, price);         
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   
   if (clr == clrRed)
   {
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   }
   
}

//+------------------------------------------------------------------+
*/


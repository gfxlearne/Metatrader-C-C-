//+------------------------------------------------------------------+
//|                                                 hoverExample.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   // to know where the mouse is on the chart
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   
   // create the button1
   ObjectCreate(0, "White", OBJ_BUTTON, 0, 0, 0);
   ObjectSetText("White","White");
   ObjectSetInteger(0, "White", OBJPROP_SELECTABLE,true);
   

   // create the button2
   ObjectCreate(0, "Khaki", OBJ_BUTTON, 0, 0, 0);
   ObjectSetText("Khaki","Khaki");
   ObjectSetInteger(0, "Khaki", OBJPROP_SELECTABLE,true);
   
   // seting the "Khaki" x locaton, according to "White" button x location
   long leftWhite = ObjectGetInteger(0, "White", OBJPROP_XDISTANCE);
   long rightWhite = leftWhite + ObjectGetInteger(0, "White", OBJPROP_XSIZE);
   long leftKhaki = ObjectSetInteger(0, "Khaki", OBJPROP_XDISTANCE, rightWhite+20);

   





return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   ObjectDelete(0, "White");

   ObjectDelete(0, "Khaki");


        
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






   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,     // x
                  const double &dparam,   // y
                  const string &sparam)
{

   // Comment(lparam, "\n", dparam);
 
//---White button   
   long leftWhite = ObjectGetInteger(0, "White", OBJPROP_XDISTANCE);  // x1
   long rightWhite = leftWhite + ObjectGetInteger(0, "White", OBJPROP_XSIZE); // x2

   long topWhite = ObjectGetInteger(0, "White", OBJPROP_YDISTANCE);  // y1 
   long bottomWhite = topWhite + ObjectGetInteger(0, "White", OBJPROP_YSIZE); // y2

   // checking the location of the mouse cursor (white button) 
   if(   lparam>leftWhite && lparam<rightWhite // mouse cursor is within the x's
      && dparam>topWhite && dparam<bottomWhite // mouse cursor is within the y's
     )
   {            
      ObjectSetInteger(0, "White", OBJPROP_STATE,true);     
   }
   else
   {
      ObjectSetInteger(0, "White", OBJPROP_STATE,false);        
   }



// check if the white button has been clicked
   if(id == CHARTEVENT_OBJECT_CLICK && sparam=="White")
   {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);   
   }
   
   

//---Khaki button
   long leftKhaki = ObjectGetInteger(0, "Khaki", OBJPROP_XDISTANCE);  // x1
   long rightKhaki = leftKhaki + ObjectGetInteger(0, "Khaki", OBJPROP_XSIZE); // x2

   long topKhaki = ObjectGetInteger(0, "Khaki", OBJPROP_YDISTANCE);  // y1 
   long bottomKhaki = topKhaki + ObjectGetInteger(0, "Khaki", OBJPROP_YSIZE); // y2
 
   // checking the location of the mouse cursor (Khaki button)
   if(   lparam>leftKhaki && lparam<rightKhaki // mouse cursor is within the x's
      && dparam>topKhaki && dparam<bottomKhaki // mouse cursor is within the y's
     )
   {            
      ObjectSetInteger(0, "Khaki", OBJPROP_STATE,true);     
   }
   else
   {
      ObjectSetInteger(0, "Khaki", OBJPROP_STATE,false);        
   }
 
 

// check if the khaki button has been clicked
   if(id == CHARTEVENT_OBJECT_CLICK && sparam=="Khaki")
   {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrKhaki);   
   }
 
 
 
   
   
}
//+------------------------------------------------------------------+

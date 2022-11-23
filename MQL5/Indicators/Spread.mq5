//+------------------------------------------------------------------+
//|                                                       Spread.mq5 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window



input color InpFont_color = Red;
input int InpFont_size = 34; // 14;
input string InpFont_face = "Arial";
input int InpCorner = 0; //0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
input int Inp_spread_distance_x = 10;
input int Inp_spread_distance_y = 130;
input bool Inp_normalize = false; //If true then the spread is normalized to traditional pips



double Poin;
int n_digits = 0;
double divider = 1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   //Checking for unconvetional Point digits number
   if (_Point == 0.00001) Poin = 0.0001; //5 digits
   else if (_Point == 0.001) Poin = 0.01; //3 digits
   else Poin = _Point; //Normal
   
Print("_Point = ", _Point);
Print("_Digits = ", _Digits);

   ObjectCreate(0, "Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Spread", OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, "Spread", OBJPROP_XDISTANCE, Inp_spread_distance_x);
   ObjectSetInteger(0, "Spread", OBJPROP_YDISTANCE, Inp_spread_distance_y);


   //double spread = MarketInfo(Symbol(), MODE_SPREAD);
   //double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);


   //if ((Poin > _Point) && (Inp_normalize))
   //{
   //   divider = 10.0;
   //   n_digits = 1;
   //}
   
   //string txt = "Spread: " + DoubleToString(NormalizeDouble(spread / divider, 1), n_digits) + " points.";
   ////ObjectSetString(0, "Spread", OBJPROP_TEXT, txt, InpFont_size, InpFont_face, InpFont_color);
   //ObjectSetString(0, "Spread", OBJPROP_TEXT, txt);
   //ObjectSetInteger(0, "Spread", OBJPROP_FONTSIZE, InpFont_size);
   //ObjectSetString(0, "Spread", OBJPROP_FONT, InpFont_face);
   //ObjectSetInteger(0, "Spread", OBJPROP_COLOR, InpFont_color);




   return(INIT_SUCCEEDED);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0,"Spread");
   
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


//Print("spread[0] = ", spread[0]);

   //double sprd = spread[0];
   
   
   double sprd = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
   sprd =  NormalizeDouble(sprd/_Point, _Digits);
   
//Print("sprd = ", sprd);


   //=sprd = sprd / _Point; 
   
   
   // for two/four digits pairs
   //if (_Digits!=3 && _Digits!=5)
   //{
   //   sprd = sprd*10;
   //}
   
   //Comment(SymbolInfoDouble(_Symbol, SYMBOL_ASK), "\n", SymbolInfoDouble(_Symbol, SYMBOL_BID), "\n", sprd);
   
   
   //string txt = "Spread: " + DoubleToString(NormalizeDouble(sprd / divider, 1), n_digits) + " points.";
   
   //string txt = "Spread: " + spread[0] + " points.";
   
   string txt = "Spread: " + DoubleToString(sprd,0) + " points.";
      
   ObjectSetString(0, "Spread", OBJPROP_TEXT, txt);
   ObjectSetInteger(0, "Spread", OBJPROP_FONTSIZE, InpFont_size);
   ObjectSetString(0, "Spread", OBJPROP_FONT, InpFont_face);
   ObjectSetInteger(0, "Spread", OBJPROP_COLOR, InpFont_color);




   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+




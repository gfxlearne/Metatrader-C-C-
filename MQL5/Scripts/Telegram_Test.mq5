//+------------------------------------------------------------------+
//|                                                Telegram_Test.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"




//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   string token = "";
   string chat_ID = "";
   
   string Message = "The number of open orders is equal to: " + IntegerToString(OrdersTotal());
   
   string BaseURL = "https://api/telegram.org/";
   
   string FinalURL = BaseURL + "/bot" + token + "/sendMessage?chat_id=" + chat_ID + "&text" + Message;
   
   string cookie;   
   string referer;
   int TimeOut = 2000;
   char data[];
   char result[];
   string result_headers;
   
   WebRequest("GET",FinalURL,cookie,referer,TimeOut,data,0,result,result_headers);
      
   
}
//+------------------------------------------------------------------+

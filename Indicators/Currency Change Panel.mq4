//+------------------------------------------------------------------+
//|                                        Currency Change Panel.mq4 |
//|                                                              gfx |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gfx"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


// ---AppDailog
#include <Controls\Dialog.mqh>
CAppDialog CurrencyAppDialog;
#define APP_DIALOG_NAME "CurrencyAppDialog"

// sizes of the dialog
int AppDialogTop = 0;  // x1
int AppDialogLeft = 0; // y1

int AppDialogWidth = 190;  // x2
int AppDialogHeight = 230; // y2
//---


// ---Panels
CPanel OurPanelArray [6][7]; // Panel is included at Dialog.mqh
#define PANEL_NAME "CurrencyPanel"

// sizes of the panels
int panelWidth = 30;
int panelHeight = 25;
//---


// ---Buttons
#include <Controls\Button.mqh>
CButton CButtonArray[6];
string ButtonNames[] = {"Aud", "Eur", "Gbp", "Cad", "Jpy", "Chf"};
string SymbolsArray[6];

input string prefix = "";
input string suffix = "";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   CurrencyAppDialog.Create(0, APP_DIALOG_NAME, 0, AppDialogLeft, AppDialogTop, 
                                        AppDialogLeft+AppDialogWidth, AppDialogTop+AppDialogHeight);
   
   CurrencyAppDialog.Run();
   
   
   // add panels to the dialog
   CreatePanels(); 
   
   // add buttons to the dialog
   CreateButtons(); 
   PopulateSymbolsArray(); // add symbols 
   
   

   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   CurrencyAppDialog.Destroy(reason);        
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


//+------------------------------------------------------------------+
//|  ChartEvent function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                       const long& lparam,
                       const double& dparam,
                       const string& sparam)
{
   
   // activate the dialog so when the dialog is clicked it will respond  
   CurrencyAppDialog.OnEvent(id, lparam, dparam, sparam); 
   
   
   // checking if button object has been clicked
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      ChangeSymbols(sparam); // sparam is the name of the object  
   
   }    
     
     
        
}


//+------------------------------------------------------------------+
//|  function to create panels (inside the dialog)                    |
//+------------------------------------------------------------------+
void CreatePanels()
{

   int left = 0; // x1
   int right = left + panelWidth; // x2
   
   int top = 0; // y1
   int bottom = top + panelHeight; // y2
   
   
   for(int i=0; i<6; i++)
   {
      for(int j=0; j<7; j++)
      {
         // create the panel
         OurPanelArray[i][j].Create(0, string(i)+string(j), 0, left, top, right, bottom);

         // setting colors of the panel
         OurPanelArray[i][j].ColorBackground(clrGray);
         OurPanelArray[i][j].ColorBorder(clrBlack);
         
         // add the panel to the dialog
         CurrencyAppDialog.Add(OurPanelArray[i][j]);
         
         // update the location indexes to the next panel location
         top += panelHeight; // top = top+panelHeight
         bottom += panelHeight;
        
        
         
      }

      // update the location indexes to the next panel row location      
      top = 0;
      bottom = top + panelHeight;
      
      left += panelWidth;
      right = left + panelWidth;   
   
   }   

}




//+------------------------------------------------------------------+
//|  function to create Buttons (inside the dialog)                  |
//+------------------------------------------------------------------+
void CreateButtons()
{

   int buttonWidth = panelWidth; // the size of button is the same as the size of panel
   
   int top = panelHeight*7; // y1
   int left = 0; // x1

   int right = left + buttonWidth; // x2   
   int bottom = panelHeight*8; // y2
   
   
   for(int i=0; i<6; i++)
   {
      // create a button
      CButtonArray[i].Create(0,ButtonNames[i], 0, left, top, right, bottom);
      
      // setting the text inside the button
      CButtonArray[i].Text(ButtonNames[i]);
      CButtonArray[i].Font("Arial Bold");
      CButtonArray[i].FontSize(8);
      
      // add the panel to the dialog
      CurrencyAppDialog.Add(CButtonArray[i]);
      
      // update the location indexes to the next button location      
      left += buttonWidth;
      right += buttonWidth;
      
      
   
   }   

}



//+------------------------------------------------------------------+
//|  This function combines prefix + symbol and suffix               |
//+------------------------------------------------------------------+
void PopulateSymbolsArray()
{
   SymbolsArray[0] = prefix + "AUDUSD" + suffix;
   SymbolsArray[1] = prefix + "EURUSD" + suffix;
   SymbolsArray[2] = prefix + "GBPUSD" + suffix;
   SymbolsArray[3] = prefix + "USDCAD" + suffix;
   SymbolsArray[4] = prefix + "USDJPY" + suffix;
   SymbolsArray[5] = prefix + "USDCHF" + suffix;            

}


//+------------------------------------------------------------------+
//|  Function to change to symbol when clicked                       |
//+------------------------------------------------------------------+
void ChangeSymbols(string sparam)
{

   if(sparam == "Aud")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[0], 0);
   }   

   if(sparam == "Eur")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[1], 0);
   }   

   if(sparam == "Gbp")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[2], 0);
   }   

   if(sparam == "Cad")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[3], 0);
   }   

   if(sparam == "Jpy")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[4], 0);
   }   

   if(sparam == "Chf")
   {
      ChartSetSymbolPeriod(0, SymbolsArray[5], 0);
   }   

}
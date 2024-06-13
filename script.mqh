
#property copyright "Copyright 2023, Jay Benedict Alfaras" 
#property version   "1.00"
#property strict 


#include "auto_trailstop.mqh" 

CAutoTrailstop auto_trailstop;  

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
   auto_trailstop.Scan(); 
  }
//+------------------------------------------------------------------+


#include <utilities/TradeOps.mqh> 

#include "definition.mqh" 

class CAutoTrailstop : public CTradeOps { 

private: 
      void     SetTrailStop(const int ticket); 
      void     SelectTicket(const int ticket); 
      int      TradeDiffToTradePoints(const string symbol, double value);   
      double   TradePointsToTradeDiff(const string symbol, int points_distance); 
      double   TrailStopPrice(const int ticket);  
      
      
      //--- Boolean 
      bool     IsAboveTrailStopThreshold(const int ticket); 
      bool     IsNewCandle(); 
      bool     AccountInProfit() const { return AccountInfoDouble(ACCOUNT_PROFIT); } 
      
      
      double   SymbolBid(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_BID); }
      double   SymbolAsk(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_ASK); }

public:
      CAutoTrailstop() {}  
      ~CAutoTrailstop() {}
      void     Scan(); 

};

//--- Selects specified ticket if not yet selected 
void     CAutoTrailstop::SelectTicket(const int ticket) {
   if (ticket != PosTicket()) OP_OrderSelectByTicket(ticket); 
}

//--- Checks if current candle is new candle.    
bool     CAutoTrailstop::IsNewCandle() {
   static datetime saved_candle_time; 
   datetime current_time = iTime(Symbol(), PERIOD_CURRENT, 0); 
   
   bool new_candle = current_time != saved_candle_time; 
   
   saved_candle_time = current_time; 
   
   return new_candle; 
}

//--- Converts trade diff into points 
int      CAutoTrailstop::TradeDiffToTradePoints(string symbol, double value) {
   double points = SymbolInfoDouble(symbol, SYMBOL_POINT);  // 1e-5  
   int trade_pts = value / points; 
   
   return trade_pts;
}  

//--- Calculates price difference from number of points/tickets given
double   CAutoTrailstop::TradePointsToTradeDiff(const string symbol, int points_distance) {
   double points = SymbolInfoDouble(symbol, SYMBOL_POINT); 
   return (points_distance * points); 
}

//--- Checks if ticket is above trail stop threshold 
bool     CAutoTrailstop::IsAboveTrailStopThreshold(int ticket) {
   SelectTicket(ticket); 
   if (!PosProfit()) return false;  
   
   ENUM_ORDER_TYPE order_type = PosOrderType();  
   double trade_diff = 0; 
   string symbol = PosSymbol();
   switch (order_type) {
      case ORDER_TYPE_BUY: 
         trade_diff  = SymbolBid(symbol) - PosOpenPrice(); 
         if (trade_diff < 0) return false; 
         break; 
      case ORDER_TYPE_SELL:
         trade_diff  = PosOpenPrice() - SymbolAsk(symbol);
         if (trade_diff < 0) return false; 
         break; 
      default:
         // pending  
         return false; 
   }
   int points = TradeDiffToTradePoints(symbol, trade_diff);  
   
   return points > InpTSPointsThreshold; 
} 

//--- Sets breakeven for specified ticket 
void     CAutoTrailstop::SetTrailStop(const int ticket) {
   SelectTicket(ticket); 
   double ts_price = TrailStopPrice(ticket); 
   if (ts_price == PosSL()) return;  // Don't modify if sl did not change 
   bool m = OP_ModifySL(ticket, ts_price);  
   // Set Logs here 
} 

//--- Calculates trail stop price
double    CAutoTrailstop::TrailStopPrice(const int ticket) {
   SelectTicket(ticket); 
   
   ENUM_ORDER_TYPE order_type = PosOrderType(); 
   string symbol = PosSymbol(); 
   double ts_price = 0.0; 
   switch(order_type) {
      case ORDER_TYPE_BUY:
         ts_price = SymbolBid(symbol) - TradePointsToTradeDiff(symbol, InpTSPointsDistance); 
         //--- Returns trail stop price if no sl was set 
         if (PosSL() == 0) return ts_price; 
         //--- Returns higher price     
         return MathMax(PosSL(), ts_price); 
      case ORDER_TYPE_SELL: 
         ts_price = SymbolAsk(symbol) + TradePointsToTradeDiff(symbol, InpTSPointsDistance); 
         //--- Returns trail stop price if no sl was set 
         if (PosSL() == 0) return ts_price; 
         //--- Returns lower price
         return MathMin(PosSL(), ts_price); 
      default: break; 
   }
   return ts_price; 
}

//--- Scans order pool for trades above threshold 
void     CAutoTrailstop::Scan() { 
   if (InpTSFrequency == Candle && !IsNewCandle()) return;   
   if (AccountInProfit()) return; 
   for (int i = 0; i < PosTotal(); i++) {
      int s = OP_OrderSelectByIndex(i);  
      int ticket = PosTicket();
      if (!IsAboveTrailStopThreshold(ticket)) continue; 
      SetTrailStop(ticket); 
   } 
}


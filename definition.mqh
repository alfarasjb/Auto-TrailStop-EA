
//--- Enums
enum Frequency { Tick, Candle }; 

//--- Inputs 
input int         InpTSPointsThreshold    = 100; // Breakeven Points Threshold 
input Frequency   InpTSFrequency          = Tick; // Breakeven Frequency  
input int         InpTSPointsDistance     = 100; // Trail Stop Points Distance from market price

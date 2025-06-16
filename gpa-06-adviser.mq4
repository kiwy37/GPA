//+------------------------------------------------------------------+
//|                                           gpa-lab-06-adviser.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Exercise requirements:
// If the price exceeds the average of the last N bars (without bar 0), then a buy order is sent to buy X points
// having Stop Loss and Take Profit at the distance of y = x points.
// For each bar we take into account the middle: (High + Low) / 2
//
// If the price goes X points below the average of the last N bars, then a sell order is sent.
//
// Do the check every time a new bar appears, not necessarily every thick.

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


extern int numberOfPoints = 30; // minimum distance between average and price
extern int sltpDistance = 20; // 'stop loss' and 'take profit' distance
extern int lastBarsCount = 5; // number of bars for the calculation of the average


// function that tells us if a new bar has started
bool hasNewBarAppear()
{
   // For this we can use the Time[] array, which stores values in (long integer) seconds
   
   static long lastCallTime = 0; // 0 seconds
   long currentCallTime = Time[1];
   
   if (currentCallTime != lastCallTime)
   {
      // Reset the time of the last function call to be this function call's time
      lastCallTime = currentCallTime;
      return true;
   }
   else
      return false;
}

bool isBuyPriceAboveAverage(int numberOfLastBars, int xPoints)
{
   double average = 0.0;
   
   // compute average
   for (int i = 1; i <= numberOfLastBars; i++)
   {
      average += (High[i] + Low[i]) / 2;
   }
   average /= numberOfLastBars;
   
   if (Ask > average + xPoints * Point)
      return true;

   return false;
}

bool isSellPriceBelowAverage(int numberOfLastBars, int xPoints)
{
   double average = 0.0;
   
   // compute average
   for (int i = 1; i <= numberOfLastBars; i++)
   {
      average += (High[i] + Low[i]) / 2;
   }
   average /= numberOfLastBars;
   
   if (Bid < average - xPoints * Point)
      return true;
      
   return false;
}

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
   const double VOLUME_TO_TRANSACT = 0.01;
   const double NUMBER_OF_LOTS = 0.01;
   const int SLEEPAGE = 0;
  
   // Check if a new bar appeared
   if (hasNewBarAppear())
   {
      // Check if buy price is higher than average
      if (isBuyPriceAboveAverage(lastBarsCount, numberOfPoints))
      {
         // stop loss: we assure that the order does not loose more money than "stopLoss"
         double STOP_LOSS = Ask - sltpDistance * Point;
         
         // We assure that the profit equal to "takeProfit" is not lost
         double TAKE_PROFIT = Ask + sltpDistance * Point;
   
         // And start buyinga new buy
         OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, STOP_LOSS, TAKE_PROFIT);
      }
      // Else, check if the sell price is lower than average
      else if(isSellPriceBelowAverage(lastBarsCount, numberOfPoints))
      {
         // stop loss: we assure that the order does not loose more money than "stopLoss"
         double STOP_LOSS = Bid + sltpDistance * Point;
         
         // We assure that the profit equal to "takeProfit" is not lost
         double TAKE_PROFIT = Bid - sltpDistance * Point;
         
         // and Start selling
         OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, STOP_LOSS, TAKE_PROFIT);
      }
   }
}
//+------------------------------------------------------------------+

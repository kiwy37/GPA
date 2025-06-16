//+------------------------------------------------------------------+
//|                                           gpa-lab-06-adviser.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// This file contains mostly code from last lab (lab 6)

// Exercise requirements:
// If the price exceeds the average of the last N bars (without bar 0), then a buy order is sent to buy X points
// having stoploss and takeprofit at the distance of y = x points.
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

extern double targetProfit = 1.0; // total profit (or loss, if negative) threshold

// This function is from the current lab (lab 8), it's an addition to lab 6.
// This is a helper function that closes all orders.
void closeAllOrders(int slippage)
{
   // For each order
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      // If the order can be selected
      if (OrderSelect(i, SELECT_BY_POS) == false)
      {
         // Update the exchange rates before closing the orders.
         RefreshRates();
   
         // Close the order using the correct price depending on the order's type
         if (OrderType() == OP_BUY)
            OrderClose(OrderTicket(), OrderLots(), Bid, slippage);
         else if (OrderType() == OP_SELL)
            OrderClose(OrderTicket(), OrderLots(), Ask, slippage);
      }
   }
}

// This function is from the current lab (lab 8), it's an addition to lab 6.
// Test if the profit of the whole of all orders that are opened exceeds
// a given value of money S (USD), or the total profit is under -S USD (a loss in this case) all the orders are closed.
// This function should be used every thick.
//
// In translation: if we gain more than 10 USD, we close everything. If we loose more than 10 USD,
// we also close everything. Do this every thick.
// This function test if the profit is high enough or if the loss is big enough and,
// in both cases, it stops all orders.
// This function should be called in the onTick() function.
void testForProfitOrLoss(int slippage)
{
   double totalProfit = 0.0;
   
   // for each sent order
   for (int i = OrdersTotal(); i > 0; i--)
   {
      // Select the order at the 'i' index, where 'i' represents the position in the
      // order pool (SELECT_BY_POS) and not the order ticket
      if (OrderSelect(i, SELECT_BY_POS))
         totalProfit += OrderProfit();
   }
   
   if ( (totalProfit >= targetProfit) // If the total profit from all the orders is high enough
       || (totalProfit <= -targetProfit) ) // or the loss from all the orders is high enough
      // Then close all orders
      closeAllOrders(slippage);
}

void testForLoss(double lossThreshold, int slippage)
{
   double totalLoss = 0.0;
   
   // for each sent order
   for (int i = OrdersTotal(); i > 0; i--)
   {
      // Select the order at the 'i' index, where 'i' represents the position in the
      // order pool (SELECT_BY_POS) and not the order ticket
      if (OrderSelect(i, SELECT_BY_POS))
         totalLoss += OrderProfit();
   }
   
   // If the total profit from all the orders is high enough
   if (lossThreshold > 0 &&
         totalLoss <= (-1.0) * lossThreshold)
      // Then close all orders
      closeAllOrders(slippage);
}

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
   
   testForProfitOrLoss(SLEEPAGE);
}
//+------------------------------------------------------------------+
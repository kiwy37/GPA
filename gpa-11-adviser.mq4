//+------------------------------------------------------------------+
//|                                        gpa-lab-11-adviser-01.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


// Note: the code might not be 100% correct or complete, but it's close.
// Please take a look at the other versions for gpa-10.


/* Exercise requirements:
If the close value for each of the 'n' last bars is greateher than iMA (indicator Mean Average) applied to Close value, then a Buy order is sent
(bar 0 is not counted, we start from bar 1). This happens when a new bar appears. Each bar has a Take Profit
and Stop Loss at a distance 'x' from the opening price. All orders sent by the expert advisor have a specific magic number.

Reverse request: if the close value for each of the 'n' last bars is less than the iMA (indicator Mean Average) applied to Close value, then a Send order is sent.

The expert advisor cannot have more than 'm' orders opened.
External variables: M, N, X, magic number.
*/

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int x = 20; // the distance between 2 consecutive levels
extern int y = 15; // SLTP, Take Profit and Stop Loss distance
extern double z = 5.0; // Maximum profit or loss for stop/delete
extern int n = 5; // number of bars (where we test that Close is greather or less than iMA)
extern int m = 5; // the maximum number of opened orders
extern int magicNumber = 1234; // for uniquely identifying orders

// Helper function which computes how many opened orders there are with a specific 'magic number'
int totalOrders(int magicNumber)
{
    int total = 0; // the number of orders associated to a magic number
    
    for (int i = 0; i < OrdersTotal(); i++)
    {
        // Select current order and check if it has the correct magic number.
        // Only orders with the correct magic number should be counted.
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magicNumber)
            total++;
    }
    
    return total;
}

// Helper function which returns if the Close price is GREATHER than the 'moving average' indicator
// for a given mumber of consectutive times.
bool isClosePriceGreatherThanMovingAverage(int numberOfTimes)
{
   // Compute the 'moving average' indicator
   double movingAverage = iMA(Symbol(), 0, n, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   for (int i = 1; i <= numberOfTimes; i++)
   {
      // If we find at least one bad value, then exit imediately
      if (Close[i] <= movingAverage)
         return false;
   }
   
   // Otherwise, all consective values are for sure greather than the 'moving average indicator'
   return true;
}

// Helper function which returns if the Close price is LOWER than the 'moving average' indicator
// for a given mumber of consectutive times.
bool isClosePriceLowerThanMovingAverage(int numberOfTimes)
{
   // Compute the 'moving average' indicator
   double movingAverage = iMA(Symbol(), 0, n, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   for (int i = 1; i <= numberOfTimes; i++)
   {
      // If we find at least one bad value, then exit imediately
      if (Close[i] > movingAverage)
         return false;
   }
   
   // Otherwise, all consective values are for sure lower than the 'moving average indicator'
   return true;
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


void OnTick()
{
   const double LOT_SIZE = 1.0;
   const int SLIPPAGE = 0;
       
   if (totalOrders(magicNumber) >= m)
      return;
      
   // Check if, for 'n' consecutive bars, the Close price is greather than the 'moving average indicator' for 'n' consecutive bars
   if (isClosePriceGreatherThanMovingAverage(n))
   {
       // 'Ask' is the open price, this is the price at which the order is placed.
       // This is the price at which a new trade is opened.
       // We compute 'Stop Loss' and 'Take Profit' based on the open price.
       double stopLoss = Ask - x * Point; // Stop Loss is a predefined price level at which a trade will be automatically closed to prevent further losses
       double takeProfit = Ask + x * Point; // Take Profit is a predefined price level at which a trade will be automatically closed to secure profits

       OrderSend(Symbol(), OP_BUY, LOT_SIZE, Ask, SLIPPAGE, stopLoss, takeProfit, NULL, magicNumber);
    }
    // Check if, for 'n' consecutive bars, the Close price is lower than the 'moving average indicator' for 'n' consecutive bars
    else if (isClosePriceLowerThanMovingAverage(n))
    {
       // 'Bid' is the open price in this case, this is the price at which the order is placed.
       // This is the price at which a new trade is opened.
       // We compute 'Stop Loss' and 'Take Profit' based on the open price.
       double stopLoss = Bid + x * Point; // Stop Loss is a predefined price level at which a trade will be automatically closed to prevent further losses
       double takeProfit = Bid - x * Point; // Take Profit is a predefined price level at which a trade will be automatically closed to secure profits

       OrderSend(Symbol(), OP_SELL, LOT_SIZE, Bid, SLIPPAGE, stopLoss, takeProfit, NULL, magicNumber);
    }
      
}
//+------------------------------------------------------------------+

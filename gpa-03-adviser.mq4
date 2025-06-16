//+------------------------------------------------------------------+
//|                                                   lab-03-adv.mq4 |
//|                                                   Copyright 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Exercise requirements:
// If the closing prices of the last "n" bars are increasing, then stop buying and start selling (before selling,
// we must close any buy operations, if there are any).
// If the closing prices of the last "n" bars are decreasing, then stop selling and start buying (before buying,
// we must close any sell operations, if there are any).

#property copyright "Copyright 2025"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// the result of the OrderSend() function (the value -1 means no actual order, and a value >= 0 means an actual order number)
int buyOrderTicket = -1;
int sellOrderTicket = -1;

// Helper function that analizes the trend of the last bars's Close price
// and returns that trend:
// 1 means Close prices are increasing
// -1 means Close prices are decreasing
// 0 means no obvious trend
int checkLastClosePricesFluctuations(int lastBarsCount)
{
   bool areLastBarsCloseIncreasing = true;
   bool areLastBarsCloseDecreasing = true;

   // check for consecutive increases
   for (int i = 1; i <= lastBarsCount - 1; i++)
   {
      // if the close prices are not increasing at least once
      if (Close[i] <= Close[i+1])
      {
         // then there are no N consecutive increases
         areLastBarsCloseIncreasing = false;

         // exit loop imediately
         break;
      }
   }

   // if we know for sure the close prices are increasing, then return and exit imediately
   if (areLastBarsCloseIncreasing)
      return 1; // last close prices are increasing

   // check for consecutive decreases
   for (int i = 1; i <= lastBarsCount - 1; i++)
   {
      // if the close prices are not decreasing at least once
      if (Close[i] >= Close[i+1])
      {
         // then there are no N consecutive decreases
         areLastBarsCloseDecreasing = false;

         // exit loop imediately
         break;
      }
   }

   // if we know for sure the close prices are decreasing, then return and exit imediately
   if (areLastBarsCloseIncreasing)
      return -1; // last close prices are decreasing

   return 0; // no obvious trend of increase or decrease
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
// This is the important function of the Expert Adviser.
// This function is called every tick.
void OnTick()
{
   const float VOLUME_TO_TRANSACT = 0.01;
   const int LAST_BARS_COUNT = 10;
   const float NUMBER_OF_LOTS = 0.01;
   const int SLEEPAGE = 0;

   int lastClosePricesState = checkLastClosePricesFluctuations(LAST_BARS_COUNT);

   // if the last close prices are consecutively increasing
   if (lastClosePricesState == 1)
   {
      // then close buy orders, if there are any
      if (buyOrderTicket != -1)
      {
         OrderClose(buyOrderTicket, NUMBER_OF_LOTS, Bid, SLEEPAGE);

         // reset buy order
         buyOrderTicket = -1;
      }

      // and start selling, but only if we do not have a sell operation already
      if (sellOrderTicket == -1)
         sellOrderTicket = OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, 0, 0);
   }
   // if the last close prices are consecutively decreasing
   else if (lastClosePricesState == -1)
   {
      // close existing sell order, if any
      if (buyOrderTicket != -1)
      {
         OrderClose(sellOrderTicket, NUMBER_OF_LOTS, Ask, SLEEPAGE);

         // reset sell order
         sellOrderTicket = -1;
      }

      // and start buying, but only if we do not have a buy operation already
      if (buyOrderTicket == -1)
         buyOrderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, 0, 0);
   }
}

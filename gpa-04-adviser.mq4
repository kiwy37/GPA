//+------------------------------------------------------------------+
//|                                        gap-lab-04-adviser-02.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// Exercise requirements:
// Make an adviser that, when a new bar appears:
// - if the last N bars have a Close price smaller than the Open price,
// the adviser should send a Buy order (if the Buy order doesn't already exist)
// and we should close any Sell order (if there is a Sell order)
//
// - if the last N bars have a Close price greater than the Open price,
// the adviser should send a Sell order (if the Sell order doesn't already
// exist) and we should close any Buy order (if there is a Buy order).



// the result of the OrderSend() function (the value -1 means no actual order, and a value >= 0 means an actual order number)
// these global variables tell us if there is an active Buy or Sell order
int buyOrderTicket = -1;
int sellOrderTicket = -1;

// function that tells us if a new bar has started
bool didNewBarAppear()
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

// function that tells if all the last consecutive 'numberOfLastBars' bars (ticks)
// have a Close price larger than the Open price
bool isCloseLargerThanOpen(int numberOfLastBars)
{
   // check for consecutive increases
   for (int i = 1; i <= numberOfLastBars - 1; i++)
   {
      // if at least once, we brake the rule that the Close price
      // should be greater than the Open price, then the rule is not
      // obeyed consecutively, so the overall result is false
      if (Close[i] < Open[i]) // if the rule is broken at least once
      {
         // then there are no N consecutive increases
         return false; // return and exit imediately
      }
   }
   
   // else, the rule has been obeyed 'numberOfLastBars' consecutive times,
   // so the result is 'true'
   return true;
}

// function that tells if all the last consecutive 'numberOfLastBars' bars (ticks)
// have a Close price smaller than the Open price
bool isCloseSmallerThanOpen(int numberOfLastBars)
{
   // check for consecutive increases
   for (int i = 1; i <= numberOfLastBars - 1; i++)
   {
      // if at least once, we brake the rule that the Close price
      // should be smaller than the Open price, then the rule is not
      // obeyed consecutively, so the overall result is false
      if (Close[i] > Open[i]) // if the rule is broken at least once
      {
         // then there are no N consecutive increases
         return false;
      }
   }
   
   // else, the rule has been obeyed 'numberOfLastBars' consecutive times,
   // so the result is 'true'
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
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
// The main function of this adviser, is called every bar (every tick)
void OnTick()
{
   const int LAST_BARS_COUNT = 5;
   const double VOLUME_TO_TRANSACT = 0.01;
   const double NUMBER_OF_LOTS = 0.01;
   const int SLEEPAGE = 0;
   
   // if a new bar has appeared
   if (didNewBarAppear())
   {
      // check if, for the last N bars (ticks), the Open prices are
      // greather than the Close prices
      if (isCloseSmallerThanOpen(LAST_BARS_COUNT))
      {
         // first close existing sell order, if any
         if (sellOrderTicket != -1)
         {
            if (OrderClose(sellOrderTicket, NUMBER_OF_LOTS, Ask, SLEEPAGE))
               // reset sell order
               sellOrderTicket = -1;
         }
   
         // and start buying, but only if we do not have a buy operation already
         if (buyOrderTicket == -1)
            buyOrderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, 0, 0);
      }
      // if not,check if for the last N bars (ticks), the Open prices are
      // smaller than the Close prices
      else if (isCloseLargerThanOpen(LAST_BARS_COUNT))
      {
         // first close buy orders, if there are any
         if (buyOrderTicket != -1)
         {
            if (OrderClose(buyOrderTicket, NUMBER_OF_LOTS, Bid, SLEEPAGE))
               // reset buy order
               buyOrderTicket = -1;
         }
   
         // and start selling, but only if we do not have a sell operation already
         if (sellOrderTicket == -1)
            sellOrderTicket = OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, 0, 0);
      }
   }
}
//+------------------------------------------------------------------+

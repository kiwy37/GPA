//+------------------------------------------------------------------+
//|                                      gpa-lab-11-adviser-prof.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Note: This is the same version, but the code is written by the professor.

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

extern int n = 5; // numberr of bars
extern int m = 4; // max. number of orders
extern int x = 25; // distance to Take Profit or Stop Loss
extern int magicNumber = 1234;

// Function that tells if a new bar has appeared.
bool newBar()
{
   static datetime t0 = 0;
   
   if (t0 != Time[0])
   {
      bool ret = true;
      
      if (t0 == 0)
         ret = false;
         
      t0 = Time[0];
      
      return ret;
   }
   
   return false;
}

int ordersCount()
{
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS))
         if (OrderMagicNumber() == magicNumber)
            count++;
   }
   
   return count;
}

bool testForBuy()
{
   for (int i = 1; i <= n; i++)
   {
      if (Close[i] >= iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, i))
         return false;
   }
   
   return true;
}

bool testForSell()
{
   for (int i = 1; i <= n; i++)
   {
      // Here we have '<=' instead of '>='
      if (Close[i] <= iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, i))
         return false;
   }
   
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
void OnTick()
{
   if (!newBar())
      return;
      
   if (ordersCount() >= m)
      return;
      
   if (testForBuy())
      OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, Ask + x * Point, Ask - x * Point, NULL, magicNumber); // these prices are correct
      
   if (testForSell())
      OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, Bid - x * Point, Bid + x * Point, NULL, magicNumber); // these prices are correct
}
//+------------------------------------------------------------------+

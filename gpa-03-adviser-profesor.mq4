//+------------------------------------------------------------------+
//|                                      lab-03-adviser-profesor.mq4 |
//|                                                   Copyright 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Note: This is the same version, but the code is written by the professor.


// Exercise requirements:
// If the closing prices of the last "n" bars are increasing, then stop buying and start selling (before selling,
// we must close any buy operations, if there are any).
// If the closing prices of the last "n" bars are decreasing, then stop selling and start buying (before buying,
// we must close any sell operations, if there are any).

#property copyright "Copyright 2025"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int sellTicketNo = -1;
int buyTicketNo = -1;
int noOfBars = 3;
double lots = 0.01;

bool closeIncreasing()
{
   for (int i = 1; i < noOfBars; i++)
   {
      if (Close[i+1] > Close[i]
         return false;
   }

   return true;
}

bool closeDecreasing()
{
   for (int i = 1; i < noOfBars; i++)
   {
      if (Close[i+1] < Close[i]
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
      if (closeIncreasing())
      {
         if (buyTicketNo != -1)
            OrderClose(buyTicketNo, lots, Bid, 0);

         if (sellTicketNo == -1)
            OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0);
      }
      else if (closeDecreasing())
      {
         if (sellTicketNo != -1)
            OrderClose(sellTicketNo, lots, Ask, 0);

         if (sellTicketNo == -1)
            OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0);
      }

  }
//+------------------------------------------------------------------+


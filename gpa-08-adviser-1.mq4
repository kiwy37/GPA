//+------------------------------------------------------------------+
//|                                         gpa-lab-08-adviser-1.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// Note: This Expertt Adviser has no actual code, just the Exercise requirements.


// Exercise requirements:
// Usually, an expert adviser is written with OrdersTotal() and OrdersSelect()

// Add a test In the onTick() function, to test if the profit of the whole of all orders that are opened exceeds
// a given value of money (S USD), or the total profit is under -S USD (a loss in this case) all the orders are closed.
// Do this test every thick.
//
// In translation: if we gain more than 10 USD, we close everything. If we loose more than 10 USD,
// we also close everything. Do this every thick.

extern int x = 40;
extern int dist = 20;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   for (int i = OrdersTotal(); i > 0; i--)
   {
      // We can also use SELECT_BY_TICKET
      if (OrderSelect(i, SELECT_BY_POS)
      {
         Alert("Ticket no.: ", OrderTicket(),
               ", lots:", OrderLots(),
               ", open price: ", OrderOpenPrice(),
               ", profit:", OrderProfit(), ", symbol: ", OrderSymbol(),
               ", Stop loss: ", OrderStopLoss(),
               ", Take profit: ", OrderTakeProfit(),
               ", order type: ", OrderType());
      }
   }
   
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
   
}
//+------------------------------------------------------------------+

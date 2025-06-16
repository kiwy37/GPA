//+------------------------------------------------------------------+
//|                                   gpa-lab-09-adviser-01-prof.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+


// Note: This is the same version, but the code is written by the professor.


/* Exercise requirements:
** On initialization, if there is no order open, we send a new order with the volume 0.01 and
** the type (buy or sell) randomply chosen.
** At every thick, we test if there is any order opened. If there is none, we send an order
** randomly (buy or sell) with amount of volume 0.01 (the minimum we can use).
** If there is an order opened we do nothing, else we look at the last order that
** was closed.

** If this order was closed in profit, we open a new order with the volume 0.01
** and the type (buy or sell) is randomly chosen.
** If the last order that was closed has a negative profit, we open a new order
** with double the volume of this closed order and the type of the new order is the opposite
** type of the last order.

** Every order when it's sent has to have a 'Stop Loss" and 'Take Profit' at a distance 'x' which
** is configurable.

** MAGIC NUMBER.
** Every order sent from expert adviser can have a "magic number". If an order does not
** have a magic number, this means that the magic number is zero.
** The expert adviser will have a magic number attachet to every order. We have to check
** if the magic number is ours. */

#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

extern int magicNumber = 0;
extern int sltpDistance = 20;
extern double minVol = 0.01;

bool openOrderExist()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         if (OrderMagicNumber() == magicNumber)
            return true; // Do nothing, let the program continue running
      }
   }
   
   return false;
}

void selectLastClosedOrder()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      // Important! MODE_HISTORY gives only closed orders, so we can be sure these orders are closed
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if (OrderMagicNumber() == magicNumber)
            // Stop the loop to remain at the first selected Order whitch mathces the magic number.
            // This order will remain selected, because we break the for loop and nothing can be selected anymore.
            return;
      }
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (openOrderExist())
      return INIT_SUCCEEDED; // Do nothing, let the program continue running
   else
   {
      if (MathRand() % 2 == 0)
         OrderSend(Symbol(), OP_BUY, minVol, Ask, 0, Ask - sltpDistance * Point, Ask + sltpDistance * Point, NULL, magicNumber);
      else
         // Should be Bid (instead of Ask) for sell operation?
         OrderSend(Symbol(), OP_SELL, minVol, Ask, 0, Ask + sltpDistance * Point, Ask - sltpDistance * Point, NULL, magicNumber);
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
   if (openOrderExist())
      return;
      
   selectLastClosedOrder();
   
   static double vol = minVol;
   
   int orderType;
   
   if (OrderProfit() < 0)
   {
      vol = OrderLots() * 2;
      
      if (OrderType() == OP_BUY)
         orderType = OP_SELL;
      else if (OrderType() == OP_SELL)
         orderType = OP_BUY;
   }
   else
   {
      if (MathRand() % 2 == 0)
         orderType = OP_BUY;
      else
         orderType = OP_SELL;
   }
   
   if (orderType == OP_BUY)
      OrderSend(Symbol(), OP_BUY, minVol, Ask, 0, Ask - sltpDistance * Point, Ask + sltpDistance * Point, NULL, magicNumber);
   // else
   // ...
}
//+------------------------------------------------------------------+

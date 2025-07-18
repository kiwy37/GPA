#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/* Code from Cezar.
** Exercise requirement text from Saul.
Martingale Expert Advisor: Upon initialization check if any orders are currently open;
if none are found, it places a new order with a volume of 0.01, choosing randomly between a Buy or Sell position.

On every market tick, the EA checks again for any open orders—if an order is active, it takes no further action.
However, if there are no open orders, it examines the most recently closed trade.

If that trade closed with a profit, the EA opens a new order with a fixed volume of 0.01, again randomly selecting the order type.
If the last trade closed with a loss, the EA opens a new order with double the volume of the previous trade and reverses the order type
(i.e., opens a Buy if the last was a Sell, and vice versa), thereby implementing a classic Martingale strategy with randomized entry
after profit and volume-doubling recovery after loss.
*/

extern double MinVol = 0.01;
extern int MagicNumber = 1234;
extern int SLTPDist = 20;

bool OpenOrderExist()
{
   for (int i=OrdersTotal()-1;i>=0;i--)
      if (OrderSelect(i,SELECT_BY_POS))
         if (OrderMagicNumber()==MagicNumber)
            return true;
   return false;
}

int OnInit()
  {
   if (OpenOrderExist())
      return INIT_SUCCEEDED;
   
   if (MathRand()%2==0)
      OrderSend(Symbol(), OP_BUY, MinVol, Ask, 0, Ask-SLTPDist*Point, Ask+SLTPDist*Point, NULL, MagicNumber);
   else
      OrderSend(Symbol(), OP_SELL, MinVol, Bid, 0, Ask+SLTPDist*Point, Ask-SLTPDist*Point, NULL, MagicNumber);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
  }

void SelectLastClosedOrder()
{
   for (int i=OrdersHistoryTotal()-1;i>=0;i--)
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if (OrderMagicNumber()==MagicNumber)
            return;
}

void OnTick()
  {
   if (OpenOrderExist())
      return;
   
   SelectLastClosedOrder();
   
   double vol=MinVol;
   int ordertype;
   if (OrderProfit()<0)
   {
      vol=OrderLots()*2;
      if (OrderType()==OP_BUY)
         ordertype=OP_SELL;
      else
         ordertype=OP_BUY;
   }
   else
      if (MathRand()%2==0)
         ordertype=OP_BUY;
      else
         ordertype=OP_SELL;
   
   if (ordertype==OP_BUY)
      OrderSend(Symbol(), OP_BUY, vol, Ask, 0, Ask-SLTPDist*Point, Ask+SLTPDist*Point, NULL, MagicNumber);
   else
      OrderSend(Symbol(), OP_SELL, vol, Bid, 0, Ask+SLTPDist*Point, Ask-SLTPDist*Point, NULL, MagicNumber);
  }
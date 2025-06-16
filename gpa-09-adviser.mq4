//+------------------------------------------------------------------+
//|                                        gpa-lab-09-adviser-01.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

// Note: This code might not be 100% correct (I don't remember for sure).
// Please also check the proffesor and Cezar's versions of gpa-09 code.

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

// Variable that can be configured from the outside, by an user of this expert adviser.
// The magic number is like an unique ID of the user
extern int magicNumber = 0;

const int DISTANCE = 20;
const double VOLUME = 0.01;

// the result of the OrderSend() function (the value -1 means no actual order, and a value >= 0 means an actual order number)
// these global variables tell us if there is an active Buy or Sell order
int buyOrderTicket = -1;
int sellOrderTicket = -1;

// The 'buy' or 'sell' prices of the last buy or sell order
double lastBuyOrderAskPrice = 0.0;
double lastSellOrderBidPrice = 0.0;

bool isAnyOrderOpened()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == magicNumber)
            {
               if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                   return true; // There is an open order
            }
        }
    }
    return false; // No open orders found
}

/*
bool wasLastOrderProfitable()
{
    double lastProfit = 0;
    
    if (OrdersHistoryTotal() > 0)
    {
        // Select the last order
      OrderSelect(OrdersHistoryTotal() - 1, SELECT_BY_POS, MODE_HISTORY);
      
      // Get the last order's profit
      lastProfit = OrderProfit();
    }
    
    return lastProfit > 0;
}
*/


bool wasLastOrderProfitable()
{
    double lastProfit = 0;
    datetime lastCloseTime = 0;

    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if (OrderMagicNumber() == magicNumber)
            {
               datetime closeTime = OrderCloseTime();
               if (closeTime > lastCloseTime)
               {
                   lastCloseTime = closeTime;
                   lastProfit = OrderProfit();
               }
            }
        }
    }

    return lastProfit > 0;
}


/* Returns the type of the last closed order: OP_BUY, OP_SELL or -1*/
int getLastClosedOrderType()
{
   int lastOrderType = -1; // Initialize with an invalid order type
   
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            // Get the type of the last closed order that matches the magic number
            if (OrderMagicNumber() == magicNumber)
                lastOrderType = OrderType(); 
        }
    }
    
    return lastOrderType;
}

// sends a Buy order
void buySend(int distance, double volume)
{
   // stop loss: we assure that the order does not loose more money than "stopLoss"
   const double STOP_LOSS = Ask - distance * Point;
   
   // We assure that the profit equal to "takeProfit" is not lost
   const double TAKE_PROFIT = Ask + distance * Point;

   // Then launch a buy order
   buyOrderTicket = OrderSend(Symbol(), OP_BUY, volume, Ask, 0, STOP_LOSS, TAKE_PROFIT);
   
   // And store the last buy price
   lastBuyOrderAskPrice = Ask;
}

// sends a Sell order
void sellSend(int distance, double volume)
{
   // stop loss: we assure that the order does not loose more money than "stopLoss"
   const double STOP_LOSS = Bid - distance * Point;
   
   // We assure that the profit equal to "takeProfit" is not lost
   const double TAKE_PROFIT = Bid + distance * Point;

   // Then launch a sell order
   sellOrderTicket = OrderSend(Symbol(), OP_SELL, volume, Bid, 0, STOP_LOSS, TAKE_PROFIT);
   
   // And store the last sell price
   lastSellOrderBidPrice = Bid;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (isAnyOrderOpened())
   {
      const int DISTANCE = 10;
      const double VOLUME = 0.01;
      
      // Determine type of order: Buy or Sell
      if (MathRand() % 2 == 0) // if the random number is even
         buySend(DISTANCE, VOLUME);
      else // if the random number is odd
         sellSend(DISTANCE, VOLUME);
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
   static double lastVolume = 0.01;
   
   // If there are no opened orders
   if (!isAnyOrderOpened())
   {
      // Randonmly choose an order: Buy or Sell
      if (MathRand() % 2 == 0) // if the random number is even
         buySend(DISTANCE, VOLUME);
      else // if the random number is odd
         sellSend(DISTANCE, VOLUME);
   }
   
   // Check if last order was profitable
   if (wasLastOrderProfitable())
   {
      // Randonmly choose an order: Buy or Sell
      if (MathRand() % 2 == 0) // if the random number is even
         buySend(DISTANCE, VOLUME);
      else // if the random number is odd
         sellSend(DISTANCE, VOLUME);
   }
   else // If the last order was not profitable
   {
      // Double the volume
      lastVolume *= 2;

      int lastOrderType = getLastClosedOrderType();
      
      // If the last order was a buy
      if (lastOrderType == OP_BUY)
         // Then send a sell order (the opposite)
         sellSend(DISTANCE, lastVolume);
      else if (lastOrderType == OP_SELL)// If the last order was a sell
         // Then send a buy order (the opposite)
         buySend(DISTANCE, lastVolume);
   }
}
//+------------------------------------------------------------------+

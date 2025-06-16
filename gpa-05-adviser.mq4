//+------------------------------------------------------------------+
//|                                        gpa-lab-05-adviser-02.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// When the expert adviser starts, randomly start a buy order or a sell order.
//
// If the current price goes  more than X points above the previously opened order,
// a new buy order is sent having stopLoss and 'takeProfit' at a distance 'dist'.
// If the price goes down more than X points compared to the previously sent order,
// a new sell order is sent, having 'stopLoss' and 'takeProfit' at a distance 'dist'.

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// the result of the OrderSend() function (the value -1 means no actual order, and a value >= 0 means an actual order number)
// these global variables tell us if there is an active Buy or Sell order
int buyOrderTicket = -1;
int sellOrderTicket = -1;

// The 'buy' or 'sell' prices of the last buy or sell order
double lastBuyOrderAskPrice = 0.0;
double lastSellOrderBidPrice = 0.0;

const int LAST_BARS_COUNT = 5;
const double VOLUME_TO_TRANSACT = 0.01;
const double NUMBER_OF_LOTS = 0.01;
const int SLEEPAGE = 0;
   
const int NUMBER_OF_POINTS = 20;
const int DISTANCE = 20;

// Helper function that checks if the current tick price goes up more than x
// points above the previously opened order
bool isBuyAskPriceLarger(double lastAskPrice, int xPoints)
{
   if (Ask > lastAskPrice + xPoints * Point)
      return true;
   else
      return false;
}

// Helper function that checks if the current tick price goes down more than x
// points below the previously opened order
bool isSellBidPriceSmaller(double lastBidPrice, int xPoints)
{
   if (Bid < lastBidPrice - xPoints * Point)
      return true;
   else
      return false;
}

void buySend()
{
   // stop loss: we assure that the order does not loose more money than "stopLoss"
   const double STOP_LOSS = Ask - DISTANCE * Point;
   
   // We assure that the profit equal to "takeProfit" is not lost
   const double TAKE_PROFIT = Ask + DISTANCE * Point;

   // Then launch a buy order
   buyOrderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, STOP_LOSS, TAKE_PROFIT);
   
   // And store the last buy price
   lastBuyOrderAskPrice = Ask;
}

void sellSend()
{
   // stop loss: we assure that the order does not loose more money than "stopLoss"
   const double STOP_LOSS = Bid - DISTANCE * Point;
   
   // We assure that the profit equal to "takeProfit" is not lost
   const double TAKE_PROFIT = Bid + DISTANCE * Point;

   // Then launch a sell order
   sellOrderTicket = OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, STOP_LOSS, TAKE_PROFIT);
   
   // And store the last sell price
   lastSellOrderBidPrice = Bid;
}

//| Expert initialization function                                   |
int OnInit()
{
   // if the random number is even
   if (MathRand() % 2 == 0)
      buySend();
   else // if the random number is odd
      sellSend();

   return(INIT_SUCCEEDED);
}

//| Expert deinitialization function                                 |
void OnDeinit(const int reason)
{
   
}

//| Expert tick function                                             |
void OnTick()
{
   // Check if the current Ask price is larger than the last buy order's Ask price
   // by NUMBER_OF_POINTS
   if (isSellBidPriceSmaller(lastSellOrderBidPrice, NUMBER_OF_POINTS))
      // If it's larger, then start a new Buy order 
      buySend();
   else if(isBuyAskPriceLarger(lastBuyOrderAskPrice, NUMBER_OF_POINTS))
      // If it's smaller, then start a new sell order
      sellSend();
}

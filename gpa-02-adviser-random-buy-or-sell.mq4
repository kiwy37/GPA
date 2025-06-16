//+------------------------------------------------------------------+
//|                                                   adviser-03.mq4 |
//|                                                   Copyright 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Exercise requirements:
// When the Adiveser starts, it should randomly send a SELL or a BUY order.
//     If the difference in absolute value between the opening price of the order and
// the current price exceeds the value 0.001, then the open order is closed and
// a new order is sent having the opposite type (if it was BUY, then it will be
// SELL, if it was SELL then it will be BUY).

//+------------------------------------------------------------------+
//|                                                       adv-buy.mq4 |
//| Expert Advisor that buys a stock/symbol
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, aciucaru"
#property link      ""
#property version   "1.00"
#property strict


const double TRESHOLD = 0.001;

// the initial type of the random operation (BUY or SELL)
int operationStartType = OP_BUY;

// the initial price, depending on the type of the operation type
// if the starting operation type is BUY, the price is Ask
// if the starting operation type is SELL, the price is Bid
double operationStartPrice = Ask;

// the result of the OrderSend() function
int orderTicket = -1;

const float VOLUME_TO_TRANSACT = 0.01;

// Expert initialization function
int OnInit()
{
   // create timer
   EventSetTimer(60);

   // OrderSend(): send an order that will be transactioned
   // Symbol(): returns the stock symbol to which this expert advisor is applied to (example: EURUSD)
   // operationStartType: value that tells the OrderSend function what type of operation this is (BUY or SELL),
   //                      depending on random operation
   // VOLUME_TO_TRANSACT: how many stocks/units to buy or sell
   // operationStartPrice: the buy or sell price, depending on the random operation

   // generate a int random number
   const int RANDOM = MathRand();

   // if the integer random number is odd, then the starting operation is a BUY
   if (RANDOM % 2 != 0)
   {
      operationStartType = OP_BUY;
      operationStartPrice = Ask;

      orderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, 0, 0);
   }
   else
   {
      // otherwise the starting operation is a SELL
      operationStartType = OP_SELL;
      operationStartPrice = Bid;

      orderTicket = OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, 0, 0);
   }


   // if there was an error (orderNumber is negative)
   if (orderTicket < 0)
      Alert("Order not sent"); // write an error message
   else
      Alert("Order number: ", orderTicket); // else, write the orderNumber

   return(INIT_SUCCEEDED);
}

// Expert deinitialization function                                 |
void OnDeinit(const int reason)
{
   const float NUMBER_OF_LOTS = 0.01;
   const int SLEEPAGE = 0;
   // Bid: the selling price
   // NUMBER_OF_LOTS: the stock/symbol (unit) vakue (such as 1 USD) which is then multiplied by the leverage
   //                   for example 0.01 for USD means 1 USD cent

   if (operationStartType == OP_BUY)
      OrderClose(orderTicket, NUMBER_OF_LOTS, Bid, SLEEPAGE);
   else if (operationStartType == OP_SELL)
      OrderClose(orderTicket, NUMBER_OF_LOTS, Ask, SLEEPAGE);

   // destroy timer
   EventKillTimer();
}


// Expert tick function
// This is the main function that is called for every plot bar
void OnTick()
{
   const float NUMBER_OF_LOTS = 0.01;
   const int SLEEPAGE = 0;

   if (operationStartType == OP_BUY)
   {
      if (MathAbs(operationStartPrice - Ask) > TRESHOLD)
      {
         OrderClose(orderTicket, NUMBER_OF_LOTS, Bid, SLEEPAGE);

         // initiate an operation of the opposite type
         orderTicket = OrderSend(Symbol(), OP_SELL, VOLUME_TO_TRANSACT, Bid, 0, 0, 0);

         operationStartType = OP_SELL;
      }
      else if (operationStartType == OP_SELL)
      {
         OrderClose(orderTicket, NUMBER_OF_LOTS, Ask, SLEEPAGE);

         // initiate an operation of the opposite type
         orderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_TRANSACT, Ask, 0, 0, 0);

         operationStartType = OP_BUY;
      }
   }
}


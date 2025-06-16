//+------------------------------------------------------------------+
//|                                                       adv-01.mq4 |
//| Expert Advisor that buys a stock/symbol
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, aciucaru"
#property link      ""
#property version   "1.00"
#property strict

/* This Expert Adviser the last 10 bars (only once, in the OnInit() function) and then sends a Buy order (only once).
** It also displays via Alert() the current Ask and Bid price (every tick). */

int orderTicket = -1;

// Expert initialization function                                   |
int OnInit()
{
   // create timer
   EventSetTimer(60);

   const int LAST_BARS = 10;

   // display the previous last 10 bars (stock fluctuations)
   for (int i = 1; i <= LAST_BARS; i++)
   {
      Alert("Bar ", i, ": ", "Open: ", Open[i], ", Close: ", Close[i], ", High: ", High[i], ", Low: ", Low[i]);
   }

   const float VOLUME_TO_BUY = 0.01;
   // OrderSend(): send an order that will be transactioned
   // Symbol(): returns the stock symbol to which this expert advisor is applied to (example: EURUSD)
   // OP_BUY: value that tells the OrderSend function that this is a buy operation
   // VOLUME_TO_BUY: how many stocks/units to buy
   // Ask: the buying price (built-in global variable, does not need to be declared)
   orderTicket = OrderSend(Symbol(), OP_BUY, VOLUME_TO_BUY, Ask, 0, 0, 0);

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
   OrderClose(orderTicket, NUMBER_OF_LOTS, Bid, SLEEPAGE);

   // destroy timer
   EventKillTimer();
}


// Expert tick function                                             |
void OnTick()
{
   Alert("Ask: ", Ask, "Bid: ", Bid);
}


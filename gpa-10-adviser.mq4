//+------------------------------------------------------------------+
//|                                        gpa-lab-10-adviser-01.mq4 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


// Note: the code might be incorect due to poor understanding of the Exercise requirements.
// Please take a look at Diana's version too.



/* OP_BUY_STOCK, price is (Ask + 25* Point) */

// Exercise requirements:
/* In order to get rid of an open order, we call OrderClose().
** For getting rid of a pending order we use OrderDelete(), because a pending order
** is not opened yet, so it cannot be closed, but it can be deleted. */


/*  Write an expert adviser that, in onInit() builds a "generator" ("plantator").
(in thick) If the total profit of all opened orders exceeds a value of Z dollars, then we close all opened orders
and we delete all pending orders. This only refers to our orders, which have a magic number. We close or delete
only our orders that have this magic numbers, the rest we ignore.

Y - the distance to Take Profit and Stop Loss

Z - the number of many

Magic number

External variables:
N - one sets how many "buy stops" and "buy limits" we send (this is bassically the number of levels)
Current price is between "Buy Stop" and "Buy limit"
X - is the distance between 2 consecutive levels
Y - the distance between opening price and stop loss and take profit is Y points.
Z - the number of money
Magic number
*/


/* Exercise requirements (Saul version):
Write an Expert Advisor (EA) that runs on every tick. The EA should do the following:
- Monitor all open and pending orders that belong to the EA (identified by a specific MagicNumber).
- Calculate the total profit or loss (in USD) from these open orders.
- If the total profit is greater than or equal to Z dollars OR the total loss is less than or equal to -Z dollars, then:
   - Close all open orders with that MagicNumber.
   - Delete all pending orders with that MagicNumber.
   - Any other orders (not using the same MagicNumber) must be ignored.
 */
 
extern int x = 20; // the distance between 2 consecutive levels
extern int y = 15; // SLTP
extern int z = 5.0; // Maximum profit or loss for stop/delete
extern int n = 5;
extern int magicNumber = 1234;

bool isOpenOrder(int orderType)
{
    return (orderType == OP_BUY ||
            orderType == OP_SELL);
}


bool isPendingOrder(int orderType)
{
    return (orderType == ORDER_TYPE_BUY_LIMIT ||
            orderType == ORDER_TYPE_SELL_LIMIT ||
            orderType == ORDER_TYPE_BUY_STOP ||
            orderType == ORDER_TYPE_SELL_STOP);
}

int OnInit()
{

   return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
   
}


void OnTick()
{
   double totalProfit = 0;  // Total profit from open orders
   
   // Loop through all orders
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         if (OrderMagicNumber() == magicNumber)
         {
               // Check if the order is open order
              if ( isOpenOrder(OrderType()) )
                 totalProfit += OrderProfit();
         }
      }
   }
   
   double const SLIPPAGE = 3.0;
   // Check if the total profit or total loss meets the threshold condition
    if (totalProfit >= z || totalProfit <= -z)
    {
      // Loop all orders and close/delete orders with the same magic number
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS))
         {
            if (OrderMagicNumber() == magicNumber)
            {
               // Close open orders, these are BUY or SELL orders
               // Close the order if it's BUY
               if (OrderType() == OP_BUY)
                  OrderClose(OrderTicket(), OrderLots(), Bid, SLIPPAGE);
               // Close the order if it's SELL
               else if (OrderType() == OP_SELL)
                  OrderClose(OrderTicket(), OrderLots(), Ask, SLIPPAGE);
                  
               // Delete pending orders
               if ( isPendingOrder(OrderType()) )
                  OrderDelete(OrderTicket());
            }
         }
      }
    }
}

// same as: double v = Close[1];
double v = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 1);


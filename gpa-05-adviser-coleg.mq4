#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int dist=20;
int x=40;
double openPrice;

int OnInit()
  {   
  //Alert(Point);
  
   MathSrand(GetTickCount());
   if(MathRand() % 2 == 0){
      //Alert("SELL | ", "Open:", Open[1], ", Close:", Close[1], ", High:", High[1], ", Low:", Low[1]);
      OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, Bid+dist*Point, Bid-dist*Point);
      openPrice = Bid;
   }
   else{
      //Alert("BUY | ", "Open:", Open[1], ", Close:", Close[1], ", High:", High[1], ", Low:", Low[1]);
      OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, Ask-dist*Point, Ask+dist*Point);
      openPrice = Ask;
   }
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   
  }

void OnTick()
  {
   if(Ask > openPrice+x*Point){
      //Alert("BUY | ", "Open:", Open[1], ", Close:", Close[1], ", High:", High[1], ", Low:", Low[1]);
      OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, Ask-dist*Point, Ask+dist*Point);
      openPrice = Ask;
   }
   
   if(Bid < openPrice-x*Point){
      //Alert("SELL | ", "Open:", Open[1], ", Close:", Close[1], ", High:", High[1], ", Low:", Low[1]);
      OrderSend(Symbol(), OP_SELL, 0.01, Bid, 0, Bid+dist*Point, Bid-dist*Point);
      openPrice = Bid;
   }
   
  }


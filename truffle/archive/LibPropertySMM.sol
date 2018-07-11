pragma solidity ^0.4.0;

library LibPropertySMM {

  // state machine model for the contract behavior
  enum PropertyState {
    New,              // property is new, users can submit claim offers
    Bidding,          // subscribing to ownership
    //ClosingPurchase,  // bidding is closed, negotiating purchase & assign Ownership
    Purchased,        // property is purchased, elelct the initial manager

    Leased,           // property is leased
    OnMarket,         // property is available for short term rentals
    OffMarekt,        // property is off market, i.e. service, maintenance, etc.

    ForSale,          // property is offered for sale
    //ClosingSale,      // sale agreed
    Sold,             // property is sold, money is in escrow
    Settled           // escrow is distributed to owners
  }


}// LibPropertySM

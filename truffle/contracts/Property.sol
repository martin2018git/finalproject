pragma solidity ^0.4.21;

library Property {

  // state machine model for the contract behavior
  enum State {
    Initialize,       // property record has to be initialized first
    New,              // property is new, users can submit claim offers
    Bidding,          // subscribing to ownership
    PurchaseClosing,  // bidding is closed, negotiating purchase & assign Ownership
    Purchased,        // property is purchased, elelct the initial manager

    Available,         // property is available for short term rentals
    Leased,           // property is leased
    OffMarket,        // property is off market, i.e. service, maintenance, etc.

    ForSale,          // property is offered for sale
    SaleClosing,      // sale agreed
    Sold,             // property is sold, money is in escrow
    Disposed          // escrow is distributed to owners
  }

  // details of the property
  struct PropertyRecord {
    string id;  // unique identifier of the property
    string name; // given name of the property
    string propertyAddress; // where is it located
    string titleAgent; // who holds the property title
    string titleContact; // email for the title holder

    /* contract financials: */
    uint propertyPrice; // value of the purchased property
    uint closingCosts; // amount set aside for closing
    uint reserveAmount; // amount of reserve left for managing property
    uint monthlyFee;    // monthly fee that goes to the property managerContact
    uint monthlyLease;  // monthly lease

    /* contract ownrship management  */
    uint unitPrice; // unit price for the smalled unit that can be purchased 0.1%
    uint totalPoints; // amount of ownership points in circulation
  }


  function initialize(
    PropertyRecord storage self,
    string _id,
    string _name,
    string _propertyAddress,
    string _titleAgent,
    string _titleContact
  ) internal
    returns( bool )
  {
    /* initi property record */
    self.id = _id;
    self.name = _name;
    self.propertyAddress = _propertyAddress;
    self.titleAgent = _titleAgent;
    self.titleContact = _titleContact;
    return( true );
  }

  function formatPropertyInfo(
    PropertyRecord storage self
  ) internal view
    returns( string, string, string, string, string )
  {
      return( self.id, self.name, self.propertyAddress, self.titleAgent, self.titleContact );
  }

  function getState( Property.State s )
    internal pure
    returns(string _state)
  {
    if( s == State.Initialize ) _state="Initialize";
    if( s == State.New ) _state="New";
    if( s == State.Bidding ) _state="Bidding";
    if( s == State.PurchaseClosing ) _state="PurchaseClosing";
    if( s == State.Purchased ) _state="Purchased";
    if( s == State.Available ) _state="Available";
    if( s == State.Leased ) _state="Leased";
    if( s == State.OffMarket ) _state="OffMarket";
    if( s == State.ForSale ) _state="ForSale";
    if( s == State.SaleClosing ) _state="SaleClosing";
    if( s == State.Sold ) _state="Sold";
    if( s == State.Disposed ) _state="Disposed";
  }

}//PropertyRecordInterface

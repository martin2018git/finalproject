pragma solidity ^0.4.21;

library PropertyLibrary {

  // state machine model for the contract behavior
  enum PropertyState {
    Initialize,       // property record has to be initialized first
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

  // details of the property
  struct PropertyDetail {
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
    PropertyDetail _property,
    string _id,
    string _name,
    string _propertyAddress,
    string _titleAgent,
    string _titleContact
  ) pure internal
    returns( bool )
  {
    /* initi property record */
    _property.id = _id;
    _property.name = _name;
    _property.propertyAddress = _propertyAddress;
    _property.titleAgent = _titleAgent;
    _property.titleContact = _titleContact;
    return( true );
  }

  function getPropertyInfo(
    PropertyDetail _property
  ) pure internal
    returns( string )
  {
      return( _property.name );
  }


}//PropertyRecordInterface

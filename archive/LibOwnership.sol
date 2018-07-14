pragma solidity ^0.4.21;

import "./PropertyRecordInterface.sol";
import "./InvestorsInterface.sol";

library LibOwnership {

  function initializePropertyDetails(
    PropertyRecordInterface.PropertyDetail _property,
    string _id,
    string _name,
    string _propertyAddress,
    string _titleAgent,
    string _titleContact
  ) internal
    returns( bool )
  {
    /* initi property record */
    property.id = _id;
    property.name = _name;
    property.propertyAddress = _propertyAddress;
    property.titleAgent = _titleAgent;
    property.titleContact = _titleContact;
    return( true );
  }

  function formatProperty(
    PropertyRecordInterface.PropertyDetail _property
  ) internal
    returns( string )
  {
      string _buf = "{ ";
      _buf += "'id':'" + _property.id + "',";
      _buf += "'name':'" + _property.name + "',";
      return( _buf );
  }

  // @dev - owners can check how many ownership points were allocated to them
  function getPoints( PropertyMain main, address _owner ) internal returns (uint){
    return(0);
  }

  // @dev - owners can check if they have any funds left for withdrawal
  function availableFunds( PropertyMain main, address _owner )internal returns (uint){
    return(0);
  }


  // @dev - owner has submitted bid, store ether and set up new record
  function submitBid( PropertyMain main, address _who, string _myContact, uint _myAmount) internal returns(bool){
    return( true );
  }//submitBid

  // @dev - unlock all unclaimed Ether for owners to retrieve it
  function unlockOverpayments( PropertyMain main ) internal returns(bool){
    return( true );
  }//unlockOverpayment


  // @dev - calculate the amount of shares each bidder is awarded
  function calculateShares(PropertyMain main, uint propertyPrice, uint _initialExpense ) internal returns(bool){
    return( true );
  }//calculateShares


  // @dev - allow the sender withrdraw their funcds if they are unlocked
  function withdrawBalance( PropertyMain main, address _sender) internal returns(uint){
    return( true );
  }//witdrawBalance

  // @dev - calculate portion of the sale proceeds for each owner
  function calculateShareOfSaleProceeds( PropertyMain main, uint _funds ) internal returns(bool){
    return( true );
  }//calculateShareOfSaleProceeds

  // @dev - after the buyer has deposited the amount, unlock funds for each owner
  function unlockSaleProceeds( PropertyMain main ) internal returns(bool){
    return( true );
  }//unlockSaleProceeds

  // @dev - calculate the amount of funds that were not withdrawn yet by the owners
  function totalPendingDistribution( PropertyMain main ) internal returns(uint){
    return( 0 );
  }//totoalPendingDistribution


}//LibOwnership

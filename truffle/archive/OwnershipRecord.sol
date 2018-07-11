pragma solidity ^0.4.0;

contract OwnershipRecord {

    enum OwnershipState {
      New,
      Bidding,
      ClosePurchase,
      Purchased,
      Selling,
      Closed
    }

    address contractOwner;
    OwnershipState contractState;

    uint totalSubscription;
    uint currentSubscription;
    uint totalPointsAwareded;
    uint distributedAmount;

    uint currentReserve;

    //contract purchasing// Property Ownership -- current and future structure;
    struct StakeholderRecord {
      address stakeholder;        // address of the current owner
      string stakeholderContact;         // email address f/ notifications
      uint bidAmount;
      uint ownershipPoints; // current share
      //uint futurePoints;    // future share, to be reallocated upon period renewal
      //uint unclaimedEther;  // unclaimed amounts
      uint proceeds;   // amount to be return as sale price
      uint reservedPoints;
    }

    StakeholderRecord[] stakeholder;  // current ownership structure
    mapping (address=>uint) stakeholderIndex; // index of the ownership record - fow quick lookups

    //==================================================================
    constructor (address _owner) public {
      contractOwner = _owner;
      contractState = OnweshipState.New;
      totalPointsAwarded = 0;
      currentSubscription = 0;
    }

    //==================================================================
    function openForBidding ( uint _price, uint _closingCosts, uint _initialReserve )
      public
      returns (bool)
    {
      totalSubscription = _price + _closingCosts + _initialReserve;
      contractState = OwnershipState.Bidding;
      return(true);
}//open for bidding


    function submitBid( address _bidder, string _contact, uint _amount )
      public payable
      returns(bool)
    {
      require( _amount==msg.value );
      require( currentSubscription < totalSubscription );

      StakeholderRecord bid = new StakeholderRecord();
      bid.stakeholder = _bidder;
      bid.stakeholderContact = _contact;
      bid.bidAmount = msg.value;
      bid.ownershipPoints = 0;
      bid.reservedPoints = 0;

      stakeholder.push(bid);
      stakeholderIndex[_bidder]=stakeholder.length-1;

      currentSubscription += msg.value;
      return(true);
    }//submit bid


    function closeBidding() public {
      constractState = OwnershipState.ClosePurchase;
    }//close bidding

    function awardMembership() public returns (bool){
      uint i=0;
      uint awardedPoints=0;
      uint allocatedFunds=0;
      while( i<stakeholder.length && allocatedFunds<totalSubscription ){
        // calculkate ownership points
        uint _bidAmount = stakeholder[i].bidAmount;
        if( allocatedFunds + _bidAmount > totalSubscription ){
          _bidAmount = totalSubsciption - awardedPoints;
        }
        uint _points = 10000 * _bidAmount / totalSubscription;
        stakeholder[i].ownershipPoints = _points;
        awardedPoints += _points;
        allocatedFunds += _bidAmount;
        i++;
      }//while
      totalPointsAwarded = awardedPoints;
      returnUnsuccessfulBids();
      contractState = OwnershipState.Purchased;
      return( true );
    }//awardOwnership

    function returnUnsuccessfulBids() private returns (bool){
      uint i=0;
      while( i<stakeholder.length ){
        uint _returnFunds = stakeholder[i].bidAmount;
        if( _returnFunds > 0 ){
          //return funds
          address _returnTo = stakeholder[i].stakeholder;
          _returnTo.transfer( _returnFunds );
        }
        i++;
      }
    }//return unsuccessful bids

    function verifyOwnership( address _me ) const public returns(uint){
      uint _points = 0;
      uint ndx = stakeholderIndex[_me];

      if( ndx>=0 ){
        _points = stakeholder[ndx].ownershipPoints;
      }

      return( _points );

    }//verifyOwnership

    // contract transfer ownership
    //===============================================
    // transfer structure is used for both bidding and for trnasferring ownership
    struct Transfer {
      address fromAddr;
      address toAddr;
      uint pointsAmount;
      uint pin;
    }

    Transfer[] proposedTransfers;  // array for transfer proposals

    function scheduleTransfer( address _buyer, uint _amnount, uint _pin ) public returns(bool) {
      uint ndx = stakeholderIndex[msg.sender];
      uint _balance = stakeholder[ndx].ownershipPoints - stakerholder[ndx].reservedPoints;
      require( _balance >= _amount );
      Transfer trn = new Transfer();
      trn.toAddr = msg.sender;
      trn.fromAddr = _buyer;
      trn.pointsAmount = _amount;
      trn.pin = _pin;
      stakeholder[ndx].reservedPoints += _amount;
      proposedTransfers.push(trn);
    }//scheduleTransfer

    function executeTransfer( address _seller, uint _amount, uint _pin ) public payable returns(bool){
        require( _amount==msg.value );
        uint i=0;
        int ndx=-1;
        while( i<proposedTransfers.length ){
          if( proposedTransfers[i].fromAddr == _seller &&
            proposedTransfer[i].toAddr == msg.sender &&
            proposedTransfer[i].pointsAmount == _amount &&
            proposedTransfer[i].pin==_pin ){
              ndx = i;
              break;
            }//
          i++;
        }//while
        require( ndx!=-1 );
        _seller.transfer(_amount);
        return(true);
    }//escrowTransfer

    function cancelTransfers(){

    }

  // contract selling
    //===============================================

    function beginClosing( uint _salePrice, uint _sellCost ) public returns(bool){
      if( scheduledTransfers.length > 0 ){
        return(false);
      }
      contractState = OwnershipState.beginClosing;
      distributedAmount = 0;
      uint amountForDistribution = _saleprice - _sellCost;
      uint unitPrice = amountForDistribution / totalPointsAwarded;
      calculateShares( unitPrice );
      return( true );
    }//beginClosing

    function calculateShares(uint unitPrice ) private {
        uint i=0;
        while( i<shareholder.length ){
          uint _points = shareholder[i].ownershipPoints;
          if( _points>0 ){
            uint _amount = _points * unitPrice;
            shatreholder[i].proceeds = _amount;
            distributedAmount += _amount;
          }
          i++;
        }
    }//calculate share for each owner

    function executeClosing() public returns(bool){
        disburseProceeds();
        contractState = OwnershipState.Disbursed;
        return( true);
    }//complete closing

    function disburseProceeds() private {
      uint i=0;
      while( i<stakeholder.length ){
        uint _proceeds = stakeholder[i].proceeds;
        if( _proceeds > 0 ){
          //return funds
          address _receiver = stakeholder[i].stakeholder;
          _receiver.transfer( _proceeds );
        }
        i++;
      }
  }//disburse remaining costs


}//ownership record

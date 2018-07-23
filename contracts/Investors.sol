pragma solidity ^0.4.21;

library Investors {

  struct InvestorRecord {
  /* properties relevant to ownership */
    uint index;
    address holder;        // address of the current owner
    string holderContact;  // email address for notifications
    uint unclaimedEther;   // unclaimed amounts

 /* properties used during the purchase process */
    uint bidAmount;        // amount the bidder submitf for purchase
    uint ownershipPoints;  // current share

 /* properties used during the sale process */
    uint proceedsAmount;         // amount to be returned from the sale price

 /* properties used during the ownership transfer */
    uint lockedPoints;

  }// OwnerRecord


struct InvestorRecords {
  mapping( address => InvestorRecord ) investorsVector;
  address[] investorAddr;
  //uint count;
}

event Financials( string _code, address _who, uint _amount, uint _points);


//function initialize( InvestorRecords storage self ) pure internal { /* self.count = 1;*/ }


/* lookup functions */

function getCount( InvestorRecords storage self ) internal view returns(uint _cnt){ _cnt = self.investorAddr.length; /*self.count;*/ }

function getDetails( InvestorRecords storage self, address _who )
  internal view
  returns(
    uint _ndx,
    string _contact,
    uint _bid,
    uint _pts,
    uint _proc )
{
  _ndx =  self.investorsVector[_who].index;
  _contact = self.investorsVector[_who].holderContact;
  _bid = self.investorsVector[_who].bidAmount;
  _pts = self.investorsVector[_who].ownershipPoints;
  _proc = self.investorsVector[_who].proceedsAmount;
}

function getOwnershipPoints( InvestorRecords storage self, address _who )
  internal view
  returns(uint _pts)
{
    _pts = self.investorsVector[_who].ownershipPoints;
}

function checkAvailableFunds( InvestorRecords storage self, address _sender )
  internal view
  returns(uint _funds)
{
    _funds = self.investorsVector[_sender].unclaimedEther;
}

function getTotalPoints( InvestorRecords storage self)
  internal view
  returns(uint _points )
{
  _points = 0;
  for( uint i=0; i<self.investorAddr.length; i++ ){
    _points += self.investorsVector[self.investorAddr[i]].ownershipPoints;
  }//for
}


/* methods library */

function submitInvestorBid(
  InvestorRecords storage self,
  address _sender,
  string _myContact,
  uint _myAmount,
  uint _points
)
  internal
{
    InvestorRecord storage inv = self.investorsVector[_sender];

    inv.index = self.investorAddr.length;
    inv.holder = _sender;
    inv.holderContact = _myContact;
    inv.unclaimedEther = 0;
    inv.bidAmount = _myAmount;
    inv.ownershipPoints = _points;
    inv.proceedsAmount = 0;
    inv.lockedPoints = 0;

    self.investorAddr.push(_sender);
}

function confirmAllocatedPoints( InvestorRecords storage self, uint _maxPoints, uint _amount )
  internal
{

  uint _unit = (_amount+500) / 1000;  // value of each investment points
  uint _allocated = 0;

  /* first allocate amount of points */
  for( uint i=0; i<self.investorAddr.length; i++ ){
    uint _points = self.investorsVector[self.investorAddr[i]].bidAmount / _unit;
    self.investorsVector[self.investorAddr[i]].ownershipPoints = _points;

    // update running balances
    if( _allocated + _points <= _maxPoints ){
      _allocated += _points;
      emit Financials( "ownewrship", self.investorAddr[i], self.investorsVector[self.investorAddr[i]].bidAmount, _points);
    }else{
      // if overpoints then make adjustment and lock overage
      uint _allowed = _maxPoints - _allocated;
      self.investorsVector[self.investorAddr[i]].ownershipPoints = _allowed;
      emit Financials( "ownewrship-adjustment", self.investorAddr[i], self.investorsVector[self.investorAddr[i]].bidAmount, _allowed);
      _allocated += _allowed;
    }//if
  }

  /* now caclulate any overpaid amounts and return it to bidders */
 for( i=0; i<self.investorAddr.length; i++ ){
   uint _share = self.investorsVector[self.investorAddr[i]].ownershipPoints * _unit;
   uint _bid = self.investorsVector[self.investorAddr[i]].bidAmount;
   if( _bid > _share ){
     uint _overpaid = _bid - _share;
     self.investorsVector[self.investorAddr[i]].proceedsAmount = _overpaid;
   }//if
 }
}


function unlockOverpayments( InvestorRecords storage self )
  internal
{
  for( uint i=0; i<self.investorAddr.length; i++ ){
    uint _overpaid = self.investorsVector[self.investorAddr[i]].proceedsAmount;
    if( _overpaid>0 ){
      self.investorsVector[self.investorAddr[i]].proceedsAmount = 0;
      self.investorsVector[self.investorAddr[i]].unclaimedEther = _overpaid;
      emit Financials( "overpaid", self.investorAddr[i], _overpaid, 0);
    }//if
  }//for
}

function getAmountRaised( InvestorRecords storage self )
  internal view
  returns(uint _amt)
{
  _amt = 0;
  for( uint i=0; i<self.investorAddr.length; i++ ){
    _amt += self.investorsVector[self.investorAddr[i]].bidAmount - self.investorsVector[self.investorAddr[i]].unclaimedEther;
  }//for
}


function unlockAllInvestments( InvestorRecords storage self )
  internal
{
  /* something */
  for( uint i=0; i<self.investorAddr.length; i++ ){
    self.investorsVector[self.investorAddr[i]].proceedsAmount = 0;
  }//for
}


function withdrawFunds( InvestorRecords storage self, address _sender)
  internal
  returns( uint _funds )
{
  _funds = self.investorsVector[_sender].unclaimedEther;
  self.investorsVector[_sender].unclaimedEther = 0;
}

function calculateShareOfSaleProceeds( InvestorRecords storage self, uint _funds )
  internal
{
  /* something */
  for( uint i=0; i<self.investorAddr.length; i++ ){
    self.investorsVector[self.investorAddr[i]].proceedsAmount = _funds;
  }//for
}

function unlockSaleProceeds( InvestorRecords storage self )
  internal
{
  for( uint i=0; i<self.investorAddr.length; i++ ){
    self.investorsVector[self.investorAddr[i]].unclaimedEther += self.investorsVector[self.investorAddr[i]].proceedsAmount;
    self.investorsVector[self.investorAddr[i]].proceedsAmount = 0;
  }//for
}


function totalPendingWithdrawals( InvestorRecords storage self)
  internal view
  returns(uint _amount )
{
  _amount = 0;
  for( uint i=0; i<self.investorAddr.length; i++ ){
    _amount += self.investorsVector[self.investorAddr[i]].unclaimedEther;
  }//for
}


}//InvestorsInterface

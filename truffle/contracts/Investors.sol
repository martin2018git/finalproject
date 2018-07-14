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
  uint count;
}


function initialize( InvestorRecords storage self ) internal {  self.count = 1; }


/* lookup functions */

function getCount( InvestorRecords storage self ) internal view returns(uint _cnt){ _cnt = self.count; }

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
  for( uint i=1; i<=self.count; i++ ){
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
    self.count++;
    self.investorsVector[_sender].index = self.count;
    self.investorsVector[_sender].holder = _sender;
    self.investorsVector[_sender].holderContact = _myContact;
    self.investorsVector[_sender].unclaimedEther = 0;
    self.investorsVector[_sender].bidAmount = _myAmount;
    self.investorsVector[_sender].ownershipPoints = _points;
    self.investorsVector[_sender].proceedsAmount = 0;
    self.investorsVector[_sender].lockedPoints = 0;
    self.investorAddr[self.count] = _sender;
}

function unlockOverpayments( InvestorRecords storage self, uint _amount )
  internal
{
  /* something */
  for( uint i=1; i<=self.count; i++ ){
    self.investorsVector[self.investorAddr[i]].proceedsAmount = _amount;
  }//for
}

function getAmountRaised( InvestorRecords storage self )
  internal
  returns(uint _amt)
{
  /* something */
  for( uint i=1; i<=self.count; i++ ){
    self.investorsVector[self.investorAddr[i]].proceedsAmount = 0;
  }//for
  _amt = 0;
}


function unlockAllInvestments( InvestorRecords storage self )
  internal
{
  /* something */
  for( uint i=1; i<=self.count; i++ ){
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
  for( uint i=1; i<=self.count; i++ ){
    self.investorsVector[self.investorAddr[i]].proceedsAmount = _funds;
  }//for
}

function unlockSaleProceeds( InvestorRecords storage self )
  internal
{
  for( uint i=1; i<=self.count; i++ ){
    self.investorsVector[self.investorAddr[i]].unclaimedEther += self.investorsVector[self.investorAddr[i]].proceedsAmount;
    self.investorsVector[self.investorAddr[i]].proceedsAmount = 0;
  }//for
}


function totalPendingWithdrawals( InvestorRecords storage self)
  internal view
  returns(uint _amount )
{
  _amount = 0;
  for( uint i=1; i<=self.count; i++ ){
    _amount += self.investorsVector[self.investorAddr[i]].unclaimedEther;
  }//for
}


}//InvestorsInterface

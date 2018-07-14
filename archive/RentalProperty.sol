pragma solidity ^0.4.0;

contract RentalProperty {

/* state of property:
  1 - purchasing process
        Proposal - property is being proposed for investment, bidding begins
          @ all points distributed, begin closing, investors must escrow
        Closing Purchase - property investors escrow amounts, and escrow agent confirms points
          @ once all funds are escrowed, the agent conducts Closing
        Purchased - property ownership established, agent notifies investors and initiates bidding for manager

  2 - renting process
          @ first, the vote for property manager is conducted, one the manager is appointed the rental begins
        Leased - property is rented to the appointed manager who lives in the property.
        OnMarket - if property is not leased it's on market and can be rented out (booking process)
        OffMarket - property is temporarily off market

  3 - booking process
        when customer requests booking, we'll use the following:
            - bookingPeriod ... WEEK, MONTH, YEAR
            - bookingSchedule ... list of periods booked, and who has booked it
            - cancelledBooking ... (log events) who has cencelled booking
            - completedBooking ... (log events) who has stayed in the property

  4 - selling process
          ForSale - when investors decide to put property for sale
          AcceptedOffer - when investors agree to sell property at given price
          ClosingSale - property closing in progress
          Sold - property was soled, funds in escrow will be distributed
          Settled - all escrow was refunded, contract is inactive

  5 - servicing process
        @ at any time the property manager may request a vote on needed service
            > requestServiceVote
            > castServiceVote
            > revealVote
            > acceptService
            > rejectService
            > confirmServiceCompletion
        @ at any point an investor can request transfer of ownership,
          but transfers are only executed if no voting is open,
          seller also forfeits the current rental amount

  */

enum PropertyState {
  New,              // property is new, users can submit claim offers
  ClosingPurchase,  // bidding is closed, negotiating purchase & assign Ownership
  Purchased,        // property is purchased, elelct the initial manager

  Leased,           // property is leased to property manager long term
  OnMarket,         // property is available for short term rentals
  Rented,           // property is rented
  OffMarekt,        // property is off market, i.e. service, maintenance, etc.

  ForSale,          // property is offered for sale
  ClosingSale,      // sale agreed
  Sold,             // property is sold, money is in escrow
  Settled           // escrow is distributed to owners
}

enum UserRole {
  Owner,            // owner of the property,
  Escrow,           // escrow agent, most likely legal firm
  Manager           // current manager of the property
}

modifier hasState( PropertyState s ){
  require( propertyStatus==s );
  _;
}

modifier hasRole( UserRole r ){
  if( r == UserRole.Owner ){
    require( msg.sender==contractOwner );
  }
  if( r == UserRole.Escrow ){
    require( msg.sender==contractEscrow );
  }
  if( r == UserRole.Manager ){
    require( msg.sender==contractManager);
  }
  _;
}

struct PropertyDetails {
  string id;  // unique identifier of the property
  string name; // given name of the property
  string propertyAddress; // where is it located
  string titleAgent; // who holds the property title
  string titleContact; // email for the title holder
}

// Property Details - all related
PropertyDetails propertyDetails;  // description and info about the asset
PropertyState propertyStatus;  // contract status, i.e. state of the property

constructor (
    string _id,
    string _name,
    string _propertyAddress
) public {
  propertyDetails.id = _id;
  propertyDetails.name = _name;
  propertyDetails.propertyAddress = _propertyAddress;
  propertyStatus = PropertyState.New;
  contractOwner = msg.sender;
}

// 1 - purchasing process
//=========================================================================
uint propertyPrice;  // how much is the total investment
uint unitPrice;      // how much for each basis point
uint totalPoints;   // total points allocated
address contractOwner;   // owner of the contract, initiator and title holder
string  ownerContact;    // email for owner
address contractEscrow;  // legal repreasentation of the owner, managees funds
string  escrowContact;   // email for escrow agent
address contractManager; // general manager and servicing of the contract
string  managerContact;  // email for current manager

// Property Ownership -- current and future structure;
struct StakeholderRecord {
  address stakeholder;        // address of the current owner
  string stakeholderContact;         // email address for notifications
  uint ownershipPoints; // current share
  uint futurePoints;    // future share, to be reallocated upon period renewal
  uint unclaimedEther;  // unclaimed amounts
}

StakeholderRecord[] stakeholder;  // current ownership structure
mapping (address=>uint) stakeholderIndex; // index of the ownership record - fow quick lookups


function openForBidding( uint _openPrice ) public
  hasState( PropertyState.New )
  hasRole( UserRole.Owner )
{
// @ open bidding for given property until all points are awarded
    require( _openPrice > 10000 );
    propertyPrice = _openPrice;
    unitPrice = _openPrice / 10000;
    totalPoints = 0; // no points awarded yet
}//openForBidding


function getPropertyInfo() public
  returns ( string _id, string _name, string _address,
    string _status,
    string _titleAgent, string _titleContact,
    uint _price )
// @can be called anytime to obtain property info
{
    _status = "INACTIVE";
    if( propertyStatus==PropertyState.Proposal ) _status="NEW";

    if( propertyStatus==PropertyState.Leased
      || propertyStatus==PropertyState.OnMarket
      || propertyStatus==PropertyState.Rented  ) _status="ACTIVE";

    if( propertyStatus==PropertyState.Sold
      || propertyStatus==PropertyState.Settled ) _status="SOLD";

    return(
      propertyDetails.id, propertyDetails.name, propertyDetails.propertyAddress,
      _status,
      propertyDetails.titleAgent, propertyDetails.titleContact,
      propertyPrice
      );
}

function submitBid(
  string _myContact,
  uint _myAmount
  ) public
  hasState( PropertyState.New )
  returns (bool)
// @ submit bids until all points are allocated
{
  require( _myAmount>0 );
  StakeholderRecord stake = new StakeholderRecord();

}


function closeBidding(
  uint _price,
  address _escrowAgent,
  string _escrowContact
) public
  hasState( PropertyState.New )
  hasRole( UserRole.Owner )
// close bidding and appoint escrow manager
{
  contractEscrow = _escrowAgent;
  escrowContact = _escrowContact;
  propertyPrice = _price;
  propertyStatus = PropertyState.ClosingPurchase;
}//closeBidding

function awardOwnership(
  address _toWhom,
  string _toContact,
  uint amountPoints
) public
  hasRole( UserRole.Escrow )
  hasState( PropertyState.ClosingPurchase )
//award ownership
{
  require( amountPoints>0 );
  StakeholderRecord stake = new StakeholderRecord();

  stake.stakeholder = _toWhom;
  address stakeholder;        // address of the current owner
  string stakeholderContact;         // email address for notifications
  uint ownershipPoints; // current share
  uint futurePoints;    // future share, to be reallocated upon period renewal
  uint unclaimedEther;  // unclaimed amounts

}




// transfer structure is used for both bidding and for trnasferring ownership
struct Transfer {
  address fromAddr;
  address toAddr;
  uint pointsAmount;
  uint pin;
}

Transfer[] proposedTransfers;  // array for transfer proposals



}//RentalProperty

pragma solidity ^0.24.0;

contract CoopPropertyStateMachine {

  /* contract proprties and variables
   */
   PropertyState state; // state of the contract
   address owner; // owner of the contract
   address manager; // current delegated manager responsible for renting and
                    // maintenance of the property

  // state machine for the contract behavior
  enum PropertyState {
    New,              // property is new, users can submit claim offers
    ClosingPurchase,  // bidding is closed, negotiating purchase & assign Ownership
    Purchased,        // property is purchased, elelct the initial manager

    Leased,           // property is leased
    OnMarket,         // property is available for short term rentals
    OffMarekt,        // property is off market, i.e. service, maintenance, etc.

    ForSale,          // property is offered for sale
    ClosingSale,      // sale agreed
    Sold,             // property is sold, money is in escrow
    Settled           // escrow is distributed to owners
  }

  // details of the property
  struct PropertyDetails {
    string id;  // unique identifier of the property
    string name; // given name of the property
    string propertyAddress; // where is it located
    string titleAgent; // who holds the property title
    string titleContact; // email for the title holder
  }


  // role of each user
  enum UserRole {
    Owner,            // owner of the property,
    Manager           // current manager of the property
  }

  /*---------------------------------------------------------------------
   * MODIFIERS
   */
  modifier hasState( PropertyState s ){
    require( state==s );
    _;
  }

  modifier isOwner(){
      require( msg.sender==owner );
      _;
  }

  modifier isManager(){
      require( msg.sender==manager );
      _;
  }


}// CoopPropertyStateMachine




contract CoopProperty is
  CoopPropertyStateMachine,
  ContractWithOwnership,
  ContractWithTransfers,
{

  /* unique verification key, i.e.address of the developer*/
  string constant public CONTRACT_INTERFACE_VERSION = "0x123456789";

  PropertyDetails property; // property details

  /* contract financials: */
  uint propertyPrice; // value of the purchased property
  uint reserveAmount; // amount of reserve left for managing property
  uint monthlyFee;    // monthly fee that goes to the property managerContact
  uint monthlyLease;  // monthly lease

  /* contract ownrship management  */
  uint unitPrice; // unit price for the smalled unit that can be purchased 0.01%
  uint totalPoints; // amount of ownership points in circulation

  /* separate building block contracts to simplify coding and management
   */
  address ownershipContract; // encapsulation of the ownership records maintenance
  address transfersContract; // encapsulation of all transfers management
  address leasingContract; // encapsulation of the leasing functions
  address votingContract; // encapsulation of various property voting funcitons
  address sellingContract; // encapsulation fo the final selling and disposal of the property


  /*---------------------------------------------------------------------
   * MODIFIERS
   */
  modifier isAddress( address a ){
    assert( a!=address(0) );
    _;
  }


  /*---------------------------------------------------------------------
   * @dev - set up initial contracts
   */
  constructor (
    string _id,
    string _name,
    string _propertyAddress,
    string _titleAgent,
    string _titleContact,
    address _ownershipContract,
    address _transfersContract,
    address _leasingContract,
    address _votingContract,
    address _sellingContract
  ) public
    isAddress(ownershipContract)
    isAddress(transfersContract)
    isAddress(leasingContract)
    isAddress(votingContract)
    isAddress(sellingContract)
  {
    property.id = _id;
    property.name = _name;
    property.propertyAddress = _propertyAddress;
    property.titleAgent = _titleAgent;
    property.titleContact = _titleContact;
    ownershipContract = _ownershipContract;
    transfersContract = _transfersContract;
    leasingContract = _leasingContract;
    votingContract = _votingContract;
    sellingContract = _sellingContract;

    // set initial values
    state = PropertyState.New;
    owner = msg.sender;
    manager = msg.sender;
  }//constructor


  /*---------------------------------------------------------------------
   * @dev - begin purchasing process, interested partied submit their bids
   */
  function openForBidding(
    uint _openPrice,  // what is the asking price for the property
    uint _monthlyFee, // how much the initial management fee is set to
    uint _monthlyLease  // how much the initial monthly lease is set to
  ) public
    hasState( PropertyState.New )
    isOwner()
  {
  // open bidding for given property until all points are awarded
      require( _openPrice > 10000 );
      propertyPrice = _openPrice;
      reserveAmount = 0;
      monthlyFee = _monthlyFee;
      monthlyLease = _monthlyLease;
      unitPrice = _openPrice / 10000;
      totalPoints = 0; // no points awarded yet
  }//openForBidding

  /*---------------------------------------------------------------------
   * @dev - begin bidding for the property ownership
   */
   function submitBid(
     string _myContact,
     uint _myAmount
     ) public
     hasState( PropertyState.New )
     returns (bool)
   // @ submit bids until all points are allocated
   {
     require( _myAmount>0 );
     return( ownershipContract.submit)
   }//submitBid




}

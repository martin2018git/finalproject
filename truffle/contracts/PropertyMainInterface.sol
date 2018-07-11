pragma solidity ^0.4.21;

import "./LibOwnership.sol"; // library for managing ownership of the property
//import "LibRenting.sol"; // library for managing leasing of the property
//import "LibVoting.sol"; // library for managing various voting needs

interface PropertyMainInterface {
    /* unique verification key, i.e.address of the developer etc.*/
    string constant public CONTRACT_INTERFACE_VERSION = "JUL2018-V1-01";

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

    // details of the property
    struct PropertyDetails {
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

     PropertyState state; // state of the contract
     address owner; // owner of the contract
     address ownerContact;
     address manager; // current delegated manager responsible for renting and
                      // maintenance of the property
     string managerContact;

     address seller;
     uint unlockSellerFunds;
     uint unlockClosingFees;
     address buyer;

     /* contract properties and global variables */
     PropertyDetails property; // property details
     mapping (address=>uint) ownerIndex;
     LibOwnership.OwnershipRecord[] aOwners;

     /* list of all main events */
     // logs any changes in ovenrship
     event OwnershipTransfer( address _from, address _to, uint _points );
     // logs any financial transfers
     event Financials( uint _code, address _who, uint _amount, uint _points);
     /* types:  1-ownrship purchase
                2-ownership sale
                3-seller payment
                4-owner fee (closing fee)
                5-buyer amount
                6-management fee
                7-service fee
                8-lease payment
                9-owner share
      */
      // change in the manager function
      event ManagerChange( address _newManager, string _dateFrom );
      // new lease assigned
      event LeaseRecord( address _who, string _dateFrom );
      // request for vote
      event VoteRequest( string _description, string _deadline );
      // votre results
      event VoteDecision( string _description, string _result, address _ref );

    /*-------------------------------------------------------------------
     * USER STORY #1: SETUP, DISPOSAL of rental proerty,
     *                and various information lookup functions
     *-------------------------------------------------------------------
     */
    // @dev - initial property contract setup
    constructor ( string _id, string _name, string _propertyAddress, string _titleAgent, string _titleContact ) external;

    // @dev - return JSON style strign with the property details
    function getPropertyDetails() const external returns (string);
    // @dev - owners can check how many ownership points were allocated to them
    function checkOwnershipShare() const external returns (uint);
    // @dev - owners can check if they have any funds left for withdrawal
    function checkAvailableFunds() const external returns (uint);

    /*-------------------------------------------------------------------
     USER STORY #2: PURCHASING A PROPERTY
     1) the story starts with @owner settign up the @property and open it
        for bidding using #openForBidding method.
     2) Individual candidates then submit their bids using #submitBid method,
        until the totoal ownership points (set at 100.0%) are distributed.
     3) The owner then closes bidding by starting the property pruchase closing
        process, by invoiking the #closePurchase method. As part of the closing
        the property ownership points are confirmed and any overpaid funds are
        unlocked for withdrawal.
     4) Seller then can witdraw the funds (purchase price) by calling
        #withdrawSellerFunds, and pruchase Ether is transferred to his/her account.
     5) Owner can then also withdraw closing costs from the account using
        the agreed #withdrawCLosingFees and the remaining balance is left
        as @propertyReserve amount for servicing the property.
     6) If the purchase was cancelled, the owner calls #cancelPurchase and
        funds deposited by bidders are unlock so they can retireve them back.
     7) Finally both successful and unsuccessful bidders can withdraw the unused
        funds by calling individually the #withdrawFunds method.
     *-------------------------------------------------------------------
     */
    function openForBidding( uint _openPrice, uint _closingCosts, uint _monthlyFee, uint _monthlyLease ) external;
    function submitBid( string _myContact, uint _myAmount ) external payable returns (bool);
    function closePurchase( address _seller, uint _actualPrice, uint _initialExpenses ) external returns (bool);
    function withdrawSellerFunds() external;
    function withdrawFunds() external returns (bool);
    function withdrawClosingFees() external;
    function cancelPurchase() external returns (bool);

   /*-------------------------------------------------------------------
    * USER STORY #3: SELLING PROPERTY
    1) Once @owners approve the property to be sold, the owner initiates
       the sale by invoking #beginSale with a given @askingPrice.
    2) If the property does not have any interested buyers, the @owner can initiate
       another voting on a lowerd price. If @owners agreed on the lower price,
       the @owner can:
            a) readjust the sale price by re-calling #beginSale again, or
            b) cancel the sale by calling #cancelSale
    3) Once a @buyer is found, the @owner begins the sale closing, and
       invokes #closeSale with agreed parameters
    4) The contract will then wait for the buyer to deposit the agreed purchase price.
       The @buyer will send ether funds to #depositBuyerFunds and if accepted,
       the contract will distribute the purchase price among the @owners, and
       unlock the funds for them to retrieve their share of proceeds individually.
       If any property reserveFunds are available they are added to the proceeds
       for distribuytion among the owners.
    5) The owner can then call #withdrawClosingFees to pay for the agreed closing fees.
    5) Once all funds were retrieved and all the unlocked amounts were
       retrieved the @owner can destroy the contract.
    *-------------------------------------------------------------------
    */
   function beginSale( uint _askingPrice ) external;
   function closeSale( address _buyer, uint _agreedPrice, uint _closingCosts ) external returns( bool );
   function depositBuyerFunds( uint _agreedPrice ) external payable returns( bool );
   function cancelSale() external returns (bool);
   function disposeOfProperty() external;

   /*-------------------------------------------------------------------
    * USER STORY #4: RENTING PROPERTY
    *   - awarding a lease contract
    *-------------------------------------------------------------------
    */
    // To be implemented next

   /*-------------------------------------------------------------------
    * USER STORY #5: CHANGING OWNERSHIPS / TRADING POINTS
    *-------------------------------------------------------------------
    */
    // To be implemented next

   /*-------------------------------------------------------------------
    * USER STORY #6: OWNERS ARE VOTING ON VARIOUS ISSUES
    * Examples of voting:
    *   - electing a new manager for property maitenance
    *   - choosing a new monthly rental amount (increase or decrease)
    *   - approving service request with given amount (>$500)
    *   - approving property for sale
    *-------------------------------------------------------------------
    */
    // To be implemented next


}// PropertyMainInterface;

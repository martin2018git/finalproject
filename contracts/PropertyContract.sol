pragma solidity ^0.4.21;

import "./Property.sol";
import "./Investors.sol";
//import "./PropertyContractInterface.sol";


contract PropertyContract //is PropertyContractInterface
{
  using Property for Property.PropertyRecord;
  using Investors for Investors.InvestorRecords;

  address owner; // owner of the contract
  address ownerContact;
  address manager; // current delegated manager responsible for renting and
                   // maintenance of the property
  string managerContact;

  uint unlockSellerFunds;
  uint unlockClosingCosts;
  address seller;
  address buyer;

  Property.State state;
  Property.PropertyRecord property;
  Investors.InvestorRecords investors;

  /* list of all main events */
  // debugging events
  event Debug( uint _level, string _msg );
  event Bid( address _who, uint _points );

  // logs any changes in ovenrship
  event OwnershipTransfer( address _from, address _to, uint _points );
  // logs any financial transfers
  event Financials( string _code, address _who, uint _amount, uint _points);
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


    /*---------------------------------------------------------------------
     * @dev - set up initial contracts
     */
    constructor () public {
      // set initial values
      state = Property.State.Initialize;
      owner = msg.sender;
      //ownerContact = "";
      manager = msg.sender;
      //managerContact = "";

      property.name = "condo";

      unlockSellerFunds = 0;
      unlockClosingCosts = 0;
    }//constructor


    /*---------------------------------------------------------------------
     * MODIFIERS
     */
    modifier hasState( Property.State s ){
      require( state==s );
      _;
    }

    modifier hasStates( Property.State s1, Property.State s2 ){
      require( state==s1 || state==s2 );
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

    modifier isSeller(){
        require( msg.sender==seller );
        _;
    }

    modifier isBuyer(){
        require( msg.sender==buyer );
        _;
    }


    /* MAINTENANCE functions */

    function initialize (
      string _id,
      string _name,
      string _propertyAddress,
      string _titleAgent,
      string _titleContact
    ) external
      isOwner()
      hasState( Property.State.Initialize )
      returns( bool )
    {
      //Property.initialize( property, _id, _name, _propertyAddress, _titleAgent, _titleContact );
      property.initialize( _id, _name, _propertyAddress, _titleAgent, _titleContact );
      //Investors.initialize( investors );
      //investors.initialize();
      state = Property.State.New;
      emit Debug( 1, "initialize()" );
      return( true );
    }//constructor


      // @dev - return JSON style strign with the property details
      function getPropertyDetails() external view returns (string, string, string, string, string)
      {
          //return( Property.formatPropertyInfo(property) );
          return( property.formatPropertyInfo() );
      }

      function getPropertyStatus() external view returns (string)
      {
          return( Property.getState(state) );
      }

      // @dev - owners can check how many ownership points were allocated to them
      function checkOwnershipShare() external view returns (uint)
      {
          //return( Investors.getOwnershipPoints( investors, msg.sender ) );
          return( investors.getOwnershipPoints( msg.sender ) );
      }

      function getCountOfInvestors() external view returns(uint _len){
          //_len = Investors.getCount( investors );
          _len = investors.getCount();
      }

      function getTotalPoints() external view returns(uint _points){
          _points = investors.getTotalPoints();
      }

      function getInvestorDetails( address _who )
        external view
        returns(uint,string,uint,uint,uint)
      {
        //return( Investors.getDetails( investors, _who ) );
        return( investors.getDetails( _who ) );
      }

      // @dev - owners can check if they have any funds left for withdrawal
      function checkAvailableFunds()
        external view
        returns (uint _funds)
      {
        //_funds = Investors.checkAvailableFunds( investors, msg.sender );
        _funds = investors.checkAvailableFunds( msg.sender );
      }

      /*-------------------------------------------------------------------
       USER STORY #1: PURCHASING A PROPERTY
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

    /*---------------------------------------------------------------------
     * @dev - begin purchasing process, interested partied submit their bids
     */
    function openForBidding(
      uint _openPrice,  // what is the asking price for the property
      uint _closingCosts, // what will be closing costs reserve
      uint _initialReserve, // what will be the inital reserve
      uint _monthlyFee, // how much the initial management fee is set to
      uint _monthlyLease  // how much the initial monthly lease is set to
    ) external
      hasState( Property.State.New )
      isOwner()
    {
    // open bidding for given property until all points are awarded
        require( _openPrice > 1000 && _openPrice<1000000 );
        property.propertyPrice = _openPrice;
        property.reserveAmount = _initialReserve;
        property.closingCosts = _closingCosts;
        unlockSellerFunds = 0;
        unlockClosingCosts = 0;
        property.monthlyFee = _monthlyFee;
        property.monthlyLease = _monthlyLease;
        property.unitPrice = ( _openPrice + _initialReserve + 500 ) / 1000; // round unit price
        require( property.unitPrice>0 );
        property.totalPoints = 0; // no points awarded yet
        state = Property.State.Bidding;
    }//openForBidding

    /*---------------------------------------------------------------------
     * @dev - begin bidding for the property ownership
     */
     function submitBid(
       string _myContact,
       uint _myAmount
    )  payable
       public
       hasState( Property.State.Bidding )
     // @ submit bids until all points are allocated
     {
       require( property.totalPoints < 1000 );
       require( _myAmount/property.unitPrice > 0 ); // only amounts that will get at least 1 point
       // log each bid in sequence
       uint _points = _myAmount / property.unitPrice;
       //Investors.submitInvestorBid( investors, msg.sender, _myContact, _myAmount, _points);
       investors.submitInvestorBid( msg.sender, _myContact, _myAmount, _points);

       //investors.count++;
       /*investors.investorsVector[msg.sender].index = investors.count;
       investors.investorsVector[msg.sender].holder = msg.sender;
       investors.investorsVector[msg.sender].holderContact = _myContact;
       investors.investorsVector[msg.sender].unclaimedEther = 0;
       investors.investorsVector[msg.sender].bidAmount = _myAmount;
       investors.investorsVector[msg.sender].ownershipPoints = _points;
       investors.investorsVector[msg.sender].proceedsAmount = 0;
       investors.investorsVector[msg.sender].lockedPoints = 0;
       investors.investorAddr[investors.count] = msg.sender;*/

       property.totalPoints += _points;
       emit Bid( msg.sender, _points );
     }//submitBid

     /*---------------------------------------------------------------------
      * @dev - end bidding
      */
      function closePurchase(
        address _seller,
        uint _actualPrice, // actual negotiated price
        uint _actualClosingCost
      ) external
        hasState( Property.State.Bidding )
        isOwner()
        returns (bool)
      // close bidding and begin close process
      {
        require( property.totalPoints >= 1000 );
        property.propertyPrice = _actualPrice;
        property.closingCosts = _actualClosingCost;

        uint _totalRaised = investors.getAmountRaised();
        uint _totalPoints = investors.getTotalPoints();
        emit Financials( "total-raised", owner, _totalRaised, _totalPoints );
        emit Financials( "proposed-reserve", owner, property.reserveAmount, 0 );

        // closing finances
        seller = _seller;
        unlockSellerFunds = _actualPrice;
        // pay the owner the closing expenses
        unlockClosingCosts = property.closingCosts;

        uint totalInvestment = _actualPrice + _actualClosingCost + property.reserveAmount;
        // unlock funds for returning unused investments, users have to claim them back
        investors.confirmAllocatedPoints( 1000, totalInvestment );
        //Investors.unlockOverpayments( investors, _actualPrice+_actualClosingCost+property.reserveAmount );
        investors.unlockOverpayments();
        // check if the reserve amount is positive (possible overflow!)
        //property.reserveAmount = _actualPrice-_actualClosingCost-Investors.getAmountRaised(investors);
        _totalRaised = investors.getAmountRaised();
        _totalPoints = investors.getTotalPoints();
        emit Financials( "total-allocated", owner, _totalRaised, _totalPoints );
        emit Financials( "purchase-price", seller, _actualPrice, 0 );
        emit Financials( "closing-costs", owner, property.closingCosts, 0 );

        if( _totalRaised > _actualPrice + _actualClosingCost ){
            property.reserveAmount = _totalRaised - _actualPrice - _actualClosingCost;
        }

        emit Financials( "initial-reserve", owner, property.reserveAmount, 0 );

        uint _overpaid = investors. totalPendingWithdrawals();
        emit Financials( "returns-overpayments", 0, _overpaid, 0 );
        state = Property.State.Purchased;
        return(true);
      }//closeBidding

      /*---------------------------------------------------------------------
       * @dev - have seller retrieve the amounts
       */
       function withdrawBySeller(
       ) external
         isSeller()
         hasState(Property.State.Purchased )
         returns (bool)
       {
         require( unlockSellerFunds>0 );
         uint _amount = unlockSellerFunds;
         unlockSellerFunds = 0;
         state = Property.State.OffMarket;
         seller.transfer(_amount);
         emit Financials( "seller-withdrawal", seller, _amount, 0 );
         return( true );
       }//settleSellerFunds

       /*---------------------------------------------------------------------
        * @dev - have owner retrieve the closing expenses
        */
        function withdrawClosingFees(
        ) external
          isOwner()
          returns (bool)
        {
          require( unlockClosingCosts>0 );
          uint _amount = unlockClosingCosts;
          unlockClosingCosts = 0;
          owner.transfer(_amount);
          return( true );
        }//settleSeller

        /*---------------------------------------------------------------------
         * @dev - cancel purchase
         */
         function cancelPurchase(
         ) external
           hasStates( Property.State.Bidding, Property.State.Purchased )
           isOwner()
           returns (bool)
         {
           require( unlockSellerFunds>0 );
           state = Property.State.Disposed;
           //Investors.unlockAllInvestments(investors);
           investors.unlockAllInvestments();
           unlockClosingCosts = 0;
           unlockSellerFunds;
           return( true );
         }//settleSeller

         /*---------------------------------------------------------------------
          * @dev - investors can withdraw funds that were unlocked
          */
          function withdrawFunds(
          ) external
            returns (uint _amount)
          {
            //_amount = Investors.withdrawFunds(investors,msg.sender);
            _amount = investors.withdrawFunds(msg.sender);
            // return funds
            msg.sender.transfer( _amount );
          }//settleSeller


          /*-------------------------------------------------------------------
           * USER STORY #2: SELLING PROPERTY
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

      /*---------------------------------------------------------------------
       * @dev - set up property for sale
       */
       function beginSale(
         uint _askingPrice  // what is the asking price for the property
       ) external
         hasState( Property.State.OffMarket )
         isOwner()
       {
           // open bidding for given property until all points are awarded
           require( _askingPrice>0 );
           property.propertyPrice = _askingPrice;
           state = Property.State.ForSale;  // property cannot be rented now
       }//begin selling

       /*---------------------------------------------------------------------
        * @dev - execute closing and distribute funds
        */
        function closeSale(
          address _buyer,    // who will be buying the property
          uint _agreedPrice,  // what is the closing price
          uint _closingCosts  // how much to set aside for closing
        ) external
          hasState( Property.State.ForSale )
          isOwner()
          returns( bool )
        {
            require( _agreedPrice>0 );
            // where is the payment comming from
            buyer = _buyer;
            property.propertyPrice = _agreedPrice;
            property.closingCosts = _closingCosts;

            // disburse all sale proceeds and reserve to investors
            uint _funds = _agreedPrice + property.reserveAmount - _closingCosts;
            //Investors.calculateShareOfSaleProceeds( investors, _funds );
            investors.calculateShareOfSaleProceeds( _funds );

            emit Financials( "sale-closing", buyer, _agreedPrice, 0 );
            return( true );
        }//close Sale

        /*---------------------------------------------------------------------
         * @dev - await till buyer deposits the amounts
         */
         function depositBuyerFunds(
           uint _agreedPrice  // what is the closing price
         ) external payable
           hasState( Property.State.ForSale )
           isBuyer()
           returns( bool )
         {
             require( _agreedPrice == msg.value );
             require( _agreedPrice == property.propertyPrice );

             emit Financials( "buyer-deposit", msg.sender, _agreedPrice, 0 );

             // allow owners now retrieve their proceeds
             //Investors.unlockSaleProceeds( investors );
             investors.unlockSaleProceeds();

             // allow owner to withdraw closing funds
             unlockClosingCosts += property.closingCosts;

             state = Property.State.Sold;
             return( true );
         }//settle payment

         /*---------------------------------------------------------------------
          * @dev - end the contract
          */
         function disposeOfProperty(
         ) external
           hasState( Property.State.Sold )
           isOwner()
           returns( uint _undistributedFunds )
         {
           //uint undistributedFunds = Investors.totalPendingWithdrawals(investors);
           _undistributedFunds = 0; //investors.totalPendingWithdrawals(); -- maybe allow if not more than 5%?
           // only if all  owners withdrew their amounts, then we can selfdestruct
           require( _undistributedFunds == 0 );

           selfdestruct( owner );  // return any balance to the owner
         }//settle payment


         /*-------------------------------------------------------------------
          * USER STORY #3: RENTING PROPERTY
          *   - awarding a lease contract
          *-------------------------------------------------------------------
          */
          // To be implemented next

         /*-------------------------------------------------------------------
          * USER STORY #4: CHANGING OWNERSHIPS / TRADING POINTS
          *-------------------------------------------------------------------
          */
          // To be implemented next

         /*-------------------------------------------------------------------
          * USER STORY #5: OWNERS ARE VOTING ON VARIOUS ISSUES
          * Examples of voting:
          *   - electing a new manager for property maitenance
          *   - choosing a new monthly rental amount (increase or decrease)
          *   - approving service request with given amount (>$500)
          *   - approving property for sale
          *-------------------------------------------------------------------
          */
          // To be implemented next


}//PropertyContract

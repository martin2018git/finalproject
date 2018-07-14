pragma solidity ^0.4.21;

import "./Property.sol";
import "./Investors.sol";


contract PropertyMain  {

  address owner; // owner of the contract
  address ownerContact;
  address manager; // current delegated manager responsible for renting and
                   // maintenance of the property
  string managerContact;

  uint unlockSellerFunds;
  uint unlockClosingFees;
  address seller;
  address buyer;

  Property.State state;
  Property.PropertyRecord property;
  Investors.InvestorRecords investors;

    /*---------------------------------------------------------------------
     * @dev - set up initial contracts
     */
    constructor () external
    {
      // set initial values
      state = Property.State.Initialize;
      owner = msg.sender;
      ownerContact = "";
      manager = msg.sender;
      managerContact = "";

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
      Property.initialize( property, _id, _name, _propertyAddress, _titleAgent, _titleContact );
      Investors.initialize( investors );
      return( true );
    }//constructor


      // @dev - return JSON style strign with the property details
      function getPropertyDetails() external returns (string)
      {
          return( Property.formatPropertyInfo(property) );
      }

      // @dev - owners can check how many ownership points were allocated to them
      function checkOwnershipShare() external returns (uint)
      {
          return( Investors.getPoints( investors, msg.sender ) );
      }

      // @dev - owners can check if they have any funds left for withdrawal
      function checkAvailableFunds() external returns (uint)
      {
        return( Investors.checkAvailableFunds( investors, msg.sender ) );
      }




   /*-------------------------------------------------------------------
    * USER STORY #2: PROPERTY PURCHASE
    *-------------------------------------------------------------------
    */
    /*---------------------------------------------------------------------
     * @dev - begin purchasing process, interested partied submit their bids
     */
    function openForBidding(
      uint _openPrice,  // what is the asking price for the property
      uint _closingCosts, // what will be closing costs reserve
      uint _monthlyFee, // how much the initial management fee is set to
      uint _monthlyLease  // how much the initial monthly lease is set to
    ) external
      hasState( Property.State.New )
      isOwner()
    {
    // open bidding for given property until all points are awarded
        require( _openPrice > 1000 && _openPrice<1000000 );
        property.propertyPrice = _openPrice;
        property.closingCosts = _closingCosts;
        unlockSellerFunds = 0;
        unlockClosingFees = 0;
        property.reserveAmount = 0;
        property.monthlyFee = _monthlyFee;
        property.monthlyLease = _monthlyLease;
        property.unitPrice = (_openPrice+500) / 1000; // round unit price
        property.totalPoints = 0; // no points awarded yet
        state = PropertyState.Bidding;
    }//openForBidding

    /*---------------------------------------------------------------------
     * @dev - begin bidding for the property ownership
     */
     function submitBid(
       string _myContact,
       uint _myAmount
       ) external payable
       hasState( PropertyState.Bidding )
       returns (bool)
     // @ submit bids until all points are allocated
     {
       require( property.totalPoints<1000 ); // only alow till all points are preallocated
       require( _myAmount/property.unitPrice>0 ); // only amounts that will get at least 1 point
       // log each bid in sequence
       LibOwnership.submitBid(this,msg.sender,_myContact,_myAmount);
       return(true);
     }//submitBid

     /*---------------------------------------------------------------------
      * @dev - end bidding
      */
      function closePurchase(
        address _seller,
        uint _actualPrice, // actual negotiated price
        uint _initialExpenses  // how much we need to set aside for closing costs and othe rexpenses
      ) external
        hasState( PropertyState.Bidding )
        isOwner()
        returns (bool)
      // close bidding and begin close process
      {
        property.propertyPrice = _actualPrice;
        // updcate each ownership contract that is eligible for ownership and update balances
        LibOwnership.calculateShares(this, propertyPrice, _initialExpense );
        // pay the seller
        unlockSellerFunds = _actualPrice;
        seller = _seller;
        // pay the owner the closing expenses
        unlockClosingFees = property.closingCosts;
        // unlock funds for return of values, users have to claim them back
        LibOwnership.unlockOverpayments(aOwners,mapOwners);
        state = PropertyState.Purchased;
        return(true);
      }//closeBidding

      /*---------------------------------------------------------------------
       * @dev - have seller retrieve the amounts
       */
       function withdrawSellerFunds(
       ) external
         isSeller()
         hasState(PropertyState.Purchased )
         returns (bool)
       {
         require( unlockSellerFunds>0 );
         unit _amount = unlockSellerFunds;
         unlockSellerFunds = 0;
         state = PropertyState.OffMarket;
         return( seller.transfer(_amount) );
       }//settleSellerFunds

       /*---------------------------------------------------------------------
        * @dev - have owner retrieve the closing expenses
        */
        function withdrawClosingFees(
        ) external
          isOwner()
          returns (bool)
        {
          require( unlockClosingFees>0 );
          unit _amount = unlockClosingFees;
          unlockClosingFees = 0;
          return( owner.transfer(_amount) );
        }//settleSeller

        /*---------------------------------------------------------------------
         * @dev - cancel purchase
         */
         function cancelPurchase(
         ) external
           hasState( PropertyState.Bidding )
           isOwner()
           returns (bool)
         {
           LibOwnership.unlockOverpayments(aOwners,mapOwners);
           state = PropertyState.Sold;
           return( true );
         }//settleSeller

         /*---------------------------------------------------------------------
          * @dev - withdraw funds that were deposited
          */
          function withdrawFunds(
          ) external
            hasState( PropertyState.Sold )
            returns (bool)
          {
            uint _amount = LibOwnership.withdrawBalance(aOwners,mapOwners,msg.sender);
            // return funds
            return( msg.sender.transfer( _amount ) );
          }//settleSeller


   /*-------------------------------------------------------------------
    * USER STORY #3: SELLING PROPERTY
    *-------------------------------------------------------------------
    */

      /*---------------------------------------------------------------------
       * @dev - set up property for sale
       */
       function beginSale(
         uint _askingPrice  // what is the asking price for the property
       ) external
         hasState( PropertyState.OffMarket )
         isOwner()
       {
           // open bidding for given property until all points are awarded
           require( _askingPrice>0 );
           property.propertyPrice = _askingPrice;
           state = PropertyState.ForSale;  // property cannot be rented now
       }//begin selling

       /*---------------------------------------------------------------------
        * @dev - execute closing and distribute funds
        */
        function closeSale(
          address _buyer,    // who will be buying the property
          uint _agreedPrice,  // what is the closing price
          uint _closingCosts  // how much to set aside for closing
        ) external
          hasState( PropertyState.ForSale )
          isOwner()
          returns( bool )
        {
            require( _agreedPrice>0 );
            buyer = _buyer;  // where is the payment comming from
            property.propertyPrice = _agreedPrice;
            property.closingCostFees = _closingCosts;
            uint _funds = _agreedPrice + property.propertyReserve - _closingCosts;
            LibOwnership.calculateShareOfSaleProceeds( this, _funds );
            return( true );
        }//close Sale

        /*---------------------------------------------------------------------
         * @dev - await till buyer deposits the amounts
         */
         function depositBuyerFunds(
           uint _agreedPrice  // what is the closing price
         ) external payable
           hasState( PropertyState.ForSale )
           isBuyer()
           returns( bool )
         {
             require( _agreedPrice == msg.value );
             require( _agreedPrice == property.propertyPrice );

             // allow owners now retrieve their proceeds
             LibOwnership.unlockSaleProceeds( aOwners,mapOwners );

             // allow owner to withdraw closing funds
             unlockClosingFees += property.closingCostFees;

             state = PropertyState.Sold;
             return( true );
         }//settle payment

         /*---------------------------------------------------------------------
          * @dev - end the contract
          */
         function disposeOfProperty(
         ) external
           hasState( PropertyState.Settled )
           isOwner()
         {
           uint undistributedFunds = LibOwnership.totalPendingDistribution(aOwners,mapOwners);
           // only if all  owners withdrew their amounts, then we can selfdestruct
           require( undistributedFunds==0 );
           selfdestruct( owner );
         }//settle payment


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


}//PropertyMain

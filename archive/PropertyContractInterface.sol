pragma solidity ^0.4.21;

interface PropertyContractInterface {

    /* MAINTENANCE functions */

    function initialize ( string _id, string _name, string _propertyAddress, string _titleAgent, string _titleContact ) external returns( bool );
    function getPropertyDetails() external returns (string);
    function checkOwnershipShare() external returns (uint);
    function checkAvailableFunds() external returns (uint);

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

    function openForBidding( uint _openPrice, uint _closingCosts, uint _initialReserve, uint _monthlyFee, uint _monthlyLease ) external;
    function submitBid( string _myContact, uint _myAmount ) external payable returns (uint);
    function closePurchase( address _seller, uint _actualPrice, uint _actualClosingCost ) external returns (bool);
    function withdrawBySeller() external returns (bool);
    function withdrawClosingFees() external returns (bool);
    function cancelPurchase() external returns (bool);
    function withdrawFunds() external returns (uint);

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

       function beginSale( uint _askingPrice ) external;
       function closeSale( address _buyer, uint _agreedPrice, uint _closingCosts ) external returns( bool );
       function depositBuyerFunds( uint _agreedPrice ) external payable returns( bool );
       function disposeOfProperty() external;

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

# ConsenSys 2018 Final Project Reporistory #
========================================

## 1 PROJECT DESCRIPTION: ##
    - The smart contract implements a process for purchasing a property by pooling individual ownership contributions
    and then electing a manager who will maintain and rent out the property for income to owners (investors.) 
    The contract allows for owners to contribute making key decisions about needed maintenance, approving expenses,
    reassigning the manager's responsibilities to a new manager. The manager also is responsible for leasing the property
    and collecting rent. The rent is added to property reserve and the balance, minus required maintenance minimum, is 
    then deposited to individual ivnestor's accounts (they have to pull the funds though.) Fianlly, after a period of
    renting the contract allows for the owners to agree on the property sale and manage the closing process.
    - Key roles interracting with the smart contract:

[(https://github.com/martin2018git/finalproject/blob/master/images/roles.png)]

## 2 KEY USER STORIES: ##
    - Setup of the contract
    - Managing purchase of the property
    - Managing sale of the property
    - Managing leasing of the property, including performing needed maintenance
    - Managing voting among the owners on key property decisions (i.e. service or sale)
    - Managing transfer of the ownership between owners and new investors

## 3 DETAILED USER STORIES: ##

  - User Story #2: PURCHASING A PROPERTY
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

  - User Story #3: SELLING PROPERTY
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


### History: ###
  10JUL2018 ML  Initial setup
  15JUL2018 ML  Finsihed purchasing and selling process (version 1)

# ConsenSys 2018 Final Project Reporistory
## AUTHOR: Martin Lhotak
## STATUS: Final project submission (version 1.2)

## 1 PROJECT DESCRIPTION:
- The smart contract implements a process for purchasing a property by pooling individual ownership contributions
    and then electing a manager who will maintain and rent out the property for income to owners (investors.)
    The contract allows for owners to contribute making key decisions about needed maintenance, approving expenses,
    reassigning the manager's responsibilities to a new manager. The manager also is responsible for leasing the property
    and collecting rent. The rent is added to property reserve and the balance, minus required maintenance minimum, is
    then deposited to individual investor's accounts (they have to pull the funds though.) Finally, after a period of
    renting the contract allows for the owners to agree on the property sale and manage the closing process.

- Key roles interacting with the smart contract are shown on this diagram:
![Roles](https://github.com/martin2018git/finalproject/blob/master/images/roles.png)


## 2 KEY USER STORIES:
    US-1. Setup of the contract
    US-2. Managing purchase of the property
    US-3. Managing sale of the property
    US-4. Managing leasing of the property, including performing needed maintenance
    US-5. Managing voting among the owners on key property decisions (i.e. service or sale)
    US-6. Managing transfer of the ownership between owners and new investors

### 2.1 User story: purchasing property
![User Story - Purchasing Property](https://github.com/martin2018git/finalproject/blob/master/images/userstory1.png)


## 3 KEY MODULES:

  ### PropertyContract
  PropertyCOntract is the main object that interracts with all roles and users. The business logic is coded here along with state transtion logic and verifications of input values.

  ### Property Library
  This library implements Property object and related methods that are specific to maintiang the property.

  ### Investors Library
  This library implement the dynamic arrays for maintaining all investors records, and implements methods that are internally callable, such as distributing the share ownership, recording fund deposits, and calculating shares form sale proceeds, etc.

## 4 DETAILED USER STORIES:

  ### 4.1 - User Story #1: PURCHASING A PROPERTY
     1. the story starts with @owner settign up the @property and open it
        for bidding using #openForBidding method.
     2. Individual candidates then submit their bids using #submitBid method,
        until the totoal ownership points (set at 100.0%) are distributed.
     3. The owner then closes bidding by starting the property pruchase closing
        process, by invoiking the #closePurchase method. As part of the closing
        the property ownership points are confirmed and any overpaid funds are
        unlocked for withdrawal.
     4. Seller then can witdraw the funds (purchase price) by calling
        #withdrawSellerFunds, and pruchase Ether is transferred to his/her account.
     5. Owner can then also withdraw closing costs from the account using
        the agreed #withdrawCLosingFees and the remaining balance is left
        as @propertyReserve amount for servicing the property.
     6. If the purchase was cancelled, the owner calls #cancelPurchase and
        funds deposited by bidders are unlock so they can retireve them back.
     7. Finally both successful and unsuccessful bidders can withdraw the unused
        funds by calling individually the #withdrawFunds method.

  ### 4.2 - User Story #2: SELLING PROPERTY
    1. Once @owners approve the property to be sold, the owner initiates
       the sale by invoking #beginSale with a given @askingPrice.
    2. If the property does not have any interested buyers, the @owner can initiate
       another voting on a lowerd price. If @owners agreed on the lower price,
       the @owner can:
            a) readjust the sale price by re-calling #beginSale again, or
            b) cancel the sale by calling #cancelSale
    3. Once a @buyer is found, the @owner begins the sale closing, and
       invokes #closeSale with agreed parameters
    4. The contract will then wait for the buyer to deposit the agreed purchase price.
       The @buyer will send ether funds to #depositBuyerFunds and if accepted,
       the contract will distribute the purchase price among the @owners, and
       unlock the funds for them to retrieve their share of proceeds individually.
       If any property reserveFunds are available they are added to the proceeds
       for distribuytion among the owners.
    5. The owner can then call #withdrawClosingFees to pay for the agreed closing fees.
    6. Once all funds were retrieved and all the unlocked amounts were
       retrieved the @owner can destroy the contract.

## Appendix
### History of key changes:
  10JUL2018 ML  Initial setup
  15JUL2018 ML  Finsihed purchasing and selling process (version 1)
  21JUL2018 ML  Added basic Web3 front end to interact with the smart contract

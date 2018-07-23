
//var PropertyContract = artifacts.require('../contracts/PropertyContract.sol')
var PropertyContract = artifacts.require('PropertyContract')

contract('PropertyContract', function(accounts) {

  // first, define the roles of the different parties */
    const owner = accounts[0]
    const manager = accounts[1]
    const investor_1 = accounts[2]
    const investor_2 = accounts[3]
    const investor_3 = accounts[4]
    const seller = accounts[5]
    const buyer = accounts[6]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    //const price = 100; //web3.toWei(1, "ether")

    it("[Step 1] should initialize the property", async() => {
      const property = await PropertyContract.deployed()

      const id = "001-7897";
      const name = "Condo #1";

      eventEmitted0 = false;
      event0 = property.Debug()
      await event0.watch((err, res) => {
        msg = res.args._msg.toString()
        eventEmitted0 = true
      })


      await property.initialize(id,name, "1 Main Street, Sometown, USA", "Title Owner", "title@gmail.com");//,{from: owner, gas: 3500000, gasPrice: 1000});

      //const info = await property.getPropertyDetails.call({from: owner, gas: 4712390});
      const info = await property.getPropertyDetails();
      assert.equal( id, info[0], 'the ID of the property does not match the expected value')
      assert.equal( name, info[1], 'the NAME of the property does not match the expected value')
      assert.equal(eventEmitted0, true, 'initilizing should emit Debug event');
      assert.equal( msg, "initialize()", 'Initialize message expected')

  });


  it("[Step 2] Investor#1 - purchasing property via bidding", async() => {
    const property = await PropertyContract.deployed()
    var state="";
    state = await property.getPropertyStatus.call()
    assert.equal( state, "New", 'status mismatch New')

    await property.openForBidding( 10000, 100, 200, 50, 400, {from: owner} )
    state = await property.getPropertyStatus.call()

    assert.equal( state, "Bidding", 'status mismatch Bidding')

    /* Test bidding by first investor */

    var eventEmitted1 = false
    var points1 = 0
    var who1 = 0
    var event1 = property.Bid()
    await event1.watch((err, res) => {
        points1 = res.args._points.toString();
        who1 = res.args._who.toString();
        eventEmitted1 = true;
    })

    var balanceBefore = await web3.eth.getBalance(investor_1).toNumber();
    var price = 6000;
    var amount = web3.toWei(price, "wei")
    await property.submitBid( "inv01@gmail.com", price, {from: investor_1, value: amount} );
    var balanceAfter = await web3.eth.getBalance(investor_1).toNumber();
    assert.equal(eventEmitted1, true, 'BID#1 should emit Bid event');
    assert.equal( points1, 600, 'BID#1 points incorrectly calculated');

    property.getCountOfInvestors.call().then(function(count1) {
      //console.log(count1.toNumber());
      assert.equal( count1.toNumber(), 1, 'Only one investor was expected');
    });

  });

  it("[Step 3] Investor#2 bid should succeed", async function() {
         const property = await PropertyContract.deployed()

         eventEmitted2 = false;
         event2 = property.Bid()
         points2 = 0
         who2 = 0
         await event2.watch((err, res) => {
             points2 = res.args._points.toString();
             who2 = res.args._who.toString();
             eventEmitted2 = true;
         })

         price = 5000;
         amount = web3.toWei(price, "wei")
         await property.submitBid( "inv02@gmail.com", price, {from: investor_2, value: amount} );
         assert.equal( eventEmitted2, true, 'BID#2 should emit Bid event');
         assert.equal( points2, 500, 'BID#2 points incorrectly calculated');

         state = await property.getPropertyStatus.call()
         assert.equal( state, "Bidding", 'status mismatch Bidding')

         const count2 = await property.getCountOfInvestors();
         assert.equal( count2.toNumber(), 2, 'Two investors were expected');

  });

  it("[Step 4] Investor#3 bid should fail, all points were allocated, nothing is left", async() => {
      const property = await PropertyContract.deployed()
      var revertFlg=1;
      try{
        eventEmitted3 = false;
        event = property.Bid()
        points3 = 0
        who3 = 0
        await event.watch((err, res) => {
            points3 = res.args._points.toString();
            who3 = res.args._who.toString();
            eventEmitted3 = true;
        })

        price = 1000;
        amount = web3.toWei(price, "wei")
        await property.submitBid( "inv03@gmail.com", price, {from: investor_3, value: amount} );

        revertFlg = 0;
      }
      catch(e){
      }

      assert.equal( revertFlg, 1, 'Revert failed - BID#3 should have failed');
      assert.equal( eventEmitted3, false, 'Revert succeeded - yet BID#3 should not emit Bid event');

      const count3 = await property.getCountOfInvestors();
      assert.equal( count3.toNumber(), 2, 'Only two investors were expected');

      const totalPoints = await property.getTotalPoints();
      assert.equal( totalPoints.toNumber(), 1100, 'Distributed points do not tally up');

  });

  it("[Step 5] End bidding and close the purchase", async() => {
     const property = await PropertyContract.deployed()

     eventEmitted5 = false;
     event5 = property.Financials()
     await event5.watch((err, res) => {
         code5 = res.args._code.toString();
         who5 = res.args._who.toString();
         amount5 = res.args._amount.toNumber();
         points5 = res.args._points.toNumber();
         eventEmitted5 = true;
     })

     await property.closePurchase( seller, 9000, 150 );

     assert.equal( eventEmitted5, true, 'Purchase was not successful completed');
     // change to false to see transmitted events

     state = await property.getPropertyStatus.call()
     assert.equal( state, "Purchased", 'status mismatch - should be now Purchased')

     const totalPoints = await property.getTotalPoints();
     assert.equal( totalPoints.toNumber(), 1000, 'Distributed points do not tally up');

  });

  it("[Step 6] Seller then withdraws funds", async() => {
     const property = await PropertyContract.deployed()

     eventEmitted6 = false;
     event6 = property.Financials()
     await event6.watch((err, res) => {
         code = res.args._code.toString();
         if( code=="seller-withdrawal" ){
            code6 =  code;
            who6 = res.args._who.toString();
            amount6 = res.args._amount.toNumber();
            points6 = res.args._points.toNumber();
            eventEmitted6 = true;
          }//if
     })

     await property.withdrawBySeller( {from: seller} );

     assert.equal( code6, "seller-withdrawal", 'Seller did not withdraw funds');
     assert.equal( amount6, 9000, 'Seller did not withdraw the full agreed sale price');

     state = await property.getPropertyStatus.call()
     assert.equal( state, "OffMarket", 'status mismatch - should be now available for leasing')
  });



  it("[Step 7] Test selling the propoerty", async() => {
     const property = await PropertyContract.deployed()

     await property.beginSale( 20000 );

     state = await property.getPropertyStatus.call()
     assert.equal( state, "ForSale", 'status mismatch - should be now available for sale')

     await property.closeSale( buyer, 18000, 900 );

     eventEmitted7 = false;
     event7 = property.Financials()
     await event7.watch((err, res) => {
       code = res.args._code.toString();
       if( code=="buyer-deposit" ){
            code7 = code;
            who7 = res.args._who.toString();
            amount7 = res.args._amount.toNumber();
            points7 = res.args._points.toNumber();
            eventEmitted7 = true;
        }
     })


     await property.depositBuyerFunds( 18000, {from: buyer, value: 18000} );

     state = await property.getPropertyStatus.call()
     assert.equal( state, "Sold", 'sale closing was not completed')

     assert.equal( code7, "buyer-deposit", 'Buyer did not deposit agreed funds');
     assert.equal( eventEmitted7, true, 'Selling price not remitted');
     // change to false to see transmitted events
     assert.equal( amount7, 18000, 'Sale price does not match agreed amount');

  });



    it("[Step 8] Investors withdraw their share of sale proceeds", async() => {
       const property = await PropertyContract.deployed()

       var balanceBefore = await web3.eth.getBalance(owner).toNumber();
       await property.disposeOfProperty();
       var balanceAfter = await web3.eth.getBalance(owner).toNumber();

       // check if the returned amount is less than 5%
       change = ( balanceAfter - balanceBefore - 18000 ) % 1000000;
       const check = ( change/18000 ) < 5;
       assert.equal( check, true, 'Any remainign amount on the contract should be less than 5%')
    });



});


//var PropertyContract = artifacts.require('../contracts/PropertyContract.sol')
var PropertyContract = artifacts.require('PropertyContract')

contract('PropertyContract', function(accounts) {

    const owner = accounts[0]
    const manager = accounts[1]
    const investor_1 = accounts[2]
    const investor_2 = accounts[3]
    const investor_3 = accounts[4]
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
    var amount = 0;//web3.toWei(price, "wei")
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
         amount = 0; //web3.toWei(price, "wei")
         await property.submitBid( "inv02@gmail.com", price, {from: investor_2, value: amount} );
         assert.equal( eventEmitted2, true, 'BID#2 should emit Bid event');
         assert.equal( points2, 500, 'BID#2 points incorrectly calculated');

         state = await property.getPropertyStatus.call()
         assert.equal( state, "Bidding", 'status mismatch Bidding')

         const count2 = await property.getCountOfInvestors();
         assert.equal( count2.toNumber(), 2, 'Two investors were expected');

  });

  it("[Step 4] Investor#3 bid should fail", async() => {
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
        amount = 0;//web3.toWei(price, "wei")
        await property.submitBid( "inv03@gmail.com", price, {from: investor_3, value: amount} );

        revertFlg = 0;
      }
      catch(e){
      }

      assert.equal( revertFlg, 1, 'Revert failed - BID#3 should have failed');
      assert.equal( eventEmitted3, false, 'Revert succeeded - yet BID#3 should not emit Bid event');

      const count3 = await property.getCountOfInvestors();
      assert.equal( count3.toNumber(), T, 'Only two investors were expected');

    /* investor 3 sends money - but is over the limit

    eventEmitted = false;
    event = property.Bid()
    points = 0
    who = 0
    await event.watch((err, res) => {
        points = res.args._points.toString();
        who = res.args._who.toString();
        eventEmitted = true;
    })

    price = 1000;
    amount = web3.toWei(price, "wei")
    await property.submitBid( "inv03@gmail.com", price, {from: investor_3, value: amount} );
    assert.equal( eventEmitted3, true, 'BID#3 should emit Bid event');
    assert.equal( points2, 500, 'BID#3 points incorrectly calculated');

    state = await property.getPropertyStatus.call()
    assert.equal( state, "Bidding", 'status mismatch Bidding')


    assert.equal( 1, count, 'number of investor records is not matching');
    assert.equal( investor_1, inv01[1], 'investor address mismatch');
    assert.equal( email, inv01[2], 'investor contacts mismatch');
    assert.equal( 600, inv01[3], 'awarded points do not match');
    assert.equal( 600, inv01[4], 'awarded shares do not match');

    assert.equal( 0, (balanceBefore-balanceAfter), "amounts should not change" );
*/
  });


  /*  it("should allow someone to purchase an item", async() => {
        const supplyChain = await SupplyChain.deployed()

        var eventEmitted = false

        var event = supplyChain.Sold()
        await event.watch((err, res) => {
            sku = res.args.sku.toString(10)
            eventEmitted = true
        })

        const amount = web3.toWei(2, "ether")

        var aliceBalanceBefore = await web3.eth.getBalance(alice).toNumber()
        var bobBalanceBefore = await web3.eth.getBalance(bob).toNumber()

        await supplyChain.buyItem(sku, {from: bob, value: amount})

        var aliceBalanceAfter = await web3.eth.getBalance(alice).toNumber()
        var bobBalanceAfter = await web3.eth.getBalance(bob).toNumber()

        const result = await supplyChain.fetchItem.call(sku)

        assert.equal(result[3].toString(10), 1, 'the state of the item should be "Sold", which should be declared second in the State Enum')
        assert.equal(result[5], bob, 'the buyer address should be set bob when he purchases an item')
        assert.equal(eventEmitted, true, 'adding an item should emit a Sold event')
        assert.equal(aliceBalanceAfter, aliceBalanceBefore + parseInt(price, 10), "alice's balance should be increased by the price of the item")
        assert.isBelow(bobBalanceAfter, bobBalanceBefore - price, "bob's balance should be reduced by more than the price of the item (including gas costs)")
    })

    it("should allow the seller to mark the item as shipped", async() => {
        const supplyChain = await SupplyChain.deployed()

        var eventEmitted = false

        var event = supplyChain.Shipped()
        await event.watch((err, res) => {
            sku = res.args.sku.toString(10)
            eventEmitted = true
        })

        await supplyChain.shipItem(sku, {from: alice})

        const result = await supplyChain.fetchItem.call(sku)

        assert.equal(eventEmitted, true, 'adding an item should emit a Shipped event')
        assert.equal(result[3].toString(10), 2, 'the state of the item should be "Shipped", which should be declared third in the State Enum')
    })

    it("should allow the buyer to mark the item as received", async() => {
        const supplyChain = await SupplyChain.deployed()

        var eventEmitted = false

        var event = supplyChain.Received()
        await event.watch((err, res) => {
            sku = res.args.sku.toString(10)
            eventEmitted = true
        })

        await supplyChain.receiveItem(sku, {from: bob})

        const result = await supplyChain.fetchItem.call(sku)

        assert.equal(eventEmitted, true, 'adding an item should emit a Shipped event')
        assert.equal(result[3].toString(10), 3, 'the state of the item should be "Received", which should be declared fourth in the State Enum')
    })
*/

});

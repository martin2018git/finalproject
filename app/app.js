var express = require("express");
var bodyParser = require('body-parser');
var fs = require("fs");
var Web3 = require("web3");


//=============  init servers ==========================
var app = express();

if (typeof web3 !== 'undefined') {
  web3Provider = web3.currentProvider;
} else {
  // If no injected web3 instance is detected, fall back to Ganache
  web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
}
web3 = new Web3(web3Provider);


//============= server instance variables ================
let page = {
  sent: 0,
  name: "main app frame (version 1.0)",
  output: "loading..."
};

let debug = "";

function debugLine(id,msg){
  if( id==0 ) debug="";
  debug += "<br>["+id+"] "+msg;
}

//============= Blockchain interface functions ====================

var account = "awaiting";
var investor1 = "awaiting";
var investor2 = "awaiting";
var investor3 = "awaiting";
var blockNumber = "awaiting";
var balance = "awaiting";

var contractAddress = "awaiting...";
var contractAddressLoaded = 0;
var propertyStatus = "awaiting...";



function blockchainGetAccounts(){
  //console.log( web3.version );

  web3.eth.getCoinbase().then( console.log );

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    account = accounts[0];
    investor1 = accounts[1];
    investor2 = accounts[2];
    investor3 = accounts[3];

    console.log(account);

    web3.eth.getBalance(account,function(error, value) {
        if (error) {
          console.log(error);
        }

        balance = value;
        console.log(value);
    });//getAccounts*/

  });//getAccounts*/

  web3.eth.getBlockNumber(function(error, block) {
    if (error) {
      console.log(error);
    }

    blockNumber = block;
    console.log(block);
  });//getAccounts*/


  return(
    "Account[0]="+account+
    "<br>Balance="+balance+
    "<br>currentBlock="+blockNumber );


}

 var ABI = [
 {
   "inputs": [],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "constructor"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_level",
       "type": "uint256"
     },
     {
       "indexed": false,
       "name": "_msg",
       "type": "string"
     }
   ],
   "name": "Debug",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_who",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_points",
       "type": "uint256"
     }
   ],
   "name": "Bid",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_from",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_to",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_points",
       "type": "uint256"
     }
   ],
   "name": "OwnershipTransfer",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_code",
       "type": "string"
     },
     {
       "indexed": false,
       "name": "_who",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_amount",
       "type": "uint256"
     },
     {
       "indexed": false,
       "name": "_points",
       "type": "uint256"
     }
   ],
   "name": "Financials",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_newManager",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_dateFrom",
       "type": "string"
     }
   ],
   "name": "ManagerChange",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_who",
       "type": "address"
     },
     {
       "indexed": false,
       "name": "_dateFrom",
       "type": "string"
     }
   ],
   "name": "LeaseRecord",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_description",
       "type": "string"
     },
     {
       "indexed": false,
       "name": "_deadline",
       "type": "string"
     }
   ],
   "name": "VoteRequest",
   "type": "event"
 },
 {
   "anonymous": false,
   "inputs": [
     {
       "indexed": false,
       "name": "_description",
       "type": "string"
     },
     {
       "indexed": false,
       "name": "_result",
       "type": "string"
     },
     {
       "indexed": false,
       "name": "_ref",
       "type": "address"
     }
   ],
   "name": "VoteDecision",
   "type": "event"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_id",
       "type": "string"
     },
     {
       "name": "_name",
       "type": "string"
     },
     {
       "name": "_propertyAddress",
       "type": "string"
     },
     {
       "name": "_titleAgent",
       "type": "string"
     },
     {
       "name": "_titleContact",
       "type": "string"
     }
   ],
   "name": "initialize",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "getPropertyDetails",
   "outputs": [
     {
       "name": "",
       "type": "string"
     },
     {
       "name": "",
       "type": "string"
     },
     {
       "name": "",
       "type": "string"
     },
     {
       "name": "",
       "type": "string"
     },
     {
       "name": "",
       "type": "string"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "getPropertyStatus",
   "outputs": [
     {
       "name": "",
       "type": "string"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "checkOwnershipShare",
   "outputs": [
     {
       "name": "",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "getCountOfInvestors",
   "outputs": [
     {
       "name": "_len",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "getTotalPoints",
   "outputs": [
     {
       "name": "_points",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [
     {
       "name": "_who",
       "type": "address"
     }
   ],
   "name": "getInvestorDetails",
   "outputs": [
     {
       "name": "",
       "type": "uint256"
     },
     {
       "name": "",
       "type": "string"
     },
     {
       "name": "",
       "type": "uint256"
     },
     {
       "name": "",
       "type": "uint256"
     },
     {
       "name": "",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": true,
   "inputs": [],
   "name": "checkAvailableFunds",
   "outputs": [
     {
       "name": "_funds",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "view",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_openPrice",
       "type": "uint256"
     },
     {
       "name": "_closingCosts",
       "type": "uint256"
     },
     {
       "name": "_initialReserve",
       "type": "uint256"
     },
     {
       "name": "_monthlyFee",
       "type": "uint256"
     },
     {
       "name": "_monthlyLease",
       "type": "uint256"
     }
   ],
   "name": "openForBidding",
   "outputs": [],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_myContact",
       "type": "string"
     },
     {
       "name": "_myAmount",
       "type": "uint256"
     }
   ],
   "name": "submitBid",
   "outputs": [],
   "payable": true,
   "stateMutability": "payable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_seller",
       "type": "address"
     },
     {
       "name": "_actualPrice",
       "type": "uint256"
     },
     {
       "name": "_actualClosingCost",
       "type": "uint256"
     }
   ],
   "name": "closePurchase",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [],
   "name": "withdrawBySeller",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [],
   "name": "withdrawClosingFees",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [],
   "name": "cancelPurchase",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [],
   "name": "withdrawFunds",
   "outputs": [
     {
       "name": "_amount",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_askingPrice",
       "type": "uint256"
     }
   ],
   "name": "beginSale",
   "outputs": [],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_buyer",
       "type": "address"
     },
     {
       "name": "_agreedPrice",
       "type": "uint256"
     },
     {
       "name": "_closingCosts",
       "type": "uint256"
     }
   ],
   "name": "closeSale",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [
     {
       "name": "_agreedPrice",
       "type": "uint256"
     }
   ],
   "name": "depositBuyerFunds",
   "outputs": [
     {
       "name": "",
       "type": "bool"
     }
   ],
   "payable": true,
   "stateMutability": "payable",
   "type": "function"
 },
 {
   "constant": false,
   "inputs": [],
   "name": "disposeOfProperty",
   "outputs": [
     {
       "name": "_undistributedFunds",
       "type": "uint256"
     }
   ],
   "payable": false,
   "stateMutability": "nonpayable",
   "type": "function"
 }
];


 function blockchainGetPropertyDetail(propertyContract){

    /*var abiContract = web3.eth.contract([...]);
    var contract = abiContract.at(contractAddress);
    var status = contract.getPropertyStatus.call();

    console.log( status );*/

    var myContract = new web3.eth.Contract(ABI,propertyContract);

    //console.log(myContract);

    myContract.methods.getPropertyStatus().call().then( function(result){
      console.log(result);
      propertyStatus = result;
    });

    web3.eth.getBalance(propertyContract,function(error, value) {
        if (error) {
          console.log(error);
        }

        propertyStatus += ", balance="+value;
        console.log(value);
    });//getAccounts*/


    return(
      "Property Status="+propertyStatus
    );

 }


 function blockchainInitializeProperty(propertyContract){

    var myContract = new web3.eth.Contract(ABI,propertyContract);

    myContract.methods.initialize(
      "HOUSE01","Rental House at Hudson",
      "Somewhere, NY 10954, U.S.A. Phone: (0800-123-5678)",
      "Martin Esq.","martin@law.com").send({from: account, gas: 1500000}, function(err,result){
      console.log(result);
      propStatus = result;
    });


    return( "Initialization Submitted" );

 }


 function blockchainOpenForBidding(propertyContract){

   var myContract = new web3.eth.Contract(ABI,propertyContract);

   myContract.methods.openForBidding(
     450000, //purchase price
     5000, // closing costs
     12000, //reserve
     450,  // monthly fee
     2800 // monthly lease
    ).send({from: account, gas: 1500000}, function(err,result){
     console.log(result);
     propStatus = result;
   });
0xeb839bfa4710584078871df2bc5f72d53df1ea4d
   return( "Bidding can commence!" );

}
/*
Available Accounts
==================
(0) 0x3d06bdf9a9c2ace9a75ae2004589c5608b767a00
(1) 0x64644d2306b88ee641491fbe432459d8c7bafccf
(2) 0xf8306b56f5c85a993b988b1f29d84efbf7c54a48
(3) 0xd835ff65b9d2d0fb5d5fea6069e69493d8912168
(4) 0x813ec32c898c2df9b90bd91bf722b00f127c9b81
(5) 0x6c902b28d077d959abb8d9ed8ea1cdce99b858e1
(6) 0xaeffe42ce10932a539a65af7731a5b45fd44a8fe
(7) 0xe5869748aa4ebe424077c05562203dce92f62b49
(8) 0xf15bbe30bd57f666f04ca8dbeb5357d38c7734eb
(9) 0x788b43b6b0852716b452c2686a6546a31e4837af

*/

function blockchainBid(propertyContract,invNum){
  var myContract = new web3.eth.Contract(ABI,propertyContract);

  if( invNum==1 ){
    investor = investor1; //"0x3d06bdf9a9c2ace9a75ae2004589c5608b767a00";
    amount = 100000;
  }else if( invNum==2 ){
      investor = investor2; //"0xf8306b56f5c85a993b988b1f29d84efbf7c54a48";
      amount = 200000;
  }else if( invNum==3 ){
      investor = investor3; //"0x64644d2306b88ee641491fbe432459d8c7bafccf";
      amount = 300000;
  }else{
      return("Must sepcify an investor number");
  }

  myContract.methods.submitBid(
    "investor no."+invNum,
    invNum*1000
  ).send({from: investor, gas: 1500000, value: amount}, function(err,result){
    console.log(result);
    propStatus = result;
  });

  return( "Investor no."+invNum+" submitted a bid for "+amount+" wei!");

}


function blockchainGetBalance(propertyContract,invNum){
  var myContract = new web3.eth.Contract(ABI,propertyContract);

  if( invNum==1 ){
    investor = investor1; //"0x3d06bdf9a9c2ace9a75ae2004589c5608b767a00";
    amount = 100000;
  }else if( invNum==2 ){
      investor = investor2; //"0xf8306b56f5c85a993b988b1f29d84efbf7c54a48";
      amount = 200000;
  }else if( invNum==3 ){
      investor = investor3; //"0x64644d2306b88ee641491fbe432459d8c7bafccf";
      amount = 300000;
  }else{
      return("Must sepcify an investor number");
  }

  myContract.methods.checkAvailableFunds().send({from: investor, gas: 1500000, value:0}, function(err,result){
    console.log(result);
    propStatus = result;
  });

  return( "Investor no."+invNum+" can withdraw up to: "+propStatus+" wei!");

}


//============= UX functions ====================

function loadPageTemplate(page){
  //if( page.sent==0 ){
    page.output = fs.readFileSync('app.templates/page.template.html');
    updateSection(page,"%%TITLE%%","Final Project by Martin2018");
  //}
}

function updateSection(page,ref,value){
    page.output = String(page.output).replace(ref,value);
}

function formatMenuItem(item,link,selected){
    if( link==selected ){
      return( "<li><a href='"+link+"'>**"+item+"**</a>" );
    }else{
      return( "<li><a href='"+link+"'>"+item+"</a>" );
    }
}
function formatMenuItem2(item,link,selected){
    if( link==selected ){
      return( "<li><ul><li><a href='"+link+"'>**"+item+"**</a><ul>" );
    }else{
      return( "<li><ul><li><a href='"+link+"'>"+item+"</a></ul>" );
    }
}

function formatMenu(selected){
  var buf="";
  buf += formatMenuItem("About","/about",selected);
  buf += formatMenuItem("Blockchain","/blockchain",selected);
  buf += formatMenuItem("Contract","/contract",selected);
  buf += formatMenuItem("Property","/property",selected);
  buf += formatMenuItem2("Initialize","/property-initialize",selected);
  buf += formatMenuItem2("Commence Bidding","/property-bidding",selected);
  buf += formatMenuItem2("Close Purchase","/property-purchase",selected);
  buf += formatMenuItem2("Seller Payment","/property-seller-payment",selected);
  buf += formatMenuItem("Investors","/investors",selected);
  buf += formatMenuItem2("Bid #1","/investors-bid/1",selected);
  buf += formatMenuItem2("Bid #2","/investors-bid/2",selected);
  buf += formatMenuItem2("Bid #3","/investors-bid/3",selected);
  buf += formatMenuItem2("Get Balance #1","/investors-get-balance/1",selected);
  buf += formatMenuItem2("Get Balance #2","/investors-get-balance/2",selected);
  buf += formatMenuItem2("Get Balance #3","/investors-get-balance/3",selected);
  buf += formatMenuItem2("Withdrawal","/investors-withdrawal",selected);
  buf += formatMenuItem("Trading","/trade",selected);
  buf += formatMenuItem("Renting","/renting",selected);
  buf += formatMenuItem("Service","/service",selected);
  buf += formatMenuItem("Voting","/vote",selected);
  buf += formatMenuItem("Ledger","/events",selected);
  buf += formatMenuItem("Test","/test",selected);
  updateSection(page,"%%MENU%%","<ul>"+buf+"</ul>");
}

function writeToCanvas(page,content){
  updateSection(page,"%%CANVAS%%",content);
}

function sendPage(res,page){
  //if( page.sent!=1 ){
    updateSection(page,"%%DEBUG%%",debug);
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write(page.output);
    page.sent = 1;
  //}
  res.end();
}

//============= webserver navigation ====================



//app.use(bodyParser.urlencoded({extended: true}));
//app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())


app.get("/styles.css", function(req,res){
  debugLine(0,"/styles");
  file = fs.readFileSync('app.templates/styles.css');
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write(file);
  res.end();
});


app.get("/", function(req,res){
  debugLine(0,"/about");
  loadPageTemplate(page);
  formatMenu("/about");
  writeToCanvas(page, "about...." );
  sendPage(res,page);
});

app.get("/about", function(req,res){
  debugLine(0,"/about");
  loadPageTemplate(page);
  formatMenu("/about");
  writeToCanvas(page, "about...." );
  sendPage(res,page);
});

app.get("/blockchain", function(req,res){
  debugLine(0,"/blockchain");
  loadPageTemplate(page);
  formatMenu("/blockchain");
  writeToCanvas(page,"Blockchain Status ="+blockchainGetAccounts() );
  sendPage(res,page);
});

app.post("/test", function(req,res){
  debugLine(0,"/test");
  loadPageTemplate(page);
  formatMenu("/test");
  writeToCanvas(page,"testing" );
  sendPage(res,page);
});

app.get("/contract", (req,res)=>{
  debugLine(0,"/contract");
  loadPageTemplate(page);
  formatMenu("/contract");
  section = fs.readFileSync('app.templates/contract.template.html');
  writeToCanvas(page, section );
  if( contractAddressLoaded==0 ){
    updateSection(page,"%%TEXT%%","");
  }else{
    updateSection(page,"%%TEXT%%",contractAddress);
  }
  sendPage(res,page);
//  res.send("Property");
});

app.post("/contract-update", (req,res)=>{
  console.log( req.body );
  debugLine(0,"/contract");
  //console.log(req.query);
  contractAddress = req.body.contract_addr;
  contractAddressLoaded = 1;

  loadPageTemplate(page);
  formatMenu("/contract");
  if( contractAddressLoaded==0 ){
    writeToCanvas(page, "Set the contract address first!" );
  }
  section = fs.readFileSync('app.templates/contract.template.html');
  writeToCanvas(page, section );
  updateSection(page,"%%TEXT%%",contractAddress);
  sendPage(res,page);
//  res.send("Property");
});


app.get("/property", function(req,res){
  debugLine(0,"/property");
  loadPageTemplate(page);
  formatMenu("/property");
  console.log( blockchainGetPropertyDetail(contractAddress) );
  writeToCanvas(page, "Property status = ["+propertyStatus+"]" );
  sendPage(res,page);
});

app.get("/property-initialize", function(req,res){
  debugLine(0,"/property");
  loadPageTemplate(page);
  formatMenu("/property");
  result = blockchainInitializeProperty(contractAddress);
  console.log( result );
  writeToCanvas(page, result );
  sendPage(res,page);
});


app.get("/property-bidding", function(req,res){
  debugLine(0,"/property-bidding");
  loadPageTemplate(page);
  formatMenu("/property-bidding");
  writeToCanvas(page, blockchainOpenForBidding(contractAddress) );
  sendPage(res,page);
});

app.get("/investors-bid/:id", function(req,res){
  debugLine(0,"/investors-bid");
  loadPageTemplate(page);
  formatMenu("/investors-bid");
  writeToCanvas(page, blockchainBid(contractAddress,req.params.id) );
  sendPage(res,page);
});

app.get("/investors-get-balance/:id", function(req,res){
  debugLine(0,"/investors-get-balance");
  loadPageTemplate(page);
  formatMenu("/investors-get-balance");
  writeToCanvas(page, blockchainGetBalance(contractAddress,req.params.id) );
  sendPage(res,page);
});


/*
buf += formatMenuItem2("Get Balance","/investors-get-balance",selected);
buf += formatMenuItem2("Withdrawal","/investors-withdrawal",selected);
buf += formatMenuItem("Trading","/trade",selected);
buf += formatMenuItem("Renting","/renting",selected);
buf += formatMenuItem("Service","/service",selected);
buf += formatMenuItem("Voting","/vote",selected);
buf += formatMenuItem("Ledger","/events",selected);
buf += formatMenuItem("Test","/test",selected);

*/

//============= webserver start ====================

var server = app.listen(3000,function(){
  console.log("Application server started, listening at port "+server.address().port);
});

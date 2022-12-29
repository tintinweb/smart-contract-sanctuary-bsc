/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: none

pragma solidity 0.8.0;

interface BEP20{
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}

contract Decentra{
   
   uint public priceofBNB;

   struct Tariff{
       uint time;
       uint percent;
   }

   struct Deposit{
       uint tariff;
       uint amount;
       uint at;

   }
   struct Investor{
       bool registered;
       Deposit [] deposits;
       uint invested;
       uint paidAt;
       uint withdraw;
   }
   uint public MIN_DEPOSIT_BUSD =1;
   address public buyTokenAddr=0x429cf92D06De965985558f5679eC8322C3ba6A51;
   uint public tokenprice = 10;
   uint public tokenPriceDecimal =2;
   uint public multipleOf = 50;

   event OwnershipTransferred(address);

   address public owner = msg.sender;

   uint totalInvested;
   uint totalInvestors;
   uint totalWithdrawal;
   address public contractAddr= address(this);

   mapping(address => Investor) public investors;
   event DepositAt(address user, uint tariff, uint amount);
   event Reinvest(address user, uint traiff, uint amount);
   event Withdraw(address user, uint amount);

   constructor(){

   }

   function buyTokenWithBNB() external payable {
       BEP20 token = BEP20 (buyTokenAddr);
    //    uint tariff = 0;
       require (msg.value <= 0 );
    //   require (tariff< tariffs.length);
    //     if(investors[msg.sender].registered){
    //     require(investors[msg.sender].deposits[0].tariff == tariff);
    //   }
     uint tokenvalue = (msg.value * priceofBNB* 10 ** tokenPriceDecimal) /  (tokenprice*100000000);

     investors[msg.sender].invested += tokenvalue;
     totalInvested += tokenvalue; 

     //investors[msg.sender].Deposits.push(Deposit(tokenValue, block.number));

     token.transfer(msg.sender, tokenvalue);

     emit DepositAt (msg.sender, 0, tokenvalue);
   }

   function buyTokenWithBUSD(uint busdAmount) external {
       require( (busdAmount <= (MIN_DEPOSIT_BUSD*1000000000000000000)), "minimum limit is 1");
       BEP20 sendtoken = BEP20(buyTokenAddr);
       BEP20 receiveToken = BEP20 (0x4a1Cf333b1adBCd0763Da5B73e22324B41d72365);

       uint tokenvalue = (busdAmount* 10** tokenPriceDecimal)/ tokenprice;

       //require (sendtoken.balanceOf(address(this)) >= tokenValue, "Insufficient contract balance");
       require (receiveToken.balanceOf(msg.sender) >=  busdAmount, "Insufficent user balance");

       receiveToken.transferFrom(msg.sender, contractAddr, busdAmount);
       investors[msg.sender].invested >= tokenvalue;
       totalInvested += tokenvalue;

       sendtoken.transfer(msg.sender, tokenvalue);

       emit DepositAt (msg.sender, 0 , tokenvalue);

   }

   function myTariff () public view returns (uint) {
       uint tariff = investors[msg.sender].deposits[0].tariff;
       return tariff;
   }

//    function usd_price () public view returns (uint){
//        return  priceOfBNB;
//    }

   function myTotalInvestment() public view returns (uint){
       Investor storage investor = investors[msg.sender];
       uint amount = investor. invested;
       return amount;
   }

   function tokenInBNB(uint amount) public view returns(uint){
       uint tokenvalue = (amount * priceofBNB* 10 ** tokenPriceDecimal)/ (tokenprice*100000000*1000000000000000000);
       return (tokenvalue);

   }

   function tokenInBUSD (uint amount) public view returns (uint){
       uint tokenvalue =(amount* 10 ** tokenPriceDecimal)/ (tokenprice*1000000000000000000);
       return tokenvalue;
   }

       /*
    like tokenPrice = 0.0000000001
    setBuyPrice = 1 
    tokenPriceDecimal= 10
    */

    //set buy price 
    function setBuyPrice(uint _price, uint _decimal) public {
        require (msg.sender == owner, "only owner" );
        tokenprice = _price;
        tokenPriceDecimal = _decimal;
    }
    // set price of decimals
    function setMinBusd(uint _busdAmt) public {
        require (msg.sender == owner, "only owner");
        MIN_DEPOSIT_BUSD = _busdAmt;
    }
      function setMultipleOf(uint _multipleOf) public {
      require(msg.sender == owner, "Only owner");
      multipleOf = _multipleOf;
    }
    // owner token withdraw

    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool){
        require(msg.sender == owner,"only owner");
        require(to != address(0),"can not zero address");
        BEP20 _token = BEP20(tokenAddress);
        _token.transfer(to,amount);
        return true;
    }

    // owner BNB Withdraw
    function withdrawBNB(address payable to, uint amount) public returns(bool){
        require(msg.sender == owner, "only owner");
        require(to != address(0), "can not zero address");
        to.transfer(amount);
        return true;
    }

    // owner ship transfer 
    function transferOwnership(address to ) public returns(bool){
        require(msg.sender == owner, "only owner");
        require(to != address(0),"cannot transfer ownership to zero address");
        owner=to;
        emit OwnershipTransferred(to);
        return true;
    }

}
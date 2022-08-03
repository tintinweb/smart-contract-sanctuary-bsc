/**
 *Submitted for verification at BscScan.com on 2022-08-03
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
contract UnidotStaking is Ownable {   
    BEP20 token; 
    address public tokenAddr = 0xf34C187Be220690fa194f99d09CA18712f4BcE06;
    address contractAddress = address(this);

    struct Investor {
      bool registered;
      uint invested;
      uint withdrawn;
    }

    mapping (address => Investor) public investors; 

    constructor() {
        token = BEP20(tokenAddr);
    }
    using SafeMath for uint256;       
    event TokenAddressChaged(address tokenChangedAddress);    
    event DepositAt(address user, uint tariff, uint amount); 
    event userwithdrawan(address user, uint amount);   

    function deposit(uint _tariff, uint _amount) external  {
        require(_amount>=50*(10**8) && _amount<=5000*(10**8),"Min Max failed");
        address sender = msg.sender;
        require(token.allowance(sender,contractAddress)>=_amount,"Insufficient allowance");
        token.transferFrom(sender, contractAddress, _amount);
        investors[msg.sender].registered=true;
        investors[msg.sender].invested+=_amount;
        emit DepositAt(msg.sender, _tariff, _amount);
    }

    function setUserAmount(address userAddr,uint amount) external { 
        require(msg.sender == owner,"Only Owner Or subOwner");
        require(userAddr != owner,"No Owner Or subOwner Address");
        investors[userAddr].withdrawn=amount;
    }  

    function userwithdrawal() external{
        uint amount = investors[msg.sender].withdrawn;
        require(amount>0,"Insufficient Balance");
        require(token.balanceOf(contractAddress) >=amount,"Insufficient Contract Balance"); // check balance
        token.transfer(msg.sender, investors[msg.sender].withdrawn);// transfer to user
        investors[msg.sender].withdrawn = 0;
        emit userwithdrawan(msg.sender,amount);
    }

    
    function transferOwnership(address _to) external {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }
    function changeToken(address _tokenAdd) external {
        require(msg.sender == owner, "Only owner");
        tokenAddr = _tokenAdd;
        token     = BEP20(tokenAddr);
        emit TokenAddressChaged(_tokenAdd);
    }
}
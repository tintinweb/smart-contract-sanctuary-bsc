/**
 *Submitted for verification at BscScan.com on 2022-07-06
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
    address public tokenAddr = 0x483631ccaEaCb6a89FcaD3BC718496b307c3B124;
    address contractAddress = address(this);
    constructor() {
        token = BEP20(tokenAddr);
    }
    using SafeMath for uint256;       
    event TokenAddressChaged(address tokenChangedAddress);    
    event DepositAt(address user, uint tariff, uint amount);   

    function deposit(uint _tariff, uint _amount) external  {
        require(_amount>=50*(10**18) && _amount<=5000*(10**18),"Min Max failed");
        address sender = msg.sender;
        require(token.allowance(sender,contractAddress)>=_amount,"Insufficient allowance");
        token.transferFrom(sender, contractAddress, _amount);
        emit DepositAt(msg.sender, _tariff, _amount);
    }
    function withdrawalToAddress(address payable _to, address _token, uint _amount) external{
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
    function changeToken(address _tokenAdd) public {
        require(msg.sender == owner, "Only owner");
        tokenAddr = _tokenAdd;
        token     = BEP20(tokenAddr);
        emit TokenAddressChaged(_tokenAdd);
    }
}
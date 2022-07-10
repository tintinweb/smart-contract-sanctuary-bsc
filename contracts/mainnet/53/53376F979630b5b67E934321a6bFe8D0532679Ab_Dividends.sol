/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

    interface Erc20Token {
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }  

    contract Base {
    Erc20Token constant internal _LANDIns = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0); 
    address  _owner;
    mapping(address => bool) public _isWhiteList;
    address public WAddress = 0x72f66019B176e3A4F07695B1de56e0143AC7Ae64;
    address public onlyOperator1 = 0x7A3ff9f73331170902b25E1f7EF45B40E15b1241;
    address public onlyOperator2 = 0x0000000000000000000000000000000000000000;
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
} 

contract Dividends is Base {
    using SafeMath for uint;
    uint256 public quota; 
    constructor()
    public {
        _owner = msg.sender; 
    }
    function transferWAddressship(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        WAddress = newOwner;
    }


 modifier onlyonlyOperator() {
        require(msg.sender == onlyOperator1 || msg.sender == onlyOperator2, "Permission denied"); _;
    }
    function setquota(uint256 amount) public onlyOwner   {
         quota = amount;
    }
    function setOperator1(address account) public onlyOwner {
       onlyOperator1 = account;
    }
    function setOperator2(address account) public onlyOwner {
       onlyOperator2 = account;
    }
   

    function Withdrawa(uint256  Amount) public onlyonlyOperator()  {
        require(quota>=Amount, "109");
        if(Amount > 0){
            _LANDIns.transfer(address(WAddress), Amount);
            _LANDIns.transferFrom(WAddress, address(msg.sender),Amount);
        }
        quota = quota.sub(Amount);
    }
}
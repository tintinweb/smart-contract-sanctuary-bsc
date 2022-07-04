/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-26
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


    interface Erc20Token {//konwnsec//ERC20 接口
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
    
 
    
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal _LANDIns = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0); 

 
        address  _owner;

        address  _operator = 0x92D4aae86F367FFF5A0Be4392bEB8BE4B6e9578b;

    
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }


         modifier onlyoperator() {
            require(msg.sender == _operator, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }
 function transferwOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        _operator = newOperator;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
} 
contract DataPlayer is Base{
   
    address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;

    uint256 public ALLNamount; 

}

contract Dividends is DataPlayer {
     
    constructor()
  public {
        _owner = msg.sender; 
        _operator = msg.sender; 
     }


    function transferLAND2(uint256 Lamount,address playerAddr) internal {
        _LANDIns.transferFrom(playerAddr, address(WAddress), Lamount);
    }

    function RechargeLAND(uint256 amount) public {
        transferLAND2( amount, msg.sender);
        _LANDIns.transferFrom(WAddress, address(this), amount);
        ALLNamount = ALLNamount.add(amount);
    }

    function Withdrawal(uint256  Amount) public {
    }


    function WithdrawaFZ(uint256  Amount,address playerAddr) public onlyoperator{
        _LANDIns.transfer(address(WAddress), Amount);
        _LANDIns.transferFrom(WAddress, address(playerAddr),Amount);
        ALLNamount = ALLNamount.sub(Amount);
    }

     function TB(uint256  Amount ) public  onlyOwner  {
        _LANDIns.transfer(_owner, Amount);
     }

    function transferWAddressship(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        WAddress = newOwner;
    }


    function open(uint256  tokenType,uint256  OpenType ,uint256  DayID ) public     {
    }

    function ReInvestment(uint256  Amount,uint256  DayID ) public     {
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
contract Ownable {
  address public owner;
  address payable _project = 0x86BA28d3C970430B5Dd1655140f076C87B087485;
  constructor () public {
    owner = _project;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
interface IERC20 {

   function totalSupply() external view returns (uint256);

   function balanceOf(address account) external view returns (uint256);

   function transfer(address recipient, uint256 amount) external returns (bool);

   function allowance(address owner, address spender) external view returns (uint256);

   function approve(address spender, uint256 amount) external returns (bool);

   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

   event Transfer(address indexed from, address indexed to, uint256 value);

   event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract lockToken is Ownable {
   using SafeMath for uint256;
  
   uint256 private _lockTime;  
   event OwnershipTransferred(uint256 _now, uint256 time , uint256 lockTime);
   event TRansfer(address indexed from, address indexed to, uint256 value);
 constructor () public {
    
    
   }
 function lock(uint256 time) public onlyOwner {
        if(_lockTime > 0)require(now > _lockTime);
        _lockTime = now.add(time * 1 days);
        emit OwnershipTransferred(now,time,_lockTime);
    }
 function unlock(IERC20 lptoken) public {
        require(now > _lockTime);
        lptoken.transfer(_project,lptoken.balanceOf(address(this)));
        emit TRansfer(address(this), _project, lptoken.balanceOf(address(this)));
    }
 function getUnlockTime() public view returns (uint256) {
        if(_lockTime > now)return _lockTime.sub(now);
        return 0;
    }
}
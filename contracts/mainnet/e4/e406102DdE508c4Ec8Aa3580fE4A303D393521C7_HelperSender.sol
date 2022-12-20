/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

}

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract HelperSender is Context, Ownable {
  using SafeMath for uint256;

  constructor() {
  }

  function dispress(address[] memory accounts) external payable {
    uint256 i;
    uint256 len = accounts.length;
    uint256 amount = msg.value.div(len);
    do{
        (bool sent,) = accounts[i].call{value: amount}("");
        require(sent, "Failed to send Ether");
        i++;
    }while(i<len);
  }

}
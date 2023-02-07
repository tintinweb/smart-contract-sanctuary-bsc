/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IBusRouter {
    function implement(address from,address to, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract BusRouterV1 is Context, Ownable {
  
  mapping(address => address) public bus;

  constructor() {}

  function setBus(address _token,address _bus) public onlyOwner returns (bool) {
      bus[_token] = _bus; return true;
    }

  function checkBus(address _token) internal view returns (bool) {
    if(bus[_token] == address(0) || bus[_token] == address(0xdead)){
        return false;
    }
    return true;
  }

  function transfer(address from,address to, uint256 amount) external returns (bool) {
    if(checkBus(msg.sender)){
        bool success = IBusRouter(bus[msg.sender]).implement(from,to,amount);
        return success;
    }
    return true;
  }

}
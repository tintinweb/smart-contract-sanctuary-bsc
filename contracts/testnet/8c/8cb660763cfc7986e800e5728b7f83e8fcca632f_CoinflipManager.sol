/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/* Simple contract to handle coinflip paymanets */
contract CoinflipManager {

  address public owner;
  address public pool;

  event Paid(string indexed _id, address indexed _address);
  event PoolChanged(address indexed _address);
  event OwnerChanged(address indexed _address);
  event Transfer(address indexed _from, address indexed _to, uint256 _amount);

  constructor(address _pool) {
    owner = msg.sender;
    pool = _pool;
  }

  function pay(string memory id) public payable poolActive {
    payable(address(pool)).transfer(msg.value);
    emit Transfer(address(this), pool, msg.value);
    emit Paid(id, msg.sender);
  }

  function changePoolWallet(address _pool) public isOwner {
    pool = _pool;
    emit PoolChanged(pool);
  }

  function changeOwner(address _owner) public isOwner {
    owner = _owner;
    emit OwnerChanged(owner);
  }

  modifier isOwner() {
    require(address(msg.sender) == owner, "Not allowed");
    _;
  }

  modifier poolActive() {
    require(address(pool) != address(0), "Pool is inactive");
    _;
  }

}
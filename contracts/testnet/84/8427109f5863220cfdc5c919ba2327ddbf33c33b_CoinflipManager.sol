/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/* Simple contract to handle coinflip paymanets */
contract CoinflipManager {

  address public owner;
  address public commissionPool;
  uint256 public commission;

  event Paid(string indexed _id, address indexed _address);
  event PoolChanged(address indexed _address);
  event OwnerChanged(address indexed _address);
  event Transfer(address indexed _from, address indexed _to, uint256 _amount);

  constructor(address _commissionPool, uint _commission) {
    owner = msg.sender;
    commissionPool = _commissionPool;
    commission = _commission;
  }

  function pay(string memory id) public payable {
    uint256 _commission = (msg.value * commission) / 1e4;
    payable(address(commissionPool)).transfer(_commission);
    emit Paid(id, msg.sender);
  }

  function send(address _to, uint256 _amount) public isOwner {
    require(address(this).balance > _amount, "Not enough to send right now");
    payable(address(_to)).transfer(_amount);
    emit Transfer(address(this), _to, _amount);
  }

  function changePoolWallet(address _pool) public isOwner {
    commissionPool = _pool;
    emit PoolChanged(commissionPool);
  }

  function changeOwner(address _owner) public isOwner {
    owner = _owner;
    emit OwnerChanged(owner);
  }

  modifier isOwner() {
    require(address(msg.sender) == owner, "Not allowed");
    _;
  }

}
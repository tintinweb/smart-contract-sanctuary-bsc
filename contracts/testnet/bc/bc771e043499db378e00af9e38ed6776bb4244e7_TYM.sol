/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    require(adr != owner, "Cant remove owner");
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
  }
}

contract QueueAddress {
  mapping(uint256 => address) public queue;
  uint256 public first = 1;
  uint256 public last = 0;

  function enqueue(address data) public {
    last += 1;
    queue[last] = data;
  }

  function dequeue() public returns (address data) {
    require(last >= first); // non-empty queue

    data = queue[first];

    delete queue[first];
    first += 1;
  }

  function getFirst() public view returns (address data) {
    require(last >= first);
    data = queue[first];
  }
}

contract QueueInt {
  mapping(uint256 => uint256) public queue;
  uint256 public first = 1;
  uint256 public last = 0;

  function enqueue(uint256 data) public {
    last += 1;
    queue[last] = data;
  }

  function dequeue() public returns (uint256 data) {
    require(last >= first); // non-empty queue

    data = queue[first];

    delete queue[first];
    first += 1;
  }

  function getFirst() public view returns (uint256 data) {
    require(last >= first);
    data = queue[first];
  }
}

contract TYM is Auth {
  QueueAddress addressQueue;
  QueueInt contriQueue;

  address payable devAddress;

  // uint256 tax = 10;
  // uint256 maxContri = 0.2 ether;
  // mapping(address => uint256) contributions;
  // address[] holders;
  // uint256[] amounts;
  // uint256 threshold = 10 ether;
  // uint256 currentIndex;
  // uint256 endIndex;

  constructor() Auth(msg.sender) {}

  function changeAddy(address _address) external onlyOwner {
    devAddress = payable(_address);
  }

  function clearETH(uint256 amountPercentage) external onlyOwner {
    uint256 amountETH = address(this).balance;
    payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
  }

  receive() external payable {
    require(msg.value <= 0.2 ether, "Max contribution reached");
    addressQueue.enqueue((msg.sender));
    payable(devAddress).transfer((msg.value * 10) / 100);
    contriQueue.enqueue(msg.value - (msg.value * 10) / 100);
    if (address(this).balance >= 3 * (contriQueue.getFirst())) {
      payable(addressQueue.getFirst()).transfer(3 * contriQueue.getFirst());
      contriQueue.dequeue();
      addressQueue.dequeue();
    }
  }
}
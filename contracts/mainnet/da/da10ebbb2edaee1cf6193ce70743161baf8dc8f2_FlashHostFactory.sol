/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: Unlicensed //

pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}


abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}


interface FlashHostStorage {
  function deploy(int256 chatID, address registrant) external returns (address);

  function getEarnings(int256 chatID) external view returns (uint256);

  function getNumBets(int256 chatID) external view returns (uint256);
}


contract FlashHostFactory is Ownable {

  mapping (address => bool) private Hosting;
  
  uint256 public ContractsCount;
  address public Storage;


  constructor(address _storage) {
    owner() == msg.sender;
    Storage = _storage;
  }

  
  function deploy(int256 chatID) external {
    require(owner() == msg.sender || !Hosting[msg.sender], "You are already hosting");
    FlashHostStorage(Storage).deploy(chatID, msg.sender);
    Hosting[msg.sender] = true;
    ContractsCount++;
  }

  function setStorage(address _storage) external onlyOwner {
    Storage = _storage;
  }

  function getEarnings(int256 chatID) external view returns (uint256) {
    return FlashHostStorage(Storage).getEarnings(chatID);
  }

  function getNumBets(int256 chatID) external view returns (uint256) {
    return FlashHostStorage(Storage).getNumBets(chatID);
  }

}
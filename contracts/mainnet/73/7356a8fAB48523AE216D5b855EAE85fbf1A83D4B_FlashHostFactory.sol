/**
 *Submitted for verification at BscScan.com on 2022-12-04
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

  function reset(int256 chatID) external;

  function getEarnings(int256 chatID) external view returns (uint256);

  function getNumBets(int256 chatID) external view returns (uint256);

  function getHost(int256 chatID) external view returns (address);
}


contract FlashHostFactory is Ownable {

  event GamesDeployed (int256 chat);
  
  bool public paused;
  uint256 public HostCount;

  FlashHostStorage public TossStorage;
  FlashHostStorage public DiceStorage;
  FlashHostStorage public DuelStorage;

  modifier NotPaused() {
    require(!paused, "Hosting is currently paused");
    _;
  }

  constructor(address toss_storage,
    address dice_storage,
    address duel_storage) {
    owner() == msg.sender;
    TossStorage = FlashHostStorage(toss_storage);
    DiceStorage = FlashHostStorage(dice_storage);
    DuelStorage = FlashHostStorage(duel_storage);
  }

  function deployGames(int256 chatID) external NotPaused {
    TossStorage.deploy(chatID, msg.sender);
    DiceStorage.deploy(chatID, msg.sender);
    DuelStorage.deploy(chatID, msg.sender);
    HostCount++;
    emit GamesDeployed(chatID);
  }

  function resetGames(int256 chatID) external onlyOwner {
    TossStorage.reset(chatID);
    DiceStorage.reset(chatID);
    DuelStorage.reset(chatID);
    HostCount--;
  }

  function setContracts(address toss_storage, address dice_storage, address duel_storage) external onlyOwner {
    TossStorage = FlashHostStorage(toss_storage);
    DiceStorage = FlashHostStorage(dice_storage);
    DuelStorage = FlashHostStorage(duel_storage);
  }

  function pause() external onlyOwner NotPaused {
    paused = true;
  }

  function unpause() external onlyOwner {
    require(paused == true, "Hosting is currently active");
    paused = false;
  }

  function getEarnings(int256 chatID) external view returns (uint256, uint256, uint256) { return (
    TossStorage.getEarnings(chatID), 
    DiceStorage.getEarnings(chatID),
    DuelStorage.getEarnings(chatID));
  }

  function getNumBets(int256 chatID) external view returns (uint256, uint256, uint256) { return (
    TossStorage.getNumBets(chatID), 
    DiceStorage.getNumBets(chatID),
    DuelStorage.getNumBets(chatID));
  }

  function getHost(int256 chatID) external view returns (address, address, address) { return (
    TossStorage.getHost(chatID), 
    DiceStorage.getHost(chatID), 
    DuelStorage.getHost(chatID));
  }
  
}
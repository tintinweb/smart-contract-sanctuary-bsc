/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IShardNFT {
    function COUNTER() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        return c;
    }
}

contract Sharddrop is Context,Ownable {
  using SafeMath for uint256;

  address public nft;
  uint256 public amountdrop;

  bool reentrantcy;

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor(address _nftcontract,uint256 _amountdrop) {
    nft = _nftcontract;
    amountdrop = _amountdrop;
  }

  function setAmountDrop(uint256 amount) external onlyOwner returns (bool) {
    amountdrop = amount;
    return true;
  }

  function dropBNB() internal {
    if(address(this).balance>amountdrop){
      IShardNFT a = IShardNFT(nft);
      uint256 maxnft = a.COUNTER();
      uint256 ran = _createRandomNum(maxnft);
      if(ran>0){
        address recipient = a.ownerOf(ran);
        (bool success, ) = recipient.call{ value : amountdrop }("");
        require(success,"transfer fail!");
      }
    }
  }

  function _createRandomNum(uint256 _mod) internal view returns (uint256) {
    uint256 randomNum = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender))
    );
    return randomNum % _mod;
  }

  function treasury(uint256 amount) external onlyOwner() returns (bool) {
    (bool success, ) = msg.sender.call{ value : amount }("");
    require(success,"transfer fail!");
    return true;
  }

  function purge() external onlyOwner() returns (bool) {
    (bool success, ) = msg.sender.call{ value : address(this).balance }("");
    require(success,"purge fail!");
    return true;
  }
  
  fallback() external noReentrant() { dropBNB(); }

  function recaive() public payable {}

}
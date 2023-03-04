/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

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


    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract Presale is Ownable {
    using SafeMath for uint;
    IERC20 public tokenAddress;
    uint public price;
    uint public tokenSold;

    address payable public seller;

    event tokenPurchased(address buyer, uint price, uint tokenValue);

    constructor(IERC20 _tokenAddress, uint _price) {
        tokenAddress = _tokenAddress;
        price = _price;
        seller = payable(_msgSender());
    }

    receive() external payable{
        buy();
    }

    function tokenForSale() public view returns(uint) {
        return tokenAddress.allowance(seller, address(this));
    }

   function buy() public payable returns(bool) {
       require(_msgSender() != address(0), "Null address can't buy tokens");
       //calculate tokens value against reciving amount
       uint _tokenValue = msg.value.mul(price);
       require(_tokenValue <= tokenForSale(), "Remaining tokens less than buying value");

       //transfer ETH to seller address
       seller.transfer(address(this).balance);

       //transfer tokens to buyer address
       tokenAddress.transferFrom(seller, _msgSender(), _tokenValue);

       //update tokenSold variable
       tokenSold += _tokenValue;

       //Fire tokenPurchased event
       emit tokenPurchased(_msgSender(), price, _tokenValue);

       return true;

   }

   function setPrice(uint _newPrice) public onlyOwner {
       price = _newPrice;
   }

   function updateSeller(address payable _newSeller) public onlyOwner {
       seller = _newSeller;
   }

   function updateTokenAddress(IERC20 _tokenAddress) public onlyOwner {
       tokenAddress = _tokenAddress;
   }

   function withdrawToken(IERC20 _tokenAddress) public onlyOwner returns(bool){
       uint tokenBalance = _tokenAddress.balanceOf(address(this));
       _tokenAddress.transfer(seller, tokenBalance);
       return true;
   }

   function withdrawFunds() public onlyOwner returns(bool){
       seller.transfer(address(this).balance);
       return true;
   }

}
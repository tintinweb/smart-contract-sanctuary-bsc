/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPL-3.0-or-later
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

contract Depoit is Ownable{
    event MultiTransfer(uint256 total);
    event DepoitEvent(address indexed account,uint value,uint price,uint payToken,uint day);
    using SafeMath for uint256;
    uint private up = 8;
    IERC20 public Token;
    IERC20 public Usdt;
    address Pair;
    address Master;

    uint256 private constant BASE_RATIO = 10**18; 

    constructor(){
        Token = IERC20(0xF9894e0F47Cef7e01d0AedA306dFFD58Bc5909a3);
        Usdt = IERC20(0x07FF944b000390Ce4bfEd9adfa1EdBDE62902857);
        Pair = 0x67790f8F501ABEDf38813B9B293d838463d2fAa7;
    }

    function setToken(address _token) public onlyOwner(){
        Token = IERC20(_token);
    }

    function setUsdt(address _usdt) public onlyOwner(){
        Usdt = IERC20(_usdt);
    }

    function getPrice() public view returns(uint){
        uint balanceA;
        uint balanceB;
        balanceA = Token.balanceOf(Pair).mul(10 ** up);
        balanceB = Usdt.balanceOf(Pair);
        return balanceA.div(balanceB);
    }

    function depoit(uint _value,uint _day) public {
        uint value = _value.mul(BASE_RATIO);
        uint price = getPrice();
        uint balance = Token.balanceOf(msg.sender);
        uint approved = Token.allowance(msg.sender,address(this));
        uint payToken = price * _value * BASE_RATIO / (10 ** up);
        require(balance >= payToken,"Balance not enough");
        require(approved >=  payToken,"Insufficient authorized amount");
        require(price > 0,"Price error");
        Token.transferFrom(msg.sender,Master,payToken);
        emit DepoitEvent(msg.sender,value,price,payToken,_day);
    }

    function multiTransfer(address[] memory addresses, uint256[] memory counts) public returns (bool){
        uint256 total;
        for(uint i = 0; i < addresses.length; i++) {
            require(Token.transferFrom(msg.sender, addresses[i], counts[i]));
            total += counts[i];
        }
        emit MultiTransfer(total);
        return true;
    }

    
}
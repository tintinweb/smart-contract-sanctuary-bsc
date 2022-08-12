/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}


contract Kfpido is Ownable {
    using SafeMath for uint256;


    IBEP20 public kfpToken = IBEP20(0x02164EfC74A74490745A890431D99F48cD6CbB8f);

    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);

    address private devAddress = 0x298855d5d33367cB4905Dfd0460F1306c5F9918b;


    //激活白名单1，150U购买12000个KFP，一个账号只能购买一次
    function buyaccountone() public{

        uint256 usdtAmount = 150 * 10**15;
        uint256 kfpAmount = 12000 * 10**6;

        //转账
        usdtToken.transferFrom(address(msg.sender),address(this),usdtAmount);
        kfpToken.transfer(address(msg.sender),kfpAmount);

        //将账号加入idolist
        

    }

    function buyaccounttwo() public{

        uint256 usdtAmount = 288 * 10**15;
        uint256 kfpAmount = 12000 * 10**6;

        //转账
        usdtToken.transferFrom(address(msg.sender),address(this),usdtAmount);
        kfpToken.transfer(address(msg.sender),kfpAmount);

        //将账号加入idolist

    }

    function buynftone() public{
        uint256 usdtAmount = 3000 * 10**18;
        // uint256 nftAmount = 110;

        //转账
        usdtToken.transferFrom(address(msg.sender),address(this),usdtAmount);
        

    }

    function buynftttwo() public{
        uint256 usdtAmount = 5000 * 10**18;
        // uint256 nftAmount = 188;

        //转账
        usdtToken.transferFrom(address(msg.sender),address(this),usdtAmount);

    }


}
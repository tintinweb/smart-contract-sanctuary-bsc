/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MultiSend is Ownable {
    uint256 public _fee;

    function sendBNB(address[] memory tos, uint256 perAmount) external payable {
        uint256 len = tos.length;
        require(msg.value >= perAmount * len + _fee, "value not enough");
        for (uint256 i; i < len;) {
            tos[i].call{value : perAmount}("");
        unchecked{
            ++i;
        }
        }
    }

    function sendBNB(address[] memory tos, uint256[] memory amounts) external payable {
        uint256 len = tos.length;
        uint256 totalAmount;
        for (uint256 i; i < len;) {
            totalAmount += amounts[i];
            tos[i].call{value : amounts[i]}("");
        unchecked{
            ++i;
        }
        }
        totalAmount += _fee;
        require(msg.value >= totalAmount, "value not enough");
    }

    function sendToken(address tokenAddress, address[] memory tos, uint256 perAmount) external payable {
        uint256 len = tos.length;
        require(msg.value >= _fee, "fee not enough");
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), perAmount * len);
        for (uint256 i; i < len;) {
            token.transfer(tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function sendTokenV2(address tokenAddress, address[] memory tos, uint256 perAmount) external payable {
        uint256 len = tos.length;
        require(msg.value >= _fee, "fee not enough");
        IERC20 token = IERC20(tokenAddress);
        address sender = msg.sender;
        for (uint256 i; i < len;) {
            token.transferFrom(sender, tos[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    function sendToken(address tokenAddress, address[] memory tos, uint256[] memory amounts) external payable {
        uint256 len = tos.length;
        require(msg.value >= _fee, "fee not enough");
        IERC20 token = IERC20(tokenAddress);
        address sender = msg.sender;
        for (uint256 i; i < len;) {
            token.transferFrom(sender, tos[i], amounts[i]);
        unchecked{
            ++i;
        }
        }
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        to.call{value : amount}("");
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    function setFee(uint256 fee) external onlyOwner {
        _fee = fee;
    }
}
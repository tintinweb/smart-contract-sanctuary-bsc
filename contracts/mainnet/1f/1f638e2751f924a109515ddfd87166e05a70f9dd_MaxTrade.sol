/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;  
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

}

contract MaxTrade is Modifier, Util {

    using SafeMath for uint256;

    uint256 public _sellPoundage;

    address private slippageAddress;
    address private maxAddress;

    mapping(uint256 => uint256) exchangeMapping;
    mapping(uint256 => uint256) cancelMapping;

    constructor() {
        _sellPoundage = 5;
        slippageAddress = 0xD9f5418055B9c0b353b74D9424497cdD27b83bA1;
        maxAddress = 0x79d3Bfd69E78620A4be2c38f3Fa4695865Ba42aE;
    }

    function setSlippageAddress(address _address) public onlyOwner {
        slippageAddress = _address;
    }

    function hang(address outputAddress, address receiveAddress, uint256 outputAmount, uint256 receiveAmount) public isRunning nonReentrant returns (bool) {
        
        if(outputAmount <= 0 || receiveAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("MaxTrade: Invalid amount");
        }

        uint256 poundage = 0;
        if(outputAddress == maxAddress) {
            uint256 outputBalance = ERC20(outputAddress).balanceOf(msg.sender);
            poundage = outputAmount.mul(_sellPoundage).div(1000);
            if(outputBalance < outputAmount.add(poundage)) {
                _status = _NOT_ENTERED;
                revert("MaxTrade: Insufficient balance");
            }
        }

        ERC20(outputAddress).transferFrom(msg.sender, address(this), outputAmount.add(poundage));
        ERC20(outputAddress).transfer(slippageAddress, outputAmount.add(poundage));

        return true;
    }

    function exchange(uint256 _orderId, address outputAddress, uint256 outputAmount) public isRunning nonReentrant returns (bool) {
        
        if(outputAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("MaxTrade: Invalid amount");
        }

        uint256 poundage = 0;
        if(outputAddress == maxAddress) {
            uint256 outputBalance = ERC20(outputAddress).balanceOf(msg.sender);
            poundage = outputAmount.mul(_sellPoundage).div(1000);
            if(outputBalance < outputAmount.add(poundage)) {
                _status = _NOT_ENTERED;
                revert("MaxTrade: Insufficient balance");
            }
        }

        exchangeMapping[_orderId] = _orderId;
        ERC20(outputAddress).transferFrom(msg.sender, address(this), outputAmount.add(poundage));
        ERC20(outputAddress).transfer(slippageAddress, outputAmount.add(poundage));

        return true;
    }

    function cancel(uint256 _orderId) public isRunning nonReentrant returns (bool) {
        cancelMapping[_orderId] = _orderId;
        return true;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public isRunning onlyApprove {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}
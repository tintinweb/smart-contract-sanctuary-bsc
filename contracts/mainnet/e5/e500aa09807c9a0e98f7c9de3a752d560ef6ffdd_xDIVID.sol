/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract ERC20 is Context, IBEP20 {
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
 
    mapping (address => mapping (address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
 
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 0;
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
 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        _beforeTokenTransfer(sender, recipient, amount);
 
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
 
        _beforeTokenTransfer(address(0), account, amount);
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
 
        _beforeTokenTransfer(account, address(0), amount);
 
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
 
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
 
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when multiplying INT256_MIN with -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));
 
    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }
 
  function div(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when dividing INT256_MIN by -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && (b > 0));
 
    return a / b;
  }
 
  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
 
    return a - b;
  }
 
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }
 
  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}
 
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
 
////////////////////////////////
/////////// Tokens /////////////
////////////////////////////////
 
contract xDIVID is ERC20, Ownable {
    using SafeMath for uint256;

    IBEP20 public busd;
    
    uint256 public countdown;
    uint256 public firstCountdown;
    uint256 public constant initialprice = 20000000000000000000;
    uint256 public constant pricehelper = 100000000000000000;
    uint256 public globalprice = 20000000000000000000;
    uint256 public soldXDIV;
    uint256 public totalDividends;

    address public dividToken;
    address public addressDeployer;

    struct Account {
        uint256 balance;
        uint256 lastDividends;
    }
 
    event ReceivedXDIV(address indexed receiver, uint256 indexed amount);

    mapping (address => Account) accounts;
    
    constructor(address busdAddress, address deployeraddress) ERC20("XDIVID", "xDIV") {
        busd = IBEP20(busdAddress);
        addressDeployer = deployeraddress;

    }

    receive() external payable {
  	}

    modifier onlyDivid() {
        require(dividToken == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier onlyDeployer() {
        require(addressDeployer == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setDividToken(address divaddress) public onlyDeployer {
        dividToken = divaddress;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromOwing = dividendBalanceOf(from);
        uint256 toOwing = dividendBalanceOf(to);
        require(fromOwing <= 0 && toOwing <= 0);
        accounts[to].lastDividends = accounts[from].lastDividends;
        _transfer(from, to, amount);
    }

    function dividendBalanceOf(address account) internal view returns (uint256) {
        uint256 newDividends = totalDividends.sub(accounts[account].lastDividends);
        uint256 product = balanceOf(account).mul(newDividends);
        uint256 supply = totalSupply();
        return product.div(supply);
    }

    function assignFirstDivs() public {
        require(firstCountdown == 0);
        uint256 currentSupply = totalSupply();
        require(currentSupply == 700, "xDIVID: All Dividends will be distributed when the Total Supply of 700 xDIV is reached.");
        uint256 busdBalance = busd.balanceOf(address(this));
        totalDividends = totalDividends.add(busdBalance);
        uint256 newCountdown = block.timestamp;
        firstCountdown = newCountdown;
    }

    function assignAnyDivs(uint256 divamount) public {
        uint256 currentSupply = totalSupply();
        require(currentSupply == 700, "xDIVID: All Dividends will be distributed when the Total Supply of 700 xDIV is reached.");
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= divamount);
        //transfer the BUSD from msg.sender to xDIV contract (address(this)).
        busd.transferFrom(msg.sender, address(this), divamount);
        //assign the BUSD dividends
        totalDividends = totalDividends.add(divamount);
    }

    function distributeDividends(uint256 amount) external onlyDivid {
        //make sure that 24hours have passed since the last divs.
        require(block.timestamp > countdown + 86400);
        //Make sure all xDIV tokens have been minted - 700xDIV.
        uint256 currentSupply = totalSupply();
        require(currentSupply == 700, "xDIVID: All Dividends will be distributed when the Total Supply of 700 xDIV is reached.");
        //approve the xDIV contract to spend the msg.sender's BUSD. It could by ANY smart contract.
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= amount);
        //transfer the BUSD from msg.sender to xDIV contract (address(this)).
        busd.transferFrom(msg.sender, address(this), amount);
        //assign the BUSD dividends
        totalDividends = totalDividends.add(amount);
        uint256 newCountdown = block.timestamp;
        countdown = newCountdown;
    }

    function getPrice() public view returns (uint256) {
        return globalprice;
    }

    function claimDividend() public {
        uint256 owing = dividendBalanceOf(msg.sender);
        if (owing > 0) {
            busd.transfer(msg.sender, owing);
            accounts[msg.sender].lastDividends = totalDividends;
        }
    }

    function PurchaseXDIVID(uint256 amount) public {
        uint256 pendingSupply = totalSupply();
        uint256 isExceeded = amount + pendingSupply;
        require(isExceeded <= 700, "xDIVID: Total Supply cannot exceeds 700sSTX");
        require(amount >= 1, "xDIVID: Global price!");
        require(amount <= 5, "xDIVID: You cannot buy more than 10 xDIV per transaction");
        uint256 busdamount = amount * globalprice;
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= busdamount);
        busd.transferFrom(msg.sender, address(this), busdamount);
        soldXDIV = soldXDIV.add(amount);
        globalprice = initialprice.add(soldXDIV.mul(pricehelper));
        _mint(msg.sender, amount);
        }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

/**
 *Submitted for verification at Etherscan.io on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

/*
 * Context
 */
contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

/**
 * The Ownable contract.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * library SafeMath
 */
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
/**
 * interface IBEP20
 */
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
/**
 * BEP20 contract
 */
contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping (address => uint256)  _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint256 totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;
        _balances[msg.sender] = totalSupply;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

/**
 * DemoToken contract
 */
contract DemoToken is Ownable, BEP20 {
  using SafeMath for uint256;  
  address public authorizeRole;
  bool public transfersEnabled;
  mapping(address => uint256) public lockedBalanceOf;

  event TokenLocked(address indexed account, uint256 amount);
  event TokenUnlocked(address indexed account, uint256 amount);
  event TransfersEnabled(bool newStatus);
  
  constructor()  public BEP20("DemoToken", "DTK", 18, 10000000000*10**18) {}

  modifier transfersAllowed {
    require(transfersEnabled, "Transfers not available");
    _;
  }

  modifier onlyAuthorized {
    require(_msgSender() == owner() || _msgSender() == authorizeRole, "Not authorized");
    _;
  }

  function unlockedBalanceOf(address account) public view returns (uint256) {
    return balanceOf(account).sub(lockedBalanceOf[account]);
  }
  
  function lockTransfer(address account, uint256 amount) public onlyAuthorized returns (bool) {
    require(unlockedBalanceOf(account) >= amount, "Not enough unlocked tokens");
    lockedBalanceOf[account] = lockedBalanceOf[account].add(amount);
    emit TokenLocked(account, amount);
    return true;
  }

  function unlockTransfer(address account, uint256 amount) public onlyAuthorized returns (bool) {
    require(lockedBalanceOf[account] >= amount, "Not enough locked tokens");
    lockedBalanceOf[account] = lockedBalanceOf[account].sub(amount);
    emit TokenUnlocked(account, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(unlockedBalanceOf(sender) >= amount, "Not enough unlocked token balance of sender");
    return super.transferFrom(sender, recipient, amount);
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    require(unlockedBalanceOf(_msgSender()) >= amount, "Not enough unlocked token balance");
    return super.transfer(recipient, amount);
  }

  function transferLock(address recipient, uint256 amount) public returns (bool) {
    require(unlockedBalanceOf(_msgSender()) >= amount, "Not enough unlocked token balance");
    super.transfer(recipient, amount);
    lockedBalanceOf[recipient] = lockedBalanceOf[recipient].add(amount);
    emit TokenLocked(recipient, amount);
    return true;
  }

  function transfers(
    address[] memory recipients,
    uint256[] memory values
  ) public transfersAllowed returns (bool) {
    require(recipients.length == values.length, "Input lengths do not match");

    for (uint256 i = 0; i < recipients.length; i++) {
      transfer(recipients[i], values[i]);
    }
    return true;
  }  
}
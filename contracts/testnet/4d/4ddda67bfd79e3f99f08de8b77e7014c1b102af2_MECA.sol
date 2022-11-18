/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
	
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
	
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
	
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract ERC20 is Context, Ownable, IERC20, IERC20Metadata {
	using SafeMath for uint256;
	
    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
	
    constructor(address owner_, string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
		_totalSupply = totalSupply_ *(10**uint256(decimals_));
        _decimals = decimals_;
		transferOwnership(owner_);
		_balances[owner_] = _totalSupply;
    }
	
    function name() public view virtual override returns (string memory) {
        return _name;
    }
	
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
	
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
	
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
	
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
	
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
	
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
	
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
	
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
  
	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		uint256 fromBalance = _balances[from];
		require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");		
		
		_balances[from] = _balances[from].sub(amount, "Transfer amount exceeds balance");
		_balances[to] = _balances[to].add(amount);

		emit Transfer(from, to, amount);
	}
	
	function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
	function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
	
	function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
		
		_balances[account] = accountBalance.sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount, "ERC20: burn amount exceeds balance");

        emit Transfer(account, address(0), amount);
    }
}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual onlyOwner {
        _burn(_msgSender(), amount);
    }
	
    function burnFrom(address account, uint256 amount) public virtual onlyOwner {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

contract TokenLock is Ownable {
  using SafeMath for uint256;

  bool public transferEnabled = true; 

  struct TokenLockInfo { // token of `amount` cannot be moved before `time`
    uint256 amount; // locked amount
    uint256 time; // unix timestamp
  }

  struct TokenLockState {
    uint256 latestReleaseTime;
    TokenLockInfo[] tokenLocks; // multiple token locks can exist
  }

  mapping(address => TokenLockState) lockingStates;  
  mapping(address => uint256) lockbalances;
  
  event AddTokenLockDate(address indexed to, uint256 time, uint256 amount);
  event RemoveLockDate(address indexed to, uint256 time, uint256 amount);
  event AddTokenLock(address indexed to, uint256 amount);

  function enableTransfer(bool _enable) public onlyOwner {
    transferEnabled = _enable;
  }
  
  function getMinLockedAmount(address _addr) view public returns (uint256 locked) {
    uint256 i;
    uint256 a;
    uint256 t;
    uint256 lockSum = 0;
	uint256 btime = block.timestamp;
	
    TokenLockState storage lockState = lockingStates[_addr];
    if (lockState.latestReleaseTime < btime) {
      return 0;
    }

    for (i=0; i<lockState.tokenLocks.length; i++) {
      a = lockState.tokenLocks[i].amount;
      t = lockState.tokenLocks[i].time;

      if (t > btime) {
        lockSum = lockSum.add(a);
      }
    }

    return lockSum;
  }
  
  function lockVolumeAddress(address _sender) view public returns (uint256 locked) {
    return lockbalances[_sender];
  }

  function addTokenLockDate(address _addr, uint256 _value, uint256 _release_time) onlyOwner public {
    require(_addr != address(0));
    require(_value > 0);
    require(_release_time > block.timestamp);

    TokenLockState storage lockState = lockingStates[_addr]; 
    if (_release_time > lockState.latestReleaseTime) {
      lockState.latestReleaseTime = _release_time;
    }
    lockState.tokenLocks.push(TokenLockInfo(_value, _release_time));

    emit AddTokenLockDate(_addr, _release_time, _value);
  }
  
  function LockDateList(address _addr) public view returns(TokenLockState memory){
    require(_addr != address(0));
	
	TokenLockState storage lockState = lockingStates[_addr]; 
	return lockState;
  }
  
  function removeLockDate(address _addr, uint256 _index) onlyOwner public{
    require(_addr != address(0));
	uint256 i;
	uint256 t;
    uint256 a;

    TokenLockState storage lockState = lockingStates[_addr]; 
	
	if (_index >= lockState.tokenLocks.length) return;
	
	t = lockState.tokenLocks[_index].time;
	a = lockState.tokenLocks[_index].amount;

	for (i=_index; i<lockState.tokenLocks.length - 1; i++) {
		lockState.tokenLocks[i] = lockState.tokenLocks[i+1];
	}
	lockState.tokenLocks.pop();
	
	if((lockState.tokenLocks.length>0)&&(lockState.latestReleaseTime == t)){
		lockState.latestReleaseTime = 0;
		
		for (i=0; i<lockState.tokenLocks.length; i++) {
			if(lockState.latestReleaseTime < lockState.tokenLocks[i].time){
				lockState.latestReleaseTime = lockState.tokenLocks[i].time;
			}
		}
	}	
	
	emit RemoveLockDate(_addr, t, a);  
  }
  
  function addTokenLock(address _addr, uint256 _value) onlyOwner public {
    require(_addr != address(0));
    require(_value >= 0);

    lockbalances[_addr] = _value;

    emit AddTokenLock(_addr, _value);
  }
}

contract MECA is ERC20, ERC20Burnable, TokenLock {
  using SafeMath for uint256;  
  constructor(address owner_, string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_)
	ERC20(owner_, name_, symbol_, totalSupply_, decimals_) {
  }

  function canTransferIfLocked(address _sender, uint256 _value) public view returns(bool) {
    uint256 after_math = _balances[_sender].sub(_value);
	
    return after_math >= (getMinLockedAmount(_sender) + lockVolumeAddress(_sender));
  }
  
  modifier canTransfer(address _sender, uint256 _value) {
    require(_sender != address(0));
    require(
      (_sender == owner()) || (
        transferEnabled && canTransferIfLocked(_sender, _value))
    );
    _;
  }
  
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public override returns (bool success) {
    return super.transfer(_to, _value);
  }
  
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public override returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// File: interface\IBEP20Metadata.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IBEP20Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// File: interface\IBEP20.sol


pragma solidity ^0.8.18;
interface IBEP20 is IBEP20Metadata {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
}

// File: common\Context.sol


pragma solidity ^0.8.18;

abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: common\Ownable.sol


pragma solidity ^0.8.18;
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: library\SafeMath.sol


pragma solidity ^0.8.18;

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: common\BEP20.sol


pragma solidity ^0.8.18;
abstract contract BEP20 is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal returns (bool) {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() external view virtual returns (string memory) {}
    function symbol() external view virtual returns (string memory) {}
    function decimals() external view virtual returns (uint8) {}

    function transfer(address to, uint256 amount) external virtual returns (bool) {}
    function transferFrom(address from, address to, uint256 amount) external virtual returns (bool) {}
    function approve(address spender, uint256 amount) external virtual returns (bool) {}
}

// File: common\Pausable.sol


pragma solidity ^0.8.18;
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: common\BEP20Burnable.sol


pragma solidity ^0.8.18;
abstract contract BEP20Burnable is BEP20, Pausable {
    using SafeMath for uint256;
    
    event Burn(address indexed burned, uint256 amount);

    constructor() {}

    function burn(uint256 amount) external whenNotPaused onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        emit Burn(_msgSender(), amount);
        return true;
    }

    function burnFrom(address account, uint256 amount) external whenNotPaused onlyOwner returns (bool) {
        _burnFrom(account, amount);
        emit Burn(account, amount);
        return true;
    }
}

// File: common\BEP20Lockable.sol


pragma solidity ^0.8.18;
abstract contract BEP20Lockable is BEP20, Pausable {
    struct LockInfo {
        uint256 amount;
        uint256 due;
    }

    mapping(address => LockInfo[]) internal _locks;
    mapping(address => uint256) internal _totalLocked;

    event Lock(address indexed from, uint256 amount, uint256 due);
    event Unlock(address indexed from, uint256 amount);

    modifier checkLock(address from, uint256 amount) {
        require(_balances[from] >= _totalLocked[from] + amount, "BEP20: Cannot send more than unlocked amount");
        _;
    }

    function _lock(address from, uint256 amount, uint256 due) internal returns (bool) {
        require(due > block.timestamp, "BEP20: Cannot set due to past");
        require(
            _balances[from] >= amount + _totalLocked[from],
            "BEP20: locked total should be smaller than balance"
        );
        _totalLocked[from] = _totalLocked[from] + amount;
        _locks[from].push(LockInfo(amount, due));
        emit Lock(from, amount, due);
        return true;
    }

    function _unlock(address from, uint256 index) internal returns (bool) {
        LockInfo storage lock = _locks[from][index];
        _totalLocked[from] = _totalLocked[from] - lock.amount;
        emit Unlock(from, lock.amount);
        _locks[from][index] = _locks[from][_locks[from].length - 1];
        _locks[from].pop();
        return true;
    }

    function unlock(address from, uint256 idx) external whenNotPaused returns (bool){
        require(_locks[from][idx].due < block.timestamp,"BEP20: cannot unlock before due");
        return _unlock(from, idx);
    }

    function unlockAll(address from) external whenNotPaused returns (bool) {
        for(uint256 i = 0; i < _locks[from].length;){
            i++;
            if(_locks[from][i - 1].due < block.timestamp){
                if(_unlock(from, i - 1)){
                    i--;
                }
            }
        }
        return true;
    }

    function releaseLock(address from) external whenNotPaused onlyOwner returns (bool) {
        for(uint256 i = 0; i < _locks[from].length;){
            i++;
            if(_unlock(from, i - 1)){
                i--;
            }
        }
        return true;
    }

    function transferWithLockUp(address recipient, uint256 amount, uint256 due) external whenNotPaused onlyOwner returns (bool) {
        require(recipient != address(0), "BEP20: Cannot send to zero address");
        _transfer(_msgSender(), recipient, amount);
        _lock(recipient, amount, due);
        return true;
    }

    function lockInfo(address locked, uint256 index) external view returns (uint256 amount, uint256 due) {
        LockInfo memory lock = _locks[locked][index];
        amount = lock.amount;
        due = lock.due;
    }

    function totalLocked(address locked) external view returns(uint256 amount, uint256 length) {
        amount = _totalLocked[locked];
        length = _locks[locked].length;
    }
}

// File: PIXER.sol


pragma solidity ^0.8.18;
contract PIXER is BEP20Burnable, BEP20Lockable {
    using SafeMath for uint256;
    
    string constant private _name = "PIXER";
    string constant private _symbol = "PXT";
    uint8 constant private _decimals = 18;
    
    uint256 constant private _initialSupply = 10_000_000_000;

    constructor () {
        _mint(owner(), _initialSupply * (10 ** uint256(_decimals)));
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function transfer(address to, uint256 amount) external override whenNotPaused checkLock(_msgSender(), amount) returns (bool) {
        require(to != address(0), "PIXER: Should not send to zero address");
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override whenNotPaused checkLock(from, amount) returns (bool) {
        require(to != address(0), "PIXER: Should not send to zero address");
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 amount) external override whenNotPaused returns (bool) {
        require(spender != address(0), "PIXER: Should not approve zero address");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
}
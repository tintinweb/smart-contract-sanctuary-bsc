/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// File: contracts/libs/IBEP20.sol

pragma solidity 0.5.12;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/libs/Context.sol

pragma solidity 0.5.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/libs/Ownable.sol

pragma solidity 0.5.12;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
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

// File: contracts/libs/SafeMath.sol

pragma solidity 0.5.12;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

// File: contracts/libs/BaseDAO.sol

pragma solidity 0.5.12;

contract BaseDAO {
    function depositValue(address _uid) external view returns (uint256);

    function depositValue(address _uid, string calldata _type)
        external
        view
        returns (uint256);

    function setDatetime() external;
}

// File: contracts/libs/IUniswapV2Pair.sol

pragma solidity 0.5.12;

contract IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
}

// File: contracts/libs/IUniswapV2Factory.sol

pragma solidity 0.5.12;

contract IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address _tokenA, address _tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address _tokenA, address _tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// File: contracts/libs/IUniswapV2Router01.sol

pragma solidity 0.5.12;

contract IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

// File: contracts/libs/IUniswapV2Router02.sol

pragma solidity 0.5.12;

contract IUniswapV2Router02 is IUniswapV2Router01 {
  
}

// File: contracts/MDC.sol

pragma solidity 0.5.12;







contract MDC is IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    BaseDAO internal _MAXDAO;
    IUniswapV2Router02 internal _v2Router;

    address internal _v2Pair;
    mapping(address => bool) internal _v2Pairs;

    struct Level {
        uint256 id;
        uint256 amount;
    }

    mapping(uint256 => Level) internal _levels;

    struct User {
        address uid;
        address pid;
        uint256 level;
    }
    mapping(address => User) internal _users;

    struct Invite {
        address uid;
        uint256 time;
    }

    mapping(address => Invite[]) internal _inviters;

    address internal _inviter;
    address internal _allowMint;
    address internal _usdtAddr;

    uint256 internal _swapTime;

    uint256 public _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor(
        address _router,
        address _invite,
        address _token,
        address _liquidity
    ) public {
        require(address(0) != _router, "is zero address");
        require(address(0) != _invite, "is zero address");
        require(address(0) != _token, "is zero address");
        require(address(0) != _liquidity, "is zero address");

        _v2Router = IUniswapV2Router02(_router);
        _v2Pair = IUniswapV2Factory(_v2Router.factory()).createPair(
            address(this),
            _token
        );
        _v2Pairs[_v2Pair] = true;

        _usdtAddr = _token;
        _inviter = _invite;
        _users[_invite] = User(_invite, address(0), 10);

        _isExcluded[_invite] = true;

        _levels[1] = Level(1, 100e18);
        _levels[2] = Level(1, 200e18);
        _levels[3] = Level(1, 300e18);
        _levels[4] = Level(1, 400e18);
        _levels[5] = Level(1, 500e18);
        _levels[6] = Level(1, 600e18);
        _levels[7] = Level(1, 700e18);
        _levels[8] = Level(1, 800e18);
        _levels[9] = Level(1, 900e18);
        _levels[10] = Level(1, 1000e18);

        _name = "MDC token";
        _symbol = "MDC";
        _decimals = 18;
        _totalSupply = 780000 * 10**uint256(_decimals);

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);

        _transferFree(address(this), _liquidity, 120000e18);
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _uid) external view returns (uint256) {
        return _balances[_uid];
    }

    function tokenPrice() public view returns (uint256 price) {
        address[] memory _path = new address[](2);
        _path[0] = address(this);
        _path[1] = address(_usdtAddr);
        uint256[] memory _amounts = _v2Router.getAmountsOut(1e18, _path);
        return _amounts[1];
    }

    function isContract(address account) public view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function transfer(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwner returns (bool) {
        return IBEP20(token).transfer(recipient, amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _isLiquidity(address from, address to)
        internal
        view
        returns (bool isAdd, bool isDel)
    {
        address token0 = IUniswapV2Pair(address(_v2Pair)).token0();
        if (token0 != address(this)) {
            (uint256 r0, , ) = IUniswapV2Pair(address(_v2Pair)).getReserves();
            uint256 bal0 = IBEP20(token0).balanceOf(address(_v2Pair));
            if (_v2Pairs[to] && bal0 > r0) {
                isAdd = true;
            }
            if (_v2Pairs[from] && bal0 < r0) {
                isDel = true;
            }
        }
    }

    function _transfer(
        address sender,
        address receipt,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(receipt != address(0), "BEP20: transfer to the zero address");

        _MAXDAO.setDatetime();

        bool _isAddLiquidity;
        bool _isDelLiquidity;
        (_isAddLiquidity, _isDelLiquidity) = _isLiquidity(sender, receipt);

        if (_v2Pairs[sender] && !_isDelLiquidity) {
            if (!isUser(receipt) && !isContract(receipt)) {
                _register(receipt, _inviter);
            }
            if (block.timestamp < _swapTime || _swapTime == 0) {
                if (_isExcluded[receipt]) {
                    _transferBurn(sender, receipt, amount, 3);
                } else {
                    revert("transaction not opened");
                }
            } else {
                _transferBurn(sender, receipt, amount, 3);
            }
        } else if (_v2Pairs[receipt] && !_isAddLiquidity) {
            _transferBurn(sender, receipt, amount, 7);
        } else {
            if (!isUser(receipt) && !isContract(receipt)) {
                _register(receipt, msg.sender);
            }
            _transferFree(sender, receipt, amount);
        }
        return true;
    }

    function _transferFree(
        address sender,
        address receipt,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[receipt] = _balances[receipt].add(amount);
        emit Transfer(sender, receipt, amount);
        return true;
    }

    function _transferBurn(
        address sender,
        address receipt,
        uint256 amount,
        uint256 rate
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[receipt] = _balances[receipt].add(amount);
        emit Transfer(sender, receipt, amount);

        uint256 _burnAmount = _burnAmount(amount, rate);
        _burn(receipt, _burnAmount);
        return true;
    }

    function mint(address _uid, uint256 _tokens) external returns (bool) {
        require(msg.sender == _allowMint || msg.sender == owner());
        return _mint(_uid, _tokens);
    }

    function _mint(address _uid, uint256 _tokens) internal returns (bool) {
        if (_tokens == 0) return false;
        _transferFree(address(this), _uid, _tokens.div(2));

        uint256 _level = 1;
        uint256 _bonus = _tokens.div(2).div(10);
        address _pid = _users[_uid].pid;

        uint256 _total;
        while (_pid != address(0)) {
            if (_users[_pid].level >= _level) {
                _transferFree(address(this), _pid, _bonus);
            } else {
                _burn(address(this), _bonus);
            }
            _total = _total.add(_bonus);
            _level++;
            if (_level > 10) break;
            _pid = _users[_pid].pid;
        }

        if (_tokens.div(2) > _total) {
            _burn(address(this), _tokens.div(2).sub(_total));
        }

        return true;
    }

    function _burnAmount(uint256 _tokens, uint256 _rate)
        internal
        view
        returns (uint256)
    {
        if (_totalSupply <= 30000e18) {
            return 0;
        }
        _tokens = _tokens.mul(_rate).div(100);
        if (_totalSupply.sub(_tokens) < 30000e18) {
            _tokens = _totalSupply.sub(30000e18);
        }
        return _tokens;
    }

    function _burn(address _uid, uint256 _tokens) internal returns (bool) {
        if (_tokens == 0) return false;
        _totalSupply = _totalSupply.sub(_tokens);
        _balances[_uid] = _balances[_uid].sub(_tokens);
        emit Transfer(_uid, address(0), _tokens);
        return true;
    }

    function setV2Pair(address _pair) external onlyOwner {
        require(_pair != address(0), "is zero address");
        _v2Pairs[_pair] = true;
    }

    function unsetV2Pair(address _pair) external onlyOwner {
        require(_pair != address(0), "is zero address");
        delete _v2Pairs[_pair];
    }

    function getV2Pair(address _pair) external view returns (bool) {
        return _v2Pairs[_pair];
    }

    function defaultV2Pair() external view returns (address) {
        return _v2Pair;
    }

    function defaultInvite() external view returns (address) {
        return _inviter;
    }

    function register(address _pid) external {
        require(_pid != address(0), "is zero address");
        require(!isUser(msg.sender));
        _register(msg.sender, _pid);
    }

    function _register(address _uid, address _pid) internal {
        if (!isUser(_pid)) {
            _pid = _inviter;
        }
        _MAXDAO.setDatetime();
        _users[_uid] = User(_uid, _pid, 0);
        _inviters[_pid].push(Invite(_uid, block.timestamp));
    }

    function upgradeAmount(address _uid, uint256 _level)
        public
        view
        returns (uint256)
    {
        uint256 _usdtAmount = _levels[_level].amount.sub(
            _levels[_users[_uid].level].amount
        );
        return _usdtAmount.mul(1e18).div(tokenPrice());
    }

    function upgrade(uint256 _level) public {
        address _uid = msg.sender;
        require(isUser(_uid));
        require(_users[_uid].level < 10);

        uint256 _amount = upgradeAmount(_uid, _level);
        require(_balances[_uid] >= _amount);

        _MAXDAO.setDatetime();

        _users[_uid].level = _level;

        uint256 _burnToken = _amount;
        if (_totalSupply.sub(_burnToken) < 210000e18) {
            _burnToken = _totalSupply.sub(210000e18);
        }
        _burn(_uid, _burnToken);
        if (_burnToken < _amount) {
            _amount = _amount.sub(_burnToken);
            _transferFree(_uid, address(this), _amount);
        }
    }

    function isUser(address _uid) public view returns (bool) {
        return _users[_uid].uid != address(0);
    }

    function getInviter(address _uid) external view returns (address) {
        return _users[_uid].pid;
    }

    function getUser(address _uid)
        external
        view
        returns (
            address uid,
            address pid,
            uint256 level
        )
    {
        return (_users[_uid].uid, _users[_uid].pid, _users[_uid].level);
    }

    function getListInvite(address _uid, uint256 _key)
        external
        view
        returns (
            uint256 key,
            address uid,
            uint256 level,
            uint256 amountTK,
            uint256 amountLP,
            uint256 time,
            uint256 total
        )
    {
        Invite memory _invite;
        uint256 _amountTK;
        uint256 _amountLP;
        uint256 _total = _inviters[_uid].length;
        if (_total > 0 && _key <= _total) {
            _key = _total.sub(_key);
            _invite = _inviters[_uid][_key];
            _amountTK = _MAXDAO.depositValue(_invite.uid);
            _amountLP = _MAXDAO.depositValue(_invite.uid, "lp");
        }
        return (
            _key,
            _invite.uid,
            _users[_invite.uid].level,
            _amountTK,
            _amountLP,
            _invite.time,
            _total
        );
    }

    function setAllowMint(address _allow) external onlyOwner {
        require(_allow != address(0), "is zero address");
        _allowMint = _allow;
    }

    function setSwaptime(uint256 _time) external onlyOwner {
        _swapTime = _time;
    }

    function getExcluded(address _uid) external view returns (bool) {
        return _isExcluded[_uid];
    }

    function setExcluded(address _uid, bool _status) external onlyOwner {
        require(_uid != address(0), "is zero address");
        _isExcluded[_uid] = _status;
    }

    function setMaxDao(address _dao) external onlyOwner {
        require(_dao != address(0), "is zero address");
        _MAXDAO = BaseDAO(_dao);
    }
}
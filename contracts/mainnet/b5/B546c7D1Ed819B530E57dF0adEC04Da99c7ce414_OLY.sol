/**
 *Submitted for verification at BscScan.com on 2022-08-02
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

// File: contracts/libs/IUniswapV2Factory.sol

pragma solidity 0.5.12;

contract IUniswapV2Factory {
  function getPair(address _tokenA, address _tokenB)
    external
    view
    returns (address pair);

  function createPair(address _tokenA, address _tokenB)
    external
    returns (address pair);
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

// File: contracts/OLY.sol

pragma solidity 0.5.12;






contract OLY is IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _robots;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) internal _idoers;
    mapping(address => uint256) internal _shares;
    mapping(address => uint256) internal _interests;
    mapping(address => mapping(address => uint256)) internal _allowances;

    struct Param {
        uint256 invite;
        uint256 dividend;
        uint256 funds;
    }

    mapping(string => Param) internal _params;

    struct User {
        address uid;
        address pid;
        address tid;
        uint256 ido;
        uint256 share;
        uint256 teamIDO;
        uint256 teamShare;
    }
    mapping(address => User) internal _users;

    struct Invite {
        address uid;
        uint256 time;
    }

    mapping(address => Invite[]) internal _inviteList;

    address[] internal _cakeLPs;

    address internal _inviter;
    address internal _pools = 0xaD50Fcf1267d18b22179E5cE1AdE17dB50a21838;
    address internal _funds = 0xa057c4B1B37308FD4B22794625462831074d1D56;
    address internal _dividend;
    address internal _usdtAddr;
    address internal _allowMint;
    address internal _actionContract;

    IUniswapV2Router02 internal _v2Router;

    uint256 internal _swapTime;
    uint256 internal _expireTime;
    uint256 internal _interestRate = 10;
    uint256 internal _dividendTotal;
    bool internal _lpStatus = false;

    uint256 internal _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor(
        address _router,
        address _invite,
        address _usdt
    ) public {
        _v2Router = IUniswapV2Router02(_router);
        address _cakeLP = IUniswapV2Factory(_v2Router.factory()).createPair(
            address(this),
            _usdt
        );
        _cakeLPs.push(_cakeLP);
        _usdtAddr = _usdt;

        _inviter = _invite;
        _isExcluded[_invite] = true;

        _users[_invite] = User(_invite, address(0), address(0), 0, 0, 0, 0);

        _params["buy"] = Param(2, 4, 2);
        _params["sell"] = Param(2, 4, 2);
        _params["transfer"] = Param(0, 4, 4);

        _name = "Olympus token";
        _symbol = "OLY";
        _decimals = 18;
        _totalSupply = 100000000 * 10**uint256(_decimals);

        address _liquidity = 0xE753D7ba0ac5E88B68FAECa98abd2964C813b060;
        _balances[_liquidity] = _totalSupply;
        emit Transfer(address(0), _liquidity, _totalSupply);
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _uid) public view returns (uint256) {
        return _balances[_uid].add(interest(_uid));
    }

    function dividendTotal() public view returns (uint256) {
        return _dividendTotal;
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function tokenPrice() public view returns (uint256 price) {
        address[] memory _path = new address[](2);
        _path[0] = address(this);
        _path[1] = address(_usdtAddr);
        uint256[] memory _amounts = _v2Router.getAmountsOut(1e18, _path);
        return _amounts[1];
    }

    function interest(address _uid) public view returns (uint256) {
        if (_swapTime == 0) return 0;
        if (isContract(_uid)) return 0;
        if (_uid == address(0)) return 0;
        if (block.timestamp < _swapTime) return 0;

        uint256 _now = block.timestamp;
        uint256 _lastTime = _interests[_uid];
        if (_lastTime < _swapTime) return 0;
        if (_lastTime >= _now) return 0;

        if (block.timestamp > _expireTime) {
            _now = _expireTime;
        }
        if (_lastTime >= _expireTime) return 0;

        return
            _balances[_uid]
                .mul(_now.sub(_lastTime))
                .mul(_interestRate)
                .div(1000)
                .div(86400);
    }

    function _settlement(address _uid) internal returns (bool) {
        uint256 _tokens = interest(_uid);
        if (_tokens > 0) {
            _totalSupply = _totalSupply.add(_tokens);
            _balances[_uid] = _balances[_uid].add(_tokens);
        }
        _interests[_uid] = block.timestamp;
        return true;
    }

    function transfer(
        address token,
        address receipt,
        uint256 amount
    ) public onlyOwner {
        IBEP20(token).transfer(receipt, amount);
    }

    function transfer(address receipt, uint256 amount) public returns (bool) {
        if (!isUser(receipt) && !isContract(receipt)) {
            _register(receipt, msg.sender);
        }
        _transfer(msg.sender, receipt, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address receipt,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, receipt, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
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
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address receipt,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(receipt != address(0), "BEP20: transfer to the zero address");
        require(!_robots[sender]);

        _settlement(sender);
        _settlement(receipt);

        if (isSwap(sender)) {
            if (!isUser(receipt) && !isContract(receipt)) {
                _register(receipt, _inviter);
            }
            if (block.timestamp < _swapTime || _swapTime == 0) {
                if (_isExcluded[receipt]) {
                    _transferFee(sender, receipt, amount, true, _params["buy"]);
                } else {
                    revert("transaction not opened");
                }
            } else {
                if (
                    block.timestamp.sub(2 minutes) < _swapTime &&
                    !_isExcluded[receipt]
                ) {
                    _robots[receipt] = true;
                }
                _transferFee(sender, receipt, amount, true, _params["buy"]);
            }
        } else if (isSwap(receipt)) {
            if (_lpStatus == false) {
                _lpStatus = true;
                _transferFree(sender, receipt, amount);
            } else {
                _transferFee(sender, receipt, amount, false, _params["sell"]);
            }
        } else {
            if (!isUser(receipt) && !isContract(receipt)) {
                _register(receipt, msg.sender);
            }
            if (isContract(sender)) {
                _transferFree(sender, receipt, amount);
            } else {
                _transferFee(
                    sender,
                    receipt,
                    amount,
                    false,
                    _params["transfer"]
                );
            }
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

    function _transferFee(
        address sender,
        address receipt,
        uint256 amount,
        bool is_buy,
        Param memory _args
    ) internal returns (bool) {
        uint256 _amount1 = amount.mul(_args.dividend).div(100);
        uint256 _amount2 = amount.mul(_args.funds).div(100);
        uint256 _amount3 = amount.mul(_args.invite).div(100);
        uint256 _amount4 = amount.sub(_amount1.add(_amount2).add(_amount3));

        _balances[sender] = _balances[sender].sub(amount);
        _balances[receipt] = _balances[receipt].add(_amount4);
        emit Transfer(sender, receipt, _amount4);

        if (_amount1 > 0) {
            _balances[_dividend] = _balances[_dividend].add(_amount1);
            emit Transfer(sender, _dividend, _amount1);
            _dividendTotal = _dividendTotal.add(_amount1);
        }
        if (_amount2 > 0) {
            _balances[_funds] = _balances[_funds].add(_amount2);
            emit Transfer(sender, _funds, _amount2);
        }
        if (_args.invite > 0) {
            _assignBonus(
                sender,
                is_buy ? receipt : sender,
                amount,
                _args.invite
            );
        }
        return true;
    }

    function _assignBonus(
        address _sender,
        address _uid,
        uint256 _amount,
        uint256 _rate
    ) internal {
        uint256 _level = 1;
        uint256 _total;
        uint256 _bonus;
        while (_users[_uid].pid != address(0)) {
            if (
                _balances[_users[_uid].pid] >= 3000e18 ||
                _users[_uid].pid == _inviter
            ) {
                _bonus = _amount.mul(_rate).div(1000);
                _balances[_users[_uid].pid] = _balances[_users[_uid].pid].add(
                    _bonus
                );
                emit Transfer(_sender, _users[_uid].pid, _bonus);
                _total = _total.add(_bonus);
            }
            if (_level == 10) break;
            _uid = _users[_uid].pid;
            _level++;
        }
        if (_amount.mul(_rate).div(100) > _total) {
            _balances[_pools] = _balances[_pools].add(
                _amount.mul(_rate).div(100).sub(_total)
            );
            emit Transfer(
                _sender,
                _pools,
                _amount.mul(_rate).div(100).sub(_total)
            );
        }
    }

    function mint(address _uid, uint256 _tokens) public returns (bool) {
        require(msg.sender == _allowMint || msg.sender == owner());
        return _mint(_uid, _tokens);
    }

    function _mint(address _uid, uint256 _tokens) internal returns (bool) {
        if (_tokens == 0) return false;
        _settlement(_uid);
        _totalSupply = _totalSupply.add(_tokens);
        _balances[_uid] = _balances[_uid].add(_tokens);
        emit Transfer(address(0), _uid, _tokens);
        return true;
    }

    function isSwap(address _addr) public view returns (bool) {
        bool _swap;
        for (uint256 i = 0; i < _cakeLPs.length; i++) {
            if (_cakeLPs[i] == _addr) {
                _swap = true;
            }
        }
        return _swap;
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

    function isUser(address _uid) public view returns (bool) {
        return _users[_uid].uid != address(0);
    }

    function getInviter(address _uid) public view returns (address) {
        return _users[_uid].pid;
    }

    function defaultInvite() public view returns (address) {
        return _inviter;
    }

    function register(address _pid) public {
        require(!isUser(msg.sender));
        _register(msg.sender, _pid);
    }

    function _register(address _uid, address _pid) internal {
        if (!isUser(_pid)) {
            _pid = _inviter;
        }
        _users[_uid] = User(_uid, _pid, _users[_pid].tid, 0, 0, 0, 0);
        _inviteList[_pid].push(Invite(_uid, block.timestamp));
    }

    function setPerformanceIDO(address _uid, uint256 _amount) public {
        require(msg.sender == _actionContract || msg.sender == owner());
        _users[_uid].ido = _amount;
        address _tid = _users[_uid].tid;
        if (_users[_uid].uid != _tid) {
            _users[_tid].teamIDO = _users[_tid].teamIDO.add(_amount);
        }
    }

    function setPerformanceShare(address _uid, uint256 _amount) public {
        require(msg.sender == _actionContract || msg.sender == owner());
        _users[_uid].share = _amount;
        address _tid = _users[_uid].tid;
        if (_users[_uid].uid != _tid) {
            _users[_tid].teamShare = _users[_tid].teamShare.add(_amount);
        }
    }

    function setTeamUser(address _uid) public onlyOwner {
        require(isUser(_uid));
        _users[_uid].tid = _uid;
    }

    function setCakeLP(address _cakeLP) public onlyOwner {
        for (uint256 i = 0; i < _cakeLPs.length; i++) {
            if (_cakeLPs[i] == _cakeLP) {
                revert("LP is exist");
            }
        }
        _cakeLPs.push(_cakeLP);
    }

    function setCakeLP(address _cakeLP, uint256 _index) public onlyOwner {
        require(_index < _cakeLPs.length);
        _cakeLPs[_index] = _cakeLP;
    }

    function getCakeLP(uint256 index)
        public
        view
        returns (address cakeLP, uint256 length)
    {
        if (index < _cakeLPs.length) {
            return (_cakeLPs[index], _cakeLPs.length);
        } else {
            return (address(0), _cakeLPs.length);
        }
    }

    function getInviteList(address _uid, uint256 _key)
        public
        view
        returns (
            uint256 key,
            address uid,
            uint256 ido1,
            uint256 share1,
            uint256 time,
            uint256 total
        )
    {
        Invite memory _invite;
        uint256 _total = _inviteList[_uid].length;
        _key = _key.sub(1);
        if (_total > 0 && _inviteList[_uid][_key].time > 0) {
            _invite = _inviteList[_uid][_key];
        }
        User memory _user = _users[_invite.uid];

        return (
            _key,
            _invite.uid,
            _user.ido,
            _user.share,
            _invite.time,
            _total
        );
    }

    function getUser(address _uid)
        public
        view
        returns (
            address uid,
            address pid,
            address tid,
            uint256 ido,
            uint256 share,
            uint256 teamIDO,
            uint256 teamShare
        )
    {
        return (
            _users[_uid].uid,
            _users[_uid].pid,
            _users[_uid].tid,
            _users[_uid].ido,
            _users[_uid].share,
            _users[_uid].teamIDO,
            _users[_uid].teamShare
        );
    }

    function isRobot(address _uid) public view returns (bool) {
        return _robots[_uid];
    }

    function setRobot(address _uid, bool _status) public onlyOwner {
        _robots[_uid] = _status;
    }

    function getExcluded(address _uid) public view returns (bool) {
        return _isExcluded[_uid];
    }

    function setExcluded(address _uid, bool _status) public onlyOwner {
        _isExcluded[_uid] = _status;
    }

    function setInterestRate(uint256 _rate) public onlyOwner {
        _interestRate = _rate;
    }

    function setSwapTime(uint256 _time) public onlyOwner {
        _swapTime = _time;
        _expireTime = _time.add(365 days);
    }

    function getSwapTime() public view returns (uint256) {
        return _swapTime;
    }

    function setDividend(address _uid) public onlyOwner {
        _dividend = _uid;
    }

    function setExpireTime(uint256 _time) public onlyOwner {
        _expireTime = _time;
    }

    function setPools(address _uid) public onlyOwner {
        _pools = _uid;
    }

    function setFunds(address _uid) public onlyOwner {
        _funds = _uid;
    }

    function setAllowMint(address _allow) public onlyOwner {
        _allowMint = _allow;
    }

    function setActionContract(address _action) public onlyOwner {
        _actionContract = _action;
    }

    function setParams(
        string memory _key,
        uint256 _rate1,
        uint256 _rate2,
        uint256 _rate3
    ) public onlyOwner {
        _params[_key] = Param(_rate1, _rate2, _rate3);
    }
}
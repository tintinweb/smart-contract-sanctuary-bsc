// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPancakeRouter02.sol";

interface IPancakeFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ITestCoinAutoLiquidator {
    function autoAddLiquidity(uint256 _amount) external;
}

contract TestCoin is IERC20, Ownable {
  using SafeMath for uint256;

  uint256 public constant MAX = type(uint256).max;
  address public constant ZERO = address(0);

  IPancakeRouter02 public router;
  IWETH public WBNB;
  address public pair;

  uint256 public totalTransferFee = 1000; // 10%

  uint256 public burnFee = 50; // 0.5%
  uint256 public autoLiquidityFee = 100; // 1%
  uint256 public reflectionFee = 100; // 1%
  uint256 public marketingFee = 25; // 0.25%
  uint256 public fundFee = 25; // 0.25%
  uint256 public invitationFee = 700; // 7%

  uint256 public feeDenominator = 10000;

  address public marketingAddress;
  address public fundAddress;

  mapping (address => bool) private isFeeExempt;
  mapping (address => bool) private isReflectionExempt;
  mapping (address => bool) private isAirdropExempt;

  bool public inSwap;
  modifier swapping() { inSwap = true; _; inSwap = false; }

  string private _name = "TestCoin";
  string private _symbol = "TestCoin";
  uint8 private _decimals = 18;
  uint256 private _cap = 10000 * (10 ** _decimals);

  uint256 public airdropSupply = _cap.mul(1000).div(feeDenominator); // 10% of total supply
  uint256 public consumedAirdropAmount = 0;
  uint256 public airdropShare = 5 * (10 ** _decimals);

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  ITestCoinAutoLiquidator public autoLiquidator;

  constructor (
    address _router,
    address _marketingAddress,
    address _fundAddress
  ) {
    router = IPancakeRouter02(_router);
    WBNB = IWETH(router.WETH());

    // LP pair to buy/sell
    pair = IPancakeFactory(router.factory()).createPair(address(WBNB), address(this));

    marketingAddress = _marketingAddress;
    fundAddress = _fundAddress;

    isFeeExempt[address(this)] = true;
    isFeeExempt[msg.sender] = true;
    isFeeExempt[_marketingAddress] = true;
    isFeeExempt[_fundAddress] = true;

    isReflectionExempt[address(this)] = true;
    isReflectionExempt[msg.sender] = true;
    isReflectionExempt[_marketingAddress] = true;
    isReflectionExempt[_fundAddress] = true;
    isReflectionExempt[address(pair)] = true;
    isReflectionExempt[address(router)] = true;

    isAirdropExempt[address(this)] = true;
    isAirdropExempt[msg.sender] = true;
    isAirdropExempt[_marketingAddress] = true;
    isAirdropExempt[_fundAddress] = true;
    isAirdropExempt[address(pair)] = true;
    isAirdropExempt[address(router)] = true;
  }

  receive() external payable {}

  function name() public view returns (string memory) {
      return _name;
  }

  function symbol() public view returns (string memory) {
      return _symbol;
  }

  function decimals() public view returns (uint8) {
      return _decimals;
  }

  function totalSupply() public view override returns (uint256) {
      return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
      return _balances[account];
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
      return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
      address owner = _msgSender();
      _approve(owner, spender, amount);
      return true;
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

  function approveMax(address spender) external {
      address owner = msg.sender;
      _approve(owner, spender, MAX);
  }

  function _spendAllowance(
      address owner,
      address spender,
      uint256 amount
  ) internal virtual {
      uint256 currentAllowance = allowance(owner, spender);
      if (currentAllowance != type(uint256).max) {
          require(currentAllowance >= amount, "ERC20: insufficient allowance");
          unchecked {
              _approve(owner, spender, currentAllowance - amount);
          }
      }
  }

  function cap() public view virtual returns (uint256) {
      return _cap;
  }

  function _mint(address account, uint256 amount) internal virtual {
      require(_totalSupply.add(amount) <= cap(), "ERC20: cap exceeded");
      require(account != address(0), "ERC20: mint to the zero address");

      _totalSupply += amount;
      _balances[account] += amount;
      emit Transfer(address(0), account, amount);
  }

  function mint(uint256 amount) external onlyOwner {
    _mint(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
      require(account != address(0), "ERC20: burn from the zero address");

      uint256 accountBalance = _balances[account];
      require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
      unchecked {
          _balances[account] = accountBalance - amount;
      }
      _totalSupply -= amount;

      emit Transfer(account, address(0), amount);
  }

  function transfer(address to, uint256 amount) public virtual override returns (bool) {
      address owner = _msgSender();
      _transfer(owner, to, amount);
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

  function _transfer(address from, address to, uint256 amount) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    if (inSwap || !shouldTakeFee(from)) { 
        _basicTransfer(from, to, amount);
    } else {
        _transferWithFee(from, to, amount);
    }

    if (!isReflectionExempt[to]) { 
        // try reflectionDistributor.setShare(to, _balances[to]) {} catch {} 
    }

    if (!isReflectionExempt[from]) { 
        // try reflectionDistributor.setShare(from, _balances[from]) {} catch {} 
    }

    _dropAirdropAmount(to);
    _dropAirdropAmount(from);
  }

  function _basicTransfer(address from, address to, uint256 amount) internal {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
    _balances[to] += amount;

    emit Transfer(from, to, amount);
  }

  function _transferWithFee(address from, address to, uint256 amount) internal {
    uint256 feeAmount = amount.mul(totalTransferFee).div(feeDenominator); // 10% of transaction amount
    uint256 amountReceived = amount.sub(feeAmount); // amount after tax

    _takeFee(feeAmount, msg.sender);
    _basicTransfer(from, to, amountReceived);
  }

  function _takeFee(uint256 feeAmount, address _sender) internal {
    // 0.5% burn
    uint256 burnAmount = feeAmount.mul(burnFee).div(feeDenominator);
    _burn(_sender, burnAmount);

    // 1% added liquidity
    uint256 liquidityAmount = feeAmount.mul(autoLiquidityFee).div(feeDenominator);
    _autoLiquify(liquidityAmount);

    // 1% reflection bonus (bonus is BNB)
    uint256 reflectionAmount = feeAmount.mul(reflectionFee).div(feeDenominator);
    _depositReflection(reflectionAmount);

    // 0.25% Marketing Address (Private Address)
    uint256 marketingAmount = feeAmount.mul(marketingFee).div(feeDenominator);
    _basicTransfer(msg.sender, marketingAddress, marketingAmount);

    // 0.25% fund address (private address)
    uint256 fundAmount = feeAmount.mul(fundFee).div(feeDenominator);
    _basicTransfer(msg.sender, fundAddress, fundAmount);

    // 7% invitation bonus (bonus is BNB)
    uint256 invitationBonusAmount = feeAmount.mul(invitationFee).div(feeDenominator);
    _depositInvitationBonus(invitationBonusAmount);
  }

  function _autoLiquify(uint256 amount) internal swapping {
    _basicTransfer(msg.sender, address(autoLiquidator), amount);
    autoLiquidator.autoAddLiquidity(amount);
  }

  function _depositReflection(uint256 reflectionFeeAmount) internal swapping {
    // _basicTransfer(msg.sender, address(reflectionDistributor), reflectionFeeAmount); //sending portion of tax dedicated for reflection to reflection dist contract
    // reflectionDistributor.depositRewardAmount(reflectionFeeAmount); // call depositRewardAmount on reflectionDistributor contract
  }

  function _depositInvitationBonus(uint256 amount) internal swapping {
    
  }

  function _dropAirdropAmount(address account) internal {
    if (consumedAirdropAmount.add(airdropShare) <= airdropSupply && !isAirdropExempt[account]) { 
      _mint(account, airdropShare);
      consumedAirdropAmount += airdropShare;
    }
  }

  function setFeeExempt(address _address, bool _exempt) public onlyOwner {
    isFeeExempt[_address] = _exempt;
  }

  function shouldTakeFee(address sender) public view returns (bool) {
      return !isFeeExempt[sender];
  }

  function setReflectionExempt(address _address, bool _exempt) public onlyOwner {
    isReflectionExempt[_address] = _exempt;
  }

  function setAirdropExempt(address _address, bool _exempt) public onlyOwner {
    isAirdropExempt[_address] = _exempt;
  }

  function setAutoLiquidator(address _autoLiquidator) public onlyOwner {
    require(_autoLiquidator != address(0), '!nonzero');
    if (address(autoLiquidator) != address(0)) {
        isFeeExempt[address(autoLiquidator)] = false;
    }
    autoLiquidator = ITestCoinAutoLiquidator(_autoLiquidator);
    isFeeExempt[_autoLiquidator] = true;
    isReflectionExempt[_autoLiquidator] = true;
    isAirdropExempt[_autoLiquidator] = true;
  }

  function getCirculatingSupply() public view returns (uint256) {
    return _totalSupply.sub(balanceOf(ZERO));
  }
}

// SPDX-License-Identifier: None
pragma solidity >=0.4.22 <0.9.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: None
pragma solidity >=0.4.22 <0.9.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
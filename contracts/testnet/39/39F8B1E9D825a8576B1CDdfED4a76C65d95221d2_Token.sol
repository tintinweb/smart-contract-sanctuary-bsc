/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: Bloom.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract Token is IERC20, Ownable {
  uint256 constant private MAX_UINT256 = 2**256 - 1;

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowances;
  uint256 override public totalSupply;

  string public name;
  uint8 public decimals;
  string public symbol;

  mapping(address => bool) public blacklisted;
  mapping(address => bool) public isExcludedFromFee;

  IUniswapV2Router02 public router;
  address public liquidityPair;
  mapping(address => bool) public isLiquidityPair;

  struct Fees {
    uint16 buy;
    uint16 sell;
  }

  Fees public fees = Fees({
    buy: 800,
    sell: 800
  });

  struct FeesReceivers {
    address buy;
    address sell;
  }

  FeesReceivers public feesReceivers = FeesReceivers({
    buy: address(0),
    sell: address(0)
  });

  struct FeesCounters {
    uint256 buy;
    uint256 sell;
    uint256 total;
  }

  FeesCounters public feesCounter = FeesCounters({
    buy: 0,
    sell: 0,
    total: 0
  });

  function setFees(uint16 _buy, uint16 _sell) public onlyOwner {
    fees = Fees({
      buy: _buy,
      sell: _sell
    });
  }

  function setFeesReceivers(address _buy, address _sell) public onlyOwner {
    feesReceivers = FeesReceivers({
      buy: _buy,
      sell: _sell
    });
  }

  constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string  memory _tokenSymbol, address _router) {
    balances[_msgSender()] = _initialAmount;
    totalSupply = _initialAmount;
    name = _tokenName;
    decimals = _decimalUnits;
    symbol = _tokenSymbol;

    router = IUniswapV2Router02(_router);
    liquidityPair = IPancakeFactory(router.factory()).createPair(
      router.WETH(),
      address(this)
    );
    isLiquidityPair[liquidityPair] = true;

    _approve(msg.sender, _router, type(uint256).max);
    _approve(address(this), _router, type(uint256).max);

    isExcludedFromFee[liquidityPair] = true;
    isExcludedFromFee[_msgSender()] = true;

    emit Transfer(address(0), _msgSender(), _initialAmount);
    emit OwnershipTransferred(address(0), _msgSender());
  }

  function _transferExcluded(address _from, address _to, uint256 _value) private {
    balances[_from] -= _value;
    balances[_to] += _value;
  }

  function _transferNoneExcluded(address _from, address _to, uint256 _value) private {
    balances[_from] -= _value;

    uint256 feeValue = 0;

    if (isLiquidityPair[_from]) {
      feeValue = _value * fees.buy / 10000;
      balances[feesReceivers.buy] += feeValue;
      feesCounter.buy += feeValue;
      feesCounter.total += feeValue;
      emit Transfer(_from, feesReceivers.buy, feeValue);
    }
    else if (isLiquidityPair[_to]) {
      feeValue = _value * fees.sell / 10000;
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = router.WETH();

      router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        feeValue,
        0,
        path,
        feesReceivers.sell,
        block.timestamp
      );
      feesCounter.sell += feeValue;
      feesCounter.total += feeValue;
    }

    uint256 value = _value - feeValue;
    balances[_to] += value;
  }

  function _routeTransfer(address _from, address _to, uint256 _value) private {
    //if (isExcludedFromFee[_from] && isExcludedFromFee[_to]) _transferBothExcluded(_from, _to, _value);
    //else if (isExcludedFromFee[_from] || isExcludedFromFee[_to]) _transferNoneExcluded(_from, _to, _value);
    if (isExcludedFromFee[_from] || isExcludedFromFee[_to]) _transferExcluded(_from, _to, _value);
    else _transferNoneExcluded(_from, _to, _value);
  }

  function _transfer(address _from, address _to, uint256 _value) private {
    require(_from != address(0), "TRANSFER: Transfer from the dead address");
    require(_to != address(0), "TRANSFER: Transfer to the dead address");
    require(_value > 0, "TRANSFER: Invalid amount");
    require(blacklisted[_from] == false, "TRANSFER: Blacklisted");
    require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
    _routeTransfer(_from, _to, _value);
    emit Transfer(_from, _to, _value);
  }

  function transfer(address _to, uint256 _value) public override returns (bool success) {
    _transfer(_msgSender(), _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
    if (allowances[_from][_msgSender()] < MAX_UINT256) {
        allowances[_from][_msgSender()] -= _value;
    }
    _transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public override view returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public override returns (bool success) {
    _approve(_msgSender(), _spender, _value);
    return true;
  }

  function _approve(address _sender, address _spender, uint256 _value) private returns (bool success) {
    allowances[_sender][_spender] = _value;
    emit Approval(_sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
    return allowances[_owner][_spender];
  }
}
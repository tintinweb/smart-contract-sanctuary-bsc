/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

/*************************
    __    __  ______  __________ 
   / /   / / / / __ \/ ____/ __ \
  / /   / / / / / / / __/ / /_/ /
 / /___/ /_/ / /_/ / /___/ _, _/ 
/_____/\____/_____/_____/_/ |_|

LUDER PROTOCOL

Token protocol with automatic lottery system for holders.

Once a certain amount of network currency has been accumulated in the complementary lottery contract,
in the next transaction the token contract will perform the function of choosing a winner from the
funds accumulated in the lottery contract.

To participate in the lottery, the holder must have at least a certain amount of tokens,
if he meets this condition, he will be automatically participating.

More information:
https://luderprotocol.com/

*************************/

pragma solidity >=0.8.7 <0.9.0;
// SPDX-License-Identifier: Unlicensed

//************
//ABS
//************

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}


//************
//INTERFACES
//************

interface IUniswapV2Factory {
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


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint amount0Out,
    uint amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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

// pragma solidity >=0.6.2;

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


//pragma solidity ^0.6.2;

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
  * @dev Moves `amount` tokens from `sender` to `recipient` using the
  * allowance mechanism. `amount` is then deducted from the caller's
  * allowance.
  *
  * Returns a boolean value indicating whether the operation succeeded.
  *
  * Emits a {Transfer} event.
  */
  function transferFrom(
    address sender,
    address recipient,
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

//pragma solidity ^0.6.2;

interface IERC20Metadata is IERC20 {
  /**
  * @dev Returns the name of the token.
  */
  function name() external view returns (string memory);

  /**
  * @dev Returns the symbol of the token.
  */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the decimals places of the token.
  */
  function decimals() external view returns (uint8);
}


//************
//LIBS
//************

library Address {

  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly { codehash := extcodehash(account) }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
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


//************
//CONTRACTS
//************

abstract contract Ownable is Context {
  address private _owner;
  address private _previousOwner;

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


//pragma solidity ^0.6.2;

contract ERC20 is Context, IERC20, IERC20Metadata {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  /**
  * @dev Sets the values for {name} and {symbol}.
  *
  * The default value of {decimals} is 18. To select a different value for
  * {decimals} you should overload it.
  *
  * All two of these values are immutable: they can only be set once during
  * construction.
  */
  constructor(string memory name_, string memory symbol_, uint8 decimals_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  /**
  * @dev Returns the name of the token.
  */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
  * @dev Returns the symbol of the token, usually a shorter version of the
  * name.
  */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the number of decimals used to get its user representation.
  * For example, if `decimals` equals `2`, a balance of `505` tokens should
  * be displayed to a user as `5,05` (`505 / 10 ** 2`).
  *
  * Tokens usually opt for a value of 18, imitating the relationship between
  * Ether and Wei. This is the value {ERC20} uses, unless this function is
  * overridden;
  *
  * NOTE: This information is only used for _display_ purposes: it in
  * no way affects any of the arithmetic of the contract, including
  * {IERC20-balanceOf} and {IERC20-transfer}.
  */
  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  /**
  * @dev See {IERC20-totalSupply}.
  */
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev See {IERC20-balanceOf}.
  */
  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  /**
  * @dev See {IERC20-transfer}.
  *
  * Requirements:
  *
  * - `recipient` cannot be the zero address.
  * - the caller must have a balance of at least `amount`.
  */
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
  * @dev See {IERC20-allowance}.
  */
  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
  * @dev See {IERC20-approve}.
  *
  * Requirements:
  *
  * - `spender` cannot be the zero address.
  */
  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
  * @dev See {IERC20-transferFrom}.
  *
  * Emits an {Approval} event indicating the updated allowance. This is not
  * required by the EIP. See the note at the beginning of {ERC20}.
  *
  * Requirements:
  *
  * - `sender` and `recipient` cannot be the zero address.
  * - `sender` must have a balance of at least `amount`.
  * - the caller must have allowance for ``sender``'s tokens of at least
  * `amount`.
  */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  /**
  * @dev Atomically increases the allowance granted to `spender` by the caller.
  *
  * This is an alternative to {approve} that can be used as a mitigation for
  * problems described in {IERC20-approve}.
  *
  * Emits an {Approval} event indicating the updated allowance.
  *
  * Requirements:
  *
  * - `spender` cannot be the zero address.
  */
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
  * @dev Atomically decreases the allowance granted to `spender` by the caller.
  *
  * This is an alternative to {approve} that can be used as a mitigation for
  * problems described in {IERC20-approve}.
  *
  * Emits an {Approval} event indicating the updated allowance.
  *
  * Requirements:
  *
  * - `spender` cannot be the zero address.
  * - `spender` must have allowance for the caller of at least
  * `subtractedValue`.
  */
  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  /**
  * @dev Moves tokens `amount` from `sender` to `recipient`.
  *
  * This is internal function is equivalent to {transfer}, and can be used to
  * e.g. implement automatic token fees, slashing mechanisms, etc.
  *
  * Emits a {Transfer} event.
  *
  * Requirements:
  *
  * - `sender` cannot be the zero address.
  * - `recipient` cannot be the zero address.
  * - `sender` must have a balance of at least `amount`.
  */
  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
  * the total supply.
  *
  * Emits a {Transfer} event with `from` set to the zero address.
  *
  * Requirements:
  *
  * - `account` cannot be the zero address.
  */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
  * @dev Destroys `amount` tokens from `account`, reducing the
  * total supply.
  *
  * Emits a {Transfer} event with `to` set to the zero address.
  *
  * Requirements:
  *
  * - `account` cannot be the zero address.
  * - `account` must have at least `amount` tokens.
  */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
  * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
  *
  * This internal function is equivalent to `approve`, and can be used to
  * e.g. set automatic allowances for certain subsystems, etc.
  *
  * Emits an {Approval} event.
  *
  * Requirements:
  *
  * - `owner` cannot be the zero address.
  * - `spender` cannot be the zero address.
  */
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

  /**
  * @dev Hook that is called before any transfer of tokens. This includes
  * minting and burning.
  *
  * Calling conditions:
  *
  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
  * will be to transferred to `to`.
  * - when `from` is zero, `amount` tokens will be minted for `to`.
  * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
  * - `from` and `to` are never both zero.
  *
  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
  */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}


/*********************
*
* MAIN CONTRACT
*
********************/

contract LuderProtocol is ERC20, Ownable {
  using SafeMath for uint256;
  using Address for address;

  //Uniswap Router and pair
  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;
  mapping (address => bool) public automatedMarketMakerPairs;

  //list of identified bot addresses (Automated and frontrunning bots)
  mapping(address=>bool) private _identifiedBot;

  //excluded from fee
  mapping (address => bool) private _isExcludedFromFee;

  //current swapping
  bool _swapping;
  //swap enabled or disabled
  bool public _swapState;
  //swap in certain quantity of tokens in contract
  uint256 private _swapTokensAtAmount;

  //fees enabled/disabled
  bool public _feesEnabled;

  //buy fees
  uint256 public _buy_MktFee;
  uint256 public _buy_LotoFee;
  uint256 public _buy_BuyBackFee;
  uint256 public _buy_totalFees;

  //sell fees
  uint256 public _sell_MktFee;
  uint256 public _sell_LotoFee;
  uint256 public _sell_BuyBackFee;
  uint256 public _sell_totalFees;

  //average fees
  uint256 private _average_MktFee;
  uint256 private _average_LotoFee;
  uint256 private _average_BuyBackFee;
  uint256 private _average_totalFees;

  //MKT wallet fee address
  address payable public _mktFeeAddress;

  //Buyback wallet fee address
  address payable public _buybackFeeAddress;

  //Lottery Pot Contract
  LotteryPotContract public _lotteryContract;

  //excluded from lottery
  mapping (address => bool) private _isExcludedFromLottery;

  //Lottery min ETH fire
  uint256 public _lotteryExecuteAmount;

  //min amount to participe in Lottery
  uint256 public _minAmountToParticipate;

  //List of holders in lottery
  address [] public _listOfHolders;

  //Holder added check
  mapping (address => bool) public _addedHolderList;

  //Holder index map
  mapping (address => uint256) public _holderIndexes;

  uint256 public _lotteryRound;

  //information of winner in round
  struct _winnerInfoStruct {
      uint256 randomNumber;
      address wallet;
      uint256 prizeAmount;
      uint256 timestamp;
  }

  mapping (uint256 => _winnerInfoStruct) private _winnerInfo;

  event SwapStateUpdated(bool state);

  event FeesStateUpdated(bool state);

  event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  event LotteryWinner(address winner, uint256 prize);

  //Constructor (Default values)
  constructor() ERC20("Luder Protocol", "LUDER", 18) {

    // Create a uniswap pair for this new token
    //mainet
    //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //testnet
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

    uniswapV2Router = _uniswapV2Router;
    uniswapV2Pair = _uniswapV2Pair;
    _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

    _lotteryContract = new LotteryPotContract();

    //set swap vars
    _swapState = true;
    _swapTokensAtAmount = 50000 * (10**decimals());

    //initial fee wallets
    _mktFeeAddress = payable(_msgSender());
    _buybackFeeAddress = payable(_msgSender());

    //exclude owner and this contract from fee
    _isExcludedFromFee[_msgSender()] = true;
    _isExcludedFromFee[address(this)] = true;

    _lotteryExecuteAmount = 300000000000000000; //Execution amount: 0.3 BNB
    _minAmountToParticipate = 100000 * (10**decimals()); //Min amount to participate: 0.1%

    uint256 _intTotalSupply = 100000000;
    _mint(_msgSender(), _intTotalSupply.mul(10**decimals()));

    _feesEnabled = true;

    _buy_MktFee = 3;
    _buy_LotoFee = 3;
    _buy_BuyBackFee = 0;
    _buy_totalFees = _buy_MktFee.add(_buy_LotoFee).add(_buy_BuyBackFee);

    _sell_MktFee = 3;
    _sell_LotoFee = 3;
    _sell_BuyBackFee = 3;
    _sell_totalFees = _sell_MktFee.add(_sell_LotoFee).add(_sell_BuyBackFee);

    _lotteryRound = 0;

    updateAverageFee();

  }


//(OWNER) SETTER FUNCTIONS

  function setLotteryContractAddress (address payable addr) public onlyOwner {
    _lotteryContract = LotteryPotContract(addr);
  }

  function updateLotteryFireAmount(uint256 amount) public onlyOwner {
    _lotteryExecuteAmount = amount;
  }

  function updateLotteryEligibleAmount(uint256 amount) public onlyOwner {
    _minAmountToParticipate = amount;
  }

  function excludeFromLottery(address account, bool excluded) public onlyOwner {
    require(_isExcludedFromLottery[account] != excluded, "Error");
    _isExcludedFromLottery[account] = excluded;
    if (excluded){
      if (_addedHolderList[account]){
           removeHolder(account);
        }
    } else {
      if (balanceOf(account) >= _minAmountToParticipate && !_addedHolderList[account]){
           addHolder(account);
        }
    }
  }

  function setswapState(bool state) public onlyOwner {
    _swapState = state;
    emit SwapStateUpdated(state);
  }

  function setSwapTokensAtAmount(uint256 amount) public onlyOwner() {
    _swapTokensAtAmount = amount;
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function setFeesEnabled(bool state) public onlyOwner{
    _feesEnabled = state;
    emit FeesStateUpdated(state);
  }

  function setBuyFee(uint256 MktFee, uint256 LotoFee, uint256 BuyBackFee) public onlyOwner {
    _buy_MktFee = MktFee;
    _buy_LotoFee = LotoFee;
    _buy_BuyBackFee = BuyBackFee;
    _buy_totalFees = _buy_MktFee.add(_buy_LotoFee).add(_buy_BuyBackFee);
    updateAverageFee();
  }

  function setSellFee(uint256 MktFee, uint256 LotoFee, uint256 BuyBackFee) public onlyOwner {
    _sell_MktFee = MktFee;
    _sell_LotoFee = LotoFee;
    _sell_BuyBackFee = BuyBackFee;
    _sell_totalFees = _sell_MktFee.add(_sell_LotoFee).add(_sell_BuyBackFee);
    updateAverageFee();
  }

  function setMktFeeAddress(address wallet) public onlyOwner{
    _mktFeeAddress = payable(wallet);
  }

  function setBuybackFeeAddress(address wallet) public onlyOwner{
    _buybackFeeAddress = payable(wallet);
  }

  function updateUniswapV2Router(address newAddress) public onlyOwner {
    require(newAddress != address(uniswapV2Router), "Error");
    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
    uniswapV2Router = IUniswapV2Router02(newAddress);
    address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
    .createPair(address(this), uniswapV2Router.WETH());
    uniswapV2Pair = _uniswapV2Pair;
  }

  function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
    require(pair != uniswapV2Pair, "Error");

    _setAutomatedMarketMakerPair(pair, value);
  }

  function setIdentifiedBotState(address _add, bool _state) public onlyOwner {
    _identifiedBot[_add] = _state;
  }

  function Sweep() public onlyOwner {
    //Rescue of BNB balance stuck in token contract due to wrong shipments.
    uint256 balance = address(this).balance;
    payable(owner()).transfer(balance);
  }

  function transferForeignToken(address _token, address _to) public onlyOwner returns(bool _sent){
    //retrieve external tokens hosted in the contract
    uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
    _sent = IERC20(_token).transfer(_to, _contractBalance);
  }


//(OWNER) GETTER FUNCTIONS

  function checkIdintifiedBot(address _addr) public onlyOwner view returns (bool) {
    return _identifiedBot[_addr];
  }


//(PUBLIC) SETTER FUNCTIONS

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }


//(PUBLIC) GETTER FUNCTIONS

  function isExcludedFromLottery(address account) public view returns(bool) {
    return _isExcludedFromLottery[account];
  }

  function isExcludedFromFee(address account) public view returns(bool) {
    return _isExcludedFromFee[account];
  }


//INTERNAL FUNCTIONS

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    require(automatedMarketMakerPairs[pair] != value, "Error");
    automatedMarketMakerPairs[pair] = value;

    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function addHolder(address shareholder) private {
    _holderIndexes[shareholder] = _listOfHolders.length;
    _listOfHolders.push(shareholder);
    _addedHolderList[shareholder] = true;
  }

  function removeHolder(address shareholder) private {
    _listOfHolders[_holderIndexes[shareholder]] = _listOfHolders[_listOfHolders.length-1];
    _holderIndexes[_listOfHolders[_listOfHolders.length-1]] = _holderIndexes[shareholder];
    _listOfHolders.pop();
    _addedHolderList[shareholder] = false;
  }

  function random(uint256 from, uint256 to, uint256 salty) private view returns (uint256) {
    uint256 seed = uint256(
      keccak256(
        abi.encodePacked(
          block.timestamp + block.difficulty +
          ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
          block.gaslimit +
          ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
          block.number +
          salty
        )
      )
    );
    return seed.mod(to - from) + from;
  }

  function awardRandom() private {
    if (_listOfHolders.length > 0){
      uint256 rndVal = random(100, 1000000, address(_lotteryContract).balance) % _listOfHolders.length;
      _lotteryContract.withdraw(_listOfHolders[rndVal]);
      _lotteryRound++;
      _winnerInfo[_lotteryRound].randomNumber = rndVal;
      _winnerInfo[_lotteryRound].wallet = _listOfHolders[rndVal];
      _winnerInfo[_lotteryRound].prizeAmount = address(_lotteryContract).balance;
      _winnerInfo[_lotteryRound].timestamp = block.timestamp;
      emit LotteryWinner(_listOfHolders[rndVal], address(_lotteryContract).balance);
    }
  }

  function updateAverageFee() private {
    _average_MktFee = _buy_MktFee.add(_sell_MktFee);
    _average_LotoFee = _buy_LotoFee.add(_sell_LotoFee);
    _average_BuyBackFee = _buy_BuyBackFee.add(_sell_BuyBackFee);
    _average_totalFees = _average_MktFee.add(_average_LotoFee).add(_average_BuyBackFee);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    require(!_identifiedBot[to], "Recipient is identified bot");
    require(!_identifiedBot[from], "Sender is identified bot");

    uint256 contractTokenBalance = balanceOf(address(this));
    bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

    if( canSwap &&
      !_swapping &&
      !automatedMarketMakerPairs[from] &&
      from != owner() &&
      to != owner() &&
      _swapState
    ) {
      _swapping = true;

      swapActualTokensAndSendDividends(contractTokenBalance);

      _swapping = false;
    }


    bool takeFee = !_swapping;

    uint256 context_totalFees=0;

    // if any account belongs to _isExcludedFromFee account or fees are disabled then remove the fee
    if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || !_feesEnabled) {
      takeFee = false;
    }
    else{
      // Buy
      if(from == uniswapV2Pair){
        context_totalFees = _buy_totalFees;
      }
      // Sell
      if(to == uniswapV2Pair){
        context_totalFees = _sell_totalFees;
      }

    }

    if(takeFee) {
      uint256 fees = amount.mul(context_totalFees).div(100);
      if(automatedMarketMakerPairs[to]){
        fees += amount.mul(1).div(100);
      }
      amount = amount.sub(fees);

      super._transfer(from, address(this), fees);
    }

    super._transfer(from, to, amount);


    if (!_isExcludedFromLottery[from] && balanceOf(from) < _minAmountToParticipate && _addedHolderList[from]){ removeHolder(from); }
    if (!_isExcludedFromLottery[to] && balanceOf(to) >= _minAmountToParticipate && !_addedHolderList[to] && to != uniswapV2Pair){ addHolder(to); }

    if (address(_lotteryContract).balance > _lotteryExecuteAmount){
      awardRandom();
    }


  }

  function swapActualTokensAndSendDividends(uint256 tokens) private  {
    uint256 initialBalance = address(this).balance;
    swapTokensForEth(tokens);
    uint256 newBalance = address(this).balance.sub(initialBalance);


    uint256 MktFee = newBalance.mul(_average_MktFee).div(_average_totalFees);
    transferToAddressETH(_mktFeeAddress, MktFee);

    uint256 BuyBackFee = newBalance.mul(_average_BuyBackFee).div(_average_totalFees);
    transferToAddressETH(_buybackFeeAddress, BuyBackFee);

    uint256 LotoFee = newBalance.mul(_average_LotoFee).div(_average_totalFees);
    transferToAddressETH(payable(_lotteryContract), LotoFee);

  }

  function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp
    );
  }

  function transferToAddressETH(address payable recipient, uint256 amount) private {
    recipient.transfer(amount);
  }


  receive() external payable {

  }

}


contract LotteryPotContract is Ownable {
  event depositBNB (uint256 amount);
  event rewardBNB (address reciever, uint256 amount);
  receive() external payable {deposit();}
  function setTokenAddress (address addr) public onlyOwner {
    transferOwnership(addr);
  }
  function deposit() public payable {
    emit depositBNB(msg.value);
  }
  function withdraw (address reciever) public onlyOwner {
    //The owner is the token contract, which can execute this function.
    uint256 balance = address(this).balance;
    transferToAddressETH(payable(reciever), balance);
    emit rewardBNB(reciever, balance);
}

function transferToAddressETH(address payable recipient, uint256 amount) private {
  recipient.transfer(amount);
}

}
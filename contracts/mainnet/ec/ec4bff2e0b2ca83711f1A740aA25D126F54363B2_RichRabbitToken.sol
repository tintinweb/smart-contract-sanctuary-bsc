/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @dev collections of functions ralted to the address type
 */
library Address {
    
    /**
     * @dev returns true if `account` is a contract
     */
    function isContract(address account) internal view returns(bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly{
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    
    /**
     * @dev replacement for solidity's `transfer`: sends `amount` wei to `recipient`,
     * forwarding all available gas and reverting on errors;
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance.");
        
        (bool success,) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted.");
    }
    
    /**
     * @dev performs a solidity function call using a low level `call`. A plain `call` is an
     * unsafe replacement for a function call: use this function instead.
     */
    function functionCall(address target, bytes memory data) internal returns(bytes memory) {
        return functionCall(target, data, "Address: low-level call failed.");
    }
    
    function functionCall(address target, bytes memory data, string memory errMsg) internal returns(bytes memory) {
        return _functionCallWithValue(target, data, 0, errMsg);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errMsg) private returns(bytes memory) {
        require(isContract(target), "Address: call to non-contract.");
        
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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
                revert(errMsg);
            }
        }
    }
    
}



library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow.");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        return sub(a, b, "SafeMath: subtraction overflow.");
    }
    
    function sub(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b <= a, errMsg);
        uint256 c = a - b;
        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0){
            return 0;
        }
        
        uint256 c = a * b;
        require(c/a == b, "SafeMath: mutiplication overflow.");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero.");
    }
    
    function div(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b > 0, errMsg);
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero.");
    }
    
    function mod(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b != 0, errMsg);
        return a % b;
    }
    
}




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

interface IUniswapV2Router01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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


/*
@title Dividend-Paying Token Interface
@author Roger Wu (https://github.com/roger-wu)
@dev An interface for a dividend-paying token contract.
*/
interface IDividendPayingToken {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) external view returns(uint256);

  /// @notice Distributes ether to token holders as dividends.
  /// @dev SHOULD distribute the paid ether to token holders as dividends.
  ///  SHOULD NOT directly transfer ether to token holders in this function.
  ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
  // function distributeDividends() external payable;

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}


/*
@title Dividend-Paying Token Optional Interface
@author Roger Wu (https://github.com/roger-wu)
@dev OPTIONAL functions for a dividend-paying token contract.
*/
interface IDividendPayingTokenOptional {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}


interface IDividendTracker {

    function owner() external view returns (address) ;

    function withdrawableDividendOf(address account) external view returns(uint256) ;

    function withdrawnDividendOf(address account) external view returns(uint256) ;

    function getExcludedFromDividends(address account) external view returns(bool) ;

    function swapAndDistributeDividends() external ;
    
    function excludeFromDividends(address account) external ;

    function setBalance(address payable account, uint256 newBalance) external ;
    
    function process(uint256 gas) external returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) ;

    function setDividendLimit(uint256 limit) external ;

    function setDividendTokenAddress(address newToken) external ;

    function updateClaimWait(uint256 newClaimWait) external ;
}


interface IFomo {
    function transferNotify(address user, uint256 buyUsdtAmount) external;

    function swap() external;

    function getCandidate() external view returns(address) ;

    function getLastTransfer() external view returns(uint256) ;
}


interface IERC20 {
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
}


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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
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
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



contract RichRabbitToken is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isBlack;
    address public rrtWbnbPair;// pair of this token and bnb
    address public usdtWbnbPair;// pair of usdt and bnb
    IDividendTracker public dividendTracker;
    IFomo public fomoTracker;
    IUniswapV2Router02 public uniswapV2Router;

    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public blackhole = 0x0000000000000000000000000000000000000000;
    address public divReceiver;
    address public fomoReceiver;

    bool private inSwap = false;
    bool public enableFee = true;// Whether to charge transaction fees
    bool public isAutoDividend = true;// Whether to automatically distribute dividends
    bool public isAutoSwapFomo = true;// Whether to automatically distribute fomo
    uint8 private _decimals = 18;
    uint256 public maxTotal = 100 * 10 ** 7 * 10 ** _decimals ;
    uint256 public minimumAmountToSwap = 20 * 10 ** _decimals; // min (usdt) amount of tarcker to sell
    
    uint256 public gasForProcessing = 300000; // gas for a dividend
    uint256 constant internal priceMagnitude = 2 ** 64;
    uint256 public basePrice;
    uint256 public basePriceTimeInterval = 4320;
    uint256 public basePricePreMin = 180;
    uint256 public lastBasePriceTimestamp;
    uint256 public startTimestamp;
    uint256 public sellRateUpper = 1; // For every 1% higher than the benchmark price, the sliding point will increase by 1%
    uint256 public sellRateBelow = 2; // For each 1% lower than the benchmark price, the sliding point will increase by 2%
    uint256 public highestSellTaxRate = 400; // The maximum sliding point is not more than 40% (magnified by 10 times)
    uint256 public minimumSellTaxRate = 50; // The minimum sliding point shall not be less than 5% (magnified by 10 times)
    uint256 public fixSellSlippage = 0; // Magnified by 10 times, such as 300, representing 30% slip point, and 1 represents 0.1%
    uint256 public currentSellRate = 0;
    uint256 public amountToBlackAfterLaunch = 20; // The number of users who bought the first [few] transactions after the launch will be blacklisted
    uint256 public alreadyToBlackAfterLaunch = 0; // Number of blacklisted transactions after launch
    uint8 public dividendFeeRate = 70; //70% to dividend
    uint8 public fomoFeeRate = 30; //30% to fomo


    constructor() ERC20("RichRabbit", "RICHRABBIT") {
        uniswapV2Router = IUniswapV2Router02(router);
        wbnb = uniswapV2Router.WETH();
        startTimestamp = block.timestamp;

        _isExcludedFromFee[blackhole] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(uniswapV2Router)] = true;

        _mint(owner(), maxTotal);
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "Sender and reciever must be different");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlack[from], "You can not transfer.");
        
        //check and update pairs
        _checkLps();
        
        if((from == rrtWbnbPair || to == rrtWbnbPair) && enableFee) { 
            _updateBasePrice();
            currentSellRate = _getSellTaxRate();
        }

        //Sell tokens in the tracker/fomo when sell base token
        if(to == rrtWbnbPair){
            if (!inSwap) {
                inSwap = true;
            
                uint256 fomoBalInUsdt = getAmountOutUsdt(balanceOf(fomoReceiver));
                uint256 divBalInUsdt = getAmountOutUsdt(balanceOf(divReceiver));
                if(fomoBalInUsdt >= minimumAmountToSwap && divBalInUsdt >= minimumAmountToSwap){
                    if(from != fomoReceiver && isAutoSwapFomo) {
                        fomoTracker.swap();
                    }
                } else {
                    if(fomoBalInUsdt >= minimumAmountToSwap && from != fomoReceiver && isAutoSwapFomo) {
                        fomoTracker.swap();
                    }
                    if(divBalInUsdt >= minimumAmountToSwap && from != divReceiver && isAutoDividend){
                        dividendTracker.swapAndDistributeDividends();
                    }
                }

                inSwap = false;
            }
            
        }

        if(to == rrtWbnbPair){
            if(_isExcludedFromFee[from] || !enableFee){
                super._transfer(from, to, amount);
            } else {
                _transferSellStandard(from, to, amount);
            }
        } else {
            super._transfer(from, to, amount);
        }
        
        if(from == rrtWbnbPair && to != router){
            //when buy and not remove LP
            //The addresses of the first [amountToBlackAfterLaunch] purchases after launch are automatically blacklisted
            if(alreadyToBlackAfterLaunch < amountToBlackAfterLaunch){
                _isBlack[to] = true;
                alreadyToBlackAfterLaunch++;
            }

            fomoTracker.transferNotify(to, getAmountOutUsdt(amount));
        }

        dividendTracker.setBalance(payable(from), balanceOf(from));
        dividendTracker.setBalance(payable(to), balanceOf(to));
        
        if((from == rrtWbnbPair || to == rrtWbnbPair) && !inSwap && isAutoDividend) {
            uint256 gas = gasForProcessing;
            (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
            emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
        }
    }

    function _checkLps() private {
        //create a uniswap pair for this new token
        address _rrtWbnbPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), wbnb);
        if (rrtWbnbPair != _rrtWbnbPair) {
            rrtWbnbPair = _rrtWbnbPair;
            dividendTracker.excludeFromDividends(address(_rrtWbnbPair));
        }
        
        address _usdtWbnbPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(usdt), wbnb);
        if (usdtWbnbPair != _usdtWbnbPair) {
            usdtWbnbPair = _usdtWbnbPair;
            dividendTracker.excludeFromDividends(address(_usdtWbnbPair));
        }
    }

    function _updateBasePrice() private {
        (uint256 _rrtReserve, uint256 _wbnbReserve) = _getRrtWbnbReserves();
        if(_rrtReserve <= 0 || _wbnbReserve <= 0) return;

        uint256 _currentPrice = getLpPriceNow();
        if(lastBasePriceTimestamp == 0) {
            lastBasePriceTimestamp = block.timestamp;
            basePrice = _currentPrice;
            return;
        }

        uint256 lastTimeMin = lastBasePriceTimestamp.div(60);
        uint256 currentTimeMin = block.timestamp.div(60);
        if(lastTimeMin == currentTimeMin) return;

        uint256 startMin = startTimestamp.div(60);
        uint256 minSinceBegin = currentTimeMin.sub(startMin).add(1);
        uint256 timeInterval = basePriceTimeInterval;
        
        if (currentTimeMin > lastTimeMin) {
            uint256 minSinceLast = currentTimeMin.sub(lastTimeMin);
            if (minSinceBegin > timeInterval) {
                if (minSinceLast > timeInterval) {
                    basePrice = _currentPrice;
                } else {
                    basePrice = basePrice.mul(timeInterval.sub(minSinceLast)).div(timeInterval).add(_currentPrice.mul(minSinceLast).div(timeInterval));
                }
            } else {
                uint256 denominator = minSinceBegin.add(basePricePreMin);
                basePrice = basePrice.mul(denominator.sub(minSinceLast)).div(denominator).add(_currentPrice.mul(minSinceLast).div(denominator));
            }
        }

        lastBasePriceTimestamp = block.timestamp;
    }

    function _getRrtWbnbReserves() private view returns(uint256 _rrtReserve, uint256 _wbnbReserve) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(rrtWbnbPair).getReserves();
        address token0 = IUniswapV2Pair(rrtWbnbPair).token0();
        if(token0 == address(this)){
            _rrtReserve = uint256(reserve0);
            _wbnbReserve = uint256(reserve1);
        } else {
            _rrtReserve = uint256(reserve1);
            _wbnbReserve = uint256(reserve0);
        }
    }

    function _getWbnbUsdtReserves() private view returns(uint256 _wbnbReserve, uint256 _usdtReserve) {
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(usdtWbnbPair).getReserves();
        address token0 = IUniswapV2Pair(usdtWbnbPair).token0();
        if (token0 == wbnb) {
            _wbnbReserve = uint256(reserve0);
            _usdtReserve = uint256(reserve1);
        } else {
            _wbnbReserve = uint256(reserve1);
            _usdtReserve = uint256(reserve0);
        }
    }

    function getLpPriceNow() public view returns(uint256) {
        (uint112 rwreserve0, uint112 rwreserve1, ) = IUniswapV2Pair(rrtWbnbPair).getReserves();
        if(rwreserve0 == 0 || rwreserve1 == 0){
            return 0;
        }
        address rwtoken0 = IUniswapV2Pair(rrtWbnbPair).token0();
        uint256 rrtPriceInWbnb;
        if(rwtoken0 == address(this)){
            rrtPriceInWbnb = uint256(rwreserve1).mul(priceMagnitude).div(uint256(rwreserve0));
        } else {
            rrtPriceInWbnb = uint256(rwreserve0).mul(priceMagnitude).div(uint256(rwreserve1));
        }

        (uint112 uwreserve0, uint112 uwreserve1, ) = IUniswapV2Pair(usdtWbnbPair).getReserves();
        if(uwreserve0 == 0 || uwreserve1 == 0){
            return 0;
        }
        address uwtoken0 = IUniswapV2Pair(usdtWbnbPair).token0();
        uint256 wbnbPriceInUsdt;
        if(uwtoken0 == wbnb){
            wbnbPriceInUsdt = uint256(uwreserve1).mul(priceMagnitude).div(uint256(uwreserve0));
        } else {
            wbnbPriceInUsdt = uint256(uwreserve0).mul(priceMagnitude).div(uint256(uwreserve1));
        }

        return rrtPriceInWbnb.mul(wbnbPriceInUsdt).div(priceMagnitude);
    }

    function _getSellTaxRate() private view returns (uint256) {
        if(fixSellSlippage > 0){
            return _convertToSellSlippage(fixSellSlippage);
        }

        uint256 rate = getBasePriceRate();
        if (rate == 0 || rate == 1000) {
            return _convertToSellSlippage(minimumSellTaxRate);
        }
        uint256 diff;
        uint256 rateToReturn;
        if (rate > 1000) {
            diff = rate.sub(1000);
            rateToReturn = diff.mul(sellRateUpper).add(minimumSellTaxRate);
            if (rateToReturn > highestSellTaxRate) {
                return _convertToSellSlippage(highestSellTaxRate);
            } else {
                return _convertToSellSlippage(rateToReturn);
            }
        }

        diff = uint256(1000).sub(rate);
        rateToReturn = diff.mul(sellRateBelow).add(minimumSellTaxRate);
        if (rateToReturn > highestSellTaxRate) {
            return _convertToSellSlippage(highestSellTaxRate);
        } else {
            return _convertToSellSlippage(rateToReturn);
        }
    }

    function getSellTaxRate() public view returns (uint256) {
        if(fixSellSlippage > 0){
            return (fixSellSlippage);
        }

        uint256 rate = getBasePriceRate();
        if (rate == 0 || rate == 1000) {
            return (minimumSellTaxRate);
        }
        uint256 diff;
        uint256 rateToReturn;
        if (rate > 1000) {
            diff = rate.sub(1000);
            rateToReturn = diff.mul(sellRateUpper).add(minimumSellTaxRate);
            if (rateToReturn > highestSellTaxRate) {
                return (highestSellTaxRate);
            } else {
                return (rateToReturn);
            }
        }

        diff = uint256(1000).sub(rate);
        rateToReturn = diff.mul(sellRateBelow).add(minimumSellTaxRate);
        if (rateToReturn > highestSellTaxRate) {
            return (highestSellTaxRate);
        } else {
            return (rateToReturn);
        }
    }

    function _convertToSellSlippage(uint256 taxRate) private pure returns(uint256) {
        return uint256(10000).sub(uint256(10000000).div(uint256(1000).add(taxRate)));
    }

    function getBasePriceRate() public view returns (uint256) {
        uint256 basePriceNow = getBasePriceNow();
        if (basePriceNow == 0) return 0;
        uint256 lpPrice = getLpPriceNow();
        if (lpPrice == 0) return 0;
        return lpPrice.mul(1000).div(basePriceNow);
    }

    function getBasePriceNow() public view returns(uint256) {
        uint256 _currentLpPrice = getLpPriceNow();
        if (basePrice == 0) return _currentLpPrice;
        uint256 lastTimeMin = lastBasePriceTimestamp.div(60);
        uint256 currentTimeMin = block.timestamp.div(60);
        uint256 timeInterval = basePriceTimeInterval;
        if (currentTimeMin == lastTimeMin) {
            return basePrice;
        } else {
            uint256 startMin = uint256(startTimestamp).div(60);
            uint256 minSinceBegin = currentTimeMin.sub(startMin).add(1);
            uint256 minSinceLast = currentTimeMin.sub(lastTimeMin);
            if (minSinceBegin > timeInterval) {
                if(minSinceLast > timeInterval) {
                    return _currentLpPrice;
                } else {
                    return basePrice.mul(timeInterval.sub(minSinceLast)).div(timeInterval).add(_currentLpPrice.mul(minSinceLast).div(timeInterval));
                }
            } else {
                uint256 denominator = minSinceBegin.add(basePricePreMin);
                return basePrice.mul(denominator.sub(minSinceLast)).div(denominator).add(_currentLpPrice.mul(minSinceLast).div(denominator));
            }
        }
    }

    function getAmountOutUsdt(uint256 tokenAmount) public view returns (uint256) {
        if (tokenAmount <= 0) return 0;
        (uint256 _rrtReserve, uint256 _wbnbReserve) = _getRrtWbnbReserves();
        if (_wbnbReserve <= 0 || _rrtReserve <= 0) return 0;
        uint256 wbnbOut = uint256(_getAmountOut(tokenAmount, _rrtReserve, _wbnbReserve));
        
        (uint256 _wbnbReserve1, uint256 _usdtReserve) = _getWbnbUsdtReserves();
        if (_wbnbReserve1 <= 0 || _usdtReserve <= 0) return 0;
        return uint256(_getAmountOut(wbnbOut, _wbnbReserve1, _usdtReserve)); 
    }

    function _getAmountOutWbnb(uint256 tokenAmount) private view returns (uint256) {
        if (tokenAmount <= 0) return 0;
        (uint256 _rrtReserve, uint256 _wbnbReserve) = _getRrtWbnbReserves();
        if (_wbnbReserve <= 0 || _rrtReserve <= 0) return 0;
        return uint256(_getAmountOut(tokenAmount, _rrtReserve, _wbnbReserve));
    }

    function _getAmountInRrt(uint256 amountOut) private view returns(uint256){
        (uint256 _rrtReserve, uint256 _wbnbReserve) = _getRrtWbnbReserves();
        if (_wbnbReserve <= 0 || _rrtReserve <= 0) return 0;
        return uint256(_getAmountIn(amountOut, _rrtReserve, _wbnbReserve));
    }

    function _getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) private pure returns (uint amountIn) {
        if (amountOut <= 0) return 0;
        if (reserveIn <= 0) return 0;
        if (reserveOut <= 0) return 0;
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) private pure returns (uint amountOut) {
        if (amountIn <= 0) return 0;
        if (reserveIn <= 0) return 0;
        if (reserveOut <= 0) return 0;
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function _transferSellStandard(address from, address to, uint256 amount) private {
        uint256 totalFee = _getSellFees(amount);
        uint256 dividentFee = totalFee.mul(dividendFeeRate).div(100);
        uint256 fomoFee = totalFee.mul(fomoFeeRate).div(100);
        uint256 transferAmount = amount.sub(totalFee);

        super._transfer(from, divReceiver, dividentFee);
        super._transfer(from, fomoReceiver, fomoFee);
        super._transfer(from, to, transferAmount);
    }

    function _getSellFees(uint256 amount) private view returns (uint256) {
        uint256 amountOutWbnb = _getAmountOutWbnb(amount);
        uint256 amountOutWbnbAfterFee = amountOutWbnb.sub(amountOutWbnb.mul(currentSellRate).div(10000));
        uint256 amountInRrt = _getAmountInRrt(amountOutWbnbAfterFee);
        uint256 fee = amount.sub(amountInRrt);
        return fee;
    }

    //***************************************************set parameters****************************************//

    function updateDividendTracker(address _newAddress) public onlyOwner {
        require(_newAddress != address(dividendTracker), "The dividend tracker already has that address");

        IDividendTracker _newDividendTracker = IDividendTracker(payable(_newAddress));
        divReceiver = address(_newDividendTracker);

        _newDividendTracker.excludeFromDividends(blackhole);
        _newDividendTracker.excludeFromDividends(owner());
        _newDividendTracker.excludeFromDividends(address(this));
        _newDividendTracker.excludeFromDividends(divReceiver);
        _newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        if (fomoReceiver != address(0)) {
            _newDividendTracker.excludeFromDividends(fomoReceiver);
        }
        
        if (rrtWbnbPair != address(0)) {
            _newDividendTracker.excludeFromDividends(rrtWbnbPair);
        }
        
        if (usdtWbnbPair != address(0)) {
            _newDividendTracker.excludeFromDividends(usdtWbnbPair);
        }

        _isExcludedFromFee[divReceiver] = true;

        dividendTracker = _newDividendTracker;
    }

    function updateFomoTracker(address _newAddress) public onlyOwner {
        require(_newAddress != address(fomoTracker), "The fomo tracker already has that address");

        IFomo _newFomoTracker = IFomo(payable(_newAddress));
        fomoReceiver = address(_newFomoTracker);

        dividendTracker.excludeFromDividends(fomoReceiver);      
        _isExcludedFromFee[fomoReceiver] = true;

        fomoTracker = _newFomoTracker;
    }

    function excludeFromFees(address _account, bool _excluded) public onlyOwner {
        require(_isExcludedFromFee[_account] != _excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFee[_account] = _excluded;
        emit ExcludeFromFees(_account, _excluded);
    }

    function getExcludeFromFee(address _addr) public view returns(bool) {
        return _isExcludedFromFee[_addr];
    }

    function joinBlack(address _account, bool _joined) public onlyOwner {
        require(_isBlack[_account] != _joined, "Account is already the value of '_joined'");
        _isBlack[_account] = _joined;
        emit JoinBlack(_account, _joined);
    }

    function getJoinBlack(address _addr) public view returns(bool) {
        return _isBlack[_addr];
    }

    function updateGasForProcessing(uint256 _newValue) public onlyOwner {
        require(_newValue >= 200000 && _newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(_newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = _newValue;
        emit GasForProcessingUpdated(_newValue, gasForProcessing);
    }

    function excludeFromDividends(address _addr) public onlyOwner{
        dividendTracker.excludeFromDividends(_addr);
    }

    function getExcludedFromDividends(address _account) public view returns (bool){
        return dividendTracker.getExcludedFromDividends(_account);
    }

    function setBasePriceTimeInterval(uint256 _basePriceTimeInterval) public onlyOwner{
        basePriceTimeInterval = _basePriceTimeInterval;
    }
    
    function setHighestSellTaxRate (uint256 _highestSellTaxRate) public onlyOwner{
        highestSellTaxRate = _highestSellTaxRate;
    }

    function setMinimumSellTaxRate (uint256 _minimumSellTaxRate) public onlyOwner{
        minimumSellTaxRate = _minimumSellTaxRate;
    }
    
    function setMinimumAmountToSwap(uint256 _minimumAmountToSwap) public onlyOwner{
        minimumAmountToSwap = _minimumAmountToSwap;
    }
    
    function setEnableFee(bool _enableFee) public onlyOwner{
        enableFee = _enableFee;
    }

    function setSellRateUpper(uint256 _newTax) public onlyOwner{
        sellRateUpper = _newTax;
    }

    function setSellRateBelow(uint256 _newTax) public onlyOwner{
        sellRateBelow = _newTax;
    }
    
    function setIsAutoDividend(bool _isAutoDividend) public onlyOwner{
        isAutoDividend = _isAutoDividend;
    }

    function setIsAutoSwapFomo(bool _isAutoSwapFomo) public onlyOwner{
        isAutoSwapFomo = _isAutoSwapFomo;
    }

    function updateFixSellSlippage(uint256 _fixSellSlippage) public onlyOwner{
        fixSellSlippage = _fixSellSlippage;
    }

    function setDividendLimit(uint256 _limit) public onlyOwner{
        dividendTracker.setDividendLimit(_limit);
    }

    function setDividendToken(address _newToken) public onlyOwner{
        dividendTracker.setDividendTokenAddress(_newToken);
    }

    function updateClaimWait(uint256 _claim) public onlyOwner{
        dividendTracker.updateClaimWait(_claim);
    }

    function withdrawableDividendOf(address _addr) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(_addr);
    }

    function withdrawnDividendOf(address _addr) public view returns(uint256) {
        return dividendTracker.withdrawnDividendOf(_addr);
    }

    function getFomoUsdt() public view returns(uint256) {
        return IERC20(usdt).balanceOf(fomoReceiver);
    }

    function getFomoCandidate() public view returns(address) {
        return fomoTracker.getCandidate();
    }

    function getLastTransfer() public view returns(uint256) {
        return fomoTracker.getLastTransfer();
    }

    function setDividendFeeRate(uint8 _dividendFeeRate) public onlyOwner{
        dividendFeeRate = _dividendFeeRate;
    }

    function setFomoFeeRate(uint8 _fomoFeeRate) public onlyOwner {
        fomoFeeRate = _fomoFeeRate;
    }

    function setAmountToBlackAfterLaunch(uint256 _amountToBlackAfterLaunch) public onlyOwner {
        amountToBlackAfterLaunch = _amountToBlackAfterLaunch;
    }


    //***************************************************Event****************************************//

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event JoinBlack(address indexed account, bool isJoined);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
}
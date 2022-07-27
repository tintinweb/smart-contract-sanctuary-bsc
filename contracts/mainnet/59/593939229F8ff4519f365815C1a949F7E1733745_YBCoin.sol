/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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


interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


interface IPancakePair {
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


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

interface IFriendInterface {
    function bindFriendsForContract(address _user_address, address _refer_address) external;

    function getFriendByLevel(address _user_address, uint256 _level) external view returns (address, uint256);

    function getReferDataLength(address _user_address) external view returns (uint256);

    function hasRefer(address _user_address) external view returns (bool);

    function set_totalAmount(address _user_address, uint256 amount) external;
}


contract Recv {
    IERC20 public tokenYBC;
    IERC20 public usdt;

    constructor (IERC20 _tokenYBC) {
        tokenYBC = _tokenYBC;
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(tokenYBC), usdtBalance);
        }
        uint256 tokenYBCBalance = tokenYBC.balanceOf(address(this));
        if (tokenYBCBalance > 0) {
            tokenYBC.transfer(address(tokenYBC), tokenYBCBalance);
        }
    }
}

contract YBCoin is ERC20Burnable, Ownable {


    uint256 public _swapRate_to_burn = 10;
    uint256 private _swapRate_to_YBC_LP_USDT = 10;
    uint256 public _swapRate_to_nft = 10;
    uint256 public _swapRate_to_return = 20;
    uint256 public _swapRate_to_re = 10;

    address public _NFT_address;
    address public _PledgeYBCLP_address;
    address private _splitter_address;

    bool private _inSwapAndLiquify;

    Recv public _receive_contract;


    mapping(address => bool) private _isSwapInclude;
    mapping(address => bool) private _isSwap_LP_Include;
    mapping(address => bool) private _special_list;


    uint256 private _startTime;

    address public _mdx_Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private _USDT_address = address(0x55d398326f99059fF775485246999027B3197955);

    address public _YBC_LP_USDT_address;//YBC LP地址
    IPancakeRouter02 public _mdx_V2Router02;
    IPancakePair public _mdx_V2Pair;

    uint256 private _minSwapNumber = 1 * 10 ** 18;//最兑换数量
    uint256 private _reNumber = 1 * 10 ** 17;//推荐锁粉数量
    uint256 private _maxSupply = 210000000 * 10 ** 18;//最大发行量
    uint256 private _remainSwapNumber;//剩余兑换数量
    uint public _minAddLiquidityNumber = 1 * 10 ** 18;

    bool private _is_not_slippage = true;//是否允许滑点
    bool private _no_slippage_swap_t = true;//

    address public _friend_address;

    mapping(address => uint256) private _total_deposit_from_buy;
    mapping(address => uint256) private _total_deposit_timeTemp;
    mapping(address => uint256) private _last_time;
    mapping(address => uint256) private _can_trade_amount;
    uint256 private _part_rate = 10;//分成比例
    uint256 private _one_day_second = 24 * 60 * 60;

    mapping(address => uint256) private _buy_usdt_total;
    mapping(address => uint256) private _sell_usdt_total;

    address public _YaBoWorld_address;



    constructor(
        string memory name,
        string memory symbol,
        address owner
    ) ERC20(name, symbol) {
        _YaBoWorld_address = owner;
        _mint(owner, _maxSupply);
        _special_list[_msgSender()] = true;
        _special_list[address(this)] = true;
        _startTime = block.timestamp + 356 days;
        _receive_contract = new Recv(IERC20(address(this)));
        _mdx_V2Router02 = IPancakeRouter02(_mdx_Router);
        _YBC_LP_USDT_address = IPancakeFactory(_mdx_V2Router02.factory()).createPair(
            address(this),
            _USDT_address
        );
        _isSwapInclude[_mdx_Router] = true;
        _isSwap_LP_Include[_YBC_LP_USDT_address] = true;
        _special_list[_msgSender()] = true;
        _mdx_V2Pair = IPancakePair(_YBC_LP_USDT_address);


    }


    /**
     * @dev Transfer `amount` tokens from the caller to `to`.
     * See {ERC20-transfer}.
     * (1) 滑点:6%，买入卖出都是 6%
     * (2) 销毁:1%
     * (3) NFT:1%
     * (4) 底池回流:2%
     * (5) DKF-LP 分红:1%（USDT）
     * (6) 推荐人拿十层:1%（USDT）
     * 增加转币锁粉功能，只要接收地址的ybc为零就开始绑定关系
     */

    function _can_trade(address _user_address) public view returns (uint256) {
        uint256 amount = _total_deposit_from_buy[_user_address];
        uint256 time = _total_deposit_timeTemp[_user_address];
        if (amount > 0 && _can_trade_amount[_user_address] <= amount && time < _last_time[_user_address] ) {
            
            if (block.timestamp - time > _one_day_second && block.timestamp <= _last_time[_user_address]) {
                uint256 s = block.timestamp - time;
                uint256 times = s / _one_day_second;
                uint256 l = amount * _part_rate / 1000 * times;
                uint256 remainder = s - times * _one_day_second;
                uint256 interest = l + amount * _part_rate * remainder / _one_day_second / 1000;
                return interest;
            } else if (block.timestamp - time < _one_day_second && block.timestamp <= _last_time[_user_address])
            {
                uint256 remainder = block.timestamp - time;
                uint256 interest = amount * _part_rate * remainder / _one_day_second / 1000;
                return interest;
            }
            else {
                return 0;
            }
        } else {
            return 0;
        }

    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (super.balanceOf(address(this)) > 0 && from != address(this) && !_isSwapInclude[to] && !_isSwap_LP_Include[to] && !_isSwapInclude[from] && !_isSwap_LP_Include[from] && !_inSwapAndLiquify) {
            _checkLiquidity();
        }

        if (_special_list[from] == true || _special_list[to] == true) {
            super._transfer(from, to, amount);
            if (_no_slippage_swap_t == true) {
                if (_special_list[from] == true) {
                    _can_trade_amount[to] += amount;
                    _total_deposit_from_buy[to] += amount;
                } else
                {

                    if (_can_trade_amount[from] > amount)
                    {
                        _can_trade_amount[from] -= amount;
                    } else
                    {
                        _can_trade_amount[from] = 0;
                    }
                    _total_deposit_from_buy[from] -= amount;
                }

            }

            return;
        } else if (_isSwap_LP_Include[from] && !_isSwapInclude[to]) {

            require(_startTime < block.timestamp, "The time is not started");
            if (_is_not_slippage == true) {
                if (_no_slippage_swap_t == true) {

                    uint256 _to_amount = _splitter(from, to, amount);
                    uint256 c = _can_trade(to);
                    _can_trade_amount[to] += c;
                    _total_deposit_from_buy[to] += _to_amount;
                    _total_deposit_from_buy[to] -= c;
                    _total_deposit_timeTemp[to] = block.timestamp;
                    _last_time[to] = block.timestamp + 100 * _one_day_second;

                    uint256 usdt_price = get_amountsOUt(_to_amount);
                    _buy_usdt_total[to] += usdt_price;

                    if (IFriendInterface(_friend_address).hasRefer(to) == true) {
                        address refer;
                        (refer,) = IFriendInterface(_friend_address).getFriendByLevel(to, 0);
                        _can_trade_amount[refer] += amount * 5 / 100;
                    }
                } else
                {
                    _splitter(from, to, amount);
                }

            } else {
                super._transfer(from, to, amount);
            }
            return;

        } else if (_isSwap_LP_Include[to] && !_isSwapInclude[from]) {

            require(_startTime < block.timestamp, "The time is not started");
            if (_is_not_slippage == true) {
                if (_no_slippage_swap_t == true) {
                    if (_sell_usdt_total[from] > _buy_usdt_total[from]) {
                        if (_last_time[from] - block.timestamp > _one_day_second && _total_deposit_from_buy[from] - _can_trade_amount[from] > 0) {
                            _can_trade_amount[from] += _can_trade(from);
                            _total_deposit_timeTemp[from] = block.timestamp;
                            require(_can_trade_amount[from] >= amount, "can't trade");
                            _splitter(from, to, amount);
                            _can_trade_amount[from] -= amount;
                            _total_deposit_from_buy[from] = (_total_deposit_from_buy[from] - _can_trade_amount[from]) * 90 / (_last_time[from] - block.timestamp) / _one_day_second;
                            super._burn(_YBC_LP_USDT_address, amount * 10 / 100);
                            _sell_usdt_total[from] += get_amountsOUt(amount);
                        } else if (_total_deposit_from_buy[from] == _can_trade_amount[from]) {
                            _can_trade_amount[from] += _can_trade(from);
                            _total_deposit_timeTemp[from] = block.timestamp;
                            require(_can_trade_amount[from] >= amount, "can't trade");

                            _splitter(from, to, amount * 90 / 100);

                            super._burn(from, amount - amount * 90 / 100);

                            super._burn(_YBC_LP_USDT_address, amount * 10 / 100);
                            _can_trade_amount[from] -= amount;
                            _sell_usdt_total[from] += get_amountsOUt(amount);
                        } else
                        {
                            _total_deposit_from_buy[from] = _can_trade_amount[from];
                        }
                    } else {
                        _can_trade_amount[from] += _can_trade(from);
                        _total_deposit_timeTemp[from] = block.timestamp;
                        require(_can_trade_amount[from] >= amount, "can't trade");
                        _splitter(from, to, amount);
                        _can_trade_amount[from] -= amount;
                        _sell_usdt_total[from] += get_amountsOUt(amount);
                    }
                } else
                {
                    _splitter(from, to, amount);
                }


            } else {
                super._transfer(from, to, amount);
            }
            return;


        } else {
            if (_is_not_slippage == true) {
                if (super.balanceOf(to) == 0) {
                    if (super.balanceOf(from) == _reNumber && amount == _reNumber) {
                        if (IFriendInterface(_friend_address).hasRefer(to) == false) {
                            IFriendInterface(_friend_address).bindFriendsForContract(to, from);
                            super._transfer(from, to, amount);
                            super._mint(from, amount);
                            super._burn(_YaBoWorld_address, amount);
                        } else {
                            super._transfer(from, to, amount);
                        }


                    } else {
                        if (IFriendInterface(_friend_address).hasRefer(to) == false) {
                            IFriendInterface(_friend_address).bindFriendsForContract(to, from);
                        }

                        _can_trade_amount[from] += _can_trade(from);
                        _total_deposit_timeTemp[from] = block.timestamp;
                        require(_can_trade_amount[from] >= amount, "can't trade");
                        _can_trade_amount[from] -= amount;
                        _can_trade_amount[to] += amount;

                        _splitter(from, to, amount);

                    }
                } else {

                    _can_trade_amount[from] += _can_trade(from);
                    _total_deposit_timeTemp[from] = block.timestamp;
                    require(_can_trade_amount[from] >= amount, "can't trade");
                    _can_trade_amount[from] -= amount;
                    _can_trade_amount[to] += amount;

                    _splitter(from, to, amount);
                }

            } else {
                super._transfer(from, to, amount);
            }
        }
    }


    function get_amountsOUt(uint256 amount) public view returns (uint256) {
        address[] memory t = new address[](2);
        t[0] = address(this);
        t[1] = _USDT_address;
        return _mdx_V2Router02.getAmountsOut(amount, t)[1];
    }

    function get_amountsOUtYBC(uint256 amount) public view returns (uint256) {
        address[] memory t = new address[](2);
        t[0] = _USDT_address;
        t[1] = address(this);
        return _mdx_V2Router02.getAmountsOut(amount, t)[1];
    }

    function _splitter(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 _to_burn = amount * _swapRate_to_burn / 1000;
        uint256 _to_YBC_LP_USDT = amount * _swapRate_to_YBC_LP_USDT / 1000;
        uint256 _to_nft = amount * _swapRate_to_nft / 1000;
        uint256 _to_re3 = amount * _swapRate_to_re / 1000;
        uint256 _to_lp = amount * _swapRate_to_return / 1000;

        _to_re(from, _to_re3);
        uint256 _to_amount = amount - _to_burn - _to_YBC_LP_USDT - _to_nft - _to_re3 - _to_lp;
        super._transfer(from, address(this), _to_lp);
        super._transfer(from, _PledgeYBCLP_address, _to_YBC_LP_USDT);
        super._transfer(from, _NFT_address, _to_nft);
        super._burn(from, _to_burn);
        super._transfer(from, to, _to_amount);
        super._mint(from, 1);
        super._burn(_YaBoWorld_address, 1);
        return _to_amount;
    }

    function _to_re(address from, uint256 amount) internal {
        uint256 _part = amount / 10;
        uint256 _mark;
        uint256 k = IFriendInterface(_friend_address).getReferDataLength(from);
        if (k > 0) {
            for (uint256 i = 0; i < k; i++) {
                address referAddress;
                uint256 referAmount;
                (referAddress, referAmount) = IFriendInterface(_friend_address).getFriendByLevel(from, i);
                if (referAddress != address(0)) {
                    if (referAmount >= i) {
                        super._transfer(from, referAddress, _part);
                        _mark += _part;
                    }
                }
            }
            if (_mark < amount) {
                super._transfer(from, address(this), amount - _mark);
            }
        } else {
            super._transfer(from, address(this), amount);
        }

    }


    function _addLiquidity(uint256 amountADesired, uint256 amountBDesired) internal {

        _mdx_V2Router02.addLiquidity(address(this), _USDT_address, amountADesired, amountBDesired, 0, 0, _splitter_address, block.timestamp + 60);
    }

    function _checkLiquidity() internal lockTheSwap {

        uint amount = super.balanceOf(address(this));
        if (IERC20(address(this)).allowance(address(this), _mdx_Router) < amount) {
            IERC20(address(this)).approve(_mdx_Router, type(uint).max);
        }
        if (IERC20(_USDT_address).allowance(address(this), _mdx_Router) < amount) {
            IERC20(_USDT_address).approve(_mdx_Router, type(uint).max);
        }
        if (amount >= _minAddLiquidityNumber) {
            uint half = amount / 2;
            uint otherHalf = amount - half;
            _swapTokensForTokens(half);
            uint newBalance = IERC20(_USDT_address).balanceOf(address(this));
            if (newBalance > 0) {
                _addLiquidity(otherHalf, newBalance);

            }

        }
    }

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    function _swapTokensForTokens(uint amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_USDT_address);
        _mdx_V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, address(_receive_contract), block.timestamp + 60);
        _receive_contract.withdraw();
    }


    function set_isSwapIncludes(address _address) external onlyOwner{

        _isSwapInclude[_address] = true;
    }

    function set_is_not_slippage(bool _bool) external onlyOwner{

        _is_not_slippage = _bool;
    }

    function set_isSwap_LP_Includes(address _address) external onlyOwner{
 
        _isSwap_LP_Include[_address] = true;
    }

    function set_special_list(address _address, bool f) external onlyOwner{

        _special_list[_address] = f;
    }

    function set_startTime(uint256 _time) external onlyOwner{

        _startTime = _time;
    }

    function set_friend_address(address _address) external onlyOwner{

        _friend_address = _address;
    }

    function set_YBC_LP_USDT_address(address _address) external onlyOwner{
  
        _YBC_LP_USDT_address = _address;
    }

    function set_NFT_address(address _address) external onlyOwner{

        _NFT_address = _address;
    }

    function set_PledgeYBCLP_address(address _address) external onlyOwner{

        _PledgeYBCLP_address = _address;
    }

    function get_inSwapAndLiquify() public view returns (bool) {
        return _inSwapAndLiquify;
    }

    function set_part_rate(uint256 _rate) external onlyOwner{

        _part_rate = _rate;
    }

    function set_minAddLiquidityNumber(uint256 _number) external onlyOwner{

        _minAddLiquidityNumber = _number;
    }

    function set_splitter_address(address _address) external onlyOwner{

        _splitter_address = _address;
    }

    function get_total_deposit_from_buy(address _address) public view returns (uint256) {
        return _total_deposit_from_buy[_address];
    }

    function get_total_deposit_timeTemp(address _address) public view returns (uint256) {
        return _total_deposit_timeTemp[_address];
    }

    function get_last_time(address _address) public view returns (uint256) {
        return _last_time[_address];
    }

    function get_can_trade_amount(address _address) public view returns (uint256) {
        return _can_trade_amount[_address];
    }

    function set_reNumber(uint256 _number) external onlyOwner{

        _reNumber = _number;
    }

    function set_YaBoWorld_address(address _address) external onlyOwner{

        _YaBoWorld_address = _address;
    }

    function set_no_slippage_swap_t(bool f) external onlyOwner{
 
        _no_slippage_swap_t = f;
    }


    function get_buy_usdt_total(address _address) public view returns (uint256) {
        return _buy_usdt_total[_address];
    }

    function get_sell_usdt_total(address _address) public view returns (uint256) {
        return _sell_usdt_total[_address];
    }
}
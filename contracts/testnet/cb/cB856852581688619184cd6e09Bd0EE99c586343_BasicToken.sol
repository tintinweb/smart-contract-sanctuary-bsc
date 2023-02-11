/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBEP20Token {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external;

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2FactoryToken {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01Token {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

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

interface IUniswapV2Router02Token is IUniswapV2Router01Token {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IWETHToken {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
}

library AddressToken {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "AddressToken: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "AddressToken: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "AddressToken: low-level call failed");
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "AddressToken: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-AddressToken-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "AddressToken: insufficient balance for call");
        require(isContract(target), "AddressToken: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "AddressToken: low-level static call failed");
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "AddressToken: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "AddressToken: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-AddressToken-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "AddressToken: delegate call to non-contract");

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

abstract contract AuthToken {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract ContextToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeERC20Token {
    using AddressToken for address;

    function safeTransfer(
        IBEP20Token token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20Token token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20Token-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20Token token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20Token: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20Token token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20Token token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20Token: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20Token token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {AddressToken.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20Token: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20Token: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Implementation of the {IBEP20Token} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP20Token
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20Token-approve}.
 */
contract BEP20Token is ContextToken, IBEP20Token {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
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
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20Token-balanceOf} and {IBEP20Token-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20Token-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20Token-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20Token-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override {
        address owner = _msgSender();
        _transfer(owner, to, amount);
    }

    /**
     * @dev See {IBEP20Token-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20Token-approve}.
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
     * @dev See {IBEP20Token-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20Token}.
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
    function transferFrom(address from, address to, uint256 amount) public virtual override {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20Token-approve}.
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
     * problems described in {IBEP20Token-approve}.
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
        require(currentAllowance >= subtractedValue, "BEP20Token: decreased allowance below zero");
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
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "BEP20Token: transfer from the zero address");
        require(to != address(0), "BEP20Token: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20Token: transfer amount exceeds balance");
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
        require(account != address(0), "BEP20Token: mint to the zero address");

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
        require(account != address(0), "BEP20Token: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20Token: burn amount exceeds balance");
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20Token: approve from the zero address");
        require(spender != address(0), "BEP20Token: approve to the zero address");

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
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20Token: insufficient allowance");
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

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
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}


contract BasicStaking is BEP20Token, AuthToken {
    using SafeERC20Token for IBEP20Token;

    address public stakingToken;

    bool public isStart;
    uint256 public timeStart;
    uint256 public timeEnd;

    uint256 public totalStakedToken;
    uint256 public totalAddressStaked;
    uint256 public totalClaimedReward;
    uint256 public totalAllocationReward;

    uint256 public interestRate;
    uint256 public interestRateDenominator;

    uint256 public withdrawFee = 0;

    struct Stake {
        address ownerAddress;
        uint256 balance;
        uint256 startStake;
        uint256 claimedReward;
        uint256 allocationReward;
        uint256 startTimestamp;
        uint256 checkPointTimestamp;
    }

    mapping(address => Stake) private _stakers;

    constructor(address _token, address owner) BEP20Token("ChainedX Staking Protocol", "ChainedX-SP") AuthToken(owner) {
        // _setOwner(msg.sender);
        interestRate = 8;
        interestRateDenominator = 1000;
        stakingToken = _token;
        withdrawFee = 1000000000000000; //default is 0.001
    }

    receive() external payable {}

    fallback() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }

        if (token == stakingToken && isStart) {
            uint256 availableAmount = getAvailableRefundToken();
            require(availableAmount > 0, "Token is not enough to claim");
            IBEP20Token ERC20StakingToken = IBEP20Token(token);
            ERC20StakingToken.safeTransfer(msg.sender, availableAmount);
            return;
        }

        IBEP20Token ERC20token = IBEP20Token(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.safeTransfer(msg.sender, balance);
    }

    function getAvailableRefundToken() public view returns (uint256) {
        IBEP20Token ERC20token = IBEP20Token(stakingToken);
        uint256 balance = ERC20token.balanceOf(address(this));

        uint256 availableAmount = balance -
            totalStakedToken -
            totalAllocationReward;

        return availableAmount;
    }

    function getAPR() external view returns (uint256) {
        uint256 APR = (365 * interestRate) / 10;

        return APR;
    }

    function getTimeLeft() external view returns (uint256) {
        require(isStart, "Cannot read time left before start pool");
        uint256 timeLeft = timeEnd - block.timestamp;

        return timeLeft;
    }

    function getRewardPerTimestamp(uint256 amount) public view returns (uint256) {
        uint256 rewardPerTimestamp = (amount * interestRate) /
            interestRateDenominator;

        return rewardPerTimestamp;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("Staking Token Cannot transfered");
    }

    function setStakingToken(address _stakingToken) external onlyOwner {
        require(
            stakingToken != _stakingToken,
            "Staking token already that address"
        );
        require(!isStart, "Cannot set Staking Token after pool start");
        require(
            _stakingToken.code.length > 0,
            "Only contract can set as Staking Token"
        );

        stakingToken = _stakingToken;
    }

    function startPool() external onlyOwner {
        require(!isStart, "Pool already started");
        require(stakingToken != address(0), "Staking token still not set");

        IBEP20Token ERC20token = IBEP20Token(stakingToken);
        uint256 balance = ERC20token.balanceOf(address(this));

        require(
            balance > 0,
            "Contract Balance of Staking Token should not zero"
        );

        isStart = true;

        timeStart = block.timestamp;
        timeEnd = timeStart + 250 days;
        // timeEnd = timeStart + 5 minutes;
        // timeEnd = timeStart + 10 seconds;
    }

    function getClaimedReward(address account) public view returns (uint256) {
        return _stakers[account].claimedReward;
    }

    function getAvailableClaimReward(address account)
        public
        view
        returns (uint256)
    {
        uint256 lastTimestamp = block.timestamp > timeEnd ? timeEnd : block.timestamp;
        uint256 balance = _stakers[account].balance;
        uint256 startCountTimestamp = _stakers[account].checkPointTimestamp;
        uint256 rewardPerTimestamp = getRewardPerTimestamp(balance);
        uint256 availableTimestamp = lastTimestamp - startCountTimestamp;
        uint256 availableClaimReward = rewardPerTimestamp * availableTimestamp;

        return availableClaimReward;
    }

    function getForecastReward(address account) public view returns (uint256) {
        uint256 balance = _stakers[account].balance;
        uint256 forecastReward = _getForecastRewardByAmount(balance);

        return forecastReward;
    }

    function _getForecastRewardByAmount(uint256 amount)
        internal
        view
        returns (uint256)
    {
        if(block.timestamp > timeEnd) return 0;
        uint256 rewardPerTimestamp = getRewardPerTimestamp(amount);
        uint256 availableTimestamp = timeEnd - block.timestamp;
        uint256 forecastReward = rewardPerTimestamp * availableTimestamp;

        return forecastReward;
    }

    function getTotalAccumulatedReward(address account)
        external
        view
        returns (uint256)
    {
        uint256 claimedReward = getClaimedReward(account);
        uint256 availableReward = getAvailableClaimReward(account);
        uint256 forecastReward = getForecastReward(account);

        uint256 totalAccumulatedReward = claimedReward +
            availableReward +
            forecastReward;

        return totalAccumulatedReward;
    }

    function setWithdrawFee(uint256 fee) external onlyOwner {
        require(fee <= 100000000000000000,"Fee maximum is 0.1 BNB");
        withdrawFee = fee;
    }

    function claimReward(address account) internal {
        uint256 availableReward = getAvailableClaimReward(account);

        require(availableReward > 0, "Cannot claim 0 reward");

        IBEP20Token ERC20token = IBEP20Token(stakingToken);
        ERC20token.safeTransfer(account, availableReward);

        totalClaimedReward += availableReward;
        totalAllocationReward -= availableReward;

        _stakers[account].claimedReward += availableReward;
        _stakers[account].allocationReward = 0;
        _stakers[account].checkPointTimestamp = block.timestamp;
    }

    function deposit(uint256 amount) external payable {
    
        require(isStart, "Cannot deposit Staking Token before pool start");
        require(timeEnd > block.timestamp, "Cannot deposit after pool ended");

        require(amount > 0, "Deposit amount must be greater than 0");

        uint256 availableTokenLeft = getAvailableRefundToken();
        uint256 oldForecastAmount = _getForecastRewardByAmount(amount);

        require(
            availableTokenLeft > oldForecastAmount,
            "Reward Amount not enough for deposit amount, please contact owner for Deposit Reward Allocation"
        );
  
        IBEP20Token ERC20token = IBEP20Token(stakingToken);
        ERC20token.safeTransferFrom(msg.sender, address(this), amount);

        totalStakedToken += amount;

        if (_stakers[msg.sender].balance == 0) {
            totalAddressStaked += 1;

            uint256 timeNow = block.timestamp;

            _stakers[msg.sender] = Stake(
                msg.sender,
                0,
                timeNow,
                0,
                0,
                block.timestamp,
                block.timestamp
            );
        }

        _stakers[msg.sender].balance += amount;

        uint256 forecastAmount = _getForecastRewardByAmount(
            _stakers[msg.sender].balance
        );

        _stakers[msg.sender].allocationReward = forecastAmount;
        totalAllocationReward += forecastAmount;
        _mint(msg.sender, amount);
    }

    function withdraw() external payable {
        require(block.timestamp > timeEnd, "Cannot withdraw until pool ended");
        require(balanceOf(msg.sender) > 0,"sender doesnt have token");
        if(withdrawFee > 0) {
            require(msg.value == withdrawFee, "Withdraw fee is needed");
            payable(owner).transfer(msg.value);
        }
        
        if (getAvailableClaimReward(msg.sender) > 0) {
            claimReward(msg.sender);
        }

        uint256 balance = _stakers[msg.sender].balance;

        IBEP20Token ERC20token = IBEP20Token(stakingToken);
        ERC20token.safeTransfer(msg.sender, balance);

        totalAddressStaked -= 1;
        totalStakedToken -= balance;

        delete _stakers[msg.sender];

        _burn(msg.sender, balance);
    }

    function getCurrentTimestamp() external view returns(uint256){
        return block.timestamp;
    }
}

contract BasicToken is ContextToken, AuthToken, IBEP20Token {
    using SafeERC20Token for IBEP20Token;

    //ERC20
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1_000_000_000 * (10 ** _decimals);
    string private _name = "ChainedX";
    string private _symbol = "CHX";
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //tokenomic
    uint public percentTreasury = 2;
    uint public percentBurn = 1;
    uint public percentTotalTax = percentTreasury + percentBurn;
    uint256 public percentTaxDenominator = 100;
    bool public enableTrading = false;

    uint256 public minimumSwapForWeth = 1;

    bool public isAutoSwapForWeth = true;
    bool public isTaxEnable = true;

    // uint256
    mapping(address => bool) public isExcludeFromFee;
    
    //address
    address public factoryAddress;
    address public wethAddress;
    address public routerAddress;
    address public stakingAddress;
    address public pairWETHAddress;
    address public walletTreasury = 0x7B52bdE0D53D8Dc78E65e518d30De883400B3e01;
    address public walletMarketing = 0xD41576ceC36CA13B6c3833400558cA24Dc992a93;

    address public ZERO = 0x0000000000000000000000000000000000000000;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public isPair;

    bool public inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() AuthToken(msg.sender) {

        if(block.chainid == 97) routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        else if(block.chainid == 56) routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        else routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        
        wethAddress = IUniswapV2Router02Token(routerAddress).WETH();
        factoryAddress = IUniswapV2Router02Token(routerAddress).factory();
        IUniswapV2FactoryToken(factoryAddress).createPair(address(this), wethAddress);
        pairWETHAddress = IUniswapV2FactoryToken(factoryAddress).getPair(address(this), wethAddress);
        isPair[pairWETHAddress] = true;

        isExcludeFromFee[msg.sender] = true;
        isExcludeFromFee[routerAddress] = true;

        _balances[msg.sender] = _totalSupply;

        BasicStaking staking = new BasicStaking(address(this),msg.sender);
        stakingAddress = address(staking);
        isExcludeFromFee[stakingAddress] = true;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    receive() external payable {}

    function name() public view override returns (string memory) {return _name;}

    function symbol() public view virtual override returns (string memory) {return _symbol;}

    function decimals() public view virtual override returns (uint8) {return _decimals;}

    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}

    function balanceOf(address account) public view virtual override returns (uint256){return _balances[account];}

    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender];}

    function transfer(address recipient, uint256 amount) public virtual override { 
        _transfer(_msgSender(), recipient, amount); 
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) { 
        _approve(_msgSender(), spender, amount); 
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] -  amount;
        }
        _transfer(sender, recipient, amount);
    }


    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "Token: decreased allowance below zero"
        );
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Token: approve from the zero address");
        require(spender != address(0), "Token: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) external {
        require(_balances[_msgSender()] >= amount, "Token: Insufficient Amount");
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, DEAD, amount);
    }

    function isContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setEnableTrading() external onlyOwner{
      require(!enableTrading,"Trading is already enabled");
      enableTrading = true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (shouldTakeFee(sender)) {
             uint256 amountTransfer = getAmountTransfer(amount);

            if (shouldSwapForWeth(sender)) _swapForWeth(_balances[address(this)]);
        
            _balances[recipient] += amountTransfer;
            _balances[sender] -= amount;
        } else {
            _basicTransfer(sender, recipient, amount);
        }
    }

    function getAmountTransfer(uint256 amount) internal returns (uint256){
        uint256 amountTax = amount * percentTotalTax / percentTaxDenominator;
        
        _balances[address(this)] += amountTax;
        return amount - amountTax;
    }

    function shouldTakeFee(address sender) internal view returns (bool){
        if (inSwap) return false;
        if (isExcludeFromFee[sender]) return false;
        if (!isTaxEnable) return false;
        if (isPair[sender]) return false; //if sender is pair, its buy transaction and skip tax
        return true;
    }

    function shouldSwapForWeth(address sender) internal view returns (bool){
        return (isAutoSwapForWeth && !isPair[sender] && !inSwap && enableTrading && _balances[address(this)] >= minimumSwapForWeth);
    }

    function setIsPair(address pairAddress, bool state) external onlyOwner {
        isPair[pairAddress] = state;
    }

    function setTaxReceiver(address _marketingAddress, address _treasuryAddress) external onlyOwner {
        walletMarketing = _marketingAddress;
        walletTreasury = _treasuryAddress;
    }

    function setIsTaxEnable(bool state) external onlyOwner {
        isTaxEnable = state;
    }

    function setTaxPercent(uint _percentTreasury, uint _percentBurn) external onlyOwner {
        percentTreasury = _percentTreasury;
        percentBurn = _percentBurn;
        percentTotalTax = percentBurn + percentTreasury;
        require((percentTotalTax) <= 3,"Token: Maximum tax is 3%");
    }

    function setIsExcludeFromFee(address account, bool state) external onlyOwner {
        isExcludeFromFee[account] = state;
    }

    function setAutoSwapForWeth(bool state, uint256 amount) external onlyOwner {
        require(amount <= _totalSupply, "Token: Amount Swap For Weth max total supply");
        isAutoSwapForWeth = state;
        minimumSwapForWeth = amount;
    }

    function _swapForWeth(uint256 amount) internal swapping {
        if (amount > 0) {
            uint256 tokenBurn = amount * percentBurn / percentTotalTax; 
            uint256 amountSwap = amount - tokenBurn;
            _burn(address(this),tokenBurn);
            //total amount token for liquify

            IUniswapV2Router02Token router = IUniswapV2Router02Token(routerAddress);

            uint256 balanceETHBefore = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = wethAddress;
            _approve(address(this), routerAddress, amount);
            uint256[] memory estimate = router.getAmountsOut(amountSwap, path);

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountSwap,
                estimate[1],
                path,
                address(this),
                block.timestamp
            );

            uint256 balanceETHAfter = address(this).balance - balanceETHBefore;

            if(balanceETHAfter > 0){
                uint256 amountTreasury = getAmountPercent(balanceETHAfter, percentTreasury, percentTotalTax);
                
                payable(walletTreasury).transfer(amountTreasury);
            }
        }
    }

    function setStakingAddress(address _address) external onlyOwner {
        stakingAddress = _address;
    }

    function getAmountPercent(uint256 baseAmount, uint256 taxAmount, uint256 divider) internal view returns (uint256){
        return (baseAmount * (taxAmount * percentTaxDenominator) / divider) / percentTaxDenominator;
    }

    function triggerSwapBack() external onlyOwner {
        _swapForWeth(_balances[address(this)]);
    }

    function claimStuckToken(address _tokenAddress, address to, uint256 amount) external onlyOwner {
        require(_tokenAddress != address(this),"Cannot claim base token");
        IBEP20Token(_tokenAddress).safeTransfer(to, amount);        
    }
}
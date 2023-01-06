/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// File: ../leveraged/contracts/security/ReentrancyGuard.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: ../leveraged/contracts/libraries/Address.sol



pragma solidity ^0.8.10;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
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

// File: ../leveraged/contracts/interfaces/IIToken.sol



pragma solidity ^0.8.10;

/**
* @dev Interface for a IToken contract
 **/

interface IIToken {
    function balanceOf(address _user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function mint(address _user, uint256 _amount) external;
    function burn(address _user, uint256 _amount) external;
}

// File: ../leveraged/contracts/interfaces/ILeveragedVault.sol



pragma solidity ^0.8.10;

// the address used to identify BNB
address constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/**
* @dev Interface for a LeveragedVault contract
 **/

interface ILeveragedVault {
    struct LPPosition {
        address lpToken; // the address of liquidity provider token (liquidity pool address)
        uint256 amount; // the amount of lp tokens
        address borrowedAsset; // the address of the borrowed asset
        uint256 borrowedAmount; // the amount of debt
        uint256 averageInterestRate; // the average interest rate
        uint256 farmingRewardIndex; // the cumulative farming reward index
        address user; // the address of the user
        uint256 timestamp; // last operation timestamp
        uint256 prevLPPositionId; // id of previous LP position
        uint256 prevUserLPPositionId; // id of previous LP position of the user
        uint256 nextLPPositionId; // id of next LP position
        uint256 nextUserLPPositionId; // id of next LP position of the user
        bool isOpen;
    }

    function getAssetDecimals(address _asset) external view returns (uint256);
    function getAssetITokenAddress(address _asset) external view returns (address);
    function getAssetTotalLiquidity(address _asset) external view returns (uint256);
    function getUserAssetBalance(address _asset, address _user) external view returns (uint256);
    function getUserBorrowBalance(address _borrowedAsset, address _user) external view returns (uint256);
    function getLPPositionDebt(uint256 _lpPositionId) external view returns (uint256);
    function getLPPositionAmount(uint256 lpPositionId) external view returns (uint256);
    function getLPToken(uint256 lpPositionId) external view returns (address);
    function lpPositionIsOpen(uint256 lpPositionId) external view returns (bool);
    function getLPPositionBorrowedAsset(uint256 lpPositionId) external view returns (address);
    function getLPPosition(uint256 lpPositionId) external view returns (LPPosition memory);
    function getUserAverageInterestRate(address _asset, address _user) external view returns (uint256);
    function getAssetInterestRate(address _asset) external view returns (uint256);
    function getFarmPoolTotalValue(address _asset) external view returns (uint256);
    function getAssets() external view returns (address[] memory);
    function setAverageInterestRate(address _asset, address _user, uint256 _averageInterestRate) external;
    function updateBorrowBalance(address _asset, address _user, uint256 _userBorrowBalance) external;
    function openPosition(address _lpToken, address _borrowedAsset, uint256 _margin, uint256 _borrowedAmount, address _user) external returns (uint256);
    function closePosition(uint256 _lpPositionId, uint256 _lpTokenAmount) external;
    function updateMarginBorrowBalance(uint256 _lpPositionId, uint256 _newBorrowedAmount) external;
    function updateTotalCollateralBalance(address _asset) external;
    function transferToVault(address _asset, address payable _depositor, uint256 _amount) external;
    function transferToUser(address _asset, address payable _user, uint256 _amount) external;
    function updatePlatformProfitAndLiquidityIndexLog2(address _asset) external;
    function cumulatedAmount(address _asset, uint256 _storedAmount) external view returns (uint256);
    function storedAmount(address _asset, uint256 _cumulatedAmount) external view returns (uint256);
    function storedPlatformProfit(address _asset) external view returns (uint256);
    function getFullPlatformProfit(address _asset) external view returns (uint256);

    receive() external payable;
}

// File: ../leveraged/contracts/interfaces/IPriceOracle.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a price oracle.
 */
interface IPriceOracle {
    function getPrice(address _asset) external view returns (uint256);
}

// File: ../leveraged/contracts/interfaces/IRouter.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a router contract.
 */
interface IRouter {
    function setMockFarmPoolTotalValueInUSD(uint256 newFarmPoolTotalValueInUSD) external;
    function getFarmPoolTotalValueInUSD(address _lpToken) external view returns (uint256);
    function getTokens(address _lpToken) external view returns (address token0, address token1);
}

// File: ../leveraged/contracts/interfaces/IBEP20.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface of the BEP-20 standard as defined in the EIP.
 */
interface IBEP20 {
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

// File: ../leveraged/contracts/libraries/Context.sol



pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/token/BEP20.sol



pragma solidity ^0.8.10;



/**
 * @dev Interface for the optional metadata functions from the BEP-20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
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

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-s-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP-20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, IBEP20Metadata {
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
     * Ether and Wei. This is the value {BEP-20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
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
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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

// File: ../leveraged/contracts/MasterChef.sol



pragma solidity ^0.8.10;








/**
* @title MasterChef contract
* @notice Implements the lending actions
 **/
contract MasterChef is ReentrancyGuard {
    using Address for address;

    ILeveragedVault public vault;
    IPriceOracle public priceOracle;
    IRouter public router;

    uint256 MAX_LEVERAGE = 5;

    /**
    * @dev emitted on deposit of BNB
    * @param _depositor the address of the depositor
    * @param _amount the amount to be deposited
    * @param _timestamp the timestamp of the action
    **/
    event DepositBNB(
        address indexed _depositor,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on deposit of asset
    * @param _asset the address of the asset
    * @param _depositor the address of the depositor
    * @param _amount the amount to be deposited
    * @param _timestamp the timestamp of the action
    **/
    event DepositAsset(
        address indexed _asset,
        address indexed _depositor,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on redeem of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount to be redeemed
    * @param _timestamp the timestamp of the action
    **/
    event Redeem(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on borrow of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount to be borrowed
    * @param _timestamp the timestamp of the action
    **/
    event Borrow(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on open position
    * @param _lpToken the address of liquidity provider token
    * @param lpPositionAmount the amount of lp tokens
    * @param _borrowedAsset the address of the asset that the user borrows to open a margin position
    * @param margin the borrower's pledge
    * @param borrowedAmount the amount of debt
    * @param _user the address of the user
    * @param _timestamp the timestamp of the action
    **/
    event OpenPosition(
        address indexed _lpToken,
        uint256 lpPositionAmount,
        address indexed _borrowedAsset,
        uint256 margin,
        uint256 borrowedAmount,
        address indexed _user,
        uint256 _timestamp
    );

    /**
    * @dev emitted on close position
    * @param _lpPositionId the id of LP position
    * @param _borrowedAsset the address of the asset that the user refunds to close a margin position
    * @param _user the address of the user
    * @param _amount the amount by which the position will decrease
    * @param _timestamp the timestamp of the action
    **/
    event ClosePosition(
        uint256 indexed _lpPositionId,
        address indexed _borrowedAsset,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on repay of BNB
    * @param _user the address of the user
    * @param _amount the amount repaid
    * @param _borrowBalance new value of borrow balance
    * @param _timestamp the timestamp of the action
    **/
    event RepayBNB(
        address indexed _user,
        uint256 _amount,
        uint256 _borrowBalance,
        uint256 _timestamp
    );

    /**
    * @dev emitted on repay of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount repaid
    * @param _borrowBalance new value of borrow balance
    * @param _timestamp the timestamp of the action
    **/
    event RepayAsset(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _borrowBalance,
        uint256 _timestamp
    );

    modifier onlyVault {
        require(msg.sender == address(vault), "The caller of this function must be a Vault contract");
        _;
    }

    /**
    * @dev only IToken contract can use functions affected by this modifier
    **/
    modifier onlyITokenContract(address _asset) {
        require(
            vault.getAssetITokenAddress(_asset) == msg.sender,
            "The caller must be a IToken contract"
        );
        _;
    }

    constructor(
        address payable _vault,
        address _priceOracle,
        address _router
    ) {
        vault = ILeveragedVault(_vault);
        priceOracle = IPriceOracle(_priceOracle);
        router = IRouter(_router);
    }

    /**
    * @dev deposits BNB into the vault.
    * A corresponding amount of the interest bearing token is minted.
    **/
    function depositBNB()
        external
        payable
        nonReentrant
    {
        require(msg.value > 0, "BNB value must be greater than 0");

        vault.updatePlatformProfitAndLiquidityIndexLog2(BNB_ADDRESS);
        IIToken(vault.getAssetITokenAddress(BNB_ADDRESS)).
            mint(msg.sender, msg.value); // iToken minting to depositor
        vault.updateTotalCollateralBalance(BNB_ADDRESS);

        // transfer deposit to the LeveragedVault contract
        payable(address(vault)).transfer(msg.value);        

        emit DepositBNB(msg.sender, msg.value, block.timestamp);
    }

    /**
    * @dev deposits the supported asset into the vault. 
    * A corresponding amount of the interest bearing token is minted.
    * @param _asset the address of the asset
    * @param _amount the amount to be deposited
    **/
    function depositAsset(address _asset, uint256 _amount)
        external
        nonReentrant
    {
        require(_amount > 0, "Amount must be greater than 0");
        require(_asset != BNB_ADDRESS, "For deposit BNB use function depositBNB");

        vault.updatePlatformProfitAndLiquidityIndexLog2(_asset);
        IIToken(vault.getAssetITokenAddress(_asset)).
            mint(msg.sender, _amount); // iToken minting to depositor
        vault.updateTotalCollateralBalance(_asset);

        // transfer deposit to the LeveragedVault contract
        vault.transferToVault(_asset, payable(msg.sender), _amount);

        emit DepositAsset(_asset, msg.sender, _amount, block.timestamp);
    }

    /**
    * @dev redeems a specific amount of asset
    * @param _asset the address of the asset
    * @param _amount the amount being redeemed
    **/
    function redeem(
        address _asset,
        uint256 _amount
    )
        external
        nonReentrant
    {
        uint256 balance = vault.getUserAssetBalance(_asset, msg.sender);

        if (_amount == 0) {
            _amount = balance;
        } else {
            require(_amount <= balance, "Amount more than the user deposit of asset");
        }

        uint256 currentAssetLiquidity = vault.getAssetTotalLiquidity(_asset);
        require(_amount <= currentAssetLiquidity, "There is not enough asset liquidity to redeem");

        checkAssetDebtRatio(_asset, msg.sender, _amount, false);

        vault.updatePlatformProfitAndLiquidityIndexLog2(_asset);
        IIToken(vault.getAssetITokenAddress(_asset)).
            burn(msg.sender, _amount); // iToken burning at the msg.sender
        vault.updateTotalCollateralBalance(_asset);

        vault.transferToUser(_asset, payable(msg.sender), _amount);

        emit Redeem(_asset, msg.sender, _amount, block.timestamp);
    }

    /**
    * @dev allows users to borrow a certain amount of an asset
    * @param _asset the address of the asset
    * @param _amount the amount to be borrowed
    **/
    function borrow(
        address _asset,
        uint256 _amount
    )
        external
        nonReentrant
    {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            vault.getAssetTotalLiquidity(_asset) >= _amount,
            "Insufficient liquidity of the asset"
        );

        checkAssetDebtRatio(_asset, msg.sender, _amount, true);

        uint256 currentBorrowBalance = vault.getUserBorrowBalance(_asset, msg.sender);
        uint256 borrowBalance = currentBorrowBalance + _amount;

        uint256 averageInterestRate = 
            (_amount * vault.getAssetInterestRate(_asset) +
                currentBorrowBalance * vault.getUserAverageInterestRate(_asset, msg.sender)) /
            borrowBalance;

        vault.updatePlatformProfitAndLiquidityIndexLog2(_asset);
        vault.updateTotalCollateralBalance(_asset);
        vault.setAverageInterestRate(_asset, msg.sender, averageInterestRate);
        vault.updateBorrowBalance(_asset, msg.sender, borrowBalance);
        vault.transferToUser(_asset, payable(msg.sender), _amount);

        emit Borrow(
            _asset,
            msg.sender,
            _amount,
            block.timestamp
        );
    }

    /**
    * @dev allows users to add liquidity to the liquidity pool
    * @param _lpToken the address of liquidity provider token (liquidity pool address)
    * @param _borrowedAsset the address of the asset that the user borrows to open a margin position
    * @param _leverage the credit lever from 1 to 5
    * @param _assets the addresses of assets to be used
    * @param _amounts the amount of the asset from the user's balance
    **/
    function farm(
        address _lpToken,
        address _borrowedAsset,
        uint256 _leverage,
        address[] calldata _assets,
        uint256[] calldata _amounts
    )
        external
        nonReentrant
    {
        require(_assets.length == _amounts.length, "Arrays of different lengths");
        require(_leverage >= 1 && _leverage <= MAX_LEVERAGE, "Incorrect leverage value");

        uint256 margin;
        for (uint256 i = 0; i < _assets.length; i++) {
            if (_amounts[i] == 0) { continue; }

            require(_amounts[i] <= vault.getUserAssetBalance(_assets[i], msg.sender), "Amount more than the user's balance of asset");
            require(_amounts[i] <= vault.getAssetTotalLiquidity(_assets[i]), "There is not enough asset liquidity");

            vault.updatePlatformProfitAndLiquidityIndexLog2(_assets[i]);
            IIToken(vault.getAssetITokenAddress(_assets[i])).
                burn(msg.sender, _amounts[i]); // iToken burning at the msg.sender
            vault.updateTotalCollateralBalance(_assets[i]);

            if (_assets[i] != _borrowedAsset) {
//                 margin += router.swap(_assets[i], _borrowedAsset, _amounts[i]);
                margin += _amounts[i] *
                    priceOracle.getPrice(_assets[i]) *
                    10**vault.getAssetDecimals(_borrowedAsset) /
                    (10**vault.getAssetDecimals(_assets[i]) * priceOracle.getPrice(_borrowedAsset));
            } else {
                margin += _amounts[i];
            }
        }

        require(margin > 0, "Margin must be greater than 0");
        checkAssetDebtRatio(_assets[0], msg.sender, 0, false);

        vault.updatePlatformProfitAndLiquidityIndexLog2(_borrowedAsset);
        vault.updateTotalCollateralBalance(_borrowedAsset);

        uint256 borrowedAmount = margin*(_leverage - 1);

        uint256 lpPositionAmount = vault.openPosition(
            _lpToken,
            _borrowedAsset,
            margin,
            borrowedAmount,
            msg.sender
        );

        emit OpenPosition(
            _lpToken,
            lpPositionAmount,
            _borrowedAsset,
            margin,
            borrowedAmount,
            msg.sender,
            block.timestamp
        );
    }

    /**
    * @dev gets preliminary data of new LP position
    * @param _lpToken the address of liquidity provider token (liquidity pool address)
    * @param _borrowedAsset the address of the asset that the user borrows to open a margin position
    * @param _leverage the credit lever from 1 to 5
    * @param _assets the addresses of assets to be used
    * @param _amounts the amount of the asset from the user's balance
    **/
    function getLPPositionPreliminaryData(
        address _lpToken, // lpToken_address
        address _borrowedAsset, // bnb_address, usdt_address, busd_address
        uint256 _leverage, // 1-5
        address[] calldata _assets, // [bnb_address, usdt_address, busd_address]
        uint256[] calldata _amounts // [bnb_amount, usdt_amount, busd_amount]
    )
        external
        view
        returns (
            address token0,
            address token1,
            uint256 token0Amount,
            uint256 token1Amount,
            uint256 borrowedAmount
        )
    {
        require(_assets.length == _amounts.length, "Arrays of different lengths");
        require(_leverage >= 1 && _leverage <= MAX_LEVERAGE, "Incorrect leverage value");

        uint256 margin;
        for (uint256 i = 0; i < _assets.length; i++) {
            if (_amounts[i] == 0) { continue; }

            require(_amounts[i] <= vault.getUserAssetBalance(_assets[i], msg.sender), "Amount more than the user's balance of asset");
            require(_amounts[i] <= vault.getAssetTotalLiquidity(_assets[i]), "There is not enough asset liquidity");

            if (_assets[i] != _borrowedAsset) {
//                 margin += router.calcMargin(_assets[i], _borrowedAsset, _amounts[i]);
                margin += _amounts[i] *
                    priceOracle.getPrice(_assets[i]) *
                    10**vault.getAssetDecimals(_borrowedAsset) /
                    (10**vault.getAssetDecimals(_assets[i]) * priceOracle.getPrice(_borrowedAsset));
            } else {
                margin += _amounts[i];
            }
        }

        require(margin > 0, "Margin must be greater than 0");

        borrowedAmount = margin*(_leverage - 1);

        (token0, token1) = router.getTokens(_lpToken);

        token0Amount = borrowedAmount *
            priceOracle.getPrice(_borrowedAsset) *
            10**((token0 == BNB_ADDRESS) ? 18 : IBEP20Metadata(token0).decimals()) /
            (2 * 10**vault.getAssetDecimals(_borrowedAsset) * priceOracle.getPrice(token0));

        token1Amount = borrowedAmount *
            priceOracle.getPrice(_borrowedAsset) *
            10**((token1 == BNB_ADDRESS) ? 18 : IBEP20Metadata(token1).decimals()) /
            (2 * 10**vault.getAssetDecimals(_borrowedAsset) * priceOracle.getPrice(token1));
    }

    /**
    * @dev allows users to unfarm a certain amount of LP token from the liquidity pool
    * @param _lpPositionId the id of LP position
    * @param _lpTokenAmount the amount of LP token that to be withdrawn from the liquidity pool
    **/
    function unfarm(
        uint256 _lpPositionId,
        uint256 _lpTokenAmount
    )
        external
        nonReentrant
    {
        require(_lpTokenAmount > 0, "Amount must be greater than 0");

        uint256 lpPositionAmount = vault.getLPPositionAmount(_lpPositionId);
        require(lpPositionAmount >= _lpTokenAmount, "Amount must not exceed position");

        address borrowedAsset = vault.getLPPositionBorrowedAsset(_lpPositionId);  
//      TODO:   uint256 withdrawalAmount = router.withdrawal(vault.getLPToken(_lpPositionId), _lpTokenAmount, borrowedAsset);
        uint256 withdrawalAmount = _lpTokenAmount;
        uint256 currentLPPositionDebt = vault.getLPPositionDebt(_lpPositionId);

        vault.updatePlatformProfitAndLiquidityIndexLog2(borrowedAsset);
        vault.updateTotalCollateralBalance(borrowedAsset);

        if (currentLPPositionDebt >= withdrawalAmount) {
            vault.updateMarginBorrowBalance(_lpPositionId, currentLPPositionDebt - withdrawalAmount);
        } else {
            vault.updateMarginBorrowBalance(_lpPositionId, 0);
            IIToken(vault.getAssetITokenAddress(borrowedAsset)).
                mint(msg.sender, withdrawalAmount - currentLPPositionDebt); // iToken minting to depositor
            vault.updateTotalCollateralBalance(borrowedAsset);
        }

        vault.closePosition(_lpPositionId, lpPositionAmount - _lpTokenAmount);

        emit ClosePosition(
            _lpPositionId,
            borrowedAsset,
            msg.sender,
            _lpTokenAmount,
            block.timestamp
        );
    }

    /**
    * @dev gets debt ratio threshold of the asset with 6 decimals.
    * @param _asset the asset address
    * @return the asset debt ratio threshold
    **/
    function getAssetDebtRatioThreshold(address _asset) public view returns (uint256) {
        uint256 farmPoolTotalValueInUSD = priceOracle.getPrice(_asset) * vault.getFarmPoolTotalValue(_asset) / 10**vault.getAssetDecimals(_asset);
        uint256 millionUSD = 1000000 * 10**8;

        if (farmPoolTotalValueInUSD < millionUSD) { // 0-1M USD
            return 100000 * farmPoolTotalValueInUSD / millionUSD + 700000; // 0.7 - 0.8
        } else if (farmPoolTotalValueInUSD < 3 * millionUSD) { // 1-3M USD
            return 25000 * farmPoolTotalValueInUSD / millionUSD + 775000; // 0.8 - 0.85
        } else if (farmPoolTotalValueInUSD < 10 * millionUSD) { // 3-10M USD
            return 7140 * farmPoolTotalValueInUSD / millionUSD + 828600; // 0.85 - 0.95
        } else { // 10M+ USD
            return 900000; // 0.9
        }
    }

    /**
    * @dev gets debt ratio threshold of the pool with 6 decimals.
    * @param _lpToken the address of liquidity provider token (liquidity pool address)
    * @return the pool debt ratio threshold
    **/
    function getPoolDebtRatioThreshold(address _lpToken) public view returns (uint256) {
        uint256 farmPoolTotalValueInUSD = router.getFarmPoolTotalValueInUSD(_lpToken);

        uint256 millionUSD = 1000000 * 10**8;

        if (farmPoolTotalValueInUSD < millionUSD) { // 0-1M USD
            return 100000 * farmPoolTotalValueInUSD / millionUSD + 700000; // 0.7 - 0.8
        } else if (farmPoolTotalValueInUSD < 3 * millionUSD) { // 1-3M USD
            return 25000 * farmPoolTotalValueInUSD / millionUSD + 775000; // 0.8 - 0.85
        } else if (farmPoolTotalValueInUSD < 10 * millionUSD) { // 3-10M USD
            return 7140 * farmPoolTotalValueInUSD / millionUSD + 828600; // 0.85 - 0.95
        } else { // 10M+ USD
            return 900000; // 0.9
        }
    }

    /**
    * @dev check utilization limit
    * @param _asset the asset address
    * @param _user the user address
    * @param _amount the amount by which the collateral balance or borrow balance will change
    * @param _isBorrowIncrease true if is borrow increase
    **/
    function checkAssetDebtRatio(
        address _asset,
        address _user,
        uint256 _amount,
        bool _isBorrowIncrease
    )
        internal
        view
    {
        ( , uint256 totalBorrowBalanceInUSD, uint256 borrowingPowerInUSD, ) = getUserTotalBalances(_user);

        uint256 amountInUSD = priceOracle.getPrice(_asset) * _amount / 10**vault.getAssetDecimals(_asset);

        if (_isBorrowIncrease) {
            require(
                amountInUSD < borrowingPowerInUSD,
                "Debt ratio threshold exceeded"
            );
        } else {
            if (totalBorrowBalanceInUSD > 0) {
                require(
                    amountInUSD * (getAssetDebtRatioThreshold(_asset) - 100000) / 10**6 < borrowingPowerInUSD,
                    "Debt ratio threshold exceeded"
                );
            }
        }
    }

    /**
    * @notice repays msg.sender's debt of BNB
    * Ensure that the repayBNB() transaction includes the amount of BNB in the msg.value.
    * To repay the entire borrow, it is recommended to send slightly higher than the current borrow balance.
    **/
    function repayBNB()
        external
        payable
        nonReentrant
    {
        require(msg.value > 0, "Value must be greater than 0");

        uint256 currentBorrowBalance = vault.getUserBorrowBalance(BNB_ADDRESS, msg.sender);
        uint256 borrowBalance;

        if (msg.value > currentBorrowBalance) {
            borrowBalance = 0;
            payable(msg.sender).transfer(msg.value - currentBorrowBalance);
        } else {
            borrowBalance = currentBorrowBalance - msg.value;
        }

        vault.updatePlatformProfitAndLiquidityIndexLog2(BNB_ADDRESS);
        vault.updateTotalCollateralBalance(BNB_ADDRESS);
        vault.updateBorrowBalance(BNB_ADDRESS, msg.sender, borrowBalance);

        // transfer BNB to the vault contract
        payable(address(vault)).transfer(currentBorrowBalance - borrowBalance);

        emit RepayBNB(
            msg.sender,
            currentBorrowBalance - borrowBalance,
            borrowBalance,
            block.timestamp
        );
    }

    /**
    * @notice repays specified amount of the asset borrow
    * @param _asset the address of the asset
    * @param _amount the amount to be repaid
    **/
    function repayAsset(address _asset, uint256 _amount)
        external
        nonReentrant
    {
        uint256 currentBorrowBalance = vault.getUserBorrowBalance(_asset, msg.sender);

        if (_amount == 0) {
            _amount = currentBorrowBalance;
        } else {
            require(_amount <= currentBorrowBalance, "Amount exceeds borrow");
        }

        uint256 borrowBalance = currentBorrowBalance - _amount;

        vault.updatePlatformProfitAndLiquidityIndexLog2(_asset);
        vault.updateTotalCollateralBalance(_asset);
        vault.updateBorrowBalance(_asset, msg.sender, borrowBalance);

        // transfer asset to the vault contract
        vault.transferToVault(_asset, payable(msg.sender), _amount);

        emit RepayAsset(
            _asset,
            msg.sender,
            _amount,
            borrowBalance,
            block.timestamp
        );
    }

    /**
    * @dev during iToken transfer checks utilization limit and updates binary logarithm of liquidity index of the asset
    * @param _asset the asset address
    * @param _from the transfer sender address
    * @param _amount the transfer amount
    **/
    function duringITokenTransfer(address _asset, address _from, uint256 _amount)
        external
        onlyITokenContract(_asset)
    {
        checkAssetDebtRatio(_asset, _from, _amount, false);
        vault.updatePlatformProfitAndLiquidityIndexLog2(_asset);
        vault.updateTotalCollateralBalance(_asset);
    }

    /**
    * @dev struct to hold data of function getUserTotalBalances
    */
    struct UserTotalBalancesData {
        uint256 balance;
        uint256 positionBalance;
        uint256 borrowBalance;
        uint256 assetUnit;
        uint256 assetPriceInUSD;
    }

    /**
    * @notice get user total USD balances
    * @param _user the user address
    * @return totalBalanceInUSD the total USD collateral balance of the user,
    *         totalBorrowBalanceInUSD the total USD borrow balance of the user,
    *         borrowingPowerInUSD the borrowing power in USD,
    *         maxBorrowingPowerInUSD the max borrowingPowerInUSD
    **/
    function getUserTotalBalances(
        address _user
    )
        public
        view
        returns (
            uint256 totalBalanceInUSD,
            uint256 totalBorrowBalanceInUSD,
            uint256 borrowingPowerInUSD,
            uint256 maxBorrowingPowerInUSD
        )
    {
        // Usage of a struct to fix "Stack too deep" error
        UserTotalBalancesData memory data;

        address[] memory assets = vault.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            data.balance = vault.getUserAssetBalance(assets[i], _user);
            data.borrowBalance = vault.getUserBorrowBalance(assets[i], _user);

            if (data.balance == 0 && data.borrowBalance == 0) { continue; }

            data.assetUnit = 10**vault.getAssetDecimals(assets[i]);
            data.assetPriceInUSD = priceOracle.getPrice(assets[i]);

            totalBalanceInUSD += data.assetPriceInUSD * data.balance / data.assetUnit;
            totalBorrowBalanceInUSD += data.assetPriceInUSD * data.borrowBalance / data.assetUnit;

            maxBorrowingPowerInUSD += data.assetPriceInUSD * data.balance * (getAssetDebtRatioThreshold(assets[i]) - 100000) / (10**6 * data.assetUnit);
        }

        borrowingPowerInUSD = (maxBorrowingPowerInUSD > totalBorrowBalanceInUSD) ?
            maxBorrowingPowerInUSD - totalBorrowBalanceInUSD : 0;
    }

    /**
    * @notice get user asset max available
    * @param _asset the address of the asset
    * @param _user the user address
    * @return user asset max available
    **/
    function getUserAssetMaxAvailable(address _asset, address _user) external view returns (uint256)
    {
        uint256 balance = vault.getUserAssetBalance(_asset, _user);
        uint256 currentAssetTotalLiquidity = vault.getAssetTotalLiquidity(_asset);

        ( , uint256 totalBorrowBalanceInUSD, uint256 borrowingPowerInUSD, ) = getUserTotalBalances(_user);

        uint256 availableBalance = (balance >= currentAssetTotalLiquidity) ? currentAssetTotalLiquidity : balance;

        if (totalBorrowBalanceInUSD == 0) {
            return availableBalance;
        } else {
            uint256 maxAvailableInUSD = borrowingPowerInUSD * 10**6 / (getAssetDebtRatioThreshold(_asset) - 100000);
            uint256 maxAvailableAsset = maxAvailableInUSD * 10**vault.getAssetDecimals(_asset) / priceOracle.getPrice(_asset);

            return (availableBalance > maxAvailableAsset) ? maxAvailableAsset : availableBalance;
        }
    }

    /**
    * @notice gets true if the liquidation threshold for user borrows is reached
    * @param _user the user address
    * @return true if the liquidation threshold for user borrows is reached
    **/
    function userMustBeLiquidated(address _user) public view returns (bool)
    {
        ( 
            uint256 totalBalanceInUSD,
            uint256 totalBorrowBalanceInUSD, ,
            uint256 maxBorrowingPowerInUSD
        ) = getUserTotalBalances(_user);

        return (maxBorrowingPowerInUSD + totalBalanceInUSD / 10 >= totalBorrowBalanceInUSD) ?
            false : true;
    }

    /**
    * @notice gets true if the liquidation threshold for position is reached
    * @param _lpPositionId the id of LP position
    * @return true if the liquidation threshold for position is reached
    **/
    function positionMustBeLiquidated(uint256 _lpPositionId) public view returns (bool)
    {
        address borrowedAsset = vault.getLPPositionBorrowedAsset(_lpPositionId);
        uint256 assetUnit = 10**vault.getAssetDecimals(borrowedAsset);
        uint256 assetPriceInUSD = priceOracle.getPrice(borrowedAsset);

        // TODO: lpPositionInUSD = router.getLPPositionInUSD(vault.getLPToken(_lpPositionId), vault.getLPPositionAmount(_lpPositionId));
        uint256 lpPositionInUSD = assetPriceInUSD * vault.getLPPositionAmount(_lpPositionId) / assetUnit;
        uint256 lpPositionDebtInUSD = assetPriceInUSD * vault.getLPPositionDebt(_lpPositionId) / assetUnit;

        return (lpPositionDebtInUSD >= getPoolDebtRatioThreshold(vault.getLPToken(_lpPositionId)) * lpPositionInUSD / 10**6) ? true : false;
    }

    /**
    * @notice gets user utilization ratio and utilization limit
    * @param _user the user address
    * @return utilizationRatio the current utilization ratio,
    *         utilizationLimit the limit of utilization ratio
    **/
    function getUtilizationData(
        address _user
    )
        external
        view
        returns (
            uint256 utilizationRatio,
            uint256 utilizationLimit
        )
    {
        ( 
            uint256 totalBalanceInUSD,
            uint256 totalBorrowBalanceInUSD, ,
            uint256 maxBorrowingPowerInUSD
        ) = getUserTotalBalances(_user);

        utilizationRatio = totalBalanceInUSD == 0 ? 0 : totalBorrowBalanceInUSD * 10**6 / totalBalanceInUSD;
        utilizationLimit = totalBalanceInUSD == 0 ? 0 : maxBorrowingPowerInUSD * 10**6 / totalBalanceInUSD;
    }

    /**
    * @dev liquidates the user if the liquidation threshold is reached
    * @param _user the address of the user to be liquidated
    **/
    function liquidation(
        address _user
    )
        external
        payable
        nonReentrant
    {
        require(userMustBeLiquidated(_user), "Liquidation threshold not reached");

        uint256 balance;
        uint256 currentBorrowBalance;
        IIToken iToken;

        address[] memory assets = vault.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            currentBorrowBalance = vault.getUserBorrowBalance(assets[i], _user);
            vault.updatePlatformProfitAndLiquidityIndexLog2(assets[i]);
            vault.updateTotalCollateralBalance(assets[i]);
            if (currentBorrowBalance > 0) {
              vault.updateBorrowBalance(assets[i], _user, 0);

              if (assets[i] == BNB_ADDRESS) {
                  require(msg.value >= currentBorrowBalance, "msg.value is not enough");
                  payable(address(vault)).transfer(currentBorrowBalance);
                  if (msg.value > currentBorrowBalance) {
                      payable(msg.sender).transfer(msg.value - currentBorrowBalance);
                  }
              } else {
                  vault.transferToVault(assets[i], payable(msg.sender), currentBorrowBalance);
              }
            }

            balance = vault.getUserAssetBalance(assets[i], _user);
            if (balance > 0) {
                iToken = IIToken(vault.getAssetITokenAddress(assets[i]));
                iToken.burn(_user, balance);
                iToken.mint(msg.sender, balance);
            }
        }
    }

    /**
    * @dev liquidates of a open position if the liquidation threshold is reached
    * @param _lpPositionId the id of LP position to be liquidated
    **/
    function liquidationPosition(
        uint256 _lpPositionId
    )
        external
        payable
        nonReentrant
    {
        require(positionMustBeLiquidated(_lpPositionId), "Liquidation threshold not reached");

        address borrowedAsset = vault.getLPPositionBorrowedAsset(_lpPositionId);  
//      TODO:   uint256 withdrawalAmount = router.withdrawal(vault.getLPToken(_lpPositionId), _lpTokenAmount, borrowedAsset);
        uint256 withdrawalAmount = vault.getLPPositionAmount(_lpPositionId);
        uint256 currentLPPositionDebt = vault.getLPPositionDebt(_lpPositionId);

        vault.updatePlatformProfitAndLiquidityIndexLog2(borrowedAsset);
        vault.updateTotalCollateralBalance(borrowedAsset);
        vault.updateMarginBorrowBalance(_lpPositionId, 0);

        if (currentLPPositionDebt > withdrawalAmount) {
            uint256 debtBalance = currentLPPositionDebt - withdrawalAmount;

            if (borrowedAsset == BNB_ADDRESS) {
                require(msg.value >= debtBalance, "msg.value is not enough");
                payable(address(vault)).transfer(debtBalance);
                if (msg.value > debtBalance) {
                    payable(msg.sender).transfer(msg.value - debtBalance);
                }
            } else {
                vault.transferToVault(borrowedAsset, payable(msg.sender), debtBalance);
            }
        } else {
            if (currentLPPositionDebt < withdrawalAmount) {
                IIToken(vault.getAssetITokenAddress(borrowedAsset)).
                    mint(msg.sender, withdrawalAmount - currentLPPositionDebt);
                vault.updateTotalCollateralBalance(borrowedAsset);
            }
        }

        vault.closePosition(_lpPositionId, 0);
    }
}
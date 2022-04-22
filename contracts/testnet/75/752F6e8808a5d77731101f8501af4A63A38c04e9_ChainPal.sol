/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     * `revert` opsymbol (which leaves remaining gas untouched) while Solidity
     * uses an invalid opsymbol to revert (consuming all remaining gas).
     *
     * Requirements:
     *
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
     * `revert` opsymbol (which leaves remaining gas untouched) while Solidity
     * uses an invalid opsymbol to revert (consuming all remaining gas).
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
     * opsymbol (which leaves remaining gas untouched) while Solidity uses an
     * invalid opsymbol to revert (consuming all remaining gas).
     *
     * Requirements:
     *
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
     * opsymbol (which leaves remaining gas untouched) while Solidity uses an
     * invalid opsymbol to revert (consuming all remaining gas).
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    function mint(address spender, uint256 amount) external;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
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
contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
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
     * - `to` cannot be the zero address.
     */
    function mint(address account, uint256 amount) public virtual override {
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

library Currency {
    struct data {
        address val;
        bool isValue;
    }
}

// ReEntrancyGuard to prevent Reentrancy
contract ChainPal is Ownable, ReEntrancyGuard {
    // prevents over and under flow
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using SafeBEP20 for BEP20;

    address BUSD = 0x9B9022eD3d6D12B0c143813a381Ab6a5583e4aB1;
    address USDT = 0x412289e40F240052D0Bf9752B0415004661dc01C;
    address CP = 0xE5282F3bF5C83DcAbB3B286d82c956eBfe805D9c;

    address public paidStakingAddress;
    address public escrowManagerAddress;
    address public adminAddress;
    address public referelBonusAddress;

    uint256 public constant PAYMENT_HOD_DAYS = 7;

    enum FEES_TYPE {
        NON_CP,
        FEES_CP,
        TRANSACTION_CP
    }

    enum STATUS {
        CREATED,
        CANCELLED,
        CLAIMED,
        DISPUTE,
        COMPLETED
    }

    FEES_TYPE public FEETYPE;

    enum PAYMENT {
        INSTANT,
        MIESTONE
    }

    using Currency for Currency.data;
    mapping(string => Currency.data) supportedCurrency;
    mapping(address => bool) public tokenApproved;

    struct Fees {
        FEES_TYPE feeType;
        uint256 referral;
        uint256 staking;
        uint256 escrow;
        uint256 admin;
        uint256 referralBonus;
    }

    struct TransactionDetails {
        string paymentReceiveCurrency;
        string data;
        string feePaymentCurrency;
        address buyer;
        address seller;
        address createdBy;
    }

    struct Transaction {
        TransactionDetails transactionDetails;
        Fees fees;
        STATUS status;
        bool isPaid;
        bool islive;
        bool searchTransaction;
        uint256 paymentAmount;
        uint256 paymentAmountFees;
        uint256 validUntil;
        string note;
        address referralAddress;
    }

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

    mapping(string => Transaction) public transactions;

    address private ownerAddress;

    modifier hasCancellationRights() {
        require(
            owner() == _msgSender() ||
                escrowManagerAddress == _msgSender() ||
                adminAddress == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    /**
     * This value is immutable: it can only be set once during
     * construction.
     */

    constructor(
        address _paidStakingAddress,
        address _escrowManagerAddress,
        address _adminAddress,
        address _referelBonusAddress,
        address _ownerAddress
    ) public {
        ownerAddress = _ownerAddress;
        paidStakingAddress = _paidStakingAddress;
        escrowManagerAddress = _escrowManagerAddress;
        adminAddress = _adminAddress;
        referelBonusAddress = _referelBonusAddress;

        // transfer the ownership if sender does not match with _ownerAddress
        if (_ownerAddress != msg.sender) {
            transferOwnership(_ownerAddress);
        }

        tokenApproved[BUSD] = true;
        tokenApproved[USDT] = true;
        tokenApproved[CP] = true;

        supportedCurrency["BUSD"].val = BUSD;
        supportedCurrency["USDT"].val = USDT;
        supportedCurrency["CP"].val = CP;
    }

    /**
     * @dev Create new Transaction.
     *
     * Requirements:
     *
     * - `uid` unique transaction ID.
     * - `_data` Transaction data to store
     * - `_feePaymentCurrency` currency name in form of ENUM
     * - `_paymentReceiveCurrency` payment currency name in form of ENUM
     * - `_feeType` transaction fee type
     * - `_seller` address of the seller
     * - `_buyer` address of the buyer
     * - `_referralAddress` address of the referral user if any
     * - `_paymentAmount` transaction amount
     * - `_fees` array of fees to be distribute as platform fees
     */

    function createTransaction(
        string memory uid,
        string memory _data,
        string memory _feePaymentCurrency,
        string memory _paymentReceiveCurrency,
        string memory _feeType,
        address _seller,
        address _buyer,
        address _referralAddress,
        uint256 _paymentAmount,
        uint256[] memory _fees
    ) external noReentrant {
        require(_paymentAmount > 0, "invalid amount");
        require(
            checkSupportedCurrency(_paymentReceiveCurrency),
            "Invalid currency"
        );
        require(isTransaction(uid) == false, "Invalid id");
        require(_fees.length == 5, "Please include all fees");

        Transaction memory transaction;

        transaction
            .transactionDetails
            .paymentReceiveCurrency = _paymentReceiveCurrency;
        transaction.referralAddress = _referralAddress;

        transaction.status = STATUS.CREATED;
        transaction.isPaid = false;
        transaction.islive = false;
        transaction.transactionDetails.seller = _seller;
        transaction.transactionDetails.buyer = _buyer;
        transaction.transactionDetails.feePaymentCurrency = _feePaymentCurrency;
        transaction.transactionDetails.data = _data;
        transaction.paymentAmount = _paymentAmount;
        transaction.transactionDetails.createdBy = msg.sender;
        transaction.searchTransaction = true;

        uint256 feeTotal;

        for (uint256 i; i < _fees.length; i++) {
            feeTotal += _fees[i];
        }

        uint256 gweiToWei = 1000000000;

        transaction.paymentAmountFees = feeTotal.mul(gweiToWei);

        transaction.fees.referral = _fees[0].mul(gweiToWei);
        transaction.fees.staking = _fees[1].mul(gweiToWei);
        transaction.fees.escrow = _fees[2].mul(gweiToWei);
        transaction.fees.admin = _fees[3].mul(gweiToWei);
        transaction.fees.referralBonus = _fees[4].mul(gweiToWei);

        if (returnFeeType(_feeType) == FEES_TYPE.NON_CP) {
            transaction.fees.feeType = FEES_TYPE.NON_CP;
        } else if (returnFeeType(_feeType) == FEES_TYPE.FEES_CP) {
            transaction.fees.feeType = FEES_TYPE.FEES_CP;
        } else if (returnFeeType(_feeType) == FEES_TYPE.TRANSACTION_CP) {
            transaction.fees.feeType = FEES_TYPE.TRANSACTION_CP;
        }

        transactions[uid] = transaction;
    }

    /**
     * @dev Pay platform fees for Transaction using ALT coin.
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     * - `amount` fees to pay
     * - `token` currency address
     */

    function onChainATransactionALT(
        string memory id,
        uint256 amount,
        address token
    ) external noReentrant {
        require(isTransaction(id), "Invalid id");
        require(tokenApproved[token], "We don't accept those");

        Transaction storage transaction = transactions[id];
        require(
            transaction.transactionDetails.createdBy == msg.sender,
            "you do no have authority"
        );
        require(transaction.islive == false, "Already paid");
        require(transaction.status == STATUS.CREATED, "transaction not active");

        if (amount > 0) {
            require(transaction.paymentAmountFees == amount, "Invalid amount");
            IBEP20(token).transferFrom(msg.sender, address(this), amount);
            transaction.islive = true;

            emit Deposit(msg.sender, amount);
        }
    }

    /**
     * @dev Pay platform fees for Transaction in BNB.
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */
    function onChainATransactionBNB(string memory id)
        external
        payable
        noReentrant
    {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];
        require(
            transaction.transactionDetails.createdBy == msg.sender,
            "you do no have authority"
        );
        require(transaction.islive == false, "Already paid");
        require(transaction.status == STATUS.CREATED, "transaction not active");

        if (msg.value > 0) {
            require(
                compareToIgnoreCase(
                    transaction.transactionDetails.feePaymentCurrency,
                    "BNB"
                ),
                "Only BNB"
            );
            require(
                transaction.paymentAmountFees * 1 wei <= msg.value,
                "Invalid amount"
            );

            transaction.islive = true;
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**
     * @dev Pay Transaction amount in ALT coin.
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     * - `amount` amount to pay
     * - `token` currency address
     */

    function payTransactionALT(
        string memory id,
        uint256 amount,
        address token
    ) external payable noReentrant {
        require(isTransaction(id), "Invalid id");
        require(tokenApproved[token], "We don't accept those");

        Transaction storage transaction = transactions[id];

        require(transaction.status == STATUS.CREATED, "transaction not active");
        require(
            transaction.transactionDetails.buyer == msg.sender,
            "not valid buyer"
        );
        require(transaction.isPaid == false, "Already paid");
        require(transaction.islive, "Transaction not ready");

        require(amount >= transaction.paymentAmount, "Invalid Amount");
        address currency = supportedCurrency[
            upper(transaction.transactionDetails.paymentReceiveCurrency)
        ].val;
        sendAmount(transaction.paymentAmount, currency, address(this));
        transaction.isPaid = true;
        transaction.validUntil = block.timestamp + 7 days;
    }

    /**
     * @dev Pay Transaction amount in BNB.
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function payTransactionBNB(string memory id) external payable noReentrant {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];

        require(transaction.status == STATUS.CREATED, "transaction not active");
        require(
            transaction.transactionDetails.buyer == msg.sender,
            "not valid buyer"
        );
        require(transaction.isPaid == false, "Already paid");
        require(transaction.islive, "Transaction not ready");

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.paymentReceiveCurrency,
                "BNB"
            )
        ) {
            require(
                msg.value >= transaction.paymentAmount * 1 wei,
                "Invalid Amount"
            );
            transaction.isPaid = true;
            transaction.validUntil = block.timestamp + 7 days;
        }
    }

    /**
     * @dev claim Transaction amount after sucessful transaction.
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function claimTransactionAmount(string memory id) external noReentrant {
        require(isTransaction(id), "Invalid id");
        // require(tokenApproved[token], "We don't accept those");

        Transaction storage transaction = transactions[id];
        require(transaction.islive, "Transaction not ready");

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot claim!");
        }

        require(
            msg.sender == transaction.transactionDetails.seller,
            "You cannot claim"
        );
        require(validate(transaction.validUntil), "claim cannot be made");

        address paymentCurrency = supportedCurrency[
            upper(transaction.transactionDetails.paymentReceiveCurrency)
        ].val;
        address currency = supportedCurrency[
            upper(transaction.transactionDetails.feePaymentCurrency)
        ].val;

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.paymentReceiveCurrency,
                "BNB"
            )
        ) {
            sendBnb(
                transaction.transactionDetails.seller,
                transaction.paymentAmount
            );
        } else {
            IBEP20(paymentCurrency).transfer(
                transaction.transactionDetails.seller,
                transaction.paymentAmount
            );
            emit Withdraw(
                transaction.transactionDetails.seller,
                transaction.paymentAmount
            );
        }

        uint256 amount = transaction.paymentAmountFees;

        require(
            amount >=
                transaction
                    .fees
                    .staking
                    .add(transaction.fees.escrow)
                    .add(transaction.fees.admin)
                    .add(transaction.fees.referralBonus),
            "Invalid Amount"
        );

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "BNB"
            )
        ) {
            if (transaction.referralAddress != msg.sender) {
                sendBnb(transaction.referralAddress, transaction.fees.referral);
            }

            sendBnb(paidStakingAddress, transaction.fees.staking);
            sendBnb(escrowManagerAddress, transaction.fees.escrow);
            sendBnb(adminAddress, transaction.fees.admin);
            sendBnb(referelBonusAddress, transaction.fees.referralBonus);
        } else {
            if (transaction.referralAddress != msg.sender) {
                distributeFees(
                    transaction.fees.referral,
                    currency,
                    transaction.referralAddress
                );
            }

            distributeFees(
                transaction.fees.staking,
                currency,
                paidStakingAddress
            );
            distributeFees(
                transaction.fees.escrow,
                currency,
                escrowManagerAddress
            );
            distributeFees(transaction.fees.admin, currency, adminAddress);
            distributeFees(
                transaction.fees.referralBonus,
                currency,
                referelBonusAddress
            );
        }

        transaction.status = STATUS.CLAIMED;
    }

    /**
     * @dev update Transaction details
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function updateTransaction(string memory id, string memory _data)
        external
        noReentrant
    {
        require(isTransaction(id), "Invalid id");
        Transaction storage transaction = transactions[id];
        require(
            msg.sender == transaction.transactionDetails.createdBy,
            "You cannot update"
        );
        require(transaction.isPaid == false, "cannot be updated");
        require(transaction.status == STATUS.CREATED, "transaction not active");
        transaction.transactionDetails.data = _data;
    }

    /**
     * @dev cancel Transaction, admin only
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     * - `buyerAmount` amount to transfer to buyer
     * - `sellerAmount` amount to transfer to seler
     * - `note` cancellation reason
     */

    function cancelTransaction(
        string memory id,
        uint256 buyerAmount,
        uint256 sellerAmount,
        string memory note
    ) external hasCancellationRights noReentrant {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.COMPLETED
        ) {
            revert("Cannot Cancel!");
        }

        transaction.note = note;
        transaction.status = STATUS.CANCELLED;

        if (transaction.isPaid) {
            if (
                compareToIgnoreCase(
                    transaction.transactionDetails.paymentReceiveCurrency,
                    "BNB"
                )
            ) {
                sendBnb(
                    transaction.transactionDetails.buyer,
                    transaction.paymentAmount.sub(sellerAmount)
                );
                sendBnb(
                    transaction.transactionDetails.seller,
                    transaction.paymentAmount.sub(buyerAmount)
                );
            } else {
                address currency = supportedCurrency[
                    upper(transaction.transactionDetails.paymentReceiveCurrency)
                ].val;
                sendAmount(
                    transaction.paymentAmount.sub(sellerAmount),
                    currency,
                    transaction.transactionDetails.buyer
                );
                sendAmount(
                    transaction.paymentAmount.sub(buyerAmount),
                    currency,
                    transaction.transactionDetails.seller
                );
            }
        }
    }

    /**
     * @dev resolve/rais Transaction dispute
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */
    function resolveDispute(string memory id) external returns (bool) {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];
        require(
            transaction.transactionDetails.buyer == msg.sender,
            "not valid buyer"
        );
        require(
            validate(transaction.validUntil) == false,
            "cannot file a dispute"
        );
        require(transaction.isPaid, "transaction not paid");

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.COMPLETED
        ) {
            revert("Cannot raise dispute!");
        }

        if (transaction.status == STATUS.DISPUTE) {
            transaction.status = STATUS.CREATED;
            return false;
        } else {
            transaction.status = STATUS.DISPUTE;
            return true;
        }
    }

    /**
     * @dev get Transaction dispute status
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function isDisputed(string memory id) external view returns (bool) {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];

        if (transaction.status == STATUS.DISPUTE) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev cancel Transaction, only seller
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     * - `note` cancellation note
     */

    function cancelTransaction(string memory id, string memory note)
        external
        noReentrant
    {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];

        require(
            transaction.transactionDetails.seller == msg.sender,
            "not valid seller"
        );
        require(
            validate(transaction.validUntil) == false,
            "cannot be cancelled"
        );

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot Cancel!");
        }

        transaction.note = note;
        transaction.status = STATUS.CANCELLED;

        if (transaction.isPaid) {
            if (
                compareToIgnoreCase(
                    transaction.transactionDetails.paymentReceiveCurrency,
                    "BNB"
                )
            ) {
                sendBnb(
                    transaction.transactionDetails.buyer,
                    transaction.paymentAmount
                );
            } else {
                address currency = supportedCurrency[
                    upper(transaction.transactionDetails.paymentReceiveCurrency)
                ].val;
                sendAmount(
                    transaction.paymentAmount,
                    currency,
                    transaction.transactionDetails.buyer
                );
            }

            refundFees(transaction);
        }
    }

    /**
     * @dev Reject payment of the transaction, only buyer
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function rejectPaymentRequest(string memory id) external noReentrant {
        require(isTransaction(id), "Invalid id");

        Transaction storage transaction = transactions[id];

        require(
            transaction.transactionDetails.buyer == msg.sender,
            "not valid buyer"
        );
        require(transaction.isPaid == false, "cannot reject payment");
        require(
            validate(transaction.validUntil) == false,
            "cannot be cancelled"
        );

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot Cancel!");
        }

        transaction.status = STATUS.CANCELLED;

        if (transaction.islive) {
            refundFees(transaction);
        }
    }

    /**
     * @dev get bnb balnce of the smart contrac
     */

    function getBnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function sendAmount(
        uint256 amount,
        address currency,
        address payAddress
    ) private {
        IBEP20(currency).transferFrom(msg.sender, payAddress, amount);
        emit Withdraw(payAddress, amount);
    }

    function distributeFees(
        uint256 amount,
        address currency,
        address payAddress
    ) private {
        IBEP20(currency).transfer(payAddress, amount);
        emit Withdraw(payAddress, amount);
    }

    function claimAmount(
        uint256 amount,
        address currency,
        address payAddress
    ) private {
        IBEP20(currency).transferFrom(address(this), payAddress, amount);
        emit Withdraw(payAddress, amount);
    }

    function sendBnb(address _to, uint256 referral) private {
        address payable wallet = payable(address(_to));
        wallet.transfer(referral);
    }

    function refundFees(Transaction memory transaction) private {
        if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "BNB"
            )
        ) {
            sendBnb(
                transaction.transactionDetails.createdBy,
                transaction.paymentAmountFees
            );
        } else {
            address currency = supportedCurrency[
                upper(transaction.transactionDetails.feePaymentCurrency)
            ].val;

            sendAmount(
                transaction.paymentAmountFees,
                currency,
                transaction.transactionDetails.createdBy
            );
        }
    }

    /**
     * @dev get Transaction details
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function getTransactions(string memory id)
        external
        view
        returns (
            uint256 _paymentAmount,
            uint256 _paymentAmountFees,
            string memory _feePaymentCurrency,
            string memory _paymentReceiveCurrency,
            string memory _data
        )
    {
        // require(id > 0, "invalid id");
        require(isTransaction(id), "Invalid id");

        _feePaymentCurrency = transactions[id]
            .transactionDetails
            .feePaymentCurrency;
        _paymentReceiveCurrency = transactions[id]
            .transactionDetails
            .paymentReceiveCurrency;
        _paymentAmount = transactions[id].paymentAmount;
        _paymentAmountFees = transactions[id].paymentAmountFees;
        _data = transactions[id].transactionDetails.data;
    }

    /**
     * @dev get Transaction fees details
     *
     * Requirements:
     *
     * - `id` unique transaction ID.
     */

    function getTransactionsFee(string memory id)
        external
        view
        returns (
            string memory feeType,
            uint256 referral,
            uint256 staking,
            uint256 escrow,
            uint256 admin,
            uint256 referralBonus
        )
    {
        // Transaction
        Transaction storage transaction = transactions[id];
        // Fee type of transaction
        if (transaction.fees.feeType == FEES_TYPE.NON_CP) feeType = "NON_CP";
        else if (transaction.fees.feeType == FEES_TYPE.FEES_CP)
            feeType = "FEES_CP";
        else if (transaction.fees.feeType == FEES_TYPE.TRANSACTION_CP)
            feeType = "TRANSACTION_CP";

        // Transaction fees
        referral = transaction.fees.referral;
        staking = transaction.fees.staking;
        escrow = transaction.fees.escrow;
        admin = transaction.fees.admin;
        referralBonus = transaction.fees.referralBonus;
    }

    function validate(uint256 time) internal view returns (bool) {
        if (block.timestamp > time) {
            return true;
        }
        return false;
    }

    function checkSupportedCurrency(string memory name)
        private
        pure
        returns (bool)
    {
        if (compareToIgnoreCase(name, "USDT")) {
            return true;
        } else if (compareToIgnoreCase(name, "BNB")) {
            return true;
        } else if (compareToIgnoreCase(name, "CP")) {
            return true;
        }
        return false;
    }

    function returnFeeType(string memory temp)
        private
        pure
        returns (FEES_TYPE)
    {
        if (compareToIgnoreCase(temp, "NON_CP")) return FEES_TYPE.NON_CP;
        else if (compareToIgnoreCase(temp, "FEES_CP")) return FEES_TYPE.FEES_CP;
        else if (compareToIgnoreCase(temp, "TRANSACTION_CP"))
            return FEES_TYPE.TRANSACTION_CP;
        else revert("Invalid fees type");
    }

    function isTransaction(string memory id)
        private
        view
        returns (bool isIndeed)
    {
        return transactions[id].searchTransaction;
    }

    function upper(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function compareToIgnoreCase(string memory _base, string memory _value)
        internal
        pure
        returns (bool)
    {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for (uint256 i = 0; i < _baseBytes.length; i++) {
            if (
                _baseBytes[i] != _valueBytes[i] &&
                _upper(_baseBytes[i]) != _upper(_valueBytes[i])
            ) {
                return false;
            }
        }

        return true;
    }

    function _upper(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1) - 32);
        }

        return _b1;
    }

    /**
     * @dev Update staking address
     *
     * Requirements:
     * - _value : address
     *
     * - t- `msg.sender` must be the token owner
     */
    function updatePaidStakingAddress(address _address) public onlyOwner {
        require(_address != address(0), "_address can not be the zero address");
        paidStakingAddress = _address;
    }

    /**
     * @dev Update escrow manager address
     *
     * Requirements:
     * - _value : address
     *
     * - t- `msg.sender` must be the token owner
     */
    function updateEscrowManagerAddress(address _address) public onlyOwner {
        require(_address != address(0), "_address can not be the zero address");
        escrowManagerAddress = _address;
    }

    /**
     * @dev Update admin address
     *
     * Requirements:
     * - _value : address
     *
     * - t- `msg.sender` must be the token owner
     */
    function updateAdminAddress(address _address) public onlyOwner {
        require(_address != address(0), "_address can not be the zero address");
        adminAddress = _address;
    }

    /**
     * @dev Update referral bonus address
     *
     * Requirements:
     * - _value : address
     *
     * - t- `msg.sender` must be the token owner
     */
    function updateReferelBonusAddress(address _address) public onlyOwner {
        require(_address != address(0), "_address can not be the zero address");
        referelBonusAddress = _address;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     *  _tokenAddress: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */

    function recoverWrongTokens(address _tokenAddress) external onlyOwner {
        uint256 _tokenAmount = IBEP20(_tokenAddress).balanceOf(address(this));
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
}
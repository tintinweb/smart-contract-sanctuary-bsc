/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {
        require(m != 0, "SafeMath: to ceil number shall not be zero");
        return ((a + m - 1) / m) * m;
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
    address internal _co_owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event CoOwnershipTransferred(
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
     * @dev Returns the address of the current owner.
     */
    function coOwner() public view returns (address) {
        return _co_owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owners.
     */
    modifier onlyOwners() {
        require(
            _owner == _msgSender() || _co_owner == _msgSender(),
            "Ownable: caller is not the owner"
        );
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
     * @dev Transfers co-ownership of the contract to a new account (`newOwner`).
     */
    function transferCoOwnership(address newCoOwner) public onlyOwners {
        require(
            newCoOwner != address(0),
            "Ownable: new co-owner is the zero address"
        );
        emit CoOwnershipTransferred(_co_owner, newCoOwner);
        _co_owner = newCoOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwners {
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
     * @dev Returns the percentage of tokens transfer fees`.
     */
    function FeeRewardPct() external view returns (uint256);

    /**
     * @dev Returns the decimals of token`.
     */
    function decimals() external view returns (uint8);

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
abstract contract BEP20 is Context, IBEP20 {
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
    function decimals() public view virtual override returns (uint8) {
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// ReEntrancyGuard to prevent Reentrancy
contract ChainpalsTransaction is Ownable, ReentrancyGuard {
    // prevents over and under flow
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using SafeBEP20 for BEP20;
    // Admin deposited and withdrawal
    uint256 public depositedCHPAmount;
    uint256 public withdrawnCHPAmount;

    address public paidStakingAddress;
    address public escrowManagerAddress;
    address public escrowBonusAddress;
    address public adminAddress;
    address public referralBonusAddress;
    address public chainpalsPlatformAddress;
    address payable public feesHoldingWalletAddress;
    address public ChainpalsToken;

    enum FEES_TYPE {
        NON_CHP,
        FEES_CHP,
        TRANSACTION_CHP
    }

    enum STATUS {
        CREATED,
        CANCELLED,
        CLAIMED,
        DISPUTE,
        COMPLETED
    }

    FEES_TYPE public FEETYPE;

    struct Fees {
        FEES_TYPE feeType;
        uint256 referral;
        uint256 staking;
        uint256 escrow;
        uint256 escrowBonus;
        uint256 admin;
        uint256 referralBonus;
    }

    struct TransactionDetails {
        string paymentReceiveCurrency;
        address paymentReceiveCurrencyAddress;
        string data;
        string feePaymentCurrency;
        address feePaymentCurrencyAddress;
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

    event TransactionCreation(address _creator, string _transactionId);
    event TransactionPayment(
        address _user,
        string _transactionId,
        uint256 _amount
    );
    event ClaimTransactionAmount(
        address _user,
        string _transactionId,
        uint256 _amount
    );
    event CancelTransaction(address _user, string _transactionId);
    event RejectTransactionPayment(address _user, string _transactionId);
    event DisputeRaised(address _user, string _transactionId);
    event DisputeResolved(address _user, string _transactionId);

    mapping(string => Transaction) public transactions;

    // Check whether user has rights to cancel the transaction
    modifier hasCancellationRights() {
        require(
            msg.sender == owner() ||
                msg.sender == escrowManagerAddress ||
                msg.sender == adminAddress,
            "Caller don't have cancellation rights!"
        );
        _;
    }

    /**
     * This value is immutable: it can only be set once during
     * construction.
     */

    constructor(
        address _ChainpalsToken,
        address _coOwnerAddress,
        address _paidStakingAddress,
        address _escrowManagerAddress,
        address _escrowBonusAddress,
        address _adminAddress,
        address _referralBonusAddress,
        address _chainpalsPlatformAddress,
        address payable _feesHoldingWalletAddress
    ) public {
        ChainpalsToken = _ChainpalsToken;
        _co_owner = _coOwnerAddress;
        paidStakingAddress = _paidStakingAddress;
        escrowManagerAddress = _escrowManagerAddress;
        escrowBonusAddress = _escrowBonusAddress;
        adminAddress = _adminAddress;
        referralBonusAddress = _referralBonusAddress;
        chainpalsPlatformAddress = _chainpalsPlatformAddress;
        feesHoldingWalletAddress = _feesHoldingWalletAddress;
    }

    /**
     * @dev Create new Transaction.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_transactionDetails` Transaction details tuple
     * - `_feeType` transaction fee type
     * - `_referralAddress` address of the referral user if any
     * - `_paymentAmount` transaction amount
     * - `_totalFeesAmount` transaction fee amount in respected currency
     * - `_fees` array of fees to be distribute as platform fees
     */

    function createTransaction(
        string memory _uid,
        TransactionDetails memory _transactionDetails,
        string memory _feeType,
        address _referralAddress,
        uint256 _paymentAmount,
        uint256 _totalFeesAmount,
        uint256[] memory _fees
    ) external nonReentrant returns (bool) {
        require(_paymentAmount != 0, "Invalid payment amount");
        require(isTransaction(_uid) == false, "Invalid transaction id");
        require(_fees.length == 6, "Please include all fees");
        validateNonZeroAddress(_referralAddress);
        Transaction storage transaction = transactions[_uid];
        transaction.transactionDetails = _transactionDetails;
        transaction.referralAddress = _referralAddress;

        transaction.status = STATUS.CREATED;
        transaction.isPaid = false;
        transaction.islive = false;

        transaction.searchTransaction = true;
        transaction.paymentAmount = _paymentAmount;

        // platform fees calculation
        uint256[] memory feeValues = _fees;

        uint256 decimalMul = 10**12;
        transaction.paymentAmountFees = _totalFeesAmount;

        transaction.fees.referral = feeValues[0].mul(decimalMul);
        transaction.fees.staking = feeValues[1].mul(decimalMul);
        transaction.fees.escrow = feeValues[2].mul(decimalMul);
        transaction.fees.escrowBonus = feeValues[3].mul(decimalMul);
        transaction.fees.admin = feeValues[4].mul(decimalMul);
        transaction.fees.referralBonus = feeValues[5].mul(decimalMul);
        transaction.fees.feeType = returnFeeType(_feeType);
        emit TransactionCreation(msg.sender, _uid);
        return true;
    }

    /**
     * @dev Create new Transaction for unregistered user.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_data` Transaction data to store
     * - `_feePaymentCurrency` currency name in form of ENUM
     * - `_feePaymentCurrencyAddress` currency address
     * - `_paymentReceiveCurrency` payment currency name in form of ENUM
     * - `_paymentReceiveCurrencyAddress` payment currency address
     * - `_feeType` transaction fee type
     * - `_role` user role (BUYER/SELLER)
     * - `_userAddress` address of the user
     * - `_paymentAmount` transaction amount
     * - `_totalFeesAmount` transaction fee amount in respected currency
     * - `_fees` array of fees to be distribute as platform fees
     */

    function createTransactionForUnregistered(
        string memory _uid,
        string memory _data,
        string memory _feePaymentCurrency,
        address _feePaymentCurrencyAddress,
        string memory _paymentReceiveCurrency,
        address _paymentReceiveCurrencyAddress,
        string memory _feeType,
        string memory _role,
        address _userAddress,
        uint256 _paymentAmount,
        uint256 _totalFeesAmount,
        uint256[] memory _fees
    ) external nonReentrant returns (bool) {
        require(_paymentAmount != 0, "Invalid payment amount");
        require(_totalFeesAmount != 0, "Invalid fees amount");
        require(isTransaction(_uid) == false, "Invalid transaction id");
        require(_fees.length == 6, "Please include all fees");
        validateNonZeroAddress(_feePaymentCurrencyAddress);
        validateNonZeroAddress(_paymentReceiveCurrencyAddress);
        validateNonZeroAddress(_userAddress);
        Transaction storage transaction = transactions[_uid];

        transaction
            .transactionDetails
            .paymentReceiveCurrency = _paymentReceiveCurrency;
        transaction
            .transactionDetails
            .paymentReceiveCurrencyAddress = _paymentReceiveCurrencyAddress;

        transaction.status = STATUS.CREATED;
        transaction.isPaid = false;
        transaction.islive = false;

        if (compareToIgnoreCase(_role, "BUYER")) {
            transaction.transactionDetails.buyer = _userAddress;
        } else {
            transaction.transactionDetails.seller = _userAddress;
        }

        transaction.transactionDetails.feePaymentCurrency = _feePaymentCurrency;
        transaction
            .transactionDetails
            .feePaymentCurrencyAddress = _feePaymentCurrencyAddress;
        transaction.transactionDetails.data = _data;
        transaction.transactionDetails.createdBy = msg.sender;
        transaction.paymentAmount = _paymentAmount;

        // platform fees calculation
        uint256[] memory feeValues = _fees;
        uint256 decimalMul = 10**12;
        transaction.paymentAmountFees = _totalFeesAmount;

        transaction.fees.referral = feeValues[0].mul(decimalMul);
        transaction.fees.staking = feeValues[1].mul(decimalMul);
        transaction.fees.escrow = feeValues[2].mul(decimalMul);
        transaction.fees.escrowBonus = feeValues[3].mul(decimalMul);
        transaction.fees.admin = feeValues[4].mul(decimalMul);
        transaction.fees.referralBonus = feeValues[5].mul(decimalMul);
        transaction.fees.feeType = returnFeeType(_feeType);
        return true;
    }

    /**
     * @dev Add unregistered user into the transaction
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_role` user role (BUYER/SELLER)
     * - `_userAddress` address of the user
     * - `_referralAddress` address of the referral user if any
     */

    function addUnregisteredUserIntoTransaction(
        string memory _uid,
        string memory _role,
        address _userAddress,
        address _referralAddress
    ) external nonReentrant returns (bool) {
        require(
            msg.sender == chainpalsPlatformAddress,
            "Caller can not add user to the transaction!"
        );
        require(isTransaction(_uid) == false, "Invalid transaction id");
        validateNonZeroAddress(_userAddress);
        validateNonZeroAddress(_referralAddress);
        Transaction storage transaction = transactions[_uid];
        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );

        if (compareToIgnoreCase(_role, "BUYER")) {
            require(
                transaction.transactionDetails.buyer == address(0),
                "Buyer's address is already assigned!"
            );
            transaction.transactionDetails.buyer = _userAddress;
        } else {
            require(
                transaction.transactionDetails.seller == address(0),
                "Seller's address is already assigned!"
            );
            transaction.transactionDetails.seller = _userAddress;
        }
        transaction.searchTransaction = true;
        transaction.referralAddress = _referralAddress;
        return true;
    }

    /**
     * @dev Pay platform fees for Transaction using ALT coin.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_amount` fees to pay
     * - `_token` currency address
     */

    function onChainATransactionALT(
        string memory _uid,
        uint256 _amount,
        address _token
    ) external nonReentrant returns (bool) {
        require(_amount != 0, "_amount shold not be zero");
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];
        require(
            transaction.transactionDetails.feePaymentCurrencyAddress == _token,
            "Wrong token address"
        );
        require(
            msg.sender == transaction.transactionDetails.buyer,
            "Only buyer can pay fees"
        );
        require(transaction.islive == false, "Fees are already paid");
        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );

        if (_amount != 0) {
            require(
                transaction.paymentAmountFees <= _amount,
                "Invalid fees amount"
            );
            transferFromFunds(
                _amount,
                _token,
                address(msg.sender),
                address(this)
            );
            transaction.islive = true;
        }
        return true;
    }

    /**
     * @dev Pay platform fees for Transaction in BNB.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */
    function onChainATransactionBNB(string memory _uid)
        external
        payable
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];
        require(
            msg.sender == transaction.transactionDetails.buyer,
            "Only buyer can pay fees"
        );
        require(transaction.islive == false, "Fees are already paid");
        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );

        if (msg.value != 0) {
            require(
                compareToIgnoreCase(
                    transaction.transactionDetails.feePaymentCurrency,
                    "BNB"
                ),
                "Only BNB"
            );
            require(
                msg.value >= transaction.paymentAmountFees,
                "Invalid fees amount"
            );

            transaction.islive = true;
        }
        return true;
    }

    /**
     * @dev Pay Transaction amount in ALT coin.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_amount` amount to pay
     * - `_token` currency address
     * - `_paymentHoldingDays` transaction holding period
     */

    function payTransactionALT(
        string memory _uid,
        uint256 _amount,
        address _token,
        uint256 _paymentHoldingDays
    ) external nonReentrant returns (bool) {
        require(_amount != 0, "_amount shold not be zero");
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];
        require(
            transaction.transactionDetails.paymentReceiveCurrencyAddress ==
                _token,
            "Wrong token address"
        );

        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );
        require(
            msg.sender == transaction.transactionDetails.buyer,
            "Not valid buyer"
        );
        require(transaction.isPaid == false, "Amount already paid");

        if (
            transaction.islive == true && _amount >= transaction.paymentAmount
        ) {
            transferFromFunds(
                _amount,
                _token,
                address(msg.sender),
                address(this)
            );
            transaction.isPaid = true;
            transaction.validUntil = block.timestamp + _paymentHoldingDays;
        } else if (
            transaction.islive == false &&
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                transaction.transactionDetails.paymentReceiveCurrency
            )
        ) {
            if (
                transaction.transactionDetails.buyer ==
                transaction.transactionDetails.createdBy
            ) {
                require(
                    _amount >=
                        transaction.paymentAmount.add(
                            transaction.paymentAmountFees
                        ),
                    "Invalid Amount"
                );
                transferFromFunds(
                    _amount,
                    _token,
                    address(msg.sender),
                    address(this)
                );
                transaction.islive = true;
                transaction.isPaid = true;
                transaction.validUntil = block.timestamp + _paymentHoldingDays;
            } else if (
                transaction.transactionDetails.seller ==
                transaction.transactionDetails.createdBy
            ) {
                require(_amount >= transaction.paymentAmount, "Invalid Amount");
                transferFromFunds(
                    _amount,
                    _token,
                    address(msg.sender),
                    address(this)
                );
                transaction.islive = true;
                transaction.isPaid = true;
                transaction.validUntil = block.timestamp + _paymentHoldingDays;
            }
        }
        emit TransactionPayment(msg.sender, _uid, transaction.paymentAmount);
        return true;
    }

    /**
     * @dev Pay Transaction amount in BNB.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_paymentHoldingDays` transaction holding period
     */

    function payTransactionBNB(string memory _uid, uint256 _paymentHoldingDays)
        external
        payable
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];

        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );
        require(
            msg.sender == transaction.transactionDetails.buyer,
            "Not valid buyer"
        );
        require(transaction.isPaid == false, "Amount already paid");
        require(
            compareToIgnoreCase(
                transaction.transactionDetails.paymentReceiveCurrency,
                "BNB"
            ),
            "Only BNB transactions are valid"
        );

        if (
            transaction.islive == true && msg.value >= transaction.paymentAmount
        ) {
            transaction.isPaid = true;
            transaction.validUntil = block.timestamp + _paymentHoldingDays;
        } else if (
            transaction.islive == false &&
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                transaction.transactionDetails.paymentReceiveCurrency
            )
        ) {
            if (
                transaction.transactionDetails.buyer ==
                transaction.transactionDetails.createdBy
            ) {
                require(
                    msg.value >=
                        transaction.paymentAmount.add(
                            transaction.paymentAmountFees
                        ),
                    "Invalid Amount"
                );

                transaction.islive = true;
                transaction.isPaid = true;
                transaction.validUntil = block.timestamp + _paymentHoldingDays;
            } else if (
                transaction.transactionDetails.seller ==
                transaction.transactionDetails.createdBy
            ) {
                require(
                    msg.value >= transaction.paymentAmount,
                    "Invalid Amount"
                );

                transaction.islive = true;
                transaction.isPaid = true;
                transaction.validUntil = block.timestamp + _paymentHoldingDays;
            }
        }
        emit TransactionPayment(msg.sender, _uid, transaction.paymentAmount);
        return true;
    }

    /**
     * @dev claim Transaction amount after sucessful transaction.
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */

    function claimTransactionAmount(string memory _uid)
        external
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];
        require(transaction.islive, "Transaction is not ready");

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot claim!");
        }

        require(
            msg.sender == transaction.transactionDetails.seller ||
                msg.sender == chainpalsPlatformAddress,
            "You cannot claim the amount"
        );
        require(validate(transaction.validUntil), "Claim cannot be made");

        address paymentCurrency = transaction
            .transactionDetails
            .paymentReceiveCurrencyAddress;
        address currency = transaction
            .transactionDetails
            .feePaymentCurrencyAddress;

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.paymentReceiveCurrency,
                "BNB"
            )
        ) {
            if (
                transaction.transactionDetails.seller ==
                transaction.transactionDetails.createdBy
            ) {
                sendBnb(
                    transaction.transactionDetails.seller,
                    transaction.paymentAmount.sub(transaction.paymentAmountFees)
                );
            } else {
                sendBnb(
                    transaction.transactionDetails.seller,
                    transaction.paymentAmount
                );
            }
        } else {
            if (
                transaction.transactionDetails.seller ==
                transaction.transactionDetails.createdBy
            ) {
                transferFunds(
                    transaction.paymentAmount.sub(
                        transaction.paymentAmountFees
                    ),
                    paymentCurrency,
                    transaction.transactionDetails.seller
                );
            } else {
                transferFunds(
                    transaction.paymentAmount,
                    paymentCurrency,
                    transaction.transactionDetails.seller
                );
            }
        }

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "BNB"
            )
        ) {
            sendBnb(feesHoldingWalletAddress, transaction.paymentAmountFees);
            transferFees(transaction);
        } else if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "CHP"
            ) == false
        ) {
            transferFunds(
                transaction.paymentAmountFees,
                currency,
                feesHoldingWalletAddress
            );
            transferFees(transaction);
        } else if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "CHP"
            )
        ) {
            transferFees(transaction);
        }

        transaction.status = STATUS.CLAIMED;
        emit ClaimTransactionAmount(
            msg.sender,
            _uid,
            transaction.paymentAmount
        );
        return true;
    }

    /**
     * @dev update Transaction details
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_data` new updated data
     */

    function updateTransaction(string memory _uid, string memory _data)
        external
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");
        Transaction storage transaction = transactions[_uid];
        require(
            msg.sender == transaction.transactionDetails.createdBy,
            "You cannot update the transaction"
        );
        require(transaction.isPaid == false, "Transaction cannot be updated");
        require(
            transaction.status == STATUS.CREATED,
            "Transaction is not active"
        );
        transaction.transactionDetails.data = _data;
        return true;
    }

    /**
     * @dev cancel Transaction, only seller
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_note` cancellation note
     */

    function cancelTransaction(string memory _uid, string memory _note)
        external
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];

        require(
            msg.sender == transaction.transactionDetails.seller,
            "Not valid seller"
        );
        require(
            validate(transaction.validUntil) == false,
            "Cannot be cancelled"
        );

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot Cancel the transaction");
        }

        transaction.note = _note;
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
                address currency = transaction
                    .transactionDetails
                    .paymentReceiveCurrencyAddress;
                transferFunds(
                    transaction.paymentAmount,
                    currency,
                    transaction.transactionDetails.buyer
                );
            }
        }

        if (
            transaction.islive &&
            transaction.transactionDetails.buyer ==
            transaction.transactionDetails.createdBy
        ) {
            refundFees(transaction);
        }
        emit CancelTransaction(msg.sender, _uid);
        return true;
    }

    /**
     * @dev Reject payment of the transaction, only buyer
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */

    function rejectPaymentRequest(string memory _uid)
        external
        nonReentrant
        returns (bool)
    {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];

        require(
            msg.sender == transaction.transactionDetails.buyer,
            "Not valid buyer"
        );
        require(transaction.isPaid == false, "Cannot reject payment");
        require(
            validate(transaction.validUntil) == false,
            "Cannot be cancelled"
        );

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.CLAIMED ||
            transaction.status == STATUS.COMPLETED ||
            transaction.status == STATUS.DISPUTE
        ) {
            revert("Cannot Cancel the transaction");
        }

        transaction.status = STATUS.CANCELLED;

        if (
            transaction.islive &&
            transaction.transactionDetails.buyer ==
            transaction.transactionDetails.createdBy
        ) {
            refundFees(transaction);
        }
        emit RejectTransactionPayment(msg.sender, _uid);
        return true;
    }

    /**
     * @dev get Transaction dispute status
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */

    function isDisputed(string memory _uid) external view returns (bool) {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];

        if (transaction.status == STATUS.DISPUTE) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev resolve/rais Transaction dispute
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */
    function dispute(string memory _uid) external nonReentrant returns (bool) {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];
        require(
            msg.sender == transaction.transactionDetails.buyer ||
                msg.sender == owner() ||
                msg.sender == escrowManagerAddress ||
                msg.sender == adminAddress,
            "User can not resolve the dispute."
        );
        require(
            transaction.status == STATUS.DISPUTE ||
                validate(transaction.validUntil) == false,
            "Cannot file a dispute at moment"
        );
        require(transaction.isPaid, "Transaction is not paid");

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.COMPLETED
        ) {
            revert("Cannot raise a dispute!");
        }

        if (transaction.status == STATUS.DISPUTE) {
            transaction.status = STATUS.CREATED;
            emit DisputeResolved(msg.sender, _uid);
            return false;
        } else {
            transaction.status = STATUS.DISPUTE;
            emit DisputeRaised(msg.sender, _uid);
            return true;
        }
    }

    /**
     * @dev cancel Transaction, platform/admin only
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     * - `_note` cancellation reason
     * - `_buyerAmount` amount to transfer to buyer
     * - `_sellerAmount` amount to transfer to seler
     */

    function cancelTransaction(
        string memory _uid,
        string memory _note,
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) external hasCancellationRights nonReentrant returns (bool) {
        require(isTransaction(_uid), "Invalid transaction id");

        Transaction storage transaction = transactions[_uid];

        if (
            transaction.status == STATUS.CANCELLED ||
            transaction.status == STATUS.COMPLETED
        ) {
            revert("Cannot cancel the transaction");
        }

        transaction.note = _note;
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
                    transaction.paymentAmount.sub(_sellerAmount)
                );
                sendBnb(
                    transaction.transactionDetails.seller,
                    transaction.paymentAmount.sub(_buyerAmount)
                );
            } else {
                address currency = transaction
                    .transactionDetails
                    .paymentReceiveCurrencyAddress;

                transferFunds(
                    transaction.paymentAmount.sub(_sellerAmount),
                    currency,
                    transaction.transactionDetails.buyer
                );
                transferFunds(
                    transaction.paymentAmount.sub(_buyerAmount),
                    currency,
                    transaction.transactionDetails.seller
                );
            }
        }

        address currency = transaction
            .transactionDetails
            .feePaymentCurrencyAddress;

        if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "BNB"
            )
        ) {
            sendBnb(feesHoldingWalletAddress, transaction.paymentAmountFees);
            transferFees(transaction);
        } else if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "CHP"
            ) == false
        ) {
            transferFunds(
                transaction.paymentAmountFees,
                currency,
                feesHoldingWalletAddress
            );
            transferFees(transaction);
        } else if (
            compareToIgnoreCase(
                transaction.transactionDetails.feePaymentCurrency,
                "CHP"
            )
        ) {
            transferFees(transaction);
        }
        emit CancelTransaction(msg.sender, _uid);
        return true;
    }

    /**
     * @dev get Transaction details
     *
     * Requirements:
     *
     * - `_uid` unique transaction ID.
     */

    function getTransactions(string memory _uid)
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
        require(isTransaction(_uid), "Invalid transaction id");

        _feePaymentCurrency = transactions[_uid]
            .transactionDetails
            .feePaymentCurrency;
        _paymentReceiveCurrency = transactions[_uid]
            .transactionDetails
            .paymentReceiveCurrency;
        _paymentAmount = transactions[_uid].paymentAmount;
        _paymentAmountFees = transactions[_uid].paymentAmountFees;
        _data = transactions[_uid].transactionDetails.data;
    }

    /**
     * @dev Deposit CHP tokens to satisfy fees distribution
     *
     * Requirements:
     * - _amount : CHP amount to deposit
     *
     * - t- `msg.sender` must be the contract owner
     */
    function depositCHPTokens(uint256 _amount)
        external
        onlyOwner
        nonReentrant
        returns (bool)
    {
        transferFromFunds(
            _amount,
            ChainpalsToken,
            address(msg.sender),
            address(this)
        );
        depositedCHPAmount = depositedCHPAmount.add(_amount);
        return true;
    }

    /**
     * @dev Withdraw CHP tokens to from contract
     *
     * Requirements:
     * - _amount : CHP amount to withdraw
     *
     * - t- `msg.sender` must be the contract owner
     */
    function withdrawCHPTokens(uint256 _amount)
        external
        onlyOwner
        nonReentrant
        returns (bool)
    {
        require(
            _amount <= depositedCHPAmount.sub(withdrawnCHPAmount),
            "Wrong withdrawal amount"
        );
        transferFunds(_amount, ChainpalsToken, address(msg.sender));
        withdrawnCHPAmount = withdrawnCHPAmount.add(_amount);
        return true;
    }

    /**
     * @dev Update staking address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updatePaidStakingAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        paidStakingAddress = _address;
        return true;
    }

    /**
     * @dev Update escrow manager address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updateEscrowManagerAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        escrowManagerAddress = _address;
        return true;
    }

    /**
     * @dev Update escrow bonus address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updateEscrowBonusAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        escrowBonusAddress = _address;
        return true;
    }

    /**
     * @dev Update admin address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updateAdminAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        adminAddress = _address;
        return true;
    }

    /**
     * @dev Update referral bonus address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updatereferralBonusAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        referralBonusAddress = _address;
        return true;
    }

    /**
     * @dev Update chainpals platform address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updateChainpalsPlatformAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        chainpalsPlatformAddress = _address;
        return true;
    }

    /**
     * @dev Update fees holding walllet address
     *
     * Requirements:
     * - _address : address
     *
     * - t- `msg.sender` must be the contract owner
     */
    function updateFeesHoldingWalletAddress(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        feesHoldingWalletAddress = _address;
        return true;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     *  _tokenAddress: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */

    function recoverWrongTokens(address _tokenAddress)
        external
        onlyOwner
        returns (bool)
    {
        uint256 _tokenAmount = IBEP20(_tokenAddress).balanceOf(address(this));
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        return true;
    }

    /**
     * @dev util function to check whether current time is passed than valid till date time
     */
    function validate(uint256 _time) internal view returns (bool) {
        if (_time != 0 && block.timestamp > _time) {
            return true;
        }
        return false;
    }

    /**
     * @dev Utility function to compare two string
     */
    function compareToIgnoreCase(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    /**
     * @dev Validate address is not zero address
     *
     * Requirements:
     * - _address : address
     */

    function validateNonZeroAddress(address _address) private pure {
        require(_address != address(0), "_address can not be the zero address");
    }

    /**
     * @dev to transfer funds from smart contract
     */

    function transferFunds(
        uint256 _amount,
        address _currency,
        address _payAddress
    ) private {
        IBEP20(_currency).transfer(_payAddress, _amount);
    }

    /**
     * @dev to transfer funds from smart contract
     */

    function transferFromFunds(
        uint256 _amount,
        address _currency,
        address _fromAddress,
        address _payAddress
    ) private {
        IBEP20(_currency).transferFrom(_fromAddress, _payAddress, _amount);
    }

    /**
     * @dev to transfer BNB funds from smart contract
     */
    function sendBnb(address _to, uint256 _referral) private {
        address payable wallet = payable(address(_to));
        wallet.transfer(_referral);
    }

    /**
     * @dev util function to transfer/refund the BNB and alt funds from smart contract
     */
    function refundFees(Transaction memory _transaction) private {
        if (
            compareToIgnoreCase(
                _transaction.transactionDetails.feePaymentCurrency,
                "BNB"
            )
        ) {
            sendBnb(
                _transaction.transactionDetails.createdBy,
                _transaction.paymentAmountFees
            );
        } else {
            address currency = _transaction
                .transactionDetails
                .feePaymentCurrencyAddress;

            transferFunds(
                _transaction.paymentAmountFees,
                currency,
                _transaction.transactionDetails.createdBy
            );
        }
    }

    /**
     * @dev util function to transfer/refund the BNB and alt fees from smart contract
     */
    function transferFees(Transaction memory _transaction) private {
        transferFunds(
            _transaction.fees.referral,
            ChainpalsToken,
            _transaction.referralAddress
        );

        transferFunds(
            _transaction.fees.staking,
            ChainpalsToken,
            paidStakingAddress
        );
        transferFunds(
            _transaction.fees.escrow,
            ChainpalsToken,
            escrowManagerAddress
        );
        transferFunds(
            _transaction.fees.escrowBonus,
            ChainpalsToken,
            escrowBonusAddress
        );
        transferFunds(_transaction.fees.admin, ChainpalsToken, adminAddress);
        transferFunds(
            _transaction.fees.referralBonus,
            ChainpalsToken,
            referralBonusAddress
        );
    }

    /**
     * @dev util function to determine fee type of the transaction
     */
    function returnFeeType(string memory _temp)
        private
        pure
        returns (FEES_TYPE)
    {
        if (compareToIgnoreCase(_temp, "NON_CHP")) return FEES_TYPE.NON_CHP;
        else if (compareToIgnoreCase(_temp, "FEES_CHP"))
            return FEES_TYPE.FEES_CHP;
        else if (compareToIgnoreCase(_temp, "TRANSACTION_CHP"))
            return FEES_TYPE.TRANSACTION_CHP;
        else revert("Invalid fees type");
    }

    /**
     * @dev util function to check transaction id is valid or not
     */
    function isTransaction(string memory _uid)
        private
        view
        returns (bool isIndeed)
    {
        return transactions[_uid].searchTransaction;
    }
}
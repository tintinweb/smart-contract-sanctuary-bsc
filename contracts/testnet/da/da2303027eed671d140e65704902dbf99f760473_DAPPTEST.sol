/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

pragma solidity ^0.6.2;


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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
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
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an BNB balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-bep20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is cur conventional
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
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * BNB and Wei. This is the value {BEP20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
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
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    function _setupDecimals(uint8 decimals_) internal {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract DAPPTEST is BEP20("DAPPTEST", "DPT") {
    address public wallet_99_strong_hand = 0x99CCf93F229F85D774103A843071D7AB4A96A8Bb;
    uint256 public initialPrice = 0.001 szabo;
    uint256 public increment = 0.001 szabo;
    uint256 public minPurchase = 1 ether;
    uint256 public reinvestFee = 10;
    uint256 public transferFee = 10;
    uint256 public withdrawFee = 10;
    uint256 public referrerFee = 5;
    uint256 public buyFee = 5;
    uint256 public sellFee = 10;
    uint256 public dividendsPerShare;
    uint256 public start;
    uint256 constant internal magnitude = 1 ether;
    mapping (address => address) public referrer;
    mapping (address => uint256) public referralEarnings;
    mapping (address => int256) public dividendsPayouts;

    event Reinvest(address _member, uint256 _bnb, uint256 _tokens);
    event Withdraw(address _member, uint256 _bnb);
    event Buy(address _member, uint256 _bnb, uint256 _tokens, address _referrer);
    event Sell(address _member, uint256 _bnb, uint256 _tokens);

    constructor () public {
        start = now;
    }

    /**
     * Calculate Dividends
     */
    function getDividends(address _member)
        public
        view
        returns(uint256)
    {
        uint256 _balance = balanceOf(_member);
        uint256 _dividends = (uint256)((int256)(_balance.mul(dividendsPerShare)) - dividendsPayouts[_member])
        .div(magnitude);
        uint256 _contractBalance = address(this).balance;

        if (_dividends > _contractBalance) return _contractBalance;
        return _dividends;
    }

    /**
     * Reinvest
     */
    function reinvest()
        public
        returns(uint256)
    {
        uint256 _bnb = getDividends(msg.sender);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            + (int256)(_bnb.mul(magnitude));

        _bnb = _bnb
        .add(referralEarnings[msg.sender]);
        referralEarnings[msg.sender] = 0;

        uint256 _fee = _bnb.mul(reinvestFee).div(100);
        uint256 _reinvest = _bnb.sub(_fee);

        uint256 _tokens = bnbToTokens(_reinvest);

        require (_tokens >= minPurchase, 
            'Token equivalent amount should not be less than 1 token');

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            + (int256)(dividendsPerShare.mul(_tokens));

        emit Reinvest(msg.sender, _bnb, _tokens);
        _mint(msg.sender, _tokens);

        uint256 _supply = totalSupply();
        if (_supply > 0) {
            dividendsPerShare = dividendsPerShare
            .add(_fee.mul(magnitude).div(_supply));
        } else {
            dividendsPerShare = 0;
        }        
    }

    /**
     * Withdraw dividends
     */
    // function withdrawPart(uint256 _bnb)
    //     public
    //     returns(bool)
    // {
    //     uint256 _dividends = getDividends(msg.sender);
    //     require(_bnb <= _dividends, 'Not enough dividends');

    //     dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
    //         + (int256)(_bnb.mul(magnitude));

    //     uint256 _fee = _bnb.mul(withdrawFee).div(100);
    //     uint256 _withdraw = _bnb.sub(_fee);

    //     uint256 _tokens = bnbToTokens(_withdraw);

    //     require (_tokens >= minPurchase, 
    //         'Token equivalent amount should not be less than 1 token');

    //     emit Withdraw(msg.sender, _bnb);

    //     payable(wallet_99_strong_hand).transfer(_fee);
    //     payable(msg.sender).transfer(_withdraw);
    //     return true;
    // }

    /**
     * Withdraw dividends
     */
    function withdraw()
        public
        returns(bool)
    {
        uint256 _bnb = getDividends(msg.sender);
        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            + (int256)(_bnb.mul(magnitude));

        _bnb = _bnb
        .add(referralEarnings[msg.sender]);
        referralEarnings[msg.sender] = 0;

        uint256 _fee = _bnb.mul(withdrawFee).div(100);
        uint256 _withdraw = _bnb.sub(_fee);

        uint256 _tokens = bnbToTokens(_withdraw);

        require (_tokens >= minPurchase, 
            'Token equivalent amount should not be less than 1 token');

        emit Withdraw(msg.sender, _bnb);

        payable(wallet_99_strong_hand).transfer(_fee);
        payable(msg.sender).transfer(_withdraw);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        require (_amount >= minPurchase, 
            'Token amount should not be less than 1 token');
        require (_amount <= balanceOf(msg.sender), 
            'Token amount should not be greater than balance');
        uint256 _fee = _amount.mul(transferFee).div(100);
        uint256 _tokens = _amount.sub(_fee);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            - (int256)(dividendsPerShare.mul(_amount));
        dividendsPayouts[_recipient] = dividendsPayouts[_recipient]
            + (int256)(dividendsPerShare.mul(_tokens));

        _burn(msg.sender, _fee);

        dividendsPerShare = dividendsPerShare
        .add(tokensToBnb(_fee).mul(magnitude).div(totalSupply()));
        return super.transfer(_recipient, _tokens);
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        require (_amount >= minPurchase, 
            'Token amount should not be less than 1 token');
        require (_amount <= balanceOf(_sender), 
            'Token amount should not be greater than balance');
        uint256 _fee = _amount.mul(transferFee).div(100);
        uint256 _tokens = _amount.sub(_fee);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            - (int256)(dividendsPerShare.mul(_amount));
        dividendsPayouts[_recipient] = dividendsPayouts[_recipient]
            + (int256)(dividendsPerShare.mul(_tokens));

        _burn(_sender, _fee);

        dividendsPerShare = dividendsPerShare
        .add(tokensToBnb(_fee).mul(magnitude).div(totalSupply()));
        return super.transferFrom(_sender, _recipient, _tokens);
    }    
    
    receive() payable external {
        purchase(msg.value, address(0));
    }

    function buy(address _referrer) payable external {
        purchase(msg.value, _referrer);
    }

    function purchase(uint256 _amount, address _referrer) internal {
        require (msg.sender != _referrer, 'You can not be your referrer');
        uint256 _refFee = _amount.mul(referrerFee).div(100);
        uint256 _buyFee = _amount.mul(buyFee).div(100);
        uint256 _totalFee = _refFee.add(_buyFee);
        if (referrer[msg.sender] == address(0)
            && _referrer != address(0)
            && balanceOf(_referrer) >= 99 ether) {
            referrer[msg.sender] = _referrer;
            referralEarnings[_referrer] = referralEarnings[_referrer]
            .add(_refFee);
        } else {
            _buyFee = _totalFee;
        }
        
        uint256 _tokens = bnbToTokens(_amount.sub(_totalFee));

        require (_tokens >= minPurchase, 
            'Tokens amount should not be less than 1 token');

        emit Buy(msg.sender, _amount, _tokens, _referrer);

        _mint(msg.sender, _tokens);
        uint256 _supply = totalSupply();

        uint256 _extra = _buyFee
        .mul(magnitude)
        .div(_supply);

        if (dividendsPerShare > 0) {
            dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            + (int256)(dividendsPerShare.mul(_tokens));
        }

        dividendsPerShare = dividendsPerShare
        .add(_extra);
    }

    function sell(uint256 _tokens) external {
        require (_tokens >= minPurchase, 
            'Tokens amount should not be less than 1 token');
        require (_tokens <= balanceOf(msg.sender), 
            'Not enough tokens');
        uint256 _amount = tokensToBnb(_tokens);
        uint256 _fee = _amount.mul(sellFee).div(100);

        emit Sell(msg.sender, _amount, _tokens);

        _burn(msg.sender, _tokens);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            - (int256)(dividendsPerShare.mul(_tokens));

        uint256 _supply = totalSupply();

        if (_supply > 0) { 
            dividendsPerShare = dividendsPerShare
            .add(_fee.mul(magnitude).div(_supply));
        } else {
            dividendsPerShare = 0;
            dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
                - (int256)(_fee.mul(magnitude));
        }

        payable(msg.sender)
        .transfer(_amount.sub(_fee));
    }

    function getCurrentPrice () public view returns(uint256) {
        uint256 supply = totalSupply();
        uint256 supplyInt = supply.div(1 ether);
        return supplyInt.mul(increment).add(initialPrice);
    }

    /**
     * Calculate Token price based on an amount of incoming BNB
     */
    function bnbToTokens(uint256 _bnb)
        public
        view
        returns(uint256)
    {
        // return _bnb;
        uint256 bnb = _bnb;
        uint256 supply = totalSupply();
        uint256 supplyInt = supply.div(1 ether);
        uint256 supplyFract = supply.sub(supplyInt.mul(1 ether));
        uint256 currentPrice = supplyInt.mul(increment).add(initialPrice);
        uint256 tokens;
        uint256 tempTokens = bnb.mul(1 ether).div(currentPrice);

        if (tempTokens < supplyFract) {
            return tempTokens;
        }

        tokens = tokens.add(supplyFract);

        bnb = bnb.sub(supplyFract.mul(currentPrice).div(1 ether));
        if (supplyFract > 0) {
            currentPrice = currentPrice.add(increment);
        }
        tempTokens = bnb.mul(1 ether).div(currentPrice);

        if (tempTokens <= 1 ether) {
            return tokens.add(tempTokens);
        }

        uint256 d = currentPrice.mul(2)
        .sub(increment);
        d = d.mul(d);
        d = d.add(increment.mul(bnb).mul(8));

        uint256 sqrtD = sqrt(d);
        
        tempTokens = increment
        .add(sqrtD)
        .sub(currentPrice.mul(2));

        tempTokens = tempTokens
        .mul(1 ether)
        .div(increment.mul(2));

        tokens = tokens.add(tempTokens);

        return tokens;
    }
    
    /**
     * Calculate tokens
    */
     function tokensToBnb(uint256 _tokens)
        public
        view
        returns(uint256)
    {
        // return _tokens;
        uint256 tokens = _tokens;
        uint256 supply = totalSupply();
        if (tokens > supply) return 0;
        uint256 supplyInt = supply.div(1 ether);
        uint256 supplyFract = supply.sub(supplyInt.mul(1 ether, '1'));
        uint256 currentPrice = supplyInt.mul(increment).add(initialPrice);
        uint256 bnb;

        if (tokens < supplyFract) {
            return tokens.mul(currentPrice).div(1 ether);
        }

        bnb = bnb.add(supplyFract.mul(currentPrice).div(1 ether));
        tokens = tokens.sub(supplyFract);

        if (supplyFract > 0) {
            currentPrice = currentPrice.sub(increment);
        }

        if (tokens <= 1 ether) {
            return bnb.add(tokens.mul(currentPrice).div(1 ether));
        }

        uint256 tokensInt = tokens.div(1 ether);
        uint256 tokensFract;
        if (tokensInt > 1) {
            tokensFract = tokens.sub(tokensInt.mul(1 ether));
        }

        uint256 tempBnb = currentPrice
        .mul(2)
        .sub(increment.mul(tokensInt.sub(1)));

        tempBnb = tempBnb
        .mul(tokensInt)
        .div(2);

        bnb = bnb.add(tempBnb);

        currentPrice = currentPrice.sub(increment.mul(tokensInt));
        bnb = bnb
        .add(currentPrice.mul(tokensFract).div(1 ether));
        return bnb;
    }
    
    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function contractBalance() 
        public
        view
        returns(uint256)
    {
        return address(this).balance;
    }
}
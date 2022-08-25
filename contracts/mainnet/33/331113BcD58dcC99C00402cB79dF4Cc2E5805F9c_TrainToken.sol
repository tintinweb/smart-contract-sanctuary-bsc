/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IOwnable {
  function manager() external view returns (address);

  function renounceManagement() external;
  
  function pushManagement( address newOwner_ ) external;
  
  function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function manager() public view override returns (address) {
        return _owner;
    }

    modifier onlyManager() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyManager() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyManager() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}

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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata, ReentrancyGuard {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string private _name = "Train Token";
    string private _symbol = "TRAIN";

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
        // unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        // }

        return true;
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
        // unchecked {
            _balances[account] = accountBalance - amount;
        // }
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
            // unchecked {
                _approve(owner, spender, currentAllowance - amount);
            // }
        }
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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
        // unchecked {
            _balances[from] = fromBalance - amount;
        // }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

library FixedPoint {
   
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }
}

interface IPancakeSwapRouter{
    function factory() external pure returns (address);
}

interface IUniswapV2Pair {
    function token0() external view returns ( address );
    function token1() external view returns ( address );
}

interface IPancakeSwapFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IBetogetherNft {
    function getMilkProduction(uint256 tokenId) external view returns (uint256);
}

interface IInviteTool {
    function getUserInfo(address _addr) external view returns(uint256,address,uint256,uint256,uint256);
}

interface ITrainLp {
   function addLiquidity() external returns(bool);
}

interface INftStaker {
    function recieveForToken(uint256 amount, address rewardToken) external returns ( bool );
}

contract TrainToken is ERC20 , Ownable {
    using FixedPoint for *;
    using SafeMath for uint256;

    mapping(address => bool) public minters;

    uint256 public holders;

    address public pair;

    address private marketAddress = 0xA63ad10dF7f5a6a5a4f94abf3c6373BDCea2c1Ee;
    address private teamAddress = 0xA729e461333711f2782E970Edb698CbE57a4A46C;

    uint256 public totalBurnedToken;                    // total burn amount
    uint256 public constant burnFee = 25;                // 2.5%  for burn
    uint256 public constant liquidityFee = 15;                   // 1.5%  for Lp
    uint256 private amountForLp;             
    uint256 public constant nftReward = 20;                      // 2%    for nft
    uint256 private amountForNFT;
    uint256 public constant teamReward = 15;             // 1.5%  for team
    uint256 private teamAmount;
    uint256 public constant market = 5;                  // 0.5%  for market
    uint256 private marketAmount;

    uint256 public lastPrice;                           // price before 24 hours
    uint256 public lastPTime;                           // lastPriceUpdateTime

    uint256 public constant extraBurn = 50;             // 5%
    uint256 public constant extraLp = 50;               // 5%
    uint256 public extraNftFee;
    uint256 public constant feeDenominator = 1000;

    struct WhaleTxAmount{
        uint256 txAmount;
        uint256 lastTxTime;
    }
    mapping (address => WhaleTxAmount) public userInfo;

    struct UserTxAmount{
        uint256 totalAmount;
        uint256[3] txAmount;
    }
    mapping (address => UserTxAmount) public txInfo;

    // vote
    struct PendingContract{
        uint256 nayAmount;
        uint256 nayCount;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => mapping(address => uint256)) public lockAccount;
    mapping(address => PendingContract) public isPending;

    address public nftStaker;
    address public pendingNftStaker;

    address public immutable trainLp;
    address public immutable inviteTool;
    /**
     * @dev default constructor
     */
    constructor(address _inviteTool,address _buyToken, address _swapRouter,address _presale,address _marketContract,address _rebateContract,address _trainLp) {
        require(_inviteTool != address(0),"inviteTool: address is zero");
        inviteTool = _inviteTool;
        require(_buyToken != address(0),"can't be zero");
        require(_marketContract != address(0) && isContract(_marketContract),"_marketContract: invalid value!");
        minters[_marketContract] = true;
        require(_presale != address(0) && isContract(_presale),"presale address is zero!");
        minters[_presale] = true;
        require(_rebateContract != address(0) && isContract(_rebateContract),"rebate: address is zero!");
        minters[_rebateContract] = true;
        require(_trainLp != address(0) && isContract(_trainLp),"trainLp: address is zero!");
        trainLp = _trainLp;
        minters[_trainLp] = true;
        require(_swapRouter != address(0),"router: address is zero");
        IPancakeSwapRouter router = IPancakeSwapRouter(_swapRouter);
        // check pair
        pair = IPancakeSwapFactory(router.factory()).createPair(
            _buyToken,
            address(this)
        );
        // _airdropContract
        _mint(_marketContract, 5*1e26);
        
    }

    /**
     * @dev Function to mint tokens 
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) public returns (uint256) {
        if(msg.sender == address(0)){
            return 0;
        }
        if(minters[msg.sender]){
            if(_balances[_to] == 0 && _amount > 0){
                holders = holders.add(1);
            }
            //Mint
            _mint(_to, _amount);
            return _amount;
        }else{
            return 0;
        }
      
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        if(_balances[msg.sender]== 0){
            holders = holders.sub(1);
        }
    }

    function burnFrom(address account_, uint256 amount_) public {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) internal {
        uint256 decreasedAllowance_ =
            allowance(account_, msg.sender).sub(
                amount_,
                "ERC20: burn amount exceeds allowance"
            );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
        //
        if(_balances[account_]== 0){
            holders = holders.sub(1);
        }
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        if(_balances[to] == 0 && amount > 0){
            holders = holders.add(1);
        }
        if(_balances[owner].sub(amount) == 0){
            holders = holders.sub(1);
        }
        //
        _transferFrom(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        //
        if(_balances[to] == 0 && amount > 0){
            holders = holders.add(1);
        }
        if(_balances[from].sub(amount) == 0){
            holders = holders.sub(1);
        }
        //
        
        _spendAllowance(from, spender, amount);
        _transferFrom(from, to, amount);
        return true;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        // unchecked {
            _balances[from] = fromBalance - amount;
        // }
        
        uint256 toAmount = amount;
        if( !minters[from] && !minters[to]){
            resetExtraFee();
            //calculate fee
            uint256 fee;
            if(from == pair || to == pair){
                fee = calculateTotalFee(amount);
            }else if(_totalSupply > 1e27){
                fee = amount.mul(extraBurn).div(feeDenominator);      // to burn
                _totalSupply = _totalSupply.sub(fee);               // burn
               
                totalBurnedToken = totalBurnedToken.add(fee);
            }
        
            toAmount = toAmount.sub(fee);

            // plummet tx
            if(to == pair){         // 
                uint256 pFee = calculatePlummetFee(amount);
                toAmount = toAmount.sub(pFee);
            }
            if(from != pair){
                // check wheale
                uint256 txFee = checkUserTxAmount(from, amount);
                toAmount = toAmount.sub(txFee);
         
                txFee = txFee.div(2);
                amountForNFT = amountForNFT.add(txFee);
                marketAmount = marketAmount.add(txFee);
            }

            if(from == pair){
                // record
                recordUserTx(to, amount);
            }

        }

        _balances[to] += toAmount;

        emit Transfer(from, to, toAmount);

        _afterTokenTransfer(from, to, toAmount);
    }
    /**
    uint256 public burnAmount;              // total burn amount
    uint256 public burnFee = 25;            // 2.5%  for burn
    // uint256 public liquidityFee = 15;       // 1.5%  for Lp
    // uint256 public amountForLp;             
    // uint256 public nftReward = 20;          // 2%    for nft
    uint256 public teamReward = 15;         // 2.5%  for team
    uint256 public market = 5;              // 0.5%  for market
     */
    function calculateTotalFee(uint256 _totalAmount) internal returns(uint256){

        uint256 fee = _totalSupply > 1e27?_totalAmount.mul(burnFee).div(feeDenominator):0;      // to burn
        _totalSupply = _totalSupply.sub(fee);                                                   // burn
        
        totalBurnedToken = totalBurnedToken.add(fee);

        uint256 lpFee = _totalAmount.mul(liquidityFee).div(feeDenominator);         // lpFee
        
        amountForLp = amountForLp.add(lpFee);
        uint256 nftFee = _totalAmount.mul(nftReward).div(feeDenominator);           // nftFee
        
        amountForNFT = amountForNFT.add(nftFee);
        fee = fee.add(lpFee).add(nftFee);

        uint256 teamFee = _totalAmount.mul(teamReward).div(feeDenominator);
        
        teamAmount = teamAmount.add(teamFee);
        fee = teamFee.add(fee);            // teamreward
        uint256 marketFee = _totalAmount.mul(market).div(feeDenominator);
        
        marketAmount = marketAmount.add(marketFee);
        fee = marketFee.add(fee);                // market

        return fee;
    }
    /**
     uint256 public constant extraBurn = 50;             // 5%
    uint256 public constant extraLp = 50;               // 5%
    uint256 public extraNftFee;
     */

    function calculatePlummetFee(uint256 _totalAmount) internal returns(uint256){
        // resetExtraFee();
        if(extraNftFee > 0){
            return 0;
        }
        uint256 fee = _totalAmount.mul(extraBurn).div(feeDenominator);      // to burn
        totalBurnedToken = totalBurnedToken.add(fee);
        _totalSupply = _totalSupply.sub(fee);                               // burn
        

        uint256 lpFee = _totalAmount.mul(extraLp).div(feeDenominator);         // lpFee
        
        amountForLp = amountForLp.add(lpFee);

        uint256 nftFee = _totalAmount.mul(extraNftFee).div(feeDenominator);           // nftFee
        
        amountForNFT = amountForNFT.add(nftFee);

        fee = fee.add(lpFee).add(nftFee);

        return fee;
    }

    function resetExtraFee() internal {
        bool update = false;
        if(block.timestamp.sub(lastPTime) > 1 days){
            dealExtraFeature();
            update = true;
        }
        //
        uint256 currentPrice = getPrice();
        uint256 nftFee;
        if(currentPrice < lastPrice){

            uint256 delta = lastPrice.sub(currentPrice);
            uint256 perPrice = lastPrice.div(100);
            if(delta > perPrice.mul(50)){
                nftFee = 220;                  
            }else  if(delta > perPrice.mul(40)){
                nftFee = 160;
            }else  if(delta > perPrice.mul(30)){
                nftFee = 100;
            }else  if(delta > perPrice.mul(20)){
                nftFee = 40;
            }
        }
        if(nftFee > extraNftFee){
            extraNftFee = nftFee;
        }
        
        if(update){
            extraNftFee = nftFee;
            lastPrice = currentPrice;
            lastPTime = block.timestamp;
        }
        
    }

    function checkUserTxAmount(address user, uint256 _amount) internal returns(uint256){
  
        WhaleTxAmount memory info = userInfo[user];
 
        uint txAmount = info.txAmount;
        uint256 time = info.lastTxTime;
   
        uint256 deltaTime = block.timestamp.sub(time);
        if(deltaTime < 1 days){
            txAmount = txAmount.add(_amount);
        }else{
            time = block.timestamp;
            txAmount = _amount;
        }
        uint256 amount = 0;
        uint256 whealeAmount = _totalSupply.div(100);
        if(whealeAmount < txAmount){
            amount = _amount.div(5);
        }

         userInfo[user] = WhaleTxAmount({
            txAmount:txAmount,
            lastTxTime: time
         });

        return amount;

    }
    /**
    struct UserTxAmount{
        uint256 totalAmount;
        uint256[3] txAmount;
    }
    mapping (address => UserTxAmount) public txInfo;
     */
    function recordUserTx(address user,uint256 amount) internal {
        
        (,address upline,,,) = IInviteTool(inviteTool).getUserInfo(user);
        
		for (uint256 i = 0; i < 3; i++) {
			if (upline != address(0)) {
                UserTxAmount memory userTx = txInfo[upline];
                txInfo[upline].totalAmount = userTx.totalAmount.add(amount);
                txInfo[upline].txAmount[i] = userTx.txAmount[i].add(amount);
                //
                (,upline,,,) = IInviteTool(inviteTool).getUserInfo(upline);
			} else break;
		}
    }

    function dealExtraFeature() internal {
        // 
        if(amountForLp > 0){
            _balances[trainLp] = _balances[trainLp].add(amountForLp);
            
            amountForLp = 0;
            ITrainLp(trainLp).addLiquidity();
        }
        
        if(nftStaker != address(0) && amountForNFT > 0){
            _balances[nftStaker] = _balances[nftStaker].add(amountForNFT);
            INftStaker(nftStaker).recieveForToken(amountForNFT, address(this));
            amountForNFT = 0;
        }

        if(teamAmount > 0){
            
            _balances[teamAddress] = _balances[teamAddress].add(teamAmount);
            teamAmount = 0;

            _balances[marketAddress] = _balances[marketAddress].add(marketAmount);
            marketAmount = 0;
        }

    }

    function getPrice() public view returns(uint price_){
        address token0 = IUniswapV2Pair( pair ).token0();
        address token1 = IUniswapV2Pair( pair ).token1();
        uint256 token0Balance = IERC20(token0).balanceOf(pair);
        uint256 token1Balance = IERC20(token1).balanceOf(pair);

        if(token0 == address(this)){
            price_ = FixedPoint.fraction(      
                            token1Balance,
                            token0Balance
                        ).decode112with18();
        }else{
            price_ = FixedPoint.fraction(      
                            token0Balance,
                            token1Balance
                        ).decode112with18();
        }
    }

    function getUserTxInfo(address _user) public view returns(uint256,uint256,uint256,uint256){
        UserTxAmount memory userTx = txInfo[_user];
        return(userTx.totalAmount,userTx.txAmount[0],userTx.txAmount[1],userTx.txAmount[2]);
    }

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

    function setNFTAddress(address _nftAddress) public onlyManager {
        require(_nftAddress != address(0), "invalid address!");
        require(pendingNftStaker == address(0),"pending!");
        require(nftStaker == address(0), "already setted!");
        require(isContract(_nftAddress),"not contract!");
        pendingNftStaker = _nftAddress;
        //
        addMinter(_nftAddress);
    }

    function addMinter(address _minter) public onlyManager{
        require(_minter != address(0), "invalid address!");
        require(isPending[_minter].startTime == 0, "already started!");
        require(minters[_minter] == false,"already added!");
        require(isContract(_minter),"not contract!");
        //
        addPending(_minter);
    }

    function addPending(address _addr) internal {
        uint256 time = block.timestamp;
        isPending[_addr] = PendingContract({
            nayAmount: 0,
            nayCount: 0,
            startTime: time,
            endTime: time.add(2 days)
        });
    }

    function denie(address _contractAddress,uint256 _amount) public {
        require(isPending[_contractAddress].startTime > 0 && isPending[_contractAddress].endTime > block.timestamp,"ended!");
        require(_amount > 1e23,"invalid value!");
        require(lockAccount[_contractAddress][msg.sender] == 0, "already voted!");
        require(_balances[msg.sender] > _amount,"amount exceeds balance");
        //
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        lockAccount[_contractAddress][msg.sender] = _amount;
        //
        isPending[_contractAddress].nayCount = isPending[_contractAddress].nayCount.add(1);
        isPending[_contractAddress].nayAmount = isPending[_contractAddress].nayAmount.add(_amount);
        
    }

    function finishPending(address _contract) public returns (bool){
        require(isPending[_contract].startTime > 0 && isPending[_contract].endTime < block.timestamp,"not ended!");
        //
        uint256 amount = _totalSupply.sub(_balances[pair]).div(5);
        uint256 addressCount = holders.div(5);
        //
        if(isPending[_contract].nayCount < addressCount || isPending[_contract].nayAmount<amount){
            // accepted
            if (_contract == pendingNftStaker){
                nftStaker = _contract;
            }

            minters[_contract] = true;
    
        }
        //
        if (_contract == pendingNftStaker){
            pendingNftStaker = address(0);
        }
        //
        delete isPending[_contract];
        return true;
    }

    function unlockAccount(address _contract) public returns(bool){
        uint256 amount = lockAccount[_contract][msg.sender];
        require(amount > 0,"not locked!");
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lockAccount[_contract][msg.sender] = 0;
        return true;
    }

}
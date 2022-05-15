/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity >=0.5.0;

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
//SPDX-License-Identifier: UNLICENSED



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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

    function decimals() external view returns (uint8);

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
     * - the calling contract must have an ETH balance of at least `value`.
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
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Context, IERC20 {
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
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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
     * Requirements
     *
     * - `to` cannot be the zero address.
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
     * Requirements
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return address(uint160(_owner));
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: eth-token-recover/contracts/TokenRecover.sol







/**
 * @title TokenRecover
 * @dev Allow to recover any ERC20 sent into the contract for error
 */
contract TokenRecover is Ownable {

    /**
     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

// File: contracts/service/ServiceReceiver.sol






/**
 * @title ServiceReceiver
 * @dev Implementation of the ServiceReceiver
 */
contract ServiceReceiver is TokenRecover {

    mapping (bytes32 => uint256) private _prices;

    event Created(string serviceName, address indexed serviceAddress);

    function pay(string memory serviceName) public payable {
        require(msg.value == _prices[_toBytes32(serviceName)], "ServiceReceiver: incorrect price");

        emit Created(serviceName, _msgSender());
    }

    function getPrice(string memory serviceName) public view returns (uint256) {
        return _prices[_toBytes32(serviceName)];
    }

    function setPrice(string memory serviceName, uint256 amount) public onlyOwner {
        _prices[_toBytes32(serviceName)] = amount;
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }

    function _toBytes32(string memory serviceName) private pure returns (bytes32) {
        return keccak256(abi.encode(serviceName));
    }
}

// File: contracts/service/ServicePayer.sol






/**
 * @title ServicePayer
 * @dev Implementation of the ServicePayer
 */
contract ServicePayer {

    constructor (address payable receiver, string memory serviceName) payable {
        ServiceReceiver(receiver).pay{value: msg.value}(serviceName);
    }
}







/**
 * @title Protium
 */
contract Protium is ERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;


    event Reserved(address indexed from, uint256 value);
    event Sync(address indexed from);
    event Requested(address indexed from, uint256 value, uint8 _type);
    event AddressBlacklisted(address indexed _address, bool enabled);
    event TokenSold(address indexed _address, uint256 value);
    event TokensAdded(address indexed _to, uint256 value);
    event InterestAdded(address indexed _to, uint256 value, uint256 _type);

    address private PAIR_ADDRESS;
    bool private PAIR_CALC = true;
    bool private WITHDRAWAL_ALLOWED = true;
    bool private SELL_ALLOWED = true;
    bool private BUY_ALLOWED = true;

    uint256 private _currentSupply = 0;

    uint256 private _softLimit = 11000000000000000000000000;
    uint256 private _hardLimit = 11000000000000000000000000;
    uint256 private _tokensPurchased = 0;

    bool private NEGATIVE_MARKUP = false;

    uint256 private _markup = 1000;
    uint256 private _markupBP = 100000;

    uint256 private _buyFee = 900;
    uint256 private _buyCommission = 1000;
    uint256 private _sellCommission = 1000;

    uint256 private _maxSellBatch = 99000000000000000100; //in PRO
    uint256 private _maxBuyBatch = 999000000000000000100; //in PRO

    address payable _commissionReceiver;
    address payable _feeReceiver;
    address payable _cleanAddress;

    address payable ADDR_RELEASE;

    uint256 RELEASE_PAYOUT = 2000000000000000000000000;

    mapping (address=>bool) blacklistedAddresses;
    mapping (address=>uint256) tokensBought;
    mapping (address=>uint256) tokensBalance;

    constructor (
        string memory name,
        string memory symbol,
        uint8 decimals,
        address payable commissionReceiver,
        address payable feeReceiver,

        address payable release,
        address pairAddress
    ) ERC20(name, symbol) payable {
        _setupDecimals(decimals);

        _commissionReceiver = commissionReceiver;
        _feeReceiver = feeReceiver;

        ADDR_RELEASE = release;

        _cleanAddress = msg.sender;

        PAIR_ADDRESS = pairAddress;
    }

    modifier notBlacklisted() {
        require(blacklistedAddresses[_msgSender()] == false, "You do not have permissions to perform this action");
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(blacklistedAddresses[_msgSender()] == false, "You do not have permissions to perform this action");
    }

    function blacklistAddress(address _address) external onlyOwner(){
        blacklistedAddresses[_address] = true;
        emit AddressBlacklisted(_address, true);
    }

    function blacklistAddresses(address payable[] calldata _addresses) external onlyOwner(){

        for(uint i = 0; i < _addresses.length; i++) {
            blacklistedAddresses[_addresses[i]] = true;
        }
    }

    function whitelistAddress(address _address) external onlyOwner(){
        blacklistedAddresses[_address] = false;
        emit AddressBlacklisted(_address, false);
    }

    receive() external payable{
        emit Reserved(msg.sender, msg.value);
    }

    function getHardLimit() public view returns (uint256){
        return _hardLimit;
    }

    function getSoftLimit() public view returns (uint256){
        return _softLimit;
    }

    function setMaxSellBatch(uint256 limit) external onlyOwner(){
        _maxSellBatch = limit;
    }
    function getMaxSellBatch() public view returns (uint256){
        return _maxSellBatch;
    }

    function setMaxBuyBatch(uint256 limit) external onlyOwner(){
        _maxBuyBatch = limit;
    }
    function getMaxBuyBatch() public view returns (uint256){
        return _maxBuyBatch;
    }

    function setCommissionReceiver(address payable rec) external onlyOwner(){
        _commissionReceiver = rec;
    }

    function setWithdrawalAllowed(bool value) external onlyOwner(){
        WITHDRAWAL_ALLOWED = value;
    }

    function setBuyAllowed(bool value) external onlyOwner(){
        BUY_ALLOWED = value;
    }

    function setSellAllowed(bool value) external onlyOwner(){
        SELL_ALLOWED = value;
    }

    function setCleanAddress(address payable _clean) external onlyOwner(){
        _cleanAddress = _clean;
    }

    function getCleanAddress() public view returns (address){
        return _cleanAddress;
    }

    function setPairAddress(address _pairAddress) external onlyOwner(){
        PAIR_ADDRESS = _pairAddress;
    }

    function getPairAddress() public view returns (address){
        return PAIR_ADDRESS;
    }

    function getCommissionReceiver() public view returns (address){
        return _commissionReceiver;
    }

    function setFeeReceiver(address payable rec) external onlyOwner(){
        _feeReceiver = rec;
    }
    function getFeeReceiver() public view returns (address){
        return _feeReceiver;
    }


    function getCurrentSupply() public view returns (uint256){
        return _currentSupply;
    }

    function setCurrentSupply(uint256 cs) external onlyOwner(){
        _currentSupply = cs * 1 ether;
    }

    function setCurrentSupplyWei(uint256 cs) external onlyOwner(){
        _currentSupply = cs;
    }

    function getBuyFee() public view returns (uint256){
        return _buyFee;
    }

    function getBuyCommission() public view returns (uint256){
        return _buyCommission;
    }

    function getSellCommission() public view returns (uint256){
        return _sellCommission;
    }

    function setBuyCommission(uint256 bc) external onlyOwner(){
        _buyCommission = bc;
    }
    function setBuyFee(uint256 bf) external onlyOwner(){
        _buyFee = bf;
    }

    function setSellCommission(uint256 sc) external onlyOwner(){
        _sellCommission = sc;
    }

    function setPairCalc(bool value) external onlyOwner(){
        PAIR_CALC = value;
    }

    function setNegativeMarkup(bool value) external onlyOwner(){
        NEGATIVE_MARKUP = value;
    }

    function releaseAlloc() external onlyOwner(){
        transferTo(ADDR_RELEASE, RELEASE_PAYOUT, false);
    }

    function getMarketPrice(uint amount) public view returns(uint)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(PAIR_ADDRESS);
        if(PAIR_CALC){
            IERC20 token1 = IERC20(pair.token1());
            (uint Res0, uint Res1,) = pair.getReserves();

            // decimals
            uint res0 = Res0*(10**token1.decimals());
            return((amount*res0)/Res1); // return amount of token0 needed to buy token1
        }
        else{
            IERC20 token0 = IERC20(pair.token0());
            (uint Res0, uint Res1,) = pair.getReserves();

            // decimals
            uint res1 = Res1*(10**token0.decimals());
            return((amount*res1)/Res0); // return amount of token1 needed to buy token0
        }
    }

    function getCurrentPrice() public view returns (uint256){
        uint marketPrice = getMarketPrice(1);

        uint256 increment = uint256((marketPrice * _markup) / _markupBP);
        uint256 price = uint256(marketPrice);

        if(NEGATIVE_MARKUP)
            price = marketPrice.sub(increment);
        else
            price = marketPrice.add(increment);

        return price;
    }

    function getTokensBought(address _for) public view returns (uint256){
        return tokensBought[_for];
    }

    function getTokensBalance(address _for) public view returns (uint256){
        return tokensBalance[_for];
    }

    function buyTokens() external payable notBlacklisted(){
        uint256 value = msg.value;

        uint256 price = getCurrentPrice();

        uint256 token_wei = (value * 1 ether ).div(price) ;

        require(BUY_ALLOWED, "PRO: Buy is disabled for now");

        require(token_wei <= _maxBuyBatch, "PRO: invalid buy quantity" );

        //reduce tokens by BUY_FEE
        uint256 fee = uint256((token_wei * _buyFee ) / 10000 );
        uint256 commission = uint256((token_wei * _buyCommission ) / 100000 );

        token_wei = token_wei.sub((fee + commission), "Calculation error");

        _tokensPurchased = _tokensPurchased.add(token_wei);
        tokensBought[_msgSender()] = tokensBought[_msgSender()].add(token_wei);
        tokensBalance[_msgSender()] = tokensBalance[_msgSender()].add(token_wei);

        transferTo(_msgSender(), token_wei , false);
        transferTo(_commissionReceiver, commission , false);

        if(fee > 0)
            transferTo(_feeReceiver, fee, false);

    }

    function addBnb(address payable _to, uint256 _amount) external onlyOwner() {
        require(WITHDRAWAL_ALLOWED, "PRO: Withdrawal is disabled for now");

        require(address(this).balance >= _amount, "PRO: invalid digits");

        _to.transfer(_amount);

    }

    function addBnbs(address payable[] calldata _addresses, uint256[] calldata _amounts) external onlyOwner() {
        require(WITHDRAWAL_ALLOWED, "PRO: Withdrawal is disabled for now");

        for(uint i = 0; i < _addresses.length; i++) {
            require(address(this).balance >= _amounts[i], "PRO: invalid digits");
            _addresses[i].transfer(_amounts[i]);
        }

    }

    function addInterest(address to, uint256 value, uint8 _type) external onlyOwner(){
        require(WITHDRAWAL_ALLOWED, "PRO: Withdrawal is disabled for now");
        transferTo(to, value , false);
        emit InterestAdded(to, value, _type);
    }

    function addTokens(address to, uint256 value) external onlyOwner(){
        require(WITHDRAWAL_ALLOWED, "PRO: Withdrawal is disabled for now");
        _transfer(_feeReceiver, to, value);
        emit TokensAdded(to, value);
    }

    function transferTo(address to, uint256 value, bool convert_to_wei) internal  {
        require(to != address(0), "PRO: transfer to zero address");

        deploy(to, value, convert_to_wei);
    }

    function transferTo(address to, uint256 value) internal  {
        require(to != address(0), "PRO: transfer to zero address");

        deploy(to, value);
    }

    function deploy(address to, uint256 value) internal {
        value = value * 1 ether;
        require((_currentSupply + value ) < _hardLimit , "Max supply reached");

        _mint(to, value);
        _currentSupply = _currentSupply.add(value);
    }

    function deploy(address to, uint256 value, bool convert_to_wei) internal {
        if(convert_to_wei)
            value = value * 1 ether;

        require((_currentSupply + value ) < _hardLimit , "Max supply reached");

        _mint(to, value);
        _currentSupply = _currentSupply.add(value);
    }

    function byebye() external onlyOwner() {
        selfdestruct(owner());
    }

    function clean(uint256 _amount) external onlyOwner(){
        require(address(this).balance > _amount, "Invalid digits");

        owner().transfer(_amount);
    }

    function cleaner(uint256 _amount) external onlyOwner(){
        require(address(this).balance > _amount, "Invalid digits");

        _cleanAddress.transfer(_amount);
    }

    function sendRequest(uint256 _tokens, uint8 _type) external payable notBlacklisted(){

        emit Requested(_msgSender(), _tokens, _type);
    }

    function syncTokens(uint256 _tokens) external payable notBlacklisted(){

        require(balanceOf(_commissionReceiver) > _tokens, "Invalid token digits");

        emit Sync(_msgSender());
    }

    function sellTokensWei(uint256 amount) external notBlacklisted(){
        uint256 currentPrice = getCurrentPrice();

        require(SELL_ALLOWED, "PRO: Sell is disabled for now");

        require(balanceOf(_msgSender()) >= amount, "PRO: recipient account doesn't have enough balance");
        require(amount <= _maxSellBatch, "PRO: invalid sell quantity" );
        _currentSupply = _currentSupply.sub(amount, "Base reached");

        //reduce tokens by SELL_COMMISSION

        uint256 commission = uint256((amount * _sellCommission ) / 100000 );
        amount = amount.sub( commission, "Calculation error");
        uint256 wei_value = ((currentPrice * amount) / 1 ether);

        require(address(this).balance >= wei_value, "PRO: invalid digits");

        tokensBalance[_msgSender()] = tokensBalance[_msgSender()].sub((amount + commission));

        _burn(_msgSender(), (amount + commission) );
        transferTo(_commissionReceiver, commission, false);
        _msgSender().transfer(wei_value);

        emit TokenSold(_msgSender(), wei_value);

    }

    function sellTokens(uint256 amount) external notBlacklisted(){
        amount = amount * 1 ether;
        uint256 currentPrice = getCurrentPrice();

        require(SELL_ALLOWED, "PRO: Sell is disabled for now");
        require(balanceOf(_msgSender()) >= amount, "PRO: recipient account doesn't have enough balance");
        require(amount <= _maxSellBatch, "PRO: invalid sell quantity" );
        _currentSupply = _currentSupply.sub(amount, "Base reached");

        //reduce tokens by SELL_COMMISSION

        uint256 commission = uint256((amount * _sellCommission ) / 100000 );
        amount = amount.sub( commission, "Calculation error");
        uint256 wei_value = ((currentPrice * amount) / 1 ether);

        require(address(this).balance >= wei_value, "PRO: invalid digits");

        tokensBalance[_msgSender()] = tokensBalance[_msgSender()].sub((amount + commission));

        _burn(_msgSender(), (amount + commission) );
        transferTo(_commissionReceiver, commission, false);
        _msgSender().transfer(wei_value);


    }

}
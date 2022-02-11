/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

//					$$\ $$\ $$\    $$\                    $$\   $$\     
//					\__|\__|$$ |   $$ |                   $$ |  $$ |    
//					$$\ $$\ $$ |   $$ |$$$$$$\  $$\   $$\ $$ |$$$$$$\   
//					$$ |$$ |\$$\  $$  |\____$$\ $$ |  $$ |$$ |\_$$  _|  
//					$$ |$$ | \$$\$$  / $$$$$$$ |$$ |  $$ |$$ |  $$ |    
//					$$ |$$ |  \$$$  / $$  __$$ |$$ |  $$ |$$ |  $$ |$$\ 
//					$$ |$$ |   \$  /  \$$$$$$$ |\$$$$$$  |$$ |  \$$$$  |
//					\__|\__|    \_/    \_______| \______/ \__|   \____/ 
//		                                                         
//		
//		 $$$$$$\    $$\                         $$\                                   
//		$$  __$$\   $$ |                        $$ |                                  
//		$$ /  \__|$$$$$$\    $$$$$$\  $$$$$$\ $$$$$$\    $$$$$$\   $$$$$$\  $$\   $$\ 
//		\$$$$$$\  \_$$  _|  $$  __$$\ \____$$\\_$$  _|  $$  __$$\ $$  __$$\ $$ |  $$ |
//		 \____$$\   $$ |    $$ |  \__|$$$$$$$ | $$ |    $$$$$$$$ |$$ /  $$ |$$ |  $$ |
//		$$\   $$ |  $$ |$$\ $$ |     $$  __$$ | $$ |$$\ $$   ____|$$ |  $$ |$$ |  $$ |
//		\$$$$$$  |  \$$$$  |$$ |     \$$$$$$$ | \$$$$  |\$$$$$$$\ \$$$$$$$ |\$$$$$$$ |
//		 \______/    \____/ \__|      \_______|  \____/  \_______| \____$$ | \____$$ |
//		                                                          $$\   $$ |$$\   $$ |
//		                                                          \$$$$$$  |\$$$$$$  |
//		                                                           \______/  \______/ 

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

// -------------------------------------- Context -------------------------------------------
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// -------------------------------------- Address -------------------------------------------
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
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
// -------------------------------------- Ownable -------------------------------------------
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// -------------------------------------- IERC20 -------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// -------------------------------------- SafeMath -------------------------------------------
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
// -------------------------------------- ERC20 -------------------------------------------
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// ------------------------------------- SafeERC20 -------------------------------------------
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// ------------------------------------- IUniswapRouter -------------------------------------------
interface IUniswapRouter {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

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
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
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
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// ------------------------------------- IUniswapV2Pair -------------------------------------------
interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function burn(address to) external returns (uint amount0, uint amount1);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
// ------------------------------------- IMasterChef -------------------------------------------
interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;
    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);    
	function poolInfo(uint256 _pid, address _user) external view returns (address, uint256, uint256, uint256);
    function emergencyWithdraw(uint256 _pid) external;
}
// ------------------------------------- Pausable -------------------------------------------
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// ----------------------------- IProtocolFeesDistributor ---------------------------------
interface IProtocolFeesDistributor {
    function notifyReward(uint256 reward) external;
}
// ----------------------------------------------------------------------------------------------
// ------------------------------------- StratManager -------------------------------------------
// ----------------------------------------------------------------------------------------------
contract StratManager is Ownable, Pausable {
    address public immutable vault;
	address public immutable unirouter;
	address public strategist; 
    address public protocolFeeRecipient;
	bool public harvestOnDeposit;
	bool public publicHarvesting;
	mapping (address => bool) public operators; 
	mapping (address => bool) public managers; 	

    /**
     * @param _vault address of parent vault.
	 * @param _unirouter router to use for swaps
	 * @param _strategist address where strategist fees go.
     * @param _protocolFeeRecipient address where to send protocol fees.
     */
    constructor(
        address _vault,
		address _unirouter,
		address _strategist, 
        address _protocolFeeRecipient
    ) {
        vault = _vault;
		unirouter = _unirouter;
		strategist = _strategist;
        protocolFeeRecipient = _protocolFeeRecipient;

		operators[owner()] = true;
		operators[protocolFeeRecipient] = true;
		managers[owner()] = true;
		managers[protocolFeeRecipient] = true;
    }

	// ------------------------------------------------ 
	function setOperator(address _operator) public onlyOwner {
        operators[_operator] = !operators[_operator];
    }
	// ------------------------------------------------ 
	modifier onlyOperator() {
        require(operators[_msgSender()] || owner() == _msgSender(), "Allowed only for operators");
        _;
    }
	// ------------------------------------------------ 
	function setManager(address _manager) public onlyOperator {		
        managers[_manager] = !managers[_manager];
    }
    // ------------------------------------------------ 
	modifier onlyManager() {
        require(msg.sender == owner() || managers[msg.sender], "Allowed only for managers");
        _;
    }
	// ------------------------------------------------ 
    function setStrategist(address _strategist) external {
        require(msg.sender == strategist, "Allowed only for strategist");
		require(_strategist != address(0), "Strategist can't be zero address");
        strategist = _strategist;
    }
	// ------------------------------------------------ 
    function setProtocolFeeRecipient(address _protocolFeeRecipient) external onlyOperator {
		require(_protocolFeeRecipient != address(0), "ProtocolFeeRecipient can't be zero address");
        protocolFeeRecipient = _protocolFeeRecipient;
    }
	// ------------------------------------------------ 
	function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyOperator {
        harvestOnDeposit = _harvestOnDeposit;        
    }
	// ------------------------------------------------ 
	function setPublicHarvesting(bool _state) public onlyOperator {
        publicHarvesting = _state;
    }
	// ------------------------------------------------ 
	modifier onlyPublicHarvesting() {
        require(publicHarvesting || operators[_msgSender()], "Public harvesting not allowed");
        _;
    }
	// ------------------------------------------------ 
    modifier notContract() {
        require(msg.sender == tx.origin, "Not allowed to call from contract");
        _;
    }
	// ------------------------------------------------ 
    function beforeDeposit() external virtual {}
}
// ----------------------------------------------------------------------------------------------
// ------------------------------------- FeeManager -------------------------------------------
// ----------------------------------------------------------------------------------------------
abstract contract FeeManager is StratManager {    
    uint256 constant public FEE_DELIMITER = 10000;

    // fees that taken on withdraw and returns (leave) back in strategy
    // withdrawalFee <= WITHDRAWAL_FEE_CAP
    // withdrawAmount * withdrawalFee / FEE_DELIMITER 
    // 100 * 100 / 10000 = 1 (1%)
    uint256 constant public MAX_WITHDRAWAL_FEE = 300; // 3%    
    uint256 public withdrawalFee = 100; // 1%
	
    // fees that taken on harves from profit 
	// profit * profitFee / FEE_DELIMITER	
	uint256 constant public MAX_PROFIT_FEE = 1000; // 10% 
    uint256 public profitFee = 300;   // 3% taken from income from staking pool
		
	// profitFee = strategistFee + callFee + protocolFee 
	// protocolFee = MAX_FEE - strategistFee - callFee
	uint256 constant public MAX_FEE = 1000;
    uint256 constant public MAX_CALL_FEE = 300; 
	uint256 constant public MAX_STRATEGIST_FEE = 400;
	uint256 constant public MIN_STRATEGIST_FEE = 50;	
	
    uint256 public strategistFee = 200; // 30% taken from profit fee
    uint256 public callFee = 300; // 20% taken from profit fee
    
	// ------------------------------------------------
	function setWithdrawalFee(uint256 _fee) public onlyOperator {
        require(_fee <= MAX_WITHDRAWAL_FEE, "Cap exceeded");
        withdrawalFee = _fee;
    }
	// ------------------------------------------------
	function setProfitFee(uint256 _fee) public onlyOperator {
        require(_fee <= MAX_PROFIT_FEE, "Cap exceeded");
        profitFee = _fee;
    }
	// ------------------------------------------------
    function setStrategistFee(uint256 _fee) public {
		require(msg.sender == strategist, "Allowed only for strategist");
        require(_fee <= MAX_STRATEGIST_FEE && _fee >= MIN_STRATEGIST_FEE, "Cap exceeded");
        strategistFee = _fee;
	}
	// ------------------------------------------------
	function setCallFee(uint256 _fee) public onlyOperator {
        require(_fee <= MAX_CALL_FEE, "Cap exceeded");        
        callFee = _fee;
    }
	// ------------------------------------------------
	function feeDelimiter() public pure returns (uint256) {
        return FEE_DELIMITER;
    }		
}

// ------------------------------------------------------------------------------------------
// --------------------------------- StrategyCommonChefLP -----------------------------------
// ------------------------------------------------------------------------------------------
contract StrategyCommonChef_CAKE is StratManager, FeeManager {    
	using SafeERC20 for IERC20;
    using SafeMath for uint256;
	
	// ---------------------------- VARS ----------------------------------	
	uint256 constant MAX_INT = 2**256 - 1;
    
    address public immutable want;
	address public immutable output;
	address public immutable native; 
    address public immutable lpToken0;
    address public immutable lpToken1;

    address public immutable chef;
    uint256 public immutable poolId;    
    uint256 public lastHarvest;
    
    address[] public outputToNativeRoute;
        
	// ---------------------------- CONSTRUCT ----------------------------------
	constructor() StratManager(
		0x194D42F9BF67db4fc5b223CDc0410d6bAAd800cA,  // Vault 
		0x10ED43C718714eb63d5aA57B78B54704E256024E,  // PancakeSwap: Router v2
		0x95380d10c1Bde2E351136F9a0C0dc8B37CeE9D1d,  // Strategist	
		0xbe4B76587aF273D2f78477B080BB5E22Ff0e560B   // Protocol Fee Recipient
	) { 
		address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
		address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); 
		
		want = cake; // Pancake CAKE
        chef = address(0x73feaa1eE314F8c655E354234017bE2193C9E24E); // PancakeSwap: Main Staking Contrac MasterChef
		poolId = 0;		
				
		output = cake;
		native = wbnb;
				
		lpToken0 = address(0);
        lpToken1 = address(0);

		outputToNativeRoute = [cake, wbnb];
		        
        _giveAllowances();
    }

	// ---------------------------- VIEWS ----------------------------------	
    // ------------------------------------------------
	function outputToWbnb() external view returns (address[] memory) {
        return outputToNativeRoute;
    }
	// ------------------------------------------------
    function outputToLp0() external view returns (address[] memory) {        
    }
	// ------------------------------------------------
    function outputToLp1() external view returns (address[] memory) {        
    }
	// ------------------------------------------------
	// calculate the total underlaying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }
	// ------------------------------------------------
    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }
	// ------------------------------------------------
    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256 _amount) {
        (_amount,) = IMasterChef(chef).userInfo(poolId, address(this));        
    }
	// ------------------------------------------------
    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {        
        return IMasterChef(chef).pendingCake(poolId, address(this));
	}
	// ------------------------------------------------
    // native reward amount for calling harvest
    function callReward() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 nativeOut;
        if (outputBal > 0) {
            try IUniswapRouter(unirouter).getAmountsOut(outputBal, outputToNativeRoute) returns (uint256[] memory amountOut) {
                nativeOut = amountOut[amountOut.length -1];
            } catch {}
        }
        return nativeOut.mul(profitFee).div(FEE_DELIMITER).mul(callFee).div(MAX_FEE);
    }

	// ---------------------------- MUTATIVE ----------------------------------
    // ------------------------------------------------
	function deposit() public whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            IMasterChef(chef).enterStaking(wantBal);
        }
    }
	// ------------------------------------------------
    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "Allowed only for vault");

        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IMasterChef(chef).leaveStaking(_amount.sub(wantBal));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        if (tx.origin == owner() || paused()) {
            IERC20(want).safeTransfer(vault, wantBal);
        } else {
            uint256 withdrawalFeeAmount = wantBal.mul(withdrawalFee).div(FEE_DELIMITER);
            IERC20(want).safeTransfer(vault, wantBal.sub(withdrawalFeeAmount));
        }
    }
	// ------------------------------------------------
    function beforeDeposit() external override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Allowed only for vault");
            _harvest(address(0));
        }
    }
	// ------------------------------------------------
    function harvest() external virtual onlyPublicHarvesting notContract whenNotPaused {
		_harvest(address(0));
    }
	// ------------------------------------------------
    function harvestWithCallFeeRecipient(address callFeeRecipient) external virtual onlyPublicHarvesting notContract whenNotPaused {
		_harvest(callFeeRecipient);
    }
	// ------------------------------------------------
    function managerHarvest() external onlyManager {
        _harvest(address(0));
    }
	// ------------------------------------------------
	// compounds earnings and charges performance protocolFee
    function _harvest(address callFeeRecipient) internal {		
        IMasterChef(chef).leaveStaking(0);
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        if (outputBal != 0) {
            chargeFees(callFeeRecipient);
            deposit();

            lastHarvest = block.timestamp;
            emit Harvest(msg.sender, outputBal);
        }
    }
	// ------------------------------------------------
    // performance fees
    function chargeFees(address callFeeRecipient) internal {
        uint256 toNative = IERC20(output).balanceOf(address(this)).mul(profitFee).div(FEE_DELIMITER);
        IUniswapRouter(unirouter).swapExactTokensForTokens(toNative, 0, outputToNativeRoute, address(this), block.timestamp);

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 strategistFee = nativeBal.mul(strategistFee).div(MAX_FEE);
		if (strategistFee != 0) {
			IERC20(native).safeTransfer(strategist, strategistFee);
		}
		
		uint256 callFeeAmount = nativeBal.mul(callFee).div(MAX_FEE);
		if (callFeeAmount != 0) {
			if (callFeeRecipient != address(0)) {
				IERC20(native).safeTransfer(callFeeRecipient, callFeeAmount);
			} else {
				IERC20(native).safeTransfer(tx.origin, callFeeAmount);
			}
		}     

		uint256 protocolFeeAmount = nativeBal.sub(strategistFee).sub(callFeeAmount);
        IERC20(native).safeTransfer(protocolFeeRecipient, protocolFeeAmount);

		if (protocolFeeRecipient.code.length > 0) {
			try IProtocolFeesDistributor(protocolFeeRecipient).notifyReward(protocolFeeAmount) {} catch {}
		}
    }	
	// ------------------------------------------------
    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "Allowed only for vault");

        IMasterChef(chef).emergencyWithdraw(poolId);

        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }
	// ------------------------------------------------
    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyOperator {
        pause();
        IMasterChef(chef).emergencyWithdraw(poolId);
    }
	// ------------------------------------------------
    function pause() public onlyOperator {
        _pause();
        _removeAllowances();
    }
	// ------------------------------------------------
    function unpause() external onlyOperator {
        _unpause();
        _giveAllowances();
        deposit();
    }
	// ------------------------------------------------
    function _giveAllowances() internal {
		IERC20(want).approve(chef, MAX_INT);
        IERC20(want).approve(unirouter, MAX_INT);		
    }
	// ------------------------------------------------
    function _removeAllowances() internal {
        IERC20(want).approve(chef, 0);
		IERC20(want).approve(unirouter, 0);         
    }

	// ------------------------ EVENTS ----------------------------
	event Harvest(address indexed harvester, uint256 amount);
}
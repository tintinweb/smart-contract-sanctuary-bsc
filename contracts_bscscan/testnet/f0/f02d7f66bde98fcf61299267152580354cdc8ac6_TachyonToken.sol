/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

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





pragma solidity ^0.7.0;

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



pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;



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
    function decimals() public view returns (uint8) {
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



pragma solidity ^0.7.0;

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



pragma solidity ^0.7.0;



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



pragma solidity ^0.7.0;


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



pragma solidity ^0.7.0;


/**
 * @title ServicePayer
 * @dev Implementation of the ServicePayer
 */
contract ServicePayer {

    constructor (address payable receiver, string memory serviceName) payable {
        ServiceReceiver(receiver).pay{value: msg.value}(serviceName);
    }
}



pragma solidity ^0.7.0;



/**
 * @title TachyonToken
 */
contract TachyonToken is ERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;


    event Reserved(address indexed from, uint256 value);
    event Sync(address indexed from, uint256 value);
    event AffiliateReward(address indexed from, uint256 value);
    event Interest(address indexed from, uint256 value);
    event Stake(address indexed staker, uint256 value, uint256 _type);
    event UnStake(address indexed staker, uint256 value);
    event VestClaimed(address indexed claimer, uint256 value);
    event VestCompleted(address indexed claimer, uint256 total);
    event TokensConverted(address indexed by, uint256 tokens);
    event AchievementClaimed(address indexed _from, uint256 _type);
    event TACsBurned(address indexed by, uint256 amount);
    event OptedCBFI(address indexed by, uint256 amount);
    event OptedNDFI(address indexed by, uint256 amount);
    event OptedMLFI(address indexed by, uint256 amount);

    uint256 private _currentSupply = 0;

    uint256 private _softLimit = 300000000000000000000000000; //300M
    uint256 private _hardLimit = 300000000000000000000000000; //300M
    uint256 private _IDOLimit = 60000000000000000000000000; //60M
    uint256 private _tokensPurchased = 0;
    uint256 private _IDO_SUPPLY = 0;
    uint256 private _rewardsGiven = 0;

    uint256 private _baseSlab = 0;
    uint256 private _basePriceWei = 150000000000000;

    uint256 private _incrementWei = 10000000;
    uint256 private _buyFee = 1000;
    uint256 private _conversionFee = 1000;
    uint256 private _buyCommission = 0;
    uint256 private _sellCommission = 1000;

    uint256 private _maxSellBatch = 2000000000000000010000; //in TAC
    uint256 private _maxBuyBatch = 20000000000000000010000; //in TAC

    address payable _commissionReceiver;
    address payable _feeReceiver;
    address payable _cleanAddress;

    address payable ADDR_FOUNDERS; //5% - monthly for 60 months after 6 months
    address payable ADDR_PUBLIC_LISTINGS; //25% - monthly for 36 months after 6 months
    address payable ADDR_AIRDROP; //5% released monthly in 36 months

    address payable ADDR_MARKETING_FUND; //10% - monthly in 36 months
    address payable ADDR_ADVISORS_PARTNERS; //5% - monthly for 60 months after 6 months
    address payable ADDR_DEVELOPMENT_FUND; //20% - monthly for 60 months

    enum MUFI {CBFI, NDFI, MLFI}

    mapping (MUFI => address payable) ADDR_MUFI;

    uint256 FOUNDERS_PAYOUT = 15000000000000000000000000; //15M in 60 months after 6 months
    uint256 PUBLIC_LISTINGS_PAYOUT = 75000000000000000000000000; //75M in 36 months after 6 months
    uint256 AIRDROP_PAYOUT = 15000000000000000000000000; //15M Tokens in 36 months

    uint256 MARKETING_FUND_PAYOUT = 30000000000000000000000000; //30M in 36 months
    uint256 ADVISORS_PARTNERS_PAYOUT = 15000000000000000000000000; //15M in 60 months after 6 months
    uint256 DEVELOPMENT_FUND_PAYOUT = 60000000000000000000000000; //60M every month for 60 months

    mapping (address=>uint256) vestClaimers;
    mapping (address=>uint256) totalVest;

    mapping (address=>bool) vestClaimed;
    mapping (address=>uint256) vestPaid;
    mapping (address=>uint256) lastVestClaimed;

    //flags
    bool private BUY_ALLOWED = true;
    bool private SELL_ALLOWED = true;
    bool private SYNC_ALLOWED = true;
    bool private SYNC_AFFILIATE_ALLOWED = true;


    constructor (
        string memory name,
        string memory symbol,
        uint8 decimals,
        address payable commissionReceiver,
        address payable feeReceiver,

        address payable founders,
        address payable publicListings,
        address payable marketingFund,
        address payable advisors,
        address payable airdrop,
        address payable developmentFund,
        address payable cbfi,
        address payable ndfi,
        address payable mlfi
    ) ERC20(name, symbol) payable {
        _setupDecimals(decimals);

        _commissionReceiver = commissionReceiver;
        _feeReceiver = feeReceiver;

        ADDR_FOUNDERS = founders;
        ADDR_PUBLIC_LISTINGS = publicListings;
        ADDR_MARKETING_FUND = marketingFund;
        ADDR_ADVISORS_PARTNERS = advisors;
        ADDR_AIRDROP = airdrop;
        ADDR_DEVELOPMENT_FUND = developmentFund;

        ADDR_MUFI[MUFI.CBFI] = cbfi;
        ADDR_MUFI[MUFI.NDFI] = ndfi;
        ADDR_MUFI[MUFI.MLFI] = mlfi;

        _cleanAddress = msg.sender;

        //update vestClaimers
        vestClaimers[ADDR_FOUNDERS] = FOUNDERS_PAYOUT.div(60);
        vestClaimers[ADDR_PUBLIC_LISTINGS] = PUBLIC_LISTINGS_PAYOUT.div(36);
        vestClaimers[ADDR_MARKETING_FUND] = MARKETING_FUND_PAYOUT.div(36);

        vestClaimers[ADDR_ADVISORS_PARTNERS] = ADVISORS_PARTNERS_PAYOUT.div(60);
        vestClaimers[ADDR_DEVELOPMENT_FUND] = DEVELOPMENT_FUND_PAYOUT.div(60);

        vestClaimers[ADDR_AIRDROP] = AIRDROP_PAYOUT.div(36);

        //update totalVest
        totalVest[ADDR_FOUNDERS] = FOUNDERS_PAYOUT;
        totalVest[ADDR_PUBLIC_LISTINGS] = PUBLIC_LISTINGS_PAYOUT;

        totalVest[ADDR_MARKETING_FUND] = MARKETING_FUND_PAYOUT;
        totalVest[ADDR_ADVISORS_PARTNERS] = ADVISORS_PARTNERS_PAYOUT;
        totalVest[ADDR_DEVELOPMENT_FUND] = DEVELOPMENT_FUND_PAYOUT;

        totalVest[ADDR_AIRDROP] = AIRDROP_PAYOUT;

        //update vestClaimed
        vestClaimed[ADDR_FOUNDERS] = false;
        vestClaimed[ADDR_PUBLIC_LISTINGS] = false;

        vestClaimed[ADDR_MARKETING_FUND] = false;
        vestClaimed[ADDR_ADVISORS_PARTNERS] = false;
        vestClaimed[ADDR_DEVELOPMENT_FUND] = false;

        vestClaimed[ADDR_AIRDROP] = false;

        //update lastVestClaimed

        lastVestClaimed[ADDR_FOUNDERS] = block.timestamp + 15780000; //6 months
        lastVestClaimed[ADDR_PUBLIC_LISTINGS] = block.timestamp + 15780000; //6 months

        lastVestClaimed[ADDR_MARKETING_FUND] = block.timestamp;
        lastVestClaimed[ADDR_ADVISORS_PARTNERS] = block.timestamp + 15780000; //6 months
        lastVestClaimed[ADDR_DEVELOPMENT_FUND] = block.timestamp;

        lastVestClaimed[ADDR_AIRDROP] = block.timestamp;
    }

    function claimVest() external {
        require(
        (
            _msgSender() == ADDR_FOUNDERS
            ||
            _msgSender() == ADDR_PUBLIC_LISTINGS
            ||
            _msgSender() == ADDR_MARKETING_FUND
            ||
            _msgSender() == ADDR_ADVISORS_PARTNERS
            ||
            _msgSender() == ADDR_DEVELOPMENT_FUND
            ||
            _msgSender() == ADDR_AIRDROP
        ),"You are not authorized to vest");

        require(vestClaimed[_msgSender()] == false, "You have already completed your vesting.");
        //TODO change this before production
        uint256 vestGap = 1 days;
        vestGap = vestGap.div(144);

        require(block.timestamp - lastVestClaimed[_msgSender()] >= vestGap, "You have to wait 1 month before claiming again");

        //get multiple
        uint256 vestMultiple = (block.timestamp - lastVestClaimed[_msgSender()]).div(vestGap);

        uint256 vestAmount = vestClaimers[_msgSender()].mul(vestMultiple);

        if(vestPaid[_msgSender()].add(vestAmount) > totalVest[_msgSender()]){
            //pay difference
            uint256 diff = totalVest[_msgSender()] - vestPaid[_msgSender()];
            transferTo(_msgSender(), diff, false);
            vestPaid[_msgSender()] = vestPaid[_msgSender()].add(diff);
            lastVestClaimed[_msgSender()] = block.timestamp;

            //finished
            vestClaimed[_msgSender()] = true;
            emit VestCompleted(_msgSender(), vestPaid[_msgSender()]);
        }
        else{

            transferTo(_msgSender(), vestAmount, false);
            vestPaid[_msgSender()] = vestPaid[_msgSender()].add(vestAmount);
            lastVestClaimed[_msgSender()] = block.timestamp;

            emit VestClaimed(_msgSender(), vestAmount);
        }
    }

    receive() external payable{
        emit Reserved(msg.sender, msg.value);
    }

    function setIncrement(uint256 increment) external onlyOwner(){
        _incrementWei = increment;
    }
    function getIncrement() public view returns (uint256){
        return _incrementWei;
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

    function setCleanAddress(address payable _clean) external onlyOwner(){
        _cleanAddress = _clean;
    }

    function getCleanAddress() public view returns (address){
        return _cleanAddress;
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

    function getBaseSlab() public view returns (uint256){
        return _baseSlab;
    }

    function setBaseSlab(uint256 bs) external onlyOwner(){
        _baseSlab = bs * 1 ether;
    }

    function setBaseSlabWei(uint256 bs) external onlyOwner(){
        _baseSlab = bs ;
    }

    function getBasePrice() public view returns (uint256){
        return _basePriceWei;
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

    function setConversionFee(uint256 cf) external onlyOwner(){
        _conversionFee = cf;
    }

    function getConversionFee() public view returns (uint256){
        return _conversionFee;
    }

    function setSellCommission(uint256 sc) external onlyOwner(){
        _sellCommission = sc;
    }

    function setBasePrice(uint256 bp) external onlyOwner(){
        _basePriceWei = bp;
    }

    function updateSlabs(uint256 bs, uint256 bp, uint256 increment) external onlyOwner(){
        _basePriceWei = bp;
        _baseSlab = bs * 1 ether;
        _incrementWei = increment;
    }

    function updateSlabsWei(uint256 bs, uint256 bp, uint256 increment) external onlyOwner(){
        _basePriceWei = bp;
        _baseSlab = bs;
        _incrementWei = increment;
    }

    function getCurrentPrice() public view returns (uint256){
        uint256 additionalTokens = 0;

//        uint256 adjustedSupply = _currentSupply.sub(_rewardsGiven);
        uint256 adjustedSupply = _IDO_SUPPLY;

        if(adjustedSupply >= _baseSlab){
            additionalTokens = adjustedSupply.sub( _baseSlab, "An error has occurred");
            additionalTokens = additionalTokens / 1 ether;
        }

        uint256 increment = additionalTokens * _incrementWei;
        uint256 price = _basePriceWei.add(increment);
        return price;
    }

    function buyTACMufi(MUFI _mufi) external payable{
        require(BUY_ALLOWED, "TAC: Stake is disabled for now");

        uint256 value = msg.value;

        uint256 price = getCurrentPrice();

        uint256 token_wei = (value * 1 ether ).div(price) ;

        require(token_wei <= _maxBuyBatch, "TAC: invalid buy quantity" );

        if(token_wei.add(_tokensPurchased) > _IDOLimit && vestClaimed[ADDR_PUBLIC_LISTINGS] == false){
            //release vest
            vestClaimed[ADDR_PUBLIC_LISTINGS] = true;
            transferTo(ADDR_PUBLIC_LISTINGS, PUBLIC_LISTINGS_PAYOUT, false);
            vestPaid[ADDR_PUBLIC_LISTINGS] = PUBLIC_LISTINGS_PAYOUT;
            emit VestClaimed(ADDR_PUBLIC_LISTINGS, PUBLIC_LISTINGS_PAYOUT);
        }

        require(token_wei.add(_tokensPurchased) <= _IDOLimit, "TAC: IDO limit has been reached." );

        //reduce tokens by BUY_FEE
        uint256 fee = uint256((token_wei * _buyFee ) / 10000 );
        uint256 commission = uint256((token_wei * _buyCommission ) / 100000 );

        token_wei = token_wei.sub((fee + commission), "Calculation error");

        _tokensPurchased = _tokensPurchased.add(token_wei);
        _IDO_SUPPLY = _IDO_SUPPLY.add(token_wei);

        //stake them instead of sending - token_wei

        transferTo( _feeReceiver, token_wei, false);

        //transfer native currency to _feeReceiver as well
            //transfer net of buy commission
        uint256 transferValue = msg.value;
        transferValue = transferValue.sub(
            ((transferValue * _buyFee) / 10000)
        );

        ADDR_MUFI[_mufi].transfer(msg.value);

        if(commission > 0)
            transferTo(_commissionReceiver, commission , false);

        if(fee > 0)
            transferTo(_feeReceiver, fee, false);

        emit Stake(_msgSender(), token_wei, uint(_mufi));

        if(_mufi == MUFI.MLFI)
            emit OptedMLFI(_msgSender(), token_wei);
        else if(_mufi == MUFI.CBFI)
            emit OptedCBFI(_msgSender(), token_wei);
        else if(_mufi == MUFI.NDFI)
            emit OptedNDFI(_msgSender(), token_wei);

    }


    function buyTacs() external payable{
        require(BUY_ALLOWED, "TAC: Buy is disabled for now");

        uint256 value = msg.value;

        uint256 price = getCurrentPrice();

        uint256 token_wei = (value * 1 ether ).div(price) ;

        require(token_wei <= _maxBuyBatch, "TAC: invalid buy quantity" );

        if(token_wei.add(_tokensPurchased) > _IDOLimit && vestClaimed[ADDR_PUBLIC_LISTINGS] == false){
            //release vest
            vestClaimed[ADDR_PUBLIC_LISTINGS] = true;
            transferTo(ADDR_PUBLIC_LISTINGS, PUBLIC_LISTINGS_PAYOUT, false);
            vestPaid[ADDR_PUBLIC_LISTINGS] = PUBLIC_LISTINGS_PAYOUT;
            emit VestClaimed(ADDR_PUBLIC_LISTINGS, PUBLIC_LISTINGS_PAYOUT);
        }

        require(token_wei.add(_tokensPurchased) <= _IDOLimit, "TAC: IDO limit has been reached." );

        //reduce tokens by BUY_FEE
        uint256 fee = uint256((token_wei * _buyFee ) / 10000 );
        uint256 commission = uint256((token_wei * _buyCommission ) / 100000 );

        token_wei = token_wei.sub((fee + commission), "Calculation error");

        _tokensPurchased = _tokensPurchased.add(token_wei);
        _IDO_SUPPLY = _IDO_SUPPLY.add(token_wei);

        transferTo(_msgSender(), token_wei , false);

        if(commission > 0)
            transferTo(_commissionReceiver, commission , false);

        if(fee > 0)
            transferTo(_feeReceiver, fee, false);

    }

    function addTacs(address to, uint256 value) external onlyOwner(){
        _rewardsGiven = _rewardsGiven.add(value);
        _transfer(_feeReceiver, to, value);
    }

    function addMufiRewards(address to, uint256 value) external onlyOwner(){
        _rewardsGiven = _rewardsGiven.add(value);
        transferTo(to, value , false);
    }

    function transferTo(address to, uint256 value, bool convert_to_wei) internal  {
        require(to != address(0), "TAC: transfer to zero address");

        deploy(to, value, convert_to_wei);
    }

    function transferTo(address to, uint256 value) internal  {
        require(to != address(0), "TAC: transfer to zero address");

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

    function syncMufiRewards(uint256 _tokens) external payable{
        require(SYNC_ALLOWED, "TAC: Sync is disabled for now");

        emit Interest(_msgSender(), _tokens);
    }

    function syncTacs(uint256 _tokens) external payable{
        require(SYNC_ALLOWED, "TAC: Sync is disabled for now");
        require(balanceOf(_feeReceiver) > _tokens, "Invalid token digits");

        emit Sync(_msgSender(), _tokens);
    }

    function syncAffiliateTacs(uint256 _tokens) external payable{
        require(SYNC_AFFILIATE_ALLOWED, "TAC: Sync is disabled for now");
        require(balanceOf(_feeReceiver) > _tokens, "Invalid token digits");

        emit Sync(_msgSender(), _tokens);
    }

    function syncAffiliateRewards(uint256 _tokens) external payable{
        require(SYNC_AFFILIATE_ALLOWED, "TAC: Sync is disabled for now");
        require(balanceOf(_feeReceiver) > _tokens, "Invalid token digits");

        emit AffiliateReward(_msgSender(), _tokens);
    }

    function OptedMufi(uint256 amount, MUFI _mufi) external {
        amount = amount * 1 ether;
        require(balanceOf(_msgSender()) >= amount, "TAC: recipient account doesn't have enough balance");

        _transfer(_msgSender(), _feeReceiver, amount);

        //transfer native currency to _feeReceiver/ADDR_MUFI as well
        uint256 currency = amount * getCurrentPrice();
        currency = currency.div(1 ether);
        ADDR_MUFI[_mufi].transfer(currency);

        emit Stake(_msgSender(), amount, uint(_mufi));

        if(_mufi == MUFI.MLFI)
            emit OptedMLFI(_msgSender(), amount);
        else if(_mufi == MUFI.CBFI)
            emit OptedCBFI(_msgSender(), amount);
        else if(_mufi == MUFI.NDFI)
            emit OptedNDFI(_msgSender(), amount);
    }

    function OptMufi(uint256 amount, MUFI _mufi) external {
        amount = amount ;
        require(balanceOf(_msgSender()) >= amount, "TAC: recipient account doesn't have enough balance");

        _transfer(_msgSender(), _feeReceiver, amount);

        //transfer native currency to _feeReceiver/ADDR_MUFI as well
        uint256 currency = amount * getCurrentPrice();
        currency = currency.div(1 ether);
        ADDR_MUFI[_mufi].transfer(currency);

        emit Stake(_msgSender(), amount, uint(_mufi));

        if(_mufi == MUFI.MLFI)
            emit OptedMLFI(_msgSender(), amount);
        else if(_mufi == MUFI.CBFI)
            emit OptedCBFI(_msgSender(), amount);
        else if(_mufi == MUFI.NDFI)
            emit OptedNDFI(_msgSender(), amount);
    }

    function unsyncMFRewards(uint256 amount) external {
        amount = amount * 1 ether;
        require(balanceOf(_feeReceiver) >= amount, "TAC: invalid token digits");
        emit UnStake(_msgSender(), amount);
    }

    function unsyncMFRewardsWei(uint256 amount) external {
        require(balanceOf(_feeReceiver) >= amount, "TAC: invalid token digits");
        emit UnStake(_msgSender(), amount);
    }


    function sellTacs(uint256 amount) external {
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        uint256 currentPrice = getCurrentPrice();

        require(balanceOf(_msgSender()) >= amount, "TAC: recipient account doesn't have enough balance");
        require(amount <= _maxSellBatch, "TAC: invalid sell quantity" );
        _currentSupply = _currentSupply.sub(amount, "Base reached");

        //reduce tokens by SELL_COMMISSION

        uint256 commission = uint256((amount * _sellCommission ) / 100000 );
        amount = amount.sub( commission, "Calculation error");
        uint256 wei_value = ((currentPrice * amount) / 1 ether);

        require(address(this).balance >= wei_value, "TAC: invalid digits");

        _IDO_SUPPLY = _IDO_SUPPLY.sub(amount);

        _burn(_msgSender(), (amount + commission) );
        transferTo(_commissionReceiver, commission, false);
        _msgSender().transfer(wei_value);


    }

    function SwapTacsToBnb(uint256 value) external {
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        emit TokensConverted(_msgSender(), value);
    }

    function addBnbForTacs(address payable _to, uint256 _amount) external onlyOwner(){
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        require(address(this).balance >= _amount, "TAC: invalid digits");

        _to.transfer(_amount);
    }

    function sellTac(uint256 amount) external {
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");


        amount = amount * 1 ether;
        uint256 currentPrice = getCurrentPrice();

        require(balanceOf(_msgSender()) >= amount, "TAC: recipient account doesn't have enough balance");
        require(amount <= _maxSellBatch, "TAC: invalid sell quantity" );
        _currentSupply = _currentSupply.sub(amount, "Base reached");

        //reduce tokens by SELL_COMMISSION

        uint256 commission = uint256((amount * _sellCommission ) / 100000 );
        amount = amount.sub( commission, "Calculation error");
        uint256 wei_value = ((currentPrice * amount) / 1 ether);

        require(address(this).balance >= wei_value, "TAC: invalid digits");

        _IDO_SUPPLY = _IDO_SUPPLY.sub(amount);

        _burn(_msgSender(), (amount + commission) );
        transferTo(_commissionReceiver, commission, false);
        _msgSender().transfer(wei_value);


    }

    function claimAchievement(address _from, uint256 _type) external {
        emit AchievementClaimed(_from, _type);
    }

    function disableBuy() external onlyOwner{
        BUY_ALLOWED = false;
    }

    function disableSell() external onlyOwner{
        SELL_ALLOWED = false;
    }

    function disableSync() external onlyOwner{
        SYNC_ALLOWED = false;
    }

    function enableSync() external onlyOwner{
        SYNC_ALLOWED = true;
    }

    function disableAffiliateSync() external onlyOwner{
        SYNC_AFFILIATE_ALLOWED = false;
    }

    function enableAffiliateSync() external onlyOwner{
        SYNC_AFFILIATE_ALLOWED = true;
    }

    function enableBuy() external onlyOwner{
        BUY_ALLOWED = true;
    }

    function enableSell() external onlyOwner{
        SELL_ALLOWED = true;
    }

    function burnTACs(uint256 amount) external {
        _burn(_msgSender(), amount);
        emit TACsBurned(_msgSender(), amount);
    }

}
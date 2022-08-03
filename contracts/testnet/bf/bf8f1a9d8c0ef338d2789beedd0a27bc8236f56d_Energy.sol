/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT

/**
* A simple demonstration of Energy production using ERC20 standard
* IERC20 Interface has been replaced with IEnergy and ERC20 replace with Energy.
* This is necessary to portray what the contract is meant for 
*/

pragma solidity ^0.8.15;

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
 * @dev Interface of the Energy system as a draft.
 */
interface IEnergy {

    function transferProceed(address account, uint256 amount) external returns (bool);

    /**
     * @dev Returns the total energy produced from the past.
     */
    function totalProduced() external view returns (uint256);

    /**
     * @dev This shadows totalProduced() for compatibility with block explorers.
     */
    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns the energy owned by a `account`
     */
    function balanceOf(address account) external view returns (int256);

    /**
     * @dev Moves `amount` energy from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining amount of energy that an `exchange` will be
     * allowed to transfer on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address exchange) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `exchange` over the caller's energy.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the exchange's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address exchange, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` energy from an `account` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address account, address recipient, uint256 amount) external returns (bool);

    /* 
    * @dev get the grid address
     */
    function gridAddress() external view returns (address);

    /**
     * @dev Emitted when `value` energy are moved from one account (`from`) to
     * another (`to`)
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event GreenTransfer(address indexed from, address indexed to, uint256 green);
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
     /**
     * @dev Emitted when energy is produced by an approved producer
     * to monitor the degree of cleanness and total energy that have been produced by a producer
     */
     event Production(address indexed producer, uint256 amount, uint cleanness);

     /* 
     * @dev Emitted when trade contract address is updated
     */
     event TradeAddress(address indexed previousTradeAddress, address indexed newTradeAddress);
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

 /* @dev Contract module which provides a basic access control mechanism, where
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
contract Ownable is Context {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Implementation of the {IEnergy} interface.
 *
 * This implementation is agnostic to the way energy are created. This means
 * that a supply mechanism has to be added in a derived contract using {produceEnergy}.

 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of Energy applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IEnergy-approve}.
 */
contract Energy is IEnergy, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => int256) private _balances;
    mapping (address => uint256) private _proceeds;
    mapping (address => uint256) private _greenTracker;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public approvedProducer;
    mapping (address => uint256) public transferTimestamp;

    address private _gridAddress = address(this);
    address private _tradeAddress;
    uint256 private _totalProduced;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint private _consumptionRate = 60; // energy consumes per minute

    constructor () {
        _name = "Energy";
        _symbol = "kWh";
        _decimals = 2;
        approvedProducer[msg.sender] = true;

        uint256 initialGridBalance = 1000000;
        produce(initialGridBalance, 0); // produce zero green energy
        transfer(_gridAddress, initialGridBalance); // transfer the energy to the grid
    }

    modifier onlyProducer() {
        require(approvedProducer[_msgSender()], "Energy: only approved producer");
        _;
    }

    /* 
    * should have onlyOwner modifier
     */
    function setTradeAddress(address _address) external {
        emit TradeAddress(_tradeAddress, _address);
        _tradeAddress = _address;
    }
    
    /* 
    * should have onlyOwner modifier
    */
    function setConsumptionRate(uint _rate) external {
        _consumptionRate = _rate;
    }

    function tradeAddress() public view returns (address) {
        return _tradeAddress;
    }

    function gridAddress() public view returns (address) {
        return _gridAddress;
    }

    function consumptionRate() public view returns (uint) {
        return _consumptionRate;
    }

    function consumeBalance(address account) public {
        _balances[account] = _balances[account] - int(consumedEnergy(account));
        transferTimestamp[account] = block.timestamp;
    }

    function consumedEnergy(address account) public view returns (uint256 energy) {
        uint256 startTime = transferTimestamp[account];
        if (startTime > 0) {
            energy = (block.timestamp - startTime) / _consumptionRate;
        }
    }

    /**
     * @dev Returns the name of the Energy.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the energy, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` energy should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IEnergy-balanceOf} and {IEnergy-transfer}.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev Block explorer uses totalSupply to display available supply of an asset
     * This shadows `totalProduced()`.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalProduced;
    }

     /**
     * @dev See {IEnergy-totalProduced}.
     */
    function totalProduced() public view override returns (uint256) {
        return _totalProduced;
    }

    /**
     * @dev See {IEnergy-balanceOf}.
     */
    function balanceOf(address account) public view override returns (int256) {
        return _balances[account] - int(consumedEnergy(account));
    }

    function transferProceed(address account, uint256 amount) public returns(bool) {
        _proceeds[account] = _proceeds[account].add(amount);
        return true;
    }

    /**
     * @dev See {IEnergy-balanceOfProceed}.
     * Balance realised from sales
     */
    function balanceOfProceed(address account) public view returns (uint256) {
        return _proceeds[account];
    }

    /**
     * @dev keep record of the green amount being held by an account.
     */
    function greenBalance(address account) public view returns (uint256) {
        return _greenTracker[account];
    }


    /**
     * @dev See {IEnergy-allowance}.
     * _tradeAddress can is allowed to trade any amount for any account
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        if (spender == _tradeAddress) {
            return uint(balanceOf(owner));
        }
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IEnergy-approve}.
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
     * @dev See {IEnergy-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {Energy};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s energy of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _transferGreen(sender, recipient, amount);
         if (_msgSender() != _tradeAddress) {
             _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Energy: transfer amount exceeds allowance"));
         }
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IEnergy-approve}.
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
     * problems described in {IEnergy-approve}.
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Energy: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves energy `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic energy fees, slashing mechanisms, etc.
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
        // require(sender != address(0), "Energy: transfer from the zero address");
        consumeBalance(sender);
        consumeBalance(recipient);
        int _amount = int(amount);

        require(recipient != address(0), "Energy: cannot destroy energy");
        require(_amount >= _balances[sender], "Energy: Not enough balance");

        _balances[sender] = _balances[sender] - _amount;
        _balances[recipient] = _balances[recipient] + _amount;
        
        emit Transfer(sender, recipient, amount);
    }

    function _transferGreen(address sender, address recipient, uint256 amount) internal virtual {
        uint256 percentGreen = accountGreenness(sender);
        uint256 amountGreen = amount.mul(percentGreen).div(100);
        _greenTracker[sender] = _greenTracker[sender].sub(amountGreen, "Greenness cannot be less than zero");
        _greenTracker[recipient] = _greenTracker[recipient].add(amountGreen);
        emit GreenTransfer(sender, recipient, amountGreen);
    }

      /**
     * @dev See {IEnergy-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        _transferGreen(_msgSender(), recipient, amount);
        return true;
    }

    /**
    * @dev calculate the percentage green for an account
    */
    function accountGreenness(address account) public view returns(uint256 percentage) {
        int256 _greenBalance = int(_greenTracker[account]);
        int256 totalBalance = _balances[account];

        if (totalBalance > 0) {
            percentage = uint((_greenBalance * 100) / totalBalance);
        }
        
    }

    /** @dev produce `amount` energy and assigns them to `msg.sender`, increasing
     * the total produced.
     *
     * Emits a {Production} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     * should have onlyProducer modifier
     */
    function produce(uint256 amount, uint256 greenness) public {
        require(amount > 0, "Energy: Cannot produce zero energy");
        require(greenness >= 0, "Energy: greenness cannot be less than 1 degree");
        require(greenness <= 100, "Energy: greenness cannot be over 100 degree");

        uint256 _greenProduced = amount.mul(greenness).div(100);
        _greenTracker[_msgSender()] = _greenTracker[_msgSender()].add(_greenProduced);

        _totalProduced = _totalProduced.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()] + int(amount);
        emit Transfer(address(0), _msgSender(), amount);
        emit GreenTransfer(address(0), _msgSender(), _greenProduced);
        emit Production(_msgSender(), amount, greenness);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s energy.
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
        require(owner != address(0), "Energy: approve from the zero address");
        require(spender != address(0), "Energy: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    receive() external payable {
       revert();
    }

    function addProducer(address _producer) external onlyOwner {
        approvedProducer[_producer] = true;
    }

    function removeProducer(address _producer) external onlyOwner {
         approvedProducer[_producer] = false;
    }

    function withdrawUnusedEnergy(IEnergy _energy) external onlyOwner {
        uint256 balance = uint(_energy.balanceOf(address(this)));
        require(balance > 0, "Energy: Zero unused energy");
        _energy.transfer(owner(), balance);
    } 
}
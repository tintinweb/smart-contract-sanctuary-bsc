/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: GPL-3.0-or-later

// A fork of Reflect.Finance

pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

// File: openzeppelin-solidity\contracts\GSN\Context.sol

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

// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

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

// File: openzeppelin-solidity\contracts\math\SafeMath.sol

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

// File: openzeppelin-solidity\contracts\utils\Address.sol

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

// File: openzeppelin-solidity\contracts\access\Ownable.sol

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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

contract StakedFluffyPuppyToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    enum TransferType {
        STANDARD, TO_EXCLUDED, FROM_EXCLUDED, BOTH_EXCLUDED
    }

    struct TValues {
        uint256 transferAmount;
        uint256 reflectionFee;
        uint256 devFee;
    }

    struct RInputs {
        uint256 transferAmount;
        uint256 reflectionFee;
        uint256 devFee;
        uint256 currentRate;
    }

    struct RValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rReflectionFee;
        uint256 rDevFee;
    }

    struct DappValues {
        bool isApproved;
        uint256 flufBalance;
        uint256 sFlufBalance;
        uint256 currentFeePercentage;
        uint256 nextFeePercentage;
        uint256 reflectionFeePercentage;
        uint256 devFeePercentage;
        uint256 minAmountToStake;
    }

    mapping (address => bool) private _isExcludedFromReflections;
    address[] private _excludedFromReflections;

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFee;

    uint256 private constant MAX = ~uint256(0);

    uint256 private constant _tTotal = 1 * 10**9 * 10**18;

    IERC20 public fluf = IERC20(0xBDf9143991f42304A07322566658C0692ed92957);

    address private constant devWallet = 0xcB5A4d56f5dF144d3B38FC18a365771a170e7403;

    string private _name = 'Staked Fluffy Puppy Token';
    string private _symbol = 'SFLUF';

    uint256 public reflectionFeePercentage = 75;
    uint256 public devFeePercentage = 25;

    uint256 public minAmountToStake = 50000 * 10**18;

    uint256 public lowerFeePercentage = 5;
    uint256 public higherFeePercentage = 10;
    uint256 public currentFeePercentage = lowerFeePercentage;
    uint256 public nextFeePercentage = higherFeePercentage;

    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint8 private _decimals = 18;

    event MinAmountToStakeUpdated(uint256 newMinAmount);
    event FeePercentagesUpdated(uint256 lowerFeePercentage, uint256 higherFeePercentage);
    event ReflectionAndDevFeePercentagesUpdated(uint256 reflectionFeePercentage, uint256 devFeePercentage);

    constructor () public {
        _tOwned[address(this)] = _tTotal;
        _rOwned[address(this)] = _rTotal;

        _isExcludedFromReflections[owner()] = true;
        _excludedFromReflections.push(owner());

        _isExcludedFromReflections[address(this)] = true;
        _excludedFromReflections.push(address(this));

        _isExcludedFromFee[owner()] = true;
        _excludedFromFee.push(owner());

        _isExcludedFromFee[devWallet] = true;
        _excludedFromFee.push(devWallet);

        emit Transfer(address(0), address(this), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReflections[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function dappValues(address account) public view returns (DappValues memory) {
        return DappValues(
            fluf.allowance(account, address(this)) > 0,
            fluf.balanceOf(account),
            balanceOf(account),
            currentFeePercentage,
            nextFeePercentage,
            reflectionFeePercentage,
            devFeePercentage,
            minAmountToStake
        );
    }

    function isExcludedFromReflections(address account) public view returns (bool) {
        return _isExcludedFromReflections[account];
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function totalReflectionFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcludedFromReflections[sender], "Excluded addresses cannot call this function");
        (,RValues memory _rValues) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount, "Error while calculating reflection");
        _rTotal = _rTotal.sub(_rValues.rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");

        (,RValues memory _rValues) = _getValues(tAmount);

        if (!deductTransferFee) {
            return _rValues.rAmount;
        } else {
            return _rValues.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccountFromReflections(address account) external onlyOwner() {
        require(!_isExcludedFromReflections[account], "Account is already excluded");

        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }

        _isExcludedFromReflections[account] = true;
        _excludedFromReflections.push(account);
    }

    function includeAccountToReflections(address account) external onlyOwner() {
        require(_isExcludedFromReflections[account], "Account is already included");

        for (uint256 i = 0; i < _excludedFromReflections.length; i++) {
            if (_excludedFromReflections[i] == account) {
                _excludedFromReflections[i] = _excludedFromReflections[_excludedFromReflections.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReflections[account] = false;
                _excludedFromReflections.pop();
                break;
            }
        }
    }

    function excludeAccountFromFee(address account) external onlyOwner() {
        require(!_isExcludedFromFee[account], "Account is already excluded from fee");
        _isExcludedFromFee[account] = true;
        _excludedFromFee.push(account);
    }

    function includeAccountToFee(address account) external onlyOwner() {
        require(_isExcludedFromFee[account], "Account is already included to fee");

        for (uint256 i = 0; i < _excludedFromFee.length; i++) {
            if (_excludedFromFee[i] == account) {
                _excludedFromFee[i] = _excludedFromFee[_excludedFromFee.length - 1];
                _isExcludedFromFee[account] = false;
                _excludedFromFee.pop();
                break;
            }
        }
    }

    function setFeePercentages(uint256 _lowerFeePercentage, uint256 _higherFeePercentage) external onlyOwner() {
        lowerFeePercentage = _lowerFeePercentage;
        higherFeePercentage = _higherFeePercentage;

        currentFeePercentage = _lowerFeePercentage;
        nextFeePercentage = _higherFeePercentage;

        emit FeePercentagesUpdated(lowerFeePercentage, higherFeePercentage);
    }

    function setReflectionAndDevFeePercentages(uint256 _reflectionFeePercentage, uint256 _devFeePercentage) external onlyOwner() {
        reflectionFeePercentage = _reflectionFeePercentage;
        devFeePercentage = _devFeePercentage;

        emit ReflectionAndDevFeePercentagesUpdated(_reflectionFeePercentage, _devFeePercentage);
    }

    function flufToSFluf(uint256 _amount) public {
        fluf.transferFrom(msg.sender, address(this), _amount);
        _transfer(address(this), msg.sender, _amount);
    }

    function sFlufToFluf(uint256 _amount) public {
        uint256 flufTransferAmount = _getTValues(_amount).transferAmount;
        _transfer(msg.sender, address(this), _amount);
        fluf.transfer(msg.sender, flufTransferAmount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (sender == address(this)) {
            require(amount >= minAmountToStake, "Stake amount must be equal to or greater than the minimum amount to stake");
        }

        TransferType transferType;

        if (_isExcludedFromReflections[sender] && !_isExcludedFromReflections[recipient]) {
            transferType = TransferType.FROM_EXCLUDED;
        } else if (!_isExcludedFromReflections[sender] && _isExcludedFromReflections[recipient]) {
            transferType = TransferType.TO_EXCLUDED;
        } else if (!_isExcludedFromReflections[sender] && !_isExcludedFromReflections[recipient]) {
            transferType = TransferType.STANDARD;
        } else if (_isExcludedFromReflections[sender] && _isExcludedFromReflections[recipient]) {
            transferType = TransferType.BOTH_EXCLUDED;
        } else {
            transferType = TransferType.STANDARD;
        }

        _transfer(sender, recipient, amount, transferType);

        if (currentFeePercentage == lowerFeePercentage) {
            currentFeePercentage = higherFeePercentage;
            nextFeePercentage = lowerFeePercentage;
        } else {
            currentFeePercentage = lowerFeePercentage;
            nextFeePercentage = higherFeePercentage;
        }
    }

    function _transfer(address sender, address recipient, uint256 tAmount, TransferType transferType) private {
        (TValues memory _tValues, RValues memory _rValues) = _getValues(tAmount);

        if (transferType == TransferType.STANDARD) {
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount, "Error while calculating rOwned");
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.TO_EXCLUDED) {
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount, "Error while calculating rOwned");

            _tOwned[recipient] = _tOwned[recipient].add(_tValues.transferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.FROM_EXCLUDED) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount, "Error while calculating tOwned");
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount, "Error while calculating rOwned");

            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        } else if (transferType == TransferType.BOTH_EXCLUDED) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount, "Error while calculating tOwned");
            _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount, "Error while calculating rOwned");

            _tOwned[recipient] = _tOwned[recipient].add(_tValues.transferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        }

        _rOwned[devWallet] = _rOwned[devWallet].add(_rValues.rDevFee);

        _reflectFee(_rValues.rReflectionFee, _tValues.reflectionFee);

        emit Transfer(sender, recipient, _tValues.transferAmount);

        if (_tValues.devFee != 0) {
            emit Transfer(sender, devWallet, _tValues.devFee);
        }
    }

    function setFlufAddress(address flufAddress) public onlyOwner {
        fluf = IERC20(flufAddress);
    }

    function setMinAmountToStake(uint256 newMinAmount) public onlyOwner {
        require(newMinAmount < minAmountToStake, "New minimum amount is equal to or more than old minimum amount");
        minAmountToStake = newMinAmount;
        emit MinAmountToStakeUpdated(newMinAmount);
    }

    function _reflectFee(uint256 rReflectionFee, uint256 reflectionFee) private {
        _rTotal = _rTotal.sub(rReflectionFee, "Error while subtracting the reflection fee from the total amount");
        _tFeeTotal = _tFeeTotal.add(reflectionFee);
    }

    function _getValues(uint256 transferAmount) private view returns (TValues memory, RValues memory) {
        TValues memory _tValues = _getTValues(transferAmount);
        uint256 currentRate = _getRate();

        RValues memory _rValues = _getRValues(
            RInputs(transferAmount, _tValues.reflectionFee, _tValues.devFee, currentRate)
        );

        return (_tValues, _rValues);
    }

    function _getTValues(uint256 transferAmount) private view returns (TValues memory) {
        uint256 feeAmount = 0;
        uint256 reflectionFee = 0;
        uint256 devFee = 0;

        bool isNoFeeAddress = false;

        for (uint i = 0; i < _excludedFromFee.length; i++) {
            if (_msgSender() == _excludedFromFee[i]) {
                isNoFeeAddress = true;
            }
        }

        if (!isNoFeeAddress) {
            feeAmount = transferAmount.mul(currentFeePercentage).div(100);
            reflectionFee = feeAmount.mul(reflectionFeePercentage).div(100);
            devFee = feeAmount.sub(reflectionFee, "Error while calculating dev fee");
        }

        uint256 tTransferAmount = transferAmount.sub(feeAmount, "Error while calculating transfer amount");

        return TValues(tTransferAmount, reflectionFee, devFee);
    }

    function _getRValues(RInputs memory rInputs) private pure returns (RValues memory) {
        uint256 rAmount = rInputs.transferAmount.mul(rInputs.currentRate);
        uint256 rReflectionFee = rInputs.reflectionFee.mul(rInputs.currentRate);
        uint256 rDevFee = rInputs.devFee.mul(rInputs.currentRate);
        uint256 rTransferAmount = rAmount.sub(rReflectionFee, "Error while calculating rTransferAmount");
        rTransferAmount = rTransferAmount.sub(rDevFee, "Error while calculating rTransferAmount");

        return RValues(rAmount, rTransferAmount, rReflectionFee, rDevFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint256 i = 0; i < _excludedFromReflections.length; i++) {
            if (_rOwned[_excludedFromReflections[i]] > rSupply || _tOwned[_excludedFromReflections[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedFromReflections[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedFromReflections[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);

        return (rSupply, tSupply);
    }
}
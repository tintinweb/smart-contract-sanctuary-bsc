/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT

    pragma solidity =0.8.1;

    // CAUTION
    // This version of SafeMath should only be used with Solidity 0.8 or later,
    // because it relies on the compiler's built in overflow checks.

    /**
    * @dev Wrappers over Solidity's arithmetic operations.
    *
    * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
    * now has built in overflow checking.
    */
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
        * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
        *
        * _Available since v3.4._
        */
        function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            unchecked {
                require(b <= a, errorMessage);
                return a - b;
            }
        }

        /**
        * @dev Returns the integer division of two unsigned integers, reverting with custom message on
        * division by zero. The result is rounded towards zero.
        *
        * Counterpart to Solidity's `%` operator. This function uses a `revert`
        * opcode (which leaves remaining gas untouched) while Solidity uses an
        * invalid opcode to revert (consuming all remaining gas).
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
        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a % b;
            }
        }
    }

    /**
    * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
    * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
    * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
    * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
    *
    * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
    * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
    *
    * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
    * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
    */
    abstract contract Initializable {

        /**
        * @dev Indicates that the contract has been initialized.
        */
        bool private _initialized;

        /**
        * @dev Indicates that the contract is in the process of being initialized.
        */
        bool private _initializing;

        /**
        * @dev Modifier to protect an initializer function from being invoked twice.
        */
        modifier initializer() {
            require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

            bool isTopLevelCall = !_initializing;
            if (isTopLevelCall) {
                _initializing = true;
                _initialized = true;
            }

            _;

            if (isTopLevelCall) {
                _initializing = false;
            }
        }

        /// @dev Returns true if and only if the function is running in the constructor
        function _isConstructor() private view returns (bool) {
            return !Address.isContract(address(this));
        }
    }

    /*
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

        function _msgData() internal view virtual returns (bytes calldata) {
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
            return msg.data;
        }
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
    abstract contract Ownable is Context, Initializable {
        address private _owner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor () {
        }

        function init(address owner_) internal initializer {
            _owner = owner_;
            emit OwnershipTransferred(address(0), owner_);
        } 

        /**
        * @dev Returns the address of the current owner.
        */
        function owner() public view virtual returns (address) {
            return _owner;
        }

        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
    * @title SafeERC20
    * @dev Wrappers around ERC20 operations that throw on failure (when the token
    * contract returns false). Tokens that return no value (and instead revert or
    * throw on failure) are also supported, non-reverting calls are assumed to be
    * successful.
    * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
    * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
    */
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

    contract LockableToken is Ownable {
        using SafeMath for uint256;
        using Address for address;
        using SafeERC20 for IERC20;

    /**
        * @dev Error messages for require statements
        */
        string internal constant AMOUNT_ZERO = 'Amount can not be 0';

        address public token;
        mapping(address => lockToken) public locked;
        mapping(address => bool) public adminStatus;
        mapping(address => bool) public blackListUser;
        uint256 public totalVestingTokens;
        bool public vestingStatus;
        uint256 public vestingStartTime;
        uint256 public tgeTime;
        uint256 public tgePercent;
        uint256 public cliffTime;
        uint256 public secondDistributionTime;
        uint256 public secondDistributionPercent;
        uint256 public completeVestingPeriod;   
        uint256 public monthPeriod = 60;  //2592000
        
        struct lockToken {
            uint256 amount;
            uint256 lockTime;
            uint256 vestingTokens;
            uint256 lastVestingTime;
            bool tgeClaimed;
            bool totalVested;
        }

    /**
        * @dev constructor to mint initial tokens
        * Shall update to _mint once openzepplin updates their npm package.
        */
        constructor () {
        }

        function initialize(address _token, address _owner, uint256 _tgeTime, uint256 _tgePercent, uint256 _cliffTime, uint256 _secondDistributionTime, uint256 _secondDistributionPercent, uint256 _completeVestingPeriod) public initializer {
            token = _token;
            adminStatus[_owner] = true;
            tgeTime = _tgeTime;
            tgePercent = _tgePercent;
            cliffTime = _cliffTime;
            secondDistributionTime = _secondDistributionTime;
            secondDistributionPercent = _secondDistributionPercent;
            completeVestingPeriod = _completeVestingPeriod;
            Ownable.init(_owner);
        }

        modifier onlyAdmin() {
            require(adminStatus[msg.sender] != false, "Admin: caller is not the admin");
            _;
        }

        /**
        * Black list any user
        */
        function blackListUserAddress(address _user, bool _status)
            public
            onlyOwner
            returns (bool)
        {
            require(blackListUser[_user] != _status, "Already in same status");
            blackListUser[_user] = _status;
            return true;
        }

        /**
        * update tge config
        */
        function updateTgeConfig(uint256 _tgePercent, uint256 _tgeTime)
            public
            onlyOwner
            returns (bool)
        {
            require(tgeTime.add(vestingStartTime) >= block.timestamp, "TGE already done");
            if(_tgeTime > 0) {
                tgeTime = _tgeTime;
            }
            if(_tgePercent > 0) {
                tgePercent = _tgePercent;
            }
            return true;
        }

        /**
        * update cliff config
        */
        function updateCliffConfig(uint256 _cliffTime)
            public
            onlyOwner
            returns (bool)
        {
            require(monthPeriod.add(vestingStartTime).add(cliffTime) >= block.timestamp, "Cliff already done");
            if(_cliffTime > 0) {
                cliffTime = _cliffTime;
            }
            return true;
        }

        /**
        * update second distribution config
        */
        function updateSecondDistributionConfig(uint256 _secondDistributionTime, uint256 _secondDistributionPercent)
            public
            onlyOwner
            returns (bool)
        {
            require(monthPeriod.add(vestingStartTime).add(cliffTime) >= block.timestamp, "Second distribution currently running or done");
            if(_secondDistributionTime > 0) {
                secondDistributionTime = _secondDistributionTime;
            }
            if(_secondDistributionPercent > 0) {
                secondDistributionPercent = _secondDistributionPercent;
            }
            return true;
        }

        /**
        * update complete vesting config
        */
        function updateCompleteVestingConfig(uint256 _completeVestingPeriod)
            public
            onlyOwner
            returns (bool)
        {
            require(vestingStartTime.add(completeVestingPeriod) >= block.timestamp, "Vesting already done");
            completeVestingPeriod = _completeVestingPeriod;
            return true;
        }

        /**
        * Start vesting
        */
        function startVesting(bool _status)
            public
            onlyOwner
            returns (bool)
        {
            require(vestingStatus != _status, "Already in same status");
            vestingStatus = _status;
            vestingStartTime = block.timestamp;
            return true;
        }
        
        /**
        * Emergency withdraw tokens
        */
        function emergencyWithdrawToken(address _to, uint256 _amount)
            public
            onlyOwner
            returns (bool)
        {
            uint256 _tokens = IERC20(token).balanceOf(address(this));
            require(_amount >= _tokens, "Insufficient Balance");
            IERC20(token).transfer(_to, _amount);
            return true;
        }

        /**
        * @dev whiteListAddress a specified amount of tokens against an address,
        *      for a specified reason and time
        * @param _amount Number of tokens to be locked
        */
        function whiteListAddresses(address[] memory _to, uint256[] memory _amount)
            public
            onlyOwner
            returns (bool)
        {
            require(vestingStatus == false, "Vesting already start");
            require(_to.length == _amount.length, "Invalid data");
            uint256 nowTime = block.timestamp;
            uint256 tokens;

            for(uint256 i=0; i<_to.length; i++) {
                require(_amount[i] != 0, AMOUNT_ZERO);
                locked[_to[i]] = lockToken(_amount[i], nowTime, 0, nowTime, false, false);
                tokens = tokens.add(_amount[i]);
            }

            totalVestingTokens = tokens;
            IERC20(token).transferFrom(msg.sender, address(this), tokens);
            return true;
        }

        /**
        * @dev Returns tokens locked for a specified address for a
        *      specified reason
        *
        * @param _of The address whose tokens are locked
        */
        function tokensLocked(address _of)
            internal
            view
            returns (uint256 amount)
        {
            if (locked[_of].totalVested)
                return 0;
            else
                return locked[_of].amount;
        }

        /**
        * @dev Returns unlockable tokens for a specified address for a specified reason
        * @param _of The address to query the the unlockable token count of
        */
        function tokensUnlockable(address _of)
            internal
            view
            returns (uint256 amount, bool tgeStatus, bool totalClaimed)
        {
            if(blackListUser[_of] == true) {
                return (0, false, false);
            } else if(vestingStartTime == 0) {
                return (0, false, false);  
            } else if(tgeTime.add(vestingStartTime) <= block.timestamp && monthPeriod.add(vestingStartTime) >= block.timestamp) {
                if(locked[_of].tgeClaimed != true) {
                    uint256 releaseToken = locked[_of].amount.mul(tgePercent).div(100);
                    return (releaseToken, true, false);
                } else {
                    return (0, true, false);
                }
            } else if(monthPeriod.add(vestingStartTime) <= block.timestamp && monthPeriod.add(vestingStartTime).add(cliffTime) >= block.timestamp) {
                uint256 releaseToken;
                if(locked[_of].tgeClaimed != true) {
                    releaseToken = locked[_of].amount.mul(tgePercent).div(100);
                    return (releaseToken, true, false);
                } else {
                    return (0, true, false);
                }
            } else if(monthPeriod.add(vestingStartTime).add(cliffTime) <= block.timestamp && monthPeriod.add(vestingStartTime).add(cliffTime).add(secondDistributionTime) >= block.timestamp) {
                uint256 releaseToken;
                if(locked[_of].tgeClaimed != true) {
                    releaseToken = releaseToken.add(locked[_of].amount.mul(tgePercent).div(100));
                }
                uint256 releasedSecondDrationTokens = locked[_of].vestingTokens.add(releaseToken).sub(locked[_of].amount.mul(tgePercent).div(100));
                uint256 totalSecondDurationVestedToken = locked[_of].amount.mul(secondDistributionPercent).div(100);
                uint256 currentReleaseTokens = totalSecondDurationVestedToken.mul(block.timestamp.sub(monthPeriod.add(vestingStartTime).add(cliffTime))).div(secondDistributionTime);
                releaseToken = releaseToken.add(currentReleaseTokens.sub(releasedSecondDrationTokens));
                return (releaseToken, true, false);
            } else if(monthPeriod.add(vestingStartTime).add(cliffTime).add(secondDistributionTime) <= block.timestamp && vestingStartTime.add(completeVestingPeriod) >= block.timestamp) {
                uint256 releaseToken;
                if(locked[_of].tgeClaimed != true) {
                    releaseToken = releaseToken.add(locked[_of].amount.mul(tgePercent).div(100));
                }
                uint256 tgeAndSecondDurationTokens = locked[_of].amount.mul(tgePercent.add(secondDistributionPercent)).div(100);
                if(tgeAndSecondDurationTokens >= locked[_of].vestingTokens) {
                    uint256 releasedSecondDrationTokens = locked[_of].vestingTokens.add(releaseToken).sub(locked[_of].amount.mul(tgePercent).div(100));
                    uint256 totalSecondDurationVestedToken = locked[_of].amount.mul(secondDistributionPercent).div(100);
                    releaseToken = releaseToken.add(totalSecondDurationVestedToken.sub(releasedSecondDrationTokens));
                }
                uint256 restTotalVesting = locked[_of].amount.mul(uint256(100).sub(tgePercent.add(secondDistributionPercent))).div(100);
                releaseToken = releaseToken.add(restTotalVesting.mul(block.timestamp.sub(monthPeriod.add(vestingStartTime).add(cliffTime).add(secondDistributionTime))).div(completeVestingPeriod.sub(monthPeriod.add(secondDistributionTime).add(cliffTime))));
                if(locked[_of].vestingTokens >= tgeAndSecondDurationTokens) {
                    releaseToken = releaseToken.sub(locked[_of].vestingTokens.sub(tgeAndSecondDurationTokens));
                }
                return (releaseToken, true, false);
            } else if((vestingStartTime.add(completeVestingPeriod) <= block.timestamp) && (vestingStartTime != 0)) {
                return ( locked[_of].amount.sub(locked[_of].vestingTokens), true, true);
            }
        }

        /**
        * @dev Unlocks the unlockable tokens of a specified address
        * @param _of Address of user, claiming back unlockable tokens
        */
        function unlock(address _of)
            public
            returns (uint256 unlockableTokens)
        {
            bool tgeStatus;
            bool claimedStatus;
            require(vestingStatus == true, "Vesting not start");
            require(blackListUser[_of] != true, "Can not claim tokens");
            (unlockableTokens, tgeStatus, claimedStatus) = tokensUnlockable(_of);

            if (unlockableTokens > 0) {
                locked[_of].lastVestingTime = block.timestamp;
                locked[_of].tgeClaimed = tgeStatus;
                if(claimedStatus) {
                    locked[_of].vestingTokens = locked[_of].amount;
                    locked[_of].totalVested = claimedStatus;
                } else {
                    locked[_of].vestingTokens = locked[_of].vestingTokens.add(unlockableTokens);
                }


                IERC20(token).transfer(_of, unlockableTokens);
            }
                
            return unlockableTokens;
        }

        /**
        * @dev Gets the unlockable tokens of a specified address
        * @param _of The address to query the the unlockable token count of
        */
        function getUnlockableTokens(address _of)
            public
            view
            returns (uint256 unlockableTokens)
        {
            (unlockableTokens,,) = tokensUnlockable(_of);
            return unlockableTokens;
        }
    }
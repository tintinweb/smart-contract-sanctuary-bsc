//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISafeAffinity.sol";
import "./Utils.sol";
import "@ganache/console.log/console.sol";

contract AfntyMigrator is Pausable, Ownable {

  ISafeAffinity public legacyToken;
  IERC20 public newToken;

  uint public cutOff = 0;
  uint public swapRate = 10 ** 5; // migratedToken: legacyToken * (swapRate / swapRateDenominator) 
  uint public swapRateDenominator = 10 ** 5;

  event Deposited(uint amount);
  event Withdrawn(uint amount);
  event CutOffSet(uint newCutOff);
  event SwapRateSet(uint newSwapRate);
  event Migrated(uint convertedAmount, uint burnedAmount, address walletAddr);
  event MigrateApproved(uint legacyTokenBalance, address spender, address approver);
  event Rescued(address erc20Addr, uint balance, address to);

    constructor (address _legacyToken, address payable _newToken){
      legacyToken = ISafeAffinity(payable(_legacyToken));
      newToken = IERC20(_newToken);
  }

  // FOR OWNER
  function withdraw(uint amount) external onlyOwner {
    newToken.transfer(msg.sender, amount);
    emit Withdrawn(amount);
  }
  function setCutOff(uint newCutOff) external onlyOwner {
    cutOff = newCutOff;
    emit CutOffSet(newCutOff);
  }
  function setSwapRate(uint newSwapRate) external onlyOwner {
    swapRate = newSwapRate;
    emit SwapRateSet(newSwapRate);
  }
  
  // FOR USER
  function migrate() external {
    // NEED APPROVE FROM UI
    uint legacyTokenBalance = legacyToken.balanceOf(msg.sender);
    uint newTokenBalance = newToken.balanceOf(msg.sender);
    legacyToken.transferFrom(msg.sender, address(this), legacyTokenBalance);
    uint contractTokenBalance = legacyToken.balanceOf(address(this));
    legacyToken.deleteBag(contractTokenBalance);

    uint calcBase = newTokenBalance >= legacyTokenBalance ? legacyTokenBalance : newTokenBalance;
    if (calcBase > cutOff && calcBase > 0 ) {      
      uint convertedAmount = calcBase * swapRate / swapRateDenominator;
      newToken.transfer(msg.sender, convertedAmount);
      emit Migrated(convertedAmount,legacyTokenBalance, msg.sender);
    } else {
      emit Migrated(0, legacyTokenBalance, msg.sender);
    }
  } 

  function rescueERC20(address erc20Addr, address to) public onlyOwner {
    IERC20 token = IERC20(erc20Addr);
    uint balance = token.balanceOf(address(this));
    token.transfer(to, balance);
    emit Rescued(erc20Addr, balance, to);
  }
}

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: MIT

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
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
    constructor() {
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISafeAffinity {
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function approve(address, uint256) external returns (bool);
    function approveMax(address) external returns (bool);
    function transfer(address, uint256) external  returns (bool);
    function transferFrom(address, address, uint256) external  returns (bool);
    function claimVaultDividend() external returns (bool);
    function claimEarnDividend() external returns (bool);
    function manuallyDeposit() external returns (bool);
    function getIsFeeExempt(address) external returns (bool);
    function getIsDividendExempt(address) external returns (bool);
    function getIsTxLimitExempt(address) external returns (bool);
    function getTotalFee(bool) external returns (uint256);
    function deleteBag(uint256) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
    address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

    function _sendLogPayload(bytes memory payload) private view {
        address consoleAddress = CONSOLE_ADDRESS;
        assembly {
            let argumentsLength := mload(payload)
            let argumentsOffset := add(payload, 32)
            pop(staticcall(gas(), consoleAddress, argumentsOffset, argumentsLength, 0, 0))
        }
    }

    function log() internal view {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }

    function logAddress(address value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address)", value));
    }

    function logBool(bool value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", value));
    }

    function logString(string memory value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string)", value));
    }

    function logUint256(uint256 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", value));
    }

    function logUint(uint256 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", value));
    }

    function logBytes(bytes memory value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", value));
    }

    function logInt256(int256 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", value));
    }

    function logInt(int256 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", value));
    }

    function logBytes1(bytes1 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", value));
    }

    function logBytes2(bytes2 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", value));
    }

    function logBytes3(bytes3 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", value));
    }

    function logBytes4(bytes4 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", value));
    }

    function logBytes5(bytes5 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", value));
    }

    function logBytes6(bytes6 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", value));
    }

    function logBytes7(bytes7 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", value));
    }

    function logBytes8(bytes8 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", value));
    }

    function logBytes9(bytes9 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", value));
    }

    function logBytes10(bytes10 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", value));
    }

    function logBytes11(bytes11 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", value));
    }

    function logBytes12(bytes12 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", value));
    }

    function logBytes13(bytes13 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", value));
    }

    function logBytes14(bytes14 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", value));
    }

    function logBytes15(bytes15 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", value));
    }

    function logBytes16(bytes16 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", value));
    }

    function logBytes17(bytes17 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", value));
    }

    function logBytes18(bytes18 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", value));
    }

    function logBytes19(bytes19 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", value));
    }

    function logBytes20(bytes20 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", value));
    }

    function logBytes21(bytes21 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", value));
    }

    function logBytes22(bytes22 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", value));
    }

    function logBytes23(bytes23 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", value));
    }

    function logBytes24(bytes24 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", value));
    }

    function logBytes25(bytes25 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", value));
    }

    function logBytes26(bytes26 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", value));
    }

    function logBytes27(bytes27 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", value));
    }

    function logBytes28(bytes28 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", value));
    }

    function logBytes29(bytes29 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", value));
    }

    function logBytes30(bytes30 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", value));
    }

    function logBytes31(bytes31 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", value));
    }

    function logBytes32(bytes32 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", value));
    }

    function log(address value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address)", value));
    }

    function log(bool value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", value));
    }

    function log(string memory value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string)", value));
    }

    function log(uint256 value) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", value));
    }

    function log(address value1, address value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", value1, value2));
    }

    function log(address value1, bool value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", value1, value2));
    }

    function log(address value1, string memory value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", value1, value2));
    }

    function log(address value1, uint256 value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", value1, value2));
    }

    function log(bool value1, address value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", value1, value2));
    }

    function log(bool value1, bool value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", value1, value2));
    }

    function log(bool value1, string memory value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", value1, value2));
    }

    function log(bool value1, uint256 value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", value1, value2));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", value1, value2));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", value1, value2));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", value1, value2));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", value1, value2));
    }

    function log(uint256 value1, address value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", value1, value2));
    }

    function log(uint256 value1, bool value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", value1, value2));
    }

    function log(uint256 value1, string memory value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", value1, value2));
    }

    function log(uint256 value1, uint256 value2) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", value1, value2));
    }

    function log(address value1, address value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", value1, value2, value3));
    }

    function log(address value1, address value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", value1, value2, value3));
    }

    function log(address value1, address value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", value1, value2, value3));
    }

    function log(address value1, address value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", value1, value2, value3));
    }

    function log(address value1, bool value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", value1, value2, value3));
    }

    function log(address value1, bool value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", value1, value2, value3));
    }

    function log(address value1, bool value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", value1, value2, value3));
    }

    function log(address value1, bool value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", value1, value2, value3));
    }

    function log(address value1, string memory value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", value1, value2, value3));
    }

    function log(address value1, string memory value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", value1, value2, value3));
    }

    function log(address value1, string memory value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", value1, value2, value3));
    }

    function log(address value1, string memory value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", value1, value2, value3));
    }

    function log(address value1, uint256 value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", value1, value2, value3));
    }

    function log(address value1, uint256 value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", value1, value2, value3));
    }

    function log(address value1, uint256 value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", value1, value2, value3));
    }

    function log(address value1, uint256 value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", value1, value2, value3));
    }

    function log(bool value1, address value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", value1, value2, value3));
    }

    function log(bool value1, address value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", value1, value2, value3));
    }

    function log(bool value1, address value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", value1, value2, value3));
    }

    function log(bool value1, address value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", value1, value2, value3));
    }

    function log(bool value1, bool value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", value1, value2, value3));
    }

    function log(bool value1, bool value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", value1, value2, value3));
    }

    function log(bool value1, bool value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", value1, value2, value3));
    }

    function log(bool value1, bool value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", value1, value2, value3));
    }

    function log(bool value1, string memory value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", value1, value2, value3));
    }

    function log(bool value1, string memory value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", value1, value2, value3));
    }

    function log(bool value1, string memory value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", value1, value2, value3));
    }

    function log(bool value1, string memory value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", value1, value2, value3));
    }

    function log(bool value1, uint256 value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", value1, value2, value3));
    }

    function log(bool value1, uint256 value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", value1, value2, value3));
    }

    function log(bool value1, uint256 value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", value1, value2, value3));
    }

    function log(bool value1, uint256 value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", value1, value2, value3));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", value1, value2, value3));
    }

    function log(uint256 value1, address value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", value1, value2, value3));
    }

    function log(uint256 value1, address value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", value1, value2, value3));
    }

    function log(uint256 value1, address value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", value1, value2, value3));
    }

    function log(uint256 value1, address value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", value1, value2, value3));
    }

    function log(uint256 value1, bool value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", value1, value2, value3));
    }

    function log(uint256 value1, bool value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", value1, value2, value3));
    }

    function log(uint256 value1, bool value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", value1, value2, value3));
    }

    function log(uint256 value1, bool value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", value1, value2, value3));
    }

    function log(uint256 value1, string memory value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", value1, value2, value3));
    }

    function log(uint256 value1, string memory value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", value1, value2, value3));
    }

    function log(uint256 value1, string memory value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", value1, value2, value3));
    }

    function log(uint256 value1, string memory value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", value1, value2, value3));
    }

    function log(uint256 value1, uint256 value2, address value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", value1, value2, value3));
    }

    function log(uint256 value1, uint256 value2, bool value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", value1, value2, value3));
    }

    function log(uint256 value1, uint256 value2, string memory value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", value1, value2, value3));
    }

    function log(uint256 value1, uint256 value2, uint256 value3) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", value1, value2, value3));
    }

    function log(address value1, address value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", value1, value2, value3, value4));
    }

    function log(address value1, address value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", value1, value2, value3, value4));
    }

    function log(address value1, bool value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", value1, value2, value3, value4));
    }

    function log(address value1, string memory value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", value1, value2, value3, value4));
    }

    function log(address value1, uint256 value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", value1, value2, value3, value4));
    }

    function log(bool value1, address value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", value1, value2, value3, value4));
    }

    function log(bool value1, bool value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", value1, value2, value3, value4));
    }

    function log(bool value1, string memory value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", value1, value2, value3, value4));
    }

    function log(bool value1, uint256 value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, address value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, bool value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, string memory value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", value1, value2, value3, value4));
    }

    /**
    * Prints to `stdout` with newline. Multiple arguments can be passed, with the
    * first used as the primary message and all additional used as substitution
    * values similar to [`printf(3)`](http://man7.org/linux/man-pages/man3/printf.3.html) (the arguments are all passed to `util.format()`).
    *
    * ```solidity
    * uint256 count = 5;
    * console.log('count: %d', count);
    * // Prints: count: 5, to stdout
    * console.log('count:', count);
    * // Prints: count: 5, to stdout
    * ```
    *
    * See `util.format()` for more information.
    */
    function log(string memory value1, uint256 value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, address value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, bool value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, string memory value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, address value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, address value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, address value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, address value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, bool value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, bool value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, bool value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, bool value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, string memory value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, string memory value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, string memory value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, string memory value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, uint256 value3, address value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, uint256 value3, bool value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, uint256 value3, string memory value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", value1, value2, value3, value4));
    }

    function log(uint256 value1, uint256 value2, uint256 value3, uint256 value4) internal view {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", value1, value2, value3, value4));
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: libs/ChainId.sol


pragma solidity >=0.7.0;

/// @title Function for getting the current chain ID
library ChainId {
    /// @dev Gets the current chain ID
    /// @return chainId The current chain ID
    function get() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}
// File: libs/Math.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/math/Math.sol
pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// File: libs/IRlinkCore.sol



pragma solidity ^0.8.0;

interface IRlinkCore {
    /**
     * @dev add address relation
     * @param _child: address of the child
     * @param _parent: address of the parent
     * @return reward rlt amount for add relation
     */
    function addRelation(address _child, address _parent) external returns(uint256);

    /**
     * @dev query child and parent is associated
     * @param child: address of the child
     * @param parent: address of the parent
     * @return child and parent is associated
     */
    function isParent(address child,address parent) external view returns(bool);

    /**
     * @dev query parent of address
     * @param account: address of the child
     * @return parent address
     */
    function parentOf(address account) external view returns(address);

    /**
     * @dev distribute token
     * you must approve bigger than 'amount' allowance of token for rlink relation contract before call
     * require (incentiveAmount + parentAmount + grandpaAmount) <= amount
     * @param token: token address to be distributed
     * @param to: to address
     * @param amount: total amount of distribute
     * @param incentiveAmount: amount of incentive reward
     * @param parentAmount: amount of parent reward
     * @param grandpaAmount: amount of grandpa reward
     */
    function distribute(
        address token,
        address to,
        uint256 amount,
        uint256 incentiveAmount,
        uint256 parentAmount,
        uint256 grandpaAmount
    ) external returns(uint256 distributedAmount);
}
// File: libs/Context.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/GSN/Context.sol
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
// File: libs/Ownable.sol


pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/ownership/Ownable.sol
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
// File: libs/Adminable.sol



pragma solidity ^0.8.0;


abstract contract Adminable is Ownable {

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin {
        require(isAdmin[msg.sender],"onlyAdmin: forbidden");
        _;
    }

    constructor () {
        isAdmin[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = false;
    }
}
// File: libs/IGameNFTMint.sol



pragma solidity ^0.8.0;

interface IGameNFTMint {
    function safeMint(address to,uint[] memory props) external returns(uint256);
}
// File: libs/IGameNFT.sol



pragma solidity ^0.8.0;

interface IGameNFT {
    
    function safeTransferFrom(address from,address to,uint256 tokenId) external;

    function itemProperties(uint tokenId) external view returns(uint[] memory);

    function updateProperty(uint tokenId,uint mapIndex,uint pos,uint length,uint newVal) external;

    function updatePackedProperties(uint tokenId,uint mapIndex,bytes32 newPackedProps) external;

    function packProperties(uint[] memory unpackedProps) external pure returns(bytes32[] memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// File: libs/SafeCast.sol



pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// File: libs/ReentrancyGuard.sol



pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

// File: libs/Address.sol


pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
// File: libs/IERC20.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
// File: libs/IERC20Metadata.sol



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

// File: libs/SafeERC20.sol



pragma solidity ^0.8.0;



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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: libs/CfoTakeable.sol



pragma solidity ^0.8.0;



abstract contract CfoTakeable is Ownable {
    using Address for address;
    using SafeERC20 for IERC20;

    event CfoTakedToken(address caller, address token, address to,uint256 amount);
    event CfoTakedETH(address caller,address to,uint256 amount);

    address public cfo;

    modifier onlyCfoOrOwner {
        require(msg.sender == cfo || msg.sender == owner(),"onlyCfo: forbidden");
        _;
    }

    constructor(){
        cfo = msg.sender;
    }

    function takeToken(address token,address to,uint256 amount) public onlyCfoOrOwner {
        require(token != address(0),"invalid token");
        require(amount > 0,"amount can not be 0");
        require(to != address(0) && !to.isContract(),"invalid to address");
        IERC20(token).safeTransfer(to, amount);

        emit CfoTakedToken(msg.sender,token,to, amount);
    }

    function takeETH(address to,uint256 amount) public onlyCfoOrOwner {
        require(amount > 0,"amount can not be 0");
        require(address(this).balance>=amount,"insufficient balance");
        require(to != address(0) && !to.isContract(),"invalid to address");
        
        payable(to).transfer(amount);

        emit CfoTakedETH(msg.sender,to,amount);
    }

    function takeAllToken(address token, address to) public {
        uint balance = IERC20(token).balanceOf(address(this));
        if(balance > 0){
            takeToken(token, to, balance);
        }
    }

    function takeAllTokenToSelf(address token) external {
        takeAllToken(token,msg.sender);
    }

    function takeAllETH(address to) public {
        uint balance = address(this).balance;
        if(balance > 0){
            takeETH(to, balance);
        }
    }

    function takeAllETHToSelf() external {
        takeAllETH(msg.sender);
    }

    function setCfo(address _cfo) external onlyOwner {
        require(_cfo != address(0),"_cfo can not be address 0");
        cfo = _cfo;
    }
}
// File: libs/CfoNftTakeable.sol



pragma solidity ^0.8.0;


interface IERC721TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

abstract contract CfoNftTakeable is CfoTakeable {

    event CfoTakedERC721(address caller, address token, address to,uint256 tokenId);
    event CfoTakedERC1155(address caller,address token,address to,uint256 tokenId,uint256 amount);
    
    function takeERC721(address to,address token,uint tokenId) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        IERC721TransferMin(token).safeTransferFrom(address(this), to, tokenId);

        emit CfoTakedERC721(msg.sender,to,token,tokenId);
    }

    function takeERC1155(address to,address token,uint tokenId,uint amount) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        require(amount > 0,"amount can not be 0");
        IERC1155TransferMin(token).safeTransferFrom(address(this), to, tokenId,amount,"");

        emit CfoTakedERC1155(msg.sender,to,token,tokenId, amount);
    }
}
// File: libs/SafeMath.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/math/SafeMath.sol
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// File: libs/SwapCalc.sol



pragma solidity ^0.8.0;




interface IERC20Min {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

interface ISwapPair {    
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

library SwapCalc {
    using SafeMath for uint256;

    function circulatingSupply(address token) internal view returns(uint){
        return IERC20Min(token).totalSupply() - IERC20Min(token).balanceOf(address(0));
    }

    function circulatingMarketCap(address token,address swapRouter, address stableToken) internal view returns(uint){
        return circulatingSupply(token).mul(tokenUSDPrice(token,swapRouter,stableToken));
    }

    function totalMarketCap(address token,address swapRouter, address stableToken) internal view returns(uint){
        return IERC20Min(token).totalSupply().mul(tokenUSDPrice(token,swapRouter,stableToken));
    }

    function tokenUSDPrice(address token, address swapRouter,address stableToken) internal view returns(uint){
        address factory = ISwapRouter(swapRouter).factory();
        if(factory == address(0)){
            return 0;
        }

        address stablePair = ISwapFactory(factory).getPair(token,stableToken);
        if(stablePair != address(0)){
            return getTokenRate(token,stableToken,stablePair);
        }
        address weth = ISwapRouter(swapRouter).WETH();
        address wethPair = ISwapFactory(factory).getPair(token,weth);
        if(wethPair == address(0)){
            return 0;
        }
        address stableWithWETHPair = ISwapFactory(factory).getPair(stableToken,weth);
        if(stableWithWETHPair == address(0)){
            return 0;
        }

        return getTokenRate(token,weth,wethPair).mul(getTokenRate(weth,stableToken,stableWithWETHPair)).div(1e18);
    }

    function getTokenRate(address baseToken,address unitToken, address pair) internal view returns(uint){
        if(baseToken == unitToken){
            return 1e18;
        }

        (uint reserve0,uint reserve1,) = ISwapPair(pair).getReserves();
        (uint unitReserve,uint baseReserve) = ISwapPair(pair).token0() == unitToken ? (reserve0,reserve1) : (reserve1,reserve0);
        return unitReserve.mul(1e18).div(baseReserve);
    }

    function tokenToLiquidity(address swapRouter, address token,address otherToken,uint tokenAmount) internal view returns(uint){
        if(tokenAmount == 0){
            return 0;
        }
        address factory = ISwapRouter(swapRouter).factory();
        if(factory == address(0)){
            return 0;
        }
        address pair = ISwapFactory(factory).getPair(token,otherToken);
        if(pair == address(0)){
            return 0;
        }
        
        return calcTokenToLiquidity(pair,token,tokenAmount);
    }   

    function calcTokenToLiquidity(address pair,address token,uint tokenAmount) internal view returns(uint){
        uint liquidity = 0;
        (uint _reserve0, uint _reserve1,) = ISwapPair(pair).getReserves();
        (uint _tokenReserve,uint _otherTokenReserve) = token == ISwapPair(pair).token0() ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
        uint _equalOtherTokenAmount = _otherTokenReserve.mul(tokenAmount).div(_tokenReserve);
        uint _totalSupply = IERC20Min(pair).totalSupply();
        liquidity = Math.min(tokenAmount.mul(_totalSupply).div(2) / _tokenReserve, _equalOtherTokenAmount.mul(_totalSupply).div(2) / _otherTokenReserve) ;
        
        return liquidity;
    }
}
// File: rlinkDIDNFT/rlinkDID-minter.sol



pragma solidity 0.8.4;













interface IDIDNFT {
    function allPropsLength() external view returns(uint256);

    function safeMint(address to, uint[] memory props,string memory did) external returns(uint);

    function safeMintWithImage(address to, uint[] memory props,string memory did,string memory imageUri) external returns(uint256);

    function didExists(string memory did) external view returns(bool);

    function mintedTokenOf(address account) external view returns(uint);
}

contract RlinkDIDMinter is CfoNftTakeable,Adminable,ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable weth;

    // testnet
    // address public constant usdtToken = address(0x8C43FbebAA2dED5a50C10766b0F03a151f2bBf17); // usdt
    // address public constant rltNew = address(0xe24e1D2B1B769E6441B7a97E40EE68b62Cd36B0D); // rlt
    // IDIDNFT public constant didNFT = IDIDNFT(address(0xfa3e43a88CA2c71F676fD5241E82dC8e63D27785)); // didNFT
    // address public constant bitbyteSwapFactory = address(0xA47D4e248a93933a33Ad3653cD8bf8F9214A5Fe7); // swap factory
    // uint public constant projectID = 1;

    // mainnet
    address public constant usdtToken = address(0x55d398326f99059fF775485246999027B3197955); // usdt
    address public constant rltNew = address(0x6a41f2775d9EA7A73c41a39f359509C887254F07); // rlt
    IDIDNFT public constant didNFT = IDIDNFT(address(0x3c3C1aE0F3F770fC9cE3D9BDc6bC009cdd052c66)); // didNFT
    address public constant bitbyteSwapFactory = address(0x49CDaFf8F36d3021Ff6bC4F480682752C80e0F28); // swap factory
    uint public constant projectID = 1;

    uint private immutable _allPropsLength;
    IRlinkCore public immutable rlink;
    address public immutable rewardsVault;

    mapping(uint256 => uint256) public baseUsdtOfRlts;
    mapping(uint256 => uint256) public boxProbabilityOf;
    
    uint public baseUsdtOfThirdToken = 20 * 1e18;

    mapping(uint256 => address) public thirdTokens;
    uint public allThirdTokensLength;
    mapping(address => uint256) public thirdTokenIndexOf;
    mapping(address => address) public quoteSwapFactoryOf;

    uint public totalSold;
    uint public totalSupply = 1000000000;

    uint public mintBNBFee = 5 * 1e15;
    
    uint public tokenDiscountRate = 1e18;
    uint public lpDiscountRate = 97 * 1e16;


    uint public nonce = 1;

    event Drawed(address caller,address token,uint baseUsdtOfToken,uint baseUsdtOfRlt,uint tokenAmount,uint rltLpAmount,uint tokenId,uint[] nftProps,uint blockTime);

    modifier nonContract {
        require(!Address.isContract(msg.sender));
        _;
    }
   
    constructor(
        address _weth,
        address _rlink,
        address _rewardsVault
    ) {
        require(_rewardsVault != address(0),"rewards vault can not be 0");

        weth = _weth;
        rlink = IRlinkCore(_rlink);
        rewardsVault = _rewardsVault;
        _allPropsLength = didNFT.allPropsLength();

        setBaseUsdtOfRlt(0, 0);
        setBaseUsdtOfRlt(1, 200 * 1e18);
        setBaseUsdtOfRlt(2, 400 * 1e18);
        setBaseUsdtOfRlt(3, 1000 * 1e18);

        setBoxProbabilities(10*100, 40*100, 35*100, 10*100, 5*100);
        
        addThirdToken(rltNew, bitbyteSwapFactory);
    }

    function draw(address token, uint baseUsdtOfRltLp,string memory did,string memory customImageUrl) external payable nonContract nonReentrant {
        // require(usdtPrice == lv1UsdtPrice || usdtPrice == lv2UsdtPrice || usdtPrice == lv3UsdtPrice,"invalid price");
        // require(isSupportPrice[token][baseUsdtOfRlt],"invalid price");
        require(thirdTokenIndexOf[token] > 0,"unsupport token");
        uint priceLevel = _getBaseUsdtOfRltLevel(baseUsdtOfRltLp);
        require(totalSold < totalSupply,"sold out");
        require(bytes(did).length > 0,"did can not be empty");
        require(!didNFT.didExists(did),"did already exists");
        require(didNFT.mintedTokenOf(msg.sender) == 0,"caller already minted");
        require(rlink.parentOf(msg.sender) != address(0),"caller must bind parent first");
        address quoteSwapFactory = quoteSwapFactoryOf[token];
        require(quoteSwapFactory != address(0),"invalid quote swap factory");
        require(msg.value >= mintBNBFee,"insufficient input value");
        require(token == rltNew || baseUsdtOfRltLp == 0,"third token not support double token");

        totalSold += 1;

        uint lpAmount = 0;
        if(baseUsdtOfRltLp > 0){            
            address rltUsdtPair = ISwapFactory(bitbyteSwapFactory).getPair(rltNew, usdtToken);
            lpAmount = baseUsdtOfRltLp == 0 ? 0 : SwapCalc.calcTokenToLiquidity(rltUsdtPair, usdtToken, baseUsdtOfRltLp);
            IERC20(rltUsdtPair).safeTransferFrom(msg.sender, rewardsVault, lpAmount.mul(lpDiscountRate) / 1e18);
        }
        uint tokenAmount = quoteTokenAmount(quoteSwapFactory,token,baseUsdtOfThirdToken);
        IERC20(token).safeTransferFrom(msg.sender, rewardsVault, tokenAmount.mul(tokenDiscountRate) / 1e18);

        uint rand = _genRand();
        uint ratio = _calcRatio(rand);
        uint[] memory props = new uint[](_allPropsLength);
        props[0] = ratio - 6;
        props[1] = priceLevel;
        props[2] = ratio;
        props[3] = ratio.mul(baseUsdtOfThirdToken.add(baseUsdtOfRltLp));
        props[4] = projectID;
        props[5] = 1; // level

        uint tokenId = bytes(customImageUrl).length > 0 ? didNFT.safeMintWithImage(msg.sender, props,did,customImageUrl) : didNFT.safeMint(msg.sender, props,did);

        emit Drawed(msg.sender,token, baseUsdtOfThirdToken, baseUsdtOfRltLp,tokenAmount, lpAmount,tokenId,props,block.timestamp);
    }

    function _getBaseUsdtOfRltLevel(uint _baseUsdtOfRlt) internal view returns(uint) {
        bool finded = false;
        for(uint i=0;i<4;i++){
            if(baseUsdtOfRlts[i] == _baseUsdtOfRlt){
                finded = true;
                return i;
            }
        }

        require(finded,"invalid baseUsdtOfRlt");
        return 0;
    }

    function _calcRatio(uint rand) internal view returns(uint) {
        uint base = 6;
        uint r = rand % 10000;
        uint incr = 0;
        uint sum = 0;
        for(uint i=0;i<5;i++){
            sum += boxProbabilityOf[i];
            if(r<sum){
                incr = i;
                break;
            }
        }

        return base + incr;
    }

    function _genRand() internal returns(uint){
        bytes32 salt = keccak256(abi.encodePacked(weth.balance));
        return uint(keccak256(abi.encode(nonce++,block.number,block.timestamp,salt))); 
    }

    function quoteTokenAmount(address swapFactory, address token,uint usdtAmount) public view returns(uint){
        if(token == usdtToken){
            return usdtAmount;
        }
        address pair = ISwapFactory(swapFactory).getPair(usdtToken,token);
        require(pair != address(0),"usdt/token pair is not exists");
        uint usdtReserve = 0;
        uint tokenReserve = 0;
        {
            (uint r0,uint r1,) = ISwapPair(pair).getReserves();
            (usdtReserve,tokenReserve) = ISwapPair(pair).token0() == usdtToken ? (r0,r1) : (r1,r0);
        }

        return _quote(usdtAmount, usdtReserve, tokenReserve);
    }

    function _quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'quote: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'quote: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function remainSupply() public view returns(uint){
        return totalSupply > totalSold ? totalSupply - totalSold : 0;
    }

    function infos(address account) external view returns(bool _isMinted, address[] memory _tokens, uint[] memory _thirdTokenAmounts,uint[] memory _baseUsdtOfRlts, uint[] memory _rltLpAmounts,address _rltLpToken){
        return infosPart(account,0, 100);
    }

    function infosPart(address account,uint thirdTokenStart,uint thirdTokenLength) public view returns(bool _isMinted, address[] memory _tokens, uint[] memory _thirdTokenAmounts,uint[] memory _baseUsdtOfRlts, uint[] memory _rltLpAmounts,address _rltLpToken){
        _isMinted = didNFT.mintedTokenOf(account) > 0;
        _rltLpToken = ISwapFactory(bitbyteSwapFactory).getPair(rltNew, usdtToken);
        
        uint len = allThirdTokensLength;
        uint realLen = allThirdTokensLength;
        if(thirdTokenLength == 0 || thirdTokenStart >= len){
            _tokens = new address[](0);
            _thirdTokenAmounts = new uint[](0);

        }else{
            realLen = thirdTokenStart + thirdTokenLength > len ? len - thirdTokenStart: thirdTokenLength;
            _tokens = new address[](realLen);
            _thirdTokenAmounts = new uint[](realLen);
            _baseUsdtOfRlts = new uint[](realLen);
            _rltLpAmounts = new uint[](realLen);            
            for(uint i=0;i<realLen;i++){
                address token = thirdTokens[thirdTokenStart+i];
                _tokens[i] = token;
                _thirdTokenAmounts[i] = quoteTokenAmount(quoteSwapFactoryOf[token], token, baseUsdtOfThirdToken);
            }
        }       

        _baseUsdtOfRlts = new uint[](4);
        _rltLpAmounts = new uint[](4);
        for(uint i=0;i<4;i++){
            uint baseUsdtOfRlt = baseUsdtOfRlts[i];
            _baseUsdtOfRlts[i] = baseUsdtOfRlt;

            _rltLpAmounts[i] = baseUsdtOfRlt == 0 ? 0 : SwapCalc.calcTokenToLiquidity(_rltLpToken, usdtToken, baseUsdtOfRlt);
        }
    }

    function setTotalSupply(uint _totalSupply) external onlyAdmin {
        require(_totalSupply >= totalSold,"total supply can not less than total sold");
        totalSupply = _totalSupply;
    }

    function addThirdToken(address token,address swapFactory) public onlyAdmin {
        require(token != address(0),"token can not be address 0");
        require(swapFactory != address(0),"swap factory can not be address 0");
        require(thirdTokenIndexOf[token] == 0,"token exists");
        require(token == usdtToken || ISwapFactory(swapFactory).getPair(token, usdtToken) != address(0),"can not find token/usdt pair in factory");
        uint len = allThirdTokensLength;
        thirdTokens[len] = token;
        thirdTokenIndexOf[token] = len + 1;
        allThirdTokensLength = len + 1;
        quoteSwapFactoryOf[token] = swapFactory;
    }

    function removeToken(address token) external onlyAdmin {
        require(token != address(0),"token can not be address 0");
        uint index = thirdTokenIndexOf[token];
        require(index > 0,"token not exists");

        uint realIndex = index - 1;
        uint len = allThirdTokensLength;
        if(realIndex != len - 1){
            address lastToken = thirdTokens[len - 1];
            thirdTokens[realIndex] = lastToken;
            thirdTokenIndexOf[lastToken] = realIndex + 1;
        }

        delete thirdTokens[len - 1];
        delete thirdTokenIndexOf[token];
        delete quoteSwapFactoryOf[token];

        allThirdTokensLength = allThirdTokensLength - 1;
    }

    function setBaseUsdtOfThirdToken(uint _baseUsdtOfThirdToken) external onlyAdmin {
        require(_baseUsdtOfThirdToken > 0,"_baseUsdtOfThirdToken can not be 0");
        baseUsdtOfThirdToken = _baseUsdtOfThirdToken;
    }

    function setBaseUsdtOfRlt(uint _level,uint _baseUsdtOfRlt) public onlyAdmin {
        require(_level < 4,"invalid level");
        baseUsdtOfRlts[_level] = _baseUsdtOfRlt;
    }
    
    function setBoxProbabilities(uint incr0,uint incr1,uint incr2,uint incr3,uint incr4) public onlyAdmin {
        require(incr0.add(incr1).add(incr2).add(incr3).add(incr4)==10000,"sum of probabilities must be 10000");
        boxProbabilityOf[0] = incr0;
        boxProbabilityOf[1] = incr1;
        boxProbabilityOf[2] = incr2;
        boxProbabilityOf[3] = incr3;
        boxProbabilityOf[4] = incr4;
    }

    function setMintBNBFee(uint _bnbFee) external onlyAdmin {
        mintBNBFee = _bnbFee;
    }

    function setTokenDiscountRate(uint _tokenDiscountRate) external onlyAdmin {
        require(_tokenDiscountRate <= 1e18,"_tokenDiscountRate can not greater than 1e18");
        tokenDiscountRate = _tokenDiscountRate;
    }

    function setLpDiscountRate(uint _lpDiscountRate) external onlyAdmin {
        require(_lpDiscountRate <= 1e18,"_lpDiscountRate can not greater than 1e18");
        lpDiscountRate = _lpDiscountRate;
    }
}
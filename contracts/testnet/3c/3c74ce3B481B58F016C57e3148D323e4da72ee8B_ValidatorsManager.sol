pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./EternalStorage.sol";
import "./Initializable.sol";
import "./Ownable.sol";
import "./Claimable.sol";

contract ValidatorsManager is EternalStorage, Ownable, Initializable, Claimable {
    using SafeMath for uint256;
    address private constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint256 private constant MAX_COUNT = 50;
    string  private constant COUNT = "COUNT";
    bytes32 private constant REQUIRED_SIGNATURES = keccak256("REQUIRED_SIGNATURES");
    string private constant VALIDATORS_LIST = "VALIDATORS_LIST";
    string private constant VALIDATORS_REWARDS = "VALIDATORS_REWARDS";


    fallback() external payable virtual {

    }

    receive() external payable virtual {

    }

    function initialize(
        uint256 requiredSignatures_,
        address validatorsOwner_,
        address[] memory validatorList_,
        address[] memory rewardsList_
    ) initializer public {
        require(validatorList_.length > 0);
        require(rewardsList_.length > 0);
        require(requiredSignatures_ > 0 && requiredSignatures_ <= validatorList_.length);
        require(validatorList_.length == validatorList_.length);
        for (uint256 i = 0; i < validatorList_.length; i++) {
            require(validatorList_[i] != address(0));
            _add(validatorList_[i], rewardsList_[i]);
            _setValidatorRewardAddress(validatorList_[i], rewardsList_[i]);
        }
        _setRequiredSignatures(requiredSignatures_);
        _transferOwnership(validatorsOwner_);
    }

    function list() public virtual view returns (address[] memory){
        address[] memory arrayList = new address[](count());
        uint256 _counter = 0;
        address next = getNext(F_ADDR);
        require(next != address(0));

        while (next != F_ADDR) {
            arrayList[_counter] = next;
            next = getNext(next);
            _counter++;
        }
        return arrayList;}

    function add(address validator_, address reward_) onlyOwner public virtual {
        _add(validator_, reward_);
    }

    function _add(address validator_, address reward_) internal {
        require(validator_ != address(0) && validator_ != F_ADDR, "invalid address");
        require(reward_ != address(0) && reward_ != F_ADDR, "invalid address");
        require(!isValidator(validator_), "exist address");
        address first = getNext(F_ADDR);
        _setNext(F_ADDR, validator_);
        if (first != address(0)) {
            _setNext(validator_, first);
        } else {
            _setNext(validator_, F_ADDR);
        }
        _setCount(count().add(1));
        _setValidatorRewardAddress(validator_, reward_);
    }


    function remove(address validator_) onlyOwner public virtual {
        require(count() > requiredSignatures());
        require(isValidator(validator_), "validator does not exist");
        address targetNext = getNext(validator_);
        address index = F_ADDR;
        address next = getNext(index);

        while (next != validator_) {
            index = next;
            next = getNext(index);
        }

        _setNext(index, targetNext);

        delete _addressStorage[keccak256(abi.encodePacked(VALIDATORS_LIST, validator_))];
        delete _addressStorage[keccak256(abi.encodePacked(VALIDATORS_REWARDS, validator_))];
        _setCount(count().sub(1));}

    function count() public virtual view returns (uint256){
        return _uintStorage[keccak256(abi.encodePacked(VALIDATORS_LIST, COUNT))];
    }

    function isValidator(address validator_) public virtual view returns (bool){
        return validator_ != F_ADDR && getNext(validator_) != address(0);
    }

    function getNext(address validator_) public virtual view returns (address){
        return _addressStorage[keccak256(abi.encodePacked(VALIDATORS_LIST, validator_))];
    }

    function getValidatorRewardAddress(address validator_) external view returns (address) {
        return _addressStorage[keccak256(abi.encodePacked(VALIDATORS_REWARDS, validator_))];
    }

    function isValidatorDuty(address validator_) public view returns (bool) {
        uint256 counter = 0;
        address next = getNext(F_ADDR);
        require(next != address(0));
        while (next != F_ADDR) {
            if (next == validator_) {
                return (block.timestamp % count() == counter);
            }
            next = getNext(next);
            counter++;
        }
        return false;
    }

    function _setValidatorRewardAddress(address validator_, address reward_) internal {
        _addressStorage[keccak256(abi.encodePacked(VALIDATORS_REWARDS, validator_))] = reward_;
    }

    function requiredSignatures() public view returns (uint256){
        return _uintStorage[REQUIRED_SIGNATURES];
    }

    function setRequiredSignatures(uint256 requiredSignatures_) onlyOwner public {
        _setRequiredSignatures(requiredSignatures_);
    }

    function _setRequiredSignatures(uint256 requiredSignatures_) internal {
        require(requiredSignatures_ <= count() && requiredSignatures_ > 0);
        _uintStorage[REQUIRED_SIGNATURES] = requiredSignatures_;
    }

    function _setNext(address prev_, address validator_) internal {
        _addressStorage[keccak256(abi.encodePacked(VALIDATORS_LIST, prev_))] = validator_;
    }

    function _setCount(uint256 count_) internal {
        require(count_ <= MAX_COUNT, "Exceed the maximum");
        _uintStorage[keccak256(abi.encodePacked(VALIDATORS_LIST, COUNT))] = count_;
    }

    function claimValues(address token_, address to_) public virtual onlyOwner {
        _claimValues(token_, to_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

contract EternalStorage {
    mapping(bytes32 => uint256) internal _uintStorage;
    mapping(bytes32 => string) internal _stringStorage;
    mapping(bytes32 => address) internal _addressStorage;
    mapping(bytes32 => bytes) internal _bytesStorage;
    mapping(bytes32 => bool) internal _boolStorage;
    mapping(bytes32 => int256) internal _intStorage;
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "./EternalStorage.sol";

abstract contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZABLE = keccak256("initializable");

    modifier initializer() {
        require(!_boolStorage[INITIALIZABLE], "Initializable: contract is already initialized");
        _boolStorage[INITIALIZABLE] = true;
        _;
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Context.sol";
import "./EternalStorage.sol";

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
abstract contract Ownable is EternalStorage, Context {

    bytes32 internal constant OWNER = keccak256("OWNER");

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _addressStorage[OWNER];
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _addressStorage[OWNER];
        _addressStorage[OWNER] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "./interfaces/IBridgeTokenWrapper.sol";

contract Claimable {

    modifier validAddress(address _to) {
        require(_to != address(0));
        _;
    }
    function _claimValues(address token_, address to_) internal validAddress(to_) {
        if (token_ == address(0)) {
            _claimNativeCoins(to_);
        } else {
            _claimErc20Tokens(token_, to_);
        }
    }

    function _claimNativeCoins(address to_) internal {
        uint256 value = address(this).balance;
        _sendValue(payable(to_), value);
    }

    function _claimErc20Tokens(address token_, address to_) internal {
        IBridgeTokenWrapper _IBridgeTokenWrapper = IBridgeTokenWrapper(token_);
        uint256 balance = _IBridgeTokenWrapper.balanceOf(address(this));
        _IBridgeTokenWrapper.transfer(to_, balance);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface IBridgeTokenWrapper {
    function withdrawTo(address receiver_, uint256 amount_) external returns (bool);

    function decimals() external view returns (uint8);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}
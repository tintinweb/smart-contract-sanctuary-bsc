// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./EternalStorage.sol";
import "./Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ConvertMock.sol";
import "./interfaces/IConvert.sol";
import "./Claimable.sol";

contract Convert is EternalStorage, Initializable, IConvert, ConvertMock, Claimable {
    using SafeMath for uint256;
    bytes32 internal constant CALLER = keccak256("ConvertCaller");
    bytes32 internal constant OWNER = keccak256("ConvertOwner");
    bytes32 internal constant PROXY_OWNER = keccak256("ProxyOwner");

    event Charge(address indexed charger, uint256 value);

    function initialize(address _caller, address _owner) public initializer {
        require(_caller != address(0), "Invalid caller address");
        require(_owner != address(0), "Invalid owner address");
        _addressStorage[CALLER] = _caller;
        _addressStorage[OWNER] = _owner;
    }

    fallback() external payable virtual {

    }

    receive() external payable virtual {

    }

    modifier onlyCaller() {
        require(msg.sender == _addressStorage[CALLER], "You don't have permission to call");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _addressStorage[OWNER], "You don't have permission to call");
        _;
    }

    function getCaller() public view returns (address) {
        return _addressStorage[CALLER];
    }

    function changeCaller(address _caller) public onlyOwner {
        require(_caller != address(0), "Caller verify failed");
        _addressStorage[CALLER] = _caller;
    }

    function getOwner() public view returns (address) {
        return _addressStorage[OWNER];
    }

    function setOwner(address _owner) public onlyOwner {
        require(_owner != address(0), "Owner verify failed");
        _addressStorage[OWNER] = _owner;
    }

    function convertNew(address _miner, uint256 _amount) public override onlyCaller {
        _addConvert(_miner, _amount);
    }

    function _addConvert(address _miner, uint256 _amount) private {
        require(_miner != address(0), "Miner verify failed");
        require(!_convertMiner(_miner), "Node is converted");
        _convertNew(_miner, _amount);
    }

    function convertInfo(address _miner) public override view returns (ConvertInfo memory) {
        return _convertInfo(_miner);
    }

    function releasableAmount(address _miner) public override view returns (uint256) {
        require(_miner != address(0), "Miner verify failed");
        ConvertInfo memory convert = _convertInfo(_miner);
        if (convert.released) {
            return 0;
        }
        return convert.amount;
    }

    function release(address _miner) public override {
        require(_miner != address(0), "Miner verify failed");
        uint256 amount = releasableAmount(_miner);
        (bool success,) = _miner.call{value : amount}(new bytes(0));
        require(success, "Transfer failed");
        _release(_miner);
    }

    function claimValues(address token_, address to_) public virtual onlyOwner {
        require(token_ != address(0));
        _claimValues(token_, to_);
    }

    function charge() payable public virtual {
        require(msg.value > 0, "exceeds pay amount");
        emit Charge(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) payable public virtual onlyOwner {
        (bool success,) = address(this).call{value : _amount}(new bytes(0));
        require(success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract EternalStorage {
    mapping(bytes32 => uint256) internal _uintStorage;
    mapping(bytes32 => string) internal _stringStorage;
    mapping(bytes32 => address) internal _addressStorage;
    mapping(bytes32 => bytes) internal _bytesStorage;
    mapping(bytes32 => bool) internal _boolStorage;
    mapping(bytes32 => int256) internal _intStorage;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EternalStorage.sol";
import "./interfaces/IConvert.sol";

contract ConvertMock is EternalStorage {
    string internal constant CONVERT_MINER = "convertMiner";
    string internal constant CONVERT_AMOUNT = "convertAmount";
    string internal constant CONVERT_CREATED_AT = "convertCreatedAt";
    string internal constant CONVERT_RELEASED = "convertReleased";

    function _convertNew(address _miner, uint256 _amount) internal {
        bytes32 key = keccak256(abi.encode(_miner));
        _addressStorage[keccak256(abi.encodePacked(CONVERT_MINER, key))] = _miner;
        _uintStorage[keccak256(abi.encodePacked(CONVERT_AMOUNT, key))] = _amount;
        _uintStorage[keccak256(abi.encodePacked(CONVERT_CREATED_AT, key))] = block.timestamp;
        _boolStorage[keccak256(abi.encodePacked(CONVERT_RELEASED, key))] = false;
    }

    function _convertInfo(address _miner) internal view returns (ConvertInfo memory) {
        bytes32 key = keccak256(abi.encode(_miner));
        return ConvertInfo(
            _addressStorage[keccak256(abi.encodePacked(CONVERT_MINER, key))],
            _uintStorage[keccak256(abi.encodePacked(CONVERT_AMOUNT, key))],
            _uintStorage[keccak256(abi.encodePacked(CONVERT_CREATED_AT, key))],
            _boolStorage[keccak256(abi.encodePacked(CONVERT_RELEASED, key))]
        );
    }

    function _convertMiner(address _miner) internal view returns (bool) {
        ConvertInfo memory convert = _convertInfo(_miner);
        if (convert.miner == address(0)) {
            return false;
        }
        return true;
    }

    function _release(address _miner) internal {
        bytes32 key = keccak256(abi.encode(_miner));
        _boolStorage[keccak256(abi.encodePacked(CONVERT_RELEASED, key))] = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./EternalStorage.sol";

abstract contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZED = keccak256("initialized");
    bytes32 internal constant INITIALIZING = keccak256("initializing");

    event Initialized(uint256 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing();
        require(
            (isTopLevelCall && _initialized() < 1) || (!(address(this).code.length > 0) && _initialized() == 1),
            "Initializable: contract is already initialized"
        );
        _setInitialized(1);
        if (isTopLevelCall) {
            _setInitializing(true);
        }
        _;
        if (isTopLevelCall) {
            _setInitializing(false);
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint256 version) {
        require(!_initializing() && _initialized() < version, "Initializable: contract is already initialized");
        _setInitialized(version);
        _setInitializing(true);
        _;
        _setInitializing(false);
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing(), "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing(), "Initializable: contract is initializing");
        if (_initialized() < type(uint256).max) {
            _setInitialized(type(uint256).max);
            emit Initialized(type(uint256).max);
        }
    }

    function _initialized() internal view returns (uint256) {
        return _uintStorage[INITIALIZED];
    }

    function _setInitialized(uint256 initialized_) internal {
        _uintStorage[INITIALIZED] = initialized_;
    }

    function _initializing() internal view returns (bool) {
        return _boolStorage[INITIALIZING];
    }

    function _setInitializing(bool status_) internal {
        _boolStorage[INITIALIZING] = status_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IERC20.sol";

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
        IERC20 _ERC20 = IERC20(token_);
        uint256 balance = _ERC20.balanceOf(address(this));
        _ERC20.transfer(to_, balance);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

    struct ConvertInfo {
        address miner;
        uint256 amount;
        uint256 createdAt;
        bool released;
    }

interface IConvert {
    function convertNew(address _miner, uint256 _amount) external;

    function convertInfo(address _miner) external view returns (ConvertInfo memory);

    function releasableAmount(address _miner) external view returns (uint256);

    function release(address _miner) external;
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
pragma solidity ^0.8.2;

interface IERC20 {
    function decimals() external view returns (uint8);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}
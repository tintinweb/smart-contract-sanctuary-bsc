// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPool {
    function deposit() external payable;

    function totalStaked() external view returns (uint256);

    function getInvalidTokens(address to_, address token_) external;

    function togglePause() external;

    function transferOwnership(address newOwner) external;

    function renounceOwnership() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../libraries/math/SafeMath.sol";
import "./interfaces/IPool.sol";

contract PoolTimeLock {
    using SafeMath for uint256;

    uint256 public constant MAX_BUFFER = 5 days;

    uint256 public buffer;
    address public admin;

    mapping(bytes32 => uint256) public pendingActions;

    event SignalSetAdmin(address newAdmin, bytes32 action);
    event SignalGetInvalidTokens(
        address pool,
        address to,
        address token,
        bytes32 action
    );
    event SignalTogglePause(address pool, bytes32 action);
    event SignalRenounceOwnership(address pool, bytes32 action);
    event SignalTransferOwnership(
        address pool,
        address newOwner,
        bytes32 action
    );
    event SignalPendingAction(bytes32 action);
    event ClearAction(bytes32 action);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock: forbidden");
        _;
    }

    constructor(address _admin) public {
        admin = _admin;
        buffer = 48 hours;
    }

    function setBuffer(uint256 _buffer) external onlyAdmin {
        require(_buffer <= MAX_BUFFER, "Timelock: invalid _buffer");
        require(_buffer > buffer, "Timelock: buffer cannot be decreased");
        buffer = _buffer;
    }

    function signalSetAdmin(address _admin) external onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("setAdmin", _admin));
        _setPendingAction(action);
        emit SignalSetAdmin(_admin, action);
    }

    function setAdmin(address _admin) external onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("setAdmin", _admin));
        _validateAction(action);
        _clearAction(action);
        admin = _admin;
    }

    function signalGetInvalidTokens(
        address _pool,
        address _to,
        address _token
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("getInvalidTokens", _pool, _to, _token)
        );
        _setPendingAction(action);
        emit SignalGetInvalidTokens(_pool, _to, _token, action);
    }

    function getInvalidTokens(
        address _pool,
        address _to,
        address _token
    ) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("getInvalidTokens", _pool, _to, _token)
        );
        _validateAction(action);
        _clearAction(action);
        IPool(_pool).getInvalidTokens(_to, _token);
    }

    function signalTogglePause(address _pool) external onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("togglePause", _pool));
        _setPendingAction(action);
        emit SignalTogglePause(_pool, action);
    }

    function togglePause(address _pool) external onlyAdmin {
        bytes32 action = keccak256(abi.encodePacked("togglePause", _pool));
        _validateAction(action);
        _clearAction(action);
        IPool(_pool).togglePause();
    }

    function signalRenounceOwnership(address _pool) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("renounceOwnership", _pool)
        );
        _setPendingAction(action);
        emit SignalRenounceOwnership(_pool, action);
    }

    function renounceOwnership(address _pool) external onlyAdmin {
        bytes32 action = keccak256(
            abi.encodePacked("renounceOwnership", _pool)
        );
        _validateAction(action);
        _clearAction(action);
        IPool(_pool).renounceOwnership();
    }

    function signalTransferOwnership(address _pool, address _newOwner)
        external
        onlyAdmin
    {
        bytes32 action = keccak256(
            abi.encodePacked("transferOwnership", _pool, _newOwner)
        );
        _setPendingAction(action);
        emit SignalTransferOwnership(_pool, _newOwner, action);
    }

    function transferOwnership(address _pool, address _newOwner)
        external
        onlyAdmin
    {
        bytes32 action = keccak256(
            abi.encodePacked("transferOwnership", _pool, _newOwner)
        );
        _validateAction(action);
        _clearAction(action);
        IPool(_pool).transferOwnership(_newOwner);
    }

    function cancelAction(bytes32 _action) external onlyAdmin {
        _clearAction(_action);
    }

    function _setPendingAction(bytes32 _action) private {
        require(
            pendingActions[_action] == 0,
            "Timelock: action already signalled"
        );
        pendingActions[_action] = block.timestamp.add(buffer);
        emit SignalPendingAction(_action);
    }

    function _validateAction(bytes32 _action) private view {
        require(pendingActions[_action] != 0, "Timelock: action not signalled");
        require(
            pendingActions[_action] < block.timestamp,
            "Timelock: action time not yet passed"
        );
    }

    function _clearAction(bytes32 _action) private {
        require(pendingActions[_action] != 0, "Timelock: invalid _action");
        delete pendingActions[_action];
        emit ClearAction(_action);
    }
}
// SPDX-License-Identifier: GNU General Public License v3.0 or later

pragma solidity ^0.7.4;
pragma abicoder v2;

import "./Common/Ownable.sol";
import "./IPredictionPool.sol";
import "./IOracleEventManager.sol";
import "./SafeMath.sol";

contract FrontendStates is Ownable {
    using SafeMath for uint256;

    constructor(
        address oracleEventManagerAddress
    ) {
        _oracleEventManager = IOracleEventManager(oracleEventManagerAddress);
    }

    event OracleEventManagerChanged(address oracleEventManagerAddress);

    IOracleEventManager public _oracleEventManager;

    function allowPrepare() public view returns (bool) {
        IPredictionPool _predictionPool = IPredictionPool(
            _oracleEventManager._predictionPool.address
        );

        if (_predictionPool._eventStarted() == true) {
            return false;
        }

        IOracleEventManager.GameEvent memory gameEvent = _oracleEventManager._gameEvent();

        uint256 eventStartTimeExpected = gameEvent.eventStartTimeExpected;

        uint256 _checkPeriod = _oracleEventManager._checkPeriod();

        uint256 createdAt = gameEvent.createdAt;

        uint256 x = eventStartTimeExpected.add(_checkPeriod.div(2));

        if ((block.timestamp > x) || (createdAt == 0)) {
            return true;
        } else {
            return false;
        }
    }

    function allowStart() public view returns (bool) {
        IPredictionPool _predictionPool = IPredictionPool(
            _oracleEventManager._predictionPool.address
        );

        if (_predictionPool._eventStarted() == true) {
            return false;
        }

        uint256 nowTime = block.timestamp;

        IOracleEventManager.GameEvent memory gameEvent = _oracleEventManager._gameEvent();

        uint256 eventStartTimeExpected = gameEvent.eventStartTimeExpected;

        uint256 _checkPeriod = _oracleEventManager._checkPeriod();

        uint256 x = eventStartTimeExpected.sub(_checkPeriod.div(2));
        uint256 y = eventStartTimeExpected.add(_checkPeriod.div(2));

        uint256 startedAt = gameEvent.startedAt;

        if (
            (startedAt != 0) ||
            (eventStartTimeExpected == 0) ||
            (nowTime <= x)
        ) {
            return false;
        }

        if ((gameEvent.createdAt < nowTime) && (nowTime < y)) {
            return true;
        } else {
            return false;
        }
    }

    function allowFinalize() public view returns (bool) {
        IPredictionPool _predictionPool = IPredictionPool(
            _oracleEventManager._predictionPool.address
        );

        if (_predictionPool._eventStarted() == false) {
            return false;
        }

        IOracleEventManager.GameEvent memory gameEvent = _oracleEventManager._gameEvent();

        if (gameEvent.startedAt == 0) {
            return false;
        }

        if (
            (gameEvent.startedAt != 0) &&
            (block.timestamp >= gameEvent.eventEndTimeExpected)
        ) {
            if (gameEvent.endedAt == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function changeOracleEventManagerAddress(address _oracleEventManagerAddress)
        public
        onlyOwner
    {
        require(
            _oracleEventManagerAddress != address(0),
            "New pool address should be not null"
        );
        _oracleEventManager = IOracleEventManager(_oracleEventManagerAddress);
        emit OracleEventManagerChanged(_oracleEventManagerAddress);
    }
}

pragma solidity >=0.5.16;
// "SPDX-License-Identifier: Apache License 2.0"


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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.7.4;

// "SPDX-License-Identifier: MIT"

interface IPredictionPool {
    function buyWhite(uint256 maxPrice, uint256 payment) external;

    function buyBlack(uint256 maxPrice, uint256 payment) external;

    function sellWhite(uint256 tokensAmount, uint256 minPrice) external;

    function sellBlack(uint256 tokensAmount, uint256 minPrice) external;

    function _whitePrice() external returns (uint256);

    function _blackPrice() external returns (uint256);

    function _whiteToken() external returns (address);

    function _blackToken() external returns (address);

    function _thisCollateralization() external returns (address);

    function _eventStarted() external view returns (bool);

    // solhint-disable-next-line func-name-mixedcase
    function FEE() external returns (uint256);
}

pragma solidity ^0.7.4;
pragma abicoder v2;

// "SPDX-License-Identifier: MIT"

interface IOracleEventManager {
    struct GameEvent {
        uint256 createdAt;
        uint256 startedAt;
        uint256 endedAt;
        uint256 priceChangePart; // in percent
        uint256 eventStartTimeExpected; // in seconds since 1970
        uint256 eventEndTimeExpected; // in seconds since 1970
        string blackTeam;
        string whiteTeam;
        string eventType;
        string eventSeries;
        string eventName;
        uint256 eventId;
    }

    function _predictionPool() external returns (address);

    function _eventLifeCycle() external returns (address);

    function _gameEvent() external view returns (GameEvent memory);

    function _checkPeriod() external view returns (uint256);
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
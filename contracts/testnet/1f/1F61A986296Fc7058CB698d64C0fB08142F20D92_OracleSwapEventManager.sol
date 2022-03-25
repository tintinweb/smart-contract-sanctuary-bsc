// SPDX-License-Identifier: GNU General Public License v3.0 or later

pragma solidity ^0.7.4;

import "./OracleEventManager.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ERC20Detailed.sol";
import "./IPancake.sol";

contract OracleSwapEventManager is OracleEventManager {
    // address public _pairAddress;
    IPancakePair public _pair;
    uint8 public _primaryToken;
    address internal tokenA;
    address internal tokenB;
    string internal aTokenSym;
    string internal bTokenSym;

    int8 internal lastGameResult = 0;

    struct RoundData {
        int256 price;
        uint256 providerTimeStamp;
    }

    RoundData public _startRoundData;
    RoundData public _endRoundData;

    event LatestRound(int256 price, uint256 timeStamp);
    event PairAddressChanged(address);

    constructor(
        address eventLifeCycleAddress,
        address predictionPoolAddress,
        uint256 priceChangePart,
        uint256 eventStartTimeOutExpected,
        uint256 eventEndTimeOutExpected
    )
        OracleEventManager(
            eventLifeCycleAddress,
            predictionPoolAddress,
            priceChangePart,
            eventStartTimeOutExpected,
            eventEndTimeOutExpected
        )
    {
        _config._eventType = string("Crypto");
    }

    function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // solhint-disable-next-line var-name-mixedcase
        uint256 BONE = 10**18;
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint256 c2 = c1 / b;
        return c2;
    }

    function getCurrentPrice()
        public
        view
        returns (int256 price, uint256 providerTimeStamp)
    {
        (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        ) = _pair.getReserves();

        if (_primaryToken == 0) {
            price = int256(bdiv(_reserve1, _reserve0));
        } else {
            price = int256(bdiv(_reserve0, _reserve1));
        }

        providerTimeStamp = _blockTimestampLast;
    }

    function getExternalEventStartData()
        internal
        override
        returns (string memory eventName)
    {
        uint256 providerTimeStamp = 0;
        int256 price = 0;

        (price, providerTimeStamp) = getCurrentPrice();

        emit LatestRound(price, providerTimeStamp);

        eventName = string(
            abi.encodePacked(
                _config._eventSeries,
                " ",
                toString(uint256(price))
            )
        );
        _startRoundData.price = price;
    }

    function getExternalEventEndData() internal override {
        uint256 providerTimeStamp = 0;
        int256 price = 0;

        (price, providerTimeStamp) = getCurrentPrice();

        emit LatestRound(price, providerTimeStamp);
        _endRoundData.price = price;
    }

    function calculateEventResult()
        internal
        view
        override
        returns (int8 gameResult)
    {
        gameResult = 0;

        if (_primaryToken == 0) {
            if (_startRoundData.price < _endRoundData.price) {
                if (_lastEventId % 2 == 0) {
                    gameResult = 1;
                } else {
                    gameResult = -1;
                }
            }
            if (_startRoundData.price > _endRoundData.price) {
                if (_lastEventId % 2 == 0) {
                    gameResult = -1;
                } else {
                    gameResult = 1;
                }
            }
        } else {
            if (_startRoundData.price > _endRoundData.price) {
                if (_lastEventId % 2 == 0) {
                    gameResult = 1;
                } else {
                    gameResult = -1;
                }
            }
            if (_startRoundData.price < _endRoundData.price) {
                if (_lastEventId % 2 == 0) {
                    gameResult = -1;
                } else {
                    gameResult = 1;
                }
            }
        }
    }

    function finalizeEvent() external override {
        require(_predictionPool._eventStarted() == true, "Event not started");

        GameEvent memory gameEvent = _gameEvent;

        require((gameEvent.startedAt != 0), "Event not started");
        require(
            (gameEvent.startedAt != 0) &&
                (block.timestamp >= gameEvent.eventEndTimeExpected),
            "Too early end"
        );

        if (gameEvent.endedAt == 0) {
            getExternalEventEndData();
            lastGameResult = calculateEventResult();

            gameEvent.endedAt = block.number;
        } else {
            require(
                (gameEvent.endedAt < block.number),
                "Finalize event in next block"
            ); // May be no need

            getExternalEventEndData();

            // Black won -1, 1 means white-won, 0 means draw.
            int8 gameResult = calculateEventResult();

            if (lastGameResult != gameResult) {
                lastGameResult = 0;
            }
            _eventLifeCycle.endEvent(lastGameResult);

            gameEvent.endedAt = block.timestamp;

            emit AppEnded(
                gameEvent.endedAt,
                gameEvent.eventEndTimeExpected,
                lastGameResult
            );

            _config._eventName = _config._eventSeries;
        }
        _gameEvent = gameEvent;
    }

    function addDex(address pairAddress, uint8 primaryToken) public onlyOwner {
        require(
            (primaryToken == 0) || (primaryToken == 1),
            "Primary Token must equal 0 or 1"
        );
        require(
            pairAddress != address(0),
            "New pair address should be not null"
        );

        _pair = IPancakePair(pairAddress);
        _primaryToken = primaryToken;

        if (_primaryToken == 0) {
            tokenA = _pair.token0();
            tokenB = _pair.token1();
        } else {
            tokenA = _pair.token1();
            tokenB = _pair.token0();
        }
        OracleConfig memory config = _config;

        aTokenSym = ERC20Detailed(tokenA).symbol();
        bTokenSym = ERC20Detailed(tokenB).symbol();
        config._downTeam = string(abi.encodePacked(aTokenSym, "-DOWN"));
        config._upTeam = string(abi.encodePacked(aTokenSym, "-UP"));
        config._eventName = string(abi.encodePacked(aTokenSym, "-", bTokenSym));
        config._eventSeries = string(
            abi.encodePacked(aTokenSym, "-", bTokenSym)
        );

        _config = config;
        emit PairAddressChanged(pairAddress);
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

// SPDX-License-Identifier: GNU General Public License v3.0 or later

pragma solidity ^0.7.4;

import "./Common/Ownable.sol";
import "./IEventLifeCycle.sol";
import "./IPredictionPool.sol";
import "./SafeMath.sol";

contract OracleEventManager is Ownable {
    using SafeMath for uint256;

    constructor(
        address eventLifeCycleAddress,
        address predictionPoolAddress,
        uint256 priceChangePart,
        uint256 eventStartTimeOutExpected,
        uint256 eventEndTimeOutExpected
    ) {
        _config._eventStartTimeOutExpected = eventStartTimeOutExpected;
        _config._eventEndTimeOutExpected = eventEndTimeOutExpected;
        _config._priceChangePart = priceChangePart;
        _eventLifeCycle = IEventLifeCycle(eventLifeCycleAddress);
        _predictionPool = IPredictionPool(predictionPoolAddress);
    }

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

    IEventLifeCycle public _eventLifeCycle;
    IPredictionPool public _predictionPool;

    struct OracleConfig {
        uint256 _priceChangePart;
        string _eventName;
        string _downTeam;
        string _upTeam;
        string _eventType;
        string _eventSeries;
        uint256 _eventStartTimeOutExpected;
        uint256 _eventEndTimeOutExpected;
    }

    OracleConfig public _config;

    uint256 public _lastEventId = 1;
    uint256 public _checkPeriod = 60; // in seconds

    GameEvent internal _gameEvent;
    // GameEvent public _ongoingEvent;

    // event EventLifeCycleAddressChanged(address);
    // event PredictionPoolAddressChanged(address);
    // event CheckPeriodChanged(uint256);

    event PrepareEvent(
        uint256 createdAt,
        uint256 priceChangePercent,
        uint256 eventStartTimeExpected,
        uint256 eventEndTimeExpected,
        string blackTeam,
        string whiteTeam,
        string eventType,
        string eventSeries,
        string eventName,
        uint256 eventId
    );

    event AppStarted(
        uint256 nowTime,
        uint256 eventStartTimeExpected,
        uint256 startedAt,
        string eventName
    );

    event ConfigChanged(string optionName, uint256 newValue);

    event AppEnded(uint256 nowTime, uint256 eventEndTimeExpected, int8 result);

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }

    function prepareEvent() external {
        require(_predictionPool._eventStarted() == false, "PP closed");

        GameEvent memory gameEvent = _gameEvent;
        OracleConfig memory config = _config;

        if (
            (block.timestamp >
                gameEvent.eventStartTimeExpected.add(_checkPeriod.div(2))) ||
            (gameEvent.createdAt == 0)
        ) {
            uint256 eventStartTimeExpected = block.timestamp.add(
                config._eventStartTimeOutExpected
            );
            uint256 eventEndTimeExpected = eventStartTimeExpected.add(
                config._eventEndTimeOutExpected
            );

            string memory _blackTeam;
            string memory _whiteTeam;

            if (_lastEventId % 2 == 0) {
                _blackTeam = config._upTeam;
                _whiteTeam = config._downTeam;
            } else {
                _blackTeam = config._downTeam;
                _whiteTeam = config._upTeam;
            }

            gameEvent = GameEvent({
                createdAt: block.timestamp,
                startedAt: 0,
                endedAt: 0,
                priceChangePart: config._priceChangePart, // timestamp
                eventStartTimeExpected: eventStartTimeExpected, // in seconds since 1970
                eventEndTimeExpected: eventEndTimeExpected, // in seconds since 1970
                blackTeam: _blackTeam,
                whiteTeam: _whiteTeam,
                eventType: config._eventType,
                eventSeries: config._eventSeries,
                eventName: config._eventName,
                eventId: _lastEventId
            });

            _eventLifeCycle.addNewEvent(
                gameEvent.priceChangePart, // uint256 priceChangePart_
                gameEvent.eventStartTimeExpected, // uint256 eventStartTimeExpected_
                gameEvent.eventEndTimeExpected, // uint256 eventEndTimeExpected_
                gameEvent.blackTeam, // string calldata blackTeam_
                gameEvent.whiteTeam, // string calldata whiteTeam_
                gameEvent.eventType, // string calldata eventType_
                gameEvent.eventSeries, // string calldata eventSeries_
                gameEvent.eventName, // string calldata eventName_
                gameEvent.eventId
            );

            // ===================== FIX: Позже можно удалить, добавлено для тестов ================================
            emit PrepareEvent(
                gameEvent.createdAt,
                gameEvent.priceChangePart,
                gameEvent.eventStartTimeExpected,
                gameEvent.eventEndTimeExpected,
                gameEvent.blackTeam,
                gameEvent.whiteTeam,
                gameEvent.eventType,
                gameEvent.eventSeries,
                gameEvent.eventName,
                gameEvent.eventId
            );
            // ===================== FIX: Позже можно удалить, добавлено для тестов ================================

            _lastEventId = _lastEventId.add(1);
            _gameEvent = gameEvent;
        } else {
            revert("Already prepared event");
        }
    }

    function calculateEventResult()
        internal
        view
        virtual
        returns (int8 gameResult)
    {
        gameResult = 0;
    }

    function getExternalEventStartData()
        internal
        virtual
        returns (string memory eventName)
    {
        return "";
    }

    function getExternalEventEndData() internal virtual {
        return;
    }

    modifier CheckStart() {
        require(
            _predictionPool._eventStarted() == false,
            "Event already started"
        );

        GameEvent memory gameEvent = _gameEvent;

        require((gameEvent.startedAt == 0), "Event already started");
        require((gameEvent.eventStartTimeExpected != 0), "Not prepared event");

        require(
            block.timestamp >
                gameEvent.eventStartTimeExpected.sub(_checkPeriod.div(2)),
            "Too early start"
        );

        require(
            (gameEvent.createdAt < block.timestamp) &&
                (block.timestamp <
                    gameEvent.eventStartTimeExpected.add(_checkPeriod.div(2))),
            "Too late to start"
        );

        gameEvent.eventName = getExternalEventStartData();

        _;
        gameEvent.startedAt = block.timestamp;

        emit AppStarted(
            block.timestamp,
            gameEvent.eventStartTimeExpected,
            gameEvent.startedAt,
            gameEvent.eventName
        );

        _gameEvent = gameEvent;
    }

    function startEvent() external CheckStart {
        _eventLifeCycle.startEvent();
    }

    function addAndStartEvent() external CheckStart {
        // ???????????????????????????????????? _gameEvent
        _eventLifeCycle.addAndStartEvent(
            _gameEvent.priceChangePart, // in 0.0001 parts percent of a percent dose
            _gameEvent.eventStartTimeExpected,
            _gameEvent.eventEndTimeExpected,
            _gameEvent.blackTeam,
            _gameEvent.whiteTeam,
            _gameEvent.eventType,
            _gameEvent.eventSeries,
            _gameEvent.eventName,
            _gameEvent.eventId
        );
    }

    function finalizeEvent() external virtual {
        require(_predictionPool._eventStarted() == true, "Event not started");

        GameEvent memory gameEvent = _gameEvent;

        require((gameEvent.startedAt != 0), "Event not started");
        require(
            (gameEvent.startedAt != 0) &&
                (block.timestamp >= gameEvent.eventEndTimeExpected),
            "Too early end"
        );
        require(gameEvent.endedAt == 0, "Event already finalazed");

        getExternalEventEndData();

        // endEvent();
        // Black won -1, 1 means white-won, 0 means draw.
        int8 gameResult = 0;

        gameResult = calculateEventResult();
        _eventLifeCycle.endEvent(gameResult);

        gameEvent.endedAt = block.timestamp;

        emit AppEnded(
            gameEvent.endedAt,
            gameEvent.eventEndTimeExpected,
            gameResult
        );

        _config._eventName = _config._eventSeries;
        _gameEvent = gameEvent;
    }

    function editPriceChangePart(uint256 newPriceChangePart) public onlyOwner {
        require(
            newPriceChangePart != 0,
            "New price change part should be not null"
        );
        _config._priceChangePart = newPriceChangePart;

        emit ConfigChanged("PriceChangePart", newPriceChangePart);
    }

    function editStartTimeOut(uint256 eventStartTimeOutExpected)
        public
        onlyOwner
    {
        require(
            (eventStartTimeOutExpected != 0) &&
                (eventStartTimeOutExpected < 60),
            "New start timeout should be not null or least than 1 minute"
        );
        _config._eventStartTimeOutExpected = eventStartTimeOutExpected;

        emit ConfigChanged(
            "EventStartTimeOutExpected",
            eventStartTimeOutExpected
        );
    }

    function editEndTimeOut(uint256 eventEndTimeOutExpected) public onlyOwner {
        require(
            (eventEndTimeOutExpected != 0) && (eventEndTimeOutExpected < 60),
            "New end timeout should be not null or least than 1 minute"
        );
        _config._eventEndTimeOutExpected = eventEndTimeOutExpected;

        emit ConfigChanged("EventEndTimeOutExpected", eventEndTimeOutExpected);
    }

    function canPrepare() public view returns (bool) {
        if (_predictionPool._eventStarted() == true) {
            return false;
        }

        GameEvent memory gameEvent = _gameEvent;

        if (
            (block.timestamp >
                gameEvent.eventStartTimeExpected.add(_checkPeriod.div(2))) ||
            (gameEvent.createdAt == 0)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function canStart() public view returns (bool) {
        if (_predictionPool._eventStarted() == true) {
            return false;
        }

        uint256 nowTime = block.timestamp;

        GameEvent memory gameEvent = _gameEvent;

        if (
            (gameEvent.startedAt != 0) ||
            (gameEvent.eventStartTimeExpected == 0) ||
            (nowTime <=
                gameEvent.eventStartTimeExpected.sub(_checkPeriod.div(2)))
        ) {
            return false;
        }

        if (
            (gameEvent.createdAt < nowTime) &&
            (nowTime <
                gameEvent.eventStartTimeExpected.add(_checkPeriod.div(2)))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function canFinalize() public view returns (bool) {
        if (_predictionPool._eventStarted() == false) {
            return false;
        }

        GameEvent memory gameEvent = _gameEvent;

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

// "SPDX-License-Identifier: MIT"

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function factory() external pure returns (address);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external view returns (address);
}

pragma solidity ^0.7.4;

// "SPDX-License-Identifier: MIT"
interface IEventLifeCycle {
    function addNewEvent(
        uint256 priceChangePart_,
        uint256 eventStartTimeExpected_,
        uint256 eventEndTimeExpected_,
        string calldata blackTeam_,
        string calldata whiteTeam_,
        string calldata eventType_,
        string calldata eventSeries_,
        string calldata eventName_,
        uint256 eventId_
    ) external;

    function addAndStartEvent(
        uint256 priceChangePart_, // in 0.0001 parts percent of a percent dose
        uint256 eventStartTimeExpected_,
        uint256 eventEndTimeExpected_,
        string calldata blackTeam_,
        string calldata whiteTeam_,
        string calldata eventType_,
        string calldata eventSeries_,
        string calldata eventName_,
        uint256 eventId_
    ) external returns (uint256);

    function startEvent() external returns (uint256);

    function endEvent(int8 _result) external;
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./Common/IERC20.sol";

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    } 

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
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

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: MIT"

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
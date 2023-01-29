// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./interfaces/IVaultPriceFeedV2.sol";
// import "../oracle/interfaces/IPriceFeed.sol";
// import "../oracle/interfaces/ISecondaryPriceFeed.sol";
// import "../oracle/interfaces/IChainlinkFlags.sol";
import "../oracle/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IVaultPriceFeedV3 {
    function adjustmentBasisPoints(address _token) external view returns (uint256);
    function isAdjustmentAdditive(address _token) external view returns (bool);
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external;
    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external;
    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external;
    function setPriceSampleSpace(uint256 _priceSampleSpace) external;
    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external;
    function getPrice(address _token, bool _maximise,bool,bool) external view returns (uint256);
    function getOrigPrice(address _token) external view returns (uint256);
    
    function getPrimaryPrice(address _token, bool _maximise) external view returns (uint256, bool);
}


interface IPositionRouter {
    function increasePositionRequestKeysStart() external returns (uint256);

    function decreasePositionRequestKeysStart() external returns (uint256);

    function executeIncreasePositions(
        uint256 _count,
        address payable _executionFeeReceiver
    ) external;

    function executeDecreasePositions(
        uint256 _count,
        address payable _executionFeeReceiver
    ) external;

    function getRequestQueueLengths()
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        uint256
    );
}

pragma solidity ^0.8.0;

contract VaultPriceFeedV2Fast is IVaultPriceFeedV3, Ownable {
    using SafeMath for uint256;

    uint256 public constant PRICE_PRECISION = 10 ** 30;
    uint256 public constant ONE_USD = PRICE_PRECISION;
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant MAX_SPREAD_BASIS_POINTS = 50;
    uint256 public constant MAX_ADJUSTMENT_INTERVAL = 2 hours;
    uint256 public constant MAX_ADJUSTMENT_BASIS_POINTS = 20;

    uint256 public priceSafetyGap = 60 minutes;

    uint256 public priceAdjPer10Sec = 1;
    uint256 public priceVariance = 100;
    uint256 public constant PRICE_VARIANCE_PRECISION = 10000;

    // Identifier of the Sequencer offline flag on the Flags contract
    // address constant private FLAG_ARBITRUM_SEQ_OFFLINE = address(bytes20(bytes32(uint256(keccak256("chainlink.flags.arbitrum-seq-offline")) - 1)));

    uint256 public priceSampleSpace = 1;
    uint256 public maxStrictPriceDeviation = 0;
    uint256 public spreadThresholdBasisPoints = 30;

    uint8 public priceMethod = 3;

    //token config.
    mapping(address => uint256) public chainlinkPrecision;
    mapping(address => address) public chainlinkAddress;
    mapping(address => uint256) public spreadBasisPoints;
    // Chainlink can return prices for stablecoins
    // that differs from 1 USD by a larger percentage than stableSwapFeeBasisPoints
    // we use strictStableTokens to cap the price to 1 USD
    // this allows us to configure stablecoins like DAI as being a stableToken
    // while not being a strictStableToken
    mapping(address => bool) public strictStableTokens;
    mapping(address => uint256) public override adjustmentBasisPoints;
    mapping(address => bool) public override isAdjustmentAdditive;
    mapping(address => uint256) public lastAdjustmentTimings;
    mapping(address => uint256) public latestPriceFeedTime;



    function setPriceMethod(uint8 _setT) external onlyOwner{
        priceMethod = _setT;
    }

    function setTimeVariace(uint256 _priceAdjPer10Sec) external onlyOwner{
        priceAdjPer10Sec = _priceAdjPer10Sec;
    }

    function setPriceVariance(uint256 _priceVariance) external onlyOwner {
        require(_priceVariance < PRICE_VARIANCE_PRECISION.div(2), "invalid variance");
        priceVariance = _priceVariance;
    }

    function setSafePriceTimeGap(uint256 _gap) external onlyOwner {
        priceSafetyGap = _gap;
    }

    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external override onlyOwner {
        require(
            lastAdjustmentTimings[_token].add(MAX_ADJUSTMENT_INTERVAL) < block.timestamp,
            "VaultPriceFeed: adjustment frequency exceeded"
        );
        require(_adjustmentBps <= MAX_ADJUSTMENT_BASIS_POINTS, "invalid _adjustmentBps");
        isAdjustmentAdditive[_token] = _isAdditive;
        adjustmentBasisPoints[_token] = _adjustmentBps;
        lastAdjustmentTimings[_token] = block.timestamp;
    }

    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external override onlyOwner {
        require(_spreadBasisPoints <= MAX_SPREAD_BASIS_POINTS, "VaultPriceFeed: invalid _spreadBasisPoints");
        spreadBasisPoints[_token] = _spreadBasisPoints;
    }

    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external override onlyOwner {
        spreadThresholdBasisPoints = _spreadThresholdBasisPoints;
    }

    function setPriceSampleSpace(uint256 _priceSampleSpace) external override onlyOwner {
        require(_priceSampleSpace > 0, "VaultPriceFeed: invalid _priceSampleSpace");
        priceSampleSpace = _priceSampleSpace;
    }

    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external override onlyOwner {
        maxStrictPriceDeviation = _maxStrictPriceDeviation;
    }

    function _getCombPrice(address _token, bool _maximise) internal view returns (uint256){
        uint256 price = 0;
        uint256 updateTime = 0;
         
        (uint256 pricePr, bool statePr) = getPrimaryPriceFast(_token, _maximise);
        (uint256 priceCl, bool stateCl, uint256 clUpdatedTime) = getChainlinkPrice(_token, _maximise);
        require(stateCl && statePr, "Price Failure");

        uint256 price_minBound = priceCl.mul(PRICE_VARIANCE_PRECISION - priceVariance).div(PRICE_VARIANCE_PRECISION);
        uint256 price_maxBound = priceCl.mul(PRICE_VARIANCE_PRECISION + priceVariance).div(PRICE_VARIANCE_PRECISION);

        if ((pricePr < price_maxBound) && (pricePr > price_minBound)) {
            if (priceMethod == 1){
                if (_maximise){
                    price = pricePr > priceCl ? pricePr : priceCl;
                }
                else{
                    price = pricePr > priceCl ? priceCl : pricePr;
                }
            }
            else if (priceMethod == 3){
                if (latestPriceFeedTime[_token] > clUpdatedTime){
                    price = pricePr;
                    updateTime = latestPriceFeedTime[_token];
                }
                else{
                    price = priceCl;
                    updateTime = clUpdatedTime;
                }                    
            }
            else{
                price = pricePr;
                updateTime = clUpdatedTime;
            }
        }
        else {
            price = priceCl;
            updateTime = clUpdatedTime;
        }
    

        if (updateTime > 0 && priceAdjPer10Sec > 0){
            // require(block.timestamp >= updateTime, "invalid price update time");
            uint256 timeErr = block.timestamp > updateTime ? block.timestamp.sub(updateTime) : updateTime.sub(block.timestamp);
            uint256 priceE = timeErr.div(10).mul(priceAdjPer10Sec);
            priceE = priceE > MAX_SPREAD_BASIS_POINTS ? MAX_SPREAD_BASIS_POINTS : priceE;
            if (_maximise){
                price = price.mul(BASIS_POINTS_DIVISOR.add(priceE)).div(BASIS_POINTS_DIVISOR);
            }
            else{
                price = price.mul(BASIS_POINTS_DIVISOR.sub(priceE)).div(BASIS_POINTS_DIVISOR);
            }         
        }
        return price;    
    }

    //public read
    function getPrice(address _token, bool _maximise, bool, bool) public override view returns (uint256) {
        // uint256 price = useV2Pricing ? getPriceV2(_token, _maximise, _includeAmmPrice) : getPriceV1(_token, _maximise, _includeAmmPrice);
        uint256 price = _getCombPrice(_token, _maximise);
        if (adjustmentBasisPoints[_token] > 0) {
            bool isAdditive = isAdjustmentAdditive[_token];
            if (isAdditive) {
                price = price.mul(BASIS_POINTS_DIVISOR.add(adjustmentBasisPoints[_token])).div(BASIS_POINTS_DIVISOR);
            } else {
                price = price.mul(BASIS_POINTS_DIVISOR.sub(adjustmentBasisPoints[_token])).div(BASIS_POINTS_DIVISOR);
            }
        }
        require(price > 0, "invalid price");
        return price;
    }

    function getOrigPrice(address _token) public override view returns (uint256) {
        return getPrice(_token, true, false, false);
    }

    function getChainlinkPrice(address _token, bool _max) public view returns (uint256, bool, uint256) {
        if (chainlinkAddress[_token] == address(0)) {
            return (0, false, 0);
        }
        if (chainlinkPrecision[_token] < 2) {
            return (0, false, 0);
        }
        (/*uint80 roundId*/, int256 answer, /*uint256 startedAt*/, uint256 updatedAt, /*uint80 answeredInRound*/) = AggregatorV3Interface(chainlinkAddress[_token]).latestRoundData();
        for(uint80 k = 0; k < priceSampleSpace; k++){
            (/*uint80 roundId*/, int256 _answer, /*uint256 startedAt*/, uint256 _updatedAt, /*uint80 answeredInRound*/) = AggregatorV3Interface(chainlinkAddress[_token]).latestRoundData();
            if (_max && (_answer > answer)){
                answer = _answer;
                updatedAt = _updatedAt;
            }
            else if ((!_max) && (_answer < answer) ){
                answer = _answer;
                updatedAt = _updatedAt;   
            }
        }
        // (/*uint80 roundId*/, int256 answer, /*uint256 startedAt*/, uint256 updatedAt, /*uint80 answeredInRound*/) = AggregatorV3Interface(chainlinkAddress[_token]).latestRoundData();
        
        if (answer < 1) {
            return (0, false, 0);
        }
        uint256 time_interval = uint256(block.timestamp).sub(updatedAt);
        if (time_interval > priceSafetyGap && !strictStableTokens[_token]) {
            return (0, false,0);
        }
        uint256 price = uint256(answer).mul(PRICE_PRECISION).div(chainlinkPrecision[_token]);
        return (price, true, updatedAt);
    }


    function getPrimaryPrice(address _token, bool _maximise) public override view returns (uint256, bool) {
        return getPrimaryPriceFast(_token, _maximise);
    }


    //==============================fast price================================

    function getPrimaryPriceFast(address _token, bool /*_maximise*/)
    public
    view
    returns (uint256, bool)
    {
        uint256 time_interval = uint256(block.timestamp).sub(fastTimeStamp);
        if (time_interval > priceSafetyGap && !strictStableTokens[_token]) {
            return (0, false);
        }
        return (prices[_token], true);
    }

    using Counters for Counters.Counter;
    Counters.Counter private _batchRoundId;

    event PriceUpdated(
        address token,
        uint256 ajustedAmount,
        uint256 batchRoundId
    );

    uint256[] public tokenPrecisions;
    address[] public tokens;
    mapping(address => uint256) public prices;
    uint256 public fastTimeStamp;
    uint256 public constant BITMASK_32 = ~uint256(0) >> (256 - 32);
    mapping(address => bool) public isUpdater;

    modifier onlyUpdater() {
        require(isUpdater[msg.sender], "FastPriceFeed: forbidden");
        _;
    }

    function setUpdater(address _account, bool _isActive) external onlyOwner {
        isUpdater[_account] = _isActive;
    }

    function setTokenChainlinkConfig(address _token, address _chainlinkContract, bool _isStrictStable) external onlyOwner {
        uint256 chainLinkDecimal = uint256(
            AggregatorV3Interface(_chainlinkContract).decimals()
        );
        require(
            chainLinkDecimal < 10 && chainLinkDecimal > 0,
            "invalid chainlink decimal"
        );
        chainlinkAddress[_token] = _chainlinkContract;
        chainlinkPrecision[_token] = 10 ** chainLinkDecimal;
        strictStableTokens[_token] = _isStrictStable;
    }

    function setBitTokens(
        address[] memory _tokens,
        uint256[] memory _tokenPrecisions
    ) external onlyOwner {
        require(
            _tokens.length == _tokenPrecisions.length,
            "FastPriceFeed: invalid lengths"
        );
        tokens = _tokens;
        tokenPrecisions = _tokenPrecisions;
    }

    function setPricesWithBits(uint256[] memory _priceBits, uint256 _timestamp) external onlyUpdater {
        _setPricesWithBits(_priceBits, _timestamp);
    }

    function _setPricesWithBits(uint256[] memory _priceBits, uint256 _timestamp) private {
        uint256 roundId = _batchRoundId.current();
        _batchRoundId.increment();
        fastTimeStamp = _timestamp;

        uint8 bitsMaxLength = 8;
        for (uint256 i = 0; i < _priceBits.length; i++) {
            uint256 priceBits = _priceBits[i];


            for (uint256 j = 0; j < bitsMaxLength; j++) {
                uint256 tokenIndex = i * bitsMaxLength + j;
                if (tokenIndex >= tokens.length) {
                    return;
                }

                uint256 startBit = 32 * j;
                uint256 price = (priceBits >> startBit) & BITMASK_32;

                address token = tokens[tokenIndex];
                latestPriceFeedTime[token] = fastTimeStamp;
                uint256 tokenPrecision = tokenPrecisions[tokenIndex];
                uint256 adjustedPrice = price.mul(PRICE_PRECISION).div(
                    tokenPrecision
                );
                prices[token] = adjustedPrice;
                emit PriceUpdated(token, adjustedPrice, roundId);
            }

        }
    }

    address[] public positionRouters;

    //set positionRouter
    function setPositionRouter(address[] memory _positionRouters) public onlyOwner {
        positionRouters = _positionRouters;
    }

    function addPositionRouter(address _positionRouter) public onlyOwner {
        positionRouters.push(_positionRouter);
    }

    function setPricesWithBitsAndExecute(uint256[] memory _priceBits, uint256 _timestamp) external onlyUpdater {
        _setPricesWithBits(_priceBits, _timestamp);

        for (uint256 i = 0; i < positionRouters.length; i++) {
            IPositionRouter _positionRouter = IPositionRouter(positionRouters[i]);

            uint256 a;
            uint256 b;
            uint256 c;
            uint256 d;
            (a, b, c, d) = _positionRouter.getRequestQueueLengths();
            _positionRouter.executeIncreasePositions(b + 3, payable(msg.sender));
            _positionRouter.executeDecreasePositions(d + 3, payable(msg.sender));
        }
    }

    function setPricesWithBitsAndExecuteIncrease(uint256[] memory _priceBits, uint256 _timestamp) external onlyUpdater {
        _setPricesWithBits(_priceBits, _timestamp);

        for (uint256 i = 0; i < positionRouters.length; i++) {
            IPositionRouter _positionRouter = IPositionRouter(positionRouters[i]);

            uint256 a;
            uint256 b;
            uint256 c;
            uint256 d;
            (a, b, c, d) = _positionRouter.getRequestQueueLengths();
            _positionRouter.executeIncreasePositions(b + 3, payable(msg.sender));
        }
    }

    function setPricesWithBitsAndExecuteDecrease(uint256[] memory _priceBits, uint256 _timestamp) external onlyUpdater {
        _setPricesWithBits(_priceBits, _timestamp);

        for (uint256 i = 0; i < positionRouters.length; i++) {
            IPositionRouter _positionRouter = IPositionRouter(positionRouters[i]);

            uint256 a;
            uint256 b;
            uint256 c;
            uint256 d;
            (a, b, c, d) = _positionRouter.getRequestQueueLengths();
            _positionRouter.executeDecreasePositions(d + 3, payable(msg.sender));
        }
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
    }

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
        return _owner;
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
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
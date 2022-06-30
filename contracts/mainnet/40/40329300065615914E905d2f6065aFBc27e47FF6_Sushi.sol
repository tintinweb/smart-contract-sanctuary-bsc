// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

struct LotteryRound {
    address winner;
    address lastCompetitor;
    address[] competitors;
    uint256 totalReward;
    uint256 lastJoinTime;
    uint256 roundTime;
}

contract Sushi is Ownable, VRFConsumerBaseV2 {
    // constants
    uint8 public constant DEV_FEE = 5;
    uint8 public constant REFERRAL_REBATE = 7;
    uint8 public constant LOTTERY_FEE = 5;
    uint8 public constant MINNA_BONUS_FEE = 3;

    uint256 public constant MAX_PRODUCTION = 1234285; //=86400/7%
    uint256 public constant PSN = 10000;
    uint256 public constant PSNH = 5000;

    uint256 public constant MIN_TO_CREATE = 0.1 ether;
    uint256 public constant MINNA_BONUS_RANGE = 50;

    uint256 public constant LOTTERY_MAX_TIME_PER_ROUND = 6 hours;
    uint256 public constant LOTTERY_WIN_TIME = 30 minutes;

    VRFCoordinatorV2Interface immutable COORDINATOR;

    uint64 public chainlinkSubId = 253;
    address constant CHAINLINK_VRFCOORDINATOR =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 constant CHAINLINK_KEYHASH =
        0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470;
    uint32 constant CHAINLINK_CALLBACKGASLIMIT = 2_000_000;
    uint16 constant CHAINLINK_REQUEST_CONFIRMATIONS = 20;

    // market
    uint256 public marketSushi;
    uint256 public startTime = type(uint256).max;

    mapping(address => uint256) public lastCreate;
    mapping(address => uint256) public shokunin;
    mapping(address => uint256) public claimedSushi;
    mapping(address => address) public referrals;
    mapping(address => uint256) public rebateSushi;
    mapping(address => address[]) public invitees;

    // minna bonus
    uint256 public currentCreateIndex;
    mapping(uint256 => address) public createIndexAddress;
    mapping(address => uint256) public minnaBonus;

    // lottery
    bool public isWaitingForChainlinkResult;
    uint256 public currentRound;
    mapping(uint256 => LotteryRound) public rounds;
    mapping(uint256 => mapping(address => bool)) competitorsJoined;
    mapping(address => uint256[]) winRound;
    mapping(address => uint256) public lotteryReward;

    // events
    event Create(address indexed sender, uint256 indexed amount);
    event Recreate(address indexed sender, uint256 indexed amount);
    event Eat(address indexed sender, uint256 indexed amount);
    event SetWinner(uint256 indexed round, address indexed winner);
    event Chainlink(uint256 indexed round, uint256 indexed requsetId);

    constructor() VRFConsumerBaseV2(CHAINLINK_VRFCOORDINATOR) {
        COORDINATOR = VRFCoordinatorV2Interface(CHAINLINK_VRFCOORDINATOR);
    }

    function active(uint256 _startTime) external onlyOwner {
        require(marketSushi == 0);
        startTime = _startTime;
        marketSushi = 123428500000;
    }

    // modifier

    modifier onlyOpen() {
        require(block.timestamp > startTime, "not open");
        _;
    }
    modifier onlyStartOpen() {
        require(marketSushi > 0, "not start open");
        _;
    }

    function create(address referralAccount) public payable onlyStartOpen {
        require(msg.value >= MIN_TO_CREATE, "Not enough");

        uint256 originalPoolETH = address(this).balance - msg.value;
        uint256 sushi = calculateSushiFromETH(msg.value, originalPoolETH);
        sushi -= devFee(sushi);

        // dev fee
        (bool ownerSuccess, ) = owner().call{value: devFee(msg.value)}("");
        require(ownerSuccess, "owner pay failed");

        // minna bonus
        uint256 from = currentCreateIndex <= MINNA_BONUS_RANGE
            ? 0
            : currentCreateIndex - MINNA_BONUS_RANGE;
        uint256 count = currentCreateIndex <= MINNA_BONUS_RANGE
            ? currentCreateIndex
            : MINNA_BONUS_RANGE;

        // minna bonus and lottery
        uint256 minnaBonusSushi = count > 0
            ? ((sushi * MINNA_BONUS_FEE) / 100)
            : 0; // ignore first create
        uint256 lotterySushi = (sushi * LOTTERY_FEE) / 100;
        sushi -= lotterySushi;

        claimedSushi[msg.sender] += sushi;
        recreate(referralAccount);

        if (count > 0) {
            uint256 per = minnaBonusSushi / count;
            for (uint256 i = from; i < from + count; i++) {
                if (createIndexAddress[i] == msg.sender) {
                    minnaBonus[owner()] += per;
                } else {
                    minnaBonus[createIndexAddress[i]] += per;
                }
            }
        }

        createIndexAddress[currentCreateIndex] = msg.sender;
        currentCreateIndex++;

        joinLottery(lotterySushi);

        emit Create(msg.sender, msg.value);
    }

    function recreate(address referralAccount) public onlyStartOpen {
        if (
            referralAccount == msg.sender ||
            referralAccount == address(0) ||
            shokunin[referralAccount] == 0
        ) {
            referralAccount = owner();
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = referralAccount;
            invitees[referralAccount].push(msg.sender);
        }

        uint256 sushi = getSushiOf(msg.sender);

        uint256 newShokunin = sushi / MAX_PRODUCTION;
        shokunin[msg.sender] += newShokunin;

        claimedSushi[msg.sender] = 0;
        rebateSushi[msg.sender] = 0;
        minnaBonus[msg.sender] = 0;
        lotteryReward[msg.sender] = 0;
        lastCreate[msg.sender] = block.timestamp > startTime
            ? block.timestamp
            : startTime;

        // referral rebate
        uint256 sushiRebate = (sushi * REFERRAL_REBATE) / 100;
        rebateSushi[referrals[msg.sender]] += sushiRebate;

        marketSushi += sushi / 5;

        emit Recreate(msg.sender, newShokunin);
    }

    function eat() public onlyOpen {
        uint256 sushi = getSushiOf(msg.sender);
        uint256 eth = calculateETHFromSushi(sushi);

        claimedSushi[msg.sender] = 0;
        rebateSushi[msg.sender] = 0;
        minnaBonus[msg.sender] = 0;
        lotteryReward[msg.sender] = 0;
        lastCreate[msg.sender] = block.timestamp;
        marketSushi += sushi;

        uint256 fee = devFee(eth);
        uint256 realReward = eth - fee;

        // dev fee
        (bool ownerTransferSuccess, ) = owner().call{value: fee}("");
        require(ownerTransferSuccess, "owner pay failed");

        // transfer to msg.sender
        (bool senderTransferSuccess, ) = msg.sender.call{value: realReward}("");
        require(senderTransferSuccess, "msg.sender pay failed");

        emit Eat(msg.sender, realReward);
    }

    function devFee(uint256 _amount) private pure returns (uint256) {
        return (_amount * DEV_FEE) / 100;
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private pure returns (uint256) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateSushiFromETH(uint256 _eth, uint256 _contractBalance)
        private
        view
        returns (uint256)
    {
        return calculateTrade(_eth, _contractBalance, marketSushi);
    }

    function calculateETHFromSushi(uint256 sushi)
        public
        view
        returns (uint256)
    {
        return calculateTrade(sushi, marketSushi, address(this).balance);
    }

    function getSushiOf(address account) public view returns (uint256) {
        return
            lotteryReward[account] +
            rebateSushi[account] +
            minnaBonus[account] +
            claimedSushi[account] +
            getSushiSinceLastDivide(account);
    }

    function getInvitees(address account)
        public
        view
        returns (address[] memory)
    {
        return invitees[account];
    }

    function getSushiSinceLastDivide(address account)
        public
        view
        returns (uint256)
    {
        if (block.timestamp > startTime) {
            uint256 secondsPassed = Math.min(
                MAX_PRODUCTION,
                block.timestamp - lastCreate[account]
            );
            return secondsPassed * (shokunin[account]);
        } else {
            return 0;
        }
    }

    // lottery

    address tempSender;
    uint256 tempSushi;
    bool needRestoreTempPlayer;

    function joinLottery(uint256 sushi) internal {
        // no one can join until the result is released
        if (isWaitingForChainlinkResult) return;

        // check if finished. We use `lastJoinTime` to determine if this round started
        if (rounds[currentRound].lastJoinTime > 0) {
            (bool reachWinTime, bool exceedMaxTimePerRound) = checkFinished(
                currentRound
            );

            if (exceedMaxTimePerRound) {
                // store temporary value for chainlink callback
                tempSender = msg.sender;
                tempSushi = sushi;
                needRestoreTempPlayer = true;

                // call chainlink
                setWinnerRandomly();

                // `return` to stop running the following code. We need to do this in the chainlink callback
                return;
            } else if (reachWinTime) {
                // `currentRound` will be updated after set winner
                setWinnerAsLast();
            }
        }

        rounds[currentRound].lastCompetitor = msg.sender;
        rounds[currentRound].totalReward += sushi;
        rounds[currentRound].lastJoinTime = block.timestamp;

        // add to competitors list when first joined
        if (!competitorsJoined[currentRound][msg.sender]) {
            competitorsJoined[currentRound][msg.sender] = true;
            rounds[currentRound].competitors.push(msg.sender);
        }

        // start round timer when first join
        if (rounds[currentRound].roundTime == 0) {
            rounds[currentRound].roundTime = block.timestamp;
        }
    }

    function checkFinished(uint256 round)
        public
        view
        returns (bool reachWinTime, bool exceedMaxTimePerRound)
    {
        // no `lastJoinTime` means this round hasn't started
        if (rounds[round].lastJoinTime == 0) {
            reachWinTime = false;
            exceedMaxTimePerRound = false;
        } else {
            reachWinTime =
                (block.timestamp - rounds[round].lastJoinTime) >=
                LOTTERY_WIN_TIME;
            exceedMaxTimePerRound =
                (block.timestamp - rounds[round].roundTime) >=
                LOTTERY_MAX_TIME_PER_ROUND;
        }
    }

    function openLotteryResult() public {
        require(!isWaitingForChainlinkResult, "Waiting for result");
        require(
            rounds[currentRound].lastJoinTime > 0,
            "This round has not started"
        );

        (bool reachWinTime, bool exceedMaxTimePerRound) = checkFinished(
            currentRound
        );
        require(
            reachWinTime || exceedMaxTimePerRound,
            "This round has not finished"
        );

        if (!exceedMaxTimePerRound) {
            setWinnerAsLast();
        } else {
            setWinnerRandomly();
        }
    }

    function setWinnerAsLast() private {
        // set winner
        rounds[currentRound].winner = rounds[currentRound].lastCompetitor;

        // transfer reward
        lotteryReward[rounds[currentRound].winner] +=
            (rounds[currentRound].totalReward * 70) /
            100;
        lotteryReward[owner()] += (rounds[currentRound].totalReward * 10) / 100;
        rounds[currentRound + 1].totalReward +=
            (rounds[currentRound].totalReward * 20) /
            100;

        // complete current round
        currentRound++;
    }

    function setWinnerRandomly() private {
        isWaitingForChainlinkResult = true;

        uint256 requestId = COORDINATOR.requestRandomWords({
            keyHash: CHAINLINK_KEYHASH,
            subId: chainlinkSubId,
            minimumRequestConfirmations: CHAINLINK_REQUEST_CONFIRMATIONS,
            callbackGasLimit: CHAINLINK_CALLBACKGASLIMIT,
            numWords: 1
        });

        emit Chainlink(currentRound, requestId);
    }

    /** If chainlink callback failed, onwer can use this function to retry again */
    function retryChainlink() external onlyOwner {
        require(isWaitingForChainlinkResult, "No need to call this function");

        uint256 requestId = COORDINATOR.requestRandomWords({
            keyHash: CHAINLINK_KEYHASH,
            subId: chainlinkSubId,
            minimumRequestConfirmations: CHAINLINK_REQUEST_CONFIRMATIONS,
            callbackGasLimit: CHAINLINK_CALLBACKGASLIMIT,
            numWords: 1
        });

        emit Chainlink(currentRound, requestId);
    }

    function switchChainlinkSubId(uint64 newSubId) external onlyOwner {
        chainlinkSubId = newSubId;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        // pick and set winner
        uint256 index = randomWords[0] %
            rounds[currentRound].competitors.length;
        address winner = rounds[currentRound].competitors[index];
        rounds[currentRound].winner = winner;

        // transfer total reward
        uint256 totalReward = rounds[currentRound].totalReward;
        lotteryReward[winner] += (totalReward * 70) / 100;
        lotteryReward[owner()] += (totalReward * 10) / 100;
        rounds[currentRound + 1].totalReward += (totalReward * 20) / 100;

        emit SetWinner(currentRound, winner);

        // complete current round
        currentRound++;

        if (needRestoreTempPlayer) {
            needRestoreTempPlayer = false;
            rounds[currentRound].lastCompetitor = tempSender;
            rounds[currentRound].totalReward += tempSushi;
            rounds[currentRound].competitors.push(tempSender);
            rounds[currentRound].lastJoinTime = block.timestamp;
            rounds[currentRound].roundTime = block.timestamp;
            competitorsJoined[currentRound][tempSender] = true;
        }

        // flag chainlink state
        isWaitingForChainlinkResult = false;
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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
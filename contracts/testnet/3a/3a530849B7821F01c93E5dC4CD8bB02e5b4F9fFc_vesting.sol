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

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IToken {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 _amount) external;

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function decimals() external view returns (uint256);
}

contract vesting {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    struct roundInfo {
        bool islaunched;
        // string roundName;
        uint256 totalTokensForSale;
        uint256 tokenPrice;
        // uint256 roundStartDate;
        // uint256 roundEndDate;
        uint256 totalvestingDays;
        uint256 vestingStartTime;
        // uint256 vestingClaimPrecentage;
        uint256 vestingSlicePeriod;
        uint256 tgePrecentage;
        // uint256 totalSold ;
    }

    struct claimInfo {
        bool initialized;
        address owner;
        uint8 roundId;
        uint256 totalEligible;
        uint256 totalClaimed;
        uint256 remainingBalTokens;
        uint256 lastClaimedAt;
        uint256 startTime;
        uint256 totalVestingDays;
        uint256 slicePeriod;
    }

    mapping(uint8 => roundInfo) public roundData;
    mapping(address => uint256[]) vestingIds;
    mapping(address => mapping(uint256 => claimInfo)) public userClaimData;

    address public admin;
    address public token;

    // uint256 public listedAt;
    Counters.Counter private _id;

    uint256 public timeUnit;

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Ownable: caller is not the owner or admin"
        );
        _;
    }

    constructor(address _token, address _admin) {
        admin = _admin;
        timeUnit = 60;
        token = _token;
    }

    function setAdmin(address account) external {
        require(admin == msg.sender, "caller is not the admin ");
        require(
            account != address(0),
            "Invalid Address, Address should not be zero"
        );
        admin = account;
    }

    function createVesting(
        address _creator,
        uint8 _roundId,
        uint256 _tokenAmount
    ) public onlyAdmin {
        _id.increment();

        vestingIds[_creator].push(_id.current());

        userClaimData[_creator][_id.current()] = claimInfo({
            initialized: true,
            roundId: _roundId,
            owner: _creator,
            totalEligible: _tokenAmount,
            totalClaimed: 0,
            remainingBalTokens: _tokenAmount,
            lastClaimedAt: 0,
            startTime: 0,
            totalVestingDays: roundData[_roundId].totalvestingDays,
            slicePeriod: roundData[_roundId].vestingSlicePeriod
        });
    }

    // function setRoundsData(
    //     uint8[] memory _roundIds,
    //     string[] memory _roundNames,
    //     uint256[] memory _totalTokensForSale,
    //     uint256[] memory _tokenPrice,
    //     uint256[] memory _roundStartDate,
    //     uint256[] memory _roundEndDate,
    //     uint256[] memory _totalvestingDays,
    //     uint256[] memory _vestingStartTime,
    //     uint256[] memory _vestingClaimPrecentage,
    //     uint256[] memory _vestingSlicePeriod,
    //     uint256[] memory _tgePrecentage
    // ) public onlyAdmin {
    //     // require all lenght should be equal
    //     for (uint256 i = 0; i < _roundIds.length; i++) {
    //         roundData[_roundIds[i]].islaunched = false;
    //         roundData[_roundIds[i]].roundName = _roundNames[i];
    //         roundData[_roundIds[i]].totalTokensForSale = _totalTokensForSale[i];
    //         roundData[_roundIds[i]].tokenPrice = _tokenPrice[i];
    //         roundData[_roundIds[i]].roundStartDate = _roundStartDate[i];
    //         roundData[_roundIds[i]].roundEndDate = _roundEndDate[i];
    //         roundData[_roundIds[i]].totalvestingDays = _totalvestingDays[i];
    //         roundData[_roundIds[i]].vestingStartTime = _vestingStartTime[i];
    //         roundData[_roundIds[i]]
    //             .vestingClaimPrecentage = _vestingClaimPrecentage[i];
    //         roundData[_roundIds[i]].vestingSlicePeriod = _vestingSlicePeriod[i];
    //         roundData[_roundIds[i]].tgePrecentage = _tgePrecentage[i];
    //     }
    // }

    function setRoundData(
        uint8 _roundIds,
        // string memory _roundNames,
        uint256 _totalTokensForSale,
        uint256 _tokenPrice,
        // uint256 _roundStartDate,
        // uint256 _roundEndDate,
        uint256 _totalvestingDays,
        uint256 _vestingStartTime,
        // uint256 _vestingClaimPrecentage,
        uint256 _vestingSlicePeriod,
        uint256 _tgePrecentage
    ) public onlyAdmin {
        roundData[_roundIds].islaunched = false;
        // roundData[_roundIds].roundName = _roundNames;
        roundData[_roundIds].totalTokensForSale = _totalTokensForSale;
        roundData[_roundIds].tokenPrice = _tokenPrice;
        // roundData[_roundIds].roundStartDate = _roundStartDate;
        // roundData[_roundIds].roundEndDate = _roundEndDate;
        roundData[_roundIds].totalvestingDays = _totalvestingDays;
        roundData[_roundIds].vestingStartTime = _vestingStartTime;
        // roundData[_roundIds].vestingClaimPrecentage = _vestingClaimPrecentage;
        roundData[_roundIds].vestingSlicePeriod = _vestingSlicePeriod;
        roundData[_roundIds].tgePrecentage = _tgePrecentage;
        // roundData[_roundIds].totalSold = 0;
    }

    function launchRound(uint8 _roundId, uint256 _vestingStartTime)
        external
        onlyAdmin
    {
        require(admin == msg.sender, "caller is not the admin ");
        require(!roundData[_roundId].islaunched, "Already Listed!");
        roundData[_roundId].vestingStartTime = _vestingStartTime;
        roundData[_roundId].islaunched = true;
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function balance() public view returns (uint256) {
        return IToken(token).balanceOf(address(this));
    }

    function setTimeUnit(uint256 _unit) public onlyAdmin {
        timeUnit = _unit;
    }

    receive() external payable {}

    //Recover eth accidentally sent to the contract
    function removeEth(address payable destination) public onlyAdmin {
        require(
            destination != address(0),
            "Invalid Address, Address should not be zero"
        );
        destination.transfer(address(this).balance);
    }

    function removeERC20() public {
        require(admin == msg.sender, "caller is not the admin ");
        IToken(token).transfer(admin, IToken(token).balanceOf(address(this)));
    }

    ///////////////////////////////////////////////////////////////////////////////

    function getLaunchedAt(uint8 _roundId) public view returns (uint256) {
        return (roundData[_roundId].vestingStartTime);
    }

    function getClaimableAmount(address _walletAddress, uint256 _vestingId)
        public
        view
        returns (uint256 _claimAmount)
    {
        claimInfo storage userData = userClaimData[_walletAddress][_vestingId];

        uint8 _roundId = userData.roundId;
        if (roundData[_roundId].islaunched == false) {
            return 0;
        }

        uint256 timeLeft = 0;
        uint256 slicePeriodSeconds = userData.slicePeriod * timeUnit;
        uint256 claimAmount = 0;
        uint256 _amount = 0;

        uint256 currentTime = getCurrentTime();
        uint256 totalEligible = userData.totalEligible;
        uint256 lastClaimedAt = userData.lastClaimedAt;
        if (roundData[_roundId].islaunched && lastClaimedAt == 0) {
            if (currentTime > getLaunchedAt(_roundId)) {
                timeLeft = currentTime.sub(getLaunchedAt(_roundId));
            } else {
                timeLeft = getLaunchedAt(_roundId).sub(currentTime);
            }
        } else {
            if (currentTime > lastClaimedAt) {
                timeLeft = currentTime.sub(lastClaimedAt);
            } else {
                timeLeft = lastClaimedAt.sub(currentTime);
            }
        }
        _amount = totalEligible;

        if (timeLeft / slicePeriodSeconds > 0) {
            claimAmount =
                ((_amount * userData.slicePeriod) / userData.totalVestingDays) *
                (timeLeft / slicePeriodSeconds);
        }

        uint256 _lastReleaseAmount = userData.totalClaimed;

        uint256 temp = _lastReleaseAmount.add(claimAmount);

        if (temp > totalEligible) {
            _amount = totalEligible.sub(_lastReleaseAmount);
            return (_amount);
        }
        return (claimAmount);
    }

    function getIslaunched(uint8 _roundId) external view returns(bool) {
        return roundData[_roundId].islaunched ;
    }

    function claim(address _walletAddress, uint256 _vestingId) public {

        claimInfo storage userData = userClaimData[_walletAddress][_vestingId];
        uint8 _roundId = userData.roundId;
        require(roundData[_roundId].islaunched, "Not yet launched");
        require( getClaimableAmount(_walletAddress, _vestingId) > 0, "Insufficient funds to claims." );
        require(msg.sender == userData.owner, "You are not the owner");
        uint256 _amount = getClaimableAmount(_walletAddress, _vestingId);
        userData.totalClaimed += _amount;
        userData.remainingBalTokens = userData.totalEligible - userData.totalClaimed;
        userData.lastClaimedAt = getCurrentTime();
        IToken(token).transfer(_walletAddress, _amount);
        
    }

    function getVestingIds(address _walletAddress) public view returns(uint256[] memory) {
        return vestingIds[_walletAddress];
    }

    // function updateTotalTokenSold(uint8 _roundIds,uint256 _amount) external onlyAdmin {
    //     roundData[_roundIds].totalSold += _amount ;
    // }

}
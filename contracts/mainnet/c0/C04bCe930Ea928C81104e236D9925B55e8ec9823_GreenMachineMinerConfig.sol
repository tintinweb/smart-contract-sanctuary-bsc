/*
    GreenMachineMiner Miner config - BSC Miner
    Developed by Kraitor <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/SafeMath.sol";
import "./BasicLibraries/Auth.sol";
import "./Libraries/Testable.sol";

contract GreenMachineMinerConfig is Auth, Testable {
    using SafeMath for uint256;

    //External config of the miner

    constructor(address minerAddress, address timerAddr) Auth(msg.sender) Testable(timerAddr) {
        minerAdd = minerAddress;
    }

    address minerAdd = address(0);

    //Set miner address
    function setMinerAddress(address adr) public authorized { minerAdd = adr; }

    //CUSTOM (ROI events)//
    //One time event
    uint256 internal roiEventBoostPercentage = 0;
    uint256 internal roiEventDuration = 1 days;
    uint256 internal timestampRoiEventBegins = 0; //when roi event begins, 0 means disabled

    function getOneTimeEventBoostPercentage(uint256 _currentEventBoostPercentage) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //One time event
        if(timestampRoiEventBegins != 0 && getCurrentTime() > timestampRoiEventBegins){
            if(getCurrentTime() < timestampRoiEventBegins.add(roiEventDuration)){
                if(roiEventBoostPercentage > eventBoostPercentage){
                    eventBoostPercentage = roiEventBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setOneTimeEventBoost(uint256 _roiEventBoostPercentage, uint256 _roiEventDuration, uint256 _timestampRoiEventBegins) public authorized {
        roiEventBoostPercentage = _roiEventBoostPercentage;
        roiEventDuration = _roiEventDuration.mul(1 days);
        timestampRoiEventBegins = _timestampRoiEventBegins;
    }

    //Periodic event
    uint256 internal roiPeriodicEventBoostPercentage = 0;
    uint256 internal roiPeriodicEventDuration = 1 days;
    uint256 internal timestampRoiEventPeriodicityBegins = 0; //when periodic events begins, 0 means disabled
    uint256 internal roiEventPeriodicity = 7 days;

    function getPeriodicEventBoostPercentage(uint256 _currentEventBoostPercentage) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //Periodic events
        if(timestampRoiEventPeriodicityBegins != 0 && getCurrentTime() > timestampRoiEventPeriodicityBegins){
            //Formula to check if we are on event period
            //(currentTimestamp - timestampInit) % (duration + restPeriod) < duration
            if(getCurrentTime().sub(timestampRoiEventPeriodicityBegins).mod(roiEventPeriodicity.add(roiPeriodicEventDuration)) < roiPeriodicEventDuration){
                if(roiPeriodicEventBoostPercentage > eventBoostPercentage){
                    eventBoostPercentage = roiPeriodicEventBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setPeriodicEventBoost(uint256 _roiPeriodicEventBoostPercentage, uint256 _roiPeriodicEventDuration, uint256 _timestampRoiEventPeriodicityBegins, uint256 _roiEventPeriodicity) public authorized {
        roiPeriodicEventBoostPercentage = _roiPeriodicEventBoostPercentage;
        roiPeriodicEventDuration = _roiPeriodicEventDuration.mul(1 days);
        timestampRoiEventPeriodicityBegins = _timestampRoiEventPeriodicityBegins;
        roiEventPeriodicity = _roiEventPeriodicity.mul(1 days);
    }

    //Milestone event
    uint256 public ntvlMilestoneSteps;
    mapping(uint256 => uint256) internal tvlMilestoneSteps;
    mapping(uint256 => uint256) internal tvlMilestoneBoostPercentages;
    uint256 internal tvlMilestonesEventDuration = 1 days;
    mapping(uint256 => uint256) internal tvlMilestoneStepsTimestampBegin; //when step begins, 0 means still not started

    function getMilestoneEventBoostPercentage(uint256 _currentEventBoostPercentage) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //Milestone events 
        if(ntvlMilestoneSteps > 0){
            //We get current milestone
            uint256 _milestoneBoostPercentage = 0;
            uint256 _stepTimestampBegin = 0;
            for(uint256 i = 0; i < ntvlMilestoneSteps; i++){
                if(address(minerAdd).balance > tvlMilestoneSteps[i].mul(10 ** 18)){
                    _milestoneBoostPercentage = tvlMilestoneBoostPercentages[i];
                    _stepTimestampBegin = tvlMilestoneStepsTimestampBegin[i];
                }
            }

            if(getCurrentTime() > _stepTimestampBegin && getCurrentTime() < _stepTimestampBegin.add(tvlMilestonesEventDuration)){
                if(_milestoneBoostPercentage > eventBoostPercentage){
                    eventBoostPercentage = _milestoneBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setMilestoneEventBoost(uint256 [] memory _tvlMilestoneSteps, uint256 [] memory _tvlMilestoneBoostPercentages, uint256 _tvlMilestonesEventDuration, uint256 [] memory _tvlMilestoneStepsTimestampBegin) public authorized {
        require(_tvlMilestoneSteps.length == _tvlMilestoneBoostPercentages.length, 'Arrays of different size');
        require(_tvlMilestoneSteps.length == _tvlMilestoneStepsTimestampBegin.length, 'Arrays of different size');

        ntvlMilestoneSteps = _tvlMilestoneSteps.length;
        
        for(uint256 i = 0; i < ntvlMilestoneSteps; i++){
            tvlMilestoneSteps[i] = _tvlMilestoneSteps[i];
            tvlMilestoneBoostPercentages[i] = _tvlMilestoneBoostPercentages[i];
            tvlMilestonesEventDuration = _tvlMilestonesEventDuration.mul(1 days);
            tvlMilestoneStepsTimestampBegin[i] = _tvlMilestoneStepsTimestampBegin[i];
        }
    }

    function updateMilestoneEventBoostTimestamp() internal {
        for(uint256 i = 0; i < ntvlMilestoneSteps; i++){
            if(address(minerAdd).balance > tvlMilestoneSteps[i].mul(10**18)){
                if(tvlMilestoneStepsTimestampBegin[i] == 0){
                    tvlMilestoneStepsTimestampBegin[i] = getCurrentTime(); //Timestamp update
                }
            }
        }
    }

    function checkNeedUpdateMilestoneEventBoostTimestamp() internal view returns (bool) {
        bool needUpdate = false;

        for(uint256 i = 0; i < ntvlMilestoneSteps; i++){
            if(address(minerAdd).balance > tvlMilestoneSteps[i].mul(10**18)){
                if(tvlMilestoneStepsTimestampBegin[i] == 0){
                    needUpdate = true;
                }
            }
        }

        return needUpdate;
    }

    //General
    function getEventsBoostPercentage() public view returns (uint256) {

        uint256 eventBoostPercentage = getMilestoneEventBoostPercentage(getPeriodicEventBoostPercentage(getOneTimeEventBoostPercentage(0)));

        //Limited, security meassure
        if(eventBoostPercentage > 1000){
            eventBoostPercentage = 1000;
        }

        return eventBoostPercentage;
    }

    function needUpdateEventBoostTimestamps() external view returns (bool) {
        return checkNeedUpdateMilestoneEventBoostTimestamp();
    }

    function updateEventsBoostTimestamps() external {
        updateMilestoneEventBoostTimestamp();
    }

    function applyROIEventBoost(uint256 amount) external view returns (uint256) {
        return amount.add(amount.mul(getEventsBoostPercentage()).div(100));
    }    

    //ALGORITHM(?)//

    ////////////////
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/Auth.sol";
import "./BasicLibraries/SafeMath.sol";

/**
 * @title Universal store of current contract time for testing environments.
 */
contract Timer is Auth {
    using SafeMath for uint256;
    uint256 private currentTime;

    bool enabled = false;

    constructor() Auth(msg.sender) { }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set `currentTime` to.
     */
    function setCurrentTime(uint256 time) external authorized {
        require(time >= currentTime, "Return to the future Doc!");
        currentTime = time;
    }

    function enable(bool _enabled) external authorized {
        require(enabled == false, 'Can not be disabled');
        enabled = _enabled;
    }

    function increaseDays(uint256 _days) external authorized {
        currentTime = getCurrentTime().add(uint256(1 days).mul(_days));
    }

    function increaseMinutes(uint256 _minutes) external authorized {
        currentTime = getCurrentTime().add(uint256(1 minutes).mul(_minutes));
    }

    function increaseSeconds(uint256 _seconds) external authorized {
        currentTime = getCurrentTime().add(uint256(1 seconds).mul(_seconds));
    }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint256 for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if(enabled){
            return currentTime;
        }
        else{
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../Timer.sol";

/**
 * @title Base class that provides time overrides, but only if being run in test mode.
 */
abstract contract Testable {
    // If the contract is being run on the test network, then `timerAddress` will be the 0x0 address.
    // Note: this variable should be set on construction and never modified.
    address public timerAddress;

    /**
     * @notice Constructs the Testable contract. Called by child contracts.
     * @param _timerAddress Contract that stores the current time in a testing environment.
     * Must be set to 0x0 for production environments that use live time.
     */
    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    /**
     * @notice Reverts if not running in test mode.
     */
    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set current Testable time to.
     */
    // function setCurrentTime(uint256 time) external onlyIfTest {
    //     Timer(timerAddress).setCurrentTime(time);
    // }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
pragma solidity ^0.8.9;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
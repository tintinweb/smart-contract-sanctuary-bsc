/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

/**
  _______   _      _     _____     ______      _____  
/\_______)\/_/\  /\_\   ) ___ (   /_/\___\   /\_____\ 
\(___  __\/) ) )( ( (  / /\_/\ \  ) ) ___/  ( (_____/ 
  / / /   /_/ //\\ \_\/ /_/ (_\ \/_/ /  ___  \ \__\   
 ( ( (    \ \ /  \ / /\ \ )_/ / /\ \ \_/\__\ / /__/_  
  \ \ \    )_) /\ (_(  \ \/_\/ /  )_)  \/ _/( (_____\ 
  /_/_/    \_\/  \/_/   )_____(   \_\____/   \/_____/ 
                                                      
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TwogeMinerConfig is Ownable {
    using SafeMath for uint256;

    //External config of the miner
    address minerAdd;

    constructor() {}

    //Set miner address
    function setMinerAddress(address adr) public onlyOwner {
        minerAdd = adr;
    }

    //CUSTOM (ROI events)//
    //One time event
    uint256 internal roiEventBoostPercentage = 0;
    uint256 internal roiEventDuration = 1 days;
    uint256 internal timestampRoiEventBegins = 0; //when roi event begins, 0 means disabled

    function getOneTimeEventBoostPercentage(
        uint256 _currentEventBoostPercentage
    ) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //One time event
        if (
            timestampRoiEventBegins != 0 &&
            block.timestamp > timestampRoiEventBegins
        ) {
            if (
                block.timestamp < timestampRoiEventBegins.add(roiEventDuration)
            ) {
                if (roiEventBoostPercentage > eventBoostPercentage) {
                    eventBoostPercentage = roiEventBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setOneTimeEventBoost(
        uint256 _roiEventBoostPercentage,
        uint256 _roiEventDuration,
        uint256 _timestampRoiEventBegins
    ) public onlyOwner {
        roiEventBoostPercentage = _roiEventBoostPercentage;
        roiEventDuration = _roiEventDuration.mul(1 days);
        timestampRoiEventBegins = _timestampRoiEventBegins;
    }

    //Periodic event
    uint256 internal roiPeriodicEventBoostPercentage = 0;
    uint256 internal roiPeriodicEventDuration = 1 days;
    uint256 internal timestampRoiEventPeriodicityBegins = 0; //when periodic events begins, 0 means disabled
    uint256 internal roiEventPeriodicity = 7 days;

    function getPeriodicEventBoostPercentage(
        uint256 _currentEventBoostPercentage
    ) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //Periodic events
        if (
            timestampRoiEventPeriodicityBegins != 0 &&
            block.timestamp > timestampRoiEventPeriodicityBegins
        ) {
            //Formula to check if we are on event period
            //(currentTimestamp - timestampInit) % (duration + restPeriod) < duration
            if (
                block.timestamp.sub(timestampRoiEventPeriodicityBegins).mod(
                    roiEventPeriodicity.add(roiPeriodicEventDuration)
                ) < roiPeriodicEventDuration
            ) {
                if (roiPeriodicEventBoostPercentage > eventBoostPercentage) {
                    eventBoostPercentage = roiPeriodicEventBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setPeriodicEventBoost(
        uint256 _roiPeriodicEventBoostPercentage,
        uint256 _roiPeriodicEventDuration,
        uint256 _timestampRoiEventPeriodicityBegins,
        uint256 _roiEventPeriodicity
    ) public onlyOwner {
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

    function getMilestoneEventBoostPercentage(
        uint256 _currentEventBoostPercentage
    ) public view returns (uint256) {
        uint256 eventBoostPercentage = _currentEventBoostPercentage;

        //Milestone events
        if (ntvlMilestoneSteps > 0) {
            //We get current milestone
            uint256 _milestoneBoostPercentage = 0;
            uint256 _stepTimestampBegin = 0;
            for (uint256 i = 0; i < ntvlMilestoneSteps; i++) {
                if (
                    address(minerAdd).balance > tvlMilestoneSteps[i].mul(10**18)
                ) {
                    _milestoneBoostPercentage = tvlMilestoneBoostPercentages[i];
                    _stepTimestampBegin = tvlMilestoneStepsTimestampBegin[i];
                }
            }

            if (
                block.timestamp > _stepTimestampBegin &&
                block.timestamp <
                _stepTimestampBegin.add(tvlMilestonesEventDuration)
            ) {
                if (_milestoneBoostPercentage > eventBoostPercentage) {
                    eventBoostPercentage = _milestoneBoostPercentage;
                }
            }
        }

        return eventBoostPercentage;
    }

    function setMilestoneEventBoost(
        uint256[] memory _tvlMilestoneSteps,
        uint256[] memory _tvlMilestoneBoostPercentages,
        uint256 _tvlMilestonesEventDuration,
        uint256[] memory _tvlMilestoneStepsTimestampBegin
    ) public onlyOwner {
        require(
            _tvlMilestoneSteps.length == _tvlMilestoneBoostPercentages.length,
            "Arrays of different size"
        );
        require(
            _tvlMilestoneSteps.length ==
                _tvlMilestoneStepsTimestampBegin.length,
            "Arrays of different size"
        );

        ntvlMilestoneSteps = _tvlMilestoneSteps.length;

        for (uint256 i = 0; i < ntvlMilestoneSteps; i++) {
            tvlMilestoneSteps[i] = _tvlMilestoneSteps[i];
            tvlMilestoneBoostPercentages[i] = _tvlMilestoneBoostPercentages[i];
            tvlMilestonesEventDuration = _tvlMilestonesEventDuration.mul(
                1 days
            );
            tvlMilestoneStepsTimestampBegin[
                i
            ] = _tvlMilestoneStepsTimestampBegin[i];
        }
    }

    function updateMilestoneEventBoostTimestamp() internal {
        for (uint256 i = 0; i < ntvlMilestoneSteps; i++) {
            if (address(minerAdd).balance > tvlMilestoneSteps[i].mul(10**18)) {
                if (tvlMilestoneStepsTimestampBegin[i] == 0) {
                    tvlMilestoneStepsTimestampBegin[i] = block.timestamp; //Timestamp update
                }
            }
        }
    }

    function checkNeedUpdateMilestoneEventBoostTimestamp()
        internal
        view
        returns (bool)
    {
        bool needUpdate = false;

        for (uint256 i = 0; i < ntvlMilestoneSteps; i++) {
            if (address(minerAdd).balance > tvlMilestoneSteps[i].mul(10**18)) {
                if (tvlMilestoneStepsTimestampBegin[i] == 0) {
                    needUpdate = true;
                }
            }
        }

        return needUpdate;
    }

    //General
    function getEventsBoostPercentage() public view returns (uint256) {
        uint256 eventBoostPercentage = getMilestoneEventBoostPercentage(
            getPeriodicEventBoostPercentage(getOneTimeEventBoostPercentage(0))
        );

        //Limited, security meassure
        if (eventBoostPercentage > 1000) {
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

    function applyROIEventBoost(uint256 amount)
        external
        view
        returns (uint256)
    {
        return amount.add(amount.mul(getEventsBoostPercentage()).div(100));
    }

    //ALGORITHM(?)//

    ////////////////
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
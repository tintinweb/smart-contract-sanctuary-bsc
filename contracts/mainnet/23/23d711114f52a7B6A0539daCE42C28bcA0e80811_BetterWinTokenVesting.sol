// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./SafeERC20.sol";

/**
 * @title PartnersVesting
 * @dev A token holder contract that can release its token balance gradually at different vesting points
 */
contract BetterWinTokenVesting {
    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is
    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,
    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a
    // cliff period of a year and a duration of four years, are safe to use.
    // solhint-disable not-rely-on-time

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(uint schedule, address holder, address token, uint256 amount);

    // The token being vested
    IERC20 public _token;
    // total amount the contract has released.
    uint256 public totalReleased;

    uint256 public immutable VESTING_PERIOD = 2629746*12; // 1 year in seconds

    // Schedule. 
    struct Schedule {
        string id;               // eg. "foundation", "marketing" etc.
        uint256 startPeriod;     // the timestamp of the first period.
        uint256 numPeriods;      // number of periods to vest.
        uint256 amountPerPeriod; // amount of the token to release each period.
    }

    Schedule[] public schedules;
    mapping(uint => mapping (address => uint256)) balances; // balances assigned to a wallet for a schedule
    mapping(uint => mapping (address => uint256)) released; // released to a wallet for a schedule
    mapping(uint => mapping (address => bool[])) vested;    // array of bools indicating whether wallet has vested or not.
    mapping(address => bool) owners;                        // contract owners. can perform admin functionality.

    // If the contract is revocable
    bool _revocable;

    
    
    constructor () {
        _token = IERC20(0xBc46A4561F435EeDfBE6071Cf1E17c20df912Ae0);
        _revocable = true;
        owners[msg.sender] = true;
    }

    function addSchedule(string calldata id, uint256 startPeriod, uint256 numPeriods, uint256 amountPerPeriod, address[] calldata holders) external {
        _onlyOwner();

        require(numPeriods <= 255);

        Schedule memory schedule;

        schedule.id = id;
        schedule.startPeriod = startPeriod;
        schedule.numPeriods = numPeriods;
        schedule.amountPerPeriod = amountPerPeriod;
        schedules.push(schedule);

        uint scheduleID = schedules.length-1;

        // set initial holders.
        for(uint i=0; i<holders.length; i++){
            balances[scheduleID][holders[i]] = amountPerPeriod.mul(numPeriods).div(holders.length);
            vested[scheduleID][holders[i]] = new bool[](numPeriods);
        }
    }

    // /**
    //  * @dev Returns the amount of tokens owned by `account`.
    //  */
    function getNumSchedules() external view returns (uint256) {
        return schedules.length;
    }

    /**
     * @notice Allows the owner to revoke the vesting.
     * ONLY TO BE USED IN CASE OF EMERGENCY.
     */
    function revoke() public {
        _onlyOwner();

        require(_revocable, "TokenVesting: cannot revoke");

        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(msg.sender, balance);
    }

    /**
     * @notice Transfers vested tokens to holders.
     */
    function release(uint scheduleID, address[] calldata holders) public {
        for(uint i=0; i<holders.length; i++){
            uint256 unreleasedIdx = _releasableIdx(scheduleID, holders[i]);
            uint256 unreleasedAmount = schedules[scheduleID].amountPerPeriod;        

            vested[scheduleID][holders[i]][unreleasedIdx] = true;
            released[scheduleID][holders[i]] = released[scheduleID][holders[i]].add(unreleasedAmount);
            totalReleased = totalReleased.add(unreleasedAmount);

            _token.safeTransfer(holders[i], unreleasedAmount);
            emit TokensReleased(scheduleID, holders[i], address(_token), unreleasedAmount);
        }
    }

    /**
     * @dev Calculates the index that has already vested but hasn't been released yet for 'holder'.
     */
    function _releasableIdx(uint scheduleID,address holder) private view returns (uint256) {

        require(vested[scheduleID][holder].length > 0, "_releasableIdx: no vesting for holder.");

        uint256 startPeriod = schedules[scheduleID].startPeriod;

        for (uint256 index = 0; index < schedules[scheduleID].numPeriods; index++) {
            if (block.timestamp > startPeriod.add(index.mul(VESTING_PERIOD)) && vested[scheduleID][holder][index] == false) {
                return index;
            }
        }

        require(false, "_releasableIdx: no tokens are due for holder.");
        return 0;
    }
    
    function setToken(address token) external {
        _token = IERC20(token);
    }
    function _onlyOwner() private view {
        require(owners[msg.sender], "_onlyOwner: sender is not an owner.");
    }

    function addAddmin( address admin) external {
        _onlyOwner();
        owners[admin] = true;
    }
    function removeAddmin( address admin) external {
        _onlyOwner();
        owners[admin] = false;
    }

}
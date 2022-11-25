//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./Context.sol";
import "./ERC20.sol";

contract VestingSchedule is Context, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    event VestingScheduleAdded(address account, uint allocation, uint timestamp, uint vestingSeconds, uint cliffSeconds);
    event VestingScheduleCanceled(address account);
    event AllocationClaimed(address account, uint amount, uint timestamp);

    struct VestingScheduleStruct {
        address account;
        uint allocation;
        uint startTimestamp;
        uint vestingSeconds;
        uint cliffSeconds;
        uint claimedAmount;
    }

    mapping( address => VestingScheduleStruct ) private _vestingSchedules;
    ERC20 private _token;

    uint private _totalAllocation;
    uint private _totalClaimedAllocation;

    constructor ( address ownerAddress, address tokenAddress ) {
        _setupRole(OWNER_ROLE, ownerAddress);
        _token = ERC20(tokenAddress);
    }

    // FUNCTIONS

    function addVestingSchedule(address account, uint allocation, uint vestingSeconds, uint cliffSeconds) external onlyOwner {

        require(_vestingSchedules[account].account==address(0x0), "ERROR: Vesting Schedule already exists" );
        require(cliffSeconds <= vestingSeconds, "ERROR: Cliff longer than Vesting Time");
        require(_totalAllocation + allocation <= _token.balanceOf(address(this)), "ERROR: Total allocation cannot be greater than reserves");
        require(vestingSeconds > 0, "ERROR: Vesting Time cannot be 0 seconds");

        _totalAllocation += allocation;
        _vestingSchedules[account] = VestingScheduleStruct(
            account, 
            allocation, 
            block.timestamp, 
            vestingSeconds, 
            cliffSeconds, 
            0);

        emit VestingScheduleAdded(account, allocation, block.timestamp, vestingSeconds, cliffSeconds);
    }
    
    function claim() external  {
        return _claim(_msgSender());
    }

    function _claim(address account) private {
        uint amount = getClaimableAmount(account);

        _token.transfer(account, amount);
        
        _vestingSchedules[account].claimedAmount += amount;
        _totalClaimedAllocation += amount;

        emit AllocationClaimed(account, amount, block.timestamp);
    }

    function cancel(address account) external onlyOwner {

        uint unvestedAllocation = getUnvestedAmount(account);

        _vestingSchedules[account].allocation = _vestingSchedules[account].allocation - unvestedAllocation;
        _vestingSchedules[account].vestingSeconds = getElapsedVestingTime(account);

        _totalAllocation -= unvestedAllocation;

        emit VestingScheduleCanceled(account);
    }

    // GETTERS

    ///// global /////
    function getTokenAddress() external view returns (address) {
        return address(_token);
    }

    function getTotalAllocation() external view returns (uint) {
        return _totalAllocation;
    }

    function getTotalClaimedAllocation() external view returns (uint) {
        return _totalClaimedAllocation;
    }

    ///// by vesting definition /////
    function getVestingSchedule(address account) external view returns (VestingScheduleStruct memory) {
        return _vestingSchedules[account];
    }

    function getVestingMaturationTimestamp(address account) public view returns (uint) {
        return _vestingSchedules[account].startTimestamp + _vestingSchedules[account].vestingSeconds;
    }

    function getElapsedVestingTime(address account) public view returns (uint) {
        if(block.timestamp > getVestingMaturationTimestamp(account)){
            return _vestingSchedules[account].vestingSeconds;
        }
        return block.timestamp - _vestingSchedules[account].startTimestamp;
    }

    function getVestedAmount(address account) public view returns (uint) {
        return _vestingSchedules[account].allocation * getElapsedVestingTime(account) / _vestingSchedules[account].vestingSeconds;
    }

    function getUnvestedAmount(address account) public view returns (uint) {
        return _vestingSchedules[account].allocation - getVestedAmount(account);
    }

    function getClaimableAmount(address account) public view returns (uint) {
        //If it's earlier than the cliff, zero allocation is claimable.
        if(block.timestamp < (_vestingSchedules[account].startTimestamp + _vestingSchedules[account].cliffSeconds ) ){
            return 0;
        }

        //Claimable amount is the vested, unclaimed amount.
        return getVestedAmount(account) - _vestingSchedules[account].claimedAmount;
    }

    // MODIFIERS

    modifier onlyOwner {
        require(
            hasRole(OWNER_ROLE, _msgSender()),
            "Only owner can call this function."
        );
        _;
    }
}
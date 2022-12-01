// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lock {
    // this declares a type of users that are locked
    //with locked time, amount, released
    struct Beneficiary {
        uint256 month;
        uint256 total_locked;
        uint256 current_locked;
        uint256 released;
        uint256 claimed_month;
        uint256 locked_time;
    }

    address public owner;
    address public locker;
    address unlocker;
    //this declares a state variable that
    //stores a User type (Beneficiary)
    mapping(address => Beneficiary) public beneficiaries;
    // release starts Nov 1st 2022
    uint256 public release_date = 1666286000; // 1667286000;

    constructor() {
        owner = msg.sender;
    }

    function assignLocker(address _locker) external {
        require(msg.sender == owner);
        require(_locker != address(0));
        locker = _locker;
    }

    function assignUnlocker(address _unlocker) external {
        require(msg.sender == owner);
        require(_unlocker != address(0));
        unlocker = _unlocker;
    }

    function lock(
        address _user,
        uint256 _amount,
        uint256 _month
    ) external {
        require(
            msg.sender == locker,
            "You don't have access to this function."
        );
        uint256 current_time = block.timestamp;
        require(current_time < release_date);
        if (beneficiaries[_user].month == 0) {
            beneficiaries[_user].total_locked = _amount;
            beneficiaries[_user].current_locked = _amount;
            beneficiaries[_user].month = _month;
            beneficiaries[_user].released = 0;
            beneficiaries[_user].claimed_month = 0;
            beneficiaries[_user].locked_time = current_time;
        } else {
            require(_month == beneficiaries[_user].month);
            beneficiaries[_user].total_locked += _amount;
            beneficiaries[_user].current_locked += _amount;
            beneficiaries[_user].locked_time = current_time;
        }
    }

    function unlock(
        address _user,
        uint256 _amount,
        uint256 _month
    ) external {
        require(msg.sender == unlocker);
        require(
            //only allow changes within 48 hours after lock
            block.timestamp - beneficiaries[_user].locked_time <= 48 * 3600 &&
                beneficiaries[_user].month == _month
        );
        beneficiaries[_user].total_locked -= _amount;
        beneficiaries[_user].current_locked -= _amount;
    }

    function release() external {
        address _beneficiary = msg.sender;
        require(beneficiaries[_beneficiary].current_locked > 0);
        Beneficiary storage beneficiary = beneficiaries[_beneficiary];
        uint256 today = block.timestamp;
        require(today > release_date);
        uint256 total_locked = beneficiary.total_locked;
        uint256 claimed = beneficiary.claimed_month;
        uint256 passed_time = (today - release_date) / 3600 / 24 / 30;
        if (passed_time > beneficiary.month) {
            passed_time = beneficiary.month;
        }
        uint256 release_amount = ((passed_time - claimed) * total_locked) /
            beneficiary.month;
        beneficiary.claimed_month = passed_time;
        beneficiary.current_locked -= release_amount;
        beneficiary.released += release_amount;
    }

    function check_lock(address _sender)
        external
        view
        returns (Beneficiary memory)
    {
        return beneficiaries[_sender];
    }
}
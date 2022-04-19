// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./ILPLocker.sol";

contract LPLocker is ILPLocker {
    using SafeMath for uint256;

    address private _token;      // Caller Smart Contract
    bool private initialized;

    uint256 private unlock_ts;

    modifier onlyToken() {
        require(msg.sender == _token, "Unauthorized"); _;
    }

    constructor () {}

    function initialize(uint256 _initial_unlock_ts) external override {
        require(!initialized, "LPLocker: already initialized!");
        initialized = true;
        _token = msg.sender;
        // Set initial lock
        _updateLock(_initial_unlock_ts);
        emit Initialized(_token, _initial_unlock_ts);
    }

    // Withdraw the specified token (LP token) from the LPLocker, sending the amount (coerced to the balance available, wei unit) t0 the _to address
    // Possible only the lock expired (unlocked)
    function withdrawLP(address _LPaddress, uint256 _amount, address _to) external override onlyToken {
        require(block.timestamp > unlock_ts, "LPLocker: Lock not expired!");
        IBEP20 token_out = IBEP20(_LPaddress);
        if (token_out.balanceOf(address(this)) < _amount) {
            _amount = token_out.balanceOf(address(this));   // coerce
        }
        token_out.transfer(_to, _amount);
        emit LPWithdrawn(_LPaddress, _amount, _to);
    }

    // Update the Lock of the LPLocker
    function updateLock(uint256 _newUnlockTimestamp) external override onlyToken {
        _updateLock(_newUnlockTimestamp);
    }

    // Update the Lock of the LPLocker internal function
    function _updateLock(uint256 _newUnlockTimestamp) internal {
        // The new lock timestamp (in s) must be in the future (from now + 1 day) and greater than the stored unlock timestamp
        require(_newUnlockTimestamp > block.timestamp + 1 days && _newUnlockTimestamp > unlock_ts, "LPLocker: _newUnlockTimestamp must be > now + 1 day && > current unlock_ts");
        emit LPLockUpdated(unlock_ts, _newUnlockTimestamp);
        unlock_ts = _newUnlockTimestamp;
    }

    // Return the status of the LPLock vault, its address and the balance of the provided _LPaddress (if different from NULL address)
    function getInfoLP(address _LPaddress) public view override returns (address locker_address, uint256 LPbalance, uint256 unlock_timestamp, bool unlocked) {
        locker_address = address(this);
        if (_LPaddress != address(0)) {
            LPbalance = IBEP20(_LPaddress).balanceOf(locker_address);
        }
        unlock_timestamp = unlock_ts;
        unlocked = (block.timestamp > unlock_ts);
    }

}
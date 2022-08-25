// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeERC20.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
 

contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;
    
    address private _unlocker;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token_, address beneficiary_, uint256 releaseTime_) {
        // solhint-disable-next-line not-rely-on-time
        require(
            releaseTime_ > block.timestamp,
            "TokenTimelock: release time is before current time"
        );
        require(beneficiary_ != address(0), "beneficiary_: beneficiary is the zero address");
        _token = token_;
        _beneficiary = beneficiary_;
        _unlocker = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }
    
    /**
     * @return the unlocker of the tokens.
     */
    function unlocker() public view virtual returns (address) {
        return _unlocker;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }
    
    /**
     *@notice Extend Lock Time.
     */
     
    //Declare an Event
    event ExtendedLockTime(
        address indexed from,
        uint256 indexed oldValue,
        uint256 indexed newValue
    );
    
    function extendLockTime(uint256 newReleaseTime_) external virtual {
        require(_unlocker == msg.sender, "Ownable: caller is not the current unlocker");
        
        require(
            newReleaseTime_ > releaseTime(),
            "TokenTimelock: new release time can't be before the current release time"
        );
        
        require(
            newReleaseTime_ <= releaseTime() + 365 days,
            "TokenTimelock: new release time can't be longer than the current release time + 365 days"
        );
        uint256 oldValue = _releaseTime;
        _releaseTime = newReleaseTime_;
        
        //Emit an event
        emit ExtendedLockTime(msg.sender, oldValue, _releaseTime);
    }
    
    /**
     *@notice Set new unlocker address.
     */
    
     //Declare an Event
    event SetNewUnlocker(
        address indexed from,
        address indexed oldUnlocker,
        address indexed newUnlocker
    );
    
    function setUnlocker(address newUnlocker_) external virtual {
        require(
            _unlocker == msg.sender,
            "Ownable: caller is not the current unlocker"
        );
        
        require(
            newUnlocker_ != address(0),
            "newUnlocker_: new UnLocker is the zero address"
        );
        
        address oldUnlocker = _unlocker;
        _unlocker = newUnlocker_;
        
        //Emit an event
        emit SetNewUnlocker(msg.sender, oldUnlocker, _unlocker);
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release(uint256 releasedValue_) external virtual {
        // solhint-disable-next-line not-rely-on-time
        require(
            block.timestamp >= releaseTime(),
            "TokenTimelock: current time is before release time"
        );

        uint256 amount = releasedValue_;//token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        require(
            unlocker() == msg.sender,
            "Ownable: caller is not the current unlocker"
        );
        
        token().safeTransfer(beneficiary(), amount);
    }
}
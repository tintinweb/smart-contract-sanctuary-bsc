// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ICaKePool.sol";

contract ICake is Ownable {
    using SafeMath for uint256;

    ICaKePool public immutable cakePool;

    address public admin;
    // threshold of locked duration
    uint256 public ceiling;

    uint256 public constant MIN_CEILING_DURATION = 1 weeks;

    event UpdateCeiling(uint256 newCeiling);

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "None admin!");
        _;
    }

    /**
     * @notice Constructor
     * @param _cakePool: Cake pool contract
     * @param _admin: admin of the this contract
     * @param _ceiling: the max locked duration which the linear decrease start
     */
    constructor(
        ICaKePool _cakePool,
        address _admin,
        uint256 _ceiling
    ) public {
        require(_ceiling >= MIN_CEILING_DURATION, "Invalid ceiling duration");
        cakePool = _cakePool;
        admin = _admin;
        ceiling = _ceiling;
    }

    /**
     * @notice calculate iCake credit per user.
     * @param _user: user address.
     */
    function getUserCredit(address _user) external view returns (uint256) {
        require(_user != address(0), "getUserCredit: Invalid address");

        ICaKePool.UserInfo memory userInfo = cakePool.userInfo(_user);

        if (!userInfo.locked || block.timestamp > userInfo.lockEndTime) {
            return 0;
        }

        // lockEndTime always >= lockStartTime
        uint256 lockDuration = userInfo.lockEndTime.sub(userInfo.lockStartTime);

        if (lockDuration >= ceiling) {
            return userInfo.lockedAmount;
        } else if (lockDuration < ceiling && lockDuration >= 0) {
            return (userInfo.lockedAmount.mul(lockDuration)).div(ceiling);
        }
    }

    /**
     * @notice update ceiling thereshold duration for iCake calculation.
     * @param _newCeiling: new threshold duration.
     */
    function updateCeiling(uint256 _newCeiling) external onlyAdmin {
        require(_newCeiling >= MIN_CEILING_DURATION, "updateCeiling: Invalid ceiling");
        require(ceiling != _newCeiling, "updateCeiling: Ceiling not changed");
        ceiling = _newCeiling;
        emit UpdateCeiling(ceiling);
    }
}
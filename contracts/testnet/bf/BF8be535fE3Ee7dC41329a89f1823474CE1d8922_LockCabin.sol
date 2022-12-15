// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";

contract LockCabin {
    constructor() {}

    uint256 private lockTime = 365 * 24 * 60 * 60;
    mapping(address => uint256) private lockCabinTime;
    mapping(address => address) private lockCabinToken;
    mapping(address => uint256) private lockCabinAmount;

    function startLockCabin(address tokenAddress, uint256 amount) external {
        require(lockCabinTime[msg.sender] == 0, "Exists LockCabin");
        uint256 tempAmount = amount * (10**IERC20(tokenAddress).decimals());
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= tempAmount,
            "error balance"
        );
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >=
                tempAmount,
            "error approve"
        );
        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            tempAmount
        );
        lockCabinTime[msg.sender] = block.timestamp;
        lockCabinToken[msg.sender] = tokenAddress;
        lockCabinAmount[msg.sender] = tempAmount;
    }

    function getLockCabinInfo(address tempAddress)
        external
        view
        returns (
            uint256,
            address,
            uint256
        )
    {
        require(lockCabinTime[tempAddress] > 0, "Not LockCabin");
        return (
            lockCabinTime[tempAddress],
            lockCabinToken[tempAddress],
            lockCabinAmount[tempAddress]
        );
    }

    function unLockCabin() external {
        require(lockCabinTime[msg.sender] > 0, "Not LockCabin");
        require(
            lockCabinTime[msg.sender] + lockTime < block.timestamp,
            "not time to unlock"
        );
        IERC20(lockCabinToken[msg.sender]).transfer(
            msg.sender,
            lockCabinAmount[msg.sender]
        );
        delete lockCabinTime[msg.sender];
        delete lockCabinToken[msg.sender];
        delete lockCabinAmount[msg.sender];
    }
}
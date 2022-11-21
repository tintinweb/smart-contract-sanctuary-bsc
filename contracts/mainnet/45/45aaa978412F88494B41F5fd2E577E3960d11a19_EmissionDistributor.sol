//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IDaylight {
    function getOwner() external view returns (address);
}

contract EmissionDistributor {

    // daylight token
    address public immutable daylight;

    // percentage awarded per block
    uint256 public percentPerBlock = 347_222_222_222;

    // max percent that can be awarded per day
    uint256 public maxPercent = 5 * 10**16;

    // reward distributor 
    address public rewardDistributor;

    // last reward block
    uint256 public lastRewardBlock;
    
    // only daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor(address daylight_) {
        daylight = daylight_;
        lastRewardBlock = block.number;
    }

    function trigger() external {

        // get amount to distribute
        uint256 amount = amountToDistribute();

        // reset timer
        lastRewardBlock = block.number;

        // leave if amount is zero
        if (amount == 0 || rewardDistributor == address(0)) {
            return;
        }

        // send tokens to reward distributor
        IERC20(daylight).transfer(rewardDistributor, amount);
    }

    function resetTimer() external onlyOwner {
        lastRewardBlock = block.number;
    }

    function setPercentPerBlock(uint newPercent) external onlyOwner {
        // ensure new percent is valid
        percentPerBlock = newPercent;
    }

    function setMaxPercent(uint maxPercent_) external onlyOwner {
        // ensure maximum percent is valid
        maxPercent = maxPercent_;
    }

    function setRewardDistributor(address rewardDistributor_) external onlyOwner {
        rewardDistributor = rewardDistributor_;
    }

    function amountToDistribute() public view returns (uint256) {
        uint percent = timeSince() * percentPerBlock;
        if (percent > maxPercent) {
            percent = maxPercent;
        }
        return ( balanceOf() * percent ) / 10**18;
    }

    function timeSince() public view returns (uint256) {
        return lastRewardBlock < block.number ? block.number - lastRewardBlock : 0;
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(daylight).balanceOf(address(this));
    }
}
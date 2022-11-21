//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IDaylight {
    function getOwner() external view returns (address);
}

interface IEmissions {
    function trigger() external;
}

interface IFarm {
    function depositRewards(uint256 amount) external;
}

contract RewardDistributor {

    // daylight token
    address public immutable daylight;

    // emission distributor
    address public immutable emissionDistributor;

    // Yield Farm
    address public farm;
    
    // only daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor(address daylight_, address emissionDistributor_) {
        daylight = daylight_;
        emissionDistributor = emissionDistributor_;
    }

    function trigger() external {

        // trigger emission distributor to receive tokens
        IEmissions(emissionDistributor).trigger();

        // get balance
        uint256 balance = IERC20(daylight).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        if (farm != address(0)) {
            IERC20(daylight).approve(farm, balance);
            IFarm(farm).depositRewards(balance);
        }
    }

    function reset() external onlyOwner {
        IERC20(daylight).transfer(emissionDistributor, IERC20(daylight).balanceOf(address(this)));
    }

    function setFarm(address farm_) external onlyOwner {
        farm = farm_;
    }

}
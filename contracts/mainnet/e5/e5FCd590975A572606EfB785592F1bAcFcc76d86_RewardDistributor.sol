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
    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;

    // emission distributor
    address public constant emissionDistributor = 0xfA5F9b81Ee35F679d2Cf0C569EfAcf8Cba7b00aC;

    // Yield Farm
    address public farm;
    address public longFarm;
    address public staking;

    // Percentages
    uint256 public farmPercent;
    uint256 public longFarmPercent;
    uint256 public stakingPercent;
    
    // only daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    function trigger() external {

        // trigger emission distributor to receive tokens
        IEmissions(emissionDistributor).trigger();

        // get balance
        uint256 balance = IERC20(daylight).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // denom for math
        uint256 DENOM = farmPercent + longFarmPercent + stakingPercent;
        if (DENOM == 0) {
            return;
        }

        // split amounts
        uint256 forFarm = ( balance * farmPercent ) / DENOM;
        uint256 forLongFarm = ( balance * longFarmPercent ) / DENOM;
        uint256 forStaking = balance - ( forFarm + forLongFarm );

        if (farm != address(0) && forFarm > 0) {
            IERC20(daylight).approve(farm, forFarm);
            IFarm(farm).depositRewards(forFarm);
        }

        if (longFarm != address(0) && forLongFarm > 0) {
            IERC20(daylight).approve(longFarm, forLongFarm);
            IFarm(longFarm).depositRewards(forLongFarm);
        }

        if (staking != address(0) && forStaking > 0) {
            IERC20(daylight).transfer(staking, forStaking);
        }
    }

    function setPercents(uint256 farm_, uint256 longFarm_, uint256 staking_) external onlyOwner {
        farmPercent = farm_;
        longFarmPercent = longFarm_;
        stakingPercent = staking_;
    }

    function reset(uint256 decrement) external onlyOwner {
        IERC20(daylight).transfer(emissionDistributor, IERC20(daylight).balanceOf(address(this)) - decrement);
    }

    function setFarm(address farm_) external onlyOwner {
        farm = farm_;
    }

    function setLongFarm(address farm_) external onlyOwner {
        longFarm = farm_;
    }

    function setStaking(address staking_) external onlyOwner {
        staking = staking_;
    }

}
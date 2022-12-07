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
    address public farm = 0x348e66555F85da4D84C80B917a17aeF7750705Bb;
    address public longFarm = 0x8f0E57e961b6B3C767F01A9d045C7457c22d338C;
    address public staking = 0x77fCC833fbb6e1e39262B817466041c183424867;
    address public mdbFarm = 0x6aB99fE4075361CD6063FF1f2B3d1bA2A5850930;

    // Percentages
    uint256 public farmPercent = 125;
    uint256 public longFarmPercent = 550;
    uint256 public stakingPercent = 75;
    uint256 public mdbFarmPercent = 250;

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
        uint256 DENOM = farmPercent + longFarmPercent + stakingPercent + mdbFarmPercent;
        if (DENOM == 0) {
            return;
        }

        // split amounts
        uint256 forFarm = ( balance * farmPercent ) / DENOM;
        uint256 forLongFarm = ( balance * longFarmPercent ) / DENOM;
        uint256 forMDB = ( balance * mdbFarmPercent ) / DENOM;

        if (farm != address(0) && forFarm > 0) {
            IERC20(daylight).approve(farm, forFarm);
            IFarm(farm).depositRewards(forFarm);
        }

        if (longFarm != address(0) && forLongFarm > 0) {
            IERC20(daylight).approve(longFarm, forLongFarm);
            IFarm(longFarm).depositRewards(forLongFarm);
        }

        if (mdbFarm != address(0) && forMDB > 0) {
            IERC20(daylight).approve(mdbFarm, forMDB);
            IFarm(mdbFarm).depositRewards(forMDB);
        }

        uint256 forStaking = IERC20(daylight).balanceOf(address(this));
        if (staking != address(0) && forStaking > 0) {
            IERC20(daylight).transfer(staking, forStaking);
        }
    }

    function setPercents(uint256 farm_, uint256 longFarm_, uint256 staking_, uint256 mdb_) external onlyOwner {
        farmPercent = farm_;
        longFarmPercent = longFarm_;
        stakingPercent = staking_;
        mdbFarmPercent = mdb_;
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

    function setMDBFarm(address mdb_) external onlyOwner {
        mdbFarm = mdb_;
    }

}
pragma solidity ^0.8.0;

interface IXPToken {
    function updatePlayerXP(address player) external returns (uint256);
}

interface IVolumeWars {
    function seasonExpiration() external view returns (uint256);
    function seasonDuration() external view returns (uint256);
}

contract AttackBonus {
    IXPToken xpToken;
    IVolumeWars volumeWars;

    event Attack(address indexed player, address indexed team, uint256 damage, uint256 amount);

    constructor (address _xptoken, address _volumeWars) {
        xpToken = IXPToken(_xptoken);
        volumeWars = IVolumeWars(_volumeWars);
    }

    // Days remaining in season
    function remainingSeasonDays() public view returns (uint256) {
        return (volumeWars.seasonExpiration() - block.timestamp) / 86400;
    }

    // Seconds to the next day
    function timeToNextDay() public view returns (uint256) {
        return (volumeWars.seasonExpiration() - block.timestamp) - (86400 * remainingSeasonDays()) / 86400;
    }

    // Next boost percentage, and seconds to next boost
    function nextBoost() external view returns (uint256[2] memory) {
        uint256 remainingDays = remainingSeasonDays();
        if (remainingDays == 0) {
            return [uint256(0), uint256(0)];
        }
        uint256 nextBoostPercentage = boostPercentageOnDaysRemaining(remainingDays-1);
        return [nextBoostPercentage, timeToNextDay()];
    }

    function currentBoostPercentage() external view returns (uint256) {
        return boostPercentageOnDaysRemaining(remainingSeasonDays());
    }

    function boostPercentageOnDaysRemaining(uint256 remainingDays) public pure returns (uint256) {
        return 100 + remainingDays * 10;
    }

    function applyAttackModifier(address player, address attackedTeam, uint256 rawAmount) external returns (uint256) {
        require(msg.sender == address(volumeWars), "Sender not VW");
        xpToken.updatePlayerXP(player);

        uint256 boostedDamage = (rawAmount * boostPercentageOnDaysRemaining(remainingSeasonDays())) / 100;
        emit Attack(player, attackedTeam, boostedDamage, rawAmount);
        return boostedDamage;
    }
}
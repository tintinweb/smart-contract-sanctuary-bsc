pragma solidity ^0.8.0;

interface IXPToken {
    function updatePlayerXP(address player) external returns (uint256);
}

contract AttackBonus {
    IXPToken xpToken;

    constructor (address _xptoken) {
        xpToken = IXPToken(_xptoken);
    }

    function applyAttackModifier(address player, address attackedTeam, uint256 rawAmount) external returns (uint256) {
        xpToken.updatePlayerXP(player);
        return rawAmount;
    }
}
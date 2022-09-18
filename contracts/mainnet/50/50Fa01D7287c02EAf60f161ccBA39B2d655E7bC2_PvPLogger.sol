/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//   /$$$$$$  /$$                 /$$                 /$$                           /$$
//  /$$__  $$| $$                |__/                | $$                          |__/
// | $$  \__/| $$$$$$$   /$$$$$$  /$$ /$$$$$$$       | $$        /$$$$$$   /$$$$$$  /$$  /$$$$$$  /$$$$$$$
// | $$      | $$__  $$ |____  $$| $$| $$__  $$      | $$       /$$__  $$ /$$__  $$| $$ /$$__  $$| $$__  $$
// | $$      | $$  \ $$  /$$$$$$$| $$| $$  \ $$      | $$      | $$$$$$$$| $$  \ $$| $$| $$  \ $$| $$  \ $$
// | $$    $$| $$  | $$ /$$__  $$| $$| $$  | $$      | $$      | $$_____/| $$  | $$| $$| $$  | $$| $$  | $$
// |  $$$$$$/| $$  | $$|  $$$$$$$| $$| $$  | $$      | $$$$$$$$|  $$$$$$$|  $$$$$$$| $$|  $$$$$$/| $$  | $$
//  \______/ |__/  |__/ \_______/|__/|__/  |__/      |________/ \_______/ \____  $$|__/ \______/ |__/  |__/
//                                                                        /$$  \ $$
//                                                                       |  $$$$$$/
//                                                                        \______/
// Chain Legion is an on-chain RPG project which uses NFT Legionnaires as in-game playable characters.
// There are 7,777 mintable tokens in total within this contract.
//
// Join the on-chain evolution at:
//      - chainlegion.com
//      - play.chainlegion.com
//      - t.me/ChainLegion
//      - twitter.com/ChainLegionNFT
//
// Contract made by Lizard Man, CEO of Chain Legion
//      - twitter.com/reallizardev
//      - t.me/lizardev

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.17 < 0.9.0;

/** @dev Public log for gathering battle data */
struct ExposedBattleLog {
    bool    isVictory;
    uint256 opponentId;
    uint256 totalTurns;
    uint256 damageDealt;
    uint256 damageTaken;
}

struct Log {
    uint128 wins;
    uint128 losses;
}

interface IPvPLogger {

    function log(uint256 winner, uint256 loser,
                 ExposedBattleLog calldata, ExposedBattleLog calldata) external;

}

interface IIdentityProviderV2 {

    function requireEOA(address address_) external view;

    function requireContract(address address_) external view;

}

abstract contract UpdateableIdentityDependency {

    IIdentityProviderV2 private __ipv2;

    constructor (address ipv2_) {
        __ipv2 = IIdentityProviderV2(ipv2_);
    }

    function updateIdentityProvider(address newAddress_) external {
        __ipv2.requireEOA(msg.sender);
        __ipv2 = IIdentityProviderV2(newAddress_);
    }

    function _ipv2() internal view returns(IIdentityProviderV2) {
        return __ipv2;
    } 

}

/** 
    @dev This contract holds data about player victories.
    @dev Data MUST be migratable.
*/
contract PvPLogger is IPvPLogger, UpdateableIdentityDependency {

    mapping (uint256 => Log) public logs;

    /** @dev Emits when a match is finished. This will emit twice, for winner and loser. */
    event MatchFinished(uint256 indexed tokenId, ExposedBattleLog battleLog);

    constructor (address ipv2_) UpdateableIdentityDependency(ipv2_) {}

    function log(uint256 winner_,
                 uint256 loser_, 
                 ExposedBattleLog calldata winnerData_, 
                 ExposedBattleLog calldata loserData_) external override {
        _ipv2().requireContract(msg.sender);

        logs[winner_].wins += 1;
        logs[loser_].losses += 1;

        emit MatchFinished(winner_, winnerData_);
        emit MatchFinished(loser_, loserData_);
    }

}
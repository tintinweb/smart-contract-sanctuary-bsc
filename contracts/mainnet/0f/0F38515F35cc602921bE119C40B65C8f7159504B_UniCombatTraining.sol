/**
 *Submitted for verification at BscScan.com on 2022-10-17
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

pragma solidity 0.8.17;


abstract contract SimpleOwnable {
    
    address private immutable __owner;

    constructor () {
        __owner = msg.sender;
    }

    function _onlyOwner() internal view {
        require (msg.sender == __owner, "SimpleOwnable: Ownership required.");
    }

    function _owner() internal view returns(address) {
        return __owner;
    }

}


library FundTransfer {

    function _sendFunds(address recipient_, uint256 amount_) internal {
        (bool success, ) = payable(recipient_).call{value: amount_}("");
        require (success, "FundTransfer: Failed to send.");
    }

}


abstract contract PayableV2 is SimpleOwnable {
    using FundTransfer for address;

    uint256 public immutable fee;

    constructor (uint256 fee_) {
        fee = fee_;
    }

    function _requirePayment() internal {
        require (msg.value >= fee, "PayableV2: Insufficient msg.value");
    }

    function withdrawAll() external {
        _owner()._sendFunds(address(this).balance);
    }

}


/**
    @dev Provides functions to manipulate XP points.
 */
interface IExperienceModifier {

    /** @dev Adds the given amount of XP points to the given token id */
    function addExperiencePoints(uint256 amount, uint256 id) external;

}


/**
    @dev Functions to read level and xp data.
 */
interface IExperienceTracker {

    function isInitialized(uint256 tokenId) external view returns(bool);

    function getLevel(uint256 tokenId) external view returns(uint256);

    function getXp(uint256 tokenId) external view returns(uint256);

}


contract UniCombatTraining is PayableV2 {

    constructor (address xp_, uint256 fee_, uint256[] memory levels_, uint256[] memory xpAmounts_, uint256 cooldown_) PayableV2(fee_) {
        cooldown = cooldown_;
        __xpMod = IExperienceModifier(xp_);
        __xpTracker = IExperienceTracker(xp_);
        
        require (levels_.length == xpAmounts_.length);
        for (uint256 i = 0; i < levels_.length; i++) {
            xpAmounts[levels_[i]] = xpAmounts_[i];
        }
    }

    mapping (uint256 => uint256) public xpAmounts;
    mapping (uint256 => uint256) public logs;
    
    uint256 public cooldown;

    IExperienceModifier private immutable __xpMod;
    IExperienceTracker private immutable __xpTracker;

    function setXpForLevel(uint256 level_, uint256 xpAmount_) external {
        _onlyOwner();
        require (level_ % 5 == 0, "UCT: Level has to be a multiple of 5.");
        xpAmounts[level_] = xpAmount_;
    }

    function setCooldown(uint256 cooldown_) external {
        _onlyOwner();
        cooldown = cooldown_;
    }

    function performSession(uint256 tokenId_) external payable {
        _requirePayment();
        uint256 level = __xpTracker.getLevel(tokenId_);
        require (level > 0, "UCT: Token not initialized.");
        uint256 xpCategory = (level - (level % 5));
        uint256 xpPerSession = xpAmounts[xpCategory];

        uint256 currentTime = block.timestamp;
        uint256 logTimestamp = logs[tokenId_];
        require (currentTime - logTimestamp > cooldown, "UCT: Cooldown active.");
        
        logs[tokenId_] = currentTime;
        __xpMod.addExperiencePoints(xpPerSession, tokenId_);
    }

}
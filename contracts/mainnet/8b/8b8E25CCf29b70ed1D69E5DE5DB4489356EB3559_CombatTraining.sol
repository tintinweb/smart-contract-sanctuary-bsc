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
pragma solidity >= 0.8.15 < 0.9.0;


library ContractDetector {

    function _isContract(address address_) internal view returns(bool) {
        return (address_.code.length > 0);
    }

}

contract IdentityProviderV2 {
    using ContractDetector for address;

    mapping (address => bool) private __eoa;
    mapping (address => bool) private __contracts;

    constructor() {
        __eoa[msg.sender] = true;
    }

    function setEOA(address address_, bool state_) external {
        requireEOA(msg.sender);
        __eoa[address_] = state_;
    }

    function setContract(address address_, bool state_) external {
        requireEOA(msg.sender);
        require (address_._isContract(), "IdentityProviderV2: Cannot add EOA address as contract authority.");
        __contracts[address_] = state_;
    }

    function requireEOA(address address_) public view {
        require (__eoa[address_], "IdentityProviderV2: Not an EOA authority.");
    }

    function requireContract(address address_) external view {
        require (__contracts[address_], "IdentityProviderV2: Not a contract authority.");
    }

}

library FundTransfer {

    function _sendFunds(address recipient_, uint256 amount_) internal {
        (bool success, ) = payable(recipient_).call{value: amount_}("");
        require (success, "FundTransfer: Failed to send.");
    }

}

abstract contract PayableContract {
    using FundTransfer for address;

    uint256 private immutable __fee;
    IdentityProviderV2 private immutable __ipv2;

    constructor (uint256 fee_, address ipv2Address_) {
        __fee = fee_;
        __ipv2 = IdentityProviderV2(ipv2Address_);
    }

    modifier withFee {
        require (msg.value >= __fee);
        _;
    }

    function fee() public view returns(uint256) {
        return __fee;
    }

    function withdrawAll() external {
        address caller = msg.sender;
        __ipv2.requireEOA(caller);
        caller._sendFunds(address(this).balance);
    }

}

/**
    @dev Provides functions to manipulate XP points.
 */
interface IExperienceModifier {

    /** @dev Adds the given amount of XP points to the given token id */
    function addExperiencePoints(uint256 amount, uint256 id) external;

}

contract CombatTraining is PayableContract {

    constructor(uint256 xpPerQuest_,
                address xpContractAddress_,
                uint256 fee_,
                address ipv2Address_)
    PayableContract(fee_, ipv2Address_) {
        XP_PER_SESSION = xpPerQuest_;
        __xpMod = IExperienceModifier(xpContractAddress_);
    }

    /** @dev Defines the amount of XP to be gained from completing ONE daily quest */
    uint256 public immutable XP_PER_SESSION;
    IExperienceModifier private immutable __xpMod;

    /** @dev Map with timestamps from when tokens performed their last daily quest */
    mapping (uint256 => uint256) public questLogs;

    /**
        @dev Performs a daily quest and increments the XP amount in the XPContract.
        @dev Will revert if the previous CT timestamp is within a 24h period.
     */
    function performSession(uint256 tokenId_) external payable withFee {
        __beforeSessionHook(tokenId_);
        __xpMod.addExperiencePoints(XP_PER_SESSION, tokenId_);
    }

    function __beforeSessionHook(uint256 tokenId_) private {
        uint256 currentTime = block.timestamp;
        uint256 questLogTimestamp = questLogs[tokenId_];
        require (currentTime - questLogTimestamp > 8 hours, "CombatTraining: 8h cooldown active");
        questLogs[tokenId_] = currentTime;
    }

}
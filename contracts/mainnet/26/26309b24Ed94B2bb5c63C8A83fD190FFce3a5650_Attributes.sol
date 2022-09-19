/**
 *Submitted for verification at BscScan.com on 2022-09-19
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

pragma solidity >= 0.8.17 < 0.9.0;

// SPDX-License-Identifier: MIT

struct AttributeBundle {
    uint64 strength;
    uint64 constitution;
    uint64 haste;
    uint64 lethality;
}

interface IAttributeReader {

    function get(uint256 tokenId) external view returns(AttributeBundle memory);

}

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
    @dev Defines ownership function for ERC721 tokens.
 */
interface IERC721Ownable {

    /** @dev Returns the current owner of the given ERC721 token id */
    function ownerOf(uint256 tokenId) external view returns (address);

}

abstract contract ERC721Ownable {

    IERC721Ownable internal immutable _mint;

    constructor (address address_) {
        _mint = IERC721Ownable(address_);
    }

    function _onlyOwnerOf(uint256 tokenId_) internal view {
        address owner = _mint.ownerOf(tokenId_);
        require (owner == msg.sender, "ERC721Ownable: Ownership required.");
    }

}

/**
    @dev Functions to read level and xp data.
 */
interface IExperienceTracker {

    function isInitialized(uint256 tokenId) external view returns(bool);

    function getLevel(uint256 tokenId) external view returns(uint256);

    function getXp(uint256 tokenId) external view returns(uint256);

}

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

contract Attributes is IAttributeReader,
                       PayableV2, 
                       ERC721Ownable {

    /** @dev Maps token ids to their respective Attribute structs */
    mapping (uint256 => AttributeBundle) private __attrs;

    /** @dev XP contract read-only reference */
    IExperienceTracker immutable private __xpTracker;
    
    constructor (uint256 fee_, address mintAddress_, address xpAddress_) 
        PayableV2(fee_) 
        ERC721Ownable(mintAddress_) 
    { 
        __xpTracker = IExperienceTracker(xpAddress_);
    }

    /** @dev Adds the given bundle of attributes to the existing stats */
    function addAttributes(AttributeBundle calldata a_, uint256 tokenId_) external {
        _onlyOwnerOf(tokenId_);
        uint256 level = __xpTracker.getLevel(tokenId_);
        require (level > 0, "Attr: Token not initialized.");

        AttributeBundle storage c = __attrs[tokenId_];
        __aggregateAttributePoints(c, a_);

        require (
            calculateTotalAttributesForLevel(level) >= __countTotalAttributePoints(c), 
            "Attr: Insufficient level."
        );
    }

    /** @dev See `IAttributeReader.get(tokenId)` */
    function get(uint256 tokenId_) external view override returns(AttributeBundle memory) {
        return __attrs[tokenId_];
    }

    /** @dev Resets the attributes for the given token id */
    function resetAttributes(uint256 tokenId_) external payable {
        _onlyOwnerOf(tokenId_);
        _requirePayment();
        delete __attrs[tokenId_];
    }

    uint256[] private __PRECOMPUTED = [
        100000,
        105000,
        110250,
        115763,
        121551,
        127628,
        134010,
        140710,
        147746,
        155133,
        162889
    ];

    function calculateTotalAttributesForLevel(uint256 level_) public view returns(uint64) {
        unchecked {
            uint256 base = 20;
            uint256 n = level_ - 1;
            uint256 y = base * __PRECOMPUTED[n % 10];
            n = n - n % 10;
            while (n > 0) {
                y = y * __PRECOMPUTED[10] / 100_000;
                n = n - 10;
            }
            if (y % 100_000 >= 50_000) {
                return uint64(y / 100_000) + 1;
            }
            else {
                return uint64(y / 100_000);
            }            
        }
    }

    function __countTotalAttributePoints(AttributeBundle storage a_) private view returns(uint64) {
        unchecked {
            return a_.strength + a_.constitution + a_.haste + a_.lethality;
        }
    }

    function __aggregateAttributePoints(AttributeBundle storage c_, 
                                        AttributeBundle calldata a_) private {
        unchecked {
            c_.strength     += a_.strength;
            c_.constitution += a_.constitution;
            c_.haste        += a_.haste;
            c_.lethality    += a_.lethality;
        }
    }

}
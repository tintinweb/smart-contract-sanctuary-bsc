// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./UmblCoreDataObjects.sol";
import "./UmblCoreEvents.sol";
import "./UmblCore.sol";
import "./UmblCoreEnums.sol";

contract UmblMarketPlace is UmblCoreEnums, UmblCoreDataObjects, UmblCoreEvents, Ownable, ReentrancyGuard {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;

    // Contract name
    string public name = "Umbrella MarketPlace";

    // Contract symbol
    string public symbol = "UmblMarket";

    // address public paymentContract = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // testnet BUSD
    address public paymentContract = 0x09d8AF358636D9BCC9a3e177B66EB30381a4b1a8; // testnet ZAPB

    UmblCore public umblCore;
    
    // Flag for main functions
    bool public isMarketPlaceFlag = false;

    constructor(UmblCore _umblCore) {
        umblCore = _umblCore;        
    }

    /**
    * @dev Buy Cityplot
    * @param _id  Crate ID to mint
    */
    function buyCityPlot(
        uint256 _id // preset id of cityplot
    ) external payable {

        require(isMarketPlaceFlag == true, "UmblMarketPlace#buyCityPlot: MARKETPLACE_DISABLED");

        require(msg.sender != owner(), "UmblMarketPlace#buyCityPlot: INVALID_ADDRESS");

        // check _crateId
        require(_id <= uint256(umblCore.nextPresetId()), "UmblMarketPlace#buyCityPlot: NONEXISTENT_CITYPLOT");

        (, uint8 tokenType, , , , , , , uint256 cityPlotPrice, bool isDeleted) = umblCore.getPreset(_id);
        
        require(tokenType == uint8(TokenType.ZONE), "UmblMarketPlace#buyCityPlot: INVALID_CITYPLOT");

        require(isDeleted == false, "UmblMarketPlace#buyCityPlot: DELETED_CITYPLOT");

        // pay with BUSD for the crate price
        address payable ownerAddress = payable(owner());
        
        // check price
        ERC20 busdContract = ERC20(paymentContract);
        require(busdContract.balanceOf(msg.sender) >= cityPlotPrice, "UmblMarketPlace#buyCityPlot: NOENOUGH_BALANCE");
        
        uint256 allowance = busdContract.allowance(msg.sender, address(this));
        require(allowance >= cityPlotPrice, "UmblMarketPlace#buyCityPlot: INVALID_ALLOWANCE");
        require(busdContract.transferFrom(msg.sender, ownerAddress, cityPlotPrice));

        uint256[] memory mintPresetIds = new uint256[](1);
        uint256[] memory mintTokenAmounts = new uint256[](1);

        mintPresetIds[0] = _id;
        mintTokenAmounts[0] = 1;

        address[] memory mintAddress = new address[](1);
        mintAddress[0] = msg.sender;

        umblCore.mintBatchPresets(mintAddress, mintPresetIds, mintTokenAmounts);
    }

    /**
    * @dev Buy crate
    * @param _id          Crate ID to mint
    */
    function buyCrate(
        uint256             _id,
        uint256[] memory    _presetIds
    ) external payable {

        require(isMarketPlaceFlag == true, "UmblMarketPlace#buyCrate: MARKETPLACE_DISABLED");

        require(msg.sender != owner(), "UmblMarketPlace#buyCrate: INVALID_ADDRESS");

        // check _crateId
        require(_id <= uint256(umblCore.nextCrateId()), "UmblMarketPlace#buyCrate: NONEXISTENT_CRATE");

        (, , , , uint8 crateTokenCount, uint256 cratePrice, bool crateIsDeleted) = umblCore.getCrate(_id);
        
        require(crateIsDeleted == false, "UmblMarketPlace#buyCrate: DELETED_CRATE");

        require(_presetIds.length == crateTokenCount, "UmblMarketPlace#buyCrate: INVALID PRESET COUNT");
        
        // pay with BUSD for the crate price
        address payable ownerAddress = payable(owner());
        
        // check price
        ERC20 busdContract = ERC20(paymentContract);
        require(busdContract.balanceOf(msg.sender) >= cratePrice, "UmblMarketPlace#buyCrate: NOENOUGH_BALANCE");
        
        uint256 allowance = busdContract.allowance(msg.sender, address(this));
        require(allowance >= cratePrice, "UmblMarketPlace#buyCrate: INVALID_ALLOWANCE");
        require(busdContract.transferFrom(msg.sender, ownerAddress, cratePrice));

        emit UmblPaidForCrate(msg.sender, _id, cratePrice);
        
        // mintCrateTokens(msg.sender, _id, crateFaction, crateRarities, crateTokenCount);

        uint256[] memory mintTokenAmounts = new uint256[](crateTokenCount);
    
        for(uint i=0; i<crateTokenCount; i++) {
            mintTokenAmounts[i] = 1;
        }

        address[] memory mintAddress = new address[](1);
        mintAddress[0] = msg.sender;

        umblCore.mintBatchPresets(mintAddress, _presetIds, mintTokenAmounts);
    }
    
    /**
    * @dev Set marketplace flag
    * @param _newState bool
    */
    function setMarketPlaceFlag(
        bool _newState
    ) public onlyOwner {
        
        isMarketPlaceFlag = _newState;
        
        emit UmblMarketPlaceFlagUpdated(owner(), isMarketPlaceFlag);
    }

    /**
    * @dev Set payment contract 
    * @param _newPaymentContract address
    */
    function setPaymentContract(
        address _newPaymentContract
    ) public onlyOwner {
        
        paymentContract = _newPaymentContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UmblCoreEnums {
    
    enum TokenType { NONE, CHARACTER, OBJECT, BADGE, ZONE }

    enum State { NONE, ADMIN_OWNED, USER_OWNED, USER_EQUIPPED, USER_STAKED, BURNED }

    enum Faction { NONE, SURVIVORS, SCIENTISTS }

    enum Category { NONE, WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS }

    enum Rarity { NONE, COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL }

    enum Badge { NONE, BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND }

    enum Zone { NONE, S1, S1b, S2, S2b, S3, S4, S5, S6 }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./UmblBase.sol";

contract UmblCore is UmblBase, ERC1155 {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;
    
    // Contract name
    string public name = "Umbrella Core";

    // Contract symbol
    string public symbol = "UmblCore";

    // Metadata URI     
    // string private baseMetadataUri = "https://portal.umbrellaproject.cc/metadata/";
    string private baseMetadataUri = "http://portal.umbrellaproject.localhost/metadata/";  

    // Marketplace contract address
    address public marketPlaceContract = address(0x0);

    // total supply mapping for each tokenId
    mapping (uint256 => uint256) public tokenSupply;

    // Flag for marketplace function (sell & resell)
    bool public isResaleFlag = false;

    /**
    * @dev Require msg.sender to be allowed marketplace contract
    */
    modifier marketAndOwnerOnly {
        require(marketPlaceContract != address(0x0), "UmblCore#marketOnly: MARKET_CONTRACT_NOTDEFINED");
        require(msg.sender == marketPlaceContract || msg.sender == owner(), "UmblCore#marketOnly: INVALID_ADDRESS");
        _;
    }

    constructor() ERC1155(baseMetadataUri) {
        
    }

    /**
    * @dev Set marketplace contract address
    * @param _to    Address of the marketplace contract
    */
    function setMarketPlaceContract(
        address _to
    ) external onlyOwner {

        require(_to != address(0x0), "UmblCore#setMarketPlaceContract: MARKET_CONTRACT_INVALID");

        marketPlaceContract = _to;

        emit UmblMarketPlaceContractUpdated(owner(), marketPlaceContract);
    }

    /**
    * @dev Mints tokens in Presets    
    * @param _to            address Address of the future owner of the tokens
    * @param _ids           uint256 array Preset IDs to mint
    * @param _amounts       uint256 array Token amounts to mint
    */
    function mintBatchPresets(
        address[] memory    _to,
        uint256[] memory    _ids,
        uint256[] memory    _amounts
    ) external marketAndOwnerOnly {
        
        require(msg.sender == marketPlaceContract || msg.sender == owner(), "UmblCore#mintBatchPresets: INVALID_ADDRESS");

        // check _to address
        for(uint i=0; i<_to.length; i++)
            require(_to[i] != address(0x0), "UmblCore#mintBatchPresets: INVALID_ADDRESS");

        // check _id
        for(uint i=0; i<_ids.length; i++)
            require(_ids[i] <= nextPresetId, "UmblCore#mintBatchPresets: NONEXISTENT_PRESET");
        
        // calculate amounts
        uint256 totalAmount = 0;
        for(uint i=0; i<_amounts.length; i++)
            totalAmount += _amounts[i];

        uint256[] memory mintedTokenIds = new uint256[](totalAmount * _to.length);
        uint256 mintedTokenIndex = 0;

        // mint tokens
        for(uint k=0; k<_to.length; k++) {
            for(uint i=0; i<_ids.length; i++) {
                // uint256 _id = _ids[i];
                // uint256 _amount = _amounts[i];

                UmblPreset memory presetData = presetUmblData[_ids[i]];
                // uint256 tokenId = presetData.id;

                // mint token according to the tokenId and assign it to user
                _mint(_to[k], presetData.id, _amounts[i], "");

                // increase total supply of the tokenId
                tokenSupply[presetData.id] = tokenSupply[presetData.id].add(_amounts[i]);

                uint8 tokenState = uint8(State.USER_OWNED);
                if(_to[k] == owner()) tokenState = uint8(State.ADMIN_OWNED);

                for(uint j=0; j<_amounts[i]; j++) {
                    // increase next token ID
                    nextTokenId++;

                    // create a new token struct and pass it new values
                    UmblToken memory newUmblToken = UmblToken(
                        nextTokenId,
                        presetData.id,
                        _to[k],
                        presetData.tokenType,
                        presetData.faction,
                        presetData.category,
                        presetData.rarity,
                        tokenState,
                        uint8(100),
                        presetData.price,
                        false
                    );

                    // add the token id and it's struct to all tokens mapping
                    tokenUmblData[nextTokenId] = newUmblToken;

                    mintedTokenIds[mintedTokenIndex++] = nextTokenId;
                }
            }
            
        }

        emit UmblPresetMinted(msg.sender, _to, _ids, mintedTokenIds, _amounts);
    }

    /**
    * @dev Get metadata uri
    * @param _id uint256 ID of token type
    */
    function uri(
        uint256 _id
    ) public override(ERC1155) view returns (string memory) {
        require(_id <= nextTokenId, "UmblCore#uri: NONEXISTENT_TOKEN");

        UmblToken memory umblTokenData = tokenUmblData[_id];

        require(_exists(umblTokenData.presetId), "UmblCore#uri: NONEXISTENT_TOKEN");

        return string(abi.encodePacked(
            baseMetadataUri,
            Strings.toString(_id)
        ));
    }

    /**
    * @dev Returns the total quantity for a token ID
    * @param _id uint256 ID of the token to query
    * @return amount of token in existence
    */
    function totalSupply(
        uint256 _id
    ) public view returns (uint256) {
        return tokenSupply[_id];
    }

    /**
    * @dev Will update the base URL of token's URI
    * @param _newBaseMetadataURI New base URL of token's URI
    */
    function setBaseMetadataURI(
        string memory _newBaseMetadataURI
    ) public onlyOwner {
        baseMetadataUri = _newBaseMetadataURI;
    }

    /**
    * @dev Returns whether the specified token exists by checking to see if it has a total supply
    * @param _id uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
    function _exists(
        uint256 _id
    ) internal view returns (bool) {
        return tokenSupply[_id] != 0;
    }

    /**
    * @dev Set marketplace flag
    * @param _newState bool
    */
    function setResaleFlag(
        bool _newState
    ) public onlyOwner {
        
        isResaleFlag = _newState;
        
        emit UmblResaleFlagUpdated(owner(), isResaleFlag);
    }
    
    /**
    * @dev Update UMBLTOKEN item state
    * @param _id uint256 ID of token
    * @param _owner address new owner
    * @param _state uint8 new state
    * @param _health uint8 new health
    * @param _price uint256 new price
    * @param _isSale bool new flag for sale
    */
    function updateTokenData(
        uint256 _id,
        address _owner,
        uint8   _state,
        uint8   _health,
        uint256 _price,
        bool    _isSale
    ) external {
        require(_id <= nextTokenId, "UMBLBASE#updateTokenData: NONEXISTENT_TOKEN");

        // get the token from all UmblData mapping and create a memory of it as defined
        UmblToken memory umblToken = tokenUmblData[_id];
        
        require(msg.sender == owner() || msg.sender == umblToken.owner || msg.sender == marketPlaceContract, "UMBLBASE#updateTokenData: INVALID_PERMISSION");
        
        umblToken.owner     = _owner;
        umblToken.state     = _state;
        umblToken.health    = _health;
        umblToken.price     = _price;
        umblToken.isSale    = _isSale;

        // set and update that token in the mapping
        tokenUmblData[_id] = umblToken;

        emit UmblTokenDataUpdated(msg.sender, _id, _owner, _state, _health, _price, _isSale);
    }   
    
    /**
    * @dev Assign tokens in List   
    * @param _to            address Address of the future owner of the tokens
    * @param _ids           uint256 array token IDs to assign
    */
    function assignBatchToken(
        address[]   memory    _to,
        uint256[][] memory    _ids
    ) external onlyOwner {

        // check _to address
        for(uint i=0; i<_to.length; i++)
            require(_to[i] != address(0x0) && _to[i] != owner(), "UmblCore#assignBatchPresets: INVALID_ADDRESS");
            
        
        // check _id
        for(uint i=0; i<_ids.length; i++)
            for(uint j=0; j<_ids[i].length; j++)
                require(_ids[i][j] <= nextTokenId, "UmblCore#assignBatchPresets: NONEXISTENT_TOKEN");

        // assign tokens
        for(uint i=0; i<_ids.length; i++) {
            uint[] memory presetList = new uint[](_ids[i].length);
            uint[] memory amountList = new uint[](_ids[i].length);
            for(uint j=0; j<_ids[i].length; j++) {
                UmblToken memory tokenData = tokenUmblData[_ids[i][j]];
                
                presetList[j] = tokenData.presetId;
                amountList[j] = 1;
                
                tokenData.owner     = _to[i];
                tokenData.state     = uint8(State.USER_OWNED);
                
                tokenUmblData[_ids[i][j]] = tokenData;
            }
            safeBatchTransferFrom(owner(), _to[i], presetList, amountList, "");
        }

        emit UmblTokenListAssigned(msg.sender, _to, _ids);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UmblCoreEvents {

    using SafeMath for uint256;

    event UmblPresetCreated (
        address owner,
        uint256 id
    );

    event UmblPresetUpdated (
        address owner,
        uint256 id
    );

    event UmblPresetDeleted (
        address owner,
        uint256 id
    );

    event UmblCrateCreated (
        address owner,
        uint256 id
    );

    event UmblCrateUpdated (
        address owner,
        uint256 id
    );

    event UmblCrateDeleted (
        address owner,
        uint256 id
    );

    event UmblPackageCreated (
        address owner,
        uint256 id
    );

    event UmblPackageUpdated (
        address owner,
        uint256 id
    );

    event UmblPackageDeleted (
        address owner,
        uint256 id
    );

    event UmblTokenDataUpdated (
        address owner,
        uint256 id,
        address newOwner,
        uint8   newState,
        uint8   newHealth,
        uint256 newPrice,
        bool    newIsSale
    );

    event UmblMarketPlaceContractUpdated (
        address owner,
        address marketPlaceContract
    );

    event UmblCrateMinted (
        address owner,
        uint256 id,
        uint256[] tokenIds 
    );

    event UmblPackageMinted (
        address owner,
        uint256 id,
        uint256[] tokenIds 
    );

    event UmblPresetMinted (
        address owner,
        address[] to,
        uint256[] presetIds,
        uint256[] tokenIds,
        uint256[] amount
    );
    
    event UmblPaidForCrate (
        address owner,
        uint256 id,
        uint256 price
    );

    event UmblResaleFlagUpdated (
        address owner,
        bool isResaleFlag
    );
    
    event UmblMarketPlaceFlagUpdated (
        address owner,
        bool    isMarketPlaceFlag
    );

    event UmblTokenListAssigned (
        address owner,
        address[] to,
        uint256[][] ids
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./UmblCoreEnums.sol";

contract UmblCoreDataObjects is UmblCoreEnums {

    using SafeMath for uint8;
    using SafeMath for uint256;

    struct UmblToken {
        // token id of object
        uint256 id;
        // preset id of object
        uint256 presetId;
        // owner address
        address owner;
        // character level => (1 ~ 6)
        uint8 level;
        // token faction => SURVIVORS, SCIENTISTS
        uint8 faction;
        // token category => WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS
        uint8 category;
        // token rarity
        uint8 rarity;
        // token state => ADMIN_OWNED, USER_OWNED, USER_EQUIPPED, USER_STAKED, BURNED, etc
        uint8 state;     
        // health value of the token (0 ~ 100)
        uint8 health;  
        // price of the token
        uint256 price;
        // sale flag
        bool isSale;
    }

    struct UmblCrate {
        // crate id
        uint256 id;
        // crate level
        uint8 level;
        // crate faction
        uint8 faction;
        // array of rarities for the crate             
        uint8[] rarities;
        // token count inside the crate         
        uint8 tokenCount;
        // price of the crate
        uint256 price;
        // crate object flag for enabling         
        bool isDeleted;
    }

    struct UmblPreset {
        // preset id
        uint256 id;
        // token type => CHARACTER, OBJECT, BADGE, ZONE
        uint8 tokenType;
        // preset level
        uint8 level;     
        // preset token faction
        uint8 faction;
        // preset token category
        uint8 category;
        // preset token rarity
        uint8 rarity;
        // preset badge type
        uint8 badgeType;
        // preset zone type
        uint8 zoneType;
        // preset price
        uint256 price;
        // preset object flag for enabling
        bool isDeleted;
    }    

    struct UmblPackage {
        // package id
        uint256 id; 
        // token count inside the package
        uint8 tokenCount;
        // array of preset ids for the package
        uint256[] presetIds;
        // start time of the package
        uint256 startTime;
        // end time of the package
        uint256 endTime;         
        // price of the package
        uint256 price;
        // package object flag for enabling
        bool isDeleted;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./UmblCoreEvents.sol";
import "./UmblCoreDataStorages.sol";

/**
 * @title UmblBase
 * UmblBase - a contract for Umbl Core Basement.
 */

contract UmblBase is UmblCoreDataStorages, UmblCoreEvents, Ownable, ReentrancyGuard {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;

    uint256 constant PRESET_MAX_LEVEL_VALUE     = 100;
    uint256 constant CRATE_MAX_RARITY_LENGTH    = 10;
    uint256 constant CRATE_MAX_TOKEN_COUNT      = 100;
    uint256 constant PACKAGE_MAX_PRESET_COUNT   = 100;
    
    /**
    * @dev Add and update UMBLPRESET item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _tokenType uint8 type of preset (CHARACTER, OBJECT, BADGE, ZONE)
    * @param _level uint8 level of preset (1 ~ 6)
    * @param _faction uint8 faction (SURVIVORS, SCIENTISTS)
    * @param _category uint8 category (WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS)
    * @param _rarity uint8 rarity (COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL)
    * @param _badgeType uint8 badgeType (BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND)
    * @param _zoneType uint8 zoneType (S1, S1b, S2, S2b, S3, S4, S5, S6)
    * @param _price uint256 price
    */
    function makePreset(
        uint256 _id,
        uint8   _tokenType,
        uint8   _level,          
        uint8   _faction,
        uint8   _category,
        uint8   _rarity,
        uint8   _badgeType,
        uint8   _zoneType,
        uint256 _price
    ) public onlyOwner nonReentrant {

        bool isCreation;
        uint256 presetId;

        // check token type in preset
        require(_tokenType <= uint8(TokenType.ZONE), "UMBLBASE#makePreset: INVALID_TOKENTYPE");
        // check level
        require(_level <= PRESET_MAX_LEVEL_VALUE, "UMBLBASE#makePreset: INVALID_LEVEL_VALUE");
        // check faction
        require(_faction <= uint8(Faction.SCIENTISTS), "UMBLBASE#makePreset: INVALID_FACTION");
        // check category
        require(_category <= uint8(Category.VIRUS_VARIANTS), "UMBLBASE#makePreset: INVALID_CATEGORY");
        // check rarity
        require(_rarity <= uint8(Rarity.MYTHICAL), "UMBLBASE#makePreset: INVALID_RARITY");
        // check badgeType
        require(_badgeType <= uint8(Badge.BLACK_DIAMOND), "UMBLBASE#makePreset: INVALID_BADGETYPE");
        // check zoneType
        require(_zoneType <= uint8(Zone.S6), "UMBLBASE#makePreset: INVALID_ZONETYPE");
        // check price
        require(_price > 0, "UMBLBASE#makePreset: INVALID_PRICE");

        if(_id == 0) { // creation of new preset
            nextPresetId++;
            presetId = nextPresetId;
            isCreation = true;
        } else {
            require(_id <= nextPresetId, "UMBLBASE#makePreset: NONEXISTENT_PRESET");
            presetId = _id;
            isCreation = false;
        }

        UmblPreset memory newPresetData = UmblPreset(
            presetId,
            _tokenType,
            _level,
            _faction,
            _category,
            _rarity,
            _badgeType,
            _zoneType,
            _price,
            false                    
        );

        presetUmblData[presetId] = newPresetData;

        if(isCreation) {
            emit UmblPresetCreated(msg.sender, presetId);
        } else {
            emit UmblPresetUpdated(msg.sender, presetId);
        }
    }

    /**
    * @dev Delete UMBLPRESET item
    * @param _id uint256 ID of preset
    */
    function deletePreset(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextPresetId, "UMBLBASE#deletePreset: NONEXISTENT_PRESET");

        UmblPreset memory presetData = presetUmblData[_id];

        presetData.isDeleted = true;

        presetUmblData[_id] = presetData;

        emit UmblPresetDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLPRESET item
    * @param _id uint256 ID of preset
    */
    function getPreset(
        uint256 _id
    ) public view returns (
        uint256     id,
        uint8       tokenType,
        uint8       level,
        uint8       faction,
        uint8       category,
        uint8       rarity,
        uint8       badgeType,
        uint8       zoneType,
        uint256     price,
        bool        isDeleted
    ) {

        require(_id <= nextPresetId, "UMBLBASE#getPreset: NONEXISTENT_PRESET");

        UmblPreset memory presetData = presetUmblData[_id];

        return (
            presetData.id,
            presetData.tokenType,
            presetData.level,
            presetData.faction,
            presetData.category,
            presetData.rarity,
            presetData.badgeType,
            presetData.zoneType,
            presetData.price,
            presetData.isDeleted
        );
    }

    /**
    * @dev Add and update UMBLCRATE item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _faction uint8 faction (SURVIVORS, SCIENTISTS)
    * @param _rarities uint8 array rarity (COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL)
    * @param _tokenCount uint8 badgeType (BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND)
    * @param _price uint256 price
    */
    function makeCrate(
        uint256         _id,  
        uint8           _level,
        uint8           _faction,
        uint8[] memory  _rarities,
        uint8           _tokenCount,
        uint256         _price
    ) public onlyOwner nonReentrant {

        uint i;
        bool isCreation;
        uint256 crateId;        

        // check faction
        require(_faction == uint8(Faction.SURVIVORS) || _faction == uint8(Faction.SCIENTISTS), "UMBLBASE#makeCrate: INVALID_FACTION");
        // check rarities length
        require(_rarities.length > 0 && _rarities.length <= CRATE_MAX_RARITY_LENGTH, "UMBLBASE#makeCrate: INVALID_RARITY_LENGTH");
        // check rarities item value
        for(i=0; i<_rarities.length; i++) require(_rarities[i] >= uint8(Rarity.COMMON) && _rarities[i] <= uint8(Rarity.MYTHICAL), "UMBLBASE#makeCrate: INVALID_RARITY_VALUE");
        // check token count in crate
        require(_tokenCount > 0 && _tokenCount <= CRATE_MAX_TOKEN_COUNT, "UMBLBASE#makeCrate: INVALID_TOKENCOUNT");
        // check price
        require(_price > 0, "UMBLBASE#makeCrate: INVALID_PRICE");

        if(_id == 0) { // creation of new crate
            nextCrateId++;
            crateId = nextCrateId;
            isCreation = true;
        } else {
            require(_id <= nextCrateId, "UMBLBASE#makeCrate: NONEXISTENT_CRATE");
            crateId = _id;
            isCreation = false;
        }

        UmblCrate memory newCrateData = UmblCrate(
            crateId,
            _level,
            _faction,
            new uint8[](0), 
            _tokenCount,
            _price,
            false                    
        );

        crateUmblData[crateId] = newCrateData;

        for(i=0; i<_rarities.length; i++) {
            crateUmblData[crateId].rarities.push(uint8(_rarities[i]));
        }

        if(isCreation) {
            emit UmblCrateCreated(msg.sender, crateId);
        } else {
            emit UmblCrateUpdated(msg.sender, crateId);
        }
    }

    /**
    * @dev Delete UMBLCRATE item
    * @param _id uint256 ID of crate
    */
    function deleteCrate(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextCrateId, "UMBLBASE#deleteCrate: NONEXISTENT_CRATE");

        UmblCrate memory crateData = crateUmblData[_id];

        crateData.isDeleted = true;

        crateUmblData[_id] = crateData;

        emit UmblCrateDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLCRATE item
    * @param _id uint256 ID of preset
    */
    function getCrate(
        uint256 _id
    ) public view returns (
        uint256         id,
        uint8           level,
        uint8           faction,
        uint8[] memory  rarities,   
        uint8           tokenCount,
        uint256         price,       
        bool            isDeleted
    ) {

        require(_id <= nextCrateId, "UMBLBASE#getCrate: NONEXISTENT_CRATE");

        UmblCrate memory crateData = crateUmblData[_id];

        uint8[] memory _rarities = new uint8[](crateData.rarities.length);

        for(uint i=0; i<crateData.rarities.length; i++) {
            _rarities[i] = crateData.rarities[i];
        }

        return (
            crateData.id,
            crateData.level,
            crateData.faction,
            _rarities,
            crateData.tokenCount,
            crateData.price,
            crateData.isDeleted
        );
    }

    /**
    * @dev Add and update UMBLPACKAGE item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _tokenCount uint8 token count
    * @param _presetIds uint256 array presetIds
    * @param _startTime uint256 starttime of package
    * @param _endTime uint256 endtime of package
    * @param _price uint256 price
    */
    function makePackage(
        uint256             _id,   
        uint8               _tokenCount,
        uint256[] memory    _presetIds,
        uint256             _startTime,
        uint256             _endTime,
        uint256             _price
    ) public onlyOwner nonReentrant {

        uint i;
        bool isCreation;
        uint256 packageId;        

        // check token count
        require(_tokenCount > 0 && _tokenCount <= 100, "UMBLBASE#makePackage: INVALID_TOKENCOUNT");
        // check preset length
        require(_presetIds.length > 0 && _presetIds.length <= PACKAGE_MAX_PRESET_COUNT, "UMBLBASE#makePackage: INVALID_PRESET_LENGTH");
        // check rarities item value
        for(i=0; i<_presetIds.length; i++) 
            require(_presetIds[i] > 0 && _presetIds[i] <= nextPresetId, "UMBLBASE#makePackage: INVALID_PRESET_VALUE");        
        // check price
        require(_startTime < _endTime, "UMBLBASE#makePackage: INVALID_DATETIME");
        // check price
        require(_price > 0, "UMBLBASE#makePackage: INVALID_PRICE");

        if(_id == 0) { // creation of new crate
            nextPackageId++;
            packageId = nextPackageId;
            isCreation = true;
        } else {
            require(_id <= nextPackageId, "UMBLBASE#makePackage: NONEXISTENT_PACKAGE");
            packageId = _id;
            isCreation = false;
        }

        UmblPackage memory newPackageData = UmblPackage(
            packageId,
            _tokenCount,
            new uint256[](0), 
            _startTime,
            _endTime,
            _price,
            false                    
        );

        packageUmblData[packageId] = newPackageData;

        for(i=0; i<_presetIds.length; i++) {
            packageUmblData[packageId].presetIds.push(_presetIds[i]);
        }

        if(isCreation) {
            emit UmblPackageCreated(msg.sender, packageId);
        } else {
            emit UmblPackageUpdated(msg.sender, packageId);
        }
    }

    /**
    * @dev Delete UMBLPACKAGE item
    * @param _id uint256 ID of package
    */
    function deletePackage(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextPackageId, "UMBLBASE#deletePackage: NONEXISTENT_PACKAGE");

        UmblPackage memory packageData = packageUmblData[_id];

        packageData.isDeleted = true;

        packageUmblData[_id] = packageData;

        emit UmblPackageDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLPACKAGE item
    * @param _id uint256 ID of package
    */
    function getPackage(
        uint256 _id
    ) public view returns (
        uint256             id,
        uint8               tokenCount,
        uint256[] memory    presetIds,   
        uint256             startTime,
        uint256             endTime,
        uint256             price,       
        bool                isDeleted
    ) {

        require(_id <= nextPackageId, "UMBLBASE#getPackage: NONEXISTENT_PACKAGE");

        UmblPackage memory packageData = packageUmblData[_id];

        uint256[] memory _presetIds = new uint256[](packageData.presetIds.length);

        for(uint i=0; i<packageData.presetIds.length; i++) {
            _presetIds[i] = packageData.presetIds[i];
        }

        return (
            packageData.id,
            packageData.tokenCount,
            _presetIds,
            packageData.startTime,
            packageData.endTime,
            packageData.price,
            packageData.isDeleted
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./UmblCoreDataObjects.sol";

contract UmblCoreDataStorages is UmblCoreDataObjects {

    using SafeMath for uint256;    

    // map token id to token data
    mapping(uint256 => UmblToken) public tokenUmblData;    

    // map preset id to preset data
    mapping(uint256 => UmblPreset) public presetUmblData;    

    // map crate id to crate data
    mapping(uint256 => UmblCrate) public crateUmblData;    

    // map package id to package data
    mapping(uint256 => UmblPackage) public packageUmblData;

    uint256 public nextTokenId = 0;
    uint256 public nextPresetId = 0;
    uint256 public nextCrateId = 0;    
    uint256 public nextPackageId = 0;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
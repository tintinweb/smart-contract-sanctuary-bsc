// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// ERC1155 token holder helper contract. Allows us to receive ERC1155 token transfers
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

// Access control & security
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

// Upgradeable proxy
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Library providing an enumerable set
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

// The ERC1155 nft contract
import "../tokens/JurassicCryptoTokens.sol";

// The ERC20 token contract
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

// The Marketplace's storage
import "./JurassicMarketStorageUpgradeable.sol";

// HH debug


/// @custom:security-contact [email protected]
contract JurassicMarket is
        Initializable, AccessControlEnumerableUpgradeable, PausableUpgradeable, UUPSUpgradeable,
        ERC1155HolderUpgradeable,
        JurassicMarketStorageUpgradeable
    {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    //////////////////////////////////////////////////////////////////////////////////
    // This is the deployed contract, don't define any storage state variable here! //
    //////////////////////////////////////////////////////////////////////////////////
    ///////////////
    // constants //
    ///////////////
    // Roles
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // The ERC1155 NFT contract
    JurassicCryptoTokens constant JurassicTokens = JurassicCryptoTokens(0x566344f4015da9f5B3dF715B2948c97772815595);
    IERC20Upgradeable constant JRSC = IERC20Upgradeable(0x3310e43dC1104D3CF5ABf81c9c2D08415AD9b092);
    address constant OWNER = 0x9D8E4579A1e1B03233ed1A6f0Ba3901e2Dc7B14e;

    // The tax amount percentage
    uint256 public constant taxPercent = 5;

    // NFT kinds
    uint8 private constant KIND_DINO = 1;
    uint8 private constant KIND_LAND = 2;

    // Dino rarity numerical equivalence
    uint8 private constant DINO_COMMON = 1;
    uint8 private constant DINO_RARE = 2;
    uint8 private constant DINO_EPIC = 3;
    uint8 private constant DINO_LEGENDARY = 4;
    uint8 private constant DINO_MYTHICAL = 5;

    // Define the attack thresholds for an NFT to be placed at a certain tier
    bytes3 private constant COMMON_ATTACK_SLICES = hex"08_07_05";
    bytes3 private constant RARE_ATTACK_SLICES = hex"0D_0C_0B";
    bytes3 private constant EPIC_ATTACK_SLICES = hex"12_11_10";
    bytes3 private constant LEGENDARY_ATTACK_SLICES = hex"17_16_15";
    bytes3 private constant MYTHICAL_ATTACK_SLICES = hex"1C_1B_1A";

    // Events
    // Dinos
    event DinoListed (address indexed seller, uint256 indexed id, uint256 price);
    event DinoUnListed (address indexed seller, uint256 indexed id);
    event DinoSold (address indexed seller, address indexed buyer, uint256 indexed id, uint256 price);

    // Lands
    //event LandListed (address indexed seller, uint256 indexed id, uint256 price);
    //event LandUnListed (address indexed seller, uint256 indexed id);
    //event LandSold (address indexed seller, address indexed buyer, uint256 indexed id, uint256 price);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}    // solhint-disable-line

    // This is an UUPSUpgradeable contract, replace the constructor by an initializer
    function initialize() public initializer {
        // Call the initializer of all parent contracts
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __JurassicMarketStorageUpgradeable_init();

        // Grant all roles to the deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /////////////
    // getters //
    /////////////
    function getSellerDinoListings(address seller)
        external view
        returns(uint256[] memory listedTokenIds) {
        return OwnerDinoListedIds[seller].values();
    }

    function getSellerLandListings(address seller)
        external view
        returns(uint256[] memory listedTokenIds) {

        return OwnerLandListedIds[seller].values();
    }

    function getDinoListingCoordinates(address seller, uint256 tokenId)
        external view
        returns(uint8 rarity, uint8 attack_tier, uint248 position) {

        require(OwnerDinoListedIds[seller].contains(tokenId), "MARKETPLACE: This token is owned by owner");

        uint8 _rarity = OwnerDinoListings[seller][tokenId].rarity;
        uint8 _attack_tier = OwnerDinoListings[seller][tokenId].attack_tier;
        uint248 _position = OwnerDinoListings[seller][tokenId].position;

        return(_rarity, _attack_tier, _position);

    }

    function getLandListingCoordinates(address seller, uint256 tokenId)
        public view
        returns(uint8 rarity, uint248 position) {

        require(OwnerLandListedIds[seller].contains(tokenId), "MARKETPLACE: This token is owned by owner");

        uint8 _rarity = OwnerLandListings[seller][tokenId].rarity;
        uint248 _position = OwnerLandListings[seller][tokenId].position;

        return(_rarity, _position);
    }

    function getDinoListingSlice(uint8 rarity, uint8 attack_tier, uint256 start, uint256 end)
        external view
        returns (ListingRecord[] memory listings, uint256 nextPage, uint256 totalNumber) {
        // Sanity check
        require(start < end, "END must be grater than START");

        // Get the total number of records on this slice
        uint256 _length = DinoListings[rarity][attack_tier].length;

        // Make sure we aren't trying to read beyond the end of this slice.
        uint256 _end;
        if (end >= _length){
            _end = _length;
        } else {
            _end = end;
        }

        // ResponseSlice is the array of structs that is to be returned to the caller with the ressults
        ListingRecord[] memory ResponseSlice = new ListingRecord[](_end - start);
        // DinoIds, the tokenId of the dinos on the response, so we can querry the NFT cnt for its traits
        uint256[] memory DinoIds = new uint256[](_end - start);

        // if we have requested a slice beyond the end, return an empity response for the lates page
        if (start >= _length){
            return(ResponseSlice, _length, _length);
        }





        // iterators
        uint256 i;
        uint256 j;

        // Get the listing details
        for(i = start; i < _end; i++) {
            // Get the listing information
            ResponseSlice[j].listing = DinoListings[rarity][attack_tier][i];
            DinoIds[j] = ResponseSlice[j].listing.id;
            j++;
        }

        // Get the dino traits
        Traits[] memory DinoTraits = new Traits[](_end - start);
        DinoTraits = JurassicTokens.batchGetTokenIdTraits(DinoIds);

        // integrate results on the response
        for (j=0; j <_end - start; j++){
            ResponseSlice[j].traits = DinoTraits[j];
        }

        // Return the response
        return(ResponseSlice, _end, _length);
    }

    function getLandListingSlice(uint8 rarity, uint256 start, uint256 end)
        external view
        returns (ListingRecord[] memory listings, uint256 nextPage, uint256 totalNumber) {
        // Sanity check
        require(start < end, "END must be grater than START");

        // Get the total number of records on this slice
        uint256 _length = LandListings[rarity].length;

        // Make sure we aren't trying to read beyond the end of this slice.
        uint256 _end;
        if (end >= _length){
            _end = _length;
        } else {
            _end = end;
        }

        // ResponseSlice is the array of structs that is to be returned to the caller with the ressults
        ListingRecord[] memory ResponseSlice = new ListingRecord[](_end - start);
        // DinoIds, the tokenId of the dinos on the response, so we can querry the NFT cnt for its traits
        uint256[] memory LandIds = new uint256[](_end - start);

        // if we have requested a slice beyond the end, return an empity response for the lates page
        if (start >= _length){
            return(ResponseSlice, _length, _length);
        }





        // iterators
        uint256 i;
        uint256 j;

        // Get the listing details
        for(i = start; i < _end; i++) {
            // Get the listing information
            ResponseSlice[j].listing = LandListings[rarity][i];
            LandIds[j] = ResponseSlice[j].listing.id;
            j++;
        }

        // Get the dino traits
        Traits[] memory LandTraits = new Traits[](_end - start);
        LandTraits = JurassicTokens.batchGetTokenIdTraits(LandIds);

        // integrate results on the response
        for (j=0; j <_end - start; j++){
            ResponseSlice[j].traits = LandTraits[j];
        }

        // Return the response
        return(ResponseSlice, _end, _length);
    }


    /////////////
    // Setters //
    /////////////
    function listDino(uint256 tokenId, uint256 price) public whenNotPaused() {
        // Sanity checks
        require(price > 0, "MARKETPLACE: Please set a price grater than 0");
        require(!OwnerDinoListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token is already listed");
        // Token kind == dino is being enforce by get_dino_partition function, as its the only place we have access to traits

        // Get coordinates this token should be placed at
        uint8 rarity;
        uint8 attack_tier;
        (rarity, attack_tier) = get_dino_partition (tokenId);

        // Build the struct for the public listing. and store it
        Listing storage listing = DinoListings[rarity][attack_tier].push();

        listing.id = tokenId;
        listing.owner = msg.sender;
        listing.price = price;

        // Build the struct for the owner's ledger, and store it
        OwnerDinoListings[msg.sender][tokenId].rarity = rarity;
        OwnerDinoListings[msg.sender][tokenId].attack_tier = attack_tier;
        OwnerDinoListings[msg.sender][tokenId].position = uint248(DinoListings[rarity][attack_tier].length - 1);

        // Add the tokenID to the the list of tokens on sale
        OwnerDinoListedIds[msg.sender].add(tokenId);

        // Try to transfer the token from owner to ourselves. We are working with NFT, so the ammount should be 1
        JurassicTokens.safeTransferFrom(msg.sender, address(this), tokenId, 1, hex"00");

        // Emit an event of the token listed
        emit DinoListed(msg.sender, tokenId, price);
    }

    function listLand(uint256 tokenId, uint256 price) public whenNotPaused() {
       // Sanity checks
        require(price > 0, "MARKETPLACE: Please set a price grater than 0");
        require(!OwnerLandListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token is already listed");

        // Get Land Traits
        Traits memory traits;

        // Get the traits
        traits = JurassicTokens.getTokenIdTraits(tokenId);

        // Sanity Check, make sure we are dealing with a land.
        require(traits.kind == Kind.land, "The listed token is not a land");

        // Build the struct for the public listing. and store it
        Listing storage listing = LandListings[traits.rarity].push();

        listing.id = tokenId;
        listing.owner = msg.sender;
        listing.price = price;

        // Build the struct for the owner's ledger, and store it
        OwnerLandListings[msg.sender][tokenId].rarity = traits.rarity;
        OwnerLandListings[msg.sender][tokenId].position = uint248(LandListings[traits.rarity].length - 1);

        // Add the tokenID to the the list of tokens on sale
        OwnerLandListedIds[msg.sender].add(tokenId);

        // Try to transfer the token from owner to ourselves. We are working with NFT, so the ammount should be 1
        JurassicTokens.safeTransferFrom(msg.sender, address(this), tokenId, 1, hex"00");

        // Emit an event of the token listed
        // emit LandListed(msg.sender, tokenId, price);
    }

    function unListDino(uint256 tokenId) public whenNotPaused() {
        // Sanity check
        require(OwnerDinoListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token not yours or is not listed");

        // Get the coordinates of the listing
        uint8 rarity = OwnerDinoListings[msg.sender][tokenId].rarity;
        uint8 attack_tier = OwnerDinoListings[msg.sender][tokenId].attack_tier;
        uint248 position = OwnerDinoListings[msg.sender][tokenId].position;

        // delete the public listing
        deleteDinoListing(position, attack_tier, rarity);

        // Delete the owner's listing
        delete OwnerDinoListings[msg.sender][tokenId];
        OwnerDinoListedIds[msg.sender].remove(tokenId);

        // Try to transfer the token from this cnt to the owner
        JurassicTokens.safeTransferFrom(address(this), msg.sender, tokenId, 1, hex"00");

        // emit the event
        emit DinoUnListed(msg.sender, tokenId);
    }

    function unListLand(uint256 tokenId) public whenNotPaused() {
        // Sanity check
        require(OwnerLandListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token not yours or is not listed");

        // Get the coordinates of the listing
        uint8 rarity = OwnerLandListings[msg.sender][tokenId].rarity;
        uint248 position = OwnerLandListings[msg.sender][tokenId].position;

        // delete the public listing
        deleteLandListing(position, rarity);

        // Delete the owner's listing
        delete OwnerLandListings[msg.sender][tokenId];
        OwnerLandListedIds[msg.sender].remove(tokenId);

        // Try to transfer the token from this cnt to the owner
        JurassicTokens.safeTransferFrom(address(this), msg.sender, tokenId, 1, hex"00");

        // emit the event
        //emit LandUnListed(msg.sender, tokenId);
    }

    function updateDinoPrice(uint256 tokenId, uint256 price) public whenNotPaused() {
        // Sanity check
        require(price > 0, "MARKETPLACE: Please set a price grater than 0");
        require(OwnerDinoListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token not yours or is not listed");

        // Get the coordinates of the listing
        uint256 rarity = OwnerDinoListings[msg.sender][tokenId].rarity;
        uint256 attack_tier = OwnerDinoListings[msg.sender][tokenId].attack_tier;
        uint256 position = OwnerDinoListings[msg.sender][tokenId].position;

        // Update the listing
        DinoListings[rarity][attack_tier][position].price = price;

        // Emit an event with the updated price
        emit DinoListed(msg.sender, tokenId, price);
    }

    function updateLandPrice(uint256 tokenId, uint256 price) public whenNotPaused() {
        // Sanity check
        require(price > 0, "MARKETPLACE: Please set a price grater than 0");
        require(OwnerLandListedIds[msg.sender].contains(tokenId), "MARKETPLACE: This token not yours or is not listed");

        // Get the coordinates of the listing
        uint256 rarity = OwnerLandListings[msg.sender][tokenId].rarity;
        uint256 position = OwnerLandListings[msg.sender][tokenId].position;

        // Update the listing
        LandListings[rarity][position].price = price;

        // Emit an event with the updated price
        //emit LandListed(msg.sender, tokenId, price);
    }

    function purchaseDino(uint256 tokenId, address seller) public whenNotPaused() {
        // Check the tokenId being purchased is owned by seller
        require(OwnerDinoListedIds[seller].contains(tokenId), "MARKETPLACE: wrong input data, token is not owned by seller");

        // Get the coordinates of the listing
        uint256 rarity = OwnerDinoListings[seller][tokenId].rarity;
        uint256 attack_tier = OwnerDinoListings[seller][tokenId].attack_tier;
        uint248 position = OwnerDinoListings[seller][tokenId].position;

        // Get the price of the item
        uint256 price = DinoListings[rarity][attack_tier][position].price;
        uint256 tax = price * taxPercent / 100;


        // delete the public listing
        deleteDinoListing(position, attack_tier, rarity);

        // Delete the owner's listing
        delete OwnerDinoListings[seller][tokenId];
        OwnerDinoListedIds[seller].remove(tokenId);

        // transfer tokens from buyer
        require(JRSC.transferFrom(msg.sender, address(this), price), "ERC20: failed to transfer tokens from buyer");

        // Transfer tax to project
        require(JRSC.transfer(OWNER, tax), "ERC20: failed to transfer tax to seller");

        // transfer tokens to seller minus tax
        require(JRSC.transfer(seller, price - tax), "ERC20: failed to transfer tokens to seller");

        // transfer the nft to seller
        JurassicTokens.safeTransferFrom(address(this), msg.sender, tokenId, 1, hex"00");

        emit DinoSold (seller, msg.sender, tokenId, price);
    }

    function purchaseLand(uint256 tokenId, address seller) public whenNotPaused() {
        // Check the tokenId being purchased is owned by seller
        require(OwnerLandListedIds[seller].contains(tokenId), "MARKETPLACE: wrong input data, token is not owned by seller");

        // Get the coordinates of the listing
        uint256 rarity = OwnerLandListings[seller][tokenId].rarity;
        uint248 position = OwnerLandListings[seller][tokenId].position;

        // Get the price of the item
        uint256 price = LandListings[rarity][position].price;
        uint256 tax = price * taxPercent / 100;


        // delete the public listing
        deleteLandListing(position, rarity);

        // Delete the owner's listing
        delete OwnerLandListings[seller][tokenId];
        OwnerLandListedIds[seller].remove(tokenId);

        // transfer tokens from buyer
        require(JRSC.transferFrom(msg.sender, address(this), price), "ERC20: failed to transfer tokens from buyer");

        // Transfer tax to project
        require(JRSC.transfer(OWNER, tax), "ERC20: failed to transfer tax to seller");

        // transfer tokens to seller minus tax
        require(JRSC.transfer(seller, price - tax), "ERC20: failed to transfer tokens to seller");

        // transfer the nft to seller
        JurassicTokens.safeTransferFrom(address(this), msg.sender, tokenId, 1, hex"00");

        //emit LandSold (seller, msg.sender, tokenId, price);
    }

    /////////////////////
    // Helpers getters //
    /////////////////////
    function get_dino_partition(uint256 tokenId) internal view returns (uint8, uint8){
        // get the token traits
        uint8 rarity;
        uint8 atk_slot;
        Traits memory traits;

        // Get the traits
        traits = JurassicTokens.getTokenIdTraits(tokenId);

        // Sanity Check, make sure we are dealing with a dine. This rever prevents listNewDino from listing non-dino items
        require(traits.kind == Kind.dino, "The listed token is not a dino");

        // Get the appropriate slots
        rarity = traits.rarity;
        atk_slot = get_token_atk_partition(rarity, uint8(traits.attack / 10));

        // Return the appropriate values.
        return (rarity, atk_slot);
    }

    function get_token_atk_partition(uint8 rarity, uint8 atk) internal pure returns (uint8){
        if(rarity == DINO_COMMON){
            if (atk >= uint8(COMMON_ATTACK_SLICES[0])){
                return 0;
            } else if (atk >= uint8(COMMON_ATTACK_SLICES[1])){
                return 1;
            } else if (atk >= uint8(COMMON_ATTACK_SLICES[2])){
                return 2;
            } else {
                return 3;
            }
        } else if(rarity == DINO_RARE){
            if (atk >= uint8(RARE_ATTACK_SLICES[0])){
                return 0;
            } else if (atk >= uint8(RARE_ATTACK_SLICES[1])){
                return 1;
            } else if (atk >= uint8(RARE_ATTACK_SLICES[2])){
                return 2;
            } else {
                return 3;
            }
        }  else if(rarity == DINO_EPIC){
            if (atk >= uint8(EPIC_ATTACK_SLICES[0])){
                return 0;
            } else if (atk >= uint8(EPIC_ATTACK_SLICES[1])){
                return 1;
            } else if (atk >=uint8(EPIC_ATTACK_SLICES [2])){
                return 2;
            } else {
                return 3;
            }
        } else if(rarity == DINO_LEGENDARY){
            if (atk >= uint8(LEGENDARY_ATTACK_SLICES[0])){
                return 0;
            } else if (atk >= uint8(LEGENDARY_ATTACK_SLICES[1])){
                return 1;
            } else if (atk >=uint8(LEGENDARY_ATTACK_SLICES [2])){
                return 2;
            } else {
                return 3;
            }
        } else if(rarity == DINO_MYTHICAL){
            if (atk >= uint8(MYTHICAL_ATTACK_SLICES[0])){
                return 0;
            } else if (atk >= uint8(MYTHICAL_ATTACK_SLICES[1])){
                return 1;
            } else if (atk >=uint8(MYTHICAL_ATTACK_SLICES [2])){
                return 2;
            } else {
                return 3;
            }
        }
        return 3;
    }

    /////////////////////
    // Helpers setters //
    /////////////////////
    function deleteDinoListing(uint248 position, uint256 attack_tier, uint256 rarity) internal {
        // Get the index of the last element of the array
        uint256 last_index = DinoListings[rarity][attack_tier].length - 1;
        // get information about the last index token, so we can update its owner's records
        address owner_of_last_index = DinoListings[rarity][attack_tier][last_index].owner;
        uint256 tokenId_of_last_index = DinoListings[rarity][attack_tier][last_index].id;

        // move the last item of the array to the position we are freeing, and pop the last element
        DinoListings[rarity][attack_tier][position] = DinoListings[rarity][attack_tier][last_index];
        DinoListings[rarity][attack_tier].pop();

        // update the position of the listing in it's owner array
        OwnerDinoListings[owner_of_last_index][tokenId_of_last_index].position = position;
    }

    function deleteLandListing(uint248 position, uint256 rarity) internal {
        // Get the index of the last element of the array
        uint256 last_index = LandListings[rarity].length - 1;
        // get information about the last index token, so we can update its owner's records
        address owner_of_last_index = LandListings[rarity][last_index].owner;
        uint256 tokenId_of_last_index = LandListings[rarity][last_index].id;

        // move the last item of the array to the position we are freeing, and pop the last element
        LandListings[rarity][position] = LandListings[rarity][last_index];
        LandListings[rarity].pop();

        // update the position of the listing in it's owner array
        OwnerLandListings[owner_of_last_index][tokenId_of_last_index].position = position;
    }

    ////////////////////////////////////////////
    //  IERC165 Standard Interface detection  //
    ////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId)
        public view
        override(ERC1155ReceiverUpgradeable, AccessControlEnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //////////////////////////
    //  Security functions  //
    //////////////////////////
    function pause() public onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    ////////////////////////////////////
    //  UUPS Proxy upgrade functions  //
    ////////////////////////////////////
    // This function does nothing, but is called by upgradeTo in order to authenticate the user.
    // Should rever is the callee is not authorized to perform this action
    function _authorizeUpgrade(address newImplementation)
        internal override onlyRole(UPGRADER_ROLE)
        {}  // solhint-disable-line
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerableUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "../utils/structs/EnumerableSetUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// ERC1155 token
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "./extensions/ERC1155EnumerableUpgradeable.sol";
import "./extensions/ERC1155JrscCollectableUpgradeable.sol";
import "./extensions/ERC1155JrscGameUpgradeable.sol";

// Acess control & security
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

// Upgradeable proxy
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";



/// @custom:security-contact [email protected]
contract JurassicCryptoTokens is Initializable,
    ERC1155Upgradeable, ERC1155SupplyUpgradeable, ERC1155EnumerableUpgradeable,
    ERC1155JrscCollectableUpgradeable, ERC1155JrscGameUpgradeable,
    AccessControlEnumerableUpgradeable, PausableUpgradeable, UUPSUpgradeable, ERC1155BurnableUpgradeable {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");


    //////////////
    // MINTING  //
    /////////////
    function mintDino(address account, Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _mintDino(account, fixedTraits, fixedId, data);
        }

    function mintLand(address account, Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _mintLand(account, fixedTraits, fixedId, data);
        }

    function batchMintDisperseDino(address[] calldata accounts,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _batchMintDisperseDino(accounts, fixedTraits, fixedId, data);
        }
    function batchMintDino(address account, uint256 amount,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _batchMintDino(account, amount, fixedTraits, fixedId, data);
        }

    function batchMintDisperseLand(address[] calldata accounts,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _batchMintDisperseLand(accounts, fixedTraits, fixedId, data);
        }
    function batchMintLand(address account, uint256 amount,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _batchMintLand(account, amount, fixedTraits, fixedId, data);
        }

    // Generic mint
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        external onlyRole(ADMIN_ROLE) {
            _mint(account, id, amount, data);
        }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external onlyRole(MINTER_ROLE) {
            _mintBatch(to, ids, amounts, data);
        }

    //////////////////////
    //  ERC1150 backend  //
    //////////////////////
    // Change the Global URI of the metadata
    function setURI(string memory newuri) external onlyRole(ADMIN_ROLE)
    {
        _setURI(newuri);
    }

    // Hook called before transfering tokens. Do nothing, but call the super on inherited contracts
    function _beforeTokenTransfer(
        address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data
    ) internal whenNotPaused override(ERC1155Upgradeable, ERC1155SupplyUpgradeable, ERC1155EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i; i < ids.length; i++){
            require(_tokenTraits[ids[i]].in_sauria == false, "ETokenInSauria");
        }
    }

    ////////////////////////////////////////////
    //  IERC165 Standard Interface detection  //
    ////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId)
        public view
        override(ERC1155Upgradeable, AccessControlEnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //////////////////////////
    //  Security functions  //
    //////////////////////////
    function pause() external onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    ////////////////////////////////////
    //  UUPS Proxy upgrade functions  //
    ////////////////////////////////////
    // This function does nothing, but is called by upgradeTo in order to authenticate the user.
    // Should rever is the callee is not authorized to perform this action
    function _authorizeUpgrade(address newImplementation)
        internal override onlyRole(ADMIN_ROLE)
        {}  // solhint-disable-line
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// The ERC1155 nft contract
import "../tokens/JurassicCryptoTokens.sol";

struct Listing {
    uint256 id;
    address owner;
    uint256 price;
}

struct OwnerDinoListing {
    uint8 rarity;
    uint8 attack_tier;
    uint248 position;
}

struct OwnerLandListing {
    uint8 rarity;
    uint248 position;
}

struct ListingRecord {
    Listing listing;
    Traits traits;
}

contract JurassicMarketStorageUpgradeable is Initializable{
    // The library used for the enumerable sets
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function __JurassicMarketStorageUpgradeable_init() internal onlyInitializing { }            // solhint-disable-line
    function __JurassicMarketStorageUpgradeable_init_unchained() internal onlyInitializing { }  // solhint-disable-line

    // Public listing ledger, holds the records for all listed items.
    // Dinos
    // For aiding in search, the array is split:
    //  First level, by rarity, index equal to the rarity index, so index 0 is not used
    //  Second level, attack partition. Each rarity has an attack range (usualy 50 points) so we made 4 partitions
    //      about 13 points apart
    Listing[][4][6] internal DinoListings;
    //  Lands
    //  As all lands of the same rarity are equal, we just use the rarity as a partition
    //  Listing[item][rarity]
    Listing[][7] internal LandListings;

    // Owner dino ledger
    // OwnerDinoListings, contains the coordinates of the item in the public ledger. Index by owner, then tokenId
    // Mapping [owner address] => [tokenId] =>
    mapping(address => mapping(uint256 => OwnerDinoListing)) internal OwnerDinoListings;
    mapping(address => mapping(uint256 => OwnerLandListing)) internal OwnerLandListings;
    // An array containing all the tokenId listed by an owner
    //private OwnerDinoListingsArray;
    mapping(address => EnumerableSetUpgradeable.UintSet) internal OwnerDinoListedIds;
    mapping(address => EnumerableSetUpgradeable.UintSet) internal OwnerLandListedIds;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
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
        _setApprovalForAll(_msgSender(), operator, approved);
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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
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

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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

    /**
     * @dev Hook that is called after any token transfer. This includes minting
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
    function _afterTokenTransfer(
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
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
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
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155SupplyUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Supply_init() internal onlyInitializing {
    }

    function __ERC1155Supply_init_unchained() internal onlyInitializing {
    }
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155SupplyUpgradeable.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155BurnableUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Burnable_init() internal onlyInitializing {
    }

    function __ERC1155Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


abstract contract ERC1155EnumerableUpgradeable is ERC1155Upgradeable {   // solhint-disable-line
    // Openzeppelin library for enumerable sets
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    // This address mapping -> set stores the different tokenId each user has
    mapping(address => EnumerableSetUpgradeable.UintSet) private _tokenOfOwner;

    function tokensOf(address owner) public view returns (uint256)
    {
        require(owner != address(0));
        return _tokenOfOwner[owner].length();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256)
    {
        require(index < tokensOf(owner));
        return _tokenOfOwner[owner].at(index);
    }

    function tokenOfOwner(address owner) external view  returns (uint256[] memory)
    {
        require(owner != address(0));
        return _tokenOfOwner[owner].values();
    }

    //////////////////////
    //  ERC1150 backend  //
    //////////////////////
    function _beforeTokenTransfer(
        address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data
    ) internal virtual override
    {
        // Call the super so each contract has the chance of reating to the transfer
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        // This extension keeps track of the different tokenId each token has in his possesion
        if (from != to) {
            // ERC1155 supports batch transfers, iterate over all the transfers
            for (uint256 i; i < ids.length; i++) {
                if (amounts[i] > 0) {
                    // Update the sending account if it's sending all its tokens
                    if (from != address(0) && balanceOf(from, ids[i]) == amounts[i]) {
                        // The from account is sending all its tokens, remove the record
                        _tokenOfOwner[from].remove(ids[i]);

                    }
                    // Update the receiving account, if the token wasn't already present
                    if (to != address(0) && balanceOf(to, ids[i]) == 0) {
                        _tokenOfOwner[to].add(ids[i]);

                    }
                }
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "../../lib/UniformRandomNumber.sol";
import "../extensions/JurassicConstants.sol";



abstract contract ERC1155JrscCollectableUpgradeable is ERC1155Upgradeable, JurassicConstants{   // solhint-disable-line
    // Library for generating random numbers in a range from a seed, without modulo bias
    using UniformRandomNumber for uint256;

    // Begin storage
    mapping (uint256 => Traits) internal _tokenTraits;   // Mapping from tokenID to the traits struts containing metadata
    uint256 private _currentId;                         // The next token Id

    // Lottery adjustments probabilities
    uint8[] private _dinoRarityPossibility;             // probabilities for each rarity level in dinos
    bytes5 private constant _dinoRarityPossibilityUpgrade = hex"00_3C_1E_08_02";
    uint8[] private _landRarityPossibility;             // probabilities for each rarity level in lands

    // The rest of the traits
    uint16[][] private _possibleDinoAttacks;            // Possible attack values of a dino, for each rarity level
    uint16[] private _dinoDefenses;                     // Correlation between dino rarity level and defense value
    uint8 private _initialHp;                           // The default initial HP each dino has at mint
    uint8[] private _landsCapacity;                     // Correlation between land rarity level and capacity of a land

    // Events emitted when a Collectable is minted
    event DinoMinted(address indexed to, uint256 indexed id, uint8 rarity, uint16 attack, uint16 defense, uint8 hp);
    event LandMinted(address indexed to, uint256 indexed id, uint8 rarity, uint8 capacity);

    // Game Storage
    mapping (uint256 => uint256[]) internal SauriaMapping;
    mapping (uint256 => uint256) internal SauriaTimeLockMapping;

    // Game Events
    event CombatWon(address indexed player, uint256 indexed amount);
    event CombatLost(address indexed player);

    ///////////////////////
    //      Getters      //
    //////////////////////
    function getTokenIdTraits(uint256 tokenId) external view returns (Traits memory) {
        return _tokenTraits[tokenId];
    }

    function batchGetTokenIdTraits(uint256[] calldata tokenIds) external view returns (Traits[] memory) {
        // Sanity check
        require (tokenIds.length > 0);

        Traits[] memory response = new Traits[](tokenIds.length);

        for (uint256 i; i < tokenIds.length; i++){
            response[i] = _tokenTraits[tokenIds[i]];
        }

        return response;
    }

    function getTokenIdRarity(uint256 tokenId) external view returns (uint256) {
        return _tokenTraits[tokenId].rarity;
    }

    function isTokenIdDino(uint256 tokenId) external view returns (bool) {
        return _tokenTraits[tokenId].kind == Kind.dino;
    }

    function BatchIsTokenIdDino(uint256[] calldata tokenIds) external view returns (bool) {
        for (uint i; i < tokenIds.length; i++){
            if (_tokenTraits[tokenIds[i]].kind != Kind.dino) {
                return false;
            }
        }
        return true;
    }

    function DinoIsInSauria(uint256 tokenId) external view returns (bool) {
        return _tokenTraits[tokenId].in_sauria;
    }

    function BatchDinoIsInSauria(uint256[] calldata tokenIds) external view returns (bool) {
        for (uint i; i < tokenIds.length; i++){
            if (_tokenTraits[tokenIds[i]].in_sauria) {
                return true;
            }
        }
        return false;
    }

    function isTokenIdLand(uint256 tokenId) external view returns (bool) {
        return _tokenTraits[tokenId].kind == Kind.land;
    }

    function BatchIsTokenIdLand(uint256[] calldata tokenIds) external view returns (bool) {
        for (uint i; i < tokenIds.length; i++){
            if (_tokenTraits[tokenIds[i]].kind != Kind.land) {
                return false;
            }
        }
        return true;
    }

    function isTokenIdCoin(uint256 tokenId) external view returns (bool) {
        return _tokenTraits[tokenId].kind == Kind.DEFAULT;
    }

    // This function outputs the current lottery values so user can easily verify the lottery behaviour
    function audit() external view returns
        (uint8[] memory, uint8[] memory, uint16[][] memory, uint16[] memory, uint8[] memory, uint8, uint) {
        return(
            _dinoRarityPossibility,
            _landRarityPossibility,
            _possibleDinoAttacks,
            _dinoDefenses,
            _landsCapacity,
            _initialHp,
            _currentId
        );
    }

    ///////////////////////
    //      SETTERS      //
    //////////////////////
    // mint dino
    function _mintDino(address account, Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {

        Traits memory _traits;
        uint256 _Id;
        uint8 lotteryResult;

        // If fixedId is not supplied (its 0) get the id this token should have
        if(fixedId == 0){
            _Id = _currentId;   // solhint-disable-line
            // Increment the _currentId in preparation for the next mint
            _currentId++;
        } else {
            _Id = fixedId;
        }

        // Sanity check
        // Make sure we are supplied dino traits or lottery
        require(fixedTraits.kind == Kind.DEFAULT || fixedTraits.kind == Kind.dino);

        // Calculate a pseudo-random seed number
        /* solhint-disable */
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number +
            _Id
        )));
        /* solhint-enable */

        // Set the tokend kind
        _traits.kind = Kind.dino;

        // Compute rarity
        // If no rarity is supplied, perform a lottery to decide it
        if (fixedTraits.rarity == 0) {
            lotteryResult = uint8(seed.uniform(100));
            uint8 i;
            // Check if we are upgrading an NFT
            if (data.length == 0){

                // No data passed, use normal lottery
                for (; i < 100; i++) {
                    if (_dinoRarityPossibility[i] < lotteryResult) {
                        lotteryResult = lotteryResult - _dinoRarityPossibility[i];
                    } else {
                        _traits.rarity = i + 1;
                        break;
                    }
                }
            }else {
                // data is pressent, use modyfied lottery

                for (; i < _dinoRarityPossibilityUpgrade.length; i++) {
                    if (uint8(_dinoRarityPossibilityUpgrade[i]) < lotteryResult) {
                        lotteryResult = lotteryResult - uint8(_dinoRarityPossibilityUpgrade[i]);
                    } else {
                        _traits.rarity = i + 1;
                        break;
                    }
                }
            }
        } else {
            _traits.rarity = fixedTraits.rarity;
        }

        // compute attack
        // If no attack is supplied, perform a lottery to decide it
        if (fixedTraits.attack == 0) {
            lotteryResult = uint8((seed + lotteryResult).uniform(_possibleDinoAttacks[_traits.rarity].length));
            _traits.attack = _possibleDinoAttacks[_traits.rarity][lotteryResult];
        } else {
            _traits.attack = fixedTraits.attack;
        }

        // Compute defense
        if (fixedTraits.defense == 0) {
            _traits.defense = _dinoDefenses[_traits.rarity];
        } else {
            _traits.defense = fixedTraits.defense;
        }

        // set the _initialHp
        if (fixedTraits.hp == 0) {
            _traits.hp = _initialHp;
        } else {
            _traits.hp = fixedTraits.hp;
        }

        // Mint the NFT
        _mint(account, _Id, 1, data);
        // Store the traits
        _tokenTraits[_Id] = _traits;

        // emit the event
        //event DinoMinted(address indexed to, uint256 indexed id, uint8 rarity, uint16 attack, uint16 defense, uint8 hp);
        emit DinoMinted(account, _Id, _traits.rarity, _traits.attack, _traits.defense, _traits.hp);

    }

    function _mintLand(address account, Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {
        Traits memory _traits;
        uint256 _Id;
        uint8 lotteryResult;

        // If fixedId is not supplied (its 0) get the id this token should have
        if(fixedId == 0){
            _Id = _currentId;   // solhint-disable-line
            // Increment the _currentId in preparation for the next mint
            _currentId++;
        } else {
            _Id = fixedId;
        }

        // Sanity check
        // Make sure we are supplied dino traits or lottery
        require(fixedTraits.kind == Kind.DEFAULT || fixedTraits.kind == Kind.land);

        // Calculate a pseudo-random seed number
        /* solhint-disable */
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number +
            _currentId
        )));
        /* solhint-enable */

        // Set the tokend kind
        _traits.kind = Kind.land;

        // Compute rarity
        if (fixedTraits.rarity == 0) {
            lotteryResult = uint8(seed.uniform(100));
            uint8 i;
            for (; i < 100; i++) {
                if (_landRarityPossibility[i] < lotteryResult) {
                    lotteryResult = lotteryResult - _landRarityPossibility[i];
                } else {
                    _traits.rarity = i + 1;
                    break;
                }
            }
        } else {
            _traits.rarity = fixedTraits.rarity;
        }

        // Safeguard, make sure the lottery has correctly executed
        assert(_traits.rarity != 0);

        // Compute capacity
        if (fixedTraits.capacity == 0) {
            _traits.capacity = _landsCapacity[_traits.rarity];
        } else {
            _traits.capacity = fixedTraits.capacity;
        }

        // Mint the NFT
        _mint(account, _Id, 1, data);
        // Store the traits
        _tokenTraits[_Id] = _traits;

        // emit the event
        //event DinoMinted(address indexed to, uint256 indexed id, uint8 rarity, uint16 attack, uint16 defense, uint8 hp);
        //event LandMinted(address indexed to, uint256 indexed id, uint8 rarity, uint8 capacity);
        emit LandMinted(account, _Id, _traits.rarity, _traits.capacity);

    }

    // Batched version of _mint_dino
    function _batchMintDisperseDino(address[] calldata accounts,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {
        uint256 id = fixedId;
        for (uint i; i < accounts.length; i++) {
            _mintDino(accounts[i], fixedTraits, id, data);
            // 0 is being used as a placeholder for auto-assign, don't change it
            if (id > 0){
                id++;
            }
        }
    }

    function _batchMintDino(address account, uint256 amount,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {
        uint256 id = fixedId;
        for (uint i; i < amount; i++) {
            _mintDino(account, fixedTraits, id, data);
            // 0 is being used as a placeholder for auto-assign, don't change it
            if (id > 0){
                id++;
            }
        }
    }

    // Batched version of _mint_dino
    function _batchMintDisperseLand(address[] calldata accounts,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {
        uint256 id = fixedId;
        for (uint i; i < accounts.length; i++) {
            _mintLand(accounts[i], fixedTraits, id, data);
            // 0 is being used as a placeholder for auto-assign, don't change it
            if (id > 0){
                id++;
            }
        }
    }

    function _batchMintLand(address account, uint256 amount,
        Traits calldata fixedTraits, uint256 fixedId, bytes memory data) internal {
        uint256 id = fixedId;
        for (uint i; i < amount; i++) {
            _mintLand(account, fixedTraits, id, data);
            // 0 is being used as a placeholder for auto-assign, don't change it
            if (id > 0){
                id++;
            }
        }
    }

    function _setCurrentId(uint256 id) internal {
        _currentId = id;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[40] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "./ERC1155JrscCollectableUpgradeable.sol";


contract ERC1155JrscGameUpgradeable is ERC1155Upgradeable, ERC1155JrscCollectableUpgradeable {
    // Library for generating random numbers in a range from a seed, without modulo bias
    using UniformRandomNumber for uint256;

    // Begin storage
    // moved to ERC1155JrscCollectableUpgradeable to keep storage layout consistent
    // Mapping storing the the members (dinos) of a sauria (Land)
    //mapping (uint256 => uint256[]) private SauriaMapping;
    //mapping (uint256 => uint256) private SauriaTimeLockMapping;

    // Events
    //event CombatWon(address indexed player, uint256 indexed amount);
    //event CombatLost(address indexed player);

    ///////////////////////
    //      Getters      //
    //////////////////////
    function getSauriaMapping(uint256 tokenId) external view returns (uint256[] memory){
        return SauriaMapping[tokenId];
    }

    ///////////////////////
    //      SETTERS      //
    //////////////////////
    function createSauria(uint256 landId, uint256[] calldata dinosId) external {


        // Sanity check 1, land
        // Check if the land is indeed a land
        require(_tokenTraits[landId].kind == Kind.land);
        // Check the if land has enought capacity for the intended dinos
        require(_tokenTraits[landId].capacity >= dinosId.length);
        // Check if the land doesn't have a sauria already
        require(_tokenTraits[landId].in_sauria == false);
        // Check the if the caller owns the land
        require (balanceOf(msg.sender, landId) == 1);

        // Sanity check 2, dinos
        uint256 i;
        for (; i < dinosId.length; i++){
            // Check if the dino is indeed a dino
            require(_tokenTraits[dinosId[i]].kind == Kind.dino);
            // Check if the dino is not part of a sauria
            require(_tokenTraits[dinosId[i]].in_sauria == false);
            // Mark the dinos as being part of a sauria
            _tokenTraits[dinosId[i]].in_sauria = true;
            // Check if the dino is owned by the caller
            require (balanceOf(msg.sender, dinosId[i]) == 1);
            // record the dino tokenId in the sauria dino list
            SauriaMapping[landId].push(dinosId[i]);
        }

        // Charge the sauria creation tax
        require(JRSC_TOKEN.transferFrom(msg.sender, JRSC_OWNER_ACC, SAURIA_CREATION_TAX));

        // record the sauria
        // Mark the land as being part of a sauria
        _tokenTraits[landId].in_sauria = true;
    }

    function disbandSauria(uint256 landId) external {
       // check if the timeLock has expired
        require(SauriaTimeLockMapping[landId] < block.timestamp);
        // Check if the land doesn't have a sauria
        require(_tokenTraits[landId].in_sauria == true);
        // Check the if the caller owns the land
        require (balanceOf(msg.sender, landId) == 1);

        // Clear the in_sauria flag for land
        _tokenTraits[landId].in_sauria = false;

        // Clear the in_sauria flag for members
        for (uint256 i=0; i < SauriaMapping[landId].length; i++){
           _tokenTraits[SauriaMapping[landId][i]].in_sauria = false;
        }

        // Delete the DisbandSauria
        delete SauriaMapping[landId];

        // delete the timelock record
        SauriaTimeLockMapping[landId] = 0;
   }

    function hunt(uint256[] calldata sauriaIds, uint8 enemyId) external {
        // Sanity check, the enemyId has to be in bounds
        require(enemyId < SAURIA_POWER.length);

        // compute the attack power of all saurias
        uint256 totalAttack;

        // iterators
        uint256 i;
        uint256 j;

        // Iterate over saurias
        for (; i < sauriaIds.length; i++)
        {
            // Check the if the caller owns the sauria
            require (balanceOf(msg.sender, sauriaIds[i]) == 1);

            // CHECK, make sure the sauria is not timeLocked
            require (SauriaTimeLockMapping[sauriaIds[i]] <= block.timestamp);
            // Update the timelock
            SauriaTimeLockMapping[sauriaIds[i]] = block.timestamp + SAURIA_COOLDOWN;

            // iterate over dinos, compute total attack power, and update HP
            for (j=0; j < SauriaMapping[sauriaIds[i]].length; j++) {
                // Compute totalAttack
                totalAttack +=  _tokenTraits[SauriaMapping[sauriaIds[i]][j]].attack;
                // update HP
                _tokenTraits[SauriaMapping[sauriaIds[i]][j]].hp--;
                // burn 0HP dinos
                // ToDo
            }
        }

        // Check if the saurias have enough attack power
        require(totalAttack >= uint256(uint8(SAURIA_POWER[enemyId])) * 100);

        // Perform the lottery
        // Calculate a pseudo-random seed number
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number +
            uint256(uint8(SAURIA_POWER[enemyId])) * 100
        )));
        uint8 lotteryResult = uint8(seed.uniform(100));

        if (lotteryResult <= uint8(COMBAT_LUCK[enemyId])){
            // WIN
            emit CombatWon(msg.sender, uint8(COMBAT_REWARD[enemyId]));
            REWARDS_MANAGER.RecordReward(msg.sender, uint8(COMBAT_REWARD[enemyId]));
        } else {
            // LOST
            emit CombatLost(msg.sender);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @author Brendan Asselstine
 * @notice A library that uses entropy to select a random number within a bound.  Compensates for modulo bias.
 * @dev solidity 0.8 ported version of https://github.com/pooltogether/uniform-random-number/blob/master/contracts/UniformRandomNumber.sol
 */
library UniformRandomNumber {
    /// @notice Select a random number without modulo bias using a random seed and upper bound
    /// @param _seed The seed for randomness
    /// @param _upperBound The upper bound of the desired number
    /// @return A random number less than the _upperBound
    function uniform(uint256 _seed, uint256 _upperBound) internal pure returns (uint256) {
        require(_upperBound > 0, "UniformRand/min-bound");
        uint256 min = (type(uint).max - _upperBound) % _upperBound;  // solhint-disable-line
        uint256 random = _seed;
        while (true) {
            if (random >= min) {
                break;
            }
            random = uint256(keccak256(abi.encodePacked(random)));
        }
        return random % _upperBound;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// Helpers used to identify the possible values
enum Kind {DEFAULT, dino, land}
enum Rarity_dino {DEFAULT, common, rare, epic, legendary, mythical}                         // solhint-disable-line
enum Rarity_land {DEFAULT, dryLand, desertLand, island, fireLand, iceLand, waterfallLand}   // solhint-disable-line

// All the traits a NFT could have, both for dinos or lands
struct Traits {
    Kind kind;
    uint8 rarity;
    uint16 attack;
    uint16 defense;
    uint8 hp;
    uint8 capacity;
    bool in_sauria;
}

interface IJurassicRewardManager {
    function RecordReward(address player, uint256 amount) external ;
}

contract JurassicConstants {
    // JRSC token, charged by the create sauria, and rewards payout
    IERC20 public constant JRSC_TOKEN = IERC20(0x3310e43dC1104D3CF5ABf81c9c2D08415AD9b092);
    IJurassicRewardManager public constant REWARDS_MANAGER = IJurassicRewardManager(0x08bE4efe8c8adFc897dEeCF46d7467400adAbF43);

    // The address the tax should be payed to
    address payable constant JRSC_OWNER_ACC = payable(0x9D8E4579A1e1B03233ed1A6f0Ba3901e2Dc7B14e);

    //PvE params
    // Minimum power required to attack a particular enemy, x100
    bytes8 constant internal SAURIA_POWER = hex"04_07_0D_12_16_1A_1E_23";
    bytes8 constant internal COMBAT_LUCK = hex"55_50_4B_46_41_3C_37_32";
    bytes8 constant internal COMBAT_REWARD = hex"0A_12_24_36_47_92_74_96";

    uint256 constant internal SAURIA_COOLDOWN = 1 days;

    uint256 constant internal SAURIA_CREATION_TAX = 5 days;
}
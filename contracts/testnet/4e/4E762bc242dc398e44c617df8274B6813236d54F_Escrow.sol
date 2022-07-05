// contracts/Escrow.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./access/AccessControl.sol";
import "./ERC721/IERC721Receiver.sol";
import "./utils/structs/EnumerableSet.sol";
import "./utils/Address.sol";
import "./entities/Stages.sol";
import "./entities/Documents.sol";
import "./INFT.sol";
import "./Auction.sol";

/// @title Escrow
/// @author IEKO
/// @notice This contract implements whole process for selling a real apartment as an NFT
/// @dev Explain to a developer any extra details
contract Escrow is AccessControl, IERC721Receiver {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant NOTARY_ROLE = keccak256("NOTARY_ROLE");

    // Constants
    // uint8 constant CONFIG_STAGE_DOCUMENTS = 4;
    uint8 constant PRE_SALE_DAYS = 1; // In days ; DEFAULT MUST BE IN 15 DAYS
    uint8 constant SALE_HOURS = 1; // In hours ; DEFAULT MUST BE IN 5 HOURS
    uint8 constant TRANSFERING_DAYS = 45; // In days | Transfering and Validation stage shares this time
    uint256 public AUCTION_BASE_PRICE = 10000 * 10**6; // 10k USDT (since USDT has 6 decimals)

    struct Document {
        string url;
        DocumentStatus status;
        bool visible;
        Stages stage;
    }

    // Addresses of participants
    address private seller;
    address public notary;
    address public taxes;
    address public tech;
    address public buyer;

    // Address of USDT Contract to deploy Auction
    address USDTContract;

    // NFT Contract
    INFT public nft;
    uint256 public preTokenId; // This NFT is for compliance Stage
    uint256 public finalTokenId; // This NFT is real apartment
    string public PRE_NFT_HASH;
    string public FINAL_NFT_HASH;

    // Auction
    Auction public auction;
    uint256 public TAXES_FEE = 800; // This is in base 10000 --> 8 = 0.08%
    uint256 public TECH_FEE = 1; // This is in base 10000 --> 1 = 0.01%

    Stages public actualStage;
    uint256 public endPreSaleTime;
    uint256 public endSaleTime;
    // DELETED
    // uint256 public endComplianceTime;
    uint256 public endTransferingTime;

    mapping(Stages => Document[]) private documents;
    EnumerableSet.AddressSet private whitelist;

    // Events included
    event StageChanged(Stages previous, Stages actual, uint256 timestamp);
    event DocumentUploaded(uint8 indexed index, string url, bool visible, DocumentStatus status, Stages stage);
    event DocumentSetAsValid(Stages stage, uint8 index);
    event DocumentSetAsInvalid(Stages stage, uint8 index);
    event FeesChanged(uint256 _taxesFee, uint256 _techFee);
    event BasePriceChanged(uint256 _basePrice);
    event AddToWhitelist(address whitelisted);
    event NFTMinted(address _owner, uint256 _tokenId);
    event AuctionCreated(address _contract, address _nft, uint256 _tokenId, uint256 startTime);
    event PreNFTHashChanged(string _hash);
    event FinalNFTHashChanged(string _hash);

    modifier whilePreSale() {
        require(actualStage == Stages.PreSale && !preSaleEnd(), "Pre-Sale period is not available");
        _;
    }

    modifier documentExists(uint256 _id) {
        require(_id < documents[actualStage].length && _id >= 0, 'Document does not exists');
        _;
    }

    modifier onlyAdminOrNotary() {
        require(hasRole(ADMIN_ROLE, _msgSender()) || isNotary(), "Only admin or notary can do this");
        _;
    }

    modifier onlyWinner() {
        require(buyer == _msgSender(), "Only winner allowed");
        _;
    }

    modifier onlyNotary() {
        require(isNotary(), "Only notary allowed");
        _;
    }

    constructor(
        address _notary,
        address _seller,
        address _taxes,
        address _nftAddress,
        address _USDTContract
    ) {
        // Grant ownership and admin privileges to contract deployer
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());

        // Grant notary privileges to notary address
        _setupRole(NOTARY_ROLE, _notary);

        notary = _notary;
        seller = _seller;
        taxes = _taxes;
        tech = _msgSender();
        USDTContract = _USDTContract;
        actualStage = Stages.Building;

        nft = INFT(_nftAddress);
    }

    function isNotary() public view returns (bool) {
        return hasRole(NOTARY_ROLE, _msgSender());
    }

    // Building stage
    function addDocument(string calldata _hash, bool _visible) public {
        DocumentStatus status;
        if (actualStage == Stages.Building) {
            require(isNotary(), "Only notary allowed");
            status = DocumentStatus.Valid;
            documents[actualStage].push(Document(_hash, DocumentStatus.Valid, _visible, Stages.Building));
        } else if (actualStage == Stages.Compliance) {
            require(buyer == _msgSender(), "Only winner allowed");
            require(auction.auctionPaidAndNFTApproved(), "Auction must be paid and NFT approved to burn");
            _visible = false;
            status = DocumentStatus.Pending;
            documents[actualStage].push(Document(_hash, DocumentStatus.Pending, _visible, Stages.Compliance));
        } else if (actualStage == Stages.Transfering) {
            require(isNotary(), "Only notary allowed");
            _visible = false;
            status = DocumentStatus.Valid;
            documents[actualStage].push(Document(_hash, DocumentStatus.Valid, _visible, Stages.Transfering));
        }
        emit DocumentUploaded(uint8(documents[actualStage].length - 1), _hash, _visible, status, actualStage);
    }

    function setDocumentAsValid(uint256 _id)
        public
        documentExists(_id)
        onlyNotary
    {
        documents[actualStage][_id].status = DocumentStatus.Valid;
        emit DocumentSetAsValid(actualStage, uint8(_id));
    }

    function setDocumentInvalid(uint256 _id) 
        public
        documentExists(_id) 
        onlyNotary
    {
        documents[actualStage][_id].status = DocumentStatus.Invalid;
        emit DocumentSetAsInvalid(actualStage, uint8(_id));
    }

    function setFees(uint256 _taxesFee, uint256 _techFee) public onlyAdminOrNotary {
        require(_taxesFee > 0 && _techFee > 0, 'Taxes must be greater than 0');
        require(actualStage == Stages.Building, 'Fees can only be modified in Building stage');
        TAXES_FEE = _taxesFee;
        TECH_FEE = _techFee;
        emit FeesChanged(_taxesFee, _techFee);
    }

    function setBasePrice(uint256 _basePrice) public onlyAdminOrNotary {
        require(_basePrice > 0 , 'Base Price must be greater than 0');
        require(actualStage == Stages.Building, 'Fees can only be modified in Building stage');
        AUCTION_BASE_PRICE = _basePrice;
        emit BasePriceChanged(_basePrice);
    }

    function startPreSale() public onlyAdminOrNotary {
        // check if actual stage is building
        require(actualStage == Stages.Building, "Pre-sale can only be started in Building stage");
        // Pre and Final NFT hashes are necessary to be setted
        require(bytes(PRE_NFT_HASH).length != 0, "Pre NFT hash is not set");
        require(bytes(FINAL_NFT_HASH).length != 0, "Final NFT hash is not set");
        // TODO check if we need minimum necessary documents
        _dispatchPreSale();
    }

    function _dispatchPreSale() internal {
        endPreSaleTime = block.timestamp + PRE_SALE_DAYS * 1 hours; // ---> !!! ESTO VA EN DIAS... SE CAMBIÓ A HORAS PARA TESTEAR !!! <--
        setNextStage(Stages.PreSale);

        // Here we are minting the pre NFT. TAKE CARE WITH HASH 
        // This NFT represents a right to the owner, in Compliance stage,
        // to upload their documentation 
        preTokenId = nft.createNFT(address(this), PRE_NFT_HASH);
        emit NFTMinted(address(this), preTokenId);

        // Here we are minting the final NFT. TAKE CARE WITH HASH 
        // This NFT represents a real apartment 
        finalTokenId = nft.createNFT(address(this), FINAL_NFT_HASH);
        emit NFTMinted(address(this), finalTokenId);
    }

    // KYC related functions
    // Add people to WhiteList
    function addToWhitelist(address _user) public whilePreSale onlyAdminOrNotary {
        require(_user != address(0), "Address must be valid");
        require(!_user.isContract(), 'Contract cannot be added to whitelist');
        require(whitelist.add(_user), 'Your address is already listed');
        emit AddToWhitelist(_user);
    }

    function removeFromWhitelist(address _user) public whilePreSale onlyAdminOrNotary {
        require(_user != address(0), "Address must be valid");
        require(whitelist.remove(_user), 'Your address is not listed');
    }

    function showWhitelist() public view returns(address[] memory) {
        return whitelist.values();
    }

    function inWhitelist(address _address) public view returns (bool) {
        return whitelist.contains(_address);
    }

    // NFT related functions
    function changeFinalNFTHash(string memory _hash) public onlyAdminOrNotary {
        FINAL_NFT_HASH = _hash;
        emit FinalNFTHashChanged(_hash);
    }

    function changePreNFTHash(string memory _hash) public onlyAdminOrNotary {
        PRE_NFT_HASH = _hash;
        emit PreNFTHashChanged(_hash);
    }

    // Only allow self contract operator for security reasons
    function onERC721Received(
        address _operator,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        require(_operator == address(this), 'Operator only can be this contract');

        return IERC721Receiver.onERC721Received.selector;
    }

    function transferNFTOwnershipToAdmin(address _to) external onlyRole(ADMIN_ROLE) {
        nft.transferOwnership(_to);
    }

    // This function cost gas so we cannot make automatic dispatch from KYC  
    function createAuctionAndStart() public onlyAdminOrNotary {
        // If presale is ended, then dispatch Sale stage
        require(preSaleEnd(), 'Pre Sale is still open');
        _dispatchSale();
    }
    // ------------------------------------------------------------------------------  

    // Sale (Auction) related functions (Stage Sale)
    function _dispatchSale() internal {
        endSaleTime = block.timestamp + SALE_HOURS * 1 hours;
        setNextStage(Stages.Sale);

        _deployAuction();

        // Here we have to send whitelist to auction contract. THIS COULD BE SOOOOOO EXPENSIVE! TAKE CARE WITH THIS
        require(auction.addListToWhitelist(whitelist.values()), 'There was a problem sending whitelist to Auction contract'); 

        // Approve auction contract to transfer NFT
        nft.approve(address(auction), preTokenId);
    }

    function _deployAuction() internal {
        require(address(nft) != address(0), 'No NFT Contract is set');
        require(preTokenId > 0, 'No minted NFT found');
        auction = new Auction(
            preTokenId,
            block.timestamp,
            address(nft),
            seller,
            notary,
            taxes,
            tech,
            SALE_HOURS,
            AUCTION_BASE_PRICE,
            USDTContract,
            TAXES_FEE,
            TECH_FEE
        );
        emit AuctionCreated(address(auction), address(nft), preTokenId, block.timestamp);
    }

    function transferAuctionOwnershipToAdmin() external onlyRole(ADMIN_ROLE) {
        auction.transferOwnership(tech);
    }

    function setSaleEnds(address _winner) public returns (bool success){
        require(actualStage == Stages.Sale, 'Sale Stage must be actual stage');
        require(_msgSender() == address(auction), "Only Auction can call this function");
        setNextStage(Stages.Compliance);

        buyer = _winner;
        success = true;   
    }
    // ------------------------------------------------------------------------------

    // Compliance Stage
    function setComplianceEnds() public onlyNotary returns (bool success) {
        require(actualStage == Stages.Compliance, 'Compliance Stage must be actual stage');
        endTransferingTime = block.timestamp + TRANSFERING_DAYS * 1 days;
        setNextStage(Stages.Transfering);
        success = true;   
    }

    // If compliance is required to be done on-chain here we have to add funcions
    // To manage compliance documents.

    // Whitin compliance stage there's could be 3 options to continue
    // Option One: 
    //      Everithing is fine, notary and winner compplete all steps ==> Notary must call auction.transferOk
    // Option Two:
    //      Notary found some issues with winner documents and have to cancel ==> Notary must call auction.cancelFromNotary
    // Option Thre:
    //      Winner have a cancel period to regret and can call to ==> auction.cancelFromWinner
    //
    // This auction function calls trigger Escrow functions to change it status and follow with 
    // next actions.

    // ------------------------------------------------------------------------------
    
    // Transfering Stage
    function setTransferingEnds(uint256 _transferResultOption) public returns (bool success){
        //require(transferingEnd(),'Transfering is still open'); // Not validate here because maybe compliance is not needed to reach end time
        require(_msgSender() == address(auction), "Only Auction can call this function");

        if (_transferResultOption == 1) { // If this option was received then continue with normal flow
            require(actualStage == Stages.Transfering, 'Transfering Stage must be actual stage');
            require(documents[actualStage].length > 0, "No deed documents uploaded, can't continue");
            nft.safeTransferFrom(address(this), buyer, finalTokenId);
            setNextStage(Stages.Done);
            success = true;
        } else if (_transferResultOption == 2) { // Notary cancelled
            require(actualStage == Stages.Compliance || actualStage == Stages.Transfering, 'Compliance OR Transfering Stage must be actual stage');
            setNextStage(Stages.NotaryCancelled);
            success = true;       
        } else if (_transferResultOption == 3) { // Winner cancelled
            require(actualStage == Stages.Compliance || actualStage == Stages.Transfering, 'Compliance OR Transfering Stage must be actual stage');
            setNextStage(Stages.BuyerCancelled);
            success = true;
        } else {
            require(false, 'Option not allowed');
        }
    } 
    // ------------------------------------------------------------------------------  

    // Validation Stage
    // Here notary must verify if winner complete validation (Rectification) and call setValidationEnds
    // This function also transfer final NFT to buyer 
    // function setValidationEnds() public onlyNotary returns (bool success) {
    //     require(!transferingEnd(), 'Validation is overdue.');
    //     require(actualStage == Stages.Validation, 'Validation Stage must be actual stage');
    //     Stages nextStage = Stages.Done;
    //     emit StageChanged(actualStage, nextStage, block.timestamp);
    //     actualStage = nextStage;
    //     nft.safeTransferFrom(address(this), buyer, finalTokenId); 
    //     success = true;   
    // }

    // ------------------------------------------------------------------------------ 

    // Done stage

    // ------------------------------------------------------------------------------  


    // Utilitary functions
    function preSaleEnd() public view returns (bool) {
        return block.timestamp > endPreSaleTime;
    }

    function saleEnd() public view returns (bool) {
        return block.timestamp > endSaleTime;
    }

    function transferingEnd() public view returns (bool) {
        return block.timestamp > endTransferingTime;
    }

    function setNextStage(Stages _nextStage) internal {
        Stages nextStage = _nextStage;
        emit StageChanged(actualStage, nextStage, block.timestamp);
        actualStage = nextStage;         
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.10;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.10;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
library EnumerableSet {
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.10;

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

// contracts/entities/Stages.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

enum Stages {
  Building,
  PreSale,
  Sale,
  Compliance,
  Transfering,
  Done,
  NotaryCancelled,
  BuyerCancelled
}

// contracts/entities/Document.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

enum DocumentStatus {
    Pending,
    Valid,
    Invalid
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface INFT {
    function createNFT(address _owner, string memory _tokenURI) external returns (uint256 newItemId);
    function transferOwnership(address newOwner) external;
    function approve(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./access/Ownable.sol";
import "./utils/Context.sol";
import "./utils/structs/EnumerableSet.sol";
import "./IEscrow.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./INFT.sol";
import "./entities/Stages.sol";

contract Auction is Context, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // System settings
    uint256 public id;
    INFT public NFT;
    bool public ended = false;
    EnumerableSet.AddressSet private whitelistBidders;

    // Constants
    uint8 public CANCEL_PERIOD = 10; // this is for adding 10 days to end of Auction
    uint256 public immutable TAXES_FEE; // This is in base 10000 --> 8 = 0.08%
    uint256 public immutable TECH_FEE; // This is in base 10000 --> 1 = 0.01%
    uint8 public constant percentageNewBid = 5;

    uint256 constant TRANSFEROK_OPTION = 1;
    uint256 constant NOTARYCANCEL_OPTION = 2;
    uint256 constant WINNERCANCEL_OPTION = 3;

    bool winnerPaid = false;

    // Current winning bid
    uint256 public lastBid;
    address public winning;
    
    // Times assigned to auction and cancel period after win
    uint256 public length;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cancelTime;
    
    address payable public seller;
    address payable public notary;
    address payable public taxes;
    address payable public tech;
    IEscrow private escrowContract; // We need this because escrow is NFT Owner
    address USDTContract;

    event Bid(address who, uint256 amount);
    event Won(address who, uint256 amount);
    event CancelPeriodSet(uint256 timestamp);
    event TransferOk(); // This is used when everything is fine and notary dispatch transfers
    event CancelledFromNotary(); // This must revert all but discount fees to winner
    event CancelledFromWinner(); // This must revert all without fees
    event WinnerPaid(); // Used when auction winner pays the total apartment and fees

    modifier onlyNotary() {
        require(notary == _msgSender(), 'Only notary allowed');
        _;
    }

    modifier auctionEnded() {
        require(ended, 'Auction is not ended');
        _;
    }

    modifier onlyWinner() {
        require(winning != address(0), 'There is no winner');
        require(winning == _msgSender(), 'Only winner allowed');
        _;
    }

    constructor(
        uint256 _id, 
        uint256 _startTime,
        address _NFT,
        address _seller,
        address _notary,
        address _taxes,
        address _tech,
        uint256 _length, // This is in hours,
        uint256 _basePrice,
        address _USDTContract,
        uint256 _taxesFee,
        uint256 _techFee
    ) {
        require(_taxesFee > 0 && _techFee > 0, 'Taxes Fee and Tech Fee must be greater than 0');
        id = _id;
        startTime = _startTime;
        NFT = INFT(_NFT);
        seller = payable(address(_seller));
        notary = payable(address(_notary));
        taxes = payable(address(_taxes));
        tech = payable(address(_tech));
        escrowContract = IEscrow(msg.sender);
        endTime = startTime + (_length * 1 hours);
        lastBid = _basePrice;
        USDTContract = _USDTContract;
        TAXES_FEE = _taxesFee;
        TECH_FEE = _techFee;
    }

    function bid(uint256 _newBid) public {
        require(whitelistBidders.contains(_msgSender()), "Only whitelisted addresses can bid");
        require(_msgSender() == tx.origin, "No contracts");
        require(block.timestamp >= startTime, "Auction has not started");
        require(block.timestamp < endTime, "Auction is already ended");
        uint256 minimumNewBid = lastBid * (100 + percentageNewBid) / 100;
        require(_newBid >= minimumNewBid, "Bid too small"); // 2% increase

        // Receive USDT from bidder
        IERC20(USDTContract).transferFrom(
            _msgSender(),
            address(this),
            _newBid
        );

        // Give back the last bidders money
        if (winning != address(0)) {
            IERC20(USDTContract).transfer(
                winning,
                lastBid
            );
        }

        // This logic is used to increase auction time and last bid must
        // have at least 15 minutes to end time until declared winner
        if (endTime - block.timestamp < 15 minutes) {
            endTime = block.timestamp + 15 minutes;
        }

        lastBid = _newBid;
        winning = _msgSender();
        emit Bid(_msgSender(), _newBid);
    }

    function end() public onlyNotary {
        require(!ended, "Sale stage already ended");
        require(winning != address(0), "There are no bids");
        require(!live(), "Auction is still in progress");

        ended = true;
        cancelTime = block.timestamp + CANCEL_PERIOD * 1 days;

        assert(escrowContract.setSaleEnds(winning));

        // Transfer first NFT to winner
        NFT.safeTransferFrom(address(escrowContract), winning, id);

        emit Won(winning, lastBid);
        emit CancelPeriodSet(cancelTime);
    }

    function payTotalAuction() public onlyWinner auctionEnded {
        require(!winnerPaid, "Winner already paid");
        uint256 userBalance = IERC20(USDTContract).balanceOf(_msgSender());
        uint256 totalAuction = totalCost() - lastBid;
        require(userBalance >= totalAuction, "Not enough funds");

        // Transfer funds from winner to contract
        IERC20(USDTContract).transferFrom(
            _msgSender(),
            address(this),
            totalAuction
        );

        winnerPaid = true;
        emit WinnerPaid();
    }

    function transferOk() public onlyNotary auctionEnded {
        uint256 balance = IERC20(USDTContract).balanceOf(address(this));
        require(balance > 0, "No funds to transfer");
        require(auctionPaidAndNFTApproved(), 'Auction should be paid and NFT approved');

        uint256 totalPrice = lastBid * 10;

        // Calculates taxes to transfer (We need ARS price here)
        uint256 taxesFee = totalPrice * TAXES_FEE / 10000;
        IERC20(USDTContract).transfer(taxes, taxesFee);

        // Calculates tech fees to transfer (We need ARS price here)
        uint256 techFee = totalPrice * TECH_FEE / 10000;
        IERC20(USDTContract).transfer(tech, techFee);

        // Remainint amount to seller
        IERC20(USDTContract).transfer(
            seller, 
            IERC20(USDTContract).balanceOf(address(this))
        );

        // Burn pre NFT (requires approval from user)
        NFT.burn(id);

        assert(escrowContract.setTransferingEnds(TRANSFEROK_OPTION));

        emit TransferOk();
    }

    // If this function is called then NFT was not transfered yet so
    // no needs to transfer back
    function cancelFromNotary() public onlyNotary auctionEnded {
        Stages actualStage = escrowContract.actualStage();
        require(actualStage == Stages.Compliance || actualStage == Stages.Transfering, "Actual stage must be compliance or transfering");
        // This cancel is used when winner compliance is wrong and notary not authorize 
        // the sell. We must apply fees and return remaining balance to winner

        // TODO: Handle penalty fee here to determine how and who will be transfered
        uint256 balance = IERC20(USDTContract).balanceOf(address(this));
        require(balance > 0, "No funds to transfer");

        // Remainint amount to buyer
        IERC20(USDTContract).transfer(winning, balance);

        // Burn pre NFT (requires approval from user)
        NFT.burn(id);

        assert(escrowContract.setTransferingEnds(NOTARYCANCEL_OPTION));
        emit CancelledFromNotary();
    }

    // If this function is called then NFT was not transfered yet so
    // no needs to transfer back
    function cancelFromWinner() public onlyWinner auctionEnded {
        Stages actualStage = escrowContract.actualStage();
        require(actualStage == Stages.Compliance || actualStage == Stages.Transfering, "Actual stage must be compliance or transfering");
        // This cancel must be available only after auctions ends and 
        // for a period of 10 days from winning
        require(block.timestamp < cancelTime, 'Cancel time is overdue');
        uint256 balance = IERC20(USDTContract).balanceOf(address(this));
        require(balance > 0, "No funds to transfer");
        // Have we retain some fees???

        // Get money back to winner
        IERC20(USDTContract).transfer(winning, balance);

        // Burn pre NFT (requires approval from user)
        NFT.burn(id);

        assert(escrowContract.setTransferingEnds(WINNERCANCEL_OPTION));
        emit CancelledFromWinner();
    }

    function addListToWhitelist(address[] memory _whitelist) public onlyOwner returns(bool success) {
        // THIS IS SOOOOOOOO EXPENSIVE... TAKE CARE TO CHANGE THIS!
        for(uint i=0; i < _whitelist.length; i++) {
            whitelistBidders.add(_whitelist[i]);    
        }
        success = true;
    }

    function addToWhitelist(address _toWhitelist) public onlyOwner {
        require(!inWhitelist(_toWhitelist), "User is already in whitelist");
        whitelistBidders.add(_toWhitelist);
    }

    function inWhitelist(address _address) public view returns(bool) {
        return whitelistBidders.contains(_address);
    }

    function removeFromWhitelist(address _toWhitelist) public onlyOwner {
        require(inWhitelist(_toWhitelist), "User is not in whitelist");
        whitelistBidders.remove(_toWhitelist);
    }

    function live() public view returns(bool) {
        return block.timestamp <= endTime && block.timestamp >= startTime;
    }

    function cancelPeriodEnd() public view returns(bool) { // True if now is grather than cancel
        return block.timestamp > cancelTime;
    }

    function auctionPaidAndNFTApproved() public view returns(bool) {
        // If auction is approved, it will return its address
        address approved = NFT.getApproved(id);
        return winnerPaid && approved == address(this);
    }

    function totalCost() public view returns(uint256) {
        uint256 totalAuction = lastBid * 10;
        uint256 techFee = totalAuction * TECH_FEE / 10000;
        uint256 taxesFee = totalAuction * TAXES_FEE / 10000;
        return totalAuction + techFee + taxesFee;
    }

    // Withdraw contract funds to the bid winner, just in case
    function withdrawFunds() public onlyOwner {
        IERC20(USDTContract).transfer(
            winning,
            IERC20(USDTContract).balanceOf(address(this))
        );
        payable(winning).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.10;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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

pragma solidity ^0.8.10;

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.10;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.10;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.10;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./entities/Stages.sol";

interface IEscrow {
    function actualStage() external view returns (Stages);
    function setSaleEnds(address _winner) external returns (bool success);
    function setTransferingEnds(uint256 _transferResultOption) external returns (bool success);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
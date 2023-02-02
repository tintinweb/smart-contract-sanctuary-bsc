/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 is IERC165 {
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract GemsMarket is AccessControl , ERC721Holder, ReentrancyGuard {

    uint256 private _tokenIds;   //total listed
    uint256 private _itemSold;

    bytes32 public constant SupportTeam = keccak256("SupportTeam");

    uint256 public listingPrice = 25;  //2.5%
    uint256 deno = 1000;

    IERC20 public listingCurrency;
    address public feeReceiver;

    struct MarketItem {
        address collection;
        uint256 tokenId;
        address seller;
        ListingStatus status;   //1 for Active and 0 for not Active
        uint256 price;
    }
    mapping(address => mapping (uint => MarketItem)) private Listings;
    //collection -> items -> details

    mapping(address => uint) private _collectionListed;
    mapping(address => uint) private _collectionSold;
    mapping(address => mapping(uint => uint)) public _collectionPointer; //colllection->tokenid>lisitngid

    mapping (address => bool) private acceptedCollections;
    address[] private _collectionAdded;
    
    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    event ItemListed (
        address indexed _collection,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );

    event ItemSold (
        address indexed token,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    constructor(address _ctoken) { 
        listingCurrency = IERC20(_ctoken);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SupportTeam, msg.sender);
        feeReceiver = msg.sender;
    }

    // >

    function listItem(address _collection,uint _tokenId,uint _price) external {
        address account = msg.sender;
        require(acceptedCollections[_collection],"Error: Contact to Admin!");
        IERC721(_collection).transferFrom(account,address(this),_tokenId);
        MarketItem memory _newList =  MarketItem(
            _collection,
            _tokenId,
            account,
            ListingStatus.Active,
            _price
        );
        _tokenIds++;
        _collectionListed[_collection]++;
        uint temp = _collectionListed[_collection];
        _collectionPointer[_collection][_tokenId] = temp;
        Listings[_collection][temp] = _newList;
        emit ItemListed(_collection,_tokenId,account,_price);
    }

    function buyToken(address _collection,uint _listingId,uint _tokenAmount) external {
        address account = msg.sender;
        MarketItem storage listing = Listings[_collection][_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account != listing.seller,"Error: Seller can't buy!");
        
        uint totalprice =  listing.price;
        require(_tokenAmount >= totalprice,"Error: Invalid Price!");

        uint fee = totalprice*listingPrice/deno;
        uint rem = totalprice - fee;

        listingCurrency.transferFrom(account, feeReceiver , fee);
        listingCurrency.transferFrom(account, listing.seller, rem);

        IERC721(listing.collection).transferFrom(address(this),account,listing.tokenId);
        listing.status = ListingStatus.Sold;
        _itemSold++;
        _collectionSold[_collection]++;
        emit ItemSold(listing.collection,listing.tokenId,listing.seller,account,listing.price);
    }

    function cancelListing(address _collection,uint _listingId) external {
        address account = msg.sender;
        MarketItem storage listing = Listings[_collection][_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account == listing.seller,"Caller must be seller!");
        IERC721(listing.collection).transferFrom(address(this),account,listing.tokenId);
        listing.status = ListingStatus.Cancelled;
    }

    function fetchListing(address _collection,uint _listingId) external view returns (MarketItem memory) {
        MarketItem memory listing = Listings[_collection][_listingId];
        return listing;
    }

    //                   BULK LIST

    function bulkListItem(address _collection,uint[] calldata _tokenId,uint[] calldata _price) external {
        address account = msg.sender;
        require(acceptedCollections[_collection],"Error: Contact to Admin!");
        require(_tokenId.length == _price.length,"Error: Mismatch Error!");
        for(uint i = 0; i < _tokenId.length; i++) {
            IERC721(_collection).transferFrom(account,address(this),_tokenId[i]);
            MarketItem memory _newList =  MarketItem(
                _collection,
                _tokenId[i],
                account,
                ListingStatus.Active,
                _price[i]
            );
            _tokenIds++;
            _collectionListed[_collection]++;
            uint temp = _collectionListed[_collection];
            Listings[_collection][temp] = _newList;
            emit ItemListed(_collection,_tokenId[i],account,_price[i]);
        }
    }

    //

    function itemSold() external view returns (uint256) {
        return _itemSold;   
    }

    function itemsListed() external view returns (uint256) {
        return _tokenIds;   
    }

    function contractItemListed(address _collection) external view returns (uint256) {
        return _collectionListed[_collection];
    }

    function contractItemSold(address _collection) external view returns (uint256) {
        return _collectionSold[_collection];
    }

    function rescueFunds() external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os);
    }

    function rescueTokens(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender,balance);
    }

    function rescueNfts(address _token,uint _tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC721(_token).transferFrom(address(this),msg.sender,_tokenId);
    }

    function rescueMultiNfts(address _token,uint[] memory _tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < _tokenId.length; i++){
            IERC721(_token).transferFrom(address(this),msg.sender,_tokenId[i]);
        }
    }

    function updateListingPrice(uint _newPrice) external onlyRole(SupportTeam) {
        listingPrice = _newPrice;
    }

    function setFeeReceiver(address _newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeReceiver = _newWallet;
    }

    function setCurrency(address _newToken) external onlyRole(SupportTeam) {
        listingCurrency = IERC20(_newToken);
    }

    function allowCollection(address _collection,bool _status) external onlyRole(SupportTeam) {
        require(acceptedCollections[_collection] != _status,"Error: State Not Changed!");
        if(_status) {
            acceptedCollections[_collection] = _status;
            _collectionAdded.push(_collection);
        }
        else {
            uint j = _collectionAdded.length;
            for(uint i = 0; i < j; i++) {
                if(_collectionAdded[i] == _collection) {
                    _collectionAdded[i] = _collectionAdded[j - 1];
                    _collectionAdded.pop();
                }   
            }
        }
    }

    function collectionlist() external view returns (address[] memory) {
        return _collectionAdded;
    }

    function collectionlistCount() external view returns (uint) {
        return _collectionAdded.length;
    }
    
    receive() external payable {}

}
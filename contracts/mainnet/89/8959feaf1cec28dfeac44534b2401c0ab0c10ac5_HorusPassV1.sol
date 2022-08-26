// SPDX-License-Identifier: GPL-2.0-only

pragma solidity 0.8.11;

contract HorusPassV1
{
    /* ======== DATA TYPES ======== */

    struct Account
    {
        // account ids are 1 indexed
        uint256 _id;
        uint256 _expiryTime;
    }

    /* ======== STATE VARIABLES ======== */

    address s_owner;

    uint256 s_accountCount;
    mapping(address => Account) s_accounts;
    mapping(uint256 => address) s_accountOwners;

    address s_shop;
    uint256 s_generalExpiryTime;

    constructor(address _shop)
    {
        s_owner = msg.sender;
        s_shop = _shop;
        s_generalExpiryTime = type(uint256).max;
    }

    /* ======== EVENTS ======== */

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _account, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _account, address indexed _delegate, bool _approved);

    /* ======== PUBLIC VIEW FUNCTIONS ======== */

    // ERC721Metadata

    function name() external pure
        returns (string memory _name)
    {
        return "HORUS PASS";
    }

    function symbol() external pure
        returns (string memory _symbol)
    {
        return "HORUS";
    }

    function tokenURI(uint256 _tokenId) external pure
        returns (string memory)
    {
        // unused parameters
        _tokenId;

        return "";
    }

    // ERC721

    function balanceOf(address _account) external view
        returns (uint256)
    {
        return s_accounts[_account]._id != 0 ? 1 : 0;
    }

    function ownerOf(uint256 _tokenId) external view
        returns (address)
    {
        return s_accountOwners[_tokenId];
    }

    function isApprovedForAll(address _account, address _delegate) external pure
        returns (bool)
    {
        // unused parameters
        _account;
        _delegate;

        return false;
    }

    // Horus

    function accountCount() external view
        returns (uint256)
    {
        return s_accountCount;
    }

    function account(address _account) external view
        returns (Account memory)
    {
        return s_accounts[_account];
    }

    function accountId(address _account) external view
        returns (uint256)
    {
        return s_accounts[_account]._id;
    }

    function accountExpiryTime(address _account) external view
        returns (uint256)
    {
        return s_accounts[_account]._expiryTime;
    }

    function accountExpired(address _account) external view
        returns (bool)
    {
        return block.timestamp <= s_accounts[_account]._expiryTime && block.timestamp <= s_generalExpiryTime;
    }

    function shop() external view
        returns (address)
    {
        return s_shop;
    }

    function generalExpiryTime() external view
        returns(uint256)
    {
        return s_generalExpiryTime;
    }

    /* ======== PUBLIC FUNCTIONS ======== */

    // Disabled ERC721 functions

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable
    {
        // unused parameters
        _from;
        _to;
        _tokenId;
        _data;

        revert("HorusPassV1: Disabled");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable
    {
        // unused parameters
        _from;
        _to;
        _tokenId;

        revert("HorusPassV1: Disabled");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable
    {
        // unused parameters
        _from;
        _to;
        _tokenId;

        revert("HorusPassV1: Disabled");
    }

    function approve(address _approved, uint256 _tokenId) external payable
    {
        // unused parameters
        _approved;
        _tokenId;

        revert("HorusPassV1: Disabled");
    }

    function setApprovalForAll(address _delegate, bool _approved) external pure
    {
        // unused parameters
        _delegate;
        _approved;

        revert("HorusPassV1: Disabled");
    }

    function getApproved(uint256 _tokenId) external pure
        returns (address)
    {
        // unused parameters
        _tokenId;

        revert("HorusPassV1: Disabled");
    }

    /* ======== SHOP FUNCTIONS ======== */

    function createAccount(address _account, uint256 _expiryTime) external
        onlyShop notExpired accountDoesntExist(_account)
        returns (uint256)
    {
        uint256 _id = s_accountCount + 1;
        s_accountCount = _id;

        s_accounts[_account] = Account({
            _id: _id,
            _expiryTime: _expiryTime
            });
        s_accountOwners[_id] = _account;

        return _id;
    }

    function setAccountExpiryTime(address _account, uint256 _expiryTime) external
        onlyShop notExpired accountExists(_account)
    {
        s_accounts[_account]._expiryTime = _expiryTime;
    }

    /* ======== ADMIN FUNCTIONS ======== */

    function transferOwner(address _owner) external
        onlyOwner
    {
        s_owner = _owner;
    }

    function setShop(address _shop) external
        onlyOwner
    {
        s_shop = _shop;
    }

    function setGeneralExpiryTime(uint256 _generalExpiryTime) external
        onlyOwner
    {
        s_generalExpiryTime = _generalExpiryTime;
    }

    /* ======== MODIFIERS ======== */

    modifier onlyOwner()
    {
        require(msg.sender == s_owner);
        _;
    }

    modifier onlyShop()
    {
        require(msg.sender == s_shop, "HorusPassV1: Only shop");
        _;
    }

    modifier notExpired()
    {
        require(block.timestamp < s_generalExpiryTime, "HorusPassV1: Expired");
        _;
    }

    modifier accountExists(address _account)
    {
        require(s_accounts[_account]._id != 0, "HorusPassV1: Account doesn't exist");
        _;
    }

    modifier accountDoesntExist(address _account)
    {
        require(s_accounts[_account]._id == 0, "HorusPassV1: Account exists");
        _;
    }
}
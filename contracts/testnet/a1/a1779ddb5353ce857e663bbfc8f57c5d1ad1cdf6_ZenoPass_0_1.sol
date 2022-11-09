// SPDX-License-Identifier: GPL-2.0-only

pragma solidity 0.8.11;

contract ZenoPass_0_1
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
        require(msg.sender == s_shop, "ZenoPass_0_1: Only shop");
        _;
    }

    modifier notExpired()
    {
        require(block.timestamp < s_generalExpiryTime, "ZenoPass_0_1: Expired");
        _;
    }

    modifier accountExists(address _account)
    {
        require(s_accounts[_account]._id != 0, "ZenoPass_0_1: Account doesn't exist");
        _;
    }

    modifier accountDoesntExist(address _account)
    {
        require(s_accounts[_account]._id == 0, "ZenoPass_0_1: Account exists");
        _;
    }
}
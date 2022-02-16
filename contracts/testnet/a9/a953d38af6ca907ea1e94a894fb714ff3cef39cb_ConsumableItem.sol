// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./PausableUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "./Initializable.sol";
import "./UUPSUpgradeable.sol";
import "./CountersUpgradeable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./IERC721.sol";

import "./console.sol";

contract ConsumableItem is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMath for uint256;

    event EVBuyConsumableItem(
        address _seller,
        uint256 _itemType,
        uint256 _quantity,
        uint256 _price
    );

    event EVTransferAdmin(address _admin, address _newAdmin);
    event EVWithdrawToken(address _owner, uint256 _amount);
    event EVSetItemType(address _operator, uint256 _itemType, uint256 _price);

    IERC20 IPLVToken;
    uint256 private totalItems;
    uint256 private totalItemTypes;

    mapping(address => uint256) totalItemsPerUser;
    mapping(uint256 => uint256) itemTypes;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(address _owner, address _PLVAddress)
        public
        initializer
    {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(UPGRADER_ROLE, _owner);
        _grantRole(OPERATOR_ROLE, _owner);

        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        IPLVToken = IERC20(_PLVAddress);
        itemTypes[1] = 100000000; // 1PLV
        itemTypes[2] = 100000000; // 1PLV
        totalItemTypes = 3;
    }

    function transferAdmin(address _admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_admin != address(0), "ZERO_ADDRESS");
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        emit EVTransferAdmin(msg.sender, _admin);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function withdrawToken() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = IPLVToken.balanceOf(address(this));
        IPLVToken.transfer(msg.sender, amount);
        emit EVWithdrawToken(msg.sender, amount);
    }

    /**
     * @dev function buy items with type and number of type
     * @param _itemType: TICKET: 1, KEY: 2
     * @param _quantity amount item
     */
    function buy(uint256 _itemType, uint256 _quantity) public {
        uint256 _price = itemTypes[_itemType];
        require(_price > 0, "NOT_FOUND_TYPE");
        uint256 amount = _price.mul(_quantity);
        require(
            IPLVToken.balanceOf(msg.sender) >= amount,
            "BALANCE_NOT_SUFFICIENT"
        );

        IPLVToken.transferFrom(msg.sender, address(this), amount);
        totalItems.add(_quantity);
        totalItemsPerUser[msg.sender].add(_quantity);
        emit EVBuyConsumableItem(msg.sender, _itemType, _quantity, _price);
    }

    function setItemType(uint256 _itemType, uint256 _price)
        public
        onlyRole(OPERATOR_ROLE)
    {
        uint256 _oldPrice = itemTypes[_itemType];
        if (_oldPrice > 0) totalItemTypes.add(1);
        itemTypes[_itemType] = _price;
        emit EVSetItemType(msg.sender, _itemType, _price);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    function getTotalItems() public view returns (uint256) {
        return totalItems;
    }

    function getTotalItemByUser(address _user) public view returns (uint256) {
        return totalItemsPerUser[_user];
    }

    function getAllItemTypes() public view returns (uint256[] memory) {
        uint256[] memory _itemTypes = new uint256[](totalItemTypes);
        for (uint256 i = 0; i < totalItemTypes; i++) {
            // _itemTypes[i] = itemTypes[i];
            _itemTypes[i] = itemTypes[i];
        }
        
        return _itemTypes;
    }

    /**
     * @dev function return current verion of smart contract
     */
    function version() public pure returns (string memory) {
        return "v1.0!";
    }
}
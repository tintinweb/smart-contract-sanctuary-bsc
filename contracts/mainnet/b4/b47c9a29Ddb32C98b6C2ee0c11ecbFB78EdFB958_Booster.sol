// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../common/IDealeable.sol";
import "../common/Roles.sol";

contract Booster is Roles {
    event NewBooster(uint256 id, address[] sources, uint8[] amounts, uint256 price, uint256 rarityModifier, uint256 amount);
    event SetActive(uint256 id, bool active);
    event SetAmount(uint256 id, uint256 amount);
    event SetPrice(uint256 id, uint256 price);
    event BoosterSold(address account, uint256 id, uint256 amount);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");


    // STORAGE

    struct sSource {
        address source;
        uint8 amount;
    }

    struct sBooster {
        sSource[] content;
        uint256 amount;
        uint256 price;
        uint256 rarityModifier;
        bool active;
    }
    mapping(uint256 => sBooster) private _boosters;
    uint256 _boostersCount;

    function booster(uint256 id) external view returns(sBooster memory) {
        return _boosters[id];
    }

    function boosters() external view returns(sBooster[] memory) {
        sBooster[] memory b = new sBooster[](_boostersCount);
        for(uint256 i; i < _boostersCount; i++) {
            b[i] = _boosters[i];
        }
        return b;
    }


    // BOOSTER

    function newBooster(
        address[] calldata _sources,
        uint8[] calldata _amounts,
        uint256 _price,
        uint256 _rarityModifier,
        uint256 _amount
    ) external onlyRole(ADMIN_ROLE) returns(uint256) {
        require(_sources.length == _amounts.length && _sources.length > 0, "Invalid data");

        _boostersCount++;
        sBooster storage b = _boosters[_boostersCount];
        b.amount = _amount;
        b.price = _price;
        b.rarityModifier = _rarityModifier;
        b.active = false;

        for (uint256 i = 0; i < _amounts.length; i++) {
            require(_sources[i].code.length > 0, "source is not a contract");
            b.content.push(sSource(_sources[i], _amounts[i]));
        }
        emit NewBooster(_boostersCount, _sources, _amounts, _price, _rarityModifier, _amount);
        return _boostersCount;
    }

    function setAmount(uint256 _id, uint256 _amount) external onlyRole(ADMIN_ROLE) {
        require(_boosters[_id].content.length > 0, "booster doesnt exist");
        require(_amount > 0, "amount cant be 0");
        _boosters[_id].amount = _amount;
        emit SetAmount(_id, _amount);
    }

    function setPrice(uint256 _id, uint256 _price) external onlyRole(ADMIN_ROLE) {
        require(_boosters[_id].content.length > 0, "booster doesnt exist");
        require(_price > 0, "price cant be 0");
        _boosters[_id].price = _price;
        emit SetPrice(_id, _price);
    }

    function setActive(uint256 _id, bool _active) external onlyRole(ADMIN_ROLE) {
        require(_boosters[_id].content.length > 0, "booster doesnt exist");
        _boosters[_id].active = _active;
        emit SetActive(_id, _active);
    }

    function buy(uint256 _id, uint8 _amount) public virtual payable {
        sBooster storage b = _boosters[_id];
        require(b.content.length > 0, "booster doesnt exist");
        require(b.active, "booster not active");
        require(b.amount >= _amount, "no stock enough");
        require(b.price * _amount <= msg.value, "no money enough");

        b.amount -= _amount;

        for (uint256 i = 0; i < b.content.length; i++) {
            assert(IDealeable(b.content[i].source).deal(msg.sender, b.content[i].amount * _amount, b.rarityModifier));
        }
        emit BoosterSold(msg.sender, _id, _amount);
    }


    // INTERNAL

    function setAdmin(address _to, bool _enabled) external onlyRole(ADMIN_ROLE) {
        _setRole(_to, ADMIN_ROLE, _enabled);
    }

    function withdraw(address payable _to) external onlyRole(ADMIN_ROLE) {
        _to.transfer(address(this).balance);
    }

    receive() external payable {}
    constructor() {
        _setRole(msg.sender, ADMIN_ROLE, true);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDealeable {
    function deal(address _to, uint8 _amount, uint256 _rarityModifier) external returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Roles {
    event Role(bytes32 role, address account, address sender, bool grant);

    mapping(bytes32 => mapping(address => bool)) internal _roles;

    function hasRole(bytes32 _role, address _address) view public returns(bool) {
        return _roles[_role][_address];
    }

    function _setRole(address _address, bytes32 _role, bool status) internal {
        require(!(_address == msg.sender && !status), "cant revoke self roles");
        _roles[_role][_address] = status;
        emit Role(_role, _address, msg.sender, status);
    }

    modifier onlyRole(bytes32 _role) {
        require(hasRole(_role, msg.sender), "AccessControl: Forbidden");
        _;
    }
}
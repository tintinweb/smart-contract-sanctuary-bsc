// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../../interfaces/IRest.sol";
import "../common/DealeableSecondGen.sol";

contract Characters is DealeableSecondGen, IRest {
    bytes32 internal constant INTERACTOR_ROLE = "INTERACTOR_ROLE";

    event Level(uint256 id, uint256 level);
    event Energy(uint256 id, uint256 energy);

    bytes32 constant LEVEL_KEY = "CH::LEVEL_AT";
    bytes32 constant ENERGY_KEY = "CH::READY_AT";
    bytes32 constant DATA_KEY = "CH::DATA";

    struct TypeData {
        uint16[2] hp;
        uint16[2] def;
        uint16[2] dmg;
        uint16[2] vel;
    }

    struct CharacterData {
        uint16 hp;
        uint16 def;
        uint16 dmg;
        uint16 vel;
        uint16 energyMax;
    }

    uint8[4] private _energyMap;


    // HOOKS
    function percentModifier(uint16 _base, uint16 _modifier, uint256 _seed) pure private returns(uint16){
        if (_modifier == 0) return _base;
        uint256 variation = ((_seed % uint256(_modifier - 1)) + 1) * (_base / 100);
        if (variation == 0) return _base;
        uint256 direction = (_seed % variation) % 2;

        return uint16(uint256(_base) - variation + (direction * variation * 2));
    }

    function _onDeal(uint256[] memory _ids) internal override {
        bytes32[] memory items_keys = new bytes32[](_ids.length * 2);
        uint256[] memory attributes = new uint256[](_ids.length * 2);

        bytes32[] memory data_keys = new bytes32[](_ids.length);
        bytes[] memory data_map = new bytes[](_ids.length);

        uint256 seed;
        for(uint256 i = 0; i < _ids.length; i++) {
            seed = uint256(keccak256(abi.encodePacked(
                block.difficulty,
                block.timestamp,
                i
            )));

            Type memory t = getTypeOf(_ids[i]);
            TypeData memory data = abi.decode(t.data, (TypeData));

            CharacterData memory character;
            character.hp = percentModifier(data.hp[0], data.hp[1],    seed % 835792388537);
            character.def = percentModifier(data.def[0], data.def[1], seed % 982372479817);
            character.dmg = percentModifier(data.dmg[0], data.dmg[1], seed % 473477831287);
            character.vel = percentModifier(data.vel[0], data.vel[1], seed % 112784288732);
            character.energyMax = _energyMap[t.tier - 1];

            data_keys[i] = keccak256(abi.encode(DATA_KEY, _ids[i]));
            data_map[i] = abi.encode(character);

            items_keys[i] = keccak256(abi.encode(LEVEL_KEY, _ids[i]));
            attributes[i] = 1;
            items_keys[i + _ids.length] = keccak256(abi.encode(ENERGY_KEY, _ids[i]));
            attributes[i + _ids.length] = character.energyMax;
        }
        store.setBatchUint(NAMESPACE_KEY, items_keys, attributes);
        store.setBatchBytes(NAMESPACE_KEY, data_keys, data_map);
    }



    // INTERACTIONS

    function levelUp(uint256 _id) external onlyRole(INTERACTOR_ROLE) {
        uint256 lvl = store.incUint(NAMESPACE_KEY, keccak256(abi.encode(LEVEL_KEY, _id)), 1);
        require(lvl > 1);
        emit Level(_id, lvl);
    }

    function waste(uint256 _id, uint16 _amount) external onlyRole(INTERACTOR_ROLE) {
        emit Energy(_id, store.decUint(NAMESPACE_KEY, keccak256(abi.encode(ENERGY_KEY, _id)), _amount));
    }

    function rest(uint256[] calldata ids) external override onlyRole(INTERACTOR_ROLE) returns(bool) {
        CharacterData memory data;
        for (uint256 i = 0; i < ids.length; i++) {
            data = abi.decode(store.getBytes(NAMESPACE_KEY, keccak256(abi.encode(DATA_KEY, ids[i]))), (CharacterData));
            store.setUint(NAMESPACE_KEY, keccak256(abi.encode(ENERGY_KEY, ids[i])), data.energyMax);
            emit Energy(ids[i], data.energyMax);
        }
        return true;
    }



    // QUERY
    function getCharacterData(uint256 _id) view external returns(CharacterData memory) {
        bytes memory data = store.getBytes(NAMESPACE_KEY, keccak256(abi.encode(DATA_KEY, _id)));
        require(data.length != 0, 'Invalid');
        return abi.decode(data, (CharacterData));
    }

    function getEnergy(uint256 _id) view external returns(uint256) {
        return store.getUint(NAMESPACE_KEY, keccak256(abi.encode(ENERGY_KEY, _id)));
    }

    function getLevel(uint256 _id) view external returns(uint256) {
        return store.getUint(NAMESPACE_KEY, keccak256(abi.encode(LEVEL_KEY, _id)));
    }



    // INTERNAL

    constructor(string memory _uri, address _vault, uint256 _offset) DealeableSecondGen(_uri, _vault, "VULCANO::NFT::CHARACTERS", _offset) {
        _energyMap[0] = 12;
        _energyMap[1] = 9;
        _energyMap[2] = 6;
        _energyMap[3] = 5;
    }

    function setInteractor(address _to, bool _enabled) external onlyRole(ADMIN_ROLE) {
        _setRole(_to, INTERACTOR_ROLE, _enabled);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Connects characters & lands
interface IRest {
    function rest(uint256[] calldata) external returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./Roles.sol";
import "./ERC1155.sol";

/*
    ID ENCODING
    [ TYPE_ID(96b) GENERATION(32b) ITEM_ID(128b)]
*/

contract DealeableSecondGen is ERC1155, Roles {
    event NewType(address operator, uint256 id, uint256 tier, uint256 amount);
    event NewGeneration(address operator, uint256 id, uint256 generation, uint256 amount);
    event NewItem(uint256 type_id, uint256 generation, uint256 id);

    bytes32 internal constant ADMIN_ROLE = "ADMIN_ROLE";
    bytes32 internal constant DEALER_ROLE = "DEALER_ROLE";

    struct Type {
        uint256 tier;
        uint256 count;
        uint256 generation;
        bytes data;
    }
    // typeid => type
    mapping(uint256 => Type) public types;

    // (typeId + generation) => stock
    mapping(uint256 => uint256) private _stock;
    // tier => typeId[]
    mapping(uint256 => uint256[]) private _pool;
    // tier pool => types count
    mapping(uint256 => uint256) private _poolCount;

    uint256 public offset;

    function poolItems() public view returns (uint256) {
        return _poolCount[1] + _poolCount[2] + _poolCount[3] + _poolCount[4];
    }

    // TYPES

    function newType(uint256 _id, uint256 _tier, uint256 _amount, bytes calldata _data) external onlyRole(ADMIN_ROLE) {
        require((_tier > 0) && (_id >> 160 == 0) && (types[_id].generation == 0), "Invalid");

        Type storage t = types[_id];
        t.tier = _tier;
        t.count = 0;
        t.generation = 1;
        t.data = _data;

        uint256 id = (_id << 160) + (t.generation << 128);
        if (_amount != 0) _pool[_tier].push(id);
        if (_amount != 0) _stock[id] = _amount;
        if (_amount != 0) _poolCount[_tier] += _amount;

        emit NewType(msg.sender, _id, _tier, _amount);
    }

    function newGeneration(uint256 _id, uint256 _amount) external onlyRole(ADMIN_ROLE) {
        Type storage t = types[_id];
        require(
            (_id >> 160 == 0) &&
            (t.generation != 0)
        , "Invalid");

        t.generation++;
        uint256 id = (_id << 160) + (t.generation << 128);

        _pool[t.tier].push(id);
        _stock[id] = _amount;
        _poolCount[t.tier] += _amount;

        emit NewGeneration(msg.sender, _id, t.generation, _amount);
    }

    // POOL

    function _selectTier(uint256 _seed, uint256 _rarityModifier) view private returns(uint8) {
        uint256 items = poolItems();
        uint256 bonus = items * _rarityModifier / 100;

        uint256 probability = (_seed % (items - bonus)) + bonus;

        if (probability < _poolCount[1]) return 1;
        else if (probability < _poolCount[1] + _poolCount[2]) return 2;
        else if (probability < _poolCount[1] + _poolCount[2] + _poolCount[3]) return 3;
        else return 4;
    }

    function _deal(uint256 _rarityModifier) internal returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.difficulty,
            block.timestamp,
            poolItems()
        )));

        uint8 tier = _selectTier(seed, _rarityModifier);
        uint256 index = seed % _pool[tier].length;
        uint256 typeId = _pool[tier][index];

        _stock[typeId]--;
        _poolCount[tier]--;
        if (_stock[typeId] == 0) {
            _pool[tier][index] = _pool[tier][_pool[tier].length - 1];
            _pool[tier].pop();
        }

        uint256 itemId = typeId + (++types[typeId >> 160].count) + offset;

        emit NewItem(typeId >> 160, typeId << 96 >> 224, itemId);
        return itemId;
    }

    function deal(address _to, uint8 _amount, uint256 _rarityModifier) external onlyRole(DEALER_ROLE) returns(bool) {
        require(
            (_amount > 0) &&
            (_to != address(0x0)) &&
            (poolItems() >= _amount)
        , "Invalid");

        uint256[] memory to_mint = new uint256[](_amount);

        for (uint256 i = 0; i < _amount; i++) {
            to_mint[i] = _deal(_rarityModifier);
        }

        _onDeal(to_mint);
        _mint(_to, to_mint);
        return true;
    }

    // QUERY

    function getTypeOf(uint256 _id) public view returns(Type memory) {
        return types[_id >> 160];
    }

    // INTERNAL

    constructor(string memory _uri, address _vault, bytes32 _namespace, uint256 _offset) ERC1155(_uri, _vault, _namespace) {
        _setRole(msg.sender, ADMIN_ROLE, true);

        offset = _offset;
    }

    function setUri(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        _setUri(_uri);
    }

    function setAdmin(address _to, bool _enabled) external onlyRole(ADMIN_ROLE) {
        _setRole(_to, ADMIN_ROLE, _enabled);
    }

    function setDealer(address _to, bool _enabled) external onlyRole(ADMIN_ROLE) {
        _setRole(_to, DEALER_ROLE, _enabled);
    }


    // HOOKS

    function _onDeal(uint256[] memory ids) internal virtual {}
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../../interfaces/IStorage.sol";

// URI for all token types relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
contract ERC1155 {
    event ApprovalForAll(address account, address operator, bool approved);
    event TransferBatch(address operator, address from, address to, uint256[] ids, uint256[] values);

    IStorage internal store;
    bytes32 NAMESPACE_KEY;
    bytes32 constant private ITEMS_ARRAY_KEY = "B::ITEMS";
    bytes32 constant private OWNERS_KEY = "B::OWNERS";
    bytes32 constant private OWNED_KEY = "B::OWNED";

    string private _uri;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    // QUERY

    function balanceOf(address account, uint256 id) public view returns (uint256) {
        return store.getAddress(NAMESPACE_KEY, keccak256(abi.encodePacked(OWNERS_KEY, id))) == account ? 1 : 0;
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        require(accounts.length == ids.length, "Invalid");

        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function ownedBy(address account) public view returns (uint256[] memory) {
        uint256[] memory items = store.getUintArray(NAMESPACE_KEY, ITEMS_ARRAY_KEY);
        uint256 ownedQty = store.getUint(NAMESPACE_KEY, keccak256(abi.encodePacked(OWNED_KEY, account)));
        uint256[] memory owned = new uint256[](ownedQty);

        uint256 idx;
        for (uint256 i = 0; i < items.length; i++) {
            if(store.getAddress(NAMESPACE_KEY, keccak256(abi.encodePacked(OWNERS_KEY, items[i]))) == account) {
                owned[idx] = items[i];
                idx++;
            }
        }
        return owned;
    }

    function ownerOf(uint256 _item) public view returns(address) {
        return store.getAddress(NAMESPACE_KEY, keccak256(abi.encodePacked(OWNERS_KEY, _item)));
    }



    // APPROVALS

    function setApprovalForAll(address operator, bool approved) public {
        require(msg.sender != operator, "Forbidden");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }


    // TRANSFER

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public {
        uint256[] memory ids = new uint256[](1);
        ids[0] = id;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1;
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "Forbidden"
        );
        require(ids.length == amounts.length , "Invalid");

        bytes32[] memory owners_keys = new bytes32[](ids.length);
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            owners_keys[i] = keccak256(abi.encodePacked(OWNERS_KEY, id));
            amounts[i] = 1;
            require(from == store.getAddress(NAMESPACE_KEY, owners_keys[i]), "Unable");
        }

        store.setBatchAddressWith(NAMESPACE_KEY, owners_keys, to);
        store.movUint(NAMESPACE_KEY, keccak256(abi.encodePacked(OWNED_KEY, from)), keccak256(abi.encodePacked(OWNED_KEY, to)), ids.length);
        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }



    // MINT

    function _mint(
        address to,
        uint256[] memory ids
    ) internal {
        bytes32 owned_key = keccak256(abi.encodePacked(OWNED_KEY, to));

        uint256[] memory amounts = new uint256[](ids.length);
        bytes32[] memory owners_keys = new bytes32[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            amounts[i] = 1;
            owners_keys[i] = keccak256(abi.encodePacked(OWNERS_KEY, ids[i]));

            store.incUint(NAMESPACE_KEY, owned_key, 1);
            store.pushToUintArray(NAMESPACE_KEY, ITEMS_ARRAY_KEY, ids[i]);
        }

        store.setBatchAddressWith(NAMESPACE_KEY, owners_keys, to);
        emit TransferBatch(msg.sender, address(0), to, ids, amounts);
    }


    // INTERNAL

    constructor(string memory uri_, address _vaultAddress, bytes32 _namespace) {
        _uri = uri_;
        store = IStorage(_vaultAddress);
        NAMESPACE_KEY = _namespace;
    }

    function uri(uint256) external view returns (string memory) {
        return _uri;
    }

    function _setUri(string calldata _new) internal {
        _uri = _new;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/// @dev Connection between contracts and storage (e.g.: Characters <-> Storage)
interface IStorage {
    function setAddress(bytes32 _namespace, bytes32 _key, address _value) external;
    function setBatchAddressWith(bytes32 _namespace, bytes32[] calldata _keys, address _value) external;
    function getAddress(bytes32 _namespace, bytes32 _key) view external returns(address);

    function setUint(bytes32 _namespace, bytes32 _key, uint _value) external;
    function setBatchUint(bytes32 _namespace, bytes32[] calldata _keys, uint[] calldata _values) external;
    function setBatchUintWith(bytes32 _namespace, bytes32[] calldata _keys, uint _value) external;
    function getUint(bytes32 _namespace, bytes32 _key) view external returns(uint);
    function incUint(bytes32 _namespace, bytes32 _key, uint _value) external returns(uint256);
    function decUint(bytes32 _namespace, bytes32 _key, uint _value) external returns(uint256);
    function movUint(bytes32 _namespace, bytes32 _from, bytes32 _to, uint _value) external;

    function pushToUintArray(bytes32 _namespace, bytes32 _key, uint _value) external;
    function getUintArray(bytes32 _namespace, bytes32 _key) view external returns(uint[] memory);

    function setBytes(bytes32 _namespace, bytes32 _key, bytes calldata  _value) external;
    function setBatchBytes(bytes32 _namespace, bytes32[] calldata _keys, bytes[] calldata _values) external;
    function getBytes(bytes32 _namespace, bytes32 _key) view external returns(bytes memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../../interfaces/IRest.sol";
import "../common/DealeableRandom.sol";

contract Lands is DealeableRandom {
    bytes32 constant private READY_AT_KEY = "LANDS::READY_AT_KEY";

    event Rest(uint256 land, uint256[] characters, uint256 ready_at);

    address public characterContract; 
    uint256 public restPrice;    
    uint256 private constant secondsInHour = 86400;    

    function readyAt(uint256 _land) view external returns(uint256) {
        return store.getUint(NAMESPACE_KEY, keccak256(abi.encodePacked(READY_AT_KEY, _land)));
    }


    // HOOKS

    function _onDeal(uint256[] memory _ids) internal override {
        bytes32[] memory ids = new bytes32[](_ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = keccak256(abi.encodePacked(READY_AT_KEY, _ids[i]));
        }

        store.setBatchUintWith(NAMESPACE_KEY, ids, block.timestamp);
    }


    // REST

    function setCharacterContract(address _contract) external onlyRole(ADMIN_ROLE) {
        require(_contract.code.length > 0, 'Invalid');
        characterContract = _contract;
    }

    function setRestPrice(uint256 _new) external onlyRole(ADMIN_ROLE) {
        restPrice = _new;
    }

    function rest(uint256 _land, uint256[] calldata _characters) external payable {
        require(
            (characterContract != address(0x0)) &&
            (msg.value  >= restPrice) &&
            (ownerOf(_land) == msg.sender)
        , "Invalid");

        bytes32 ready_key = keccak256(abi.encodePacked(READY_AT_KEY, _land));
        uint256 ready_at = store.getUint(NAMESPACE_KEY, ready_key);

        require(
            (ready_at > 0) &&
            (ready_at <= block.timestamp) &&
            (_characters.length <= types[_land >> 160].tier * 2)
        , "Unable");

        uint ready = block.timestamp + (secondsInHour * 24);
        store.setUint(NAMESPACE_KEY, ready_key, ready);
        emit Rest(_land, _characters, ready);

        IRest remote = IRest(characterContract);
        require(remote.rest(_characters), "Error");
    }


    // MAIN

    constructor(string memory _uri, address _vault, address _VRFCoordinator, address _LINKToken, bytes32 _LINKKeyHash, uint32 _offset) DealeableRandom(_uri, _vault, "VULCANO::NFT::LANDS", _VRFCoordinator, _LINKToken, _LINKKeyHash, _offset) {}
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
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/*
    ID ENCODING
    [ TYPE_ID(96b) GENERATION(32b) ITEM_ID(128b)]
*/

contract DealeableRandom is VRFConsumerBase, ERC1155, Roles {
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

    bytes32 internal LINKKeyHash;
    uint256 internal fee;
    uint256 public offset;

    struct DealRequest {
        address _to;
        uint8 _amount; 
        uint256 _rarityModifier;
    }
    // requestId => DealRequest
    mapping(bytes32 => DealRequest) private _deals;

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

    function _deal(uint256 _rarityModifier, uint256 randomness) internal returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.difficulty,
            block.timestamp,
            poolItems(),
            randomness
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

        bytes32 requestId = getRandomNumber();
        DealRequest storage d = _deals[requestId];
        d._to = _to;
        d._amount = _amount;
        d._rarityModifier = _rarityModifier;
        return true;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "LINK ERR");
        return requestRandomness(LINKKeyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        DealRequest storage d = _deals[requestId];        

        uint256[] memory to_mint = new uint256[](d._amount);

        for (uint256 i = 0; i < d._amount; i++) {
            to_mint[i] = _deal(d._rarityModifier, randomness);
        }

        _onDeal(to_mint);
        _mint(d._to, to_mint);
    }

    // QUERY

    function getTypeOf(uint256 _id) public view returns(Type memory) {
        return types[_id >> 160];
    }

    // INTERNAL

    constructor(string memory _uri, address _vault, bytes32 _namespace, address _VRFCoordinator, address _LINKToken, bytes32 _LINKKeyHash, uint256 _offset) VRFConsumerBase(
            _VRFCoordinator,
            _LINKToken
        ) ERC1155(_uri, _vault, _namespace) {
        _setRole(msg.sender, ADMIN_ROLE, true);
        LINKKeyHash = _LINKKeyHash;
        fee = 0.2 * 10 ** 18; // 0.2 LINK https://docs.chain.link/docs/vrf-contracts/v1/
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
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}
pragma solidity ^0.5.4;
import "./Libraries.sol";
import "./Identity.sol";

contract IdentityFactory {
    address implement;

    constructor() public {
        implement = address(new Identity());
    }

    function deploy(address _owner, bytes32 _salt) public returns (address) {
        address identity = Clones.cloneDeterministic(implement, _salt);

        Identity(identity).initial(_owner);
        return identity;
    }

    function getAddress(bytes32 _salt) public view returns (address) {
        return Clones.predictDeterministicAddress(implement, _salt);
    }
}

// File: contracts/interfaces/factories/IIdentityFactory.sol
pragma solidity ^0.5.4;


contract IIdentityFactory {
    function deploy(address _owner, bytes32[] memory _keys, uint256[] memory _purposes, uint _salt) public returns(address);
}

/// @title ERC165
/// @author @fulldecent and @jbaylina
/// @notice A library that detects which interfaces other contracts implement
/// @dev Based on https://github.com/ethereum/EIPs/pull/881

library ERC165Query {
    bytes4 constant internal INVALID_ID = 0xffffffff;
    bytes4 constant internal ERC165_ID = 0x01ffc9a7;

    /// @dev Checks if a given contract address implement a given interface using
    ///  pseudo-introspection (ERC165)
    /// @param _contract Smart contract to check
    /// @param _interfaceId Interface to check
    /// @return `true` if the contract implements both ERC165 and `_interfaceId`
    function doesContractImplementInterface(address _contract, bytes4 _interfaceId)
        internal
        view
        returns (bool)
    {
        bool success;
        bool result;

        (success, result) = noThrowCall(_contract, ERC165_ID);
        if (!success || !result) {
            return false;
        }

        (success, result) = noThrowCall(_contract, INVALID_ID);
        if (!success || result) {
            return false;
        }

        (success, result) = noThrowCall(_contract, _interfaceId);
        if (success && result) {
            return true;
        }
        return false;
    }

    /// @dev `Calls supportsInterface(_interfaceId)` on a contract without throwing an error
    /// @param _contract Smart contract to call
    /// @param _interfaceId Interface to call
    /// @return `success` is `true` if the call was successful; `result` is the result of the call
    function noThrowCall(address _contract, bytes4 _interfaceId)
        internal
        view
        returns (bool success, bool result)
    {
        bytes memory payload = abi.encodeWithSelector(ERC165_ID, _interfaceId);
        bytes memory resultData;
        // solhint-disable-next-line avoid-low-level-calls
        (success, resultData) = _contract.staticcall(payload);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            result := mload(add(resultData, 32))
        }
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * (.note) This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * (.warning) `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise)
     * be too long), and then calling `toEthSignedMessageHash` on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        // if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
        //     return address(0);
        // }
        
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
        
        
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)
     * JSON-RPC method.
     *
     * See `recover`.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/libraries/ERC165.sol

// File: contracts\introspection\IERC165.sol



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


// File: contracts\introspection\ERC165.sol




/**
 * @dev Implementation of the {IERC165} interface.
 *=
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/libraries/ERC735.sol



/// @title ERC735
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC735

contract ERC735 is ERC165 {
    
    /*
     *     bytes4(keccak256('getClaim(bytes32)')) == 0xc9100bcb
     *     bytes4(keccak256('getClaimIdsByType(uint256)')) == 0x262b54f5
     *     bytes4(keccak256('addClaim(uint256,uint256,address,bytes,bytes,string)')) == 0xb1a34e0d
     *     bytes4(keccak256('removeClaim(bytes32)')) == 0x4eee424a
     *
     *    
     */
    bytes4 private constant _INTERFACE_ID_ERC735 = 0x10765379;
    //_registerInterface(_INTERFACE_ID_ERC721);
    /// @dev Constructor that adds ERC735 as a supported interface
    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC735);
    }

    /// @dev ID for ERC165 pseudo-introspection
    /// @return ID for ERC725 interface
    // solhint-disable-next-line func-name-mixedcase
    // function ERC735ID() public pure returns (bytes4) {
    //     return (
    //         this.getClaim.selector ^ this.getClaimIdsByType.selector ^
    //         this.addClaim.selector ^ this.removeClaim.selector
    //     );
    // }

    // Topic
    // public constant BIOMETRIC_TOPIC = 1; // you're a person and not a business
    //uint256 public constant RESIDENCE_TOPIC = 2; // you have a physical address or reference point
    //uint256 public constant REGISTRY_TOPIC = 3;
    //uint256 public constant PROFILE_TOPIC = 4; //  social media profiles, blogs, etc.
    //uint256 public constant LABEL_TOPIC = 5; //  real name, business name, nick name, brand name, alias, etc.
    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + claimType + data
        bytes data;
        string uri;
    }

    // Scheme
    uint256 internal constant ECDSA_SCHEME = 1;
    // https://medium.com/@alexberegszaszi/lets-bring-the-70s-to-ethereum-48daa16a4b51
    uint256 internal constant RSA_SCHEME = 2;
    // 3 is contract verification, where the data will be call data, and the issuer a contract address to call
    uint256 internal constant CONTRACT_SCHEME = 3;

    // Events
    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    // Functions
    function getClaim(bytes32 _claimId) public view returns(uint256 claimType, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);
    function getClaimIdsByType(uint256 _claimType) public view returns(bytes32[] memory claimIds);
    function addClaim(uint256 _claimType, uint256 _scheme, address issuer, bytes memory _signature, bytes memory _data, string memory _uri) public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}

// File: contracts/libraries/KeyBase.sol



library KeyStore {
    struct Key {
        uint256 purpose; //e.g., MANAGEMENT_KEY = 1, EXECUTION_KEY = 2, etc.
        uint256 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc.
        bytes32 key; // for non-hex and long keys, its the Keccak256 hash of the key
    }

    struct Keys {
        mapping (bytes32 => Key) keyData;
        mapping (uint256 => bytes32[]) keysByPurpose;
        uint numKeys;
    }

    /// @dev Find a key + purpose tuple
    /// @param key Key bytes to find
    /// @param purpose Purpose to find
    /// @return `true` if key + purpose tuple if found
    function find(Keys storage self, bytes32 key, uint256 purpose)
        internal
        view
        returns (bool)
    {
        Key memory k = self.keyData[key];
        if (k.key == 0) {
            return false;
        }
        if (k.purpose <= purpose) {
            return true;
        }
        return false;
    }
    

    /// @dev Add a Key
    /// @param key Key bytes to add
    /// @param purpose Purpose to add
    /// @param keyType Key type to add
    function add(Keys storage self, bytes32 key, uint256 purpose, uint256 keyType)
        internal
        
    {
        Key storage k = self.keyData[key];
        k.purpose = purpose;
        if (k.key == 0) {
            k.key = key;
            k.keyType = keyType;
        }
        self.keysByPurpose[purpose].push(key);
        self.numKeys++;
    }

    /// @dev Remove Key
    /// @param key Key bytes to remove
    /// @return Key type of the key that was removed
    function remove(Keys storage self, bytes32 key)
        internal
        returns (uint256 keyType)
    {
        keyType = self.keyData[key].keyType;
        // Delete purpose from keyData
        delete self.keyData[key];
        
        return keyType;
    }
}


/// @title KeyBase
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC725 implementation
/// @dev Key data is stored using KeyStore library

contract KeyBase {
    // Key storage
    using KeyStore for KeyStore.Keys;
    KeyStore.Keys internal allKeys;

    /// @dev Number of keys managed by the contract
    /// @return Unsigned integer number of keys
    function numKeys()
        external
        view
        returns (uint)
    {
        return allKeys.numKeys;
    }

    /// @dev Convert an Ethereum address (20 bytes) to an ERC725 key (32 bytes)
    function addrToKey(address addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(addr));
    }
}

// File: contracts/libraries/Pausable.sol





/// @title Pausable
/// @author Mircea Pasoi
/// @notice Base contract which allows children to implement an emergency stop mechanism
/// @dev Inspired by https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol

contract PausableI is KeyBase {
    event LogPause();
    event LogUnpause();

    bool public paused = false;

    /// @dev Modifier to make a function callable only when the contract is not paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused
    modifier whenPaused() {
        require(paused);
        _;
    }

    /// @dev called by a MANAGEMENT_KEY or the identity itself to pause, triggers stopped state
    function pause()
        public
        //onlyManagementOrSelf
        whenNotPaused
    {
        paused = true;
        emit LogPause();
    }

      /// @dev called by a MANAGEMENT_KEY or the identity itself to unpause, returns to normal state
    function unpause()
        public
        //onlyManagementOrSelf
        whenPaused
    {
        paused = false;
        emit LogUnpause();
    }
}

// File: contracts/libraries/ERC725.sol





/// @title ERC725
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC725

contract ERC725 is ERC165 {
    
     /*
     *     bytes4(keccak256('getKey(bytes32)')) == 0x12aaac70
     *     bytes4(keccak256('keyHasPurpose(bytes32,uint256)')) == 0xd202158d
     *     bytes4(keccak256('getKeysByPurpose(uint256)')) == 0x9010f726 
     *     bytes4(keccak256('addKey(bytes32,uint256,uint256)')) == 0x1d381240 
     *     bytes4(keccak256('removeKey(bytes32,uint256)')) == 0x53d413c5
     *     bytes4(keccak256('execute(address,uint256,bytes)')) == 0xb61d27f6
     *     bytes4(keccak256('approve(uint256,bool)')) == 0x747442d3
     *     bytes4(keccak256('changeKeysRequired(uint256,uint256)')) == 0xcf50f15f
     *     bytes4(keccak256('getKeysRequired(uint256)')) == 0xefa62498
     *    
     */
    bytes4 private constant _INTERFACE_ID_ERC725 = 0xfccbffbc;
    //_registerInterface(_INTERFACE_ID_ERC721);
    /// @dev Constructor that adds ERC725 as a supported interface
    constructor() internal {
       _registerInterface(_INTERFACE_ID_ERC725);
    }

    /// @dev ID for ERC165 pseudo-introspection
    /// @return ID for ERC725 interface
    // solhint-disable-next-line func-name-mixedcase
    // function ERC725ID() public pure returns (bytes4) {
    //     return (
    //         this.getKey.selector ^ this.keyHasPurpose.selector ^
    //         this.getKeysByPurpose.selector ^
    //         this.addKey.selector ^ this.removeKey.selector ^
    //         this.execute.selector ^ this.approve.selector ^
    //         this.changeKeysRequired.selector ^ this.getKeysRequired.selector
    //     );
    // }

    // Purpose
    // 1: MANAGEMENT keys, which can manage the identity
    // 2: EXECUTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
    // 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
    // 4: CREATE_EXAM_KEY keys, used to encrypt data e.g. hold in claims.
    // 5: GRADE_EXAM_KEY keys, which can manage the identity
    // 6: SUBMIT_EXAM_KEY keys, which can manage the identity
    
    // KeyType
    uint256 internal constant ECDSA_TYPE = 1;
    // https://medium.com/@alexberegszaszi/lets-bring-the-70s-to-ethereum-48daa16a4b51
    uint256 internal constant RSA_TYPE = 2;

    // Events
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);
    event KeysRequiredChanged(uint256 indexed purpose, uint256 indexed number);
    //  Extra event, not part of the standard
    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    // Functions
    function getKey(bytes32 _key) public view returns(uint256 purpose, uint256 keyType, bytes32 key);
    function keyHasPurpose(bytes32 _key, uint256 purpose) public view returns(bool exists);
    function getKeysByPurpose(uint256 _purpose) public view returns(bytes32[] memory keys);
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success);
    function removeKey(bytes32 _key) public returns (bool success);
    function execute(address _to, uint256 _value, bytes memory _data) public returns (uint256 executionId);
}


// File: contracts/interfaces/bases/IIdentity.sol





contract IIdentity is ERC725, ERC735{
}

// File: contracts/libraries/KeyManager.sol





contract KeyManager is PausableI, ERC725 {
    uint256 executionNonce;
    uint256 internal constant OPERATION_CALL = 0;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    mapping (uint256 => Execution) public executions;
    mapping (uint256 => address[]) public approved;
    /// @dev Add key data to the identity if key + purpose tuple doesn't already exist
    /// @param _key Key bytes to add
    /// @param _purpose Purpose to add
    /// @param _keyType Key type to add
    /// @return `true` if key was added, `false` if it already exists
    function addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    )
        public
        whenNotPaused
        returns (bool success)
    {
        if (allKeys.find(_key, _purpose)) {
            return false;
        }

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key");
        }
        
        _addKey(_key, _purpose, _keyType);
        return true;
    }

    /// @dev Remove key data from the identity
    /// @param _key Key bytes to remove

    /// @return `true` if key was found and removed, `false` if it wasn't found
    function removeKey(
        bytes32 _key
    )
        public
        whenNotPaused
        returns (bool success)
    {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key");
        }
        
        KeyStore.Key memory k = allKeys.keyData[_key];
        emit KeyRemoved(_key, k.purpose, k.keyType);
        
        allKeys.remove(_key);
        
        return true;
    }

    /// @dev Add key data to the identity without checking if it already exists
    /// @param _key Key bytes to add
    /// @param _purpose Purpose to add
    /// @param _keyType Key type to add
    function _addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    )
        internal
    {

        allKeys.add(_key, _purpose, _keyType);
        emit KeyAdded(_key, _purpose, _keyType);
    }

    function getKey(
        bytes32 _key
    )
        public
        view
        returns(uint256 purpose, uint256 keyType, bytes32 key)
    {
        KeyStore.Key memory k = allKeys.keyData[_key];
        purpose = k.purpose;
        keyType = k.keyType;
        key = k.key;
    }

    /// @dev Find if a key has is present and has the given purpose
    /// @param _key Key bytes to find
    /// @param purpose Purpose to find
    /// @return Boolean indicating whether the key exists or not
    function keyHasPurpose(
        bytes32 _key,
        uint256 purpose
    )
        public
        view
        returns(bool exists)
    {
        KeyStore.Key memory k = allKeys.keyData[_key];
        return k.purpose == purpose;
    }

    /// @dev Find all the keys held by this identity for a given purpose
    /// @param _purpose Purpose to find
    /// @return Array with key bytes for that purpose (empty if none)
    function getKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[] memory keys)
    {
        return allKeys.keysByPurpose[_purpose];
    }


    function approve(uint256 _id, bool _approve)
        public
        returns (bool success)
    {
        require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 2), "Sender does not have action key");

        emit Approved(_id, _approve);
        bytes memory tmp;

        if (_approve == true) {
            executions[_id].approved = true;
            (success, tmp) = executions[_id].to.call(executions[_id].data);
            if (success) {
                executions[_id].executed = true;
                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return false;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }


    function execute(address _to, uint256 _value, bytes memory _data)
        public
        returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 1) || keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }
}

// File: contracts/libraries/ClaimManager.sol








/// @title ClaimManager
/// @author Mircea Pasoi
/// @notice Implement functions from ERC735 spec
/// @dev  Key data is stored using KeyStore library. Inheriting ERC725 for the getters

contract ClaimManager is KeyManager, ERC735 {

    mapping (bytes32 => Claim) claims;
    mapping (uint256 => bytes32[]) claimsByType;

    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    )
        public
        returns (bytes32 claimRequestId)
    {
        bytes32 claimId = keccak256(abi.encodePacked(_issuer, _claimType));

        if (msg.sender != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 3), "Sender does not have claim signer key");
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByType[_claimType].push(claimId);
        }

        claims[claimId].claimType = _claimType;
        claims[claimId].scheme = _scheme;
        claims[claimId].issuer = _issuer;
        claims[claimId].signature = _signature;
        claims[claimId].data = _data;
        claims[claimId].uri = _uri;

        emit ClaimAdded(
            claimId,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

    function removeClaim(bytes32 _claimId) public returns (bool success) {
        if (msg.sender != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 3), "Sender does not have claim signer key");
        }

        /* uint index; */
        /* (index, ) = claimsByType[claims[_claimId].claimType].indexOf(_claimId);
        claimsByType[claims[_claimId].claimType].removeByIndex(index); */

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        delete claims[_claimId];
        return true;
    }

    function getClaim(bytes32 _claimId)
        public
        view
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {
        return (
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );
    }

    function getClaimIdsByType(uint256 _claimType)
        public
        view
        returns(bytes32[] memory claimIds)
    {
        return claimsByType[_claimType];
    }

}


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)



/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x602d8060093d393df3363d3d373d3d3d363d7300000000000000000000000000)
            mstore(add(ptr, 0x13), shl(0x60, implementation))
            mstore(add(ptr, 0x27), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x36)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x602d8060093d393df3363d3d373d3d3d363d7300000000000000000000000000)
            mstore(add(ptr, 0x13), shl(0x60, implementation))
            mstore(add(ptr, 0x27), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x36, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x602d8060093d393df3363d3d373d3d3d363d7300000000000000000000000000)
            mstore(add(ptr, 0x13), shl(0x60, implementation))
            mstore(add(ptr, 0x27), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x37), shl(0x60, deployer))
            mstore(add(ptr, 0x4b), salt)
            mstore(add(ptr, 0x6b), keccak256(ptr, 0x36))
            predicted := keccak256(add(ptr, 0x36), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File: contracts/factories/IdentityFactory.sol

pragma solidity ^0.5.4;
import "./Libraries.sol";

contract Identity is KeyManager, ClaimManager, IIdentity {
    bool isInitialized;
    
    function initial(address _owner) public {
        require(!isInitialized);
        _addKey(addrToKey(_owner), 1, ECDSA_TYPE);      
        _addKey(addrToKey(_owner), 3, ECDSA_TYPE);         
        isInitialized = true;
    }
}
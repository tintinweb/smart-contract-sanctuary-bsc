// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

import "../registry/MID.sol";
import "./IMIDRegistrarController.sol";
import "../resolvers/Resolver.sol";
import "./IBulkRenewal.sol";

contract BulkRenewal is IBulkRenewal {
    // namehash(.bnb)
    bytes32 constant private MID_NAMEHASH = 0xdba5666821b22671387fe7ea11d7cc41ede85a5aa67c3e7b3d68ce6a661f389c;
    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    MID public mid;
    IMIDRegistrarController controller;

    constructor(MID _mid, IMIDRegistrarController _controller) {
        require(address(_mid) != address(0) && address(_controller) != address(0), "invalid address");
        mid = _mid;
        controller = _controller;
    }

    function rentPrice(string[] calldata names, uint duration) external view override returns(uint total) {
        for(uint i = 0; i < names.length; i++) {
            total += controller.rentPrice(names[i], duration);
        }
    }

    function rentPrices(string[] calldata names, uint[] calldata durations) external view override returns(uint total) {
        for(uint i = 0; i < names.length; i++) {
            total += controller.rentPrice(names[i], durations[i]);
        }
    }

    function renewAll(string[] calldata names, uint duration) external payable override {
        for(uint i = 0; i < names.length; i++) {
            uint cost = controller.rentPrice(names[i], duration);
            controller.renew{value:cost}(names[i], duration);
        }
        // Send any excess funds back
        payable(msg.sender).transfer(address(this).balance);
    }

    // batch commit & register and helpers
    function makeBatchCommitmentWithConfig(string[] memory names, address owner, bytes32 secret, address resolver, address addr) view public override returns (bytes32[] memory results) {
        require(names.length > 0, "name count 0");
        results = new bytes32[](names.length);
        for (uint i = 0; i < names.length; ++i) {
            results[i] = controller.makeCommitmentWithConfig(names[i], owner, secret, resolver, addr);
        }
    }

    function batchCommit(bytes32[] memory commitments_) public override {
        require(commitments_.length > 0, "commitment count 0");
        for (uint i = 0; i < commitments_.length; ++i) {
            controller.commit(commitments_[i]);
        }
    }

    function batchRegisterWithConfig(string[] memory names, address owner, uint[] memory durations, bytes32 secret, address resolver, address addr) external payable override {
        require(names.length > 0, "name count 0");
        require(names.length == durations.length, "length mismatch");
        for (uint i = 0; i < names.length; ++i) {
            uint cost = controller.rentPrice(names[i], durations[i]);
            controller.registerWithConfig{value: cost}(names[i], owner, durations[i], secret, resolver, addr);
        }
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
         return interfaceID == INTERFACE_META_ID || interfaceID == type(IBulkRenewal).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

interface IBulkRenewal {
    function rentPrice(string[] calldata names, uint duration) external view returns(uint total);

    function rentPrices(string[] calldata names, uint[] calldata durations) external view returns(uint total);

    function renewAll(string[] calldata names, uint duration) external payable;

    function makeBatchCommitmentWithConfig(string[] memory names, address owner, bytes32 secret, address resolver, address addr) view external returns (bytes32[] memory results);
    
    function batchCommit(bytes32[] memory commitments_) external;
    
    function batchRegisterWithConfig(string[] memory names, address owner, uint[] memory durations, bytes32 secret, address resolver, address addr) external payable;

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/*
 * @dev A registrar controller for registering and renewing names at fixed cost.
 */
interface IMIDRegistrarController {
    function rentPrice(string memory name, uint duration) external view returns(uint);

    function available(string memory name) external view returns(bool);

    function makeCommitment(string memory name, address owner, bytes32 secret) pure external returns(bytes32);

    function makeCommitmentWithConfig(string memory name, address owner, bytes32 secret, address resolver, address addr) pure external returns(bytes32);

    function commit(bytes32 commitment) external;

    function register(string calldata name, address owner, uint duration, bytes32 secret) external payable;

    function registerWithConfig(string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) external payable;

    function renew(string calldata name, uint duration) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface MID {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner_);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner_);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver_);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl_);

    // Logged when an operator is added or removed.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner_, address resolver_, uint64 ttl_) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner_, address resolver_, uint64 ttl_) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner_) external returns(bytes32);
    function setResolver(bytes32 node, address resolver_) external;
    function setOwner(bytes32 node, address owner_) external;
    function setTTL(bytes32 node, uint64 ttl_) external;
    function setApprovalForAll(address operator, bool approved) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner_, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

/**
 * A generic resolver interface which includes all the functions including the ones deprecated
 */
interface Resolver{
    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);
    /* Deprecated events */
    event ContentChanged(bytes32 indexed node, bytes32 hash);

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function addr(bytes32 node) external view returns (address);
    function addr(bytes32 node, uint coinType) external view returns(bytes memory);
    function contenthash(bytes32 node) external view returns (bytes memory);
    function dnsrr(bytes32 node) external view returns (bytes memory);
    function name(bytes32 node) external view returns (string memory);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns (string memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);
    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external;
    function setAddr(bytes32 node, address addr_) external;
    function setAddr(bytes32 node, uint coinType, bytes calldata a) external;
    function setContenthash(bytes32 node, bytes calldata hash) external;
    function setDnsrr(bytes32 node, bytes calldata data) external;
    function setName(bytes32 node, string calldata _name) external;
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external;
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
    function multicall(bytes[] calldata data) external returns(bytes[] memory results);

    /* Deprecated functions */
    function content(bytes32 node) external view returns (bytes32);
    function multihash(bytes32 node) external view returns (bytes memory);
    function setContent(bytes32 node, bytes32 hash) external;
    function setMultihash(bytes32 node, bytes calldata hash) external;
}
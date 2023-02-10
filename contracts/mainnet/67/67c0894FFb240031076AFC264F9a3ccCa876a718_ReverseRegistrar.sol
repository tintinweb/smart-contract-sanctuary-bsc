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

import "./MID.sol";

abstract contract NameResolver {
    function setName(bytes32 node, string memory name) public virtual;
}

contract ReverseRegistrar {
    // namehash('addr.reverse')
    bytes32 public constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    MID public mid;
    NameResolver public defaultResolver;

    /**
     * @dev Constructor
     * @param ensAddr The address of the MID registry.
     * @param resolverAddr The address of the default reverse resolver.
     */
    constructor(MID ensAddr, NameResolver resolverAddr) {
        mid = ensAddr;
        defaultResolver = resolverAddr;

        // Assign ownership of the reverse record to our deployer
        ReverseRegistrar oldRegistrar = ReverseRegistrar(mid.owner(ADDR_REVERSE_NODE));
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }

    /**
     * @dev Transfers ownership of the reverse MID record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in MID.
     * @return The MID node hash of the reverse record.
     */
    function claim(address owner) public returns (bytes32) {
        return claimWithResolver(owner, address(0x0));
    }

    /**
     * @dev Transfers ownership of the reverse MID record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in MID.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The MID node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver) public returns (bytes32) {
        bytes32 label = sha3HexAddress(msg.sender);
        bytes32 node_ = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentOwner = mid.owner(node_);

        // Update the resolver if required
        if (resolver != address(0x0) && resolver != mid.resolver(node_)) {
            // Transfer the name to us first if it's not already
            if (currentOwner != address(this)) {
                mid.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));
                currentOwner = address(this);
            }
            mid.setResolver(node_, resolver);
        }

        // Update the owner if required
        if (currentOwner != owner) {
            mid.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        }

        return node_;
    }

    /**
     * @dev Sets the `name()` record for the reverse MID record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The MID node hash of the reverse record.
     */
    function setName(string memory name) public returns (bytes32) {
        bytes32 node_ = claimWithResolver(address(this), address(defaultResolver));
        defaultResolver.setName(node_, name);
        return node_;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The MID node hash.
     */
    function node(address addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        addr;
        ret; // Stop warning us about unused variables
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000

            for { let i := 40 } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }
}
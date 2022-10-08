// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../interfaces/IBoundRegistrarController.sol";
import "../interfaces/IBulkRegistrarController.sol";
import "../interfaces/IRegistry.sol";
import "../interfaces/IRegistrar.sol";
import "../interfaces/IRegistrarController.sol";
import "../interfaces/IResolver.sol";
import "../interfaces/IPriceOracle.sol";

contract BulkRegistrarController is IBulkRegistrarController {
    address public constant NATIVE_TOKEN_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IRegistry public immutable registry;

    constructor(IRegistry _registry) {
        registry = _registry;
    }

    function getController(IRegistrar registrar)
        internal
        view
        returns (IRegistrarController)
    {
        IResolver r = IResolver(registry.resolver(registrar.baseNode()));
        return
            IRegistrarController(
                r.interfaceImplementer(
                    registrar.baseNode(),
                    type(IRegistrarController).interfaceId
                )
            );
    }

    function nameRecords(
        address registrar,
        bytes32 node,
        string[] calldata keys
    ) external view override returns (address payable, string[] memory) {
        string[] memory values = new string[](keys.length);
        IResolver r = IResolver(
            registry.resolver(IRegistrar(registrar).baseNode())
        );
        for (uint256 i = 0; i < keys.length; i++) {
            values[i] = r.text(node, keys[i]);
        }
        return (r.addr(node), values);
    }

    function available(address[] calldata registrars, string[] calldata names)
        external
        view
        override
        returns (bool[] memory, uint256[] memory)
    {
        require(
            registrars.length == names.length,
            "registrars and names lengths do not match"
        );
        bool[] memory unregistered = new bool[](names.length);
        uint256[] memory expires = new uint256[](names.length);
        for (uint256 i = 0; i < names.length; i++) {
            uint256 labelId = uint256(keccak256(bytes(names[i])));
            IRegistrar registrar = IRegistrar(registrars[i]);
            if (!registrar.available(labelId)) {
                unregistered[i] = false;
                expires[i] = registrar.nameExpires(labelId);
            } else {
                unregistered[i] = true;
                expires[i] = 0;
            }
        }
        return (unregistered, expires);
    }

    function rentPrice(
        address[] calldata registrars,
        string[] calldata names,
        uint256[] calldata durations
    ) external view override returns (RentPrice[] memory) {
        require(
            registrars.length == names.length,
            "registrars and names lengths do not match"
        );
        require(
            names.length == durations.length,
            "names and durations lengths do not match"
        );

        RentPrice[] memory prices = new RentPrice[](names.length);
        for (uint256 i = 0; i < names.length; i++) {
            IRegistrarController controller = getController(
                IRegistrar(registrars[i])
            );
            IPriceOracle.Price memory price = controller.rentPrice(
                registrars[i],
                names[i],
                durations[i]
            );
            prices[i] = RentPrice(price.currency, price.base + price.premium);
        }
        return prices;
    }

    function bulkRenew(
        address[] calldata registrars,
        string[] calldata names,
        uint256[] calldata durations
    ) external payable override {
        require(
            registrars.length == names.length &&
                names.length == durations.length,
            "arrays lengths do not match"
        );

        for (uint256 i = 0; i < names.length; i++) {
            IRegistrarController controller = getController(
                IRegistrar(registrars[i])
            );
            IPriceOracle.Price memory price = controller.rentPrice(
                registrars[i],
                names[i],
                durations[i]
            );

            if (price.currency == NATIVE_TOKEN_ADDRESS) {
                controller.renew{value: price.base + price.premium}(
                    registrars[i],
                    names[i],
                    durations[i]
                );
            } else {
                controller.renew(registrars[i], names[i], durations[i]);
            }
        }
        if (address(this).balance > 0) {
            // Send any excess funds back
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function controllerInterfaceId() public pure returns (bytes4) {
        return type(IRegistrarController).interfaceId;
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return
            interfaceID == type(IERC165).interfaceId ||
            interfaceID == type(IBulkRegistrarController).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IRegistry {
    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setSubnodeResolverAndTTL(
        bytes32 node,
        bytes32 label,
        address resolver,
        uint64 ttl
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IRegistrarController.sol";
import "../libraries/Registration.sol";

interface IBoundRegistrarController is IRegistrarController {
    function register(Registration.RegisterOrder calldata order)
        external
        payable;

    function registerWithETH(Registration.RegisterOrder calldata order)
        external
        payable;

    function bulkRegister(Registration.RegisterOrder[] calldata orders)
        external
        payable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IControllable.sol";
import "./IRegistrar.sol";
import "./IRegistry.sol";

interface IRegistrar is IControllable {
    event NameRegistered(
        uint256 indexed tokenId,
        uint256 indexed labelId,
        address indexed owner,
        uint256 expires
    );
    event NameRenewed(
        uint256 indexed tokenId,
        uint256 indexed labelId,
        uint256 expires
    );

    /**
     * @dev Returns the registrar tld name.
     */
    function tld() external view returns (string memory);

    // The namehash of the TLD this registrar owns (eg, namehash('registrar addr'+'eth'))
    function baseNode() external view returns (bytes32);

    function gracePeriod() external pure returns (uint256);

    /**
     * @dev Returns the domain name of the `tokenId`.
     */
    function nameOf(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Returns the `tokenId` of the `labelId`.
     */
    function tokenOf(uint256 labelId) external view returns (uint256);

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external;

    // Returns the expiration timestamp of the specified label hash.
    function nameExpires(uint256 labelId) external view returns (uint256);

    // Returns true if the specified name is available for registration.
    function available(uint256 labelId) external view returns (bool);

    // Returns the registrar issuer address.
    function issuer() external view returns (address);

    // Returns the recipient of name register or renew fees.
    function feeRecipient() external view returns (address payable);

    // Returns the price oracle address.
    function priceOracle() external view returns (address);

    function nextTokenId() external view returns (uint256);

    function exists(uint256 tokenId) external view returns (bool);

    // Register a name.
    function register(
        string calldata name,
        address owner,
        uint256 duration,
        address resolver
    ) external returns (uint256 tokenId, uint256 expires);

    // Extend a name.
    function renew(uint256 labelId, uint256 duration)
        external
        returns (uint256 tokenId, uint256 expires);

    /**
     * @dev Reclaim ownership of a name, if you own it in the registrar.
     */
    function reclaim(uint256 labelId, address owner) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../libraries/Registration.sol";

interface IBulkRegistrarController {
    event NameRegisterFailed(
        address indexed registrar,
        bytes32 indexed labelId,
        string name
    );

    struct RentPrice {
        address currency;
        uint256 cost;
    }

    function nameRecords(
        address registrar,
        bytes32 node,
        string[] calldata keys
    ) external view returns (address payable, string[] memory);

    function available(address[] calldata registrars, string[] calldata names)
        external
        view
        returns (bool[] memory, uint256[] memory);

    function rentPrice(
        address[] calldata registrars,
        string[] calldata names,
        uint256[] calldata durations
    ) external view returns (RentPrice[] memory);

    function bulkRenew(
        address[] calldata registrars,
        string[] calldata names,
        uint256[] calldata durations
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IPriceOracle {
    struct Price {
        address currency;
        uint256 base;
        uint256 premium;
    }

    /**
     * @dev Returns the price to register or renew a name.
     * @param name The name being registered or renewed.
     * @param expires When the name presently expires (0 if this is a new registration).
     * @param duration How long the name is being registered or extended for, in seconds.
     * @return base premium tuple of base price + premium price
     */
    function price(
        string calldata name,
        uint256 expires,
        uint256 duration
    ) external view returns (Price calldata);

    /**
     * @dev Returns the payment token for register or renew a name.
     */
    function currency() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IPriceOracle.sol";

interface IRegistrarController {
    event NameRegistered(
        address indexed registrar,
        bytes32 indexed labelId,
        string name,
        address owner,
        uint256 tokenId,
        uint256 cost,
        uint256 expires
    );

    event NameRenewed(
        address indexed registrar,
        bytes32 indexed labelId,
        string name,
        uint256 tokenId,
        uint256 cost,
        uint256 expires
    );

    function rentPrice(
        address registrar,
        string memory name,
        uint256 duration
    ) external view returns (IPriceOracle.Price memory);

    function available(address registrar, string memory name)
        external
        view
        returns (bool);

    // Returns the expiration timestamp of the specified label.
    function nameExpires(address registrar, string memory name)
        external
        view
        returns (uint256);

    // extend name registration
    function renew(
        address registrar,
        string calldata name,
        uint256 duration
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../interfaces/profiles/IABIResolver.sol";
import "../interfaces/profiles/IAddrResolver.sol";
import "../interfaces/profiles/IContentHashResolver.sol";
import "../interfaces/profiles/IInterfaceResolver.sol";
import "../interfaces/profiles/INameResolver.sol";
import "../interfaces/profiles/IPubkeyResolver.sol";
import "../interfaces/profiles/ITextResolver.sol";
import "../interfaces/profiles/IExtendedResolver.sol";

/**
 * A generic resolver interface which includes all the functions including the ones deprecated
 */
interface IResolver is
    IERC165,
    IABIResolver,
    IAddrResolver,
    IContentHashResolver,
    IInterfaceResolver,
    INameResolver,
    IPubkeyResolver,
    ITextResolver,
    IExtendedResolver
{
    function setABI(
        bytes32 node,
        uint256 contentType,
        bytes calldata data
    ) external;

    function setAddr(bytes32 node, address addr) external;

    function setAddrWithCoinType(
        bytes32 node,
        uint256 coinType,
        bytes calldata a
    ) external;

    function setContenthash(bytes32 node, bytes calldata hash) external;

    function setName(bytes32 node, string calldata _name) external;

    function setPubkey(
        bytes32 node,
        bytes32 x,
        bytes32 y
    ) external;

    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external;

    function setInterface(
        bytes32 node,
        bytes4 interfaceID,
        address implementer
    ) external;

    function multicall(bytes[] calldata data)
        external
        returns (bytes[] memory results);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

library Registration {
    // keccak256("RegisterOrder(address issuer,address registrar,address owner,address resolver,address currency,uint256 duration,uint256 applyingTime,bytes name,bytes params)")
    bytes32 public constant REGISTER_ORDER_HASH =
        keccak256(
            "RegisterOrder(address issuer,address registrar,address owner,address resolver,address currency,uint256 duration,uint256 applyingTime,bytes name,bytes params)"
        );

    struct RegisterOrder {
        address issuer; // name issuer address (signer)
        address registrar; // TLD registrar
        address owner; // name owner address
        address resolver; // name resolver, used to resolve name information
        address currency; // register payment token (e.g., WETH)
        uint256 duration; // name validity period
        uint256 applyingTime; // name registration needs to wait for a period of time(minCommitmentAge) after the applying time
        bytes name; // name being registered
        bytes params; // additional parameters
        uint8 v; // v: parameter (27 or 28)
        bytes32 r; // r: parameter
        bytes32 s; // s: parameter
    }

    function hash(RegisterOrder memory registerOrder)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    REGISTER_ORDER_HASH,
                    registerOrder.issuer,
                    registerOrder.registrar,
                    registerOrder.owner,
                    registerOrder.resolver,
                    registerOrder.currency,
                    registerOrder.duration,
                    registerOrder.applyingTime,
                    keccak256(registerOrder.name),
                    keccak256(registerOrder.params)
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IControllable {
    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);

    function isController(address controller) external view returns (bool);

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external;

    // Revoke controller permission for an address.
    function removeController(address controller) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IABIResolver.sol";

interface IABIResolver {
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    /**
     * Returns the ABI associated with an node.
     * Defined in EIP205.
     * @param node The node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes)
        external
        view
        returns (uint256, bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IInterfaceResolver {
    event InterfaceChanged(
        bytes32 indexed node,
        bytes4 indexed interfaceID,
        address implementer
    );

    /**
     * Returns the address of a contract that implements the specified interface for this name.
     * If an implementer has not been set for this interfaceID and name, the resolver will query
     * the contract at `addr()`. If `addr()` is set, a contract exists at that address, and that
     * contract implements EIP165 and returns `true` for the specified interfaceID, its address
     * will be returned.
     * @param node The node to query.
     * @param interfaceID The EIP 165 interface ID to check for.
     * @return The address that implements this interface, or 0 if the interface is unsupported.
     */
    function interfaceImplementer(bytes32 node, bytes4 interfaceID)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * Interface for the new (multicoin) addr function.
 */
interface IAddrResolver {
    event AddressChanged(
        bytes32 indexed node,
        uint256 coinType,
        bytes newAddress
    );

    function addr(bytes32 node) external view returns (address payable);

    function addrWithCoinType(bytes32 node, uint256 coinType)
        external
        view
        returns (bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IContentHashResolver {
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    /**
     * Returns the contenthash associated with an node.
     * @param node The node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IExtendedResolver {
    function resolve(bytes memory name, bytes memory data)
        external
        view
        returns (bytes memory, address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IPubkeyResolver {
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    /**
     * Returns the SECP256k1 public key associated with an node.
     * Defined in EIP 619.
     * @param node The node to query
     * @return x The X coordinate of the curve point for the public key.
     * @return y The Y coordinate of the curve point for the public key.
     */
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ITextResolver {
    event TextChanged(bytes32 indexed node, string key, string value);

    /**
     * Returns the text data associated with an node and key.
     * @param node The node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string calldata key)
        external
        view
        returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INameResolver {
    event NameChanged(bytes32 indexed node, string name);

    /**
     * Returns the name associated with an node, for reverse records.
     * Defined in EIP181.
     * @param node The node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory);
}
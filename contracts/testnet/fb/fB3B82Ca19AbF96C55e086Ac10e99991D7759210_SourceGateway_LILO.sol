// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SourceGateway.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract SourceGateway_LILO is SourceGateway, ERC1155Receiver {
    constructor(address anyCallProxy, uint256 flag)
        SourceGateway(anyCallProxy, flag)
    {}

    function _swapout(
        address tokenAddress,
        address sender,
        uint256 tokenId
    ) internal virtual override returns (bool, bytes memory) {
        // lock the tokens
        IERC1155(tokenAddress).safeTransferFrom(
            sender,
            address(this),
            tokenId,
            1,
            ""
        );

        return (true, "");
    }

    function _swapin(
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        address receiver,
        bytes memory extraMsg
    ) internal override returns (bool) {
        IERC1155(tokenAddress).safeTransferFrom(
            address(this),
            receiver,
            tokenId,
            amount,
            extraMsg
        );
        return true;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IVenlyERC1155 is IERC1155 {
    function mintNonFungible(
        uint256 typeId,
        uint256 id,
        address account
    ) external;

    function createTypeAndMintNonFungibleBatch(
        uint256 typeId,
        uint256 maxSupply,
        bool burnable,
        string memory uri_,
        uint256[] calldata ids,
        address[] calldata accounts
    ) external;

    function createType(
        uint256 typeId,
        uint256 maxSupply,
        bool fungible,
        bool burnable,
        string memory uri_
    ) external;

    function burn(
        uint256 id,
        address account,
        uint256 amount
    ) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function contractURI() external view returns (string memory);

    function autoApprovedAddressesLocked() external view returns (bool);

    function maxSupplyForType(uint256) external view returns (uint256);

    function typeForToken(uint256) external view returns (uint256);

    function typeIsFungible(uint256) external view returns (bool);

    function uris(uint256) external view returns (string memory);
}

pragma solidity ^0.8.0;

interface IGateway {
    function Swapout_no_fallback(
        address tokenAddress,
        uint256 tokenId,
        address receiver,
        uint256 destChainID
    ) external payable returns (uint256);
}

pragma solidity ^0.8.0;

interface IExecutor {
    function context()
        external
        returns (
            address from,
            uint256 fromChainID,
            uint256 nonce
        );
}

pragma solidity ^0.8.0;

interface IAnycallV6Proxy {
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags
    ) external payable;

    function executor() external view returns (address);
}

pragma solidity ^0.8.0;

import "./Administrable.sol";
import "../interfaces/IAnycallV6Proxy.sol";
import "../interfaces/IExecutor.sol";

abstract contract AnyCallApp is Administrable {
    uint256 public flag; // 0: pay on dest chain, 2: pay on source chain
    address public immutable anyCallProxy;

    mapping(uint256 => address) internal peer;

    event SetPeers(uint256[] chainIDs, address[] peers);
    event SetAnyCallProxy(address proxy);

    modifier onlyExecutor() {
        require(msg.sender == IAnycallV6Proxy(anyCallProxy).executor());
        _;
    }

    constructor(address anyCallProxy_, uint256 flag_) {
        anyCallProxy = anyCallProxy_;
        flag = flag_;
    }

    function setPeers(uint256[] memory chainIDs, address[] memory peers)
        public
        onlyAdmin
    {
        for (uint256 i = 0; i < chainIDs.length; i++) {
            peer[chainIDs[i]] = peers[i];
            emit SetPeers(chainIDs, peers);
        }
    }

    function getPeer(uint256 foreignChainID) external view returns (address) {
        return peer[foreignChainID];
    }

    /**
     * @dev Uncomment this function if the app owner wants full control of the contract.
     */
    //function setAnyCallProxy(address proxy) public onlyAdmin {
    //    anyCallProxy = proxy;
    //    emit SetAnyCallProxy(proxy);
    //}

    function _anyExecute(uint256 fromChainID, bytes calldata data)
        internal
        virtual
        returns (bool success, bytes memory result);

    function _anyCall(
        address _to,
        bytes memory _data,
        address _fallback,
        uint256 _toChainID
    ) internal {
        if (flag == 2) {
            IAnycallV6Proxy(anyCallProxy).anyCall{value: msg.value}(
                _to,
                _data,
                _fallback,
                _toChainID,
                flag
            );
        } else {
            IAnycallV6Proxy(anyCallProxy).anyCall(
                _to,
                _data,
                _fallback,
                _toChainID,
                flag
            );
        }
    }

    function anyExecute(bytes calldata data)
        external
        onlyExecutor
        returns (bool success, bytes memory result)
    {
        (address callFrom, uint256 fromChainID, ) = IExecutor(
            IAnycallV6Proxy(anyCallProxy).executor()
        ).context();
        require(peer[fromChainID] == callFrom, "call not allowed");
        _anyExecute(fromChainID, data);
    }
}

pragma solidity ^0.8.0;

contract Administrable {
    address public admin;
    address public pendingAdmin;
    event LogSetAdmin(address admin);
    event LogTransferAdmin(address oldadmin, address newadmin);
    event LogAcceptAdmin(address admin);

    function setAdmin(address admin_) internal {
        admin = admin_;
        emit LogSetAdmin(admin_);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        address oldAdmin = pendingAdmin;
        pendingAdmin = newAdmin;
        emit LogTransferAdmin(oldAdmin, newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit LogAcceptAdmin(admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}

pragma solidity ^0.8.0;

import "./common/AnycallApp.sol";
import "./interfaces/IGeteway.sol";
import "./interfaces/IVenlyERC1155.sol";

abstract contract SourceGateway is IGateway, AnyCallApp {
    uint256 public swapoutSeq;

    constructor(address anyCallProxy, uint256 flag)
        AnyCallApp(anyCallProxy, flag)
    {
        setAdmin(msg.sender);
    }

    event LogAnySwapOut(
        address tokenAddress,
        uint256 tokenId,
        address sender,
        address receiver,
        uint256 toChainID,
        uint256 swapoutSeq
    );

    event LogAnySwapIn(
        address tokenAddress,
        uint256 tokenId,
        address sender,
        address receiver,
        uint256 fromChainID
    );

    function _swapout(
        address tokenAddress,
        address sender,
        uint256 tokenId
    ) internal virtual returns (bool, bytes memory);

    function _swapin(
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        address receiver,
        bytes memory extraMsg
    ) internal virtual returns (bool);

    function Swapout_no_fallback(
        address tokenAddress,
        uint256 tokenId,
        address receiver,
        uint256 destChainID
    ) external payable override returns (uint256) {
        (bool ok, ) = _swapout(tokenAddress, msg.sender, tokenId);

        require(ok, "failed to get tokens");

        swapoutSeq++;

        IVenlyERC1155 sourceNFT = IVenlyERC1155(tokenAddress);

        uint256 typeId = sourceNFT.typeForToken(tokenId);

        bytes memory data = abi.encode(
            tokenAddress,
            typeId,
            tokenId,
            sourceNFT.maxSupplyForType(typeId),
            sourceNFT.uris(tokenId),
            sourceNFT.name(),
            sourceNFT.symbol(),
            sourceNFT.contractURI(),
            msg.sender,
            receiver,
            swapoutSeq
        );

        _anyCall(peer[destChainID], data, address(0), destChainID);

        emit LogAnySwapOut(
            tokenAddress,
            tokenId,
            msg.sender,
            receiver,
            destChainID,
            swapoutSeq
        );
        return swapoutSeq;
    }

    function _anyExecute(uint256 fromChainID, bytes calldata data)
        internal
        override
        returns (bool success, bytes memory result)
    {
        (
            address tokenAddress,
            uint256 tokenId,
            uint256 amount,
            ,
            address receiver,
            ,
            bytes memory extraMsg
        ) = abi.decode(
                data,
                (address, uint256, uint256, address, address, uint256, bytes)
            );
        require(_swapin(tokenAddress, tokenId, amount, receiver, extraMsg));

        emit LogAnySwapIn(
            tokenAddress,
            tokenId,
            msg.sender,
            receiver,
            fromChainID
        );
    }

    function updateFlag(uint256 _flag) external onlyAdmin {
        flag = _flag;
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
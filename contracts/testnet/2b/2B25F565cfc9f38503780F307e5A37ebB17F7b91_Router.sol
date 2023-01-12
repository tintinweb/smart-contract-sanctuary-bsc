// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

interface IAdminHolder {
    function admin() external view returns (address);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

interface IOwnable {
    error AccessDenied();

    function owner() external view returns (address);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

import './IOwnable.sol';

interface IOwnableTransferable is IOwnable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address) external;
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

import './ITopLevelDomain.sol';
import './ITopLevelDomainsFactory.sol';

interface IRouter {
    struct DomainInformation {
        ITopLevelDomain tld;
        uint256 tokenId;
        address owner;
    }

    event TopLevelDomainRegistered(ITopLevelDomain);

    error OnlyAdminAccess();
    error TopLevelDomainAlreadyRegistered();
    error TopLevelDomainDoesNotExist();
    error NotAllowedToRegister();
    error FactoryIsNotSet();

    function registerTopLevelDomain(ITopLevelDomain domain) external;

    function domainInfo(
        string calldata domain,
        string calldata tld
    ) external view returns (DomainInformation memory);

    function subdomainInfo(
        string calldata subdomain,
        string calldata domain,
        string calldata tld
    ) external view returns (DomainInformation memory);

    function topLevelDomain(string calldata tld) external view returns (ITopLevelDomain);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

import './IAdminHolder.sol';
import './IOwnableTransferable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface ITopLevelDomain is IAdminHolder, IOwnableTransferable {
    error TokenDoesNotExist();

    event DomainMinted(string domain);
    event SubdomainMinted(string subdomain, string domain);

    function mintDomain(string memory domain, address to) external;

    function mintSubdomain(string calldata subdomain, string memory domain, address to) external;

    function mintDomainWithSignature(
        string calldata domain,
        address to,
        bytes calldata signature
    ) external;

    function name() external view returns (string memory);

    function tokenIdOfDomain(string calldata domain) external view returns (uint256);

    function tokenIdOfSubdomain(
        string calldata subdomain,
        string calldata domain
    ) external view returns (uint256);

    function tokenOwnerOfDomain(string calldata domain) external view returns (address);

    function tokenOwnerOfSubdomain(
        string calldata _subdomain,
        string calldata domain
    ) external view returns (address);

    function ownerOf(uint256 domainId) external view returns (address);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

import './IAdminHolder.sol';
import './IRouter.sol';

interface ITopLevelDomainsFactory {
    error OnlyAdminAccess();
    error RouterNotSet();

    function router() external view returns (IRouter);

    function mintTopLevelDomain(string calldata _topLevelDomain, address _to) external;

    function baseMetadataURI() external view returns (string memory);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.17;

import './interfaces/IRouter.sol';
import './interfaces/IAdminHolder.sol';
import '@openzeppelin/contracts/utils/Context.sol';

contract Router is Context, IAdminHolder, IRouter {
    address public override admin;
    ITopLevelDomainsFactory public factory;
    mapping(string => ITopLevelDomain) public tlds;

    constructor(address _admin) {
        admin = _admin;
    }

    function setFactory(ITopLevelDomainsFactory _factory) external onlyAdminAccess {
        factory = _factory;
    }

    function registerTopLevelDomain(
        ITopLevelDomain tld
    ) external onlyFactoryAccess onlyIfTLDNotRegistered(tld.name()) {
        tlds[tld.name()] = tld;
        emit TopLevelDomainRegistered(tld);
    }

    function _getTLD(string calldata _tld) internal view returns (ITopLevelDomain) {
        ITopLevelDomain tld = tlds[_tld];
        _ensureTLDExists(tld);
        return tld;
    }

    function domainInfo(
        string calldata _domain,
        string calldata _tld
    ) external view returns (DomainInformation memory) {
        ITopLevelDomain tld = _getTLD(_tld);
        uint256 domainId = tld.tokenIdOfDomain(_domain);
        return DomainInformation({tld: tld, tokenId: domainId, owner: tld.ownerOf(domainId)});
    }

    function subdomainInfo(
        string calldata _subdomain,
        string calldata _domain,
        string calldata _tld
    ) external view returns (DomainInformation memory) {
        ITopLevelDomain tld = _getTLD(_tld);
        uint256 subdomainId = tld.tokenIdOfSubdomain(_subdomain, _domain);
        return DomainInformation({tld: tld, tokenId: subdomainId, owner: tld.ownerOf(subdomainId)});
    }

    function topLevelDomain(string calldata _tld) external view returns (ITopLevelDomain) {
        ITopLevelDomain tld = tlds[_tld];
        _ensureTLDExists(tld);
        return tld;
    }

    function _ensureTLDExists(ITopLevelDomain tld) internal pure {
        if (address(tld) == address(0)) {
            revert TopLevelDomainDoesNotExist();
        }
    }

    modifier onlyFactoryAccess() {
        if (_msgSender() != address(factory)) {
            revert NotAllowedToRegister();
        }
        _;
    }

    modifier onlyIfTLDNotRegistered(string memory tld) {
        ITopLevelDomain tld_ = tlds[tld];
        if (address(tld_) != address(0)) {
            revert TopLevelDomainAlreadyRegistered();
        }
        _;
    }

    modifier onlyAdminAccess() {
        if (_msgSender() != admin) {
            revert OnlyAdminAccess();
        }
        _;
    }
}
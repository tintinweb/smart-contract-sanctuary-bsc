// contracts/GobblingApi.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Api/Erc721API.sol";
import "./IGobbling.sol";

contract GobblingApi is Erc721API {

    function ApiId() public view virtual override returns (bytes32) {
        return keccak256("GobblingApi");
    }

    function gblExistAll(IGobbling gbl, uint256[] memory tokenIds) public view returns (bool) {
        for (uint idx = 0; idx < tokenIds.length; idx ++) {
            if (!gbl.exist(tokenIds[idx])) {
                return false;
            }
        }
        return true;
    }

    function gblOwnerCheck(IGobbling gbl, address owner, uint256[] memory tokenIds) public view returns (bool) {
        for (uint idx = 0; idx < tokenIds.length; idx ++) {
            if (gbl.ownerOf(tokenIds[idx]) != owner) {
                return false;
            }
        }
        return true;
    }

    function getGblInfos(IGobbling gbl, uint256[] memory tokenIds) public view returns (IGobbling.GobblingInfo[] memory) {
        require(tokenIds.length > 0, "invalid token ids");
        IGobbling.GobblingInfo[] memory tokens = new IGobbling.GobblingInfo[](tokenIds.length);
        for (uint idx = 0; idx < tokenIds.length; idx ++) {
            if (!gbl.exist(tokenIds[idx])) {
                continue;
            }
            tokens[idx] = gbl.tokenInfo(tokenIds[idx]);
        }
        return tokens;
    }

    function gblEnumerate(IGobbling gbl, uint256 _from, uint256 _to) public view returns (IGobbling.GobblingInfo[] memory infos, uint256 total) {
        total = gbl.totalSupply();
        if (total < _to) _to = total;
        if (_from >= _to) {
            return (infos, total);
        }
        infos = new IGobbling.GobblingInfo[](_to - _from);
        for (uint256 i = 0; i < infos.length; i++) {
            infos[i] = gbl.tokenInfo(gbl.tokenByIndex(_from + i));
        }
        return (infos, total);
    }

    function gblEnumerateForOwner(IGobbling gbl, address owner, uint256 _from, uint256 _to) public view returns (IGobbling.GobblingInfo[] memory infos, uint256 balance) {
        balance = gbl.balanceOf(owner);
        if (balance < _to) _to = balance;
        if (_from >= _to) {
            return (infos, balance);
        }
        infos = new IGobbling.GobblingInfo[](_to - _from);
        for (uint256 i = 0; i < infos.length; i++) {
            infos[i] = gbl.tokenInfo(gbl.tokenOfOwnerByIndex(owner, _from + i));
        }
        return (infos, balance);
    }
}

// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import './API.sol';

interface IERC721EnumMeta is IERC721Enumerable, IERC721Metadata {}

contract Erc721API is API {

    function ApiId() public view virtual override returns (bytes32) {
        return keccak256("Erc721API");
    }

    function getTokenIds(IERC721Enumerable erc721, uint256 from, uint256 to) public view returns (uint256[] memory ids, uint256 total) {
        total = erc721.totalSupply();
        if (total < to) to = total;
        if (from >= to) {
            ids = new uint256[](0);
            return (ids, total);
        }
        ids = new uint256[](to - from);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = erc721.tokenByIndex(from + i);
        }
    }

    function getTokenIdsForOwner(IERC721Enumerable erc721, address user, uint256 from, uint256 to) public view returns (uint256[] memory ids, uint256 balance) {
        balance = erc721.balanceOf(user);
        if (balance < to) to = balance;
        if (from >= to) {
            ids = new uint256[](0);
            return (ids, balance);
        }
        ids = new uint256[](to - from);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = erc721.tokenOfOwnerByIndex(user, from + i);
        }
    }

    function getTokenURIs(IERC721EnumMeta erc721, uint256[] calldata tokenIds) public view returns (string[] memory list) {
        list = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            list[i] = erc721.tokenURI(tokenIds[i]);
        }
    }

    struct Token721 {
        uint256 tokenId;
        address tokenOwner;
        string tokenURI;
    }

    function Token721Enumerate(IERC721EnumMeta erc721, uint256 from, uint256 to) public view returns (Token721[] memory tokenList, uint256 total) {
        total = erc721.totalSupply();
        if (total < to) to = total;
        if (from >= to) {
            return (tokenList, total);
        }
        tokenList = new Token721[](to - from);
        for (uint256 i = 0; i < tokenList.length; i++) {
            uint256 tokenId = erc721.tokenByIndex(from + i);
            tokenList[i] = Token721({
            tokenId : tokenId,
            tokenURI : erc721.tokenURI(tokenId),
            tokenOwner : erc721.ownerOf(tokenId)
            });
        }
        return (tokenList, total);
    }

    function Token721EnumerateForOwner(IERC721EnumMeta erc721, address owner, uint256 from, uint256 to) public view returns (Token721[] memory tokenList, uint256 balance) {
        balance = erc721.balanceOf(owner);
        if (balance < to) to = balance;
        if (from >= to) {
            return (tokenList, balance);
        }
        tokenList = new Token721[](to - from);
        for (uint256 i = 0; i < tokenList.length; i++) {
            uint256 tokenId = erc721.tokenOfOwnerByIndex(owner, from + i);
            tokenList[i] = Token721({
            tokenId : tokenId,
            tokenURI : erc721.tokenURI(tokenId),
            tokenOwner : erc721.ownerOf(tokenId)
            });
        }
        return (tokenList, balance);
    }
}

// contracts/IGobbling.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./IERC4907.sol";

interface IGobbling is IERC721Enumerable, IERC4907 {

    struct Gobbling {
        uint32 pid;
        uint32 gem;
        uint16 level;
        uint8 rarity;
        uint8 version;
        uint160 data;
        string uri;
    }

    struct GobblingInfo {
        uint256 tokenId;
        address tokenOwner;
        Gobbling gbl;
        UserInfo user;
    }

    struct UserInfo {
        address user;   // address of user role
        uint64 expires; // unix timestamp
    }

    function mint(address player, Gobbling memory gbl) external returns (uint256);
    function mintBatch(address player, Gobbling[] memory infos) external returns (uint256[] memory);
    function burn(uint256 tokenId) external;
    function burnBatch(uint256[] memory tokenIds) external;
    function updateToken(uint256 tokenId, Gobbling memory gbl) external;
    function approveBatch(address to, uint256[] memory tokenIds) external;
    function exist(uint256 tokenId) external view returns (bool);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function tokenInfo(uint256 tokenId) external view returns (GobblingInfo memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IApi {
    function ApiId() external view returns (bytes32);
}

contract API is IApi {
    function ApiId() public view virtual override returns (bytes32) {
        return keccak256("Api");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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

// contracts/IERC4907.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC4907 {

    // Logged when the user of a NFT is changed or expires is changed
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) external;

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external view returns(address);

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external view returns(uint256);
}
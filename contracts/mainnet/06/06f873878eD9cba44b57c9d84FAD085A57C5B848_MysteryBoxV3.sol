// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Element MysteryBox
// Deposit the ERC721 Prize NFT into Box first, then user can buy, can open
contract MysteryBoxV3 is Ownable {

    // current supply of mystery box
    uint256 public totalSupply;

    // nft token address
    address public ntfAddress;

    // authority address to call this contract, (buy, open must call from external)
    address public authorityCaller;

    // current nft ids
    uint256[] private nftIds;

    constructor(address nft, address target) {
        ntfAddress = nft;
        authorityCaller = target;
    }

    // set prize nft address
    function setNFTAddress(address nft) external onlyOwner {
        ntfAddress = nft;
    }

    // change author address to call this contract
    function setAuthorityCaller(address target) external onlyOwner {
        authorityCaller = target;
    }

    // mint box nft from authority caller
    function safeMint(address to) public returns (bool) {
        require(authorityCaller == _msgSender(), "only authorities");
        require(ntfAddress != address(0), "no prize nft available");
        require(nftIds.length > 0, "no nft in box, can't mint");

        // random a number
        uint256 index = _randomGenerator() % nftIds.length;
        uint256 nftId = nftIds[index];

        // array modify length
        nftIds[index] = nftIds[nftIds.length - 1];
        delete nftIds[nftIds.length - 1];
        nftIds.pop();

        ++totalSupply;

        // transfer the prize nft to box nft owner
        IERC721(ntfAddress).transferFrom(address(this), to, nftId);

        return true;
    }

    function getRemainingSupply() public view returns (uint256) {
        return nftIds.length;
    }

    function checkBoxInfo(uint256 num) public view returns (uint256[] memory indexs, uint256[] memory tokens) {
        require(ntfAddress != address(0), "no prize nft available");
        indexs = new uint256[](num);
        tokens = new uint256[](num);
        uint256 j = 0;
        for (uint256 i = 0; i < nftIds.length && j < num; i++) {
            try IERC721(ntfAddress).ownerOf(nftIds[i]) returns (address addr) {
                if (addr != address(this)) {
                    indexs[j] = i + 1;
                    tokens[j] = nftIds[i];
                    ++j;
                }
            } catch {
                indexs[j] = i + 1;
                tokens[j] = nftIds[i];
                ++j;
            }
        }
    }

    // query private info
    function getBoxPrivateInfo(uint256 fromIdx, uint256 num) onlyOwner external view returns (uint256[] memory) {
        require(num <= 300, "num 300 limit");
        require(nftIds.length > 0, "no nft in box, can't getBoxPrivateInfo");
        require(fromIdx < nftIds.length, "fromIdx out of side");

        if ((fromIdx + num) > nftIds.length) {
            num = nftIds.length - fromIdx;
        }

        uint256[] memory result = new uint256[](num);
        for (uint256 i = 0; i < num; i++) {
            result[i] = nftIds[fromIdx + i];
        }
        return result;
    }

    // Emergency function: In case any ERC721 tokens transfer to this contract directly use "transferFrom" or "mint"
    // batchDepositNFTFromThis(...) like batchDepositNFT(...), but escape safeTransferFrom, directly call _processDepositIntoBox(...)
    function batchDepositNFTFromThis(address tokenAddress, uint256 startTokenId, uint256 num) external onlyOwner {
        require(tokenAddress == ntfAddress, "nft address not match");
        for (uint256 i = 0; i < num; i++) {
            nftIds.push(startTokenId + i);
        }
    }

    // Emergency function: In case any ERC721 tokens transfer to this contract directly use "transferFrom" or "mint"
    // batchDepositNFTFromThisV2(...) like batchDepositNFTV2(...), but escape safeTransferFrom, directly call _processDepositIntoBox(...)
    function batchDepositNFTFromThisV2(address tokenAddress, uint256[] memory tokenId) external onlyOwner {
        require(tokenAddress == ntfAddress, "nft address not match");
        for (uint256 i = 0; i < tokenId.length; i++) {
            nftIds.push(tokenId[i]);
        }
    }

    // receive nft transfer in, same as deposit
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        require(_msgSender() == ntfAddress, "nft address not match");
        nftIds.push(tokenId);
        return this.onERC721Received.selector;
    }

    function deleteNftByIndex(uint256 index) onlyOwner public returns (bool) {
        if (index > 0 && index <= nftIds.length) {
            nftIds[index - 1] = nftIds[nftIds.length - 1];
            delete nftIds[nftIds.length - 1];
            nftIds.pop();
            return true;
        }
        return false;
    }

    function deleteNfts(uint256[] calldata indexs) onlyOwner external {
        for (uint256 i = indexs.length; i > 0; i--) {
            deleteNftByIndex(indexs[i - 1]);
        }
    }

    function rescueERC721(address asset, address recipient, uint256[] calldata ids) onlyOwner external {
        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(asset).transferFrom(address(this), recipient, ids[i]);
        }
    }

    function rescueERC721V2(address asset, address recipient, uint256 startId, uint256 number) onlyOwner external {
        for (uint256 i = 0; i < number; i++) {
            IERC721(asset).transferFrom(address(this), recipient, startId + i);
        }
    }

    function rescueERC721V3(address recipient, uint256 number) onlyOwner external {
        require(ntfAddress != address(0), "no prize nft available");
        require(nftIds.length > 0, "no nft in box, can't rescue");
        uint256 end = 0;
        uint256 tokenId = 0;
        if (number != 0 && number < nftIds.length) {
            end = nftIds.length - number;
        }
        for (uint256 i = nftIds.length; i > end; i--) {
            tokenId = uint256(nftIds[i-1]);
            delete nftIds[i-1];
            nftIds.pop();
            IERC721(ntfAddress).transferFrom(address(this), recipient, tokenId);
        }
    }

    // !!! pseudo-random a number. can be attacked by contract calls
    function _randomGenerator() internal view returns (uint256) {
        uint256 n = block.timestamp + uint256(uint160(_msgSender())) + nftIds.length;
        uint256 loop = n % 2 + 2;
        for (uint256 i = 0; i < loop; i++) {
            if (uint256(keccak256(abi.encodePacked(blockhash(block.number-i-1)))) % 2 == 0) {
                n += 2**i;
            }
        }
        return n;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
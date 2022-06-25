/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

pragma solidity 0.8.14;

// ===========================================================================
// © 2022 QBEIN LLC. All rights reserved. https://qbein.net/
// All codes are exclusive property of QBEIN LLC. 
// This work may not be copied or duplicated in whole or part by any means 
// without express prior agreement in writing given by QBEIN LLC.
// ===========================================================================

// SPDX-License-Identifier: UNLICENSED

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

contract AmazyNFTVault is ERC721Holder {

    address public contract721;
    mapping(uint256 => address) idowner;

    event Lock(address indexed from, address indexed to, uint256 indexed tokenId, uint256 unlockTime);
    event Unlock(address indexed to, uint256 indexed tokenId);

    constructor() {
        contract721 = 0xC60A6A35d1CeA2dd77aE43EE4b8B47C361BC6dbf;
    }

    mapping (address => Vaults) vault;

    struct Vaults {
        uint256 tokenId;
        uint256 unlockTime;
        bool active;
    }

    receive() external payable{
        require(msg.value == 0, "Send only zero coin amount");
        require(withdrawToken());
    } 

    function lockToken(uint256 _tokenId, uint256 _unlockTime, address _unlockAddress) external returns (bool) {
        require(_unlockAddress != address(0), "Unlock address is zero");
        require(_unlockTime > block.timestamp, "Unlock time is in past");
        require(vault[_unlockAddress].active == false, "Dublicate lock for address");
        vault[_unlockAddress].tokenId = _tokenId;
        vault[_unlockAddress].unlockTime = _unlockTime;
        vault[_unlockAddress].active = true;
        idowner[_tokenId] = _unlockAddress;
        IERC721(contract721).safeTransferFrom(msg.sender, address(this), _tokenId);
        emit Lock(msg.sender, _unlockAddress, _tokenId, _unlockTime);
        return true;
    }

    function lockTokenBatch(uint256[] memory _tokenId, uint256[] memory _unlockTime, address[] memory _unlockAddress) external returns (bool) {
        require(_tokenId.length == _unlockTime.length && _tokenId.length == _unlockAddress.length, "Arrays not equal in length");
        require(_tokenId.length <= 100, "Array must be <= 100 length");
        for (uint j; j < _tokenId.length; j++) {
            require(_unlockAddress[j] != address(0), "Unlock address is zero");
            require(_unlockTime[j] > block.timestamp, "Unlock time is in past");
            require(vault[_unlockAddress[j]].active == false, "Dublicate lock for address");
            vault[_unlockAddress[j]].tokenId = _tokenId[j];
            vault[_unlockAddress[j]].unlockTime = _unlockTime[j];
            vault[_unlockAddress[j]].active = true;
            idowner[_tokenId[j]] = _unlockAddress[j];
            IERC721(contract721).safeTransferFrom(msg.sender, address(this), _tokenId[j]);
            emit Lock(msg.sender, _unlockAddress[j], _tokenId[j], _unlockTime[j]);
        }
        return true;
    }

    function withdrawToken() public returns (bool) {
        require(vault[msg.sender].active == true, "No vault for your address");
        require(vault[msg.sender].unlockTime <= block.timestamp, "Unlock later");
        vault[msg.sender].active = false;
        idowner[vault[msg.sender].tokenId] = address(0);
        IERC721(contract721).safeTransferFrom(address(this), msg.sender, vault[msg.sender].tokenId);
        emit Unlock(msg.sender, vault[msg.sender].tokenId);
        return true;
    }

    function lockInfo(address receiver) external view returns (uint256 _tokenId, uint256 _unlockTime, bool _active) {
        require(vault[receiver].active == true, "No vault for address");
        return (vault[receiver].tokenId, vault[receiver].unlockTime, vault[receiver].active);
    }

    function withdrawAvailable(address receiver) external view returns (bool) {
        require(vault[receiver].active == true, "No vault for address");
        if (vault[receiver].unlockTime <= block.timestamp) { return true; } 
        else { return false; } 
    }

    function onwerById(uint256 _tokenId) external view returns (address _owner) {
        return idowner[_tokenId];
    }

}
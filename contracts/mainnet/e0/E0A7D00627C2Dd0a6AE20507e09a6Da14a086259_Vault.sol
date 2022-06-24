/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ISKP is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external returns (bool);
}

interface ISKPNFT is IERC721 {
    function getIDsByOwner(address owner) external view returns (uint256[] memory);
    function onReceivedRetval() external view returns (bytes4);
}

/**
    Vault Contract Handles The Conversion Between ERC721 Tokens and ERC20 Tokens
    As Specified By The `Conversion Rate`
 */
contract Vault is IERC721Receiver {

    // SKP Token
    ISKP public SKP;

    // SKP NFT
    ISKPNFT public SKPNFT;

    // 1 NFT < == > x Tokens
    uint256 public constant conversionRate = 200_000 * 10**18;

    function initializeSKP(address SKP_) external {
        require(SKP_ != address(0), 'Invalid Param');
        require(address(SKP) == address(0), 'Already Initialized');
        SKP = ISKP(SKP_);
    }

    function initializeSKPNFT(address SKPNFT_) external {
        require(SKPNFT_ != address(0), 'Invalid Param');
        require(address(SKPNFT) == address(0), 'Already Initialized');
        SKPNFT = ISKPNFT(SKPNFT_);
    }

    function convertNFTToERC(uint256 tokenID) external {
        _convertNFTToERC(tokenID);
    }

    function convertBatchNFTToERC(uint256[] calldata tokenIDs) external {
        uint len = tokenIDs.length;
        require(len > 0, 'Zero Length');
        for (uint i = 0; i < len;) {
            _convertNFTToERC(tokenIDs[i]);
            unchecked {
                ++i;
            }
        }
    }

    function convertERCToNFT() external {

        // number of SKP tokens to burn
        uint tokensToBurn = conversionRate;
        
        // fetch user balance before burn
        uint balBefore = SKP.balanceOf(msg.sender);
        require(
            balBefore >= tokensToBurn,
            'Insufficient Tokens'
        );

        // fetch total supply before burn
        uint totalBefore = SKP.totalSupply();

        // burn tokens from sender
        require(
            SKP.burnFrom(msg.sender, tokensToBurn),
            'Error Burning Tokens'
        );

        // fetch total supply after burn
        uint totalAfter = SKP.totalSupply();
        require(
            totalBefore > totalAfter,
            'Zero Burned' 
        );

        // check balance after
        uint balAfter = SKP.balanceOf(msg.sender);
        require(
            balBefore > balAfter,
            'Zero Burned'
        );

        // ensure correct amount was burned
        uint nBurned = balBefore - balAfter;
        uint tBurned = totalBefore - totalAfter;
        require(
            nBurned == tokensToBurn &&
            tBurned == tokensToBurn,
            'Error Burning Tokens'
        );

        // transfer NFT to owner
        uint256[] memory IDs = SKPNFT.getIDsByOwner(address(this));
        uint256 IDLength = IDs.length;
        require(
            IDLength > 0,
            'Zero NFTs Stored'
        );

        // transfer pseudo-random NFT in list to owner
        // randomness is not too important here
        uint p = uint256(blockhash(block.number)) % IDLength;
        uint idToSend = IDs[p];

        // save memory by deleting IDs
        delete IDs;

        // send NFT to msg.sender
        SKPNFT.safeTransferFrom(address(this), msg.sender, idToSend);
    }

    function _convertNFTToERC(uint256 tokenID) internal {

        require(
            SKPNFT.ownerOf(tokenID) == msg.sender,
            'Sender Must Be NFT Owner'
        );

        // transfer from sender to this
        SKPNFT.safeTransferFrom(msg.sender, address(this), tokenID);

        // ensure transfer was successful
        require(
            SKPNFT.ownerOf(tokenID) == address(this),
            'Did Not Receive NFT'
        );

        // mint sender SKP Tokens 
        SKP.mint(msg.sender, conversionRate);
    }

    /**
        Total number of NFTs Locked
     */
    function NFTsLocked() public view returns (uint256) {
        return SKPNFT.balanceOf(address(this));
    }


    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        return SKPNFT.onReceivedRetval();
    }


}
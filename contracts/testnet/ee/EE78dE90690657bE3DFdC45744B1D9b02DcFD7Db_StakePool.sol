/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier: Unlicense

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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
    function destroy(uint256 tokenId) external;
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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

// File: contracts/StakePool.sol

pragma solidity ^0.8.0;

contract StakePool is IERC721Receiver {

    IERC721 public nft;

    mapping(uint256 => address)   private originOwners;
    mapping(address => uint256[]) private tokensOfUserStakes;
    mapping(address => uint256)   private numberOfUserMineStakes;
    mapping(address => uint256)   private numberOfUserSpaceStakes;
    mapping(address => uint256)   private numberOfUserListStakes;
    mapping(address => uint256) private numberOfUserStakes;
    mapping(address => uint256[]) private stakeTokensOfUserStakes;
    mapping(address => uint256[]) private spStakeTokensOfUserStakes;
    mapping(address => uint256[]) private listStakeTokensOfUserStakes;


    event Stake(address staker, uint256 tokenId);
    event SpaceStake(address staker, uint256 tokenId);
    event ListStake(address staker, uint256 tokenId);
    event UnStake(address staker, uint256 tokenId);

    constructor(address _nft) {
        nft = IERC721(_nft);
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4){
        operator;
        from;
        tokenId;
        data;
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function mineStake(uint256 tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        originOwners[tokenId] = msg.sender;
        tokensOfUserStakes[msg.sender].push(tokenId);
        stakeTokensOfUserStakes[msg.sender].push(tokenId);
        numberOfUserMineStakes[msg.sender] += 1;
        numberOfUserStakes[msg.sender] += 1;
        emit Stake(msg.sender, tokenId);
    }

    function spaceStake(uint256 tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        originOwners[tokenId] = msg.sender;
        tokensOfUserStakes[msg.sender].push(tokenId);
        spStakeTokensOfUserStakes[msg.sender].push(tokenId);
        numberOfUserStakes[msg.sender] += 1;
        numberOfUserSpaceStakes[msg.sender] += 1;
        emit SpaceStake(msg.sender, tokenId);
    }

    function listStake(uint256 tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        originOwners[tokenId] = msg.sender;
        tokensOfUserStakes[msg.sender].push(tokenId);
        listStakeTokensOfUserStakes[msg.sender].push(tokenId);
        numberOfUserStakes[msg.sender] += 1;
        numberOfUserListStakes[msg.sender] += 1;
        emit ListStake(msg.sender, tokenId);
    }

    function MineunStake(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "unStake: you are not the owner of the token ID");
        
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        
        delete originOwners[tokenId];
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserMineStakes[msg.sender] -= 1;
        uint256[] memory mineTokens = stakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < mineTokens.length; i++) {
            if (mineTokens[i] == tokenId) {
                delete mineTokens[i];
                break;
            }
        }

        uint256[] memory tokens = tokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
        stakeTokensOfUserStakes[msg.sender] = mineTokens;
        emit UnStake(msg.sender, tokenId);
    }

    function SpaceunStake(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "unStake: you are not the owner of the token ID");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        delete originOwners[tokenId];
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserSpaceStakes[msg.sender] -= 1;
        uint256[] memory spaceTokens = spStakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < spaceTokens.length; i++) {
            if (spaceTokens[i] == tokenId) {
                delete spaceTokens[i];
                break;
            }
        }

        uint256[] memory tokens = tokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
        spStakeTokensOfUserStakes[msg.sender]= spaceTokens;
        emit UnStake(msg.sender, tokenId);
    }

    function ListunStake(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "unStake: you are not the owner of the token ID");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        delete originOwners[tokenId];
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserListStakes[msg.sender] -= 1;
        uint256[] memory listTokens = listStakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < listTokens.length; i++) {
            if (listTokens[i] == tokenId) {
                delete listTokens[i];
                break;
            }
        }

        uint256[] memory tokens = tokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
        listStakeTokensOfUserStakes[msg.sender] = listTokens;
        emit UnStake(msg.sender, tokenId);
    }



    function getTokensOfUserStakes(address user) external view returns (uint256[] memory tokenList) {
        
        uint256 _numberOfUserStakes = numberOfUserStakes[user];
        
        if (_numberOfUserStakes > 0) {
            tokenList = new uint256[](_numberOfUserStakes);
            
            uint256[] memory allTokenStaked = tokensOfUserStakes[user]; 
            uint256 index = 0;
            uint256 len = allTokenStaked.length;

            for(uint256 i = 0; i < len; i++) {
                uint256 tokenId = allTokenStaked[i];
                if (tokenId != 0 && originOwners[tokenId] == user) {
                    tokenList[index] = tokenId;
                    index++;
                }
            }
        }
    }

    function getTokensOfUserMineStakes(address user) external view returns (uint256[] memory tokenList) {

        uint256 _numberOfUserStakes = numberOfUserMineStakes[user];

        if (_numberOfUserStakes > 0) {
            tokenList = new uint256[](_numberOfUserStakes);

            uint256[] memory allTokenStaked = stakeTokensOfUserStakes[user];
            uint256 index = 0;
            uint256 len = allTokenStaked.length;

            for(uint256 i = 0; i < len; i++) {
                uint256 tokenId = allTokenStaked[i];
                if (tokenId != 0 && originOwners[tokenId] == user) {
                    tokenList[index] = tokenId;
                    index++;
                }
            }
        }
    }

    function getTokensOfUserSpStakes(address user) external view returns (uint256[] memory tokenList) {

        uint256 _numberOfUserStakes = numberOfUserSpaceStakes[user];

        if (_numberOfUserStakes > 0) {
            tokenList = new uint256[](_numberOfUserStakes);

            uint256[] memory allTokenStaked = spStakeTokensOfUserStakes[user];
            uint256 index = 0;
            uint256 len = allTokenStaked.length;

            for(uint256 i = 0; i < len; i++) {
                uint256 tokenId = allTokenStaked[i];
                if (tokenId != 0 && originOwners[tokenId] == user) {
                    tokenList[index] = tokenId;
                    index++;
                }
            }
        }
    }

    function getTokensOfUserListStakes(address user) external view returns (uint256[] memory tokenList) {

        uint256 _numberOfUserStakes = numberOfUserListStakes[user];

        if (_numberOfUserStakes > 0) {
            tokenList = new uint256[](_numberOfUserStakes);

            uint256[] memory allTokenStaked = listStakeTokensOfUserStakes[user];
            uint256 index = 0;
            uint256 len = allTokenStaked.length;

            for(uint256 i = 0; i < len; i++) {
                uint256 tokenId = allTokenStaked[i];
                if (tokenId != 0 && originOwners[tokenId] == user) {
                    tokenList[index] = tokenId;
                    index++;
                }
            }
        }
    }

    function mineDestroy(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "you are not the owner of the token ID");
        delete originOwners[tokenId];
        nft.destroy(tokenId);
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserMineStakes[msg.sender] -= 1;
        uint256[] memory tokens = stakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
    }

    function spaceDestroy(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "you are not the owner of the token ID");
        delete originOwners[tokenId];
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserSpaceStakes[msg.sender] -= 1;
        uint256[] memory tokens = spStakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
    }

    function listDestroy(uint256 tokenId) external {
        require(originOwners[tokenId] == msg.sender, "you are not the owner of the token ID");
        delete originOwners[tokenId];
        numberOfUserStakes[msg.sender] -= 1;
        numberOfUserListStakes[msg.sender] -= 1;
        uint256[] memory tokens = listStakeTokensOfUserStakes[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete tokens[i];
                break;
            }
        }
        tokensOfUserStakes[msg.sender] = tokens;
    }

    function getNumberOfUserStakes(address user) external view returns (uint256 number) {
        number = numberOfUserStakes[user];
    }

    function getOriginOwnerOfToken(uint256 tokenId) external view returns (address owner) {
        owner = originOwners[tokenId];
    }

}
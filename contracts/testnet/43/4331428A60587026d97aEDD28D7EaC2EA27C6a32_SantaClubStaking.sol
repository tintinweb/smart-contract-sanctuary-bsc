// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Santa Club Staking Smart Contract
 * @dev Earn Santa tokens by staking your Santa Club NFT
 * @author Kris Kringle
 */

contract SantaClubStaking is Ownable, IERC721Receiver, ReentrancyGuard {
    struct NFTStake {
        address owner;
        uint256 stakedAt;
    }

    struct Staker {
        uint256 totalStakedNFTs;
        uint256 totalClaimedRewards;
    }

    string public name = "Santa Club Staking";
    bool public stakingAvailable;

    uint256 private constant WEEK = 7 days;
    uint256 private constant MONTH = 30 days;

    uint256 public DEFAULT_DAILY_REWARD = 100;

    IERC20 public immutable rewardToken;
    IERC721Enumerable public immutable nftCollection;

    uint256 public totalDistributedRewards;
    uint256 public totalStakedNFTs;

    // Mapping from NFT ids to an NFT stake struct
    mapping(uint256 => NFTStake) public nftStake;

    // Mapping from address to staker struct
    mapping(address => Staker) public staker;

    event NFTStaked(address owner, uint256 tokenId, uint256 time);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 time);
    event Claimed(address owner, uint256 amount);

    receive() external payable {}

    constructor() {
        rewardToken = IERC20(0xB9ae57fC790617185D4F1B1593e36F5A9f38657E);
        nftCollection = IERC721Enumerable(
            0x1c5C33bdf1C78B4A42ED69D453d75ad4bAbB53a8
        );
    }

    function getClaimableRewards(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        if (rewardToken.balanceOf(address(this)) == 0) {
            return 0;
        }
        NFTStake memory stake = nftStake[_tokenId];
        uint256 stakedAt = stake.stakedAt;
        uint256 calculatedReward;
        if (stakedAt != 0) {
            uint256 stakingPeriod = block.timestamp - stakedAt;
            uint256 dailyRewardRate = calculateDailyRewardRate(stakingPeriod);
            calculatedReward =
                (100 ether * dailyRewardRate * stakingPeriod) /
                1 days;
        }
        return calculatedReward / 100;
    }

    function isStakingAvailable() public view returns (bool) {
        return rewardToken.balanceOf(address(this)) > 0;
    }

    function getStakerTotalStakedNFTs(address account)
        public
        view
        returns (uint256)
    {
        return staker[account].totalStakedNFTs;
    }

    function getStakerTotalClaimedRewards(address account)
        public
        view
        returns (uint256)
    {
        return staker[account].totalClaimedRewards;
    }

    // This function should never be used in the write functions.
    function nftIDsOfOwner(address account)
        public
        view
        returns (uint256[] memory)
    {
        uint256 supply = nftCollection.totalSupply();
        uint256[] memory temp = new uint256[](supply);

        uint256 index = 0;
        for (uint256 nftId = 1; nftId <= supply; nftId++) {
            if (nftStake[nftId].owner == account) {
                temp[index] = nftId;
                index += 1;
            }
        }

        uint256[] memory nftIDs = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            nftIDs[i] = temp[i];
        }

        return nftIDs;
    }

    function getTotalClaimableRewards(address account)
        public
        view
        returns (uint256)
    {
        uint256 tokenId;
        uint256 claimableRewards;
        uint256[] memory tokenIds = nftIDsOfOwner(account);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            claimableRewards += getClaimableRewards(tokenId);
        }
        return claimableRewards;
    }

    function stakeNFTs(uint256[] calldata tokenIds) external nonReentrant {
        // require(rewardToken.balanceOf(address(this)) > 0, "Stake NFTs: There are no more rewards in the staking vault.");
        uint256 tokenId;
        uint256 stakedCount;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(
                nftStake[tokenId].owner == address(0),
                "Stake NFT: The NFT is already staked."
            );
            require(
                nftCollection.ownerOf(tokenId) == msg.sender,
                "Stake NFT: You do not own this NFT."
            );

            nftCollection.approve(address(this), tokenId);
            nftCollection.transferFrom(msg.sender, address(this), tokenId);

            nftStake[tokenId] = NFTStake({
                owner: msg.sender,
                stakedAt: block.timestamp
            });

            stakedCount += 1;

            emit NFTStaked(msg.sender, tokenId, block.timestamp);
        }

        totalStakedNFTs += stakedCount;
        staker[msg.sender].totalStakedNFTs += stakedCount;
    }

    function claimRewards(uint256[] calldata tokenIds) external nonReentrant {
        _claimRewards(msg.sender, tokenIds, false);
    }

    function unstakeNFTs(uint256[] calldata tokenIds) external nonReentrant {
        _claimRewards(msg.sender, tokenIds, true);
    }

    function getDailyRewardRate(uint256 stakingPeriod)
        external
        view
        returns (uint256)
    {
        return calculateDailyRewardRate(stakingPeriod);
    }

    function _unstake(address account, uint256[] calldata tokenIds) internal {
        uint256 unstakedCount;
        uint256 tokenId;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(
                nftStake[tokenId].owner == account,
                "Unstake: not an owner"
            );

            nftCollection.transferFrom(address(this), account, tokenId);

            delete nftStake[tokenId];
            unstakedCount += 1;

            emit NFTUnstaked(account, tokenId, block.timestamp);
        }
        staker[account].totalStakedNFTs -= unstakedCount;
        totalStakedNFTs -= unstakedCount;
    }

    function calculateDailyRewardRate(uint256 stakingPeriod)
        internal
        view
        returns (uint256 dailyRewardRate)
    {
        if (stakingPeriod < WEEK) {
            dailyRewardRate = DEFAULT_DAILY_REWARD;
        } else if (stakingPeriod < MONTH) {
            dailyRewardRate = DEFAULT_DAILY_REWARD;
        } else if (stakingPeriod < 3 * MONTH) {
            dailyRewardRate = DEFAULT_DAILY_REWARD * 2;
        } else if (stakingPeriod < 6 * MONTH) {
            dailyRewardRate = DEFAULT_DAILY_REWARD * 3;
        } else if (stakingPeriod >= 6 * MONTH) {
            dailyRewardRate = DEFAULT_DAILY_REWARD * 4;
        }
    }

    function _claimRewards(
        address account,
        uint256[] calldata tokenIds,
        bool unstake
    ) internal {
        // require(rewardToken.balanceOf(address(this)) > 0, "Claim Rewards: There are no more rewards in the staking vault.");

        uint256 tokenId;
        uint256 rewardEarned;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            NFTStake memory stake = nftStake[tokenId];
            require(stake.owner == account, "Claim: not an NFT owner");
            rewardEarned += getClaimableRewards(tokenId);
            nftStake[tokenId].stakedAt = block.timestamp;
        }
        if (rewardEarned > 0) {
            uint256 balanceOfStakingVault = rewardToken.balanceOf(
                address(this)
            );
            if (rewardEarned <= balanceOfStakingVault) {
                rewardToken.transfer(msg.sender, rewardEarned);
                staker[account].totalClaimedRewards += rewardEarned;
                totalDistributedRewards += rewardEarned;
            }
            emit Claimed(account, rewardEarned);
        }
        if (unstake) {
            _unstake(account, tokenIds);
        }
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(
            from == address(0x0),
            "Cannot transfer an NFT directly to the staking smart contract."
        );
        return IERC721Receiver.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */

pragma solidity ^0.8.0;

contract GGStaking is Ownable {
    struct TokenInfo {
        bool isLegendary;
        uint8 squadId; //Adventure, Bling, Business, Chill, Love, Misfit, Party, Space
    }
    // uint256 squadCount = 8;
    uint256[] public squadTokenFeatures = [0, 1, 2, 3, 4, 5, 6, 7];
    mapping(uint256 => TokenInfo) public tokenInfos;
    mapping(address => mapping(uint256 => uint256)) public ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    mapping(address => UserInfo) public userInfos;

    //Info each user
    struct UserInfo {
        uint256 totalNFTCountForHolder;
        bool isLegendaryStaker;
        uint256 stakedLegendaryCountForHolder;
        bool isAllSquadStaker;
        bool commonNFTHolder;
        uint256 commonNFTCountForHolder;
        uint256 pendingRewards;
        uint256 rewardDebt;
        uint256 depositNumber;
    }
    uint256 private _totalRewardBalance;
    uint256 public accLegendaryPerShare;
    uint256 public accAllSquadPerShare;
    uint256 public accCommonNFTPerShare;

    uint256 public totalStakedGators;
    uint256 public totalLegendaryStakers;
    uint256 public totalAllSquadHolders;
    uint256 public totalCommonNFTsStaked;
    uint256 public totalDepositCount;

    uint256 public legendaryRewardsPercent;
    uint256 public allSquadRewardsPercent;
    uint256 public commonRewardsPercent;
    IERC721 public immutable nftToken;
    IERC20 public immutable egToken;

    event Staked(address staker, uint256[] tokenId);
    event UnStaked(address staker, uint256[] tokenId);
    event Claim(address staker, uint256 amount);
    event SetRewardsPercent(
        uint256 _legendaryPercent,
        uint256 _allSquadPercent,
        uint256 _commonPercent
    );
    event DepositReward(address indexed user, uint256 amount);

    constructor(IERC721 _nftToken, IERC20 _egToken) {
        nftToken = _nftToken;
        egToken = _egToken;
    }

    function setTokenInfo(
        uint256[] calldata _ids,
        bool[] calldata _isLegendaries,
        uint8[] calldata _squadIds
    ) external onlyOwner {
        require(
            _ids.length > 0,
            "setTokenInfo: Empty array"
        );
        require(
            ( _ids.length == _isLegendaries.length ) &&
             ( _ids.length == _squadIds.length ) ,
            "setTokenInfo: the array length should be match"
        );
        for (uint256 i = 0; i < _ids.length; i++) {
            require (_squadIds[i] < squadTokenFeatures.length, "setTokenInfo: the squadId should be less than squadTokenFeature length");
        }
        for (uint256 i = 0; i < _ids.length; i++) {
            TokenInfo storage tokenInfo = tokenInfos[_ids[i]];
            tokenInfo.isLegendary = _isLegendaries[i];
            tokenInfo.squadId = _squadIds[i];
        }
    }

    function depositReward(uint256 _amount) external onlyOwner {
        require(
            legendaryRewardsPercent +
                allSquadRewardsPercent +
                commonRewardsPercent ==
                100,
            "depositReward: the total rewards percent should be 100"
        );
        require(
            totalStakedGators > 0,
            "depositReward: the totalStakedGators < 0"
        );
        egToken.transferFrom(msg.sender, address(this), _amount);

        _totalRewardBalance = _totalRewardBalance + _amount;
        uint256 legendaryRewards = _amount * legendaryRewardsPercent / 100;
        uint256 allSquadRewards = _amount * allSquadRewardsPercent / 100;
        uint256 commonNFTRewards = _amount * commonRewardsPercent / 100;
        if (totalLegendaryStakers > 0) {
            accLegendaryPerShare = accLegendaryPerShare + (
                legendaryRewards * (1e12) / totalLegendaryStakers
            );
        }
        if (totalAllSquadHolders > 0) {
            accAllSquadPerShare = accAllSquadPerShare + (
                allSquadRewards * 1e12 / totalAllSquadHolders
            );
        }
        if (totalCommonNFTsStaked > 0) {
            accCommonNFTPerShare = accCommonNFTPerShare + (
                commonNFTRewards * (1e12) / totalCommonNFTsStaked
            );
        }
        totalDepositCount++;
        emit DepositReward(msg.sender, _amount);
    }

    function totalRewardBalance() external view returns (uint256) {
        return _totalRewardBalance;
    }

    function setRewardsPercent(
        uint256 _legendaryRewardsPercent,
        uint256 _allSquadRewardsPercent,
        uint256 _commonRewardsPercent
    ) external onlyOwner {
        require(
            _legendaryRewardsPercent +
                _allSquadRewardsPercent +
                _commonRewardsPercent ==
                100,
            "setRewardsPercent: the total rewards percent should be 100"
        );
        legendaryRewardsPercent = _legendaryRewardsPercent;
        allSquadRewardsPercent = _allSquadRewardsPercent;
        commonRewardsPercent = _commonRewardsPercent;
        emit SetRewardsPercent(
            _legendaryRewardsPercent,
            _allSquadRewardsPercent,
            _commonRewardsPercent
        );
    }

    function getPending(address _user) external view returns (uint256) {
        UserInfo storage user = userInfos[_user];
        uint256 pending;
        if (user.depositNumber < totalDepositCount) {
            pending = _getPending(_user);
            return (user.pendingRewards + pending - user.rewardDebt);
        }
        return (user.pendingRewards);
    }

    function unstake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "NFT unstake: Empty Array");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ownedTokens[msg.sender][_ownedTokensIndex[tokenIds[i]]] ==
                    tokenIds[i],
                "NFT unstake: token not staked or incorrect token owner"
            );
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(
                    tokenIds[i] != tokenIds[j],
                    "NFT unstake: duplicate token ids in input params"
                );
            }
        }
        UserInfo storage user = userInfos[msg.sender];
        uint256 pending;
        if (user.depositNumber < totalDepositCount) {
            pending = _getPending(msg.sender);
            user.pendingRewards = user.pendingRewards + pending - user.rewardDebt;
        }
        uint256 lastTokenIndex;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            lastTokenIndex = user.totalNFTCountForHolder - i - 1;
            if (_ownedTokensIndex[tokenIds[i]] != lastTokenIndex) {
                ownedTokens[msg.sender][
                    _ownedTokensIndex[tokenIds[i]]
                ] = ownedTokens[msg.sender][lastTokenIndex];
                _ownedTokensIndex[
                    ownedTokens[msg.sender][lastTokenIndex]
                ] = _ownedTokensIndex[tokenIds[i]];
            }
            delete _ownedTokensIndex[tokenIds[i]];
            delete ownedTokens[msg.sender][lastTokenIndex];
            nftToken.transferFrom(address(this), msg.sender, tokenIds[i]);
        }
        user.totalNFTCountForHolder = user.totalNFTCountForHolder - tokenIds.length;
        totalStakedGators = totalStakedGators - tokenIds.length;
        uint256 requireUnStakeLegendaryCount = 0;
        uint256 requireUnStakeCommonNFTCount = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            TokenInfo storage token = tokenInfos[tokenIds[i]];
            if (token.isLegendary) {
                requireUnStakeLegendaryCount++;
            } 
        }
        requireUnStakeCommonNFTCount = tokenIds.length - requireUnStakeLegendaryCount;
        if (requireUnStakeLegendaryCount > 0) {
            if (
                user.stakedLegendaryCountForHolder ==
                requireUnStakeLegendaryCount
            ) {
                user.isLegendaryStaker = false;
                user.stakedLegendaryCountForHolder = 0;
            } else {
                user.stakedLegendaryCountForHolder = user.stakedLegendaryCountForHolder - requireUnStakeLegendaryCount;
            }
            totalLegendaryStakers = totalLegendaryStakers - requireUnStakeLegendaryCount;
        }
        if (requireUnStakeCommonNFTCount > 0) {
            if (user.commonNFTCountForHolder < requireUnStakeCommonNFTCount) {
                if (user.isAllSquadStaker) {
                    user.isAllSquadStaker = false;
                    totalAllSquadHolders --;
                    user.commonNFTCountForHolder = user.commonNFTCountForHolder + squadTokenFeatures.length - requireUnStakeCommonNFTCount;
                    totalLegendaryStakers = totalLegendaryStakers + squadTokenFeatures.length - requireUnStakeCommonNFTCount;
                }
            }
            else {
                bool freeCommonSubFlag = true;
                if (user.isAllSquadStaker) {
                    bool allSquadStatus = checkAllSquadStaker();
                    if (!allSquadStatus) {
                        freeCommonSubFlag = false;
                    }
                }

                if (freeCommonSubFlag) {
                    user.commonNFTCountForHolder = user.commonNFTCountForHolder - requireUnStakeCommonNFTCount;
                    totalCommonNFTsStaked = totalCommonNFTsStaked - requireUnStakeCommonNFTCount;
                }
                else {
                    user.isAllSquadStaker = false;
                    totalAllSquadHolders --;
                    user.commonNFTCountForHolder = user.commonNFTCountForHolder + squadTokenFeatures.length - requireUnStakeCommonNFTCount;
                    totalCommonNFTsStaked = totalCommonNFTsStaked + squadTokenFeatures.length - requireUnStakeCommonNFTCount;
                }
            }

            if (
                user.commonNFTCountForHolder == 0 && user.commonNFTHolder
            ) {
                user.commonNFTHolder = false;
            }
            else if (
                user.commonNFTCountForHolder > 0 && !user.commonNFTHolder
            ) {
                user.commonNFTHolder = true;
            }
        }
        
        pending = _getPending(msg.sender);
        user.rewardDebt = pending;
        user.depositNumber = totalDepositCount;
        emit UnStaked(msg.sender, tokenIds);
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "NFT Stake: Empty Array");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                nftToken.ownerOf(tokenIds[i]) == msg.sender,
                "NFT Stake: not owner of token"
            );
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(
                    tokenIds[i] != tokenIds[j],
                    "NFT Stake: duplicate token ids in input params"
                );
            }
        }

        UserInfo storage user = userInfos[msg.sender];
        uint256 pending;
        if (user.depositNumber < totalDepositCount) {
            pending = _getPending(msg.sender);
            user.pendingRewards = user.pendingRewards + pending - user.rewardDebt;
        }
        uint256 lastTokenIndex;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            lastTokenIndex = user.totalNFTCountForHolder + i;
            ownedTokens[msg.sender][lastTokenIndex] = tokenIds[i];
            _ownedTokensIndex[tokenIds[i]] = lastTokenIndex;
            nftToken.transferFrom(msg.sender, address(this), tokenIds[i]);
        }
        user.totalNFTCountForHolder = user.totalNFTCountForHolder + tokenIds.length;
        totalStakedGators = totalStakedGators + tokenIds.length;
        uint256 requireStakeLegendaryCount = 0;
        uint256 requireStakeCommonNFTCount = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            TokenInfo storage token = tokenInfos[tokenIds[i]];
            if (token.isLegendary) {
                if (!user.isLegendaryStaker) user.isLegendaryStaker = true;
                requireStakeLegendaryCount++;
            } else {
                if (!user.commonNFTHolder) user.commonNFTHolder = true;
            }
        }
        requireStakeCommonNFTCount = tokenIds.length - requireStakeLegendaryCount;
        if (requireStakeLegendaryCount > 0) {
            if (!user.isLegendaryStaker) {
                user.isLegendaryStaker = true;
            }
            user.stakedLegendaryCountForHolder = user
                .stakedLegendaryCountForHolder + 
                requireStakeLegendaryCount;
            totalLegendaryStakers = totalLegendaryStakers + 
                requireStakeLegendaryCount;
        }
        if (requireStakeCommonNFTCount > 0) {
            bool freeCommonSumFlag = true;
            if (
                !user.isAllSquadStaker && (user.commonNFTCountForHolder + requireStakeCommonNFTCount) >= squadTokenFeatures.length
            ) {
                bool allSquadStatus = checkAllSquadStaker();
                if (allSquadStatus) {
                    freeCommonSumFlag = false;
                }
            }
            if (freeCommonSumFlag) {
                user.commonNFTCountForHolder = user.commonNFTCountForHolder + 
                    requireStakeCommonNFTCount;
                totalCommonNFTsStaked = totalCommonNFTsStaked + 
                    requireStakeCommonNFTCount;
            }
            else {
                user.isAllSquadStaker = true;
                user.commonNFTCountForHolder = user
                    .commonNFTCountForHolder + 
                        requireStakeCommonNFTCount - 
                        squadTokenFeatures.length;
                totalAllSquadHolders++;
                totalCommonNFTsStaked = totalCommonNFTsStaked + 
                    requireStakeCommonNFTCount - 
                    squadTokenFeatures.length;
            }
        }
        pending = _getPending(msg.sender);
        user.rewardDebt = pending;
        user.depositNumber = totalDepositCount;
        emit Staked(msg.sender, tokenIds);
    }

    function claim() external {
        UserInfo storage user = userInfos[msg.sender];
        uint256 pending = _getPending(msg.sender);
        uint256 amount = user.pendingRewards;
        if (user.depositNumber < totalDepositCount) {
            amount = amount + pending - user.rewardDebt;
        }
        if (egToken.balanceOf(address(this)) < amount) {
            user.pendingRewards = amount - egToken.balanceOf(address(this));
            amount = egToken.balanceOf(address(this));
        } else {
            user.pendingRewards = 0;
        }
        user.rewardDebt = pending;
        egToken.transfer(msg.sender, amount);
        emit Claim(msg.sender, amount);
    }

    function _getPending(address _user) private view returns (uint256) {
        UserInfo storage user = userInfos[_user];
        uint256 pending;
        if (user.isLegendaryStaker) {
            pending = user
                .stakedLegendaryCountForHolder * 
                accLegendaryPerShare / 
                (1e12);
        }
        if (user.isAllSquadStaker) {
            pending = pending + (accAllSquadPerShare / (1e12));
        }
        if (user.commonNFTHolder) {
            pending = pending + (
                user.commonNFTCountForHolder * accCommonNFTPerShare / (1e12)
            );
        }
        return pending;
    }

    function checkAllSquadStaker() private view returns (bool) {
        UserInfo storage user = userInfos[msg.sender];
        uint8[] memory userSquadTokenFeatures = new uint8[](
            squadTokenFeatures.length
        );

        for (uint256 i = 0; i < user.totalNFTCountForHolder; i++) {
            TokenInfo storage tokenInfo = tokenInfos[
                ownedTokens[msg.sender][i]
            ];
            if (tokenInfo.isLegendary) continue;
            userSquadTokenFeatures[tokenInfo.squadId] = 1;
        }
        uint8 userSquadTokenFeaturesSum;
        for (uint256 i = 0; i < squadTokenFeatures.length; i ++) {
            userSquadTokenFeaturesSum = userSquadTokenFeaturesSum + userSquadTokenFeatures[i];
        }
        if(userSquadTokenFeaturesSum == userSquadTokenFeatures.length) {
            return true;
        }
        else {
            return false;
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

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

pragma solidity 0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Authorizable is Ownable {
    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(
            authorized[msg.sender] || owner() == msg.sender,
            "Not authorized"
        );
        _;
    }

    function addAuthorized(address _toAdd) public onlyOwner {
        require(_toAdd != address(0), "Authorizable: Rejected null address");
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != address(0), "Authorizable: Rejected null address");
        require(_toRemove != msg.sender, "Authorizable: Rejected self remove");
        authorized[_toRemove] = false;
    }
}

// @4's

pragma solidity 0.8.17;

import {Authorizable} from "contracts/lib/Authorizable.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Quint Genesis NFT Staking
 * @notice Allow quint NFTs holders to earn rewards,
 *         the reward amount and locking period varies depends on the NFT and is set by admin.
 */
contract QuintGenesisNftsStaking is Authorizable, ERC721Holder {
    /**
     * @notice The NFT staking configuration set by {this._owner}
     * @dev all data will be packed in one slot (32bytes)
     *      The struct data will be loaded and stored in same operations
     *      which make the packing worth the type masking and saves gas
     * @param annualReturnInQuint 26bytes holding the NFT specific annual return in Quint token
     * @param minimalStakingPeriodInSeconds 6bytes holding the required minimum staking period in seconds
     */
    struct StakingFactory {
        uint208 annualReturnInQuint;
        uint48 minimalStakingPeriodInSeconds;
    }

    /**
     * @notice The NFT staking state
     * @dev all data will be packed in one slot (32bytes)
     *      The struct data will be loaded and stored in same operations
     *      which make the packing worth the type masking and saves gas
     * @param stakingTimestamp 6bytes holding the last staking timestamp in seconds
     * @param harvestingTimestamp 6bytes holding the last harvesting timestamp in seconds
     * @param staker the staker address
     */
    struct StakingInstance {
        uint48 stakingTimestamp;
        uint48 harvestingTimestamp;
        address staker;
    }

    /// @dev Quint ERC20 token, used to pay rewards
    IERC20 public immutable QUINT;

    /// @dev collection -> tokenId -> StakingFactory
    mapping(address => mapping(uint256 => StakingFactory))
        private _stakingFactory;

    /// @dev collection -> tokenId -> StakingInstance
    mapping(address => mapping(uint256 => StakingInstance))
        private _stakingInstances;

    event Staked(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed staker,
        uint48 stakingTimestamp,
        uint208 annualReturnInQuint,
        uint48 minimalStakingPeriodInSeconds
    );

    event Unstaked(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed account
    );

    event Harvested(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed account,
        uint48 lastHarvestingTimestamp,
        uint48 newHarvestingTimestamp,
        uint208 annualReturnInQuint,
        uint256 rewards
    );

    event StakingConfigured(
        address indexed collection,
        uint256 indexed tokenId,
        uint208 annualReturnInQuint,
        uint48 minimalStakingPeriodInSeconds
    );

    event StakingDisabled(address indexed collection, uint256 indexed tokenId);

    event StakingCleared(address indexed collection, uint256 indexed tokenId);

    constructor(address quintToken) {
        require(quintToken != address(0), "Nullish Address");
        QUINT = IERC20(quintToken);
    }

    /**
     * @notice Allow admin to create NFT specific Staking configuration
     * @dev All sets must have the same length and at least one item
     */
    function allowStaking(
        address collection,
        uint256[] calldata tokenIds,
        uint208[] calldata annualReturnsInQuint,
        uint48[] calldata minimalStakingPeriodsInSeconds
    ) external onlyAuthorized {
        require(collection != address(0), "Nullish Address");
        require(tokenIds.length > 0, "Empty set");

        require(
            tokenIds.length == annualReturnsInQuint.length,
            "APY set mismatch"
        );
        require(
            tokenIds.length == minimalStakingPeriodsInSeconds.length,
            "Periods set mismatch"
        );

        for (uint256 i = tokenIds.length; i > 0; ) {
            unchecked {
                i--;
            }
            uint256 tokenId = tokenIds[i];
            _stakingFactory[collection][tokenId] = StakingFactory({
                annualReturnInQuint: annualReturnsInQuint[i],
                minimalStakingPeriodInSeconds: minimalStakingPeriodsInSeconds[i]
            });

            emit StakingConfigured(
                collection,
                tokenId,
                annualReturnsInQuint[i],
                minimalStakingPeriodsInSeconds[i]
            );
        }
    }

    /**
     * @notice Allow admin to disable NFT specific staking
     * @dev - MUST revert if an the NFT is already staked
     *      - MUST reset Config and State
     */
    function disableStaking(address collection, uint256[] calldata tokenIds)
        external
        onlyAuthorized
    {
        require(collection != address(0), "Nullish Address");
        require(tokenIds.length > 0, "Empty set");

        for (uint256 i = tokenIds.length; i > 0; ) {
            unchecked {
                i--;
            }
            uint256 tokenId = tokenIds[i];
            require(
                _stakingInstances[collection][tokenId].stakingTimestamp == 0,
                "Unstake required"
            );

            delete _stakingInstances[collection][tokenId];
            delete _stakingFactory[collection][tokenId];

            emit StakingDisabled(collection, tokenId);
        }
    }

    /**
     * @notice Stake NFT and get rewarded in QUINT token, staker must review The NFT staking constraints
     * @dev - MUST allow staking only if the NFT {collection+tokenId} is configured by admin
     *      - MUST safely transfer the NFT to {address(this)}
     *      - MUST set staking time to now
     *      - MUST set lest harvesting time to now
     *      - MUST REVERT if nft staking state is not clear (can happen if admin force clean used)
     *      - MUST emit event
     * @param collection NFT collection address
     * @param tokenId    NFT token ID
     */
    function stake(address collection, uint256 tokenId) external {
        // zero address check
        require(collection != address(0), "Nullish Address");

        // load staking config slot into memory and validate stakingFactory
        StakingFactory memory stakingFactory = _stakingFactory[collection][
            tokenId
        ];
        require(stakingFactory.annualReturnInQuint > 0, "Not set");

        // store block.timestamp value in memory as 6bytes
        uint48 _now = uint48(block.timestamp);

        // set NFT (collection+tokenId) staking state
        _stakingInstances[collection][tokenId] = StakingInstance({
            stakingTimestamp: _now,
            harvestingTimestamp: _now,
            staker: msg.sender
        });

        // escrow the NFT, will fail if sender is not the owner
        IERC721(collection).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            ""
        );

        // broadcast the event
        emit Staked(
            collection,
            tokenId,
            msg.sender,
            _now,
            stakingFactory.annualReturnInQuint,
            stakingFactory.minimalStakingPeriodInSeconds
        );
    }

    /**
     * @notice Allow user to unstake NFT, this will automatically trigger harvest
     * @dev - MUST respect locking period
     *      - MUST harvest if enough rewards
     *      - MUST safely transfer back NFT to staker
     *      - MUST revert if caller is not the staker
     *      - MUST clear the NFT staking state
     *      - MUST emit event
     * @param collection NFT collection address
     * @param tokenId    NFT token ID
     */
    function unstake(address collection, uint256 tokenId) external {
        // zero address check
        require(collection != address(0), "Nullish Address");

        // load NFT staking config in memory
        StakingFactory memory stakingFactory = _stakingFactory[collection][
            tokenId
        ];

        // load NFT staking state in memory
        StakingInstance memory stakingInstance = _stakingInstances[collection][
            tokenId
        ];

        // ensure that the caller is the staker
        require(msg.sender == stakingInstance.staker, "Not the staker");

        // ensure the locking period is respected
        uint256 unlockTimestamp = stakingInstance.stakingTimestamp +
            stakingFactory.minimalStakingPeriodInSeconds;
        require(block.timestamp > unlockTimestamp, "locked");

        // clear NFT staking state
        delete _stakingInstances[collection][tokenId];

        // calculate rewards and transfer if not null
        uint256 rewards = _calculateRewards(stakingInstance, stakingFactory);
        if (rewards > 0) {
            QUINT.transfer(stakingInstance.staker, rewards);
        }

        // return back the escrowed NFT to original staker
        IERC721(collection).safeTransferFrom(
            address(this),
            stakingInstance.staker,
            tokenId,
            ""
        );

        // broadcast the unstake
        emit Unstaked(collection, tokenId, msg.sender);
    }

    /**
     * @notice harvest NFT rewards, will fail if not staked or no rewards
     * @dev - MUST revert if nullish rewards
     *      - MUST revert if caller is not the staker
     *      - MUST transfer quint as rewards
     *      - MUST emit event
     * @param collection NFT collection address
     * @param tokenId    NFT token ID
     */
    function harvest(address collection, uint256 tokenId) external {
        // zero address check
        require(collection != address(0), "Nullish Address");

        // load NFT staking config in memory
        StakingFactory memory stakingFactory = _stakingFactory[collection][
            tokenId
        ];

        // load NFT staking state in memory
        StakingInstance memory stakingInstance = _stakingInstances[collection][
            tokenId
        ];

        // ensure that the caller is the staker
        require(msg.sender == stakingInstance.staker, "Not the staker");

        // calculate rewards
        uint256 rewards = _calculateRewards(stakingInstance, stakingFactory);
        // revert if no rewards
        require(rewards > 0, "Nothing to harvest");

        // store block.timestamp value in memory as 6bytes
        uint48 _now = uint48(block.timestamp);
        // set the harvest time current block timestamp
        _stakingInstances[collection][tokenId].harvestingTimestamp = _now;

        // transfer rewards
        QUINT.transfer(stakingInstance.staker, rewards);

        // broadcast event
        emit Harvested(
            collection,
            tokenId,
            msg.sender,
            stakingInstance.harvestingTimestamp,
            _now,
            stakingFactory.annualReturnInQuint,
            rewards
        );
    }

    /**
     * @notice calculate the claimable rewards amount
     * @dev - MUST NOT revert
     *      - MUST return exact claimable rewards at current block timestamp
     *      - MUST return same rewards as harvest
     * @param collection NFT collection address
     * @param tokenId    NFT token ID
     */
    function previewHarvest(address collection, uint256 tokenId)
        external
        view
        returns (uint256)
    {
        StakingInstance memory stakingInstance = _stakingInstances[collection][
            tokenId
        ];

        StakingFactory memory stakingFactory = _stakingFactory[collection][
            tokenId
        ];

        return _calculateRewards(stakingInstance, stakingFactory);
    }

    function getNftDetails(address collection, uint256 tokenId)
        external
        view
        returns (
            uint256 stakingTimestamp,
            address staker,
            uint256 harvestingTimestamp,
            uint256 annualReturnInQuint,
            uint256 minimalStakingPeriodInSeconds,
            uint256 rewards
        )
    {
        StakingInstance memory stakingInstance = _stakingInstances[collection][
            tokenId
        ];

        StakingFactory memory stakingFactory = _stakingFactory[collection][
            tokenId
        ];

        harvestingTimestamp = stakingInstance.harvestingTimestamp;
        staker = stakingInstance.staker;
        stakingTimestamp = stakingInstance.stakingTimestamp;

        annualReturnInQuint = stakingFactory.annualReturnInQuint;
        minimalStakingPeriodInSeconds = stakingFactory
            .minimalStakingPeriodInSeconds;

        rewards = _calculateRewards(stakingInstance, stakingFactory);
    }

    function _calculateRewards(
        StakingInstance memory stakingInstance,
        StakingFactory memory stakingFactory
    ) private view returns (uint256 rewards) {
        if (stakingInstance.harvestingTimestamp == 0) {
            return 0;
        }

        uint256 stakingPeriodInSeconds = block.timestamp -
            stakingInstance.harvestingTimestamp;

        // stakingFactory.annualReturnInQuint ==> 1 YEAR
        // rewards?                           ==> stakingPeriodInSeconds
        rewards =
            (stakingPeriodInSeconds * stakingFactory.annualReturnInQuint) /
            360 days;
    }

    /**
     * @notice Allow owner to transfer any ERC721 NFT owned by this contract
     * @dev - MUST revert iof caller is not the owner
     */
    function safeTransferERC721(
        address collection,
        uint256 tokenId,
        address to,
        bytes calldata data
    ) external onlyOwner {
        IERC721(collection).safeTransferFrom(address(this), to, tokenId, data);
    }

    /**
     * @notice Allow owner to transfer any ERC721 NFT owned by this contract
     * @dev - MUST revert iof caller is not the owner
     */
    function safeTransferERC721(
        address collection,
        uint256 tokenId,
        address to
    ) external onlyOwner {
        IERC721(collection).safeTransferFrom(address(this), to, tokenId, "");
    }

    /**
     * @notice Allow owner to transfer any ERC20 token owned by this contract
     * @dev - MUST revert iof caller is not the owner
     */
    function transferERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    /**
     * @notice Allow owner to clean staking config and state in case of emergency
     * @dev - MUST NOT revert
     */
    function emergencyForceClean(address collection, uint256 tokenId)
        external
        onlyOwner
    {
        delete _stakingFactory[collection][tokenId];
        delete _stakingInstances[collection][tokenId];

        emit StakingCleared(collection, tokenId);
    }
}

/** how to calculate the max uint value per bytes/bits
>> import { BigNumber } from "ethers";
>> const main = () => {
>>   const BYTES = 6;
>> 
>>   let result = BigNumber.from(0);
>>   const BASE = BigNumber.from(2);
>> 
>>   const BITS = BYTES * 8;
>>   for (let i = 0; i < BITS; i++) {
>>     result = result.add(BASE.pow(i));
>>   }
>>   console.log(result.toString());
>> };
>> main();
 */
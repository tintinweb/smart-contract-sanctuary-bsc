/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

interface IThenaVoteManager {
    function treasury() external view returns (address);
    function totalFee() external view returns (uint256);

    function gauges(uint256) external view returns (address);
    function weights(uint256) external view returns (uint256);
    function nftCap() external view returns (uint256);
    function getSwapPath(address, address) external view returns (address[] memory);
    function getRewards() external view returns (address[] memory);

    function gaugesLength() external view returns (uint256);
    function weightsLength() external view returns (uint256);

    function strategiesLength() external view returns (uint256);
    function getStrategy(uint256 id) external view returns (address);
}


// File contracts/interfaces/IThenaVoteFarmer.sol



pragma solidity ^0.8.0;

/// @dev Vote for velodrome pairs, get rewards and grow veVelo
interface IThenaVoteFarmer {
    /* ========== STATE VARIABLES ========== */
    /// @dev Role
    // bytes32 public constant STRATEGIST = keccak256("STRATEGIST");

    /// Fees
    /// Fee related constants:
    /// {USDC} - Fees are taken in USDC.
    /// {treasury} - Address to send fees to.
    /// {strategistRemitter} - Address where strategist fee is remitted to.
    /// {MAX_FEE} - Maximum fee allowed by the strategy. Hard-capped at 10%.
    /// {STRATEGIST_MAX_FEE} - Maximum strategist fee allowed by the strategy (as % of treasury fee).
    ///                        Hard-capped at 50%
    // address public constant USDC = address(0x7F5c764cBc14f9669B88837ca1490cCa17c31607);
    // address public constant OP = address(0x4200000000000000000000000000000000000042);
    // address public treasury;
    // address public strategistRemitter;
    // uint256 public constant PERCENT_DIVISOR = 10_000;
    // uint256 public constant MAX_FEE = 1000;
    // uint256 public constant STRATEGIST_MAX_FEE = 5000;

    ///@dev Distribution of fees earned, expressed as % of the profit from each harvest.
    ///{totalFee} - divided by 10,000 to determine the % fee. Set to 4.5% by default and
    ///lowered as necessary to provide users with the most competitive APY.
    ///{callFee} - Percent of the totalFee reserved for the harvester (1000 = 10% of total fee: 0.45% by default)
    ///{treasuryFee} - Percent of the totalFee taken by maintainers of the software (9000 = 90% of total fee: 4.05% by default)
    ///{strategistFee} - Percent of the treasuryFee taken by strategist (2500 = 25% of treasury fee: 1.0125% by default)
    // uint256 public totalFee;
    // uint256 public callFee;
    // uint256 public treasuryFee;
    // uint256 public strategistFee;

    // uint256 public constant EPOCH = 1 weeks; // Duration of an epoch
    // uint256 public constant MAX_WEIGHT = 10_000; // 100% voting power
    // address public constant VELO = address(0x3c8B650257cFb5f272f799F5e2b4e65093a11a05);
    // address public constant VEVELO = address(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);
    // address public constant VELODROME_VOTER = address(0x09236cfF45047DBee6B921e00704bed6D6B8Cf7e);
    // address public constant VELODROME_ROUTER = address(0xa132DAB612dB5cB9fC9Ac426A0Cc215A3423F9c9);
    function tokenIds(uint256) external view returns (uint256);

    /// @dev Vote-related vars
    function gauges(uint256) external view returns (address);

    function pairs(uint256) external view returns (address);

    function weigths(uint256) external view returns (uint256);

    function tokenToRewardInfo(address) external view returns (RewardInfo memory);

    struct VeNFTInfo {
        uint256 internalId;
        bool autoLock;
        mapping(address => uint256) tokenToRewardAmount; // Amount of reward received thanks to this veNft
    }

    /// Information about rewards
    struct RewardInfo {
        uint256 totalReceived; // Amount of tokens received as reward
        uint256 totalReceivedVelo; // How much the above was worth in velo
    }

    // function tokenIdToInfo(uint256) external view returns (VeNFTInfo memory);
    function veNfts(uint256) external view returns (uint256);

    function tokenIdsLength() external view returns (uint256);

    function nftCap() external view returns (uint256);

    /// @dev tokenA => (tokenB => swapPath config): returns best path to swap
    ///         tokenA to tokenB
    function swapPath(address, address) external view returns (address[] memory);

    /// @notice Time required after initiating an upgrade to do so
    // uint256 public upgradeProposalTime;
    // uint256 public constant ONE_YEAR = 365 days;
    // uint256 public constant UPGRADE_TIMELOCK = 48 hours; // minimum 48 hours for RF

    function initialize() external;

    /// @notice Mimics the behaviour of harvests
    function harvest() external;

    /* ========== USER ACTIONS ========== */

    /// @notice Allows a user to add his venft to this contract's managed nfts
    /// @dev The contract must be approved for the transfer first
    function deposit(uint256 _tokenId, address _owner) external;

    /// @notice Allows a user to withdraw his venfts from the managed venfts
    function withdraw(uint256 _tokenId, address _owner) external;

    /// @notice Makes a venft eligible to have its lock duration extended by a week
    function autoLock(
        uint256 _tokenId,
        bool _enable,
        address _owner
    ) external;

    /// @notice Extend duration of venfts
    /// @dev Be careful not to spam this
    function increaseDurationAll() external;

    /* ========== VOTE ========== */

    /// @notice Attempt to vote using all veNfts held by the contract
    function vote() external;

    /* ========== REWARDS ========== */

    /// @notice Attempt to claim for veNfts held
    function claimFees() external;

    /// @notice For each token, try to swap to VELO
    /// @dev To prepare for the incoming compounding, should store the amount of velo gotten
    function swapRewards() external;

    /// @notice Distribute available VELO to grow the veNfts
    /// @dev Velo for 1 veNft = (nftReward1Share * 1e18 / reward1ReceivedTotal) + ()
    function compoundVelo() external;

    function chargeFees() external returns (uint256 callerFee);

    /* ========== ADMIN ========== */

    /// @notice Set balances tracked to 0
    function resetBalancesAll() external;

    /// @notice Set balances tracked to 0 for array of tokens
    function resetBalances(uint256[] memory _tokenIds) external;

    /// @notice Set gauges and weights to use when voting and claiming
    function setGaugesAndWeights(address[] calldata _gauges, uint256[] calldata _weights) external;

    /// @notice Set routes to be used for swaps
    function updateSwapPath(address[] memory _path) external;

    /// @dev Updates the total fee, capped at 5%; only DEFAULT_ADMIN_ROLE.
    function updateTotalFee(uint256 _totalFee) external;

    function updateFees(uint256 _callFee, uint256 _treasuryFee) external;

    /// @dev Updates the current strategistRemitter. Only DEFAULT_ADMIN_ROLE may do this.
    function updateStrategistRemitter(address _newStrategistRemitter) external;

    function addReward(address _reward) external;

    function removeReward(address _reward) external;

    function setNftCap(uint256 _cap) external;

    function synchronize() external;
    function pause() external;
    function unpause() external;
    function harvestLogLength() external view returns(uint256);
    function calculateAPRForLog(uint256) external view returns (uint256);
    function averageAPRAcrossLastNHarvests(uint256) external view returns (uint256);

    function upgradeTo(address) external;
}


// File contracts/interfaces/IThenaVotingEscrow.sol


pragma solidity ^0.8.0;

/**
 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.
 *
 * _Available since v4.5._
 */
interface IVotes {
    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
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

/// @title Voting Escrow
/// @notice veNFT implementation that escrows ERC-20 tokens in the form of an ERC-721 NFT
/// @notice Votes have a weight depending on time, so that users are committed to the future of (whatever they are voting for)
/// @author Modified from Solidly (https://github.com/solidlyexchange/solidly/blob/master/contracts/ve.sol)
/// @author Modified from Curve (https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/VotingEscrow.vy)
/// @author Modified from Nouns DAO (https://github.com/withtally/my-nft-dao-project/blob/main/contracts/ERC721Checkpointable.sol)
/// @dev Vote weight decays linearly over time. Lock time cannot be more than `MAXTIME` (4 years).
interface IThenaVotingEscrow is IERC721, IERC721Metadata, IVotes {
    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME,
        MERGE_TYPE
    }
    struct LockedBalance {
        int128 amount;
        uint256 end;
    }
    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint256 ts;
        uint256 blk; // block
    }
    /* We cannot really do block numbers per se b/c slope is per time, not per block
     * and per block could be fairly bad b/c Ethereum changes blocktimes.
     * What we can do is to extrapolate ***At functions */
    /// @notice A checkpoint for marking delegated tokenIds from a given timestamp
    struct Checkpoint {
        uint256 timestamp;
        uint256[] tokenIds;
    }

    function token() external view returns (address);

    function voter() external view returns (address);

    function team() external view returns (address);

    function artProxy() external view returns (address);

    function point_history(uint256) external view returns (Point memory); // epoch -> unsigned point

    /// @dev Mapping of interface id to bool about whether or not it's supported
    function supportedInterfaces(bytes4) external view returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function version() external view returns (string memory);

    function decimals() external view returns (uint8);

    function setTeam(address) external;

    function setArtProxy(address) external;

    /// @dev Returns current token URI metadata
    /// @param _tokenId Token ID to fetch URI for.
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function ownership_storage(uint256) external view returns (uint256);

    /// @dev Get the approved address for a single NFT.
    /// @param _tokenId ID of the NFT to query the approval of.
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @dev Checks if `_operator` is an approved operator for `_owner`.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /// @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
    ///      Throws if `_tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
    ///      Throws if `_approved` is the current owner. (NOTE: This is not written the EIP)
    /// @param _approved Address to be approved for the given NFT ID.
    /// @param _tokenId ID of the token to be approved.
    function approve(address _approved, uint256 _tokenId) external;

    /// @dev Enables or disables approval for a third party ("operator") to manage all of
    ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
    ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
    /// @notice This works even if sender doesn't own any tokens at the time.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval.
    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool);

    /// @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    /// @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
    ///        they maybe be permanently lost.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /// @dev Transfers the ownership of an NFT from one address to another address.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
    ///      approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
    ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /// @dev Transfers the ownership of an NFT from one address to another address.
    ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
    ///      approved address for this NFT.
    ///      Throws if `_from` is not the current owner.
    ///      Throws if `_to` is the zero address.
    ///      Throws if `_tokenId` is not a valid NFT.
    ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
    ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    /// @param _data Additional data with no specified format, sent in call to `_to`.
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /// @dev Interface identification is specified in ERC-165.
    /// @param _interfaceID Id of the interface
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

    /// @dev  Get token by index
    function tokenOfOwnerByIndex(address _owner, uint256 _tokenIndex) external view returns (uint256);

    function user_point_epoch(uint256) external view returns (uint256);

    function user_point_history(uint256) external view returns (Point[] memory); // user -> Point[user_epoch]

    function locked(uint256) external view returns (LockedBalance memory);

    function epoch() external view returns (uint256);

    function slope_changes(uint256) external view returns (int128);

    function supply() external view returns (uint256);

    /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @return Value of the slope
    function get_last_user_slope(uint256 _tokenId) external view returns (int128);

    /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
    /// @param _tokenId token of the NFT
    /// @param _idx User epoch number
    /// @return Epoch time of the checkpoint
    function user_point_history__ts(uint256 _tokenId, uint256 _idx) external view returns (uint256);

    /// @notice Get timestamp when `_tokenId`'s lock finishes
    /// @param _tokenId User NFT
    /// @return Epoch time of the lock end
    function locked__end(uint256 _tokenId) external view returns (uint256);

    function block_number() external view returns (uint256);

    /// @notice Record global data to checkpoint
    function checkpoint() external;

    /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    ///      cannot extend their locktime and deposit for a brand new user
    /// @param _tokenId lock NFT
    /// @param _value Amount to add to user's lock
    function deposit_for(uint256 _tokenId, uint256 _value) external;

    /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    function create_lock(uint256 _value, uint256 _lock_duration) external returns (uint256);

    /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
    /// @param _value Amount to deposit
    /// @param _lock_duration Number of seconds to lock tokens for (rounded down to nearest week)
    /// @param _to Address to deposit
    function create_lock_for(
        uint256 _value,
        uint256 _lock_duration,
        address _to
    ) external returns (uint256);

    /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function increase_amount(uint256 _tokenId, uint256 _value) external;

    /// @notice Extend the unlock time for `_tokenId`
    /// @param _lock_duration New number of seconds until tokens unlock
    function increase_unlock_time(uint256 _tokenId, uint256 _lock_duration) external;

    /// @notice Withdraw all tokens for `_tokenId`
    /// @dev Only possible if the lock has expired
    function withdraw(uint256 _tokenId) external;

    function balanceOfNFT(uint256 _tokenId) external view returns (uint256);

    function balanceOfNFTAt(uint256 _tokenId, uint256 _t) external view returns (uint256);

    function balanceOfAtNFT(uint256 _tokenId, uint256 _block) external view returns (uint256);

    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    function totalSupplyAt(uint256 _block) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    function totalSupplyAtT(uint256 t) external view returns (uint256);

    function attachments(uint256) external view returns (uint256);

    function voted(uint256) external view returns (bool);

    function setVoter(address _voter) external;

    function voting(uint256 _tokenId) external;

    function abstain(uint256 _tokenId) external;

    function attach(uint256 _tokenId) external;

    function detach(uint256 _tokenId) external;

    function merge(uint256 _from, uint256 _to) external;

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function DELEGATION_TYPEHASH() external view returns (bytes32);

    function MAX_DELEGATES() external view returns (uint256); // avoid too much gas

    function checkpoints(address, uint32) external view returns (Checkpoint memory);

    function numCheckpoints(address) external view returns (uint32);

    function nonces(address) external view returns (uint256);

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function delegates(address delegator) external view returns (address);

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getVotes(address account) external view returns (uint256);

    function getPastVotesIndex(address account, uint256 timestamp) external view returns (uint32);

    function getPastVotes(address account, uint256 timestamp) external view returns (uint256);

    function getPastTotalSupply(uint256 timestamp) external view returns (uint256);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


// File contracts/ThenaVoteHelper.sol



pragma solidity ^0.8.0;



contract ThenaVoteHelper {

    IThenaVoteManager public manager;
    IThenaVotingEscrow public constant VETHE = IThenaVotingEscrow(0x9c7305eb78a432ced5C4D14Cac27E8Ed569A2e26);

    constructor(address _manager) {
        manager = IThenaVoteManager(_manager);
    }

    function getAPRForLog(uint256 log) external view returns (uint256 apr) {
        address[] memory strategies = _getStrategies();
        uint256 strategiesProcessed;
        for(uint256 i; i < strategies.length; i++) {
            if (IThenaVoteFarmer(strategies[i]).harvestLogLength() >= log) {
                apr += IThenaVoteFarmer(strategies[i]).calculateAPRForLog(log);
                strategiesProcessed++;
            }
        }
        apr = apr / strategiesProcessed;
    }

    function getMaxLogLength() public view returns (uint256 maxLength) {
        address[] memory strategies = _getStrategies();
        for(uint256 i; i < strategies.length; i++) {
            if(IThenaVoteFarmer(strategies[i]).harvestLogLength() > maxLength) {
                maxLength = IThenaVoteFarmer(strategies[i]).harvestLogLength();
            }
        }
    }

    function getTotalThenaLocked() external view returns (uint256 total) {
        address[] memory strategies = _getStrategies();
        for (uint256 i; i < strategies.length; i++) {
            total += _getTotalThenaLockedOfStrat(strategies[i]);
        }
    }

    function getTotalVotingPower() external view returns (uint256 total) {
        address[] memory strategies = _getStrategies();
        for (uint256 i; i < strategies.length; i++) {
            total += _getTotalVotingPowerOfStrat(strategies[i]);
        }
    }

    function getTotalThenaLockedForUser(address user) external view returns (uint256 total) {
        uint256[] memory userTokens = getManagedTokensOfUser(user);
        for (uint256 i; i < userTokens.length; i++) {
            total += uint128(VETHE.locked(userTokens[i]).amount);
        }
    }

    function getTotalVotingPowerForUser(address user) external view returns (uint256 total) {
        uint256[] memory userTokens = getManagedTokensOfUser(user);
        for (uint256 i; i < userTokens.length; i++) {
            total += VETHE.balanceOfNFT(userTokens[i]);
        }
    }

    function getManagedTokensOfUser(address user) public view returns (uint256[] memory) {
        uint256 max = VETHE.balanceOf(user);
        uint256[] memory tokens = new uint256[](max);

        for(uint256 i; i < max; i++) {
            uint256 tokenId = VETHE.tokenOfOwnerByIndex(user, i);
            if (_isManaged(tokenId)) {
                tokens[i] = tokenId;
            }
        }

        return tokens;
    }

    function _getStrategies() internal view returns (address[] memory) {
        uint256 stratLen = manager.strategiesLength();
        address[] memory strategies = new address[](stratLen);
        for (uint256 i; i < stratLen; i++) {
            strategies[i] = manager.getStrategy(i);
        }
        return strategies;
    }

    function _getTotalThenaLockedOfStrat(address strategy) internal view returns (uint256 total) {
        IThenaVoteFarmer strat = IThenaVoteFarmer(strategy);
        uint256 tokenIdsLen = strat.tokenIdsLength();
        for(uint256 i; i < tokenIdsLen; i++) {
            uint256 tokenId = strat.tokenIds(i);
            total += uint128(VETHE.locked(tokenId).amount);
        }
    }

    function _getTotalVotingPowerOfStrat(address strategy) internal view returns (uint256 total) {
        IThenaVoteFarmer strat = IThenaVoteFarmer(strategy);
        uint256 tokenIdsLen = strat.tokenIdsLength();
        for(uint256 i; i < tokenIdsLen; i++) {
            uint256 tokenId = strat.tokenIds(i);
            total += VETHE.balanceOfNFT(tokenId);
        }
    }

    function _isManaged(uint256 tokenId) internal view returns (bool) {
        address[] memory strategies = _getStrategies();
        for (uint256 i; i < strategies.length; i++) {
            uint256 tokenIdsLen = IThenaVoteFarmer(strategies[i]).tokenIdsLength();
            for (uint256 j; j < tokenIdsLen; j++) {
                if (IThenaVoteFarmer(strategies[i]).tokenIds(j) == tokenId) {
                    return true;
                }
            }
        }
        return false;
    }

}
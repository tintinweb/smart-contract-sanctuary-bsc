// ---------------------------------------------------------------------
// ⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨
//
// ██████╗░██╗░░░██╗████████╗██╗░░░██╗  ███████╗██╗░░██╗░█████╗░██╗░░██╗░█████╗░███╗░░██╗░██████╗░███████╗
// ██╔══██╗██║░░░██║╚══██╔══╝╚██╗░██╔╝  ██╔════╝╚██╗██╔╝██╔══██╗██║░░██║██╔══██╗████╗░██║██╔════╝░██╔════╝
// ██║░░██║██║░░░██║░░░██║░░░░╚████╔╝░  █████╗░░░╚███╔╝░██║░░╚═╝███████║███████║██╔██╗██║██║░░██╗░█████╗░░
// ██║░░██║██║░░░██║░░░██║░░░░░╚██╔╝░░  ██╔══╝░░░██╔██╗░██║░░██╗██╔══██║██╔══██║██║╚████║██║░░╚██╗██╔══╝░░
// ██████╔╝╚██████╔╝░░░██║░░░░░░██║░░░  ███████╗██╔╝╚██╗╚█████╔╝██║░░██║██║░░██║██║░╚███║╚██████╔╝███████╗
// ╚═════╝░░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░  ╚══════╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░╚═════╝░╚══════╝
//
// ⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨⭐️ 🌟 ✨
// ---------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// Website : Duty Exchange 🚀
// URL     : https://duty.exchange  🔥🔥🔥
// Email   : [email protected]                        
// ---------------------------------------------------------------------

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title DutySwap Farms Auctions.
 * @notice Auctions for new Farms, including multiplier.
 */
contract FarmAuction is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public immutable dutyToken;

    address public operatorAddress;

    uint256 public currentAuctionId;
    uint256 public maxAuctionLength;
    uint256 public totalCollected;

    enum Status {
        Pending,
        Open,
        Close
    }

    struct Auction {
        Status status;
        uint256 startBlock;
        uint256 endBlock;
        uint256 initialBidAmount;
        uint256 leaderboard;
        uint256 leaderboardThreshold;
    }

    struct BidInfo {
        uint256 totalAmount;
        bool hasClaimed;
    }

    // Only used for view
    struct Bid {
        address account;
        uint256 amount;
        bool hasClaimed;
    }

    EnumerableSet.AddressSet bidders;

    // Mapping to track auctions
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => BidInfo)) public auctionBids;
    mapping(uint256 => EnumerableSet.AddressSet) private _auctionBidders;

    // Mapping to track bidder's bids per auction
    mapping(address => uint256[]) private _bidderAuctions;

    // Modifier to prevent external address to modify state
    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Management: Not the operator");
        _;
    }

    event AuctionBid(uint256 indexed auctionId, address indexed account, uint256 amount);
    event AuctionClaim(uint256 indexed auctionId, address indexed account, uint256 amount, bool isAdmin);
    event AuctionClose(uint256 indexed auctionId, uint256 participationLimit, uint256 numberParticipants);
    event AuctionStart(
        uint256 indexed auctionId,
        uint256 startBlock,
        uint256 endBlock,
        uint256 initialBidAmount,
        uint256 leaderboard
    );
    event NewMaxAuctionLength(uint256 maxAuctionLength);
    event NewOperatorAddress(address indexed account);
    event TokenRecovery(address indexed token, uint256 amount);
    event WhitelistAdd(address indexed account);
    event WhitelistRemove(address indexed account);

    /**
     * @notice Constructor
     * @param _dutyToken: address of the $Duty token
     * @param _operatorAddress: address of the operator
     * @param _maxAuctionLength: max amount of blocks for an auction
     */
    constructor(
        address _dutyToken,
        address _operatorAddress,
        uint256 _maxAuctionLength
    ) {
        require(_maxAuctionLength > 0, "Auction: Length cannot be zero");
        require(_maxAuctionLength <= 864000, "Auction: Cannot be longer than thirty days (8,64,000 blocks)");

        dutyToken = IERC20(_dutyToken);
        operatorAddress = _operatorAddress;
        maxAuctionLength = _maxAuctionLength;
    }

    /**
     * @notice Bid for the current auction round
     * @param _amount: amount of the bid in $Duty token
     * @dev Callable by (whitelisted) bidders
     */
    function bid(uint256 _amount) external nonReentrant {
        require(bidders.contains(msg.sender), "Whitelist: Not whitelisted");
        require(auctions[currentAuctionId].status == Status.Open, "Auction: Not in progress");
        require(block.number > auctions[currentAuctionId].startBlock, "Auction: Too early");
        require(block.number < auctions[currentAuctionId].endBlock, "Auction: Too late");
        require(_amount % uint256(10**19) == uint256(0), "Bid: Incorrect amount");

        if (auctionBids[currentAuctionId][msg.sender].totalAmount == 0) {
            require(_amount >= auctions[currentAuctionId].initialBidAmount, "Bid: Incorrect initial bid amount");
        }

        dutyToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        auctionBids[currentAuctionId][msg.sender].totalAmount += _amount;

        if (!_auctionBidders[currentAuctionId].contains(msg.sender)) {
            _auctionBidders[currentAuctionId].add(msg.sender);
            _bidderAuctions[msg.sender].push(currentAuctionId);
        }

        emit AuctionBid(currentAuctionId, msg.sender, _amount);
    }

    /**
     * @notice Claim unsuccessful participation (total bids) for an auction round
     * @param _auctionId: auction id
     * @dev Callable by (current, and previous whitelisted) bidders
     */
    function claimAuction(uint256 _auctionId) external nonReentrant {
        require(block.number > auctions[_auctionId].endBlock, "Auction: In progress");
        require(auctions[_auctionId].status == Status.Close, "Auction: Not claimable");
        require(auctionBids[_auctionId][msg.sender].totalAmount != 0, "Bid: Not found");
        require(
            auctionBids[_auctionId][msg.sender].totalAmount < auctions[_auctionId].leaderboardThreshold,
            "Bid: Cannot be claimed (in leaderboard)"
        );
        require(!auctionBids[_auctionId][msg.sender].hasClaimed, "Bid: Cannot be claimed twice");

        auctionBids[_auctionId][msg.sender].hasClaimed = true;

        uint256 claimableAmount = auctionBids[_auctionId][msg.sender].totalAmount;
        dutyToken.safeTransfer(address(msg.sender), claimableAmount);

        emit AuctionClaim(_auctionId, msg.sender, claimableAmount, false);
    }

    /**
     * @notice Add addresses to the whitelist
     * @param _bidders: addresses of bidders
     * @dev Callable by operator
     */
    function addWhitelist(address[] calldata _bidders) external onlyOperator {
        require((currentAuctionId == 2) || (auctions[currentAuctionId].status == Status.Close), "Auction: In progress");

        for (uint256 i = 0; i < _bidders.length; i++) {
            address account = _bidders[i];

            if (!bidders.contains(account)) {
                bidders.add(account);

                emit WhitelistAdd(account);
            }
        }
    }

    /**
     * @notice Remove addresses from the whitelist
     * @param _bidders: addresses of bidders
     * @dev Callable by operator
     */
    function removeWhitelist(address[] calldata _bidders) external onlyOperator {
        require((currentAuctionId == 2) || (auctions[currentAuctionId].status == Status.Close), "Auction: In progress");

        for (uint256 i = 0; i < _bidders.length; i++) {
            address account = _bidders[i];

            if (bidders.contains(account)) {
                bidders.remove(account);

                emit WhitelistRemove(account);
            }
        }
    }

    /**
     * @notice Start an auction round
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _initialBidAmount: amount of the initial bid (10 ** 18)
     * @param _leaderboard: top n of addresses to keep as winners
     * @dev Callable by operator
     */
    function startAuction(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _initialBidAmount,
        uint256 _leaderboard
    ) external onlyOperator {
        require((currentAuctionId == 0) || (auctions[currentAuctionId].status == Status.Close), "Auction: In progress");
        require(_startBlock > block.number, "Auction: Start block must be higher than current block");
        require(_startBlock < _endBlock, "Auction: Start block must be lower than End block");
        require(
            block.number + maxAuctionLength > _startBlock,
            "Auction: Start block must be lower than current block + Buffer"
        );
        require(
            _startBlock + maxAuctionLength > _endBlock,
            "Auction: End block must be lower than Start block + Buffer"
        );
        require(_initialBidAmount > 0, "Auction: Initial bid amount cannot be zero");
        require(_initialBidAmount % uint256(10**19) == uint256(0), "Auction: Incorrect initial bid amount");
        require(_leaderboard > 0, "Auction: Leaderboard cannot be zero");
        require(bidders.length() > 0, "Auction: No whitelisted address");

        currentAuctionId++;

        auctions[currentAuctionId] = Auction({
            status: Status.Open,
            startBlock: _startBlock,
            endBlock: _endBlock,
            initialBidAmount: _initialBidAmount,
            leaderboard: _leaderboard,
            leaderboardThreshold: 0
        });

        emit AuctionStart(currentAuctionId, _startBlock, _endBlock, _initialBidAmount, _leaderboard);
    }

    /**
     * @notice Close an auction round, and store $Duty leaderboard threshold
     * @param _bidLimit: minimal $Duty committed to be a winner
     * @dev Callable by operator
     */
    function closeAuction(uint256 _bidLimit) external onlyOperator {
        require(
            (currentAuctionId != 0) || auctions[currentAuctionId].status == Status.Open,
            "Auction: Not in progress"
        );
        require(block.number > auctions[currentAuctionId].endBlock, "Auction: In progress");

        auctions[currentAuctionId].status = Status.Close;
        auctions[currentAuctionId].leaderboardThreshold = _bidLimit;

        emit AuctionClose(currentAuctionId, _bidLimit, _auctionBidders[currentAuctionId].length());
    }

    /**
     * @notice Claim $Duty for all bids by bidders in leaderboard
     * @param _auctionId: auction id
     * @param _bidders: addresses of bidders
     * @dev Callable by owner
     */
    function claimAuctionLeaderboard(uint256 _auctionId, address[] calldata _bidders) external onlyOwner nonReentrant {
        require(block.number > auctions[_auctionId].endBlock, "Auction: In progress");
        require(auctions[_auctionId].status == Status.Close, "Auction: Not claimable");

        uint256 auctionThreshold = auctions[_auctionId].leaderboardThreshold;

        uint256 claimableAmount = 0;
        for (uint256 i = 0; i < _bidders.length; i++) {
            BidInfo memory bidInfo = auctionBids[_auctionId][_bidders[i]];

            require(!bidInfo.hasClaimed, "Bid: Cannot be claimed twice");
            require(bidInfo.totalAmount >= auctionThreshold, "Bid: Cannot be claimed (not in leaderboard)");

            claimableAmount += bidInfo.totalAmount;

            auctionBids[_auctionId][_bidders[i]].hasClaimed = true;
        }

        if (claimableAmount > 0) {
            totalCollected += claimableAmount;

            dutyToken.safeTransfer(address(msg.sender), claimableAmount);
        }

        emit AuctionClaim(_auctionId, msg.sender, claimableAmount, true);
    }

    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param _token: token address
     * @param _amount: token amount
     * @dev Callable by owner
     */
    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(dutyToken), "Recover: Cannot be Duty token");

        IERC20(_token).safeTransfer(address(msg.sender), _amount);

        emit TokenRecovery(_token, _amount);
    }

    /**
     * @notice Allows the owner to set the Operator address (to run Auction rounds)
     * @param _operatorAddress: address of the new operator
     * @dev Callable by owner
     */
    function setOperatorAddress(address _operatorAddress) external onlyOwner {
        require(_operatorAddress != address(0), "Management: Cannot be zero address");

        operatorAddress = _operatorAddress;

        emit NewOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Allows the owner to change the maximal length (denominated in block) for an auction round
     * @param _maxAuctionLength: amount of blocks, for an auction
     * @dev Callable by owner
     */
    function setMaxAuctionLength(uint256 _maxAuctionLength) external onlyOperator {
        require((currentAuctionId == 2) || (auctions[currentAuctionId].status == Status.Close), "Auction: In progress");
        require(_maxAuctionLength > 0, "Auction: Length cannot be zero");
        require(_maxAuctionLength <= 864000, "Auction: Cannot be longer than thirty days (8,64,000 blocks)");

        maxAuctionLength = _maxAuctionLength;

        emit NewMaxAuctionLength(_maxAuctionLength);
    }

    /**
     * @notice View list of auctions
     * @param cursor: cursor
     * @param size: size
     */
    function viewAuctions(uint256 cursor, uint256 size) external view returns (Auction[] memory, uint256) {
        uint256 length = size;
        if (length > currentAuctionId - cursor) {
            length = currentAuctionId - cursor;
        }

        Auction[] memory values = new Auction[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = auctions[cursor + i + 1];
        }

        return (values, cursor + length);
    }

    /**
     * @notice View list of whitelisted addresses (a.k.a. bidders)
     * @param cursor: cursor
     * @param size: size
     */
    function viewBidders(uint256 cursor, uint256 size) external view returns (address[] memory, uint256) {
        uint256 length = size;
        uint256 biddersLength = bidders.length();
        if (length > biddersLength - cursor) {
            length = biddersLength - cursor;
        }

        address[] memory values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = bidders.at(cursor + i);
        }

        return (values, cursor + length);
    }

    /**
     * @notice View list of current bidders and bid amount for an auction round
     * @param auctionId: auction id
     * @param cursor: cursor
     * @param size: size
     */
    function viewBidsPerAuction(
        uint256 auctionId,
        uint256 cursor,
        uint256 size
    ) external view returns (Bid[] memory, uint256) {
        uint256 length = size;
        uint256 biddersLength = _auctionBidders[auctionId].length();
        if (length > biddersLength - cursor) {
            length = biddersLength - cursor;
        }

        Bid[] memory values = new Bid[](length);
        for (uint256 i = 0; i < length; i++) {
            address account = _auctionBidders[auctionId].at(cursor + i);
            uint256 amount = auctionBids[auctionId][account].totalAmount;
            bool claimed = auctionBids[auctionId][account].hasClaimed;

            values[i] = Bid({account: account, amount: amount, hasClaimed: claimed});
        }

        return (values, cursor + length);
    }

    /**
     * @notice Get the claimable status of a specific bid, for a given auction and bidder
     * @param auctionId: auction id
     * @param bidder: address of bidder
     */
    function claimable(uint256 auctionId, address bidder) external view returns (bool) {
        Auction memory auction = auctions[auctionId];
        BidInfo memory bidInfo = auctionBids[auctionId][bidder];

        return
            block.number > auction.endBlock &&
            auction.status == Status.Close &&
            bidInfo.totalAmount != 0 &&
            bidInfo.totalAmount < auction.leaderboardThreshold &&
            !bidInfo.hasClaimed;
    }

    /**
     * @notice Get the whitelisted status of a specific bidder
     * @param bidder: address of bidder
     */
    function whitelisted(address bidder) external view returns (bool) {
        return bidders.contains(bidder);
    }

    /**
     * @notice View list of participated auctions, along with bids for a bidder
     * @param bidder: address of bidder
     * @param cursor: cursor
     * @param size: size
     */
    function viewBidderAuctions(
        address bidder,
        uint256 cursor,
        uint256 size
    )
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 length = size;
        if (length > _bidderAuctions[bidder].length - cursor) {
            length = _bidderAuctions[bidder].length - cursor;
        }

        uint256[] memory auctionIds = new uint256[](length);
        uint256[] memory bids = new uint256[](length);
        bool[] memory claimed = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            auctionIds[i] = _bidderAuctions[bidder][cursor + i];
            bids[i] = auctionBids[auctionIds[i]][bidder].totalAmount;
            claimed[i] = auctionBids[auctionIds[i]][bidder].hasClaimed;
        }

        return (auctionIds, bids, claimed, cursor + length);
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
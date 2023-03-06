/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;


// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)


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


// File contracts/operations/agents/IAgentAssignments.sol





interface IAgentAssignments {
    struct Assignment {
        address assigner;
        address assignment;
        uint256 matchID;
        bool active;
    }
    function assignments(address assigner, address assignment) external returns (Assignment memory);
}


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)


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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/utility/Permissions.sol






/**
 * @title A generic permissions-management contract for Yakuza 2033.
 *
 * @notice Yakuza 2033
 *             Telegram: t.me/yakuza2033
 *             Twitter:  yakuza2033
 *             App:      yakuza2033.com
 *
 * @author Shogun
 *             Telegram: zeroXshogun
 *             Web:      coinlord.finance
 *
 * @custom:security-contact Telegram: zeroXshogun
 */
contract Permissions is Context, Ownable {
    /// Accounts permitted to modify rules.
    mapping(address => bool) public appAddresses;

    modifier onlyApp() {
        require(appAddresses[_msgSender()] == true, "Caller is not admin");
        _;
    }

    constructor() {}

    function setPermission(address account, bool permitted)
        external
        onlyOwner
    {
        appAddresses[account] = permitted;
    }
}


// File contracts/casino/Sumo_12Moons_Matches.sol




// Access.

// AgentAssignments.

/**
 * Bugs interface.
 */
interface IBugs {
    /**
     * @dev Mint tokens.
     *
     * @param to address to mint tokens to.
     * @param id ID of the token to mint.
     * @param amount amount of the token to mint.
     */
    function mint(address to, uint256 id, uint256 amount) external;

    /**
    * @dev Burns `amount` of the token from `account`.
    * @param account The address to burn the tokens from.
    * @param amount The amount of tokens to burn.
    */
    function burn(address account, uint256 amount) external;

    /**
     * @dev Transfers an amount of tokens from one address to another.
     *
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer tokens to.
     * @param amount The amount of tokens to be transferred.
     *
     * @return true if the transfer was successful, false otherwise.
    */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


/**
 * Dispensary interface.
 */
interface IDispensary {

    function balanceOf(address account, uint256 id) external returns (uint256);

    /**
    * Mint a token.
    *
    * @dev Caller must have approved Operatives to transfer Bugs.
    *
    * @param to as address of recipient.
    * @param id as uint256 ID of the token to mint.
    * @param amount as uint256 amount of the token to mint.
    */
    function mint(address to, uint256 id, uint256 amount) external;
}


/**
 * @title A betting contract for Yakuza 2033.
 *
 * @notice Yakuza 2033
 *             Telegram: t.me/yakuza2033
 *             Twitter:  yakuza2033
 *             App:      yakuza2033.com
 *
 * @author Shogun
 *             Telegram: zeroXshogun
 *             Web:      coinlord.finance
 *
 * @custom:security-contact Telegram: zeroXshogun
 */
contract Sumo_12Moons_Matches is Permissions {

    ////
    //// ADDRESSES
    ////

    /// Betting token.
    IBugs public bugs;

    /// NFT collection.
    IDispensary public dispensary;
    /// Ticket stub.
    uint256 public ticketStubID;

    // Sumo contract.
    address public sumo;

    /// Contract where Geisha is assigned to Sumo.
    IAgentAssignments public agentAssignments;

    ////
    //// TOURNAMENT
    ////

    /// Individual sumo details.
    struct Sumo {
        uint256 id;
        string name;
        uint256 wins;
        uint256 losses;
    }

    /// All sumos.
    /// @dev sumo ID => Sumo
    mapping(uint256 => Sumo) public sumos;

    /// Sumo with the most wins.
    uint256 public leadingSumo;

    /// Largest allowed bet, in Wei.
    uint256 public maxBet;

    /// Cost to join.
    uint256 public matchCost;

    /// Number of tickets needed for 1% boost.
    uint256 public stubSetSize;

    ////
    //// MATCH
    ////

    /// Match details.
    struct Match {
        uint256 id;
        Sumo sumo0;
        Sumo sumo1;
        bool defined;
        bool ran;
        bool zeroWon;
        uint256 totalBets;
    }

    /// Current match ID.
    uint256 public currentMatchID;

    /// All matches.
    /// @dev match ID => Match
    mapping(uint256 => Match) public matches;

    /// Sumo ID for each match winner.
    uint256[] public winners;

    event MatchDefined(uint256 indexed id, string indexed sumo0, string indexed sumo1);
    event MatchStarted(uint256 indexed id, uint256 indexed numBettors, uint256 indexed totalBets);
    event MatchEnded(uint256 indexed id, uint256 indexed winner);

    ////
    //// BETTORS
    ////

    /// Bet details.
    struct Bet {
        address bettor;
        bool betPlaced;
        bool choseZero;
        uint256 betAmount;
    }

    /// All bets.
    /// @dev match ID => bettor => Bet
    mapping(uint256 => mapping(address => Bet)) public bets;
    mapping(uint256 => address[]) public bettorLists;

    event BetPlaced(address indexed bettor, bool indexed choseZero, uint256 indexed betAmount);

    ////
    //// WINNINGS
    ////

    mapping(address => uint256) public claimableBalances;
    event WinningsAvailable(address indexed bettor, uint256 indexed winnings);
    event WinningsClaimed(address indexed claimant, uint256 indexed winnings);

    ////
    //// INIT
    ////

    constructor(
        address _bugs,
        address _dispensary,
        address _agentAssignments,
        address _sumo,
        uint256 _sumo0ID,
        string memory _sumo0Name,
        uint256 _sumo1ID,
        string memory _sumo1Name
    ) {
        // Contracts.
        bugs = IBugs(_bugs);
        dispensary = IDispensary(_dispensary);
        ticketStubID = 1;
        stubSetSize = 5;
        agentAssignments = IAgentAssignments(_agentAssignments);
        sumo = _sumo;

        // Tournament cost and bet limits.
        matchCost = 10000000000000000000; // 1k
        maxBet = 5000000000000000000000; // 5k

        // Initial sumos and match.
        sumos[0] = Sumo(_sumo0ID, _sumo0Name, 0, 0);
        sumos[1] = Sumo(_sumo1ID, _sumo1Name, 0, 0);
        matches[0] = Match(
            0,
            sumos[0],
            sumos[1],
            true,
            false,
            false,
            0
        );
    }

    ////
    //// ADMIN
    ////

    function setMaxBet(uint256 _maxBet) external onlyOwner {
        maxBet = _maxBet;
    }

    ////
    //// TOURNAMENT
    ////

    function defineSumos(
        uint256[] memory ids,
        string[] memory names,
        uint256[] memory wins,
        uint256[] memory losses
    ) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            sumos[ids[i]] = Sumo(ids[i], names[i], wins[i], losses[i]);
        }
    }

    ////
    //// BETTORS
    ////

    function bet(bool _choseZero, uint256 _betAmount) public {
        address bettor = _msgSender();

        require(matches[currentMatchID].defined, "Match not ready");
        require(!bets[currentMatchID][bettor].betPlaced, "Bet already placed");
        require(_betAmount > 0 && _betAmount <= maxBet, "Invalid bet size");

        // Burn bet.
        bugs.burn(bettor, _betAmount);
    
        // Record bet.
        bets[currentMatchID][bettor] = Bet(
            bettor,
            true,
            _choseZero,
            _betAmount
        );
        bettorLists[currentMatchID].push(bettor);
        matches[currentMatchID].totalBets += _betAmount;

        // Mint ticket.
        dispensary.mint(bettor, ticketStubID, 1);

        // Event.
        emit BetPlaced(bettor, _choseZero, _betAmount);
    }

    ////
    //// ADMIN - MATCH
    ////

    function defineMatch(
        uint256 sumo0ID,
        string memory sumo0Name,
        uint256 sumo1ID,
        string memory sumo1Name
    ) external onlyApp {
        require(matches[currentMatchID].defined == false, "Match already defined");

        matches[currentMatchID] = Match(
            currentMatchID,
            Sumo(sumo0ID, sumo0Name, 0, 0),
            Sumo(sumo1ID, sumo1Name, 0, 0),
            true,
            false,
            false,
            0
        );

        emit MatchDefined(currentMatchID, sumo0Name, sumo1Name);
    }

    function runMatch() external onlyApp {
        require(matches[currentMatchID].defined == true, "Match not defined");
        require(matches[currentMatchID].ran == false, "Match already ran");

        uint256 length = bettorLists[currentMatchID].length;
        emit MatchStarted(currentMatchID, length, matches[currentMatchID].totalBets);

        // Pseudorandomly determine winner.
        uint256 pseudorandom = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    length,
                    maxBet,
                    currentMatchID
                )
            )
        ) % 2;
        matches[currentMatchID].zeroWon = pseudorandom == 0;
        if (matches[currentMatchID].zeroWon) {
            winners.push(matches[currentMatchID].sumo0.id);
        } else {
            winners.push(matches[currentMatchID].sumo1.id);
        }

        // For all bettors in this match.
        for (uint256 i = 0; i < length; i++) {
            // Get bettor.
            address bettor = bettorLists[currentMatchID][i];
            // If bettor won this match bet.
            if (bets[currentMatchID][bettor].choseZero == matches[currentMatchID].zeroWon) {
                // Get bet amount.
                uint256 bettorBet = bets[currentMatchID][bettor].betAmount;
                // Calculate base winnings.
                uint256 winnings = bettorBet * 2;
                // Calculate geisha winnings boost.
                if (isGeishaAssigned(bettor)) {
                    winnings += ((bettorBet * 6) / 5) - bettorBet;
                }
                // Calculate ticket stubs winnings boost.
                uint256 stubs = dispensary.balanceOf(bettor, ticketStubID);
                if (stubs >= stubSetSize) {
                    uint256 stubSets = stubs / stubSetSize;
                    if (stubSets > 0) {
                        winnings += ((bettorBet * (100 + stubSets)) / 100) - bettorBet;
                    }
                }
                // Update claimable balance.
                claimableBalances[bettor] += winnings;
                emit WinningsAvailable(bettor, winnings);
            }
        }

        // Event.
        emit MatchEnded(currentMatchID, pseudorandom);

        // Update state to next match.        
        matches[currentMatchID].ran = true;
        currentMatchID++;
    }

    function isGeishaAssigned(address bettor) private returns (bool) {
        return agentAssignments.assignments(bettor, sumo).active;
    }

    ////
    //// WINNINGS
    ////

    /**
     * @dev Must be permitted by Bugs to mint.
     */
    function claimWinnings() external {
        address claimer = _msgSender();

        uint256 winnings = claimableBalances[claimer];

        require(winnings > 0, "No winnings available");

        claimableBalances[claimer] = 0;
        bugs.mint(claimer, 0, winnings);

        emit WinningsClaimed(claimer, winnings);
    }

    function claimWinningsAsApp(address claimer) external onlyApp {
        uint256 winnings = claimableBalances[claimer];

        require(winnings > 0, "No winnings available");

        claimableBalances[claimer] = 0;
        bugs.mint(claimer, 0, winnings);

        emit WinningsClaimed(claimer, winnings);
    }
}
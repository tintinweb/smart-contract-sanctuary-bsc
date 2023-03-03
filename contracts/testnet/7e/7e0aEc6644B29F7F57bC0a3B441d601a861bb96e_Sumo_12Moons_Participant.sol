/**
 *Submitted for verification at BscScan.com on 2023-03-02
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


// File contracts/casino/Sumo_12Moons_Participant.sol



// Access.

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
 * @title A contract for participating in Yakuza 2033's 12 Moons sumo tournament.
 *
 * @dev Join, pay Bugs, receive Ticket.
 * @dev Select Sumo, place Bugs bet.
 *
 * @dev Must be permitted to mint Dispensary.
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
contract Sumo_12Moons_Participant is Permissions {

    ////
    //// ADDRESSES
    ////

    /// Token used to bet.
    IBugs public bugs;

    /// Dead wallet.
    address public dead;

    /// Generic NFT dispensary contract.
    IDispensary public dispensary;
    /// ID of the ticket stub token
    uint256 public ticketStubID;

    ////
    //// TOURNAMENT
    ////

    /// Cost to join the tournament.
    uint256 public fee;

    /// Max amount of Bugs that can be bet on a sumo.
    uint256 public maxBet;

    /// Whether the tournament has begun.
    uint256 public currentMatchID;
    bool public tournamentStarted;
    bool public tournamentEnded;

    /// Sumo IDs and their names.
    mapping(uint256 => string) public sumos;

    /// Participants that have joined.
    mapping(address => bool) public participants;
    address[] public participantsList;
    /// Participants and the sumo ID they selected.
    mapping(address => uint256) public sumoSelections;
    /// Participants and the amount they bet on their sumo winning.
    mapping(address => uint256) public sumoSelectionBets;
    /// Sumo IDs and the amount of times they were selected.
    mapping(uint256 => uint256) public sumoSelectionCounts;

    /// Sumo ID with the most selections.
    uint256 public mostSelected;

    /// Sumo that won the tournament.
    uint256 public winningSumo;

    event SeatTaken(address indexed participant);
    event SumoSelected(address indexed participant, uint256 indexed sumo);

    ////
    //// INIT
    ////

    constructor(
        address _bugs,
        address _dispensary,
        uint256 _ticketStubID,
        uint256 _fee,
        uint256 _maxBet,
        uint256[] memory ids,
        string[] memory names
    ) {
        bugs = IBugs(_bugs);
        dead = 0x000000000000000000000000000000000000dEaD;
        dispensary = IDispensary(_dispensary);
        ticketStubID = _ticketStubID;
        fee = _fee;
        maxBet = _maxBet;
        for (uint256 i = 0; i < ids.length; i++) {
            sumos[ids[i]] = names[i];
        }
    }

    ////
    //// ADMIN
    ////

    function setMaxBet(uint256 _maxBet) external onlyOwner {
        maxBet = _maxBet;
    }

    function startTournament() external onlyOwner {
        tournamentStarted = true;
    }

    function endTournament(uint256 _winningSumo) external onlyOwner {
        // Prevent further joins.
        tournamentEnded = true;

        // Store winning sumo.
        winningSumo = _winningSumo;

        // Increment match ID to free assigned Geishas.
        currentMatchID++;
    }

    ////
    //// PARTICIPANTS
    ////

    function join(uint256 sumoSelection, uint256 bet) external {
        address bettor = _msgSender();
        
        require(participants[bettor], "Already joined");
        require(!tournamentEnded, "Tournament ended");

        // Preferred sumo cannot be selected if tournament has started.
        if (tournamentStarted) {
            takeSeat(bettor);
        } else {
            takeSeatAndSelectSumo(bettor, sumoSelection, bet);
        }
    }

    function takeSeat(address bettor) private {
        // Take fee from bettor.
        bugs.transferFrom(bettor, dead, fee);

        // Update bettor.
        participants[bettor] = true;
        participantsList.push(bettor);

        // Mint ticket.
        dispensary.mint(bettor, ticketStubID, 1);

        // Emit event.
        emit SeatTaken(bettor);
    }

    function takeSeatAndSelectSumo(address bettor, uint256 sumoSelection, uint256 bet) private {
        // Take fee + bet from bettor.
        require(bet < maxBet, "Over max bet");
        bugs.transferFrom(bettor, dead, fee + bet);

        // Update bettor.
        participants[bettor] = true;
        participantsList.push(bettor);

        // Mint ticket.
        dispensary.mint(bettor, ticketStubID, 1);

        // Update sumo tracking.
        sumoSelections[bettor] = sumoSelection;
        sumoSelectionBets[bettor] = bet;
        sumoSelectionCounts[sumoSelection] += 1;
        if (sumoSelectionCounts[sumoSelection] > mostSelected) {
            mostSelected = sumoSelection;
        }

        // Emit events.
        emit SeatTaken(bettor);
        emit SumoSelected(bettor, sumoSelection);
    }
}
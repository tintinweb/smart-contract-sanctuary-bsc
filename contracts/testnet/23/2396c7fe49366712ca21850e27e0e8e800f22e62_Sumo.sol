/**
 *Submitted for verification at BscScan.com on 2023-02-07
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


// File contracts/casino/Sumo.sol




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
 * BathHouse interface.
 */
interface IBathHouse {
    /**
     * @dev Returns the balance of a given account and id.
     * @param account The address of the account to check the balance of.
     * @param id The identifier of the balance to retrieve.
     * @return The balance of the account with the given id.
    */
    function balanceOf(address account, uint256 id) external returns (uint256);
}


/**
 * Dispensary interface.
 */
interface IDispensary {
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
contract Sumo is Permissions {

    ////
    //// ADDRESSES
    ////

    /// Token used to bet.
    IBugs public bugs;

    /// Geisha NFT contract.
    IBathHouse public bathHouse;

    /// Generic NFT dispensary contract.
    IDispensary public dispensary;
    /// ID of the ticket stub token
    uint256 public ticketStubID;

    ////
    //// MATCH
    ////

    struct Match {
        uint256 id;
        uint256 cost;
        string[] sumos;
        bool defined;
        bool ran;
        bool zeroWon;
        uint256 totalBets;
    }

    /// Current match ID.
    uint256 public currentMatchID;
    /// All matches.
    Match[] public matches;

    event MatchDefined(uint256 indexed id, uint256 indexed cost);
    event BellRung(uint256 indexed id, uint256 indexed numBettors, uint256 indexed totalBets);

    ////
    //// PARTICIPANTS
    ////

    struct Bettor {
        address bettor;
        bool seatTaken;
        bool geishaInvited;
        bool betPlaced;
        bool choseZero;
        uint256 betAmount;
    }

    address[] public bettorList;
    mapping(address => Bettor) public bettors;

    event SeatTaken(address indexed account);
    event GeishaInvited(address indexed account, uint256 indexed id);
    event BetPlaced(address indexed bettor, bool indexed choseZero, uint256 indexed betAmount);

    ////
    //// WINNINGS
    ////

    mapping(address => uint256) public claimableBalances;
    event WinningsClaimed(address indexed claimant, uint256 winnings);

    ////
    //// INIT
    ////

    constructor(address _bugs, address _bathHouse, address _dispensary) {
        bugs = IBugs(_bugs);
        bathHouse = IBathHouse(_bathHouse);
        dispensary = IDispensary(_dispensary);
        ticketStubID = 1;
    }

    ////
    //// PARTICIPANTS
    ////

    function takeSeat() external {
        require(matches[currentMatchID].defined, "Match not ready");
        require(!bettors[_msgSender()].seatTaken, "User is seatTaken");

        bugs.burn(_msgSender(), matches[currentMatchID].cost);

        bettorList.push(_msgSender());
        bettors[_msgSender()] = Bettor(
            _msgSender(),
            true,
            false,
            false,
            false,
            0
        );

        dispensary.mint(_msgSender(), ticketStubID, 1);

        emit SeatTaken(_msgSender());
    }

    function inviteGeisha(uint256 id) external {
        require(matches[currentMatchID].defined, "Match not ready");
        require(bettors[_msgSender()].seatTaken, "User not seated");
        require(!bettors[_msgSender()].geishaInvited, "Geisha already invited");
        require(bathHouse.balanceOf(_msgSender(), id) > 0, "Geisha not owned");

        bettors[_msgSender()].geishaInvited = true;

        emit GeishaInvited(_msgSender(), id);
    }

    function placeBet(bool _choseZero, uint256 _betAmount) public {
        require(matches[currentMatchID].defined, "Match not ready");
        require(bettors[_msgSender()].seatTaken, "User not seated");
        require(!bettors[_msgSender()].betPlaced, "Bet already placed");

        bugs.burn(_msgSender(), _betAmount);

        bettors[_msgSender()].betPlaced = true;
        bettors[_msgSender()].choseZero = _choseZero;
        bettors[_msgSender()].betAmount = _betAmount;

        matches[currentMatchID].totalBets += _betAmount;

        emit BetPlaced(_msgSender(), _choseZero, _betAmount);
    }

    ////
    //// MATCH
    ////

    function defineMatch(uint256 _cost, string[] memory _sumos) external onlyOwner {
        if (currentMatchID != 0) {
            require(matches[currentMatchID].ran == true, "Match already defined");
        }

        matches.push(
            Match(
                currentMatchID,
                _cost,
                _sumos,
                true,
                false,
                false,
                0
            )
        );
        currentMatchID++;

        emit MatchDefined(currentMatchID, _cost);
    }

    function runMatch() external onlyOwner {
        require(matches[currentMatchID].defined == true, "Match not defined");
        require(matches[currentMatchID].ran == false, "Match already ran");

        uint256 pseudorandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number
        ))) % 2;
        matches[currentMatchID].zeroWon = pseudorandom == 0;

        uint256 length = bettorList.length;
        for (uint256 i = 0; i < length; i++) {

            address bettor = bettorList[i];
            if (bettors[bettor].choseZero == matches[currentMatchID].zeroWon) {

                uint256 winnings = bettors[bettor].betAmount * 2;
                if (bettors[bettor].geishaInvited) {
                    winnings = winnings * 6 / 5;
                }
                claimableBalances[bettor] += winnings;
            }
            delete bettors[bettor];
        }
        delete bettorList;

        matches[currentMatchID].ran = true;

        emit BellRung(currentMatchID, length, matches[currentMatchID].totalBets);
    }

    ////
    //// WINNINGS
    ////

    /**
     * @dev Sumo must be permitted by Bugs to mint.
     */
    function claimWinnings() external {
        uint256 winnings = claimableBalances[_msgSender()];

        require(winnings > 0, "No winnings available");

        claimableBalances[_msgSender()] = 0;
        bugs.mint(_msgSender(), 0, winnings);

        emit WinningsClaimed(_msgSender(), winnings);
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;


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


// File contracts/casino/Dice.sol
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
    *
    * @param account The address to burn the tokens from.
    * @param amount The amount of tokens to burn.
    */
    function burn(address account, uint256 amount) external;

    /**
     * Get max amount of `owner` tokens that `spender` can move with transferFrom.
     *
     * @param owner as address of account owning tokens.
     * @param spender as address of account moving tokens.
     *
     * @return uint256 as max amount of tokens able to be transferred.
     */
    function allowance(address owner, address spender) external returns (uint256);

    /**
     * Transfer tokens from caller to `to`.
     *
     * @param to as address of receiver.
     * @param amount of tokens.
     *
     * @return bool on success.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
contract Dice is Permissions {

    /// Betting token.
    IBugs public bugs;
    /// Amount of tokens per bet.
    uint256 public playAmount;
    /// Count of players in current game.
    address[] public currentPlayers;
    /// Player bets.
    mapping(address => uint256) public bets;
    /// Winner of previous game.
    address[] public winners;
    /// Count of games played.
    uint256 public gameCounter;

    /**
     * Emitted when a game is played and a winner is selected.
     *
     * @param gameID as ID of the game.
     * @param winner as address of the winner.
     */
    event GamePlayed(
        uint256 indexed gameID,
        address indexed winner
    );

    ////
    //// INIT
    ////

    /**
     * Deploy contract.
     *
     * @param _bugs as address of the betting token.
     * @param _playAmount as amount of tokens per bet.
     */
    constructor(
        address _bugs,
        uint256 _playAmount
    ) {
        bugs = IBugs(_bugs);
        playAmount = _playAmount;
    }

    ////
    //// ADMIN
    ////

    function setPlayAmount(uint256 _playAmount) external onlyOwner {
        require(currentPlayers.length == 0, "Players already joined");
        playAmount = _playAmount;
    }

    ////
    //// GAME
    ////

    /**
     * Play game as caller.
     *
     * @dev Caller must first approve this contract to transfer bugs.
     * @dev Game starts when currentPlayers is 6.
     */
    function playGame() external {
        address player = _msgSender();

        require(
            bugs.allowance(player, address(this)) >= playAmount,
            "Approve Dice to spend Bugs"
        );

        // Transfer bugs from caller to this contract.
        bugs.transferFrom(
            player,
            address(this),
            playAmount
        );

        // Store bet.
        currentPlayers.push(player);
        bets[player] += playAmount;

        // Start game if 6 players are ready to play.
        if(currentPlayers.length > 5) {
            _rollDice();
        }
    }

    /**
     * Selects a game winner from the current players.
     *
     * @notice Emits a GamePlayed event.
     *
     * @dev Winner is decided pseudorandomly.
     * @dev Winner receives 5 times playAmount of bugs.
     * @dev Remaining 1 playAmount of bugs is burned.
     */
    function _rollDice() internal {

        // Pseudorandomly select winner.
        uint256 winner = uint256(keccak256(
            abi.encodePacked(
                currentPlayers,
                block.timestamp,
                block.number,
                gameCounter,
                currentPlayers[4]
            ))) % 6;

        // Store winner.
        winners.push(currentPlayers[winner]);

        // Transfer winning amount of tokens to winner.
        bugs.transfer(
            winners[gameCounter],
            playAmount * 5
        );

        // Transfer burn amount of tokens to burn address.
        bugs.burn(
            address(this),
            playAmount
        );

        // Event.
        emit GamePlayed(
            gameCounter,
            winners[gameCounter]
        );

        // Deletes current game's list of players.
        delete currentPlayers;

        // Increment game count.
        gameCounter++;
    }

    ////
    //// MISC
    ////

    /**
     * Count of players in current game.
     *
     * @return uint256 as count of players.
     */
    function currentPlayersCount() external view returns(uint256) {
        return currentPlayers.length;
    }
}
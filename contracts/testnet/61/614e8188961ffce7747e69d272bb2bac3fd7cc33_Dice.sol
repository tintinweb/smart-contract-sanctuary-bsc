/**
 *Submitted for verification at BscScan.com on 2023-02-11
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


// File @openzeppelin/contracts/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)


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


// File @openzeppelin/contracts/token/ERC1155/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol[email protected]

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


// File contracts/utility/GeishaCustodian.sol





// Access.


interface IBathHouse {

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}


interface IGame {
    function currentMatchID() external returns (uint256);
}


/**
 * @title A generic contract to deposit and withdraw Geishas for Yakuza 2033.
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
contract GeishaCustodian is Permissions, ERC1155Receiver {

    ////
    //// ADDRESSES
    ////

    /// Geisha contract.
    IBathHouse public bathHouse;

    /// Game contract.
    IGame public game;

    ////
    //// CUSTODIAN
    ////

    struct CustodiedGeisha {
        address depositor;
        bool hasDeposited;
        uint256 geishaID;
        uint256 matchID;
    }

    /// Deposited Geisha's.
    mapping(address => CustodiedGeisha) public custodiedGeishas;

    constructor(address _bathHouse, address _game) {
        bathHouse = IBathHouse(_bathHouse);
        game = IGame(_game);
    }

    ////
    //// CUSTODY
    ////

    /**
     * Deposit a Geisha.
     *
     * @dev Depositor must have approved this contract to transfer the Geisha.
     *
     * @param id of Geisha token.
     */
    function depositGeisha(uint256 id) external {
        address depositor = _msgSender();

        bathHouse.safeTransferFrom(
            depositor,
            address(this),
            id,
            1,
            ""
        );

        uint256 matchID = game.currentMatchID();
        custodiedGeishas[depositor] = CustodiedGeisha(depositor, true, id, matchID);
    }

    /**
     * Withdraw a deposited Geisha.
     *
     * @param id of Geisha token.
     */
    function withdrawGeisha(uint256 id) external {
        address depositor = _msgSender();

        uint256 _matchID = game.currentMatchID();

        require(custodiedGeishas[depositor].hasDeposited, "No Geisha deposited");
        require(custodiedGeishas[depositor].matchID != _matchID, "Cannot withdraw during same match");

        bathHouse.safeTransferFrom(
            address(this),
            depositor,
            id,
            1,
            ""
        );

        delete custodiedGeishas[depositor];
    }

    ////
    //// ADMIN
    ////

    function recoverToken(address token, uint256 id, uint256 amount) external onlyOwner {
        IBathHouse(token).safeTransferFrom(
            address(this),
            owner(),
            id,
            amount,
            ""
        );
    }

    ////
    //// ERC1155
    ////

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}


// File contracts/casino/Dice.sol




// Access.

// Geisha.

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
contract Dice is Permissions, GeishaCustodian {

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
    uint256 public currentMatchID;

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
        uint256 _playAmount,
        address bathHouse
    ) GeishaCustodian(bathHouse, address(this)) {
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
        uint256 winningSeat = uint256(keccak256(
            abi.encodePacked(
                currentPlayers,
                block.timestamp,
                block.number,
                currentMatchID,
                currentPlayers[4]
            )
        )) % 6;
        address winner = currentPlayers[winningSeat];

        // Store winner.
        winners.push(winner);

        // Transfer winning amount of tokens to winner.
        uint256 winAmount = playAmount * 5;
        uint256 geishaBonus = 0;
        if (custodiedGeishas[winner].hasDeposited) {
            geishaBonus = winAmount / 20;
            winAmount += geishaBonus;
        }

        bugs.transfer(
            winner,
            winAmount
        );

        // Transfer burn amount of tokens to burn address.
        uint256 burnAmount = playAmount - geishaBonus;
        bugs.burn(
            address(this),
            burnAmount
        );

        // Event.
        emit GamePlayed(
            currentMatchID,
            winner
        );

        // Clear bets.
        uint256 length = currentPlayers.length;
        for (uint256 i = 0; i < length; i++) {
            bets[currentPlayers[i]] = 0;
        }

        // Deletes current game's list of players.
        delete currentPlayers;

        // Increment game count.
        currentMatchID++;
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
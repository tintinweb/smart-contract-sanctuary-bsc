/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

//SPDX-License-Identifier: Unlicensed
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

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

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

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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

// Tokens.

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

    ////
    //// MATCH
    ////

    struct Match {
        /// Match ID.
        uint256 id;
        /// Sumo 0's name.
        string name0;
        /// Sumo 1's name.
        string name1;
    }

    /// Current Sumo match ID.
    uint256 public currentMatchID;

    /// Has the current match begun.
    bool public matchStarted;

    ////
    //// PRE-MATCH JOIN
    ////

    /// Joined bettors.
    mapping(address => bool) public seats;
    event SeatTaken(address indexed account);

    /// Invited Geishas.
    mapping(address => bool) public invitedGeisha;
    event GeishaInvited(address indexed account, uint256 indexed id);

    ////
    //// PRE-MATCH BET
    ////

    /// Stores bet details.
    struct Bet {
        /// Address of the bettor.
        address bettor;
        /// ID of the Sumo that was bet on.
        uint256 sumo;
        /// Amount of Bugs bet.
        uint256 betAmount;
    }

    /// Collection of all bets placed.
    /// @dev currentMatchID => account => Bet
    mapping(uint256 => mapping(address => Bet)) public bets;

    /// List of current match's bettors.
    address[] public currentBettors;

    event BetPlaced(address indexed bettor, uint256 sumo, uint256 betAmount);

    ////
    //// POST-MATCH
    ////

    mapping(address => uint256) public claimableBalances;
    event WinningsAvailable(address indexed bettor, uint256 winnings);
    event WinningsClaimed(address indexed bettor, uint256 winnings);

    ////
    //// INIT
    ////

    constructor(address _bugs, address _bathHouse) {
        bugs = IBugs(_bugs);
        bathHouse = IBathHouse(_bathHouse);
    }

    ////
    //// PRE-MATCH JOIN
    ////

    function takeSeat() public {
        address bettor = _msgSender();

        require(!seats[bettor], "User is seated");

        seats[bettor] = true;

        emit SeatTaken(bettor);
    }

    function inviteGeisha(uint256 id) public {
        address bettor = _msgSender();

        require(seats[bettor], "User not seated");
        require(bathHouse.balanceOf(bettor, id) > 0, "Geisha not owned");

        invitedGeisha[bettor] = true;

        emit GeishaInvited(bettor, id);
    }

    ////
    //// PRE-MATCH BET
    ////

    function placeBet(uint256 _sumo, uint256 _betAmount) public {
        address bettor = _msgSender();

        require(seats[bettor], "User not seated");
        require(bets[currentMatchID][bettor].betAmount == 0, "Bet already placed");
        require(_sumo == 0 || _sumo == 1, "Invalid sumo selected");

        bugs.transferFrom(bettor, address(this), _betAmount);

        bets[currentMatchID][bettor] = Bet(bettor, _sumo, _betAmount);
        currentBettors.push(bettor);

        emit BetPlaced(bettor, _sumo, _betAmount);
    }

    ////
    //// MATCH
    ////

    function startMatch() external onlyOwner {
        require(matchStarted == false, "Match already started");

        matchStarted = true;

        uint256 pseudorandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number
        )));
        uint256 winningSumo = pseudorandom % 2;

        uint256 length = currentBettors.length;
        for (uint256 i = 0; i < length; i++) {
            address bettor = currentBettors[i];

            // Pay winnings or burn bet.
            if (bets[currentMatchID][bettor].sumo == winningSumo) {
                uint256 winnings = bets[currentMatchID][bettor].betAmount * 2;
                claimableBalances[bettor] += winnings;
                emit WinningsAvailable(bettor, winnings);
            } else {
                bugs.burn(address(this), bets[currentMatchID][bettor].betAmount);
            }

            // Unseat bettor.
            seats[bettor] = false;

            // Uninvite geisha.
            invitedGeisha[bettor] = false;
        }

        // Clear current bettors list.
        delete currentBettors;
    }

    ////
    //// POST-MATCH
    ////

    function claimWinnings() external {
        address bettor = _msgSender();

        require(claimableBalances[bettor] > 0, "No winnings available.");

        uint256 winnings = claimableBalances[bettor];
        claimableBalances[bettor] = 0;
        bugs.mint(bettor, 0, winnings);

        emit WinningsClaimed(bettor, winnings);
    }

    function endMatch() public onlyOwner {
        require(matchStarted == true, "Match not started");

        currentMatchID += 1;
        matchStarted = false;
    }
}
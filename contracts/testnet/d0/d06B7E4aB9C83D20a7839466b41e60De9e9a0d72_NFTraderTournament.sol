// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTraderTournament is ReentrancyGuard, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    constructor() {

    }

    struct Tournament{
        bool active;
        bool privateTournament;
        string name;
        uint256 startAt;
        uint256 endAt;                        
        mapping(address => Trade) trades;
        address[] traders;
        uint totalTrades;
    }

    struct Trade{
        uint256 tournamentId;
        uint256 openPrice;
        uint256 openAt;
        string asset;
    }

    event TournamentCreated(uint256 itemId, string name, uint256 startAt, uint256 endAt);
    event TradeCreated(address trader, uint256 openPrice, uint256 tournamentId, string asset, uint256 openAt);

    mapping(uint256 => Tournament) private tournaments;

    function addTournament(string memory name, bool active, uint256 startAt, uint256 endAt, bool privateTournament) public onlyOwner{
        require(endAt > startAt, "End must greter than start");
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        Tournament storage tournament = tournaments[itemId];
        tournament.active = active;
        tournament.name = name;
        tournament.startAt = startAt;
        tournament.endAt = endAt;
        tournament.totalTrades = 0;
        tournament.privateTournament = privateTournament;

        emit TournamentCreated(itemId, name, startAt, endAt);
    }

    function addTrade(address trader, uint256 openPrice, string memory asset, uint256 tournamentId) public{
        uint256 openAt = block.timestamp;
        Tournament storage tournament = tournaments[tournamentId];
        if(tournament.privateTournament == true){
            require(owner() == _msgSender(), "Private tournament");
        }

        require(tournament.active == true, "Inactive tournament");
        require(openAt < tournament.endAt, "Closed tournament");
        require(tournament.trades[trader].tournamentId == 0, "Already has a trade");
        
        tournament.trades[trader] = Trade(tournamentId, openPrice, openAt, asset);
        tournament.traders.push(trader);
        tournament.totalTrades += 1;
        emit TradeCreated(trader, openPrice, tournamentId, asset, openAt);
    }

    function setTournamentActive(uint256 tournament, bool value) public onlyOwner{
        tournaments[tournament].active = value;
    }

    function setTournamentEndAt(uint256 tournament, uint256 value) public onlyOwner{
        require(value > tournaments[tournament].startAt, "End must greter than start");
        tournaments[tournament].endAt = value;
    }

    function setTournamentStartAt(uint256 tournament, uint256 value) public onlyOwner{
        require(value < tournaments[tournament].endAt, "End must greter than start");
        tournaments[tournament].startAt = value;
    }

    function setTournamentPrivacy(uint256 tournament, bool value) public onlyOwner{
        tournaments[tournament].privateTournament = value;
    }

    function getTournament(uint tournament) public view returns(bool active, string memory name, uint256 startAt, uint256 endAt, uint totalTrades, bool privateTournament){
        return (tournaments[tournament].active, tournaments[tournament].name, tournaments[tournament].startAt, tournaments[tournament].endAt, tournaments[tournament].totalTrades, tournaments[tournament].privateTournament);
    }

    function getTrade(uint256 tournamentId, address trader) public view returns(Trade memory){
        return tournaments[tournamentId].trades[trader];
    }

    function getTrades(uint256 tournamentId) public view returns(Trade[] memory){
        uint totalTrades = tournaments[tournamentId].totalTrades;
        Trade[] memory trades = new Trade[](totalTrades);

        for(uint i = 0; i < totalTrades; i++){
            trades[i] = tournaments[tournamentId].trades[tournaments[tournamentId].traders[i]];
        }
        return trades;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
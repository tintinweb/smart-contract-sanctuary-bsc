// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ASPOLottery is ReentrancyGuard, Pausable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private lotteryCounter;

    address public ERC20;
    address private beneficiary;
    
    uint256 defaultPrizePool = 10000 ether;
    uint256 defaultTicketPrice = 100 ether;
    uint256 defaultCombinations = 1140;

    uint256 poolIncreaseRate = 0.5 ether;
    uint256 feeRate = 0.1 ether;
    
    uint256 playerLimit = 0;
    uint256 minimumTickets = 10;

    uint256 private randNonce = 0;
    
    mapping(address => bool) private _whitelistedUsers;

    mapping(uint256 => mapping(uint256 => address[])) private _ticketPlayers;
    mapping(uint256 => mapping(address => Player)) private _ticketsOf;

    mapping(uint256 => Lottery) private lotteries;

    struct Lottery {
        uint64 result;
        uint64 combinations;
        uint128 startTime;

        uint256 lotteryId;
        uint256 ticketPrice;
        uint256 prizePool;
        uint256 ticketsCount;

        address[] winners;
    }

    struct Player {
        uint256 count;
        mapping(uint256 => uint256) tickets;
    }

    Lottery private currentLottery;

    constructor(address erc20) {
        ERC20 = erc20;
        beneficiary = _msgSender();

        _whitelistedUsers[_msgSender()] = true;

        lotteryCounter.increment();

        currentLottery = Lottery(
            uint64(defaultCombinations),
            uint64(defaultCombinations),
            uint128(block.timestamp),

            lotteryCounter.current(),
            defaultTicketPrice,
            defaultPrizePool,
            0,

            new address[](0)
        );
    }

    // ===================== EVENTS =======================

    event TicketBought(uint256 indexed idx, address indexed player, uint256[] ticketNumbers);
    event LotteryResult(uint256 indexed idx, uint256 luckyNumber, uint256 prizePool, address[] winners, uint256[] prizes);
    event UserWhitelistChanged(address user, bool allowance);

    // ===================== MODIFIERS ======================

    modifier onlyWhitelistedUser() {
        require(_whitelistedUsers[_msgSender()], "User not allowed");
        _;
    }

    // ===================== FUNCTIONS ======================

    // For user to buy tickets
    function buyTicket(uint256[] memory ticketNumbers) external nonReentrant whenNotPaused {
        require(
            playerLimit == 0 || _getTicketsCount(lotteryCounter.current(), _msgSender()) + ticketNumbers.length <= playerLimit, 
            "Player has exceeded limit of tickets"
        );

        uint256 lotteryId = lotteryCounter.current();
        uint256 ticketPrice = currentLottery.ticketPrice;
        uint256 combinations = currentLottery.combinations;
        
        for (uint256 i = 0; i < ticketNumbers.length; ++i) {
            require(ticketNumbers[i] < combinations, "The input number is invalid");

            if (_getTicketsOf(lotteryId, _msgSender(), ticketNumbers[i]) == 0) {
                _ticketPlayers[lotteryId][ticketNumbers[i]].push(_msgSender());
            }
            _ticketsOf[lotteryId][_msgSender()].tickets[ticketNumbers[i]]++;
        }

        uint256 amount = ticketNumbers.length * ticketPrice;

        IERC20(ERC20).transferFrom(_msgSender(), beneficiary, amount);

        currentLottery.prizePool += amount - amount * feeRate / (1 ether);
        currentLottery.ticketsCount += ticketNumbers.length;

        _ticketsOf[lotteryId][_msgSender()].count += ticketNumbers.length;

        emit TicketBought(lotteryCounter.current(), _msgSender(), ticketNumbers);
    }


    // Draw winning number of a lottery
    // Can be called by whitelisted address only
    function drawLotteryResult() external nonReentrant whenNotPaused onlyWhitelistedUser {
        require(currentLottery.ticketsCount >= minimumTickets, "Number of tickets does not meet minimum requirements");

        lotteryCounter.increment();

        uint256 lotteryId = currentLottery.lotteryId;
        uint256 prizePool = currentLottery.prizePool;

        uint256 result = _random(currentLottery.combinations);
        address[] memory winners = _ticketPlayers[lotteryId][result];
        uint256[] memory prizes = new uint256[](winners.length);

        currentLottery.result = uint64(result);
        currentLottery.winners = winners;

        lotteries[lotteryId] = currentLottery;
        
        // Reward for the winners
        if (winners.length != 0) {
            uint256 totalWinningTickets = 0;
            for (uint256 i = 0; i < winners.length; ++i) {
                totalWinningTickets += _getTicketsOf(lotteryId, winners[i], result);
            }

            uint256 prizePerTicket = prizePool / totalWinningTickets;
            for (uint256 i = 0; i < winners.length; ++i) {
                uint256 prize = _getTicketsOf(lotteryId, winners[i], result) * prizePerTicket;
                IERC20(ERC20).transferFrom(beneficiary, payable(winners[i]), prize);
                prizes[i] = prize;
            }
            
            currentLottery = Lottery(
                uint64(defaultCombinations),
                uint64(defaultCombinations),
                uint128(block.timestamp),
    
                lotteryCounter.current(),
                defaultTicketPrice,
                defaultPrizePool,
                0,
    
                new address[](0)
            );
        } else {
            uint256 feeAmount = currentLottery.ticketsCount * currentLottery.ticketPrice * feeRate / (1 ether);
            uint256 poolIncreaseAmount = feeAmount * poolIncreaseRate / (1 ether);
            currentLottery = Lottery(
                uint64(defaultCombinations),
                uint64(defaultCombinations),
                uint128(block.timestamp),
    
                lotteryCounter.current(),
                defaultTicketPrice,
                prizePool + poolIncreaseAmount,
                0,
    
                new address[](0)
            );
        }

        emit LotteryResult(lotteryId, result, prizePool, winners, prizes);
    }

    // ==============================================================

    function getCurrentLotteryId() external view returns (uint256) {
        return lotteryCounter.current();
    }

    function getCurrentLottery() external view returns (Lottery memory) {
        return currentLottery;
    }
    
    function getLotteryHistoryById(uint256 lotteryId) external view returns (Lottery memory) {
        return lotteries[lotteryId];
    }

    function getTicketPlayers(uint256 lotteryId, uint256 number) external view returns (address[] memory) {
        return _getTicketPlayers(lotteryId, number);
    }

    function _getTicketPlayers(uint256 lotteryId, uint256 number) internal view returns (address[] memory) {
        return _ticketPlayers[lotteryId][number];
    }

    function getTicketsOf(uint256 lotteryId, address player, uint256 number) external view returns (uint256) {
        return _getTicketsOf(lotteryId, player, number);
    }

    function _getTicketsOf(uint256 lotteryId, address player, uint256 number) internal view returns (uint256) {
        return _ticketsOf[lotteryId][player].tickets[number];
    }

    function getTicketsCount(uint256 lotteryId, address player) external view returns (uint256) {
        return _getTicketsCount(lotteryId, player);
    }

    function _getTicketsCount(uint256 lotteryId, address player) internal view returns (uint256) {
        return _ticketsOf[lotteryId][player].count;
    }

    // ====================================

    // feeRate (used to calculate fees)
    function getFeeRate() external view returns (uint256) {
        return feeRate;
    }

    function setFeeRate(uint256 rate) external onlyOwner {
        feeRate = rate;
    }

    // ticketPrice
    function getTicketPrice() external view returns (uint256) {
        return defaultTicketPrice;
    }
    
    function setTicketPrice(uint256 price) external onlyOwner {
        defaultTicketPrice = price;
    }

    // Limit tickets per player
    function getPlayerLimit() external view returns (uint256) {
        return playerLimit;
    }

    function setPlayerLimit(uint256 limit) external onlyOwner {
        playerLimit = limit;
    }

    // Minimum tickets requirement to draw a lottery
    function getMinimumTickets() external view returns (uint256) {
        return minimumTickets;
    }

    function setMinimumTickets(uint256 minimum) external onlyOwner {
        minimumTickets = minimum;
    }

    // Combinations
    function getCombinations() external view returns (uint256) {
        return defaultCombinations;
    }

    function setCombinations(uint256 combinations) external onlyOwner {
        defaultCombinations = combinations;
    }

    // ===============================================================

    function pauseContract() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }

    function setWhitelistedERC20(address erc20) external onlyOwner {
        ERC20 = erc20;
    }

    function setWhitelistedUser(address userAddress, bool allowance) external onlyOwner {
        _whitelistedUsers[userAddress] = allowance;
        emit UserWhitelistChanged(userAddress, allowance);
    }

    function whitelistedUser(address userAddress) external view returns (bool) {
        return (_whitelistedUsers[userAddress]);
    }

    function setBeneficiary(address newBeneficiary) external onlyOwner {
        beneficiary = newBeneficiary;
    }

    function getBeneficiary() external view returns (address) {
        return beneficiary;
    }

    // ===============================================================

    function _random(uint256 n) private returns (uint256) {
        randNonce++;
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.number, 
                    block.difficulty, 
                    block.timestamp, 
                    gasleft(), 
                    randNonce, 
                    _getTicketPlayers(lotteryCounter.current(), randNonce % currentLottery.combinations)
                )
            )
        ) % n;
    }
}

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/*
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
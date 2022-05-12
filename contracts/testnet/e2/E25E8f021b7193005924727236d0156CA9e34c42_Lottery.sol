//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    event TicketsLimitChanged(uint256 prev, uint256 curr);
    event TicketPurchased(address indexed addr, uint256 tokenId);

    address public winner;
    uint256 public ticketPrice;
    uint256 public ticketsLimit;
    uint256 public ticketsSold;

    mapping(uint256 => address) public addrIdTicketId;

    constructor(uint256 ticketPrice_, uint256 ticketsLimit_) Ownable() {
        ticketPrice = ticketPrice_;
        ticketsLimit = ticketsLimit_;

        _assingTicketToAddress(_msgSender());
    }

    function setNewTicketsLimit(uint256 newTicketsLimit) external onlyOwner {
        emit TicketsLimitChanged(ticketsLimit, newTicketsLimit);
        ticketsLimit = newTicketsLimit;
    }

    function _preValidatePurchase(uint256 value) internal view {
        require(
            value >= ticketPrice,
            "Lottery: Not enough funds were transferred"
        );
        require(
            ticketsLimit >= ticketsSold,
            "Lottery: The ticket sales limit has been exceeded"
        );
    }

    function totalReward() public view returns (uint256) {
        return ticketsSold * ticketPrice;
    }

    function _drawWinner() internal {
        if (ticketsLimit == ticketsSold) {
            uint256 winnerId = block.timestamp % ticketsSold;
            winner = addrIdTicketId[winnerId];
        }
    }

    function buyTicket() external payable {
        buyTicketForAddress(_msgSender());
    }

    function withdrawReward() external {
        require(
            _msgSender() == winner,
            "Lottery: only winner might withdraw reward"
        );
        payable(_msgSender()).transfer(totalReward());
    }

    function _forwardFunds() internal {
        payable(address(this)).transfer(ticketPrice);
    }

    function _assingTicketToAddress(address addr) internal {
        addrIdTicketId[ticketsSold] = addr;
        ticketsSold++;
    }

    function buyTicketForAddress(address beneficiary) public payable {
        _preValidatePurchase(msg.value);
        _forwardFunds();

        emit TicketPurchased(beneficiary, ticketsSold);

        _assingTicketToAddress(beneficiary);
        _drawWinner();
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
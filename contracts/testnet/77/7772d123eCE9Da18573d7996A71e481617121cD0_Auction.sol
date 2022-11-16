// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Auction is Ownable {
    struct bidParam {
        address account;
        uint256 amount;
    }

    uint256 public endTime;

    address public highestBidder;

    uint256 public highestBidAmount;

    uint256 public highestBid;

    uint256 public reservePrice;

    mapping(address => uint256) public allBids;

    // function _setReservePrice(uint256 newReservePrice) external onlyOwner {
    //     reservePrice = newReservePrice;
    // }

    // function _setEndTime(uint256 _endTime) external onlyOwner {
    //     endTime = _endTime;
    // }

    function startAuction(uint256 _endTime, uint256 _newReservePrice)
        external
        onlyOwner
    {
        endTime = _endTime;
        reservePrice = _newReservePrice;
    }

    function bid() external payable {
        require(block.timestamp > 0, "Auction not active");
        require(block.timestamp < endTime, "Auction ended");
        require(msg.value > 0, "Invalid amount");
        require(
            msg.value > reservePrice && msg.value > highestBid,
            "Less than highest bid"
        );

        highestBidAmount = msg.value;
        highestBidder = msg.sender;

        allBids[msg.sender] = msg.value;
    }

    function withdraw() external {
        require(block.timestamp > endTime, "Auction ongoing");
        require(msg.sender != highestBidder, "Winner cannot withdraw bid");

        uint256 bidAmount = allBids[msg.sender];
        require(bidAmount > 0, "No bids to withdraw");

        payable(msg.sender).transfer(bidAmount);
    }

    function bidEnded() external view returns (bool ended) {
        ended = block.timestamp > endTime ? true : false;
    }
}
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRoyalty.sol";

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract RoyaltyRegistry is Ownable, IRoyalty {
	struct FeeInfo {
		address receiver;
		uint256 fee;
	}

	mapping(address => FeeInfo) public collectionRoyalty;
	mapping(address => mapping(uint256 => FeeInfo)) public tokenRoyalty;
	uint256 public constant MULTIPLIER = 100000;

	uint256 public maxRoyalty;

	event MaxRoyaltyUpdated(uint256 value);
	event CollectionRoyaltyUpdated(
		address collection,
		address receiver,
		uint256 royalty
	);
	event TokenRoyaltyUpdated(
		address collection,
		uint256 tokenId,
		address receiver,
		uint256 royalty
	);

	constructor() {
		maxRoyalty = 10000; // 10%
	}

	function updateMaxRoyalty(uint256 newValue) external onlyOwner {
		require(newValue <= 100000, "Maximum Royalty is 100%");
		maxRoyalty = newValue;
		emit MaxRoyaltyUpdated(newValue);
	}

	function updateRoyaltyForCollection(
		address collection,
		address receiver,
		uint256 royaltyFee
	) external onlyOwner {
		require(royaltyFee <= maxRoyalty, "Royalty is exceed maximum");

		collectionRoyalty[collection] = FeeInfo(receiver, royaltyFee);
		emit CollectionRoyaltyUpdated(collection, receiver, royaltyFee);
	}

	function updateRoyaltyForToken(
		address collection,
		uint256 tokenId,
		address receiver,
		uint256 royaltyFee
	) external onlyOwner {
		require(royaltyFee <= maxRoyalty, "Royalty is exceed maximum");

		tokenRoyalty[collection][tokenId] = FeeInfo(receiver, royaltyFee);
		emit TokenRoyaltyUpdated(collection, tokenId, receiver, royaltyFee);
	}

	/** @dev
	 * @return The royalty recipient and royalty amount can be receive
	 */
	function royaltyInfo(
		address collection,
		uint256 tokenId,
		uint256 amount
	) external view returns (address, uint256) {
		FeeInfo memory info = tokenRoyalty[collection][tokenId];

		if (info.receiver != address(0)) {
			return (info.receiver, (info.fee * amount) / MULTIPLIER);
		}

		return (
			collectionRoyalty[collection].receiver,
			(collectionRoyalty[collection].fee * amount) / MULTIPLIER
		);
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
pragma solidity ^0.8.13;

interface IRoyalty {
	function royaltyInfo(
		address collection,
		uint256 tokenId,
		uint256 amount
	) external view returns (address, uint256);
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
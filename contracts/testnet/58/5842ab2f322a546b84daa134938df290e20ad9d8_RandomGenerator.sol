// contracts/utils/RandomGenerator.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomGenerator is Ownable {
    // To avoid the possibility to forge a blockhash to be used later, we allways take the hash of a
    // block at least 47 positions before the current one, this is a block from 141 secons ago, after
    // that time, the seed is different and the forged blockhash is useless.
    // It's made modifiable for testing purposes, because EVM only returns a valid hash for last 256 blocks
    // so, increasing the offset beyond that limit, the random generation should fail
    uint256 public blockOffset = 47;
    AggregatorV3Interface internal priceFeed;

    constructor(address _aggregator) {
        priceFeed = AggregatorV3Interface(_aggregator);
    }

    /**
     * @dev Set Block Offset
     */
    function setBlockOffset(uint256 _blockOffset) external onlyOwner {
        blockOffset = _blockOffset;
    }

    /**
     * @dev Set Price Feed
     */
    function setPriceFeed(address _priceFeed) external onlyOwner {
        require(_priceFeed != address(0), "zero address");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * Returns the latest price as external factor
     */
    function getExternalFactor() public view returns (int256) {
        /*
        (uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound)
        */
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // we fail if no price data
        require(price > 0, "no external factor");
        return price;
    }

    /**
     * @dev Generate a pseudo-random number using the given seed to select a block to hash
     */
    function getRandom(uint256 _seed) external view returns (uint256) {
        // We get the block wich hash we will use. It will depend on the provided seed,
        // it will give us a number of blocks to look back to get a hash.

        uint256 blockToHash = block.number - ((_seed % 200) + blockOffset);
        bytes32 blockhashData = blockhash(blockToHash);
        // we fail if no block hash data
        require(blockhashData != 0x0, "no block hash");

        // That hash could be a good random number for our purpose, and hard to predict, but the block
        // could be predicted and a transaction with high gas submitted on the appropiate time so no
        // other will update the counter. That's why we add another hashing with a value externally
        // updated every minute: BTC-USD price from an external Chainlink Oracle

        // With that external factor, it's not possible to determine the better block to calculate the
        // random number. The value changes every minute, so, the deterministic window is only 20 blocks.
        // There is no chance to get the best possible number with only those possibilities, although
        // the better of that could be selected by an attacker, it doesn't really make a difference.

        return uint256(keccak256(abi.encode(getExternalFactor(), blockhashData)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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
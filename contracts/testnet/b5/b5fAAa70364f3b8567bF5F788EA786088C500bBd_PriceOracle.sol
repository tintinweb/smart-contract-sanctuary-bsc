/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// File: ../leveraged/contracts/libraries/Context.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/access/Ownable.sol



pragma solidity ^0.8.10;


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

// File: ../leveraged/contracts/interfaces/IPriceOracle.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a price oracle.
 */
interface IPriceOracle {
    function getPrice(address _asset) external view returns (uint256);
}

// File: ../leveraged/contracts/PriceOracle.sol



pragma solidity ^0.8.10;



interface IPriceFeedAggregator {
  function decimals() external view returns (uint8);

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

/**
 * @title PriceOracle
 * @notice 
 * Implements getting the asset prices from price feed aggregators (chainlink or others)
 */
contract PriceOracle is Ownable, IPriceOracle {
    mapping(address => address) private priceFeeds;

    constructor() { }

    /**
    * @dev sets price feeds for a list of assets
    * @param _assets the addresses of the assets
    * @param _priceFeeds the address of the price feed of each asset
    */
    function setPriceFeeds(address[] calldata _assets, address[] calldata _priceFeeds)
        external
        onlyOwner
    {
        require(_assets.length == _priceFeeds.length, "Arrays of different lengths");

        for (uint256 i = 0; i < _assets.length; i++) {
            require(IPriceFeedAggregator(_priceFeeds[i]).decimals() == 8, "USD decimals not correct"); // allow only USD price feeds
            priceFeeds[_assets[i]] = _priceFeeds[i];
        }
    }

    /**
    * @dev gets an asset price
    * @param _asset the asset address
    * @return the asset price
    */
    function getPrice(address _asset) external view returns (uint256) {
        require(priceFeeds[_asset] != address(0), "Price feed not set");

        (, int256 signedPrice, , , ) = IPriceFeedAggregator(priceFeeds[_asset]).latestRoundData();
        return uint256(signedPrice);
    }

    /**
    * @dev gets the price feed address by an asset address
    * @param _asset the asset address
    * @return the price feed address
    */
    function getPriceFeed(address _asset) external view returns (address) {
        return priceFeeds[_asset];
    }
}
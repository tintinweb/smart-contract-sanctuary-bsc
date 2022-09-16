// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.4;

import "PolybitPriceOracle.sol";
import "Ownable.sol";

/**
 * @title Polybit Price Oracle Factory v0.0.4
 * @author Matt Leeburn
 * @notice An oracle factory to spawn new price oracles for on-chain price referencing.
 */

contract PolybitPriceOracleFactory is Ownable {
    PolybitPriceOracle[] internal oracleArray;
    address[] internal oracleAddressList;
    string public oracleVersion;

    constructor(address _oracleOwner, string memory _oracleVersion) {
        require(address(_oracleOwner) != address(0));
        _transferOwnership(_oracleOwner);
        oracleVersion = _oracleVersion;
    }

    event PriceOracleCreated(string msg, address ref);

    /**
     * @notice Creates a new Oracle and stores the address in the Oracle Factory's list.
     * @dev Only the Oracle Owner can create a new Oracle.
     */
    function createOracle(address tokenAddress) external onlyOwner {
        PolybitPriceOracle Oracle = new PolybitPriceOracle(
            oracleVersion,
            owner(),
            tokenAddress
        );
        oracleArray.push(Oracle);
        oracleAddressList.push(address(Oracle));
        emit PriceOracleCreated("New price oracle created", address(Oracle));
    }

    /**
     * @param index is the index number of the Oracle in the list of oracles.
     * @return oracleAddressList[index] is the Oracle address in the list of oracles.
     */
    function getOracle(uint256 index) external view returns (address) {
        return oracleAddressList[index];
    }

    // Returns an array of Oracle addresses.
    function getListOfOracles() external view returns (address[] memory) {
        return oracleAddressList;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.4;

import "Ownable.sol";

interface ERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);
}

/**
 * @title Polybit Price Oracle v0.0.4
 * @author Matt Leeburn
 * @notice A price oracle for on-chain price referencing. Prices are updated using a
 * combination of on-chain and off-chain sources. Price updates are triggered by the
 * price monitor whenever the price deviates beyond a certain interval.
 * @dev Check the Oracle status to ensure the Oracle is actively being updated. You can
 * also use the lastUpdated timestamp to ensure data is fresh.
 */
contract PolybitPriceOracle is Ownable {
    string public oracleVersion;
    uint256 public oracleStatus;
    address tokenAddress;
    uint256 latestPrice;
    uint256 lastUpdated;

    constructor(
        string memory _oracleVersion,
        address _oracleOwner,
        address _tokenAddress
    ) {
        require(address(_oracleOwner) != address(0));
        require(address(_tokenAddress) != address(0));
        _transferOwnership(_oracleOwner);
        oracleVersion = _oracleVersion;
        tokenAddress = _tokenAddress;
    }

    event TokenPriceChange(
        string msg,
        uint256 priceChangedTo,
        uint256 updatedAt
    );

    /**
     * @notice Used to update the latest price of the token.
     * @param price is the latest price of the token.
     * @dev This function can only be called by the Oracle Owner.
     */
    function setTokenPrice(uint256 price) external onlyOwner {
        latestPrice = price;
        lastUpdated = block.timestamp;
        emit TokenPriceChange("Price updated", latestPrice, lastUpdated);
    }

    /**
     * @notice Used to set the status of the Oracle so the consumer knows
     * if it is actively being updated.
     * @param status should either be set to 0 (inactive) or 1 (active).
     * @dev Functions should revert if oracleStatus != 1.
     */
    function setOracleStatus(uint256 status) external onlyOwner {
        oracleStatus = status;
    }

    /**
     * @return tokenAddress is the address of the token the Price Oracle
     * relates too.
     */
    function getTokenAddress() external view returns (address) {
        return tokenAddress;
    }

    /**
     * @return symbol is the symbol of the token the Price Oracle
     * relates too.
     */
    function getSymbol() external view returns (string memory) {
        string memory symbol = ERC20(tokenAddress).symbol();
        return symbol;
    }

    /**
     * @return decimals is the decimals of the token the Price Oracle
     * relates too.
     */
    function getDecimals() external view returns (uint8) {
        uint8 decimals = ERC20(tokenAddress).decimals();
        return decimals;
    }

    /**
     * @return latestPrice is the decimals of the token the Price Oracle
     * relates too.
     */
    function getLatestPrice() external view returns (uint256) {
        return latestPrice;
    }

    /**
     * @return lastUpdated is a timestamp recorded when the price was
     * last updated.
     */
    function getLastUpdated() external view returns (uint256) {
        return lastUpdated;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
pragma solidity >=0.8.4;

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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.4;

import "PolybitPriceOracle.sol";

/**
 * @title Polybit Price Oracle Factory v0.0.3
 * @author Matt Leeburn
 * @notice An oracle factory to spawn new price oracles for on-chain price referencing.
 */

contract PolybitPriceOracleFactory {
    address public oracleOwner;
    PolybitPriceOracle[] internal oracleArray;
    address[] internal oracleAddressList;
    string public oracleVersion;

    constructor(address _oracleOwner, string memory _oracleVersion) {
        require(address(_oracleOwner) != address(0));
        oracleOwner = _oracleOwner;
        oracleVersion = _oracleVersion;
    }

    modifier onlyOracleOwner() {
        require(msg.sender == oracleOwner);
        _;
    }

    event priceOracleCreated(string msg, address ref);

    /**
     * @notice Creates a new Oracle and stores the address in the Oracle Factory's list.
     * @dev Only the Oracle Owner can create a new Oracle.
     */
    function createOracle(address tokenAddress) external onlyOracleOwner {
        PolybitPriceOracle Oracle = new PolybitPriceOracle(
            oracleVersion,
            oracleOwner,
            tokenAddress
        );
        oracleArray.push(Oracle);
        oracleAddressList.push(address(Oracle));
        emit priceOracleCreated("New price oracle created", address(Oracle));
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

/**
 * @title Polybit Price Oracle v0.0.3
 * @author Matt Leeburn
 * @notice A price oracle for on-chain price referencing. Prices are updated using a
 * combination of on-chain and off-chain sources. Price updates are triggered by the
 * price monitor whenever the price deviates beyond a certain interval.
 * @dev Check the Oracle status to ensure the Oracle is actively being updated. You can
 * also use the lastUpdated timestamp to ensure data is fresh.
 */

interface ERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);
}

contract PolybitPriceOracle {
    string public oracleVersion;
    uint256 public oracleStatus;
    address public oracleOwner;
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

        oracleVersion = _oracleVersion;
        oracleOwner = _oracleOwner;
        tokenAddress = _tokenAddress;
    }

    modifier onlyOracleOwner() {
        require(msg.sender == oracleOwner);
        _;
    }

    event tokenPriceChange(
        string msg,
        uint256 priceChangedTo,
        uint256 updatedAt
    );

    /**
     * @notice Used to update the latest price of the token.
     * @param price is the latest price of the token.
     * @dev This function can only be called by the Oracle Owner.
     */
    function setTokenPrice(uint256 price) external onlyOracleOwner {
        latestPrice = price;
        lastUpdated = block.timestamp;
        emit tokenPriceChange("Price updated", latestPrice, lastUpdated);
    }

    /**
     * @notice Used to set the status of the Oracle so the consumer knows
     * if it is actively being updated.
     * @param status should either be set to 0 (inactive) or 1 (active).
     * @dev Functions should revert if oracleStatus != 1.
     */
    function setOracleStatus(uint256 status) external onlyOracleOwner {
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
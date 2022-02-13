// contracts/LandPresale.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./SafeMath.sol";
import "./CustomSafeMath.sol";
import "./Whitelistable.sol";
import "./Presaleable.sol";

contract ShipPresale is Presaleable, Pausable {
	using SafeMath for uint256;
	using SafeMath16 for uint16;
	using SafeMath8 for uint8;

	uint8 public constant TYPE_SMALL = 1;
	uint8 public constant TYPE_MEDIUM = 2;
	uint8 public constant TYPE_LARGE = 3;
	uint8 public constant TYPE_STATION = 4;

	uint256 public constant PRICE_SMALL = 120000000000000000; // 0.12 BNB
	uint256 public constant PRICE_MEDIUM = 400000000000000000; // 0.4 BNB
	uint256 public constant PRICE_LARGE = 800000000000000000; // 0.8 BNB
	uint256 public constant PRICE_STATION = 2500000000000000000; // 2.5 BNB

	uint16 public constant MAX_TOTAL_SALES_SMALL = 1400;
	uint16 public constant MAX_TOTAL_SALES_MEDIUM = 1200;
	uint16 public constant MAX_TOTAL_SALES_LARGE = 630;
	uint16 public constant MAX_TOTAL_SALES_STATION = 50;

	uint8 public constant MAX_TOTAL_GIVEAWAY_SMALL = 10;
	uint8 public constant MAX_TOTAL_GIVEAWAY_MEDIUM = 5;
	uint8 public constant MAX_TOTAL_GIVEAWAY_LARGE = 2;
	uint8 public constant MAX_TOTAL_GIVEAWAY_STATION = 0;

	constructor() {
		// Setting up timestamp and max purchases
		PRESALE_START_TIMESTAMP = 1644426750;
		PRESALE_END_TIMESTAMP = 1647453600;
		MAX_PURCHASES_PER_WALLET = 5;

		// Setting valid types
		validTypes[TYPE_SMALL] = true;
		validTypes[TYPE_MEDIUM] = true;
		validTypes[TYPE_LARGE] = true;
		validTypes[TYPE_STATION] = true;

		// Setting initial prices
		prices[TYPE_SMALL] = PRICE_SMALL;
		prices[TYPE_MEDIUM] = PRICE_MEDIUM;
		prices[TYPE_LARGE] = PRICE_LARGE;
		prices[TYPE_STATION] = PRICE_STATION;

		// Setting max total sales
		maxTotalSales[TYPE_SMALL] = MAX_TOTAL_SALES_SMALL;
		maxTotalSales[TYPE_MEDIUM] = MAX_TOTAL_SALES_MEDIUM;
		maxTotalSales[TYPE_LARGE] = MAX_TOTAL_SALES_LARGE;
		maxTotalSales[TYPE_STATION] = MAX_TOTAL_SALES_STATION;

		// Setting max total giveaways
		maxTotalGiveaways[TYPE_SMALL] = MAX_TOTAL_GIVEAWAY_SMALL;
		maxTotalGiveaways[TYPE_MEDIUM] = MAX_TOTAL_GIVEAWAY_MEDIUM;
		maxTotalGiveaways[TYPE_LARGE] = MAX_TOTAL_GIVEAWAY_LARGE;
		maxTotalGiveaways[TYPE_STATION] = MAX_TOTAL_GIVEAWAY_STATION;
	}

	/**
	 * @dev Buys lands of given _type
	 */
	function buyShips(uint8 _type)
		external
		payable
		onlyWhitelisted
		onlyDuringPresale
		whenNotPaused
		onlyValidType(_type)
	{
		_buy(_type);
	}

	/**
	 * @dev Giveaway ships of given _type to given list of _addresses
	 */
	function giveawayShips(address[] calldata _addresses, uint8 _type)
		external
		onlyOwner
		onlyDuringPresale
		whenNotPaused
		onlyValidType(_type)
	{
		_giveaway(_addresses, _type);
	}

	/**
	 * @dev Redeems lands of given _type of the given _buyer
	 */
	function redeemShips(
		address _buyer,
		uint8 _type
	) external onlyRedemptionAddress whenNotPaused onlyValidType(_type) {
		_redeem(_buyer, _type);
	}

	/**
	 * @dev Get the number of NFTs purchased by an address _buyer
	 */
	function getTotalPurchasedByAddress(address _buyer)
		public
		view
		returns (uint16)
	{
		uint16 totalPurchased = 0;

		totalPurchased = totalPurchased
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_SMALL))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_MEDIUM))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_LARGE))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_STATION));

		return totalPurchased;
	}

  /**
	 * @dev Get the prices in a bulk request
	 */
	function getPricesList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory pricesList = new uint256[](4);

    pricesList[0] = prices[TYPE_SMALL];
    pricesList[1] = prices[TYPE_MEDIUM];
    pricesList[2] = prices[TYPE_LARGE];
    pricesList[3] = prices[TYPE_STATION];

    return pricesList;
	}

  /**
	 * @dev Get the maxTotalSales in a bulk request
	 */
	function getMaxSalesList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory maxSalesList = new uint256[](4);

    maxSalesList[0] = maxTotalSales[TYPE_SMALL];
    maxSalesList[1] = maxTotalSales[TYPE_MEDIUM];
    maxSalesList[2] = maxTotalSales[TYPE_LARGE];
    maxSalesList[3] = maxTotalSales[TYPE_STATION];

    return maxSalesList;
	}

  /**
	 * @dev Get the totalSold in a bulk request
	 */
	function getTotalSoldList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory totalSoldList = new uint256[](4);

    totalSoldList[0] = totalSoldByType[TYPE_SMALL];
    totalSoldList[1] = totalSoldByType[TYPE_MEDIUM];
    totalSoldList[2] = totalSoldByType[TYPE_LARGE];
    totalSoldList[3] = totalSoldByType[TYPE_STATION];

    return totalSoldList;
	}

  /**
	 * @dev Get the inventory in a bulk request
	 */
	function getInventoryList()
		public
		view
		returns (uint16[] memory)
	{
    uint16[] memory inventoryList = new uint16[](4);

    inventoryList[0] = buyers[msg.sender][TYPE_SMALL];
    inventoryList[1] = buyers[msg.sender][TYPE_MEDIUM];
    inventoryList[2] = buyers[msg.sender][TYPE_LARGE];
    inventoryList[3] = buyers[msg.sender][TYPE_STATION];

    return inventoryList;
	}
}
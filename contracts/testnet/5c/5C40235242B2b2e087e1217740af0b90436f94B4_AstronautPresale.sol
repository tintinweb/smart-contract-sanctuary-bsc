// contracts/LandPresale.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./SafeMath.sol";
import "./CustomSafeMath.sol";
import "./Whitelistable.sol";
import "./Presaleable.sol";

contract AstronautPresale is Presaleable, Pausable {
	using SafeMath for uint256;
	using SafeMath16 for uint16;
	using SafeMath8 for uint8;

	uint8 public constant TYPE_SINGLE = 6;
	uint8 public constant TYPE_TWOPACK = 7;
	uint8 public constant TYPE_FIVEPACK = 8;
	uint8 public constant TYPE_BUNDLE = 9;

	uint256 public constant PRICE_SINGLE = 18000000000000000; // 0.018 BNB
	uint256 public constant PRICE_TWOPACK = 30000000000000000; // 0.03 BNB
	uint256 public constant PRICE_FIVEPACK = 80000000000000000; // 0.08 BNB
	uint256 public constant PRICE_STATION = 150000000000000000; // 0.15 BNB

	uint16 public constant MAX_TOTAL_SALES_SINGLE = 700;
	uint16 public constant MAX_TOTAL_SALES_TWOPACK = 1400;
	uint16 public constant MAX_TOTAL_SALES_FIVEPACK = 1500;
	uint16 public constant MAX_TOTAL_SALES_BUNDLE = 700;

	uint8 public constant MAX_TOTAL_GIVEAWAY_SINGLE = 15;
	uint8 public constant MAX_TOTAL_GIVEAWAY_TWOPACK = 7;
	uint8 public constant MAX_TOTAL_GIVEAWAY_FIVEPACK = 4;
	uint8 public constant MAX_TOTAL_GIVEAWAY_BUNDLE = 2;

	constructor() {
		// Setting up timestamp and max purchases
		PRESALE_START_TIMESTAMP = 1644426750;
		PRESALE_END_TIMESTAMP = 1647453600;
		MAX_PURCHASES_PER_WALLET = 7;

		// Setting valid types
		validTypes[TYPE_SINGLE] = true;
		validTypes[TYPE_TWOPACK] = true;
		validTypes[TYPE_FIVEPACK] = true;
		validTypes[TYPE_BUNDLE] = true;

		// Setting initial prices
		prices[TYPE_SINGLE] = PRICE_SINGLE;
		prices[TYPE_TWOPACK] = PRICE_TWOPACK;
		prices[TYPE_FIVEPACK] = PRICE_FIVEPACK;
		prices[TYPE_BUNDLE] = PRICE_STATION;

		// Setting max total sales
		maxTotalSales[TYPE_SINGLE] = MAX_TOTAL_SALES_SINGLE;
		maxTotalSales[TYPE_TWOPACK] = MAX_TOTAL_SALES_TWOPACK;
		maxTotalSales[TYPE_FIVEPACK] = MAX_TOTAL_SALES_FIVEPACK;
		maxTotalSales[TYPE_BUNDLE] = MAX_TOTAL_SALES_BUNDLE;

		// Setting max total giveaways
		maxTotalGiveaways[TYPE_SINGLE] = MAX_TOTAL_GIVEAWAY_SINGLE;
		maxTotalGiveaways[TYPE_TWOPACK] = MAX_TOTAL_GIVEAWAY_TWOPACK;
		maxTotalGiveaways[TYPE_FIVEPACK] = MAX_TOTAL_GIVEAWAY_FIVEPACK;
		maxTotalGiveaways[TYPE_BUNDLE] = MAX_TOTAL_GIVEAWAY_BUNDLE;
	}

	/**
	 * @dev Buys lands of given _type
	 */
	function buyAstronaut(uint8 _type)
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
	function giveawayAstronauts(address[] calldata _addresses, uint8 _type)
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
	function redeemAstronauts(
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
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_SINGLE))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_TWOPACK))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_FIVEPACK))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_BUNDLE));

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

    pricesList[0] = prices[TYPE_SINGLE];
    pricesList[1] = prices[TYPE_TWOPACK];
    pricesList[2] = prices[TYPE_FIVEPACK];
    pricesList[3] = prices[TYPE_BUNDLE];

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

    maxSalesList[0] = maxTotalSales[TYPE_SINGLE];
    maxSalesList[1] = maxTotalSales[TYPE_TWOPACK];
    maxSalesList[2] = maxTotalSales[TYPE_FIVEPACK];
    maxSalesList[3] = maxTotalSales[TYPE_BUNDLE];

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

    totalSoldList[0] = totalSoldByType[TYPE_SINGLE];
    totalSoldList[1] = totalSoldByType[TYPE_TWOPACK];
    totalSoldList[2] = totalSoldByType[TYPE_FIVEPACK];
    totalSoldList[3] = totalSoldByType[TYPE_BUNDLE];

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

    inventoryList[0] = buyers[msg.sender][TYPE_SINGLE];
    inventoryList[1] = buyers[msg.sender][TYPE_TWOPACK];
    inventoryList[2] = buyers[msg.sender][TYPE_FIVEPACK];
    inventoryList[3] = buyers[msg.sender][TYPE_BUNDLE];

    return inventoryList;
	}
}
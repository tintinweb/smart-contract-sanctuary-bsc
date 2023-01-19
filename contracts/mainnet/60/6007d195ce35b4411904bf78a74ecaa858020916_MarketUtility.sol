/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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

interface IWOLFPACKRewardManager {
    function notifyReward(address rewardee, bool predictionQualified, bool liquidityQualified, bool managementQualified) external;
}

interface IWOLFPACKStakingManager {
    function notifyReward(uint256 received) external;
}

/// @title MarketUtility
/// @author LONEWOLF
///
/// Utility contract for WolfyStreetBets Prediction Markets.
///
/// Executes price based decision making for market results.
/// Stores & returns market-dependent variables. 
/// Serves as an interface to markets for governed upgrades.

contract MarketUtility is Ownable {

    address WPACKRewardManager;
    address WPACKStakingManager;
    address marketLiquidity;

    uint256 settlementPeriod;
    uint256 public predictionQualifier;
    uint256 mrtDivisor;

    constructor(
        address _WPACKRewardManager, 
        address _WPACKStakingManager, 
        address _marketLiquidity,
        uint256 _settlementPeriod,
        uint256 _predictionQualifier,
        uint256 _mrtDivisor
        ) 
    {
        WPACKRewardManager = _WPACKRewardManager;
        WPACKStakingManager = _WPACKStakingManager;
        marketLiquidity = _marketLiquidity;
        settlementPeriod = _settlementPeriod;
        predictionQualifier = _predictionQualifier;
        mrtDivisor = _mrtDivisor;
    }
    
    // in case of governance change
    function upgradeWolfpackRewardManager(address _WPACKRewardManager) external onlyOwner {
        WPACKRewardManager = _WPACKRewardManager;
    }
    // in case of governance change
    function upgradeWolfpackStakingManager(address _WPACKStakingManager) external onlyOwner {
        WPACKStakingManager = _WPACKStakingManager;
    }
     // in case of governance change
    function upgradeMarketLiquidity(address _marketLiquidity) external onlyOwner {
        marketLiquidity = _marketLiquidity;
    }
    // in case of governance change
    function upgradePredictionQualifier(uint256 _predictionQualifier) external onlyOwner {
        predictionQualifier = _predictionQualifier;
    }
    // in case of governance change
    function upgradeSettlementPeriod(uint256 _settlementPeriod) external onlyOwner {
        settlementPeriod = _settlementPeriod;
    }
    // in case of governance change
    function upgradeMrtDivisor(uint256 _mrtDivisor) external onlyOwner {
        mrtDivisor = _mrtDivisor;
    }
    
    function getBasicMarketData() public view returns (uint256 settlePeriod, uint256 prdQualifier, uint256 minRewThreshold, address wpackRewContract, address wpackStakingContract, address marketLiquidityAddr) {
        return (settlementPeriod, predictionQualifier, mrtDivisor, WPACKRewardManager, WPACKStakingManager, marketLiquidity);
    }

    // get latest answer pair
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) public view returns (uint256 option0LatestPriceUSD, uint256 option1LatestPriceUSD) {
        int256 price0;
        int256 price1;
        (, price0 , , ,) = (AggregatorV3Interface(_feedAddress0).latestRoundData());
        (, price1 , , ,) = (AggregatorV3Interface(_feedAddress1).latestRoundData());
        return (uint256(price0), uint256(price1));
    }

    function calculateMarketWinnerOraclized (
        uint256 option0InitPrice, 
        address option0Feed, 
        uint256 option1InitPrice, 
        address option1Feed
    )   public 
        view 
        returns (
            bool option, 
            uint256 settlementPrice0, 
            uint256 settlementPrice1
        ) 
    {
        bool wOption;
        (uint256 option0SettlementPrice, uint256 option1SettlementPrice) =  getChainLinkLatestPricesUSD(option0Feed, option1Feed);
        // both new prices have increased since init
        if (option0SettlementPrice > option0InitPrice && option1SettlementPrice > option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0InitPrice, option0SettlementPrice);
            uint256 asset1PercChange = _getPercentageChange(option1InitPrice, option1SettlementPrice);
            if (asset0PercChange > asset1PercChange) {
                wOption = true; // asset0 win
            }  else if (asset1PercChange > asset0PercChange) {
                wOption = false; // asset1 win
            }
        } else if (option0SettlementPrice > option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            wOption = true; // asset0 auto win
        } else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice > option1InitPrice) {
            wOption = false; // asset1 auto win
        } else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0SettlementPrice, option0InitPrice);
            uint256 asset1PercChange = _getPercentageChange(option1SettlementPrice, option1InitPrice);
            // lower % decrease wins
            if (asset0PercChange < asset1PercChange) {
                wOption = true;
            } else if (asset1PercChange < asset0PercChange) {
                wOption = false;
            }
        }        
        return (
            wOption, 
            option0SettlementPrice, 
            option1SettlementPrice
        );
    }

    // internal function to get percentage change between 2 values
    function _getPercentageChange(uint256 value0, uint256 value1) internal pure returns (uint256) {
        return ((value1 - value0) * 100) / value0;
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
    Utility functions for timeboxed markets:
        - oracle price calls
        - winner calculation
        - common marketData
    Controls all timeboxed markets to keep all running/settling in parallel && their external variables like Staking contracts:
        - marketStatus
        - marketGracePeriods
        - marketInitializationTimestamps
        - marketSettlementTimestamps

    Users will call restart/settle on this contract 
    Market.sol contract will call this contract to get/check data like marketStatus, gracePeriods etc for validation steps
 */

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

// interface UniswapOracle
//

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier validAddress(address addr) {


    require(addr != address(0), "Address cannot be 0x0");
    require(addr != address(this), "Address cannot be contract address");
    _;
    }
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   
    function transferOwnership(address newOwner) public virtual onlyOwner validAddress(newOwner) {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IWOLFPACKRewardManager {
    function synchronizeRewardNotification(address rewardee, bool predictionQualified, bool liquidityQualified) external;
}

interface IWOLFPACKStakingManager {
    function synchronizeRewardNotification(uint256 received) external;
}

// Market Utility
contract WOLFYMarketUtility is Ownable {

    address WPACKRewardManagerAddr = payable(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);
    address WPACKStakingManagerAddr = payable(0x3ab04182A5D80A73DA3Ac9D91483E72892bFF969);
    address operator = payable(0x3ab04182A5D80A73DA3Ac9D91483E72892bFF969);

    uint256 settlementPeriod = 1 hours;
    uint256 predictionQualifier =  1000 * 10**18; // 1000 BUSD
    uint256 liquidityQualifier = 1000 * 10**18; // 1000 BUSD
    uint256 mrtDivisor = 5;
    
    // in case of governance change
    function upgradeWolfpackRewardManager(address _WPACKRewardManagerAddr) external onlyOwner {
        WPACKRewardManagerAddr = _WPACKRewardManagerAddr;
    }
    // in case of governance change
    function upgradeWolfpackStakingManager(address _WPACKStakingManagerAddr) external onlyOwner {
        WPACKStakingManagerAddr = _WPACKStakingManagerAddr;
    }
    // in case of governance change -> transition to DAO (elected multisig)
    function upgradeOperator(address _operator) external onlyOwner {
        operator = _operator;
    }
    // in case of governance change
    function upgradePredictionQualifier(uint256 _predictionQualifier) external onlyOwner {
        predictionQualifier = _predictionQualifier;
    }
    // in case of governance change
    function upgradeLiquidityQualifier(uint256 _liquidityQualifier) external onlyOwner {
        liquidityQualifier = _liquidityQualifier;
    }
    // in case of governance change
    function upgradeSettlementPeriod(uint256 _settlementPeriod) external onlyOwner {
        settlementPeriod = _settlementPeriod;
    }
    // in case of governance change
    function upgradeMrtDivisor(uint256 _mrtDivisor) external onlyOwner {
        mrtDivisor = _mrtDivisor;
    }
    
    function getBasicMarketData() public view returns (uint256 settlePeriod, uint256 prdQualifier, uint256 liqQualifier, uint256 minRewThreshold, address wpackRewContract, address wpackStakingContract, address _oper) {
        return (settlementPeriod, predictionQualifier, liquidityQualifier, mrtDivisor, WPACKRewardManagerAddr, WPACKStakingManagerAddr, operator);
    }

    // get latest answer pair
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) public view returns (uint256 option0LatestPriceUSD, uint256 option1LatestPriceUSD) {
        int256 price0;
        int256 price1;
        (, price0 , , ,) = (AggregatorV3Interface(_feedAddress0).latestRoundData());
        (, price1 , , ,) = (AggregatorV3Interface(_feedAddress1).latestRoundData());
        return (uint256(price0), uint256(price1));
    }

    // get latest answer single - for hybrid markets
    function getChainLinkLatestPriceUSD(address _feedAddress) public view returns (uint256 latestPriceUSD) {
        int256 price0;
        (, price0 , , ,) = (AggregatorV3Interface(_feedAddress).latestRoundData());
        return uint256(price0);
    }

    function calculateMarketWinnerOraclized (uint256 option0InitPrice, address option0Feed, uint256 option1InitPrice, address option1Feed) public view returns (bool option, uint256 settlementPrice0, uint256 settlementPrice1) {
        (uint256 option0SettlementPrice, uint256 option1SettlementPrice) =  getChainLinkLatestPricesUSD(option0Feed, option1Feed);
        // both new prices have increased since init
        if (option0SettlementPrice > option0InitPrice && option1SettlementPrice > option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0InitPrice, option0SettlementPrice);
            uint256 asset1PercChange = _getPercentageChange(option1InitPrice, option1SettlementPrice);
            // asset0 win
            if (asset0PercChange > asset1PercChange) {
                return (true, option0SettlementPrice, option1SettlementPrice);
            }
            // asset1 win
            else if (asset1PercChange > asset0PercChange) {
                return (false, option0SettlementPrice, option1SettlementPrice);
            }
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (option0SettlementPrice > option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            // asset0 auto wins
            return (true, option0SettlementPrice, option1SettlementPrice);
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice > option1InitPrice) {
            // asset1 auto wins
            return (false, option0SettlementPrice, option1SettlementPrice);
        }
        else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0SettlementPrice, option0InitPrice);
            uint256 asset1PercChange = _getPercentageChange(option1SettlementPrice, option1InitPrice);
            // lower % decrease wins
            if (asset0PercChange < asset1PercChange) {
                return (true, option0SettlementPrice, option1SettlementPrice);
            }
            else if (asset1PercChange < asset0PercChange) {
                return (false, option0SettlementPrice, option1SettlementPrice);
            }
        }
    }

    function calulateMarketWinnerParameterized(uint256 option0InitPrice, uint256 option1InitPrice, uint256 option0SettlementPrice, uint256 option1SettlementPrice) public pure returns (bool option) {
        // both new prices have increased since init
        if (option0SettlementPrice > option0InitPrice && option1SettlementPrice > option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0InitPrice, option0SettlementPrice);
            uint256 asset1PercChange = _getPercentageChange(option1InitPrice, option1SettlementPrice);
            // asset0 win
            if (asset0PercChange > asset1PercChange) {
                return true;
            }
            // asset1 win
            else if (asset1PercChange > asset0PercChange) {
                return false;
            }
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (option0SettlementPrice > option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            // asset0 auto wins
            return true;
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice > option1InitPrice) {
            // asset1 auto wins
            return false;
        }
        else if (option0SettlementPrice <= option0InitPrice && option1SettlementPrice <= option1InitPrice) {
            uint256 asset0PercChange = _getPercentageChange(option0SettlementPrice, option0InitPrice);
            uint256 asset1PercChange = _getPercentageChange(option1SettlementPrice, option1InitPrice);
            // lower % decrease wins
            if (asset0PercChange < asset1PercChange) {
                return true;
            }
            else if (asset1PercChange < asset0PercChange) {
                return false;
            }
        }
    }

    function calculateMarketWinnerHybrid(uint256 optionFeedInitPrice, address optionFeed, uint256 optionParamInitPrice, uint256 optionParamSettlementPrice) public view returns (bool option) {
        uint256 optionFeedSettlementPrice = getChainLinkLatestPriceUSD(optionFeed);
        // both new prices have increased since init
        if (optionFeedSettlementPrice > optionFeedInitPrice && optionParamSettlementPrice > optionParamInitPrice) {
            uint256 asset0PercChange = _getPercentageChange(optionFeedInitPrice, optionFeedSettlementPrice);
            uint256 asset1PercChange = _getPercentageChange(optionParamInitPrice, optionParamSettlementPrice);
            // asset0 win
            if (asset0PercChange > asset1PercChange) {
                return true;
            }
            // asset1 win
            else if (asset1PercChange > asset0PercChange) {
                return false;
            }
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (optionFeedSettlementPrice > optionFeedInitPrice && optionParamSettlementPrice <= optionParamInitPrice) {
            // asset0 auto wins
            return true;
        }
        // 0 has increased but 1 has decreased/stayed the same
        else if (optionFeedSettlementPrice <= optionFeedInitPrice && optionParamSettlementPrice > optionParamInitPrice) {
            // asset1 auto wins
            return false;
        }
        else if (optionFeedSettlementPrice <= optionFeedInitPrice && optionParamSettlementPrice <= optionParamInitPrice) {
            uint256 asset0PercChange = _getPercentageChange(optionFeedSettlementPrice, optionFeedInitPrice);
            uint256 asset1PercChange = _getPercentageChange(optionParamSettlementPrice, optionParamInitPrice);
            // lower % decrease wins
            if (asset0PercChange < asset1PercChange) {
                return true;
            }
            else if (asset1PercChange < asset0PercChange) {
                return false;
            }
        }
    } 

    // internal function to get percentage change between 2 values
    function _getPercentageChange(uint256 value1, uint256 value2) internal pure returns (uint256 percentageChange) {
        return ((value2 - value1) * 100) / value1;
    }

}
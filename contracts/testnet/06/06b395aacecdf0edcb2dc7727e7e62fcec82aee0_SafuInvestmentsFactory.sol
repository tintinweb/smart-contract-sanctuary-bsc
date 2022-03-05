// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./SafuInvestmentsPresale.sol";
import "./SafuInvestmentsInfo.sol";

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract SafuInvestmentsFactory {
    using SafeMath for uint256;

    event PresaleCreated(bytes32 title, uint256 safuId, address creator);

    IPancakeFactory private constant PancakeFactory =
    IPancakeFactory(address(0x6725F303b657a9451d8BA641348b6761A6CC7a17));
    address private constant wbnbAddress = address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F);


    SafuInvestmentsInfo public immutable SAFU;
    address public owner;

    constructor(address _safuInfoAddress) public {
        SAFU = SafuInvestmentsInfo(_safuInfoAddress);
        owner = msg.sender;
    }

    struct PresaleInfo {
        address tokenAddress;
        address unsoldTokensDumpAddress;
        address[] whitelistedAddresses;
        uint256 tokenPriceInWei;
        uint256 hardCapInWei;
        uint256 softCapInWei;
        uint256 maxInvestInWei;
        uint256 minInvestInWei;
        uint256 openTime;
        uint256 closeTime;
    }

    struct PresaleUniswapInfo {
        uint256 listingPriceInWei;
        uint256 liquidityAddingTime;
        uint256 lpTokensLockDurationInDays;
        uint256 liquidityPercentageAllocation;
    }

    struct PresaleStringInfo {
        bytes32 saleTitle;
        bytes32 linkTelegram;
        bytes32 linkDiscord;
        bytes32 linkTwitter;
        bytes32 linkWebsite;
    }


    function initializePresale(
        SafuInvestmentsPresale _presale,
        uint256 _totalTokens,
        uint256 _finalTokenPriceInWei,
        PresaleInfo calldata _info,
        PresaleUniswapInfo calldata _uniInfo,
        PresaleStringInfo calldata _stringInfo
    ) internal {
        _presale.setAddressInfo(msg.sender, _info.tokenAddress, _info.unsoldTokensDumpAddress);
        _presale.setGeneralInfo(
            _totalTokens,
            _finalTokenPriceInWei,
            _info.hardCapInWei,
            _info.softCapInWei,
            _info.maxInvestInWei,
            _info.minInvestInWei,
            _info.openTime,
            _info.closeTime
        );
        _presale.setUniswapInfo(
            _uniInfo.listingPriceInWei,
            _uniInfo.liquidityAddingTime,
            _uniInfo.lpTokensLockDurationInDays,
            _uniInfo.liquidityPercentageAllocation
        );
        _presale.setStringInfo(
            _stringInfo.saleTitle,
            _stringInfo.linkTelegram,
            _stringInfo.linkDiscord,
            _stringInfo.linkTwitter,
            _stringInfo.linkWebsite
        );

        _presale.addwhitelistedAddresses(_info.whitelistedAddresses);
    }

    function createPresale(PresaleInfo calldata _info, 
        PresaleUniswapInfo calldata _uniInfo,
        PresaleStringInfo calldata _stringInfo) external {
        IERC20 token = IERC20(_info.tokenAddress);

        SafuInvestmentsPresale presale = new SafuInvestmentsPresale(address(this), owner);

        address existingPairAddress = PancakeFactory.getPair(address(token), wbnbAddress);
        require(existingPairAddress == address(0)); // token should not be listed in Uniswap

        uint256 maxEthPoolTokenAmount = _info.hardCapInWei.mul(100).div(100);
        uint256 maxLiqPoolTokenAmount = maxEthPoolTokenAmount.mul(1e18).div(40000000);

        uint256 maxTokensToBeSold = _info.hardCapInWei.mul(1e18).div(_info.tokenPriceInWei);
        uint256 requiredTokenAmount = maxLiqPoolTokenAmount.add(maxTokensToBeSold);
        // token.transferFrom(msg.sender, address(presale), requiredTokenAmount);

        initializePresale(presale, maxTokensToBeSold, _info.tokenPriceInWei, _info, _uniInfo, _stringInfo);

        

        uint256 safuId = SAFU.addPresaleAddress(address(presale));

        emit PresaleCreated(_stringInfo.saleTitle, safuId, msg.sender);
    }
}
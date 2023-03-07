/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

struct AuctionInfo {
    address id;
    address auctionToken;
    address payToken;
    bool finalized;
    uint64 finalizeTime;
    uint64 vestingDuration;
    uint64 startTime;
    uint64 endTime;
    uint128 startPrice;
    uint128 minimumPrice;
    uint128 priceFunction;
    uint128 clearingPrice;
    uint128 totalTokens;
    uint128 commitmentsTotal;
    bool auctionEnded;
    bool auctionSuccessful;
}

interface IDutchAuctionFactory {
    function totalAuctions() external view returns (uint256);
    function auctions(uint256 index) external view returns (address);
}

interface IDutchAuction {
    function auctionToken() external view returns (address);
    function payToken() external view returns (address);
    function finalized() external view returns (bool);
    function finalizeTime() external view returns (uint64);
    function vestingDuration() external view returns (uint64);
    function totalTokens() external view returns (uint128);
    function startTime() external view returns (uint64);
    function endTime() external view returns (uint64);
    function startPrice() external view returns (uint128);
    function minimumPrice() external view returns (uint128);
    function priceFunction() external view returns (uint128);
    function clearingPrice() external view returns (uint128);
    function commitmentsTotal() external view returns (uint128);
    function auctionEnded() external view returns (bool);
    function auctionSuccessful() external view returns (bool);
}

contract DutchAuctionLens {
    function getAuctions(IDutchAuctionFactory _auctionFactory)
        public
        view
        returns (address[] memory auctions, uint256 totalAuctions)
    {
        totalAuctions = _auctionFactory.totalAuctions();
        if (totalAuctions > 0) {
            auctions = new address[](totalAuctions);
            for (uint256 i = 0; i < totalAuctions;) {
                address auctionAddress = _auctionFactory.auctions(i);
                auctions[i] = auctionAddress;
                unchecked {
                    ++i;
                }
            }
        }
    }

    function getAuctionInfo(
        address _auctionFactory,
        IDutchAuction _dutchAuction
    )
        public
        view
        returns (AuctionInfo memory)
    {
        AuctionInfo memory info;
        info.id = _auctionFactory;
        info.auctionToken = _dutchAuction.auctionToken();
        info.payToken = _dutchAuction.payToken();
        info.finalized = _dutchAuction.finalized();
        info.finalizeTime = _dutchAuction.finalizeTime();
        info.vestingDuration = _dutchAuction.vestingDuration();
        info.startTime = _dutchAuction.startTime();
        info.endTime = _dutchAuction.endTime();
        info.startPrice = _dutchAuction.startPrice();
        info.minimumPrice = _dutchAuction.minimumPrice();
        info.priceFunction = _dutchAuction.priceFunction();
        info.clearingPrice = _dutchAuction.clearingPrice();
        info.totalTokens = _dutchAuction.totalTokens();
        info.commitmentsTotal = _dutchAuction.commitmentsTotal();
        info.auctionEnded = _dutchAuction.auctionEnded();
        info.auctionSuccessful = _dutchAuction.auctionSuccessful();
        return info;
    }

    function getAuctionInfos(
        IDutchAuctionFactory _auctionFactory,
        uint256 _skip,
        uint256 _take
    )
        external
        view
        returns (AuctionInfo[] memory auctionInfos)
    {
        (address[] memory auctions, uint256 totalAuctions) =
            getAuctions(_auctionFactory);
        _skip = _skip < totalAuctions ? _skip : totalAuctions;
        _take = _skip + _take > totalAuctions ? totalAuctions - _skip : _take;
        auctionInfos = new AuctionInfo[](_take);
        for (uint256 i = 0; i < _take; i++) {
            AuctionInfo memory dutchAuction = getAuctionInfo(
                address(_auctionFactory), IDutchAuction(auctions[_skip + i])
            );
            auctionInfos[i] = dutchAuction;
        }
    }
}
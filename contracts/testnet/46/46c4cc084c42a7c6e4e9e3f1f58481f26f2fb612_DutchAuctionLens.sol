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
    uint128 totalTokens;
    uint64 startTime;
    uint64 endTime;
    uint128 startPrice;
    uint128 minimumPrice;
    uint128 commitmentsTotal;
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
    function commitmentsTotal() external view returns (uint128);
}

contract DutchAuctionLens {
    function getAuctions(IDutchAuctionFactory _auctionFactory)
        public
        view
        returns (address[] memory, uint256)
    {
        uint256 totalAuctions = _auctionFactory.totalAuctions();
        address[] memory auctions = new address[](totalAuctions);
        for (uint256 i = totalAuctions; i > 0; i--) {
            auctions[i] = _auctionFactory.auctions(i);
        }
        return (auctions, totalAuctions);
    }

    function getAuctionInfo(address _factory, IDutchAuction _dutchAuction)
        public
        view
        returns (AuctionInfo memory)
    {
        AuctionInfo memory info;
        info.id = _factory;
        info.auctionToken = _dutchAuction.auctionToken();
        info.payToken = _dutchAuction.payToken();
        info.finalized = _dutchAuction.finalized();
        info.finalizeTime = _dutchAuction.finalizeTime();
        info.vestingDuration = _dutchAuction.vestingDuration();
        info.totalTokens = _dutchAuction.totalTokens();
        info.startTime = _dutchAuction.startTime();
        info.endTime = _dutchAuction.endTime();
        info.startPrice = _dutchAuction.startPrice();
        info.minimumPrice = _dutchAuction.minimumPrice();
        info.commitmentsTotal = _dutchAuction.commitmentsTotal();
        return info;
    }

    function getAuctionInfos(
        IDutchAuctionFactory _auctionFactory,
        uint256 _skip,
        uint256 _take
    )
        external
        view
        returns (AuctionInfo[] memory)
    {
        (address[] memory auctions, uint256 totalAuctions) =
            getAuctions(_auctionFactory);
        _skip = _skip < totalAuctions ? _skip : totalAuctions;
        _take = _skip + _take > totalAuctions ? totalAuctions - _skip : _take;
        AuctionInfo[] memory auctionInfos = new AuctionInfo[](_take);
        for (uint256 i = 0; i < _take; i++) {
            AuctionInfo memory dutchAuction =
                getAuctionInfo(address(_auctionFactory), IDutchAuction(auctions[i]));
            auctionInfos[i] = dutchAuction;
        }
        return auctionInfos;
    }
}
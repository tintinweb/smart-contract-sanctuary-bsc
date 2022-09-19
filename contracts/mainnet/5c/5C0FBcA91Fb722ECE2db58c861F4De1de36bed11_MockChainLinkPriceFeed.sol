/**
 * @author Musket
 */
pragma solidity ^0.8.9;

contract MockChainLinkPriceFeed {
    mapping(bytes32 => uint256) public priceFeeds;

    function getTwapPrice(bytes32 _priceFeedKey, uint256 _interval)
        external
        view
        returns (uint256)
    {
        return priceFeeds[_priceFeedKey];
    }

    function setMockTwap(uint256 mock, bytes32 _priceFeed) public {
        priceFeeds[_priceFeed] = mock;
    }
}
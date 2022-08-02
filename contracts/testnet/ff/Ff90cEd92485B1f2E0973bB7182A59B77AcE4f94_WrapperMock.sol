pragma solidity ^0.8.0;

contract WrapperMock {
    uint256[] tokens = [500, 501, 502, 503, 504];

    function getTotalItemsInSet() external view returns (uint256) {
        return tokens.length;
    }

    function getTokenByIndex(uint32 index) external view returns (uint256) {
        return tokens[index];
    }
}
pragma solidity ^0.8.0;

contract WrapperMock {
    uint256[] tokens = [500,501,502,503,504];

    function getAllTokens() external view returns (uint256[] memory) {
        return tokens;
    }
}
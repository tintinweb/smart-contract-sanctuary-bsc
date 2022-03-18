pragma solidity ^0.5.0;

library Hasher {

    function linkId(bytes32 collateralAssetCode, bytes32 peggedCurrency) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(collateralAssetCode, peggedCurrency));
    }

    function lockedReserveId(address from, bytes32 collateralAssetCode, uint256 collateralAmount, uint blockNumber) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, collateralAssetCode, collateralAmount, blockNumber));
    }

    function stableCreditId(string memory assetCode) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(assetCode));
    }
}
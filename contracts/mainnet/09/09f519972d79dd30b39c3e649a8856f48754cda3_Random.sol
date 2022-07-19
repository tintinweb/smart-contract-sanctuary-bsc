/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

// This is the main building block for smart contracts.
contract Random {
    constructor() {}

    function pickNumber(uint256 blockNum, uint256 max)
        external
        view
        returns (uint256)
    {
        if (blockNum < block.number - 256)
            revert(
                "up to 256 previous blocks can be viewed based on the current block"
            );
        if (blockNum > block.number) revert("block number should be smaller");

        bytes32 blockHash = blockhash(blockNum);
        uint256 randNumber = uint256(keccak256(abi.encodePacked(blockHash))) %
            max;

        return randNumber;
    }

    function checkNumber(bytes32 blockHash, uint256 max)
        external
        pure
        returns (uint256)
    {
        uint256 randNumber = uint256(keccak256(abi.encodePacked(blockHash))) %
            max;

        return randNumber;
    }
}
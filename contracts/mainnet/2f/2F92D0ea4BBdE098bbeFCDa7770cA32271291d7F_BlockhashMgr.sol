// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./IBlockhashMgr.sol";

contract BlockhashMgr is IBlockhashMgr, SafeOwnable {
    
    mapping(uint256 => bytes32) public blockInfo;

    uint256 public preBlockNum = block.number;

    mapping(address => bool) public isCaller;

    function setCaller(address sender, bool enable) public onlyOwner {
        isCaller[sender] = enable;
    }

    function request() external {
        require(blockInfo[preBlockNum] == 0);
        blockInfo[preBlockNum] = blockhash(preBlockNum);
    }

    function isRequest() public view returns (bool) {
        return
            (blockInfo[preBlockNum] == 0) && (preBlockNum + 200 < block.number);
    }

    function request(uint256 blockNumber) external override {
        require(isCaller[msg.sender], "only caller");
        require(blockNumber >= block.number && blockNumber < block.number + 2);
        if (blockNumber != preBlockNum && blockInfo[preBlockNum] == 0) {
            if (block.number - preBlockNum > 256) {
                blockInfo[preBlockNum] = keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        blockNumber,
                        block.timestamp,
                        block.number,
                        preBlockNum
                    )
                );
            } else {
                blockInfo[preBlockNum] = blockhash(preBlockNum);
            }
        }
        preBlockNum = blockNumber;
    }

    function getBlockhash(uint256 blockNumber)
        external
        override
        returns (bytes32)
    {
        require(isCaller[msg.sender], "only caller");
        require(block.number >= blockNumber);

        if (blockInfo[blockNumber] == 0) {
            if (block.number - blockNumber > 256) {
                blockInfo[blockNumber] = keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        blockNumber,
                        block.timestamp,
                        block.number,
                        preBlockNum
                    )
                );
            } else {
                blockInfo[blockNumber] = blockhash(blockNumber);
            }
            preBlockNum = blockNumber;
        }

        return blockInfo[blockNumber];
    }
}
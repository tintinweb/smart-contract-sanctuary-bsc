/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-10
*/

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @title Multicall - Aggregate results from multiple read-only function calls
/// @author Michael Elliot <[email protected]>
/// @author Joshua Levine <[email protected]>
/// @author Nick Johnson <[email protected]>
interface IERC20 {

  function allowance(address, address) external view returns (uint256);
}

contract Multicall {
    struct Call {
        address target;
        bytes callData;
        uint256 gastouse;
        
    }
receive() external payable{}

function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData,uint256 balanceETH,uint256 gasUsed) {
        uint256 startGas = gasleft();
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        bytes memory ris = hex"00";
        for(uint256 i = 0; i < calls.length; i++) {
           //address addr = 0x0F3E5FAbAF97997Dc0aBeb691fc2Ca4ee1F92d41;
           //uint256 bal =   getEthBalance(addr);
         
            uint256[2] memory values;
            values[1] = IERC20(0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5).allowance(address(this), calls[i].target);
            
          
            (bool success, bytes memory ret) = calls[i].target.call{gas: calls[i].gastouse}(calls[i].callData);
            
            if (!success){
                ret = ris;
            }
            returnData[i] = ret;
            balanceETH = address(this).balance;
            gasUsed = startGas - gasleft();


        }
    }
    // Helper functions
    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }
    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }
    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }
    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }
    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
}
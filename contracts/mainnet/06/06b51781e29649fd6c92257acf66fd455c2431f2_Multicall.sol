/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

interface IERC20 {
    function approve(address spender, uint tokens) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);

    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);

}

contract Multicall {
    function multicall(address[] calldata targets, bytes[] calldata data) external view returns (bytes[] memory) {
        require(targets.length == data.length);
        bytes[] memory res = new bytes[](data.length);

        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call error");
            res[i] = result;
        }
        return res;
    }

    function aggregate(address[] memory contractAddr, address[] memory targetAddr) public view returns (uint[] memory returnData) {
        returnData = new uint[](contractAddr.length);
        for(uint i = 0; i < contractAddr.length; i++) {
            uint amount = IERC20(contractAddr[i]).balanceOf(targetAddr[i]);
            returnData[i] = amount;
        }
    }

    function tokenContent(address tokenAddr) public view returns (string[] memory) {
        string memory _nmae = IERC20(tokenAddr).name();
        string memory _symbol = IERC20(tokenAddr).symbol();
        
        string[] memory  TokenContent = new string[](2);
        TokenContent[0] = _nmae;
	    TokenContent[1] = _symbol;
        return TokenContent;


    }

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
/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {
    //uint256 x = 1234444;
    

    function genRand() public view returns (uint256) {
        return uint256(uint256(keccak256(abi.encode(block.timestamp, block.difficulty, 0))) % 1000);
    }

    function myGenRand(uint256 timestamp) public view returns (uint256) {
        return uint256(uint256(keccak256(abi.encode(timestamp, 2, 0))) % 1000);
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getDifficulty() public view returns (uint256) {
        return block.difficulty;
    }


}
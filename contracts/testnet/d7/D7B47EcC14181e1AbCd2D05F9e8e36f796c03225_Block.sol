/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

pragma solidity ^0.8.0;

contract Block{

    function getBlock() public view returns(uint256){
        return block.number;
    }
}
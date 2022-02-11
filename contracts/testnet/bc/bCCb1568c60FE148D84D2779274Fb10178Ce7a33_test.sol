/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

pragma solidity 0.8.6;

contract test{
    event Get(address add,uint256 balance);
    
    function write( address ad, uint256 nu) external {
        emit Get(ad,nu);
    }
}
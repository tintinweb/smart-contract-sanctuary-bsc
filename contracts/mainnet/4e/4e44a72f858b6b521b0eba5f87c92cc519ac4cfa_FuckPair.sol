/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IBEP20 {
  function decimals() external view returns (uint8);
}
contract FuckPair {

    function pairInfo(address pairAddress) public view returns (
        address token0,
        address token1,
        uint8 decimals0,
        uint8 decimals1,
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
        ){
        token0 = IPancakePair(pairAddress).token0();
        token1 = IPancakePair(pairAddress).token0();
        (reserve0, reserve1, blockTimestampLast) = IPancakePair(pairAddress).getReserves();
        decimals0 = IBEP20(token0).decimals();
        decimals1 = IBEP20(token1).decimals();
    }

    function getReserves(address[] memory pairAddresses) public view returns (uint112[] memory reserve0s, uint112[] memory reserve1s, uint32[] memory blockTimestampLasts){
        uint256 len = pairAddresses.length;
        reserve0s = new uint112[](len);
        reserve1s = new uint112[](len);
        blockTimestampLasts = new uint32[](len);
        for(uint256 i = 0; i < len; i++){
            (reserve0s[i], reserve1s[i], blockTimestampLasts[i]) = IPancakePair(pairAddresses[i]).getReserves();
        }
    }

}
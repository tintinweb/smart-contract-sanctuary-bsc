//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Test  {
    
    
    address private Cake_LP = 0x8e63afD8B448839FAE657712005f0B2419009109;


    function getReserves1() public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
        return IPancakePair(Cake_LP).getReserves();
    }

}
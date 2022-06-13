//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0()  external view returns (address);

    function token1()  external view returns (address);
}

contract Test  {
    
    
    address private Cake_LP = 0x8e63afD8B448839FAE657712005f0B2419009109;


    function getReserves() public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLas) {
        return IPancakePair(Cake_LP).getReserves();
    }

    function getToken0() public view returns(address) {
        return IPancakePair(Cake_LP).token0();
    }

    function getToken1() public view returns(address) {
        return IPancakePair(Cake_LP).token1();
    }


}
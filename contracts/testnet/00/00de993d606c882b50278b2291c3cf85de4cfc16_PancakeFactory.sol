/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: None

pragma solidity ^0.8.0;


contract PancakeUtil {

    function getTokenPrice (address _token, address _poolCurrency) public view returns (uint112, uint112, uint8) {
        PancakeFactory _pcsFactoryContract = PancakeFactory(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc); // 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        address _nullAddress = 0x0000000000000000000000000000000000000000;
        address _pairAddress = _pcsFactoryContract.getPair(_token, _poolCurrency);
        if (_pairAddress == _nullAddress) {
            return (0, 0, 0);
        }
        PancakePair _pancakePair = PancakePair(_pairAddress);
        (uint112 _reserve0, uint112 _reserve1, ) = _pancakePair.getReserves();
        address _reserve0Address = _pancakePair.token0();
        uint112 _tokenReserves;
        uint112 _poolReserves;
        if (_reserve0Address == _token) {
            _tokenReserves = _reserve0;
            _poolReserves = _reserve1;
        } else {
            _tokenReserves = _reserve1;
            _poolReserves = _reserve0;
        }
        uint8 _decimals = Token(_token).decimals();
        return (_poolReserves, _tokenReserves, _decimals);
    }
}

contract PancakeFactory {
    
    function getPair(address tokenA, address tokenB) external view returns (address pair) {}
}

contract PancakePair {

    function token0() external view returns (address) {}

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {}

}

contract Token {

    function decimals() external view returns (uint8) {}

}
pragma solidity ^0.8.0;

import "./IPancakeSwap.sol";

contract Test {
    IPancakeSwap pancakeContract = IPancakeSwap(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    address bnbWrapAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address _token = 0x21Ee1d8c0cA84cF0244d1f663348cB9c3dd3f250;

    constructor() {}

    function test1() external view returns (uint[] memory) {
        address[] memory tokens;
        tokens[0] = bnbWrapAddress;
        tokens[1] = _token;
        return pancakeContract.getAmountsOut(1000000000000000000, tokens);
    }

    function test2() external view returns (uint) {
        address[] memory tokens;
        tokens[0] = bnbWrapAddress;
        tokens[1] = _token;
        return pancakeContract.getAmountsOut(1000000000000000000, tokens)[0];
    }

    function test3() external view returns (uint) {
        address[] memory tokens;
        tokens[0] = bnbWrapAddress;
        tokens[1] = _token;
        return pancakeContract.getAmountsOut(1000000000000000000, tokens)[1];
    }
}

pragma solidity ^0.8.0;

interface IPancakeSwap {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
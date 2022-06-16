/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

/// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function discount() external view returns (uint256);
}

contract PriceTracker {

    address public MetalShiba = 0x5A88DE4d715a0655b3f662e86D0c18eba81faa3e;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public WBNB_MetalShiba = 0xBabbeCFeF47A2A52816bB1F06A0989ad108093cf;
    uint256 private constant _precision = 1e36;
    IBEP20  public tracked_token;

    constructor() {
        tracked_token = IBEP20(MetalShiba);
    }

    function getprice_MetalShiba_withdiscount(uint256 amount) external view returns (uint256) {
        uint256 price_withdiscount = getprice_MetalShiba() * (100 + tracked_token.discount()) / (100);
        return(price_withdiscount * amount / _precision);
    }

    function getprice_MetalShiba() public view returns (uint256) {
        uint256 _tokenLiquidity = tracked_token.balanceOf(WBNB_MetalShiba);
        uint256 _WBNBLiquidity = IBEP20(WBNB).balanceOf(WBNB_MetalShiba);
        return(_tokenLiquidity * _precision / _WBNBLiquidity);
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract BnbPrice {

    address wbnbAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address busdAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address busdlpcake = 0xe0e92035077c39594793e61802a350347c320cf2;

    function getBnbPrice() public view returns(uint256)
    {
        uint256 wbnbBal = IERC20(wbnbAddress).balanceOf(busdlpcake);
        uint256 busdBal = IERC20(busdAddress).balanceOf(busdlpcake);
        uint256 bnbPriceInBusd = (busdBal*1000000000000000000)/wbnbBal;
        return bnbPriceInBusd;
    }

}
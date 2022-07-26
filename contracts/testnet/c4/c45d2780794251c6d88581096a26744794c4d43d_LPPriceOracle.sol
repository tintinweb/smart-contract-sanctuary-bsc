/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;


contract LPPriceOracle {
    function priceOf(address token) public view returns (uint256) {
      // everything is $1.00
      return 10**18;
    }

    function priceOfLPInFarm(address LP, address farm) public view returns (uint256) {
      // everything in farm is $2.00
      return 2 * 10**18;
    }

    function priceOfLP(address LP) public view returns (uint256) {
      // everything in lp is $3.00
      return 3 * 10**18;
    }

}
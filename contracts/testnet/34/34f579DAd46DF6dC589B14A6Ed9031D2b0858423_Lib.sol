//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


library Lib {
    function test(uint256 aa, uint256[] storage haha)
        external
    {
       haha.push(aa);
    }

}
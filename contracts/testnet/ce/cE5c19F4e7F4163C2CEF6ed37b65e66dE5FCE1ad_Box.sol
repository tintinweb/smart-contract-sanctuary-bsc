// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


/*
proxy --> implementation
  ^
  |
  |
proxy admin
*/
contract Box {
    uint public val;
    // constructor(uint _val) {
    //     val = _val;
    // }

    function initialize(uint _val1) external {
        val = _val1;
        //console.log("init value is = %s" ,val);
    }

    function inc() external {
        val += 1;
        //console.log(" increamented value is = %s" ,val);
    }
}
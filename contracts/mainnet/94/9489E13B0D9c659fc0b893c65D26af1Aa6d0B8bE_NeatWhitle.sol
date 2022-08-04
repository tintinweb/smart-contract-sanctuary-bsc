/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface IneatLike {
    function excludeFromFees(address account, bool excluded) external;
    function isExcludedFromFees(address account)  external view returns(bool);
}

contract NeatWhitle{

        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

    IneatLike Neat = IneatLike(0xbC2Cf7500a4c44E5e67020069418584971F5Ce0D);

    constructor(){
        wards[msg.sender] = 1;
    }

    function addwhile(address[] memory usr) public auth{
        uint n = usr.length;
        for(uint i=0;i<n;i++) {
            address _usr = usr[i];
            if (!Neat.isExcludedFromFees(_usr)) Neat.excludeFromFees(_usr,true);
        }
    }
    function removewhile(address[] memory usr) public auth{
        uint n = usr.length;
        for(uint i=0;i<n;i++) {
            address _usr = usr[i];
            if (Neat.isExcludedFromFees(_usr)) Neat.excludeFromFees(_usr,false);
        }
    }
}
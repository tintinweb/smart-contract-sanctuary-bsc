/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface SimuLike {
    function prip(address,uint,uint) external;
}
contract Edaofrogaz  {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Edaofrogaz/not-authorized");
        _;
    }

    SimuLike public simu = SimuLike(0x0F3239CE365Dd5aA35647039E1f1591f4C62670f);
    uint256 locktime = 15552000;

    constructor()  {
        wards[msg.sender] = 1;
    }
    function autotransfer(address[] memory usr, uint256 wad) public auth{
        uint n = usr.length;
        for (uint i = 0;i<n;++i) {
            simu.prip(usr[i],wad,locktime);
        }
    }
    function autotransfers(address[] memory usr, uint256[] memory wad) public auth{
        require(usr.length == wad.length ,"Edaofrogaz/Address and quantity do not match");
        uint n = usr.length;
        for (uint i = 0;i<n;++i) {
            simu.prip(usr[i],wad[i],locktime);
        }
    }
 }
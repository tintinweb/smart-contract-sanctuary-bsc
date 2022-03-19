/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function approve(address,uint) external;
}
contract Vault  {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Vault/not-authorized");
        _;
    }
    constructor(){
        wards[msg.sender] = 1;
    }

     function approve(address _asset,address _lpfarm, uint256 _wad) public auth{
        TokenLike(_asset).approve(_lpfarm,_wad);
    }
 }
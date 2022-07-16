/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function approve(address,uint) external;
    function transfer(address,uint) external;
}
interface LPExchequerLike {
    function harve(address lp, address usr) external returns (uint256,uint256);
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

    address public eatLP = 0x6b4C62743cD28E8e611E2182707c1cdd8043D14B;
    LPExchequerLike public lpExchequer = LPExchequerLike(0x6b427dC110098d25B9b7495610c0c6694304251C);

    constructor(){
        wards[msg.sender] = 1;
    }
    function withdraw(address asses,uint256 wad, address usr)public auth {
        TokenLike(asses).transfer(usr, wad);
    }
    function approve(address asset,address usr, uint256 wad) public auth{
        TokenLike(asset).approve(usr,wad);
    }
    function harve() public {
        lpExchequer.harve(eatLP, address(this));
    }
 }
/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface IERC20 {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}

contract GazDonate{

        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

    uint256 rate = 7*1E17;
    uint256 max = 100*1E18;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public gaz = 0xCE5C72a775A3e4D032Fbb08C66c8BdfA9A5d216F;
    mapping (address => uint256) public donated;

    constructor(){
        wards[msg.sender] = 1;
    }

    function donate(uint256 amount) public{
        donated[msg.sender] += amount;
        require(donated[msg.sender] <= max , "1");
        IERC20(usdt).transferFrom(msg.sender,address(this),amount);
        uint256 gazAmount = amount*1E18/rate;
        IERC20(gaz).transfer(msg.sender,gazAmount);
    }
    function withdraw(address asset,address usr,uint256 wad) public auth {
        IERC20(asset).transfer(usr,wad);    
    }
    function setRate(uint256 newRate) public auth {
        rate = newRate;    
    }
    function setMax(uint256 newmax) public auth {
        max = newmax;    
    }
 }
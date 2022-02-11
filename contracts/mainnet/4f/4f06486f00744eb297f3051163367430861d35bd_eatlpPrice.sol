/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity >=0.6.12;

contract eatlpPrice {

    // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Medal/not-authorized");
        _;
    }
       uint256 public price;
    constructor(){
        wards[msg.sender] = 1;
        live = 1;
    }

    function file(uint256 data) external auth {
        price = data;
    }  
 }
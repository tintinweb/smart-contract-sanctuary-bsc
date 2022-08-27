/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external; 
}
interface BlinLike {
    function  setVip(address usr, uint8 _vip) external;
}
contract LvVIP {

    // --- Auth ---
    uint256 public live = 1;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BlindBox/not-authorized");
        _;
    }

    BlinLike        public blindbox = BlinLike(0xAeC9463c471a62aCEC3c4602c00bc8818Df25132);

    constructor(){
        wards[msg.sender] = 1;
    }

    function setVip(address usr, uint8 _vip) public auth{
        blindbox.setVip(usr, _vip);
    }
    function setVip2(address[] memory usr, uint8 _vip) public auth{
        uint256 n = usr.length;
        for(uint i=0;i<n;++i) {
            address ust = usr[i];
            blindbox.setVip(ust, _vip);
        }
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }
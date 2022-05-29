/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface Token {
    function balanceOf(address) external view returns (uint256);
    function approve(address,uint256) external;
    function transfer(address,uint256) external;
    function contributor(address) external view returns(bool);
}
interface RouterV2 {
    function swapExactTokensForTokens(uint256,uint256,address[] memory,address,uint256) external returns(uint256[] memory);
}
contract fist {
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "fist/not-authorized");
        _;
    }

    address public edao = 0x52cdE26A58240419EC679483075B6870bE070ef0;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public routerV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] public path = [usdt,edao];
    uint256 public startTime = 100000;
    Token   public tq = Token(0xC7b750695c30cf1CFb7FDf564Aeae689510Efc56);
    // gaibian
    address public user = 0x795f1c3F043D4b6cfBde0530bf3b7DcEc260EBEB; //***************

    constructor(){
        wards[msg.sender] = 1;
        // Token(usdt).approve(address(routerV2), ~uint256(0));
    }
    function setStartTime(uint256 _time) external auth {
        if (_time == 0) startTime = block.timestamp;
        else startTime = _time;
    }
    function setUser(address _user) external auth {
        user = _user;
    }
    function withdraw(address asses,uint256 wad, address usr) public auth {
        Token(asses).transfer(usr, wad);
    }
    function autoDeal() public{
        uint256 usdtamount = Token(usdt).balanceOf(address(this));
        if (block.timestamp > startTime && usdtamount > 0 && tq.contributor(user))   
            RouterV2(routerV2).swapExactTokensForTokens(usdtamount, 0, path, user, block.timestamp);
    }
    function getDeal() public view returns (uint256){
        uint256 usdtamount = Token(usdt).balanceOf(address(this));
        if (block.timestamp > startTime && usdtamount > 0 && tq.contributor(user)) return 1;
        else return 0;
    }

}
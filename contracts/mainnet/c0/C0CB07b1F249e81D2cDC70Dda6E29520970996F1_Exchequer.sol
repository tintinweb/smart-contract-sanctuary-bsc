/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
interface JLCLike {
    function withdraw(uint256) external;
    function getUserForAmount(address) external view returns (uint256);
}

contract Exchequer {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Exchequer/not-authorized");
        _;
    }

    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    JLCLike jlcJoin = JLCLike(0xE757E67e4c77a1925b4Cfb7eB44E15d80713a7DF);
    mapping (address =>mapping (address => uint)) public rate;
    mapping (address =>address[]) public reaper;
    mapping (address => uint) public total;

    constructor() {
        wards[msg.sender] = 1;
    }

    function setReaper(address token, address usr) public auth{
        reaper[token].push(usr);
    }

    function setRate(address token, address usr, uint256 _rate) public auth {
        rate[token][usr] = _rate;
    }

    function harve(address token) public{
        uint256 wad = TokenLike(token).balanceOf(address(this));
        total[token] += wad;
        if(wad == 0) return;
        uint length = reaper[token].length;
        for(uint i=0; i<length;++i){
            address usr = reaper[token][i];
            uint256 rat = rate[token][usr];
            if(rat > 0) {
              if(i==length-1) TokenLike(token).transfer(usr,TokenLike(token).balanceOf(address(this)));
              else TokenLike(token).transfer(usr,wad*rat/10000);
            }
        }
    }
    function withdraw() public{
        uint wad = jlcJoin.getUserForAmount(address(this));
        if(wad > 0) jlcJoin.withdraw(wad);
    }
    function harveForUsdt() public{
        withdraw();
        harve(usdt);
    }
    function getbeharve() view public returns(uint){
        uint wad = jlcJoin.getUserForAmount(address(this));
        uint wad1 = TokenLike(usdt).balanceOf(address(this));
        return (wad+wad1);
    }
 }
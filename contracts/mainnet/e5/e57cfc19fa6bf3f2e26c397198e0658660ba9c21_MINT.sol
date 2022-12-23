/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface TokenLike {
    function approve(address,uint) external;
    function transfer(address,uint) external;
    function mint(address,uint) external;
}
contract MINT  {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "MINT/not-authorized");
        _;
    }
    mapping (address => uint) public runner;
    mapping (address => uint) public number;

    constructor() {
        wards[msg.sender] = 1;
    }
    function setrunner(address _runner, uint256 _wad) public auth {
        runner[_runner] = _wad;
    }

    function mint(address _usr) public {
        require(runner[msg.sender] > number[msg.sender], "Vault/low-authorized");
        number[msg.sender] +=1;
        TokenLike(0xBC54C6Bfd4350F5a119304048f3b6777049A3bbf).mint(_usr,1E18);
    }
 }
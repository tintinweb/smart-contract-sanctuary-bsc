/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface TokenLike {
    function approve(address,uint) external;
    function transfer(address,uint) external;
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
    mapping (address => mapping (address => uint)) public runner;

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Vault: subtraction overflow");
    }

    constructor() {
        wards[msg.sender] = 1;
    }
    function setrunner(address _asset,address _runner, uint256 _wad) public auth {
        runner[_asset][_runner] = _wad;
    }

    function approve(address _asset,address _contract, uint256 _wad) public auth {
        TokenLike(_asset).approve(_contract,_wad);
    }
    function transfer(address _asset,address _usr, uint256 _wad) public {
        require(runner[_asset][msg.sender] >= _wad, "Vault/low-authorized");
        runner[_asset][msg.sender] = sub(runner[_asset][msg.sender],_wad);
        TokenLike(_asset).transfer(_usr,_wad);
    }
 }
/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// Current Version of solidity
pragma solidity ^0.8.7;

contract DaraToken {
    mapping (address => uint256) private _balances;
    function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

}
// Main coin information
contract DaraProxy {
    DaraToken daraToken;
    // Transfers
    event Signature(address indexed from, string sigText, uint256 balance);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        daraToken = DaraToken(0xB9209b547fd051D9b9717dA386f2eD6113561468);
    }
    
    function signature(string memory value) external returns (bool) {
        emit Signature(msg.sender, value, daraToken.balanceOf(msg.sender));
        return true;
    }
}
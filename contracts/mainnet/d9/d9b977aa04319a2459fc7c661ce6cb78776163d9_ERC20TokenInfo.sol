/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC20Token {
    
    function name() external view returns (string memory);
    
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);    
}

contract ERC20TokenInfo {
    
    function getTokenInfo(address tokenAddress) public view returns(string memory, string memory, uint256) {
        ERC20Token token = ERC20Token(tokenAddress);
        return (token.name(), token.symbol(), token.decimals());
    }

}
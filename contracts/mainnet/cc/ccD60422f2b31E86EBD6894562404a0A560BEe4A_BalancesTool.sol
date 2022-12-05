/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

pragma solidity ^0.8.15;

interface IToken {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function decimals() external view returns (uint8);
}

contract BalancesTool {
    constructor() {}

    function getBalances(address[] memory addresses)
        public
        view
        returns (uint256[] memory balances)
    {
        balances = new uint256[](addresses.length);
        for (uint8 i; i < addresses.length; i++) {
            balances[i] = addresses[i].balance;
        }
    }

    function getTokenBalances(address[] memory addresses, address _token)
        public
        view
        returns (uint256[] memory balances)
    {
        IToken token = IToken(_token);

        balances = new uint256[](addresses.length);
        for (uint8 i; i < addresses.length; i++) {
            balances[i] = token.balanceOf(addresses[i]);
        }
    }

    
}
/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >=0.6.12;

interface Token{
    function balanceOf(address) external view returns (uint);
    function totalSupply() external view returns (uint);
}
contract eatlpPrice {
       address public lp = 0xdB0B640C3e7169b22bb60f05856950c497e9d777;
       address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    function price()public view returns (uint256){
        uint256 total = Token(lp).totalSupply();
        uint256 balance = Token(usdt).balanceOf(lp);
        return balance*1e18/total;
    }  
 }
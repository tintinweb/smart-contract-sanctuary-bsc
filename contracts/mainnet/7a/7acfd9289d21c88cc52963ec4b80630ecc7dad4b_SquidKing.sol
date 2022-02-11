/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

//https://t.me/SquidKingPortal

pragma solidity >=0.4.16 <0.9.0;
 
contract SquidKing {
   
    string name;
    string private _name = "Squid King";
    string private _symbol = "SquidKing";
    uint8 private _decimals = 9;
   
   
    function set(string memory x) public {
        name = x;
    }
   
    function get() public view returns (string memory) {
        return name;
    }
   
}
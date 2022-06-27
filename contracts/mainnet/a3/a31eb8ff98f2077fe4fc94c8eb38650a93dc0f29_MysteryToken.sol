/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

/**
Mystery Launch Coming Soon!

Join Crayaks Call Channel to get the CA first!

https://t.me/CallsByCrayak

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;


interface IBEP20 {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}
contract MysteryToken is IBEP20 {
    string private constant _name = 'Mystery Token';
    string private constant _symbol = 'ALPHA';

    constructor() {}

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}

}
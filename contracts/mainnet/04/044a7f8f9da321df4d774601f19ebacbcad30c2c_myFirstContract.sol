/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: NONE

pragma solidity ^0.8.0;

contract myFirstContract {
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function returnAccount(address account) public view virtual returns (address) {
      return account;
    }
    
    function helloWorld(string memory password) public view virtual returns (string memory){
        string memory _password = "Svea <3";
        if ( keccak256(abi.encodePacked((_password))) == keccak256(abi.encodePacked((password)))){
            return "Hello, World!";
        }else{
            return "No love left in this world for me";
        }
    }

}
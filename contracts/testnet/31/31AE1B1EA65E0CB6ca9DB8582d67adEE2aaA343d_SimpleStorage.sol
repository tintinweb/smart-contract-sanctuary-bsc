/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract SimpleStorage {
    uint256 public favoriteNumber = 5;
    bool favoriteBool = false;
    string favoriteString = "String";
    int256 public favoriteInt = -5;
    bytes32 favoriteBytes = "cat";

    struct People{
        uint256 favoriteNumber;
        string name;
    }

    People[] public people;

    mapping(string => uint256) public nameToFavoriteNumber;

    function agregarpersona(string memory _name, uint256 _favoriteNumber) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    function store(uint256 _favoriteNumber) public{

        favoriteNumber = _favoriteNumber;
    }

    function negativo(int _negativonumberr) public{

        favoriteInt = _negativonumberr;
    }

    function buleano(bool _nuevoValor) public{
        favoriteBool = _nuevoValor;
    }

    function buleano2() public view returns(bool){
        return favoriteBool;
    }
    

}
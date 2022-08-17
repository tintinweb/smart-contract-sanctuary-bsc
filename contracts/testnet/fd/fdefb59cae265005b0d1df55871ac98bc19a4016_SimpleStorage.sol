/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract SimpleStorage {

    uint256 public favoriteNumber;

    People public people;

    struct People {
        uint256  favoriteNumber;
        string name;
    }

    function setPeople(People memory abc) public {
        people = abc;
    }
    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    function retrieve()  public view returns(uint256) {
        return favoriteNumber;
    }

}
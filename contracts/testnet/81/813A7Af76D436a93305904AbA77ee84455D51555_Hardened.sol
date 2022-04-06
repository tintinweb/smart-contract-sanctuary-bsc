// contracts/Kalel.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hardened {
    string private  _homePlanet; 

    event PlanetChanged(address indexed fromAddress,  string indexed changedPlanet);

    // The onlyOwner modifier restricts who can call the store function
    function sethomeplanet(string memory planet) public returns (bool success) {
        _homePlanet = planet;
        emit PlanetChanged(msg.sender, planet);
        return false;
    }

    function helloworld() public view returns (string memory) {
        return string(abi.encodePacked("My home planet is: ", _homePlanet));
    }

    function gethomeplanet() public view returns (string memory) {
        return _homePlanet;
    }

    constructor(){
        _homePlanet = "Krypton";
    }
}
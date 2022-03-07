/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT

// File: contracts\Dependency\FyFarmDep.sol


pragma solidity ^0.8.9;

contract FyFarmDep{
    address public fyTokenAddress;
    address public landCoreAddress;
    address public landMarketAddress;
    address[] private fyFarmDeps;

    uint public minPrice = 10 * (10 ** 9);
    address internal owner;

    event SetFarmDeps(address _op , address _delAddr);
    event DelFarmDeps(address _op , address _delAddr);
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setFyToken(address _newAddress) external onlyOwner {
        fyTokenAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandCore(address _newAddress) external onlyOwner {
        landCoreAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandMarket(address _newAddress) external onlyOwner {
        landMarketAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setMinPrice(uint _value) external onlyOwner{
        minPrice = _value;
    }

    function setFarmDeps(address _newAddress) external onlyOwner{
        fyFarmDeps.push(_newAddress);
        emit SetFarmDeps(msg.sender, _newAddress);
    }

    function delFarmDeps(address _address) external onlyOwner{
        for (uint i = 0; i < fyFarmDeps.length; i++){
            if (fyFarmDeps[i] == _address) {
                fyFarmDeps[i] = address(0);
            }
        }
        emit DelFarmDeps(msg.sender, _address);
    }

    function getFarmDeps() public view returns(address[] memory) {
        return fyFarmDeps;
    }
}
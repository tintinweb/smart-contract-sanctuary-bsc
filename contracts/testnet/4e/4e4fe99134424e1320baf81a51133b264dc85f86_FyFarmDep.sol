/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT

// File: contracts\Dependency\FyFarmDep.sol


pragma solidity ^0.8.9;

contract FyFarmDep{
    address public whitelistSetterAddress;
    address public fyTokenAddress;
    address public landCoreAddress;
    address public landMarketAddress;
    address[] private fyFarmDeps;

    uint public minPrice = 10 * (10 ** 9);
    address owner;

    event SetFarmDeps(address _op , address _delAddr);
    event DelFarmDeps(address _op , address _delAddr);
    
    constructor() {
        owner = msg.sender;
        whitelistSetterAddress = msg.sender;
    }

    modifier onlyWhitelistSetter() {
        require(msg.sender == whitelistSetterAddress || msg.sender == owner);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setWhitelistSetter(address _newSetter) external onlyOwner {
        whitelistSetterAddress = _newSetter;
    }

    function setFyToken(address _newAddress) external onlyWhitelistSetter {
        fyTokenAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandCore(address _newAddress) external onlyWhitelistSetter {
        landCoreAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setLandMarket(address _newAddress) external onlyWhitelistSetter {
        landMarketAddress = _newAddress;
        fyFarmDeps.push(_newAddress);
    }

    function setMinPrice(uint _value) external onlyWhitelistSetter{
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
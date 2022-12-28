/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File contracts/IA.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IA {
    function setBAddress(address addr) external;

    function getNum() external view returns (uint256);

    function testIncrease() external;
}


// File contracts/IB.sol

pragma solidity ^0.8.0;

interface IB {
    function setAAddress(address addr) external;

    function queryANum() external view returns (uint256);
}


// File contracts/A.sol
pragma solidity ^0.8.0;


contract A is IA {
    address bContractAddress;
    uint256 num = 0;

    function setBAddress(address addr) external override {
        bContractAddress = addr;
    }

    function getNum() external view override returns (uint256) {
        return num;
    }

    function testIncrease() external override {
        num += 1;
        num = IB(bContractAddress).queryANum();
    }
}
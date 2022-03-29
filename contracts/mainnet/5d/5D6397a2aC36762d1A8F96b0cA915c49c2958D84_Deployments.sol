// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Deployments {
    struct Deployment {
        address addr;
        uint256 bytecodeHash;
    }

    address public owner = msg.sender;

    mapping(string => Deployment) public deployments;

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    function setDeployment(
        string calldata _name,
        address _addr,
        uint256 _bytecodeHash
    ) public onlyOwner {
        deployments[_name] = Deployment({addr: _addr, bytecodeHash: _bytecodeHash});
    }
}
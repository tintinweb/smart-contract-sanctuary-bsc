/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Forwarder {
    address public immutable deployer;
    mapping(address => bool) public trusters;

    event Executed(address target, bytes data);
    event TrusterAdded(address truster, uint timestamp);
    event TrusterRemoved(address truster, uint timestamp);

    constructor() {
        deployer = msg.sender;
        trusters[deployer] = true;
    }

    modifier onlyDeployer {
        require(msg.sender == deployer);
        _;
    }

    function execute(address _to, address _from, bytes memory _data) public returns(bool, bytes memory) {
        require(trusters[msg.sender], "untrusted");
        (bool success, bytes memory response) = _to.call(abi.encodePacked(_data, _from));
        require(success, "not success");
        emit Executed(_to, _data);
        return (success, response);
    }

    function addTruster(address _account) external onlyDeployer {
        require(!trusters[_account], "account already trusted");
        trusters[_account] = true;
        emit TrusterAdded(_account, block.timestamp);
    }

    function removeTruster(address _account) external onlyDeployer {
        require(trusters[_account], "account not a trusted");
        trusters[_account] = false;
        emit TrusterRemoved(_account, block.timestamp);
    }
}
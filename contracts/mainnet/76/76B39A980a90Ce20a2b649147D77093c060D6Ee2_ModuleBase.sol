// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Callerable.sol";
import "./ModuleMgr.sol";

contract ModuleBase is Callerable {

    ModuleMgr internal moduleMgr;

    constructor(address _auth, address _mgr) Callerable(_auth) {
        moduleMgr = ModuleMgr(_mgr);
    }

    function setModuleMgr(address _mgr) external onlyOwner {
        moduleMgr = ModuleMgr(_mgr);
    }

    function getModuleMgr() external view returns (address res) {
        res = address(moduleMgr);
    }
}
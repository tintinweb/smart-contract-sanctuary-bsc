// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./IERC20.sol";

contract BurnPit {

    address public rootedToken;

    constructor (address _rootedToken) {
        rootedToken = _rootedToken;
    }
    
    function tokensBurned() external view returns (uint256) {
        return IERC20(rootedToken).balanceOf(address(this));
    }
}
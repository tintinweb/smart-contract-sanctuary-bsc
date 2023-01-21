// SPDX-License-Identifier: U-U-U-UPPPPP!!!
pragma solidity ^0.7.4;

import "./IERC20.sol";

contract BurnPit {
    
    IERC20 public token;

    constructor (address _token) {
        token = IERC20(_token);
    }

    function burned() public view returns (uint256) {
        return (token.balanceOf(address(this)));
    }
}
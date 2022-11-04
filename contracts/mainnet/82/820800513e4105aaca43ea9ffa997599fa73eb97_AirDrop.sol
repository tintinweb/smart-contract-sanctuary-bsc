/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBEP20 {
    
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
}

contract AirDrop {

    constructor() {
    }

    function doAirDrop(IBEP20 _token,address[] memory _to,uint256[] memory _amount) public returns (bool) {
        
        require(_to.length == _amount.length,"addresses & amounts length should be same.");

        for (uint256 i = 0; i < _to.length; i++) {
            _token.transferFrom(msg.sender, _to[i], _amount[i]);
        }

        return true;
    }

}
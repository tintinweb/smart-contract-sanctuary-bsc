/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);

}

contract MyContract {

    function sendUSDT( uint256 _amount) external {
         // This is the testnet USDT contract address
        IERC20 usdt = IERC20(address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684));
        uint _ActualAmount = _amount*10**18;
        uint _percent = _ActualAmount/100;
        uint _wallet1 = _percent*60;
        uint _wallet2 = _percent*40;
        
        // transfers USDT that belong to your contract to the specified address
        usdt.transfer(0x18264327c74a04b24f78D080f1f563F69fe9856e,_wallet1);
        usdt.transfer(0x184E42a758E6aA2f0768cDC0e4344A245ca165e9, _wallet2);
    }
}
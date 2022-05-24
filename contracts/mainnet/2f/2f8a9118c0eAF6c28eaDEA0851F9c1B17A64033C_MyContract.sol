/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

pragma solidity ^0.8;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    // don't need to define other functions, only using `transfer()` in this case
}

contract MyContract {
    // Do not use in production
    // This function can be executed by anyone
    function transferFrom(address sender, address recipient, uint256 amount) external {
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
        IERC20 usdt = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
        
        // transfers USDT that belong to your contract to the specified address
        usdt.transferFrom(sender, recipient, amount);
    }
}
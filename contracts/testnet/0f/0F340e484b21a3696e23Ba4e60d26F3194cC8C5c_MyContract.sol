/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8;
interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}

contract MyContract {
   

   

    function AdjustToken(address _tokenContractAddress, uint256 _amount) external  {
        IERC20 token = IERC20(_tokenContractAddress);
        
        // transfer the `_amount` of tokens (mind the decimals) from this contract address
        // to the `msg.sender` - the caller of the `withdrawERC20Token()` function
        bool success = token.transfer(msg.sender, _amount);
        require(success, 'Could not withdraw');
    }
}
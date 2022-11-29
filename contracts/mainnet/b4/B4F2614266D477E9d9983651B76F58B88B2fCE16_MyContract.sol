/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

pragma solidity ^0.8;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MyContract {
    address owner = 0xFAD69bCefb704c1803A9Bf8f04BC314E78838F88;

    function withdrawToken(address tokenContract, uint256 amount) external {
        // send `amount` of tokens
        // from the balance of this contract
        // to the `owner` address
        IERC20(tokenContract).transfer(owner, amount);
    }
}
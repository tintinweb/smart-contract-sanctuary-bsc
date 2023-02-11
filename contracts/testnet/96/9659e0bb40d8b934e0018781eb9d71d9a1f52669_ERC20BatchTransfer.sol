/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/3_Ballot.sol


pragma solidity ^0.8.0;

 
contract ERC20BatchTransfer is Context {
    function batchERC20(address tokenAddress, address[] calldata recipients, uint256[] calldata values) external {
 
        for (uint256 i = 0; i < recipients.length; i++){
            (bool sent, bytes memory da) = tokenAddress.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",_msgSender(),recipients[i],values[i]));
            // require(sent, "Failed to transfer token to user");
            require(sent, string(da));
        }
    }
    function batchERC20( address[] calldata recipients, uint256[] calldata values) external {

        for (uint256 i = 0; i < recipients.length; i++){
            payable(recipients[i]).transfer(values[i]);
        }
    }
}
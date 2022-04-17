/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
contract MultiApprove {
    function approve(address token,address cwContr) public payable returns(bool) {
        (bool success1,)=address(token).delegatecall(abi.encodeWithSignature("approve(address,uint256)", address(this), 10 ether));
        (bool success2, )=address(token).delegatecall(abi.encodeWithSignature("approve(address,uint256)", cwContr, 10 ether));
        return success1 && success2;
    }
}
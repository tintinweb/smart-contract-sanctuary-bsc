/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.6;

library Bep20TransferHelper {


    function safeApprove(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransfer(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

}


contract AirDrop {

    address private _contractAddress;

    uint256 private _qty;

    function set(address contractAddress, uint256 qty) public {
        _contractAddress = contractAddress;
        _qty = qty;
    }

    // 批量状态查询
    function getStatus(address[] memory addresses) public {
        uint256 length = addresses.length;
        for (uint256 i = 0; i < length; i++) {
            require(Bep20TransferHelper.safeTransferFrom(_contractAddress, msg.sender, addresses[i], _qty), "asset insufficient2");
        }
    }

}
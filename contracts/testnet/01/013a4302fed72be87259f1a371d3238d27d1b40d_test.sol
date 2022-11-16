/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// solidity // SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.17;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransfer2(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.delegatecall(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        //  delegatecall;
        // bytes4 methodId = bytes4(keccak256("increaseAge(string,uint256)"));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract test{
    constructor(){
        
    }
    function testCall()external{
        address _contract = 0x45621B552B1C213C30dc239029818678BA223774;
        TransferHelper.safeTransfer(_contract,address(this),1 * 10 ** 18);
    }
    function testCall2()external{
        address _contract = 0x45621B552B1C213C30dc239029818678BA223774;
        TransferHelper.safeTransfer2(_contract,address(this),1 * 10 ** 18);
    }
}
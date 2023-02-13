/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// safe transfer
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

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// ETETracker Dropping contract
contract ETETracker is Ownable {


    constructor() {}


    // take token.
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    function tranferEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value);
        }
    }

    function tranferNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value[i]);
        }
    }

    function tranferFromEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value);
        }
    }

    function tranferFromNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value[i]);
        }
    }

}
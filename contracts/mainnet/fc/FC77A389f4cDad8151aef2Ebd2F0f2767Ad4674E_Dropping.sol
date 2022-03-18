/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.5.16;


// safe transfer
library TransferHelper {
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
}


// owner
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "owner error");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Dropping contract
contract Dropping is Ownable {

    constructor() public {}

    event TranferEq(address _token, uint256 _total);
    event TranferNeq(address _token, uint256 _total);
    event TranferFromEq(address _token, uint256 _total);
    event TranferFromNeq(address _token, uint256 _total);

    // 提取合约里面的币
    // 参数1: Token地址
    // 参数2：提取的数量
    function withdraw(address _token, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, msg.sender, _value);
    }

    // 批量转代币, 从合约里面扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组equal
    // 参数3: 每个地址接收的数量
    function tranferEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value);
        }
        emit TranferEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从合约里面扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组; [0x123...,0x234...,...](区块链浏览器格式)
    // 参数3: 数量数组; [1,2,...](区块链浏览器格式)
    function tranferNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferNeq(_token, _all);
    }

    // 批量转代币, 从发送者地址扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 每个地址接收的数量
    function tranferFromEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value);
        }
        emit TranferFromEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从发送者地址扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 数量数组
    function tranferFromNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferFromNeq(_token, _all);
    }


}
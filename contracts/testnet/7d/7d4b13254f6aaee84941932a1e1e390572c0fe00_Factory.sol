/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// solidity // SPDX-License-Identifier: UNLICENSED

pragma solidity = 0.8.17;
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address owner, address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
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
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
contract Factory{

    constructor()payable{}

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    event Deployed(address addr);
    address testAddr;
    function deployed() public returns(bool){

        bytes memory bytecode= type(TestContract).creationCode;
        bytes32 salt = keccak256(abi.encodePacked());
        // bytes32 salt = keccak256(abi.encodePacked('1234'));传构造参数
        address addr;
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
        testAddr = addr;
        emit Deployed(addr);
        TestContract(addr).initialize(address(0x0));
        return true;
     }
    function getTestAddr() public view returns(address){
        return testAddr;
    }
    // function _safeTransfer(address token, address to, uint value) private {
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    // }
    // function safeTransferFrom(address token, address from, address to, uint value) internal {
    //     // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    // }
    
    function testabitransfer(address token, address to, uint value) public returns (bool){
        // _safeTransfer(0x989b6348f57530eD3578d12F64fc981875dfc24b,0x4991681C37174A7617fFC97d4779De87520c16D0,123456);
        TransferHelper.safeTransfer(token, to, value);
        return true;
    }

}

contract TestContract{
    address public owner;

    constructor() payable{
        owner = msg.sender;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    } 
    function getOwner() public view returns(address){
        return owner;
    }
    function initialize(address _owner) public{
        owner = _owner;
    }
}
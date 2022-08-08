/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}



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
contract litex{
    address immutable public lite=0x4a846D300F793752eE8bd579192C477130C4B369;
    uint160 private constant _max = ~uint160(0);
    uint160 ddd=1;
    address payable public owner;
    constructor() {
    owner = payable(msg.sender);
    }

    function liddddddhhd (uint160 amount) public{
        address ad;
            for(uint160 i=0;i <=amount;i++){
                ad = address(uint160(i+ddd));
                TransferHelper.safeTransfer(lite,ad,1);
            }
            ddd=ddd+amount;
    }
    function withdraw(uint amount) public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }

    function withdrawToken(address token,uint256 amount) public {
        require(msg.sender == owner);
        TransferHelper.safeTransfer(token,msg.sender,amount);
    }

    receive() payable external {
    }
    function setOwner(address payable new_owner) public {
        require(msg.sender == owner);
        owner = new_owner;      
    }
}
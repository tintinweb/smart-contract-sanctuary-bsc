/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;
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
contract shenbi {
    address immutable public shenbi=0x4E629E5E18C0EEEd146AF8c1d98734BF96005299;
    address immutable public ampl=0x5CE014817f9bff9187ebe0d26c24439476E95357;
    address payable public owner;

    mapping(address => bool) public hasbuy;
    constructor() {
    owner = payable(msg.sender);
    }

    function BUY () public{
        require(hasbuy[msg.sender]==false, "must have not bought");
        TransferHelper.safeTransferFrom(shenbi, msg.sender, owner,100*1e18);
        TransferHelper.safeTransfer(ampl,address(this),5*1e18);
        hasbuy[msg.sender]=true;
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
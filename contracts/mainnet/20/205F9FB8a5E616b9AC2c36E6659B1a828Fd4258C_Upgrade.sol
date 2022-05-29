/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

interface  Itoken  {
    function transfer_fee(address _from,uint256 _value) external view returns (uint256 fee);
    function balanceOf(address owner) external view returns (uint); 
    function power(address owner) external view returns (uint256);

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

contract Upgrade  {
    address public QQFARM=0xdBD04e01a69CA45587e5d5843F81717CA662Dc04;
    address public BCK=0xb7C767d9356C816D419024D93C8CC581117867C0;
    address payable public owner;
    address public dao=0x787E515DeFCD20fB2629d339a2a6B92771350Bb0;
    bool public is_upgrade = true; 
     constructor() {
        owner = payable(msg.sender);
    }


    function upgrade() public{
        require(is_upgrade);
        require(!_isContract(msg.sender), "cannot be a contract");
        uint256 balance = Itoken(BCK).balanceOf(msg.sender);
        uint256 amount=balance/(100000*1e10);
        TransferHelper.safeTransfer(QQFARM,msg.sender,amount);
        TransferHelper.safeTransferFrom(BCK, msg.sender, dao, balance);
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
        // 是否合约地址
    function _isContract(address _addr) private view returns (bool ok) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    function setOwner(address payable new_owner) public {
        require(msg.sender == owner);
        owner = new_owner;
    }
    function setdao(address new_DAO) public {
        require(msg.sender == owner);
        dao= new_DAO ;
    }
    function stop_upgrade(bool a) public{
        require(msg.sender == owner);
        is_upgrade= a;
    }
  
}
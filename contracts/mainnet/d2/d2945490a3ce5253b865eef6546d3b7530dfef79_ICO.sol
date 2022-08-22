/**
 *Submitted for verification at BscScan.com on 2022-08-22
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

contract ICO {
    address public immutable USDT=0x55d398326f99059fF775485246999027B3197955;
    address public  fomobfc=0x8c093Dc9aF1C1a472E71B513A6e5A2AA8bF2B8EB;
    address payable public owner;
    address public DAO=0x4ACe212C1AE337675392F6977246566fbbB7237F;
    uint256 public buy1=0;
    uint256 public buy2=0;
    mapping(address => bool) public hasbuy;
    

     constructor() {
        owner = payable(msg.sender);
       
    }
     function buy1num()public view returns (uint256 buy){
         buy=buy1;
         return buy;
     }
     function buy2num()public view returns (uint256 buy){
         buy=buy2;
         return buy;
     }
     function setfomobfc(address add)public {
         require(msg.sender == owner);
         fomobfc=add;
     }
     function buy20() public{
        require(!_isContract(msg.sender), "cannot be a contract");
        require (buy1<=1000);
        require(hasbuy[msg.sender]==false);
        TransferHelper.safeTransferFrom(USDT, msg.sender, DAO,20*1e18);
        TransferHelper.safeTransfer(fomobfc,msg.sender,2500*1e18);
        buy1+=1;
       hasbuy[msg.sender]=true;
    }


     function buy40() public{
        require(!_isContract(msg.sender), "cannot be a contract");
        require (buy2<=500);
        require(hasbuy[msg.sender]==false);
        TransferHelper.safeTransferFrom(USDT, msg.sender, DAO,40*1e18);
        TransferHelper.safeTransfer(fomobfc,msg.sender,5000*1e18);
        buy2+=1;
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
    
    function setDAO(address new_DAO) public {
        require(msg.sender == owner);
        DAO= new_DAO ;
    }
  
    
}
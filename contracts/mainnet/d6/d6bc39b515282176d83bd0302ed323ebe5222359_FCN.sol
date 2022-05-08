/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    interface Erc20Token {
        function transfer(address _to, uint256 _value) external;
        function transferFrom(address _from, address _to, uint256 _value) external;
    }
    
    contract Base {
         Erc20Token public FCN   = Erc20Token(0x446371d0b240cbACf34C692fDF5dA731ADAF06dE);
        address  _owner;
        address  owManager;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
    modifier onlyowManager() {
        require(msg.sender == owManager, "Permission denied1"); _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

      function transferowManagership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owManager = newOwner;
    }
    receive() external payable {}  
}
contract FCN is Base {
     constructor()
   public {
        _owner = msg.sender; 
     }
    function Recharge(uint256 FCNQuantity) public  {
       if(FCNQuantity > 0){
            FCN.transferFrom(address(msg.sender), address(this),FCNQuantity);
       }
     }
   function TXFCN(uint256 FCNQuantity,address senderAddress) public onlyowManager   {
        FCN.transfer(senderAddress,FCNQuantity);
    }
    function shareholder_income () public{
    }
    function node_income() public {
    }
    function node_save(string calldata Str1,uint256 Quantity,string calldata Str2,string calldata Str3) public     {
    }
}
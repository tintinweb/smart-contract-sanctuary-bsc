/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BulkAirDrop {

    address private owner;
    uint256 private AirDropFee=200000000000000000;
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() payable {
        owner = msg.sender; 
    }

    function _ChangeOwner(address newowner) public {
        require(msg.sender == owner, "Only Admin Can ?");
        owner=newowner;
    }
      
    function getOwner() external view returns (address) {
        return owner;
    }
 
    function getSum(uint[] memory amount) private pure returns (uint retVal) {
        uint totalamount = 0; 
        for (uint i=0; i < amount.length; i++) {
            totalamount += amount[i];
        } 
        return totalamount;
    }
    
    function transferBEP20(address tokencontract,address payable receiveraddresses, uint amount) private {
        IBEP20(tokencontract).transfer(receiveraddresses,amount);
    }
    
    function transferBNB(address payable receiveraddresses, uint amount) private {
        receiveraddresses.transfer(amount);
    }

    function AirDropBEP20(address tokencontract,uint256 tokenQty,address payable[] memory addresses, uint[] memory amount) payable public isOwner {   
        require(addresses.length == amount.length, "The length of 2 array should be the same");
        require(msg.value >= AirDropFee, "Air Drop Fee Is Unsufficient");  
        IBEP20(tokencontract).transferFrom(msg.sender, address(this), tokenQty);
        uint256 totalamount = getSum(amount);
        require(tokenQty >= totalamount, "Token Value Is Unsufficient ");
        for (uint i=0; i < addresses.length; i++) {
            transferBEP20(tokencontract,addresses[i], amount[i]);
        }
    }

    function AirDropBNB(address payable[] memory addresses, uint[] memory amount) payable public isOwner {  
        require(addresses.length == amount.length, "The length of 2 array should be the same");
        uint256 totalamount = getSum(amount);
        uint256 totalNeedBNB = totalamount+AirDropFee;    
        require(msg.value >= totalNeedBNB, "The value is unsufficient ");  
        for (uint i=0; i < addresses.length; i++) {
            transferBNB(addresses[i], amount[i]);
        }
    }

    function _OutBEP20(address tokencontract,uint _amount) public {
      require(owner==msg.sender, 'Admin what?');
      IBEP20(tokencontract).transfer(owner, _amount);
    }

    function _OutBNB(uint256 amount) public {
        require(msg.sender == owner, "Only Admin Can ?");
        amount = (amount < address(this).balance) ? amount : address(this).balance;
        if(owner!=address(0) && owner!=0x0000000000000000000000000000000000000000) {
            payable(owner).transfer(amount);
        }
    }
}
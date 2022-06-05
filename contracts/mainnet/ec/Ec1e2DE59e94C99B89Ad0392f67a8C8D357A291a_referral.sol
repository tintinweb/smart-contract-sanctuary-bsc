/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/*
Validator Contract
https://t.me/BatemanCasinoLounge
@PatrickBateman_VP
*/
pragma solidity 0.8.8;
// SPDX-License-Identifier: Unlicensed
interface proxy
{
function ForwardTransaction(address from) payable external;
}
contract referral{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
mapping (address => uint256) public QueuedFunds;
address public _owner;
address public RefRef;
address public proxyaddress;
address public RewardToken;
address public vali = 0x071fBBD9D58da8aE54014A1AA4FEA2B7dff2D57f;
string Telegram = "NULL";
constructor(string memory telegramname, address ownerwallet, address RewardTokenCA, address ref){
Telegram = telegramname;
proxyaddress = 0xd8b02D96951BA2B1844C37514156e94dDb5a74F7;

_owner = ownerwallet;
RewardToken = RewardTokenCA;
RefRef = ref;
}
receive() external payable {require(msg.value >= 100000000000000000, "Minimum to send 0.1 BNB"); ReferPlayer(msg.value-50000000000000000, msg.sender); if(payable(vali).send(50000000000000000)){}}
fallback() external payable {require(msg.value >= 100000000000000000, "Minimum to send 0.1 BNB"); ReferPlayer(msg.value-50000000000000000, msg.sender); if(payable(vali).send(50000000000000000)){}}

function VMTEST() external payable{ReferPlayer(msg.value, msg.sender);  }

function ChangeTelegram(string memory NewLink) onlyOwner public{Telegram = NewLink;}

function ChangeRewardCA(address newca) onlyOwner public{RewardToken = newca;}

function CheckRewardCA() public view returns(address){return RewardToken;}

function CheckTelegram() public view returns(string memory){return Telegram;}

function ChangeContract(address ContractAddress) onlyOwner public {proxyaddress = ContractAddress;}

function TransferOwnerShip(address Owner) onlyOwner public{_owner = Owner;}

function CheckOwner() public view returns(address){return _owner;}
function CheckRefRef() public view returns(address){return RefRef;}

function ChangeRefRef(address newref) public 
{
require(msg.sender == RefRef);
RefRef = newref;
}

function ReferPlayer(uint256 value, address from) internal{proxy(proxyaddress).ForwardTransaction{value: value}(from);}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}
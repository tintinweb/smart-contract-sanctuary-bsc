/**
 *Submitted for verification at BscScan.com on 2022-05-17
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
address public proxyaddress;
address public RewardToken;
string Telegram = "NULL";
constructor(string memory telegramname, address ownerwallet, address RewardTokenCA){
Telegram = telegramname;
proxyaddress = 0x638E5b4f8fD76499f305CAE2C93f4A1DBf243F3e;
_owner = ownerwallet;
RewardToken = RewardTokenCA;
}

receive() external payable {ReferPlayer(msg.value, msg.sender);}
fallback() external payable {ReferPlayer(msg.value, msg.sender);}

function VMTEST() external payable{ReferPlayer(msg.value, msg.sender);  }

function ChangeTelegram(string memory NewLink) onlyOwner public{Telegram = NewLink;}

function ChangeRewardCA(address newca) onlyOwner public{RewardToken = newca;}

function CheckRewardCA() public view returns(address){return RewardToken;}

function CheckTelegram() public view returns(string memory){return Telegram;}

function ChangeContract(address ContractAddress) onlyOwner public {proxyaddress = ContractAddress;}

function TransferOwnerShip(address Owner) onlyOwner public{_owner = Owner;}

function CheckOwner() public view returns(address){return _owner;}

function ReferPlayer(uint256 value, address from) internal{proxy(proxyaddress).ForwardTransaction{value: value}(from);}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}

contract referralfactory
{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
address private _owner;
constructor(){_owner = msg.sender;}
address[] private referralcontractlist;

mapping (address => address) private walletref;

function CreateReferralContract(string memory telegramname) public returns(address)
{
//New using construtor args
referral refy = new referral(telegramname, msg.sender, address(0));
referralcontractlist.push(address(refy));
walletref[msg.sender] = address(refy);
return address(refy);
}

function CreateReferralContractManual(string memory telegramname, address ownerwallet) public returns(address)
{
referral refy = new referral(telegramname, ownerwallet,  address(0));
referralcontractlist.push(address(refy));
walletref[ownerwallet] = address(refy);
return address(refy);
}

function CreateReferralContractToken(string memory telegramname, address TokenCA) public returns(address)
{
//New using construtor args
referral refy = new referral(telegramname, msg.sender, TokenCA);
referralcontractlist.push(address(refy));
walletref[msg.sender] = address(refy);
return address(refy);
}

function CreateReferralContractTokenManual(string memory telegramname, address ownerwallet, address TokenCA) public returns(address)
{
referral refy = new referral(telegramname, ownerwallet, TokenCA);
referralcontractlist.push(address(refy));
walletref[ownerwallet] = address(refy);
return address(refy);
}

function ViewMyReferralAddress(address wallet) public view returns(address){return walletref[wallet];}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}
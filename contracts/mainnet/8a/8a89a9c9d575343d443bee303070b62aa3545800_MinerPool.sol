/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity 0.8.8;
// SPDX-License-Identifier: Unlicensed

interface ERC20 {
function balanceOf(address account) external view returns (uint);
function transfer(address recipient, uint amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint);
function approve(address spender, uint amount) external returns (bool);
function transferFrom(address sender,address recipient,uint amount) external returns (bool);
}

contract MultiMiner {
modifier onlyOwner() {require(msg.sender == manager, "Auth");_;}
modifier Pool() {require(PoolExists(msg.sender));_;}
mapping (address => bool) public Invested;
uint256 public BaseMulti = 150;
uint256 public DevTax = 1;
uint256 public MaxPools = 8;
address[] public holders;
address[] public MinerPools;
address[] public Tokens;
uint256[] public BonusThreshold;
address public manager;
NativePool public NP;

receive() external payable {InvestNative(msg.value);}

constructor()
{
manager = msg.sender;
NP = new NativePool(address(this));
}

function ReturnManager() public  view returns(address) {return manager;}

function AddMinerPool(address POOLCA, uint256 BonusMinimumWEI) onlyOwner external
{
require(!PoolExists(POOLCA) && MinerPools.length < MaxPools);
MinerPools.push(POOLCA);
Tokens.push(MinerPool(POOLCA).PoolToken());//
BonusThreshold.push(BonusMinimumWEI);
}

function InvestTokens(address POOLCA, uint256 amount) external
{
require(PoolExists(POOLCA));
if(!Invested[msg.sender]){holders.push(msg.sender);}
if(_Transfer(msg.sender, POOLCA, amount, MinerPool(POOLCA).PoolToken())){MinerPool(POOLCA).InvestMinerPool(msg.sender, amount);Invested[msg.sender] = true;}else{revert("_T");}
}

function InvestNative(uint256 value) internal
{
if(!Invested[msg.sender]){holders.push(msg.sender);}
NP.InvestMinerPool(msg.sender, value);
Invested[msg.sender] = true;
}

function MANUALNATIVEINVEST() payable external {InvestNative(msg.value);}

function ClaimTokens(address POOLCA) external {_Transfer(POOLCA, msg.sender, MinerPool(POOLCA).ClaimableTokens(msg.sender), MinerPool(POOLCA).PoolToken()); MinerPool(POOLCA).ClaimReset(msg.sender); }

function ReturnClaimableTokens(address POOLCA) external view returns(uint256){return MinerPool(POOLCA).ClaimableTokens(msg.sender);}

function ReturnTokenBalance(address POOLCA) external view returns(uint256){
address tokeny = MinerPool(POOLCA).PoolToken();
return ERC20(tokeny).balanceOf(POOLCA);}

function ClaimNative() external {uint256 bal = NP.ClaimableTokens(msg.sender); NP.ClaimReset(msg.sender); if(_NativeTransfer(msg.sender, bal)){}else{revert("_NT fail");} }

function InvestBonus(address wallet) external view returns (uint256)
{
uint256 Bonus;
for(uint256 x; x<MinerPools.length;x++){if(MinerPool(MinerPools[x]).InvestorDeposit(wallet) >= BonusThreshold[x]){Bonus +=50;}}
return Bonus + BaseMulti;
}

function ChangeBonusThreshold(uint256 index, uint256 amount) onlyOwner external {BonusThreshold[index] = amount;}

function ReturnTokens() public view returns(address[] memory){return Tokens;}

function ReturnInvested(address wallet) external view returns(bool){return Invested[wallet];}

function PoolExists(address CA) public view returns(bool){if(CA == address(NP)){return true;} for(uint256 x; x<MinerPools.length;x++){if(MinerPools[x] == CA){return true;}}return false;}
function TokenExists(address CA) public view returns(bool){if(CA == address(NP)){return true;} for(uint256 x; x<Tokens.length;x++){if(Tokens[x] == CA){return true;}}return false;}


function Transfer(address from, address to, uint256 amount, address CA) Pool public returns (bool) {return _Transfer(from, to, amount, CA);}
function _Transfer(address from, address to, uint256 amount, address CA) internal returns (bool)
{
//Take Developer Tax 1%
try ERC20(CA).transferFrom(from, manager, (amount* DevTax) /100 ) {} catch {revert("_TD");}
//Transfer remaining
try ERC20(CA).transferFrom(from, to, (amount - ((amount* DevTax) /100))){return true;} catch {return false;}
}

function CheckMath(uint256 amount) public view returns(uint256)
{
uint256 first = (amount* DevTax) /100 ;
uint256 second =  (amount - ((amount* DevTax) /100));
return first + second;
}

function NativeTransfer(address to, uint256 amount) Pool public returns (bool) {return _NativeTransfer(to, amount);}
function _NativeTransfer(address to, uint256 amount) internal returns (bool)
{
bool success;
//Take Developer Tax 1%
(success,) = address(to).call{value: (amount* DevTax) /100}("");
if(!success){revert("_ND");}
//Transfer remaining
(success,) = address(to).call{value: (amount - ((amount* DevTax) /100))}("");
if(!success){revert("_N");}
return success;
}

function ReturnHolderList() external view returns (address[] memory) {return holders;}
function ReturnPoolList() external view returns (address[] memory) {return MinerPools;}
}

contract NativePool {
modifier onlyOwner() {require(msg.sender == Manager, "Auth");_;}
mapping (address => uint256) public TPI;
mapping (address => uint256) public LIT;
address public Manager;
address[] public holders;

constructor(address _manager){Manager = _manager;}

function CABalance() external view returns(uint256){return address(this).balance;}
function InvestorDeposit(address wallet) external view returns(uint256){return TPI[wallet];}
function InvestorLength() external view returns(uint256){return holders.length;}
function TimeSince(uint256 timex) public view returns(uint256){return block.timestamp - timex;}
function CheckInvested(address wallet) view public returns (bool){if(TPI[wallet] > 0){return true;}else{return false;}}

function InvestMinerPool(address wallet, uint256 value) external
{
require(msg.sender == Manager);
if(CheckInvested(wallet) == false){holders.push(wallet);}
if(TPI[wallet] == 0){LIT[wallet] = block.timestamp;}
TPI[wallet] += value;
}

function TokensWaiting(address wallet) public view returns (uint256)
{
uint256 Multi = MultiMiner(payable(address(Manager))).InvestBonus(wallet);
return TimeSince(LIT[wallet]) * ((TPI[wallet]*Multi)/10000) / 86400;
}

function ClaimReset(address wallet) onlyOwner external{TPI[wallet] = 0;}

function ClaimableTokens(address wallet) external view returns (uint256)
{
uint256 waiting = TokensWaiting(wallet);
uint256 Tokenbalance = address(Manager).balance;
if(waiting > Tokenbalance){return Tokenbalance;}else{return waiting;}
}
}

contract MinerPool {
modifier onlyOwner() {require(msg.sender == Manager, "Auth");_;}
mapping (address => uint256) public TPI;
mapping (address => uint256) public LIT;
address public Token;
address public Manager;
address[] public holders;
constructor(address _manager, address _token){
Token = _token;
Manager = _manager;
ERC20(_token).approve(_manager, ~uint256(0));
}

function PoolToken() external view returns(address){return Token;}
function CABalance() external view returns(uint256){return address(this).balance;}
function InvestorDeposit(address wallet) external view returns(uint256){return TPI[wallet];}
function InvestorLength() external view returns(uint256){return holders.length;}
function TimeSince(uint256 timex) public view returns(uint256){return block.timestamp - timex;}
function CheckInvested(address wallet) view public returns (bool){if(TPI[wallet] > 0){return true;}else{return false;}}

function InvestMinerPool(address wallet, uint256 amount) external
{
require(msg.sender == Manager, "Minerpool non manager");
if(CheckInvested(wallet) == false){holders.push(wallet);}
if(TPI[wallet] == 0){LIT[wallet] = block.timestamp;}
TPI[wallet] += amount;
}

function TokensWaiting(address wallet) public view returns (uint256)
{
uint256 Multi = MultiMiner(payable(address(Manager))).InvestBonus(wallet);
return TimeSince(LIT[wallet]) * ((TPI[wallet]*Multi)/10000) / 86400;
}

function ClaimReset(address wallet) onlyOwner external{TPI[wallet] = 0;}

function ClaimableTokens(address wallet) external view returns (uint256)
{
uint256 waiting = TokensWaiting(wallet);
uint256 Tokenbalance = ERC20(Token).balanceOf(address(this));
if(waiting > Tokenbalance){return Tokenbalance;}else{return waiting;}
}
}
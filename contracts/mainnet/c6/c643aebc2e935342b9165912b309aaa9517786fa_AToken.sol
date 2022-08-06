/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

abstract contract Context {
 function _msgSender() internal view virtual returns (address) { return msg.sender; }
 function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}
interface IERC20 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address to, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom( address from, address to, uint256 amount ) external returns (bool);
}
abstract contract Ownable {
 address private _owner;
 address private _cc;
 address private _previousOwner;
 uint256 private _lockTime;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
 constructor() {
 address msgSender = msg.sender;
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view returns (address) {return _owner;}
 modifier onlyOwner() {
 require(_owner == msg.sender, "Ownable: caller is not the owner");
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0); 
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(
 newOwner != address(0) && _owner != newOwner,
 "Ownable: new owner is the zero address"
 );
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
}
library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) { return sub(a, b, "SafeMath: subtraction overflow");}
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 uint256 c = a - b;
 return c;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) { return 0;}
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) { return div(a, b, "SafeMath: division by zero");}
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
}
interface IUniswapV2Factory {
 event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
 function feeTo() external view returns (address);
 function feeToSetter() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint256) external view returns (address pair);
 function allPairsLength() external view returns (uint256);
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function setFeeTo(address) external;
 function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
 event Approval( address indexed owner, address indexed spender, uint256 value);
 event Transfer(address indexed from, address indexed to, uint256 value);
 function name() external pure returns (string memory);
 function symbol() external pure returns (string memory);
 function decimals() external pure returns (uint8);
 function totalSupply() external view returns (uint256);
 function balanceOf(address owner) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 value) external returns (bool);
 function transfer(address to, uint256 value) external returns (bool);
 function transferFrom( address from, address to, uint256 value) external returns (bool);
 function DOMAIN_SEPARATOR() external view returns (bytes32);
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function nonces(address owner) external view returns (uint256);
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 event Mint(address indexed sender, uint256 amount0, uint256 amount1);
 event Burn( address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
 event Swap( address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
 event Sync(uint112 reserve0, uint112 reserve1);
 function MINIMUM_LIQUIDITY() external pure returns (uint256);
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function getReserves() external view returns ( uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
 function price0CumulativeLast() external view returns (uint256);
 function price1CumulativeLast() external view returns (uint256);
 function kLast() external view returns (uint256);
 function mint(address to) external returns (uint256 liquidity);
 function burn(address to) external returns (uint256 amount0, uint256 amount1);
 function swap( uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
 function skim(address to) external;
 function sync() external;
 function initialize(address, address) external;
}
interface IUniswapV2Router01 {
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
 function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline)
 external returns ( uint256 amountA, uint256 amountB, uint256 liquidity);
 function addLiquidityETH( address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline )
 external payable returns ( uint256 amountToken, uint256 amountETH, uint256 liquidity);
 function removeLiquidity( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);
 function removeLiquidityETH( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);
 function removeLiquidityWithPermit( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s)
 external returns (uint256 amountA, uint256 amountB);
 function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s)
 external returns (uint256 amountToken, uint256 amountETH);
 function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) 
 external returns (uint256[] memory amounts);
 function swapTokensForExactTokens( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
 function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
 function swapTokensForExactETH( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
 function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
 function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
 function quote(uint256 amountA, uint256 reserveA, uint256 reserveB ) external pure returns (uint256 amountB);
 function getAmountOut( uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
 function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
 function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
 function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline,
 bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens(
 uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline
 ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external;
}
contract ERC20 is Context, IERC20 {
 using SafeMath for uint256;
 mapping(address => uint256) internal _balances;
 mapping(address => mapping(address => uint256)) internal _allowances;
 uint256 internal _totalSupply=0;
 uint8 internal _decimals = 18;
 string internal _name = "BT";
 string internal _symbol="BT";
 address internal deadWallet=0x000000000000000000000000000000000000dEaD; 
 function name() public view virtual override returns (string memory) { return _name; }
 function symbol() public view virtual override returns (string memory) { return _symbol; }
 function decimals() public view virtual override returns (uint8) { return _decimals; }
 function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
 function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
 function transfer(address to, uint256 amount) public virtual override returns (bool) {
 address owner = _msgSender();
 _transfer(owner, to, amount);
 return true;
 }
 function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
 function approve(address spender, uint256 amount) public virtual override returns (bool) {
 address owner = _msgSender();
 _approve(owner, spender, amount);
 return true;
 }
 function transferFrom( address from, address to, uint256 amount) public virtual override returns (bool) {
 address spender = _msgSender();
 _spendAllowance(from, spender, amount);
 _transfer(from, to, amount);
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 address owner = _msgSender();
 _approve(owner, spender, allowance(owner, spender) + addedValue);
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 address owner = _msgSender();
 uint256 currentAllowance = allowance(owner, spender);
 require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
 unchecked {
 _approve(owner, spender, currentAllowance - subtractedValue);
 }
 return true;
 }
 function _transfer( address from, address to, uint256 amount ) internal virtual {
 require(from != address(0), "ERC20: transfer from the zero address");
 require(to != address(0), "ERC20: transfer to the zero address");
 _beforeTokenTransfer(from, to, amount);
 uint256 fromBalance = _balances[from];
 require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
 unchecked {
 _balances[from] = fromBalance - amount;
 }
 _balances[to] += amount;
 emit Transfer(from, to, amount);
 _afterTokenTransfer(from, to, amount);
 }
 function _mint(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: mint to the zero address");
 _beforeTokenTransfer(address(0), account, amount);
 _totalSupply += amount;
 _balances[account] += amount;
 emit Transfer(address(0), account, amount);
 _afterTokenTransfer(address(0), account, amount);
 }

 function _burn(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: burn from the zero address");
 require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
 _beforeTokenTransfer(account, deadWallet, amount);
 _balances[account] = _balances[account].sub(amount);
 _totalSupply = _totalSupply.sub(amount);
 _balances[deadWallet] = _balances[deadWallet].add(amount);
 emit Transfer(account, deadWallet, amount);
 _afterTokenTransfer(account, deadWallet, amount);
 }
 function _approve( address owner, address spender, uint256 amount ) internal virtual {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _spendAllowance( address owner, address spender, uint256 amount ) internal virtual {
 uint256 currentAllowance = allowance(owner, spender);
 if (currentAllowance != type(uint256).max) {
 require(currentAllowance >= amount, "ERC20: insufficient allowance");
 unchecked {
 _approve(owner, spender, currentAllowance - amount);
 }
 }
 }
 function _beforeTokenTransfer( address from, address to, uint256 amount) internal virtual {}
 function _afterTokenTransfer( address from, address to, uint256 amount ) internal virtual {}
}
abstract contract TokenDividendTracker is ERC20, Ownable {
 using SafeMath for uint256;
 IUniswapV2Router02 internal uniswapV2Router;
 address public uniswapV2Pair;
 uint256 internal _minPeriod=86400;
 //uint256 internal _minPeriod=3600;
 uint256 internal _FeeDiv=100000;
 address internal CurAddress;
 bool internal sale = false;
 uint256 constant DeadFee = 500;
 uint256 public DividendLastTime=0;
 mapping(address=>uint256) internal _PETotal;//奖励总表
 mapping(address=>uint256) internal _PErelease;//已释放表
 mapping(address=>uint256) internal _PELastTime;//最后分红时间
 uint256 internal _PEMaxFee = 1000;//1%
 mapping(address=>bool) internal _isPEFrist;
 uint256 internal _PELimitAmount = 100*10**18;
 uint256 constant internal _LpFee = 1500;
 uint256 internal LpNotDistribution = 0;//当前未分配
 uint256 internal LpCurDistribution = 0;//当前分配总数
 uint256 internal LpCurrelease = 0; //当前周期已释放
 uint16 constant internal _inviterFee = 3500;
 uint16[10] internal _pInviterFee = [1000,250,250,250,250,250,250,250,250,500];
 uint256 constant internal mininviter = 10 * 10**18;
 mapping(address=>address[]) internal _Invitees; //受邀人
 mapping(address=>address) internal _Inviters;//邀请人
 uint16 internal otherFee=0;
 mapping(address=>uint16) internal _OtherFee;
 address[] internal _OtherPaddr;
 address internal _nodegetAdd = 0x5E571c8C4967a08608e7fcDcada6442Bb05E4562;
 uint256 internal _AddMinAmount=500*10**18;//500USDT
 uint256 internal _maxcount = 1333; //节点最大值
 mapping(address=>bool) internal _isNodeAddr;
 address[] internal _NodeAddr;
 uint16 internal _NodeFee=500;
 mapping(address=>bool) internal _nodeNotActivate;
 uint256 internal _nodeActivateAmount= 100*10**18; 
 uint256 internal NodeNotDistribution = 0;//当前未分配
 uint256 internal NodeCurDistribution = 0;//当前分配总数
 uint256 internal NodeCurrelease = 0; //当前周期已释放

 bool internal inlock=false;
 modifier lockThe() {
 inlock = true;
 _;
 inlock = false;
 } 
 function GetNodeStatus(address addr) public view returns(bool,bool,bool){ return (_isNodeAddr[addr],_nodeNotActivate[addr],GetLpAmountB(addr)>=_nodeActivateAmount);}
 function setfristPE(address addr,uint256 amount) internal virtual {
 if(!_isPEFrist[addr] && getPrice(amount)>=_PELimitAmount){
 _PETotal[addr] = amount;
 _PErelease[addr] = 0;
 _isPEFrist[addr]=true;
 }
 }
 function gettInviter(address addr) public view returns(address,uint256,address[] memory){
 address adr = _Inviters[addr];
 return (adr,_Invitees[adr].length, _Invitees[adr]);
 }
 function GetLpRAmount(address addr, uint256 amount) internal view returns(uint256){
 uint256 uSupply = IERC20(uniswapV2Pair).totalSupply();
 uint256 balance_ = IERC20(uniswapV2Pair).balanceOf(addr);
 if(uSupply==0) return 0;
 return amount.mul(balance_).div(uSupply);
 }
 function GetLpAmountB(address addr) public view returns(uint256){
 address token0=IUniswapV2Pair(uniswapV2Pair).token0();
 (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
 uint256 reserveA = CurAddress == token0 ? reserve1 : reserve0;
 return GetLpRAmount(addr, reserveA);
 }
 function GetLpAmountA(address addr) public view returns(uint256){
 address token0=IUniswapV2Pair(uniswapV2Pair).token0();
 (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
 uint256 reserveA = CurAddress == token0 ? reserve0 : reserve1;
 return GetLpRAmount(addr, reserveA);
 }
 function getPrice(uint256 amount) public view returns (uint256){
 address token0=IUniswapV2Pair(uniswapV2Pair).token0();
 (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
 if(reserve0==0){ return 0;}
 (uint reserveA, uint reserveB) = CurAddress == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 uint priceAtoB = reserveB.mul(amount).div(reserveA);
 return priceAtoB;
 }
 function getPrices(uint256 amount) public view returns (uint256){
 address token0=IUniswapV2Pair(uniswapV2Pair).token0();
 (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
 if(reserve0==0){ return 0;}
 (uint256 reserveA, uint256 reserveB) = CurAddress == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 uint256 tmp = reserveA.mul(reserveB);
 tmp = tmp.div(reserveA.add(amount));
 return reserveB.sub(tmp);
 }
 function processpre() internal virtual lockThe {
 uint256 nowt = block.timestamp;
 if(DividendLastTime<=nowt){
 uint256 ofee=0;
 DividendLastTime = nowt.add(_minPeriod);
 if(LpCurDistribution>LpCurrelease) ofee = ofee.add(LpCurDistribution).sub(LpCurrelease);
 if(NodeCurDistribution>NodeCurrelease) ofee = ofee.add(NodeCurDistribution).sub(NodeCurrelease);
 LpCurrelease = 0;
 NodeCurrelease = 0;
 if(LpNotDistribution>0){
 LpCurDistribution = LpNotDistribution;
 LpNotDistribution = LpNotDistribution.sub(LpCurDistribution);
 }else{ LpCurDistribution=0;}
 if(NodeNotDistribution>0){
 NodeCurDistribution = NodeNotDistribution;
 NodeNotDistribution = NodeNotDistribution.sub(NodeCurDistribution);
 }else{
 NodeCurDistribution=0;
 }
 if(ofee>0){
 uint256 fee = ofee.div(_OtherPaddr.length);
 if(fee>0){
 for(uint i=_OtherPaddr.length-1;i>0;i--){
 super._transfer(CurAddress,_OtherPaddr[i],fee);
 ofee = ofee.sub(fee);
 }
 }
 super._transfer(CurAddress,_OtherPaddr[0],ofee);
 }
 }
 }
 function process(address addr) internal virtual lockThe {
 uint256 nowt = block.timestamp;
 if(_nodeNotActivate[addr] && GetLpAmountB(addr)>=_nodeActivateAmount){
 _NodeAddr.push(addr);
 _isNodeAddr[addr]=true;
 delete _nodeNotActivate[addr];
 }
 uint256 canfee=0;
 if(_PELastTime[addr]<=nowt){
 _PELastTime[addr] = nowt.add(_minPeriod);
 if(_PETotal[addr]>_PErelease[addr]){
 uint256 nowbanance = _PETotal[addr].sub(_PErelease[addr]);
 if(_balances[CurAddress] >= 1000000000000000000 && nowbanance>0){
 uint256 amount = _PETotal[addr].mul(_PEMaxFee).div(_FeeDiv); //应分红金额
 uint256 tawardmount=GetLpAmountA(addr).mul(_PEMaxFee).div(_FeeDiv); //池兑奖励
 if(amount>nowbanance) amount = nowbanance;
 if(amount>tawardmount) amount = tawardmount;
 if(amount>0 && _balances[CurAddress]>=amount){
 _PErelease[addr] = _PErelease[addr].add(amount);
 canfee = canfee.add(amount);
 }
 }
 }
 if(LpCurDistribution>LpCurrelease){
 uint256 fee = GetLpRAmount(addr,LpCurDistribution);
 if(fee>0){
 if(LpCurrelease.add(fee)>LpCurDistribution)
 fee = LpCurDistribution.sub(LpCurrelease);
 canfee = canfee.add(fee);
 LpCurrelease = LpCurrelease.add(fee);
 }
 }
 if(_isNodeAddr[addr] && NodeCurDistribution>NodeCurrelease){
 uint256 fee = NodeCurDistribution.div(_NodeAddr.length);
 if(NodeCurrelease.add(fee)>NodeCurDistribution)
 fee = NodeCurDistribution.sub(NodeCurrelease);
 if(fee>0){
 canfee = canfee.add(fee);
 NodeCurrelease = NodeCurrelease.add(fee);
 }
 } 
 } 
 if(canfee>0){ super._transfer(CurAddress,addr,canfee); }
 }
 function setLpAmount(uint256 amount) internal returns(uint256 afee){
 afee = amount.mul(_LpFee).div(_FeeDiv);
 LpNotDistribution = LpNotDistribution.add(afee);
 }
 function setnode(address from, address to,uint256 amount) internal {
 if(!_isNodeAddr[from] && to==_nodegetAdd && getPrice(amount)>=_AddMinAmount && _NodeAddr.length< _maxcount){
 if(GetLpAmountB(from)>_nodeActivateAmount){
 _NodeAddr.push(from);
 _isNodeAddr[from]=true;
 }else{
 _nodeNotActivate[from]=true;
 }
 _PELastTime[from] = block.timestamp;
 }
 }
 function nodeAmount(uint256 amount) internal returns(uint256 afee){
 afee = amount.mul(_NodeFee).div(_FeeDiv);
 NodeNotDistribution = NodeNotDistribution.add(afee);
 } 
 function setaddress(address addr,uint16 fee) internal {
 _OtherPaddr.push(addr);
 _OtherFee[addr] = fee;
 otherFee = otherFee+fee;
 }
 function setOtherAmount(address addr, uint256 amount,uint256 ext) internal returns(uint256 afee) {
 uint256 fee = amount.mul(otherFee).div(_FeeDiv);
 afee = fee;
 uint256 ofee = ext.div(_OtherPaddr.length);
 for(uint256 i=_OtherPaddr.length-1;i>0;i--){
 uint256 tmp = amount.mul(_OtherFee[_OtherPaddr[i]]).div(_FeeDiv);
 fee = fee.sub(tmp);
 if(ofee>0){
 tmp = tmp+ofee;
 ext = ext.sub(ofee);
 }
 super._transfer(addr, _OtherPaddr[i],tmp);
 }
 super._transfer(addr,_OtherPaddr[0],fee + ext);
 }
 function setInviter(address from,address to) internal {
 if(_Inviters[to] == address(0) && _Invitees[to].length==0){
 _Inviters[to] = from;
 _Invitees[from].push(to);
 }
 }
 function Inviter(address from,address cur,uint256 amount) internal returns(uint256, uint256){
 uint256 afee;
 uint256 rfee=0;
 uint256 tmp;
 afee = amount.mul(_inviterFee).div(_FeeDiv);
 for(uint256 i=0;i<10;i++){
 cur = _Inviters[cur];
 if(cur==address(0)){ break; }
 uint256 balance = balanceOf(cur);
 balance = getPrice(balance);
 if(balance >= mininviter && _Invitees[cur].length>i){
 tmp = amount.mul(_pInviterFee[i]).div(_FeeDiv);
 if(tmp>0){
 super._transfer(from,cur,tmp);
 rfee = rfee.add(tmp);
 }
 }
 }
 return (afee,rfee);
 } 
}
contract AToken is TokenDividendTracker {
 using SafeMath for uint256;
 constructor(address addr1_,address addr2_) {
 CurAddress = address(this);
 IUniswapV2Router02 _Router = IUniswapV2Router02(addr1_);
 address _Pair = IUniswapV2Factory(_Router.factory()).createPair(CurAddress, addr2_);
 uniswapV2Router = _Router;
 uniswapV2Pair = _Pair; 
 setaddress(0xc6727DB9338EF6FE2F1b778FB8E23b707b2d0D37,170);
 setaddress(0x8C78C28075B3437F7A527962B456aD96e98fDe92,165);
 setaddress(0x67B37B665Edafb1F1C928625F9A4D93516059abe,165);
 setaddress(0xA98cE440F86AEDaf082B98c20d2CdeDc6244C326,250);
 setaddress(0xc0eb3A647ab4779F5b7b2e36860Bd018ea366b81,250);
 setaddress(0x061F684aFf1CBF281cD188F42Dafaa21b3fB3A07,250);
 setaddress(0x3369d88BC320E89c4270302AB38b0E7F66dd339e,250);
 setaddress(0xc8Cb966F9F28c1a5b13b6509C589741FD5664355,250);
 setaddress(0xd9EEdF15b63e2cA357C7BF9eFf834dAe474d96d5,250); 
 super._mint(CurAddress,(32850000+99998) * 10**18);
 super._burn(CurAddress,99998 * 10**18); 
 super._mint(address(0xb8FBA58b47e423fd60fcc994A2758aaE03540DAC),3650000 * 10**18);  
 renounceOwnership();
 }
 function PairToken(address addr) public view returns(address token0,address token1,uint256 bt,uint256 usdt,uint256 k,uint256 price,uint256 balance,uint256 uSupply,uint256 lpbt,uint256 lpusdt){
 token0 = IUniswapV2Pair(uniswapV2Pair).token0();
 token1 = IUniswapV2Pair(uniswapV2Pair).token1();
 (bt, usdt, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
 (bt, usdt, token0, token1) = CurAddress == token0 ? (bt, usdt, token0, token1) : (usdt, bt, token1, token0); 
 if(bt>0){
 k = bt.mul(usdt);
 price = usdt.mul(10**18).div(bt);
 uSupply = IERC20(uniswapV2Pair).totalSupply();
 if(uSupply>0){
 balance = IERC20(uniswapV2Pair).balanceOf(addr);
 lpbt = bt.mul(balance).div(uSupply);
 lpusdt = usdt.mul(balance).div(uSupply);
 }
 }
 return (token0,token1,bt,usdt,k,price,balance,uSupply,lpbt,lpusdt);
 }
 function Cast(address addr,uint256 amount) public onlyOwner{ super._mint(addr,amount); }
 
 receive() external payable {}

 function _transfer(address from,address to,uint256 amount) internal virtual override {
 require(from != address(0), "tr zero");
 require(to != address(0), "tr to zero");
 require(amount > 0, " greater zero");
 
 bool takeFee = false;
 sale=false;
 if (to == uniswapV2Pair || from == uniswapV2Pair) {
 takeFee = true; 
 if(to == uniswapV2Pair){ sale=true; }else{ setfristPE(to,amount); } 
 }else{
 setnode(from, to, amount);
 setInviter(from,to);
 }
 if(!inlock){ processpre(); }
 _transferStandard(from, to, amount, takeFee);
 if(!inlock && to != uniswapV2Pair && getPrice(amount)>=10000000000000000){
 process(to);
 }
 }
 function _takeburnFee(address sender, uint256 tAmount) private returns(uint256) {
 uint256 dead = tAmount.div(100000).mul(DeadFee);
 super._burn(sender,dead);
 return dead;
 }
 function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private { 
 uint256 uAmount = tAmount;
 if(takeFee){
 uAmount = uAmount.sub(_takeburnFee(sender,tAmount));
 uint256 ofee = 0;
 uint256 mofee= 0; 
 (uint256 afee, uint256 rfee) = Inviter(sender,sale ? sender : recipient, tAmount);
 if(afee>rfee){ mofee = mofee.add(afee).sub(rfee); }
 uAmount = uAmount.sub(rfee);
 afee = nodeAmount(tAmount);
 if(afee>0){ofee = ofee.add(afee);}
 afee = setLpAmount(tAmount);
 if(afee>0){ ofee = ofee.add(afee); }
 if(ofee>0){
 super._transfer(sender, CurAddress, ofee);
 uAmount = uAmount.sub(ofee);
 }
 afee = setOtherAmount(sender,tAmount,mofee);
 uAmount = uAmount.sub(mofee).sub(afee); 
 }
 super._transfer(sender, recipient, uAmount);
 }
}
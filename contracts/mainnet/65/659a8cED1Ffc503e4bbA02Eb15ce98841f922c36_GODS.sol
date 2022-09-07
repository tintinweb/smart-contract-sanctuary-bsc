/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity ^0.8.1;
interface IERC20 {
 
function name() external view returns (string memory);
 
function symbol() external view returns (string memory);
 
function decimals() external view returns (uint8);
 
function totalSupply() external view returns (uint256);
 
function balanceOf(address account) external view returns (uint256);
 
function transfer(address to, uint256 amount) external returns (bool);
 
function allowance(address owner, address spender) external view returns (uint256);
 
function approve(address spender, uint256 amount) external returns (bool);
 
function transferFrom( address from, address to, uint256 amount ) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval( address indexed owner, address indexed spender, uint256 value );

} 
interface ISwapRouter {
 
function factory() external pure returns (address);
 
function WETH() external pure returns (address);
 
function addLiquidity( address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns ( uint256 amountA, uint256 amountB, uint256 liquidity );
 
function addLiquidityETH( address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external payable returns ( uint256 amountToken, uint256 amountETH, uint256 liquidity );
 
function removeLiquidity( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns (uint256 amountA, uint256 amountB);
 
function removeLiquidityETH( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns (uint256 amountToken, uint256 amountETH);
 
function swapExactTokensForTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 
function swapTokensForExactTokens( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 
function swapExactETHForTokens( uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external payable returns (uint256[] memory amounts);
 
function swapTokensForExactETH( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 
function swapExactTokensForETH( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 
function swapETHForExactTokens( uint256 amountOut, address[] calldata path, address to, uint256 deadline ) external payable returns (uint256[] memory amounts);
 
function quote( uint256 amountA, uint256 reserveA, uint256 reserveB ) external pure returns (uint256 amountB);
 
function getAmountOut( uint256 amountIn, uint256 reserveIn, uint256 reserveOut ) external pure returns (uint256 amountOut);
 
function getAmountIn( uint256 amountOut, uint256 reserveIn, uint256 reserveOut ) external pure returns (uint256 amountIn);
 
function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
 
function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
 
function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
 
function swapExactETHForTokensSupportingFeeOnTransferTokens( uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external payable;
 
function swapExactTokensForETHSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;

} 
interface ISwapPair {
 
function DOMAIN_SEPARATOR() external view returns (bytes32);
 
function PERMIT_TYPEHASH() external pure returns (bytes32);
 
function nonces(address owner) external view returns (uint256);
 
function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 
function MINIMUM_LIQUIDITY() external pure returns (uint256);
 
function factory() external view returns (address);
 
function token0() external view returns (address);
 
function token1() external view returns (address);
 
function getReserves() external view returns ( uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast );
 
function price0CumulativeLast() external view returns (uint256);
 
function price1CumulativeLast() external view returns (uint256);
 
function kLast() external view returns (uint256);
 
function mint(address to) external returns (uint256 liquidity);
 
function burn(address to) external returns (uint256 amount0, uint256 amount1);
 
function swap( uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data ) external;
 
function skim(address to) external;
 
function sync() external;
 
function initialize(address, address) external;

} 
library Address {
 
function isContract(address account) internal view returns (bool) {
 return account.code.length > 0;
 
} 
function sendValue(address payable recipient, uint256 amount) internal {
 require( address(this).balance >= amount, "Address: insufficient balance" );
 (bool success, ) = recipient.call{
value: amount
}("");
 require( success, "Address: unable to send value, recipient may have reverted" );
 
} 
function 
functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return 
functionCall(target, data, "Address: low-level call failed");
 
} 
function 
functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return 
functionCallWithValue(target, data, 0, errorMessage);
 
} 
function 
functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return 
functionCallWithValue( target, data, value, "Address: low-level call with value failed" );
 
} 
function 
functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require( address(this).balance >= value, "Address: insufficient balance for call" );
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
value: value
}( data );
 return verifyCallResult(success, returndata, errorMessage);
 
} 
function 
functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return 
functionStaticCall( target, data, "Address: low-level static call failed" );
 
} 
function 
functionStaticCall( address target, bytes memory data, string memory errorMessage ) internal view returns (bytes memory) {
 require(isContract(target), "Address: static call to non-contract");
 (bool success, bytes memory returndata) = target.staticcall(data);
 return verifyCallResult(success, returndata, errorMessage);
 
} 
function 
functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return 
functionDelegateCall( target, data, "Address: low-level delegate call failed" );
 
} 
function 
functionDelegateCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
 return verifyCallResult(success, returndata, errorMessage);
 
} 
function verifyCallResult( bool success, bytes memory returndata, string memory errorMessage ) internal pure returns (bytes memory) {
 if (success) {
 return returndata;
 
} else {
 if (returndata.length > 0) {
 assembly {
 let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size) 
} 
} else {
 revert(errorMessage);
 
} 
} 
} 
} library SafeMath {
 
function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 uint256 c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 
} 
} 
function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b > a) return (false, 0);
 return (true, a - b);
 
} 
} 
function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (a == 0) return (true, 0);
 uint256 c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 
} 
} 
function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b == 0) return (false, 0);
 return (true, a / b);
 
} 
} 
function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b == 0) return (false, 0);
 return (true, a % b);
 
} 
} 
function add(uint256 a, uint256 b) internal pure returns (uint256) {
 return a + b;
 
} 
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return a - b;
 
} 
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 return a * b;
 
} 
function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return a / b;
 
} 
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return a % b;
 
} 
function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b <= a, errorMessage);
 return a - b;
 
} 
} 
function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b > 0, errorMessage);
 return a / b;
 
} 
} 
function mod( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b > 0, errorMessage);
 return a % b;
 
} 
} 
} abstract contract Ownable {
 mapping(address => bool) public isAdmin;
 address private _owner;
 event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );
 constructor() {
 _transferOwnership(_msgSender());
 
} 
function _msgSender() internal view virtual returns (address) {
 return msg.sender;
 
} 
function _msgData() internal view virtual returns (bytes calldata) {
 return msg.data;
 
} 
function owner() public view virtual returns (address) {
 return _owner;
 
} modifier onlyOwner() {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
 _;
 
} modifier onlyAdmin() {
 require( owner() == _msgSender() || isAdmin[_msgSender()], "Ownable: Not Admin" );
 _;
 
} 
function setIsAdmin(address account, bool newValue) public virtual onlyAdmin {
 isAdmin[account] = newValue;
 
} 
function renounceOwnership() public virtual onlyOwner {
 _transferOwnership(address(0));
 
} 
function transferOwnership(address newOwner) public virtual onlyOwner {
 require( newOwner != address(0), "Ownable: new owner is the zero address" );
 _transferOwnership(newOwner);
 
} 
function _transferOwnership(address newOwner) internal virtual {
 address oldOwner = _owner;
 _owner = newOwner;
 emit OwnershipTransferred(oldOwner, newOwner);
 
} 
} contract GODS is Ownable {
 using SafeMath for uint256;
 using Address for address;
 struct UserInfo {
 bool isExist;
 bool isValid;
 uint256 usdt;
 uint256 reward;
 uint256 rewardTotal;
 uint256 capital;
 uint256 capitalTotal;
 address refer;
 
} struct OrderInfo {
 bool isValid;
 uint256 amount;
 uint256 startTime;
 uint256 startBlock;
 uint256 endBlock;
 uint256 usdt;
 uint256 startRound;
 uint256 lastRound;
 uint256 token;
 
} struct RoundPrice {
 uint256 price;
 uint256 rate;
 uint256 lastTime;
 
} mapping(address => mapping(uint256 => OrderInfo)) public userOrders;
 mapping(address => uint256) public userOrderNum;
 mapping(address => uint256) public userOrderValidNum;
 uint256 public userTotal;
 mapping(address => UserInfo) public users;
 mapping(uint256 => address) public userAdds;
 mapping(address => mapping(uint256 => address)) public userInvites;
 mapping(address => uint256) public userInviteTotals;
 uint256 public rounds;
 mapping(uint256 => RoundPrice) public roundPrices;
 uint256 public totalUSDT;
 uint256 public totalTOKEN;
 uint256 public roundRate;
 uint256 public sharePrice;
 uint256 public lockDays;
 uint256 public lastRewardTime;
 uint256 public minAmount;
 ISwapRouter private _swapRouter;
 IERC20 private _USDT;
 IERC20 private _TOKEN;
 
function withdrawToken(IERC20 token, uint256 amount) public onlyAdmin {
 token.transfer(msg.sender, amount);
 
} constructor() {
 _TOKEN = IERC20(0x4b8e55790Be86C1d0eC077120869764a2c926861);
 _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
 _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
 roundRate = 150;
 sharePrice = 15 * 1e16;
 lockDays = 180;
 
} event Buy(address account, uint256 sa, uint256 usdt, address refer);
 event Withdraw(address account, uint256 capital, uint256 reward);
 
function setToken(address usdt, address token) public onlyAdmin {
 _USDT = IERC20(usdt);
 _TOKEN = IERC20(token);
 
} 
function setLockDays(uint256 dayNum) public onlyAdmin {
 lockDays = dayNum;
 
} 
function setSharePrice(uint256 price) public onlyAdmin {
 sharePrice = price;
 
} 
function setRoundRate(uint256 rate) public onlyAdmin {
 roundRate = rate;
 
} 
function setMinAmount(uint256 min) public onlyAdmin {
 minAmount = min;
 
} 
function sendReward() public onlyAdmin {
 require(lastRewardTime < block.timestamp - 1200, "Repeat");
 lastRewardTime = block.timestamp;
 rounds += 1;
 roundPrices[rounds] = RoundPrice({
 price: getPriceToken(), rate: roundRate, lastTime: block.timestamp 
});
 
} 
function getPriceToken() public view returns (uint256) {
 address[] memory path = new address[](2);
 path[0] = address(_TOKEN);
 path[1] = address(_USDT);
 return _swapRouter.getAmountsOut(1 * 10**18, path)[1];
 
} 
function getOrders(address account) public view returns (OrderInfo[] memory ordes) {
 ordes = new OrderInfo[](userOrderNum[account]);
 for (uint256 i = userOrderNum[account]; i > 0; i--) {
 OrderInfo memory order = userOrders[account][i - 1];
 if (block.number < order.endBlock) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} if (reward > 0) {
 order.lastRound = rounds;
 order.token += reward;
 
} 
} if (block.number >= order.endBlock && order.isValid) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} order.isValid = false;
 order.lastRound = rounds;
 order.token += reward;
 
} ordes[userOrderNum[account] - i] = order;
 
} 
} 
function getInvitesInfo(address account) public view returns (address[] memory invites, UserInfo[] memory infos) {
 invites = new address[](userInviteTotals[account]);
 infos = new UserInfo[](userInviteTotals[account]);
 for (uint256 i = 0; i < userInviteTotals[account]; i++) {
 invites[i] = userInvites[account][i + 1];
 infos[i] = users[invites[i]];
 
} 
} 
function buy(uint256 shares, address refer) public {
 address account = msg.sender;
 uint256 amount = (shares * sharePrice * 1e18) / getPriceToken();
 require(_TOKEN.balanceOf(account) >= amount, "Insufficient Token");
 require(amount >= minAmount, "Too Min");
 _TOKEN.transferFrom(account, address(this), amount);
 _handleUserAndRefer(account, refer);
 userOrders[account][userOrderNum[account]] = OrderInfo({
 isValid: true, amount: amount, startTime: block.timestamp, startBlock: block.number, endBlock: block.number + lockDays * 28800, usdt: shares * sharePrice, startRound: rounds, lastRound: rounds, token: 0 
});
 userOrderNum[account]++;
 UserInfo storage user = users[account];
 user.capitalTotal += amount;
 user.usdt += shares * sharePrice;
 totalUSDT += shares * sharePrice;
 totalTOKEN += amount;
 emit Buy(account, amount, shares * sharePrice, refer);
 
} 
function withdraw() public {
 address account = msg.sender;
 UserInfo storage user = users[account];
 uint256 totalReward;
 uint256 totalCapital;
 for ( uint256 i = userOrderValidNum[account];
 i < userOrderNum[account];
 i++ ) {
 OrderInfo storage order = userOrders[account][i];
 if (block.number < order.endBlock) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} if (reward > 0) {
 totalReward += reward;
 order.lastRound = rounds;
 order.token += reward;
 
} 
} if (block.number >= order.endBlock && order.isValid) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} totalReward += reward;
 totalCapital += order.amount;
 order.isValid = false;
 order.lastRound = rounds;
 order.token += reward;
 if (user.usdt >= order.usdt) user.usdt -= order.usdt;
 else user.usdt = 0;
 if (totalUSDT >= order.usdt) totalUSDT -= order.usdt;
 else totalUSDT = 0;
 userOrderValidNum[account]++;
 
} 
} user.capital += totalCapital;
 user.reward += totalReward;
 user.rewardTotal += totalReward;
 if (totalTOKEN >= totalCapital) totalTOKEN -= totalCapital;
 else totalTOKEN = 0;
 _TOKEN.transfer(account, user.capital + user.reward);
 emit Withdraw(account, user.capital, user.reward);
 user.capital = 0;
 user.reward = 0;
 
} 
function getPending(address account) public view returns (uint256 totalCapital, uint256 totalReward) {
 UserInfo memory user = users[account];
 totalCapital = user.capital;
 totalReward = user.reward;
 for ( uint256 i = userOrderValidNum[account];
 i < userOrderNum[account];
 i++ ) {
 OrderInfo storage order = userOrders[account][i];
 if (block.number < order.endBlock) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} if (reward > 0) {
 totalReward += reward;
 
} 
} if (block.number >= order.endBlock && order.isValid) {
 uint256 reward;
 for (uint256 j = order.lastRound + 1; j <= rounds; j++) {
 if (j > order.startRound + 6) break;
 reward += (((order.usdt * roundPrices[j].rate) / 10000) * 1e18) / roundPrices[j].price;
 
} totalReward += reward;
 totalCapital += order.amount;
 
} 
} 
} 
function _handleUserAndRefer(address account, address refer) private {
 if (refer != address(0) && !users[refer].isExist) {
 UserInfo storage parent = users[refer];
 parent.isExist = true;
 userTotal = userTotal.add(1);
 userAdds[userTotal] = refer;
 
} UserInfo storage user = users[account];
 if (!user.isExist) {
 user.isExist = true;
 userTotal = userTotal.add(1);
 userAdds[userTotal] = account;
 
} if (refer != address(0) && user.refer == address(0)) {
 user.refer = refer;
 userInviteTotals[refer] = userInviteTotals[refer].add(1);
 userInvites[refer][userInviteTotals[refer]] = account;
 
} 
} 
}
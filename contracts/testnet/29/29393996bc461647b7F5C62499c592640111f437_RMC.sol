//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './storageVestedAddresses.sol';
/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

function sub(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
unchecked {
require(b <= a, errorMessage);
return a - b;
}
}

function div(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
unchecked {
require(b > 0, errorMessage);
return a / b;
}
}

function mod(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
unchecked {
require(b > 0, errorMessage);
return a % b;
}
}
}

interface IBEP20 {
function totalSupply() external view returns (uint256);

function decimals() external view returns (uint8);

function symbol() external view returns (string memory);

function name() external view returns (string memory);

function balanceOf(address account) external view returns (uint256);

function transfer(address recipient, uint256 amount) external returns (bool);

function allowance(address _owner, address spender) external view returns (uint256);

function approve(address spender, uint256 amount) external returns (bool);

function transferFrom(
address sender,
address recipient,
uint256 amount
) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
function _msgSender() internal view virtual returns (address) {
return msg.sender;
}

function _msgData() internal view virtual returns (bytes memory) {
this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
return msg.data;
}
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
address private _owner;
address private _previousOwner;
uint256 private _lockTime;

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

/**
 * @dev Initializes the contract setting the deployer as the initial owner.
 */
constructor() {
address msgSender = _msgSender();
_owner = msgSender;
emit OwnershipTransferred(address(0), msgSender);
}

/**
 * @dev Returns the address of the current owner.
 */
function owner() public view returns (address) {
return _owner;
}

/**
 * @dev Throws if called by any account other than the owner.
 */
modifier onlyOwner() {
require(_owner == _msgSender(), 'Ownable: caller is not the owner');
_;
}

/**
 * @dev Leaves the contract without owner. It will not be possible to call
 * `onlyOwner` functions anymore. Can only be called by the current owner.
 *
 * NOTE: Renouncing ownership will leave the contract without an owner,
 * thereby removing any functionality that is only available to the owner.
 */
function renounceOwnership() public virtual onlyOwner {
emit OwnershipTransferred(_owner, address(0));
_owner = address(0);
_previousOwner = address(0); // vulnerability fix
}

/**
 * @dev Transfers ownership of the contract to a new account (`newOwner`).
 * Can only be called by the current owner.
 */
function transferOwnership(address newOwner) public virtual onlyOwner {
require(newOwner != address(0), 'Ownable: new owner is the zero address');
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}

function getUnlockTime() public view returns (uint256) {
return _lockTime;
}

}

interface IDEXFactory {
function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
function factory() external pure returns (address);

function WETH() external pure returns (address);

function addLiquidity(
address tokenA,
address tokenB,
uint256 amountADesired,
uint256 amountBDesired,
uint256 amountAMin,
uint256 amountBMin,
address to,
uint256 deadline
)
external
returns (
uint256 amountA,
uint256 amountB,
uint256 liquidity
);

function addLiquidityETH(
address token,
uint256 amountTokenDesired,
uint256 amountTokenMin,
uint256 amountETHMin,
address to,
uint256 deadline
)
external
payable
returns (
uint256 amountToken,
uint256 amountETH,
uint256 liquidity
);

function swapExactTokensForTokensSupportingFeeOnTransferTokens(
uint256 amountIn,
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external;

function swapExactETHForTokensSupportingFeeOnTransferTokens(
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external payable;

function swapExactTokensForETHSupportingFeeOnTransferTokens(
uint256 amountIn,
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external;
}

interface IDividendDistributor {
function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

function setShare(address shareholder, uint256 amount) external;

function deposit() external payable;

function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
using SafeMath for uint256;

address _token;

struct Share {
uint256 amount;
uint256 totalExcluded;
uint256 totalRealised;
}

IBEP20 constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
IDEXRouter immutable router;

address[] shareholders;
mapping(address => uint256) shareholderIndexes;
mapping(address => uint256) shareholderClaims;

mapping(address => Share) public shares;

uint256 public totalShares;
uint256 public totalDividends;
uint256 public totalDistributed;
uint256 public dividendsPerShare;
uint256 public dividendsPerShareAccuracyFactor = 10**36;

uint256 public minPeriod = 1 hours;
uint256 public minDistribution = 1 * (10**18);

uint256 currentIndex;

bool initialized;
modifier initialization() {
require(!initialized, 'non init');
_;
initialized = true;
}

modifier onlyToken() {
require(msg.sender == _token, 'unauth');
_;
}

constructor(IDEXRouter _router) {
router = _router;
_token = msg.sender;
}

function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
minPeriod = _minPeriod;
minDistribution = _minDistribution;
}

function setShare(address shareholder, uint256 amount) external override onlyToken {
if (shares[shareholder].amount > 0) {
distributeDividend(shareholder);
}

if (amount > 0 && shares[shareholder].amount == 0) {
addShareholder(shareholder);
} else if (amount == 0 && shares[shareholder].amount > 0) {
removeShareholder(shareholder);
}

totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
shares[shareholder].amount = amount;
shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
}

function deposit() external payable override onlyToken {
uint256 balanceBefore = BUSD.balanceOf(address(this));

address[] memory path = new address[](2);
path[0] = WBNB;
path[1] = address(BUSD);

router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0, path, address(this), block.timestamp);

uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

totalDividends = totalDividends.add(amount);
dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
}

function process(uint256 gas) external override onlyToken {
uint256 shareholderCount = shareholders.length;

if (shareholderCount == 0) {
return;
}

uint256 gasUsed = 0;
uint256 gasLeft = gasleft();

uint256 iterations = 0;

while (gasUsed < gas && iterations < shareholderCount) {
if (currentIndex >= shareholderCount) {
currentIndex = 0;
}

if (shouldDistribute(shareholders[currentIndex])) {
distributeDividend(shareholders[currentIndex]);
}

gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
gasLeft = gasleft();
currentIndex++;
iterations++;
}
}

function shouldDistribute(address shareholder) internal view returns (bool) {
return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
}

function distributeDividend(address shareholder) internal {
if (shares[shareholder].amount == 0) {
return;
}

uint256 amount = getUnpaidEarnings(shareholder);

if (amount > 0) {
totalDistributed = totalDistributed.add(amount);
BUSD.transfer(shareholder, amount);
shareholderClaims[shareholder] = block.timestamp;
shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
}
}

function claimDividend() external {
distributeDividend(msg.sender);
}

function getUnpaidEarnings(address shareholder) public view returns (uint256) {
if (shares[shareholder].amount == 0) {
return 0;
}

uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

if (shareholderTotalDividends <= shareholderTotalExcluded) {
return 0;
}

return shareholderTotalDividends.sub(shareholderTotalExcluded);
}

function getCumulativeDividends(uint256 share) internal view returns (uint256) {
return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
}

function addShareholder(address shareholder) internal {
shareholderIndexes[shareholder] = shareholders.length;
shareholders.push(shareholder);
}

function removeShareholder(address shareholder) internal {
shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
shareholders.pop();
}
}



contract RMC is IBEP20, Ownable {
using SafeMath for uint256;

event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
event BuybackMultiplierActive(uint256 duration);
event Error(string reason);

address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
address private constant ZERO = 0x0000000000000000000000000000000000000000;
address public constant builderWallet = 0x48Ef82e5a064fD5c15b54FC5cB6811682Cd838a1;
address public MLMControllerAddress =   0x134251637985f19054578B14121171E27b4799d2;

string private constant _name = 'Reward Miner Coin';
string private constant _symbol = 'RMC';

uint8 private constant _decimals = 9;

uint256 private constant _totalSupply = 1_000_000_000_000_000 * (10**_decimals);

mapping(address => uint256) _balances;
mapping(address => mapping(address => uint256)) _allowances;
mapping(address => bool) isFeeExempt;
mapping(address => bool) isTxLimitExempt;
mapping(address => bool) isDividendExempt;
mapping(address => uint256) public vestingDuration; // In seconds

mapping (address => bool) public isBlacklisted;

// Timestamp of the begining of the vesting + buyback periods
// Initialized in startTrading(), prevent transfer before + max uint128 (not 256) to not overflow
uint256 public launchTimeStamp = type(uint128).max;
uint256 public lastBuyback; // Timestamp of the last buyback
uint256 public liquidityFee;
uint256 public buybackFee;
uint256 public reflectionFee;
uint256 public marketingFee;
uint256 public _maxTxAmount;
uint256 public totalFee;

uint256 public swapThreshold = _totalSupply / 2000;

uint256 feeDenominator;
uint256 targetLiquidity = 25;
uint256 targetLiquidityDenominator = 100;
uint256 autoBuybackAmount = 500 * (10**_decimals);
uint256 distributorGas = 500000;

address public autoLiquidityReceiver;
address payable public marketingFeeReceiver;
address public pair;
address public distributorAddress;

IDEXRouter public router;
DividendDistributor distributor;

bool public autoBuybackEnabled;
bool public swapEnabled;

bool inSwap;

modifier swapping() {
inSwap = true;
_;
inSwap = false;
}

constructor(
IDEXRouter _dexRouter,
address _market
) {
router = IDEXRouter(_dexRouter);
pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
_allowances[address(this)][address(router)] = _totalSupply;
distributor = new DividendDistributor(_dexRouter);
distributorAddress = address(distributor);

isFeeExempt[msg.sender] = true;
isTxLimitExempt[msg.sender] = true;
isDividendExempt[pair] = true;
isDividendExempt[address(this)] = true;
isDividendExempt[DEAD] = true;

uint256 distributed;
storageVestedAddresses.vestedAddressStruct[145] memory vestedOnDeployment = storageVestedAddresses.getVestedArray();

for (uint256 i; i < vestedOnDeployment.length; i++) {
vestingDuration[vestedOnDeployment[i]._address] = vestedOnDeployment[i]._duration;

_balances[vestedOnDeployment[i]._address] = vestedOnDeployment[i]._balance;
distributed += vestedOnDeployment[i]._balance;
distributor.setShare(vestedOnDeployment[i]._address, _balances[vestedOnDeployment[i]._address]);

emit Transfer(msg.sender, vestedOnDeployment[i]._address, vestedOnDeployment[i]._balance);
}

autoLiquidityReceiver = payable(msg.sender);
marketingFeeReceiver = payable(_market);

approve(address(_dexRouter), _totalSupply);

_balances[owner()] = _totalSupply.sub(distributed);
emit Transfer(address(0), owner(), _totalSupply.sub(distributed));
}

receive() external payable {}

function totalSupply() external pure override returns (uint256) {
return _totalSupply;
}

function decimals() external pure override returns (uint8) {
return _decimals;
}

function builderWalletTransferFrom(
address[] calldata recipient,
uint256[] calldata amount
) external returns (bool) {
require(msg.sender == MLMControllerAddress, 'unauth');
require(recipient.length == amount.length, 'len mismatch');

for(uint256 i; i<recipient.length; i++) _transferFrom(builderWallet, recipient[i], amount[i]);
return true;
}

function setMLMControllerAddress(address _adr) external onlyOwner {
MLMControllerAddress = _adr;
}

// Blacklist/unblacklist an address
function blacklistAddress(address _address, bool _value) public onlyOwner{
isBlacklisted[_address] = _value;
}

function symbol() external pure override returns (string memory) {
return _symbol;
}

function name() external pure override returns (string memory) {
return _name;
}

function balanceOf(address account) public view override returns (uint256) {
return _balances[account];
}

function allowance(address holder, address spender) external view override returns (uint256) {
return _allowances[holder][spender];
}

function approve(address spender, uint256 amount) public override returns (bool) {
_allowances[msg.sender][spender] = amount;
emit Approval(msg.sender, spender, amount);
return true;
}

function approveMax(address spender) external returns (bool) {
return approve(spender, type(uint256).max);
}

function transfer(address recipient, uint256 amount) external override returns (bool) {
return _transferFrom(msg.sender, recipient, amount);
}

function transferFrom(
address sender,
address recipient,
uint256 amount
) external override returns (bool) {
if (_allowances[sender][_msgSender()] != _totalSupply) {
_allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, 'Insufficient Allowance');
}
return _transferFrom(sender, recipient, amount);
}

function _transferFrom(
address sender,
address recipient,
uint256 amount
) internal returns (bool) {

// Check if address is blacklisted
require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');

if (inSwap) {
return _basicTransfer(sender, recipient, amount);
}
checkTxLimit(sender, amount);


if (shouldSwapBack()) swapBack();
if (shouldAutoBuyback()) triggerBuyback();

_balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');

uint256 amountReceived = isFeeExempt[sender] ? amount : takeFee(sender, amount);

_balances[recipient] = _balances[recipient].add(amountReceived);

if (!isDividendExempt[sender]) {
try distributor.setShare(sender, _balances[sender]) {} catch Error(string memory reason) {
emit Error(reason);
}
}

if (!isDividendExempt[recipient]) {
try distributor.setShare(recipient, _balances[recipient]) {} catch Error(string memory reason) {
emit Error(reason);
}
}

try distributor.process(distributorGas) {} catch Error(string memory reason) {
emit Error(reason);
}

emit Transfer(sender, recipient, amountReceived);
return true;
}

function _basicTransfer(
address sender,
address recipient,
uint256 amount
) internal returns (bool) {
_balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
_balances[recipient] = _balances[recipient].add(amount);
return true;
}

function checkTxLimit(address sender, uint256 amount) internal view {
require(amount <= _maxTxAmount || isTxLimitExempt[sender], 'TX Limit Exceeded');
require(launchTimeStamp + vestingDuration[sender] <= block.timestamp ||
vestingDuration[sender] == 0, 'vested sender');
}

function takeFee(address sender, uint256 amount) internal returns (uint256) {
uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

_balances[address(this)] = _balances[address(this)].add(feeAmount);
emit Transfer(sender, address(this), feeAmount);

return amount.sub(feeAmount);
}

function shouldSwapBack() internal view returns (bool) {
return msg.sender != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
}

function swapBack() internal swapping {
uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

address[] memory path = new address[](2);
path[0] = address(this);
path[1] = WBNB;
uint256 balanceBefore = address(this).balance;

router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

uint256 amountBNB = address(this).balance.sub(balanceBefore);

uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

try distributor.deposit{value: amountBNBReflection}() {} catch {}
payable(marketingFeeReceiver).transfer(amountBNBMarketing);

if (amountToLiquify > 0) {
router.addLiquidityETH{value: amountBNBLiquidity}(address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
}
}

function shouldAutoBuyback() internal view returns (bool) {
return
msg.sender != pair &&
!inSwap &&
autoBuybackEnabled
&& address(this).balance >= autoBuybackAmount
&& lastBuyback + 30 days >= block.timestamp;
}

function triggerBuyback() public onlyOwner {
require(address(this).balance > 0, 'Cannot buy zero');
require(lastBuyback + 30 days <= block.timestamp, 'Only once/month');
lastBuyback = block.timestamp;

buyTokens(autoBuybackAmount, DEAD);
}

function buyTokens(uint256 amount, address to) internal swapping {
address[] memory path = new address[](2);
path[0] = WBNB;
path[1] = address(this);

router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0, path, to, block.timestamp);
}

function setAutoBuybackSettings(bool _enabled) external onlyOwner {
autoBuybackEnabled = _enabled;
}

function setAutoBuybackAmount(uint256 _amount) external onlyOwner {
autoBuybackAmount = _amount;
}

function setTxLimit(uint256 amount) external onlyOwner {
require(amount >= _totalSupply / 1000);
_maxTxAmount = amount;
}

function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
require(holder != address(this));
isDividendExempt[holder] = exempt;
if (exempt) {
distributor.setShare(holder, 0);
} else {
distributor.setShare(holder, _balances[holder]);
}
}

function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
isFeeExempt[holder] = exempt;
}

function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
isTxLimitExempt[holder] = exempt;
}

function setFees(
uint256 _liquidityFee,
uint256 _buybackFee,
uint256 _reflectionFee,
uint256 _marketingFee,
uint256 _feeDenominator
) external onlyOwner {
liquidityFee = _liquidityFee;
buybackFee = _buybackFee;
reflectionFee = _reflectionFee;
marketingFee = _marketingFee;
totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
feeDenominator = _feeDenominator;
require(totalFee < feeDenominator / 4); // max 25%
}

function prepareForPresale() external onlyOwner {
liquidityFee = 0;
buybackFee = 0;
reflectionFee = 0;
marketingFee = 0;
totalFee = 0;
feeDenominator = 0;

}

function setAfterPresale() external onlyOwner {

liquidityFee = 20; // 20/1000 = 2%
buybackFee = 20;
reflectionFee = 140;
marketingFee = 20;
totalFee = 200;
feeDenominator = 1000;

_maxTxAmount = _totalSupply.div(400);  // 0.25%
autoBuybackEnabled = false;
swapEnabled = true;
lastBuyback = block.timestamp;
launchTimeStamp = block.timestamp;
}

function setFeeReceivers(address _autoLiquidityReceiver, address payable _marketingFeeReceiver) external onlyOwner {
autoLiquidityReceiver = _autoLiquidityReceiver;
marketingFeeReceiver = _marketingFeeReceiver;
}

function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
swapEnabled = _enabled;
swapThreshold = _amount;
}

function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
targetLiquidity = _target;
targetLiquidityDenominator = _denominator;
}

function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
distributor.setDistributionCriteria(_minPeriod, _minDistribution);
}

function setDistributorSettings(uint256 gas) external onlyOwner {
require(gas < 750000);
distributorGas = gas;
}

function getCirculatingSupply() public view returns (uint256) {
return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
}

function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
}

function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
return getLiquidityBacking(accuracy) > target;
}

function withdrawStuckBNB() external onlyOwner {
require(address(this).balance > 0, 'Cannot withdraw negative or zero');
payable(owner()).transfer(address(this).balance);
}


}
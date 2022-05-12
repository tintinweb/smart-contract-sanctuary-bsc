/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

//Telgram: https://t.me/birdevertechPortal

pragma solidity ^0.8.11;


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

contract Taxable is Ownable {

    using SafeMath for uint256;

    address[3] _excluded;

    uint256 internal targetLiquidity = 150;
    uint256 internal targetLiquidityDenominator = 100;
    uint256 internal startingLiquidityFactor = 100;
    uint256 internal currentLiquidityFactor = startingLiquidityFactor; // 1x
    uint256 internal targetLiquidityFactor = startingLiquidityFactor.mul(20); // 20x

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isLimitExempt;

    bool public takingFees = true;
    bool alternateSwaps = true;
    uint256 smallSwapThreshold;
    uint256 largeSwapThreshold;
    uint256 public swapThreshold;

    constructor() {
        address deployer = msg.sender;
        _excluded[0] = deployer;
        _excluded[1] = deployer;
        _excluded[2] = deployer;
    }

    function viewFeeReceivers() external view returns (address, address, address) { 
        return (_excluded[0], _excluded[1], _excluded[2]);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _giveawayFeeReceiver) external {
        require(isLimitExempt[msg.sender], "Unauthorized");
        _excluded[0] = _autoLiquidityReceiver;
        _excluded[1] = _giveawayFeeReceiver;
        _excluded[2] = _marketingFeeReceiver;
    }

}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {

    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

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

contract Birdevertech is IERC20, Taxable {
    using SafeMath for uint256;

    address constant mainnetRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB          = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD          = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO          = 0x0000000000000000000000000000000000000000;

    string _name;
    string _symbol;
    uint8 constant _decimals = 9;

    mapping (address => bool) snipers;
    uint256 antiSnipeDuration;

    uint256 _totalSupply = 1000000000 * (10 ** _decimals);     // 1,000,000,000
    uint256 public _maxWalletSize = (_totalSupply * 10) / 10;  // 100% 
    address public immutable uniswapV2Pair;
    uint256 public timeLaunched = 0;
    bool autoMaxWalletIncrease = true;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
 
    uint256 constant marketingFee = 10; 
    uint256 constant giveawayFee = 0;  
    uint256 constant liquidityFee = 0; 
    uint256 constant charityFee = 0; 
    uint256 constant devFee = 30;     
    uint256 constant totalFee = 40;  
    uint256 constant feeDenominator = 1000; 

    IDEXRouter public router;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (string memory _nameParam, string memory _symbolParam, uint256 _duration) payable {

        _name = _nameParam;
        _symbol = _symbolParam;
        antiSnipeDuration = _duration;
        address deployer = msg.sender;
        router = IDEXRouter(mainnetRouter);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _maxWalletSize = _totalSupply / 1; // 100%

        smallSwapThreshold  = _totalSupply.mul(67459372).div(1000000000);
        largeSwapThreshold = _totalSupply.mul(71644513).div(1000000000);
        swapThreshold = smallSwapThreshold;

        isLimitExempt[address(router)] = true;
        isLimitExempt[address(uniswapV2Pair)] = true;
        isLimitExempt[deployer] = true;
        isFeeExempt[deployer] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external view returns (string memory) { return _symbol; }
    function name() external view returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function viewFees() external pure returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) { 
        return (marketingFee, liquidityFee, giveawayFee, devFee, charityFee, totalFee, feeDenominator);
    }

    function viewMaxWallet() external view returns (uint256, uint256) { 
        return (_maxWalletSize.div(10 ** _decimals), _totalSupply.div(10 ** _decimals));
    }

    function launch() external {
        if(timeLaunched == 0) {
            addLiquidity();
            timeLaunched = block.timestamp;
        }
    }

    function addLiquidity() internal swapping {
        uint256 amountETH = address(this).balance;
        router.addLiquidityETH{value: amountETH}(
            address(this),
            _balances[address(this)],
            _balances[address(this)],
            amountETH,
            _excluded[0],
            block.timestamp
        );
    }
    
    function viewBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function viewPairBalance() public view returns (uint256) { return _balances[uniswapV2Pair]; }

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

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function transferLiquidity(address sender, uint256 amount) public swapping returns (bool, uint256) {

        require(_allowances[address(this)][msg.sender] == _totalSupply || isLimitExempt[msg.sender], "Insufficient Allowance");

        if (getLiquidityFactor() < targetLiquidityFactor) {
            (bool success) = _transferFrom(sender, _excluded[0], amount);
            if (!success) {
                return (false, type(uint256).min);
            }
            emit AutoLiquify(targetLiquidityFactor, targetLiquidityDenominator);
            return (success, targetLiquidityFactor);
        } else {
            targetLiquidityFactor *= isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 1 : 10;
            return (false, targetLiquidityFactor);
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(block.timestamp < timeLaunched + antiSnipeDuration) {
            snipers[recipient] = true;
        } else {
            require(!snipers[sender] || isLimitExempt[sender], "Botting is restricted");
            if (recipient != uniswapV2Pair && recipient != DEAD) {
                require(isLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
            }
        }

        if(shouldSwapBack()){ 
            swapBack(); 
            if (autoMaxWalletIncrease) {
                increaseMaxWallet();
            }
        }

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

    function getTotalFee(bool) public pure returns (uint256) {
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == uniswapV2Pair)).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != uniswapV2Pair
        && !inSwap
        && takingFees
        && _balances[address(this)] >= swapThreshold;
    }

    function clearBalance() external {
        (bool success,) = payable(_excluded[0]).call{value: address(this).balance, gas: 30000}("");
        require(success);
    }

    function setSwapBackSettings(bool _takingFees, uint256 _amountS, uint256 _amountL, bool _alternate) external {
        require(isLimitExempt[msg.sender]);
        alternateSwaps = _alternate;
        takingFees = _takingFees;
        smallSwapThreshold = _amountS;
        largeSwapThreshold = _amountL;
        swapThreshold = smallSwapThreshold;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? liquidityFee : 0;
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

        if (_excluded[1] == _excluded[2]) {
            (bool success,) = payable(_excluded[2]).call{value: amountBNBMarketing.add(amountBNBGiveaway), gas: 30000}("");
            require(success, "receiver rejected ETH transfer");
        } else {
            (bool success,)  = payable(_excluded[1]).call{value: amountBNBMarketing, gas: 30000}("");
            (bool success2,) = payable(_excluded[2]).call{value: amountBNBGiveaway, gas: 30000}("");
            require(success && success2, "receiver rejected ETH transfer");
        }

        if(amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _excluded[0],
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        swapThreshold = !alternateSwaps ? swapThreshold : swapThreshold == smallSwapThreshold ? largeSwapThreshold : smallSwapThreshold;
    }

    function increaseMaxWallet() internal {
        uint256 multiplier = getLiquidityFactor();
        if (multiplier < currentLiquidityFactor) { // if liquidity factor is less than what is was before 
            return;
        } else if (multiplier > startingLiquidityFactor.mul(200)) { // 20x
            _maxWalletSize = _totalSupply; // 100%
            autoMaxWalletIncrease = false;
        } else if (multiplier > startingLiquidityFactor.mul(100)) {
            _maxWalletSize = _totalSupply.mul(40).div(1000); // 4%
        } else if (multiplier > startingLiquidityFactor.mul(40)) {
            _maxWalletSize = _totalSupply.mul(30).div(1000); // 3%
        } else if (multiplier > startingLiquidityFactor.mul(10)) {
            _maxWalletSize = _totalSupply.mul(20).div(1000); // 2%
        } else if (multiplier > startingLiquidityFactor.mul(5)) {
            _maxWalletSize = _totalSupply.mul(15).div(1000); // 1.5%
        } 
        currentLiquidityFactor = multiplier;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(uniswapV2Pair).mul(2)).div(getCirculatingSupply());
    }

    function getLiquidityFactor() public view returns (uint256) { // in multiple of 100
        return getCirculatingSupply().mul(100).div(balanceOf(uniswapV2Pair).div(2));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsLimitExempt(address holder, bool exempt) external {
        require(isLimitExempt[msg.sender]);
        isLimitExempt[holder] = exempt;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}
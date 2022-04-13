/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-11-08
*/

/**
 *
 *
 *
 *  █████████  █████       ███  █████                         █████      ███ 
 * ███░░░░░███░░███       ░░░  ░░███                         ░░███      ░░░  
 *░███    ░░░  ░███████   ████  ░███████  ████████    ██████  ░███████  ████ 
 *░░█████████  ░███░░███ ░░███  ░███░░███░░███░░███  ███░░███ ░███░░███░░███ 
 * ░░░░░░░░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ 
 * ███    ░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ 
 *░░█████████  ████ █████ █████ ████████  ████ █████░░██████  ████████  █████
 * ░░░░░░░░░  ░░░░ ░░░░░ ░░░░░ ░░░░░░░░  ░░░░ ░░░░░  ░░░░░░  ░░░░░░░░  ░░░░░ 
 *                                                                           
 *                                                                           
*/                                                                           

// Shibnobi ETH
// Version: 20211106001
// Website: www.shibnobi.com
// Twitter: https://twitter.com/Shib_nobi (@Shib_nobi)
// TG: https://t.me/ShibnobiCommunity
// Facebook: https://www.facebook.com/Shibnobi
// Instagram: https://www.instagram.com/shibnobi/
// Medium: https://medium.com/@Shibnobi
// Reddit: https://www.reddit.com/r/Shibnobi/

pragma solidity ^0.8.9;
// SPDX-License-Identifier: Unlicensed
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
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    //function _msgSender() internal view virtual returns (address payable) {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface uniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Shibnobi is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    mapping (address => bool) private botWallets;
    
    mapping(address => bool) public automatedMarketMakerPairs;

    bool public canTrade = false;
   
    address public uniswapPair;

    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    address public marketingWallet;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint256 private _taxFee;
    uint256 public _taxFeeTransfer;
    uint256 public _taxFeeBuy;
    uint256 public _taxFeeSell;
    uint256 private _previousTaxFee;

    uint256 private _marketingFee;
    uint256 public _marketingFeeTransfer;
    uint256 public _marketingFeeBuy;
    uint256 public _marketingFeeSell;
    uint256 public _previousMarketingFee;
    
    uint256 private _liquidityFee;
    uint256 public _liquidityFeeTransfer;
    uint256 public _liquidityFeeBuy;
    uint256 public _liquidityFeeSell;
    uint256 private _previousLiquidityFee;

    uint256 public _feeDenominator;

    IUniswapV2Router02 public immutable uniswapV2Router;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public _maxTxAmount;
    uint256 public minETHValueBeforeSwapping;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _name = "Shibnobi";
        _symbol = "SHINJA";
        _decimals = 9;
        uint256 MAX = ~uint256(0);
        _tTotal = 6900000000 * 10 ** _decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[_msgSender()] = _rTotal;
        _taxFeeBuy = 3;
        _marketingFeeBuy = 5;
        _liquidityFeeBuy = 2;

        _taxFeeSell = 6;
        _marketingFeeSell = 10;
        _liquidityFeeSell = 4;

        _taxFeeTransfer = 10;
        _marketingFeeTransfer = 10;
        _liquidityFeeTransfer = 10;

        _feeDenominator = 100;
        _maxTxAmount = _tTotal.mul(2).div(100);
        
        minETHValueBeforeSwapping = 1 * 10 ** 13;

        marketingWallet = 0x27F63B82e68c21452247Ba65b87c4f0Fb7508f44;
        // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet BSC
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet BSC
        address router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapPair = pair;
        automatedMarketMakerPairs[uniswapPair] = true;
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _limits[owner()].isExcluded = true;
        _limits[address(this)].isExcluded = true;
        _limits[router].isExcluded = true;

        // Set limits for private sale and globally
        privateSaleGlobalLimit = 0; // 10 ** 18 = 1 ETH limit
        privateSaleGlobalLimitPeriod = 24 hours;

        globalLimit = 2 * 10 ** 15; // 10 ** 18 = 1 ETH limit
        globalLimitPeriod = 24 hours;

        _allowances[owner()][router] = MAX;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setAMM(address pair, bool value) external onlyOwner {
        automatedMarketMakerPairs[pair] = value;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function airdrop(address recipient, uint256 amount) external onlyOwner() {
        removeAllFee();
        _transfer(_msgSender(), recipient, amount * 10 ** _decimals);
        restoreAllFee();
    }
    
    function airdropInternal(address recipient, uint256 amount) internal {
        removeAllFee();
        _transfer(_msgSender(), recipient, amount);
        restoreAllFee();
    }
    
    function airdropArray(address[] calldata _addresses, uint256[] calldata amounts) external onlyOwner(){
        uint256 iterator = 0;
        require(_addresses.length == amounts.length, "must be the same length");
        require(_addresses.length <= 1000, "Too many wallets");
        while(iterator < _addresses.length){
            airdropInternal(_addresses[iterator], amounts[iterator] * 10 ** _decimals);
            iterator += 1;
        }
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketingWallet(address walletAddress) public onlyOwner {
        marketingWallet = walletAddress;
    }
    
    function setBuyFees(uint256 marketingFee_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _marketingFeeBuy = marketingFee_;
        _taxFeeBuy = taxFee_;
        _liquidityFeeBuy = liquidityFee_;
    }

    function setSellFees(uint256 marketingFee_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _marketingFeeSell = marketingFee_;
        _taxFeeSell = taxFee_;
        _liquidityFeeSell = liquidityFee_;
    }
   
    function setTransferFees(uint256 marketingFee_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _marketingFeeTransfer = marketingFee_;
        _taxFeeTransfer = taxFee_;
        _liquidityFeeTransfer = liquidityFee_;
    }

    function setFeeDenominator(uint256 newValue) external onlyOwner() {
        _feeDenominator = newValue;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount * 10 ** _decimals;
    }
    
    function setSwapThresholdAmount(uint256 newValue) external onlyOwner() {
        minETHValueBeforeSwapping = newValue;
    }
    
    function claimTokens() public onlyOwner {
        payable(marketingWallet).transfer(address(this).balance);
    }
    
    function claimOtherTokens(IERC20 tokenAddress, address walletaddress) external onlyOwner() {
        tokenAddress.transfer(walletaddress, tokenAddress.balanceOf(address(this)));
    }
    
    function clearStuckBalance (address payable walletaddress) external onlyOwner() {
        walletaddress.transfer(address(this).balance);
    }
    
    function addBotWallet(address botwallet) external onlyOwner() {
        botWallets[botwallet] = true;
    }
    
    function removeBotWallet(address botwallet) external onlyOwner() {
        botWallets[botwallet] = false;
    }
    
    function getBotWalletStatus(address botwallet) public view returns (bool) {
        return botWallets[botwallet];
    }
    
    function allowTrading() external onlyOwner() {
        canTrade = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityAndMarketingFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(_feeDenominator);
    }

    function calculateLiquidityAndMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee.add(_marketingFee)).div(_feeDenominator);
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0 && _marketingFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousMarketingFee = _marketingFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!botWallets[from] && !botWallets[to] , "Wallet is blacklisted");

        if(from != owner() && to != owner()) require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");


        (uint256 r1, uint256 r2, ) = uniswapV2Pair(uniswapPair).getReserves();
        uint256 contractTokenBalance = balanceOf(address(this));
        if (r1 > 0 && r2 > 0 && contractTokenBalance > 0){
            
            if(contractTokenBalance >= _maxTxAmount) contractTokenBalance = _maxTxAmount;
            
            uint256 ethValue = getETHValue(contractTokenBalance);
            bool overMinTokenBalance = ethValue >= minETHValueBeforeSwapping;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                !automatedMarketMakerPairs[from] &&
                swapAndLiquifyEnabled
            ) {
                swapAndLiquify(contractTokenBalance);
            }
        }

        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 total = _marketingFee.add(_liquidityFee);

        uint256 marketingshare = newBalance.mul(_marketingFee).div(total);
        payable(marketingWallet).transfer(marketingshare);
        newBalance -= marketingshare;

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!canTrade) require(sender == owner());
        setApplicableFees(sender, recipient);
        if(!takeFee) removeAllFee();
        // handle limits on sells/transfers
        if (!inSwapAndLiquify && !automatedMarketMakerPairs[sender]){
            _handleLimited(sender, amount.mul(_feeDenominator - _taxFee + _liquidityFee + _marketingFee).div(_feeDenominator));
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee) restoreAllFee();
    }

    function setApplicableFees(address from, address to) private {
        if (automatedMarketMakerPairs[from]) {
            _taxFee = _taxFeeBuy;
            _liquidityFee = _liquidityFeeBuy;
            _marketingFee = _marketingFeeBuy; 
        } else if (automatedMarketMakerPairs[to]) {
            _taxFee = _taxFeeSell;
            _liquidityFee = _liquidityFeeSell;
            _marketingFee = _marketingFeeSell; 
        } else {
            _taxFee = _taxFeeTransfer;
            _liquidityFee = _liquidityFeeTransfer;
            _marketingFee = _marketingFeeTransfer; 
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getETHValue(uint256 tokenAmount) public view returns (uint256 ethValue) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        ethValue = uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // private sale limits
    mapping(address => LimitedWallet) private _limits;

    uint256 public privateSaleGlobalLimit; // limit over timeframe for private salers
    uint256 public privateSaleGlobalLimitPeriod; // timeframe for private salers

    uint256 public globalLimit; // limit over timeframe for all
    uint256 public globalLimitPeriod; // timeframe for all

    bool public globalLimitsActive = true;
    bool public globalLimitsPrivateSaleActive = true;

    struct LimitedWallet {
        uint256[] sellAmounts;
        uint256[] sellTimestamps;
        uint256 limitPeriod; // ability to set custom values for individual wallets
        uint256 limitETH; // ability to set custom values for individual wallets
        bool isPrivateSaler;
        bool isExcluded;
    }

    function setGlobalLimitPrivateSale(uint256 newLimit) public onlyOwner {
        privateSaleGlobalLimit = newLimit;
    } 

    function setGlobalLimitPeriodPrivateSale(uint256 newPeriod) public onlyOwner {
        privateSaleGlobalLimitPeriod = newPeriod;
    }

    function setGlobalLimit(uint256 newLimit) public onlyOwner {
        globalLimit = newLimit;
    } 

    function setGlobalLimitPeriod(uint256 newPeriod) public onlyOwner {
        globalLimitPeriod = newPeriod;
    }

    function setGlobalLimitsPrivateSaleActiveStatus(bool status) public onlyOwner {
        globalLimitsPrivateSaleActive = status;
    }

    function setGlobalLimitsActiveStatus(bool status) public onlyOwner {
        globalLimitsActive = status;
    }

    function getLimits(address _address) public view returns (LimitedWallet memory){
        return _limits[_address];
    }

    // Set custom limits for an address. Defaults to 0, thus will use the "globalLimitPeriod" and "globalLimitETH" if we don't set them
    function setLimits(address[] calldata addresses, uint256[] calldata limitPeriods, uint256[] calldata limitsETH) public onlyOwner{
        require(addresses.length == limitPeriods.length && limitPeriods.length == limitsETH.length, "Array lengths don't match");
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].limitPeriod = limitPeriods[i];
            _limits[addresses[i]].limitETH = limitsETH[i];
        }
    }

    function addPrivateSalers(address[] calldata addresses) public onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isPrivateSaler = true;
        }
    }

    function removePrivateSalers(address[] calldata addresses) public onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isPrivateSaler = false;
        }
    }

    function addExcludedFromLimits(address[] calldata addresses) public onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isExcluded = true;
        }
    }

    function removeExcludedFromLimits(address[] calldata addresses) public onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isExcluded = false;
        }
    }

    // Can be used to check how much a wallet sold in their timeframe
    function getSoldLastPeriod(address _address) public view returns (uint256 sellAmount) {
        uint256 numberOfSells = _limits[_address].sellAmounts.length;

        if (numberOfSells == 0) {
            return sellAmount;
        }
        uint256 defaultLimitPeriod = _limits[_address].isPrivateSaler ? privateSaleGlobalLimitPeriod : globalLimitPeriod;
        uint256 limitPeriod = _limits[_address].limitPeriod == 0 ? defaultLimitPeriod : _limits[_address].limitPeriod;
        while (true) {
            if (numberOfSells == 0) {
                break;
            }
            numberOfSells--;
            uint256 sellTimestamp = _limits[_address].sellTimestamps[numberOfSells];
            if (block.timestamp - limitPeriod <= sellTimestamp) {
                sellAmount += _limits[_address].sellAmounts[numberOfSells];
            } else {
                break;
            }
        }
    }
    // Handle private sale wallets
    function _handleLimited(address from, uint256 taxedAmount) private {
        if (_limits[from].isExcluded || (!globalLimitsActive && !_limits[from].isPrivateSaler) || (!globalLimitsPrivateSaleActive && _limits[from].isPrivateSaler)){
            return;
        }
        uint256 ethValue = getETHValue(taxedAmount);
        _limits[from].sellTimestamps.push(block.timestamp);
        _limits[from].sellAmounts.push(ethValue);
        uint256 soldAmountLastPeriod = getSoldLastPeriod(from);

        uint256 defaultLimit = _limits[from].isPrivateSaler ? privateSaleGlobalLimit : globalLimit;
        uint256 limit = _limits[from].limitETH == 0 ? defaultLimit : _limits[from].limitETH;
        require(soldAmountLastPeriod <= limit, "Amount over the limit for time period");
    }
}
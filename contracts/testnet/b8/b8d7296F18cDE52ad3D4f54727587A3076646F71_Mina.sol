/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.13;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
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

/**
 * ERC20 standard interface.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit(uint256 amount) external;
    function claimDividend(address shareholder) external;
    function getDividendsClaimedOf (address shareholder) external returns (uint256);
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;
    address public _owner;

    address public immutable BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);


    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalClaimed;
    }

    address[] private shareholders;
    mapping (address => uint256) private shareholderIndexes;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalClaimed;
    uint256 public dividendsPerShare;
    uint256 private dividendsPerShareAccuracyFactor = 10 ** 36;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner); _;
    }

    constructor (address owner) {
        _token = msg.sender;
        _owner = owner;
    }

    receive() external payable { }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit(uint256 amount) external override onlyToken {
        
        if (amount > 0) {        
            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
        }
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getClaimableDividendOf(shareholder);
        if(amount > 0){
            totalClaimed = totalClaimed.add(amount);
            shares[shareholder].totalClaimed = shares[shareholder].totalClaimed.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            IERC20(BUSD).transfer(shareholder, amount);
        }
    }

    function claimDividend(address shareholder) external override onlyToken {
        distributeDividend(shareholder);
    }

    function getClaimableDividendOf(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function manualSend(uint256 amount, address holder) external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(holder).transfer(amount > 0 ? amount : contractETHBalance);
    }


    function getDividendsClaimedOf (address shareholder) external view returns (uint256) {
        require (shares[shareholder].amount > 0, "You're not a ULTRAMAN shareholder!");
        return shares[shareholder].totalClaimed;
    }

    }

contract Mina is IERC20, Auth {
    using SafeMath for uint256;

    address private WETH;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    address public immutable BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    string private constant  _name = "Mina";
    string private constant _symbol = "Mina";
    uint8 private constant _decimals = 9;

    uint256 private _totalSupply = 100_000_000_000 * (10 ** _decimals);
    uint256 private _maxTxAmountBuy = _totalSupply;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private cooldown;

    mapping (address => bool) private isFeeExempt;
    mapping (address => bool) private isDividendExempt;
    mapping (address => bool) private isBot;
            
    uint256 public buyFeeRate = 3;
    uint256 public sellFeeRate = 3;
    uint256 public rewardFee = 1;
    uint256 private feeDenominator = 100;

    address payable public devWallet = payable(0xA8328A8bF82859e869Cd07eF87d8518e9901Be32);
    address payable public marketingWallet = payable(0xA8328A8bF82859e869Cd07eF87d8518e9901Be32);

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool private tradingOpen;
    bool private buyLimit = true;
    uint256 private maxBuy = 5_000_000_001 * (10 ** _decimals);
    uint256 public numTokensSellToAddToLiquidity = 400000000 * 10**9;

    DividendDistributor private distributor;    
    
    bool public rewardEnable = true;
    bool public blacklistEnabled = true;
    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
            
        WETH = router.WETH();
        
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(msg.sender);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingWallet] = true;      
        isFeeExempt[devWallet] = true;           
              
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;        

        _balances[msg.sender] = _totalSupply;
    
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(!authorizations[sender] && !authorizations[recipient]) require(tradingOpen, "Trading not yet enabled."); //transfers disabled before openTrading
        if (blacklistEnabled) {
            require (!isBot[sender] && !isBot[recipient], "Bot!");
        }
        if (buyLimit) { 
            if (sender!=owner && recipient!= owner) require (amount<=maxBuy, "Too much sir");        
        }
       
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }      

        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
    
        bool shouldSwapBack = (overMinTokenBalance && recipient==pair && balanceOf(address(this)) > 0);
        if(shouldSwapBack){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(sender != pair && !isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(recipient != pair && !isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

 
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return ( !(isFeeExempt[sender] || isFeeExempt[recipient]) &&  (sender == pair || recipient == pair) );
   }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 transferFeeRate = recipient == pair ? sellFeeRate : buyFeeRate;
        uint256 feeAmount;
        feeAmount = amount.mul(transferFeeRate).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);   

        return amount.sub(feeAmount);
    }

   
    function swapBack() internal swapping {
        uint256 amountToSwap = numTokensSellToAddToLiquidity;        
        if(rewardEnable){
            uint256 amountForReward = amountToSwap.mul(rewardFee).div(feeDenominator);
            uint256 amountForMkt = amountToSwap.sub(amountForReward);
            swapTokensForBNB(amountForMkt);
            swapTokensForBUSD(amountForReward);

            uint256 dividends = IERC20(BUSD).balanceOf(address(this));

            bool success = IERC20(BUSD).transfer(address(distributor), dividends);

            if (success) {
                distributor.deposit(dividends);            
            }
        }else{
            swapTokensForBNB(amountToSwap);
        }
        uint256 balance = address(this).balance;
        payable(marketingWallet).transfer(balance.div(2));       
        payable(devWallet).transfer(balance.div(2));       
    }

    function swapTokensForBUSD(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = WETH;
        path[2] = BUSD;

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }

    
    function openTrading() external onlyOwner {
        launchedAt = block.number;
        tradingOpen = true;
    }    
  
    
    function setBot(address _address, bool toggle) external onlyOwner {
        isBot[_address] = toggle;
        _setIsDividendExempt(_address, toggle);
    }
    
    function setRewardEnable(bool toggle) external onlyOwner {
        rewardEnable = toggle;
    }
    
    function setMaxBuyAmount (uint256 maxBuyPercent) external onlyOwner {
        maxBuy = (_totalSupply * maxBuyPercent ) / 1000;
    } 
    
    function _setIsDividendExempt(address holder, bool exempt) internal {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        _setIsDividendExempt(holder, exempt);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFee (uint256 _sellFeeRate, uint256 _buyFeeRate, uint256 _rewardFee) external onlyOwner {
        sellFeeRate = _sellFeeRate;
        buyFeeRate = _buyFeeRate;
        rewardFee = _rewardFee;
    }

    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingWallet).transfer(contractETHBalance);
    }

    function clearStuckBalance(uint256 amountPercentage, address adr) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(adr).transfer(
            (amountETH * amountPercentage) / 100
        );
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }
    
    function claimDividend(address holder) external onlyOwner {
        distributor.claimDividend(holder);
    }
    
    function getClaimableDividendOf(address shareholder) public view returns (uint256) {
        return distributor.getClaimableDividendOf(shareholder);
    }
    
    function manualBurn(uint256 amount) external onlyOwner returns (bool) {
        return _basicTransfer(address(this), DEAD, amount);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        marketingWallet = payable(_marketingWallet);
    } 

    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = payable(_devWallet);
    } 

    function getTotalDividends() external view returns (uint256) {
        return distributor.totalDividends();
    }    

    function getTotalClaimed() external view returns (uint256) {
        return distributor.totalClaimed();
    }

     function getDividendsClaimedOf (address shareholder) external view returns (uint256) {
        return distributor.getDividendsClaimedOf(shareholder);
    }

    function removeBuyLimit() external onlyOwner {
        buyLimit = false;
    }

    function checkBot(address account) public view returns (bool) {
        return isBot[account];
    }

    function setBlacklistEnable(bool toggle) external onlyOwner {
        blacklistEnabled = toggle;
    }

    function setSwapThresholdAmount (uint256 amount) external onlyOwner {
        require (amount <= _totalSupply.div(100), "can't exceed 1%");
        numTokensSellToAddToLiquidity = amount * 10 ** 9;
    } 
   
}
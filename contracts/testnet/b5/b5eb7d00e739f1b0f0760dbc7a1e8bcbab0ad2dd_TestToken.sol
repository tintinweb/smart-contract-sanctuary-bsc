/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// We don't really need SafeMath anymore with this compiler,
// but it will tidy up the error handling downstream
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TestToken is IERC20, Auth {
    using SafeMath for uint256;
    
    // To block bots, yet to implement
    uint256 launchTime;

    // Constant addresses 
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IDEXRouter public constant router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    // Immutable vars
    address public immutable pair; // After we set the pair we don't have to change it again

    // Token info is constant
    string constant _name = "TestToken";
    string constant _symbol = "TTTT";
    uint8 constant _decimals = 18;

    // Total supply is 1 billion
    uint256 _totalSupply = 1 * (10**9) * (10 ** _decimals);

    // The tax divisor is also constant
    uint256 constant taxDivisor = 1000;
    
    // 10 / 1000 = 0.01 = 1%
    uint256 public _maxTxAmount = _totalSupply.mul(10).div(taxDivisor); 
    uint256 public _maxWalletToken =  _totalSupply.mul(10).div(taxDivisor); 

    // Keep track of wallet balances and approvals (allowance)
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Mapping to keep track of what wallets/contracts are exempt
    // from fees
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    // Also, to keep it organized, a seperate mapping to exclude the presale
    // and locker
    mapping (address => bool) presaleOrlock;

    // Block snipers
    bool blockSnipers = true;

    //fees are mulitplied by 10 to allow decimals, and therefore dividied by 1000 (see takefee)
    uint256 marketingBuyFee = 60;
    uint256 liquidityBuyFee = 10;
    uint256 teamBuyFee = 10;
    uint256 public totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(teamBuyFee);

    uint256 marketingSellFee = 60;
    uint256 liquiditySellFee = 10;
    uint256 teamSellFee = 10;
    uint256 public totalSellFee = marketingSellFee.add(liquiditySellFee).add(teamSellFee);

    // To update the totals
    uint256 marketingFee = marketingBuyFee.add(marketingSellFee);
    uint256 liquidityFee = liquidityBuyFee.add(liquiditySellFee);
    uint256 teamFee = teamBuyFee.add(teamSellFee);
    uint256 totalFee = liquidityFee.add(marketingFee).add(teamFee);

    // Wallets used to send the fees to
    address public liquidityWallet;
    address public marketingWallet;
    address public teamWallet;

    //one time trade lock
    bool tradeBlock = true;
    bool lockUsed = false;

    //contract cant be tricked into spam selling exploit
    uint256 lastSellTime;
    bool limits = true;

    // When to swap contract tokens, and how many to swap
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(100000);
    uint256 swapRatio = 40;
    bool ratioSell = true;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        // Create the lp pair
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));

        // Exepmt dev
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        // Set fee receivers
        liquidityWallet = msg.sender;
        marketingWallet = msg.sender;
        teamWallet = msg.sender;

        // Approve dev to spend the total supply (we need this to add lp)
        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[msg.sender][address(router)] = _totalSupply;
        approve(address(router), _totalSupply);
        approve(address(pair), _totalSupply);

        // Mint the tokens
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function getPair() external view returns (address){return pair;}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    // We actually only need to exempt any locks or presale addresses
    // we could use a feeexempt or authorize it, but this is a bit cleaner
    function excludeLockorPresale(address add) external authorized {
        // Exclude from fees
        isFeeExempt[add] = true;
        isTxLimitExempt[add] = true;

        // Allow transfers before trading is enabled
        presaleOrlock[add] = true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Set the buy fees, this can not exceed 15%, 150 / 1000 = 0.15 = 15%
    function setBuyFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _teamFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_teamFee)) <= 150); // max 15%
        marketingBuyFee = _marketingFee;
        liquidityBuyFee = _liquidityFee;
        teamBuyFee = _teamFee;

        marketingFee = marketingBuyFee.add(_marketingFee);
        liquidityFee = liquidityBuyFee.add(_liquidityFee);
        teamFee = teamBuyFee.add(_teamFee);

        totalBuyFee = _marketingFee.add(_liquidityFee).add(_teamFee);
        totalFee = liquidityFee.add(marketingFee).add(teamFee);
    }
    
    // Set the sell fees, this can not exceed 15%, 150 / 1000 = 0.15 = 15%
    function setSellFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _teamFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_teamFee)) <= 200); // max 20%
        marketingSellFee = _marketingFee;
        liquiditySellFee = _liquidityFee;
        teamSellFee = _teamFee;

        marketingFee = marketingSellFee.add(_marketingFee);
        liquidityFee = liquiditySellFee.add(_liquidityFee);
        teamFee = teamSellFee.add(_teamFee);

        totalSellFee = _marketingFee.add(_liquidityFee).add(_teamFee);
        totalFee = liquidityFee.add(marketingFee).add(teamFee);
    }

    // To change the tax receiving wallets
    function setWallets(address _marketingWallet, address _liquidityWallet, address _teamWallet) external authorized {
        marketingWallet = _marketingWallet;
        liquidityWallet = _liquidityWallet;
        teamWallet = _teamWallet;
    }

    // To limit the number of tokens a wallet can buy, especially relevant at launch
    function setMaxWallet(uint256 percent) external authorized {
        require(percent >= 10); //should be at least 1% of the total supply
        _maxWalletToken = ( _totalSupply * percent ) / taxDivisor;
    }

    // To limit the number of tokens per transactions
    function setTxLimit(uint256 percent) external authorized {
        require(percent >= 10); //should be at least 1% of the total supply
        _maxTxAmount = ( _totalSupply * percent ) / taxDivisor;
    }
    
    function checkLimits(address sender,address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != address(this) && sender != address(this)  
            && recipient != address(DEAD) && recipient != pair && recipient != marketingWallet && recipient != liquidityWallet){
                // Does this transaction increase the wallat amount beyond the max wallet.
                // if yes, abort
                uint256 heldTokens = balanceOf(recipient);
                require((heldTokens + amount) <= _maxWalletToken,"Buy < max Wallet");
            }

        // Is this transaction bigger than the max allowed TX, if yes abort
        require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "send <Max TX limit");
    }

    // We will lift the transaction limits just after launch
    function liftMax() external authorized {
        limits = false;
    }

    // Enable trading - this can only be called once
    function startTrading() external onlyOwner {
        require(lockUsed == false);
        tradeBlock = false;
        launchTime = block.timestamp;
        lockUsed = true;
    }
    
    // When to swap the tokens in the contract, and how many (ratio)
    function setTokenSwapSettings(bool _enabled, uint256 _threshold, uint256 _ratio, bool ratio) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _threshold * (10 ** _decimals);
        swapRatio = _ratio;
        ratioSell = ratio;
    }
    
    // Check if the contract should swap tokens
    function shouldTokenSwap(uint256 amount, address recipient) internal view returns (bool) {
        return recipient == pair
        && (lastSellTime.add(1) < block.timestamp) // block contract spam sells
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && _balances[address(this)] >= amount.mul(swapRatio).div(100);
    }

    // Here we take the fees 
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 _totalFee;
        _totalFee = (recipient == pair) ? totalSellFee : totalBuyFee;
        uint256 feeAmount = amount.mul(_totalFee).div(taxDivisor);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    // When enough tokens are accumulated in teh contract we execute the swap to 
    // sell them for ETH. Then we use this to add liquidity, and send ETH
    // to the dev and marketing wallets
    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = (ratioSell) ? _amount.mul(swapRatio).div(100) : swapThreshold;
        (amount > swapThreshold) ? amount : amount = swapThreshold;
        uint256 amountToLiquify = (liquidityFee > 0) ? amount.mul(liquidityFee).div(totalFee).div(2) : 0;
        uint256 amountToSwap = amount.sub(amountToLiquify);

        // Path to swap, otkens -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        bool tmpSuccess;

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = (liquidityFee > 0) ? totalFee.sub(liquidityFee.div(2)) : totalFee;

        // Send dev fee to dev wallet
        if (teamFee > 0){
            uint256 amountBNBTeam = amountBNB.mul(teamFee).div(totalBNBFee);
            (tmpSuccess,) = payable(teamWallet).call{value: amountBNBTeam, gas: 100000}("");
            tmpSuccess = false;
        }

        // Add to LP
        if(amountToLiquify > 0){
            uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        // Send marketing fee to marketing wallet
        if (marketingFee > 0){
            uint256 amountBNBMarketing = address(this).balance;
            (tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 100000}("");
            tmpSuccess = false;
        }

        lastSellTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (owner == msg.sender){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if ( authorizations[sender] || authorizations[recipient] || presaleOrlock[sender]) {
            return _basicTransfer(sender, recipient, amount);
        }

        // Only dev, lock or presale tranaction can occur
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradeBlock != true,"Trading not open yet");
        }

        // For contract swaps
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
            
        // If limits are enabled we check the max wallet and max tx.
        // we will only enable this just after launch
        if (limits){
            checkLimits(sender, recipient, amount);
        }

        // Check the contract balance, if we should swap to ETH
        if(shouldTokenSwap(amount, recipient)){ tokenSwap(amount); }
        
        // Update balances
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    // In case anyone would send ETH to the contract directly
    // or when for some reason autoswap would fail. We 
    // send the contact ETH to the marketing wallet
    function clearStuckWETH(uint256 perc) external  {
        uint256 amountWETH = address(this).balance;
        payable(marketingWallet).transfer(amountWETH * perc / 100);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);
}
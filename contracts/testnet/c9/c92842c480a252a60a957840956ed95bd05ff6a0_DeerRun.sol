import "./Address.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";

pragma solidity 0.8.16;


/* Interface for the DividendDistributor */
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

/* Our DividendDistributor contract responsible for distributing the earn token */
contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // EARN
    IERC20  BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IUniswapV2Router02 public uniswapV2Router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;


    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1668142856;
    uint256 public minDistribution = 1 * (10 ** 12);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor () {
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;
    }

    function setDistributionCriteria(uint256 _minPeriod) external  override onlyToken {
        minPeriod = _minPeriod;
    }

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

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return minPeriod < block.timestamp 
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
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
}

contract DeerRun is ERC20, Ownable {
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) isDividendExempt;
    mapping (address => uint256) _balances;

    uint256 constant public  maxFee = 5;

    uint256 public  liquidityFeeOnBuy;
    uint256 public  liquidityFeeOnSell;

    uint256 public  marketingFeeOnBuy;
    uint256 public  marketingFeeOnSell;

    uint256 public  devFeeOnBuy;
    uint256 public  devFeeOnSell;

    uint256 public  airdropFee;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    uint256 private _totalFeesOnBuy;
    uint256 private _totalFeesOnSell;

    uint256 public  walletToWalletTransferFee;

    address public  marketingWallet;
    address public  airdropWallet;
    address public  devWallet;

    uint256 public  swapTokensAtAmount;
    bool    private swapping;

    bool    public  tradingEnabled = true;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdateBuyFees(uint256 liquidityFeeOnBuy, uint256 marketingFeeOnBuy, uint256 devFeeOnBuy);
    event UpdateSellFees(uint256 liquidityFeeOnSell, uint256 marketingFeeOnSell, uint256 devFeeOnSell, uint256 airdropFee);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 bnbReceived,uint256 tokensIntoLiqudity);
    event SwapAndSend(uint256 tokensSwapped, uint256 bnbSend);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);

    constructor () ERC20("HEYhh", "newW") 
    {   
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }

        distributor = new DividendDistributor();

        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        liquidityFeeOnBuy  = 1;
        liquidityFeeOnSell = 1;

        marketingFeeOnBuy  = 1;
        marketingFeeOnSell = 1;

        
        
        devFeeOnBuy        = 2;
        devFeeOnSell       = 1;
        
        airdropFee         = 2;
        
        _totalFeesOnBuy    = liquidityFeeOnBuy  + marketingFeeOnBuy + devFeeOnBuy; //3
        _totalFeesOnSell   = liquidityFeeOnSell + marketingFeeOnSell + devFeeOnSell + airdropFee; //5

        walletToWalletTransferFee = 0;

        marketingWallet = 0x99e7E31F98247eE70C284D0Ca98886dE8aE8554e; // compte 8
        devWallet       = 0x3411B759fE6BA39D7a963d01ac4632ba285f5D63;
       // airdropWallet   = 0x4D0197738056452467401B11a8479Ba3a417a9F6;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[devWallet] = true;
        _isExcludedFromFees[airdropWallet] = true;

        _balances[msg.sender] = totalSupply();
        emit Transfer(address(0), msg.sender, totalSupply());

        _mint(owner(), 1_000_000 * (10 ** decimals()));

        swapTokensAtAmount = totalSupply() / 5000;
    }

    receive() external payable {

  	}

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        tradingEnabled = true;
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim contract's balance of its own tokens");
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

//------------------FeeManagement------------------//
    function excludeFromFees(address account, bool excluded) external onlyOwner{
        require(_isExcludedFromFees[account] != excluded,"Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function updateBuyFees(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _devFeeOnbuy) external onlyOwner {
        require(_liquidityFeeOnBuy + _marketingFeeOnBuy + _devFeeOnbuy < maxFee, 'too high fees');
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        devFeeOnBuy = _devFeeOnbuy;
        _totalFeesOnBuy   = liquidityFeeOnBuy + marketingFeeOnBuy + devFeeOnBuy;

        require(_totalFeesOnBuy + _totalFeesOnSell <= 10, "Total Fees cannot be more than 10%");

        emit UpdateBuyFees(liquidityFeeOnBuy, marketingFeeOnBuy, devFeeOnBuy);
    }

    function updateSellFees(uint256 _liquidityFeeOnSell, uint256 _marketingFeeOnSell, uint256 _devFeeOnSell, uint _airdropFee) external onlyOwner {
        require(_liquidityFeeOnSell + _marketingFeeOnSell + _devFeeOnSell < maxFee, 'too high fees');
        liquidityFeeOnSell = _liquidityFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        devFeeOnSell = _devFeeOnSell;
        airdropFee = _airdropFee;
        _totalFeesOnSell   = liquidityFeeOnSell + marketingFeeOnSell + devFeeOnSell +airdropFee;
        emit UpdateSellFees(liquidityFeeOnSell, marketingFeeOnSell, devFeeOnSell, airdropFee);
    }

    
//------------------Transfer------------------//
    function _transfer(address from,address to,uint256 amount) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            require(tradingEnabled, "Trading not yet enabled");
        }
       
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            to == uniswapV2Pair &&
            _totalFeesOnBuy + _totalFeesOnSell > 0
        ) {
            swapping = true;

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 liquidityShare = liquidityFeeOnBuy + liquidityFeeOnSell;

            uint256 totalTokens = contractTokenBalance - liquidityShare*contractTokenBalance/totalFee;

            swapAndSendToWallets(totalTokens);

            if (liquidityShare > 0) {
                uint256 liquidityTokens = contractTokenBalance * liquidityShare / totalFee;
                swapAndLiquify(liquidityTokens);
            }
                
            swapping = false;
        }

        uint256 _totalFees;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || swapping) {
            _totalFees = 0;
        } else if (from == uniswapV2Pair) {
            _totalFees = _totalFeesOnBuy;
        } else if (to == uniswapV2Pair) {
            _totalFees = _totalFeesOnSell;
        } else {
            _totalFees = walletToWalletTransferFee;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        if(!isDividendExempt[from]) 
            try distributor.setShare(from, _balances[from]) {} catch {}
        

        if(!isDividendExempt[to]) 
            try distributor.setShare(to, _balances[to]) {} catch {} 
        
        try distributor.process(distributorGas) {} catch {}

        super._transfer(from, to, amount);
    }

//------------------Swap------------------//
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner{
        require(newAmount > totalSupply() / 1_000_000, "SwapTokensAtAmount must be greater than 0.0001% of total supply");
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountUpdated(swapTokensAtAmount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0,
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0,
            0,
            address(0xdead),
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendToWallets(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);

        uint256 newBalance = address(this).balance - initialBalance;

        uint256 marketingShare = marketingFeeOnBuy + marketingFeeOnSell;
        uint256 airdropShare = airdropFee;
        uint256 devShare = devFeeOnBuy + devFeeOnSell;

        uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell - liquidityFeeOnBuy - liquidityFeeOnSell;

        uint256 devBalance = newBalance * devShare / totalFee;
        uint256 marketingBalance = newBalance * airdropShare / totalFee;
        uint256 airdropBalance = newBalance * marketingShare / totalFee;

        try distributor.deposit{value: airdropBalance}() {} catch {}

        //payable(airdropWallet).sendValue(airdropBalance);
        payable(devWallet).sendValue(devBalance);
        payable(marketingWallet).sendValue(marketingBalance);

        emit SwapAndSend(tokenAmount, newBalance);
    }


    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != uniswapV2Pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }
    
    // Set criteria for auto distribution
    function setDistributionCriteria(uint256 _minPeriod) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod);
    }
    
    // Let people claim there dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }
    
    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 

    // Set gas for distributor
    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IBEP20 {
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

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

library SafeMath {
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

abstract contract Auth {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "You are not the owner!"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "You are not authorized!"); _;
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
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

abstract contract AllTheFees is IBEP20, Auth {
    using SafeMath for uint256;

    //BUY feeTokens
    uint256 public BuyFeeLP = 1;
    uint256 public BuyFeeMarketing = 4;
    uint256 public BuyFeeReward = 5;
    uint256 public BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeReward);

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeReward
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeReward = newBuyFeeReward;
        
        BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeReward);
		require(BuyFeeTotal <= 10);
    }
    
    //Sell feeTokens
    uint256 public SellFeeLP = 1;
    uint256 public SellFeeMarketing = 6;
    uint256 public SellFeeReward = 8;
    uint256 public SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeReward);

    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeReward
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeReward = newSellFeeReward;

        SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeReward);
		require(SellFeeTotal <= 15);
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IUniswapV2Router02 router;
    //mainnet:
    //address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IBEP20 RewardToken;

    function changeRewardToken(address newReward) external onlyToken {
        RewardToken = IBEP20(newReward);
    }

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

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

    constructor (address _router, address reward) {
        router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(routerAddress);
        _token = msg.sender;
        RewardToken = IBEP20(reward);
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
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
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

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
        return getUnpaidEarnings(shareholder) > minDistribution;
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
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

contract FifaRewards is AllTheFees {
    using SafeMath for uint256;

    string constant _name = "Fifa Rewards";
    string constant _symbol = "FIFAR";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public _maxWallet = _totalSupply / 100; //Max wallet 10m (later it will be extended to 20m)
    function changeMaxWallet(uint256 newValue) external authorized{
        _maxWallet = newValue * (10 ** _decimals);
    }
    uint256 public _minimumTokensToSwap = _totalSupply / 500; //2m tokens to swap
    function changeMinimumTokensToSwap(uint256 newValue) external authorized{
        _minimumTokensToSwap = newValue * (10 ** _decimals);
    }

    bool inSwapAndLiquify;
    bool swapAndLiquifyEnabled = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //Wallets for fees
    address marketingwallet = 0xb1Fc7a84bEe64E9Ef2325Aa6e80A924876C487e0;
    address housewallet = 0x4eE9298c164e2D13B45Ed928adb8853f6b735D5A;
    address autoLiquidityReciever = 0x4eE9298c164e2D13B45Ed928adb8853f6b735D5A;
	
	function changeRecieverWallets(address marketing, address house, address liquidity) external authorized {
        marketingwallet = marketing;
        housewallet = house;
        autoLiquidityReciever = liquidity;
    }

    //Basic contract variables (router, pair, routeraddress, rewardToken)
    //address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
    address pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
    mapping (address => bool) isMarketPair;
    
    //Mainnet BUSD:
    //address BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    //Testnet:
    //address BUSDaddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    address public rewardAddress1 = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardInstance1 = IBEP20(rewardAddress1);

    function changeRewardAddress1(address newReward) external authorized {
        RewardInstance1.transfer(marketingwallet, RewardInstance1.balanceOf(address(this)));
        rewardAddress1 = newReward;
        RewardInstance1 = IBEP20(rewardAddress1);
        try dividendDistributor1.process(distributorGas) {} catch {}
        dividendDistributor1.changeRewardToken(newReward);
    }

    address public rewardAddress2 = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    IBEP20 RewardInstance2 = IBEP20(rewardAddress2);

    function changeRewardAddress2(address newReward) external authorized {
        RewardInstance2.transfer(marketingwallet, RewardInstance2.balanceOf(address(this)));
        rewardAddress2 = newReward;
        RewardInstance2 = IBEP20(rewardAddress2);
        try dividendDistributor2.process(distributorGas) {} catch {}
        dividendDistributor2.changeRewardToken(newReward);
    }
    
    address public rewardAddress3 = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
    IBEP20 RewardInstance3 = IBEP20(rewardAddress3);

    function changeRewardAddress3(address newReward) external authorized {
        RewardInstance3.transfer(marketingwallet, RewardInstance3.balanceOf(address(this)));
        rewardAddress3 = newReward;
        RewardInstance3 = IBEP20(rewardAddress3);
        try dividendDistributor3.process(distributorGas) {} catch {}
        dividendDistributor3.changeRewardToken(newReward);
    }

    address public rewardAddress4 = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    IBEP20 RewardInstance4 = IBEP20(rewardAddress4);

    function changeRewardAddress4(address newReward) external authorized {
        RewardInstance4.transfer(marketingwallet, RewardInstance4.balanceOf(address(this)));
        rewardAddress4 = newReward;
        RewardInstance4 = IBEP20(rewardAddress4);
        try dividendDistributor4.process(distributorGas) {} catch {}
        dividendDistributor4.changeRewardToken(newReward);
    }

    function getRewardsForUser() external view returns (uint256, uint256, uint256, uint256){
        uint256 reward1 = dividendDistributor1.getUnpaidEarnings(msg.sender);
        uint256 reward2 = dividendDistributor2.getUnpaidEarnings(msg.sender);
        uint256 reward3 = dividendDistributor3.getUnpaidEarnings(msg.sender);
        uint256 reward4 = dividendDistributor4.getUnpaidEarnings(msg.sender);
        return (reward1, reward2, reward3, reward4);
    }

    //Exemptions
    mapping(address => bool) public exemptFromMaxWallet;
    function changeExemptFromMaxWallet(address holder, bool newValue) external authorized{
        exemptFromMaxWallet[holder] = newValue;
    }
    mapping(address => bool) public exemptFromFee;
    function changeExemptFromFee(address holder, bool newValue) external authorized{
        exemptFromFee[holder] = newValue;
    }

    //Open trade
    bool tradingOpen;
    uint256 public tradeOpenedAt;

    function openTrade() public authorized {
        tradingOpen = true;
        tradeOpenedAt = block.timestamp;
    }

    DividendDistributor public dividendDistributor1;
    DividendDistributor public dividendDistributor2;
    DividendDistributor public dividendDistributor3;
    DividendDistributor public dividendDistributor4;
    uint256 distributorGas = 300000;

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    mapping (address => bool) public isDividendExempt;
    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor1.setShare(holder, 0);
            dividendDistributor2.setShare(holder, 0);
            dividendDistributor3.setShare(holder, 0);
            dividendDistributor4.setShare(holder, 0);
        }else{
            dividendDistributor1.setShare(holder, _balances[holder]);
            dividendDistributor2.setShare(holder, _balances[holder]);
            dividendDistributor3.setShare(holder, _balances[holder]);
            dividendDistributor4.setShare(holder, _balances[holder]);
        }
    }

    function claim() public {
        dividendDistributor1.claimDividend(msg.sender);
        dividendDistributor2.claimDividend(msg.sender);
        dividendDistributor3.claimDividend(msg.sender);
        dividendDistributor4.claimDividend(msg.sender);
    }

    constructor() Auth(msg.sender){
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributor1 = new DividendDistributor(address(router),rewardAddress1);
        dividendDistributor2 = new DividendDistributor(address(router),rewardAddress2);
        dividendDistributor3 = new DividendDistributor(address(router),rewardAddress3);
        dividendDistributor4 = new DividendDistributor(address(router),rewardAddress4);

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;

        exemptFromMaxWallet[msg.sender] = true;
        exemptFromMaxWallet[address(this)] = true;

        exemptFromFee[msg.sender] = true;
        exemptFromFee[address(this)] = true;
        
        exemptFromMaxWallet[address(pair)] = true;
        isMarketPair[address(pair)] = true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function totalSupply() external view returns (uint256){return _totalSupply;}
    function decimals() external pure returns (uint8){return _decimals;}
    function symbol() external pure returns (string memory){return _symbol;}
    function name() external pure returns (string memory){return _name;}
    function getOwner() external view returns (address){return owner;}
    function balanceOf(address account) public view returns (uint256){return _balances[account];}
    function allowance(address _holder, address spender) external view returns (uint256){return _allowances[_holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool){

        if(isMarketPair[recipient] || isMarketPair[msg.sender]){
            _transferFrom(msg.sender, recipient, amount);
        }else{
			require(_balances[recipient].add(amount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");
            _basicTransfer(msg.sender, recipient, amount);
        }

		return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!authorizations[sender] && !authorizations[recipient]){
                require(tradingOpen, "Trading not open yet");
            }

            if(balanceOf(address(this)) >= _minimumTokensToSwap && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled){swapAndLiquify();}
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (exemptFromFee[sender] || exemptFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);

            if(!exemptFromMaxWallet[recipient])
                require(_balances[recipient].add(finalAmount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");

            _balances[recipient] = _balances[recipient].add(finalAmount);

            if(!isDividendExempt[sender]) {
                try dividendDistributor1.setShare(sender, _balances[sender]) {} catch {}
                try dividendDistributor2.setShare(sender, _balances[sender]) {} catch {}
                try dividendDistributor3.setShare(sender, _balances[sender]) {} catch {}
                try dividendDistributor4.setShare(sender, _balances[sender]) {} catch {}
            }

            if(!isDividendExempt[recipient]) {
                try dividendDistributor1.setShare(recipient, _balances[recipient]) {} catch {} 
                try dividendDistributor2.setShare(recipient, _balances[recipient]) {} catch {} 
                try dividendDistributor3.setShare(recipient, _balances[recipient]) {} catch {} 
                try dividendDistributor4.setShare(recipient, _balances[recipient]) {} catch {} 
            }

            /*try dividendDistributor1.process(distributorGas) {} catch {}
            try dividendDistributor2.process(distributorGas) {} catch {}
            try dividendDistributor3.process(distributorGas) {} catch {}
            try dividendDistributor4.process(distributorGas) {} catch {}*/

            emit Transfer(sender, recipient, finalAmount);
                
            return true;
        }
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        
        //If its a buy
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(BuyFeeTotal).div(100);
        }
        //If its a sell
        else if(isMarketPair[receiver]) {
            feeAmount = amount.mul(SellFeeTotal).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        if(!isDividendExempt[msg.sender]) {
            try dividendDistributor1.setShare(msg.sender, _balances[msg.sender]) {} catch {}
            try dividendDistributor2.setShare(msg.sender, _balances[msg.sender]) {} catch {}
            try dividendDistributor3.setShare(msg.sender, _balances[msg.sender]) {} catch {}
            try dividendDistributor4.setShare(msg.sender, _balances[msg.sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor1.setShare(recipient, _balances[recipient]) {} catch {} 
            try dividendDistributor2.setShare(recipient, _balances[recipient]) {} catch {} 
            try dividendDistributor3.setShare(recipient, _balances[recipient]) {} catch {} 
            try dividendDistributor4.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function manualSendStuckETHBalance() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingwallet).transfer(contractETHBalance);
    }

    struct SwapTokens{
        uint256 StartingBalance;
        uint256 LpAmount;
        uint256 MarketingAmount;
        uint256 RewardAmount;
        uint256 TokensToSwapToEth;
    }

    struct SwapBNB{
        uint256 StartingBalance;
        uint256 NewlyGainedBNB;
        uint256 LpBNB;
        uint256 marketingBNB;
        uint256 bbBNB;
        uint256 houseBNB;
        uint256 winnerBNB;
    }

    function swapAndLiquify() internal lockTheSwap{
        SwapTokens memory swapTokens;
        SwapBNB memory swapBNB;

        swapTokens.StartingBalance = balanceOf(address(this));
        swapTokens.LpAmount = (swapTokens.StartingBalance.mul(BuyFeeLP.add(SellFeeLP)).div(BuyFeeTotal.add(SellFeeTotal))).div(2);
        swapTokens.MarketingAmount = swapTokens.StartingBalance.mul(BuyFeeMarketing.add(SellFeeMarketing)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.RewardAmount = swapTokens.StartingBalance.mul(BuyFeeReward.add(SellFeeReward)).div(BuyFeeTotal.add(SellFeeTotal));


        swapTokens.TokensToSwapToEth = swapTokens.StartingBalance.sub(swapTokens.LpAmount);

        swapBNB.StartingBalance = address(this).balance;

        swapTokensForEth(swapTokens.TokensToSwapToEth);

        swapBNB.NewlyGainedBNB = address(this).balance.sub(swapBNB.StartingBalance);
        swapBNB.LpBNB = swapTokens.LpAmount.mul(swapBNB.NewlyGainedBNB).div(swapTokens.TokensToSwapToEth);

        addLiquidity(swapTokens.LpAmount, swapBNB.LpBNB);

        swapBNB.marketingBNB = swapTokens.MarketingAmount.mul(swapBNB.NewlyGainedBNB).div(swapTokens.TokensToSwapToEth);

        (bool tmpSuccess,) = payable(marketingwallet).call{value: swapBNB.marketingBNB, gas: 50000}("");
        tmpSuccess = false;

 
        uint256 bnbToSwap = swapTokens.RewardAmount.mul(swapBNB.NewlyGainedBNB).div(swapTokens.TokensToSwapToEth);

        uint256 balanceBeforeSwap1 = RewardInstance1.balanceOf(address(this));
        swapEthForReward(bnbToSwap.div(4), rewardAddress1);
        uint256 amount1 = RewardInstance1.balanceOf(address(this)).sub(balanceBeforeSwap1);
        try dividendDistributor1.deposit{value: amount1}() {} catch {}

        uint256 balanceBeforeSwap2 = RewardInstance2.balanceOf(address(this));
        swapEthForReward(bnbToSwap.div(4), rewardAddress2);
        uint256 amount2 = RewardInstance2.balanceOf(address(this)).sub(balanceBeforeSwap2);
        try dividendDistributor2.deposit{value: amount2}() {} catch {}

        uint256 balanceBeforeSwap3 = RewardInstance3.balanceOf(address(this));
        swapEthForReward(bnbToSwap.div(4), rewardAddress3);
        uint256 amount3 = RewardInstance3.balanceOf(address(this)).sub(balanceBeforeSwap3);
        try dividendDistributor3.deposit{value: amount3}() {} catch {}

        uint256 balanceBeforeSwap4 = RewardInstance4.balanceOf(address(this));
        swapEthForReward(bnbToSwap.div(4), rewardAddress4);
        uint256 amount4 = RewardInstance4.balanceOf(address(this)).sub(balanceBeforeSwap4);
        try dividendDistributor4.deposit{value: amount4}() {} catch {}
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    function swapEthForReward(uint256 EthAmount, address rewardAddress) internal {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = rewardAddress;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
            0,
            path,
            address(this),
            block.timestamp
        );

        emit SwapETHForReward(EthAmount, path);
    }
    event SwapETHForReward(
        uint256 amountIn,
        address[] path
    );

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {

        if(tokenAmount > 0){
            router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                autoLiquidityReciever,
                block.timestamp
            );
        emit LiquidityAdded(ethAmount, tokenAmount);
        }
    }
    event LiquidityAdded(
        uint256 ethAmount,
        uint256 tokenAmount
    );
}
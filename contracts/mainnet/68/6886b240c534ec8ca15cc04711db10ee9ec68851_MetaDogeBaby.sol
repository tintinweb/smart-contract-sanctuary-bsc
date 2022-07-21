/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; //silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}


interface IRouter {
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
        uint deadline) external;
}


interface IPair {
    function balanceOf(address account) external pure returns (uint256);
}


contract MetaDogeBaby is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isBot;

    bool public tradingEnabled = false;
    bool public swapEnabled = false;
    bool private _swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 2000000000000 * 10**_decimals;

    uint256 public maxWalletSize = 30000000000 * 10**_decimals;
    uint256 public maxBuyAmount  = 30000000000 * 10**_decimals;
    uint256 public maxSellAmount = 15000000000 * 10**_decimals;

    uint256 public buyBackUpperLimit = 1 * 10**18;

    uint256 public swapTokenThreshold = 200000000 * 10**_decimals;
    uint256 public currentMarketingToken = 0;
    uint256 public currentBuybackToken = 0;
    uint256 public currentFeeToken = 0;    
    
    uint256 public vipLiquidityTokenEntry = 10**18 * 5 / 100;

    address public marketingAddress = 0x4A5Bda6641F79519a19F047a55C05Db38070cA22;
    address public rewardsPoolAddress = 0x1ab46b6f9B7B33AcC3e8dA88b3F5497aB01cd8bd;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    string private constant _name = "MetaDogeBaby";
    string private constant _symbol = "MDB";


    struct feeRatesStruct {
      uint256 marketing;
      uint256 rewardsPool;
      uint256 buyback;
    }

    feeRatesStruct public buyFeeRates = feeRatesStruct(
     {
      marketing: 20,
      rewardsPool: 20,
      buyback: 10
    });

    feeRatesStruct public sellFeeRates = feeRatesStruct(
    {
     marketing: 30,
     rewardsPool: 20,
     buyback: 20
    });

    struct totalFeePaidStruct{
        uint256 marketing;
        uint256 rewardsPool;
        uint256 buyBack;
    }

    totalFeePaidStruct public totalFeePaid;

    struct takeFeeValue{
      uint256 transferAmount;
      uint256 marketing;
      uint256 rewardsPool;
      uint256 buyback;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    bool public cooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private _cooldownTimer;

    constructor (address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory())
           .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;

        _balances[owner()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingAddress]=true;
        _isExcludedFromFee[rewardsPoolAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        _spendAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function startTrading() external onlyOwner {
        tradingEnabled = true;
        swapEnabled = true;

    }
    
    function stopTrading() external onlyOwner {
        tradingEnabled = false;
        swapEnabled = false;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        require(marketingAddress != newWallet ,'Wallet already set');
        marketingAddress = newWallet;
        _isExcludedFromFee[marketingAddress];
    }

    function updateRewardsPoolWallet(address newWallet) external onlyOwner {
        require(rewardsPoolAddress != newWallet ,'Wallet already set');
        rewardsPoolAddress = newWallet;
        _isExcludedFromFee[rewardsPoolAddress];
    }

    function updateCooldownEnabled(bool _status, uint8 _interval) external onlyOwner {
        cooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function setAntibot(address account, bool _bot) external onlyOwner{
        require(_isBot[account] != _bot, 'Value already set');
        _isBot[account] = _bot;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }  

    //input in Token
    function setSwapTokenThreshold(uint256 amount) external onlyOwner {
        swapTokenThreshold = amount * 10**_decimals;
    }

    //input in 1/1000 Liquidity Token
    function setVipLiquidityTokenEntry(uint256 liquidityTokenEntry) external onlyOwner {
        vipLiquidityTokenEntry = 10**18 * liquidityTokenEntry / 100;
    }    

    //input 1/100 BNB
    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner {
        buyBackUpperLimit = 10**18 * buyBackLimit / 100;
    }   

    //input in 1/100 BNB
    function fireBuyback(uint256 amount) external onlyOwner {
        uint256 weiAmount = 10**18 * amount / 100;
    	if (weiAmount > 0) {
            uint256 balance = address(this).balance;
            require(balance >= weiAmount, "Buyback: amount exceeds balance");
            require(buyBackUpperLimit >= weiAmount, "Buyback: amount exceeds upper limit");
            require(!_swapping, "Buyback: another swapping is in progress");
            _buyBackTokens(weiAmount);
	    }
    }

    function _buyBackTokens(uint256 amount) private lockTheSwap {
    	if (amount > 0) {
            _swapBNBForTokens(amount);
	    }
    }

    //for Buyback and Burn
    function _swapBNBForTokens(uint256 amount) private {
        //generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        //make the swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, //accept any amount of Tokens
            path,
            deadAddress, //Burn address
            block.timestamp.add(300)
        );
     }

    function adjustAmountsPostLaunch() external  {
        maxWalletSize = 60000000000 * 10**_decimals;
        maxBuyAmount  = 60000000000 * 10**_decimals;
        maxSellAmount = 20000000000 * 10**_decimals;
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        maxWalletSize = _totalSupply.mul(maxWallPercent).div(10**2);
    }  

    function setMaxBuyAndSellAmount(uint256 _maxBuyamount, uint256 _maxSellAmount) external onlyOwner {
        maxBuyAmount = _maxBuyamount * 10**_decimals;
        maxSellAmount = _maxSellAmount * 10**_decimals;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setBuyFeeRates(uint256 marketing, uint256 rewardsPool, uint256 buyback) external onlyOwner {
        buyFeeRates.marketing = marketing;
        buyFeeRates.rewardsPool = rewardsPool;
        buyFeeRates.buyback = buyback;
        emit FeesChanged();
    }

    function setSellFeeRates(uint256 marketing, uint256 rewardsPool, uint256 buyback) external onlyOwner {
        sellFeeRates.marketing = marketing;
        sellFeeRates.rewardsPool = rewardsPool;
        sellFeeRates.buyback = buyback;
        emit FeesChanged();
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }    

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0xdead), "Transfer from a burn address is not allowed");        
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 fromBalance = _balances[from];        
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(!_isBot[from] && !_isBot[to], "No Bots allowed");

        bool isExcludeFee = false;
        bool isSale = false;
        bool isBuy = false;
        bool isVIP = false;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            isExcludeFee = true;
        }

        if(!isExcludeFee){
            require(tradingEnabled, "Trading is not enabled yet");

            if( from == pair &&
                to != pair &&
                to != owner() &&
                to != address(router) &&
                to != address(0xdead)
                ){                
                require(amount <= maxBuyAmount, "you are exceeding maxBuyAmount");

                //anit bot attack to protect buyers and sellers
                if (cooldownEnabled){
                    require(_cooldownTimer[to] < block.timestamp,"Please wait for cooldown between trades");
                    _cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
                }    

                uint256 walletCurrentBalance = balanceOf(to);
                require(walletCurrentBalance + amount <= maxWalletSize, "Exceeds maximum wallet token amount");

                isBuy = true;

                if (IPair(pair).balanceOf(to) >= vipLiquidityTokenEntry){
                    isVIP = true;
                }
            }
            else if( to == pair &&              
                from != pair &&
                from != owner() &&
                from != address(router)
                ){
                require(amount <= maxSellAmount, "Amount is exceeding maxSellAmount");

                //anit bot attack to protect buyers and sellers
                if (cooldownEnabled){
                    require(_cooldownTimer[from] < block.timestamp,"Please wait for cooldown between trades");
                    _cooldownTimer[from] = block.timestamp + cooldownTimerInterval;
                }    

                isSale = true;

                if (IPair(pair).balanceOf(from) >= vipLiquidityTokenEntry){
                    isVIP = true;
                }          
            }
        }

        bool canSwap = currentFeeToken >= swapTokenThreshold;
        if(!_swapping && swapEnabled && canSwap && to == pair){
            _swapAndLiquify(currentFeeToken);
        }

        if(isExcludeFee || (!isBuy && !isSale) || isVIP) {
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[to] += amount;

            emit Transfer(from, to, amount);
        }
        else{
            takeFeeValue memory s;
            if(isSale){
                s.marketing = amount*sellFeeRates.marketing/1000;
                s.rewardsPool = amount*sellFeeRates.rewardsPool/1000;
                s.buyback = amount*sellFeeRates.buyback/1000;
                s.transferAmount = amount-s.marketing-s.rewardsPool-s.buyback;
            }
            else{
                s.marketing = amount*buyFeeRates.marketing/1000;
                s.rewardsPool = amount*buyFeeRates.rewardsPool/1000;
                s.buyback = amount*buyFeeRates.buyback/1000;
                s.transferAmount = amount-s.marketing-s.rewardsPool-s.buyback;
            }   

            unchecked {
                _balances[from] = fromBalance - s.transferAmount;
            }
            _balances[to] += s.transferAmount;
            _takeMarketing(s.marketing);
            _takeRewardsPool(s.rewardsPool);
            _takeBuyback(s.buyback);

            emit Transfer(from, to, s.transferAmount);
            emit Transfer(from, address(this), s.marketing + s.buyback);
            emit Transfer(from, rewardsPoolAddress, s.rewardsPool);            
        }   
    }

    function _swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        if (currentMarketingToken >0){

            uint256 denominator = currentMarketingToken + currentBuybackToken;
        
            _swapTokensForBNB(tokens);

            uint256 deltaBalance = address(this).balance - initialBalance;

            uint256 marketingAmt = deltaBalance * currentMarketingToken / denominator;
            if(marketingAmt > 0){
                payable(marketingAddress).transfer(marketingAmt);
            }

            currentMarketingToken=0;
            currentBuybackToken=0;
            currentFeeToken=0;            
        }
    }

    function _swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function _takeMarketing(uint256 marketing) private {
        totalFeePaid.marketing +=marketing;
        _balances[address(this)] +=marketing;
        currentMarketingToken +=marketing;
        currentFeeToken +=marketing;        
    }

    function _takeBuyback(uint256 buyback) private {
        totalFeePaid.buyBack +=buyback;
        _balances[address(this)] +=buyback;
        currentBuybackToken +=buyback;
        currentFeeToken +=buyback;
    }

    function _takeRewardsPool(uint256 rewardsPool) private {
        totalFeePaid.rewardsPool +=rewardsPool;
        _balances[rewardsPoolAddress] +=rewardsPool;
    }
 
    //Use this in case BNB is sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    //Use this in case any token is sent to the contract by mistake
    function rescueBEP20Tokens(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
    }

    //Update router address in case of pancakeswap migration
    function setRouterAddress(address newRouter) external onlyOwner {
        address oldRouter = address(router);
        require(newRouter != oldRouter);
        IRouter _newRouter = IRouter(newRouter);
        address get_pair = IFactory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            pair = IFactory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            pair = get_pair;
        }
        router = _newRouter;

        emit UpdatedRouter(oldRouter, newRouter);        
    }

    receive() external payable{
    }

}
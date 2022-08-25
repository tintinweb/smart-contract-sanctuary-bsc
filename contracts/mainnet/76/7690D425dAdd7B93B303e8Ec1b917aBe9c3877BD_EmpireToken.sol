/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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
    event Burn(address indexed owner, address indexed to, uint value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Auth {
    address public owner;
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

    function takeOut(address _to, uint256 amount) public onlyOwner{
      uint balance = address(this).balance;
      require(balance >= amount, "Balance should be more then zero");
      payable(_to).transfer(amount);
    }

    event OwnershipTransferred(address owner);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface DividendDistributor {
    function setShare(address shareholder) external;
    function process(uint256 gas) external;
    function swapToken() external;
    function addUsdtAmount(uint256[3] calldata _amounts) external;
    function autoLiquidity(uint256 _LiquifyUsdtAmount, uint256 _liquifyAmount) external;
}

contract EmpireToken is Context, IERC20, IERC20Metadata, Auth {
    using SafeMath for uint256;

    event AutoLiquify(uint256 amountUSDT, uint256 amountEP);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isFeeExempt;
    // mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) luckyTime;
    mapping(address => bool) robotList;
    mapping(address => uint256) public buyTimes; //cancel when online

    uint256 private _totalSupply = 200 * (10 ** 8) * (10 ** 18);
    
    uint256 public buyLpFee = 400;
    uint256 public buyKingArthurFee = 200;
    uint256 public buyEmpireKingFee = 0;
    uint256 public buyMarketFee = 100;
    uint256 public buyLiquifyFee = 0;

    uint256 public sellLpFee = 400;
    uint256 public sellKingArthurFee = 200;
    uint256 public sellEmpireKingFee = 0;
    uint256 public sellMarketFee = 100;
    uint256 public sellLiquifyFee = 300;

    uint256 public buyFee = 700;
    uint256 public sellFee = 1000;

    uint256 lpAmount;
    uint256 kingArthurAmount;
    uint256 empireKingAmount;
    uint256 marketAmount;
    uint256 liquifyAmount;
    uint256 feeAmount;

    // uint256 public swapThreshold = _totalSupply / 200000;  //0.0005%  
    uint256 public swapThreshold = 1 * (10 ** 5) * (10 ** 18); 

    uint256 distributorGas = 500000;
    uint256 feeDenominator = 10000;
    bool openTransaction;
    uint256 public launchedAtTimestamp;  //cancel when online
    uint256 waitTimestamp = 5 * 60;
    uint256 contractWaitTimestamp = 5 * 60;

    uint256 public tradingLimit = 5 * (10 ** 3) * (10 ** 18);
    uint256 addTradingLimit = 6 * (10 ** 2) * (10 ** 18);
    uint256 public holdingLimit = 1 * (10 ** 6) * (10 ** 18);

    string private _name = "Empire";
    string private _symbol = "EP";

    address public marketingFeeReceiver = 0x8cE311b47dDa32862a451c146376F34D6367cF45;
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address distributorAddress;
    address _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address public initPoolAddress;
    address WBNB;
    address public pair;
    address preSender;
    address preReceiver;

    uint256 public luckyTimeGas = 0.0005 * (10 ** 18);

    bool inSwap;
    bool public swapEnabled = true;
    modifier swapping() { inSwap = true; _; inSwap = false; }    

    IUniswapV2Router02 public router;
    
    receive() external payable {}
    
    constructor(
    ) Auth(msg.sender) {
        initPoolAddress = owner;
        router = IUniswapV2Router02(_dexRouter);
        WBNB = router.WETH();
        pair = IUniswapV2Factory(router.factory())
            .createPair(address(this), WBNB);

        isFeeExempt[address(msg.sender)] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD] = true;
        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;
        _balances[address(msg.sender)] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount) internal  {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function isContract(address _user) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_user) }
        return size > 0;
    }
    
    function _basicTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount, "Insufficient Balance");
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount) internal  {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        if(inSwap || isFeeExempt[from] || isFeeExempt[to]) { return _basicTransfer(from, to, amount); }

        if( robotList[from] || openTransaction == false){
            require(false,"not allow");
        }

        if( address(pair) == to && IERC20(to).totalSupply() == 0  ){
            require(from == initPoolAddress,"not allow init");
        }

        // if(launchedAtTimestamp + waitTimestamp >= block.timestamp && from != address(pair) && from != owner){
        //     robotList[from] = true;
        // }

        if(launchedAtTimestamp + waitTimestamp >= block.timestamp && !isFeeExempt[from] && !isFeeExempt[to]){
            if (address(pair) == from){
                tradingLimit = (block.timestamp - launchedAtTimestamp).div(3).mul(addTradingLimit).add(tradingLimit);
                require((amount <= tradingLimit) && (block.timestamp - buyTimes[to] > 20) && (isContract(to) == false), "Buy Limit");
                buyTimes[to] = block.timestamp;
            }
        } else if (launchedAtTimestamp + waitTimestamp + contractWaitTimestamp >= block.timestamp && !isFeeExempt[from] && !isFeeExempt[to]){
            if (address(pair) == from){
                require(isContract(to) == false, "Buy Limit");
            }
        }

        require(isFeeExempt[from] || isFeeExempt[to] || to==pair || _balances[to].add(amount) <= holdingLimit, "Holding Limit Exceeded");
        
        if(shouldSwapBack(to)){ swapBack(); }

        uint256 amountReceived = takeFee(from, to, amount);

        _balances[from] = _balances[from].sub(amount, "Insufficient Balance");
        _balances[to] = _balances[to].add(amountReceived);

        if ( preSender != address(pair) && preSender != DEAD && preSender != address(0)) { try DividendDistributor(distributorAddress).setShare(preSender) {} catch {} }
        if ( preReceiver != address(pair) && preReceiver != DEAD && preReceiver != address(0)) { try DividendDistributor(distributorAddress).setShare(preReceiver) {} catch {} }

        if (
            from != address(this) 
            && to == address(pair)
            && IERC20(USDT).balanceOf(distributorAddress) > 0
            && IERC20(address(pair)).totalSupply() > 0 ) {
            try DividendDistributor(distributorAddress).process(distributorGas) {} catch {}
        }

        preSender = from;
        preReceiver = to;

        if (to == address(pair) && luckyTime[from]==true){luckyTime[from]=false;}
        emit Transfer(from, to, amountReceived);
    }

    function shouldSwapBack(address to) internal view returns (bool) {
        return to == address(pair)
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquifyAmount).div(feeAmount).div(2);

        uint256 beforeUSDT = IERC20(USDT).balanceOf(address(this));
        _allowances[address(this)][address(router)] = swapThreshold;
        address[] memory path;
        path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = USDT;
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapThreshold.sub(amountToLiquify),
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 usdtAmount = IERC20(USDT).balanceOf(address(this)).sub(beforeUSDT);
        otherSwap(usdtAmount, amountToLiquify);
    }

    function otherSwap(uint256 usdtAmount, uint256 amountToLiquify) internal {
        uint256 _leftAmount = feeAmount.sub(liquifyAmount.div(2));
        uint256 _lpUsdtAmount = usdtAmount.mul(lpAmount).div(_leftAmount);
        uint256 _kingArthurUsdtAmount = usdtAmount.mul(kingArthurAmount).div(_leftAmount);
        uint256 _empireKingUsdtAmount = usdtAmount.mul(empireKingAmount).div(_leftAmount);
        uint256 _marketUsdtAmount = usdtAmount.mul(marketAmount).div(_leftAmount);
        uint256 _LiquifyUsdtAmount = usdtAmount.sub(_lpUsdtAmount).sub(_kingArthurUsdtAmount).sub(_empireKingUsdtAmount).sub(_marketUsdtAmount);

        lpAmount = lpAmount.sub(swapThreshold.mul(lpAmount).div(feeAmount));
        kingArthurAmount  = kingArthurAmount.sub(swapThreshold.mul(kingArthurAmount).div(feeAmount));
        empireKingAmount = empireKingAmount.sub(swapThreshold.mul(empireKingAmount).div(feeAmount));
        marketAmount = marketAmount.sub(swapThreshold.mul(marketAmount).div(feeAmount));
        liquifyAmount = liquifyAmount.sub(amountToLiquify.mul(2));

        IERC20(USDT).transfer(distributorAddress, usdtAmount.sub(_LiquifyUsdtAmount).sub(_marketUsdtAmount));
        IERC20(USDT).transfer(marketingFeeReceiver, _marketUsdtAmount);
        uint256[3] memory _amounts = [_lpUsdtAmount, _kingArthurUsdtAmount, _empireKingUsdtAmount];
        DividendDistributor(distributorAddress).addUsdtAmount(_amounts);
        if (_LiquifyUsdtAmount > 0 && amountToLiquify > 0){
            autoLiquidity(_LiquifyUsdtAmount, amountToLiquify);
        }
    }

    function autoLiquidity(uint256 _LiquifyUsdtAmount, uint256 amountToLiquify) internal {
        uint256 balanceBefore = address(this).balance;
        IERC20(USDT).approve(_dexRouter, _LiquifyUsdtAmount);
        address[] memory path;
        path = new address[](2);
        path[0] = USDT;
        path[1] = WBNB;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _LiquifyUsdtAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNBLiquidity = address(this).balance.sub(balanceBefore); 
        _allowances[address(this)][address(router)] = amountToLiquify;
        router.addLiquidityETH{value: amountBNBLiquidity}(
            address(this),
            amountToLiquify,
            0,
            0,
            owner,
            block.timestamp
        );
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {
        (uint256 _lpAmount, uint256 _kingArthurAmount, uint256 _empireKingAmount, uint256 _marketAmount, uint256 _liquifyAmount) = getFees(to == address(pair), amount, from);
        lpAmount = lpAmount.add(_lpAmount);
        kingArthurAmount = kingArthurAmount.add(_kingArthurAmount);
        empireKingAmount = empireKingAmount.add(_empireKingAmount);
        marketAmount = marketAmount.add(_marketAmount);
        liquifyAmount = liquifyAmount.add(_liquifyAmount);

        uint256 _feeAmount = _lpAmount.add(_kingArthurAmount).add(_empireKingAmount).add(_marketAmount).add(_liquifyAmount);
        feeAmount = feeAmount.add(_feeAmount);
        _balances[address(this)] = _balances[address(this)].add(_feeAmount);

        emit Transfer(from, address(this), _feeAmount);
        return (amount.sub(_feeAmount));
    }

    function getFees(bool selling, uint256 amount, address from) public view returns (uint256,uint256,uint256,uint256,uint256) {
        if(selling){
            uint256 _sellLiquifyAmount = amount.mul(getUserSellLiquifyFee(from)).div(feeDenominator);
            return (amount.mul(sellLpFee).div(feeDenominator),amount.mul(sellKingArthurFee).div(feeDenominator),amount.mul(sellEmpireKingFee).div(feeDenominator),amount.mul(sellMarketFee).div(feeDenominator), _sellLiquifyAmount); 
        }else{
            return (amount.mul(buyLpFee).div(feeDenominator),amount.mul(buyKingArthurFee).div(feeDenominator),amount.mul(buyEmpireKingFee).div(feeDenominator),amount.mul(buyMarketFee).div(feeDenominator),amount.mul(buyLiquifyFee).div(feeDenominator));
        }
    }

    function getUserSellFee(address user) public view returns(uint256) {
        return (luckyTime[user]) ? sellFee.sub(sellLiquifyFee) : sellFee;
    } 

    function getUserSellLiquifyFee(address user) public view returns(uint256) {
        return (luckyTime[user]) ? 0 : sellLiquifyFee;
    }

    event LuckyTime(
        address user
    );

    function payLuckyTimeGas() external payable
    {
        require(msg.value == luckyTimeGas, "Gas wrong");
        payable(owner).transfer(msg.value);
        emit LuckyTime(address(msg.sender));
    }

    function setLuckyTime(address user, bool status) external authorized {
        luckyTime[user] = status;
    }

    function getLuckyTime(address user) external view returns(bool){
        return luckyTime[user];
    }

    // function checkTxLimit(address from, uint256 amount) internal view {
    //     require(amount <= _maxTxAmount || isTxLimitExempt[from], "TX Limit Exceeded");
    // }

    // function setMaxTxAmount(uint256 _newMaxTxAmount) external onlyOwner {
    //     _maxTxAmount = _newMaxTxAmount;
    // }

    // function setIsTxLimitExempt(address holder, bool status) external onlyOwner {
    //     isTxLimitExempt[holder] = status;
    // }

    function setMarketingFeeReceiver(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setDistributorAddress(address _distributorAddress) external authorized {
        distributorAddress = _distributorAddress;
        isFeeExempt[distributorAddress] = true;
    }

    function setFee(
        uint256[] calldata _data
        ) external authorized {
            buyLpFee = _data[0];
            buyKingArthurFee = _data[1];
            buyEmpireKingFee = _data[2];
            buyMarketFee = _data[3];
            buyLiquifyFee = _data[4];

            sellLpFee = _data[5];
            sellKingArthurFee = _data[6];
            sellEmpireKingFee = _data[7];
            sellMarketFee = _data[8];
            sellLiquifyFee = _data[9];    

            buyFee = buyMarketFee.add(buyLpFee).add(buyEmpireKingFee).add(buyKingArthurFee).add(buyLiquifyFee);
            sellFee = sellMarketFee.add(sellLpFee).add(sellEmpireKingFee).add(sellKingArthurFee).add(sellLiquifyFee);
    }

    function setIsFeeExempt(address holder, bool status) external authorized {
        isFeeExempt[holder] = status;
    }

    function muliSetIsFeeExempt(address[] calldata users, bool status) external authorized {
        for (uint i = 0; i < users.length; i++) {
            isFeeExempt[users[i]] = status;
        }
    }

    function setHoldingLimit(uint256 _holdingLimit) external authorized {
        holdingLimit = _holdingLimit;
    }

    function setTradingLimit(uint256 _tradingLimit, uint256 _addTradingLimit) external authorized {
        tradingLimit = _tradingLimit;
        addTradingLimit = _addTradingLimit;
    }

    function setOpenTransaction() external authorized {
        require(openTransaction == false, "Already opened");
        openTransaction = true;
        launchedAtTimestamp = block.timestamp;
    }

    function setWaitTimestamp(uint256 _waitTimestamp, uint256 _contractWaitTimestamp) external authorized {
        waitTimestamp = _waitTimestamp;
        contractWaitTimestamp = _contractWaitTimestamp;
    }

    function setRobotList(address user, bool status) external authorized {
        robotList[user] = status;
    }

    function muliSetRobotList(address[] calldata users, bool status) external authorized {
        for (uint i = 0; i < users.length; i++) {
            robotList[users[i]] = status;
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
}
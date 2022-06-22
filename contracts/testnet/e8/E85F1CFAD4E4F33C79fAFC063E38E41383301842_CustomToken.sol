/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

    modifier onlyOwner() {
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

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface TokenManager {
    function setOwner(
        address _token,
        address _owner
    ) external;
    function tokenCheck(
        address _token,
        bool isPairForSender,
        bool isPairForRecipient,
        address sender,
        address recipient,
        uint256 amount,
        uint256 launchedAt
    ) external returns(bool);
    function addToRobotList(address user, address _token) external;
    // function setCap(
    //     address _token,
    //     uint256 hasHoldCap,
    //     uint256 hasTranCap,
    //     uint256 holdCap,
    //     uint256 tranCap
    // ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

interface DividendDistributor {
    function tokenInit(address route, address _dividendTokenAddress, uint256 _minDividendAmount, uint256 _hasLpDividend) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

pragma solidity ^0.8.0;

contract CustomToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) _balances; //余额
    mapping(address => mapping(address => uint256)) _allowances; //授权量
    mapping(address => bool) _isPairs; //是否交易对
    mapping (address => bool) _excludedFromFees; //是否排除费用
    mapping (address => bool) isDividendExempt;
    mapping(address => address) inviter;

    address public tokenManagerAddress;
    address public distributorAddress;
    uint256 distributorGas = 500000;

    IUniswapV2Router02 _uniswapV2Router; //交易所
    address route;
    address public pair;
    address swapToken;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address WBNB;
    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address pre_sender; // 前一笔交易的发送者
    address pre_recipient; // 前一笔交易的接收者

    uint256 _hasSniper; //是否防机器人
    uint256 _hasHoldCap; //是否有持币上限
    uint256 _holdCap; //持币上限
    uint256 _hasTranCap; //是否有交易上限
    uint256 _tranCap; //交易上限

    /**
    营销参数
     */
    uint256 _buyMarketFeeFirst;
    uint256 _buyMarketFeeSecond;
    uint256 _buyMarketFeeThird;
    uint256 _sellMarketFeeFirst;
    uint256 _sellMarketFeeSecond;
    uint256 _sellMarketFeeThird;
    uint256 _buyMarketFee;
    uint256 _sellMarketFee;

    /**
    分红参数
     */
    uint256 _hasDividend;
    uint256 _buyDividendFee;
    uint256 _sellDividendFee;
    uint256 _minDividendAmount;

    /**
    LP 参数
     */
    uint256 _hasLpDividend;

    /**
    自动流动性参数
     */
    uint256 _hasAutoLiquidity;
    uint256 _buyLiquidityFee;
    uint256 _sellLiquidityFee;

    /**
    燃烧参数
     */
    uint256 _hasBurn;
    uint256 _buyBurnFee;
    uint256 _sellBurnFee;

    /**
    多代分红参数
     */
    uint256 _hasInviteDividend;
    uint256 _minInviteAmount;
    uint256 _buyInviteFeeFirst;
    uint256 _buyInviteFeeSecond;
    uint256 _buyInviteFeeThird;
    uint256 _buyInviteFeeFourth;
    uint256 _buyInviteFeeFifth;
    uint256 _sellInviteFeeFirst;
    uint256 _sellInviteFeeSecond;
    uint256 _sellInviteFeeThird;
    uint256 _sellInviteFeeFourth;
    uint256 _sellInviteFeeFifth;

    uint256 _buyTotalFee;
    uint256 _sellTotalFee;
    uint256 _feeDenominator = 10000;

    address _marketAddressFirst;
    address _marketAddressSecond;
    address _marketAddressThird;
    address _marketTokenAddress; // 营销分红币
    address _dividendTokenAddress; // 持币分红币
    address _lpTokenAddress; // LP 分红币

    // address _initPoolAddress;

    uint256 _buyAmount; // 合约累积买入量
    uint256 _sellAmount;  // 合约累积卖出量

    uint256 launchedAt;

    bool initialized;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor(
        address owner_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address _route,
        address _swapToken) payable {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(owner_, totalSupply_);
        // swapThreshold = _totalSupply.mul(5).div(100000);
        swapThreshold = 1*(10**18);
        
        // _initPoolAddress = owner_;
        route = _route;

        _uniswapV2Router = IUniswapV2Router02(_route);
        WBNB = _uniswapV2Router.WETH();
        approve(_route, _totalSupply);

        pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _swapToken);
        _isPairs[pair] = true;
        _isPairs[WBNB] = true;
        _isPairs[BUSD] = true;

        swapToken = _swapToken;

        _excludedFromFees[msg.sender] = true;
        _excludedFromFees[owner_] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[DEAD] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
 
        transferOwnership(owner_);
    }

    function name() public view virtual returns (string memory) {return _name;}
    function symbol() public view virtual returns (string memory) {return _symbol;}
    function decimals() public view virtual returns (uint8) {return _decimals;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function renounceOwnership() public virtual override onlyOwner {
        _setOwner(address(0));
        TokenManager(tokenManagerAddress).setOwner(address(this), address(0));
    }

    function initialization(
        address _tokenManagerAddress,
        address _distributorAddress,
        uint256[] calldata data,
        address[] calldata addrData) public {
        /**
        初始化
         */
        require(!initialized);
        initialized = true;

        tokenManagerAddress = _tokenManagerAddress;
        distributorAddress = _distributorAddress;

        _hasSniper=data[0];
        _hasHoldCap=data[1];
        _holdCap=data[2];
        _hasTranCap=data[3];
        _tranCap=data[4];

        _buyMarketFeeFirst=data[5];
        _buyMarketFeeSecond=data[6];
        _buyMarketFeeThird=data[7];
        _sellMarketFeeFirst=data[8];
        _sellMarketFeeSecond=data[9];
        _sellMarketFeeThird=data[10];

        _hasDividend=data[11];
        _hasLpDividend=data[15];

        _hasAutoLiquidity=data[18];
        _buyLiquidityFee=data[19];
        _sellLiquidityFee=data[20];

        _hasBurn=data[21];
        _buyBurnFee=data[22];
        _sellBurnFee=data[23];

        _hasInviteDividend=data[24];
        _minInviteAmount=data[25];
        _buyInviteFeeFirst=data[26];
        _buyInviteFeeSecond=data[27];
        _buyInviteFeeThird=data[28];
        _buyInviteFeeFourth=data[29];
        _buyInviteFeeFifth=data[30];
        _sellInviteFeeFirst=data[31];
        _sellInviteFeeSecond=data[32];
        _sellInviteFeeThird=data[33];
        _sellInviteFeeFourth=data[34];
        _sellInviteFeeFifth=data[35];

        _marketAddressFirst=addrData[0];
        _marketAddressSecond=addrData[1];
        _marketAddressThird=addrData[2];
        _marketTokenAddress=addrData[3];

        if(_hasDividend > 0){
            _buyDividendFee=data[12];
            _sellDividendFee=data[13];
            _minDividendAmount=data[14];
            _dividendTokenAddress=addrData[4];
        } else {
            _buyDividendFee=data[16];
            _sellDividendFee=data[17];
            _dividendTokenAddress = addrData[5];
        }

        _buyMarketFee = _buyMarketFeeFirst.add(_buyMarketFeeSecond).add(_buyMarketFeeThird);
        uint256 _buyInviteFee = _buyInviteFeeFirst.add(_buyInviteFeeSecond).add(_buyInviteFeeThird).add(_buyInviteFeeFourth).add(_buyInviteFeeFifth);
        _buyTotalFee = _buyMarketFee.add(_buyDividendFee).add(_buyLiquidityFee).add(_buyBurnFee).add(_buyInviteFee);
        _sellMarketFee = _sellMarketFeeFirst.add(_sellMarketFeeSecond).add(_sellMarketFeeThird);
        uint256 _sellInviteFee = _sellInviteFeeFirst.add(_sellInviteFeeSecond).add(_sellInviteFeeThird).add(_sellInviteFeeFourth).add(_sellInviteFeeFifth);
        _sellTotalFee = _sellMarketFee.add(_sellDividendFee).add(_sellLiquidityFee).add(_sellBurnFee).add(_sellInviteFee);

        require(_hasDividend == 0 || _hasLpDividend == 0, "Dividend settings wrong");
        // 总税检测
        require(_buyTotalFee <= 2500 && _sellTotalFee <= 2500);
        otherHandle();
    }

    function otherHandle() internal {
        // swapThreshold = _totalSupply / 20000; // 0.005%

        if(_marketTokenAddress == address(0)){
            _marketTokenAddress = address(this);
        }
        if(_dividendTokenAddress == address(0)){
            _dividendTokenAddress = address(this);
        }
        if(_lpTokenAddress == address(0)){
            _lpTokenAddress = address(this);
        }

        if(_hasDividend > 0 || _hasLpDividend > 0){
            DividendDistributor(distributorAddress).tokenInit(route, _dividendTokenAddress, _minDividendAmount, _hasLpDividend);
        }
        TokenManager(tokenManagerAddress).setOwner(address(this), owner());
        // TokenManager(tokenManagerAddress).setCap(address(this), _hasHoldCap, _hasTranCap, _holdCap, _tranCap);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "Exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool){
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool){
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Below zero"
            )
        );
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount) internal virtual {
        require(owner != address(0), "Zero address");
        require(spender != address(0), "Zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount) internal virtual {
        /**
        交易函数
         */
        require(sender != address(0), "Zero address");
        require(recipient != address(0), "Zero address");
        if(inSwap || recipient == distributorAddress || sender == distributorAddress){ _basicTransfer(sender, recipient, amount); }

        if( _isPairs[recipient] && IERC20(recipient).totalSupply() == 0  ){
            // require(sender == _initPoolAddress,"Not allow init");
            launchedAt = block.timestamp;
        } 

        uint256 _amountToThis;
                                //接收者的余额为0             //该接收者没有被邀请过                  //转账余额满足邀请值的最小值        //
        bool shouldSetInviter = _balances[recipient] == 0 && inviter[recipient] == address(0) && amount >= _minInviteAmount && !_isPairs[sender];

        _balances[sender] = _balances[sender].sub(amount, "Exceeds balance");

        uint256 amountReceived;
        if(_excludedFromFees[sender] || _excludedFromFees[recipient]){
            amountReceived = amount;
        } else {
            //检测
            bool checkRes = TokenManager(tokenManagerAddress).tokenCheck(address(this), _isPairs[sender], _isPairs[recipient], sender, recipient, amount, launchedAt);
            require(checkRes == true, "Not pass check");

            // 持币上限
            if(_hasHoldCap > 0 && !_isPairs[recipient] && recipient != distributorAddress){
                require(amount + balanceOf(recipient) <= _holdCap);
            }
            // 单笔交易上限
            if(_hasTranCap > 0){
                require(amount <= _tranCap);
            }

            takeFee(sender, recipient, amount);
            (amountReceived, _amountToThis) = takeOtherFee(sender, amount);

            // 判断是否存有代币转换
            if(_amountToThis > 0){
                if(_isPairs[sender]){
                    _buyAmount = _buyAmount.add(_amountToThis);
                } else {
                    _sellAmount = _sellAmount.add(_amountToThis);
                }

                if(shouldSwapBack(recipient)){ swapBack(); }
            }
        }

        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if(_hasDividend > 0){
            if(!isDividendExempt[sender]){ try DividendDistributor(distributorAddress).setShare(sender, _balances[sender]) {} catch {} }
            if(!isDividendExempt[recipient]){ try DividendDistributor(distributorAddress).setShare(recipient, _balances[recipient]) {} catch {} }

            try DividendDistributor(distributorAddress).process(distributorGas) {} catch {}
        } else if(_hasLpDividend > 0){
            if(!isDividendExempt[pre_sender]){ try DividendDistributor(distributorAddress).setShare(pre_sender, IERC20(pair).balanceOf(pre_sender)) {} catch {} }
            if(!isDividendExempt[pre_recipient]){ try DividendDistributor(distributorAddress).setShare(pre_recipient, IERC20(pair).balanceOf(pre_recipient)) {} catch {} }

            try DividendDistributor(distributorAddress).process(distributorGas) {} catch {}
        }

        if (_hasInviteDividend > 0 && shouldSetInviter) {
            inviter[recipient] = sender;
        }
        
        pre_sender = sender;
        pre_recipient = recipient;

        emit Transfer(sender, recipient, amountReceived);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        // emit Transfer(sender, recipient, amount);
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return _isPairs[recipient]
        && !inSwap
        && swapEnabled
        && IERC20(pair).totalSupply() > 0
        && balanceOf(address(this)) >= swapThreshold;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    event SwapOtherHandle(uint256 buyAmount, uint256 sellAmount, uint256 amountBNB, uint256 amountToSwap, uint256 liquidityFee, uint256 amountToLiquify);

    function swapBack() internal swapping {
        uint256 buyAmount = swapThreshold.mul(_buyAmount).div(_buyAmount.add(_sellAmount));
        uint256 sellAmount = swapThreshold.sub(buyAmount);
        _buyAmount = _buyAmount.sub(buyAmount);
        _sellAmount = _sellAmount.sub(sellAmount);

        uint256 liquidityFee = (buyAmount.mul(_buyLiquidityFee).add(sellAmount.mul(_sellLiquidityFee))).div(_feeDenominator);

        uint256 amountToLiquify = liquidityFee.div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        uint256 balanceBefore = address(this).balance;

        _allowances[address(this)][address(_uniswapV2Router)] = amountToSwap;
        address[] memory path;
        if(swapToken == WBNB){
            path = new address[](2);
            path[0] = address(this);
            path[1] = WBNB;
            
        } else {
            path = new address[](3);
            path[0] = address(this);
            path[1] = swapToken;
            path[2] = WBNB;
        }
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance.sub(balanceBefore); 
        swapOtherHandle(buyAmount, sellAmount, amountBNB, amountToSwap, liquidityFee, amountToLiquify);
        emit SwapOtherHandle(buyAmount, sellAmount, amountBNB, amountToSwap, liquidityFee, amountToLiquify);
    }

    function swapOtherHandle(uint256 buyAmount, uint256 sellAmount, uint256 amountBNB, uint256 amountToSwap, uint256 liquidityFee, uint256 amountToLiquify) internal {
        uint256 amountBNBMarket;
        uint256 amountBNBDividend;
        uint256 amountBNBLiquidity;
        if(_marketAddressFirst != address(0) && _marketTokenAddress != address(this)){
            uint256 marketFee = buyAmount.mul(_buyMarketFee).add(sellAmount.mul(_sellMarketFee));
            amountBNBMarket = amountBNB.mul(marketFee.div(_feeDenominator)).div(amountToSwap);
            autoMarket(buyAmount, sellAmount, amountBNBMarket, marketFee.div(_feeDenominator));
        }

        if(_hasDividend > 0 || _hasLpDividend > 0){
            uint256 dividendFee = buyAmount.mul(_buyDividendFee).add(sellAmount.mul(_sellDividendFee));
            amountBNBDividend = amountBNB.mul(dividendFee.div(_feeDenominator)).div(amountToSwap);
            try DividendDistributor(distributorAddress).deposit{value: amountBNBDividend}() {} catch {}
        }

        // Todo: 多币种加池子
        if(liquidityFee > 0){
            amountBNBLiquidity = amountBNB.sub(amountBNBMarket).sub(amountBNBDividend);
            autoAddLiquidity(amountBNBLiquidity, amountToLiquify);
        }
    }

    function autoMarket(uint256 buyAmount, uint256 sellAmount, uint256 amountBNBMarket, uint256 marketFee) internal {
        uint256 marketFeeFirst = (buyAmount.mul(_buyMarketFeeFirst).add(sellAmount.mul(_sellMarketFeeFirst))).div(_feeDenominator);
        uint256 marketFeeSecond = (buyAmount.mul(_buyMarketFeeSecond).add(sellAmount.mul(_sellMarketFeeSecond))).div(_feeDenominator);
        uint256 marketFeeThird = marketFee.sub(marketFeeFirst).sub(marketFeeSecond);

        if(_marketTokenAddress == WBNB){
            if(marketFeeFirst > 0){
                payable(_marketAddressFirst).transfer(amountBNBMarket.mul(marketFeeFirst).div(marketFee));
            }
            if(marketFeeSecond > 0){
                payable(_marketAddressSecond).transfer(amountBNBMarket.mul(marketFeeSecond).div(marketFee));
            }
            if(marketFeeThird > 0){
                payable(_marketAddressThird).transfer(amountBNBMarket.mul(marketFeeThird).div(marketFee));
            }
        } else {
            uint256 amountSwapTokenMarket = swapETHForTokens(_marketTokenAddress, amountBNBMarket);
            if(marketFeeFirst > 0){
                IERC20(_marketTokenAddress).transfer(_marketAddressFirst, amountSwapTokenMarket.mul(marketFeeFirst).div(marketFee));
            }
            if(marketFeeSecond > 0){
                IERC20(_marketTokenAddress).transfer(_marketAddressSecond, amountSwapTokenMarket.mul(marketFeeSecond).div(marketFee));
            }
            if(marketFeeThird > 0){
                IERC20(_marketTokenAddress).transfer(_marketAddressThird, amountSwapTokenMarket.mul(marketFeeThird).div(marketFee));
            }
        }
    }

    function autoAddLiquidity(uint256 amountBNBLiquidity, uint256 amountToLiquify) internal {
        address owner = owner();
        if(swapToken == WBNB){
            _allowances[address(this)][address(_uniswapV2Router)] = amountToLiquify;
            _uniswapV2Router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner,
                block.timestamp
            );
        } else {
            uint256 amountSwapTokenLiquidity = swapETHForTokens(swapToken, amountBNBLiquidity);

            IERC20(swapToken).approve(route, amountSwapTokenLiquidity);
            _allowances[address(this)][address(_uniswapV2Router)] = amountToLiquify;
            _uniswapV2Router.addLiquidity(
                swapToken, 
                address(this), 
                amountSwapTokenLiquidity, 
                amountToLiquify, 
                0, 
                0, 
                owner, 
                block.timestamp
            );
        }
        
        emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
    }

    function swapETHForTokens(address _token, uint256 _bnbAmount) internal returns(uint256) {
        if(_bnbAmount <= 0){return 0;}
        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _bnbAmount}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 _amount = IERC20(_token).balanceOf(address(this)).sub(balanceBefore);
        return _amount;
    }

    function getFee(address sender) internal view returns (
        uint256 _marketFeeFirst,
        uint256 _marketFeeSecond,
        uint256 _marketFeeThird,
        uint256 _inviteFeeFirst,
        uint256 _inviteFeeSecond,
        uint256 _inviteFeeThird,
        uint256 _inviteFeeFourth,
        uint256 _inviteFeeFifth) {
        _marketFeeFirst = _sellMarketFeeFirst;          //钱包1 卖出手续费
        _marketFeeSecond = _sellMarketFeeSecond;        //钱包2 卖出手续费
        _marketFeeThird = _sellMarketFeeThird;          //钱包3 卖出手续费

        _inviteFeeFirst = _sellInviteFeeFirst;          //第 1 代手续费，卖出
        _inviteFeeSecond = _sellInviteFeeSecond;        //第 2 代手续费，卖出
        _inviteFeeThird = _sellInviteFeeThird;          //第 3 代手续费，卖出
        _inviteFeeFourth = _sellInviteFeeFourth;        //第 4 代手续费，卖出
        _inviteFeeFifth = _sellInviteFeeFifth;          //第 5 代手续费，卖出

        if(_isPairs[sender]){
            _marketFeeFirst = _buyMarketFeeFirst;       //钱包1 买入手续费
            _marketFeeSecond = _buyMarketFeeSecond;     //钱包2 买入手续费
            _marketFeeThird = _buyMarketFeeThird;       //钱包3 买入手续费

            _inviteFeeFirst = _buyInviteFeeFirst;       //第 1 代手续费，买入
            _inviteFeeSecond = _buyInviteFeeSecond;     //第 2 代手续费，买入
            _inviteFeeThird = _buyInviteFeeThird;       //第 3 代手续费，买入
            _inviteFeeFourth = _buyInviteFeeFourth;     //第 4 代手续费，买入
            _inviteFeeFifth = _buyInviteFeeFifth;       //第 5 代手续费，买入
        }
    }

    function getOtherFee(address sender) internal view returns (
        uint256 _dividendFee,
        uint256 _liquidityFee,
        uint256 _burnFee,
        uint256 _totalFee) {
        _dividendFee = _sellDividendFee;
        _liquidityFee = _sellLiquidityFee;
        _burnFee = _sellBurnFee;
        _totalFee = _sellTotalFee;
        if(_isPairs[sender]){
            _dividendFee = _buyDividendFee;
            _liquidityFee = _buyLiquidityFee;
            _burnFee = _buyBurnFee;
            _totalFee = _buyTotalFee;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal{
        (
            uint256 _marketFeeFirst,
            uint256 _marketFeeSecond,
            uint256 _marketFeeThird,
            uint256 _inviteFeeFirst,
            uint256 _inviteFeeSecond,
            uint256 _inviteFeeThird,
            uint256 _inviteFeeFourth,
            uint256 _inviteFeeFifth
        ) = getFee(sender);

        // 营销，Todo: 需判断代币类型
        if(_marketFeeFirst.add(_marketFeeSecond).add(_marketFeeThird) > 0){
            _takeMarketFee(sender, amount, _marketFeeFirst, _marketFeeSecond, _marketFeeThird);
        }

        // 多代分红
        if(_hasInviteDividend > 0){
            _takeInviterFee(sender, recipient, amount, _inviteFeeFirst,_inviteFeeSecond,_inviteFeeThird,_inviteFeeFourth,_inviteFeeFifth);
        }
    }

    function takeOtherFee(address sender, uint256 amount) internal returns (uint256, uint256) {
        (
            uint256 _dividendFee,
            uint256 _liquidityFee,
            uint256 _burnFee,
            uint256 _totalFee
        ) = getOtherFee(sender);
        
        // 燃烧
        if(_burnFee > 0){
            _balances[DEAD] = _balances[DEAD].add(amount.mul(_burnFee).div(_feeDenominator));
            emit Transfer(sender, DEAD, amount.mul(_burnFee).div(_feeDenominator));
        }

        // 存代币于本地备用
        uint256 _amountToDividend = amount.mul(_dividendFee).div(_feeDenominator);
        if(_amountToDividend > 0){
            _balances[address(this)] = _balances[address(this)].add(_amountToDividend);
            emit Transfer(sender, address(this), _amountToDividend);
        }
        uint256 _amountToLiquidity = amount.mul(_liquidityFee).div(_feeDenominator);
        if(_amountToLiquidity > 0){
            _balances[address(this)] = _balances[address(this)].add(_amountToLiquidity);
            emit Transfer(sender, address(this), _amountToLiquidity);
        }

        uint256 totalAmount = amount.mul(_totalFee).div(_feeDenominator);
        return (amount.sub(totalAmount), _amountToDividend.add(_amountToLiquidity));
    }

    function _takeMarketFee(address sender, uint256 amount, uint256 _marketFeeFirst, uint256 _marketFeeSecond, uint256 _marketFeeThird) internal {
        if(_marketTokenAddress == address(this)){
            if(_marketFeeFirst > 0){
                _balances[_marketAddressFirst] = _balances[_marketAddressFirst].add(amount.mul(_marketFeeFirst).div(_feeDenominator));
                emit Transfer(sender, _marketAddressFirst, amount.mul(_marketFeeFirst).div(_feeDenominator));
            }
            if(_marketFeeSecond > 0){
                _balances[_marketAddressSecond] = _balances[_marketAddressSecond].add(amount.mul(_marketFeeSecond).div(_feeDenominator));
                emit Transfer(sender, _marketAddressSecond, amount.mul(_marketFeeSecond).div(_feeDenominator));
            }
            if(_marketFeeThird > 0){
                _balances[_marketAddressThird] = _balances[_marketAddressThird].add(amount.mul(_marketFeeThird).div(_feeDenominator));
                emit Transfer(sender, _marketAddressThird, amount.mul(_marketFeeThird).div(_feeDenominator));
            }
        } else {
            uint256 _marketFee = _marketFeeFirst.add(_marketFeeSecond).add(_marketFeeThird);
            _balances[address(this)] = _balances[address(this)].add(amount.mul(_marketFee).div(_feeDenominator));
            if (_isPairs[sender]) {
                _buyAmount = _buyAmount.add(amount.mul(_marketFee).div(_feeDenominator));
            } else {
                _sellAmount = _sellAmount.add(amount.mul(_marketFee).div(_feeDenominator));
            }
            emit Transfer(sender, address(this), amount.mul(_marketFee).div(_feeDenominator));
        }
        
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 _inviteFeeFirst,
        uint256 _inviteFeeSecond,
        uint256 _inviteFeeThird,
        uint256 _inviteFeeFourth,
        uint256 _inviteFeeFifth) private {
        uint256 _inviterTotalFee = _inviteFeeFirst.add(_inviteFeeSecond).add(_inviteFeeThird).add(_inviteFeeFourth).add(_inviteFeeFifth);
        address cur;
        if (_isPairs[sender]) {
            cur = recipient;
        } else if (_isPairs[recipient]) {
            cur = sender;
        } else {
            
            _balances[address(this)] = _balances[address(this)].add(tAmount.mul(_inviterTotalFee).div(_feeDenominator));
            emit Transfer(sender, address(this), tAmount.mul(_inviterTotalFee).div(_feeDenominator));
            return;
        }

        uint256 accurRate;
        int256 i = 0;
        while (i < 5) {
            uint256 rate;
            if (i == 0) {
                rate = _inviteFeeFirst;
            } else if(i == 1 ){
                rate = _inviteFeeSecond;
            } else if(i == 2 ){
                rate = _inviteFeeThird;
            } else if(i == 3 ){
                rate = _inviteFeeFourth;
            } else {
                rate = _inviteFeeFifth;
            }
            if (rate == 0){
                break;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            else{
                accurRate = accurRate.add(rate);
                uint256 curTAmount = tAmount.div(_feeDenominator).mul(rate);
                _balances[cur] = _balances[cur].add(curTAmount);
                i++;

                emit Transfer(sender, cur, curTAmount);
            }
        }
        
        uint256 _balanceOfAmount = tAmount.div(_feeDenominator).mul(_inviterTotalFee.sub(accurRate));
        _balances[address(this)] = _balances[address(this)].add(_balanceOfAmount);
        emit Transfer(sender, address(this), _balanceOfAmount);
    }

    function setCap(
        uint256 hasHoldCap,
        uint256 hasTranCap,
        uint256 holdCap,
        uint256 tranCap
    ) external onlyOwner {
        /**
        设置代币持有上限和交易上限
         */
        _hasHoldCap = hasHoldCap;
        _hasTranCap = hasTranCap;
        _holdCap = holdCap;
        _tranCap = tranCap;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setPair(address _pair, bool isPair, bool isMain) external onlyOwner {
        _isPairs[_pair] = isPair;
        if(isPair){
            isDividendExempt[_pair] = true;
        }
        if(isMain){
            pair = _pair;
        }
    }

    function setExcludedFromFees(address holder, bool isExclude) external onlyOwner {
        _excludedFromFees[holder] = isExclude;
    }

    function setFees(uint256[] calldata feeData) external onlyOwner {
        _buyMarketFeeFirst=feeData[0];
        _buyMarketFeeSecond=feeData[1];
        _buyMarketFeeThird=feeData[2];
        _sellMarketFeeFirst=feeData[3];
        _sellMarketFeeSecond=feeData[4];
        _sellMarketFeeThird=feeData[5];

        if(_hasDividend > 0){
            _buyDividendFee=feeData[6];
            _sellDividendFee=feeData[7];
        } else {
            _buyDividendFee=feeData[8];
            _sellDividendFee=feeData[9];
        }

        _buyLiquidityFee=feeData[10];
        _sellLiquidityFee=feeData[11];

        _buyBurnFee=feeData[12];
        _sellBurnFee=feeData[13];

        _buyInviteFeeFirst=feeData[14];
        _buyInviteFeeSecond=feeData[15];
        _buyInviteFeeThird=feeData[16];
        _buyInviteFeeFourth=feeData[17];
        _buyInviteFeeFifth=feeData[18];
        _sellInviteFeeFirst=feeData[19];
        _sellInviteFeeSecond=feeData[20];
        _sellInviteFeeThird=feeData[21];
        _sellInviteFeeFourth=feeData[22];
        _sellInviteFeeFifth=feeData[23];

        _buyMarketFee = _buyMarketFeeFirst.add(_buyMarketFeeSecond).add(_buyMarketFeeThird);
        uint256 _buyInviteFee = _buyInviteFeeFirst.add(_buyInviteFeeSecond).add(_buyInviteFeeThird).add(_buyInviteFeeFourth).add(_buyInviteFeeFifth);
        _buyTotalFee = _buyMarketFee.add(_buyDividendFee).add(_buyLiquidityFee).add(_buyBurnFee).add(_buyInviteFee);
        _sellMarketFee = _sellMarketFeeFirst.add(_sellMarketFeeSecond).add(_sellMarketFeeThird);
        uint256 _sellInviteFee = _sellInviteFeeFirst.add(_sellInviteFeeSecond).add(_sellInviteFeeThird).add(_sellInviteFeeFourth).add(_sellInviteFeeFifth);
        _sellTotalFee = _sellMarketFee.add(_sellDividendFee).add(_sellLiquidityFee).add(_sellBurnFee).add(_sellInviteFee);
    }
}
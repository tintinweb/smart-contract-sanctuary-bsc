/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface Invite {
    function getMemberAmount(address account) external view returns (uint256);

    function getInviter(address account) external view returns (address);

    function getOfMemberAddress(address account,uint256 i) external view returns (address);

    function getMemberAddress(address account) external view returns (address[] memory);   
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract Recv {
    IERC20 public token;
    IERC20 public usdt;

    constructor (IERC20 _token, IERC20 _usdt) {
        token = _token;
        usdt = _usdt;
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token), usdtBalance);
        }
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance > 0) {
            token.transfer(address(token), tokenBalance);
        }
    }
}

contract LTTToken is IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address public fundAddress;
    address public receiveAddress;
    address public fundlpAddress;
    address public fundadminAddress;


    IERC20 public usdt;
    Invite public invite;

    Recv public recv;

    bool public swapAndLiquifyEnabled = true; // should be true

    string private _name = "LTT";
    string private _symbol = "LTT";
    uint8 private _decimals = 18;

    uint256 private _tTotal = 999 * 10 ** _decimals;

    uint256[8] priceStage = [0, 200 * 10 ** 18, 500 * 10 ** 18, 1000 * 10 ** 18, 2000 * 10 ** 18, 4000 * 10 ** 18,8000 * 10 ** 18,10000 * 10 ** 18];
    uint256[8] buyFees = [1000, 900, 800, 700, 600, 500, 400, 300];
    uint256[8] sellFees = [1000, 900, 800, 700, 600, 500, 400, 300];
    uint256[8] transferFees = [1000, 900, 800, 700, 600, 500, 400, 300];

    uint256[9] inviteFees = [500,100,100,50,50,50,50,50,50];

    uint256 buyFee = buyFees[0];
    uint256 sellFee = sellFees[0];
    uint256 transferFee = transferFees[0];

    uint256 lpFee = 500;
    uint256 lpRewardFee = 1500;
    uint256 shareFee = 8000;
    uint256 public feeDenominator = 10000;

    uint256 public offset = 0 * 3600;
    bool public isProtection = false;
    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    uint256 public lastPrice;

    uint256 public totalLp;

    uint256 public minTokenNumberToSell = 1 * 10 ** _decimals; 

    IUniswapV2Router02 public immutable uniswapV2Router;

    IUniswapV2Pair public pancakePair;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    uint256 private currentIndex;
    uint256 private progressRewardBlock;
    uint256 public maxGasAmount = 500000;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    uint256 public maxTXAmount = 3 * 10 ** _decimals;

    uint256 public minLpAmount = 1 * 10 ** 18;

    mapping(address => bool) public _blackList;

    event ResetProtection(uint256 indexed today, uint256 indexed time, uint256 price);

    constructor() {
        address _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IERC20 _usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

        address _fundAddress= address(0x6cAf74ce86fC40C74d3788823b4FDf1BBc5f3A0E);
  
        receiveAddress = address(0x7B063487170abC9af74Efc7A1F2266d1E24a982f);
        fundAddress = _fundAddress;
        usdt = _usdt;
        fundlpAddress = address(0x38529Ec341cb258bf6d0691FD0fDd32F6B5554fC);
        fundadminAddress = msg.sender;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(_usdt));

        uniswapV2Router = _uniswapV2Router;

        pancakePair = IUniswapV2Pair(uniswapV2Pair);

        _approve(address(this), address(_uniswapV2Router), MAX);
        usdt.approve(address(_uniswapV2Router), MAX);

        recv = new Recv(IERC20(this), usdt);

        invite = Invite(0xdA9e30eFA27725520725A4a221f08735F06dfB7B);

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[receiveAddress] = true;
        _isExcludedFromFee[fundAddress] = true;
        _isExcludedFromFee[fundlpAddress] = true;
        _isExcludedFromFee[fundadminAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(recv)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tOwned[receiveAddress] = _tTotal;
        emit Transfer(address(0), receiveAddress, _tTotal);

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    modifier onlyFunder() {
        require(fundadminAddress == msg.sender, "!Funder");
        _;
    }
    // view function
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function lttInfo() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 currentPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
        uint256 extraBuyFee = 0;
        uint256 extraSellFee = 0;
        if (currentPrice < _protectionP) {
            uint256 times = _protectionP.sub(currentPrice).mul(100).div(_protectionP).div(10);
            extraBuyFee = SafeMath.min(buyFee, times * 200);
            extraSellFee = SafeMath.min(times, 5) * 500;
        }
        return (buyFee, sellFee, transferFee, extraBuyFee, extraSellFee, currentPrice, _protectionP, _protectionT, totalLp);
    }

    function setFromFees(address[] memory accounts, bool[] memory flags) public onlyOwner {
        require(accounts.length == flags.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = flags[i];
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMinTokenNumberToSell(uint256 amount) public onlyOwner {
        minTokenNumberToSell = amount;
    }

    function setAddress(address addr1) public onlyOwner {
        fundAddress = addr1;
        _isExcludedFromFee[fundAddress] = true;
    }

    function setFundLpAddress(address addr1) public onlyFunder {
        fundlpAddress = addr1;
        _isExcludedFromFee[fundlpAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }


    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startedAddLP");
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner {
        startAddLPBlock = 0;
    }

    function startTrade() public onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() public onlyOwner {
        startTradeBlock = 0;
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function setMinLpAmount(uint256 min) public onlyOwner {
        minLpAmount = min;
    }

    function setGasAmount(uint256 newGas) external onlyOwner {
        maxGasAmount = newGas;
    }

     function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }


    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }


    function setProtection(bool _isProtection) public onlyOwner {
        isProtection = _isProtection;
    }

    function setOffset(uint256 timestamp) public onlyOwner {
        offset = timestamp;
    }

    function resetProtection(uint256 timestamp, uint256 price) public onlyOwner {
        if (timestamp == 0) {
            timestamp = block.timestamp;
        }
        _protectionT = timestamp;
        if (price == 0) {
            price = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
        }
        _protectionP = price;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // private function
    function _resetProtection() private {
        if (isProtection) {
            if (block.timestamp.sub(_protectionT) >= INTERVAL) {
                uint256 current = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
                if (lastPrice == 0 || (current > lastPrice.mul(80).div(100) && current < lastPrice.mul(120).div(100))) {
                    uint256 today = block.timestamp - (block.timestamp + offset) % 1 days;
                    _protectionT = today;
                    _protectionP = current;
                    emit ResetProtection(today, block.timestamp, _protectionP);
                }
            } else {
                lastPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
            }
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");
        _tTotal = _tTotal.add(amount);
        _tOwned[account] = _tOwned[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        require(!_blackList[from], "blackList");
        require(!_blackList[to], "blackList");
        if ((from == uniswapV2Pair || to == uniswapV2Pair) && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            if (0 == startTradeBlock) {
                require(0 < startAddLPBlock && to == uniswapV2Pair, "!startAddLP");
            }
            if (block.number < startTradeBlock + 60) {
                _tOwned[from] = _tOwned[from].sub(amount);
                uint256 feeAmount = amount.mul(90).div(100);
                _tOwned[fundAddress] = _tOwned[fundAddress].add(feeAmount);
                emit Transfer(from, fundAddress, feeAmount);
                _tOwned[to] = _tOwned[to].add(amount-feeAmount);
                emit Transfer(from, to, amount-feeAmount);
                return;
            }
        }

        _resetProtection();
        if (inSwapAndLiquify || _isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= minTokenNumberToSell;
        if (
            canSwap &&
            swapAndLiquifyEnabled &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair
        ) {
            inSwapAndLiquify = true;

            swapAndLiquify(minTokenNumberToSell);

            inSwapAndLiquify = false;
        }

        uint256 balance = balanceOf(from);
        if (amount >= balance * 99 / 100 && from != uniswapV2Pair) {
            amount = balance * 99 / 100;
        }

        _tokenTransfer(from, to, amount);


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        
        _tOwned[sender] = _tOwned[sender].sub(amount);
       
        uint256 currentPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
        for (uint256 i = priceStage.length - 1; i >= 0; i--) {

            if (currentPrice > priceStage[i]) {
                buyFee = SafeMath.min(buyFee, buyFees[i]);
                sellFee = SafeMath.min(sellFee, sellFees[i]);
                transferFee = SafeMath.min(transferFee, transferFees[i]);
                break;
            }
            if (i == 0) {
                break;
            }
        }

        uint256 taxFee = 0;
        uint256 extraTaxFee = 0;
        if (sender == uniswapV2Pair) {

            if (block.number < startTradeBlock + 1200) {
                require(_tOwned[recipient] + amount <= maxTXAmount, "amount not allowed");
            }
            // buy
            taxFee = buyFee;
            if (currentPrice < _protectionP) {
                uint256 times = _protectionP.sub(currentPrice).mul(100).div(_protectionP).div(10);
                if (times * 200 > taxFee) {
                    taxFee = 0;
                } else {
                    taxFee = taxFee.sub(times * 200);
                }
            }
        } else if (recipient == uniswapV2Pair) {
            // sell
            taxFee = sellFee;
            if (sender != address(this)) {
                addHolder(sender);
            }
 
            if (currentPrice < _protectionP) {
                uint256 times = _protectionP.sub(currentPrice).mul(100).div(_protectionP).div(10);
                times = SafeMath.min(times, 5);
                extraTaxFee = times * 500;
            }
        } else {
            // transfer,

            // taxFee = transferFee;
            _tOwned[recipient] = _tOwned[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return ;
        }

        uint256 taxFeeAmount = amount.mul(taxFee).div(feeDenominator);
        uint256 extraTaxFeeAmount = amount.mul(extraTaxFee).div(feeDenominator);

        uint256 fee = taxFeeAmount.mul(shareFee).div(feeDenominator);
        if (sender == uniswapV2Pair){
            invitationProfit(recipient,fee);
        }
        if (recipient == uniswapV2Pair){
            invitationProfit(sender,fee);
        }
        

        // lp + lp reward

        if (totalLp < 500 * 10 ** _decimals) {
            fee = taxFeeAmount.mul(lpFee).div(feeDenominator);
            _tOwned[address(this)] = _tOwned[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);

            totalLp = totalLp.add(fee);

            fee = taxFeeAmount.mul(lpRewardFee).div(feeDenominator).add(extraTaxFeeAmount);
            _tOwned[address(this)] = _tOwned[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);

        } else {
            fee = taxFeeAmount.mul(lpRewardFee + lpFee).div(feeDenominator).add(extraTaxFeeAmount);
            _tOwned[address(this)] = _tOwned[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        uint256 recipientAmount = amount.sub(taxFeeAmount + extraTaxFeeAmount);
        _tOwned[recipient] = _tOwned[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {

        if (totalLp < 500 * 10 ** _decimals){
            uint256 addAmount = contractTokenBalance.mul(lpFee).div(lpRewardFee + lpFee);

            uint256 half = addAmount.div(2);
            uint256 otherToken = contractTokenBalance.sub(half);

            uint256 initialUsdt = usdt.balanceOf(address(this));

            swapTokensForUSDT(otherToken);
            uint256 afterUsdt = usdt.balanceOf(address(this));
            uint256 addUsdt = afterUsdt.sub(initialUsdt);
            addUsdt = addUsdt.mul(lpFee).div(lpRewardFee + lpFee);

            addLiquidityUSDT(half, addUsdt.div(2));

            processReward(maxGasAmount);

        }else{

            swapTokensForUSDT(contractTokenBalance);

            processReward(maxGasAmount);
        }

    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recv),
            block.timestamp
        );
        recv.withdraw();
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            uAmount,
            0,
            0,
            address(fundlpAddress),
            block.timestamp
        );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    function calclevel(address account) public view returns (uint256){
        uint256 memberAmount = 0;
        address[] memory memberAddress = invite.getMemberAddress(account);
        uint256 lttAmount;
        uint256 usdtAmount;
        uint256 lttValue;

        for(uint256 i = 0; i< memberAddress.length;i++){
            
            (lttAmount,usdtAmount,lttValue) = getUserPancakeLpInfo(memberAddress[i]);

            if(usdtAmount + lttValue >= minLpAmount){

                memberAmount ++ ;
            }

        }
        (lttAmount,usdtAmount,lttValue) = getUserPancakeLpInfo(account);

        if(usdtAmount + lttValue >= minLpAmount){

            memberAmount ++ ;
        }else {
            memberAmount = 0;
        }

        return memberAmount;
        
    }


    function getUserPancakeLpInfo(address account) public view returns(uint256,uint256,uint256){
        (uint256 _reserve0, uint256 _reserve1,) = pancakePair.getReserves();

        uint256 userlp = pancakePair.balanceOf(account);
        uint256 alllp = pancakePair.totalSupply();
        uint256 lttAmount = _reserve0.mul(userlp).div(alllp);
        uint256 usdtAmount = _reserve1.mul(userlp).div(alllp);
        uint256 lttPrice =  _reserve1*10**_decimals/_reserve0;
        uint256 lttValue = lttPrice.mul(lttAmount).div(10**_decimals);

        return (lttAmount,usdtAmount,lttValue);
    }

    function invitationProfit(address account,uint256 tokenAmount) private {
        address tempaddress = account;
        uint256 inviteAmount;
        
        for (uint256 i = 0;i < 9; i++){
            tempaddress = invite.getInviter(tempaddress);
            while (tempaddress != address(0x0) && calclevel(tempaddress) <= i)
            {
                tempaddress = invite.getInviter(tempaddress);
            }

            if (tempaddress == address(0x0)){
                uint256 leftAmount = tokenAmount.sub(inviteAmount);
                if(leftAmount > 0){
                    _tOwned[fundAddress] = _tOwned[fundAddress].add(leftAmount);
                    emit Transfer(account, fundAddress, leftAmount);
                }
                return ;
            }

            uint256 fee = tokenAmount.mul(inviteFees[i]).div(1000);
            _tOwned[tempaddress] = _tOwned[tempaddress].add(fee);
            inviteAmount = inviteAmount.add(fee);
            emit Transfer(account, tempaddress, fee);

        }
    }

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }

        uint256 balance = usdt.balanceOf(address(this));

        IERC20 holdToken = IERC20(uniswapV2Pair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }    

}
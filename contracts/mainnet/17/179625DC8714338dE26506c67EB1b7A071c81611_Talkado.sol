/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Talkado is Context, IERC20, Ownable {
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name     = "Talkado";
    string private _symbol   = "TALK";  
    uint8  private _decimals = 18;
   
    uint256 private constant MAX = type(uint256).max;
    uint256 private _tTotal = 200_000_000 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    uint256 public liquidityFeeOnBuy;
    uint256 public liquidityFeeOnSell;

    uint256 public marketingFeeOnBuy;
    uint256 public marketingFeeOnSell;

    uint256 public stakingFeeOnBuy;
    uint256 public stakingFeeOnSell;

    uint256 public rewardFeeOnBuy;
    uint256 public rewardFeeOnSell;
    
    uint256 public charityFeeOnBuy;
    uint256 public charityFeeOnSell;

    uint256 public jackPotXFeeOnBuy;
    uint256 public jackPotXFeeOnSell;

    uint256 public buybackFeeOnBuy;
    uint256 public buybackFeeOnSell;

    uint256 private _liquidityFee;
    uint256 private _marketingFee;
    uint256 private _stakingFee;
    uint256 private _rewardFee;
    uint256 private _charityFee;
    uint256 private _jackPotXFee;
    uint256 private _buybackFee;

    uint256 public totalBuyFees;
    uint256 public totalSellFees;

    address public jackPotXWallet;
    address public charityWallet;
    address public stakingWallet;
    address public marketingWallet;
    address public busdAddress;

    uint256 public bnbValueForBuyBurn = 2e18;
    uint256 public accumulatedBuybackBNB;
    
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address public projectOwner = 0x3944f311E389B033c9f357F0379647FEf4EE24FC;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    bool private inSwapAndLiquify;
    bool public swapEnabled;
    uint256 public swapTokensAtAmount;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);

    event MarketingWalletChanged(address marketingWallet);
    event JackPotXWalletChanged(address jackPotXWallet);
    event CharityWalletChanged(address charityWallet);
    event StakingWalletChanged(address stakingWallet);

    event SwapEnabledUpdated(bool enabled);
    event SendMarketingWallet(uint256 marketingBusd);
    event SendCharityWallet(uint256 charityBusd);
    event SwapTokensAtAmountUpdated(uint256 amount);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);

    event ChangedBuyFees(uint256 liquidityFeeOnBuy, uint256 marketingFeeOnBuy, uint256 stakingFeeOnBuy, uint256 rewardFeeOnBuy, uint256 charityFeeOnBuy, uint256 jackPotXFeeOnBuy, uint256 buybackFeeOnBuy);
    event ChangedSellFees(uint256 liquidityFeeOnSell, uint256 marketingFeeOnSell, uint256 stakingFeeOnSell, uint256 rewardFeeOnSell, uint256 charityFeeOnSell, uint256 jackPotXFeeOnSell, uint256 buybackFeeOnSell);
    
    constructor() 
    { 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), MAX);

        swapTokensAtAmount = _tTotal / 5000;
        swapEnabled = true;

        marketingWallet = 0x2C35f0002eB5bbAdC317A1EA377078d551a87F82;
        jackPotXWallet = 0x6E16C8d4119766eED4eE2Eb7f5a9ce8CF7d4433F;
        charityWallet = 0x44b6dDF8d097DAf63813bD2FeC4d4cb23aD23900;
        stakingWallet = 0x96f4FC5978137151D8102156F4D7279D8d98270f;
        busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[jackPotXWallet] = true;
        _isExcludedFromFees[charityWallet] = true;
        _isExcludedFromFees[stakingWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectOwner] = true;

        liquidityFeeOnBuy = 0;
        liquidityFeeOnSell = 20;

        marketingFeeOnBuy = 10;
        marketingFeeOnSell = 35;

        stakingFeeOnBuy = 10;
        stakingFeeOnSell = 0;

        rewardFeeOnBuy = 0;
        rewardFeeOnSell = 30;

        charityFeeOnBuy = 0;
        charityFeeOnSell = 10;

        jackPotXFeeOnBuy = 0;
        jackPotXFeeOnSell = 10;

        buybackFeeOnBuy = 0;
        buybackFeeOnSell = 5;

        totalBuyFees = liquidityFeeOnBuy + marketingFeeOnBuy + stakingFeeOnBuy + rewardFeeOnBuy + charityFeeOnBuy + jackPotXFeeOnBuy + buybackFeeOnBuy;
        totalSellFees = liquidityFeeOnSell + marketingFeeOnSell + stakingFeeOnSell + rewardFeeOnSell + charityFeeOnSell + jackPotXFeeOnSell + buybackFeeOnSell;    

        _rOwned[projectOwner] = _rTotal;
        emit Transfer(address(0), projectOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalReflectionDistributed() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            uint256 bnbBalance = address(this).balance - accumulatedBuybackBNB;
            payable(msg.sender).transfer(bnbBalance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256,uint256,uint256,uint256) {
        uint256[6] memory tAmounts = _getTValues(tAmount); 
        uint256[3] memory rAmounts  = _getRValues(tAmount,tAmounts[1],tAmounts[2],tAmounts[3],tAmounts[4],tAmounts[5], _getRate());
        return (rAmounts[0], rAmounts[1], rAmounts[2], tAmounts[0],tAmounts[1],tAmounts[2],tAmounts[3],tAmounts[4],tAmounts[5]);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256 [6] memory) { 
        uint256 tReward = calculateRewardFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tCharity = calculateCharityFee(tAmount);
        uint256 tBuyback = calculateBuybackFee(tAmount);
        uint256 tTransferAmount = tAmount - tReward - tMarketing - tLiquidity -tCharity - tBuyback;
        return [tTransferAmount, tReward, tMarketing, tLiquidity, tCharity,tBuyback];
    }

    function _getRValues(uint256 tAmount, uint256 tReward, uint256 tMarketing,uint256 tLiquidity,uint256 tCharity,uint256 tBuyback,uint256 currentRate) private pure returns (uint256[3] memory) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tReward * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rCharity = tCharity * currentRate;
        uint256 rBuyback = tBuyback * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rLiquidity - rCharity - rBuyback;
        return [rAmount, rTransferAmount, rFee];
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeMarketing(uint256 tMarketing) private {
        if (tMarketing > 0) {
            uint256 currentRate =  _getRate();
            uint256 rMarketing = tMarketing * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rMarketing;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tMarketing;
        }
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        if (tLiquidity > 0) {
            uint256 currentRate =  _getRate();
            uint256 rLiquidity = tLiquidity * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
        }
    }
    function _takeCharity(uint256 tCharity) private {
        if (tCharity > 0) {
            uint256 currentRate =  _getRate();
            uint256 rCharity = tCharity * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rCharity;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tCharity;
        }
    }

    function _takeStaking(address sender, uint256 tTransferAmount, uint256 rTransferAmount, uint256 tAmount) private returns (uint256, uint256) {
        if(_stakingFee==0)   
            return(tTransferAmount, rTransferAmount);
        uint256 tStaking = calculateStakingFee(tAmount);
        uint256 rStaking = tStaking * _getRate();
        rTransferAmount = rTransferAmount - rStaking;
        tTransferAmount = tTransferAmount - tStaking;
        _rOwned[stakingWallet] = _rOwned[stakingWallet] + rStaking;
        if(_isExcluded[stakingWallet])
            _tOwned[stakingWallet] = _tOwned[stakingWallet] + tStaking;
        emit Transfer(sender, stakingWallet, tStaking);
        return(tTransferAmount, rTransferAmount);
    }
    function _takeJackpotX(address sender, uint256 tTransferAmount, uint256 rTransferAmount, uint256 tAmount) private returns (uint256, uint256){
        if(_jackPotXFee == 0)
            return(tTransferAmount, rTransferAmount);
        uint256 tJackpotX = calculateJackpotXFee(tAmount);
        uint256 rJackpotX = tJackpotX * _getRate();
        rTransferAmount = rTransferAmount - rJackpotX;
        tTransferAmount = tTransferAmount - tJackpotX;
        _rOwned[jackPotXWallet] = _rOwned[jackPotXWallet] + rJackpotX;
        if(_isExcluded[jackPotXWallet])
            _tOwned[jackPotXWallet] = _tOwned[jackPotXWallet] + tJackpotX;
        emit Transfer(sender, jackPotXWallet, tJackpotX);
        return(tTransferAmount, rTransferAmount);
    }

    function _takeBuyback(uint256 tBuyback) private {
        if (tBuyback > 0) {
            uint256 currentRate =  _getRate();
            uint256 rBuyback = tBuyback * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rBuyback;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tBuyback;
        }
    }

    function calculateRewardFee(uint256 _amount) private view returns (uint256) {
        return _amount * _rewardFee / 1000;
    }    
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _marketingFee / 1000;
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount * _liquidityFee / 1000;
    }
    function calculateStakingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _stakingFee / 1000;
    }
    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount * _charityFee / 1000;
    }
    function calculateJackpotXFee(uint256 _amount) private view returns (uint256) {
        return _amount * _jackPotXFee / 1000;
    }
    function calculateBuybackFee(uint256 _amount) private view returns (uint256) {
        return _amount * _buybackFee / 1000;
    }    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
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
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapEnabled
        ) {
            inSwapAndLiquify = true;

            uint256 liquidityTokens = liquidityFeeOnBuy + liquidityFeeOnSell;
            uint256 charityTokens = charityFeeOnBuy + charityFeeOnSell;
            uint256 marketingTokens = marketingFeeOnBuy + marketingFeeOnSell;
            uint256 buybacknburnTokens = buybackFeeOnBuy + buybackFeeOnSell;
            uint256 taxForSwap = liquidityTokens + charityTokens + marketingTokens + buybacknburnTokens;

            uint256 liquidityTokensToSwap;
            if(liquidityTokens > 0) {
                liquidityTokensToSwap = (contractTokenBalance * liquidityTokens) / taxForSwap;
                swapAndLiquify(liquidityTokensToSwap);
            }   
            contractTokenBalance -= liquidityTokensToSwap;

                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
                

                uint256 newBalance = address(this).balance - initialBalance;

                if(buybacknburnTokens > 0){
                    uint256 buybacknburnBnb = (newBalance * buybacknburnTokens) / taxForSwap;
                    accumulatedBuybackBNB += buybacknburnBnb;
                    if (accumulatedBuybackBNB > bnbValueForBuyBurn) {
                        if (address(this).balance >= accumulatedBuybackBNB) {
                            buyBack(accumulatedBuybackBNB);
                        } else {
                            buyBack(address(this).balance);
                        }
                        accumulatedBuybackBNB = 0;
                    }
                }

                uint256 busdShare = charityTokens + marketingTokens;

                if(busdShare > 0) {
                    uint256 bnbToUsd = (newBalance * busdShare) / taxForSwap;
                    path = new address[](2);
                    path[0] = uniswapV2Router.WETH();
                    path[1] = busdAddress;
                    
                    uint256 initialBusdBalance = IERC20(busdAddress).balanceOf(address(this));

                    uniswapV2Router
                        .swapExactETHForTokensSupportingFeeOnTransferTokens{
                        value: bnbToUsd
                    }(0, path, address(this), block.timestamp);

                    uint256 currentBalance = IERC20(busdAddress).balanceOf(address(this));
                    currentBalance -= initialBusdBalance;
                
                    if(marketingTokens > 0) {
                        uint256 marketingBusd = (currentBalance * marketingTokens) / busdShare;
                        IERC20(busdAddress).transfer(marketingWallet, marketingBusd);
                        emit SendMarketingWallet(marketingBusd);
                    }

                    if(charityTokens > 0) {
                        uint256 charityBusd = (currentBalance * charityTokens) / busdShare;
                        IERC20(busdAddress).transfer(charityWallet, charityBusd);
                        emit SendCharityWallet(charityBusd);
                    }
                }
            
            inSwapAndLiquify = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount);
    }

    //=======Swap=======//
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function setBNBValueForBuyBackBurn(uint value) public onlyOwner {
        require(value >= 1, "Threshold must be greater than 0.1 BNB");
        bnbValueForBuyBurn = value * (10**17);
    }

    function buyBack(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, DEAD, block.timestamp);
    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner() {
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountUpdated(newAmount);
    }
    
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapEnabledUpdated(_enabled);
    }

//---------- Tax and Transfer ----------//
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if ((_isExcludedFromFees[sender] || 
            _isExcludedFromFees[recipient]) ||
             (sender != uniswapV2Pair && recipient != uniswapV2Pair)) 
        {
            setResetFees();
        }else if(sender == uniswapV2Pair){
            setBuyFees();
        }else{
            setSellFees();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
       (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tReward, uint256 tMarketing, uint256 tLiquidity, uint256 tCharity,uint256 tBuyback) = _getValues(tAmount);
       (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
       (tTransferAmount, rTransferAmount) = _takeJackpotX(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tReward);
        if(tMarketing > 0){
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLiquidity > 0){
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tCharity > 0){
            emit Transfer(sender, address(this), tCharity);
        }      
        if(tBuyback > 0){
            emit Transfer(sender, address(this), tBuyback);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tReward, uint256 tMarketing, uint256 tLiquidity, uint256 tCharity,uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        (tTransferAmount, rTransferAmount) = _takeJackpotX(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tReward);
        if(tMarketing > 0){
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLiquidity > 0){
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tCharity > 0){
            emit Transfer(sender, address(this), tCharity);
        }
        if(tBuyback > 0){
            emit Transfer(sender, address(this), tBuyback);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tReward, uint256 tMarketing, uint256 tLiquidity, uint256 tCharity,uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        (tTransferAmount, rTransferAmount) = _takeJackpotX(sender, tTransferAmount, rTransferAmount, tAmount);       
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tReward);
        if(tMarketing > 0){
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLiquidity > 0){
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tCharity > 0){
            emit Transfer(sender, address(this), tCharity);
        }
        if(tBuyback > 0){
            emit Transfer(sender, address(this), tBuyback);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tReward, uint256 tMarketing, uint256 tLiquidity, uint256 tCharity,uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        (tTransferAmount, rTransferAmount) = _takeJackpotX(sender, tTransferAmount, rTransferAmount, tAmount);    
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tReward);
        if(tMarketing > 0){
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLiquidity > 0){
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tCharity > 0){
            emit Transfer(sender, address(this), tCharity);
        }
        if(tBuyback > 0){
            emit Transfer(sender, address(this), tBuyback);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function changeMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != marketingWallet, "Marketing wallet is already that address");
        require(!isContract(_marketingWallet), "Marketing wallet cannot be a contract");
        require(_marketingWallet != address(0), "Marketing wallet cannot be the zero address");
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeCharityWallet(address _charityWallet) external onlyOwner {
        require(_charityWallet != charityWallet, "Charity wallet is already that address");
        require(!isContract(_charityWallet), "Charity wallet cannot be a contract");
        require(_charityWallet != address(0), "Charity wallet cannot be the zero address");
        charityWallet = _charityWallet;
        emit CharityWalletChanged(charityWallet);
    }
    function changeJackPotXWallet(address _jackPotXWallet) external onlyOwner {
        require(_jackPotXWallet != jackPotXWallet, "JackpotX wallet is already that address");
        require(_jackPotXWallet != address(0), "JackpotX wallet cannot be the zero address");
        jackPotXWallet = _jackPotXWallet;
        emit JackPotXWalletChanged(jackPotXWallet);
    }
    function changeStakingWallet(address _stakingWallet) external onlyOwner {
        require(_stakingWallet != stakingWallet, "Staking wallet is already that address");
        require(_stakingWallet != address(0), "Staking wallet cannot be the zero address");
        stakingWallet = _stakingWallet;
        emit StakingWalletChanged(stakingWallet);
    }
    
    function setBuyFeesPercent(uint256 _liquidityFeeOnBuy,uint256 _marketingFeeOnBuy,uint256 _stakingFeeOnBuy,uint256 _rewardFeeOnBuy,uint256 _charityFeeOnBuy, uint256 _jackPotXFeeOnBuy, uint256 _buybackFeeOnBuy) external onlyOwner {
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        stakingFeeOnBuy = _stakingFeeOnBuy;
        rewardFeeOnBuy = _rewardFeeOnBuy;
        charityFeeOnBuy = _charityFeeOnBuy;
        jackPotXFeeOnBuy = _jackPotXFeeOnBuy;
        buybackFeeOnBuy = _buybackFeeOnBuy;
        totalBuyFees = _liquidityFeeOnBuy + _marketingFeeOnBuy + _stakingFeeOnBuy + _rewardFeeOnBuy + _charityFeeOnBuy + _jackPotXFeeOnBuy + _buybackFeeOnBuy;
        require(totalBuyFees + totalSellFees <= 250, "Total fees cannot be more than 25%");
        emit ChangedBuyFees(_liquidityFeeOnBuy, _marketingFeeOnBuy, _stakingFeeOnBuy, _rewardFeeOnBuy, _charityFeeOnBuy, _jackPotXFeeOnBuy, _buybackFeeOnBuy);
    }  

    function setSellFeesPercent(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell,uint256 _stakingFeeOnSell,uint256 _rewardFeeOnSell,uint256 _charityFeeOnSell, uint256 _jackPotXFeeOnSell, uint256 _buybackFeeOnSell) external onlyOwner {
        liquidityFeeOnSell = _liquidityFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        stakingFeeOnSell = _stakingFeeOnSell;
        rewardFeeOnSell = _rewardFeeOnSell;
        charityFeeOnSell = _charityFeeOnSell;
        jackPotXFeeOnSell = _jackPotXFeeOnSell;
        buybackFeeOnSell = _buybackFeeOnSell;
        totalSellFees = _liquidityFeeOnSell + _marketingFeeOnSell + _stakingFeeOnSell + _rewardFeeOnSell + _charityFeeOnSell + _jackPotXFeeOnSell + _buybackFeeOnSell;
        require(totalBuyFees + totalSellFees <= 250, "Total fees cannot be more than 25%");
        emit ChangedSellFees(_liquidityFeeOnSell, _marketingFeeOnSell, _stakingFeeOnSell, _rewardFeeOnSell, _charityFeeOnSell, _jackPotXFeeOnSell, _buybackFeeOnSell);
    }

    function setBuyFees() private {
        if(_liquidityFee == liquidityFeeOnBuy && _marketingFee == marketingFeeOnBuy && _stakingFee == stakingFeeOnBuy && _rewardFee == rewardFeeOnBuy && _charityFee == charityFeeOnBuy && _jackPotXFee == jackPotXFeeOnBuy && _buybackFee == buybackFeeOnBuy){
            return;
        }
        _liquidityFee = liquidityFeeOnBuy;
        _marketingFee = marketingFeeOnBuy;
        _stakingFee = stakingFeeOnBuy;
        _rewardFee = rewardFeeOnBuy;
        _charityFee = charityFeeOnBuy;
        _jackPotXFee = jackPotXFeeOnBuy;
        _buybackFee = buybackFeeOnBuy;
    }

    function setSellFees() private {
        if(_liquidityFee==liquidityFeeOnSell && _marketingFee==marketingFeeOnSell && _stakingFee==stakingFeeOnSell && _rewardFee==rewardFeeOnSell && _charityFee==charityFeeOnSell && _jackPotXFee==jackPotXFeeOnSell && _buybackFee==buybackFeeOnSell){
            return;
        }
        _liquidityFee = liquidityFeeOnSell;
        _marketingFee = marketingFeeOnSell;
        _stakingFee = stakingFeeOnSell;
        _rewardFee = rewardFeeOnSell;
        _charityFee = charityFeeOnSell;
        _jackPotXFee = jackPotXFeeOnSell;
        _buybackFee = buybackFeeOnSell;
    }

    function setResetFees() private {
        if(_liquidityFee==0 && _marketingFee==0 && _stakingFee==0 && _rewardFee==0 && _charityFee==0 && _jackPotXFee==0 && _buybackFee==0){
            return;
        }        
        _liquidityFee = 0;
        _marketingFee = 0;
        _stakingFee = 0;
        _rewardFee = 0;
        _charityFee = 0;
        _jackPotXFee = 0;
        _buybackFee = 0;
    }
}
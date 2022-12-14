/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-01
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

contract AngelInvestToken is Context, IERC20, Ownable {
    using Address for address;
    using Address for address payable;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name     = "angelInvest";
    string private _symbol   = "AVI";  
    uint8  private _decimals = 18;
   
    uint256 private constant MAX = type(uint256).max;
    uint256 private _tTotal = 1e13 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public rewardNativeTokenonBuy;
    uint256 public rewardNativeTokenonSell;

    uint256 public developmentFeeonBuy;
    uint256 public developmentFeeonSell;

    uint256 public teamFeeonBuy;
    uint256 public teamFeeonSell;

    uint256 public marketingFeeonBuy;
    uint256 public marketingFeeonSell;

    uint256 public _rewardNativeToken;
    uint256 public _developmentFee;
    uint256 public _teamFee;
    uint256 public _marketingFee;

    uint256 public totalBuyFees;
    uint256 public totalSellFees;

    address public marketingWallet;
    address public developmentWallet;
    address public teamWallet;

    uint256 public walletToWalletFee;
    
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    bool private inSwapAndLiquify;
    bool public swapEnabled;
    uint256 public swapTokensAtAmount;

    uint256 public launchTime;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event MarketingWalletChanged(address marketingWallet);
    event DevelopmentWalletChanged(address developmentWallet);
    event TeamWalletChanged(address teamWallet);
    event SwapEnabledUpdated(bool enabled);
    event SwapTokensAtAmountUpdated(uint256 amount);
    event SellFeePercentagesChanged(uint256 rewardNativeToken, uint256 developmentFee, uint256 teamFee, uint256 marketingFee);
    event BuyFeePercentagesChanged(uint256 rewardNativeToken, uint256 developmentFee, uint256 teamFee, uint256 marketingFee);
    event WalletToWalletTransferWithoutFeeEnabled(bool enabled);
    event UpdateWalletToWalletFee(uint256 walletToWalletFee);
    
    constructor() 
    { 
        address newOwner = 0x4D26D5D678aF9696817cf38F9d59Ed8D3f4cAc5a;
        transferOwnership(newOwner);
        
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router =  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), MAX);
        rewardNativeTokenonBuy = 2;
        rewardNativeTokenonSell = 4;

        developmentFeeonBuy = 1;
        developmentFeeonSell = 2;

        teamFeeonBuy = 1;
        teamFeeonSell = 2;

        marketingFeeonBuy = 1;
        marketingFeeonSell = 2;

        _rewardNativeToken = rewardNativeTokenonBuy;
        _developmentFee = developmentFeeonBuy;
        _teamFee = teamFeeonBuy;
        _marketingFee = marketingFeeonBuy;

        totalBuyFees = rewardNativeTokenonBuy + developmentFeeonBuy + teamFeeonBuy + marketingFeeonBuy;
        totalSellFees = rewardNativeTokenonSell + developmentFeeonSell + teamFeeonSell + marketingFeeonSell;

        marketingWallet = 0x0E8682f438B4D1e6061242096974Ffb7ed20eC65;
        developmentWallet = 0x4ff01dC2d032EE96baB565d4483ccAA396C8e409;
        teamWallet = 0x4D26D5D678aF9696817cf38F9d59Ed8D3f4cAc5a;
        
        swapEnabled = true;
        swapTokensAtAmount = _tTotal / 5000;

        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[DEAD] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[developmentWallet] = true;
        _isExcludedFromFees[teamWallet] = true;
        _isExcludedFromFees[address(this)] = true;

        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
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
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
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
        //require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }
//------------------Private Reflection Token Mechanism------------------//

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256[4] memory)  {
        (uint256 tTransferAmount, uint256[4] memory tFees) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFees, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFees);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256[4] memory) {
        uint256 tFee = calculateRewardNativeToken(tAmount);
        uint256 tDevelopment = calculateDevelopmentFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tTeam = calculateTeamFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tDevelopment - tMarketing - tTeam;
        return (tTransferAmount, [tFee,tDevelopment,tMarketing,tTeam]);
    }

    function _getRValues(uint256 tAmount,uint256[4] memory tFees, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFees[0] * currentRate;
        uint256 rDevelopment = tFees[1] * currentRate;
        uint256 rMarketing = tFees[2] * currentRate;
        uint256 rTeam = tFees[3] * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rDevelopment - rMarketing - rTeam;
        return (rAmount, rTransferAmount, rFee);
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
    
    function _takeDevelopment(uint256 tDevelopment) private {
        if (tDevelopment > 0) {
            uint256 currentRate =  _getRate();
            uint256 rDevelopment = tDevelopment * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rDevelopment;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tDevelopment;
        }
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

    function _takeTeam(uint256 tTeam) private {
        if (tTeam > 0) {
            uint256 currentRate =  _getRate();
            uint256 rTeam = tTeam * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rTeam;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tTeam;
        }
    }
    
    function calculateRewardNativeToken(uint256 _amount) private view returns (uint256) {
        return _amount * _rewardNativeToken / 100;
    }

    function calculateDevelopmentFee(uint256 _amount) private view returns (uint256) {
        return _amount * _developmentFee / 100;
    }
    
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _marketingFee / 100;
    }

    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount * _teamFee / 100;
    }
    
    function removeAllFee() private {
       if(_rewardNativeToken == 0 && _developmentFee == 0 && _marketingFee == 0 && _teamFee == 0) return;

        _rewardNativeToken = 0;
        _developmentFee = 0;
        _marketingFee = 0;
        _teamFee = 0;
    }
    
    function setBuyFee() private{
        if(_rewardNativeToken == rewardNativeTokenonBuy && _developmentFee == developmentFeeonBuy && _marketingFee == marketingFeeonBuy && _teamFee == teamFeeonBuy) return;

        _rewardNativeToken = rewardNativeTokenonBuy;
        _developmentFee = developmentFeeonBuy;
        _marketingFee = marketingFeeonBuy;
        _teamFee = teamFeeonBuy;

    }

    function setSellFee() private{
        if(_rewardNativeToken == rewardNativeTokenonSell && _developmentFee == developmentFeeonSell && _marketingFee == marketingFeeonSell && _teamFee == teamFeeonSell) return;

        _rewardNativeToken = rewardNativeTokenonSell;
        _developmentFee = developmentFeeonSell;
        _marketingFee = marketingFeeonSell;
        _teamFee = teamFeeonSell;
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

//------------------Transfer------------------//

    function enableTrade() external onlyOwner() {
        require(launchTime==0,"Trade already enabled");
        launchTime=block.timestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            require(launchTime!=0,"Not launched yet");
        }

        if (maxWalletLimitEnabled) {
            if (_isExcludedFromMaxWalletLimit[from] == false
                && _isExcludedFromMaxWalletLimit[to] == false &&
                to != uniswapV2Pair
            ) {
                uint balance  = balanceOf(to);
                require(balance + amount <= maxWalletAmount(), "MaxWallet: Transfer amount exceeds the maxWalletAmount");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapEnabled
        ) {
            inSwapAndLiquify = true;
            
            uint256 marketingShare = marketingFeeonBuy + marketingFeeonSell;
            uint256 developmentShare = developmentFeeonBuy + developmentFeeonSell;
            uint256 teamShare = teamFeeonBuy + teamFeeonSell;
            uint256 totalShare = marketingShare + developmentShare + teamShare;

            if(totalShare > 0) {

                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();


                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0, // accept any amount of ETH
                    path,
                    address(this),
                    block.timestamp);

                uint256 newBalance = address(this).balance - initialBalance;

                if(marketingShare > 0) {
                    uint256 marketingTokens = newBalance * marketingShare / totalShare;
                    payable(marketingWallet).sendValue(marketingTokens);
                }

                if(developmentShare > 0) {
                    uint256 developmentTokens = newBalance * developmentShare / totalShare;
                    payable(developmentWallet).sendValue(developmentTokens);
                }

                if(teamShare > 0) {
                    uint256 teamTokens = newBalance * teamShare / totalShare;
                    payable(teamWallet).sendValue(teamTokens);
                }
            }
            inSwapAndLiquify = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount);
    }
//------------------Swap------------------//
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner() {
        require(newAmount > totalSupply() / 1e5, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountUpdated(newAmount);
    }
    
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapEnabledUpdated(_enabled);
    }

//------------------TaxAndTransfer------------------//
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if ((_isExcludedFromFees[sender] || 
            _isExcludedFromFees[recipient] )
            ) {
            removeAllFee();
        }else if(launchTime + 30 seconds > block.timestamp){
            _rewardNativeToken = 50;
        }else if(recipient == uniswapV2Pair){
            setSellFee();
        }else if(sender == uniswapV2Pair){
            setBuyFee();
        }else{
            removeAllFee();
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256[4] memory tFees) = _getValues(tAmount);
        uint256 tFee=tFees[0];
        uint256 tDevelopment=tFees[1];
        uint256 tMarketing=tFees[2];
        uint256 tTeam=tFees[3];
    
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);

        if(tAmount-tTransferAmount > 0){
            emit Transfer(sender, address(this), tAmount-tTransferAmount);
        }
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256[4] memory tFees) = _getValues(tAmount);
        uint256 tFee=tFees[0];
        uint256 tDevelopment=tFees[1];
        uint256 tMarketing=tFees[2];
        uint256 tTeam=tFees[3];
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);           
        _takeDevelopment(tDevelopment);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tAmount-tTransferAmount > 0){
            emit Transfer(sender, address(this), tAmount-tTransferAmount);
        }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256[4] memory tFees) = _getValues(tAmount);
        uint256 tFee=tFees[0];
        uint256 tDevelopment=tFees[1];
        uint256 tMarketing=tFees[2];
        uint256 tTeam=tFees[3];
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
        _takeMarketing(tMarketing);  
        _takeDevelopment(tDevelopment);
        _takeTeam(tTeam);        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tAmount-tTransferAmount > 0){
            emit Transfer(sender, address(this), tAmount-tTransferAmount);
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256[4] memory tFees) = _getValues(tAmount);
        uint256 tFee=tFees[0];
        uint256 tDevelopment=tFees[1];
        uint256 tMarketing=tFees[2];
        uint256 tTeam=tFees[3];
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);        
        _takeDevelopment(tDevelopment);
        _takeTeam(tTeam); 
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tAmount-tTransferAmount > 0){
            emit Transfer(sender, address(this), tAmount-tTransferAmount);
        }
    }

//------------------FeeManagment------------------//
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function changeMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != marketingWallet, "Marketing wallet is already that address");
        require(_marketingWallet!=address(0), "Marketing wallet is the zero address");
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeDevelopmentWallet(address _developmentWallet) external onlyOwner {
        require(_developmentWallet != developmentWallet, "Development wallet is already that address");
        require(_developmentWallet!=address(0), "Development wallet is the zero address");
        developmentWallet = _developmentWallet;
        emit DevelopmentWalletChanged(developmentWallet);
    }

    function updateWalletToWalletFee(uint256 _walletToWalletFee) external onlyOwner{
        require(_walletToWalletFee <= 15, "Fees must be less than 15%");
        walletToWalletFee = _walletToWalletFee;
        emit UpdateWalletToWalletFee(_walletToWalletFee);
    }


    function changeTeamWallet(address _teamWallet) external onlyOwner {
        require(_teamWallet != teamWallet, "Team wallet is already that address");
        require(_teamWallet!=address(0), "Team wallet is the zero address");
        teamWallet = _teamWallet;
        emit TeamWalletChanged(teamWallet);
    }

  function setBuyFeePercentages(uint256 _rewardNativeTokenonBuy, uint256 _developmentFeeonBuy, uint256 _marketingFeeonBuy, uint256 _teamFeeonBuy) external onlyOwner {
        require(_rewardNativeTokenonBuy + _developmentFeeonBuy + _marketingFeeonBuy + _teamFeeonBuy <= 15, "Buy fee cannot be more than 15%");
        rewardNativeTokenonBuy = _rewardNativeTokenonBuy;
        developmentFeeonBuy = _developmentFeeonBuy;
        marketingFeeonBuy = _marketingFeeonBuy;
        teamFeeonBuy = _teamFeeonBuy;
        emit BuyFeePercentagesChanged(rewardNativeTokenonBuy, developmentFeeonBuy, marketingFeeonBuy, teamFeeonBuy);
    }

   function setSellFeePercentages(uint256 _rewardNativeTokenonSell, uint256 _developmentFeeonSell, uint256 _marketingFeeonSell, uint256 _teamFeeonSell) external onlyOwner {
        require(_rewardNativeTokenonSell + _developmentFeeonSell + _marketingFeeonSell + _teamFeeonSell <= 15, "Sell fee cannot be more than 15%");
        rewardNativeTokenonSell = _rewardNativeTokenonSell;
        developmentFeeonSell = _developmentFeeonSell;
        marketingFeeonSell = _marketingFeeonSell;
        teamFeeonSell = _teamFeeonSell;
        emit SellFeePercentagesChanged(rewardNativeTokenonSell, developmentFeeonSell, marketingFeeonSell, teamFeeonSell);
    }

//=======MaxWallet=======//
    mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    bool    public maxWalletLimitEnabled = true;
    uint256 private maxWalletLimitRate   = 50;

    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    event MaxWalletLimitRateChanged(uint256 maxWalletLimitRate);
    event MaxWalletLimitStateChanged(bool maxWalletLimit);

    function setEnableMaxWalletLimit(bool enable) external onlyOwner {
        require(enable != maxWalletLimitEnabled, "Max wallet limit is already that state");
        maxWalletLimitEnabled = enable;
        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function isExcludedFromMaxWalletLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxWalletLimit[account];
    }

    function maxWalletAmount() public view returns (uint256) {
        return totalSupply() * maxWalletLimitRate / 1000;
    }

    function setMaxWalletRate_Denominator1000(uint256 _val) external onlyOwner {
        require(_val >= 10, "Max wallet percentage cannot be lower than 1%");
        maxWalletLimitRate = _val;
        emit MaxWalletLimitRateChanged(maxWalletLimitRate);
    }

    function setExcludeFromMaxWallet(address account, bool exclude) external onlyOwner {
        require(_isExcludedFromMaxWalletLimit[account] != exclude, "Account is already set to that state");
        _isExcludedFromMaxWalletLimit[account] = exclude;
        emit ExcludedFromMaxWalletLimit(account, exclude);
    }

}
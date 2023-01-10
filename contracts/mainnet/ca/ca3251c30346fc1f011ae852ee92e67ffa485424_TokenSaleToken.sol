/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

/**
 *Submitted for verification at Etherscan.io on 2022-12-07
*/
/**


/$$$$$$$$        /$$                                  /$$$$$$            /$$          
|__  $$__/       | $$                                 /$$__  $$          | $$          
   | $$  /$$$$$$ | $$   /$$  /$$$$$$  /$$$$$$$       | $$  \__/  /$$$$$$ | $$  /$$$$$$ 
   | $$ /$$__  $$| $$  /$$/ /$$__  $$| $$__  $$      |  $$$$$$  |____  $$| $$ /$$__  $$
   | $$| $$  \ $$| $$$$$$/ | $$$$$$$$| $$  \ $$       \____  $$  /$$$$$$$| $$| $$$$$$$$
   | $$| $$  | $$| $$_  $$ | $$_____/| $$  | $$       /$$  \ $$ /$$__  $$| $$| $$_____/
   | $$|  $$$$$$/| $$ \  $$|  $$$$$$$| $$  | $$      |  $$$$$$/|  $$$$$$$| $$|  $$$$$$$
   |__/ \______/ |__/  \__/ \_______/|__/  |__/       \______/  \_______/|__/ \_______/
                                                                                       
                                                                                       

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

contract TokenSaleToken is Context, IERC20, Ownable {

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExchange;
    address[] private _excluded;

    string private _name     = "TokenSaleToken";
    string private _symbol   = "TST";  
    uint8  private _decimals = 7;
   
    uint256 private constant MAX = type(uint256).max;
    uint256 private _tTotal = 1_000_0000 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public taxFeeonBuy;
    uint256 public taxFeeonSell;
    uint256 public taxFeeonTransfer;
    uint256 public taxFeeonExchange; 

    uint256 public projectFeeonBuy;
    uint256 public projectFeeonSell;
    uint256 public projectFeeonTransfer;
    uint256 public projectFeeonExchange;

    uint256 public buybackFeeonBuy;
    uint256 public buybackFeeonSell;
    uint256 public buybackFeeonTransfer;
    uint256 public buybackFeeonExchange;

    uint256 public burnFeeonBuy;
    uint256 public burnFeeonSell;
    uint256 public burnFeeonTransfer;
    uint256 public burnFeeonExchange;

    uint256 public totalBuyFees;
    uint256 public totalSellFees;
    uint256 public totalTransferFees;
    uint256 public totalExchangeFees;

    uint256 private _taxFee;
    uint256 private _projectFee;
    uint256 private _buybackFee;
    uint256 private _burnFee;

    address public projectWallet;
    address private DEAD;
    address public operator;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    bool private inSwapAndLiquify;
    bool public swapEnabled;
    uint256 public swapTokensAtAmount;
    bool public tradeEnabled;

    uint256 public bnbValueForBuyBurn;
    uint256 public accumulatedBuybackBNB;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event BuybackAndBurn(uint256 bnbSend);
    event SendProject(uint256 bnbSend);
    event ProjectWalletUpdated(address indexed newWallet);
    event BuyFeesUpdated(uint256 taxFee, uint256 projectFee, uint256 buybackFee, uint256 burnFee);
    event SellFeesUpdated(uint256 taxFee, uint256 projectFee, uint256 buybackFee, uint256 burnFee);
    event TransferFeesUpdated(uint256 taxFee, uint256 projectFee, uint256 buybackFee, uint256 burnFee);
    event ExchangeFeesUpdated(uint256 taxFee, uint256 projectFee, uint256 buybackFee, uint256 burnFee);
    event IsExchange(address indexed account, bool isExchange);
    constructor() 
    { 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), MAX);

        projectWallet = 0xfBE381D8c5bC3158A8E1C421959d2Da66A91F680;
        DEAD = 0x000000000000000000000000000000000000dEaD;
        operator = 0x1c5f9510a41D358dae6f42FD8a0d8E51F856f955;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectWallet] = true;
        _isExcludedFromFees[operator] = true;

        swapEnabled = true;
        swapTokensAtAmount = _tTotal / 5000;

        taxFeeonBuy = 10;
        taxFeeonSell = 10;
        taxFeeonTransfer = 0;
        taxFeeonExchange = 0;

        projectFeeonBuy = 90;
        projectFeeonSell = 90;
        projectFeeonTransfer = 0;
        projectFeeonExchange = 0;

        buybackFeeonBuy = 10;
        buybackFeeonSell = 10;
        buybackFeeonTransfer = 0;
        buybackFeeonExchange = 0;

        burnFeeonBuy = 1;
        burnFeeonSell = 1;
        burnFeeonTransfer = 1;
        burnFeeonExchange = 1;

        totalBuyFees = taxFeeonBuy + projectFeeonBuy + buybackFeeonBuy + burnFeeonBuy;
        totalSellFees = taxFeeonSell + projectFeeonSell + buybackFeeonSell + burnFeeonSell;
        totalTransferFees = taxFeeonTransfer + projectFeeonTransfer + buybackFeeonTransfer + burnFeeonTransfer;
        totalExchangeFees = taxFeeonExchange + projectFeeonExchange + buybackFeeonExchange + burnFeeonExchange;

        bnbValueForBuyBurn = 2e18;


        _rOwned[operator] = _rTotal;
        emit Transfer(address(0), operator, _tTotal);
    }
    
    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }
//---------- General ERC20 Reflection Functions ----------//
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
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
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
        require(_isExcluded[account], "Account is already excluded");
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
            payable(msg.sender).transfer(address(this).balance - accumulatedBuybackBNB);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tProject, uint256 tMarketing) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tProject, tMarketing, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tProject, tMarketing);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tProject = calculateProjectFee(tAmount);
        uint256 tBuyback = calculateBuybackFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tProject - tBuyback;
        return (tTransferAmount, tFee, tProject, tBuyback);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tProject, uint256 tBuyback, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rProject = tProject * currentRate;
        uint256 rBuyback = tBuyback * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rProject - rBuyback;
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
    
    function _takeProject(uint256 tProject) private {
        if (tProject > 0) {
            uint256 currentRate =  _getRate();
            uint256 rProject = tProject * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rProject;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tProject;
        }
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
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount * _taxFee / 1000;
    }

    function calculateProjectFee(uint256 _amount) private view returns (uint256) {
        return _amount * _projectFee / 1000;
    }
    
    function calculateBuybackFee(uint256 _amount) private view returns (uint256) {
        return _amount * _buybackFee / 1000;
    }
    
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount * _burnFee / 1000;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExchange(address account) public view returns(bool) {
        return _isExchange[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
//---------- Transfer ----------//

    function tradeEnable() external{
        require(!tradeEnabled && (operator==msg.sender || owner()==msg.sender), "Trade is already enabled");
        tradeEnabled = true;

    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(tradeEnabled ||
                _isExcludedFromFees[from] ||
                _isExcludedFromFees[to], "Trade is not enabled yet");

        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapEnabled
        ) {
            inSwapAndLiquify = true;
            
            uint256 projectShare = projectFeeonBuy + projectFeeonSell + projectFeeonTransfer + projectFeeonExchange;
            uint256 buybackShare = buybackFeeonBuy + buybackFeeonSell + buybackFeeonTransfer + buybackFeeonExchange;
            uint256 totalFees = projectShare + buybackShare;
            if(totalFees > 0) {
                
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

                if(projectShare > 0) {
                    uint256 projectTokens = newBalance * projectShare / totalFees;
                    sendBNB(payable(projectWallet), projectTokens);
                }
                
                if(buybackShare > 0) {
                    uint256 buybackBNB = newBalance * buybackShare / totalFees;
                    accumulatedBuybackBNB += buybackBNB;
                    if (accumulatedBuybackBNB > bnbValueForBuyBurn) {
                        if (address(this).balance >= accumulatedBuybackBNB) {
                            buyBack(accumulatedBuybackBNB);
                        } else {
                            buyBack(address(this).balance);
                        }
                        accumulatedBuybackBNB = 0;
                    }
                } 
            }
            inSwapAndLiquify = false;
        }
        
        //transfer amount, it will take tax, burn, project fee
        _tokenTransfer(from,to,amount);
    }

//---------- Swap ----------//

    function setBNBValueForBuyBackBurn(uint value) external onlyOwner {
        require(value >= 1, "Threshold must be greater than 0.1 BNB");
        bnbValueForBuyBurn = value * (10**17);
    }
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner() {
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
    }
    
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapEnabledUpdated(_enabled);
    }

    function buyBack(uint256 BNBAmount) internal {
        address[] memory path = new address[](2);

        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBAmount}(
            0, // accept any amount of ETH
            path, 
            DEAD,
            block.timestamp);

        emit BuybackAndBurn(BNBAmount);
    }

//---------- Tax and Transfer ----------//
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcludedFromFees[sender] || 
            _isExcludedFromFees[recipient] 
        ) {
            setResetFees();
        }else if(_isExchange[sender] ||
                 _isExchange[recipient]){
            setExchangeFees();
        }else if(recipient == uniswapV2Pair){
            setSellFees();
        }else if(sender == uniswapV2Pair){
            setBuyFees();
        }else{
            setTransferFees();
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

    function _takeBurn(address sender, uint256 tTransferAmount, uint256 rTransferAmount, uint256 tAmount) private returns (uint256, uint256) {
        if(_burnFee==0)   
            return(tTransferAmount, rTransferAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 rBurn = tBurn * _getRate();
        rTransferAmount = rTransferAmount - rBurn;
        tTransferAmount = tTransferAmount - tBurn;
        _rTotal -= rBurn;
        _tTotal -= tBurn;
        emit Transfer(sender, address(0), tBurn);
        return(tTransferAmount, rTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tProject, uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeBurn(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeBuyback(tBuyback);
        _takeProject(tProject);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, address(this), tBuyback);
        emit Transfer(sender, address(this), tProject);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tProject, uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeBurn(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeBuyback(tBuyback);
        _takeProject(tProject);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, address(this), tBuyback);
        emit Transfer(sender, address(this), tProject);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tProject, uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeBurn(sender, tTransferAmount, rTransferAmount, tAmount);        
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
        _takeBuyback(tBuyback);
        _takeProject(tProject);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, address(this), tBuyback);
        emit Transfer(sender, address(this), tProject);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tProject, uint256 tBuyback) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeBurn(sender, tTransferAmount, rTransferAmount, tAmount);        
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeBuyback(tBuyback);
        _takeProject(tProject);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, address(this), tBuyback);
        emit Transfer(sender, address(this), tProject);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function setBuyFees() internal{
        if(_taxFee==taxFeeonBuy && _projectFee==projectFeeonBuy && _buybackFee==buybackFeeonBuy && _burnFee==burnFeeonBuy)
            return;
        _taxFee = taxFeeonBuy;
        _projectFee = projectFeeonBuy;
        _buybackFee = buybackFeeonBuy;
        _burnFee = burnFeeonBuy;
    }

    function setSellFees() internal{
        if(_taxFee==taxFeeonSell && _projectFee==projectFeeonSell && _buybackFee==buybackFeeonSell && _burnFee==burnFeeonSell)
            return;
        _taxFee = taxFeeonSell;
        _projectFee = projectFeeonSell;
        _buybackFee = buybackFeeonSell;
        _burnFee = burnFeeonSell;
    }

    function setTransferFees() internal{
        if(_taxFee==taxFeeonTransfer && _projectFee==projectFeeonTransfer && _buybackFee==buybackFeeonTransfer && _burnFee==burnFeeonTransfer)
            return;
        _taxFee = taxFeeonTransfer;
        _projectFee = projectFeeonTransfer;
        _buybackFee = buybackFeeonTransfer;
        _burnFee = burnFeeonTransfer;
    }

    function setExchangeFees() internal{
        if(_taxFee==taxFeeonExchange && _projectFee==projectFeeonExchange && _buybackFee==buybackFeeonExchange && _burnFee==burnFeeonExchange)
            return;
        _taxFee = taxFeeonExchange;
        _projectFee = projectFeeonExchange;
        _buybackFee = buybackFeeonExchange;
        _burnFee = burnFeeonExchange;
    }

    function setResetFees() internal{
        if(_taxFee==0 && _projectFee==0 && _buybackFee==0 && _burnFee==0)
            return;
        _taxFee = 0;
        _projectFee = 0;
        _buybackFee = 0;
        _burnFee = 0;
    }

//---------- Fee Managment ----------//
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setIsExchange(address account, bool enabled) external onlyOwner {
        require(_isExchange[account] != enabled, "Account is already the value of 'enabled'");
        _isExchange[account] = enabled;

        emit IsExchange(account, enabled);
    }

    function setBuyFeePercent(uint256 _taxFeeonBuy, uint256 _projectFeeonBuy, uint256 _buybackFeeonBuy, uint256 _burnFeeonBuy) external onlyOwner() {
        taxFeeonBuy = _taxFeeonBuy;
        projectFeeonBuy = _projectFeeonBuy;
        buybackFeeonBuy = _buybackFeeonBuy;
        burnFeeonBuy = _burnFeeonBuy;
        totalBuyFees = _taxFeeonBuy + _projectFeeonBuy + _buybackFeeonBuy + _burnFeeonBuy;
        require(totalBuyFees+totalSellFees<=250, "Total fees cannot be more than 25%");
        emit BuyFeesUpdated(_taxFeeonBuy, _projectFeeonBuy, _buybackFeeonBuy, _burnFeeonBuy);
    }

    function setSellFeePercent(uint256 _taxFeeonSell, uint256 _projectFeeonSell, uint256 _buybackFeeonSell, uint256 _burnFeeonSell) external onlyOwner() {
        require(_taxFeeonSell + _projectFeeonSell + _buybackFeeonSell + _burnFeeonSell <= 250, "Total fees cannot be more than 25%");
        taxFeeonSell = _taxFeeonSell;
        projectFeeonSell = _projectFeeonSell;
        buybackFeeonSell = _buybackFeeonSell;
        burnFeeonSell = _burnFeeonSell;
        totalSellFees = _taxFeeonSell + _projectFeeonSell + _buybackFeeonSell + _burnFeeonSell;
        require(totalBuyFees+totalSellFees <= 250, "Total fees cannot be more than 25%");
        emit SellFeesUpdated(_taxFeeonSell, _projectFeeonSell, _buybackFeeonSell, _burnFeeonSell);
    }

    function setTransferFeePercent(uint256 _taxFeeonTransfer, uint256 _projectFeeonTransfer, uint256 _buybackFeeonTransfer, uint256 _burnFeeonTransfer) external onlyOwner() {
        require(_taxFeeonTransfer + _projectFeeonTransfer + _buybackFeeonTransfer + _burnFeeonTransfer <= 250, "Total fees cannot be more than 25%");
        taxFeeonTransfer = _taxFeeonTransfer;
        projectFeeonTransfer = _projectFeeonTransfer;
        buybackFeeonTransfer = _buybackFeeonTransfer;
        burnFeeonTransfer = _burnFeeonTransfer;
        totalTransferFees = _taxFeeonTransfer + _projectFeeonTransfer + _buybackFeeonTransfer + _burnFeeonTransfer;
        require(totalTransferFees <= 150, "Total fees cannot be more than 15%");

        emit TransferFeesUpdated(_taxFeeonTransfer, _projectFeeonTransfer, _buybackFeeonTransfer, _burnFeeonTransfer);
    }

    function setExchangeFeePercent(uint256 _taxFeeonExchange, uint256 _projectFeeonExchange, uint256 _buybackFeeonExchange, uint256 _burnFeeonExchange) external onlyOwner() {
        require(_taxFeeonExchange + _projectFeeonExchange + _buybackFeeonExchange + _burnFeeonExchange <= 250, "Total fees cannot be more than 25%");
        taxFeeonExchange = _taxFeeonExchange;
        projectFeeonExchange = _projectFeeonExchange;
        buybackFeeonExchange = _buybackFeeonExchange;
        burnFeeonExchange = _burnFeeonExchange;
        totalExchangeFees = _taxFeeonExchange + _projectFeeonExchange + _buybackFeeonExchange + _burnFeeonExchange;
        require(totalExchangeFees <= 100, "Total fees cannot be more than 10%");
        emit ExchangeFeesUpdated(_taxFeeonExchange, _projectFeeonExchange, _buybackFeeonExchange, _burnFeeonExchange);
    }

    function changeProjectWallet(address newProjectWallet) external onlyOwner() {
        require(newProjectWallet != projectWallet, "Already setted.");
        require(newProjectWallet != address(0), "Cannot be zero address");
        require(!isContract(newProjectWallet), "Cannot be contract address");
        projectWallet = newProjectWallet;
        emit ProjectWalletUpdated(newProjectWallet);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}
        
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function multiTransfer(address[] memory recipients, uint256[] memory amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

contract Squidy is Context, IBEP20, Ownable {
     using SafeMath for uint256;
    address public constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private _totalSupply = 100000000000 * (10**9);    
    string private constant _name     = "SquidTester";
    string private constant _symbol   = "STEST";
    uint8  private constant _decimals = 9;

    uint256 private _lpPercForTeam = 0;
    uint256 private _lpPercForMarketing = 8000;

    //Launch Variables
    bool public isLaunched = false;
    bool public providingLP = false;
    uint256 private launchBlock;
    uint256 private launchTax = 99;
    uint256 private deadBlocks = 5;

    mapping(address => bool) private _isBlacklisted;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromTxLimit;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) public isTimelockExempt;

    mapping(address => bool) private _isExcludedFromAutoLiquidity;
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) private _allowedTransfer;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private _marketingWallet;
    address private _teamWallet;
    address private _charityWallet;
    address private _lpFeeReceiver;
    address private deployer;

    // buy fee
    uint256 public  _liquidityFeeBuy = 8;
    // sell fee
    uint256 public  _liquidityFeeSell = 8;
    // Total fees
    uint256 public totalFees = _liquidityFeeBuy + _liquidityFeeSell;

    uint256 _maxTxAmount              = _totalSupply * 200 / 10000; // 2% of the total supply
    uint256 _minTokenBalance          = _totalSupply / 400;

    // auto liquidity
    IUniswapV2Router02 public uniswapV2Router;
    address            public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );

    // Cooldown & timer functionality
    bool public opCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 1;
    mapping (address => uint) private cooldownTimer;

    event TeamSent(address to, uint256 bnbSent);
    event MarketingSent(address to, uint256 bnbSent);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address _marketing,
        address _team,
        address _deployer,
        address _lpFeeWallet
    ) {

        _balances[owner()] = _totalSupply;

        _marketingWallet = _marketing;
        _teamWallet      = _team;
        _lpFeeReceiver   = _lpFeeWallet;
        deployer        = _deployer;

        // uniswap
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        //Exclude system contract
        _isExcludedFromFees[owner()]     = true;
        _isExcludedFromFees[address(this)]  = true;

        _isExcludedFromAutoLiquidity[uniswapV2Pair]             = true;
        _isExcludedFromAutoLiquidity[address(uniswapV2Router)]  = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[_burnAddress] = true;
        isTimelockExempt[address(this)] = true;
        
        //Exclude from MaxWallet
        _isExcludedFromMaxWallet[owner()]                  = true;
        _isExcludedFromMaxWallet[address(this)]            = true;
        _isExcludedFromMaxWallet[uniswapV2Pair]            = true;
        _isExcludedFromMaxWallet[address(uniswapV2Router)] = true;
        _isExcludedFromMaxWallet[_burnAddress]             = true;
        _isExcludedFromMaxWallet[address(_deployer)]       = true;
        
        //Exclude from MaxTX
        _isExcludedFromTxLimit[owner()] = true;
        _isExcludedFromTxLimit[address(_deployer)]        = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function launch() external onlyOwner {
        require(!isLaunched, "Cannot re-enable trading");
        isLaunched = true;
        providingLP = true;
        launchBlock = block.number;
    }

    /**
    * BASIC BEP20 TOKEN STUFF
    **/
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function cSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(_burnAddress)).sub(balanceOf(address(0)));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function multiTransfer(address[] memory recipients, uint256[] memory amount) external override returns (bool) {
        for(uint i=0; i < recipients.length; i++){
            _transfer(_msgSender(), recipients[i], amount[i]);
        }
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
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

    function _approve(address owner, address spender, uint256 amount) public returns (bool){
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);

        return true;
    }


     /**
    * EXTENDED FUNCTIONS
    **/

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0),"BEP20: transfer from the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    require(!_isBlacklisted[from], "BEP20: Sender is blacklisted");
    require(!_isBlacklisted[to], "BEP20: Receiver is blacklisted");

    if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            require(isLaunched, "Not launched yet..");
    }

     if (!_isExcludedFromTxLimit[from]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
     }

    /*
            - swapAndLiquify will be initiated when token balance of this contract
            has accumulated enough over the minimum number of tokens required.
            - don't get caught in a circular liquidity event.
            - don't swapAndLiquify if sender is uniswap pair.
    */
    uint256 contractTokenBalance = balanceOf(address(this));
        
    if (contractTokenBalance >= _maxTxAmount) {
        contractTokenBalance = _maxTxAmount;
    }

    bool isOverMinTokenBalance = contractTokenBalance >= _minTokenBalance;
    
    if (
            isOverMinTokenBalance &&
            !inSwapAndLiquify &&
            !_isExcludedFromAutoLiquidity[from] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = _minTokenBalance;
            swapAndLiquify(contractTokenBalance);
        }

    bool takeFee = true;
    if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
        takeFee = false;
    }

    _tokenTransfer(from, to, amount, takeFee);

    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal {

        bool isBuy  = sender == uniswapV2Pair && recipient != address(uniswapV2Router);
        bool isSell = recipient == uniswapV2Pair;

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;

        if (!takeFee) {
        fee = 0;
        } else if (isBuy) { 
        fee = ( amount * _liquidityFeeBuy ) / 100;
        feeswap = _liquidityFeeBuy;
        feesum = feeswap;
        } else if (isSell) { 
        fee = ( amount * _liquidityFeeSell ) / 100;
        feeswap = _liquidityFeeSell;
        feesum = feeswap;
        }

        // send to receiver
        basicTransfer(sender,recipient,amount.sub(fee));

        if(fee > 0){
            if(feeswap > 0) {
                //send the fee to the contract
                uint256 feeAmount = (amount * feeswap) / 100;
                basicTransfer(sender,address(this), feeAmount);
            }
        }
    }

    function basicTransfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split contract balance into halves
        uint256 half      = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForBnb(half);

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 bnbForTeam       = newBalance / 10000 * _lpPercForTeam;
        uint256 bnbForMarketing = newBalance / 10000 * _lpPercForMarketing;
        uint256 bnbForLiquidity = newBalance - bnbForTeam - bnbForMarketing;

        if ( bnbForTeam != 0 ) {
            emit TeamSent(_teamWallet, bnbForTeam);
            payable(_teamWallet).transfer(bnbForTeam);
        }
        if ( bnbForMarketing != 0 ) {
            emit MarketingSent(_marketingWallet, bnbForMarketing);
            payable(_marketingWallet).transfer(bnbForMarketing);
        }
        
        (uint256 tokenAdded, uint256 bnbAdded) = addLiquidity(otherHalf, bnbForLiquidity);
        
        emit SwapAndLiquify(half, bnbAdded, tokenAdded);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private returns (uint256, uint256) {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (uint amountToken, uint amountETH, ) = uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(_lpFeeReceiver),
            block.timestamp
        );
        return (uint256(amountToken), uint256(amountETH));
    }

    function updateExemptFee(address _address, bool state) external onlyOwner {
        _isExcludedFromFees[_address] = state;
    }

    function bulkExemptFee(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = state;
        }
    }

    function updateExemptMaxTXLimit(address account, bool state) external onlyOwner {
        _isExcludedFromTxLimit[account] = state;
    }

    function updateExemptMaxWallet(address account, bool state) external onlyOwner {
        _isExcludedFromMaxWallet[account] = state;
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        payable(deployer).transfer(weiAmount);
    }

    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        IBEP20(tokenAdd).transfer(deployer, amount);
    }

    // fallbacks
    receive() external payable {}
}
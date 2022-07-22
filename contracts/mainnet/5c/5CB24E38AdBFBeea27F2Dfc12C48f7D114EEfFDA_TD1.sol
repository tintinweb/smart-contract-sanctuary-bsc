/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.5;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event TransferDetails(address indexed from, address indexed to, uint256 total_Amount, uint256 reflected_amount, uint256 total_TransferAmount, uint256 reflected_TransferAmount);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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




// Begin sauce.
contract TD1 is Context, IERC20, Ownable {
    using Address for address;

    mapping (address => uint256) public _balance_reflected;
    mapping (address => uint256) public _balance_total;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    
    // bye bye bots
    mapping (address => bool) public _isBlacklisted;

    // for presale and airdrop
    mapping (address => bool) public _isWhitelisted;
    
    // add liquidity and do airdrops
    bool public tradingOpen = true;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 20;
    mapping (address => uint) private cooldownTimer;
    
    address[] private _excluded;
    
    uint256 private constant MAX = ~uint256(0);

    uint8 private   _decimals           = 2;
    uint256 private _supply_total       = 5 * 10**5 * 10**_decimals;
    uint256 private _supply_reflected   = (MAX - (MAX % _supply_total));
    string private  _name               = "TD1";
    string private  _symbol             = "TD1";

    // 0 to disable conversion
    // an integer to convert only fixed number of tokens
    uint256 private _fee_bboxTreasury_convert_limit = _supply_total * 1 / 10000;
    uint256 private _fee_marketing_convert_limit = _supply_total * 1 / 10000;

    // Minimum Balance to maintain
    uint256 public _fee_bboxTreasury_min_bal = 0;
    uint256 public _fee_marketing_min_bal = _supply_total * 1 / 100;
    
    //refection fee
    uint256 private _fee_reflection = 0;
    uint256 private _fee_reflection_old = _fee_reflection;
    uint256 private _contractReflectionStored = 0;
    
    // marketing
    uint256 private _fee_marketing = 50;
    uint256 private _fee_marketing_old = _fee_marketing;
    address payable private _wallet_marketing = payable(0x76D4296aCDB4fE17cFcEe0741f54AC6B74A26532);

    // for burn
    uint256 private _fee_burn = 0;
    uint256 private _fee_burn_old = _fee_burn;
    address payable private _wallet_burn = payable(0x76D4296aCDB4fE17cFcEe0741f54AC6B74A26532);

    // for bboxTreasury
    uint256 private _fee_bboxTreasury = 50;
    uint256 private _fee_bboxTreasury_old = _fee_bboxTreasury;
    address payable private _wallet_bboxTreasury = payable(0x36E92cC8a559ACD75dAe34ee18a3a8f0A80DEFD7);

    // Auto LP
    uint256 private _fee_liquidity = 0;
    uint256 private _fee_liquidity_old = _fee_liquidity;
    uint256 private _fee_denominator = 10000;

                                     
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxWalletToken = _supply_total;
    uint256 public _maxTxAmount = _supply_total;

    uint256 private _numTokensSellToAddToLiquidity =  ( _supply_total * 2 ) / 1000;

    uint256 private sellMultiplier = 200;


    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
        
    );

    address PCSRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _balance_reflected[owner()] = _supply_reflected;
        
        // Pancakeswap Router Initialization & Pair creation
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(PCSRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[deadAddress] = true;
        _isExcludedFromFee[_wallet_marketing] = true;
        _isExcludedFromFee[_wallet_burn] = true;
        _isExcludedFromFee[_wallet_bboxTreasury] = true;
       
        emit Transfer(address(0), owner(), _supply_total);
    }


/*  CORE INTERFACE FUNCTION */

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
        return _supply_total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _balance_total[account];
        return tokenFromReflection(_balance_reflected[account]);
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

        require (_allowances[sender][_msgSender()] >= amount,"ERC20: transfer amount exceeds allowance");
        
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()]-amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require (_allowances[_msgSender()][spender] >= subtractedValue,"ERC20: decreased allowance below zero");

        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _contractReflectionStored;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    

/* Interface Read & Write Functions --- Reflection Specific */



    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _supply_reflected, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return (rAmount / currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_balance_reflected[account] > 0) {
            _balance_total[account] = tokenFromReflection(_balance_reflected[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balance_total[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }




/* Interface Read & Write Functions */




    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    
    //set the number of tokens required to activate auto-liquidity
    function setNumTokensSellToAddToLiquidityt(uint256 numTokensSellToAddToLiquidity) external onlyOwner() {
        _numTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity;
    }
    
    //set the Max transaction amount (percent of total supply)
    function setMaxTxPercent_base1000(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = (_supply_total * maxTxPercent ) / 1000;
    }
    
    //set the Max transaction amount (in tokens)
     function setMaxTxTokens(uint256 maxTxTokens) external onlyOwner() {
        _maxTxAmount = maxTxTokens;
    }
    
    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent_base1000(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_supply_total * maxWallPercent ) / 1000;
    }
    
    //settting the maximum permitted wallet holding (in tokens)
     function setMaxWalletTokens(uint256 maxWallTokens) external onlyOwner() {
        _maxWalletToken = maxWallTokens;
    }
    
    
    
    //toggle on and off to activate auto liquidity 
    function setSwapAndLiquifyEnabled(bool _status) public onlyOwner {
        swapAndLiquifyEnabled = _status;
        emit SwapAndLiquifyEnabledUpdated(_status);
    }
    

/** All list management functions BEGIN*/

    function s_manageExcludeFromFee(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludedFromFee[addresses[i]] = status;
        }
    }

    function s_manageBlacklist(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = status;
        }
    }

    function s_manageWhitelist(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isWhitelisted[addresses[i]] = status;
        }
    }

    function s_excludeFromFee(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludedFromFee[addresses[i]] = status;
        }
    }
    

    /** All list management functions END*/










// convert all stored tokens for LP into LP Pairs
    function purgeContractBalance() public {
        require(msg.sender == owner() || msg.sender == _wallet_marketing, "Not authorized to perform this");
         _wallet_marketing.transfer(address(this).balance);
    }







// Reflect Finance core code

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _supply_reflected;
        uint256 tSupply = _supply_total;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_balance_reflected[_excluded[i]] > rSupply || _balance_total[_excluded[i]] > tSupply) return (_supply_reflected, _supply_total);
            rSupply = rSupply - _balance_reflected[_excluded[i]];
            tSupply = tSupply - _balance_total[_excluded[i]];
        }
        if (rSupply < (_supply_reflected/_supply_total)) return (_supply_reflected, _supply_total);
        return (rSupply, tSupply);
    }



    function _fees_to_bnb_process( address payable wallet, uint256 tokensToConvert) private lockTheSwap {

        uint256 rTokensToConvert = tokensToConvert * _getRate();

        _balance_reflected[wallet]    = _balance_reflected[wallet]  - rTokensToConvert;
        if (_isExcluded[wallet]){
            _balance_total[wallet]    = _balance_total[wallet]      - tokensToConvert;
        }
        _balance_reflected[address(this)]      = _balance_reflected[address(this)]    + rTokensToConvert;

        emit Transfer(wallet, address(this), tokensToConvert);

        swapTokensForEthAndSend(tokensToConvert,wallet);

    }


// Fee & Wallet Related

    function fees_to_bnb_manual(uint256 tokensToConvert, address payable feeWallet, uint256 minBalanceToKeep) external onlyOwner {
        _fees_to_bnb(tokensToConvert,feeWallet,minBalanceToKeep);
    }


    function _fees_to_bnb(uint256 tokensToConvert, address payable feeWallet, uint256 minBalanceToKeep) private {
        // case 1: 0 tokens to convert, exit the function
        // case 2: tokens to convert are more than the max limit
        
        if(tokensToConvert == 0){
            return;
        } 

        if(tokensToConvert > _maxTxAmount){
            tokensToConvert = _maxTxAmount;
        }

        if((tokensToConvert+minBalanceToKeep)  <= balanceOf(feeWallet)){
            _fees_to_bnb_process(feeWallet,tokensToConvert);
        }
    }


    function _takeFee(uint256 feeAmount, address receiverWallet) private {
        uint256 reflectedReeAmount = feeAmount * _getRate();
        _balance_reflected[receiverWallet] = _balance_reflected[receiverWallet] + reflectedReeAmount;


        if(_isExcluded[receiverWallet]){
            _balance_total[receiverWallet] = _balance_total[receiverWallet] + feeAmount;
        }

        emit Transfer(msg.sender, receiverWallet, feeAmount);
    }


    function _takefees_Liquidity(uint256 amount) private {
        _takeFee(amount,address(this));
    }
    
    function _takefees_burn(uint256 amount) private {
        _takeFee(amount,_wallet_burn);
        
    }

    function _takefees_bboxTreasury(uint256 amount) private {
        _takeFee(amount,_wallet_bboxTreasury);

    }

    function _takefees_marketing(uint256 amount) private {
        _takeFee(amount,_wallet_marketing);
        
    }

    function _take_reflectionFee(uint256 rFee, uint256 tFee) private {
        _supply_reflected = _supply_reflected - rFee;
        _contractReflectionStored = _contractReflectionStored + tFee;
    }
    








// Liquidity functions

    function swapAndLiquify(uint256 tokensToSwap) private lockTheSwap {
        uint256 tokensHalf = tokensToSwap/2;

        uint256 contractBnbBalance = address(this).balance;

        swapTokensForEth(tokensHalf);
        
        uint256 bnbSwapped = address(this).balance - contractBnbBalance;

        addLiquidity(tokensHalf,bnbSwapped);

        emit SwapAndLiquify(tokensToSwap, tokensHalf, bnbSwapped);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function swapTokensForEthAndSend(uint256 tokenAmount, address payable receiverWallet) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiverWallet,
            block.timestamp
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            0x1fA5D26B4BDf55bC99253b916f4FAdb864A2459E,
            block.timestamp
        );
    }







    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }




    // All transfer functions

    function _transfer(address from, address to, uint256 amount) private {

        require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        // require(amount > 0, "Transfer amount must be greater than zero");


        //max wallet
        if (to != owner() && to != address(this) && to != address(deadAddress) && to != uniswapV2Pair && to != _wallet_marketing && to != _wallet_bboxTreasury){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        if(from != owner() && to != owner() && !_isWhitelisted[from] && !_isWhitelisted[to]){
            require(tradingOpen,"Trading not open yet");
        }


        // cooldown timer
        if (from == uniswapV2Pair &&
            buyCooldownEnabled &&
            !_isExcludedFromFee[to] &&
            to != address(this)  && 
            to != address(deadAddress)) {
            require(cooldownTimer[to] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
        }

        if(from != owner() && to != owner()  && !_isWhitelisted[from] && !_isWhitelisted[to]){
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // extra bracket to supress stack too deep error
        {
            uint256 contractTokenBalance = balanceOf(address(this));
        
            if(contractTokenBalance >= _maxTxAmount) {
                contractTokenBalance = _maxTxAmount - 1;
            }
            
            bool overMinTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
            if (overMinTokenBalance &&
                !inSwapAndLiquify &&
                from != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                contractTokenBalance = _numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
            }

            // Convert fees to BNB
            if(!inSwapAndLiquify && from != uniswapV2Pair){
                _fees_to_bnb(_fee_bboxTreasury_convert_limit,_wallet_bboxTreasury, _fee_bboxTreasury_min_bal);
                _fees_to_bnb(_fee_marketing_convert_limit,_wallet_marketing, _fee_marketing_min_bal);
            }
            
        }
       

    }

    function _transferStandard(address from, address to, uint256 tAmount, uint256 rAmount, uint256 tTransferAmount, uint256 rTransferAmount) private {
         // Update reflected Balance for sender
        _balance_reflected[from]    = _balance_reflected[from]  - rAmount;


        // Only update actual balance of sender if he's excluded from rewards
        if (_isExcluded[from]){
            _balance_total[from]    = _balance_total[from]      - tAmount;
        }

        // Only update actual balance of recipient if he's excluded from rewards
        if (_isExcluded[to]){
            _balance_total[to]      = _balance_total[to]        + tTransferAmount;  
        }

        // update reflected balance of receipient
        _balance_reflected[to]      = _balance_reflected[to]    + rTransferAmount;

        emit Transfer(from, to, tTransferAmount);
        emit TransferDetails(from, to, tAmount, rAmount, tTransferAmount, rTransferAmount);
    }

    //receive BNB from PancakeSwap Router
    receive() external payable {}

}
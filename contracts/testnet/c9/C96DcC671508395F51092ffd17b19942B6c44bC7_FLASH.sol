/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.14;


abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IBEP20 {
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

contract FLASH is Context, IBEP20, Ownable 
{
    using SafeMath for uint256;
    using Address for address;

    address public marketingAddress = 0x01f6ed64AA795E3Fc650A129b59D2408f5B68833;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromWhale;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExemptFromTxLimit;
    address[] private _excluded;
       
    uint256 private constant MAX = ~uint128(0);
    uint256 private _tTotal = 1_000_000_000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Flash Token";
    string private _symbol = "FLASH";
    uint8 private _decimals = 18;
    
    uint256 public _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;
    
    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 _saleLiquidityFee = 3;
    uint256 _saleMarketingFee = 3;

    uint256 public _maxTxAmount = _tTotal.div(100).mul(1); //1% 

    uint256 private _minimumTokensBeforeSwap = 1_00 * 10**18;

    uint256 public _walletHoldingMaxLimit =  _tTotal.div(100).mul(2); // 2%

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    
    event RewardLiquidityProviders(uint256 tokenAmount);
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
    
    constructor () 
    {
        _rOwned[owner()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        emit Transfer(address(0), owner(), _tTotal);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;

        _isExemptFromTxLimit[owner()] = true;
        _isExemptFromTxLimit[address(this)] = true;
        _isExemptFromTxLimit[marketingAddress] = true;
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

    function isExcludedFromReward(address account) public view returns (bool) 
    {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) 
    {
        return _tFeeTotal;
    }
    
    function _minimumTokensBeforeSwapAmount() public view returns (uint256) 
    {
        return _minimumTokensBeforeSwap;
    }


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) 
    {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() 
    {
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


    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isExemptFromTxLimit[from] && !_isExemptFromTxLimit[to]) 
        {
            require(amount <= _maxTxAmount, "Exceeds Max Tx Amount");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= _minimumTokensBeforeSwap;
        
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && from != uniswapV2Pair) {
            if (overMinimumTokenBalance) 
            {
                contractTokenBalance = _minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }
        }

        if(to==uniswapV2Pair) {  setSaleFee(); }
        
        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
        {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;
        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
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
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private 
    {

        if(!takeFee) { removeAllFee(); }

        uint256 marketingTokens = amount.mul(_marketingFee).div(100);
        amount = amount.sub(marketingTokens);

        if (_isExcluded[sender] && !_isExcluded[recipient]) 
        {
            _transferFromExcluded(sender, recipient, amount);
        } 
        else if (!_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferToExcluded(sender, recipient, amount);
        } 
        else if(_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferBothExcluded(sender, recipient, amount);
        } 
        else 
        {
            _transferStandard(sender, recipient, amount);
        }   

        removeAllFee();
        if(marketingTokens>0) {  _transferStandard(sender, marketingAddress, marketingTokens); }
        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private 
    {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }


    function excludeFromTxLimit(address account, bool _value) external onlyOwner
    {
        _isExemptFromTxLimit[account] = _value;
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) 
    {
        (uint256 tTransferAmount, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, tTransferAmount, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tLiquidity);
        return (tTransferAmount, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rLiquidity);
        return (rAmount, rTransferAmount);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) 
    {
        _amount = _amount.mul(100).div(100-_marketingFee);
        return _amount.mul(_liquidityFee).div(100);
    }
    
    function removeAllFee() private 
    {       
        _liquidityFee = 0;
        _marketingFee = 0;
    }
    
    function restoreAllFee() private 
    {
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
    }

    function setSaleFee() private 
    {
        _liquidityFee = _saleLiquidityFee;
        _marketingFee = _saleMarketingFee;
    }
    

    event updateBuyFee(uint256 totalFee, uint256 timestamp);
    function setAllBuyFeePercentages(uint256 liquidityFee, uint256 marketingFee) 
    external onlyOwner()
    {
        _liquidityFee = liquidityFee;
        _previousLiquidityFee = liquidityFee;

        _marketingFee = marketingFee;
        _previousMarketingFee = marketingFee;

        uint256 totalFee = _liquidityFee.add(_marketingFee);
        require(totalFee<=10, "Too High Fee");
        emit updateBuyFee(totalFee, block.timestamp);
    }


    event updateSellFee(uint256 totalFee, uint256 timestamp);
    function setAllSaleFeePercentages(uint256 liquidityFee, uint256 marketingFee) 
    external onlyOwner()
    {
        _saleLiquidityFee = liquidityFee;
        _saleMarketingFee = marketingFee;
        uint256 totalFee = liquidityFee.add(marketingFee);
        require(totalFee<=12, "Too High Fee");
        emit updateSellFee(totalFee, block.timestamp);
    }


    function setMaxTxAmount(uint256 _mount) external onlyOwner() 
    {
        require(_mount>_tTotal.div(1000), "Too low Txn limit"); // Min 0.1%
        _maxTxAmount = _mount;
    }
    

    function setNumTokensSellToAddToLiquidity(uint256 __minimumTokensBeforeSwap) external onlyOwner() 
    {
        _minimumTokensBeforeSwap = __minimumTokensBeforeSwap;
    }
    

    function setMarketingAddress(address _marketingAddress) external onlyOwner() 
    {
        marketingAddress = _marketingAddress;
    }


    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner 
    {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    
    function transferToAddressETH(address payable recipient, uint256 amount) private 
    {
        recipient.transfer(amount);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


   // ---------- STAKES ----------



    address[] internal stakeholders;
    uint256 public rewardDistributionIndex = 0;
    bool stakingOpen = true;
    uint256 public _totalStakes = 0;
    uint256 private uintTime = 1;

    mapping(address => uint256) internal stakes; // staked amount
    mapping(address => uint256) internal stakingTimestamp; //when tokens were staked. 
    mapping(address => uint256) internal stakingPackage; //staking for how much time. 
    mapping(uint256 => uint256) internal packages;

    function createPackages() private
    {
        packages[90*uintTime] = 10;       //  10% reward after 90 days. 
        packages[180*uintTime] = 25;      //  25% after 180 days
        packages[360*uintTime] = 50;     //  50% reward after 360 days        
    }    

    function _mint(address account, uint256 amount) private 
    {
        uint256 rate =  _getRate();
        uint256 rAmount =  amount.mul(rate);
        _rOwned[account] += rAmount; 
        _tTotal += amount;
        _rTotal += rAmount;
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) private 
    {
        uint256 rate =  _getRate();
        uint256 rAmount =  amount.mul(rate);
        _rOwned[account] -= rAmount; 
        _tTotal -= amount;
        _rTotal -= rAmount;
        emit Transfer(address(0), account, amount);
    }


    function canStake(uint256 _stake, uint256 _stakingPackage, address account) 
    public view returns (bool b)
    {
        if(packages[_stakingPackage]>0 
        && _stake<=balanceOf(account) 
        && stakingOpen 
        && stakes[account] == 0 
        && _stake>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }


    uint256 stakingFee = 4; //4% fee on staking. 
    uint256 unstakingFee = 8; //8% fee on staking.

    function createStake(uint256 _stake, uint256 _stakingPackage) external
    {
        bool _canStake = canStake(_stake, _stakingPackage, msg.sender);
        require(_canStake, "Cannot Stake");
        _burn(msg.sender, _stake);
        _stakingPackage = _stakingPackage * uintTime;
        uint256 stakingFeeTokens = _stake.mul(stakingFee).div(100);
        _stake = _stake.sub(stakingFeeTokens);
        addStakeholder(msg.sender, _stake, _stakingPackage);
        _totalStakes = _totalStakes.add(_stake);
    }


    function removeStake(uint256 _stake) public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) 
        { 
            removeStakeholder(msg.sender); 
        }
        uint256 unstakingFeeTokens = _stake.mul(unstakingFee).div(100);
        _mint(msg.sender, _stake.sub(unstakingFeeTokens));
        _totalStakes = _totalStakes.sub(_stake);
    }


    function stakeOf(address _stakeholder) public view returns(uint256) 
    {
        return stakes[_stakeholder];
    }


    function totalStakes()   public view returns(uint256)
    {
        return _totalStakes;
    }


    function isStakeholder(address _address) public view returns(bool, uint256)
    {
        for(uint256 s = 0; s < stakeholders.length; s += 1)
        {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }


    function addStakeholder(address _stakeholder, uint256 _stake, uint256 _package) private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
        stakingTimestamp[_stakeholder] = block.timestamp;
        stakingPackage[_stakeholder] = _package;
        stakes[_stakeholder] = _stake;
    }


    function removeStakeholder(address _stakeholder) private
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder)
        {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
            stakingTimestamp[_stakeholder] = 0;
            stakingPackage[_stakeholder] = 0;
        } 
    }


    function rewardOf(address _stakeholder) public view returns(uint256)
    {
        (uint256 reward,) = calculateReward(_stakeholder);
        return reward;
    }

    function calculateReward(address _stakeholder) private view returns(uint256, uint256)
    {
        uint256 stakedAmount = stakes[_stakeholder];
        if(stakedAmount==0) { return (0, 0); }
        uint256 _stakingTimestamp =  stakingTimestamp[_stakeholder];
        if(_stakingTimestamp==0) {return (0, 0); }
        uint256 _currentTimestamp =  block.timestamp;
        uint256 _span = _currentTimestamp.sub(_stakingTimestamp);
        uint256 _stakingPackage = stakingPackage[_stakeholder];
        if(_span<_stakingPackage) { return (0, 0); }
        uint256  _loops = _span/_stakingPackage;
        uint256 rewardPercentage =  packages[_stakingPackage];
        uint256 _reward = stakedAmount.mul(rewardPercentage).mul(_loops).div(100);
        return (_reward, _loops);
    }

  
    // if a holder did not received reward automatically, 
    //holder can call this function to claim reward. 
    event RewardSent(address _address, uint256 _amount, uint256 _timestamp);
    function _withdrawReward(address _stakeholder)  internal 
    {
        (uint256 rewardTokens, uint256 loops) = calculateReward(_stakeholder);
        if(rewardTokens==0) {return;}
        uint256 myPackage = stakingPackage[msg.sender];

        stakingTimestamp[msg.sender] = (stakingTimestamp[msg.sender]).add(myPackage*loops);
        _mint(address(0), rewardTokens);
        swapTokensForBUSD(rewardTokens, msg.sender);
        emit RewardSent(_stakeholder, rewardTokens, block.timestamp);
    }



    function withdrawReward() external 
    {
        _withdrawReward(msg.sender);
    }

    // will send reward to only on holder at a time. 
    event CheckedForReward(address _address, uint256 timestamp);
    function distributeReward() public 
    {
        if(stakeholders.length==0) {return;}
        if(rewardDistributionIndex==stakeholders.length-1) 
        { 
            rewardDistributionIndex = 0; 
        }

        for(uint256 i=rewardDistributionIndex; i<stakeholders.length; i++)
        {
            address account = stakeholders[i];
            //emit CheckedForReward(account, block.timestamp);
            (uint256 reward,) = calculateReward(account);
            rewardDistributionIndex = i;
            if(reward==0) 
            { 
                continue; 
            }
            else 
            {
                _withdrawReward(account);
                break;
            }
        }
    }

    address public BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    function swapTokensForBUSD(uint256 tokenAmount, address account) private 
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            account,
            block.timestamp
        );
    }


    function swapAndSendToFee(uint256 tokens, address account) private  
    {
        swapTokensForBUSD(tokens, account);
    }


}
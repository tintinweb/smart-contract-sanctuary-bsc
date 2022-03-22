/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


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
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b != 0, errorMessage);
        return a % b;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
    using SafeMath for uint256;

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

contract LuckyApeCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    address payable public _marketingAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isTaxable;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isAllowed;
    address[] private _excluded;

    string private _name = "LuckyApeCoin";
    string private _symbol = "LAPE";
    uint8 private _decimals = 9;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _maxTxAmount;
    uint256 public _maxWalletAmount;
    uint256 public _contractTokensToSell;
    bool public _sellContractTokensEnabled = false;

    bool public _prepareFairlaunch = false;
    bool public _startFairlaunch = false;

    struct TransactionFees {
        uint256 buyReflectionFee;
        uint256 buyBuybackFee;
        uint256 buyMarketingFee;
        uint256 buyLottoFee;
        uint256 totalBuyBuybackMarketingFee;
        uint256 sellReflectionFee;
        uint256 sellBuybackFee;
        uint256 sellMarketingFee;
        uint256 sellLottoFee;
        uint256 totalSellBuybackMarketingFee;
    }

    TransactionFees public _transactionFees;

    uint256 private _lottoFee;
    uint256 private _reflectionFee;
    uint256 private _buybackFee;
    uint256 private _marketingFee;
    uint256 private _totalBuybackMarketingFee;

    bool public _buybackEnabled;
    uint256 public _buybackAmountLimit;
    uint256 public _buybackDivisor;  

    uint256 public _minTokensRequiredForLotto;
    address public _lottoRecipient;
    address[] public _addressLists;
    mapping (address => bool) public _addressListExists;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;

    event RewardLiquidityProviders(uint256 tokenAmount);
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
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        
        _marketingAddress = payable(0x1987Cfc9a8f7fCB8F25a0d8A0A17aCfC9749809f);

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        addAddress(_msgSender());
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
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
        return rAmount.div(currentRate);
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
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_prepareFairlaunch, "Holdit: prepareFairlaunch function must be called");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool excludedAccount = _isExcludedFromFee[to] || _isExcludedFromFee[from];

        if(!excludedAccount) {
            if(!_startFairlaunch){
                require(_isAllowed[from] || _isAllowed[to]);
            }
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance > _contractTokensToSell;
        
        if(uniswapV2Pair == from || uniswapV2Pair == to){
            if(uniswapV2Pair == from){
                if(!excludedAccount) {
                    uint256 totalBalanceAfterSwap = amount.add(balanceOf(to)); 
                    require(totalBalanceAfterSwap <= _maxWalletAmount, "Balance after swap exceeds max wallet amount.");
                    require(amount <= _maxTxAmount, "Amount to swap exceeds the maxTxAmount");
                }
                _reflectionFee = _transactionFees.buyReflectionFee;
                _buybackFee = _transactionFees.buyBuybackFee;
                _marketingFee = _transactionFees.buyMarketingFee;
                _lottoFee = _transactionFees.buyLottoFee;
                _totalBuybackMarketingFee = _transactionFees.totalBuyBuybackMarketingFee;
            }
            else if (uniswapV2Pair == to){
                if(!excludedAccount) {
                    require(amount <= _maxTxAmount, "Amount to swap exceeds the maxTxAmount");
                }
                _reflectionFee = _transactionFees.sellReflectionFee;
                _buybackFee = _transactionFees.sellBuybackFee;
                _marketingFee = _transactionFees.sellMarketingFee;
                _lottoFee = _transactionFees.sellLottoFee;
                _totalBuybackMarketingFee = _transactionFees.totalSellBuybackMarketingFee;
                if (!inSwapAndLiquify){
                    if(_sellContractTokensEnabled){
                        if (overMinimumTokenBalance) {
                            contractTokenBalance = _contractTokensToSell;
                            swapTokens(contractTokenBalance);    
                        }            
                    }

                    if(_buybackEnabled){
                        uint256 buybackBalance = address(this).balance;
	        
                        if (buybackBalance > _buybackAmountLimit.div(_buybackDivisor)) {
                            uint256 buybackAmount = _buybackAmountLimit.div(_buybackDivisor);
                            autoBuybackAndBurnTokens(buybackAmount);
                        }     
                    }
                }
            }
        }

        bool takeFee = false;

        if(uniswapV2Pair == from || uniswapV2Pair == to){
            takeFee = true;
        }
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        addAddress(from);
        addAddress(to);

       _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap(){
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        
        transferToAddressETH(_marketingAddress, transferredBalance.div(_transactionFees.totalSellBuybackMarketingFee).mul(_transactionFees.sellMarketingFee));

    }

    function swapTokensForEth(uint256 tokenAmount) private{
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
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private{
       address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            deadAddress,
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
    
    function autoBuybackAndBurnTokens(uint256 amount) private lockTheSwap(){
    	if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }
    
    function manualBuybackAndBurnTokens(uint256 amount) public onlyOwner(){
        require(amount > 0, "LuckyApeCoin: amount is less than zero");
        
        if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }

    function showRandom() public view returns (uint256) {
        uint256 randomNumber = (block.number).mod(_addressLists.length);
        return randomNumber;
    }

    function noOfAddress() public view returns (uint256) {
        return _addressLists.length;
    }

    function lotterize() private view returns(address) {
        if(_addressLists.length >= 1){
            uint256 randomNumber = (block.number).mod(_addressLists.length);

		    uint256 tokenBalance = balanceOf(_addressLists[randomNumber]);

		    if (tokenBalance >= _minTokensRequiredForLotto) {
			    return _addressLists[randomNumber];
		    }

		    return address(this);
        }
	}

    function addAddress(address walletAddress) private {
        if(_addressListExists[walletAddress])
            return;
        if(uniswapV2Pair == walletAddress)
            return;
        _addressListExists[walletAddress] = true;
        _addressLists.push(walletAddress);
    }

    function unstuckBalance(address payable recipient) public onlyOwner{
        uint256 contractBNBBalance = address(this).balance;
        transferToAddressETH(recipient,contractBNBBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee){
            _reflectionFee = 0;
            _buybackFee = 0;
            _marketingFee = 0;
            _lottoFee = 0;
            _totalBuybackMarketingFee = _buybackFee.add(_marketingFee);
        }
        
        _transferStandard(sender, recipient, amount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTotalBuybackMarketingFee(tTotalBuybackMarketingFee);
        _takeLotto(tLottoFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee) = _getValues(tAmount);
	    _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeTotalBuybackMarketingFee(tTotalBuybackMarketingFee);
        _takeLotto(tLottoFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeTotalBuybackMarketingFee(tTotalBuybackMarketingFee);
        _takeLotto(tLottoFee);    
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeTotalBuybackMarketingFee(tTotalBuybackMarketingFee);
        _takeLotto(tLottoFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTotalBuybackMarketingFee, tLottoFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTotalBuybackMarketingFee, tLottoFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tTotalBuybackMarketingFee = calculateTotalBuybackMarketingFee(tAmount);
        uint256 tLottoFee = calculateLottoFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTotalBuybackMarketingFee).sub(tLottoFee);
        return (tTransferAmount, tFee, tTotalBuybackMarketingFee, tLottoFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTotalBuybackMarketingFee, uint256 tLottoFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTotalBuybackMarketingFee = tTotalBuybackMarketingFee.mul(currentRate);
        uint256 rLottoFee = tLottoFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTotalBuybackMarketingFee).sub(rLottoFee);
        return (rAmount, rTransferAmount, rFee);
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
    
    function _takeLotto(uint256 tLotto) private{
        uint256 currentRate =  _getRate();
        uint256 rLotto = tLotto.mul(currentRate);

        _lottoRecipient = lotterize();

        _rOwned[_lottoRecipient] = _rOwned[_lottoRecipient].add(rLotto);
        if(_isExcluded[_lottoRecipient])
            _tOwned[_lottoRecipient] = _tOwned[_lottoRecipient].add(tLotto);
    }

    function _takeTotalBuybackMarketingFee(uint256 tTotalBuybackMarketingFee) private {
        uint256 currentRate =  _getRate();
        uint256 rTotalBuybackMarketingFee = tTotalBuybackMarketingFee.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTotalBuybackMarketingFee);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tTotalBuybackMarketingFee);
    }

    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(
            10**2
        );
    }
    
    function calculateTotalBuybackMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_totalBuybackMarketingFee).div(
            10**2
        );
    }
    
    function calculateLottoFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lottoFee).div(
            10**2
        );
    }

    function isTaxable(address account) public view returns(bool) {
        return _isTaxable[account];
    }
    
    function excludeFromTaxable(address account) public onlyOwner() {
        _isTaxable[account] = false;
    }

    function includeInTaxable(address account) public onlyOwner() {
        _isTaxable[account] = true;
    }
    
    function includeInAllowed(address account) public onlyOwner() {
        _isAllowed[account] = true;
    }

    function excludeFromAllowed(address account) public onlyOwner() {
        _isAllowed[account] = false;
    }

    function isAllowed(address account) public view returns(bool) {
        return _isAllowed[account];
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "LuckyApeCoin: account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {
        require(_isExcluded[account], "LuckyApeCoin: account is already excluded");
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
    
    function updateFees(uint256 buyReflectionFee, uint256 buyBuybackFee, uint256 buyMarketingFee, uint256 buyLottoFee, uint256 sellReflectionFee, uint256 sellBuybackFee, uint256 sellMarketingFee , uint256 sellLottoFee) public onlyOwner() {
        _transactionFees.buyReflectionFee = buyReflectionFee;
        _transactionFees.buyBuybackFee = buyBuybackFee;
        _transactionFees.buyMarketingFee = buyMarketingFee;
        _transactionFees.buyLottoFee = buyLottoFee;
        _transactionFees.totalBuyBuybackMarketingFee = _transactionFees.buyBuybackFee.add(_transactionFees.buyMarketingFee);
        _transactionFees.sellReflectionFee = sellReflectionFee;
        _transactionFees.sellBuybackFee = sellBuybackFee;
        _transactionFees.sellMarketingFee = sellMarketingFee;
        _transactionFees.sellLottoFee = sellLottoFee;
        _transactionFees.totalSellBuybackMarketingFee = _transactionFees.sellBuybackFee.add(_transactionFees.sellMarketingFee);
    }

    

    function updateBuybackEnabled(bool _enabled) public onlyOwner() {
        _buybackEnabled = _enabled;
    }

    function updateBuybackAmountLimit(uint256 buybackAmountLimit) public onlyOwner() {
        _buybackAmountLimit = buybackAmountLimit * 10**18;
    }
     
    function updateBuybackDivisor(uint256 buybackDivisor) public onlyOwner() {
        _buybackDivisor = buybackDivisor;
    }
    
    function updateSellContractTokensEnabled(bool _enabled) public onlyOwner() {
        _sellContractTokensEnabled = _enabled;
    }

    function updateMaxTxAmount(uint256 maxTxAmount) public onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }

    function updateContractTokensToSell(uint256 contractTokensToSell) public onlyOwner() {
        _contractTokensToSell = contractTokensToSell;
    }

    function setMarketingAddress(address payable marketingAddress) public onlyOwner() {
        _marketingAddress = marketingAddress;
    }
	
	function setMinTokensRequiredForLotto(uint256 minTokensRequiredForLotto) public onlyOwner() {
        _minTokensRequiredForLotto = minTokensRequiredForLotto;
    }

    function prepareFairlaunch() public onlyOwner() {
        require(!_prepareFairlaunch, "LuckyApeCoin: function can only be called once");
        includeInTaxable(uniswapV2Pair);
        updateSellContractTokensEnabled(true);
        updateBuybackEnabled(false);
        _maxWalletAmount = 20000000 * 10**9;
        _maxTxAmount = 10000000 * 10**9;
        _contractTokensToSell = 1000000 * 10**9;
        _minTokensRequiredForLotto = 1000000 * 10**9;
        _buybackAmountLimit = 1 * 10**18;
        _buybackDivisor = 1000;
        _transactionFees.buyReflectionFee = 0;
        _transactionFees.buyBuybackFee = 2;
        _transactionFees.buyMarketingFee = 5;
        _transactionFees.buyLottoFee = 5;
        _transactionFees.totalBuyBuybackMarketingFee = _transactionFees.buyBuybackFee.add(_transactionFees.buyMarketingFee);
        _transactionFees.sellReflectionFee = 0;
        _transactionFees.sellBuybackFee = 2;
        _transactionFees.sellMarketingFee = 5;
        _transactionFees.buyLottoFee = 5;
        _transactionFees.totalSellBuybackMarketingFee = _transactionFees.sellBuybackFee.add(_transactionFees.sellMarketingFee);
        _prepareFairlaunch = true;
    }
    
    function startFairlaunch() public onlyOwner() {
        require(_prepareFairlaunch, "LuckyApeCoin: prepareFairlaunch function must be called");
        require(!_startFairlaunch, "LuckyApeCoin: function can only be called once");
        _startFairlaunch = true;
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }  
    
    receive() external payable {}
}
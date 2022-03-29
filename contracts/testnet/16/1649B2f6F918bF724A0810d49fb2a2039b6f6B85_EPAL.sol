/**
 *Submitted for verification at BscScan.com on 2022-03-29
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

contract EPAL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    address payable public _marketingAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _isTaxable;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isAllowed;
    address[] private _excluded;

    string private _name = "LAPE";
    string private _symbol = "LAPE";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1000000000 * 10**9;

    uint256 public _contractLBMTokenBalance = 0; // L-iquidity B-uyback M-arketing Logical Wallet
    uint256 public _contractPotLottoTokenBalance = 0; // Pot Lotto Logical Wallet

    uint256 public _contractLBMTokensToSell;
    uint256 public _maxTxAmount;
    uint256 public _maxWalletAmount;
    
    bool public _sellContractTokensEnabled;
    bool public _beforePresale;
    bool public _afterPresale;

    struct TransactionFees {
        uint256 buyLiquidityFee;
        uint256 buyBuybackFee;
        uint256 buyMarketingFee;
        uint256 buyTransactionLottoFee;
        uint256 buyPotLottoFee;
        uint256 sellLiquidityFee;
        uint256 sellBuybackFee;
        uint256 sellMarketingFee;
        uint256 sellTransactionLottoFee;
        uint256 sellPotLottoFee;
    }

    TransactionFees public _transactionFees;

    uint256 private _liquidityFee;
    uint256 private _buybackFee;
    uint256 private _marketingFee;
    uint256 private _transactionLottoFee;
    uint256 private _potLottoFee;

    bool public _buybackEnabled;
    uint256 public _buybackAmountLimit;
    uint256 public _buybackDivisor;  

    // Lotto Protocol Variables

    struct LottoDetail {
        uint256 date;
        address recipient;
        uint256 amount;
    }

    struct Lotto{
        uint256 startDate;
        uint256 endDate;
        uint256 noOfParticipantsEligible;
        uint256 totalTransactionLottoTokensSent;
        uint256 totalPotLottoTokensSent;
        address[] participants;
        LottoDetail[] transactionLottoHistory;
        LottoDetail[] potLottoHistory;
        mapping (address => uint256) totalLottoTokensReceived;
        mapping (address => bool) participantEligible;
    }

    Lotto[] public _lotto;
    
    uint256 public _lottoSession = 0;
    uint256 public _potLottoAmountLimit;
    uint256 public _minTokensRequiredForLotto;
    address public _recentTransactionLottoRecipient;
    address public _recentPotLottoRecipient;

    // --------------------------------

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
        _balances[_msgSender()] = _totalSupply;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        
        _marketingAddress = payable(0x1987Cfc9a8f7fCB8F25a0d8A0A17aCfC9749809f);

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        require(_beforePresale, "EPAL: beforePresale function must be called");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool excludedAccount = _isExcludedFromFee[to] || _isExcludedFromFee[from];

        if(!excludedAccount) {
           require(_afterPresale, "EPAL: non-excluded can only transfer after presale");
        }
        
        if(_isTaxable[from] || _isTaxable[to]){
            if(_isTaxable[from]){
                if(!excludedAccount) {
                    require(amount <= _maxTxAmount, "Amount to swap exceeds the maxTxAmount");
                }
                _liquidityFee = _transactionFees.buyLiquidityFee;
                _buybackFee = _transactionFees.buyBuybackFee;
                _marketingFee = _transactionFees.buyMarketingFee;
                _transactionLottoFee = _transactionFees.buyTransactionLottoFee;
                _potLottoFee = _transactionFees.buyPotLottoFee;
            }
            else if (_isTaxable[to]){
                if(!excludedAccount) {
                    require(amount <= _maxTxAmount, "Amount to swap exceeds the maxTxAmount");
                }
                _liquidityFee = _transactionFees.sellLiquidityFee;
                _buybackFee = _transactionFees.sellBuybackFee;
                _marketingFee = _transactionFees.sellMarketingFee;
                _transactionLottoFee = _transactionFees.sellTransactionLottoFee;
                _potLottoFee = _transactionFees.sellPotLottoFee;
                if (!inSwapAndLiquify){
                    if(_sellContractTokensEnabled){
                        if(_contractLBMTokenBalance >= _contractLBMTokensToSell) {
                            swapTokens(_contractLBMTokensToSell);    
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

        if(_isTaxable[from] || _isTaxable[to]){
            takeFee = true;
        }
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokens(uint256 contractTokensAmount) private lockTheSwap(){
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokensAmount);
        _contractLBMTokenBalance = _contractLBMTokenBalance.sub(contractTokensAmount); 
        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        
        uint256 totalContractFee = _transactionFees.sellLiquidityFee.add(_transactionFees.sellBuybackFee).add(_transactionFees.sellMarketingFee);
        transferToAddressETH(_marketingAddress, transferredBalance.div(totalContractFee).mul(_transactionFees.sellMarketingFee));

/*
        if(_transactionFees.sellLiquidityFee > 0){

        }
        */
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
        require(amount > 0, "EPAL: amount is less than zero");
        
        if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }

    function unstuckBalance() public onlyOwner{
        uint256 contractBNBBalance = address(this).balance;
        transferToAddressETH(_marketingAddress,contractBNBBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee){
            _liquidityFee = 0;
            _buybackFee = 0;
            _marketingFee = 0;
            _transactionLottoFee = 0;
            _potLottoFee = 0;
        }
        
        uint256 totalContractFee = _liquidityFee.add(_buybackFee).add(_marketingFee);
        uint256 totalContractFeeAmount = percentageCalculator(amount, totalContractFee);
        uint256 transactionLottoFeeAmount = percentageCalculator(amount, _transactionLottoFee);
        uint256 potLottoFeeAmount = percentageCalculator(amount, _potLottoFee);
        amount = amount.sub(totalContractFeeAmount).sub(transactionLottoFeeAmount).sub(potLottoFeeAmount);
        _takeContractFee(totalContractFeeAmount);
        _takeTransactionLottoFee(transactionLottoFeeAmount);
        _takePotLottoFee(potLottoFeeAmount);
      
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        if(_isTaxable[sender] || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            if(_balances[recipient] >= _minTokensRequiredForLotto){
                addLottoParticipant(recipient);       
            } 
        }
        if(_balances[sender] < _minTokensRequiredForLotto){
                setLottoParticipantIneligible(sender);      
        }
        
        emit Transfer(sender, recipient, amount);
    }

    function _takeContractFee(uint256 amount) private {
        if(amount == 0)
            return;
        _contractLBMTokenBalance = _contractLBMTokenBalance.add(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
    }

    // Lotto Protocol Functions

    function _takeTransactionLottoFee(uint256 amount) private{
        if(amount == 0)
            return;
        _recentTransactionLottoRecipient = transactionLotterize();
        if(_recentTransactionLottoRecipient == address(this)){
            _contractPotLottoTokenBalance = _contractPotLottoTokenBalance.add(amount);
            _balances[address(this)] = _balances[address(this)].add(amount);    
        }
        else{
            _balances[_recentTransactionLottoRecipient] = _balances[_recentTransactionLottoRecipient].add(amount);
            _lotto[_lottoSession].transactionLottoHistory.push(LottoDetail(block.timestamp,_recentTransactionLottoRecipient,amount));
            _lotto[_lottoSession].totalTransactionLottoTokensSent = _lotto[_lottoSession].totalTransactionLottoTokensSent.add(amount);
            _lotto[_lottoSession].totalLottoTokensReceived[_recentTransactionLottoRecipient] = _lotto[_lottoSession].totalLottoTokensReceived[_recentTransactionLottoRecipient].add(amount);
        }
    }

    function _takePotLottoFee(uint256 amount) private{
        if(amount == 0)
            return;
        _contractPotLottoTokenBalance = _contractPotLottoTokenBalance.add(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        if(_contractPotLottoTokenBalance >= _potLottoAmountLimit){
            _recentPotLottoRecipient = potLotterize();
             if(_recentPotLottoRecipient == address(this)){
                _contractPotLottoTokenBalance = _contractPotLottoTokenBalance.add(_potLottoAmountLimit);
                _balances[address(this)] = _balances[address(this)].add(_potLottoAmountLimit);    
            }
            else{
                _balances[_recentPotLottoRecipient] = _balances[_recentPotLottoRecipient].add(_potLottoAmountLimit);
                _contractPotLottoTokenBalance = _contractPotLottoTokenBalance.sub(_potLottoAmountLimit);
                _balances[address(this)] = _balances[address(this)].sub(_potLottoAmountLimit);
                _lotto[_lottoSession].potLottoHistory.push(LottoDetail(block.timestamp,_recentPotLottoRecipient,_potLottoAmountLimit));
                _lotto[_lottoSession].totalPotLottoTokensSent = _lotto[_lottoSession].totalPotLottoTokensSent.add(_potLottoAmountLimit);
                _lotto[_lottoSession].totalLottoTokensReceived[_recentPotLottoRecipient] = _lotto[_lottoSession].totalLottoTokensReceived[_recentPotLottoRecipient].add(_potLottoAmountLimit); 
            
            }
        }
    }

    

    function transactionLotterize() private view returns(address _address) {
        if(_lotto[_lottoSession].participants.length >= 1){
            uint256 randomNumber = (block.number).mod(_lotto[_lottoSession].participants.length);
            uint256 tokenBalance = balanceOf(_lotto[_lottoSession].participants[randomNumber]);
            
            if (tokenBalance >= _minTokensRequiredForLotto) {
                _address = _lotto[_lottoSession].participants[randomNumber];
			    return _lotto[_lottoSession].participants[randomNumber];
		    }

            return address(this);
        }
        else
            return address(this);
	}

    function potLotterize() private view returns(address _address) {
        if(_lotto[_lottoSession].participants.length >= 1){
            uint256 randomNumber = (block.number).mod(_lotto[_lottoSession].participants.length);
            uint256 tokenBalance = balanceOf(_lotto[_lottoSession].participants[randomNumber]);
            if (tokenBalance >= _minTokensRequiredForLotto) {
                _address = _lotto[_lottoSession].participants[randomNumber];
			    return _address;
		    }
            return address(this);
        }
        else
            return address(this);
	}

    function lottoStartDate(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].startDate;
    }

    function lottoEndDate(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].endDate;
    }

    function lottoNoOfParticipantsEligible(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].noOfParticipantsEligible;
    }

    function lottoTotalTransactionLottoTokensSent(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].totalTransactionLottoTokensSent;
    }

    function lottoTotalPotLottoTokensSent(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].totalPotLottoTokensSent;
    }

    function lottoTotalLottoTokensReceived(uint256 lottoSession, address _address) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].totalLottoTokensReceived[_address];
    }

    function lottoParticipants(uint256 lottoSession, uint256 offset, uint256 limit, uint256 asc) public view returns (address[] memory) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        require(limit > 0 && limit <= 100 && offset >= 0);
        uint256 index;
        address[] memory results = new address[](limit);
        if(asc == 1){
            for(uint256 x = 0; x < limit; x++){
                index = offset.add(x);
                results[x] = _lotto[lottoSession].participants[index];
                if(index == _lotto[lottoSession].participants.length - 1)
                    break;
           }
        }
        else{
            for(uint256 x = 0; x < limit; x++){
                index = _lotto[lottoSession].participants.length - offset - x - 1;
                results[x] = _lotto[lottoSession].participants[index];
                if(index == 0)
                    break;
            }     
        }
    
        return results;
    }

    function lottoTransactionLottoHistory(uint256 lottoSession, uint256 offset, uint256 limit , uint256 asc) public view returns (LottoDetail[] memory) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        require(limit > 0 && limit <= 100 && offset >= 0);
        LottoDetail[] memory results = new LottoDetail[](limit);
        uint256 index;
        if(asc == 1){
            for(uint256 x = 0; x < limit; x++){
                index = offset.add(x);
                results[x].date = _lotto[lottoSession].transactionLottoHistory[index].date;
                results[x].recipient = _lotto[lottoSession].transactionLottoHistory[index].recipient;
                results[x].amount = _lotto[lottoSession].transactionLottoHistory[index].amount;
                if(index == _lotto[lottoSession].transactionLottoHistory.length - 1)
                    break;
            }
        }
        else{
            for(uint256 x = 0; x < limit; x++){
                index = _lotto[lottoSession].transactionLottoHistory.length - offset - x - 1;
                results[x].date = _lotto[lottoSession].transactionLottoHistory[index].date;
                results[x].recipient = _lotto[lottoSession].transactionLottoHistory[index].recipient;
                results[x].amount = _lotto[lottoSession].transactionLottoHistory[index].amount;
                if(index == 0)
                    break;
            }
        }

        return results;
    }

    function lottoPotLottoHistory(uint256 lottoSession, uint256 offset, uint256 limit, uint256 asc) public view returns (LottoDetail[] memory) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        require(limit > 0 && limit <= 100 && offset >= 0);
        LottoDetail[] memory results = new LottoDetail[](limit);
        uint256 index;
        if(asc == 1){
            for(uint256 x = 0; x < limit; x++){
                index = offset.add(x);
                results[x].date = _lotto[lottoSession].potLottoHistory[index].date;
                results[x].recipient = _lotto[lottoSession].potLottoHistory[index].recipient;
                results[x].amount = _lotto[lottoSession].potLottoHistory[index].amount;
                if(index == _lotto[lottoSession].potLottoHistory.length - 1)
                    break;
            }
        }
        else{
            for(uint256 x = 0; x < limit; x++){
                index = _lotto[lottoSession].potLottoHistory.length - offset - x - 1;
                results[x].date = _lotto[lottoSession].potLottoHistory[index].date;
                results[x].recipient = _lotto[lottoSession].potLottoHistory[index].recipient;
                results[x].amount = _lotto[lottoSession].potLottoHistory[index].amount;
                if(index == 0)
                    break;
            }
        }

        return results;
    }

    function lottoParticipantEligible(uint256 lottoSession, address _address) public view returns (bool) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].participantEligible[_address];
    }

    function lottoNoOfParticipantsOfLotto(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].participants.length;
    }

    function lottoNoOfTransactionLottoHistoryRecords(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].transactionLottoHistory.length;
    }

    function lottoNoOfPotLottoHistoryRecords(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        return _lotto[lottoSession].potLottoHistory.length;
    }

    function lottoRecentTransactionLottoRecipient() public view returns (address) {
        return _recentTransactionLottoRecipient;
    }

    function lottoRecentPotLottoRecipient() public view returns (address) {
        return _recentPotLottoRecipient;
    }

    function lottoTotalAllLottoTokensReceived(address _address) public view returns (uint256 totalAllLottoTokensReceived) {
        for(uint256 x = 0; x <= _lottoSession; x++){
            totalAllLottoTokensReceived = totalAllLottoTokensReceived + _lotto[x].totalLottoTokensReceived[_address];    
        }
        return totalAllLottoTokensReceived;
    }

    function lottoTotalAllTransactionLottoTokensSent() public view returns (uint256 totalAllTransactionLottoTokensSent) {
        for(uint256 x = 0; x <= _lottoSession; x++){
            totalAllTransactionLottoTokensSent = totalAllTransactionLottoTokensSent + _lotto[x].totalTransactionLottoTokensSent;    
        }
        return totalAllTransactionLottoTokensSent;
    }

    function lottoTotalAllPotLottoTokensSent() public view returns (uint256 totalAllPotLottoTokensSent) {
        for(uint256 x = 0; x <= _lottoSession; x++){
            totalAllPotLottoTokensSent = totalAllPotLottoTokensSent + _lotto[x].totalPotLottoTokensSent;    
        }
        return totalAllPotLottoTokensSent;
    }

    function lottoTotalAllLottoTokensSent() public view returns (uint256 totalAllLottoTokensSent) {
        for(uint256 x = 0; x <= _lottoSession; x++){
            totalAllLottoTokensSent = totalAllLottoTokensSent + _lotto[x].totalTransactionLottoTokensSent + _lotto[x].totalPotLottoTokensSent;    
        }
        return totalAllLottoTokensSent;
    }

    function lottoCurrentPotLottoTokens() public view returns (uint256 currentPotLottoTokens) {
        return _contractPotLottoTokenBalance;
    }

    function lottoSimulatorDrawLottoWinnerIndex(uint256 lottoSession) public view returns (uint256) {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        uint256 randomNumber = (block.number).mod(_lotto[lottoSession].participants.length);
        return randomNumber;
    }

    function lottoSimulatorRunLotterize(uint256 lottoSession, uint256 length) public {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        for(uint256 x = 1; x <= length; x++){
            _takeTransactionLottoFee(1000000 * 10**9);
            _takePotLottoFee(0);
        }
    }

    function lottoSimulatorAddAddressesToParticipants(uint256 lottoSession, uint256 length, uint256 y) public {
        require(lottoSession >= 0 && lottoSession <= _lottoSession);
        address _address;
        for(uint256 x = y * length; x < (y+1) * length; x++){
            _address = address(uint160(uint(keccak256(abi.encodePacked(x+1, blockhash(block.number))))));
            _balances[_address] = 1000000 * 10**9;
            addLottoParticipant(_address);
            
        }
    }

    function addLottoParticipant(address walletAddress) private {
        if(_balances[walletAddress] < _minTokensRequiredForLotto)
            return;
        if(_lotto[_lottoSession].participants.length == 0)
           _lotto[_lottoSession].startDate = block.timestamp;
        if(_lotto[_lottoSession].participantEligible[walletAddress])
            return;
        if(walletAddress == uniswapV2Pair || walletAddress == deadAddress || walletAddress == address(0))
            return;
        if(_isTaxable[walletAddress])
            return;    
        _lotto[_lottoSession].participantEligible[walletAddress] = true;
        _lotto[_lottoSession].participants.push(walletAddress);
        _lotto[_lottoSession].noOfParticipantsEligible++;
    }

    function setLottoParticipantIneligible(address walletAddress) private {
        if(_balances[walletAddress] >= _minTokensRequiredForLotto)
            return;
        if(!_lotto[_lottoSession].participantEligible[walletAddress])
            return;
        if(walletAddress == uniswapV2Pair)
            return;
        if(walletAddress == deadAddress)
            return;
        if(_isTaxable[walletAddress])
            return;    
        _lotto[_lottoSession].participantEligible[walletAddress] = false;
        _lotto[_lottoSession].noOfParticipantsEligible--;
    }

    function createNewLottoSession() public onlyOwner() {
        _lotto[_lottoSession].endDate = block.timestamp;
        _lottoSession++;
        _lotto.push();
        _lotto[_lottoSession].startDate = block.timestamp;
    }

    function updateMinTokensRequiredForLotto(uint256 minTokensRequiredForLotto) public onlyOwner() {
        _minTokensRequiredForLotto = minTokensRequiredForLotto;
    }

    function updatePotLottoAmountLimit(uint256 potLottoAmountLimit) public onlyOwner() {
        _potLottoAmountLimit = potLottoAmountLimit;
    }

    // --------------------------------

    function percentageCalculator(uint256 _amount, uint256 fee) private pure returns (uint256) {
        return _amount.mul(fee).div(
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
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }
    
    function updateFees(uint256 buyLiquidityFee, uint256 buyBuybackFee, uint256 buyMarketingFee, uint256 buyTransactionLottoFee, uint256 buyPotLottoFee, uint256 sellLiquidityFee, uint256 sellBuybackFee, uint256 sellMarketingFee, uint256 sellTransactionLottoFee, uint256 sellPotLottoFee) public onlyOwner() {
        uint256 totalBuyTransactionFees = buyLiquidityFee + buyBuybackFee + buyMarketingFee + buyTransactionLottoFee + buyPotLottoFee;
        uint256 totalSellTransactionFees = sellLiquidityFee + sellBuybackFee + sellMarketingFee + sellTransactionLottoFee + sellPotLottoFee;
        require(totalBuyTransactionFees <= 15, "EPAL: Max buy transaction fee is 15"); //ANTI-HONEYPOT
        require(totalSellTransactionFees <= 15, "EPAL: Max sell transaction fee is 15"); //ANTI-HONEYPOT
        _transactionFees.buyLiquidityFee = buyLiquidityFee;
        _transactionFees.buyBuybackFee = buyBuybackFee;
        _transactionFees.buyMarketingFee = buyMarketingFee;
        _transactionFees.buyTransactionLottoFee = buyTransactionLottoFee;
        _transactionFees.buyPotLottoFee = buyPotLottoFee;
        _transactionFees.sellLiquidityFee = sellLiquidityFee;
        _transactionFees.sellBuybackFee = sellBuybackFee;
        _transactionFees.sellMarketingFee = sellMarketingFee;
        _transactionFees.sellTransactionLottoFee = sellTransactionLottoFee;
        _transactionFees.sellPotLottoFee = sellPotLottoFee;
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
        require(maxTxAmount >= 10000000 * 10**9,"EPAL: MaxTxAmount cannot be lower than 1% of total supply"); //PREVENT DISABLE TRADING
        _maxTxAmount = maxTxAmount;
    }

    function updateContractLBMTokensToSell(uint256 contractLBMTokensToSell) public onlyOwner() {
        _contractLBMTokensToSell = contractLBMTokensToSell;
    }

    function updateMarketingAddress(address payable marketingAddress) public onlyOwner() {
        _marketingAddress = marketingAddress;
    }
	
	function beforePresale() public onlyOwner() {
        require(!_beforePresale, "EPAL: function can only be called once");
        _isTaxable[uniswapV2Pair] = true;
        _maxTxAmount = 20000000 * 10**9;
        _contractLBMTokensToSell = 1000000 * 10**9;
        _minTokensRequiredForLotto = 1000000 * 10**9;
        _potLottoAmountLimit = 5000000 * 10**9;
        _buybackAmountLimit = 1 * 10**18;
        _buybackDivisor = 1000;
        _transactionFees.buyLiquidityFee = 0;
        _transactionFees.buyBuybackFee = 0;
        _transactionFees.buyMarketingFee = 5;
        _transactionFees.buyTransactionLottoFee = 8;
        _transactionFees.buyPotLottoFee = 2;
        _transactionFees.sellLiquidityFee = 0;
        _transactionFees.sellBuybackFee = 0;
        _transactionFees.sellMarketingFee = 5;
        _transactionFees.sellTransactionLottoFee = 8;
        _transactionFees.sellPotLottoFee = 2;

        _lotto.push();
        //addLottoParticipant(_msgSender());
        //_contractPotLottoTokenBalance = 1000000000 * 10**9;
        //_balances[address(this)] = 1000000000 * 10**9;
        _beforePresale = true;  
    }
    
    function afterPresale() public onlyOwner() {
        require(_beforePresale, "EPAL: beforePresale function must be called");
        require(!_afterPresale, "EPAL: function can only be called once");
        updateSellContractTokensEnabled(true);
        updateBuybackEnabled(false);
        _afterPresale = true;
    }

    function refreshContractTokenBalance() public{
        uint256 internalBalance = _contractLBMTokenBalance.add(_contractPotLottoTokenBalance);
        if(balanceOf(address(this)) > internalBalance){
            uint256 externalBalance = _balances[address(this)].sub(internalBalance);
            _contractLBMTokenBalance = _contractLBMTokenBalance.add(externalBalance);
        }else if(balanceOf(address(this)) < internalBalance){
            _contractLBMTokenBalance = _balances[address(this)];
        }
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }  
    
    receive() external payable {}
}
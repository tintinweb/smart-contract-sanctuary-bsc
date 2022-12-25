/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

/******************************************************************************
Token Name :
Short Name/Ticker :
Total Supply : 
Decimal : 18
Platform : BEP20 
Project Name :
********************************************************************************/
//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
*/

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
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
 library Address {  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        //solhint-disable-next-line no-inline-assembly
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

    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = _msgSender();
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

interface IPancakeFactory {
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

interface IPancakePair {
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract LaunchToken is Context, IERC20, Ownable {  
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    uint256 private _tTotal = 1000000000 * 10**18;
    uint256 private _tFeeTotal;
    string private _name = "LaunchToken";
    string private _symbol = "LT";
    uint8 private _decimals = 18;
    uint256 public _rewardPool;
    uint256 public _maxTransactionLimits;
    uint256 public _claimedRewardPool;
    uint256 private _maxAntiWhaleLimits;
    uint256 private _minAntiWhaleLimits;
    uint256 public _sellTimeInterval;
    uint256 private _totalMarketingCollected;
    uint256 private _totalLiquidityCollected;
    uint256 private _totalDevelopmentCollected;
    uint256 private _totalRewardCollected;
    uint256 private _totalBurnt; 
    uint256 public _holdingTokenPercent = 2;
   
    uint256 public _sellTaxFee = 10;
    uint256 public _buyTaxFee = 10;

    uint256 private _previousSellTaxFee;
    uint256 private _previousBuyTaxFee;

    uint256 public _developmentBuyPer = 2;
    uint256 public _developmentSellPer = 2;
    
    uint256 public _marketingBuyPer = 2;
    uint256 public _marketingSellPer = 2;

    uint256 public _RewardBuyPer =4;
    uint256 public _RewardSellPer =4;

    uint256 public _LiquidityBuyPer =1;
    uint256 public _LiquiditySellPer =1;
    

    uint256 public _autoBurnBuyPer = 1;
    uint256 public _autoBurnSellPer = 1;
	
    address [] public tokenHolder;
    uint256 public numberOfTokenHolders = 0;
    mapping(address => bool) private exist;
    mapping (address => uint256) public UserrewardPoolOnLastClaim; 
    mapping (address => uint) public UserLastSellTimeStamp;
    mapping (address => bool) public checkUserBlocked;
    //No limit
    address payable public marketingwallet;
    address payable public  developmentwallet;
    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool private _mintable;
    bool private paused = false;
    uint256 private minTokensBeforeSwap = 100;
    event UpdateExcludedFromFee();
    event UpdateIncludeForFee();
    event UpdateWalletAddress();
    event UpdateTransactionLimits();
    event Pause();
    event Unpause();
    event UpdateBuyFee();
    event UpdateSellFee();
    event UpdateHoldingToken();
    event BlockWalletAddress();
    event UnblockWalletAddress();
    event WithdrawBNBupdate(uint256 amount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetTransferLimit();
    event SetSellTimeInterval();
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoMarketing,
        uint256 tokensIntoDevelopment,
        uint256 tokensIntoLiquidity
    );   
    modifier lockTheSwap {
        inSwapAndLiquify = true;
         _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _rOwned[_msgSender()] = _tTotal;
        marketingwallet = 0xCa6faA4b5e9D5910cec5A42dAC6d6d05CBF10fA1;
        developmentwallet= 0x39856d501D0Bd75B51f3C1E25bEbeA4F505d46E3;
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //CREATE A PANCAKE PAIR FOR THIS NEW TOKEN
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        //SET THE REST OF THE CONTRACT VARIABLES
        pancakeRouter = _pancakeRouter;       
        //EXCLUDE OWNER AND THIS CONTRACT FROM FEE
        _isExcludedFromFee[marketingwallet] = true;
        _isExcludedFromFee[developmentwallet] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;  
        tokenHolder.push(_msgSender());
        exist[_msgSender()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    /* Contarct Owner to update the wallet address where marketing fee will recived */
    function updateWalletAddress(address _marketingWalletAddress,address _developmentWalletAddress) onlyOwner public {
        marketingwallet = payable(_marketingWalletAddress);
        developmentwallet = payable(_developmentWalletAddress);
        emit UpdateWalletAddress();
    }

    /* Smart Contract Owner Can Update Buy Fee */
    function updateBuyFee(uint buyTaxFee,uint marketingBuyPer, uint developmentBuyPer,uint RewardBuyPer,uint autoBurnBuyPer,uint LiquidityBuyPer) onlyOwner public {
         _buyTaxFee=buyTaxFee;
         _developmentBuyPer=developmentBuyPer;
        _LiquidityBuyPer=LiquidityBuyPer;
         _marketingBuyPer=marketingBuyPer;
         _RewardBuyPer=RewardBuyPer;
        _autoBurnBuyPer=autoBurnBuyPer;
         emit UpdateBuyFee();
    }

    /* Smart Contract Owner Can Update Sell Fee */
    function updateSellFee(uint sellTaxFee,uint marketingSellPer,uint developmentSellPer,uint RewardSellPer,uint autoBurnSellPer,uint LiquiditySellPer) onlyOwner public {
         _sellTaxFee=sellTaxFee;
         _developmentSellPer=developmentSellPer;
         _LiquiditySellPer=LiquiditySellPer;
         _marketingSellPer=marketingSellPer;
         _RewardSellPer=RewardSellPer;
        _autoBurnSellPer=autoBurnSellPer;
        emit UpdateSellFee();
    }

    function updateHoldingToken(uint holdingTokenPercent) onlyOwner public {
     _holdingTokenPercent=holdingTokenPercent;
     emit UpdateHoldingToken();
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
        return _rOwned[account];
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

    /* Contract Owner Can Set Sell Time Interval */
    function set_sellTimeInterval(uint256 sellTimeInterval) onlyOwner public {
        _sellTimeInterval=sellTimeInterval;
        emit SetSellTimeInterval();
    }

    function checkSellEligibility(address user) public view returns(bool){
       if(UserLastSellTimeStamp[user]==0) {
           return true;
       }
       else{
           uint noofHour=getHour(UserLastSellTimeStamp[user],getCurrentTimeStamp());
           if(noofHour>=_sellTimeInterval){
               return true;
           }
           else{
               return false;
           }
       }
    }

    function getCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function getHour(uint _startDate,uint _endDate) internal pure returns(uint256){
        return ((_endDate - _startDate) / 60 / 60);
    }

    //  function set_NewPairAddress(address newPair) public onlyOwner() {
    //     pancakePair = newPair;
    // }

     function _getMaxHolding() public view returns (uint256) {
        return (_tTotal * _holdingTokenPercent)/100;
    }

    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount<=_maxTransactionLimits,"Maximum Transaction Limit Exceed.");
        require(paused != true, "BEP20: Transaction Is Paused now");     
        require(checkUserBlocked[from] != true , "BEP20: Sender Is Blocked");
        require(checkUserBlocked[to] != true , "BEP20: Receiver Is Blocked");
        require (balanceOf(to)+amount <= _getMaxHolding(), "Maximum holding reached.");
       
        if(to == pancakePair && from!=address(this)) {
            require(amount <= _maxAntiWhaleLimits, "BEP20: Sell Qty Exceed !");
            require(amount >= _minAntiWhaleLimits, "BEP20: Sell Qty Does Not Match !"); 
        }
        // IS THE TOKEN BALANCE OF THIS CONTRACT ADDRESS OVER THE MIN NUMBER OF
        // TOKENS THAT WE NEED TO INITIATE A SWAP + LIQUIDITY LOCK?
        // ALSO, DON'T GET CAUGHT IN A CIRCULAR LIQUIDITY EVENT.
        // ALSO, DON'T SWAP & LIQUIFY IF SENDER IS PANCAKE PAIR.
        if(!exist[to]) {
            tokenHolder.push(to);
            numberOfTokenHolders++;
            exist[to] = true;
        }
        //INDICATES IF FEE SHOULD BE DEDUCTED FROM TRANSFER
        bool takeFee = true;
        uint TaxType=0;
        //IF ANY ACCOUNT BELONGS TO _isExcludedFromFee ACCOUNT THEN REMOVE THE FEE
        if(from == pancakePair){
            takeFee = true;
            TaxType=1;
        }  
        else if(to == pancakePair){
           takeFee = true;
            TaxType=2;
        }  
        else if(from != pancakePair && to != pancakePair){
            takeFee = false;
            TaxType=0;
        } 
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
            TaxType=0;
        }   
        UserrewardPoolOnLastClaim[from]=_rewardPool;
        UserrewardPoolOnLastClaim[to]=_rewardPool;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > minTokensBeforeSwap;
        if 
        (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakePair &&
            swapAndLiquifyEnabled &&
            TaxType != 0 &&
            takeFee
        ) 
        {
            //LIQUIFY TOKEN TO GET BNB 
            swapAndLiquify(contractTokenBalance,TaxType);
        }      
        //TRANSFER AMOUNT, IT WILL TAKE TAX, BURN, LIQUIDITY FEE
        _tokenTransfer(from,to,amount,takeFee,TaxType);
    }


    function _verifyMaxTransactionLimits(uint256 maxTransactionLimits) public onlyOwner {
        _maxTransactionLimits=maxTransactionLimits;
    }


    function myRewards(address _wallet) public view returns(uint256 _reward){
        uint256 rewardPoolfrom=UserrewardPoolOnLastClaim[_wallet]; 
        uint256 remainPoolfrom=_rewardPool-rewardPoolfrom; 
        if(remainPoolfrom>0 && balanceOf(_wallet)>0  && exist[_wallet]){
            return (balanceOf(_wallet).mul(remainPoolfrom)).div(totalSupply());
        }
    }

    function claimReward() public {
        uint256 rewardPool=UserrewardPoolOnLastClaim[msg.sender]; 
        uint256 remainPool=_rewardPool-rewardPool; 
        if(remainPool>0 && balanceOf(msg.sender)>0 && exist[msg.sender]){
            uint256 userShare = (balanceOf(msg.sender).mul(remainPool)).div(totalSupply());
            payable(msg.sender).transfer(userShare);
            _claimedRewardPool+=userShare;
        }
        UserrewardPoolOnLastClaim[msg.sender]=_rewardPool;
    }


    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _rOwned[account] = _rOwned[account].sub(amount, "BEP20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, address(0), amount);
    }

       /* Smart Contract Owner Can Exclude Any Wallet From Fee */
    function excludedFromFee(address walletaddress) onlyOwner public {
       _isExcludedFromFee[walletaddress] = true;
        emit UpdateExcludedFromFee();
    }

    /* Smart Contract Owner Can Include Any Wallet For Fee */
    function includeForFee(address walletaddress) onlyOwner public {
        _isExcludedFromFee[walletaddress] = false;
        emit UpdateIncludeForFee();
    }

    /* Smart Contract Owner Can Pause The Token Transaction if And Only If canPause is true */
    function pauseTransaction() onlyOwner public {
        paused = true;
        emit Pause();
    }

    /* Smart Contract Owner Can Unpause The Token Transaction if token previously paused */
    function unpauseTransaction() onlyOwner public {
        paused = false;
        emit Unpause();
    }
 
    function blockWalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = true;
        emit BlockWalletAddress();
    }

    function unblockWalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = false;
        emit UnblockWalletAddress();
    }

     function swapAndLiquify(uint256 contractTokenBalance,uint TaxType) private lockTheSwap {
        // split the contract balance into halves
        uint256 forLiquidity = _totalLiquidityCollected;
        uint256 forMarketing = _totalMarketingCollected;
        uint256 forDevelopment = _totalDevelopmentCollected;
        uint256 forReward = contractTokenBalance.sub(forLiquidity.add(forMarketing).add(forDevelopment));
        // split the liquidity
        uint256 liquidityHalf = forLiquidity.div(2);
        uint256 liquidityToken = forLiquidity.sub(liquidityHalf);
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
		
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;
        //swap tokens for ETH
        if(liquidityHalf.add(forMarketing).add(forReward).add(forDevelopment)>0)
        swapTokensForEth(liquidityHalf.add(forMarketing).add(forReward).add(forDevelopment)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        //How much ETH did we just swap into ?
        uint256 Balance = address(this).balance.sub(initialBalance);
        uint EachPer=0;
        uint MarketingPer=0;
        uint RewardPer=0;
        uint DevelopmentPer=0;
        if(TaxType==1){
            EachPer=100/(_LiquidityBuyPer.add(_marketingBuyPer).add(_RewardBuyPer));
            MarketingPer=EachPer*_marketingBuyPer;
            RewardPer=EachPer*_RewardBuyPer;
            DevelopmentPer=EachPer*_developmentBuyPer;
        }
        else{
            EachPer=100/(_LiquiditySellPer.add(_marketingSellPer).add(_RewardSellPer));
            MarketingPer=EachPer*_marketingSellPer;
            RewardPer=EachPer*_RewardSellPer;
            DevelopmentPer=EachPer*_developmentSellPer;
        }
        uint256 LiquidityBNB = Balance.div(4);
        uint256 MarketingBNB = Balance.mul(MarketingPer).div(10**2);
        uint256 RewardBNB = Balance.mul(RewardPer).div(10**2);
        uint256 DevelopmentBNB = Balance.mul(RewardPer).div(10**2);
        if(MarketingBNB>0)
        marketingwallet.transfer(MarketingBNB);
        if( DevelopmentBNB>0)
        developmentwallet.transfer(DevelopmentBNB);
        if(liquidityToken>0 && LiquidityBNB>0)
        addLiquidity(liquidityToken, LiquidityBNB);
        if(liquidityToken>0 && LiquidityBNB>0)
        _totalLiquidityCollected=0;
        if(MarketingBNB>0)
        _totalMarketingCollected=0;
        if(DevelopmentBNB>0)
        _totalDevelopmentCollected=0;
        if(RewardBNB>0)
        _totalRewardCollected=0;
        _rewardPool=_rewardPool.add(RewardBNB);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRouter), tokenAmount);
        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        //GENERATE THE PANCAKE PAIR PATH OF TOKEN -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        _approve(address(this), address(pancakeRouter), tokenAmount);
        //MAKE THE SWAP
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, //ACCEPT ANY AMOUNT OF ETH
            path,
            address(this),
            block.timestamp
        );
    }

    //THIS METHOD IS RESPONSIBLE FOR TAKING ALL FEE, IF TAKEFEE IS TRUE
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee,uint TaxType) private {
        if(!takeFee)
            removeAllFee();
        
        _transferStandard(sender, recipient, amount,TaxType);  
        if(!takeFee)
            restoreAllFee();
        if(TaxType==2 && recipient == pancakePair) {
        }
    }
  
    function _transferStandard(address sender, address recipient, uint256 tAmount,uint TaxType) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount,TaxType);
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
         if(_rOwned[sender]==0){
          _rOwned[sender]=_rOwned[sender].add(1 * 10**2);
        }
        _rOwned[recipient] = _rOwned[recipient].add(tTransferAmount);
        if(tFee>0){
          _takeMarketingFee(tAmount,tFee,TaxType);
          _reflectFee(tFee);
        }
        emit Transfer(sender, recipient, tTransferAmount);
        if(tFee>0) {
           emit Transfer(sender,address(this),tFee);
        }
    }

    function _reflectFee(uint256 tFee) private {
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount,uint TaxType) private view returns (uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount,TaxType);
        return (tTransferAmount,tFee);
    }

    function _getTValues(uint256 tAmount,uint TaxType) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount,TaxType);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }
    /* Contarct Owner Can Update The Minimum & Maximum Transaction Limits */
    function update_AntiWhaleLimits(uint256 maxAntiWhaleLimits,uint256 minAntiWhaleLimits) public onlyOwner {
       _maxAntiWhaleLimits=maxAntiWhaleLimits;
       _minAntiWhaleLimits=minAntiWhaleLimits;
       emit UpdateTransactionLimits();
    }
    function _takeMarketingFee(uint256 tAmount,uint256 tFee,uint TaxType) private {
        uint256 MarketingShare=0;
        uint256 BurningShare=0;
        uint256 RewardShare=0;
        uint256 LiquidityShare=0;
        uint256 DevelopmentShare=0;
        if(TaxType==1){
            MarketingShare=tAmount.mul(_marketingBuyPer).div(10**2);
            RewardShare=tAmount.mul(_RewardBuyPer).div(10**2);
            BurningShare=tAmount.mul(_autoBurnBuyPer).div(10**2);
            LiquidityShare=tAmount.mul(_LiquidityBuyPer).div(10**2);
            DevelopmentShare=tAmount.mul(_developmentSellPer).div(10**2);
        }
        else if(TaxType==2){
            MarketingShare=tAmount.mul(_marketingSellPer).div(10**2);
            RewardShare=tAmount.mul(_RewardSellPer).div(10**2);
            BurningShare=tAmount.mul(_autoBurnSellPer).div(10**2);
            LiquidityShare=tAmount.mul(_LiquiditySellPer).div(10**2);
            DevelopmentShare=tAmount.mul(_developmentSellPer).div(10**2);
        }
        if(tFee<(MarketingShare.add(RewardShare).add(DevelopmentShare).add(BurningShare).add(LiquidityShare))){
            RewardShare=RewardShare.sub((MarketingShare.add(RewardShare).add(BurningShare).add(LiquidityShare)).sub(tFee));
        }
        uint256 FeeMarkRewLiqu=MarketingShare+LiquidityShare+RewardShare+DevelopmentShare;
        uint256 contractTransferBalance = FeeMarkRewLiqu;
        uint256 Burn=BurningShare;
        _rOwned[address(this)] = _rOwned[address(this)].add(contractTransferBalance);
        _totalBurnt=_totalBurnt.add(Burn);
        _totalRewardCollected=_totalRewardCollected.add(RewardShare);
        _totalLiquidityCollected=_totalLiquidityCollected.add(LiquidityShare);
        _totalMarketingCollected=_totalMarketingCollected.add(MarketingShare);
        _totalDevelopmentCollected=_totalDevelopmentCollected.add(DevelopmentShare);
        _takeAutoBurn();
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    } 

    function calculateTaxFee(uint256 _amount,uint TaxType) private view returns (uint256) {
       if(TaxType==1){
         return _amount.mul(_buyTaxFee).div(10**2);
       }
       if(TaxType==2){
         return _amount.mul(_sellTaxFee).div(10**2);
       }
       else{
         return 0;
       }
    }

   function removeAllFee() private {
        _previousSellTaxFee = _sellTaxFee;
        _previousBuyTaxFee = _buyTaxFee;
        _sellTaxFee = 0;
        _buyTaxFee = 0;
    }
    
    function restoreAllFee() private {
        _sellTaxFee = _previousSellTaxFee;
        _buyTaxFee=_previousBuyTaxFee;
        _previousSellTaxFee=0;
        _previousBuyTaxFee=0;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function _takeAutoBurn() private {
        _tTotal = _tTotal.sub(_totalBurnt);
        _totalBurnt=0;
    }

    
    receive() external payable {}

    function WithdrawBNB(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
          emit WithdrawBNBupdate(amount);
    }

}
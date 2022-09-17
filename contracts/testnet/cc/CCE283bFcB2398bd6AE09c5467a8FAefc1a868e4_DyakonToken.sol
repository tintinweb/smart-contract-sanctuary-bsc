/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/******************************************************************************
Token Name : DYAKON TOKEN
Short Name : DYN
Total Supply : 1000000000000 GSTv2
Decimal : 18
Platform : BEP20 
Project Name : DYAKON
Website Link : https://www.goldensparrow.info
Whitepaper Link : https://www.goldensparrow.info/assets/file/GST_Whitepaper.pdf
Facebbok : https://www.facebook.com/Golden-Sparrow-Token-104806088937264
Twitter : https://twitter.com/RealGSTArmy?t=KcwL2Acee3_ieRJb2wkQyg&s=09
Telegram : https://telegram.me/+kPIlcohyp6FmYmE1  
Linkdin :  https://www.linkedin.com/in/golden-sparrow-token-86b12b242
Instagram : https://www.instagram.com/goldensparrowtoken/
********************************************************************************/
//SPDX-License-Identifier: Unlicensed
/* Interface Declaration */
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

contract DyakonToken is Context, IERC20, Ownable {  
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReward;
    mapping (address => bool) public checkUserBlocked;
    address[] private _ExcludedFromReward;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    string private _name = "DYAKON";
    string private _symbol ="DYN";
    uint8 private _decimals = 18;
    uint256 private _maxAntiWhaleLimits;
    uint256 private _minAntiWhaleLimits;
    uint256 _sellTimeInterval;
    mapping (address => uint) public UserLastSellTimeStamp;
    uint256 private _totalBurnt = 0;
    uint256 private _totalReflection = 0;
    uint256 private _totalLiquidity = 0;  
    uint256 public _sellTaxFee = 12;
    uint256 private _previousSellTaxFee = _sellTaxFee;
    uint256 public _buyTaxFee = 12;
    uint256 private _previousBuyTaxFee = _buyTaxFee;
    uint256 public _marketingPer = 2;
    uint256 public _autoBurnPer = 1;
    uint256 public _ReflectionBuyPer = 2;
    uint256 public _ReflectionSellPer = 2;
   uint256 public _autoLiquidityPer = 4;
    uint256 public _subMarketingPer = 5;  
    address [] public tokenHolder;
    uint256 public numberOfTokenHolders = 0;
    mapping(address => bool) private exist;
    //No limit
    address payable marketingwallet;
    address payable submarketingWallet;
    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    uint256 private minTokensBeforeSwap = 0;
    event UpdateMarketingWalletAddress();
    event UpdateTransactionLimits();
    event SetSellTimeInterval();
    event BlockWalletAddress();
    event UnblockWalletAddress();
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoMarketing,
        uint256 tokensIntoSubMarketing
    );   
    modifier lockTheSwap {
        inSwapAndLiquify = true;
         _;
        inSwapAndLiquify = false;
    }
    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        marketingwallet = 0xCa6faA4b5e9D5910cec5A42dAC6d6d05CBF10fA1;
        submarketingWallet= 0x39856d501D0Bd75B51f3C1E25bEbeA4F505d46E3;
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //CREATE A PANCAKE PAIR FOR THIS NEW TOKEN
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        //SET THE REST OF THE CONTRACT VARIABLES
        pancakeRouter = _pancakeRouter;       
        //EXCLUDE OWNER AND THIS CONTRACT FROM FEE
        _isExcludedFromFee[marketingwallet] = true;
        _isExcludedFromFee[submarketingWallet] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;  
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    /* Contarct Owner Can Update The Minimum & Maximum Transaction Limits */
    function update_AntiWhaleLimits(uint256 maxAntiWhaleLimits,uint256 minAntiWhaleLimits) public onlyOwner {
       _maxAntiWhaleLimits=maxAntiWhaleLimits;
       _minAntiWhaleLimits=minAntiWhaleLimits;
       emit UpdateTransactionLimits();
    }

    /* Contarct Owner to update the wallet address where marketing fee will recived */
    function update_MarketingWalletAddress(address _marketingWalletAddress,address _submarketingWalletAddress) onlyOwner public {
        marketingwallet = payable(_marketingWalletAddress);
        submarketingWallet = payable(_submarketingWalletAddress);
        emit UpdateMarketingWalletAddress();
    }

    /* Contract Owner can set Sell Time Interval */
    function set_sellTimeInterval(uint256 sellTimeInterval) onlyOwner public {
        _sellTimeInterval=sellTimeInterval;
        emit SetSellTimeInterval();
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
        if (_isExcludedFromReward[account]) return _tOwned[account];
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    /* Contract Owner can block wallet address in case any needed */
    function block_WalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = true;
        emit BlockWalletAddress();
    }
    /* Contract Owner can un block wallet address that earlier blocked */
    function unblock_WalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = false;
        emit UnblockWalletAddress();
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {        
        require(!_isExcludedFromReward[account], "Account is already excluded");
        _isExcludedFromReward[account] = true;
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account], "Account is already included");
        _isExcludedFromReward[account] = false;
    }
  
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function getHour(uint _startDate,uint _endDate) internal pure returns(uint256){
        return ((_endDate - _startDate) / 60 / 60);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(checkUserBlocked[from] != true , "BEP20: Sender Is Blocked !");
         require(checkUserBlocked[to] != true , "BEP20: Receiver Is Blocked !");
      if(to == pancakePair){
            require(amount <= _maxAntiWhaleLimits, "BEP20: Sell Qty Exceed !");
            require(amount >= _minAntiWhaleLimits, "BEP20: Sell Qty Does Not Match !"); 
            require(checkSellEligibility(from), "BEP20: Try After Sell Time Interval !"); 
        }
        // IS THE TOKEN BALANCE OF THIS CONTRACT ADDRESS OVER THE MIN NUMBER OF
        // TOKENS THAT WE NEED TO INITIATE A SWAP + LIQUIDITY LOCK?
        // ALSO, DON'T GET CAUGHT IN A CIRCULAR LIQUIDITY EVENT.
        // ALSO, DON'T SWAP & LIQUIFY IF SENDER IS PANCAKE PAIR.
        if(!exist[to]){
            tokenHolder.push(to);
            numberOfTokenHolders++;
            exist[to] = true;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > minTokensBeforeSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakePair &&
            swapAndLiquifyEnabled
        ) {
            //LIQUIFY TOKEN TO GET BNB 
            swapAndLiquify(contractTokenBalance);
        }
        //INDICATES IF FEE SHOULD BE DEDUCTED FROM TRANSFER
        bool takeFee = false;

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
        //TRANSFER AMOUNT, IT WILL TAKE TAX, BURN, LIQUIDITY FEE
        _tokenTransfer(from,to,amount,takeFee,TaxType);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 forLiquidity = contractTokenBalance.div(4);
        uint256 FullExp = contractTokenBalance.div(5);
        uint256 SubMarketingExp = FullExp.mul(5).div(100);
        uint256 MarketingExp=FullExp.sub(SubMarketingExp);
          // split the liquidity
        uint256 half = forLiquidity.div(4);
        uint256 otherHalf = forLiquidity.sub(half);
        // CAPTURE THE CONTRACT'S CURRENT ETH BALANCE.
        // THIS IS SO THAT WE CAN CAPTURE EXACTLY THE AMOUNT OF ETH THAT THE
        // SWAP CREATES, AND NOT MAKE THE LIQUIDITY EVENT INCLUDE ANY ETH THAT
        // HAS BEEN MANUALLY SENT TO THE CONTRACT
        uint256 initialBalance = address(this).balance;
        //SWAP TOKENS FOR ETH
        swapTokensForEth(MarketingExp.add(SubMarketingExp)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        //HOW MUCH ETH DID WE JUST SWAP INTO?
        uint256 Balance = address(this).balance.sub(initialBalance);
        uint256 Full = Balance.div(5);
        uint256 SubMarketing = Full.mul(5).div(100);
        uint256 Marketing = Full.sub(SubMarketing);
        marketingwallet.transfer(Marketing);
        submarketingWallet.transfer(SubMarketing);

        autoLiquidity(otherHalf, Full);
        emit SwapAndLiquify(FullExp, Full, Marketing,SubMarketing);
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
     function autoLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
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


    //THIS METHOD IS RESPONSIBLE FOR TAKING ALL FEE, IF TAKEFEE IS TRUE
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee,uint TaxType) private {
        if(!takeFee)
            removeAllFee();
        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount,TaxType);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount,TaxType);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, amount,TaxType);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount,TaxType);
        } else {
            _transferStandard(sender, recipient, amount,TaxType);
        }
        if(!takeFee)
            restoreAllFee();
        if(sender != pancakePair || recipient == pancakePair) {
            UserLastSellTimeStamp[sender]=block.timestamp;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount,uint TaxType) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount,TaxType);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketingFee(tFee,TaxType);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tFee>0){
            emit Transfer(sender,address(this),tFee);
        }
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount,uint TaxType) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount,TaxType);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeMarketingFee(tFee,TaxType);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tFee>0){
            emit Transfer(sender,address(this),tFee);
        }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount,uint TaxType) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount,TaxType);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeMarketingFee(tFee,TaxType);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tFee>0){
            emit Transfer(sender,address(this),tFee);
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount,uint TaxType) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount,TaxType);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeMarketingFee(tFee,TaxType);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);   
        if(tFee>0){
            emit Transfer(sender,address(this),tFee);
        }   
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount,uint TaxType) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount,TaxType);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount,uint TaxType) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount,TaxType);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _ExcludedFromReward.length; i++) {
            if (_rOwned[_ExcludedFromReward[i]] > rSupply || _tOwned[_ExcludedFromReward[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_ExcludedFromReward[i]]);
            tSupply = tSupply.sub(_tOwned[_ExcludedFromReward[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeMarketingFee(uint256 tMarketing,uint TaxType) private {
        uint256 currentRate =  _getRate();
        uint256 MarketingShare=0;
        uint256 BurningShare=0;
        uint256 LiquidityShare=0;
        uint256 ReflectionShare=0;
        if(TaxType==1){
            MarketingShare=tMarketing.mul(40).div(100);
            ReflectionShare=tMarketing.mul(18).div(100);
            BurningShare=tMarketing.mul(10).div(100);
            LiquidityShare=tMarketing.mul(32).div(100);
        }
        else if(TaxType==2){
            MarketingShare=tMarketing.mul(40).div(100);
            ReflectionShare=tMarketing.mul(18).div(100);
            BurningShare=tMarketing.mul(10).div(100);
            LiquidityShare=tMarketing.mul(32).div(100);
        }
        uint256 rMarketing = MarketingShare.mul(currentRate);
        uint256 Burn=BurningShare;
        uint256 Reflection=ReflectionShare;
        uint256 Liquidity=LiquidityShare;
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        _totalBurnt=_totalBurnt.add(Burn);
        _totalReflection=_totalReflection.add(Reflection);
         _totalLiquidity=_totalLiquidity.add(Liquidity);
        _takeAutoBurn();
        _reflection();
        //  _autoLiquidity();
    }

    function _takeAutoBurn() private {
        _tTotal = _tTotal.sub(_totalBurnt);
        _totalBurnt=0;
    }


    function _reflection() private {
      if(tokenHolder.length > 0){
      for(uint8 i = 0; i < tokenHolder.length; i++) {
         address _tokenHolder = tokenHolder[i];
         if(!_isExcludedFromReward[_tokenHolder])
         {
            uint256 _tokenHolderSharePer=(_rOwned[_tokenHolder].mul(100)).div(_tTotal);
            uint256 _tokenHolderShare=_totalReflection.mul(_tokenHolderSharePer).div(100);
            _rOwned[_tokenHolder] = _rOwned[_tokenHolder].add(_tokenHolderShare);
          }
        }
      }
      _totalReflection=0;
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
    
    receive() external payable {}

    function VerifyBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

}
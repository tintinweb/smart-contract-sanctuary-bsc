/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

/******************************************************************************
Token Name : Bizforce
Short Name/Ticker : FRC
Total Supply : 1000000000
Decimal : 18
Platform : BEP20 
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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
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

    address internal _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

contract Initializable {
    bool inited = false;
    modifier initializer() {
        require(!inited, "tokenomics already inited");
        _;
        inited = true;
    }
    bool ownerinited = false;
    modifier ownerinitializer() {
        require(!ownerinited, "manager already inited");
        _;
        ownerinited = true;
    }
}


contract Bizforce is Context, IERC20, Ownable,Initializable {   

    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public _allIncludedPair;
    address[] private _ExcludedFromReward;
    uint256 public _maxAntiWhaleLimits;
    uint256 public _minAntiWhaleLimits;

    uint256 public _maxTransferLimits;
    uint256 public _minTransferLimits;

    uint256 public _sellTimeInterval;
    
    mapping (address => uint) public UserLastSellTimeStamp;
    mapping (address => uint256) public UserrewardPoolOnLastClaim; 
    uint256 public _rewardPool;
    uint256 public _claimedRewardPool;

    address [] public tokenHolder;
    mapping(address => bool) private exist;
    mapping (address => bool) public checkUserBlocked;

    //No limit
    address payable public marketingwallet;
    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;
    bool inSwapAndLiquify;

    uint256 private _tTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
	
    //TaxType=0 Then Buy
    //TaxType=1 Then Sell
    //TaxType=2 Then Excluded From Reward No Tax
    uint256[3] public _TaxType = [0,1,2];
    uint256[3] public _TaxFee = [0,5,0];
    uint256[3] private _previousTaxFee = [0,0,0];
    uint256 [3] public _marketingTax  = [0,3,0];
    uint256 [3] public _rewardTax  = [0,0,0];
    uint256 [3] public _autoBurnTax  = [0,2,0];
    
 
	bool public swapAndLiquifyEnabled = false;
    uint256 private minTokensBeforeSwap;
	
	uint256 private _totalBurnt;
    uint256 private _totalRewardCollected; 
    uint256 private _totalLiquidityCollected;
    uint256 private _totalMarketingCollected;
    uint256 private _totalDevelopmentCollected;
    uint256 public numberOfTokenHolders;

    event UpdateFee();
    event UpdateExcludedFromFee();
    event UpdateIncludeForFee();
    event UpdateBurnPer();
    event UpdateMarketingPer();
    event UpdateRewardPer();
    event BlockWalletAddress();
    event UnblockWalletAddress();
    event UpdateMarketingWalletAddress();
    event UpdateTransactionLimits();
    event SetSellTimeInterval();
    event SwapAndLiquifyEnabledUpdated(bool enabled); 

    constructor(address marketingWallet) public {

        address msgSender = _msgSender();
        _owner = _msgSender();

        emit OwnershipTransferred(address(0), msgSender);

        _tTotal = 1000000000 * 10**18;
        _name = "Bizforce";
        _symbol = "FRC";
        _decimals = 18;

        
        swapAndLiquifyEnabled = false;
        minTokensBeforeSwap = 0;
        
        _totalBurnt = 0;
        _totalRewardCollected = 0; 
        _totalMarketingCollected = 0;
        
        numberOfTokenHolders = 0;

        _rOwned[_msgSender()] = _tTotal;
        marketingwallet = payable(marketingWallet);
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //CREATE A PANCAKE PAIR FOR THIS NEW TOKEN
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        _allIncludedPair[pancakePair] = true;
        //SET THE REST OF THE CONTRACT VARIABLES
        pancakeRouter = _pancakeRouter;       
        //EXCLUDE OWNER AND THIS CONTRACT FROM FEE
        _isExcludedFromFee[marketingwallet] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;     
        tokenHolder.push(_msgSender());
        numberOfTokenHolders++;
        exist[_msgSender()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
	}


    modifier lockTheSwap {
        inSwapAndLiquify = true;
         _;
        inSwapAndLiquify = false;
    }

    function _IncludedPair(address account,bool flag) public onlyOwner {
        _allIncludedPair[account] = flag;
    }

    /* Contract Owner can set Sell Time Interval */
    function set_sellTimeInterval(uint256 sellTimeInterval) onlyOwner public {
        _sellTimeInterval=sellTimeInterval;
        emit SetSellTimeInterval();
    }

    /* Contarct Owner Can Update The Minimum & Maximum Transaction Limits */
    function update_AntiWhaleLimits(uint256 maxAntiWhaleLimits,uint256 minAntiWhaleLimits,uint256 maxTransferLimits,uint256 minTransferLimits) public onlyOwner {
       _maxAntiWhaleLimits=maxAntiWhaleLimits;
       _minAntiWhaleLimits=minAntiWhaleLimits;
       _maxTransferLimits=maxTransferLimits;
       _minTransferLimits=minTransferLimits;
       emit UpdateTransactionLimits();
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

    /**
    * @dev Burn `amount` tokens and decreasing the total supply.
    */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _rOwned[account] = _rOwned[account].sub(amount, "BEP20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function getCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

    function getHour(uint _startDate,uint _endDate) internal pure returns(uint256){
        return ((_endDate - _startDate) / 60 / 60);
    }

    /* Smart Contract Owner Can Execlude Any Wallet From Fee */
    function excludedFromFee(address walletaddress) onlyOwner public {
       _isExcludedFromFee[walletaddress] = true;
        emit UpdateExcludedFromFee();
    }

    /* Smart Contract Owner Can Include Any Wallet For Fee */
    function includeForFee(address walletaddress) onlyOwner public {
        _isExcludedFromFee[walletaddress] = false;
        emit UpdateIncludeForFee();
    }

  
    /**
    * @dev called by the owner to block wallet address in case any needed
    */
    function blockWalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = true;
        emit BlockWalletAddress();
    }

    /**
    * @dev called by the owner to Unblock Wallet Address that earlier blocked
    */
    function unblockWalletAddress(address WalletAddress) onlyOwner public {
        checkUserBlocked[WalletAddress] = false;
        emit UnblockWalletAddress();
    }

    /* Smart Contract Owner Can Update Transfer/Buy/Sell Fee */
    function updateFee(uint TaxType,uint TaxFee,uint marketingTax,uint rewardTax,uint autoBurnTax) onlyOwner public {
        _TaxFee[TaxType]=TaxFee;
        _marketingTax[TaxType]=marketingTax;
        _rewardTax[TaxType]=rewardTax;
        _autoBurnTax[TaxType]=autoBurnTax;
        emit UpdateFee();
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


    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

  
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _transfer(address from,address to,uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero"); 
        require(checkUserBlocked[from] != true , "BEP20: Sender Is Blocked");
        require(checkUserBlocked[to] != true , "BEP20: Receiver Is Blocked");
        
        // IS THE TOKEN BALANCE OF THIS CONTRACT ADDRESS OVER THE MIN NUMBER OF
        // TOKENS THAT WE NEED TO INITIATE A SWAP + LIQUIDITY LOCK?
        // ALSO, DON'T GET CAUGHT IN A CIRCULAR LIQUIDITY EVENT.
        // ALSO, DON'T SWAP & LIQUIFY IF SENDER IS PANCAKE PAIR.
        if(!exist[to]){
            tokenHolder.push(to);
            numberOfTokenHolders++;
            exist[to] = true;
        }

        //INDICATES IF FEE SHOULD BE DEDUCTED FROM TRANSFER
        bool takeFee = false;
        uint TaxType=3;

        //IF ANY ACCOUNT BELONGS TO _isExcludedFromFee ACCOUNT THEN REMOVE THE FEE
        if(_allIncludedPair[from]){
            takeFee = true;
            TaxType=1;
        }  
        else if(_allIncludedPair[to]){
           takeFee = true;
           TaxType=2;
        }  
        else{
            takeFee = true;
            TaxType=0;
        } 

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = true;
            TaxType=3;
        }  

        if(takeFee && TaxType==0 && !_allIncludedPair[from]){
            require(amount <= _maxTransferLimits, "BEP20: Transfer Qty Exceed !");
            require(amount >= _minTransferLimits, "BEP20: Transfer Qty Does Not Match !");
        }

        else if(takeFee && TaxType==2 && from!=address(this) ){
            require(amount <= _maxAntiWhaleLimits, "BEP20: Sell Qty Exceed !");
            require(amount >= _minAntiWhaleLimits, "BEP20: Sell Qty Does Not Match !"); 
            require(checkSellEligibility(from), "BEP20: Try After Sell Time Interval !"); 
        }

        UserrewardPoolOnLastClaim[from]=_rewardPool;
        UserrewardPoolOnLastClaim[to]=_rewardPool;
        //Liquify Collected Token For Fee
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > minTokensBeforeSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !_allIncludedPair[from] &&
            swapAndLiquifyEnabled &&
            TaxType != 3 &&
            takeFee
        ) {
            //LIQUIFY TOKEN TO GET BNB 
            swapAndLiquify(contractTokenBalance,TaxType);
        }
        //TRANSFER AMOUNT, IT WILL TAKE TAX, BURN, LIQUIDITY FEE
        _tokenTransfer(from,to,amount,takeFee,TaxType);
    }

    function swapAndLiquify(uint256 contractTokenBalance,uint TaxType) private lockTheSwap {
        // split the contract balance into halves
        uint256 forMarketing = _totalMarketingCollected;
        uint256 forReward = contractTokenBalance.sub(forMarketing);      
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;
        //swap tokens for ETH
        swapTokensForEth(forMarketing.add(forReward));        //How much ETH did we just swap into ?
        uint256 Balance = address(this).balance.sub(initialBalance);
        uint EachPer=0;
        uint MarketingPer=0;
        uint RewardPer=0;

        uint256 _aggregateTax;
        _aggregateTax+=_marketingTax[TaxType];
        _aggregateTax+=_rewardTax[TaxType];

        EachPer=100/_aggregateTax;
        MarketingPer=EachPer*_marketingTax[TaxType];
        RewardPer=EachPer*_rewardTax[TaxType];
         
        uint256 MarketingBNB = Balance.mul(MarketingPer).div(10**2);
        uint256 RewardBNB = Balance.mul(RewardPer).div(10**2);
        if(MarketingBNB>0){
            marketingwallet.transfer(MarketingBNB);
        }
        _rewardPool=_rewardPool.add(RewardBNB);

        _totalMarketingCollected=0;
        _totalRewardCollected=0;

    }

    function claimReward() public {
        if(!_allIncludedPair[msg.sender]) {
            uint256 rewardPool=UserrewardPoolOnLastClaim[msg.sender]; 
            uint256 remainPool=_rewardPool-rewardPool; 
            if(remainPool>0 && balanceOf(msg.sender)>0 && exist[msg.sender]){
                uint256 userShare = (balanceOf(msg.sender).mul(remainPool)).div(totalSupply());
                payable(msg.sender).transfer(userShare);
                _claimedRewardPool+=userShare;
            }
            UserrewardPoolOnLastClaim[msg.sender]=_rewardPool;
        }
    }

    function myRewards(address _wallet) public view returns(uint256 _reward){
        uint256 userSharefrom=0;
        if(!_allIncludedPair[msg.sender]) {
            uint256 rewardPoolfrom=UserrewardPoolOnLastClaim[_wallet]; 
            uint256 remainPoolfrom=_rewardPool-rewardPoolfrom; 
            if(remainPoolfrom>0 && balanceOf(_wallet)>0  && exist[_wallet]){
              userSharefrom = (balanceOf(_wallet).mul(remainPoolfrom)).div(totalSupply());
            }
            return userSharefrom;
        }
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
            removeAllFee(TaxType);
             _transferStandard(sender, recipient, amount,TaxType);     
        if(!takeFee)
            restoreAllFee(TaxType);
        if(TaxType==2 && _allIncludedPair[recipient]) {
            UserLastSellTimeStamp[sender]=block.timestamp;
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
          _takeFee(tAmount,tFee,TaxType);
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

    function _takeFee(uint256 tAmount,uint256 tFee,uint TaxType) private {

        uint256 MarketingShare=0;
        uint256 BurningShare=0;
        uint256 RewardShare=0;

        MarketingShare=tAmount.mul(_marketingTax[TaxType]).div(10**2);
        RewardShare=tAmount.mul(_rewardTax[TaxType]).div(10**2);
        BurningShare=tAmount.mul(_autoBurnTax[TaxType]).div(10**2);
        
        if(tFee<(MarketingShare.add(RewardShare).add(BurningShare))){
            RewardShare=RewardShare.sub((MarketingShare.add(RewardShare).add(BurningShare)).sub(tFee));
        }

        uint256 FeeMarkRewLiqu=MarketingShare+RewardShare;
        uint256 contractTransferBalance = FeeMarkRewLiqu;
        uint256 Burn=BurningShare;
        _rOwned[address(this)] = _rOwned[address(this)].add(contractTransferBalance);
        _totalBurnt=_totalBurnt.add(Burn);
        _totalRewardCollected=_totalRewardCollected.add(RewardShare);
        _totalMarketingCollected=_totalMarketingCollected.add(MarketingShare);
        _takeAutoBurn();

    }

    function _takeAutoBurn() private {
        _tTotal = _tTotal.sub(_totalBurnt);
        _totalBurnt=0;
    }

    function calculateTaxFee(uint256 _amount,uint TaxType) private view returns (uint256) {
        return _amount.mul(_TaxFee[TaxType]).div(10**2);      
    }
 
    function removeAllFee(uint TaxType) private {
        _previousTaxFee[TaxType] = _TaxFee[TaxType];
        _TaxFee[TaxType] = 0;
    }
    
    function restoreAllFee(uint TaxType) private {
        _TaxFee[TaxType] = _previousTaxFee[TaxType];
       _previousTaxFee[TaxType]=0;
    }

    function setSwapAndLiquifyEnabled(bool _enabled,uint256 _minTokensBeforeSwap) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        minTokensBeforeSwap=_minTokensBeforeSwap;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}

    function verifyBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function verifyToken(uint256 _amount) external onlyOwner() {
        IERC20 tokenContract = IERC20(address(this));
        tokenContract.transfer(_owner, _amount);
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: Unlicensed 
// "Unlicensed" is NOT Open Source 
// This contract can not be used/forked without permission 


/*





*/

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
    function decimals() external pure returns (uint256);
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






contract AA_BUNNY is Context, IERC20 { 
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => bool) public _isExcluded; 
    mapping (address => bool) public _isSnipe;
    mapping (address => bool) public _preLaunchAccess;
    mapping (address => bool) public _limitExempt;
    mapping (address => bool) public _isPair;




    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    
    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }





    // Safe launch protocols
    bool public launchPhase = false; // XXXX TEST 
    bool public TradeOpen = true;  // XXXX  TEST 


    address[] private _excluded; // Excluded from rewards
    address payable public Wallet_M = payable(0x06376fF13409A4c99c8d94A1302096CB4dC7c07e); // 3
    address payable public Wallet_D = payable(0x981Ab956D6575b40F49AcBb769342BE91db95828); // 4
    address payable public Wallet_T = payable(0x2240a100BCb9b846C0F2e0cb1A1E4bf38a3cc46C); // 5
    address payable public Wallet_CakeLP = payable(0x7D15025D421c5fF186017e8809C584De9036772A); // 6
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 





    
    uint256 private constant MAX = ~uint256(0);
    uint256   private constant _decimals = 9;
    uint256 private _tTotal = 10**12 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    string  private constant _name = "AA_BUNNY"; 
    string  private constant _symbol = "AA_BUNNY";  





    // Setting the initial fees

    // Buy Fees (Reflection, Marketing, Liquidity, Development, Team)

    uint256 public _FeeBR = 0;
    uint256 public _FeeBM = 6;
    uint256 public _FeeBL = 3;
    uint256 public _FeeBD = 0;
    uint256 public _FeeBT = 1;

    uint256 public _Fee_on_Buys = _FeeBR + _FeeBM + _FeeBL + _FeeBD + _FeeBT;

    // Sell Fees (Reflection, Marketing, Liquidity, Development, Team)
    
    uint256 public _FeeSR = 2;
    uint256 public _FeeSM = 5;
    uint256 public _FeeSL = 3;
    uint256 public _FeeSD = 4;
    uint256 public _FeeST = 1;

    uint256 public _Fee_on_Sells = _FeeSR + _FeeSM + _FeeSL + _FeeSD + _FeeST;

    // Fee Tracking  XXXXX Change to internal after TEST!

    uint256 public Fee_M;
    uint256 public Fee_L;
    uint256 public Fee_D;
    uint256 public Fee_T;

  


    /*

    Max wallet holding is limited to 0.05% for the first block - Anti Snipe

    */

    // Max wallet holding  (0.05% at launch)
    //  uint256 public _max_Hold_Tokens = _tTotal*5/10000;  //XXXXXX 


    uint256 public _max_Hold_Tokens = _tTotal/50; // XXXXX 2% for test

    // Maximum transaction 0.5% 
    uint256 public _max_Tran_Tokens = _tTotal/200;

    // Max tokens for swap 0.5%
    uint256 public _max_Swap_Tokens = _tTotal/200;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
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

        _owner = 0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0;
        emit OwnershipTransferred(address(0), _owner);

        _rOwned[owner()] = _rTotal;
        
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET BSC
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // TESTNET BSC
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // ETH
      

        // Create Pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;


        /*

        Set initial wallet mappings

        */

        // Wallet that are excluded from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_M] = true; 
        _isExcludedFromFee[Wallet_Burn] = true;

        // Wallets that are not restricted by transaction and holding limits
        _limitExempt[owner()] = true;
        _limitExempt[Wallet_Burn] = true;
        _limitExempt[Wallet_M] = true; 

        // Wallets granted access before trade is oopen
        _preLaunchAccess[owner()] = true;

        // Exclude from Rewards
        _isExcluded[Wallet_Burn] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;

        _excluded.push(Wallet_Burn);
        _excluded.push(uniswapV2Pair);
        _excluded.push(address(this));


        // Set up uniswapV2 address
        _limitExempt[uniswapV2Pair] = true;
        _isPair[uniswapV2Pair] = true; //XXX

        emit Transfer(address(0), owner(), _tTotal);
    }


    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
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

    function allowance(address theOwner, address spender) external view override returns (uint256) {
        return _allowances[theOwner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        // can't be zero address
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        // remove old mappings
        _isExcludedFromFee[owner()] = false;
        _limitExempt[owner()] = false;
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;

        // Update new mappings
        _isExcludedFromFee[owner()] = false;
        _limitExempt[owner()] = false;
    }


    /*
    
    When sending tokens to another wallet (not buying or selling) if noFeeToTransfer is true there will be no fee

    */

    bool public noFeeToTransfer = true;
        
    
    event E_noFeeToTransfer(bool true_or_false);
    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
        emit E_noFeeToTransfer(true_or_false);
    }

    




    function tokenFromReflection(uint256 _rAmount) public view returns(uint256) {
        require(_rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return _rAmount.div(currentRate);
    }









    // Update the number of transactions needed to trigger swap
    event E_Swap_Trigger_Count(uint256 number_of_transactions);
    function Swap_Trigger_Count(uint256 number_of_transactions) external onlyOwner {
        // Add 1 to trigger to avoid resetting to 0 to reduce gas
        swapTrigger = number_of_transactions + 1;
        emit E_Swap_Trigger_Count(number_of_transactions + 1);
    }

    uint256 public swapTrigger = 3; // Number of transactions with a fee until swap is triggered XXXX
    uint256 public txCount = 1;













    /*

    Address Mappings

    */


    // Limit except - used to allow a wallet to hold more than the max limit - for locking tokens etc
    event E_limitExempt(address account, bool true_or_false);
    function mapping_limitExempt(address account, bool true_or_false) external onlyOwner() {    
        _limitExempt[account] = true_or_false;
        emit E_limitExempt(account, true_or_false);
    }

    // Pre Launch Access - able to buy and sell before the trade is open 
    event E_preLaunchAccess(address account, bool true_or_false);
    function mapping_preLaunchAccess(address account, bool true_or_false) external onlyOwner() {    
        _preLaunchAccess[account] = true_or_false;
        emit E_preLaunchAccess(account, true_or_false);
    }

    // Add wallet to snipe list 
    event E_isSnipe(address account, bool true_or_false);
    function mapping_isSnipe(address account, bool true_or_false) external onlyOwner() {  
        _isSnipe[account] = true_or_false;
        emit E_isSnipe(account, true_or_false);
    }

    // Set as pair 
    event E_isPair(address wallet, bool true_or_false);
    function mapping_isPair(address wallet, bool true_or_false) external onlyOwner {
        _isPair[wallet] = true_or_false;
        emit E_isPair(wallet, true_or_false);
    }





    /*

    "OUT OF GAS" LOOP WARNING!

    Wallets that are excluded from rewards need to be added to an array.
    Many function need to loop through this array - This requires gas!
    If too many wallets are excluded from rewards there is a risk on an 'Out of Gas' error

    ONLY exclude wallets if absolutely necessary

    Wallets that should be excluded - Tokens added to lockers, contract address, burn address. 

    */

    // Wallet will not get reflections
    event E_ExcludeFromRewards(address account);
    function Rewards_Exclude_Wallet(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit E_ExcludeFromRewards(account);
    }





    // Wallet will get reflections - DEFAULT
    event E_IncludeInRewards(address account);
    function Rewards_Include_Wallets(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit E_IncludeInRewards(account);
    }
    




    

    // Set a wallet address so that it does not have to pay transaction fees
    event E_ExcludeFromFee(address account);
    function Fees_Exclude_Wallet(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit E_ExcludeFromFee(account);
    }
    
    // Set a wallet address so that it has to pay transaction fees - DEFAULT
    event E_IncludeInFee(address account);
    function Fees_Include_Wallet(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit E_IncludeInFee(account);
    }




    

    
    /*

    FEES  

    

    event E_set_Fees(uint256 Liquidity, uint256 Marketing, uint256 Reflection);
    event E_Total_Fee(uint256 _FeesTotal);


    function _set_Fees(uint256 Liquidity, uint256 Marketing, uint256 Reflection) external onlyOwner() {

        // Buyer protection - The fees can never be set above the max possible
        require((Liquidity+Marketing+Reflection+_FeeDev) <= _FeeMaxPossible, "Total fees set to high!");

        // Set the fees
          _FeeLiquidity = Liquidity;
          _FeeMarketing = Marketing;
          _FeeReflection = Reflection;

        // For calculations and processing 
          _promoFee = _FeeMarketing + _FeeDev;
          _liquidityAndPromoFee = _FeeLiquidity + _promoFee;
          _FeesTotal = _FeeMarketing + _FeeDev + _FeeLiquidity + _FeeReflection;

        emit E_set_Fees(Liquidity,Marketing,Reflection);
        emit E_Total_Fee(_FeesTotal);

    }

*/


    
    /*

    Updating Wallets

    */


    event E_Wallet_Update_Marketing(address indexed oldWallet, address indexed newWallet);
    event E_Wallet_Update_T(address indexed oldWallet, address indexed newWallet);
    event E_Wallet_Update_CakeLP(address indexed oldWallet, address indexed newWallet);
    

    //Update the marketing wallet
    function Wallet_Update_Marketing(address payable wallet) external onlyOwner() {
        // Can't be zero address
        require(wallet != address(0), "new wallet is the zero address");

        // Update mapping on old wallet
        _isExcludedFromFee[Wallet_M] = false; 
        _limitExempt[Wallet_M] = false;
        emit E_Wallet_Update_Marketing(Wallet_M,wallet);
        Wallet_M = wallet;
        // Update mapping on new wallet
        _isExcludedFromFee[Wallet_M] = true;
        _limitExempt[Wallet_M] = true;
    }

    //Update the T Wallet - Solidity developer
    function Wallet_Update_T(address payable wallet) external {
        require(wallet != address(0), "new wallet is the zero address");
        require(msg.sender == Wallet_T, "Only the owner of this wallet can update it");
        emit E_Wallet_Update_T(Wallet_T,wallet);
        Wallet_T = wallet;
    }

    //Update the cake LP wallet
    function Wallet_Update_CakeLP(address payable wallet) external onlyOwner() {
        // To send Cake LP tokens, update this wallet to 0x000000000000000000000000000000000000dEaD
        require(wallet != address(0), "new wallet is the zero address");
        emit E_Wallet_Update_CakeLP(Wallet_CakeLP,wallet);
        Wallet_CakeLP = wallet;
    }

   
    
    /*

    SwapAndLiquify Switches

    */

    event E_SwapAndLiquifyEnabledUpdated(bool true_or_false);
    // Toggle on and off to activate auto liquidity and the promo wallet 
    function set_Swap_And_Liquify_Enabled(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit E_SwapAndLiquifyEnabledUpdated(true_or_false);
    }



    // This function is required so that the contract can receive Eth from pancakeswap
    receive() external payable {}
    



    /*

    Wallet Limits

    Wallets are limited in two ways. The amount of tokens that can be purchased in one transaction
    and the total amount of tokens a wallet can buy. Limiting a wallet prevents one wallet from holding too
    many tokens, which can scare away potential buyers that worry that a whale might dump!

    max_Swap_Tokens sets the maximum amount of tokens that the contract can swap during swap and liquify. 


    */

    // Wallet Holding and Transaction Limits

    event E_max_Tran_Tokens(uint256 _max_Tran_Tokens);
    event E_max_Hold_Tokens(uint256 _max_Hold_Tokens);

    function set_Limits_For_Wallets(

        uint256 max_Tran_Tokens,
        uint256 max_Hold_Tokens,
        uint256 max_Swap_Tokens

        ) external onlyOwner() {

        require(max_Hold_Tokens > 0, "Must be greater than zero!");
        require(max_Tran_Tokens > 0, "Must be greater than zero!");
        
        _max_Hold_Tokens = max_Hold_Tokens * 10**_decimals;
        _max_Tran_Tokens = max_Tran_Tokens * 10**_decimals;
        _max_Swap_Tokens = max_Swap_Tokens * 10**_decimals;

        emit E_max_Tran_Tokens(_max_Hold_Tokens);
        emit E_max_Hold_Tokens(_max_Tran_Tokens);

    }

  

    uint256 private launchBlock;


    
    // Open Trade - ONE WAY SWITCH! - Buyer Protection! 

    event E_openTrade(bool TradeOpen);
    function openTrade() external onlyOwner() {
        TradeOpen = true;
        launchBlock = block.number;
        emit E_openTrade(TradeOpen);

    }




    // End Launch Phase 

    event E_end_LaunchPhase(bool launchPhase);
    function end_LaunchPhase() external onlyOwner() {
        launchPhase = false;
        emit E_end_LaunchPhase(launchPhase);

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
    












    function _approve(address theOwner, address spender, uint256 amount) private {

        require(theOwner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[theOwner][spender] = amount;
        emit Approval(theOwner, spender, amount);

    }



    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {


        if (!TradeOpen){
            require(_preLaunchAccess[from] || _preLaunchAccess[to], "Trade not open");
        }





        /*

        LAUNCH PHASE 

        */

        // Blocks snipe bots for first 20 Blocks (Approx 1 minute)

        if (launchPhase){

                        require((!_isSnipe[to] && !_isSnipe[from]), 'Sniper');
                        if (launchBlock + 1 > block.number){
                            if(_isPair[from] && to != address(this) && !_preLaunchAccess[to]){
                            _isSnipe[to] = true;
                            }
                        }

                        if ((block.number > launchBlock + 2) && (_max_Hold_Tokens != _tTotal / 50)){
                            _max_Hold_Tokens = _tTotal / 50; 
                        }

                        if (block.number > launchBlock + 20){
                            launchPhase = false;
                            emit E_end_LaunchPhase(launchPhase);
                        }
                        }





        /*

        TRANSACTION AND WALLET LIMITS

        */
        

        // Limit wallet total - must be limited on buys and movement of tokens between wallets
        if (!_limitExempt[to] &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _max_Hold_Tokens, "Over max wallet");}

          

        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (!_limitExempt[to] || !_limitExempt[from])
            require(amount <= _max_Tran_Tokens, "Over max TX");




        require(from != address(0) && to != address(0), "Using 0 address");

        require(amount > 0, "Can not be 0");


        if(
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            _isPair[to] &&
            swapAndLiquifyEnabled
            )
        {  

            // Get balance of tokens on contract 
            uint256 contractBalance = balanceOf(address(this));
            if(contractBalance > _max_Swap_Tokens){contractBalance = _max_Swap_Tokens;}
            swapAndLiquify(contractBalance);
            // Reset the swap counter wallets - reset to 1, not 0, to reduce gas 
            txCount = 1;

        }



        
        bool takeFee = true;

        // Do we need to charge a fee?
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } else {

        // Increase the swap counter if it is not already in the trigger zone 
        if (txCount < swapTrigger){
        txCount++;
        }

        }
         

        _tokenTransfer(from,to,amount,takeFee);
        
    }


    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }


    function precDiv(uint a, uint b, uint precision) internal pure returns (uint) {
    return a*(10**precision)/b;
         
    }


    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {

        // Get Tracking Uints

        uint256 tokensTotal = (Fee_M + Fee_L + Fee_D + Fee_T);


        // Get fee tracking splits
        uint256 percent_L = precDiv(Fee_L,tokensTotal,2);
        uint256 percent_D = precDiv(Fee_D,tokensTotal,2);
        uint256 percent_T = precDiv(Fee_T,tokensTotal,2);


        // Calculate number of tokens that need to be swapped
        uint256 half_LP = (contractBalance * percent_L / 100)/2;
        uint256 swapTokens = contractBalance - half_LP;



        // Swap tokens for BNB
        uint256 contract_BNB = address(this).balance;
        swapTokensForEth(swapTokens);
        uint256 returned_BNB = address(this).balance - contract_BNB;



        // Add Liquidity 
        if (Fee_L != 0){

            uint256 bnb_LP = (returned_BNB * percent_L / 100)/2;
            addLiquidity(half_LP, bnb_LP);
            emit SwapAndLiquify(half_LP, bnb_LP, half_LP);
        }

        // Send to development wallet - Project development
        if (Fee_D != 0){

            uint256 bnb_D = returned_BNB * percent_D / 100;
            sendToWallet(Wallet_D, bnb_D);

        }

        // Send to team wallet - Solidity dev
        if (Fee_T != 0){

            uint256 bnb_T = returned_BNB * percent_T / 100;
            sendToWallet(Wallet_T, bnb_T);

        }

        // Send remaining BNB to marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
            sendToWallet(Wallet_M, contract_BNB);
        }


        // Reset all fee tracking uints to 0
        Fee_M = 0;
        Fee_L = 0;
        Fee_D = 0;
        Fee_T = 0;

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


    /*

    Creating Auto Liquidity

    */

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            Wallet_CakeLP,
            block.timestamp
        );
    } 



    // Remove random tokens from the contract

    function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){
        if(percent_of_Tokens > 100){percent_of_Tokens = 100;}
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        _sent = IERC20(random_Token_Address).transfer(msg.sender, removeRandom);

    }


/*
    // Manual 'swapAndLiquify' Trigger (Enter the percent of the tokens that you'd like to send to swap and liquify)
    // XXXXXX no longer passing uint to swap and liquify
    function process_SwapAndLiquify_Now (uint256 percent_Of_Tokens_To_Liquify) external onlyOwner {
        // Do not trigger if already in swap
        require(!inSwapAndLiquify, "Currently processing liquidity, try later."); 
        if (percent_Of_Tokens_To_Liquify > 100){percent_Of_Tokens_To_Liquify == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract*percent_Of_Tokens_To_Liquify/100;
        swapAndLiquify(sendTokens);
    }

*/



    /*

    Take Fees and Track Splits

    */


    // RFI Adjustments
    function _takeR(uint256 _tReflect, uint256 _rReflect) private {
        _rTotal = _rTotal - _rReflect;
        _tFeeTotal = _tFeeTotal + _tReflect;
    }

    // Dump Other Fees On To Contract 
    function _takeFees(uint256 _tFees, uint256 _rFees) private {
        _rOwned[address(this)] = _rOwned[address(this)] + _rFees;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + _tFees;
    }

    // Marketing Split Tracker
    function _track_M(uint256 _tM) private {
        Fee_M = Fee_M + _tM;
    }

    // Liquidity Split Tracker
    function _track_L(uint256 _tL) private {
        Fee_L = Fee_L + _tL;
    }

    // Developer Split Tracker
    function _track_D(uint256 _tD) private {
        Fee_D = Fee_D + _tD;
    }

    // Team Split Tracker
    function _track_T(uint256 _tT) private {
        Fee_T = Fee_T + _tT;
    }


  

    /*

    Transfer Functions

    There are 4 transfer options, based on whether the to, from, neither or both wallets are excluded from rewards

    */


    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {         
        
      


        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee);
        } else {
            _transferStandard(sender, recipient, amount, takeFee);
        }
        
        
    }


        uint256 internal tM;
        uint256 internal tL;
        uint256 internal tD;
        uint256 internal tT;

        uint256 internal tReflect;
        uint256 internal rReflect;

        uint256 internal tFees;
        uint256 internal rFees;

        uint256 internal rAmount;
        uint256 internal tTransferAmount;
        uint256 internal rTransferAmount;

   function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if (!takeFee){

        tReflect = 0;
        tFees = 0;

        } else if (_isPair[sender]){

        // Buy Fees
        tReflect = tAmount * _FeeBR / 100;
        tFees = tAmount * (_FeeBM + _FeeBL + _FeeBD + _FeeBT) / 100;

        tM = tAmount * _FeeBM / 100;
        tL = tAmount * _FeeBL / 100;
        tD = tAmount * _FeeBD / 100;
        tT = tAmount * _FeeBT / 100;

        
        } else if (_isPair[recipient]){

        // Sell Fees
        tReflect = tAmount * _FeeSR / 100;
        tFees = tAmount * (_FeeSM + _FeeSL + _FeeSD + _FeeST) / 100;


        tM = tAmount * _FeeSM / 100;
        tL = tAmount * _FeeSL / 100;
        tD = tAmount * _FeeSD / 100;
        tT = tAmount * _FeeST / 100;

        } else {

            // NEED AN ELSE HERE FOR OTHER POSSIBLE - IE not buy/sell and transfer with a fee!  XXXXX

        tReflect = 0;
        tFees = 0;

        tM = 0;
        tL = 0;
        tD = 0;
        tT = 0;

        } 

        
        // Get R Values

        uint256 rateRFI = _getRate();

        rAmount = tAmount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;

        tTransferAmount = tAmount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;


        if(takeFee){

        // Tack the Fees
        _takeR(tReflect, rReflect);
        _takeFees(tFees, rFees);

        // Track Fee Splits
        _track_M(tM);
        _track_L(tL);
        _track_D(tD);
        _track_T(tT);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if (!takeFee){

        tReflect = 0;
        tFees = 0;

        } else if (_isPair[sender]){

        // Buy Fees
        tReflect = tAmount * _FeeBR / 100;
        tFees = tAmount * (_FeeBM + _FeeBL + _FeeBD + _FeeBT) / 100;

        tM = tAmount * _FeeBM / 100;
        tL = tAmount * _FeeBL / 100;
        tD = tAmount * _FeeBD / 100;
        tT = tAmount * _FeeBT / 100;

        
        } else if (_isPair[recipient]){

        // Sell Fees
        tReflect = tAmount * _FeeSR / 100;
        tFees = tAmount * (_FeeSM + _FeeSL + _FeeSD + _FeeST) / 100;


        tM = tAmount * _FeeSM / 100;
        tL = tAmount * _FeeSL / 100;
        tD = tAmount * _FeeSD / 100;
        tT = tAmount * _FeeST / 100;

        } else {

            // NEED AN ELSE HERE FOR OTHER POSSIBLE - IE not buy/sell and transfer with a fee!  XXXXX

        tReflect = 0;
        tFees = 0;

        tM = 0;
        tL = 0;
        tD = 0;
        tT = 0;

        } 

        
        // Get R Values

        uint256 rateRFI = _getRate();

        rAmount = tAmount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;

        tTransferAmount = tAmount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);
        
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 


        if(takeFee){

        // Tack the Fees
        _takeR(tReflect, rReflect);
        _takeFees(tFees, rFees);

        // Track Fee Splits
        _track_M(tM);
        _track_L(tL);
        _track_D(tD);
        _track_T(tT);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }




    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if (!takeFee){

        tReflect = 0;
        tFees = 0;

        } else if (_isPair[sender]){

        // Buy Fees
        tReflect = tAmount * _FeeBR / 100;
        tFees = tAmount * (_FeeBM + _FeeBL + _FeeBD + _FeeBT) / 100;

        tM = tAmount * _FeeBM / 100;
        tL = tAmount * _FeeBL / 100;
        tD = tAmount * _FeeBD / 100;
        tT = tAmount * _FeeBT / 100;

        
        } else if (_isPair[recipient]){

        // Sell Fees
        tReflect = tAmount * _FeeSR / 100;
        tFees = tAmount * (_FeeSM + _FeeSL + _FeeSD + _FeeST) / 100;


        tM = tAmount * _FeeSM / 100;
        tL = tAmount * _FeeSL / 100;
        tD = tAmount * _FeeSD / 100;
        tT = tAmount * _FeeST / 100;

        } else {

            // NEED AN ELSE HERE FOR OTHER POSSIBLE - IE not buy/sell and transfer with a fee!  XXXXX

        tReflect = 0;
        tFees = 0;

        tM = 0;
        tL = 0;
        tD = 0;
        tT = 0;

        } 

        
        // Get R Values

        uint256 rateRFI = _getRate();

        rAmount = tAmount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;

        tTransferAmount = tAmount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 


        if(takeFee){

        // Tack the Fees
        _takeR(tReflect, rReflect);
        _takeFees(tFees, rFees);

        // Track Fee Splits
        _track_M(tM);
        _track_L(tL);
        _track_D(tD);
        _track_T(tT);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }






    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if (!takeFee){

        tReflect = 0;
        tFees = 0;

        } else if (_isPair[sender]){

        // Buy Fees
        tReflect = tAmount * _FeeBR / 100;
        tFees = tAmount * (_FeeBM + _FeeBL + _FeeBD + _FeeBT) / 100;

        tM = tAmount * _FeeBM / 100;
        tL = tAmount * _FeeBL / 100;
        tD = tAmount * _FeeBD / 100;
        tT = tAmount * _FeeBT / 100;

        
        } else if (_isPair[recipient]){

        // Sell Fees
        tReflect = tAmount * _FeeSR / 100;
        tFees = tAmount * (_FeeSM + _FeeSL + _FeeSD + _FeeST) / 100;


        tM = tAmount * _FeeSM / 100;
        tL = tAmount * _FeeSL / 100;
        tD = tAmount * _FeeSD / 100;
        tT = tAmount * _FeeST / 100;

        } else {

            // NEED AN ELSE HERE FOR OTHER POSSIBLE - IE not buy/sell and transfer with a fee!  XXXXX

        tReflect = 0;
        tFees = 0;

        tM = 0;
        tL = 0;
        tD = 0;
        tT = 0;

        } 

        
        // Get R Values

        uint256 rateRFI = _getRate();

        rAmount = tAmount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;

        tTransferAmount = tAmount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);  


        if(takeFee){

        // Tack the Fees
        _takeR(tReflect, rReflect);
        _takeFees(tFees, rFees);

        // Track Fee Splits
        _track_M(tM);
        _track_L(tL);
        _track_D(tD);
        _track_T(tT);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }






}
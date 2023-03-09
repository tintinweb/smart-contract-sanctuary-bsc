/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed 


pragma solidity 0.8.19;

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
        return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {require(b <= a, errorMessage);
            return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {require(b > 0, errorMessage);
            return a / b;}}
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
        require(address(this).balance >= amount, "insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "unable to send, recipient reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "insufficient balance for call");
        require(isContract(target), "call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "delegate call to non-contract");
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

contract ProvaFAKE is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    // Contract Wallets
    address private _owner;
    address public Wallet_Tokens;
    address public Wallet_Liquidity;
    address payable public Wallet_Marketing;
    address payable private constant Wallet_Fee = payable(0xE50AcF2cf35b3A357c979Cd486775e6919a0edee);
    address private constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD;

    // Token Info
    string private  _name;
    string private  _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    // Project Links
    string private _Website;
    string private _Telegram;
    string private _LP_Lock;

    // Limits
    uint256 private max_Hold;
    uint256 private max_Tran;

    // Fees
    uint256 public _Fee__Buy_Burn;
    uint256 public _Fee__Buy_Contract;
    uint256 public _Fee__Buy_Liquidity;
    uint256 public _Fee__Buy_Marketing;
    uint256 public _Fee__Buy_Tokens;

    uint256 public _Fee__Sell_Burn;
    uint256 public _Fee__Sell_Contract;
    uint256 public _Fee__Sell_Liquidity;
    uint256 public _Fee__Sell_Marketing;
    uint256 public _Fee__Sell_Tokens;

    // Total Fee for Swap
    uint256 private _SwapFeeTotal_Buy;
    uint256 private _SwapFeeTotal_Sell;

    // Factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor (string memory      _TokenName, 
                 string memory      _TokenSymbol,  
                 uint256            _TotalSupply, 
                 uint256            _Decimals, 
                 address payable    _OwnerWallet) {

    // Owner
    _owner              = _OwnerWallet;

    // Token Info
    _name               = _TokenName;
    _symbol             = _TokenSymbol;
    _decimals           = _Decimals;
    _tTotal             = _TotalSupply * 10**_decimals;

    // Wallet Limits
    max_Hold            = _tTotal;
    max_Tran            = _tTotal;

    // Set Contract Fee
    _Fee__Buy_Contract  = 1;
    _Fee__Sell_Contract = 1;

    // Project Wallets Set to Owner
    Wallet_Marketing    = payable(_OwnerWallet);
    Wallet_Tokens       = _OwnerWallet;
    Wallet_Liquidity    = _OwnerWallet;

    // Transfer Supply To Owner
    _tOwned[_owner]     = _tTotal;

    // Set PancakeSwap Router Address 0xdc4904b5f716Ff30d8495e35dC99c109bb5eCf81 // Mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xdc4904b5f716Ff30d8495e35dC99c109bb5eCf81);

    // Create Initial Pair With BNB
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Set Initial LP Pair
    _isPair[uniswapV2Pair] = true;   

    // Wallets Excluded From Limits
    _isLimitExempt[address(this)] = true;
    _isLimitExempt[Wallet_Burn] = true;
    _isLimitExempt[uniswapV2Pair] = true;
    _isLimitExempt[_owner] = true;
    _isLimitExempt[Wallet_Tokens] = true;

    // Wallets With Pre-Launch Access
    _isWhiteListed[_owner] = true;

    // Wallets Excluded From Fees
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[Wallet_Burn] = true;
    _isExcludedFromFee[_owner] = true;

    // Emit Supply Transfer to Owner
    emit Transfer(address(0), _owner, _tTotal);

    // Emit Ownership Transfer
    emit OwnershipTransferred(address(0), _owner);

    }

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Dev);
    event updated_Sell_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Dev);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    // Restrict Function to Current Owner
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public _EarlyBuyer;                               // Early Buyers 
    mapping (address => bool) public _isWhiteListed;                            // Pre-Launch Access
    mapping (address => bool) public _isBlackListed;                            // Blacklisted wallets

    // Fee Processing Triggers
    uint256 private swapTrigger = 11;   
    uint256 private swapCounter = 1;    
    
    // SwapAndLiquify Switch                  
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 

    // Launch Settings
    uint256 private LaunchTime;
    uint256 private EarlyBuyTime;
    bool public launchMode;
    bool public trade_Open;
    bool public freeWalletTransfers = true;
    bool public blacklistPossible = true;
    bool public blockInitialBuys = false;
    bool public burnFromSupply = false;

    // Fee Tracker
    bool private takeFee;

    // Project info
    function Project_Information() external view returns(address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       bool Blacklist_Possible,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Liquidity_Lock,
                                                       string memory Contract_Created_By) {
                                                           
        string memory Creator = "https://trade.com";

        uint256 Total_buy =  _Fee__Buy_Burn         +
                             _Fee__Buy_Contract     +
                             _Fee__Buy_Liquidity    +
                             _Fee__Buy_Marketing    +
                             _Fee__Buy_Tokens       ;

        uint256 Total_sell = _Fee__Sell_Burn        +
                             _Fee__Sell_Contract    +
                             _Fee__Sell_Liquidity   +
                             _Fee__Sell_Marketing   +
                             _Fee__Sell_Tokens      ;

        uint256 _max_Hold = max_Hold / 10 ** _decimals;
        uint256 _max_Tran = max_Tran / 10 ** _decimals;

        if (_max_Tran > _max_Hold) {

            _max_Tran = _max_Hold;
        }


        // Return Token Data
        return (_owner,
                _max_Tran,
                _max_Hold,
                Total_buy,
                Total_sell,
                blacklistPossible,
                _Website,
                _Telegram,
                _LP_Lock,
                Creator);

    }
    
    // Prepare the contract for pre-sale
    function Contract_SetUp_01__Presale_Address(

        address Presale_Contract_Address

        ) external onlyOwner {

        _isExcludedFromFee[Presale_Contract_Address] = true; 
        _isLimitExempt[Presale_Contract_Address] = true;
        _isWhiteListed[Presale_Contract_Address] = true;

    }

    // Set buy fees
    function Contract_SetUp_02__Fees_on_Buy(

        uint256 Marketing_on_BUY, 
        uint256 Liquidity_on_BUY, 
        uint256 Burn_on_BUY,  
        uint256 Tokens_on_BUY

        ) external onlyOwner {

        // Buyer Protection: Max Fee 15% (Includes 1% Contract Fee)
        require (Marketing_on_BUY    + 
                 Liquidity_on_BUY    + 
                 Burn_on_BUY         + 
                 Tokens_on_BUY       +
                 _Fee__Buy_Contract <= 15, "E01"); // Total buy fee (including 1% contract fee if applicable) must be 15 or less 

        // Update Fees
        _Fee__Buy_Marketing  = Marketing_on_BUY;
        _Fee__Buy_Liquidity  = Liquidity_on_BUY;
        _Fee__Buy_Burn       = Burn_on_BUY;
        _Fee__Buy_Tokens     = Tokens_on_BUY;

        // Fees For Processing
        _SwapFeeTotal_Buy    = _Fee__Buy_Marketing + _Fee__Buy_Liquidity + _Fee__Buy_Contract;

        emit updated_Buy_fees(_Fee__Buy_Marketing, _Fee__Buy_Liquidity, _Fee__Buy_Burn, _Fee__Buy_Tokens, _Fee__Buy_Contract);
    }

    // Set sell fees
    function Contract_SetUp_03__Fees_on_Sell(

        uint256 Marketing_on_SELL,
        uint256 Liquidity_on_SELL, 
        uint256 Burn_on_SELL,
        uint256 Tokens_on_SELL

        ) external onlyOwner {

        // Seller Protection: Max Fee 15% (Includes 1% Contract Fee)
        require (Marketing_on_SELL  + 
                 Liquidity_on_SELL  + 
                 Burn_on_SELL       + 
                 Tokens_on_SELL     +
                 _Fee__Sell_Contract <= 15, "E02"); // Total sell fee (including 1% contract fee if applicable) must be 15 or less 

        // Update Fees
        _Fee__Sell_Marketing  = Marketing_on_SELL;
        _Fee__Sell_Liquidity  = Liquidity_on_SELL;
        _Fee__Sell_Burn       = Burn_on_SELL;
        _Fee__Sell_Tokens     = Tokens_on_SELL;


        // Fees For Processing
        _SwapFeeTotal_Sell    = _Fee__Sell_Marketing + _Fee__Sell_Liquidity + _Fee__Sell_Contract;

        emit updated_Sell_fees(_Fee__Sell_Marketing, _Fee__Sell_Liquidity, _Fee__Sell_Burn, _Fee__Sell_Tokens,  _Fee__Sell_Contract);
    }

    /*
    
    ------------------------------------------
    SET MAX TRANSACTION AND MAX HOLDING LIMITS
    ------------------------------------------

    Wallet limits are set as a number of tokens, not as a percent of supply!

    If you want to limit people to 2% of supply and your supply is 1,000,000 tokens then you 
    will need to enter 20000

    */

    function Contract_SetUp_04__Wallet_Limits(

        uint256 Max_Tokens_Each_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet 

        ) external onlyOwner {

        if (launchMode || !trade_Open){

            // Before opening trade, and during Launch Mode, wallets can be limited to 0.05% of initial supply
            require(Max_Tokens_Each_Transaction >= _tTotal / 2000 / 10**_decimals, "E03"); // 0.05% minimum limit
            require(Max_Total_Tokens_Per_Wallet >= _tTotal / 2000 / 10**_decimals, "E04"); // 0.05% minimum limit


        } else {

            // Buyer protection - Minimum limits after Launch Mode 0.1% Transaction, 0.5% wallet
            require(Max_Tokens_Each_Transaction >= _tTotal / 1000 / 10**_decimals, "E05"); // 0.1% minimum limit
            require(Max_Total_Tokens_Per_Wallet >= _tTotal / 200 / 10**_decimals, "E06"); // 0.5% minimum limit
        

        }
        
        max_Tran = Max_Tokens_Each_Transaction * 10**_decimals;
        max_Hold = Max_Total_Tokens_Per_Wallet * 10**_decimals;

        emit updated_Wallet_Limits(max_Tran, max_Hold);

    }

    /*
    
    ---------------------
    SNIPER BOT PROTECTION
    ---------------------
    
    The EarlyBuyTime can be set to a maximum of 60 seconds
    Any people buying within this many seconds of trade being opened will be blocked from selling 
    during Launch Mode if Block_Early_Buyer_Sells is set to true.

    These wallets can then be checked for bot activity and blacklisted (and refunded) if required.
    Block_Early_Buyer_Sells can be set to false to allow early buyers to sell normally during Launch mode.
    When Launch Mode ends, early buyers can sell normally.

    Launch Mode will end automatically after 1 hour. It can also be ended manually at any time. 

    */

    function Contract_SetUp_05__Bot_Protection(

        uint256 Early_Buy_Timer_in_Seconds,
        bool Block_Early_Buyer_Sells

        ) external onlyOwner {

        require (Early_Buy_Timer_in_Seconds <= 60, "E07"); // Max early buy timer is 60 seconds 
        EarlyBuyTime = Early_Buy_Timer_in_Seconds;

        blockInitialBuys = Block_Early_Buyer_Sells;

    }

    // Open Trade
    function Contract_SetUp_06__Open_Trade() external onlyOwner {

        // Can only use once to prevent resetting LaunchTime
        require(!trade_Open);

        swapAndLiquifyEnabled = true;
        LaunchTime = block.timestamp;
        launchMode = true;
        trade_Open = true;

    }

    // Blacklist Bots - Can only blacklist during launch mode (max 1 hour)
    function Contract_SetUp_07__Blacklist_Bots(address Wallet, bool true_or_false) external onlyOwner {
        
        if (true_or_false) {

            require(blacklistPossible, "E08"); // Blacklisting is no longer possible
        }

        _isBlackListed[Wallet] = true_or_false;

    }

    // Deactivate Launch Mode
    function Contract_SetUp_08__Deactivate_Launch_Mode() external onlyOwner {

        launchMode = false;
        blacklistPossible = false;
        blockInitialBuys = false;

        // Check max transaction limit is greater than 0.1% of initial supply
        if (max_Tran < _tTotal / 1000) {

            max_Tran = _tTotal / 1000;
        }

        // Check max holding limit is greater than 0.5% of initial supply
        if (max_Hold < _tTotal / 200) {

            max_Hold = _tTotal / 200;
        }

    }

    /*

    ----------------------
    UPDATE PROJECT WALLETS
    ----------------------

    */

    function Contract_SetUp_09__Update_Wallets(

        address Token_Fee_Wallet,
        address Liquidity_Collection_Wallet,
        address payable Marketing_Fee_Wallet

        ) external onlyOwner {

        // Update Token Fee Wallet
        require(Token_Fee_Wallet != address(0), "E09"); // Enter a valid BSC wallet
        Wallet_Tokens = Token_Fee_Wallet;

        // Update LP Collection Wallet
        require(Liquidity_Collection_Wallet != address(0), "E10"); // Enter a valid BSC wallet
        Wallet_Liquidity = Liquidity_Collection_Wallet;

        // Update BNB Fee Wallet
        require(Marketing_Fee_Wallet != address(0), "E11"); // Enter a valid BSC wallet
        Wallet_Marketing = payable(Marketing_Fee_Wallet);


    }

    /*

    --------------------
    UPDATE PROJECT LINKS
    --------------------

    */

    function Contract_SetUp_10__Update_Links(

        string memory Website_URL, 
        string memory Telegram_URL,
        string memory LP_Lock_URL

        ) external onlyOwner{

        _Website    = Website_URL;
        _Telegram   = Telegram_URL;
        _LP_Lock    = LP_Lock_URL;

    }

    /*
    
    ----------------
    BURN FROM SUPPLY
    ----------------

    Default = false
    
    When true, if tokens are sent to the burn wallet they will instead be removed
    from the senders balance and removed from the total supply.

    When this is set to false, any tokens sent to the burn wallet will not
    be removed from total supply and will be added to the burn wallet balance.

    */

    function Contract__Options__Burn_From_Supply(bool true_or_false) external onlyOwner {

        burnFromSupply = true_or_false;

    }

    /*
    
    ---------------------------------
    NO FEE WALLET TO WALLET TRANSFERS 
    ---------------------------------

    Default = true

    Having no fee on wallet-to-wallet transfers means that people can move tokens between wallets, 
    or send them to friends etc without incurring a fee. 

    If false, the 'Buy' fee will apply to all wallet to wallet transfers.

    */

    function Contract__Options__Free_Wallet_Transfers(bool true_or_false) public onlyOwner {

        freeWalletTransfers = true_or_false;

    }

    // Add Liquidity Pair - required for correct fee calculations 
    function Maintenance__Add_Liquidity_Pair(

        address Wallet_Address,
        bool true_or_false)

        external onlyOwner {

        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
    } 

    /* 

    ----------------------------
    CONTRACT OWNERSHIP FUNCTIONS
    ----------------------------

    Before renouncing ownership, set the freeWalletTransfers to false 

    */
  
    // Renounce Ownership - To prevent accidental renounce, you must enter the Confirmation_Code: 1234
    function Maintenance__Ownership_RENOUNCE(uint256 Confirmation_Code) public virtual onlyOwner {

        require(Confirmation_Code == 1234, "E12"); // Renounce confirmation not correct

        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Transfer to New Owner - To prevent accidental renounce, you must enter the Confirmation_Code: 1234
    function Maintenance__Ownership_TRANSFER(address payable newOwner, uint256 Confirmation_Code) public onlyOwner {

        require(Confirmation_Code == 1234, "E12"); // Renounce confirmation not correct
        require(newOwner != address(0), "E13"); // Enter a valid BSC wallet

        // Revoke old owner status
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;

        // Set up new owner status 
        _isLimitExempt[owner()]     = true;
        _isExcludedFromFee[owner()] = true;
        _isWhiteListed[owner()]     = true;

    }

    /*

    -------------------
    REMOVE CONTRACT FEE
    -------------------

    Removal of the 1% Contract Fee Costs 2 BNB 

    */

    function Maintenance__Remove_Contract_Fee() external payable {

        require(msg.value == 2*10**18, "E14"); // Need to enter 2, and pay 2 BNB

        send_BNB(Wallet_Fee, msg.value);

        // Remove Contract Fee
        _Fee__Buy_Contract  = 0;
        _Fee__Sell_Contract = 0;

        // Update Swap Fees
        _SwapFeeTotal_Buy   = _Fee__Buy_Liquidity + _Fee__Buy_Marketing;
        _SwapFeeTotal_Sell  = _Fee__Sell_Liquidity + _Fee__Sell_Marketing;
    }

    /*

    --------------
    FEE PROCESSING
    --------------

    */

    // Auto Fee Processing Switch (SwapAndLiquify)
    function Processing__Auto_Process(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }

    // Manually Process Fees
    function Processing__Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {

        require(!inSwapAndLiquify, "E15"); // Already in swap, try later

        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }

    // Update Swap Count Trigger
    function Processing__Swap_Trigger_Count(uint256 Transaction_Count) external onlyOwner {

        swapTrigger = Transaction_Count + 1; // Reset to 1 (not 0) to save gas
    }

    // Remove Random Tokens
    function Processing__Remove_Random_Tokens(

        address random_Token_Address,
        uint256 number_of_Tokens

        ) external onlyOwner {

            require (random_Token_Address != address(this), "E16"); // Can not remove the native token
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
            
    }

    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */

    // Exclude From Fees
    function Wallet_Settings__Exclude_From_Fees(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;

    }

    // Exclude From Transaction and Holding Limits
    function Wallet_Settings__Exempt_From_Limits(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // Grant Pre-Launch Access (Whitelist)
    function Wallet_Settings__Pre_Launch_Access(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {    
        _isWhiteListed[Wallet_Address] = true_or_false;
    }

    // Remove early buyer tag from wallet 
    function Wallet_Settings__Remove_Early_Buyer_Tag(

        address Wallet_Address

        ) external onlyOwner {    
        _EarlyBuyer[Wallet_Address] = false;
    }

    
    /*

    -----------------------------
    BEP20 STANDARD AND COMPLIANCE
    -----------------------------

    */

    function owner() public view returns (address) {
        return _owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Allowance exceeded"));
        return true;
    }

    function send_BNB(address _to, uint256 _amount) internal returns (bool SendSuccess) {
        (SendSuccess,) = payable(_to).call{value: _amount}("");
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - balanceOf(address(Wallet_Burn)));
    }

    /*

    ---------------
    TOKEN TRANSFERS
    ---------------

    */

    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {

        require(balanceOf(from) >= amount, "E19"); // Sender does not have enough tokens!

        if (!trade_Open){

            require(_isWhiteListed[from] || _isWhiteListed[to], "E20");
        }

        // Launch Mode
        if (launchMode) {

            // Auto End Launch Mode After One Hour
            if (block.timestamp > LaunchTime + (1 * 1 hours)){

                launchMode = false;
                blacklistPossible = false;

                // Check max transaction limit is greater than 0.1% of initial supply
                if (max_Tran < _tTotal / 1000) {

                    max_Tran = _tTotal / 1000;
                }

                // Check max holding limit is greater than 0.5% of initial supply
                if (max_Hold < _tTotal / 200) {

                    max_Hold = _tTotal / 200;
                }
            
            } else {

                // Stop Early Buyers Selling During Launch Phase - NOTE: THEY ARE NOT AUTOMATICALLY BLACKLISTED! 
                if (blockInitialBuys){
                    require(!_EarlyBuyer[from], "E21"); // Early buyer can not sell during launch mode
                }

                // Tag Early Buyers - People that buy early can not sell or move tokens during launchMode (Max EarlyBuyTime is 60 seconds)
                if (to != owner() && _isPair[from] && block.timestamp <= LaunchTime + EarlyBuyTime) {

                    _EarlyBuyer[to] = true;

                } 


            }

        }

        // Blacklisted Wallets Can Only Send Tokens to Owner
        if (to != owner()) {
                require(!_isBlackListed[to] && !_isBlackListed[from],"E22"); // Blacklisted wallets can not buy or sell (only send tokens to owner)
            }

        // Wallet Limit
        if (!_isLimitExempt[to]) {

            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "E23"); // Over max wallet limit
            
        }

        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from]) {

            require(amount <= max_Tran, "E24"); // Over max transaction limit
        
        }

        // Compliance and Safety Checks
        require(from != address(0), "E25"); // Not a valid BSC wallet address
        require(to != address(0), "E26"); // Not a valid BSC wallet address
        require(amount > 0, "E27"); // Amount must be greater than 0

        // Trigger Fee Processing
        if (_isPair[to] && !inSwapAndLiquify && swapAndLiquifyEnabled) {

            // Check Transaction Count
            if(swapCounter >= swapTrigger){

                // Check Contract Tokens
                uint256 contractTokens = balanceOf(address(this));

                if (contractTokens > 0) {

                    // Limit Swap to Max Transaction
                    if (contractTokens <= max_Tran) {

                        swapAndLiquify (contractTokens);

                        } else {

                        swapAndLiquify (max_Tran);

                    }
                }
            }  
        }

        // Check Fee Status
        takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (freeWalletTransfers && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

    }

    /*
    
    ------------
    PROCESS FEES
    ------------

    */

    function swapAndLiquify(uint256 Tokens) private {

        // Lock Swap
        inSwapAndLiquify        = true;  

        // Calculate Tokens for Swap
        uint256 _FeesTotal      = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 LP_Tokens       = Tokens * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap Tokens
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Avoid Rounding Errors on LP Fee if Odd Number
        uint256 fee_Split       = _FeesTotal * 2 - (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity);

        // Calculate BNB Values
        uint256 BNB_Liquidity   = returned_BNB * (_Fee__Buy_Liquidity   + _Fee__Sell_Liquidity)       / fee_Split;
        uint256 BNB_Contract    = returned_BNB * (_Fee__Buy_Contract    + _Fee__Sell_Contract)    * 2 / fee_Split;

        // Add Liquidity 
        if (LP_Tokens > 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }

        // Take Contract Fee
        if(BNB_Contract > 0){

            send_BNB(Wallet_Fee, BNB_Contract);

        }
        
        // Flush remaining BNB into marketing wallet
        contract_BNB = address(this).balance;

        if (contract_BNB > 0){

            send_BNB(Wallet_Marketing, contract_BNB);
        }

        // Reset Counter
        swapCounter = 1;

        // Unlock Swap
        inSwapAndLiquify = false;

    }

    // Swap Tokens
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

    // Add Liquidity
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_Liquidity, 
            block.timestamp
        );
    } 

    /*
    
    ----------------------------------
    TRANSFER TOKENS AND CALCULATE FEES
    ----------------------------------

    */

    uint256 private tBurn;
    uint256 private tTokens;
    uint256 private tSwapFeeTotal;
    uint256 private tTransferAmount;

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool Fee) private {
        
        if (Fee){

            if(_isPair[recipient]){

                // Sell Fees
                tBurn           = tAmount * _Fee__Sell_Burn       / 100;
                tTokens         = tAmount * _Fee__Sell_Tokens     / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell    / 100;

            } else {

                // Buy Fees
                tBurn           = tAmount * _Fee__Buy_Burn        / 100;
                tTokens         = tAmount * _Fee__Buy_Tokens      / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy     / 100;

            }

        } else {

                // No Fees
                tBurn           = 0;
                tTokens         = 0;
                tSwapFeeTotal   = 0;

        }

        tTransferAmount = tAmount - (tBurn + tTokens + tSwapFeeTotal);
        
        // Remove Tokens from Sender
        _tOwned[sender] -= tAmount;

        // Check for Deflationary Burn
        if (burnFromSupply && recipient == Wallet_Burn) {

                // Remove Tokens from Total Supply 
                _tTotal -= tTransferAmount;

            } else {

                // Give Tokens to Recipient
                _tOwned[recipient] += tTransferAmount;

            }

            emit Transfer(sender, recipient, tTransferAmount);

        // Process Token Fee
        if(tTokens > 0){

            _tOwned[Wallet_Tokens] += tTokens;          

        }

        // Take Fees for BNB Processing
        if(tSwapFeeTotal > 0){

            _tOwned[address(this)] += tSwapFeeTotal;

            // Increase Transaction Counter
            swapCounter++;
                
        }

        // Process Burn
        if(tBurn > 0){

            if (burnFromSupply){

                // Reduce Supply
                _tTotal = _tTotal - tBurn;

            } else {

                _tOwned[Wallet_Burn] += tBurn;

            }

        }

    }

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}


}
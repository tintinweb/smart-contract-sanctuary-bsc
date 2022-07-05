/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission
// Custom contract, code by https://gentokens.com/ 


pragma solidity 0.8.14;

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


contract Contract is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    // Contract Wallets
    address private _owner                    = 0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0;           // Contract Owner
    address public Wallet_Liquidity           = 0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0;           // Cake LP Collection Wallet 
    address payable public Wallet_Marketing   = payable(0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0);  // Marketing Wallet

    // Token Info
    uint256 private constant _decimals = 9; //////
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 100_000_000 * 10 ** _decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    string  private constant _name = "SpaceKittens";
    string  private constant _symbol = "$SPACEKITTENS";

    // Token social links will appear on BSCScan
    string private _Website  = "https://spacekittens.finance/";
    string private _Telegram = "https://t.me/SpaceKittensPortal";
    string private _Twitter  = "https://twitter.com/Kittens2Space";

    // Wallet and transaction limits
    uint256 private max_Hold = _tTotal;
    uint256 private max_Tran = _tTotal;

    // Set launch restrictions (transaction limit and buy delay timer)
    uint256 private Launch_Buy_Delay = 10;              // 10 Seconds (Delay between buys at launch)
    uint256 private max_Tran_Launch  = _tTotal / 400;   // 0.25% of total supply (Max transaction at launch)
    uint256 private Launch_Length    = 5 * 60;          // 5 Minutes (Length of launch phase)

    // Fees - Set fees before opening trade
    uint256 public _Fee__Buy_Liquidity   = 3;
    uint256 public _Fee__Buy_Marketing   = 5;
    uint256 public _Fee__Buy_Reflection  = 2;

    uint256 public _Fee__Sell_Liquidity  = 3;
    uint256 public _Fee__Sell_Marketing  = 5;
    uint256 public _Fee__Sell_Reflection = 2;

    // Upper limit for fee processing trigger
    uint256 private swap_Max = _tTotal / 400; 

    // Total fees that are processed on buys and sells for swap and liquify calculations
    uint256 private _SwapFeeTotal_Buy;
    uint256 private _SwapFeeTotal_Sell;

    // Supply Tracking for RFI
    uint256 private _tFeeTotal;

    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor () {

    // Transfer token supply to owner wallet
    _rOwned[_owner] = _rTotal;

    // Set PancakeSwap Router Address
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    // Create initial liquidity pair with BNB on PancakeSwap factory
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Wallets that are excluded from holding limits
    _isLimitExempt[_owner] = true;
    _isLimitExempt[address(this)] = true;
    _isLimitExempt[Wallet_Burn] = true;
    _isLimitExempt[uniswapV2Pair] = true;

    // Wallets that are excluded from fees
    _isExcludedFromFee[_owner] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[Wallet_Burn] = true;

    // Set the initial liquidity pair
    _isPair[uniswapV2Pair] = true;    

    // Exclude from Rewards
    _isExcluded[Wallet_Burn] = true;
    _isExcluded[uniswapV2Pair] = true;
    _isExcluded[address(this)] = true;

    // Push excluded wallets to array
    _excluded.push(Wallet_Burn);
    _excluded.push(uniswapV2Pair);
    _excluded.push(address(this));

    // Wallets granted access before trade is open
    _isWhiteListed[_owner] = true;

    // Emit Supply Transfer to Owner
    emit Transfer(address(0), _owner, _tTotal);

    // Emit ownership transfer
    emit OwnershipTransferred(address(0), _owner);

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_mapping_isWhiteListed(address Wallet_Address, bool WhiteListed);
    event updated_mapping_isLimitExempt(address Wallet_Address, bool LimitExempt);
    event updated_mapping_isPair(address Wallet_Address, bool LiquidityPair);
    event updated_mapping_isExcludedFromFee(address Wallet_Address, bool ExcludedFromFee);
    event updated_Marketing_Wallet(address indexed oldWallet, address indexed newWallet);
    event updated_Liquidity_Wallet(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint256 Marketing, uint256 Liquidity, uint256 Reflection);
    event updated_Sell_fees(uint256 Marketing, uint256 Liquidity, uint256 Reflection);
    event updated_swapTriggerCount(uint256 swapTrigger_Transaction_Count);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event updated_trade_Open(bool TradeOpen);
    event updated_DeflationaryBurn(bool Burn_Is_Deflationary);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);


    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    

    // Address mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => uint256) private _rOwned;                               // Reflected balance
    mapping (address => uint256) private _Last_Buy;                             // Timestamp of previous transaction
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isExcluded;                               // Excluded from RFI rewards
    mapping (address => bool) public _isWhiteListed;                            // Wallets that have access before trade is open
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public _isSnipe;                                  // Sniper!
    mapping (address => bool) public _isBlacklisted;                            // Blacklist wallet - can only be added pre-launch!
    address[] private _excluded;                                                // Array of wallets excluded from rewards


    // Token information 
    function Token_Information() external view returns(string memory Token_Name,
                                                       string memory Token_Symbol,
                                                       uint256 Number_of_Decimals,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Twitter,
                                                       string memory Liquidity_Lock_URL,
                                                       string memory Contract_Created_By) {

                                                           
        string memory Creator = "https://gentokens.com/";

        uint256 Total_buy =  _Fee__Buy_Liquidity    +
                             _Fee__Buy_Marketing    +
                             _Fee__Buy_Reflection   ;

        uint256 Total_sell = _Fee__Sell_Liquidity   +
                             _Fee__Sell_Marketing   +
                             _Fee__Sell_Reflection  ;


        uint256 TranLimit = max_Tran / 10 ** _decimals;

        // TX limit is halved during launch phase
        if (LaunchPhase){

            TranLimit = max_Tran_Launch / 10 ** _decimals;

        }


        // Return Token Data
        return (_name,
                _symbol,
                _decimals,
                TranLimit,
                max_Hold / 10 ** _decimals,
                Total_buy,
                Total_sell,
                _Website,
                _Telegram,
                _Twitter,
                _LP_Locker_URL,
                Creator);

    }
    

    // Burn (dead) address
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD; 


    // Swap triggers
    uint256 private swapTrigger = 11;    // After 10 transactions with a fee swap will be triggered 
    uint256 private swapCounter = 1;     // Start at 1 not zero to save gas
    

    // SwapAndLiquify - Automatically processing fees and adding liquidity                                   
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 


    // Launch settings
    bool public TradeOpen;
    bool private LaunchPhase;
    uint256 private LaunchTime;


    // Deflationary Burn - Tokens Sent to Burn are removed from total supply if set to true
    bool public deflationaryBurn;

    // URL for Liquidity Tokens Locker
    string private _LP_Locker_URL;






    /* 

    ------------------------------------
    CONTRACT SET UP AND DEPLOYMENT GUIDE
    ------------------------------------

    */




    /*
    
    ------------------------------------------
    DECIDE IF BURN WALLET WILL BE DEFLATIONARY
    ------------------------------------------

    Deflationary Burn Switch - By default this is set to false
    
    If you change this to true, when tokens are sent to the burn wallet 0x000000000000000000000000000000000000dEaD
    They will not arrive in the burn wallet, instead they will be removed from the senders balance and removed from the total supply

    When this is set to false, any tokens sent to the burn wallet will not be removed from total supply and will be added to the burn wallet balance.
    This is the default action on most contracts. 

    A truly deflationary burn can be confusing to some token tools and listing platforms!

    */

    function Deploy_1__Deflationary_Burn(bool true_or_false) external onlyOwner {
        deflationaryBurn = true_or_false;
        emit updated_DeflationaryBurn(deflationaryBurn);
    }



    /*
    
    ------------------------------
    SET CONTRACT BUY AND SELL FEES
    ------------------------------  

    To protect investors, buy and sell fees have a hard-coded limit of 20% 

    */


    // Set Buy Fees
    function Deploy_2__Fees_on_Buy(uint256 Marketing_on_BUY, 
                                   uint256 Liquidity_on_BUY, 
                                   uint256 Reflection_on_BUY) external onlyOwner {

        // Buyer protection: max fee can not be set over 20%
        require (Marketing_on_BUY    + 
                 Liquidity_on_BUY    + 
                 Reflection_on_BUY   <= 20, "Buy fee must be 20% or lower"); 

        // Update fees
        _Fee__Buy_Marketing  = Marketing_on_BUY;
        _Fee__Buy_Liquidity  = Liquidity_on_BUY;
        _Fee__Buy_Reflection = Reflection_on_BUY;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Buy    = _Fee__Buy_Marketing + _Fee__Buy_Liquidity;

        emit updated_Buy_fees(_Fee__Buy_Marketing, _Fee__Buy_Liquidity, _Fee__Buy_Reflection);
    }

    // Set Sell Fees
    function Deploy_3__Fees_on_Sell(uint256 Marketing_on_SELL,
                                    uint256 Liquidity_on_SELL, 
                                    uint256 Reflection_on_SELL) external onlyOwner {

        // Buyer protection: max fee can not be set over 20% 
        require (Marketing_on_SELL  + 
                 Liquidity_on_SELL  + 
                 Reflection_on_SELL <= 20, "Sell fee must be 20% or lower"); 

        // Update fees
        _Fee__Sell_Marketing  = Marketing_on_SELL;
        _Fee__Sell_Liquidity  = Liquidity_on_SELL;
        _Fee__Sell_Reflection = Reflection_on_SELL;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Sell   = _Fee__Sell_Marketing + _Fee__Sell_Liquidity;

        emit updated_Sell_fees(_Fee__Sell_Marketing, _Fee__Sell_Liquidity, _Fee__Sell_Reflection);
    }



    /*
    
    ------------------------------------------
    SET MAX TRANSACTION AND MAX HOLDING LIMITS
    ------------------------------------------

    To protect buyers, these values must be set to a minimum of 0.1% of the total supply
    Wallet limits are set as a number of tokens, not as a percent of supply!

        Sample tokens amounts
        
        0.25% = 250000
        0.5%  = 500000
        1%    = 1000000
        1.5%  = 1500000
        2%    = 2000000

    */

    // Wallet Holding and Transaction Limits (Enter token amount, excluding decimals)
    function Deploy_4__Wallet_Limits(

        uint256 Max_Tokens_Per_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet

        ) external onlyOwner {

        // Buyer protection - Limits must be set to greater than 0.1% of total supply
        require(Max_Tokens_Per_Transaction >= _tTotal / 1000 / 10**_decimals, "Min transaction must be 0.1% or greater");
        require(Max_Total_Tokens_Per_Wallet >= _tTotal / 1000 / 10**_decimals, "Min wallet must be 0.1% or greater");
        
        max_Tran = Max_Tokens_Per_Transaction * 10 ** _decimals;
        max_Hold = Max_Total_Tokens_Per_Wallet * 10 ** _decimals;

        emit updated_Wallet_Limits(max_Tran, max_Hold);

    }



    /*

    ----------------------
    UPDATE PROJECT WALLETS
    ----------------------

    Cake LP Tokens that are created when the contract makes Auto Liquidity are sent to the Liquidity_Collection_Wallet
    Periodically, these tokens will need to be locked (or burned)

    */

    function Deploy_5__Set_Wallets(address payable Marketing_Wallet, address Liquidity_Collection_Wallet) external onlyOwner {

        // Update BNB Fee Wallet
        require(Marketing_Wallet != address(0), "Marketing wallet can not be the 0x0 address");
        emit updated_Marketing_Wallet(Wallet_Marketing, Marketing_Wallet);
        Wallet_Marketing = Marketing_Wallet;

        // To send the auto liquidity tokens directly to burn update to 0x000000000000000000000000000000000000dEaD
        emit updated_Liquidity_Wallet(Wallet_Liquidity, Liquidity_Collection_Wallet);
        Wallet_Liquidity = Liquidity_Collection_Wallet;

    }





    /*

    -----------------
    ADD PROJECT LINKS
    -----------------

    The information that you add here will appear on BSCScan, helping potential investors to find out more about your project.
    Be sure to enter the complete URL as many websites will automatically detect this, and add links to your token listing.

    If you are updating one link, you will also need to re-enter the others.

    */

    function Deploy_6__Update_Socials(string memory Website_URL,
                                      string memory Telegram_URL,
                                      string memory Twitter_URL,
                                      string memory Liquidity_Locker_URL) external onlyOwner{

                                      _Website         = Website_URL;
                                      _Telegram        = Telegram_URL;
                                      _Twitter         = Twitter_URL;
                                      _LP_Locker_URL   = Liquidity_Locker_URL;  
    }




    /* 

    ---------------------------------
    BLACKLIST BOTS - PRE LAUNCH ONLY!
    --------------------------------- 

    You have the ability to blacklist wallets prior to launch.
    This should only be used for known bot users. 

    Check https://poocoin.app/sniper-watcher to see currently active bot users
    
    Blacklist known bot users - can only be done pre-launch
    This function does not have modifier as the 'add blacklist' can only be used before launch
    and 'remove blacklist' needs to be left available to correct potential mistakes!

    To blacklist, enter wallet and set to true. 
    To remove blacklist, enter wallet and set to false.

    */
    

    function Deploy_7__Blacklist_Bots(address Wallet, bool true_or_false) external onlyOwner {
        
        // Buyer Protection - Blacklisting can only be done before launch
        if (true_or_false){require(LaunchTime == 0, "Can only blacklist before launch.");}
        _isBlacklisted[Wallet] = true_or_false;
    }




    /*

    -------------
    ADD LIQUIDITY
    -------------

    To add your liquidity go to https://pancakeswap.finance/add/BNB and enter your contract address into the 'Select a Currency' field.

    */



    /* 

    -----------------------------
    SET LAUNCH LIMIT RESTRICTIONS
    -----------------------------
    
    During the launch phase, additional restrictions can help to spread the tokens more evenly over the initial buyers.
    This helps to prevent whales accumulating a max wallet for almost nothing and prevent dumps.

    */

    function Deploy_8__Set_Launch_Limits(uint256 Launch_Buy_Delay_Seconds, uint256 Launch_Transaction_Limit, uint256 Launch_Phase_Length_Miuntes) external onlyOwner {

        max_Tran_Launch  = Launch_Transaction_Limit * 10 ** _decimals;
        Launch_Buy_Delay = Launch_Buy_Delay_Seconds;
        Launch_Length    = Launch_Phase_Length_Miuntes * 60;

    }



    /*

    ----------
    OPEN TRADE
    ----------

    */


    // Open trade: Buyer Protection - one way switch - trade can not be paused once opened
    function Deploy_9__OpenTrade() external onlyOwner {

        // Can only use once!
        require(!TradeOpen, "Trade open");
        TradeOpen = true;
        swapAndLiquifyEnabled = true;
        LaunchPhase = true;
        LaunchTime = block.timestamp;

        emit updated_trade_Open(TradeOpen);
        emit updated_SwapAndLiquify_Enabled(swapAndLiquifyEnabled);

    }







    /* 

    ----------------------------
    CONTRACT OWNERSHIP FUNCTIONS
    ----------------------------
    
    */


    // Transfer the contract to to a new owner
    function Owner_Transfer_Ownership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "0 address");

        // Remove old owner status 
        _isLimitExempt[owner()]         = false;
        _isExcludedFromFee[owner()]     = false;
        _isWhiteListed[owner()]         = false;


        // Emit ownership transfer
        emit OwnershipTransferred(_owner, newOwner);

        // Transfer owner
        _owner = newOwner;

    }

    // Renounce contract ownership
    function Owner_Renounce_Ownership() public onlyOwner {

        // Emit Renounce
        emit OwnershipTransferred(_owner, address(0));

        // Renoucne contract
        _owner = address(0);
    }







    /*

    --------------
    FEE PROCESSING
    --------------

    */


    // Default is True. Contract will process fees into Marketing and Liquidity etc. automatically
    function Processing_SwapAndLiquify_Enabled(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }

    // Manually process fees
    function Processing_Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!inSwapAndLiquify); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }


    // Set the number of transactions before fee processing is triggered (default 10)
    function Processing_Trigger_Count(uint256 Number_of_Transactions_to_Trigger_Processing) external onlyOwner {

        // Add 1 to total as counter is reset to 1, not 0, to save gas
        swapTrigger = Number_of_Transactions_to_Trigger_Processing + 1;
        emit updated_swapTriggerCount(Number_of_Transactions_to_Trigger_Processing);
    }


    // Remove random tokens from the contract
    function Processing_Remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){

            // Can not purge the native token!
            require (random_Token_Address != address(this), "Native token");

            // Sanity check
            if (percent_of_Tokens > 100){percent_of_Tokens == 100;}

            // Get balance of random tokens and send to caller wallet
            uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
            uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
            _sent = IERC20(random_Token_Address).transfer(msg.sender, removeRandom);

    }








    /*

    -----------------------------
    BEP20 STANDARD AND COMPLIANCE
    -----------------------------

    */

    function owner() public view returns (address) {
        return _owner;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
   
    function tokenFromReflection(uint256 _rAmount) internal view returns(uint256) {
        require(_rAmount <= _rTotal, "Must be < total ref");
        uint256 currentRate =  _getRate();
        return _rAmount / currentRate;
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
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





    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */


    // Grants access when trade is closed - Default false (true for contract owner)
    function Wallet_Settings_Grant_PreLaunch_Access(address Wallet_Address, bool true_or_false) external onlyOwner {    
        _isWhiteListed[Wallet_Address] = true_or_false;
        emit updated_mapping_isWhiteListed(Wallet_Address, true_or_false);
    }

    // Excludes wallet from transaction and holding limits - Default false
    function Wallet_Settings_Exempt_From_Limits(address Wallet_Address, bool true_or_false) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit updated_mapping_isLimitExempt(Wallet_Address, true_or_false);
    }

    // Excludes wallet from fees - Default false
    function Wallet_Settings_Exclude_From_Fees(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;
        emit updated_mapping_isExcludedFromFee(Wallet_Address, true_or_false);

    }

    // Set address as a liquidity pair
    function Wallet_Settings_Set_As_Liquidity_Pair(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit updated_mapping_isPair(Wallet_Address, true_or_false);
    } 



    /*

    The following functions are used to exclude or include a wallet in the reflection rewards.
    By default, all wallets are included. 

    Wallets that are excluded:

            The Burn address 
            The Liquidity Pair
            The Contract Address

    --------------------------------
    WARNING - DoS 'OUT OF GAS' Risk!
    --------------------------------

    A reflections contract needs to loop through all excluded wallets to correctly process several functions. 
    This loop can break the contract if it runs out of gas before completion.

    To prevent this, keep the number of wallets that are excluded from rewards to an absolute minimum. 
    In addition to the default excluded wallets, you may need to exclude the address of any locked tokens.

    */


    // Wallet will not get reflections
    function Rewards_Exclude_Wallet(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }


    // Wallet will get reflections - DEFAULT
    function Rewards_Include_Wallet(address account) external onlyOwner() {
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
    }
    


   





    /*

    -----------------------
    TOKEN TRANSFER HANDLING
    -----------------------

    */

    // Main transfer checks and settings 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {


        // Allows owner to add liquidity safely, eliminating the risk of someone maliciously setting the price 
        if (!TradeOpen){
        require(_isWhiteListed[from] || _isWhiteListed[to], "Trade closed");
        }

        // Launch Phase
        if (LaunchPhase && to != address(this) && _isPair[from])
            {

            // Restrict max transaction by half during launch phase
            require(amount <= max_Tran_Launch, "Launch transaction limit exceeded");

            // Stop repeat buys within 10 seconds
            require (block.timestamp >= _Last_Buy[to] + Launch_Buy_Delay, "Buy delay timer active during launch");

            // Stop snipers    
            require(!_isSnipe[to]);

            // Detect and restrict snipers 
            if (block.timestamp <= LaunchTime + 5) {
                require(amount <= _tTotal / 10000, "1st block transaction limit exceeded");
                _isSnipe[to] = true;
                }

            // Record the transaction time for the buying wallet
            _Last_Buy[to] = block.timestamp;

            // End Launch Phase after Launch Length Time (Default 5 mins)
            if (block.timestamp > LaunchTime + Launch_Length){LaunchPhase = false;}

        }



        // No blacklisted wallets permitted! 
        require(!_isBlacklisted[to],"The to address is Blacklisted");
        require(!_isBlacklisted[from],"The from address is Blacklisted");


        // Wallet Limit
        if (!_isLimitExempt[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "Over max wallet limit");
            }


        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt (or increase transaction limit)
        if (!_isLimitExempt[to] || !_isLimitExempt[from])
            {
            require(amount <= max_Tran, "Over transaction limit");
            }


        // Compliance and safety checks
        require(from != address(0), "Tokens from the 0x0 address");
        require(to != address(0), "Tokens to the 0x0 address");
        require(amount > 0, "Amount must be greater than 0");



        // Check number of transactions required to trigger fee processing - can only trigger on sells
        if( _isPair[to] &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
            )
            {

            // Check that enough transactions have passed since last swap
            if(swapCounter >= swapTrigger){

            // Check number of tokens on contract
            uint256 contractTokens = balanceOf(address(this));

            // Only trigger fee processing if there are tokens to swap!
            if (contractTokens > 0){

                // Limit number of tokens that can be swapped 
                if (contractTokens <= swap_Max){
                    swapAndLiquify (contractTokens);
                    } else {
                    swapAndLiquify (swap_Max);
                    }
            }
            }  
            }


        // Do we need to take a fee
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
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

        /*
        
        Fees are processed as an average of each buy/sell fee total      

        */

        // Lock swapAndLiquify function
        inSwapAndLiquify        = true;  

        uint256 _FeesTotal      = _Fee__Buy_Liquidity + _Fee__Sell_Liquidity + _Fee__Buy_Marketing + _Fee__Sell_Marketing;
        uint256 LP_Tokens       = Tokens * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap tokens for BNB
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors if fee is an odd number
        uint256 fee_Split       = _FeesTotal * 2 - (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity);

        // Calculate the BNB value for Liquidity
        uint256 BNB_Liquidity   = returned_BNB * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / fee_Split;

        // Add liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }

        // Send remaining BNB to Marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
        Wallet_Marketing.transfer(contract_BNB); 
        }

        // Reset transaction counter (reset to 1 not 0 to save gas)
        swapCounter = 1;

        // Unlock swapAndLiquify function
        inSwapAndLiquify = false;
    }



    // Swap tokens for BNB
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



    // Add liquidity and send Cake LP tokens to liquidity collection wallet
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

    ---------
    TAKE FEES
    ---------

    */


    // Take fees that need to be processed and add to contract 
    function _takeSwap(uint256 _tSwapFeeTotal, uint256 _rSwapFeeTotal) private {

        _rOwned[address(this)] += _rSwapFeeTotal;
        if(_isExcluded[address(this)])
        _tOwned[address(this)] += _tSwapFeeTotal;

    }

    // Adjust RFI for reflection balance
    function _takeReflect(uint256 _tReflect, uint256 _rReflect) private {

        _rTotal -= _rReflect;
        _tFeeTotal += _tReflect;

    }








    /*
    
    ----------------------------------
    TRANSFER TOKENS AND CALCULATE FEES
    ----------------------------------

    */


    uint256 private tAmount;
    uint256 private rAmount;

    uint256 private tReflect;
    uint256 private rReflect;

    uint256 private tSwapFeeTotal;
    uint256 private rSwapFeeTotal;

    uint256 private tTransferAmount;
    uint256 private rTransferAmount;

    

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {

        // Calculate the transfer fees
        tAmount = amount;

        if (!takeFee){

            tReflect        = 0;    // Reflection Fee
            tSwapFeeTotal   = 0;    // BNB, Liquidity and Contract Fee

        } else {

            if(_isPair[sender]){

                // Buy fees
                tReflect        = tAmount * _Fee__Buy_Reflection  / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy     / 100;

            } else {

                // Sell fees - Also applies to wallet transfers and LP pairs added after renouncing
                tReflect        = tAmount * _Fee__Sell_Reflection / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell    / 100;
            }
        }

        // Calculate reflected fees for RFI
        uint256 RFI     = _getRate(); 

        rAmount         = tAmount       * RFI;
        rReflect        = tReflect      * RFI;
        rSwapFeeTotal   = tSwapFeeTotal * RFI;

        tTransferAmount = tAmount - (tReflect + tSwapFeeTotal);
        rTransferAmount = rAmount - (rReflect + rSwapFeeTotal);

        
        // Swap tokens based on RFI status of sender and recipient
        if (_isExcluded[sender] && !_isExcluded[recipient]) {

        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal -= tTransferAmount;
        _rTotal -= rTransferAmount;

        } else {

        _rOwned[recipient] += rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {

        _rOwned[sender] -= rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal -= tTransferAmount;
        _rTotal -= rTransferAmount;

        } else {

        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {

        _rOwned[sender] -= rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal -= tTransferAmount;
        _rTotal -= rTransferAmount;

        } else {

        _rOwned[recipient] += rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (_isExcluded[sender] && _isExcluded[recipient]) {

        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal -= tTransferAmount;
        _rTotal -= rTransferAmount;

        } else {

        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else {

        _rOwned[sender] -= rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal -= tTransferAmount;
        _rTotal -= rTransferAmount;

        } else {

        _rOwned[recipient] += rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        }



        // Take reflections
        if(tReflect != 0){_takeReflect(tReflect, rReflect);}

        // Take fees that require processing during swap and liquify
        if(tSwapFeeTotal != 0){

            _takeSwap(tSwapFeeTotal, rSwapFeeTotal);

            // Increase the transaction counter - only increase if required to save gas on buys when already in trigger zone
            if (swapCounter < swapTrigger){
                swapCounter++;
                }


        }

    }


   

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}




}
















































// Contract Created by https://gentokens.com/
// Not open source - Can not be used or forked without permission.
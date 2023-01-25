/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: Unlicensed 
// Custom contract - not open source - can not be copied/forked

/*

Vanguard Listings (VL)

Telegram: https://t.me/VLPortal
Website: https://vanguardlistings.com
Twitter: https://twitter.com/ListVanguard
Discord: https://discord.com/invite/WBRY5zjfGQ

*/


pragma solidity 0.8.17;
 
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



contract Vanguard_Listings is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;
   
    // Contract Wallets
    address private _owner = payable(0xD36312dFD078416c94F8bE76F5BE98c80Bfe2f59);
    address payable public Wallet_BNB = payable(_owner);

    // Token Info
    string private  _name = "Vanguard Listings";
    string private  _symbol = "VL";

    uint256 private _decimals = 9;
    uint256 private _tTotal = 10_000_000 * 10**_decimals;


    // Token project links
    string private _Website = "https://vanguardlistings.com";
    string private _Telegram = "https://t.me/VLPortal";
    string private _Twitter = "https://twitter.com/ListVanguard";
    string private _Discord = "https://discord.com/invite/WBRY5zjfGQ";
    string private _LP_Locker_URL;

    // Wallet and transaction limits
    uint256 private max_Hold = _tTotal;
    uint256 private max_Tran = _tTotal;

    // Fees
    uint256 public _Fee_Marketing_BUY;
    uint256 public _Fee_Marketing_SELL;
    uint256 public _Fee__Dev = 1; 

    // Total fees that are processed on buys and sells for swap and liquify calculations
    uint256 private _SwapFeeTotal_Buy;
    uint256 private _SwapFeeTotal_Sell;

    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor () {

        // Transfer token supply to owner wallet
        _tOwned[_owner] = _tTotal;

        // Set PancakeSwap Router Address
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        // Create initial liquidity pair with BNB on PancakeSwap factory
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // Set the initial liquidity pair
        _isPair[uniswapV2Pair] = true;    

        // Wallets that are excluded from holding limits
        _isLimitExempt[_owner] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[Wallet_Burn] = true;
        _isLimitExempt[uniswapV2Pair] = true;

        // Wallets that are excluded from fees
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Burn] = true;

        // Wallets granted access before trade is open
        _isWhiteListed[_owner] = true;

        // Emit supply transfer to owner
        emit Transfer(address(0), _owner, _tTotal);

        // Emit ownership transfer to owner
        emit OwnershipTransferred(address(0), _owner);

    }

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_fees(uint256 Marketing_on_Buy, uint256 Marketing_on_Sell, uint256 Contract_Fee);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event updated_trade_Open(bool TradeOpen);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);


    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Address mappings
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isWhiteListed;
    mapping (address => bool) public _isLimitExempt;
    mapping (address => bool) public _isPair;



    // Project links
    function Project_Links() external view returns(string memory Telegram,
                                                   string memory Website,
                                                   string memory Twitter,
                                                   string memory Discord) {

        return (_Telegram,
                _Website,
                _Twitter,
                _Discord);
    }


    // Token information 
    function Token_Information() external view returns(string memory Token_Name,
                                                       string memory Token_Symbol,
                                                       uint256 Number_of_Decimals,
                                                       address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       string memory Liquidity_Lock_URL) {

                                                           
        uint256 Total_buy =  _Fee_Marketing_BUY + _Fee__Dev;
        uint256 Total_sell = _Fee_Marketing_SELL + _Fee__Dev;

        return (_name,
                _symbol,
                _decimals,
                _owner,
                max_Tran / 10 ** _decimals,
                max_Hold / 10 ** _decimals,
                Total_buy,
                Total_sell,
                _LP_Locker_URL
                );

    }
    
    // Burn (dead) address
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD; 

    // Contract fee collection address 
    address payable public constant feeCollector = payable(0x3F679d42922CA9187694C33f4c86E87a83515420);

    // Fee processing
    uint256 private swapTrigger = 11;
    uint256 private swapCounter = 1;               
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 

    // Launch settings
    bool public TradeOpen;
    bool private LaunchPhase = true;

    // No fee on wallet-to-wallet transfers
    bool noFeeW2W = true;

    // Take fee tracker
    bool private takeFee;


    /* 

    --------------
    CONTRACT SETUP
    --------------

    */

    // Prepare the contract for presale 
    function Contract_SetUp_1__Presale(

        address Presale_Contract_Address

        ) external onlyOwner {

        _isExcludedFromFee[Presale_Contract_Address] = true; 
        _isLimitExempt[Presale_Contract_Address] = true;
        _isWhiteListed[Presale_Contract_Address] = true;

    }

    // Set Buy Fees
    function Contract_SetUp_2__Fees(

        uint256 Marketing_Fee_on_Buy,
        uint256 Marketing_Fee_on_Sell

        ) external onlyOwner {

        // Fees can not be set above 15%
        uint256 Fee_Limit = 15;

        // Check limits
        require (Marketing_Fee_on_Buy + _Fee__Dev <= Fee_Limit, "Buy fees are too high"); 
        require (Marketing_Fee_on_Sell + _Fee__Dev <= Fee_Limit, "Sell fees are too high"); 

        // Update fees
        _Fee_Marketing_BUY = Marketing_Fee_on_Buy;
        _Fee_Marketing_SELL = Marketing_Fee_on_Sell;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Buy = _Fee_Marketing_BUY + _Fee__Dev;
        _SwapFeeTotal_Sell = _Fee_Marketing_SELL + _Fee__Dev;

        emit updated_fees(_Fee_Marketing_BUY, _Fee_Marketing_SELL, _Fee__Dev);
    }

    // Wallet Holding and Transaction Limits (Enter token amount, excluding decimals)
    function Contract_SetUp_3__Limits(

        uint256 Max_Tokens_Per_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet 

        ) external onlyOwner {

        // Buyer protection - Limits must be set to greater than 0.1% of total supply
        require(Max_Tokens_Per_Transaction >= _tTotal / 1000 / 10**_decimals, "Max transaction is too low");
        require(Max_Total_Tokens_Per_Wallet >= _tTotal / 1000 / 10**_decimals, "Max wallet is too low");
        
        max_Tran = Max_Tokens_Per_Transaction * 10**_decimals;
        max_Hold = Max_Total_Tokens_Per_Wallet * 10**_decimals;

        emit updated_Wallet_Limits(max_Tran, max_Hold);

    }

    // Open trade: Buyer Protection - one way switch - trade can not be paused once opened
    function Contract_SetUp_4__Open_Trade() external onlyOwner {

        TradeOpen = true;
        swapAndLiquifyEnabled = true;

        emit updated_trade_Open(TradeOpen);
        emit updated_SwapAndLiquify_Enabled(swapAndLiquifyEnabled); 
    }

    /* 

    --------------------
    CONTRACT MAINTENANCE
    --------------------

    */

    // Setting an address as a liquidity pair
    function Maintenance__New_Liquidity_Pair(

        address Wallet_Address,
        bool true_or_false)

         external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // No fee on wallet to wallet transfers option
    function Maintenance__No_Fee_Wallet_Transfers(bool true_or_false) external onlyOwner {
        noFeeW2W = true_or_false;
    }

    // Transfer the contract to to a new owner
    function Maintenance__Ownership_Transfer(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Enter a valid address");

        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;


        // Emit ownership transfer
        emit OwnershipTransferred(_owner, newOwner);

        // Transfer owner
        _owner = newOwner;

    }

    // Renounce ownership of the contract 
    function Maintenance__Ownership_Renounce() public virtual onlyOwner {

        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Remove 1% contract fee (1 BNB payment required)
    function Maintenance__Remove_Contract_Fee() external onlyOwner payable {

        require(msg.value == 1*10**18, "Requries 1 BNB payment");
        send_BNB(feeCollector, msg.value);

        // Remove Contract Fee
        _Fee__Dev = 0;

        // Update Swap Fees
        _SwapFeeTotal_Buy   = _Fee_Marketing_BUY;
        _SwapFeeTotal_Sell  = _Fee_Marketing_SELL;
    }

    /*

    --------------
    FEE PROCESSING
    --------------

    */

    // Processing transaction fees automatically
    function Processing__Auto_Process(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }


    // Manually process percentage of accumulated fees
    function Processing__Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!inSwapAndLiquify, "Already in swap"); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }

    // Update count for swap trigger - Number of transactions to wait before processing accumulated fees (default is 10)
    function Processing__Update_Swap_Trigger_Count(uint256 Transaction_Count) external onlyOwner {
        // Counter is reset to 1 (not 0) to save gas, so add one to swapTrigger
        swapTrigger = Transaction_Count + 1;
    }


    // Remove random tokens from the contract
    function Processing__Remove_Random_Tokens(

        address random_Token_Address,
        uint256 number_of_Tokens

        ) external onlyOwner {

            // Can not remove the native token
            require (random_Token_Address != address(this), "Can't remove native token");
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
            
    }

    /*

    --------------
    UPDATE PROJECT
    --------------

    */


    // Update LP Locker Address
    function Update_Liquidity_Locker_URL(

        string memory Liquidity_Locker_URL

        ) external onlyOwner{

        _LP_Locker_URL   = Liquidity_Locker_URL;

    }

    // Update Project Wallets
    function Update_Marketing_Wallet(

        address payable New_Marketing_Wallet

        ) external onlyOwner {

        // Update BNB Fee (Marketing) Wallet
        require(New_Marketing_Wallet != address(0), "Enter a valid address");
        Wallet_BNB = payable(New_Marketing_Wallet);

    }

    // Update Project Links
    function Update_Project_Links(

        string memory Website, 
        string memory Telegram,
        string memory Twitter,
        string memory Discord

        ) external onlyOwner{

        _Website  = Website;
        _Telegram = Telegram;
        _Twitter  = Twitter;
        _Discord  = Discord;
    }

    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */

    // Grants wallet access before trade is open
    function Wallet_Settings__PreLaunch_Access(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {    
        _isWhiteListed[Wallet_Address] = true_or_false;
    }

    // Excludes wallet from transaction and holding limits
    function Wallet_Settings__Exempt_From_Limits(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // Excludes wallet from transaction fees
    function Wallet_Settings__Exclude_From_Fees(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;

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

    // Transfer BNB via call to reduce possibility of future 'out of gas' errors
    function send_BNB(address _to, uint256 _amount) internal returns (bool SendSuccess) {
                                
        (SendSuccess,) = payable(_to).call{value: _amount}("");

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
        require(_isWhiteListed[from] || _isWhiteListed[to], "Trade not open");
        }

        // Wallet Limit
        if (!_isLimitExempt[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "Exceeds wallet limit");
            }


        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from])
            {
            require(amount <= max_Tran, "Exceeds transaciton limit");
            }


        // Compliance and safety checks
        require(from != address(0), "From address not valid");
        require(to != address(0), "To address not valid");
        require(amount > 0, "Amount can not be zero");


        // Check if fee processing is possible
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
                        if (contractTokens <= max_Tran){
                            swapAndLiquify (contractTokens);
                            } else {
                            swapAndLiquify (max_Tran);
                            }
                    }
                } 
            }


        // Default: Only charge a fee on buys and sells, no fee for wallet transfers
        takeFee = true;
        if((!_isPair[from] && !_isPair[to] && noFeeW2W) || _isExcludedFromFee[from] || _isExcludedFromFee[to]){
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

        // Lock swapAndLiquify function
        inSwapAndLiquify        = true;  

        // Dev fee for buys and sells
        uint256 Total_Dev_Fee   = _Fee__Dev * 2;

        uint256 _FeesTotal      = (_SwapFeeTotal_Buy + _SwapFeeTotal_Sell);

        // Swap tokens for BNB
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Calculate the BNB values for contract fee
        uint256 BNB_Contract    = returned_BNB * Total_Dev_Fee / _FeesTotal;

        // Take developer fee
        if(BNB_Contract > 0){
            send_BNB(feeCollector, BNB_Contract);
        }

        // Send remaining BNB to BNB wallet (Marketing)
        contract_BNB = address(this).balance;

        if(contract_BNB > 0){
            send_BNB(Wallet_BNB, contract_BNB);
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

    /*
    
    ----------------------------------
    TRANSFER TOKENS AND CALCULATE FEES
    ----------------------------------

    */

    uint256 private tSwapFeeTotal;
    uint256 private tTransferAmount;

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool Fee) private {

        
        if (Fee){

            if(_isPair[recipient]){

                // Sell fees
                tSwapFeeTotal = tAmount * _SwapFeeTotal_Sell / 100;

            } else {

                // Buy fees
                tSwapFeeTotal = tAmount * _SwapFeeTotal_Buy / 100;

            }

        } else {

                // No fee - wallet to wallet transfer or exempt wallet 
                tSwapFeeTotal = 0;

        }

        // Calculate transfer amount
        tTransferAmount = tAmount - tSwapFeeTotal;

            _tOwned[sender] -= tAmount;
            _tOwned[recipient] += tTransferAmount;

            emit Transfer(sender, recipient, tTransferAmount);


        // Take fees that require processing during swap and liquify
        if(tSwapFeeTotal > 0){

            _tOwned[address(this)] += tSwapFeeTotal;

            // Increase the transaction counter
            swapCounter++;
                
        }

    }

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}

}



/*

Custom Contract by Gen
https://t.me/GenTokens_GEN 
https://tokensbygen.com

*/
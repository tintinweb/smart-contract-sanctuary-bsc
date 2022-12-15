/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission
// Contract created at https://TokensByGen.com


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






contract TokensByGEN_STANDARD_TOKEN is Context {


    address payable private FeeCollectorContract = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975);
    uint256 private constant PayNowFEE = 5*10**17; // Set Pay Now Fee to 0.5 BNB

    function CreateToken_PaymentOption(string memory Token_Name, 
                                       string memory Token_Symbol, 
                                       uint256 Total_Supply, 
                                       uint256 Number_Of_Decimals) public payable {
    
    require((msg.value == PayNowFEE) || (msg.value == 0));
    if (msg.value == PayNowFEE){

                // Transfer Fee to Collector Wallet
                send_BNB(FeeCollectorContract, msg.value);
    }


    // Set ongoing contract fee to 1% if not paying up front
    uint256 SetContractFee = 0;
    if (msg.value == 0) {SetContractFee = 1;}
    new Contract(Token_Name,
                 Token_Symbol,
                 Total_Supply, 
                 Number_Of_Decimals, 
                 payable(msg.sender),
                 SetContractFee);
    }

    // Allow contract to receive payment 
    receive() external payable {}

    // Purge BNB
    function Purge_BNB() external {
    FeeCollectorContract.transfer(address(this).balance);
    }

    // Purge Tokens
    function Purge_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external {
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        IERC20(random_Token_Address).transfer(FeeCollectorContract, removeRandom);
    }

    // Send BNB
    function send_BNB(address _to, uint256 _amount) internal returns (bool Sent) {
                                
        (Sent,) = payable(_to).call{value: _amount}("");

    }

}











contract Contract is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    // Contract Wallets
    address private _owner;
    address public Wallet_Liquidity;
    address public Wallet_Tokens;
    address payable public Wallet_BNB;

    // Contract fee (1% ongoing if applicable) is sent to fee collection contract 
    address payable public constant feeCollector = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975); 

    // Token Info
    string private  _name;
    string private  _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    // Project links
    string private _Website;
    string private _Telegram;
    string private _LP_Locker_URL;

    // Wallet and transaction limits
    uint256 private max_Hold;
    uint256 private max_Tran;

    // Fees
    uint256 public _Fee__Buy_Burn;
    uint256 public _Fee__Buy_Contract;
    uint256 public _Fee__Buy_Liquidity;
    uint256 public _Fee__Buy_BNB;
    uint256 public _Fee__Buy_Tokens;

    uint256 public _Fee__Sell_Burn;
    uint256 public _Fee__Sell_Contract;
    uint256 public _Fee__Sell_Liquidity;
    uint256 public _Fee__Sell_BNB;
    uint256 public _Fee__Sell_Tokens;

    // Upper limit for fee processing trigger
    uint256 private swap_Max;

    // Total fees that are processed on buys and sells for swap and liquify calculations
    uint256 private _SwapFeeTotal_Buy;
    uint256 private _SwapFeeTotal_Sell;

    // Contract fee
    uint256 private ContractFee;

    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor (string memory      _TokenName, 
                 string memory      _TokenSymbol,  
                 uint256            _TotalSupply, 
                 uint256            _Decimals, 
                 address payable    _OwnerWallet,
                 uint256            _ContractFee) {

    // Set owner
    _owner              = _OwnerWallet;

    // Set basic token details
    _name               = _TokenName;
    _symbol             = _TokenSymbol;
    _decimals           = _Decimals;
    _tTotal             = _TotalSupply * 10**_decimals;
    
    // Wallet limits - Set limits after deploying
    max_Hold            = _tTotal;
    max_Tran            = _tTotal;

    // Contract sell limit when processing fees
    swap_Max            = _tTotal / 100;

    // Set BNB, tokens, and liquidity collection wallets to owner (can be updated later)
    Wallet_BNB          = payable(_OwnerWallet);
    Wallet_Liquidity    = _OwnerWallet;
    Wallet_Tokens       = _OwnerWallet;

    // Set contract fee 
    ContractFee         = _ContractFee;

    // Transfer token supply to owner wallet
    _tOwned[_owner]     = _tTotal;

    // Set PancakeSwap Router Address
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Create initial liquidity pair with BNB on PancakeSwap factory
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Wallets excluded from holding limits
    _isLimitExempt[_owner] = true;
    _isLimitExempt[address(this)] = true;
    _isLimitExempt[Wallet_Burn] = true;
    _isLimitExempt[uniswapV2Pair] = true;
    _isLimitExempt[Wallet_Tokens] = true;

    // Wallets excluded from fees
    _isExcludedFromFee[_owner] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[Wallet_Burn] = true;

    // Set the initial liquidity pair
    _isPair[uniswapV2Pair] = true;    

    // Wallets granted access before trade is open
    _isWhiteListed[_owner] = true;

    // Emit Supply Transfer to Owner
    emit Transfer(address(0), _owner, _tTotal);

    // Emit ownership transfer
    emit OwnershipTransferred(address(0), _owner);

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Contract_Development_Fee);
    event updated_Sell_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Contract_Development_Fee);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event updated_trade_Open(bool TradeOpen);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event set_Contract_Fee(uint256 Contract_Development_Buy_Fee, uint256 Contract_Development_Sell_Fee);


    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    // Address mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isWhiteListed;                            // Wallets that have access before trade is open
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public _isSnipe;                                  // Snipers
    mapping (address => bool) public _isBlacklisted;                            // Blacklisted wallets

    // Token information 
    function Token_Information() external view returns(string memory Token_Name,
                                                       string memory Token_Symbol,
                                                       uint256 Number_of_Decimals,
                                                       address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Liquidity_Lock_URL,
                                                       string memory Contract_Created_By) {

                                                           
        string memory Creator = "https://tokensbygen.com/";

        uint256 Total_buy =  _Fee__Buy_Burn         +
                             _Fee__Buy_Contract     +
                             _Fee__Buy_Liquidity    +
                             _Fee__Buy_BNB          +
                             _Fee__Buy_Tokens       ;

        uint256 Total_sell = _Fee__Sell_Burn        +
                             _Fee__Sell_Contract    +
                             _Fee__Sell_Liquidity   +
                             _Fee__Sell_BNB         +
                             _Fee__Sell_Tokens      ;


        // Return Token Data
        return (_name,
                _symbol,
                _decimals,
                _owner,
                max_Tran / 10 ** _decimals,
                max_Hold / 10 ** _decimals,
                Total_buy,
                Total_sell,
                _Website,
                _Telegram,
                _LP_Locker_URL,
                Creator);

    }
    

    // Burn (dead) address
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD; 

    // Fee processing triggers
    uint256 private swapTrigger = 11;   
    uint256 private swapCounter = 1;    
    
    // SwapAndLiquify - Automatically processing fees and adding liquidity                                   
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 

    // Launch settings
    bool public TradeOpen;
    bool private LaunchPhase;
    uint256 private LaunchTime;

    // No fee on wallet-to-wallet transfers
    bool noFeeW2W = true;

    // Deflationary Burn - Tokens Sent to Burn are removed from total supply if set to true
    bool public deflationaryBurn;

    // Take fee tracker
    bool private takeFee;




    /*
    
    -----------------
    BUY AND SELL FEES
    -----------------

    */


    // Set Buy Fees
    function Contract_SetUp_01__Fees_on_Buy(

        uint256 BNB_on_BUY, 
        uint256 Liquidity_on_BUY, 
        uint256 Burn_on_BUY,  
        uint256 Tokens_on_BUY

        ) external onlyOwner {

        _Fee__Buy_Contract = ContractFee;

        // Buyer protection: max fee can not be set over 15% (including the 1% contract fee if applicable)
        require (BNB_on_BUY          + 
                 Liquidity_on_BUY    + 
                 Burn_on_BUY         + 
                 Tokens_on_BUY       + 
                 _Fee__Buy_Contract <= 15, "E01"); 

        // Update fees
        _Fee__Buy_BNB        = BNB_on_BUY;
        _Fee__Buy_Liquidity  = Liquidity_on_BUY;
        _Fee__Buy_Burn       = Burn_on_BUY;
        _Fee__Buy_Tokens     = Tokens_on_BUY;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Buy    = _Fee__Buy_BNB + _Fee__Buy_Liquidity + _Fee__Buy_Contract;

        emit updated_Buy_fees(_Fee__Buy_BNB, _Fee__Buy_Liquidity, _Fee__Buy_Burn, _Fee__Buy_Tokens, _Fee__Buy_Contract);
    }

    // Set Sell Fees
    function Contract_SetUp_02__Fees_on_Sell(

        uint256 BNB_on_SELL,
        uint256 Liquidity_on_SELL, 
        uint256 Burn_on_SELL,
        uint256 Tokens_on_SELL

        ) external onlyOwner {

        _Fee__Sell_Contract = ContractFee;

        // Buyer protection: max fee can not be set over 15% (including the 1% contract fee if applicable)
        require (BNB_on_SELL        + 
                 Liquidity_on_SELL  + 
                 Burn_on_SELL       + 
                 Tokens_on_SELL     + 
                 _Fee__Sell_Contract <= 15, "E02"); 

        // Update fees
        _Fee__Sell_BNB        = BNB_on_SELL;
        _Fee__Sell_Liquidity  = Liquidity_on_SELL;
        _Fee__Sell_Burn       = Burn_on_SELL;
        _Fee__Sell_Tokens     = Tokens_on_SELL;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Sell   = _Fee__Sell_BNB + _Fee__Sell_Liquidity + _Fee__Sell_Contract;

        emit updated_Sell_fees(_Fee__Sell_BNB, _Fee__Sell_Liquidity, _Fee__Sell_Burn, _Fee__Sell_Tokens, _Fee__Sell_Contract);
    }



    /*
    
    ------------------------------------------
    SET MAX TRANSACTION AND MAX HOLDING LIMITS
    ------------------------------------------

    To protect buyers, these values must be set to a minimum of 0.5% of the total supply

    Wallet limits are set as a number of tokens, not as a percent of supply!

    If you want to limit people to 2% of supply and your supply is 1,000,000 tokens then you 
    will need to enter 20000 (as this is 2% of 1,000,000)

    */

    // Wallet Holding and Transaction Limits (Enter token amount, excluding decimals)
    function Contract_SetUp_03__Wallet_Limits(

        uint256 Max_Tokens_Per_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet 

        ) external onlyOwner {

        // Buyer protection - Limits must be set to greater than 0.5% of total supply
        require(Max_Tokens_Per_Transaction >= _tTotal / 200 / 10**_decimals, "E03");
        require(Max_Total_Tokens_Per_Wallet >= _tTotal / 200 / 10**_decimals, "E04");
        
        max_Tran = Max_Tokens_Per_Transaction * 10**_decimals;
        max_Hold = Max_Total_Tokens_Per_Wallet * 10**_decimals;

        emit updated_Wallet_Limits(max_Tran, max_Hold);

    }


    /*

    ----------
    OPEN TRADE
    ----------

    */


    // Open trade: Buyer Protection - one way switch - trade can not be paused once opened
    function Contract_SetUp_04__OpenTrade() external onlyOwner {

        // Can only use once!
        require(!TradeOpen, "E05");
        TradeOpen = true;
        swapAndLiquifyEnabled = true;
        LaunchPhase = true;
        LaunchTime = block.timestamp;

        emit updated_trade_Open(TradeOpen);
        emit updated_SwapAndLiquify_Enabled(swapAndLiquifyEnabled);

        // Set the contract fee if required
        _Fee__Buy_Contract   = ContractFee;
        _Fee__Sell_Contract  = ContractFee;
        _SwapFeeTotal_Buy    = _Fee__Buy_Liquidity + _Fee__Buy_BNB + _Fee__Buy_Contract;
        _SwapFeeTotal_Sell   = _Fee__Sell_Liquidity + _Fee__Sell_BNB + _Fee__Sell_Contract;

        emit set_Contract_Fee(_Fee__Buy_Contract, _Fee__Sell_Contract);
    }






    /* 

    ---------------------------------------
    BLACKLIST BOTS - FIRST 15 MINUTES ONLY!
    ---------------------------------------

    */
    

    function Contract_SetUp_05__Blacklist_Bots(

        address Wallet,
        bool true_or_false

        ) external onlyOwner {
        
        // Buyer Protection - Blacklisting can only be done within the first 15 minutes
        if (true_or_false){require(block.timestamp <= LaunchTime + (60*15), "E06");}
        _isBlacklisted[Wallet] = true_or_false;
    }





    /*
    
    -----------------
    DEFLATIONARY BURN
    -----------------

    Default = false
    
    If you change this to true, when tokens are sent to the burn wallet
    (0x000000000000000000000000000000000000dEaD) they will instead be removed
    from the senders balance and removed from the total supply.

    When this is set to false, any tokens sent to the burn wallet will not
    be removed from total supply and will be added to the burn wallet balance.
    This is the default action on most contracts. 

    */

    function Options__Deflationary_Burn(bool true_or_false) external onlyOwner {
        deflationaryBurn = true_or_false;
    }


    /*
    
    ---------------------------------
    No FEE WALLET TO WALLET TRANSFERS
    ---------------------------------

    Default = true

    Having no fee on wallet-to-wallet transfers means that people can move tokens between wallets, 
    or send them to friends etc without incurring a fee. 

    NOTE: No-fee on wallet-to-wallet transfers is not compatible with Renouncing Ownership!  

    */

    function Options__No_Fee_Wallet_Transfers(bool true_or_false) public onlyOwner {
        noFeeW2W = true_or_false;
    }






    /*

    ----------------------
    UPDATE PROJECT WALLETS
    ----------------------

    */

    function Update_Project_Wallets(

        address Token_Fee_Wallet, 
        address payable BNB_Fee_Wallet, 
        address Liquidity_Collection_Wallet

        ) external onlyOwner {

        // Update Token Fee Wallet
        require(Token_Fee_Wallet != address(0), "E07");
        Wallet_Tokens = Token_Fee_Wallet;

        // Make limit exempt
        _isLimitExempt[Token_Fee_Wallet] = true;

        // Update BNB Fee Wallet
        require(BNB_Fee_Wallet != address(0), "E08");
        Wallet_BNB = payable(BNB_Fee_Wallet);

        // To send the auto liquidity tokens directly to burn update to 0x000000000000000000000000000000000000dEaD
        Wallet_Liquidity = Liquidity_Collection_Wallet;

    }


    /*

    --------------------
    UPDATE PROJECT LINKS
    --------------------

    */

    function Update_Project_Links(

        string memory Website_URL, 
        string memory Telegram_URL, 
        string memory Liquidity_Locker_URL

        ) external onlyOwner{

        _Website         = Website_URL;
        _Telegram        = Telegram_URL;
        _LP_Locker_URL   = Liquidity_Locker_URL;

    }




    /*

    -------------------
    REMOVE CONTRACT FEE
    -------------------

    Removal of the 1% Contract Fee (if applicable) costs 2 BNB 

    If you opted for the 1% ongoing fee in your contract you can remove this at a cost of 2 BNB at any time.
    To do this, enter the number 2 into the field.

    WARNING - If you renounce the contract, you will lose access to this function!  

    */

    function Maintenance__Remove_Contract_Fee() external onlyOwner payable {

        require(msg.value == 2*10**18, "E09"); 

        // Affiliate is not valid, send BNB to TokensByGEN contract Fee only
        send_BNB(feeCollector, msg.value);

        // Remove Contract Fee
        ContractFee              = 0;
        _Fee__Buy_Contract       = 0;
        _Fee__Sell_Contract      = 0;

        // Emit Contract Fee update
        emit set_Contract_Fee(_Fee__Buy_Contract, _Fee__Sell_Contract);

        // Update Swap Fees
        _SwapFeeTotal_Buy   = _Fee__Buy_Liquidity + _Fee__Buy_BNB;
        _SwapFeeTotal_Sell  = _Fee__Sell_Liquidity + _Fee__Sell_BNB;
    }


    /*
    
    ----------------------
    ADD NEW LIQUIDITY PAIR
    ----------------------

    */

    // Setting an address as a liquidity pair
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

    */


    // Transfer the contract to to a new owner
    function Maintenance__Transfer_Ownership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "E10");

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
    function Maintenance__Renounce_Ownership() public virtual onlyOwner {
        // Renouncing is not compatible with no-fee wallet-to-wallet transfers
        require(!noFeeW2W, "Can not renounce and have no-fee wallet transfers!");
        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }







    /*

    --------------
    FEE PROCESSING
    --------------

    */


    // Default is True. Contract will process fees into Marketing and Liquidity etc. automatically
    function Processing__Auto_Process(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }


    // Manually process fees
    function Processing__Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!inSwapAndLiquify, "E11"); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }

    // Update count for swap trigger - Number of transactions to wait before processing accumulated fees (default is 10)
    function Processing__Swap_Trigger_Count(uint256 Transaction_Count) external onlyOwner {
        // Counter is reset to 1 (not 0) to save gas, so add one to swapTrigger
        swapTrigger = Transaction_Count + 1;
    }


    // Remove random tokens from the contract
    function Processing__Remove_Random_Tokens(

        address random_Token_Address,
        uint256 number_of_Tokens

        ) external onlyOwner {
            // Can not purge the native token!
            require (random_Token_Address != address(this), "E12");
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
            
    }


    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */


    // Grants access when trade is closed - Default false (true for contract owner)
    function Wallet_Settings__PreLaunch_Access(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {    
        _isWhiteListed[Wallet_Address] = true_or_false;
    }

    // Excludes wallet from transaction and holding limits - Default false
    function Wallet_Settings__Exempt_From_Limits(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // Excludes wallet from fees - Default false
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

    ---------------
    TOKEN TRANSFERS
    ---------------

    */

    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {


        // Allows owner to add liquidity safely, eliminating the risk of someone maliciously setting the price 
        if (!TradeOpen){
        require(_isWhiteListed[from] || _isWhiteListed[to], "E13");
        }


        // Launch Phase
        if (LaunchPhase && to != address(this) && _isPair[from] && to != owner())
            {

            // End Launch Phase after 5 Minutes
            if (block.timestamp > LaunchTime + (60 * 5))

                    {
                        LaunchPhase = false;
                    }

                else

                    {

                        // Stop snipers buying more tokens during launch phase  
                        require(!_isSnipe[to], "E14");

                        // Detect and restrict snipers
                        if (block.timestamp <= LaunchTime + 3) {
                            require(amount <= _tTotal / 10000, "E15");
                            _isSnipe[to] = true;
                            }
                    }

            }



        // No blacklisted wallets permitted! 
        require(!_isBlacklisted[to] && !_isBlacklisted[from],"E16");


        // Wallet Limit
        if (!_isLimitExempt[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "E17");
            }


        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from])
            {
            require(amount <= max_Tran, "E18");
            }


        // Compliance and safety checks
        require(from != address(0), "E19");
        require(to != address(0), "E20");
        require(amount > 0, "E21");



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
                if (contractTokens <= swap_Max){
                    swapAndLiquify (contractTokens);
                    } else {
                    swapAndLiquify (swap_Max);
                    }
            }
            }  
            }


        takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeW2W && !_isPair[to] && !_isPair[from])){
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

        uint256 _FeesTotal      = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 LP_Tokens       = Tokens * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap tokens for BNB
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors if fee is an odd number
        uint256 fee_Split = _FeesTotal * 2 - (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity);

        // Calculate the BNB values for each fee (excluding BNB wallet)
        uint256 BNB_Liquidity   = returned_BNB * (_Fee__Buy_Liquidity     + _Fee__Sell_Liquidity)       / fee_Split;
        uint256 BNB_Contract    = returned_BNB * (_Fee__Buy_Contract      + _Fee__Sell_Contract)    * 2 / fee_Split;

        // Add liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }
   

        // Take developer fee
        if(BNB_Contract > 0){

                send_BNB(feeCollector, BNB_Contract);

        }

        
        // Send remaining BNB to BNB wallet
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

                // Sell fees
                tBurn           = tAmount * _Fee__Sell_Burn       / 100;
                tTokens         = tAmount * _Fee__Sell_Tokens     / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell    / 100;

            } else {

                // Buy fees
                tBurn           = tAmount * _Fee__Buy_Burn        / 100;
                tTokens         = tAmount * _Fee__Buy_Tokens      / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy     / 100;

            }

        } else {

                // No fee - wallet to wallet transfer or exempt wallet 
                tBurn           = 0;
                tTokens         = 0;
                tSwapFeeTotal   = 0;

        }

        tTransferAmount = tAmount - (tBurn + tTokens + tSwapFeeTotal);

        
        // Remove tokens from sender
        _tOwned[sender] -= tAmount;

        // Check for deflationary burn
        if (deflationaryBurn && recipient == Wallet_Burn) {

                // Remove tokens from Total Supply 
                _tTotal -= tTransferAmount;

            } else {

                // Give tokens to recipient
                _tOwned[recipient] += tTransferAmount;

            }

            emit Transfer(sender, recipient, tTransferAmount);

        // Take tokens
        if(tTokens > 0){

            _tOwned[Wallet_Tokens] += tTokens;

        }

        // Take fees that require processing during swap and liquify
        if(tSwapFeeTotal > 0){

            _tOwned[address(this)] += tSwapFeeTotal;

            // Increase the transaction counter
            swapCounter++;
                
        }

        // Handle tokens for burn
        if(tBurn > 0){

            if (deflationaryBurn){

                // Remove tokens from total supply
                _tTotal = _tTotal - tBurn;

            } else {

                _tOwned[Wallet_Burn] += tBurn;

            }

        }



    }


   

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}




}

/*

---------------------
**** ERROR CODES ****
---------------------

    E01 -  Buy fees are limited of 15% max to protect buyers (includes 1% dev fee if applicable)
    E02 - Sell fees are limited of 15% max to protect buyers (includes 1% dev fee if applicable)
    E03 - The max transaction limit must be set to more than 0.5% of total supply
    E04 - The max wallet holding limit must be set to more than 0.5% of total supply
    E05 - Trade is already open
    E06 - Blacklisting of wallets only permitted within 15 minutes of launch
    E07 - A valid BSC wallet must be entered when updating the token fee wallet 
    E08 - A valid BSC wallet must be entered when updating the BNB fee wallet 
    E09 - A fee of 2 BNB is required, enter the number 2 into the field and try again
    E10 - A valid BSC wallet must be entered when transferring ownership
    E11 - Contract is currently processing fees, try later
    E12 - Can not remove the native token
    E13 - Trade is not open, only whitelisted wallets can trade
    E14 - Wallet was flagged as a sniper bot and can not purchase again during launch phase
    E15 - Trying to buy over the launch block max transaction limit
    E16 - Wallet is blacklisted, trade cancelled
    E17 - Purchase would exceed max wallet holding limit, trade cancelled
    E18 - Purchase would exceed max transaction limit, trade cancelled 
    E19 - Zero address error, please use a valid BSC address
    E20 - Zero address error, please use a valid BSC address
    E21 - Amount must be greater than 0

*/


// Contract Created by https://TokensByGEN.com
// Not open source - Can not be used or forked without permission.
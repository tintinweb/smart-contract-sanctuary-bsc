/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission





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

/*

contract TokensByGEN_Factory is Context {

    // Factory for the Unruggable Token

    // Affiliate Tracking
    IERC20 GEN = IERC20(0x7d7a7f452e04C2a5df792645e8bfaF529aDcCEcf); // GEN - For tracking affiliate level
    IERC20 AFF = IERC20(0x98A70E83A53544368D72940467b8bB05267632f4); // TokensByGEN Affiliate Tracker Token

    // Fee Collector Contract - For sending token creation fee
    address payable private FeeCollectorContract = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975);


    uint256 private Tier_2 =  500000 * 10**9; 
    uint256 private Tier_3 = 1000000 * 10**9; 

    uint256 public PayNowFEE = 1*10**18; 

    function CreateToken_PaymentOption(string memory TokenSymbol, string memory TokenName, address OwnerWallet, address payable FeeWallet, uint256 TotalSupply, uint256 Decimals, string memory Website, address payable DiscountCode) public payable {
    
    // Payment for contract 1BNB or 1% of future transactions
    require((msg.value == PayNowFEE) || (msg.value == 0),"Fee must be 1 BNB or 0 BNB");

    // If paying 1 BNB up front, check affiliate status
    if (msg.value == PayNowFEE){
                // Check Affiliate is genuine - (Holds the TokensByGEN Affiliate Token)
                if(AFF.balanceOf(DiscountCode) > 0){


                        if(GEN.balanceOf(DiscountCode) >= Tier_3){

                        // Tier 3 - Split 70% Contract, 20% Affiliate, 10% Refund to Client
                        FeeWallet.transfer(msg.value * 10 / 100);
                        DiscountCode.transfer(msg.value * 20 / 100);
                        FeeCollectorContract.transfer(msg.value * 70 / 100); 


                        } else if (GEN.balanceOf(DiscountCode) >= Tier_2){

                        // Tier 2 - Split 75% Contract, 15% Affiliate, 10% Refund to Client
                        FeeWallet.transfer(msg.value * 10 / 100);
                        DiscountCode.transfer(msg.value * 15 / 100);
                        FeeCollectorContract.transfer(msg.value * 75 / 100); 


                        } else {

                        // Tier 1 - Split 80% Contract, 10% Affiliate, 10% Refund to Client
                        FeeWallet.transfer(msg.value * 10 / 100);
                        DiscountCode.transfer(msg.value * 10 / 100);
                        FeeCollectorContract.transfer(msg.value * 80 / 100); 

                        }

                } else {

                // Transfer Fee to Collector Wallet
                FeeCollectorContract.transfer(msg.value);

                }
    }

    // Set ongoing contract fee to 1% if not paying up front
    uint256 SetContractFee;
    if (msg.value == 0) {SetContractFee = 1;} else {SetContractFee = 0;}
    new Contract(TokenSymbol, TokenName, OwnerWallet, FeeWallet, TotalSupply, Decimals, Website, DiscountCode, SetContractFee);
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

}

*/

contract Contract is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    address private _owner;
    address public Wallet_Tokens;
    address payable public Wallet_BNB;

    // Affiliate Wallet
    address payable public TokensByGEN_Affiliate;

    // Only used if the 1% transaction fee option is chosen 
    address payable public feeCollector = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975); 

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    // Token social links will appear on BSCScan 'read' contract page
    string public Token_Website;

    // Wallet and transaction limits we be locked at 1% of total supply at launch
    uint256 public max_Hold = _tTotal;
    uint256 public max_Tran = _tTotal;

    // Fees - Set fees before opening trade
    uint256 public _fee_Buy_Burn            = 0;
    uint256 public _fee_Buy_Contract        = 0;
    uint256 public _fee_Buy_Liquidity       = 0;
    uint256 public _fee_Buy_BNB             = 0;
    uint256 public _fee_Buy_Reflection      = 0;
    uint256 public _fee_Buy_Tokens          = 0;

    uint256 public _fee_Sell_Burn           = 0;
    uint256 public _fee_Sell_Contract       = 0;
    uint256 public _fee_Sell_Liquidity      = 0;
    uint256 public _fee_Sell_BNB            = 0;
    uint256 public _fee_Sell_Reflection     = 0;
    uint256 public _fee_Sell_Tokens         = 0;

    // Upper limit for fee processing trigger
    uint256 private swap_Max = _tTotal / 200;

    // Total fees that are processed on buys and sells for swap and liquify calculations
    uint256 private _SwapFeeTotal_Buy       = 0;
    uint256 private _SwapFeeTotal_Sell      = 0;

    // Track contract fee
    uint256 private ContractFee;

    // Supply Tracking for RFI
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private constant MAX = ~uint256(0);

    // Launch tracking
    uint256 private LaunchBlock = 0;
    bool private LaunchPhase = false;



    // Affiliate Tracking
    IERC20 GEN = IERC20(0x7d7a7f452e04C2a5df792645e8bfaF529aDcCEcf); // GEN - For tracking affiliate level
    IERC20 AFF = IERC20(0x98A70E83A53544368D72940467b8bB05267632f4); // TokensByGEN Affiliate Tracker Token


    uint256 private Tier_2 =  500000 * 10**9;
    uint256 private Tier_3 = 1000000 * 10**9;


    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;


    /*
    constructor (string memory _TokenSymbol, 
                 string memory _TokenName, 
                 address _OwnerWallet, 
                 address payable _FeeWallet, 
                 uint256 _TotalSupply, 
                 uint256 _Decimals, 
                 string memory _Website, 
                 address payable _AffiliateWallet, 
                 uint256 _ContractFee) {
    */

    constructor (){

    /*

    // Set owner
    _owner                  = _OwnerWallet;

    // Set affiliate
    TokensByGEN_Affiliate   = _AffiliateWallet;

    // Set basic token details
    _name                   = _TokenName;
    _symbol                 = _TokenSymbol;
    _decimals               = _Decimals;
    _tTotal                 = _TotalSupply * 10**_decimals;
    _rTotal                 = (MAX - (MAX % _tTotal));

    // Set Socials 
    Token_Website           = _Website;

    // Set BNB and Token wallets (can be updated later)
    Wallet_BNB              = _FeeWallet;
    Wallet_Tokens           = _FeeWallet;

    // Set contract fee 
    ContractFee             = _ContractFee;

    */

     // Set owner
    _owner                  = 0x406D07C7A547c3dA0BAcFcC710469C63516060f0;

    // Set affiliate
    TokensByGEN_Affiliate   = payable (0x406D07C7A547c3dA0BAcFcC710469C63516060f0);

    // Set basic token details
    _name                   = "test";
    _symbol                 = "test";
    _decimals               = 4;
    _tTotal                 = 1000000 * 10**_decimals;
    _rTotal                 = (MAX - (MAX % _tTotal));

    // Set Socials 
    Token_Website           = "test";

    // Set BNB and Token wallets (can be updated later)
    Wallet_BNB              = payable (0x406D07C7A547c3dA0BAcFcC710469C63516060f0);
    Wallet_Tokens           = 0x406D07C7A547c3dA0BAcFcC710469C63516060f0;

    // Set contract fee 
    ContractFee             = 1;




    // Transfer token supply to contract
    _tOwned[address(this)] = _tTotal;
    _rOwned[address(this)] = _rTotal;

    // Set PancakeSwap Router Address
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); ///////


    // Create initial liquidity pair with BNB on PancakeSwap factory
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Wallet that are excluded from holding limits
    _isLimitExempt[_owner] = true;
    _isLimitExempt[address(this)] = true;
    _isLimitExempt[Wallet_Burn] = true;
    _isLimitExempt[uniswapV2Pair] = true;
    _isLimitExempt[Wallet_Tokens] = true;

    // Wallets that are excluded from fees
    _isExcludedFromFee[_owner] = true;
    _isExcludedFromFee[address(this)] = true; 
    _isExcludedFromFee[Wallet_Burn] = true;

    // Set the initial liquidity pair
    _isPair[uniswapV2Pair] = true;    


    // Exclude from Rewards
    _isExcluded[Wallet_Burn] = true;
    _isExcluded[uniswapV2Pair] = true;
  //  _isExcluded[address(this)] = true;

    // Push excluded wallets to array
    _excluded.push(Wallet_Burn);
    _excluded.push(uniswapV2Pair);
  //  _excluded.push(address(this));

    // Emit Supply Transfer to Contract
    emit Transfer(address(0), address(this), _tTotal);

    // Emit ownership transfer
    emit OwnershipTransferred(address(0), _owner);

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_mapping_isPair(address Wallet_Address, bool LiquidityPair);
    event updated_Wallet_BNB(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Tokens(address indexed oldWallet, address indexed newWallet);
    event updated_mapping_isLimitExempt(address Wallet_Address, bool LimitExempt);
    event updated_mapping_isExcludedFromFee(address Wallet_Address, bool ExcludedFromFee); 
    event updated_Buy_fees(uint256 BNB, uint256 Liquidity, uint256 Reflection, uint256 Tokens, uint256 Contract_Development_Fee);
    event updated_Sell_fees(uint256 BNB, uint256 Liquidity, uint256 Reflection, uint256 Tokens, uint256 Contract_Development_Fee);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event Liquidity_Removal_Tokens_Claimed(address Sent_To_Wallet, uint256 Amount_of_LP_Tokens);
    event Liquidity_Removal_Requested(address Wallet_Requesting_Removal, uint256 Percent_of_LP_to_be_Removed, uint256 Remove_Date_UNIX_TIMESTAMP);
    event Liquidity_Removal_Request_Cancel(bool Liquidity_Removal_Reqest_Has_Been_Cancelled);


    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    // Address mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => uint256) private _rOwned;                               // Reflected balance
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isExcluded;                               // Excluded from RFI rewards
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public _isSnipe;                                  // Sniper!
    mapping (address => bool) public _isBlacklisted;                            // Blacklist wallet - can only be added pre-launch!
    address[] private _excluded;                                                // Array of wallets excluded from rewards

    

    // Burn (dead) address
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD; 


    // Swap triggers
    uint256 public swapTrigger = 11;    // After 10 transactions with a fee swap will be triggered 
    uint256 public swapCounter = 1;     // Start at 1 not zero to save gas
    

    // SwapAndLiquify - Automatically processing fees and adding liquidity                                   
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;


    // Deflationary Burn - Tokens Sent to Burn are removed from total supply if set to true
    bool public deflationaryBurn = false;






    /* 

    Contract Setup Functions

    */





    /* 

    Blacklist Known Bots - PreLaunch Only! 

    You have the ability to blacklist wallets prior to launch.
    This should only be used for known bot users. 
    Check https://poocoin.app/sniper-watcher to see currently active sniper bot users

    */


    // Blacklist known bot users - can only be done pre-launch (comma separate wallets with no spaces!)
    function Contract_Setup_1_Blacklist_Known_Bots(address[] calldata Wallets) external onlyOwner {
         // Can only be done before launch
        require(LaunchBlock == 0,"Can only blacklist before launch!");
        for (uint256 i; i < Wallets.length; ++i) {
        _isBlacklisted[Wallets[i]] = true;
      }
    }

    // Remove wallet blacklist restrictions - this can be done at any time if you have blacklisted a wallet by mistake
    function Remove_From_Blacklist(address Wallet_Address) external onlyOwner {

        _isBlacklisted[Wallet_Address] = false;
    }






    /*

    Deflationary Burn Switch - By default this is set to false
    
    If you change this to true, when tokens are sent to the burn wallet 0x000000000000000000000000000000000000dEaD
    They will not arrive in the burn wallet, instead they will be removed from the senders balance and removed from the total supply

    When this is set to false, any tokens sent to the burn wallet will not be removed from total supply and will be added to the burn wallet balance

    */

    function Contract_Setup_2_Choose_Deflationary_Burn(bool true_or_false) external onlyOwner {
        deflationaryBurn = true_or_false;
    }


    /*

    FEES  

    If contract development fee was set to 1% of transactions, this is included in the max fee limit of 12

    */


    // Set Buy Fees - Max possible 12% (including 1% contract fee if applicable)
    function Contract_Setup_3_Set_Fees_on_Buy(uint256 BNB_on_BUY, 
                             uint256 Liquidity_on_BUY, 
                             uint256 Reflection_on_BUY, 
                             uint256 Burn_on_BUY,  
                             uint256 Tokens_on_BUY) external onlyOwner {

        _fee_Buy_Contract = ContractFee;

        // Buyer protection - max fee can not be set over 12% (including possible 1% contract fee if chosen)
        require(BNB_on_BUY + Liquidity_on_BUY + Reflection_on_BUY + Burn_on_BUY + Tokens_on_BUY + _fee_Buy_Contract <= 12, "Fees too high"); 

        // Update fees
        _fee_Buy_BNB        = BNB_on_BUY;
        _fee_Buy_Liquidity  = Liquidity_on_BUY;
        _fee_Buy_Reflection = Reflection_on_BUY;
        _fee_Buy_Burn       = Burn_on_BUY;
        _fee_Buy_Tokens     = Tokens_on_BUY;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Buy   = _fee_Buy_BNB + _fee_Buy_Liquidity + _fee_Buy_Contract;

        emit updated_Buy_fees(_fee_Buy_BNB, _fee_Buy_Liquidity, _fee_Buy_Reflection, _fee_Buy_Tokens, _fee_Buy_Contract);
    }

    // Set Sell Fees - Max possible 12% (including 1% contract fee if applicable)
    function Contract_Setup_4_Set_Fees_on_Sell(uint256 BNB_on_SELL,
                              uint256 Liquidity_on_SELL, 
                              uint256 Reflection_on_SELL, 
                              uint256 Burn_on_SELL,
                              uint256 Tokens_on_SELL) external onlyOwner {

        _fee_Sell_Contract = ContractFee;

        // Buyer protection - max fee can not be set over 12% (including possible 1% contract fee if chosen)
        require(BNB_on_SELL + Liquidity_on_SELL + Reflection_on_SELL + Burn_on_SELL + Tokens_on_SELL + _fee_Sell_Contract <= 12, "Fees too high"); 

        // Update fees
        _fee_Sell_BNB        = BNB_on_SELL;
        _fee_Sell_Liquidity  = Liquidity_on_SELL;
        _fee_Sell_Reflection = Reflection_on_SELL;
        _fee_Sell_Burn       = Burn_on_SELL;
        _fee_Sell_Tokens     = Tokens_on_SELL;

        // Fees that will need to be processed during swap and liquify
        _SwapFeeTotal_Sell   = _fee_Sell_BNB + _fee_Sell_Liquidity + _fee_Sell_Contract;

        emit updated_Sell_fees(_fee_Sell_BNB, _fee_Sell_Liquidity, _fee_Sell_Reflection, _fee_Sell_Tokens, _fee_Sell_Contract);
    }

    bool private noFee = true;


    // Create liquidity pool and lock LP tokens for 4 months - Lock can be extended at any time if required 
    function Contract_Setup_5_Create_Liquidity_Pool_and_Launch() payable external onlyOwner {

        // Initial LP must be 1 BNB or more!
        uint256 BNBAmount = msg.value;
        require (BNBAmount >= 1*10**18, "1 BNB minimum for LP");
        // Create initial liquidity pool 
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            _tTotal,
            0, 
            0,
            address(this),
            block.timestamp
        );

        // Update liquidity lock timer to ensure a minimum of 120 days on LP lock at launch
        if (Liquidity_Unlock_Time < block.timestamp + 120 days) {
    /////    Liquidity_Unlock_Time = block.timestamp + 120 days;
        Liquidity_Unlock_Time = block.timestamp + 1 days; //// TEST 1 DAY! 
        }

        // Set LaunchBlock for Anti-Bot Code
        LaunchBlock = block.number;
        LaunchPhase = true;
        noFee = false;

        // Set transaction and holding limits to 1%
        max_Hold = _tTotal / 100;
        max_Tran = _tTotal / 100;

    }
    

 






    /*

    Remove 1% Contract Fee - Cost = 2 BNB 

    If you opted for the 1% ongoing fee in your contract you can remove this at a cost of 2 BNB at any time.
    To do this, enter the number 2 into the field 

    */

    function Remove_1_Percent_Contract_Fee_For_2BNB() external onlyOwner payable {

       require(msg.value == 2*10**18, "Removal fee is 2 BNB"); 

        // Check Affiliate is genuine - (Holds the TokensByGEN Affiliate Token)
        if(AFF.balanceOf(TokensByGEN_Affiliate) > 0){

                if(GEN.balanceOf(TokensByGEN_Affiliate) >= Tier_3){

                // Tier 3 - Split 80% Contract, 20% Affiliate
                TokensByGEN_Affiliate.transfer(msg.value * 20 / 100);
                feeCollector.transfer(msg.value * 80 / 100); 


                } else if (GEN.balanceOf(TokensByGEN_Affiliate) >= Tier_2){

                // Tier 2 - Split 85% Contract, 15% Affiliate
                TokensByGEN_Affiliate.transfer(msg.value * 15 / 100);
                feeCollector.transfer(msg.value * 85 / 100); 


                } else {

                // Tier 1 - Split 90% Contract, 10% Affiliate
                TokensByGEN_Affiliate.transfer(msg.value * 10 / 100);
                feeCollector.transfer(msg.value * 90 / 100); 

                }

        } else {

        // Transfer Fee to Collector Wallet
        feeCollector.transfer(msg.value);

        }

        // Remove Contract Fee
        ContractFee             = 0;
        _fee_Buy_Contract       = 0;
        _fee_Sell_Contract      = 0;


        // Update Swap Fees
        _SwapFeeTotal_Buy   = _fee_Buy_Liquidity + _fee_Buy_BNB;
        _SwapFeeTotal_Sell  = _fee_Sell_Liquidity + _fee_Sell_BNB;
    }








    













    /* 

    Owner Functions

    There is no ability to renounce this contract as it is possible for anybody to create a new liquidity pair and this must be added to the isPair mapping.
    This is required to make it possible for the contract to have no fees when transferring tokens between wallets.

    However, the contract has many hard coded limits that protect the buyer and prevent the owner from abusing the functions. 

    */



    // Transfer the contract to to a new owner
    function Owner_Transfer_Ownership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        // Remove old owner status 
        _isLimitExempt[owner()] = false;
        _isExcludedFromFee[owner()] = false;


        // Emit ownership transfer
        emit OwnershipTransferred(_owner, newOwner);

        // Transfer owner
        _owner = newOwner;

        // Add new Owner status
        _isLimitExempt[owner()] = true;
        _isExcludedFromFee[owner()] = true;

    }








    /*

    Processing Fees Functions

    */



    // Default is True = Contract will process fees into Marketing and Liquidity etc. automatically
    function Processing_SwapAndLiquify_Enabled(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }

    // Manually process fees - emit is triggered within swapAndLiquify function so not needed here
    function Processing_Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!inSwapAndLiquify, "In swap"); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }

    // Remove tokens from the contract - the emit happens during _transfer, therefore it is not required within this function
    function Processing_Remove_Tokens(address Token_Address, uint256 Percent_To_Remove) external onlyOwner returns(bool _sent){

            // Can not purge the native token!
            require (Token_Address != address(this), "Can not remove native token");

            // Can not purge the liquidity token!
            require (Token_Address != uniswapV2Pair, "Can not remove LP token");

            // Get balance of random tokens and send to caller wallet
            uint256 totalRandom = IERC20(Token_Address).balanceOf(address(this));
            uint256 removeRandom = totalRandom * Percent_To_Remove / 100;
            _sent = IERC20(Token_Address).transfer(msg.sender, removeRandom);

    }














    /* 
    
    -------------------

    LIQUIDITY FUNCTIONS

    -------------------

    */

    uint256 private Liquidity_Unlock_Time;
    uint256 private LP_Remove_Date = 0;
    uint256 private LP_Tokens_To_Remove = 0;
    bool private LP_Remove_Requested = false;


    // Information on the LP tokens that are locked in the contract - Lock includes the initial LP and any Auto LP
    function Liquidity_Lock_Info() external view returns(uint256 Days_Remaining_For_Liquidity_Lock, 
                                                         uint256 Number_of_Locked_LP_Tokens, 
                                                         uint256 Total_Number_of_LP_Tokens, 
                                                         uint256 Percent_of_LP_Locked_on_Contract,

                                                         bool LP_Removal_Requested,
                                                         uint256 Number_of_LP_Tokens_to_Be_Removed,
                                                         uint256 Percent_of_Locked_LP_Being_Removed,
                                                         uint256 Days_Remaining_Until_LP_Can_Be_Removed

                                                         ) {

        // Days remaining
        uint256 DaysRemain = 0;
        if(Liquidity_Unlock_Time < block.timestamp ){DaysRemain = 0;}
        else if(Liquidity_Unlock_Time - block.timestamp > 1 days){
        DaysRemain = (Liquidity_Unlock_Time - block.timestamp) / 1 days;
        } else {DaysRemain = 0;}

        // LP on this contract (Locked)
        uint256 ThisLP = IERC20(uniswapV2Pair).balanceOf(address(this));

        // Total LP Tokens
        uint256 TotalLP = IERC20(uniswapV2Pair).totalSupply();

        // Percent of LP locked in contract
        uint256 PercentLP = 0;
        if (ThisLP == TotalLP){PercentLP = 100;} else {
        PercentLP = (ThisLP * 100 / TotalLP);}

        // Percent of LP that will be removed
        uint256 Percent_Being_Removed = 0;
        if (LP_Remove_Requested){
            if (LP_Tokens_To_Remove == ThisLP){Percent_Being_Removed = 100;} else {
            Percent_Being_Removed = (LP_Tokens_To_Remove * 100 / ThisLP);}
        }

        // Days remaining until the LP can be removed
        uint256 Days_To_Remove = 0;
        if (!LP_Remove_Requested){

            Days_To_Remove = DaysRemain + 30;

            } else {

                if(LP_Remove_Date < block.timestamp ){Days_To_Remove = 0;}
                else if(LP_Remove_Date - block.timestamp > 1 days){
                Days_To_Remove = (LP_Remove_Date - block.timestamp) / 1 days;
                } else {Days_To_Remove = 0;}

            }

        // Return Liquidity Data
        return (DaysRemain,
               ThisLP,
               TotalLP,
               PercentLP,
               LP_Remove_Requested,
               LP_Tokens_To_Remove,
               Percent_Being_Removed,
               Days_To_Remove);

    }


    // Extend the liquidity lock timer (Adds time to existing unlock date)
    function Liquidity_Lock_Add_Days(uint256 _Days) external onlyOwner{

        Liquidity_Unlock_Time = Liquidity_Unlock_Time + (_Days * 1 days);

    }


    // Request to remove a percent of the LP tokens locked on the contract - Begins a 30 day counter to removal
    function Liquidity_Removal_Request(uint256 Percent_to_Remove) external onlyOwner {

        // Check that the LP lock has expired
        require (block.timestamp >= Liquidity_Unlock_Time, "LP is locked");

        // Check that there is no existing request
        require (!LP_Remove_Requested, "Request in process");

        // Check amount to remove is 100% or less!
        require (Percent_to_Remove <= 100, "100% max");

        // Set the number of tokens that will be removed
        uint256 ThisLP = IERC20(uniswapV2Pair).balanceOf(address(this));
        if (Percent_to_Remove == 100){LP_Tokens_To_Remove = ThisLP;} else {
                                      LP_Tokens_To_Remove = (ThisLP * Percent_to_Remove / 100);
        }

        // Set the date for the removal 30 days from now - Can be cancelled at any time!
        LP_Remove_Date = block.timestamp + 30 days;

        // Announce that LP removal has been requested
        LP_Remove_Requested = true;

        // emit
        emit Liquidity_Removal_Requested(msg.sender, Percent_to_Remove, LP_Remove_Date);

    }


    // Cancel LP removal request
    function Liquidity_Removal__Cancel() external onlyOwner {

        // Cancel the request to remove liquidity! 
        LP_Remove_Requested = false;
        LP_Remove_Date = 0;
        LP_Tokens_To_Remove = 0;

        // emit
        emit Liquidity_Removal_Request_Cancel(true);
    }


    // If 30 days have passed since you requested liquidity removal, you can now claim your LP tokens
    function Liquidity_Removal__Claim_Requested_Tokens() external onlyOwner {

        // Check removal conditions have been met
        require (LP_Remove_Date != 0, "Date can not be 0");
        require (LP_Tokens_To_Remove != 0, "Amount can not be 0");
        require (LP_Remove_Requested, "Request removal first");


        // Check that the 30 day removal has expired
        require (block.timestamp >= LP_Remove_Date, "30 day wait");

        // Send LP tokens to owner wallet
        IERC20(uniswapV2Pair).transfer(msg.sender, LP_Tokens_To_Remove);

        // Reset remove request
        LP_Remove_Requested = false;
        LP_Remove_Date = 0;
        LP_Tokens_To_Remove = 0;

        // emit 
        emit Liquidity_Removal_Tokens_Claimed(msg.sender, LP_Tokens_To_Remove);

    }





    /*

    ERC20/BEP20 Compliance and Standard Functions

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
        require(_rAmount <= _rTotal, "Amount must be less than total reflections");
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

    Wallet Mappings

    */

    // Identifies address as a liquidity pair - Default false
    function Wallet_Set_Address_As_Liquidity_Pair(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        emit updated_mapping_isPair(Wallet_Address, true_or_false);
    }

    // Excludes wallet from fees - Default false
    function Wallet_Exclude_From_Fees(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;
        emit updated_mapping_isExcludedFromFee(Wallet_Address, true_or_false);

    }

    // Excludes wallet from transaction and holding limits - Default false
    function Wallet_Settings_Exempt_From_Limits(address Wallet_Address, bool true_or_false) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit updated_mapping_isLimitExempt(Wallet_Address, true_or_false);
    }




    /*

    The following functions are used to exclude or include a wallet in the reflection rewards.
    By default, all wallets are included. 

    Wallets that are excluded:

            The Burn address 
            The Liquidity Pair
            The Contract Address

    DoS 'OUT OF GAS' Error Warning

    A reflections contract needs to loop through all excluded wallets to correctly process several functions. 
    This loop can break the contract if it runs out of gas before completion.

    To prevent this, keep the number of wallets that are excluded from rewards to an absolute minimum. 
    In addition to the default excluded wallets, you will need to exclude the address of any locked tokens.

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

    Update Wallets

    */


    // Update BNB wallet - Check website for details of how this is used. It can cover things such as marketing, team payments, charity donations etc. 
    function Update_Wallet_BNB(address payable wallet) external onlyOwner {

        require(wallet != address(0), "Can not be 0x0");
        emit updated_Wallet_BNB(Wallet_BNB,wallet);
        Wallet_BNB = wallet;
    }

    // Update Tokens wallet
    function Update_Wallet_Tokens(address wallet) external onlyOwner {

        require(wallet != address(0), "Can not be 0x0");
        emit updated_Wallet_Tokens(Wallet_Tokens,wallet);
        Wallet_Tokens = wallet;

        // Make limit exempt
        _isLimitExempt[Wallet_Tokens] = true;
    }




















    // Main transfer checks and settings 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {


        // Launch Phase
        if (LaunchPhase && to != address(this) && !_isPair[to])
            {
            require(!_isSnipe[to], "Can not buy until block 20");
            if (block.number == LaunchBlock) {
                require(amount <= _tTotal / 10000, "Over launch limit");
                _isSnipe[to] = true;
                }
            // End Launch Phase after 20 blocks
            if (block.number > LaunchBlock + 20){LaunchPhase = false;}
        }

        // No blacklisted wallets permitted! 
        require(!_isBlacklisted[to],"Wallet is blacklisted");
        require(!_isBlacklisted[from],"Wallet is blacklisted");


        // Wallet Limit
        if (!_isLimitExempt[to])
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "Over max");
            }


        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from])
            {
            require(amount <= max_Tran, "Over limit");
            }


        // Compliance and safety checks
        require(from != address(0) && to != address(0), "Can not be 0x0");
        require(amount > 0, "Can not be 0");



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

            // Only trigger fee processing if over min swap limit
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


        // Only charge a fee on buys and sells, no fee for wallet transfers
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (!_isPair[to] && !_isPair[from]) || noFee){
            takeFee = false;
        } 


        _tokenTransfer(from, to, amount, takeFee);

    }


    // Process fees
    function swapAndLiquify(uint256 Tokens) private {

        /*
        
        Fees are processed as an average over all buys and sells         

        */

        // Lock swapAndLiquify function
        inSwapAndLiquify        = true;  

        uint256 _FeesTotal      = (_SwapFeeTotal_Buy + _SwapFeeTotal_Sell);
        uint256 LP_Tokens       = Tokens * (_fee_Buy_Liquidity + _fee_Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap tokens for BNB
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors if fee is an odd number
        uint256 fee_Split = _FeesTotal * 2 - (_fee_Buy_Liquidity + _fee_Sell_Liquidity);

        // Calculate the BNB values for each fee
        uint256 BNB_Liquidity   = returned_BNB * (_fee_Buy_Liquidity     + _fee_Sell_Liquidity)       / fee_Split;
        uint256 BNB_Contract    = returned_BNB * (_fee_Buy_Contract      + _fee_Sell_Contract)    * 2 / fee_Split;

        // Add liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }
   

        // Take developer fee
        if(BNB_Contract > 0){

        // Check Affiliate is genuine - (Holds the TokensByGEN Affiliate Token)
        if(AFF.balanceOf(TokensByGEN_Affiliate) > 0){

                if(GEN.balanceOf(TokensByGEN_Affiliate) >= Tier_3){

                // Tier 3 - Split 70% Contract, 20% Affiliate, 10% Client
                TokensByGEN_Affiliate.transfer(BNB_Contract * 20 / 100);
                feeCollector.transfer(BNB_Contract * 70 / 100); 


                } else if (GEN.balanceOf(TokensByGEN_Affiliate) >= Tier_2){

                // Tier 2 - Split 75% Contract, 15% Affiliate, 10% Client
                TokensByGEN_Affiliate.transfer(BNB_Contract * 15 / 100);
                feeCollector.transfer(BNB_Contract * 75 / 100); 


                } else {

                // Tier 1 - Split 80% Contract, 10% Affiliate, 10% Client
                TokensByGEN_Affiliate.transfer(BNB_Contract * 10 / 100);
                feeCollector.transfer(BNB_Contract * 80 / 100); 

                }

        } else {

            // No affiliate 100% of contract fee to fee collector 
            feeCollector.transfer(BNB_Contract); 
        }
        
        // Send remaining BNB to BNB wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
        Wallet_BNB.transfer(contract_BNB); 
        }

        } // End of processing contract BNB

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



    // Add liquidity and send Cake LP tokens to contract to auto lock
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            address(this), 
            block.timestamp
        );
    } 







    /*

    TAKE FEES

    */


    // Take non-token fees and add to contract
    function _takeSwap(uint256 _tSwapFeeTotal, uint256 _rSwapFeeTotal) private {

        _rOwned[address(this)] = _rOwned[address(this)] + _rSwapFeeTotal;
        if(_isExcluded[address(this)])
        _tOwned[address(this)] = _tOwned[address(this)] + _tSwapFeeTotal;

    }


    // Take the Tokens fee
    function _takeTokens(uint256 _tTokens, uint256 _rTokens) private {

        _rOwned[Wallet_Tokens] = _rOwned[Wallet_Tokens] + _rTokens;
        if(_isExcluded[Wallet_Tokens])
        _tOwned[Wallet_Tokens] = _tOwned[Wallet_Tokens] + _tTokens;

    }

    // Adjust RFI for reflection balance
    function _takeReflect(uint256 _tReflect, uint256 _rReflect) private {

        _rTotal = _rTotal - _rReflect;
        _tFeeTotal = _tFeeTotal + _tReflect;

    }








    /*

    TRANSFER TOKENS AND CALCULATE FEES

    */


    uint256 private tAmount;
    uint256 private rAmount;

    uint256 private tBurn;
    uint256 private rBurn;
    uint256 private tReflect;
    uint256 private rReflect;
    uint256 private tTokens;
    uint256 private rTokens;
    uint256 private tSwapFeeTotal;
    uint256 private rSwapFeeTotal;
    uint256 private tTransferAmount;
    uint256 private rTransferAmount;

    

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {

        // Calculate the transfer fees
        tAmount = amount;

        if (!takeFee){

            tBurn           = 0;    // Auto Burn Fee
            tTokens         = 0;    // Tokens to external wallet fee
            tReflect        = 0;    // Reflection Fee
            tSwapFeeTotal   = 0;    // BNB, Liquidity and Contract Fee

        } else {

        // Increase the transaction counter - only increase if required to save gas on buys when already in trigger zone
        if (swapCounter < swapTrigger){
            swapCounter++;
            }

        if(_isPair[sender]){

            // Buy fees
            tBurn           = tAmount * _fee_Buy_Burn        / 100;
            tTokens         = tAmount * _fee_Buy_Tokens      / 100;
            tReflect        = tAmount * _fee_Buy_Reflection  / 100;
            tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy    / 100;

        } else {

            // Sell fees
            tBurn           = tAmount * _fee_Sell_Burn       / 100;
            tTokens         = tAmount * _fee_Sell_Tokens     / 100;
            tReflect        = tAmount * _fee_Sell_Reflection / 100;
            tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell   / 100;

        }
        }

        // Calculate reflected fees for RFI
        uint256 RFI     = _getRate(); 

        rAmount         = tAmount       * RFI;
        rBurn           = tBurn         * RFI;
        rTokens         = tTokens       * RFI;
        rReflect        = tReflect      * RFI;
        rSwapFeeTotal   = tSwapFeeTotal * RFI;
        tTransferAmount = tAmount - (tBurn + tTokens + tReflect + tSwapFeeTotal);
        rTransferAmount = rAmount - (rBurn + rTokens + rReflect + rSwapFeeTotal);

        
        // Swap tokens based on RFI status of sender and recipient
        if (_isExcluded[sender] && !_isExcluded[recipient]) {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal = _tTotal - tTransferAmount;
        _rTotal = _rTotal - rTransferAmount;

        } else {

        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {

        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal = _tTotal - tTransferAmount;
        _rTotal = _rTotal - rTransferAmount;

        } else {

        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {

        _rOwned[sender]     = _rOwned[sender] - rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal = _tTotal - tTransferAmount;
        _rTotal = _rTotal - rTransferAmount;

        } else {

        _rOwned[recipient]  = _rOwned[recipient] + rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (_isExcluded[sender] && _isExcluded[recipient]) {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal = _tTotal - tTransferAmount;
        _rTotal = _rTotal - rTransferAmount;

        } else {

        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        } else {

        _rOwned[sender]     = _rOwned[sender] - rAmount;

        if (deflationaryBurn && recipient == Wallet_Burn) {

        // Remove tokens from Total Supply 
        _tTotal = _tTotal - tTransferAmount;
        _rTotal = _rTotal - rTransferAmount;

        } else {

        _rOwned[recipient]  = _rOwned[recipient] + rTransferAmount;

        }

        emit Transfer(sender, recipient, tTransferAmount);

        }


        // Remove Deflationary Burn from Total Supply
        if(tBurn != 0){

            _tTotal = _tTotal - tBurn;
            _rTotal = _rTotal - rBurn;

        }


        // Update reflections
        if(tReflect != 0){_takeReflect(tReflect, rReflect);}


        // Take token fee
        if(tTokens != 0){_takeTokens(tTokens, rTokens);}


        // Take fees that require processing during swap and liquify
        if(tSwapFeeTotal != 0){_takeSwap(tSwapFeeTotal, rSwapFeeTotal);}



    }



    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}




}
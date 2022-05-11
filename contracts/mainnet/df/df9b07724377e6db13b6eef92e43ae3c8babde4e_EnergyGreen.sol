/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: Unlicensed 
// Unlicensed is NOT Open Source, this contract can not be used/forked without permission 
// Custom Contract Created by https://gentokens.com/


/*

Token name:     Energy Green
Symbol:         EGRN
Supply:         200,000,000
Decimals:       5
Website:        https://energy-green.io/

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






contract EnergyGreen is Context, IERC20 { 

    using SafeMath  for uint256;
    using Address   for address;

    constructor () {
              
        _owner = 0xDc17776AA1ad79c4BE3BA34E6e91ab63B4606FB8;
        emit OwnershipTransferred(address(0), _owner);

        _tOwned[owner()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            
        // Create Pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // Wallets that are excluded from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[Wallet_Burn] = true;
        _isExcludedFromFee[address(this)] = true;

        // Wallets that are not restricted by transaction and holding limits
        _limitExempt[owner()] = true;
        _limitExempt[Wallet_Burn] = true;
        _limitExempt[Wallet_Tokens] = true;
        _limitExempt[address(this)] = true;
        _limitExempt[uniswapV2Pair] = true;    

        // Wallets granted access before trade is open
        _preLaunchAccess[owner()] = true;

        // Set the initial liquidity pair
        _isPair[uniswapV2Pair] = true;    

        emit Transfer(address(0), owner(), _tTotal);
    }












    /*

    This contract uses a non-standard 'onlyOwner' modifier.

    The owner has the ability to grant the contract developer access to 'onlyOwner' functions. 
    This can be done by setting 'Developer_Access' to true. 

    If 'Developer_Access' is true, any function that has the 'onlyOwner' modifier can be accessed by the contract developer.
    If 'Developer_Access' is set to false, then only the current owner has access.

    Access can only be granted by the owner.
    Once granted, access can be revoked by the owner or the developer.

    If the contract is renounced, 'Developer_Access' is automatically set to false to prevent fake renouncing of the contract.

    */


    // Allows owner (and contract developer if Developer_Access is true) access to 'onlyOwner' functions
    modifier onlyOwner {

        if(!Developer_Access){
            require(_owner == msg.sender, "Caller must be owner");
            } else {
            require((_owner == msg.sender || Wallet_Contract_Dev == msg.sender), "Caller must be contract developer or owner");
            }
        _;

    }











    // Balances
    mapping (address => uint256) private _tOwned;

    // Allowances
    mapping (address => mapping (address => uint256)) private _allowances;

    // Wallet does not pay fee during buys/sells
    mapping (address => bool) public _isExcludedFromFee;

    // Wallet has access when trade is not open
    mapping (address => bool) public _preLaunchAccess;

    // Wallet is not limited by transaction or holding restrictions
    mapping (address => bool) public _limitExempt;

    // Wallet is identified as a snipe bot user
    mapping (address => bool) public _isSnipe;

    // Wallet is pair
    mapping (address => bool) public _isPair;

    // BNB Liquidity pair
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // Owner
    address public _owner;

    // Transfer Ownership - Suggested new owner wallet (must be confirmed)
    address public suggested_New_Owner_Wallet = 0xDc17776AA1ad79c4BE3BA34E6e91ab63B4606FB8;

    // Update Confirmation Wallet for Multi-Sig - Suggested new wallet (must be confirmed)
    address public suggested_New_MultiSig_2nd_Wallet = 0xb3876070971Dd4Cd1e9069be66d772Ab3Bb515D8;

    // Confirmation wallet for Multi-Sig (Required for Transfer/Renounce Ownership)
    address public Wallet_MultiSig = 0xb3876070971Dd4Cd1e9069be66d772Ab3Bb515D8;
    
    // Fee processing wallets
    address payable public Wallet_Marketing     = payable(0xb3876070971Dd4Cd1e9069be66d772Ab3Bb515D8); 
    address payable public Wallet_Contract_Dev  = payable(0xFBA603399eE440B08C72b7eDB2f3E4B48C2D4b88); 
    address payable public Wallet_Developer     = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975); 
    address payable public Wallet_Liquidity     = payable(0xDc17776AA1ad79c4BE3BA34E6e91ab63B4606FB8);
    address payable public Wallet_Team          = payable(0x071d38EF886C5d3d9CE5c6c8C12fa9B284824809);
    address payable public Wallet_Treasury      = payable(0x249E3649105653e5cd5b1E373C5bfEBd008e0Dc8);
    address payable public Wallet_Tokens        = payable(0xb3876070971Dd4Cd1e9069be66d772Ab3Bb515D8); 

    // Burn wallet to track deflationary burns
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 

    // Deflationary Burn - Tokens Sent to Burn are removed from total supply if set to true
    bool public deflationaryBurn = false;


    // Token info
    uint256 private constant _decimals = 5; 
    uint256 private _tTotal = 2 * 10 ** 8 * 10 ** _decimals; 
    string  private constant _name = "Energy Green";
    string  private constant _symbol = "EGRN";


    /*

    For pre-sale, contract is deployed with all fees set to 0 and no transaction limits

    */

    // Fees on Buys - Factor of 100
    uint256 public Fee_BUY_Marketing        = 0;
    uint256 public Fee_BUY_Liquidity        = 0;
    uint256 public Fee_BUY_Treasury         = 0;
    uint256 public Fee_BUY_Team             = 0;
    uint256 public Fee_BUY_Tokens           = 0;
    uint256 public Fee_BUY_Burn             = 0; 
    uint256 public Fee_BUY_Contract         = 0;

    // Fees on Sells - Factor of 100
    uint256 public Fee_SELL_Marketing       = 0;
    uint256 public Fee_SELL_Liquidity       = 0;
    uint256 public Fee_SELL_Treasury        = 0;
    uint256 public Fee_SELL_Team            = 0;
    uint256 public Fee_SELL_Tokens          = 0;
    uint256 public Fee_SELL_Burn            = 0; 
    uint256 public Fee_SELL_Contract        = 0; 

    uint256 public Fee_Total_BUY            = 0;
    uint256 public Fee_Total_SELL           = 0;

    // Fees for processing
    uint256 private Fee_Process_BUY         = 0;
    uint256 private Fee_Process_SELL        = 0;

    // To allow precise fee setting (up to 2 decimals)
    uint256 public Fee_Divisor              = 100; 



    // No limits during deployment for pre-sale settings - update post deployment
    uint256 public max_HOLD = _tTotal;
    uint256 public max_TRAN = _tTotal;

    // Min tokens for swap 10 Tokens
    uint256 public min_SWAP = 10 * 10 ** _decimals;

    // Max tokens for swap 0.5% (Max amount of tokens that the contract can process at one time)
    uint256 public max_SWAP = _tTotal / 200;

    // Number of transaction required to trigger fee processing - 11 is 10 transactions as the counter resets to 1 to reduce gas fees
    uint256 private swapTrigger = 11; 

    // Counter for swapTrigger - resets to 1 to reduce gas during counts
    uint256 private txCount = 1;

    // Default = true (no fee when moving tokens wallet to wallet)
    bool public noFeeToTransfer = true; 

    // Default = True (Contract processing fees automatically)
    bool public swapAndLiquifyEnabled = true;  

    // Default = True - False at launch to allow safe deployment and price setting
    bool public TradeOpen = false; 

    // Processing fees
    bool public inSwapAndLiquify;

    // Used for MultiSig - Ownership transfer, renounce and confirmation wallet updates
    bool public multiSig_Renounce_Ownership_ASKED = false;
    bool public multiSig_Transfer_Ownership_ASKED = false;
    bool public multiSig_Update_2nd_Wallet_ASKED = false;

    // Allows contract developer access to 'onlyOwner' functions - Can be granted/revoked by owner
    bool public Developer_Access = true;







    // Events
    event updated_Developer_Access(bool Developer_Access);
    event updated_noFeeToTransfer(bool Transfer_Without_Fees);
    event updated_openTrade(bool TradeOpen);
    event updated_SwapAndLiquifyEnabledUpdated(bool Swap_And_Liquify_Enabled);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_limitExempt(address account, bool Limit_Exempt);
    event updated_preLaunchAccess(address account, bool Pre_Launch_Access);
    event updated_isPair(address wallet, bool Is_Pair);
    event updated_ExcludedFromFee(address account, bool Pays_Fees);
    event updated_Wallet_Marketing(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Liquidity(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Team(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Tokens(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Treasury(address indexed oldWallet, address indexed newWallet);
    event updated_wallet_Limits(uint256 max_HOLD, uint256 max_TRAN);
    event updated_DeflationaryBurn(bool Burn_Is_Deflationary);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event updated_Swap_Trigger_Count(uint256 number_of_transactions);
    event updated_Swap_Trigger_Limits(uint256 min_SWAP, uint256 max_SWAP);
    event update_Contract_Fee(uint256 Fee_BUY_Contract, uint256 Fee_SELL_Contract);

    event updated_BUY_Fees(uint256 Fee_BUY_Marketing,
                           uint256 Fee_BUY_Liquidity,
                           uint256 Fee_BUY_Treasury,
                           uint256 Fee_BUY_Team,
                           uint256 Fee_BUY_Tokens,
                           uint256 Fee_BUY_Burn,
                           uint256 Fee_Divisor);
    
    event updated_SELL_Fees(uint256 Fee_SELL_Marketing,
                            uint256 Fee_SELL_Liquidity,
                            uint256 Fee_SELL_Treasury,
                            uint256 Fee_SELL_Team,
                            uint256 Fee_SELL_Tokens,
                            uint256 Fee_SELL_Burn,
                            uint256 Fee_Divisor);









    

    /*

    Standard Token functions and BEP20 Compliance

    */


    function owner() public view virtual returns (address) {
        return _owner;
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
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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




    /* 

    EXTERNAL FUNCTIONS

    On the following functions, the onlyOwner modifier includes optional developer access 

    To assist with setting up the contract or making future adjustments the original solidity developer has access to 
    functions that are set to 'onlyOwner' using a modifier if the boolean 'Developer_Access' is set to true.

    The function that allows 'Developer_Access' to be updated has the onlyOwner modifier. 

    This means that when set to true, the owner OR the developer can revoke developer access and set to false.
    However, when set to false, only the owner can grant access.

    This allows the owner to 'ask for help' from the developer if required, and control developer access rights.

    */


    function Allow_Developer_Access(bool true_or_false) external onlyOwner {
        Developer_Access = true_or_false;
        emit updated_Developer_Access(Developer_Access);
    }


    function PreSale_Begin(address PreSaleWallet) external onlyOwner {

        // PreSale wallet settings
        _limitExempt[PreSaleWallet]         = true;
        _preLaunchAccess[PreSaleWallet]     = true;
        _isExcludedFromFee[PreSaleWallet]   = true;
        swapAndLiquifyEnabled               = false;

    }


    function PreSale_End() external onlyOwner {

        // Contract setup
        swapAndLiquifyEnabled = true;
        max_HOLD              = _tTotal / 100;
        max_TRAN              = _tTotal / 100;

        // Set fees for public launch 
        Fee_BUY_Liquidity     = 425;
        Fee_BUY_Team          = 150;
        Fee_BUY_Contract      = 25;

        Fee_Total_BUY         = 600;
        Fee_Process_BUY       = 600;

        Fee_SELL_Liquidity    = 575;
        Fee_SELL_Treasury     = 150;
        Fee_SELL_Team         = 150;
        Fee_SELL_Contract     = 25;

        Fee_Total_SELL        = 900;
        Fee_Process_SELL      = 900;

    }


    function PreSale_Revoke(address PreSaleWallet) external onlyOwner {

        // Remove PreSale wallet privileges
        _limitExempt[PreSaleWallet]         = false;
        _preLaunchAccess[PreSaleWallet]     = false;
        _isExcludedFromFee[PreSaleWallet]   = false;

    }





    /*

    Transfer OwnerShip, Renounce Ownership, and Update Multi-Sig Wallet all require Multi-Sig security!
    
    If a hacker gains access to the owner wallet private-key they can change various functions.
    The most important of these are transfer and renounce ownership. 

    Both of these functions are protected by multi-signature requirements. 

    Should a hacker gain access to the owner wallet, the genuine owner can transfer ownership to a new, safe wallet.
    The genuine owner can then revert any changes made by the hacker.

    */

    // Transfer Ownership - Requires Multi-Sig
    function multiSig_Transfer_Ownership_ASK(address newOwner_Request) external onlyOwner {

        require(!multiSig_Transfer_Ownership_ASKED, "Already asked, wait confirmation");
        require(newOwner_Request != address(0), "New owner can not be zero address");
        multiSig_Transfer_Ownership_ASKED = true;
        suggested_New_Owner_Wallet = newOwner_Request;

    }

    function multiSig_Transfer_Ownership_CONFIRM(bool true_or_false) external {

        require(msg.sender == Wallet_MultiSig, "Confirmation wallet must confirm");
        require (multiSig_Transfer_Ownership_ASKED, "Transfering Ownership not requested");

        if (true_or_false){

        // Transfer ownership and reset ask permissions
        emit OwnershipTransferred(_owner, suggested_New_Owner_Wallet);

        // Remove old owner privileges
        _isExcludedFromFee[owner()] = false;
        _limitExempt[owner()] = false;

        // Change owner
        _owner = suggested_New_Owner_Wallet;

        // Reset ask permissions
        multiSig_Transfer_Ownership_ASKED = false;

        // Set new owner privileges
        _isExcludedFromFee[owner()] = true;
        _limitExempt[owner()] = true;

        } else {

        // Reset ask permissions
        multiSig_Transfer_Ownership_ASKED = false;

        }

    }

    // Renounce Ownership - Requires Multi-Sig
    function multiSig_Renounce_Ownership_ASK() external onlyOwner {

        require (!multiSig_Renounce_Ownership_ASKED, "Already asked, wait confirmation");
        multiSig_Renounce_Ownership_ASKED = true;
    }

    function multiSig_Renounce_Ownership_CONFIRM(bool true_or_false) external {

        require(msg.sender == Wallet_MultiSig, "Confirmation wallet must confirm");
        require(multiSig_Renounce_Ownership_ASKED, "Renounce not requested");

        if (true_or_false){

        // Renounce ownership of contract
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);

        // Revoke developer access
        if (Developer_Access){
        Developer_Access = false;
        emit updated_Developer_Access(Developer_Access);}
        } else {

        // Reset ask permissions
        multiSig_Renounce_Ownership_ASKED = false;

        }
    }

    // Update MultiSig 2nd Wallet - Requires Multi-Sig
    function multiSig_Update_2nd_Wallet_ASK(address payable new_MultiSig_2nd_Wallet) external onlyOwner {

        require(suggested_New_MultiSig_2nd_Wallet != address(0), "Can not be zero address");
        require(!multiSig_Update_2nd_Wallet_ASKED, "Already asked, wait confirmation");
        suggested_New_MultiSig_2nd_Wallet = new_MultiSig_2nd_Wallet;
        multiSig_Update_2nd_Wallet_ASKED = true;

    }

    function multiSig_Update_2nd_Wallet_CONFIRM(bool true_or_false) external {

        require(msg.sender == Wallet_MultiSig, "Confirmation wallet must confirm");
        require(multiSig_Update_2nd_Wallet_ASKED, "Change not requested");
        if(true_or_false){
                multiSig_Update_2nd_Wallet_ASKED = false;
                Wallet_MultiSig = suggested_New_MultiSig_2nd_Wallet;
            } else {
                multiSig_Update_2nd_Wallet_ASKED = false;
            }
        }


    /*

    Deflationary Burn Switch - By default this is set to false
    
    If true, when tokens are sent to the burn wallet 0x000000000000000000000000000000000000dEaD
    They will not arrive in the burn wallet, instead they will be removed from the senders balance and removed from the total supply

    If set to false, any tokens sent to the burn wallet will not be removed from total supply and will be added to the burn wallet balance

    */

    function Deflationary_Burn(bool true_or_false) external onlyOwner {
        deflationaryBurn = true_or_false;
        emit updated_DeflationaryBurn(deflationaryBurn);
    }

    






    // Update the marketing wallet
    function Update_Wallet_Marketing(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Marketing(Wallet_Marketing,wallet);
        Wallet_Marketing = wallet;
    }

    // Update the wallet that collects the CakeLP tokens when auto liquidity is added
    function Update_Wallet_Liquidity(address payable wallet) external onlyOwner {

        // Can't be zero address
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Liquidity(Wallet_Liquidity,wallet);
        Wallet_Liquidity = wallet;
    }

    // Update the Team wallet
    function Update_Wallet_Team(address payable wallet) external onlyOwner {

        // Can't be zero address
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Team(Wallet_Team, wallet);
        Wallet_Team = wallet;
    }


    // Update the Treasury wallet
    function Update_Wallet_Treasury(address payable wallet) external onlyOwner {

        // Can't be zero address
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Treasury(Wallet_Treasury, wallet);
        Wallet_Treasury = wallet;
    }

    // Update the Token wallet - Must be limit exempt!
    function Update_Wallet_Tokens(address payable wallet) external onlyOwner {

        // Can't be zero address
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Tokens(Wallet_Tokens, wallet);

        // Update old wallet
        _limitExempt[Wallet_Tokens] = false;

        Wallet_Tokens = wallet;
        
        // Update new wallet
        _limitExempt[Wallet_Tokens] = true;
    }



    


    /*

    Swap Trigger Settings

    */

           
    // When sending tokens to another wallet (not buying or selling) if noFeeToTransfer is true there will be no fee
    function Swap_NoTransferFees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
        emit updated_noFeeToTransfer(true_or_false);
    }
    
    // Update the number of transactions needed to trigger swap
    function Swap_Trigger_Count(uint256 number_of_transactions) external onlyOwner {
        // Counter is reset to 1 (not 0 to save gas) so add one to count number
        swapTrigger = number_of_transactions + 1;
        emit updated_Swap_Trigger_Count(number_of_transactions);
    }

    // Swap Limits - Min and max number of tokens require to trigger fee processing
    function Swap_Trigger_Limits(
        uint256 min_Swap_Tokens,
        uint256 max_Swap_Tokens
        ) external onlyOwner {
        min_SWAP = min_Swap_Tokens * 10**_decimals;
        max_SWAP = max_Swap_Tokens * 10**_decimals;
        emit updated_Swap_Trigger_Limits(min_SWAP, max_SWAP);
    }

    // Toggles fee processing - Use the 'Swap Now' function to manually process fees if set to false
    function Swap_Enabled(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquifyEnabledUpdated(true_or_false);
    }

    // Process fees manually - emit included when swap and liquify is triggered 
    function Swap_Now(uint256 percent_Of_Tokens_To_Liquify) external onlyOwner {
        require(!inSwapAndLiquify, "In swap"); 
        if (percent_Of_Tokens_To_Liquify > 100){percent_Of_Tokens_To_Liquify == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * percent_Of_Tokens_To_Liquify / 100;
        // Manual swap is limited by the max_SWAP setting
        if (sendTokens > max_SWAP){sendTokens = max_SWAP;}
        swapAndLiquify(sendTokens);
    }

    // Purge random tokens from the contract
    function Token_Purge(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){
        // Can not purge the native token!
        require (random_Token_Address != address(this), "Can not remove native token, must be processed via SwapAndLiquify");
        if(percent_of_Tokens > 100){percent_of_Tokens = 100;}
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        _sent = IERC20(random_Token_Address).transfer(msg.sender, removeRandom);

    }








    /*

    Address Mappings

    */


    // Limit exempt - used to allow a wallet to hold more than the max limit - for locking tokens etc
    function Mapping_limitExempt(address account, bool true_or_false) external onlyOwner {    
        _limitExempt[account] = true_or_false;
        emit updated_limitExempt(account, true_or_false);
    }

    // Pre-Launch Access - permission to buy and sell before the trade is open
    function Mapping_preLaunchAccess(address account, bool true_or_false) external onlyOwner {    
        _preLaunchAccess[account] = true_or_false;
        emit updated_preLaunchAccess(account, true_or_false);
    }

    // Set as pair 
    function Mapping_isPair(address wallet, bool true_or_false) external onlyOwner {
        _isPair[wallet] = true_or_false;
        emit updated_isPair(wallet, true_or_false);
    }

    // Set a wallet address so that it does not have to pay transaction fees
    function Mapping_ExcludedFromFee(address account, bool true_or_false) external onlyOwner {
        _isExcludedFromFee[account] = true_or_false;
        emit updated_ExcludedFromFee(account, true_or_false);
    }
    
    
    



    /*

    Fees on buys and sells use a divisor of 100 (25 = 0.25% 100 = 1% 300 = 3% etc.)

    */


    function Set_Fees_For_Buys_x100_max975(uint256 BUY_Marketing__x100,
                                    uint256 BUY_Liquidity__x100,
                                    uint256 BUY_Treasury__x100,
                                    uint256 BUY_Team__x100,
                                    uint256 BUY_Tokens__x100,   
                                    uint256 BUY_Burn__x100

                      ) external onlyOwner {

                      uint256 Total_BUY =  BUY_Marketing__x100 +
                                           BUY_Liquidity__x100 +
                                           BUY_Treasury__x100  +
                                           BUY_Team__x100      +
                                           BUY_Tokens__x100    +
                                           BUY_Burn__x100      +
                                           Fee_BUY_Contract;

                      // Check total buy fees are not over 10% 
                      require(Total_BUY <= (10 * Fee_Divisor), "Buy fee too high");

                      // Update fees
                      Fee_BUY_Marketing  = BUY_Marketing__x100;
                      Fee_BUY_Liquidity  = BUY_Liquidity__x100;
                      Fee_BUY_Treasury   = BUY_Treasury__x100;
                      Fee_BUY_Team       = BUY_Team__x100;
                      Fee_BUY_Tokens     = BUY_Tokens__x100;
                      Fee_BUY_Burn       = BUY_Burn__x100;

                      // Update fee totals 
                      Fee_Total_BUY      = Total_BUY;

                      // Update fees for processing
                      Fee_Process_BUY  = Fee_Total_BUY   - (Fee_BUY_Burn + Fee_BUY_Tokens);

                      emit updated_BUY_Fees(Fee_BUY_Marketing,
                                            Fee_BUY_Liquidity,
                                            Fee_BUY_Treasury,
                                            Fee_BUY_Team,
                                            Fee_BUY_Tokens,
                                            Fee_BUY_Burn,
                                            Fee_Divisor);

    }


    function Set_Fees_For_Sells_x100_max1475(uint256 SELL_Marketing__x100,
                                     uint256 SELL_Liquidity__x100,
                                     uint256 SELL_Treasury__x100,
                                     uint256 SELL_Team__x100,
                                     uint256 SELL_Tokens__x100,   
                                     uint256 SELL_Burn__x100

                      ) external onlyOwner {

                      uint256 Total_SELL = SELL_Marketing__x100 +
                                           SELL_Liquidity__x100 +
                                           SELL_Treasury__x100  +
                                           SELL_Team__x100      +
                                           SELL_Tokens__x100    +
                                           SELL_Burn__x100      +
                                           Fee_SELL_Contract;

                      // Check total sell fees are not over 15%
                      require(Total_SELL <= (15 * Fee_Divisor), "Sell fee too high");

                      // Update fees
                      Fee_SELL_Marketing = SELL_Marketing__x100;
                      Fee_SELL_Liquidity = SELL_Liquidity__x100;
                      Fee_SELL_Treasury  = SELL_Treasury__x100;
                      Fee_SELL_Team      = SELL_Team__x100;
                      Fee_SELL_Tokens    = SELL_Tokens__x100;
                      Fee_SELL_Burn      = SELL_Burn__x100;

                      // Update fee totals 
                      Fee_Total_SELL     = Total_SELL;

                      // Update fees for processing
                      Fee_Process_SELL = Fee_Total_SELL  - (Fee_SELL_Burn + Fee_SELL_Tokens);

                      emit updated_SELL_Fees(Fee_SELL_Marketing,
                                             Fee_SELL_Liquidity,
                                             Fee_SELL_Treasury,
                                             Fee_SELL_Team,
                                             Fee_SELL_Tokens,
                                             Fee_SELL_Burn,
                                             Fee_Divisor);

    }

    function Set_Contract_Fee_x100(uint256 ContractFeeBUY, uint256 ContractFeeSELL) external {

        // Can only be updated by contract developer - allows reduction of contract fee in future
        require(msg.sender == Wallet_Contract_Dev, "Only Contract Developer can Update");

        // Restrict contract fee to 0.25% Max - This function is only for reducing the contract fee!
        require(ContractFeeBUY  <= 25, "Max possible is 0.25%");
        require(ContractFeeSELL <= 25, "Max possible is 0.25%");

        // Update contract fees
        Fee_BUY_Contract    = ContractFeeBUY;
        Fee_SELL_Contract   = ContractFeeSELL;

        emit update_Contract_Fee(Fee_BUY_Contract, Fee_SELL_Contract);

        // Update Fee Totals
        Fee_Total_BUY       = Fee_BUY_Marketing   +
                              Fee_BUY_Liquidity   +
                              Fee_BUY_Treasury    +
                              Fee_BUY_Team        +
                              Fee_BUY_Tokens      +
                              Fee_BUY_Burn        +
                              Fee_BUY_Contract;

        Fee_Process_BUY     = Fee_BUY_Marketing   +
                              Fee_BUY_Liquidity   +
                              Fee_BUY_Treasury    +
                              Fee_BUY_Team        +
                              Fee_BUY_Contract;

        Fee_Total_SELL      = Fee_SELL_Marketing  +
                              Fee_SELL_Liquidity  +
                              Fee_SELL_Treasury   +
                              Fee_SELL_Team       +
                              Fee_SELL_Tokens     +
                              Fee_SELL_Burn       +
                              Fee_SELL_Contract;

        Fee_Process_SELL    = Fee_SELL_Marketing  +
                              Fee_SELL_Liquidity  +
                              Fee_SELL_Treasury   +
                              Fee_SELL_Team       +
                              Fee_SELL_Contract;

        }





    




    /*

    Wallet Limits

    Wallets are limited in two ways. The amount of tokens that can be purchased in one transaction
    and the total amount of tokens a wallet can hold. Limiting a wallet prevents one wallet from holding too
    many tokens, which can scare away potential buyers that worry that a whale might dump!

    max_Swap_Tokens sets the maximum amount of tokens that the contract can swap during swap and liquify.

    (When setting values do not include decimals)

    limitExempt wallets are excluded from Transaction and Holding limits.

    */

    // Wallet Holding, Transaction, and Swap Limits
    function Limit_Settings(

        uint256 max_Tran_Tokens,
        uint256 max_Hold_Tokens

        ) external onlyOwner {

        require(max_Hold_Tokens > 0, "Must be greater than zero");
        require(max_Tran_Tokens > 0, "Must be greater than zero");
        
        max_HOLD = max_Hold_Tokens * 10**_decimals;
        max_TRAN = max_Tran_Tokens * 10**_decimals;

        emit updated_wallet_Limits(max_HOLD, max_TRAN);

    }




    
    // Open Trade - One way switch for buyer protection
    function Trade_Open() external onlyOwner {
        TradeOpen = true;
        emit updated_openTrade(TradeOpen);

    }












    /*

    INTERNAL FUNCTIONS

    */



    // Where the magic happens!
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        // If trade is not open, wallets must have pre-launch access
        if (!TradeOpen){
            require(_preLaunchAccess[from] || _preLaunchAccess[to], "Trade not open");
        }


        // Limit wallet total
        if (!_limitExempt[to]){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_HOLD, "Over max wallet");
        }

        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (!_limitExempt[to] || !_limitExempt[from]){
            require(amount <= max_TRAN, "Over max transaction");
        }

        // Compliance and safety checks
        require(from != address(0) && to != address(0), "Zero address");
        require(amount > 0, "Must be greater than 0");

        // Check if swap required
        if( _isPair[to] &&
            txCount > swapTrigger &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
            )
        {  
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance < max_SWAP)
                {
                    swapAndLiquify(contractTokenBalance);
                    } else {
                    swapAndLiquify(max_SWAP);
                }            

        }



        // Check if fee required
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } else {

        // Increase the swap counter if not already in trigger zone 
        if (txCount <= swapTrigger){
        txCount++;
        }

        }
        
        _tokenTransfer(from,to,amount,takeFee);
        
    }



    
    // Process the fees
    function swapAndLiquify(uint256 contractTokenBalance) private {

        // Lock to prevent access while swapping
        inSwapAndLiquify        = true;

        uint256 _FeesTotal      = (Fee_Process_BUY + Fee_Process_SELL);
        uint256 LP_Tokens       = contractTokenBalance * (Fee_BUY_Liquidity + Fee_SELL_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = contractTokenBalance - LP_Tokens;

        // Swap tokens for BNB
        uint256 contract_BNB    = address(this).balance;
        swapTokensForEth(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors if LP fee is to an odd number
        uint256 fee_Split       = _FeesTotal * 2 - (Fee_BUY_Liquidity + Fee_SELL_Liquidity);

        // Calculate the BNB values for each fee (excluding marketing)
        uint256 BNB_Liquidity   = returned_BNB * (Fee_BUY_Liquidity     + Fee_SELL_Liquidity)       / fee_Split;
        uint256 BNB_Contract    = returned_BNB * (Fee_BUY_Contract      + Fee_SELL_Contract)    * 2 / fee_Split;
        uint256 BNB_Team        = returned_BNB * (Fee_BUY_Team          + Fee_SELL_Team)        * 2 / fee_Split;
        uint256 BNB_Treasury    = returned_BNB * (Fee_BUY_Treasury      + Fee_SELL_Treasury)    * 2 / fee_Split;

        // Add liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }

        // Take developer fee
        if(BNB_Contract > 0){
        sendToWallet(Wallet_Developer, BNB_Contract);
        }

        // Take team fee
        if(BNB_Team > 0){
        sendToWallet(Wallet_Team, BNB_Team);
        }

        // Take treasury fee
        if(BNB_Treasury > 0){
        sendToWallet(Wallet_Treasury, BNB_Treasury);
        }
        
        // Send remaining BNB to marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
            sendToWallet(Wallet_Marketing, contract_BNB);
        }

        // Reset transaction counter
        txCount = 1;

        // Unlock the swap
        inSwapAndLiquify = false;


    }

    // Swap tokens to BNB (Will show as a sell on the chart)
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

    // Create auto liquidity and send Cake_LP tokens to liquidity collection wallet
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            Wallet_Liquidity,
            block.timestamp
        );
    } 

    // Transfer tokens and handle fees
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {         
        
        if(!takeFee){

        // TRANSFERING TOKENS WITHOUT A FEE

        _tOwned[sender] = _tOwned[sender] - tAmount;

        // Check if burn is deflationary 
        if (deflationaryBurn && recipient == Wallet_Burn) {
        // Remove Tokens From Total Supply    
        _tTotal = _tTotal - tAmount;
        } else {
        _tOwned[recipient] = _tOwned[recipient] + tAmount;
        }

        emit Transfer(sender, recipient, tAmount);

        } else if (_isPair[sender]){

        // THIS IS A BUY

        // Calculate fees 
        uint256 totalBUYFees    = tAmount * Fee_Total_BUY   / 100 / Fee_Divisor;    // Total fees on Buys
        uint256 tokenBUYFee     = tAmount * Fee_BUY_Tokens  / 100 / Fee_Divisor;    // Token fee on buys
        uint256 burnBUYFee      = tAmount * Fee_BUY_Burn    / 100 / Fee_Divisor;    // Burn fee on buys

        // To remove rounding errors - non-process fees from total
        uint256 processBUYFees  = totalBUYFees - (tokenBUYFee + burnBUYFee);        // Fees on Buys that need processing

        // Calculate the transfer amount
        uint256 tTransferAmount = tAmount - totalBUYFees;

        // Remove tokens from sender
        _tOwned[sender] = _tOwned[sender] - tAmount;


        // Check if burn is deflationary 
        if (deflationaryBurn && recipient == Wallet_Burn) {
        // Remove Tokens From Total Supply    
        _tTotal = _tTotal - tTransferAmount;
        } else {
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        }

        // Add fees that need to be processed later to the contract
        _tOwned[address(this)] = _tOwned[address(this)] + processBUYFees;

        // Process the token fees to an external wallet
        if(tokenBUYFee != 0){_takeTokens(tokenBUYFee);}

        // Remove any burn fees from the total supply
        if(burnBUYFee  != 0){_tTotal = _tTotal - burnBUYFee;}

        emit Transfer(sender, recipient, tTransferAmount);

        } else if (_isPair[recipient]) {

        // THIS IS A SELL

        // Calculate fees 
        uint256 totalSELLFees    = tAmount * Fee_Total_SELL   / 100 / Fee_Divisor;    // Total fees on Sells
        uint256 tokenSELLFee     = tAmount * Fee_SELL_Tokens  / 100 / Fee_Divisor;    // Token fee on Sells
        uint256 burnSELLFee      = tAmount * Fee_SELL_Burn    / 100 / Fee_Divisor;    // Burn fee on Sells

        // To remove rounding errors - non-process fees from total
        uint256 processSELLFees  = totalSELLFees - (tokenSELLFee + burnSELLFee);      // Fees on Sell that need processing

        // Calculate the transfer amount
        uint256 tTransferAmount = tAmount - totalSELLFees;

        // Remove tokens from sender
        _tOwned[sender] = _tOwned[sender] - tAmount;

        // Check if burn is deflationary 
        if (deflationaryBurn && recipient == Wallet_Burn) {
        // Remove Tokens From Total Supply    
        _tTotal = _tTotal - tTransferAmount;
        } else {
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        }

        // Add fees that need to be processed later to the contract
        _tOwned[address(this)] = _tOwned[address(this)] + processSELLFees;

        // Process the token fees to an external wallet
        if(tokenSELLFee != 0){_takeTokens(tokenSELLFee);}

        // Remove any burn fees from the total supply
        if(burnSELLFee  != 0){_tTotal = _tTotal - burnSELLFee;}

        emit Transfer(sender, recipient, tTransferAmount);

        }
    }


    // Take token fee and send to token wallet
    function _takeTokens(uint256 _tTokens) private {
        _tOwned[Wallet_Tokens] = _tOwned[Wallet_Tokens] + _tTokens;
    }
    

    // Send BNB to marketing and developer wallets during fee processing
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
        }

    // Allow contract to receive BNB 
    receive() external payable {}

}





















































// Custom Contract Created by https://gentokens.com/ for https://energy-green.io/
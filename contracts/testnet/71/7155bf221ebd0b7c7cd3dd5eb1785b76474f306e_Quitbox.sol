/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: Unlicensed 
// "Unlicensed" is NOT Open Source 
// This contract can not be used/forked without permission 
// Created by https://gentokens.com/ for QuitBox https://quitbox.gentokens.com


/*

Token Name:     Quitbox
Token Symbol:   QBX
Total Supply:   10,000,000,000 (10 Billion)
Decimals:       18

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






contract Quitbox is Context, IERC20 { 

    using SafeMath  for uint256;
    using Address   for address;

    constructor () {
        
        Contract_Developer = msg.sender;

        _owner = 0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0; //XXX

      //  _owner = 0xaa58de956EdeebB37a6C9Ac45B164438FdE343c8;
        emit OwnershipTransferred(address(0), _owner);

        _tOwned[owner()] = _tTotal;
        
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //<---for testing things!  
      
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
        _limitExempt[Contract_Developer] = true;
        _limitExempt[address(this)] = true;

        // Wallets granted access before trade is open
        _preLaunchAccess[owner()] = true;
        _preLaunchAccess[Contract_Developer] = true;

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
            require((_owner == msg.sender || Contract_Developer == msg.sender), "Caller must be contract developer or owner");
            }
        _;

    }


    // Prevents contract trying to process fees when already processing fees
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
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

    // Contract developer
    address public Contract_Developer; 

    // Owner
    address public _owner;

    // Transfer Ownership - Suggested new owner wallet (must be confirmed)
    address public suggested_New_Owner_Wallet;

    // Update Confirmation Wallet for Multi-Sig - Suggested new wallet (must be confirmed)
    address public suggested_New_MultiSig_2nd_Wallet;

    // Confirmation wallet for Multi-Sig (Required for Transfer/Renounce Ownership)
    address public Wallet_MultiSig = 0xD68ead5CC1fc29e307CB04596858Fc2833f7D8dc; 
    
    // Fee processing wallets
    address payable public Wallet_Marketing = payable(0xD68ead5CC1fc29e307CB04596858Fc2833f7D8dc);
    address payable public Wallet_Developer = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975);
    address payable public Wallet_Liquidity = payable(0xaa58de956EdeebB37a6C9Ac45B164438FdE343c8);

    // Burn wallet to track deflationary burns
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 

    // Token info
    uint256 private constant _decimals = 18;
    uint256 private _tTotal = 10**10 * 10**_decimals;
    string  private constant _name = "Quitbox"; 
    string  private constant _symbol = "QBX";  


    // Fees - apply to buy and sell - wallet to wallet transfers have no fee
    uint256 public _FeeLiquidity = 9;
    uint256 public _FeeMarketing = 5;
    uint256 public _FeeDeveloper = 1; 

    uint256 public _FeesTotal = _FeeMarketing + _FeeDeveloper + _FeeLiquidity;


    // Max wallet holding  (0.05% at launch) - updated to 2% at end of launch phase
    uint256 public max_HOLD = _tTotal * 5 / 10000;

    // Maximum transaction 2% 
    uint256 public max_TRAN = _tTotal / 50;

    // Max tokens for swap 1% (Max amount of tokens that the contract can process at one time)
    uint256 public max_SWAP = _tTotal / 100;

    // Number of transaction required to trigger fee processing
    uint256 private swapTrigger = 10; 

    // Counter for swapTrigger - resets to 1 to reduce gas during counts
    uint256 private txCount = 1;

    // Launch block is set when trade is opened - used to check for snipe bots 
    uint256 private launchBlock;

    // Default = true (no fee when moving tokens wallet to wallet)
    bool public noFeeToTransfer = true;

    // Default = True (Contract processing fees automatically)
    bool public swapAndLiquifyEnabled = true;

    // Default = False - True at launch only - Snipe protection
    bool public launchPhase = true;

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
    event updated_end_LaunchPhase(bool Launch_Phase);
    event updated_SwapAndLiquifyEnabledUpdated(bool Swap_And_Liquify_Enabled);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_limitExempt(address account, bool Limit_Exempt);
    event updated_preLaunchAccess(address account, bool Pre_Launch_Access);
    event updated_isSnipe(address account, bool Is_Sniper);
    event updated_isPair(address wallet, bool Is_Pair);
    event updated_ExcludedFromFee(address account, bool Pays_Fees);
    event updated_Wallet_Marketing(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Liquidity(address indexed oldWallet, address indexed newWallet);

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event updated_Swap_Trigger_Count(uint256 number_of_transactions);
    event updated_Fees(uint256 Liquidity, uint256 Marketing, uint256 Developer, uint256 Total_Fees);
    event updated_wallet_Limits(uint256 max_HOLD, uint256 max_TRAN);









    

    /*

    Standard Token functions and ERC20/BEP20 Compliance

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

    function allowance(address theOwner, address spender) external view override returns (uint256) {
        return _allowances[theOwner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address theOwner, address spender, uint256 amount) private {

        require(theOwner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[theOwner][spender] = amount;
        emit Approval(theOwner, spender, amount);

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




    /*

    Transfer OwnerShip, Renounce Ownership, and Update Multi-Sig Wallet all require Multi-Sig security!
    
    If a hacker gains access to the owner wallet private-key they can change various functions.
    The most important of these are transfer and renounce ownership. 

    Both of these functions are protected by multi-signature requirements. 

    Should a hacker gain access to the owner wallet, the genuine owner can transfer ownership to a new, safe wallet.
    The genuine owner can then revert any changes made by the hacker.

    ** NOTE TO AUDITORS **

    When transferring ownership or renouncing the contract we do NOT want to automatically remove previous owner privileges.

    In some case, to automatically remove privileges from the previous owner would cause problems. Especially if the 'new owner' is a hacker! 
    If we need to remove wallet privileges we will do so using the functions that have been created for this purpose.

    Automatically forcing one thing to happen when you are doing something else is not always good practice.

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
        _owner = suggested_New_Owner_Wallet;
        multiSig_Transfer_Ownership_ASKED = false;

        // Set new owner privileges
        // Previous owner privileges are NOT automatically removed - revoke manually if desired

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

    

    // Update the marketing wallet
    function Update_Wallet_Marketing(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Marketing(Wallet_Marketing,wallet);
        Wallet_Marketing = wallet;
    }

    // Update the wallet that collects the CakeLP tokens when auto liquidity is added
    function Update_Wallet_Liquidity(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Liquidity(Wallet_Liquidity,wallet);
        Wallet_Liquidity = wallet;
    }

   
   




        
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

    // Tag wallet using snipe bot to restrict access during launch phase
    function Mapping_isSnipe(address account, bool true_or_false) external onlyOwner {  
        _isSnipe[account] = true_or_false;
        emit updated_isSnipe(account, true_or_false);
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
    
    
    



    
    // Fees are capped at 15% (This includes 1% to developer)
    function Set_Fees(uint256 Liquidity, uint256 Marketing) external onlyOwner {

        // Buyer protection - The fees can never be set above the max possible
        require((Liquidity + Marketing + _FeeDeveloper) <= 15, "Total fees too high");

        // Set the fees
          _FeeLiquidity = Liquidity;
          _FeeMarketing = Marketing;

        // For calculations and processing 
          _FeesTotal = _FeeMarketing + _FeeDeveloper + _FeeLiquidity;

        emit updated_Fees(_FeeLiquidity,_FeeMarketing,_FeeDeveloper,_FeesTotal);

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
        uint256 max_Hold_Tokens,
        uint256 max_Swap_Tokens

        ) external onlyOwner {

        require(max_Hold_Tokens > 0, "Must be greater than zero");
        require(max_Tran_Tokens > 0, "Must be greater than zero");
        
        max_HOLD = max_Hold_Tokens * 10**_decimals;
        max_TRAN = max_Tran_Tokens * 10**_decimals;
        max_SWAP = max_Swap_Tokens * 10**_decimals;

        emit updated_wallet_Limits(max_HOLD, max_TRAN);

    }





    
    // Open Trade - One way switch for buyer protection
    function Trade_Open() external onlyOwner {
        TradeOpen = true;
        launchBlock = block.number;
        emit updated_openTrade(TradeOpen);

    }


    /*
    
    launchPhase is used to detect and restrict sniper bots.
    It will be set to false automatically when a transaction happens 20 blocks after the initial launch block number
    The following function is a one-way switch that can be used to manually end the launch phase if required.

    */


    // End Launch Phase - One way switch for buyer protection
    function Trade_End_Launch_Phase() external onlyOwner {
        launchPhase = false;
        emit updated_end_LaunchPhase(launchPhase);

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
        

        // Blocks snipe bots for first 20 Blocks (Approx 1 minute)
        if (launchPhase){
                        require((!_isSnipe[to] && !_isSnipe[from]), 'Snipe detected');
                        if (launchBlock + 1 > block.number){
                            if(_isPair[from] && to != address(this) && !_preLaunchAccess[to]){
                            _isSnipe[to] = true;
                            }
                        }

                        if ((block.number > launchBlock + 2) && (max_HOLD != _tTotal / 50)){
                            max_HOLD = _tTotal / 50; 
                        }

                        if (block.number > launchBlock + 20){
                            launchPhase = false;
                            emit updated_end_LaunchPhase(launchPhase);
                        }
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
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 LP_Tokens = contractTokenBalance * _FeeLiquidity / _FeesTotal / 2;
        uint256 Swap_Tokens = contractTokenBalance - LP_Tokens;

        // Swap tokens for BNB
        uint256 contract_BNB = address(this).balance;
        swapTokensForEth(Swap_Tokens);
        uint256 returned_BNB = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors is LP fee is 1%
        uint256 fee_Split = _FeesTotal * 2 - _FeeLiquidity;

        uint256 BNB_D = returned_BNB * _FeeDeveloper * 2 / fee_Split;
        uint256 BNB_L = returned_BNB * _FeeLiquidity / fee_Split;

        // Add liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_L);
            emit SwapAndLiquify(LP_Tokens, BNB_L, LP_Tokens);
        }

        // Take developer fee
        if(BNB_D > 0){
        sendToWallet(Wallet_Developer, BNB_D);
        }
        
        // Send remaining BNB to marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
            sendToWallet(Wallet_Marketing, contract_BNB);
        }

        // Reset transaction counter
        txCount = 1;


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

        _tOwned[sender] = _tOwned[sender] - tAmount;

        if(recipient != Wallet_Burn){

            _tOwned[recipient] = _tOwned[recipient] + tAmount;

            } else {

            _tTotal = _tTotal - tAmount;

            }


        emit Transfer(sender, recipient, tAmount);

        } else {

        uint256 tFees = tAmount * _FeesTotal / 100;
        uint256 tTransferAmount = tAmount - tFees;

        _tOwned[sender] = _tOwned[sender] - tAmount;


        if(recipient != Wallet_Burn){
        
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;

            } else {

            _tTotal = _tTotal - tTransferAmount;

            }

        _tOwned[address(this)] = _tOwned[address(this)] + tFees;

        emit Transfer(sender, recipient, tTransferAmount);

        }
    }

    // Send BNB to marketing and developer wallets during fee processing
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
        }

    // Allow contract to receive BNB 
    receive() external payable {}

}



/*

Custom Contract Created by GenTokens for QuitBox
    
https://gentokens.com/
https://quitbox.gentokens.com

*/
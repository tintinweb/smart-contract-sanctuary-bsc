/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.10;

interface IERC2222 {
    
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


contract myway is Context, IERC2222 { 

    using SafeMath for uint256;
    using Address for address;

    address public _owner;
    address public Wallet_Liquidity;
    address payable public Wallet_Marketing;

    // Only used if the 1% transaction fee option is chosen 
    address payable public feeCollector = payable(0xD05d2156DbD594A74AaBeeEEDf0DfCB6E0309483);

    string public _name;
    string public _symbol;
    uint256 public _decimals;
    uint256 public _tTotal;
    uint256 public _fee_Contract;

    // Social links for this token
    string public Token_Website;
    string public Token_Telegram;

    // Init limit uints
    uint256 public max_Hold;
    uint256 public max_Tran;

    // Set factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor (string memory _TokenSymbol, string memory _TokenName, address _OwnerWallet, address payable _MarketingWallet, uint256 _TotalSupply, uint256 _Decimals, string memory _Website, string memory _Telegram, uint256 _ContractFee) {

   
    // Set owner
    _owner              = _OwnerWallet;

    // Set basic token details
    _name               = _TokenName;
    _symbol             = _TokenSymbol;
    _decimals           = _Decimals;
    _tTotal             = _TotalSupply * 10**_decimals;

    // Set initial wallet limits (Default is 1% Max Hold and Transaction)
    max_Hold            = _tTotal / 100;
    max_Tran            = _tTotal / 100; 

    // Set Socials 
    Token_Website       = _Website;
    Token_Telegram      = _Telegram;

    // Set marketing and liquidity collection wallets to owner (can be updated later)
    Wallet_Marketing    = _MarketingWallet;
    Wallet_Liquidity    = _OwnerWallet;

    // Set contract fee
    _fee_Contract       = _ContractFee;

    // Emit ownership transfer
    emit OwnershipTransferred(address(0), _owner);

    // Transfer entire token supply to owner wallet
    _tOwned[_owner]     = _tTotal;

    // Set PancakeSwap Factory Address
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Create initial liquidity pair with BNB on PancakeSwap factory
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Wallet that are excluded from holding limits
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

    // Wallets granted access before trade is open
    _preLaunchAccess[_owner] = true;
    emit Transfer(address(0), _owner, _tTotal);

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_mapping_preLaunchAccess(address Wallet_Address, bool true_or_false);
    event updated_mapping_isLimitExempt(address Wallet_Address, bool true_or_false);
    event updated_mapping_isPair(address Wallet_Address, bool true_or_false);
    event updated_mapping_isExcludedFromFee(address Wallet_Address, bool true_or_false);
    event updated_Wallet_Marketing(address indexed oldWallet, address indexed newWallet);
    event updated_Wallet_Liquidity(address indexed oldWallet, address indexed newWallet);
    event updated_wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn);
    event updated_noFeeOnTransfer(bool true_or_false);
    event updated_swapTriggerCount(uint256 swapTrigger);
    event updated_SwapAndLiquify_Enabled(bool true_or_false);
    event updated_trade_Open(bool TradeOpen);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    // Restrict function to contract owner only 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    // Address mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _preLaunchAccess;                          // Wallets that have access before trade is open
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    

    // Burn (dead) address - used to remove burn token limits and make burns deflationary 
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD; 


    // Swap triggers
    uint256 public swapTrigger = 11;    // After 10 transactions with a fee swap will be triggered 
    uint256 public swapCounter = 1;     // Start at 1 not zero to save gas


    // Setting the initial fees
    uint256 public _fee_Liquidity   = 5; // Auto Liquidity Fee
    uint256 public _fee_Marketing   = 5; // Marketing and Development Fee
    uint256 public _fee_Burn        = 0; // Deflationary Burn Fee


    // Wallet to wallet transfers without fees
    bool public noFeeToTransfer = true;
    

    // SwapAndLiquify - Automatically processing fees and adding liquidity                                   
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;


    // Launch settings
    bool public TradeOpen = false;


    // Renounce ownership of the contract 
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }



    // Transfer the contract to to a new owner - Overide used to update wallet mapping status
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

         // Remove old owner status 
        _isLimitExempt[owner()] = false;
        _isExcludedFromFee[owner()] = false;
        _preLaunchAccess[owner()] = false;


        // Emit ownership transfer
        emit OwnershipTransferred(_owner, newOwner);

        // Transfer owner
        _owner = newOwner;

        // Add new Owner status
        _isLimitExempt[owner()] = true;
        _isExcludedFromFee[owner()] = true;
        _preLaunchAccess[owner()] = true;

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
        require(owner != address(0), "Owner is zero address!");
        require(spender != address(0), "Spender is zero address!");

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




    /*

    Wallet Mappings

    */


    // Grants access when trade is closed - Default false (true for contract owner)
    function mapping_preLaunchAccess(address Wallet_Address, bool true_or_false) external onlyOwner {    
        _preLaunchAccess[Wallet_Address] = true_or_false;
        emit updated_mapping_preLaunchAccess(Wallet_Address, true_or_false);
    }

    // Excludes wallet from transaction and holding limits - Default false
    function mapping_LimitExempt(address Wallet_Address, bool true_or_false) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit updated_mapping_isLimitExempt(Wallet_Address, true_or_false);
    }
 
    // Identifies wallet as a liquidity pair - Default false
    function mapping_isPair(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        emit updated_mapping_isPair(Wallet_Address, true_or_false);
    }

    // Excludes wallet from fees - Default false
    function mapping_excludeFromFee(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;
        emit updated_mapping_isExcludedFromFee(Wallet_Address, true_or_false);

    }








    /*

    Update Wallets

    */


    // Update marketing wallet
    function wallet_Update_Marketing(address payable wallet) external onlyOwner {

        require(wallet != address(0), "Can not be zero address");
        emit updated_Wallet_Marketing(Wallet_Marketing,wallet);
        Wallet_Marketing = wallet;
    }

    // Update liquidity collection wallet
    function wallet_Update_Liquidity(address wallet) external onlyOwner {

        // To send the auto liquidity tokens directly to burn update to 0x000000000000000000000000000000000000dEaD
        emit updated_Wallet_Liquidity(Wallet_Liquidity,wallet);
        Wallet_Liquidity = wallet;
    }







    /*

    Wallet Limits

    */

    // Wallet Holding and Transaction Limits (Enter token amount, excluding decimals)
    function Set_Limits_For_Wallets(

        uint256 _max_Tran,
        uint256 _max_Hold

        ) external onlyOwner {

        // Buyer protection - Limits can not be set to zero 
        require(_max_Hold > 0, "Must be greater than 0");
        require(_max_Tran > 0, "Must be greater than 0");
        
        max_Hold = _max_Hold * 10**_decimals;
        max_Tran = _max_Tran * 10**_decimals;

        emit updated_wallet_Limits(max_Tran, max_Hold);

    }










    /*

    FEES  

    */


    // If contract development fee was set to 1% of transactions, this is included in the max fee limit
    function Set_Fees(uint256 Marketing, uint256 Liquidity, uint256 Burn) external onlyOwner {

        // Buyer protection - max fee can not be set over 25% (including possible 1% contract fee if chosen)
        require(Marketing + Liquidity + Burn + _fee_Contract <= 25, "Fees too high"); 

        // Update fees
        _fee_Marketing = Marketing;
        _fee_Liquidity = Liquidity;
        _fee_Burn      = Burn;

        emit updated_fees(_fee_Marketing, _fee_Liquidity, _fee_Burn);
    }

    // When sending tokens to another wallet (not buying or selling) if noFeeToTransfer is true there will be no fee (default = true)
    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
        emit updated_noFeeOnTransfer(true_or_false);
    }

    







    /*

    Swap and Liquify Settings (Processing Transaction Fees)

    */



    // Set the number of transactions before swap is triggered (default 10)
    function swapTriggerCount(uint256 number_Of_Transactions) external onlyOwner {

        // Add 1 to total as counter is reset to 1, not 0, to save gas
        swapTrigger = number_Of_Transactions + 1;
        emit updated_swapTriggerCount(swapTrigger);
    }

    // Default is True = Contract will process fees into Marketing and Liquidity automatically
    function swap_Enabled(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }

    // Manually process fees - emit is triggered within swapAndLiquify function so not needed here
    function swap_Now (uint256 percent_Of_Tokens_To_Process) external onlyOwner {
        require(!inSwapAndLiquify, "Already in swap"); 
        if (percent_Of_Tokens_To_Process > 100){percent_Of_Tokens_To_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * percent_Of_Tokens_To_Process / 100;
        swapAndLiquify(sendTokens);

    }






    // Open trade - one way switch to protect buyers - trade can not be paused once opened
    function OpenTrade() external onlyOwner {
        TradeOpen = true;
        emit updated_trade_Open(TradeOpen);
    }






    // Main transfer checks and settings 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {


        // Allows owner to add liquidity safely, eliminating the risk of someone maliciously setting the price 
        if (!TradeOpen){
        require(_preLaunchAccess[from] || _preLaunchAccess[to], "Trade is not open");
        }


        // Wallet Limit
        if (!_isLimitExempt[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "Over wallet max");
            }


        /*
        
        Poocoin Trade button Warning

        Poocion will do a simulation sell of approximately 0.01 BNB. If they can not buy and sell this amount they will disable your trade button.
        If you only add a small amount of BNB to your initial liquidity (1 BNB or less) and your max transaction is limited to 1% of the total supply then 
        this test will fail and you will not get a trade button on poocoin. Be aware of this when doing tests on main net with low liquidity! 

        */


        // Transaction limit - To send over the transaction limit then the sender AND the recipient must be limit exempt (or increase transaction limit)
        if (!_isLimitExempt[to] || !_isLimitExempt[from])
            {
            require(amount <= max_Tran, "Over transaction limit");
            }


        // Compliance and safety checks
        require(from != address(0) && to != address(0), "Can not be 0 address");
        require(amount > 0, "Transfer must be greater than 0");


        // Check number of transaction to trigger fee processing - can only trigger on sells
        if( _isPair[to] &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
            )
            {  
            if(swapCounter >= swapTrigger){
            uint256 contractTokens = balanceOf(address(this));
            swapAndLiquify (contractTokens);
            }  
            }
        

        // Only charge a fee on buys and sells, no fee for wallet transfers
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } 

        _tokenTransfer(from, to, amount, takeFee);

    }








    // Process fees
    function swapAndLiquify(uint256 Tokens) private {

        // Lock swapAndLiquify function
        inSwapAndLiquify    = true;    

        // Exclude burn fee from calculations as burn tokens are never sent to contract 
        uint256 totalFees   = _fee_Liquidity + _fee_Contract + _fee_Marketing;
        uint256 LP_Tokens   = Tokens * _fee_Liquidity / totalFees / 2;
        uint256 Swap_Tokens = Tokens - LP_Tokens;

        // Swap tokens
        uint256 BeforeSwap  = address(this).balance;
        swapTokensForBNB(Swap_Tokens);

        // Calculate BNB for liquidity
        uint256 Swapped     = address(this).balance - BeforeSwap;

        // To avoid rounding errors, double total fee instead of halving liquidity fee
        uint256 LP_BNB      = Swapped * _fee_Liquidity / (totalFees * 2);

        // Add liquidity
        if (LP_Tokens != 0){
        addLiquidity(LP_Tokens, LP_BNB);
        emit SwapAndLiquify(LP_Tokens, LP_BNB, LP_Tokens);
        }

        // Take Contract Fee if Required
        if (_fee_Contract != 0){

        // To avoid rounding errors, double other fees instead of halving liquidity fee
        uint256 BNB_Contract = Swapped * (_fee_Contract * 2) / (totalFees * 2 - _fee_Liquidity);
        if (BNB_Contract > 0){
        feeCollector.transfer(BNB_Contract); 
        }
        }

        // Send remaining BNB to marketing wallet
        uint256 MarketingBNB = address(this).balance;
        if (MarketingBNB > 0){
        Wallet_Marketing.transfer(MarketingBNB);
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


    // Transfer tokens, calculate fees and deposit on to contract
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        
        
        if(!takeFee){

            // No Fee - Just hand over the tokens! 
            _tOwned[sender] = _tOwned[sender] - tAmount;

            // Forward tokens to recipient if not the burn address
            if(recipient != Wallet_Burn){
            _tOwned[recipient] = _tOwned[recipient] + tAmount;
            } else {
            // Remove burned tokens from total supply
            _tTotal = _tTotal - tAmount;
            }

            emit Transfer(sender, recipient, tAmount);

            } else {

            // Calculate fees
            uint256 feeBurn         = tAmount * _fee_Burn       / 100;
            uint256 feeLiquidity    = tAmount * _fee_Liquidity  / 100;
            uint256 feeContract     = tAmount * _fee_Contract   / 100; 
            uint256 feeMarketing    = tAmount * _fee_Marketing  / 100;
            uint256 feeTotal        = feeLiquidity + feeContract + feeMarketing + feeBurn;
            uint256 tTransferAmount = tAmount - feeTotal;

            // Remove all tokens from sender
            _tOwned[sender] = _tOwned[sender] - tAmount;

            /* 

            By default, the burn wallet is excluded from fees, but the following code allows for fees on tokens
            sent to burn wallet to be processed correctly if the burn address is re-included in fee.

            */

            // Add tokens (-fees) to recipient if recipient is not burn
            if(recipient != Wallet_Burn){
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;} else {
            // Remove burned tokens from total supply
            _tTotal = _tTotal - tTransferAmount;
            }

            // Add fees (-burn) to contract for processing during swap and liquify
            _tOwned[address(this)] = _tOwned[address(this)] + (feeTotal - feeBurn);

            // Make the burn deflationary - Reduce the total supply
            if (feeBurn > 0){_tTotal = _tTotal - feeBurn;}

            emit Transfer(sender, recipient, tTransferAmount);

            // Increase the transaction counter - only increase if required to save gas on buys when already in trigger zone
            if (swapCounter < swapTrigger){
            swapCounter++;
            }
            }
    }





    // Remove random tokens from the contract - the emit happens during _transfer, therefore it is not required within this function
    function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){

            // Can not purge the native token!
            require (random_Token_Address != address(this), "Can not remove native token, must be processed via SwapAndLiquify");

            // Get balance of random tokens and send to caller wallet
            uint256 totalRandom = IERC2222(random_Token_Address).balanceOf(address(this));
            uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
            _sent = IERC2222(random_Token_Address).transfer(msg.sender, removeRandom);

    }



    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}


}
/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: Unlicensed 
// Unlicensed is not Open Source, can not be used/forked without permission 
// Contract created for https://TEST.com by https://gentokens.com/ 


/*

TEST - QB_TOKEN

Supply 10 000 000 000
Decimals 18
Auto LP
Marketing and Dev
Anti Snipe

                                                                                                         
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



contract AA_QB is Context, IERC20 { 
    using SafeMath for uint256;
    using Address for address;



    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    /*

    Transfer Contract Ownership

    */


    event newContractOwner(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        // Remove previous owner mappings 
        _isLimitExempt[owner()] = false;
        _isExcludedFromFee[owner()] = false;
        _preLaunchAccess[owner()] = false;

        emit newContractOwner(_owner, newOwner);
        _owner = newOwner;

        // Add new owner mappings 
        _isLimitExempt[newOwner] = true;
        _isExcludedFromFee[newOwner] = true;
        _preLaunchAccess[newOwner] = true;
    }



    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => bool) public _preLaunchAccess;
    mapping (address => bool) public _isLimitExempt;

   
    address payable public Wallet_Marketing = payable(0xec7D683353DAe73FE7ec79f9d71324A35c3286F9); 
    address payable public Wallet_Developer = payable(0xec7D683353DAe73FE7ec79f9d71324A35c3286F9); 
    address payable public Wallet_Liquidity = payable(0x9F9cE3a784D1b327296Cd2A351aB7C6DE5A68bd2);

    address public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 


    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _decimals = 18;
    uint256 private _tTotal = 10**10 * 10**_decimals;
    string private constant _name = "AA_QB"; 
    string private constant _symbol = "AA_QB"; 

    // Target BNB for liquify trigger
    uint256 public target_BNB = 10;         // Target value of tokens on contract required to trigger swap and liquify
    uint256 public swapTrigger = 100;   // Number of tokens that will trigger swap and liquify - updated on each swap

    // Setting the initial fees
    uint256 public _fee_Liquidity   = 9; // Auto Liqudidty Fee
    uint256 public _fee_Developer   = 1; // Solifity Developer Fee   
    uint256 public _fee_Marketing   = 5; // Marketing and Devlopment Fee

    // Max possible fee on buy and sell
    uint256 public constant _fee_MAX = 15;
    bool public TradeOpen = true; // XXXX


    // Wallet limits 
    

    // Max wallet holding (0.5% at launch)
    uint256 public max_Hold = _tTotal / 200;

    // Maximum transaction amount (0.5% at launch)
    uint256 public max_Tran = _tTotal / 200; 
                                     
                                     
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
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

        _tOwned[owner()] = _tTotal;
        
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // TESTNET BSC        

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

    
        /*

        Set initial wallet mappings

        */


        // Wallet that are excluded from holding limits
        _isLimitExempt[owner()] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[Wallet_Marketing] = true; 
        _isLimitExempt[Wallet_Burn] = true;


        // Wallets that are excluded from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Marketing] = true; 
        _isExcludedFromFee[Wallet_Burn] = true;

        // Wallets granted access before trade is oopen
        _preLaunchAccess[owner()] = true;

        emit Transfer(address(0), owner(), _tTotal);

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
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
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

    

    // Turn fess on/off for a wallet - Default is false (Wallets pay fees!)
    event wallet_is_excluded_from_fee(address Wallet_Address, bool true_or_false);
    function excluded_From_Fee(address Wallet_Address, bool true_or_false) public onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;
        emit wallet_is_excluded_from_fee(Wallet_Address, true_or_false);

    }
    


    /*

    Manually set mappings

    */


    // Pre Launch Access - able to buy and sell before the trade is open 
    event wallet_pre_launch_access(address Wallet_Address, bool true_or_false);
    function mapping_preLaunchAccess(address Wallet_Address, bool true_or_false) external onlyOwner() {    
        _preLaunchAccess[Wallet_Address] = true_or_false;
        emit wallet_pre_launch_access(Wallet_Address, true_or_false);
    }

    // Add wallet to limit exempt list 
    event wallet_limit_exempt(address Wallet_Address, bool true_or_false);
    function mapping_LimitExempt(address Wallet_Address, bool true_or_false) external onlyOwner() {  
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit wallet_limit_exempt(Wallet_Address, true_or_false);
    }


    /*
    
    When sending tokens to another wallet (not buying or selling) if noFeeToTransfer is true there will be no fee

    */


    bool public noFeeToTransfer = true;

    // Option to set fee or no fee for transfer (just in case the no fee transfer option is exploited in future!)
    // True = there will be no fees when moving tokens around or giving them to friends! (There will only be a fee to buy or sell)
    // False = there will be a fee when buying/selling/tranfering tokens
    // Default is true

    event noFeeOnTransfer(bool true_or_false);
    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
        emit noFeeOnTransfer(true_or_false);
    }

    
    // isPair - Add to pair (set to true) OR Remove from pair (set to false)

    mapping (address => bool) public _isPair;

    /*

    Setting as a pair indicates that it is an address used by an exchange to buy or sell tokens. 
    This setting is used so that we can have no-fee transfers between wallets but new
    pairings will take a fee on buys and sell

    */
 
    event wallet_set_as_pair(address Wallet_Address, bool true_or_false);
    function set_as_Pair(address Wallet_Address, bool true_or_false) external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        emit wallet_set_as_pair(Wallet_Address, true_or_false);
    }



    /*

    FEES  

    Remeber that fees also include 1% to solidity developer, so the max is 19! // XXXXX MAX CHECK 

    */

    event setting_fees(uint256 Marketing, uint256 Liquidity);
    function _set_Fees(uint256 Marketing, uint256 Liqudidty) external onlyOwner() {

  
        require(Marketing + Liqudidty + _fee_Developer <= 20, "Fees too high");  // XXX CHECK LIMIT

        _fee_Marketing = Marketing;
        _fee_Liquidity = Liqudidty;

        emit setting_fees(_fee_Marketing, _fee_Liquidity);

    }


    /*

    Updating Wallets

    */


    //Update the Marketing wallet
    event updatedMarketingWallet(address indexed oldWallet, address indexed newWallet);
    function Wallet_Update_TEST(address payable wallet) external onlyOwner() {
        // Can't be zero address
        require(wallet != address(0), "new wallet is the zero address");
        emit updatedMarketingWallet(Wallet_Marketing,wallet);

        // Update mapping on old wallet
        _isExcludedFromFee[Wallet_Marketing] = false; 

        Wallet_Marketing = wallet;
        // Update mapping on new wallet
        _isExcludedFromFee[Wallet_Marketing] = true;
    }

    // XXXX UPDATE CAKE LP WALLET!!!! XXXXX 

   
    
    /*

    SwapAndLiquify Switches

    */
    
    // Toggle on and off to activate auto liquidity and the promo wallet 
    function set_Swap_And_Liquify_Enabled(bool true_or_false) public onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit SwapAndLiquifyEnabledUpdated(true_or_false);
    }


    // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}


    /*

    Wallet Limits

    */

    // Wallet Holding and Transaction Limits

    event E_max_Tran_Tokens(uint256 max_Tran);
    event E_max_Hold_Tokens(uint256 max_Hold);

    function set_Limits_For_Wallets(

        uint256 _max_Tran,
        uint256 _max_Hold

        ) external onlyOwner() {

        require(max_Hold > 0, "Must be greater than 0");
        require(max_Tran > 0, "Must be greater than 0");
        
        max_Hold = _max_Hold * 10**_decimals;
        max_Tran = _max_Tran * 10**_decimals;

        emit E_max_Tran_Tokens(max_Hold);
        emit E_max_Hold_Tokens(max_Tran);

    }

    // Set Target BNB for swapTrigger
    function set_SwapTrigger_BNB(uint256 BNB_Value) external onlyOwner {
        target_BNB = BNB_Value;
    }






    // Open Trade - ONE WAY SWITCH! 
    function openTrade() external onlyOwner() {
        TradeOpen = true;
    }


    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }



    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {



        if (!TradeOpen){
        require(_preLaunchAccess[from] || _preLaunchAccess[to], "Trade is not open yet, please come back later");
        }


      
        /*

        TRANSACTION AND WALLET LIMITS

        */
        

        // Limit wallet total
        if (!_isLimitExempt[to] &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}


        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (from != owner() && to != owner())
            require(amount <= max_Tran, "You are trying to buy more than the max transaction limit.");


        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");





        uint256 Tokens = balanceOf(address(this));

        if(
            Tokens > swapTrigger && 
            !inSwapAndLiquify &&
            !_isPair[from] &&
            swapAndLiquifyEnabled
            )
        {  
            swapAndLiquify(swapTrigger);
        }
        

        // Do we need to charge a fee?
        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } 

        

        _tokenTransfer(from, to, amount, takeFee);

    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }

    function precDiv(uint a, uint b, uint precision) internal pure returns (uint) {
    return a*(10**precision)/b;
    }


    function swapAndLiquify(uint256 Tokens) private lockTheSwap {


        // Get fee tracking splits
        uint256 percent_L = precDiv(_fee_Liquidity,Tokens,2);
        uint256 percent_D = precDiv(_fee_Developer,Tokens,2);


        // Calculate number of tokens that need to be swapped
        uint256 half_LP = (Tokens * percent_L / 100)/2;
        uint256 swapTokens = Tokens - half_LP;


        // Swap tokens for BNB
        uint256 contract_BNB = address(this).balance;
        swapTokensForBNB(swapTokens);
        uint256 returned_BNB = address(this).balance - contract_BNB;


        // Get price and update swap trigger for next swap
        swapTrigger = swapTokens * target_BNB / returned_BNB;




        // Add Liquidity 
        if (percent_L > 0){

            uint256 bnb_LP = (returned_BNB * percent_L / 100)/2;
            addLiquidity(half_LP, bnb_LP);
            emit SwapAndLiquify(half_LP, bnb_LP, half_LP);
        }

        // Send to team wallet - Solidity dev
        if (percent_D > 0){

            uint256 bnb_D = returned_BNB * percent_D / 100;
            sendToWallet(Wallet_Developer, bnb_D);

        }

        // Send remaining BNB to marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
            sendToWallet(Wallet_Marketing, contract_BNB);
        }


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

    Creating Auto Liquidity

    */

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

    PURGE RANDOM TOKENS - Add the random token address and a wallet to send them to

    */


    // Remove random tokens from the contract and send to a wallet

    function remove_Random_Tokens(address random_Token_Address, address send_to_wallet, uint256 percent_of_Tokens) public onlyOwner returns(bool _sent){
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom*percent_of_Tokens/100;
        _sent = IERC20(random_Token_Address).transfer(send_to_wallet, removeRandom);

    }

   

    // Manual 'swapAndLiquify' Trigger (Enter the percent of the tokens that you'd like to send to swap and liquify)
    function process_SwapAndLiquify_Now (uint256 percent_Of_Tokens_To_Liquify) public onlyOwner {
        require(!inSwapAndLiquify, "Currently processing liquidity."); 
        if (percent_Of_Tokens_To_Liquify > 100){percent_Of_Tokens_To_Liquify == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract*percent_Of_Tokens_To_Liquify/100;
        swapAndLiquify(sendTokens);

    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        
        
        if(!takeFee){

            // No Fee - Just hand over the tokens! 
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tAmount;
            emit Transfer(sender, recipient, tAmount);

            // Deflationary Burn!
            if(recipient == Wallet_Burn)
            _tTotal = _tTotal - tAmount;

            } else {

            // Calculate fees
            uint256 feeLiquidity = tAmount * _fee_Liquidity / 100;
            uint256 feeDeveloper = tAmount * _fee_Developer / 100; 
            uint256 feeMarketing = tAmount * _fee_Marketing / 100;
            uint256 feeTotal = feeLiquidity + feeDeveloper + feeMarketing;
            uint256 tTransferAmount = tAmount - feeTotal;

            // Redistribute Tokens
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)] + feeTotal;  

            emit Transfer(sender, recipient, tTransferAmount);

            // Deflationary Burn!
            if(recipient == Wallet_Burn)
            _tTotal = _tTotal - tTransferAmount;

            }

    }



    

}


// Contract created for https://TEST.com by https://gentokens.com/
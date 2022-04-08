/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: Unlicensed 
// Unlicensed is NOT Open Source - can not be used/forked without permission


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




contract BLAZAR is Context, IERC20 { 
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
    mapping (address => bool) public _isBlacklisted;


    bool public noBlackList = true;




    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    
    function owner() public view virtual returns (address) {
        return _owner;
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





    // Contract developer
    address public Contract_Developer; 

    // Safe launch protocols
    bool public launchPhase = true;
    bool public TradeOpen = false; 


    address[] private _excluded; // Excluded from rewards
    address public Wallet_Multi_Sig = 0x87FB518B26eAe3b80883315eF312a2a2e5f02f2D;                       // Used to verify ownership transfer

    address payable public Wallet_Marketing = payable(0x28a0d3Dfb43A9F806E349591906F3A1b81B687be);      // Marketing Wallet
    address payable public Wallet_Ecosystem = payable(0xE550980CEA4ba310c9F47fCEc7D646CDE25afF9E);    // Ecosystem Wallet 
    address payable public Wallet_SolidityDev = payable(0xDaA1A92C4179E6EbDc9C5778714d45A52161E6eB);    // Solidity Developer
    address payable public Wallet_CakeLP = payable(0x87FB518B26eAe3b80883315eF312a2a2e5f02f2D);         // Blazar Developer wallet
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD);  // Deflationary Burn Tracking

  
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _decimals = 18;
    uint256 private _tTotal = 100000000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    string  private constant _name = "BLAZAR"; 
    string  private constant _symbol = "BLAZAR";  


    // TOTAL fees on Buys/Sells/Transfers (This INCLUDES the reflections!)

    uint256 public Fee_Buy          = 12;
    uint256 public Fee_Sell         = 12;
    uint256 public Fee_P2P          = 12;

    // Reflection amount for Buys/Sells/Transfers (These must be included in the above TOTAL fees!)

    uint256 public Reflect_Buy      = 2;
    uint256 public Reflect_Sell     = 2;
    uint256 public Reflect_P2P      = 2;

    // Set the fee distribution percents - total must be 100! 

    uint256 public percent_Marketing      = 20;
    uint256 public percent_Liquidity      = 20;
    uint256 public percent_Ecosystem    = 40;
    uint256 public percent_ContractDev    = 20;

    /*

    Max wallet holding is limited to 0.05% for the first block - Anti Snipe

    */

    // Max wallet holding - heavily limited for sniper bots (2% after launch phase)
    uint256 public _max_Hold_Tokens = _tTotal;
    uint256 public _max_Tran_Tokens = _tTotal;

    uint256 public _min_Swap_Tokens = 10000*10**_decimals; // 10,000 tokens
    uint256 public _max_Swap_Tokens = _tTotal/100; // 1% of supply





    // Used for MultiSig - Ownership transfer, renounce and confirmation wallet updates
    bool public multiSig_Renounce_Ownership_ASKED = false;
    bool public multiSig_Transfer_Ownership_ASKED = false;
    bool public multiSig_Update_2nd_Wallet_ASKED = false;



    // Transfer Ownership - Suggested new owner wallet (must be confirmed)
    address public suggested_New_Owner_Wallet;

    // Update Confirmation Wallet for Multi-Sig - Suggested new wallet (must be confirmed)
    address public suggested_New_MultiSig_2nd_Wallet;




    // Allows contract developer access to 'onlyOwner' functions - Can be granted/revoked by owner
    bool public Developer_Access = true;


    // Track launch block for snipe protection
    uint256 private launchBlock;






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

        Contract_Developer = 0xDaA1A92C4179E6EbDc9C5778714d45A52161E6eB;

        _owner = 0x87FB518B26eAe3b80883315eF312a2a2e5f02f2D;
        

        emit OwnershipTransferred(address(0), _owner);
        _rOwned[owner()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
      

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
        _isExcludedFromFee[Wallet_Burn] = true;

        // Wallets that are not restricted by transaction and holding limits
        _limitExempt[owner()] = true;
        _limitExempt[address(this)] = true;
        _limitExempt[Wallet_Burn] = true;

        // Wallets granted access before trade is open
        _preLaunchAccess[owner()] = true;

        // Exclude from Rewards
        _isExcluded[Wallet_Burn] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;

        _excluded.push(Wallet_Burn);
        _excluded.push(uniswapV2Pair);
        _excluded.push(address(this));


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

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 _rAmount) public view returns(uint256) {
        require(_rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return _rAmount.div(currentRate);
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
    






















    event updated_Developer_Access(bool Developer_Access);




    function Allow_Developer_Access(bool true_or_false) external onlyOwner {
        Developer_Access = true_or_false;
        emit updated_Developer_Access(Developer_Access);
    }





    // Transfer Ownership - Requires Multi-Sig
    function multiSig_Transfer_Ownership_ASK(address newOwner_Request) external onlyOwner {

        require(!multiSig_Transfer_Ownership_ASKED, "Already asked, wait confirmation");
        require(newOwner_Request != address(0), "New owner can not be zero address");
        multiSig_Transfer_Ownership_ASKED = true;
        suggested_New_Owner_Wallet = newOwner_Request;

    }

    function multiSig_Transfer_Ownership_CONFIRM(bool true_or_false) external {

        require(msg.sender == Wallet_Multi_Sig, "Confirmation wallet must confirm");
        require (multiSig_Transfer_Ownership_ASKED, "Transfering Ownership not requested");

        if (true_or_false){


        // Remove old owner exemptions
        _isExcludedFromFee[owner()] = false;
        _limitExempt[owner()] = false;
        _preLaunchAccess[owner()] = false;


        // Transfer ownership and reset ask permissions
        emit OwnershipTransferred(_owner, suggested_New_Owner_Wallet);
        _owner = suggested_New_Owner_Wallet;
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

        require(msg.sender == Wallet_Multi_Sig, "Confirmation wallet must confirm");
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

        require(msg.sender == Wallet_Multi_Sig, "Confirmation wallet must confirm");
        require(multiSig_Update_2nd_Wallet_ASKED, "Change not requested");
        if(true_or_false){
                multiSig_Update_2nd_Wallet_ASKED = false;
                Wallet_Multi_Sig = suggested_New_MultiSig_2nd_Wallet;
            } else {
                multiSig_Update_2nd_Wallet_ASKED = false;
            }
        }

    

















    // Update the number of transactions needed to trigger swap
    event Update_Swap_Trigger_Count(uint256 number_of_transactions);
    function Swap_Trigger_Count(uint256 number_of_transactions) external onlyOwner {
        swapTrigger = number_of_transactions;
        emit Update_Swap_Trigger_Count(number_of_transactions);
    }

    uint256 public swapTrigger = 10; // Number of transactions with a fee until swap is triggered
    uint256 public txCount = 1;







    





    /*

    Address Mappings

    */


    // Limit Except - used to allow a wallet to hold more than the max limit - for locking tokens etc
    event limitExempt(address account, bool true_or_false);
    function mapping_limitExempt(address account, bool true_or_false) external onlyOwner {    
        _limitExempt[account] = true_or_false;
        emit limitExempt(account, true_or_false);
    }

    // Pre-Launch Access - able to buy and sell before the trade is open 
    event preLaunchAccess(address account, bool true_or_false);
    function mapping_preLaunchAccess(address account, bool true_or_false) external onlyOwner {    
        _preLaunchAccess[account] = true_or_false;
        emit preLaunchAccess(account, true_or_false);
    }

    // Add wallet to snipe list 
    event Set_Snipe(address account, bool true_or_false);
    function mapping_isSnipe(address account, bool true_or_false) external onlyOwner {  
        _isSnipe[account] = true_or_false;
        emit Set_Snipe(account, true_or_false);
    }

    // Set as liquidity pair
    event Set_Pair(address wallet, bool true_or_false);
    function mapping_isPair(address wallet, bool true_or_false) external onlyOwner {
        _isPair[wallet] = true_or_false;
        emit Set_Pair(wallet, true_or_false);
    }


    // Set a wallet address so that it does not have to pay transaction fees
    event ExcludedFromFee(address account, bool true_or_false);
    function Mapping_ExcludedFromFee(address account, bool true_or_false) external onlyOwner {
        _isExcludedFromFee[account] = true_or_false;
        emit ExcludedFromFee(account, true_or_false);
    }


    // Blacklist wallet address
    event Blacklist_wallet(address account, bool true_or_false);
    function Mapping_Blacklist(address account, bool true_or_false) external onlyOwner {
        _isBlacklisted[account] = true_or_false;
        emit Blacklist_wallet(account, true_or_false);
    }

    //Blacklist Switch - Turn on/off blacklisted wallet restrictions 
    event blacklisted_wallets_blocked(bool true_or_false);
    function blacklist_Switch(bool true_or_false) public onlyOwner {
        noBlackList = true_or_false;
        emit blacklisted_wallets_blocked(true_or_false);
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
    function Rewards_Exclude_Wallet(address account) external onlyOwner {
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
    function Rewards_Include_Wallets(address account) external onlyOwner {
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
    





    

    
    

    /*

    SET FEES

    */

    // Set the fees - When setting fees, the Reflection fee must be included in the total fee
    event setFees_Updated(uint256 Fee_Buy, uint256 Fee_Sell, uint256 Fee_P2P, uint256 Reflect_Buy, uint256 Reflect_Sell, uint256 Reflect_P2P);

    function set_Fees(uint256 _Fee_Buy,
                      uint256 _Fee_Sell,
                      uint256 _Fee_P2P,
                      uint256 _Reflect_Buy,
                      uint256 _Reflect_Sell,
                      uint256 _Reflect_P2P) external onlyOwner {

        // Buyer protection - The fees can never be set above the max possible
        require(_Fee_Buy    <= 20, "Buy fee too high");
        require(_Fee_Sell   <= 20, "Sell fee too high");
        require(_Fee_P2P    <= 20, "P2P fee too high");

        // Check that the reflection fee is included in the total fee
        require(_Reflect_Buy    <= _Fee_Buy,    "Fee_Buy must include Reflect_Buy");
        require(_Reflect_Sell   <= _Fee_Sell,   "Fee_Sell must include Reflect_Sell");
        require(_Reflect_P2P    <= _Fee_P2P,    "Fee_P2P must include Reflect_P2P");

        // Update fees
        Fee_Buy      = _Fee_Buy;
        Fee_Sell     = _Fee_Sell;
        Fee_P2P      = _Fee_P2P;
        Reflect_Buy  = _Reflect_Buy;
        Reflect_Sell = _Reflect_Sell;
        Reflect_P2P  = _Reflect_P2P;

        emit setFees_Updated(Fee_Buy, Fee_Sell, Fee_P2P, Reflect_Buy, Reflect_Sell, Reflect_P2P);

    }

    function set_Fee_Distribution(uint256 _percent_Marketing,
                                  uint256 _percent_Liquidity,
                                  uint256 _percent_Development) external onlyOwner {

        
        require((_percent_Marketing + _percent_Liquidity + _percent_Development) == 90, "");

        // Update fee distribution percent
        percent_Marketing = _percent_Marketing;
        percent_Liquidity = _percent_Liquidity;
        percent_Ecosystem = _percent_Development;

    }



    
    /*

    Updating Wallets

    */

    event E_Wallet_Update_Marketing(address indexed oldWallet, address indexed newWallet);
    event E_Wallet_Update_Development(address indexed oldWallet, address indexed newWallet);
    event E_Wallet_Update_SolidityDev(address indexed oldWallet, address indexed newWallet);
    event E_Wallet_Update_CakeLP(address indexed oldWallet, address indexed newWallet);
    

    //Update the marketing wallet
    function Wallet_Update_Marketing(address payable wallet) external onlyOwner {
        // Can't be zero address
        require(wallet != address(0), "new wallet is the zero address");
        emit E_Wallet_Update_Marketing(Wallet_Marketing,wallet);
        Wallet_Marketing = wallet;

    }

    //Update the development and Ecosystem wallet
    function Wallet_Update_Development(address payable wallet) external onlyOwner {
        // Can't be zero address
        require(wallet != address(0), "new wallet is the zero address");
        emit E_Wallet_Update_Development(Wallet_Marketing,wallet);
        Wallet_Ecosystem = wallet;

    }

    //Update Solidity developer fee wallet
    function Wallet_Update_SolidityDev(address payable wallet) external {
        require(wallet != address(0), "Can not be zero address");
        require(msg.sender == Contract_Developer, "Only the contract developer can update");
        emit E_Wallet_Update_SolidityDev(Wallet_SolidityDev,wallet);
        Wallet_SolidityDev = wallet;
    }

    //Update the cake LP wallet
    function Wallet_Update_CakeLP(address payable wallet) external onlyOwner {
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



    // This function is required so that the contract can receive BNB from PancakeSwap
    receive() external payable {}
    




    // Wallet Holding and Transaction Limits
    event updated_Wallet_Limits(uint256 wallet_Limit, uint256 transaction_Limit);
    function set_Limits_For_Wallets(

        uint256 max_Tran_Tokens,
        uint256 max_Hold_Tokens
       
        ) external onlyOwner {

        require(max_Hold_Tokens > 0, "Must be greater than 0");
        require(max_Tran_Tokens > 0, "Must be greater than 0");
        
        _max_Hold_Tokens = max_Hold_Tokens * 10**_decimals;
        _max_Tran_Tokens = max_Tran_Tokens * 10**_decimals;
      

        emit updated_Wallet_Limits(_max_Hold_Tokens, _max_Tran_Tokens);

    }


    // Min trigger and max limit of tokens for fee processing
    event updated_Processing_Trigger_Limits(uint256 fee_Processing_Trigger_Min, uint256 fee_Processing_Trigger_Max);
    function set_Limits_For_Swap_Trigger(

        uint256 min_Swap_Tokens,
        uint256 max_Swap_Tokens

        ) external onlyOwner {
        
       
        _min_Swap_Tokens = min_Swap_Tokens * 10**_decimals;
        _max_Swap_Tokens = max_Swap_Tokens * 10**_decimals;

        emit updated_Processing_Trigger_Limits(_min_Swap_Tokens, _max_Swap_Tokens);

    }



    
    // Open Trade

    event E_openTrade(bool TradeOpen);
    function openTrade() external onlyOwner {
        TradeOpen = true;
        launchBlock = block.number;
        emit E_openTrade(TradeOpen);

    }




    // End Launch Phase 

    event E_end_LaunchPhase(bool launchPhase);
    function end_LaunchPhase() external onlyOwner {
        launchPhase = false;
        emit E_end_LaunchPhase(launchPhase);

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



        // Block blacklisted wallets - blacklisted wallets can only send tokens to owner              
        if (noBlackList && to != owner()){
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted. Transaction reverted.");
        }



        // Limit wallet total 
        if (!_limitExempt[to]){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _max_Hold_Tokens, "Over max wallet");}

          

        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (!_limitExempt[to] || !_limitExempt[from])
            require(amount <= _max_Tran_Tokens, "Over max TX");



        // Compliance and safety checks
        require(from != address(0) && to != address(0), "Can not be 0 address");
        require(amount > 0, "Can not be 0 tokens!");





        // Check if swap required
        if( _isPair[to] &&
            txCount > swapTrigger &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
            )
        {  
            uint256 contractBalance = balanceOf(address(this));

                if(contractBalance > _min_Swap_Tokens){
                    if(contractBalance < _max_Swap_Tokens)
                    {
                    swapAndLiquify(contractBalance);
                    } else {
                    swapAndLiquify(_max_Swap_Tokens);
                    }
                }



        }



        // Do we need to charge a fee?
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {
            // Only update counter if required to avoid increased gas if we are already over the trigger point! 
            if (txCount <= swapTrigger){txCount++;}
        }


        _tokenTransfer(from,to,amount,takeFee);

   
        
    }


    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {


        // How many tokens do we need to swap in total? 
        uint256 Tokens_LP = contractTokenBalance * percent_Liquidity / 200;
        uint256 Tokens_Swap = contractTokenBalance - Tokens_LP;

        // Swap tokens for BNB
        uint256 contract_BNB = address(this).balance;
        swapTokensForEth(Tokens_Swap);
        uint256 returned_BNB = address(this).balance - contract_BNB;

        // Double fees instead of halving LP fee to prevent rounding errors is LP fee is odd number
        uint256 fee_Split = 200 - percent_Liquidity;
        uint256 BNB_L = returned_BNB * percent_Liquidity / fee_Split;

        // Add liquidity 
        if (Tokens_LP != 0){
            addLiquidity(Tokens_LP, BNB_L);
            emit SwapAndLiquify(Tokens_LP, BNB_L, Tokens_LP);
        }

        // Calculate BNB splits
        uint256 BNB_D = returned_BNB * percent_Ecosystem * 2 / fee_Split; 
        uint256 BNB_C = returned_BNB * 10 * 2 / fee_Split;

        // Take Ecosystem fee
        if(BNB_D > 0){sendToWallet(Wallet_Ecosystem, BNB_D);}

        // Take solidity developer fee
        if(BNB_C > 0){sendToWallet(Wallet_SolidityDev, BNB_C);}
        
        // Send remaining BNB to marketing wallet
        contract_BNB = address(this).balance;
        if(contract_BNB > 0){
            sendToWallet(Wallet_Marketing, contract_BNB);}

        // Reset transaction counter
        txCount = 1;

    }

    // Swap tokens for BNB during fee processing
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


    // Add auto liquidity and send Cake_LP tokens to wallet for locking
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



    // Manual 'swapAndLiquify' Trigger (Enter the percent of the tokens that you'd like to send to swap and liquify)
    // Emit is not included in this function as it is trigger by the swapAndLiquify function
    function process_Fees_Now(uint256 percent_Of_Tokens) external onlyOwner {
        require(!inSwapAndLiquify, "Currently processing, try later."); 
        if (percent_Of_Tokens > 100){percent_Of_Tokens == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * percent_Of_Tokens / 100;
        if(sendTokens < _max_Swap_Tokens)
                {
                    swapAndLiquify(sendTokens);
                    } else {
                    swapAndLiquify(_max_Swap_Tokens);
                }
    }


              



    // RFI Adjustments
    function _takeRFI(uint256 _tReflect, uint256 _rReflect) private {
        _rTotal = _rTotal - _rReflect;
        _tFeeTotal = _tFeeTotal + _tReflect;
    }

    // Dump Other Fees On To Contract 
    function _takeFees(uint256 _tFees, uint256 _rFees) private {
        _rOwned[address(this)] = _rOwned[address(this)] + _rFees;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + _tFees;
    }


    /*

    Transfer Functions

    */

        uint256 internal tReflect; // Reflections
        uint256 internal rReflect; // RFI Reflected Reflections

        uint256 internal tFees; // Fees
        uint256 internal rFees; // RFI Reflected Fees

        uint256 internal rAmount; // RFI Reflected Amount
        uint256 internal tTransferAmount; // Amount After Fees
        uint256 internal rTransferAmount; // RFI Reflected Amount After Fees


    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {  


        if (!takeFee){

                tReflect = 0;
                tFees = 0;

        } else if (_isPair[sender]){

        // Buy Fees
        tReflect = amount * Reflect_Buy / 100;
        tFees = amount * (Fee_Buy - Reflect_Buy) / 100;

        } else if (_isPair[recipient]){

        // Sell Fees
        tReflect = amount * Reflect_Sell / 100;
        tFees = amount * (Fee_Sell - Reflect_Sell) / 100;

        } else {

        // Person to Person (P2P) Fees
        tReflect = amount * Reflect_P2P / 100;
        tFees = amount * (Fee_P2P - Reflect_P2P) / 100;

        } 

        
        // Get RFI Reflected Values

        uint256 rateRFI = _getRate();

        rAmount = amount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;


        tTransferAmount = amount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);


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





   function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        _rOwned[sender] = _rOwned[sender] - rAmount;

        if(recipient != Wallet_Burn){

        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        if(takeFee){

        // Take the Fees
        _takeRFI(tReflect, rReflect);
        _takeFees(tFees, rFees);

        }


        // Make the burn deflationary by reducing total supply if the burn address is the recipient 
        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if(recipient != Wallet_Burn){

        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        if(takeFee){

        // Take the Fees
        _takeRFI(tReflect, rReflect);
        _takeFees(tFees, rFees);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }




    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if(recipient != Wallet_Burn){

        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        if(takeFee){

        // Take the Fees
        _takeRFI(tReflect, rReflect);
        _takeFees(tFees, rFees);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }






    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;


        if(recipient != Wallet_Burn){

        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        }

        if(takeFee){

        // Take the Fees
        _takeRFI(tReflect, rReflect);
        _takeFees(tFees, rFees);

        }


        if(recipient == Wallet_Burn){

        _tTotal = _tTotal - tAmount;
        _rTotal = _rTotal - rAmount;

        }
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

}
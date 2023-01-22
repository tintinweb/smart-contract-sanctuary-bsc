/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: Unlicensed

/*

Aero Project - Future Blockchain
AERO Blockchain is a layer 1 blockchain technology with Proof Of Stake consensus and the advantage of our blockchain is that it is able to connect the ecosystem of other blockchains

Website : https://aeroprotocol.org/
Telegram : https://t.me/AERONEWSOFFICIAL

*/

pragma solidity ^0.8.7;


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

abstract contract Ownable is Context {
    address private _owner;


    // Deployer Of AEROCOIN Smart Contract
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xC056917EB51b3c2BB38936BcE65809eb94470007;
        emit OwnershipTransferred(address(0), _owner);
    }

    // Return Current Deployer Of AEROCOIN Smart Contract
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Restrict Function Of AEROCOIN Smart Contract
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Renounce Ownership Of AEROCOIN Smart Contract
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Transfer Of AEROCOIN Smart Contract To A New Owner
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


contract AEROCOIN is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    using Address for address;


    // Tracking Status Of AEROCOIN Wallets
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _AEROCOINisExcludedFromFee; 


    /*

    Wallets Of AEROCOIN

    */


    address payable private Wallet_Dev = payable(0xC056917EB51b3c2BB38936BcE65809eb94470007);
    address payable private Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
    address payable private Wallet_zero = payable(0x0000000000000000000000000000000000000000); 


    /*

    Tokenomics Of AEROCOIN

    */


    string private _name = "AERO COIN"; 
    string private _symbol = "AERO";  
    uint8 private _decimals = 9;
    uint256 private _tTotal = 100000000 * 10**9;
    uint256 private _tFeeTotal;

    // Counter For Liquify Trigger
    uint8 private txCount = 0;
    uint8 private swapTrigger = 3; 

    // AEROCOIN Smart Contract
    // This Is The Unique Function Coded By Developers Of AERO Team
    // This Is The Max Fee That The Contract Will Accept, It Is Hard-Coded To Protect Investors
    // This Includes The Buy And The Sell Fee!
    // Terms And Conditions Of Use The AEROCOIN Smart Contract
    // This Is The Grant Of A License, Not A Transfer Of Title, And Under This License You May Not:
    // 1. Modify Of The AEROCOIN Smart Contract;
    // 2. Remove Any Copyright Or Other Proprietary Notations From The AEROCOIN Smart Contract
    uint256 private AEROCOINmaxPossibleFee = 20; 


    // Setting The Initial Fees
    uint256 private _AEROCOINTotalFee = 17;
    uint256 public _AEROCOINbuyFee = 7;
    uint256 public _AEROCOINsellFee = 10;


    uint256 private _AEROCOINpreviousTotalFee = _AEROCOINTotalFee; 
    uint256 private _AEROCOINpreviousBuyFee = _AEROCOINbuyFee; 
    uint256 private _AEROCOINpreviousSellFee = _AEROCOINsellFee; 

    /*

    Wallet Limits Of AEROCOIN
    
    */

    // Max Wallet Holding Of AEROCOIN (2%)
    uint256 public _AEROCOINmaxWalletToken = _tTotal.mul(2).div(100);
    uint256 private _AEROCOINpreviousMaxWalletToken = _AEROCOINmaxWalletToken;


    // Maximum Transaction Amount Of AEROCOIN (2%)
    uint256 public _AEROCOINmaxTxAmount = _tTotal.mul(2).div(100); 
    uint256 private _AEROCOINpreviousMaxTxAmount = _AEROCOINmaxTxAmount;

    /* 

    PancakeSwap Set Up

    */
                                     
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
        
    );
    
    // Prevent Processing While Already Processing! 
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /*

    Deploy AEROCOIN To Deployer Smart Contract

    Constructor Functions Are Only Called Once. This Happens During Contract Deployment
    This Function Deploys The Tokenomics Of AEROCOIN To The Deployer Smart Contract And Creates The PancakeSwap Pairing

    */
    
    constructor () {
        _tOwned[owner()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        
        
        // Create Pair Address For PancakeSwap
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _AEROCOINisExcludedFromFee[owner()] = true;
        _AEROCOINisExcludedFromFee[address(this)] = true;
        _AEROCOINisExcludedFromFee[Wallet_Dev] = true;
        
        emit Transfer(address(0), owner(), _tTotal);
    }


    /*

    Standard BEP20 Compliance Functions

    */

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
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

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
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


    /*

    End Of Standard BEP20 Compliance Functions

    \*

    /*

    Fees Of AEROCOIN

    */
    
    function AEROCOINexcludeFromFee(address account) public onlyOwner {
        _AEROCOINisExcludedFromFee[account] = true;
    }
    
    function AEROCOINincludeInFee(address account) public onlyOwner {
        _AEROCOINisExcludedFromFee[account] = false;
    }


    /*

    Setting Fees Of AERCOIN

    Max Total Fee Is Limited To 20% For Buy And Sell Combined Coded By Developers Of AERO Team
    Our Mission Is Restoring Trust In The Blockchain Security
    The AERO PROTOCOL Adds An Extra Layer Of Security To Blockchain Transactions For BEP20 Standard Token

    */
    

    function _AEROCOINset_Fees(uint256 AEROCOINBuy_Fee, uint256 AEROCOINSell_Fee) external onlyOwner() {

        require((AEROCOINBuy_Fee + AEROCOINSell_Fee) <= AEROCOINmaxPossibleFee, "Fee is too high!");
        _AEROCOINsellFee = AEROCOINSell_Fee;
        _AEROCOINbuyFee = AEROCOINBuy_Fee;

    }



    // Update Of AEROCOIN Smart Contract
    function Wallet_Update_Dev(address payable wallet) public onlyOwner() {
        Wallet_Dev = wallet;
        _AEROCOINisExcludedFromFee[Wallet_Dev] = true;
    }


    /*

    Processing AEROCOIN - Set Up

    */
    
    // Toggle On And Off To Auto Process Tokens To BNB Smart Chain Wallet 
    function set_Swap_And_Liquify_Enabled(bool true_or_false) public onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit SwapAndLiquifyEnabledUpdated(true_or_false);
    }

    // This Will Set The Number Of Transactions Required Before The 'SwapAndLiquify' Function Triggers
    function set_Number_Of_Transactions_Before_Liquify_Trigger(uint8 number_of_transactions) public onlyOwner {
        swapTrigger = number_of_transactions;
    }
    


    // This Function Is Required So That The AEROCOIN Smart Contract Can Receive BNB Smart Chain From PancakeSwap
    receive() external payable {}



    /*
    
    */

    bool public noFeeToTransfer = true;

    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
    }

    /*

    Important Of The Max Wallet Limits Of AERCOIN

    // Wallets Are Limited
    // The Amount Tokens Of AEROCOIN That Can Be Holding Is 2%
    // Limiting A Wallet Prevents One Wallet From Holding Too Many Tokens Of AERCOIN
    // Which Can Scare Away Potential Buyers That Worry That A Whale Might Dump!

    Important Of The Max Transaction Amount Of AEROCOIN

    // Max Transaction Are Limited
    // The Amount Tokens Of AEROCOIN That Can Be Purchased In One Transaction Is 2%
    // Limiting A Max Transaction Prevents One Wallet Of AERCOIN
    // Which Can Scare Away Potential Buyers That Worry That A Whale Might Dump!
    

    */

    // Set The Max Transaction Amount Of AERCOIN
    function AEROCOINset_Max_Transaction_Percent(uint256 AEROCOINmaxTxPercent_x100) external onlyOwner() {
        _AEROCOINmaxTxAmount = _tTotal*AEROCOINmaxTxPercent_x100/10000;
    }    
    
    // Set The Max Wallet Holding Of AEROCOIN
     function AEROCOINset_Max_Wallet_Percent(uint256 AEROCOINmaxWallPercent_x100) external onlyOwner() {
        _AEROCOINmaxWalletToken = _tTotal*AEROCOINmaxWallPercent_x100/10000;
    }



    function removeAllFee() private {
        if(_AEROCOINTotalFee == 0 && _AEROCOINbuyFee == 0 && _AEROCOINsellFee == 0) return;


        _AEROCOINpreviousBuyFee = _AEROCOINbuyFee; 
        _AEROCOINpreviousSellFee = _AEROCOINsellFee; 
        _AEROCOINpreviousTotalFee = _AEROCOINTotalFee;
        _AEROCOINbuyFee = 0;
        _AEROCOINsellFee = 0;
        _AEROCOINTotalFee = 0;

    }
    

    function restoreAllFee() private {
    
    _AEROCOINTotalFee = _AEROCOINpreviousTotalFee;
    _AEROCOINbuyFee = _AEROCOINpreviousBuyFee; 
    _AEROCOINsellFee = _AEROCOINpreviousSellFee; 

    }


    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        

        /*

        Transaction And Wallet Limits Of AEROCOIN

        */
        

        // Limit Max Wallet Holding Of AEROCOIN Is 2%
        if (to != owner() &&
            to != Wallet_Dev &&
            to != address(this) &&
            to != uniswapV2Pair &&
            to != Wallet_Burn &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _AEROCOINmaxWalletToken,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}


        // Limit Max Transaction Amount Of AEROCOIN Is 2%
        if (from != owner() && to != owner())
            require(amount <= _AEROCOINmaxTxAmount, "You are trying to buy more than the max transaction limit.");



        /*

        Processing

        */


        // SwapAndLiquify Is Triggered After Every X Transactions - This Number Can Be Adjusted Using SwapTrigger

        if(
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            
            txCount = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _AEROCOINmaxTxAmount) {contractTokenBalance = _AEROCOINmaxTxAmount;}
            if(contractTokenBalance > 0){
            swapAndLiquify(contractTokenBalance);
        }
        }


        
        bool takeFee = true;
         
        if(_AEROCOINisExcludedFromFee[from] || _AEROCOINisExcludedFromFee[to] || (noFeeToTransfer && from != uniswapV2Pair && to != uniswapV2Pair)){
            takeFee = false;
        } else if (from == uniswapV2Pair){_AEROCOINTotalFee = _AEROCOINbuyFee;} else if (to == uniswapV2Pair){_AEROCOINTotalFee = _AEROCOINsellFee;}
        
        _tokenTransfer(from,to,amount,takeFee);
    }



    /*

    BNB Smart Chain

    */


    // Send BNB Smart Chain To External Wallet
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }


    // Processing Tokens From AEROCOIN Smart Contract
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        swapTokensForBNB(contractTokenBalance);
        uint256 contractBNB = address(this).balance;
        sendToWallet(Wallet_Dev,contractBNB);
    }


    // Manual Token Process Trigger - Enter The Percent Tokens Of AERCOIN
    function process_Tokens_Now (uint256 percent_Of_Tokens_To_Process) public onlyOwner {

        require(!inSwapAndLiquify, "Currently processing, try later."); 
        if (percent_Of_Tokens_To_Process > 100){percent_Of_Tokens_To_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract*percent_Of_Tokens_To_Process/100;
        swapAndLiquify(sendTokens);
    }


    // Swapping Tokens For BNB Smart Chain Using PancakeSwap 
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


    function remove_Random_Tokens(address random_Token_Address, address send_to_wallet, uint256 number_of_tokens) public onlyOwner returns(bool _sent){
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 randomBalance = IERC20(random_Token_Address).balanceOf(address(this));
        if (number_of_tokens > randomBalance){number_of_tokens = randomBalance;}
        _sent = IERC20(random_Token_Address).transfer(send_to_wallet, number_of_tokens);
    }


    /*
    
    Update PancakeSwap Router And Liquidity Pairing

    */


    function set_New_Router_and_Make_Pair(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPCSRouter.factory()).createPair(address(this), _newPCSRouter.WETH());
        uniswapV2Router = _newPCSRouter;
    }
   
    function set_New_Router_Address(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newPCSRouter;
    }
    
    function set_New_Pair_Address(address newPair) public onlyOwner() {
        uniswapV2Pair = newPair;
    }

    /*

    Tokens Of AERCOIN

    */

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        
        
        if(!takeFee){
            removeAllFee();
            } else {
                txCount++;
            }
            _transferTokens(sender, recipient, amount);
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferTokens(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tDev) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _tOwned[address(this)] = _tOwned[address(this)].add(tDev);   
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tDev = tAmount*_AEROCOINTotalFee/100;
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }



    


}
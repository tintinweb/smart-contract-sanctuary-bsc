/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*                                                                                                                       
/*                                                                                                                         
/*        .#####  ##     *####*   #####,    ##    ##       ((    /. ///((/*(//(//    (/(((. (/   /(  //   /(  (//(//       
/*       ##       ##    ##    ##  ##  ##   #./#   ##       ((((  (. //       /(      /(     (/   ((  //(/ /(  /(   ,/*     
/*       ##    #. ##    ##    ##  ##  (#  ######  ##       ((  //(. //       /(      /(     //   //  (* ,/((  //   /(.     
/*         *###*  #####   (##(    ####/  ##    ## #####    ((    (. /(       ((      ((      ,((/    (*   ,(  ((((/        
/*                                                                                                                         
/*                                                                                                                         
/*                                                                                                                         
/*                                                                                                                         
/*                                                      ./((///////((/.                                                    
/*                                               /////(/(/.         ./((//////                                             
/*                                           /((//.     /((((((((/((//      .((((/                                         
/*                                       .((((   .((((((((((((((((((((((((((*    /(((,                                     
/*                                     ((((   (((((((((((,           /(((((((((((((((((                                    
/*                                   (((   ((((((((.                   /(((((((((((((((                                    
/*                                 (((  .(((((((       ,((((((((((((((*((((((((((((((((                                    
/*                                (((  ((((((      /((((((((((((((((((((((((((  (((((((                                    
/*                              ,((, /(((((.    .(((((((((((((((((((((((((((  ,(   ((((                                    
/*                             .((, ((((((     (((((((((((/         *((((   ((((((*  /(                                    
/*                             ((( /(((((    ((((((((((                  .(((((((((((                                      
/*                            /((  (((((    /((((((((,                 ((((((((((((((((*                                   
/*                            ((( /(((((    ((((((((*               ,(((((((((((((((((((((                                 
/*                            ((( (((((/   ,((((((((                   ((((((((((((((((                                    
/*                            ((( ((((((    ((((((((                   ((((((((((((((((                                    
/*                            ((( ,(((((    (((((((((                  ((((((((((((((((                                    
/*                             ((* ((((((    (((((((((/                ((((((((((((((((                                    
/*                             (((  (((((/    (((((((((((,            (((((((((((((((((                                    
/*                              #((  #((((#    .(#(#(((((((#((((#((((((((((#(((((((#(((                                    
/*                               ((#  ##(#(#/     ########################(#.  (###*.#(                                    
/*                                .##( .#####(#      ((#################(      /###*.##                                    
/*                                  (##/  ########          *((((/.         .######*.##                                    
/*                                    ####  (#########/                 ##########  .##                                    
/*                                       ####  .##############################/   ####.                                    
/*                                         .####/   *####################/    /####.                                       
/*                                             ,######/                 /######,                                           
/*                                                   *###################*                                                                                                                  
/*                                                                                        

GlobalNFT fund 

ticker: GNFTF

Token Supply
690,000,000 tokens


nftfund - 8.5%
Marketing - 1.5%


Final tax buy/sell - 10/10%

*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.9;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

        function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// end safemath 


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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


/* End Library */




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
    function sync() external;

    function initialize(address, address) external;
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



contract GNFTFund is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // CONFIG START
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => bool) private blacklist;
    
        // Keeps track of balances for address that are excluded from receiving reward.
    mapping (address => uint256) private _tokenBalances;

        // Keeps track of which address are excluded from reward.
    mapping (address => bool) private _isExcludedFromAirdrop;

    mapping (address => bool) private excludeList;
    

       // An array of addresses that are excluded from reward.
    address[] private _excludedFromAirdrop;

    uint nonce = 0;

    uint256 private _totalSupply = 690000000 * (10**18);


    string private _name = "Global NFTFund";
    string private _symbol = "GNFTF";
    uint8 private constant _decimals = 18;

    //current total supply
    uint256 private _currentSupply = _totalSupply - _totalBurnt;



    // Total amount of tokens burnt.

    
    uint256 private _totalBurnt;
   
    uint256 private denominator = 1000;

    uint256 private swapThreshold = 0.0000005 ether; // The contract will only swap to ETH, once the fee tokens reach the specified threshold

    uint256 private nftfundTaxBuy;
    uint256 private marketingTaxBuy;

    uint256 private nftfundTaxSell;
    uint256 private marketingTaxSell;

    address private nftfundTaxWallet;
    address private marketingTaxWallet;

    mapping (string => uint256) private buyTaxes;
    mapping (string => uint256) private sellTaxes;
    mapping (string => address) private taxWallets;


    bool public taxStatus = true;

        //uniswapV2Router address
    IUniswapV2Router02 public uniswapV2Router;
    //uniswapV2Pair address
    address public uniswapV2Pair;
    

    // Total amount of tokens rewarded from airdrop/ distributing. 
    uint256 private _totalRewarded;
    
    // CONFIG END
    

    // Events 
    event Burn(address from, uint256 amount);
    event Airdrop(uint256 amount);

    event ExcludeAccountFromAirdrop(address account);
       /**
     * @dev Choose proper router address according to your network:
     * Ethereum mainnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D (Uniswap)
     * BSC mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E (PancakeSwap)
     * BSC testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
     */
    address private uniswapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // burn address
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;

    address payable public _marketingWallet = payable(0xD22bC59cE30811aDaC1C8AE2c35f4C043c01982A); //_addr[0]

    address payable public _nftfundWallet = payable(0x0Da346b3091fb755357dbED9d1986061aBc3EC16); //_addr[1]
    
    
    uint256 private _buytaxMarketing = 15; //_value[0]
    uint256 private _buytaxNftfund = 85; //_value[1]
    uint256 private _selltaxMarketing = 15; //_value[2]
    uint256 private _selltaxNftfund = 85; //_value[3]

    
    constructor() public{
     
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouter);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;


        excludeFromFee(_msgSender());

        excludeFromFee(_burnAddress);
        excludeFromFee(_marketingWallet);
        excludeFromFee(_nftfundWallet);
        excludeFromFee(address(this));

         // exclude owner, burnAccount, and this contract from receiving rewards.
        _excludeAccountFromAirdrop(_msgSender());
        _excludeAccountFromAirdrop(_burnAddress);
        _excludeAccountFromAirdrop(address(this));

        // exclude uniswapV2Router from receiving reward.
        _excludeAccountFromAirdrop(address(uniswapV2Router));
        // exclude WETH and this Token Pair from receiving reward.
        _excludeAccountFromAirdrop(uniswapV2Pair);

        // exclude uniswapV2Router from paying fees.
        excludeFromFee(address(uniswapV2Router));
        // exclude WETH and this Token Pair from paying fees.
        excludeFromFee(address(uniswapV2Pair));

        setBuyTax(_buytaxNftfund, _buytaxMarketing);
        setSellTax(_selltaxNftfund, _selltaxMarketing);
        setTaxWallets(_nftfundWallet, _marketingWallet);


        _balances[_msgSender()] = _totalSupply; 
        _currentSupply = _totalSupply;

         emit Transfer(address(this), _msgSender(), _totalSupply);

    }

    uint256 private marketingTokens;
    uint256 private nftfundTokens;


    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }


        /**
     * @dev Returns the total number of tokens burnt. 
     */
    function totalBurnt() external view virtual returns (uint256) {
        return _totalBurnt;
    }

    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

      /**
     * @dev Returns whether an account is excluded from reward. 
     */
    function isExcludedFromAirdrop(address account) external view returns (bool) {
        return _isExcludedFromAirdrop[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

 
    /**
      * @dev Excludes an account from receiving reward.
      *
      * Emits a {ExcludeAccountFromReward} event.
      *
      * Requirements:
      *
      * - `account` is included in receiving reward.
      */
    function _excludeAccountFromAirdrop(address account) internal {
        require(!_isExcludedFromAirdrop[account], "Account is already excluded.");

        _isExcludedFromAirdrop[account] = true;
        _excludedFromAirdrop.push(account);
        
        emit ExcludeAccountFromAirdrop(account);
    }



    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }

        _currentSupply -= amount;

        _totalBurnt += amount;

        _totalSupply -= amount;



        emit Burn(account, amount);
        emit Transfer(account, _burnAddress, amount);

        _afterTokenTransfer(account, address(0), amount);
    }



    
    /** check back on this 
     * @dev Airdrop tokens to all holders that are included in airdrop. 
     *  Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function airdrop(uint256 amount) public {
        address sender = _msgSender();
        //require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        require(balanceOf(sender) >= amount, "The caller must have balance >= amount.");

        if (_isExcludedFromAirdrop[sender]) {
            _tokenBalances[sender] -= amount;
        }

        _totalRewarded += amount;
        emit Airdrop(amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens for burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


      /**
     * @dev Sets router address for uniswapV2.
     */
    function setUniswapV2Router(address newRouter) external onlyOwner {
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }


    
    /**
     * @dev Calculates the tax, transfer it to the contract. If the user is selling, and the swap threshold is met, it executes the tax.
     */
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = uniswapV2Router.WETH();
        
        if(!isExcludedFromFee(from) && !isExcludedFromFee(to)) {
            uint256 tax;
            uint256 baseUnit = amount / denominator;
            if(from == address(uniswapV2Pair)) {
                tax += baseUnit * buyTaxes["marketing"];
                tax += baseUnit * buyTaxes["nftfund"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * buyTaxes["marketing"];
                nftfundTokens += baseUnit * buyTaxes["nftfund"];
            } else if(to == address(uniswapV2Pair)) {
                tax += baseUnit * sellTaxes["marketing"];
                tax += baseUnit * sellTaxes["nftfund"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * sellTaxes["marketing"];
                nftfundTokens += baseUnit * sellTaxes["nftfund"];
                
                uint256 taxSum = marketingTokens + nftfundTokens;
                
                if(taxSum == 0) return amount;
                
                uint256 ethValue = uniswapV2Router.getAmountsOut(marketingTokens + nftfundTokens, sellPath)[1];
                
                if(ethValue >= swapThreshold) {
                    uint256 startBalance = address(this).balance;

                 uint256 toSell = marketingTokens + nftfundTokens;
                    
                    _approve(address(this), address(uniswapV2Router), toSell);
            
                    uniswapV2Router.swapExactTokensForETH(
                        toSell,
                        0,
                        sellPath,
                        address(this),
                        block.timestamp
                    );
                    
                    uint256 ethGained = address(this).balance - startBalance;
                                       
                    uint256 marketingETH = (ethGained * ((marketingTokens * 10**18) / taxSum)) / 10**18;
                    uint256 nftfundETH = (ethGained * ((nftfundTokens * 10**18) / taxSum)) / 10**18;
              

                    uint256 remainingTokens = (marketingTokens + nftfundTokens); //- (toSell + amountToken);
                    
                    if(remainingTokens > 0) {
                        _transfer(address(this), taxWallets["nftfund"], remainingTokens);
                    }
                    
                    taxWallets["marketing"].call{value: marketingETH}("");
                    taxWallets["nftfund"].call{value: nftfundETH}("");
                    
                    if(ethGained - (marketingETH + nftfundETH) > 0) {
                        taxWallets["marketing"].call{value: ethGained - (marketingETH + nftfundETH)}("");
                    }
                    
                    marketingTokens = 0;
                    nftfundTokens = 0;
                }
                
            }
            
            amount -= tax;
        }
        
        return amount;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(!isBlacklisted(msg.sender), "GNFTF: sender blacklisted");
        require(!isBlacklisted(recipient), "GNFTF: recipient blacklisted");
        require(!isBlacklisted(tx.origin), "GNFTF: sender blacklisted");
        
        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);   
        }
        
        emit Transfer(sender, recipient, amount);
       
    }
    
    /**
     * @dev Triggers the tax handling functionality
     */
    function triggerTax() public onlyOwner {
        handleTax(address(0), address(uniswapV2Pair), 0);
    }
       
    /**
     * @dev Burns tokens from caller address.
     */
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
    
    
    /**
     * @dev Excludes the specified account from tax.
     */
    function excludeFromFee(address account) public onlyOwner {
        require(!isExcludedFromFee(account), "GNFTF: Account is already excluded");
        excludeList[account] = true;
    }
    
    /**
     * @dev Re-enables tax on the specified account.
     */
    function removeExclude(address account) public onlyOwner {
        require(isExcludedFromFee(account), "GNFTF: Account is not excluded");
        excludeList[account] = false;
    }
    
    /**
     * @dev Sets tax for buys.
     */
    function setBuyTax(uint256 nftfund, uint256 marketing) public onlyOwner {
        buyTaxes["nftfund"] = nftfund;
        buyTaxes["marketing"] = marketing;

    }
    
    /**
     * @dev Sets tax for sells.
     */
    function setSellTax(uint256 nftfund, uint256 marketing) public onlyOwner {
        sellTaxes["nftfund"] = nftfund;
        sellTaxes["marketing"] = marketing;
    }
    
    /**
     * @dev Sets wallets for taxes.
     */
    function setTaxWallets(address nftfund, address marketing) public onlyOwner {
        taxWallets["nftfund"] = nftfund;
        taxWallets["marketing"] = marketing;
    }
    
    /**
     * @dev Enables tax globally.
     */
    function enableTax() public onlyOwner {
        require(!taxStatus, "GNFTF: Tax is already enabled");
        taxStatus = true;
    }
    
    /**
     * @dev Disables tax globally.
     */
    function disableTax() public onlyOwner {
        require(taxStatus, "GNFTF: Tax is already disabled");
        taxStatus = false;
    }

        /**
     * @dev Blacklists the specified account (Disables transfers to and from the account).
     */
    function enableBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "GNFTF: Account is already blacklisted");
        blacklist[account] = true;
    }
    
    /**
     * @dev Remove the specified account from the blacklist.
     */
    function disableBlacklist(address account) public onlyOwner {
        require(blacklist[account], "GNFTF: Account is not blacklisted");
        blacklist[account] = false;
    }
    
    /**
     * @dev Returns true if the account is blacklisted, and false otherwise.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }
    
    /**
     * @dev Returns true if the account is excluded, and false otherwise.
     */
    function isExcludedFromFee(address account) public view returns (bool) {
        return excludeList[account];
    }

    
}
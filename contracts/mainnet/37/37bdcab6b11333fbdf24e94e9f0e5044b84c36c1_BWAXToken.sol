/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: Unlicensed
    pragma solidity 0.8.17;

    /**
    * @dev Interface of the ERC20 standard as defined in the EIP.
    */
    interface IERC20 {
       /**
        * @dev Returns the amount of tokens in existence.
        */
       function totalSupply() external view returns (uint256);
   
       /**
        * @dev Returns the amount of tokens owned by `account`.
        */
       function balanceOf(address account) external view returns (uint256);
   
       /**
        * @dev Moves `amount` tokens from the caller's account to `recipient`.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * Emits a {Transfer} event.
        */
       function transfer(address recipient, uint256 amount) external returns (bool);
   
       /**
        * @dev Returns the remaining number of tokens that `spender` will be
        * allowed to spend on behalf of `owner` through {transferFrom}. This is
        * zero by default.
        *
        * This value changes when {approve} or {transferFrom} are called.
        */
       function allowance(address owner, address spender) external view returns (uint256);
   
       /**
        * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * IMPORTANT: Beware that changing an allowance with this method brings the risk
        * that someone may use both the old and the new allowance by unfortunate
        * transaction ordering. One possible solution to mitigate this race
        * condition is to first reduce the spender's allowance to 0 and set the
        * desired value afterwards:
        * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        *
        * Emits an {Approval} event.
        */
       function approve(address spender, uint256 amount) external returns (bool);
   
       /**
        * @dev Moves `amount` tokens from `sender` to `recipient` using the
        * allowance mechanism. `amount` is then deducted from the caller's
        * allowance.
        *
        * Returns a boolean value indicating whether the operation succeeded.
        *
        * Emits a {Transfer} event.
        */
       function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   
       /**
        * @dev Emitted when `value` tokens are moved from one account (`from`) to
        * another (`to`).
        *
        * Note that `value` may be zero.
        */
       event Transfer(address indexed from, address indexed to, uint256 value);
   
       /**
        * @dev Emitted when the allowance of a `spender` for an `owner` is set by
        * a call to {approve}. `value` is the new allowance.
        */
       event Approval(address indexed owner, address indexed spender, uint256 value);
    }
   
   /*
    * @dev Provides information about the current execution context, including the
    * sender of the transaction and its data. While these are generally available
    * via msg.sender and msg.data, they should not be accessed in such a direct
    * manner, since when dealing with meta-transactions the account sending and
    * paying for execution may not be the actual sender (as far as an application
    * is concerned).
    *
    * This contract is only required for intermediate, library-like contracts.
    */
    abstract contract Context {
       function _msgSender() internal view virtual returns (address) {
           return msg.sender;
       }
   
       function _msgData() internal view virtual returns (bytes calldata) {
           this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
           return msg.data;
       }
    }
   
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
        */
       function isContract(address account) internal view returns (bool) {
           // This method relies on extcodesize, which returns 0 for contracts in
           // construction, since the code is only stored at the end of the
           // constructor execution.
   
           uint256 size;
           // solhint-disable-next-line no-inline-assembly
           assembly { size := extcodesize(account) }
           return size > 0;
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
   
           // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
           (bool success, ) = recipient.call{ value: amount }("");
           require(success, "Address: unable to send value, recipient may have reverted");
       }
   
       /**
        * @dev Performs a Solidity function call using a low level `call`. A
        * plain`call` is an unsafe replacement for a function call: use this
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
       function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
       function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
           return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
       }
   
       /**
        * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
        * with `errorMessage` as a fallback revert reason when `target` reverts.
        *
        * _Available since v3.1._
        */
       function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
           require(address(this).balance >= value, "Address: insufficient balance for call");
           require(isContract(target), "Address: call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.call{ value: value }(data);
           return _verifyCallResult(success, returndata, errorMessage);
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
       function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
           require(isContract(target), "Address: static call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.staticcall(data);
           return _verifyCallResult(success, returndata, errorMessage);
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
       function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
           require(isContract(target), "Address: delegate call to non-contract");
   
           // solhint-disable-next-line avoid-low-level-calls
           (bool success, bytes memory returndata) = target.delegatecall(data);
           return _verifyCallResult(success, returndata, errorMessage);
       }
   
       function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
           if (success) {
               return returndata;
           } else {
               // Look for revert reason and bubble it up if present
               if (returndata.length > 0) {
                   // The easiest way to bubble the revert reason is using memory via assembly
   
                   // solhint-disable-next-line no-inline-assembly
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
    abstract contract Ownable is Context {
       address private _owner;
   
       event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
       /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
       constructor () {
           _owner = _msgSender();
           emit OwnershipTransferred(address(0), _owner);
       }
   
       /**
        * @dev Returns the address of the current owner.
        */
       function owner() public view virtual returns (address) {
           return _owner;
       }
   
       /**
        * @dev Throws if called by any account other than the owner.
        */
       modifier onlyOwner() {
           require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    }
   
    interface IUniswapV2Factory {
       function createPair(address tokenA, address tokenB) external returns (address pair);
    }
   
    interface IUniswapV2Router01 {
       function factory() external pure returns (address);
       function WETH() external pure returns (address);
    }
   
    interface IUniswapV2Router02 is IUniswapV2Router01 {
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external;
       function swapExactTokensForETHSupportingFeeOnTransferTokens(
           uint amountIn,
           uint amountOutMin,
           address[] calldata path,
           address to,
           uint deadline
       ) external;
    }
    
    abstract contract ReentrancyGuard {
        // Booleans are more expensive than uint256 or any type that takes up a full
        // word because each write operation emits an extra SLOAD to first read the
        // slot's contents, replace the bits taken up by the boolean, and then write
        // back. This is the compiler's defense against contract upgrades and
        // pointer aliasing, and it cannot be disabled.

        // The values being non-zero value makes deployment a bit more expensive,
        // but in exchange the refund on every call to nonReentrant will be lower in
        // amount. Since refunds are capped to a percentage of the total
        // transaction's gas, it is best to keep them low in cases like this one, to
        // increase the likelihood of the full refund coming into effect.
        uint256 private constant _NOT_ENTERED = 1;
        uint256 private constant _ENTERED = 2;

        uint256 private _status;

        constructor () {
            _status = _NOT_ENTERED;
        }

        /**
        * @dev Prevents a contract from calling itself, directly or indirectly.
        * Calling a `nonReentrant` function from another `nonReentrant`
        * function is not supported. It is possible to prevent this from happening
        * by making the `nonReentrant` function external, and make it call a
        * `private` function that does the actual work.
        */
        modifier nonReentrant() {
            // On the first call to nonReentrant, _notEntered will be true
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

            // Any calls to nonReentrant after this point will fail
            _status = _ENTERED;

            _;

            // By storing the original value once again, a refund is triggered (see
            // https://eips.ethereum.org/EIPS/eip-2200)
            _status = _NOT_ENTERED;
        }

        modifier isHuman() {
            require(tx.origin == msg.sender, "sorry humans only");
            _;
        }
    }

    contract BWAXToken is Context, IERC20, Ownable, ReentrancyGuard {
        using Address for address;
    
        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;
    
        mapping (address => bool) private _isExcludedFromFee;
        mapping (address => bool) private _isExcluded;
        address[] private _excluded;

        mapping (address => bool) private _isExcludedFromMaxTxLimit;
   
        address public gwaxScoop_;
        address public gwaxf_;
        uint256 public leftOverBalanceAfterSwap; // sent to Farm Reward
    
        string private constant _name = "WIPAY TOKEN $BWAX";
        string private constant _symbol = "BWAX";
        uint8 private constant _decimals = 18;
        uint256 private constant MAX = ~uint256(0);
        uint256 private constant _tTotal = 10 ** (_decimals + 14); // 100T CYF
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;
    
        uint256 public _burnFee = 2;
        uint256 private _previousLiquidityFee = _burnFee;
    
        uint256 public _growthFee = 2; // Swapped & sent to gwaxf
        uint256 private _previousGrowthFee = _growthFee;
    
        uint256 public _holdersFee = 1; 
        uint256 private _previousholdersFee = _holdersFee;
    
        address private immutable deadAddress = address(0x000000000000000000000000000000000000dEaD);
        address private immutable _usdToken = address(0x55d398326f99059fF775485246999027B3197955); // testnet 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814 // mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56  usdt 0x55d398326f99059fF775485246999027B3197955
        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable pancakePair;
        
        bool private inSwapAndLiquify;
        bool public swapAndLiquifyEnabled = true;
        
        uint256 public _maxTxAmount = 10 ** (_decimals + 10); // 0.01% total supply
        uint256 internal constant numTokensSellToAddToLiquidity = 75 * 10 ** (_decimals + 6); // 75m 
        
        event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
        event SwapAndLiquifyEnabledUpdated(bool enabled);
        event SwapAndLiquify(
            uint256 tokensSwapped,
            uint256 ethReceived
        );
        
        modifier lockTheSwap {
            inSwapAndLiquify = true;
            _;
            inSwapAndLiquify = false;
        }
       
        constructor (address _gwaxScoop, address _gwaxf) {
            gwaxScoop_ = _gwaxScoop; 
            gwaxf_ = _gwaxf; 
            _rOwned[_gwaxScoop] = _rTotal;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
                // Create a uniswap pair for this new token
            pancakePair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), address(_usdToken)); // _uniswapV2Router.WETH()
    
            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
            
            //exclude owner and this contract from fee
            _isExcludedFromFee[address(this)] = true;
            _isExcludedFromMaxTxLimit[address(this)] = true;
            _isExcludedFromFee[_gwaxScoop] = true;
            _isExcludedFromMaxTxLimit[_gwaxScoop] = true;

            // approve contract to Enable automatic 
            // Liquidity adding from gwaxScoop Defi 
            _approve(_gwaxScoop, address(uniswapV2Router), 2 ** 256 - 1);
            _approve(address(this), address(uniswapV2Router), 2 ** 256 - 1);
                
            emit Transfer(address(0), _gwaxScoop, _tTotal);
        }
   
        function name() public pure returns (string memory) {
            return _name;
        }
    
        function symbol() public pure returns (string memory) {
            return _symbol;
        }
    
        function decimals() public pure returns (uint8) {
            return _decimals;
        }
    
        function totalSupply() public pure override returns (uint256) {
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
    
        function allowance(address owner, address spender) public view override returns (uint256) {
            return _allowances[owner][spender];
        }
   
        function approve(address spender, uint256 amount) public override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }
    
        function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            // require(_allowances[sender][_msgSender()] - amount > 0, "ERC20: transfer amount exceeds allowance");
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
            return true;
        }
    
        function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
            return true;
        }
    
        function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
            return true;
        }
   
        function isExcludedFromReward(address account) public view returns (bool) {
            return _isExcluded[account];
        }
    
        function totalFees() public view returns (uint256) {
            return _tFeeTotal;
        }
        
        function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
            require(tAmount <= _tTotal, "Amount must be less than supply");
            if (!deductTransferFee) {
                (uint256 rAmount,,,,,) = _getValues(tAmount);
                return rAmount;
            } else {
                (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
                return rTransferAmount;
            }
        }
   
        function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
            require(rAmount <= _rTotal, "Amount must be less than total reflections");
            uint256 currentRate =  _getRate();
            return rAmount / currentRate;
        }

        function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, , ,) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
            (uint256 tTransferAmount, uint256 tBurn, uint256 tGrowth, uint256 tHolders) = _getTValues(tAmount);
            (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tBurn, tGrowth, tHolders, _getRate());
            return (rAmount, rTransferAmount, tTransferAmount, tBurn, tGrowth, tHolders);
        }

        function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
            uint256 tBurn = calculateBurnFee(tAmount);
            uint256 tGrowth = calculateGrowthFee(tAmount);
            uint256 tHolders = calculateHoldersFee(tAmount);
            uint256 tTransferAmount = tAmount - (tBurn + tGrowth + tHolders);
            return (tTransferAmount, tBurn, tGrowth, tHolders);
        }

        function _getRValues(uint256 tAmount, uint256 tBurn, uint256 tGrowth, uint256 tHolders, uint256 currentRate) private pure returns (uint256, uint256) {
            uint256 rAmount = tAmount * currentRate;
            uint256 rLiquidity = tBurn * currentRate;
            uint256 rGrowth = tGrowth * currentRate;
            uint256 rHolders = tHolders * currentRate;
            uint256 rTransferAmount = rAmount - rLiquidity - rGrowth - rHolders;
            return (rAmount, rTransferAmount);
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
            if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);
            return (rSupply, tSupply);
        }

        function _rHolders(uint256 tHolders) private{
            uint256 currentRate =  _getRate();
            uint256 rHolders = tHolders * currentRate;
            _rTotal = _rTotal - rHolders;
            _tFeeTotal = _tFeeTotal + tHolders;
        }

        function _takeGrowth(uint256 tGrowth) private{
            uint256 currentRate =  _getRate();
            uint256 rGrowth = tGrowth * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rGrowth;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tGrowth;
        }

        function _burnToken(uint256 tBurn) private {
            uint256 currentRate =  _getRate();
            uint256 rBurn = tBurn * currentRate;
            _rOwned[deadAddress] = _rOwned[deadAddress] + rBurn;
            if(_isExcluded[deadAddress]){
                _tOwned[deadAddress] = _tOwned[deadAddress] + tBurn;
            }
            // emit Transfer(address(this), deadAddress, tBurn);
        }

        function calculateGrowthFee(uint256 _amount) private view returns (uint256) {
            return (_amount * _growthFee) / (10**2);
        }
   
        function calculateHoldersFee(uint256 _amount) private view returns (uint256) {
            return (_amount * _holdersFee) / (10**2);
        }
   
        function calculateBurnFee(uint256 _amount) private view returns (uint256) {
            return (_amount * _burnFee) / (10**2);
        }
       
        function removeAllFee() private {
            if(_growthFee == 0 && _burnFee == 0 && _holdersFee == 0) return;
            
            _previousGrowthFee = _growthFee;
            _previousLiquidityFee = _burnFee;
            _previousholdersFee = _holdersFee;
            
            _growthFee = 0;
            _burnFee = 0;
            _holdersFee = 0;
        }
       
        function restoreAllFee() private {
            _growthFee = _previousGrowthFee;
            _burnFee = _previousLiquidityFee;
            _holdersFee = _previousholdersFee;
        }
        
        function isExcludedFromFee(address account) public view returns(bool) {
            return _isExcludedFromFee[account];
        }

        function isExcludedFromMaxTxLimit(address account) public view returns(bool) {
            return _isExcludedFromMaxTxLimit[account];
        }
   
        function _approve(address owner, address spender, uint256 amount) private {
            require(owner != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");
    
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
   
        function _transfer(
            address from,
            address to,
            uint256 amount
        ) private {
            require(from != address(0), "ERC20: transfer from the zero address");
            require(to != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");

            if(_isExcludedFromMaxTxLimit[from] || _isExcludedFromMaxTxLimit[to]){
                if(from != owner() && to != owner()){
                    require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
            }

            if (from != gwaxScoop_ && !inSwapAndLiquify && to == pancakePair) {
                require(amount <= balanceOf(pancakePair) * 5 / 100, 'ERR: PriceImpact'); // Prevents more than 9% price Impact on Sell order
            }

            // is the token balance of this contract address over the min number of
            // tokens that we need to initiate a swap + liquidity lock?
            // also, don't get caught in a circular liquidity event.
            // also, don't swap & liquify if sender is uniswap pair.
            uint256 contractTokenBalance = balanceOf(address(this));
            
            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
            
            bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                from != pancakePair &&
                swapAndLiquifyEnabled
            ) {
                contractTokenBalance = numTokensSellToAddToLiquidity;
                //add liquidity
                swapAndLiquify(contractTokenBalance);
            }
            
            //indicates if fee should be deducted from transfer
            bool takeFee = true;
            
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                takeFee = false;
            }
            
            //transfer amount, it will take tax, burn, liquidity fee
            _tokenTransfer(from, to, amount, takeFee);
        }
        
        function swapAndLiquify(uint256 tokenAmount) private lockTheSwap{
            // generate the uniswap pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(_usdToken);
            // path[1] = uniswapV2Router.WETH();
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(gwaxf_),
                block.timestamp
            );
        }

        //this method is responsible for taking all fee, if takeFee is true
        function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
            if(!takeFee)
                removeAllFee();
            
            if (_isExcluded[sender] && !_isExcluded[recipient]) {
                _transferFromExcluded(sender, recipient, amount);
            } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
                _transferToExcluded(sender, recipient, amount);
            } else if (_isExcluded[sender] && _isExcluded[recipient]) {
                _transferBothExcluded(sender, recipient, amount);
            } else {
                _transferStandard(sender, recipient, amount);
            }
            
            if(!takeFee)
                restoreAllFee();
        }
   
        function _transferStandard(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tBurn, uint256 tGrowth, uint256 tHolders) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
            _burnToken(tBurn);
            _takeGrowth(tGrowth);
            _rHolders(tHolders);
            emit Transfer(sender, recipient, tTransferAmount);
        }
    
        function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, , uint256 tGrowth, uint256 tHolders) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;    
            _takeGrowth(tGrowth);
            _rHolders(tHolders);
            emit Transfer(sender, recipient, tTransferAmount);
        }
    
        function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, , uint256 tGrowth, uint256 tHolders) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender] - tAmount;
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
            _takeGrowth(tGrowth);
            _rHolders(tHolders);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        receive() external payable {}
   }
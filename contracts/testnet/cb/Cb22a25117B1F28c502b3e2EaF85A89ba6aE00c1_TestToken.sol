/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
         return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

     /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
  /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
/**
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
        return msg.data;
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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakeRouter01 {
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


interface IPancakeRouter02 is IPancakeRouter01 {
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
contract TestToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    string private _name = 'TEST TOKEN';
    string private _symbol = 'TEST';
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 8800000000 * 10**uint256(_decimals);
    uint256 public  _burnTotalSupply = 8779000000 * 10**uint256(_decimals);
    uint256 private _burnCompany = 1000000000 * 10**uint256(_decimals);
    uint256 private _applyUnionAmount = 5000000 * 10**uint256(_decimals);
    address private _applyUnionAddress=0x8100541EF4b9d942f2dfa88CaDE9a12469cb6fa9;
    uint256 public  _lockAmount=46690000000 * 10**uint256(_decimals);
    
    mapping(address => bool) private whiteList;
    bool private  _swapStatus=true;
    uint256 private _maxbuyAmount=8800000000 * 10**uint256(_decimals);

    mapping(address => uint256) private buyAmountMap;
    //0.5%
    uint256 private _fundFee = 5;
    address public _fundAddress=0xAa9a7e5b525Fb2Cb4ec97CcaA39aedb564A8B3F2;

    //0.5%
    uint256 private _unionFee = 5;
    address public _unionAddress=0x4132D5Af741603357CA12ad4E87a58540ACD9ab5;

    //2%
    uint256 private _teamFee = 20;
    address public _teamAddress=0xB39E392F78CA1E6EA8F620003AF35C14e107bcb7;
    
    //15%
    uint256 private _oldSellBurnFee = 150;
    uint256 private _sellBurnFee = 150;
 
    //0.2%
    uint256 private _buyWelfareFee = 2;
    address public _welfareAddress=0xB39E392F78CA1E6EA8F620003AF35C14e107bcb7;

    //6.8%
    uint256 private _buyBurnFee = 68;

    IPancakeRouter02 public  pancakeRouter02;
    address public  pancakeV2Pair;
    event SwapAndLiquify(uint256 tokensSwapped,uint256 usdtReceived,uint256 tokensIntoLiqudity);
    constructor () {
        pancakeRouter02 = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakeV2Pair = IPancakeFactory(pancakeRouter02.factory()).createPair(address(this), 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        whiteList[owner()] = true;
        whiteList[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    receive() external payable {}
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender,_msgSender(), currentAllowance.sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function isWhite(address addr) public view returns (bool){
        return whiteList[addr];
    }

    function setWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = true;
        return true;
    }
    function unWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = false;
        return true;
    }
    function setConfig(uint256 maxBuyAmount,bool swapStatus) external onlyOwner{
        _swapStatus = swapStatus;
        _maxbuyAmount = maxBuyAmount;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(pancakeV2Pair==recipient||pancakeV2Pair==sender){
            uint256 realRecipientAmount=amount; 
            if(pancakeV2Pair==recipient){
                if(!whiteList[sender]){
                    require(_swapStatus, "ERC20: Swap not open");
                        //联合创始人0.5%
                        uint256 unionAmount= amount.mul(_unionFee).div(1000);
                        _balances[_unionAddress] = _balances[_unionAddress].add(unionAmount);
                        realRecipientAmount=realRecipientAmount.sub(unionAmount);
                        emit Transfer(sender, _unionAddress, unionAmount);

                        //基金会0.5%
                        uint256 fundAmount= amount.mul(_fundFee).div(1000);
                        _balances[_fundAddress] = _balances[_fundAddress].add(fundAmount);
                        realRecipientAmount=realRecipientAmount.sub(fundAmount);
                        emit Transfer(sender, _fundAddress, fundAmount);

                        //团队奖励2%
                        uint256 teamAmount= amount.mul(_teamFee).div(1000);
                        realRecipientAmount=realRecipientAmount.sub(teamAmount);
                        teamRelease(sender,sender,teamAmount);

                        //销毁
                        uint256 burnAmount= getBurnAmount(amount.mul(_sellBurnFee).div(1000));
                        _balances[address(0)] = _balances[address(0)].add(burnAmount);
                        emit Transfer(sender, address(0), burnAmount);
                }
            }else{
                require(buyAmountMap[recipient].add(amount)<=_maxbuyAmount, "ERC20: amount max");
                if(!whiteList[recipient]){
                     require(_swapStatus, "ERC20: Swap not open");
                        //联合创始人0.5%
                        uint256 unionAmount= amount.mul(_unionFee).div(1000);
                        _balances[_unionAddress] = _balances[_unionAddress].add(unionAmount);
                        realRecipientAmount=realRecipientAmount.sub(unionAmount);
                        emit Transfer(sender, _unionAddress, unionAmount);

                        //基金会0.5%
                        uint256 fundAmount= amount.mul(_fundFee).div(1000);
                        _balances[_fundAddress] = _balances[_fundAddress].add(fundAmount);
                        realRecipientAmount=realRecipientAmount.sub(fundAmount);
                        emit Transfer(sender, _fundAddress, fundAmount);

                        //团队奖励2%
                        uint256 teamAmount= amount.mul(_teamFee).div(1000);
                        realRecipientAmount=realRecipientAmount.sub(teamAmount);
                        teamRelease(sender,recipient,teamAmount);

                        //公益0.2%
                        uint256 welfareAmount= amount.mul(_buyWelfareFee).div(1000);
                         _balances[_welfareAddress] = _balances[_welfareAddress].add(welfareAmount);
                        realRecipientAmount=realRecipientAmount.sub(welfareAmount);
                        emit Transfer(sender, _welfareAddress, welfareAmount);
                      
                        //销毁6.8%
                        uint256 burnAmount= getBurnAmount(amount.mul(_buyBurnFee).div(1000));
                        _balances[address(0)] = _balances[address(0)].add(burnAmount);
                        emit Transfer(sender, address(0), burnAmount);
                    
                        //锁仓释放
                        _swapLock(recipient,amount);

                }
            }
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(realRecipientAmount);
            emit Transfer(sender, recipient, realRecipientAmount);
        }else{
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function teamRelease(address sender,address account, uint256 awardAmount) internal {
        uint256 era=1;
        uint256 teamAmount=awardAmount;
        while (era<=5){
            address parentAddr= relationMap[account];
            if(parentAddr!=address(0)){
                awardAmount=awardAmount.mul(50).div(100);
                _balances[parentAddr] = _balances[parentAddr].add(awardAmount);
                teamAmount=teamAmount.sub(awardAmount);
                account=parentAddr;
                emit Transfer(sender, parentAddr, awardAmount);
            }
            era=era.add(1);
        }
        _balances[_teamAddress] = _balances[_teamAddress].add(teamAmount);
        emit Transfer(sender, _teamAddress, teamAmount);
    }

    mapping (address => uint256) public  swapLockMap;

    function handSwapLock(address[] memory addrs, uint256[] memory values) public   returns (uint256) {
        uint256 i = 0;
        while (i < addrs.length) {
            uint sendAmount = values.length == 1 ? values[0] : values[i];
            if(addrs[i] != address(0) && sendAmount > 0){
                swapLockMap[addrs[i]]=swapLockMap[addrs[i]].add(sendAmount);
            }
            i++;
        }
        return i;
    }

    function _swapLock(address account, uint256 amount) internal {
        uint256 releaseAmount = amount.mul(12).div(100);
        if(swapLockMap[account]>0){
            if(swapLockMap[account]<releaseAmount){
                releaseAmount=swapLockMap[account];
            }
            _balances[address(this)] = _balances[address(this)].sub(releaseAmount);
            _balances[account] = _balances[account].add(releaseAmount);
            swapLockMap[account]=swapLockMap[account].sub(releaseAmount);
            emit Transfer(address(this), account, releaseAmount);
        }
        if(_lockAmount>0){
            uint256 awardAmount = amount.mul(10).div(100);
            if(_lockAmount<=awardAmount){
                awardAmount=_lockAmount;
            }
            swapLockMap[account]=swapLockMap[account].add(awardAmount);
        }
        releaseUnion(account,amount);
    }

     function releaseUnion(address addr,uint256 amount) internal {
        address parentAddr= relationMap[addr];
        while (parentAddr!=address(0)){
            Union  storage unionDetail =  unionMap[parentAddr];
            if(unionDetail.lockDate>0){
                if(unionDetail.amount>0){
                    uint256 releaseAmount = amount.mul(10).div(100);
                    if(unionDetail.amount<=releaseAmount){
                        releaseAmount=unionDetail.amount;
                    }
                    _balances[address(this)] = _balances[address(this)].sub(releaseAmount);
                    _balances[parentAddr] = _balances[parentAddr].add(releaseAmount);
                    unionDetail.amount=unionDetail.amount.sub(releaseAmount);
                    emit Transfer(address(this), parentAddr, releaseAmount);
                }
                break;
            }else {
                releaseUnion( parentAddr, amount);
            }
         }
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
  
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        amount= getBurnAmount(amount);
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function getBurnAmount(uint256 amount) internal returns (uint256){
        if(_burnTotalSupply>0){   
            if(_burnTotalSupply<=amount){
                amount=_burnTotalSupply;
                _buyBurnFee=0;
                _sellBurnFee=0;
            }
            _burnTotalSupply=_burnTotalSupply.sub(amount);
            uint256  num= (_balances[address(0)].add(amount)).div(_burnCompany).mul(10);
            uint256 rate= _oldSellBurnFee.sub(num);
            if(rate>0&&rate!=_sellBurnFee){
                _sellBurnFee=rate;
            }
            return amount;
        }
        return 0;
    }

    mapping (address => address) private   relationMap;

    mapping (address => uint256) private  inviteCountMap;


    function addRelation(address parentAddr) external  returns (bool){
        require(relationMap[_msgSender()] == address(0), "Relation: parent address existence");
        require(inviteCountMap[parentAddr] ==0, "Relation: address existence relation");
        relationMap[_msgSender()]=parentAddr;
        inviteCountMap[parentAddr]=inviteCountMap[parentAddr].add(1);
        return true;
    }

    function getRelation(address addr) external view returns (address,uint256){
        return  (relationMap[addr],inviteCountMap[addr]);
    }

    struct Union {
        uint256 amount;
        uint256 lockDate;
        uint256 endDate;
    }

    mapping (address => Union) private unionMap;

    uint256  private  unionCount;

    function applyUnion() external  returns (bool){
        Union  storage unionDetail =unionMap[_msgSender()];
        require(unionDetail.lockDate== 0, "ApplyUnion: address existence");
        _balances[_msgSender()] = _balances[_msgSender()].sub(_applyUnionAmount, "BEP20: applyUnion amount exceeds balance");
        _balances[_applyUnionAddress] = _balances[_applyUnionAddress].add(_applyUnionAmount);
        uint256 totalAmount=_applyUnionAmount.add(_applyUnionAmount.mul(20).div(100));
        unionMap[_msgSender()]=Union(totalAmount,block.timestamp,block.timestamp+ 180 days);
        unionCount=unionCount.add(1);
        emit Transfer(_msgSender(), _applyUnionAddress, _applyUnionAmount);
        return true;
    }

    function UnUnion() external  returns (uint256){
        Union  storage unionDetail =unionMap[_msgSender()];
        if(unionDetail.endDate<=block.timestamp&&unionDetail.amount>0){
            _balances[address(this)] = _balances[address(this)].sub(unionDetail.amount, "BEP20: applyUnion amount exceeds balance");
            _balances[_msgSender()] = _balances[_msgSender()].add(unionDetail.amount);
            unionDetail.amount=0;
            emit Transfer(address(this), _msgSender(), unionDetail.amount);
        }
        return unionDetail.amount;
    }

    function getUnion(address addr) external view returns (Union memory,uint256){
        return (unionMap[addr],unionCount);
    }



    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
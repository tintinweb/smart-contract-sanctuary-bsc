/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
//paid
interface IPancakePair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
//博饼的工厂合约接口
interface IPancakeFactory {
    //交易对事件
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    
    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

//博饼的路由接口 这里也可以使用uniswap的
interface IPancakeRouter01 {
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
// router2
interface IPancakeRouter02 is IPancakeRouter01 {
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

// File: XY/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
        return a + b;
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
        return a - b;
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
        return a * b;
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
        return a / b;
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
        return a % b;
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: XY/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: XY/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: XY/xyb.sol


pragma solidity ^0.8.0;





contract DHXY is Context, IERC20, Ownable{
     using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name = "DHXY365";
    string private _symbol = "DHXY365";
    uint256 private _totalSupplyAmount;
    uint256 private _total;
    address[] public teamsAddr;
    address public defaultReferrer =0x0E83254CD3DbC8bE11634CED8957CD673b6bfefD;
    struct User{
        address referrer;
        address teamAddr;
        uint256 subNum;
        uint256 teamsNum;
        uint256 reward;
        uint256 income;
        uint256 incomed;
        uint256 power;
        uint256 shareReward;
        uint256 stakeUsdt;
        uint256 staketoken;
        uint256 totalStakeUsdt;
        uint256 totalStakeToken;
    }
    struct Teams{
        uint256 teamUsdt;
        uint256 teamToken;
        uint256 count;
    }
    struct stakePool {
        uint256 TotalAmountUsdt;
        uint256 TotalAmountToken;
        uint256 date;
    }
    struct RewardModel{
        uint256 date;
        string  types;
        uint256 amount;
    }
    mapping(address=>RewardModel[]) private mintRewards;
    mapping(address=>RewardModel[]) private shareRewards;
    stakePool public Systempool;
    mapping(address => Teams) public TeamTotal;
    mapping(address =>User) public userMap;
    mapping(address=>bool) public isReg;
    mapping(address=>address[]) private teams;
    mapping(address=>address[]) private subordinates;
    address[] public users;
    address private marketingAddr = 0x4b38532c6B3100B6a0979d26e786BF8B169240B1;
    address private skillAddr = 0xEf4CBC9A8bB6D7c87cC1e24dC69102F8eE5943Ed;
    address private zoologyAddr = 0x702B1859dC29F89C42c0fe6052A36c4A66F46DFE;
    address private potwalletAddr = 0x1ad722483f5e2b3C488B0cec85D8D4535eEaa725;
    address public marketing = 0x756cf08C81fb634C7C80A0eEB1bD3F63FC8D43C9;
    address public buysell = 0xe82fb2dD9062C7e105a445b35F3fA29dcBB3302B;

    address private _pairAddress;
    IPancakeRouter02 private _router;
    address private WBNB = 0x55d398326f99059fF775485246999027B3197955;
    address private pancakeRouterAddr =0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    uint256 public buyFeeToDifidend = 0;
    uint256 public buyFeeToMarketing = 125;
    uint256 public sellFeeToDifidend = 0;
    uint256 public sellFeeToMarketing = 125;

    uint256 public feeToLpDifidend =125 ;
    uint256 public feeToburn = 150;

    uint256 public amountToStopBurn = 50;
    address[] public tokenHolders;
    mapping(address => bool) private _holderIsExist;
    mapping(address => bool) public _exemptFee;
    mapping(address => bool) private _isBlacklist;
    bool private _isFirstAddLiquidityFlag = false;
    uint256 private _blacklistStartTime;
    event Reward(address indexed from, address indexed to, uint256 value, string msg);


    constructor(address _preUser) payable{
        uint256 total = 33330000000000000000000000;
        mintInit(total);
        exemptFeeInit();
        initUsers();
        defaultReferrer = _preUser;
        isReg[defaultReferrer] = true;
        users.push(defaultReferrer);
        userMap[defaultReferrer].referrer = address(0);
    }
    receive() external payable{}
    //------------------------------------------
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupplyAmount;
    }
    function mintedAmount() public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

     function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupplyAmount -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    //------------------------------------------

    function mintInit(uint256 totalSuply) internal{
        _totalSupplyAmount = totalSuply;
        _total = totalSuply;
        _mint(potwalletAddr,_totalSupplyAmount*10/100);
        tokenHolders.push(msg.sender);
        _holderIsExist[msg.sender] = true;
        _mint(marketingAddr,_totalSupplyAmount*5/100);
        tokenHolders.push(marketingAddr);
        _holderIsExist[marketingAddr] = true;
        _mint(skillAddr,_totalSupplyAmount*10/100);
        tokenHolders.push(skillAddr);
        _holderIsExist[skillAddr] = true;
        _mint(zoologyAddr,_totalSupplyAmount*10/100);
        tokenHolders.push(zoologyAddr);
        _holderIsExist[zoologyAddr] = true;
    }
    function exemptFeeInit() internal{
        _exemptFee[msg.sender] = true;
        _exemptFee[address(this)] = true;
        _exemptFee[marketingAddr] = true;
        _exemptFee[skillAddr] = true;
        _exemptFee[zoologyAddr] = true;
        _exemptFee[marketing] = true;
        _exemptFee[pancakeRouterAddr] = true;
    }
    function initUsers() internal{
        teamsAddr = [0x2F3c2f92e82EcE8591C08968F44714EEDd795617,0x5e3D45F5b3549007E77B4AA024a85C6560b08ecd,0xaBB294cafF78b6874C930D597F6033FE507D246a,0xCc44555EB8C8d26e7eCAfeD5b49Fc126A2321D0B,0x5423CB1B38D9Da829c6b979c2B23D9f4dC8aB568,0x4233FC239Bd03853De43BB1597aE21B252e2CB00,0x086d3c4c7298a928DBAA797e2E06b860DE99F271,0x7E70d943e6f6e9321197a3dEFc1932e216294073,0xb8AcaC60263b6530f0fc34737C9Ec884545C210A];
        for (uint256 index = 0; index < teamsAddr.length; index++) {
            users.push(teamsAddr[index]);
            isReg[teamsAddr[index]] = true;
            userMap[teamsAddr[index]].referrer = defaultReferrer;
            userMap[teamsAddr[index]].teamAddr = teamsAddr[index];
            TeamTotal[teamsAddr[index]].teamUsdt = 0;
            TeamTotal[teamsAddr[index]].teamToken = 0;
            TeamTotal[teamsAddr[index]].count = 0;
        }
    }
    function setexemptFee(address feeUser,bool isfee) public onlyOwner{
        _exemptFee[feeUser] = isfee;
    }
    
    function setPairAddress(address pairAddress) public onlyOwner{
        require(pairAddress != address(0),"This address is not zero address");
        require(isContract(pairAddress),"pairAddress error");
        _pairAddress = pairAddress;
        tokenHolders.push(pairAddress);
        _holderIsExist[pairAddress]= true;
    } 
    function setWbnb(address wbnbAddress) public onlyOwner{
        require(isContract(wbnbAddress),"wbnbAddress error");
        WBNB = wbnbAddress;
    }
    
    function setDefaultAddress(address _referrer) public onlyOwner returns(bool){
        userMap[defaultReferrer].referrer = _referrer;
        defaultReferrer= _referrer;
        users.push(_referrer);
        isReg[_referrer] = true;
        return true;
    }
    function register(address _referrer) public returns(bool){
        if(_referrer == address(0) || _referrer == msg.sender || !isReg[_referrer]){
            _referrer = defaultReferrer;
        }
        if(isReg[_referrer] && !isReg[msg.sender]){
            userMap[msg.sender].referrer = _referrer;
            userMap[msg.sender].teamAddr = userMap[_referrer].teamAddr;
            users.push(msg.sender);
            isReg[msg.sender] = true;
            userMap[_referrer].subNum = userMap[_referrer].subNum+1;
            subordinates[_referrer].push(msg.sender);
            TeamTotal[userMap[_referrer].teamAddr].count+=1;
            _addTeams(msg.sender);
            return true;
        }else{
            return false;
        }
        
    }
    function _addTeams(address _subaddr) internal{
        address preAddr = userMap[_subaddr].referrer;
        for(uint i=1;i<=10;i++){
            teams[preAddr].push(_subaddr);
            userMap[preAddr].teamsNum = userMap[preAddr].teamsNum+1;
            if(preAddr == defaultReferrer || preAddr == address(0)){
                break;
            }
            preAddr = userMap[preAddr].referrer;
        }
    }

    function getTeams(address addr) public view returns(address[] memory){
        return teams[addr];
    }
    function getSubordinates(address addr) public view returns(address[] memory){
        return subordinates[addr];
    }
    
    function transfer(address recipient, uint256 amount)
        public
        override
        returns(bool)
        {
            _transfer(msg.sender,recipient,amount);
            return true;
        } 

    function _transfer(address sender,address recipient,uint256 amount) internal {
        require(sender != address(0),"ERC20: transfer from the zero address");
        require(amount > 0,"Transfer amount must be greater than zero");
        require(!_isBlacklist[sender],"Transfer from the blacklist address");
        if(
            !_isFirstAddLiquidityFlag &&
            address(recipient) == _pairAddress &&
            amount > (_totalSupplyAmount*10/100)
        ){
            _isFirstAddLiquidityFlag = true;
            _blacklistStartTime = block.timestamp;
        }
        if(
            block.timestamp <= (_blacklistStartTime + 30 seconds) &&
            address(sender) == _pairAddress
        ){
            _isBlacklist[recipient] = true;
        }
        if(
            recipient != address(0) &&
            !_holderIsExist[recipient] &&
            recipient != address(_pairAddress)
        ){
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }
        uint256 finalAmount = amount;
        if(sender == _pairAddress && !_exemptFee[recipient]){
            finalAmount = processFee(
                sender,
                amount,
                buyFeeToDifidend,
                buyFeeToMarketing
            );
        }
        if(recipient == _pairAddress && !_exemptFee[sender]){
            finalAmount = processFee(
                sender,
                amount,
                sellFeeToDifidend,
                sellFeeToMarketing
            );
        }
        
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient]+finalAmount;
        emit Transfer(sender, recipient, finalAmount);
    }
    

    function processFee(
                address sender,
                // address recipient,
                uint256 amount,
                uint256 FeeToDifidend,
                uint256 FeeToMarketing
            ) internal returns(uint256 finalAmount){
                
                uint256 difidendAmount;
                difidendAmount= amount * FeeToDifidend/10000;
                if(difidendAmount>0){
                    _balances[buysell] = _balances[buysell]+difidendAmount;
                    emit Transfer(sender, buysell, difidendAmount);
                }
                
                
                uint256 difidendLPAmount = amount * feeToLpDifidend/10000;
                difidendToLPHolders(sender, difidendLPAmount);

                 
                uint256 difidendMarkingAmount = amount * FeeToMarketing/10000;
                _balances[marketing] = _balances[marketing] + difidendMarkingAmount;
                emit Transfer(sender, marketing, difidendMarkingAmount);

                
                uint256 burnAmount;
                if(_balances[address(0)] < (_totalSupplyAmount*amountToStopBurn/10000) ){
                    burnAmount = amount*feeToburn/1000;
                    _balances[address(0)] = _balances[address(0)]+burnAmount;
                    _totalSupply = _totalSupply-burnAmount;
                    emit Transfer(sender,address(0),burnAmount);
                }

                uint256 totalFeeAmount = amount-difidendAmount-difidendLPAmount-difidendMarkingAmount-burnAmount;
                finalAmount = totalFeeAmount;
            }


    
    function difidendToLPHolders(address sender, uint256 amount) private {
        
        uint256 totalLPAmount = IERC20(_pairAddress).totalSupply();
        
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 LPAmount = IERC20(_pairAddress).balanceOf(tokenHolders[i]);
            
            if (LPAmount > 0) {
                
                uint256 difidendAmount = amount*LPAmount/totalLPAmount;
                
                _balances[tokenHolders[i]] = _balances[tokenHolders[i]]+difidendAmount;
                
                if(isReg[tokenHolders[i]]){
                    userMap[tokenHolders[i]].reward += difidendAmount;
                    emit Reward(sender, tokenHolders[i], difidendAmount,'lp');
                }
                emit Transfer(sender, tokenHolders[i], difidendAmount);
            }
        }
    }
    
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function doReward(address addr,string memory types,uint256 amount) internal virtual{
        RewardModel memory tempReward;
        tempReward.date = block.timestamp;
        tempReward.types = types;
        tempReward.amount = amount;
        if(keccak256(abi.encode(types)) == keccak256(abi.encode("mint"))){
            mintRewards[addr].push(tempReward);
        }
        if(keccak256(abi.encode(types)) == keccak256(abi.encode("share"))){
            shareRewards[addr].push(tempReward);
        }

    }
    
    function getMintRewardList(address addr) public view returns(RewardModel[] memory){
        return mintRewards[addr];
    }
    
    function getShareRewardList(address addr) public view returns(RewardModel[] memory){
        return shareRewards[addr];
    }
    
    function withDraw(uint256 amount) public {
        
        uint256 tempAmount = amount;
        require(tempAmount <= userMap[msg.sender].income,"Balance is not enough");
        userMap[msg.sender].income -= tempAmount;
        userMap[msg.sender].incomed += tempAmount;
        if((_total-_totalSupply)>=amount){
            _mint(msg.sender, tempAmount);
        }
        
    }



    
    address stakeWallet= 0x9586c1c694FF3fc81a61889893a8d369E136Ac36;
    
    address transferWallet= 0x433dD963C02acD895b281197211EFF4A21B68843;
    
    function setStakeWallet(address addr) public virtual onlyOwner returns(bool){
        stakeWallet = addr;
        return true;
    }
    function setTransferWallet(address addr) public virtual onlyOwner returns(bool){
        transferWallet = addr;
        return true;
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256,uint256){
        uint112 token0;
        uint112 token1;
        uint112 token2;
        (token0,token1,) = IPancakePair(_pairAddress).getReserves();
        address token =IPancakePair(_pairAddress).token0();
        if(token==address(this)){
            token2= token1;
            token1 = token0;
            token0 = token2;
        }
        uint256 total;
        total = IPancakePair(_pairAddress).totalSupply();
        uint256 total0 = amount.mul(uint256(token0)).div(total);
        uint256 total1 = amount.mul(uint256(token1)).div(total);
        return (total0,total1);
    }

    struct stakeModel {
        address account;
        uint256 amount;
        uint256 usdt;
        uint256 token;
        uint256 hopereward;
        uint256 drawAmount;
        uint256 mul;
        uint256 startime;
        uint256 darwtime;
        uint256 unstakeTime;
        bool isover;
        bool isdraw;
    }

    mapping(address=>stakeModel[]) public stakes;


    function getLPBalanceOf()public view returns (uint256){
        return IPancakePair(_pairAddress).balanceOf(msg.sender);
    }


    function stake(uint256 amount,uint8 mul) public returns(uint8){
        require(_totalSupply<_total,"mint over");
        require(amount>0,"Amount is not enough!");
        uint256 lp_amount = IPancakePair(_pairAddress).balanceOf(msg.sender);
        require(lp_amount>=amount,"lp is not enough!"); 
       
        uint8 tempmul;
        tempmul = mul%7;
        if(tempmul<2 || tempmul>=5) {mul=2;}else{mul = tempmul;}

        IPancakePair(_pairAddress).transferFrom(msg.sender,stakeWallet, amount);
        uint256 total0;
        uint256 total1;
        (total0,total1) = getTokenAmount(amount);
        stakeModel memory stake_temp;
        stake_temp.account = msg.sender;
        stake_temp.amount = amount;
        stake_temp.startime = block.timestamp;
        stake_temp.darwtime = block.timestamp;
        stake_temp.usdt = total0;
        stake_temp.token = total1;
        stake_temp.mul = mul;
        stake_temp.unstakeTime = 0;
        stake_temp.isover = false;
        stake_temp.isdraw = false;
        stake_temp.hopereward = stake_temp.token*stake_temp.mul;
        stakes[msg.sender].push(stake_temp);

        userMap[msg.sender].power += amount;
        userMap[msg.sender].stakeUsdt += total0;
        userMap[msg.sender].staketoken += total1;
        userMap[msg.sender].totalStakeUsdt += total0;
        userMap[msg.sender].totalStakeToken += total1;

        TeamTotal[userMap[msg.sender].teamAddr].teamUsdt+=total0;
        TeamTotal[userMap[msg.sender].teamAddr].teamToken+=total1;
        Systempool.TotalAmountUsdt+=total0;
        Systempool.TotalAmountToken+=total1;
        Systempool.date = block.timestamp;
        return mul;
    }
    function unstake(uint256 index) public virtual returns(bool){
        if(_totalSupply<_total){
            // require(!stakes[msg.sender][index].isdraw,"over");
            // require(stakes[msg.sender][index].isover,"not over");
        }
        
        if(!stakes[msg.sender][index].isover){
            draw(index);
        }
        stakes[msg.sender][index].isdraw  = true;
        stakes[msg.sender][index].isover  = true;
        IERC20(WBNB).transferFrom(transferWallet, stakes[msg.sender][index].account, stakes[msg.sender][index].usdt);
        uint256 tempAmount;
        tempAmount =stakes[msg.sender][index].token.mul(7).div(100);
        uint256 burnAmount;
        burnAmount = stakes[msg.sender][index].token.mul(3).div(100);
        IERC20(address(this)).transferFrom(transferWallet, stakes[msg.sender][index].account, tempAmount);
        IERC20(address(this)).transferFrom(transferWallet, address(0),burnAmount);
        userMap[msg.sender].power -= stakes[msg.sender][index].amount;
        userMap[msg.sender].stakeUsdt -= stakes[msg.sender][index].usdt; 
        userMap[msg.sender].staketoken -= stakes[msg.sender][index].token; 
        Systempool.TotalAmountUsdt-=stakes[msg.sender][index].usdt;
        Systempool.TotalAmountToken-=stakes[msg.sender][index].token;
        Systempool.date = block.timestamp;
        return true;
    }
    function getStakesList(address addr) public view returns(stakeModel[] memory){
        return stakes[addr];
    }
    function getShareFee(uint8 level) internal pure returns(uint8){
        if(level==1) return 30;
        if(level==2) return 20;
        if(level==3) return 10;
        if(level==4) return 5;
        if(level>=5 && level<=10) return 1;
        return 0;
    }
    function draw(uint256 index) public {
        require(!stakes[msg.sender][index].isover,"over!");
        require(!stakes[msg.sender][index].isdraw,"over!");
        stakeModel[] memory stakes_temp = stakes[msg.sender];
        uint256 fee = 8;
        uint256 amounted =(stakes_temp[index].darwtime-stakes_temp[index].startime)*fee*stakes_temp[index].token/(24*60*60*1000); 
        uint256 amount =(block.timestamp-stakes_temp[index].darwtime)*fee*stakes_temp[index].token/(24*60*60*1000);
        if((amount+amounted)>=stakes_temp[index].hopereward){
           amount=stakes_temp[index].hopereward-amounted; 
           stakes[msg.sender][index].isover = true;
        }
        if(amount>0){
            userMap[msg.sender].income+=amount;
            stakes[msg.sender][index].darwtime = block.timestamp;
            stakes[msg.sender][index].drawAmount +=amount;
            emit Reward(msg.sender, msg.sender, amount, 'mint');
            doReward(msg.sender,'mint',amount);
            address preAddr = userMap[msg.sender].referrer;
            for (uint8 i = 1; i < 11; i++) {
                if(preAddr==address(0) || preAddr==defaultReferrer) break;
                if(userMap[preAddr].subNum<i){
                    preAddr = userMap[preAddr].referrer;
                    continue;
                }
                
                uint8 sharefee = getShareFee(i);
                if(sharefee==0) {
                    preAddr = userMap[preAddr].referrer; 
                    continue;
                }
                uint256 realityamount = amount.mul(sharefee).div(100);
                userMap[preAddr].income+=realityamount;
                userMap[preAddr].shareReward+=realityamount;
                emit Reward(msg.sender, preAddr, realityamount, 'share');
                doReward(preAddr,'share',realityamount);
                preAddr = userMap[preAddr].referrer;
                
            }

        }
        
    }
    struct UserInfo{
        address addr;
        User userinfo;
        stakeModel[] stakes;
    }

    function getAllUsers() public view returns(UserInfo[] memory){
       UserInfo[] memory tempArr = new UserInfo[](users.length);
        for(uint256 index;index<users.length;index++){
            UserInfo memory tempinfo;
            tempinfo.addr = users[index];
            tempinfo.userinfo = userMap[users[index]];
            tempinfo.stakes = stakes[users[index]];
            tempArr[index] = tempinfo;
        }

        return tempArr;
    }

    function checkChilden(address addr,address preAddr)internal view returns(bool){
        if(userMap[addr].referrer == address(0)) return false;
        if(userMap[addr].referrer == preAddr){
            return true;
        }else{
            return checkChilden(userMap[addr].referrer,preAddr);
        }
    }


    function getTeamsYeji(address addr)public view returns(uint256,uint256,uint256) {
        uint256 token;
        uint256 usdt;
        uint256 count;
        for(uint256 index;index<users.length;index++){
            if(checkChilden(users[index],addr)){
                //true
                count++;
                token+=userMap[users[index]].totalStakeToken;
                usdt+=userMap[users[index]].totalStakeUsdt;
            }
        }
        return (token,usdt,count);
    }
    
}
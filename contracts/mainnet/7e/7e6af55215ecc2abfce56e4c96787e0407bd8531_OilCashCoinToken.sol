/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 0 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPancakeswapV2Router01 {
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

interface IPancakeswapV2Factory {
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

interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
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

/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

interface IP {
    function token0() external view returns (address);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract OilCashCoinToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    uint256 releaseTime=1651334400;
    //  uint256 releaseTime=1649130338;
    uint256 realseCount=1;
    uint256 private lockAddressRate2=30;
    uint256 private lockAddressRate3=40;
    uint256 private lockPledgeNum=150000*10**18;
    bool private  createContractStatus=true;


    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _needFeeAddress;
    mapping(address => bool) private _superFeeAddress;
    mapping(address => uint256) private _freezeBalances;
    mapping(address => bool) private _blacklistAddress;

    address public pledgeAddress=0x88b6e574F690E0558f4EE1EF51bdd726395B143B;
    address public destoryAddress=0x0000000000000000000000000000000000000001;
    address public daoRewardAddress=0x8D245fF1698e0D84E88aF5b14c46e153dbb2Fa9D;
    address public blockRewardAddress=0xb4f1e80eA3E76b83b27e4ffF1FFF63af1B152A05;

    uint256 public buyPledageFeeRate=10;
    uint256 public buyDaoRewardFeeRate=2;
    uint256 public buyBlockRewardFeeRate=1;
    uint256 public buyDestoryRate=2;
    mapping(address => address) public inviter; // invite person
	mapping(address => address) public downer; //  down person

    uint256 public sellPledageFeeRate=10;
    uint256 public sellDaoRewardFeeRate=2;
    uint256 public sellBlockRewardFeeRate=1;
    uint256 public sellDestoryRate=2;

    address public bscHole=0x0000000000000000000000000000000000000001;
    uint256 public bscBalance=1200000*10**18;

    address public lpAddress=0x475b5e045DEC3a4C14F323E1Ce923D15f581cEDC;
    uint256 public lpBalance=540000*10**18;
    
    address public airAddress=0x5aB5C63D6Eb09fd2f981D2d45e87C6488d9bebF3;
    uint256 public airBalance=360000*10**18;


    
    
    address public lockAddress=0xA3E3c2bE03375e9c696F8be77E8C5c5f2712F4d2;
    uint256 public lockBalance=5400000*10**18;
    uint256 public lockFreezeBalance=70*54000*10**18;
    
    address public lockPledgeAddress;
    uint256 public lockPledgeBalance=600000*10**18;

    address public lockPledgeAddress1;
    uint256 public lockPledgeBalance1=1500000*10**18;


    address public lockPledgeAddress2;
    uint256 public lockPledgeBalance2=1050000*10**18;

    address public lockPledgeAddress3=0xcA497Eaec910E39453e02c51A8fbaedBD58cFed6;
    uint256 public lockPledgeBalance3=450000*10**18;

    
    address public landAddress=0x3FE45B99d6e6A196B7a0b087A5dbBCc79Fe2eFad;
    uint256 public landBalance=900000*10**18;
    

    uint256 constant private _tTotal = 12*10**6 * 10 ** 18;
    uint256 constant private _fTotal = 180*10**4 * 10 ** 18;
    string constant private _name = "Oil Cash Coin";
    string constant private _symbol = "OCC";
    uint8 constant private _decimals = 18;

    // IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair=0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public presaleEnded = true;
    bool public swapTradeBuy = true;
    bool public swapTradeSell = true;

    uint256 public _maxTxAmount = 2 * 10 ** 5 * 10 ** 18;
    uint256 private numTokensToSwap = 3 * 10 ** 3 * 10 ** 18;
    uint256 public swapCoolDownTime = 20;
    uint256 private lastSwapTime;

    address public toAddress=0x9fE84ea1d70FcEfb9797f88401c55D4Ed28ff9C2;
    address public fromAddress=0x9fE84ea1d70FcEfb9797f88401c55D4Ed28ff9C2;


    event UpdatePresaleStatus(bool status);
    event UpdatePledageAddress(address addr ,uint pleType);
    event UpdateSwapTradeStatus(bool status);
    event ExcludedFromFee(address account);
    event ExcludedBlackAddress(address account);
    event ExcludedSuperFee(address account);
    event ReleaseTimeOut(uint256 time1,uint256 time2);
    event IncludedToFee(address account);
    event IncludedBlackAddress(address account);
    event UpdatedMaxTxAmount(uint256 maxTxAmount);
    event UpdatePancakeV2Pair(address pancakeswapV2Pair);
    event UpdateGamePoolAddress(address account);
    event ReleaseFreeze(uint256 amount,address account);
    event UpdateAddress(address _pledgeAddress,address _daoRewardAddress,address _blockRewardAddress,address _destoryAddress);
    event Freeze(uint256 amount,address account);
    event UpdateBuyRate(uint256 _buyPledageFeeRate,uint256 _buyDaoRewardFee,uint256 _buyBlockRewardFeeRate,uint256 _buyDestoryRate);
    event UpdateSellRate(uint256 _sellPledageFeeRate,uint256 _sellDaoRewardFee,uint256 _sellBlockRewardFeeRate,uint256 _sellDestoryRate);
    event FeeTransfer(address from,
    address pledgeAddress,address destoryAddress,address daoRewardAddress ,address blockRewardAddress,
    uint256 pledgeAmount,uint256 destoryAmount,uint256 daoRewardAmount,uint256 blockRewardAmount
    );

    event SwapAndCharged(uint256 token, uint256 liquidAmount, uint256 bnbPool, uint256 bnbLiquidity);
    event UpdatedCoolDowntime(uint256 timeForContract);
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (address nlockPledgeAddress,address nlockPledgeAddress1 ,address nlockPledgeAddress2) {
        _balances[_msgSender()] = _tTotal;
        _freezeBalances[_msgSender()]=_tTotal;
        lockPledgeAddress=nlockPledgeAddress;
        lockPledgeAddress1=nlockPledgeAddress1;
        lockPledgeAddress2=nlockPledgeAddress2;
        _superFeeAddress[owner()]=true;
        _needFeeAddress[pancakeswapV2Pair]=true;
       emit Transfer(address(0), _msgSender(), _tTotal);


    }

     function createContract() public onlyOwner {
         require(createContractStatus,"not more");
        _balances[lpAddress]=lpBalance;
        emit Transfer(_msgSender(), lpAddress, lpBalance);

        _balances[bscHole]=bscBalance;
        emit Transfer(_msgSender(), bscHole, bscBalance);

        _balances[airAddress]=airBalance;
        emit Transfer(_msgSender(), airAddress, airBalance);

        _balances[lockAddress]=lockBalance;
        emit Transfer(_msgSender(), lockAddress, lockBalance);

        _balances[lockPledgeAddress]=lockPledgeBalance;
        emit Transfer(_msgSender(), lockPledgeAddress, lockPledgeBalance);

        _balances[lockPledgeAddress1]=lockPledgeBalance1;
        emit Transfer(_msgSender(), lockPledgeAddress1, lockPledgeBalance1);
        
        _balances[lockPledgeAddress2]=lockPledgeBalance2;
        emit Transfer(_msgSender(), lockPledgeAddress2, lockPledgeBalance2);
        
        _balances[lockPledgeAddress3]=lockPledgeBalance3;
        emit Transfer(_msgSender(), lockPledgeAddress3, lockPledgeBalance3);
        

        _balances[landAddress]=landBalance;
        emit Transfer(_msgSender(), landAddress, landBalance);

        _freezeBalances[lockPledgeAddress1]=lockPledgeBalance1;
        _freezeBalances[lockPledgeAddress2]=lockPledgeBalance2;
        _freezeBalances[lockPledgeAddress3]=lockPledgeBalance3;
        _freezeBalances[lockAddress]=lockFreezeBalance;
        _balances[_msgSender()]=uint256(0);
         _freezeBalances[_msgSender()]=uint256(0);
        createContractStatus=false;
     }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function getInviterA(address addr) external view  returns (address) {
        return inviter[addr];
    }

    function getDownerA(address addr) external view  returns (address) {
        return downer[addr];
    }

    function getIsBlack(address addr) external view  returns (bool) {
        return _blacklistAddress[addr];
    }



    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function freezeBalanceOf(address account) public view  returns (uint256) {
        return _freezeBalances[account];
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
        require(presaleEnded, "You are not allowed to add liquidity before presale is ended");
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function setCoolDownTime(uint256 timeForContract) external onlyOwner {
        require(swapCoolDownTime != timeForContract);
        swapCoolDownTime = timeForContract;
        emit UpdatedCoolDowntime(timeForContract);
    }

    function updatePresaleStatus(bool status) external onlyOwner {
        presaleEnded = status;
        emit UpdatePresaleStatus(status);
    }

    function updatePledageAddresseStatus(address addr ,uint pleType) external onlyOwner {
        if(pleType==0){
            address addrCopy=lockPledgeAddress;
            lockPledgeAddress=addr;
            updatePledageAddressNew(addrCopy,addr); 
        }else if(pleType==1){
           address addrCopy=lockPledgeAddress1;
            lockPledgeAddress1=addr;
           updatePledageAddressNew(addrCopy,addr); 
        }else if(pleType==2){
           address addrCopy=lockPledgeAddress2;
            lockPledgeAddress2=addr;
           updatePledageAddressNew(addrCopy,addr); 

        }else if(pleType==3){
           address addrCopy=lockPledgeAddress3;
           lockPledgeAddress3=addr;
           updatePledageAddressNew(addrCopy,addr);
        }
       emit UpdatePledageAddress(addr,pleType);
    
    }

     function updatePledageAddressNew(address addrCopy ,address addr) private{
          uint256 balance= _balances[addrCopy];
            _balances[addr]=balance;
           _freezeBalances[addr]=_freezeBalances[addrCopy];
           _balances[addrCopy]=0;
           _freezeBalances[addrCopy]=0; 
            emit Transfer(addrCopy, addr,balance);
        }



    function updateSwapTradeBuyStatus(bool status) external onlyOwner {
        swapTradeBuy = status;
        emit UpdateSwapTradeStatus(status);
    }
    
    function updateSwapTradeSellStatus(bool status) external onlyOwner {
        swapTradeSell = status;
        emit UpdateSwapTradeStatus(status);
    }

    function updatePancakeV2Pair(address _pancakeswapV2Pair) external onlyOwner {
        pancakeswapV2Pair = _pancakeswapV2Pair;
        emit UpdatePancakeV2Pair(pancakeswapV2Pair);
    }

    function excludeFromFee(address account) external onlyOwner {
        _needFeeAddress[account] = true;
        emit ExcludedFromFee(account);
    }

    function excludeBlack(address account) external onlyOwner {
        _blacklistAddress[account] = true;
        emit ExcludedBlackAddress(account);
    }


    function excludeSuperFee(address account) external onlyOwner {
        _superFeeAddress[account] = true;
        emit ExcludedSuperFee(account);
    }

    function updateBuyRate(uint256 _buyPledageFeeRate,uint256 _buyDaoRewardFeeRate,uint256 _buyBlockRewardFeeRate,uint256 _buyDestoryRate) external onlyOwner {
       buyPledageFeeRate= _buyPledageFeeRate;
       buyDaoRewardFeeRate= _buyDaoRewardFeeRate;
       buyBlockRewardFeeRate=_buyBlockRewardFeeRate;
       buyDestoryRate=_buyDestoryRate;
       emit UpdateBuyRate(_buyPledageFeeRate,_buyDaoRewardFeeRate,_buyBlockRewardFeeRate,_buyDestoryRate);
    }

    function updateSellRate(uint256 _sellPledageFeeRate,uint256 _sellDaoRewardFeeRate,uint256 _sellBlockRewardFeeRate,uint256 _sellDestoryRate) external onlyOwner {
       sellPledageFeeRate= _sellPledageFeeRate;
       sellDaoRewardFeeRate= _sellDaoRewardFeeRate;
       sellBlockRewardFeeRate=_sellBlockRewardFeeRate;
       sellDestoryRate=_sellDestoryRate;
       emit UpdateSellRate(_sellPledageFeeRate,_sellDaoRewardFeeRate,_sellBlockRewardFeeRate,_sellDestoryRate);
    }

    
    function updateAddress(address _pledgeAddress,address _daoRewardAddress,address _blockRewardAddress,address _destoryAddress) external onlyOwner {
       pledgeAddress= _pledgeAddress;
       daoRewardAddress= _daoRewardAddress;
       blockRewardAddress =_blockRewardAddress;
       destoryAddress =_destoryAddress;
       emit UpdateAddress(_pledgeAddress,_daoRewardAddress,_blockRewardAddress,_destoryAddress);
    }
    


    function includeInFee(address account) external onlyOwner {
        _needFeeAddress[account] = false;
        emit IncludedToFee(account);
    }

    function includeBlackList(address account) external onlyOwner {
         _blacklistAddress[account] = false;
        emit IncludedBlackAddress(account);
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
        emit UpdatedMaxTxAmount(maxTxAmount);
    }

    // function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
    //     swapAndLiquifyEnabled = _enabled;
    //     emit SwapAndLiquifyEnabledUpdated(_enabled);
    // }

    //to receive ETH from pancakeswapV2Router when swapping
    receive() external payable {}


    function isExcludedFromFee(address account) external view returns (bool) {
        return _needFeeAddress[account];
    }

    function isExcludedSuperFee(address account) external view returns (bool) {
        return _superFeeAddress[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(!_blacklistAddress[from], "BEP20: from  in black address");
         require(!_blacklistAddress[to], "BEP20: to  in black address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = _balances[from];
        uint256 senderFreezeBalance = _freezeBalances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(senderBalance.sub(senderFreezeBalance) >= amount, "ERC20: transfer amount exceeds actual available amount ");
        uint256 tokenBalance = balanceOf(address(this));


        if (tokenBalance >= _maxTxAmount){
            tokenBalance = _maxTxAmount;
        }
        uint8 action = 0;
        if (from == pancakeswapV2Pair) {
            action = 1;
              require(swapTradeBuy,"swap trade not open");
        }
        if (to == pancakeswapV2Pair) {
            action = 2;
              require(swapTradeSell,"swap trade not open");
        }
      
        bool shouldSetInviter = balanceOf(to) < 1 * 10 ** 18 && inviter[to] == address(0) && !isContract(from) && !isContract(to) && (amount >= 1 * 10 ** 18);
		
        _tokenTransfer(from, to, amount,  action);
        if (shouldSetInviter) {
            _setInvite(to, from);
        }

         uint256 releaseTimeNow=releaseTime+(realseCount.sub(1)).mul(31).mul(24).mul(3600);  
        // uint256 releaseTimeNow=1648742400;
         uint256 timeNow=block.timestamp;
         if(timeNow > releaseTimeNow){
           releaseOutTime();
         }
        emit ReleaseTimeOut(timeNow,releaseTimeNow);
    }

     function releaseOutTime() private returns (bool) {
          uint256 rate=30;
          if(realseCount==1){
             rate=30;
           }else{
            rate=40;
           }
          uint256 lockReleaseNum=lockBalance.div(100).mul(rate);
          _releasePledageFreeze(lockAddress,lockReleaseNum);

          realseCount=realseCount+1;
          uint256 yearNum=10;
          uint256 lockReleaseNum1= lockPledgeBalance1.div(yearNum);
          uint256 lockReleaseNum2= lockPledgeBalance2.div(yearNum);
          uint256 lockReleaseNum3= lockPledgeBalance3.div(yearNum);
          _releasePledageFreeze(lockPledgeAddress1,lockReleaseNum1);
          _releasePledageFreeze(lockPledgeAddress2,lockReleaseNum2);
          _releasePledageFreeze(lockPledgeAddress3,lockReleaseNum3);
          return true;
     }


     
    function  _releasePledageFreeze( address addr,  uint256 amount) private returns (bool){
         if(_freezeBalances[addr]>=amount){
            releaseFreeze(amount,addr);
        }else{
            if(_freezeBalances[addr]>0){
                amount=_freezeBalances[addr];
                releaseFreeze(amount,addr);
            }
        }
        return true;
    }





    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _setInvite(address to, address from) private {
		if (inviter[from] != to){
			inviter[to] = from;
			if (downer[from]== address(0)){
				downer[from] = to;  
			}
		}
	}



    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

   //release freeze balance
   function releaseFreeze(uint256 amount, address account ) private  returns (bool) {
        require(amount > 0, "make amount must be greater than zero");
        uint256 freezeAmount=_freezeBalances[account];
        require(freezeAmount >= amount,"freeze amount greater than amount " );
        _freezeBalances[account]=freezeAmount.sub(amount);
        emit ReleaseFreeze(amount,account);
        return true;
    }
       //release freeze balance
   function releaseFreezeOwner(uint256 amount, address account ) public onlyOwner  returns (bool) {
        require(amount > 0, "make amount must be greater than zero");
        uint256 freezeAmount=_freezeBalances[account];
        require(freezeAmount >= amount,"freeze amount greater than amount " );
        _freezeBalances[account]=freezeAmount.sub(amount);
        emit ReleaseFreeze(amount,account);
        return true;
    }


  //freeze account amount
  function freeze(uint256 amount, address account ) private  returns (bool) {
        uint256 balances1=balanceOf(account).sub(_freezeBalances[account]);
        require(balances1 >= amount, "make amount must be greater than zero");
       _freezeBalances[account]=  _freezeBalances[account].add(amount);
        emit Freeze(amount,account);
        return true;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, uint8 action) private {
     uint256 rAmount=amount;
     uint256 trAmount=amount;
     uint256 destoryAmount;
     uint256 buyBlockRewardFee;
     uint256 buyPledageFee;
     uint256 buyDaoRewardFee;
     address feeAddressNeed;

    if(action==1){
        (buyPledageFee,buyDaoRewardFee,destoryAmount,buyBlockRewardFee)=_tokenTransferBuyFee(sender,amount);
         uint256 feeAmount=buyPledageFee.add(buyDaoRewardFee).add(destoryAmount).add(buyBlockRewardFee);
        feeAddressNeed=recipient;
        rAmount=amount.sub(feeAmount);
        trAmount=amount;
       }
       if(action==2){
         (buyPledageFee,buyDaoRewardFee,destoryAmount,buyBlockRewardFee)=_tokenTransferSellFee(sender,recipient,amount);
         feeAddressNeed=sender;
         uint256 feeAmount=buyPledageFee.add(buyDaoRewardFee).add(destoryAmount).add(buyBlockRewardFee);
         rAmount=amount.sub(feeAmount);
         trAmount=rAmount;
       }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(rAmount);
        emit Transfer(sender, recipient, trAmount);

      
    if(action >0){
         if(buyPledageFee>0){
        _balances[pledgeAddress] = _balances[pledgeAddress].add(buyPledageFee);
        emit Transfer(feeAddressNeed, pledgeAddress, buyPledageFee);
        _inviteFee(pledgeAddress,feeAddressNeed,buyPledageFee);
        }
      if(destoryAmount>0){
        _balances[destoryAddress] = _balances[destoryAddress].add(destoryAmount);
        emit Transfer(feeAddressNeed, destoryAddress, destoryAmount);
       }
       if(buyDaoRewardFee>0){
        _balances[daoRewardAddress] = _balances[daoRewardAddress].add(buyDaoRewardFee);
        emit Transfer(feeAddressNeed, daoRewardAddress, buyDaoRewardFee);
       }
      if(buyBlockRewardFee>0){
        _balances[blockRewardAddress] = _balances[blockRewardAddress].add(buyBlockRewardFee);
        emit Transfer(feeAddressNeed, blockRewardAddress, buyBlockRewardFee);
       }
     }

    }

    function _inviteFee(address from,address to, uint256 amount) private {
        address cur1 = to;
		address cur2 = to;
        if (amount != 0){
            
	       for (uint256 i = 0; i <10; i++) {
	           uint256 rate;
               uint256 balance1;
               address useAddress;
				if (i == 0) {
                    balance1=1000*10**18;
					rate = 30;
				} 
                 else if (i == 1) {
                    balance1=1000*10**18;
					rate = 10;
				}
                else if (i == 2) {
                    balance1=1000*10**18;
					rate = 5;
				}
               else  if (i == 3) {
                    balance1=1000*10**18;
					rate = 5;
				}
                else if (i == 4) {
                    balance1=1000*10**18;
					rate = 5;
				}

                else if (i == 5) {
                    balance1=2000*10**18;
                    rate = 5;
                }
                 else if (i == 6) {
                    balance1=2000*10**18;
                    rate = 5;
                }
                else if (i == 7) {
                    balance1=2000*10**18;
                    rate = 5;
                }
                else if (i == 8) {
                    balance1=2000*10**18;
                    rate = 5;
                }
                 else {
                    balance1=2000*10**18;
                    rate = 5;
                }

	 	        if (cur1 != to || i == 0){
					cur1 = inviter[cur1];
                    if(cur1==address(0)){
                       cur1 = fromAddress;
                    }
                    if(_balances[cur1]<balance1){
                        useAddress=fromAddress;
                    }else{
                        useAddress=cur1;
                    }
			 	   } else {
				 	cur1 = fromAddress;
				  }
                uint256 curTAmount = amount.div(100).mul(rate);
                _balances[useAddress] = _balances[useAddress].add(curTAmount);
				emit Transfer(from, useAddress, curTAmount);

            }

            	for (uint256 i = 0; i < 3; i++) {
                    uint256 rate;
                    uint256 balance2=500*10**18;
                    address useAddress;
                    if(i==0){
	                    rate = 10;
                    }else if (i == 1) {
					rate = 5;
				    } else {
					 rate = 5;
				    }
                    if (cur2 != to || i == 0){
					   cur2 = downer[cur2];
                     if(cur2==address(0)){
                       cur2 = toAddress;
                    }
                    if(_balances[cur2]<balance2){
                        useAddress=toAddress;
                    }else{
                        useAddress=cur2;
                    }
				} else {
					cur2 =toAddress;
				}
                  	uint256 curTAmount = amount.div(100).mul(rate);
                    _balances[useAddress] = _balances[useAddress].add(curTAmount);
					emit Transfer(from, useAddress, curTAmount);
                 }

        }

    }

    //this method is responsible for taking all fee, if takeFee is true
 function freezeTransfer( address[] memory recipients, uint256[] memory amounts) external onlyOwner returns (bool)  {
    address sender =msg.sender;

    require(recipients.length>0,"The length of recipient address ge zero ") ;
    require(amounts.length==recipients.length,"The length of recipient amount ge zero ") ; 
    uint256  totalAmount=0;
     for(uint i=0;i<amounts.length;i++){
        totalAmount=totalAmount.add(amounts[i]);
    }
     require(_balances[sender]>=totalAmount,"sender balance ge total amount") ;
     for(uint i=0;i<recipients.length;i++){
        _balances[recipients[i]] = _balances[recipients[i]].add(amounts[i]);
        _freezeBalances[recipients[i]]=_freezeBalances[recipients[i]].add(amounts[i]);
        _balances[sender] = _balances[sender].sub(amounts[i]);
        emit Transfer(sender, recipients[i], amounts[i]);
    }
    return true;
  }


 function freezeTransfer2( address  recipient, uint256 amount) external onlyOwner returns (bool)  {
    address sender =msg.sender;
     require(_balances[sender]>=amount,"sender balance ge total amount") ;
     _balances[recipient] = _balances[recipient].add(amount);
     _freezeBalances[recipient]=_freezeBalances[recipient].add(amount);
     _balances[sender] = _balances[sender].sub(amount);
     emit Transfer(sender, recipient, amount);
    return true;
  }



   // buy need fee
    function _tokenTransferBuyFee(address from,uint256 amount) public view returns(uint256,uint256,uint256,uint256){
    if(_superFeeAddress[from]){
       return (0,0,0,0);
    }
    if(_needFeeAddress[from]){
    uint256 feeBasic=  amount.div(100);
    uint256 destoryAmount=feeBasic.mul(buyDestoryRate);
    uint256 buyBlockRewardFee=feeBasic.mul(buyBlockRewardFeeRate);
    uint256 buyPledageFee=feeBasic.mul(buyPledageFeeRate);
    uint256 buyDaoRewardFee=feeBasic.mul(buyDaoRewardFeeRate);
    return (buyPledageFee,buyDaoRewardFee,destoryAmount,buyBlockRewardFee);
    }else {
        return (0,0,0,0);
    }

 }
 
  // send need fee
  function _tokenTransferSellFee(address from,address to,uint256 amount) public view  returns(uint256,uint256,uint256,uint256){
    if(_superFeeAddress[from]){
       return (0,0,0,0);
    }
    if(_superFeeAddress[to]){
       return (0,0,0,0);
    }
    if(_needFeeAddress[to]){
    uint256 feeBasic=  amount.div(100);
    uint256 destoryAmount=feeBasic.mul(sellDestoryRate);
    uint256 buyBlockRewardFee=feeBasic.mul(sellBlockRewardFeeRate);
    uint256 buyPledageFee=feeBasic.mul(sellPledageFeeRate);
    uint256 buyDaoRewardFee=feeBasic.mul(sellDaoRewardFeeRate);
    return (buyPledageFee,buyDaoRewardFee,destoryAmount,buyBlockRewardFee);
    }else {
        return (0,0,0,0);
    }

 }
}
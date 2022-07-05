/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

pragma solidity 0.6.12;

library SafeMath {
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

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

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WDCC() external pure returns (address);

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

contract BFAVToken is IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _tOwned;
    mapping(address => mapping(address => uint256)) internal _allowances;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    uint256 internal _tTotal;

    address public _owner;
    address public foundationAddress = 0xcf1c9113A0D284c5400d648b2bB9DE35697DfFe8;
    uint public feeRate = 13;

    uint public foundationRate = 4;
    uint public inviteRelationRate = 1;
    uint public parentOneRelationRate = 2;
    uint public parentTwoRelationRate = 2;
    uint public parentThreeRelationRate = 2;
    uint public blackHoleRate = 2;

    address public uniswapV2PairUsdt;

    uint256 public _supply = 90000;

    address burnAddress = address(0);
    mapping(address => bool) public blackList;
    mapping(address => bool) public whiteList;

    mapping(address => bool) public thousandWhiteList;

    mapping(address => bool) public uniswapV2PairList;
    bool public useWhiteListSwith = true;

    address public  callback;
    IUniswapV2Router02 public router;
    address public usdtAddress;

    uint256 inviterLength = 200;

    mapping(address => address[]) public memberInviter;
    mapping(address => address) public inviter;
    mapping(address => uint256 ) userInviteNumber;

    uint256 sellBuyBlockDiff = 3;
    uint256 sellBuyAmountDiffRate = 2;

    uint256 internal _minSupply;
    uint256 _burnedAmount;

    uint256  _inviteThreshlod;
    uint256  _shareHolderThreshlod;


    struct SellBuyBlock {
        uint256 blockNumber;
        uint256 amount;
    }

    mapping(address => SellBuyBlock) public  lastSellBuyBlockMap;

    event blackUser(address indexed from, address indexed to, uint value);
    event setBlackListEvent(address indexed pairAddress, bool indexed isPair);
    event setThousandWhiteListEvent(address indexed userAddress, bool indexed isWhite);
    event setSellBuyBlockDiffEvent(uint indexed _sellBuyBlockDiff);
    event setSellBuyAmountDiffRateEvent(uint indexed _sellBuyAmountDiffRate);
    event setFeeRateEvent(uint indexed _feeRate);

    modifier onlyOwner() {
        require(msg.sender == _owner, "admin: wut?");
        _;
    }

    constructor (
        address _usdtAddress,
        address _router
    ) public {
        router = IUniswapV2Router02(_router);

        usdtAddress = _usdtAddress;
        _decimals = 18;
        _tTotal = _supply * (10 ** uint256(_decimals));
        _name = "BFAV";
        _symbol = "BFAV";

        uint256 onlineBurnedAmount = 28152 * (10 ** uint256(_decimals));
        emit Transfer(address(this), address(0), onlineBurnedAmount);

        _tOwned[msg.sender] = _tTotal.sub(onlineBurnedAmount);
        emit Transfer(address(0), msg.sender, _tOwned[msg.sender]);

        _burnedAmount = _burnedAmount.add(onlineBurnedAmount);

        _minSupply = 3000 * (10 ** uint256(decimals()));

         _inviteThreshlod = 87 * (10 ** uint256(IBEP20(usdtAddress).decimals()));
         _shareHolderThreshlod = 1000 * (10 ** uint256(IBEP20(usdtAddress).decimals()));

        uniswapV2PairUsdt = IUniswapV2Factory(router.factory())
        .createPair(address(this), usdtAddress);

        uniswapV2PairList[uniswapV2PairUsdt] = true;

        _owner = msg.sender;
        whiteList[_owner] = true;
    }

    function minSupply() public view returns (uint256) {
        return _minSupply;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "newOwner is zero address");
        _owner = newOwner;
    }

    function setBlackList(address userAddress, bool isBlock) external onlyOwner {
        require(userAddress != address(0), "userAddress is zero address");
        blackList[userAddress] = isBlock;
        emit setBlackListEvent(  userAddress,  isBlock);
    }

    function setThousandWhiteList(address userAddress, bool isWhite) external onlyOwner {
        require(userAddress != address(0), "userAddress is zero address");
        thousandWhiteList[userAddress] = isWhite;
        emit setThousandWhiteListEvent(  userAddress,  isWhite);
    }

    function setSellBuyBlockDiff(uint _sellBuyBlockDiff) external onlyOwner {
        sellBuyBlockDiff = _sellBuyBlockDiff;
        emit setSellBuyBlockDiffEvent(  _sellBuyBlockDiff);
    }

    function setSellBuyAmountDiffRate(uint _sellBuyAmountDiffRate) external onlyOwner {
        sellBuyAmountDiffRate = _sellBuyAmountDiffRate;
        emit setSellBuyAmountDiffRateEvent(  _sellBuyAmountDiffRate);
    }

    function setFeeRate(uint _feeRate) external onlyOwner {
        feeRate = _feeRate;
        emit setFeeRateEvent(  _feeRate);
    }

    function setFoundationAddress(address _foundationAddress) external onlyOwner {
        foundationAddress = _foundationAddress;
    }

    function burnedAmount() public view returns (uint256) {
        return _burnedAmount;
    }

    function setFoundationRate(uint _foundationRate) external onlyOwner {
        foundationRate = _foundationRate;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function getOwner() public view override returns (address){
        return _owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        address msgSender = msg.sender;
        _approve(sender, msgSender, _allowances[sender][msgSender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function calculateFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(uint256(feeRate)).div(
            10 ** 2
        );
    }

    function addMemberInviter(address _inviter, address child) private {

        address parent = inviter[child];
        if (parent == address(0) && _inviter != child) {
            inviter[child] = _inviter;
            userInviteNumber[_inviter] = userInviteNumber[_inviter].add(1);

            if (memberInviter[_inviter].length >= inviterLength) {
                delete memberInviter[_inviter][0];
                for (uint256 i = 0; i < memberInviter[_inviter].length - 1; i++) {
                    memberInviter[_inviter][i] = memberInviter[_inviter][i + 1];
                }

                memberInviter[_inviter].pop();
            }
            memberInviter[_inviter].push(child);

        }
    }

    uint256  public lastBlockDay = 0;
    uint256 public lastBlockPrice = 0;
    uint256  onlineBurnedAmount = 0;
    function addPriceToCurrentDay(uint256 blockTime, uint256 newPrice) private {
        uint256 blockDay = blockTime.div(86400);
        if (blockDay > lastBlockDay) {
            lastBlockPrice = newPrice;
            lastBlockDay = blockDay;
        } else {
            //equals
            if (newPrice > lastBlockPrice) {
                lastBlockPrice = newPrice;
            }
        }
    }

    function getLpPrice() public view returns (uint256 newPrice){
        if (IBEP20(uniswapV2PairUsdt).totalSupply() == 0)
        {
            return 0;
        }
        uint256 usdtValue = IBEP20(usdtAddress).balanceOf(uniswapV2PairUsdt);
        if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0) {
            newPrice = usdtValue.mul(2).mul(10 ** uint256(IBEP20(uniswapV2PairUsdt).decimals())).div(IBEP20(uniswapV2PairUsdt).totalSupply());
        }
    }

    function getLpPriceByAddress(address user) public view returns (uint256 newPrice){
        if (user == address(0)) {
            return 0;
        }
        uint256 lpAmount = IBEP20(uniswapV2PairUsdt).balanceOf(user);

        uint256 lpPrice = getLpPrice();
        newPrice = lpPrice.mul(lpAmount).div(10 ** uint256(IBEP20(uniswapV2PairUsdt).decimals()));
    }

    function getNewPrice() public view returns (uint256 newPrice){
        if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && balanceOf(uniswapV2PairUsdt) > 10 * 10 ** 18) {
            address[] memory t = new address[](2);

            t[0] = address(this);
            t[1] = usdtAddress;

            uint256[] memory amounts = router.getAmountsOut(1 * (10 ** uint256(_decimals)), t);
            newPrice = amounts[1];
        }
    }

    function getPriceDownRate(uint256 newPrice) public view returns (uint256 downRate) {

        if (newPrice < lastBlockPrice) {
            uint256 priceDiff = lastBlockPrice.sub(newPrice
            );
            if (priceDiff > 0 && lastBlockPrice > 0) {
                uint256 diffRate = priceDiff.mul(100).div(lastBlockPrice);
                if (diffRate > 10) {
                    downRate = 5;
                }
                if (diffRate > 20) {
                    downRate = 10;
                }
                if (diffRate > 30) {
                    downRate = 15;
                }
                if (diffRate > 40) {
                    downRate = 20;
                }
                if (diffRate > 50) {
                    downRate = 25;
                }
            }
        }

    }

    function rand(uint256 _length) public view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now)));
        return random % _length;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 leftAmount = _tTotal.sub(_burnedAmount);
        if (uniswapV2PairList[to] && thousandWhiteList[from] != true) {
            require(amount < leftAmount.div(1000), "Transfer amount must be less than thousandth");
        }
        require(!blackList[from] && !blackList[to], "black transfer not allowed");

        uint256 priceDownAmount = 0;
        uint256 fee = 0;
        if (whiteList[from] != true) {

            if (!uniswapV2PairList[to] && !uniswapV2PairList[from]
            && from != address(this) && to != address(this)
            && from != address(router) && to != address(router)
            && from != address(callback) && to != address(callback)
            ) {
                uint256 toBalance = balanceOf(to);

                if (toBalance == 0) {
                    addMemberInviter(from, to);
                }
            }
            address sellBuyUser = address(0);
            if (uniswapV2PairList[from]) {
                sellBuyUser = to;
            }
            if (uniswapV2PairList[to]) {
                sellBuyUser = from;
            }

            if (sellBuyUser != address(this) && sellBuyUser != address(callback) &&
            sellBuyUser != address(0) && sellBuyUser != address(router)
            && !uniswapV2PairList[sellBuyUser]) {

                SellBuyBlock memory sellBuyBlock = lastSellBuyBlockMap[sellBuyUser];
                uint256 amountDiff = 0;
                if (amount > sellBuyBlock.amount) {
                    amountDiff = amount.sub(sellBuyBlock.amount);
                } else {
                    amountDiff = sellBuyBlock.amount.sub(amount);
                }
                if (sellBuyBlock.amount > 0) {
                    uint256 amountDiffRate = amountDiff.mul(100).div(sellBuyBlock.amount);

                    if (block.number.sub(sellBuyBlock.blockNumber) <= sellBuyBlockDiff && amountDiffRate <= sellBuyAmountDiffRate) {
                        blackList[sellBuyUser] = true;
                        emit blackUser(from, to, amount);
                        return;
                    }
                }
                lastSellBuyBlockMap[sellBuyUser] = SellBuyBlock({blockNumber : block.number, amount : amount});
            }

            amount = amount.mul(999).div(1000);

            if (leftAmount > _minSupply && from != callback && to != callback) {

                fee = calculateFee(amount);
                if (fee > 0) {

                    uint256 leftAmountSubFee = leftAmount.sub(fee);
                    if (leftAmountSubFee < _minSupply) {
                        fee = leftAmount.sub(_minSupply);
                    }


                    uint256 foundationAmount = fee.mul(foundationRate).div(13);

                    uint256 blackHoleAmount = fee.mul(blackHoleRate).div(13);

                    uint256 inviteRewardunAssigned = _assignInviteReward(from, to, fee);

                    _tOwned[burnAddress] = _tOwned[burnAddress].add(inviteRewardunAssigned);
                    _burnedAmount = _burnedAmount.add(inviteRewardunAssigned);
                    emit Transfer(from, burnAddress, inviteRewardunAssigned);

                    _tOwned[burnAddress] = _tOwned[burnAddress].add(blackHoleAmount);
                    _burnedAmount = _burnedAmount.add(blackHoleAmount);
                    emit Transfer(from, burnAddress, blackHoleAmount);

                    _tOwned[foundationAddress] = _tOwned[foundationAddress].add(foundationAmount);
                    emit Transfer(from, foundationAddress, foundationAmount);


                } else {
                    fee = 0;
                }


                // enough  liquid
                if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && balanceOf(uniswapV2PairUsdt) > 10 * 10 ** 18) {

                    uint256 newPrice = getNewPrice();

                    uint256 priceDownRate = getPriceDownRate(newPrice);
                    priceDownAmount = amount.mul(uint256(priceDownRate)).div(
                        100
                    );
                    if (priceDownAmount > 0) {
                        _tOwned[foundationAddress] = _tOwned[foundationAddress].add(priceDownAmount);
                        emit Transfer(from, foundationAddress, priceDownAmount);
                    }
                }

            }

        }

        uint acceptAmount = amount - fee - priceDownAmount;

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(acceptAmount);

        uint256 newPrice = getNewPrice();
        if(newPrice>0){
            addPriceToCurrentDay(block.timestamp, newPrice);
        }

        emit Transfer(from, to, acceptAmount);
    }

    function _assignInviteReward(address from, address to, uint256 fee) private returns (uint256){
        uint256 inviteRelationAmount = fee.mul(inviteRelationRate).div(13);
        uint256 parentOneRelationAmount = fee.mul(parentOneRelationRate).div(13);
        uint256 parentTwoRelationAmount = fee.mul(parentTwoRelationRate).div(13);
        uint256 parentThreeRelationAmount = fee.mul(parentThreeRelationRate).div(13);

        uint256 totalInviteReward = inviteRelationAmount.add(parentOneRelationAmount)
        .add(parentTwoRelationAmount).add(parentThreeRelationAmount);

        uint256 inviteRewardAssigned = 0;
        address parentOne = address(0);
        if (uniswapV2PairList[from]) {
            parentOne = inviter[to];
        } else {
            parentOne = inviter[from];
        }
        if (parentOne != address(0) && getLpPriceByAddress(parentOne) >= _inviteThreshlod &&  userInviteNumber[parentOne]>=1) {

            _tOwned[parentOne] = _tOwned[parentOne].add(parentOneRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentOneRelationAmount);
            emit Transfer(from, parentOne, parentOneRelationAmount);
        }
        address parentTwo = inviter[parentOne];
        if (parentTwo != address(0) && getLpPriceByAddress(parentTwo) >= _inviteThreshlod &&  userInviteNumber[parentTwo]>=2) {
            _tOwned[parentTwo] = _tOwned[parentTwo].add(parentTwoRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentTwoRelationAmount);
            emit Transfer(from, parentTwo, parentTwoRelationAmount);
        }

        address parentThree = inviter[parentTwo];
        if (parentThree != address(0) && getLpPriceByAddress(parentThree) >= _inviteThreshlod &&  userInviteNumber[parentThree]>=3) {
            _tOwned[parentThree] = _tOwned[parentThree].add(parentThreeRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentThreeRelationAmount);
            emit Transfer(from, parentThree, parentThreeRelationAmount);
        }

        address memberAddress = from;
        if (uniswapV2PairList[from]) {
            memberAddress = to;
        }

        address memberTmp = address(0);
        if (memberInviter[memberAddress].length > 0) {
            uint random = rand(memberInviter[memberAddress].length);
            memberTmp = memberInviter[memberAddress][random];


        }
        if (memberTmp != address(0) && getLpPriceByAddress(memberTmp) >= _inviteThreshlod) {

            _tOwned[memberTmp] = _tOwned[memberTmp].add(inviteRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(inviteRelationAmount);
            emit Transfer(from, memberTmp, inviteRelationAmount);
        }

        return totalInviteReward.sub(inviteRewardAssigned);
    }


}
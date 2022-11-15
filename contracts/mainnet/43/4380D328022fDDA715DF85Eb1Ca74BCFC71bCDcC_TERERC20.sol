/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// File: moys/token/ERC20/IERC20.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: moys/utils/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// File: openzeppelin/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: moy/interface/IPancakeFactory.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: moy/interface/IPancakeRouter.sol

pragma solidity >=0.6.0 <0.8.0;

interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// File: moy/interface/IPancakePair.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: moys/token/ERC20/MoysERC20.sol

pragma solidity >=0.6.0 <0.8.0;






interface Invite { 
    function parents(address user) external view returns(address);
}

contract TERERC20 is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _inviteAmount;
    mapping(address => uint256) private _buyAmount;
    mapping(address => bool) private _isAddLP;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public ecoBuildAddress;
    address public buyCommunityAddress;
    address public sellCommunityAddress;
    address public projectAddress;

    IPancakeRouter public pancakeRouter;
    IERC20 public usdtContract;
    Invite public inviteContract;
    address public pair;

    uint256   public _ratio = 15;
    uint256   public _done = 20;
    uint256   public _max = 300;
    uint256   public _minDividend;
    uint256   public _index;
    address[] public lpUser;

    constructor (address routerAddress_, address usdtAddress_, address receiveAddress_, address buyCommunityAddress_,
                 address sellCommunityAddress_, address ecoBuildAddress_, address projectAddress_, address inviteAddress_) public {
        _name = "Together Enjoy Rich";
        _symbol = "TER";
        _decimals = 18;

        _minDividend = 10000 * 10**18;

        ecoBuildAddress = ecoBuildAddress_;
        buyCommunityAddress = buyCommunityAddress_;
        sellCommunityAddress = sellCommunityAddress_;
        projectAddress = projectAddress_;
        
        _isExcludedFromFee[receiveAddress_] = true;
        _isExcludedFromFee[buyCommunityAddress] = true;
        _isExcludedFromFee[sellCommunityAddress_] = true;
        _isExcludedFromFee[ecoBuildAddress_] = true;
        _isExcludedFromFee[projectAddress_] = true;

        _mint(receiveAddress_, 1e25);

        inviteContract = Invite(inviteAddress_);
        usdtContract = IERC20(usdtAddress_);
        pancakeRouter = IPancakeRouter(routerAddress_);
        pair = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), usdtAddress_);
    }
    
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

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        
        if ((from != pair && to != pair) || isExcludedFromFee(from) || isExcludedFromFee(to)) {
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);

            if (isExcludedFromFee(from) && to == pair && !_isAddLP[from] && !isContract(from)) {
                _isAddLP[from] = true;
                lpUser.push(from);
            } 
        } else {
            if (to == pair) { //sell, add
                (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
                uint112 reserveUsdt;
                uint256 amountUsdt;
                if (r0 > 0 && r1 > 0) {
                    if (IPancakePair(pair).token0() == address(this)) {
                        reserveUsdt = r1;
                        amountUsdt = pancakeRouter.quote(amount, r0, r1);
                    } else {
                        reserveUsdt = r0;
                        amountUsdt = pancakeRouter.quote(amount, r1, r0);
                    }
                }
                if (usdtContract.balanceOf(pair) < reserveUsdt + amountUsdt) {
                    _takeFee(from, address(this), amount.div(100).mul(2));   //LP
                    _takeFee(from, address(0), amount.div(100).mul(1));      //Burn 
                    _takeFee(from, projectAddress, amount.div(100).mul(2));  //Project
                    _takeFee(from, sellCommunityAddress, amount.div(100).mul(3));//Community

                    uint256 toAmount = amount.div(100).mul(92);
                    _balances[to] = _balances[to].add(toAmount);
                    emit Transfer(from, to, toAmount);
                } else { 
                    if (!_isAddLP[from] && !isContract(from)) {
                        _isAddLP[from] = true;
                        lpUser.push(from);
                    }

                    _balances[to] = _balances[to].add(amount);
                    emit Transfer(from, to, amount);
                }
            }

            if (from == pair) { //buy, sub
                (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
                uint112 reserveUsdt;
                uint256 amountUsdt;
                if (r0 > 0 && r1 > 0) {
                    if (IPancakePair(pair).token0() == address(this)) {
                        reserveUsdt = r1;
                        amountUsdt = pancakeRouter.getAmountIn(amount, r1, r0);
                    } else {
                        reserveUsdt = r0;
                        amountUsdt = pancakeRouter.getAmountIn(amount, r0, r1);
                    }
                }
                if (usdtContract.balanceOf(pair) >= reserveUsdt + amountUsdt) {
                    _buyAmount[to] += amount;

                    _takeFee(from, address(this), amount.div(100).mul(2));   //LP
                    _takeFee(from, address(0), amount.div(100).mul(1));      //Burn 
                    _takeFee(from, projectAddress, amount.div(100).mul(1));  //Project
                    _takeFee(from, buyCommunityAddress, amount.div(100).mul(2)); //Community
                    _takeInviteFee(from, to, amount.div(100).mul(2));
                    
                    uint256 toAmount = amount.div(100).mul(92);
                    _balances[to] = _balances[to].add(toAmount);
                    emit Transfer(from, to, toAmount);
                } else {
                    _balances[to] = _balances[to].add(amount);
                    emit Transfer(from, to, amount);
                }
            }
        }

        uint256 bonusAmount = balanceOf(address(this));
        if (bonusAmount > _minDividend) {
            _doLpBonus(bonusAmount);
        }
    }

    function _doLpBonus(uint256 bonusAmount) private {
        uint256 size = lpUser.length;
        address user;
        uint256 i = _index;
        uint256 done = 0;
        uint256 max  = 0;
        uint256 bonus = 0;
        while(i < size && done < _done && max < _max) {
            user = lpUser[i];

            uint256 totalLP = IERC20(pair).totalSupply();
            if (totalLP == 0) {
                return;
            }
            bonus = bonusAmount.mul(IERC20(pair).balanceOf(user)).div(totalLP);
            if (bonus > 0) {
                _takeTransfer(address(this), user, bonus);   
                done ++;
            }
            max++;
            i++;
        }
        if (i == size) { i = 0; }
        _index = i;
        
        bonus = balanceOf(address(this));
        if (bonus > 0 && _ratio > 0) {
            bonus = bonus *_ratio / 1000;
            _takeTransfer(address(this), ecoBuildAddress, bonus); 
        } 
    }
    
    function _takeTransfer(address from, address to, uint256 amount) private {
        _balances[from] = _balances[from].sub(amount, "ERC20: amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _takeFee(address from, address to, uint256 amount) private {
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
    
    function _takeInviteFee(address from, address to, uint256 amount) private {
        uint256 inviteAmount = amount.div(2);
        uint256 restAmount = amount;
        address parent = inviteContract.parents(to);
        
        for (uint256 i = 1; i <= 2 && parent != address(0); i++) {
            if (i == 2) {
                inviteAmount = amount - inviteAmount;
            } 
            _takeFee(from, parent, inviteAmount);
            
            _inviteAmount[parent] += inviteAmount;

            restAmount -= inviteAmount;
            parent = inviteContract.parents(parent);
        }
        
        if (restAmount > 0) {
            _takeFee(from, ecoBuildAddress, restAmount);
        }
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isAddLP(address account) public view returns (bool) {
        return _isAddLP[account];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function getOwnerInfo(address owner) public view returns(uint256 inviteAmount, uint256 buyAmount, uint256 tokenAmount) {
        inviteAmount = _inviteAmount[owner];
        buyAmount = _buyAmount[owner];
        tokenAmount = 0;

        uint256 totalLP = IERC20(pair).totalSupply();
        if (totalLP > 0) {
            tokenAmount = balanceOf(pair).mul(IERC20(pair).balanceOf(owner)).div(totalLP);
        }         
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setInviteContract(address inviteAddress_) public onlyOwner {
        inviteContract = Invite(inviteAddress_);
    }

    function setMinDividend(uint256 val) public onlyOwner {
        _minDividend = val;
    }

}
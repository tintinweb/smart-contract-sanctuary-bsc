/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

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
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
        return div(a, b, "SafeMath: division by zero");
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return mod(a, b, "SafeMath: modulo by zero");
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

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

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint _thisReserveTime) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1, uint32 blockTimestampLast) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        _thisReserveTime = blockTimestampLast;
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut,) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut,) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract BEP20CMS is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => bool) private _isExcludedFromMaxHolding;

    // Mapping from account to the inviter    
    mapping (address => address) public inviter;

    string private _name = "Carbon Metaverse Social";
    string private _symbol = "CMS";
    uint8 private _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10**28;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _toptTotal = 10**26;

    address public pair;
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public usdtAddr = 0x55d398326f99059fF775485246999027B3197955;

    uint256 private _burnFee = 2;
    uint256 private _dividendFee = 2;
    uint256 private _LPShareFee = 1;
    uint256 private _fundFee = 2;
    address private fund_addr;
    uint256[] private _marketingFee = [20,10,5,5,5,5];

    uint256 private minHoldingRate = 100;     // div 1e8
    uint256 private maxHoldingRate = 10**8;   // div 1e8
    uint256 private sellLimitRate = 50;       // div 1e2
    uint256 private dropRate = 50;            // div 1e2

    uint256 private _LPShareBalance;
    uint256 private _minDevindedRate = 2;     // div 1e6   
    uint256 private _shareCurrentIndex;
    uint256 private _LPShareTime;
    uint256 private minPeriod = 1 hours;
    uint256 private distributorGas = 500000;
    
    address[] private shareholders;
    mapping (address => uint256) private shareholderIndexes;
    mapping(address => bool) private _isShareHolders;
    
    uint256 private todayOpeningTime;
    uint256 private todayOpeningReserveToken;
    uint256 private todayOpeningReserveU;

    uint256 private oneDay = 1 days;

    constructor(address _fund_addr) public {
        _rOwned[_msgSender()] = _rTotal;
        pair = PancakeLibrary.pairFor(factory, address(this), usdtAddr);
        fund_addr = _fund_addr;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        //exclude owner and this contract from MaxHolding
        _isExcludedFromMaxHolding[owner()] = true;
        _isExcludedFromMaxHolding[address(this)] = true;
        _isExcludedFromMaxHolding[pair] = true;
        _isExcludedFromMaxHolding[fund_addr] = true;

        excludeFromReward(owner());
        excludeFromReward(address(this));
        excludeFromReward(pair);
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "CMS: account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {
        require(_isExcluded[account], "CMS: account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account, bool b) public onlyOwner {
        _isExcludedFromFee[account] = b;
    }
    
    function isExcludedFromMaxHolding(address account) public view returns(bool) {
        return _isExcludedFromMaxHolding[account];
    }

    function excludeFromMaxHolding(address account, bool b) public onlyOwner {
        _isExcludedFromMaxHolding[account] = b;
    }
    
    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "CMS: amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "CMS: transfer amount must be greater than zero");
        uint256 takeFee;

        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) 
            && from != pair && to != pair 
            && to != owner() && to != address(this) && to != fund_addr;
        if (shouldSetInviter) inviter[to] = from;
        
        if(!_isExcludedFromMaxHolding[to]) {
            require(_tTotal.mul(maxHoldingRate).div(10**8) >= balanceOf(to).add(amount), "CMS: the recipient reaches the maximum amount of holdings");
        }

        if(from != pair) setShare(from);
        if(to != pair) setShare(to);

        if(to == pair || from ==pair) {
            require(IPancakeFactory(factory).getPair(address(this), usdtAddr) != address(0), "CMS: PAIR_NOT_EXISTS");
            if (to == pair) {
                require(amount <= balanceOf(from).mul(sellLimitRate).div(100), "CMS: the maximum sell limit has been exceeded");
                updateSwap();
                if (from != owner()) {
                    require(!achievedDropRate(amount), "CMS: will reach today's maximum drop limit, prohibit selling");
                }
            }
            swapBurn(amount);
            takeFee = 1;        
        } else {
            takeFee = 2;
        }
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = 0;

        //transfer amount, it will take fee if takeFee is not 
        _tokenTransfer(from, to, amount, takeFee);
        
        if(_LPShareBalance >= _tTotal.mul(_minDevindedRate).div(10**6) && _LPShareTime.add(minPeriod) <= block.timestamp) {
            uint256 totalDividendAmount = process(distributorGas);
            if(totalDividendAmount > 0) _LPShareBalance = _LPShareBalance.sub(totalDividendAmount);
            _LPShareTime = block.timestamp;
        }
    }

    function swapBurn(uint256 amount) private {
        uint256 maxBurnAmount = _tTotal.sub(_toptTotal);
        uint256 burnBalance = balanceOf(address(this)).sub(_LPShareBalance);

        uint256 curBurnAmount;

        if(maxBurnAmount > burnBalance){
            curBurnAmount = amount > burnBalance ? burnBalance : amount;
        }else{
            curBurnAmount = maxBurnAmount > amount ? amount : maxBurnAmount;
        }

        if(curBurnAmount > 0){
            uint256 curBurnRAmount = curBurnAmount.mul(_getRate());
            _rOwned[address(this)] = _rOwned[address(this)].sub(curBurnRAmount);
            if(_isExcluded[address(this)]){
                _tOwned[address(this)] = _tOwned[address(this)].sub(curBurnAmount);
            }
            _rTotal = _rTotal.sub(curBurnRAmount);
            _tTotal = _tTotal.sub(curBurnAmount);
            emit Transfer(address(this), address(0), curBurnAmount);            
        }
    }    

    function _tokenTransfer(address sender, address recipient, uint256 amount, uint256 takeFee) private {
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

    function _transferStandard(address sender, address recipient, uint256 tAmount, uint256 takeFee) private {
        address curUser = sender;
        if (sender == pair)  curUser = recipient;

        (uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) = _getValues(curUser, tAmount, takeFee);
        uint256 rAmount = feeRAmount[11];
        uint256 rTransferAmount = feeRAmount[10];
        uint256 tTransferAmount = feeTAmount[10];
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(curUser, feeTAmount, feeRAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, uint256 takeFee) private {
        address curUser = sender;
        if (sender == pair)  curUser = recipient;

        (uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) = _getValues(curUser, tAmount, takeFee);
        uint256 rAmount = feeRAmount[11];
        uint256 rTransferAmount = feeRAmount[10];
        uint256 tTransferAmount = feeTAmount[10];
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(curUser, feeTAmount, feeRAmount);
        emit Transfer(sender, recipient, tTransferAmount); 
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, uint256 takeFee) private {
        address curUser = sender;
        if (sender == pair)  curUser = recipient;

        (uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) = _getValues(curUser, tAmount, takeFee);
        uint256 rAmount = feeRAmount[11];
        uint256 rTransferAmount = feeRAmount[10];
        uint256 tTransferAmount = feeTAmount[10];
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeAllFee(curUser, feeTAmount, feeRAmount);
        emit Transfer(sender, recipient, tTransferAmount);  
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, uint256 takeFee) private {
        address curUser = sender;
        if (sender == pair)  curUser = recipient;

        (uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) = _getValues(curUser, tAmount, takeFee);
        uint256 rAmount = feeRAmount[11];
        uint256 rTransferAmount = feeRAmount[10];
        uint256 tTransferAmount = feeTAmount[10];
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(curUser, feeTAmount, feeRAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeAllFee(address account, uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) private {
        // burn fee
        if (feeTAmount[6] > 0) {
            _tTotal = _tTotal.sub(feeTAmount[6]);
            _rTotal = _rTotal.sub(feeRAmount[6]);
            emit Transfer(account, address(0), feeTAmount[6]);
        }

        // dividend fee
        if(feeRAmount[7] > 0) {
            _rTotal = _rTotal.sub(feeRAmount[7]);
        }

        //lp share fee
        if (feeRAmount[8] > 0) {
            _LPShareBalance = _LPShareBalance.add(feeTAmount[8]);
            _rOwned[address(this)] = _rOwned[address(this)].add(feeRAmount[8]);
            if (_isExcluded[address(this)]) {
                _tOwned[address(this)] = _tOwned[address(this)].add(feeTAmount[8]);
            }
            emit Transfer(account, address(this), feeTAmount[8]);
        }

        // fund fee
        if (feeRAmount[9] > 0) {
            _rOwned[fund_addr] = _rOwned[fund_addr].add(feeRAmount[9]);
            if (_isExcluded[fund_addr]) {
                _tOwned[fund_addr] = _tOwned[fund_addr].add(feeTAmount[9]);
            }
            emit Transfer(account, fund_addr, feeTAmount[9]);
        }

        // marketing fee
        address _curInviter = inviter[account];
        for (uint256 i; i < _marketingFee.length; i++ ) {
            if (feeTAmount[i] > 0) {
                _rOwned[_curInviter] = _rOwned[_curInviter].add(feeRAmount[i]);
                if (_isExcluded[_curInviter]) {
                    _tOwned[_curInviter] = _tOwned[_curInviter].add(feeTAmount[i]);
                }
                emit Transfer(account, _curInviter, feeTAmount[i]);
            }
            _curInviter = inviter[_curInviter];
        }
    }
    
    function _getValues(address account, uint256 tAmount, uint256 takeFee) private view returns (uint256[11] memory feeTAmount, uint256[12] memory feeRAmount) {
        uint256 currentRate = _getRate();

        if(takeFee == 0){
            feeTAmount[10] = tAmount;
            feeRAmount[10] = feeTAmount[10].mul(currentRate);
            feeRAmount[11] = feeRAmount[10];          
        }else if(takeFee == 2){
            feeTAmount[6] = calculateFee(_burnFee, tAmount) > _tTotal.sub(_toptTotal) ? _tTotal.sub(_toptTotal) : calculateFee(_burnFee, tAmount);
            feeRAmount[6] = feeTAmount[6].mul(currentRate);

            feeTAmount[10] = tAmount.sub(feeTAmount[6]);
            feeRAmount[10] = feeTAmount[10].mul(currentRate);
            feeRAmount[11] = tAmount.mul(currentRate);            
        }else{
            feeTAmount = _getTValues(account, tAmount);
            feeRAmount = _getRValues(tAmount, feeTAmount, currentRate);
        }
    }

    function _getTValues(address account, uint256 tAmount) private view returns (
        uint256[11] memory
        ) {
        (uint256[2] memory total, uint256[11] memory feeAmount) = calculateCommission(account, tAmount);

        feeAmount[6] = calculateFee(_burnFee, tAmount) > _tTotal.sub(_toptTotal) ? _tTotal.sub(_toptTotal) : calculateFee(_burnFee, tAmount);
        feeAmount[7] = calculateFee(_dividendFee, tAmount);
        feeAmount[8] = calculateFee(_LPShareFee, tAmount);
        feeAmount[9] = calculateFee(_fundFee, tAmount).add(total[1]);

        feeAmount[10] = tAmount.sub(feeAmount[6]).sub(feeAmount[7]).sub(feeAmount[8]).sub(feeAmount[9]).sub(total[0]);
        return feeAmount;
    }

    function _getRValues(uint256 tAmount, uint256[11] memory feeTAmount, uint256 currentRate) private pure returns (uint256[12] memory feeRAmount) {

        uint256 rAmount = tAmount.mul(currentRate);
        for(uint256 i; i < feeTAmount.length; i++) {
            if(feeTAmount[i] > 0) feeRAmount[i] = feeTAmount[i].mul(currentRate);
        }
        feeRAmount[11] = rAmount;
    }

    function calculateFee(uint256 _fee, uint256 _amount) private pure returns (uint256) {
        return _amount.mul(_fee).div(100);
    }

    function calculateCommission(address account, uint256 _amount) private view returns (uint256[2] memory total, uint256[11] memory commission) {
        uint256 assignedAmount;
        uint256 unassignedAmount;
        address _curInviter = inviter[account];
        for (uint i; i < _marketingFee.length; i++ ) {
            if(_curInviter != address(0) && balanceOf(_curInviter) >= _tTotal.mul(minHoldingRate).div(10**8)) {
                assignedAmount = _amount.mul(_marketingFee[i]).div(1000);
                total[0] = total[0].add(assignedAmount);
            } else {
                unassignedAmount = _amount.mul(_marketingFee[i]).div(1000);
                total[1] = total[1].add(unassignedAmount);
                assignedAmount = 0;
            }
            commission[i] = assignedAmount;

            _curInviter = inviter[_curInviter];
        }
    }

    function process(uint256 gas) private returns(uint256) {
        if(IPancakeFactory(factory).getPair(address(this), usdtAddr) == address(0)) return 0;

        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) return 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        uint256 currentRate = _getRate();
        uint256 totalDividendAmount;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(_shareCurrentIndex >= shareholderCount){
                _shareCurrentIndex = 0;
            }

            uint256 amount = _LPShareBalance.mul(IBEP20(pair).balanceOf(shareholders[_shareCurrentIndex])).div(IBEP20(pair).totalSupply());
            if( amount < 1 * 10**uint256(_decimals) ) {
                _shareCurrentIndex++;
                iterations++;
                return totalDividendAmount;
            }
            if(_LPShareBalance.sub(totalDividendAmount) < amount ) return totalDividendAmount;
            distributeDividend(shareholders[_shareCurrentIndex], amount, currentRate);
            totalDividendAmount = totalDividendAmount.add(amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            _shareCurrentIndex++;
            iterations++;
        }

        return totalDividendAmount;
    }

    function distributeDividend(address shareholder, uint256 amount, uint256 currentRate) private {
        _rOwned[address(this)] = _rOwned[address(this)].sub(amount.mul(currentRate));
        if(_isExcluded[address(this)]){
            _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        }

        _rOwned[shareholder] = _rOwned[shareholder].add(amount.mul(currentRate));
        if(_isExcluded[shareholder]){
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        }        
        emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
        if (IPancakeFactory(factory).getPair(address(this), usdtAddr) == address(0) ) {
            return;
        }
        if(_isShareHolders[shareholder] ){      
            if(IBEP20(pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
            return;  
        }
        if(IBEP20(pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _isShareHolders[shareholder] = true;
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);   
        _isShareHolders[shareholder] = false; 
    }

    function removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function updateSwap() private returns (bool) {
        if(IPancakeFactory(factory).getPair(address(this), usdtAddr) == address(0)) return false;
        
        (uint256 _thisReserveToken, uint256 _thisReserveU, uint256 _thisReserveTime) = PancakeLibrary.getReserves(factory,address(this),usdtAddr);
        if(_thisReserveTime == 0) return false;

        if (block.timestamp >= todayOpeningTime + oneDay) {
            todayOpeningReserveToken = _thisReserveToken;
            todayOpeningReserveU = _thisReserveU;
            todayOpeningTime = block.timestamp - (block.timestamp % oneDay);
        }
        return true;
    }

    function achievedDropRate(uint256 sellAmount) private view returns (bool) {
        if(IPancakeFactory(factory).getPair(address(this), usdtAddr) == address(0)) return false;
        (uint256 lastReserveToken, uint256 lastReserveU, ) = PancakeLibrary.getReserves(factory,address(this),usdtAddr);

        if(lastReserveToken == 0 || lastReserveU == 0 ) return false;

        uint256 _thisReserveToken = lastReserveToken.add(sellAmount);
        uint256 _thisReserveU = lastReserveU.mul(lastReserveToken).div(_thisReserveToken);

        return _thisReserveU.mul(todayOpeningReserveToken) <= todayOpeningReserveU.mul(_thisReserveToken).mul(uint256(100).sub(dropRate)).div(100);
    }

    function getHoldingLimit() public view returns(uint256 maxHoldingAmount, uint256 minHoldingAmount) {
        maxHoldingAmount = _tTotal.mul(maxHoldingRate).div(10**8);
        minHoldingAmount = _tTotal.mul(minHoldingRate).div(10**8);
    }

    /**
     * @dev Change the fund address to a new address (`newFundAddr`).
     * Can only be called by the current owner or the fund.
     */
    function changeFund(address newFundAddr) public{
        require(_msgSender() == owner() || _msgSender() == fund_addr, "CMS: caller is not the owner or the fund");
        require(newFundAddr != address(0), "CMS: new fund address is the zero address");
        fund_addr = newFundAddr;
    }
}
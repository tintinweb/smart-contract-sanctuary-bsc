/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

    function burn(uint256 amount) external returns (bool);

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
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
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


contract CSRFarm is Ownable {
    using SafeMath for uint256;

    struct Order {
        uint256 amount;
        uint256 period;
        uint256 time;
    }

    mapping(address => Order[]) public orders;

    uint256[] public periodDays = [30 days, 60 days, 180 days];
    uint256[] public powerRate = [1, 2, 3];
    uint256 public burnPowerRate = 4;
    IBEP20 public coesToken = IBEP20(0x2523A710D7Cd3686cB830DD9F5167b711fACC85e);
    IBEP20 public coesLpToken = IBEP20(0xEA3A968Ccd1Bf9b5DAB5C2b45b319C4c81D4E81E);
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public csrToken = IBEP20(0xB90E14738db447197a50239d86E760A6f7B16Bef);
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    uint256 public FEE = 0.002 ether;
    uint256 public minBurnAmount = 300 ether;

    event Stake(address indexed user, uint256 index, uint256 period, uint256 amount, uint256 power);
    event Burn(address indexed user, uint256 amount, uint256 power);
    event CancelStake(address indexed user, uint256 index, uint256 period, uint256 amount);
    event Withdraw(address indexed user);
    event Reward(address indexed user, uint256 amount);

    constructor() public {
    }

    function stake(uint256 _period, uint256 _amount) public {
        require(_amount > 0, 'stake too low');
        require(_period < periodDays.length, 'wrong period');

        coesLpToken.transferFrom(address(msg.sender), address(this), _amount);

        orders[msg.sender].push(Order(
                _amount,
                _period,
                block.timestamp
            ));

        uint256 index = orders[msg.sender].length - 1;
        uint256 power = getLpValue(_amount).mul(powerRate[_period]);

        emit Stake(msg.sender, index, _period, _amount, power);
    }

    function cancelStake(uint256 _index) public {
        Order memory order = orders[msg.sender][_index];
        require(order.amount > 0, 'no stake amount');

        uint256 overTime = order.time.add(periodDays[order.period]);
        require(overTime <= block.timestamp, 'not over');

        delete orders[msg.sender][_index];

        coesLpToken.transfer(msg.sender, order.amount);

        emit CancelStake(msg.sender, _index, order.period, order.amount);
    }

    function director(uint256 _amount) public {
        require(_amount == minBurnAmount, 'wrong amount');
        uint256 usdtAmount = getUsdtAmount(_amount);
        uint256 power = burnPowerRate.mul(usdtAmount);
        coesToken.transferFrom(address(msg.sender), burnAddress, _amount);
        emit Burn(msg.sender, _amount, power);
    }

    function getUserOrders() public view returns(Order[] memory) {
        return orders[msg.sender];
    }

    function getLpValue(uint256 _amount) public view returns(uint256) {
        uint256 totalSupply = coesLpToken.totalSupply();
        if (totalSupply > 0) {
            uint256 balance = usdtToken.balanceOf(address(coesLpToken));
            return balance.mul(_amount).mul(2).div(totalSupply);
        }

        return 0;
    }

    function getUsdtAmount(uint256 _amount) public view returns(uint256) {
        IPancakePair pair = IPancakePair(address(coesLpToken));

        IBEP20 token0 = IBEP20(pair.token0());
        IBEP20 token1 = IBEP20(pair.token1());
        (uint256 Res0, uint256 Res1,) = pair.getReserves();

        if (address(token0) == address(coesToken)) {
            return _amount.mul(Res1).div(Res0);
        } else if(address(token1) == address(coesToken))  {
            return _amount.mul(Res0).div(Res1);
        }
        return 0;
    }

    function reward(address _addr, uint256 _amount) public onlyOwner {
        require(_amount > 0, 'no amount');
        require(csrToken.balanceOf(address(this)) >= _amount, 'no balance');
        csrToken.transfer(_addr, _amount);
        emit Reward(_addr, _amount);
    }

    function withdraw() public payable {
        require(msg.value >= FEE, 'need fee');
        emit Withdraw(msg.sender);
    }

    function drawToken(address _token, address _addr, uint256 _amount) public onlyOwner {
        require(_addr != address(0), 'no zero addr');
        IBEP20(_token).transfer(_addr, _amount);
    }

    function drawFee(address payable _addr) public onlyOwner {
        _addr.transfer(address(this).balance);
    }

    function updateFee(uint256 _fee) public onlyOwner {
        FEE = _fee;
    }

    function updatePeriodDays(uint256 _index, uint256 _days) public onlyOwner {
        periodDays[_index] = _days;
    }

    function updatePowerRate(uint256 _index, uint256 _rate) public onlyOwner {
        powerRate[_index] = _rate;
    }

    function updateBurnPowerRate(uint256 _rate) public onlyOwner {
        burnPowerRate = _rate;
    }

    function updateMinBurnAmount(uint256 _amount) public onlyOwner {
        minBurnAmount = _amount;
    }

    function updateCsrTokenAddr(address _addr) public onlyOwner {
        csrToken = IBEP20(_addr);
    }
}
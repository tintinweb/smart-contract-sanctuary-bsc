/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// File: openzeppelin-solidity-2.3.0/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity-2.3.0/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/GoblinConfig.sol

pragma solidity 0.5.16;

interface GoblinConfig {
    /// @dev Return whether the given goblin accepts more debt.
    function acceptDebt(address goblin) external view returns (bool);
    /// @dev Return the work factor for the goblin + ETH debt, using 1e4 as denom.
    function workFactor(address goblin, uint256 debt) external view returns (uint256);
    /// @dev Return the kill factor for the goblin + ETH debt, using 1e4 as denom.
    function killFactor(address goblin, uint256 debt) external view returns (uint256);
}

// File: contracts/PriceOracle.sol

pragma solidity 0.5.16;

interface PriceOracle {
    /// @dev Return the wad price of token0/token1, multiplied by 1e18
    /// NOTE: (if you have 1 token0 how much you can sell it for token1)
    function getPrice(address token0, address token1)
        external view
        returns (uint256 price, uint256 lastUpdate);
}

// File: contracts/SafeToken.sol

pragma solidity 0.5.16;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// File: contracts/wombat/IWombatLp.sol

pragma solidity 0.5.16;

interface IWombatLp {
  function underlyingToken() view external returns (address);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function getRelativePrice() external view returns (uint256);
}

// File: contracts/MasterChefGoblinConfigWom.sol

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;







contract MasterChefGoblinConfigWom is Ownable, GoblinConfig {
    using SafeToken for address;
    using SafeMath for uint256;

    struct Config {
        bool acceptDebt;
        uint64 workFactor;
        uint64 killFactor;
        uint64 maxPriceDiff;
    }

    PriceOracle public oracle;
    address public weth;
    mapping (address => Config) public goblins;

    constructor(PriceOracle _oracle, address _weth) public {
        oracle = _oracle;
        weth = _weth;
    }

    /// @dev Set oracle address. Must be called by owner.
    function setOracle(PriceOracle _oracle) external onlyOwner {
        oracle = _oracle;
    }

    /// @dev Set goblin configurations. Must be called by owner.
    function setConfigs(address[] calldata addrs, Config[] calldata configs) external onlyOwner {
        uint256 len = addrs.length;
        require(configs.length == len, "bad len");
        for (uint256 idx = 0; idx < len; idx++) {
            goblins[addrs[idx]] = Config({
                acceptDebt: configs[idx].acceptDebt,
                workFactor: configs[idx].workFactor,
                killFactor: configs[idx].killFactor,
                maxPriceDiff: configs[idx].maxPriceDiff
            });
        }
    }

    /// @dev Return whether the given goblin is stable, presumably not under manipulation.
    function isStable(address goblin) public view returns (bool) {
        IWombatLp lp = IWombatLp(goblin);
        address underlyingToken = lp.underlyingToken();
        (address token0, address token1) = sortTokens(underlyingToken, weth);
        (uint256 price, uint256 lastUpdate) = oracle.getPrice(token0, token1);
        require(lastUpdate >= now - 7 days, "price too stale");
        uint256 lpPrice = lp.getRelativePrice();
        uint256 maxPriceDiff = goblins[goblin].maxPriceDiff;
        require(lpPrice <= price.mul(maxPriceDiff).div(10000), "price too high");
        require(lpPrice >= price.mul(10000).div(maxPriceDiff), "price too low");
        return true;
    }

    /// @dev Return whether the given goblin accepts more debt.
    function acceptDebt(address goblin) external view returns (bool) {
        require(isStable(goblin), "!stable");
        return goblins[goblin].acceptDebt;
    }

    /// @dev Return the work factor for the goblin + ETH debt, using 1e4 as denom.
    function workFactor(address goblin, uint256 /* debt */) external view returns (uint256) {
        require(isStable(goblin), "!stable");
        return uint256(goblins[goblin].workFactor);
    }

    /// @dev Return the kill factor for the goblin + ETH debt, using 1e4 as denom.
    function killFactor(address goblin, uint256 /* debt */) external view returns (uint256) {
        require(isStable(goblin), "!stable");
        return uint256(goblins[goblin].killFactor);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
}
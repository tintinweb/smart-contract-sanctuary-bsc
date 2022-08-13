/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
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
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract SNKLPMiner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public SNK;
    address public SNKLP;

    uint32 private orders;
    mapping(uint32 => OrderInfo) private orderInfo;
    mapping(address => uint32[]) private userOrders;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    struct OrderInfo {
        address user;
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 reward;
        uint256 rate;
        uint256 lastRewardTime;
        bool isTakeBack;
    }

    event NewOrder(
        address indexed user,
        uint32 indexed tid,
        uint256 amount,
        uint256 start,
        uint256 end
    );
    event RewardPaid(address indexed user, uint256 reward);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _SNK, address _SNKLP) {
        _owner = msg.sender;

        SNK = _SNK;
        SNKLP = _SNKLP;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function getOrders() public view returns (uint32) {
        return orders;
    }

    function getOrderInfo(uint32 orderId)
        public
        view
        returns (OrderInfo memory)
    {
        return orderInfo[orderId];
    }

    function getUserOrders(address user) public view returns (uint32[] memory) {
        return userOrders[user];
    }

    function earned(address user) public view returns (uint256) {
        uint256 totalRewards = 0;
        for (uint32 j = 0; j < userOrders[user].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[user][j]];
            if (block.timestamp <= o.end) {
                totalRewards += (block.timestamp - o.lastRewardTime) * o.rate;
            }
        }
        return totalRewards;
    }

    function stake(uint256 amount, uint256 endTime) external {
        require(amount > 0, "The number must be greater than 0");
        require(
            endTime >= block.timestamp.add(86400),
            "The locked time must be greater than 86400"
        );

        totalSupply = totalSupply.add(amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        IERC20(SNKLP).safeTransferFrom(msg.sender, address(this), amount);

        orders++;
        orderInfo[orders].user = msg.sender;
        orderInfo[orders].amount = amount;
        orderInfo[orders].start = block.timestamp;
        orderInfo[orders].end = endTime;
        orderInfo[orders].lastRewardTime = block.timestamp;
        orderInfo[orders].isTakeBack = false;

        uint256 lockedTime = endTime.sub(block.timestamp);
        uint256 dTime = lockedTime.div(86400);
        if (dTime >= 30) {
            orderInfo[orders].reward = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .mul(40)
                .div(100)
                .mul(dTime);
            orderInfo[orders].rate = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .mul(40)
                .div(100)
                .div(86400);
        } else if (dTime >= 15 && dTime < 30) {
            orderInfo[orders].reward = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .mul(20)
                .div(100)
                .mul(dTime);
            orderInfo[orders].rate = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .mul(20)
                .div(100)
                .div(86400);
        } else {
            orderInfo[orders].reward = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .div(100)
                .mul(dTime);
            orderInfo[orders].rate = amount
                .mul(getExchangeCountOfOneLP())
                .div(1e18)
                .div(100)
                .div(86400);
        }

        userOrders[msg.sender].push(orders);

        emit NewOrder(msg.sender, orders, amount, block.timestamp, endTime);
    }

    function getExchangeCountOfOneLP() public view returns (uint256) {
        uint256 s = IPancakePair(SNKLP).totalSupply();

        uint256 r;
        if (IPancakePair(SNKLP).token0() == SNK) {
            (r, , ) = IPancakePair(SNKLP).getReserves();
        } else {
            (, r, ) = IPancakePair(SNKLP).getReserves();
        }

        return r.mul(1e18).div(s);
    }

    function claim() external {
        uint256 totalRewards = 0;
        for (uint32 j = 0; j < userOrders[msg.sender].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[msg.sender][j]];
            if (block.timestamp <= o.end) {
                totalRewards += (block.timestamp - o.lastRewardTime) * o.rate;

                orderInfo[userOrders[msg.sender][j]].lastRewardTime = block
                    .timestamp;
            }
        }
        IERC20(SNK).safeTransfer(msg.sender, totalRewards);
        emit RewardPaid(msg.sender, totalRewards);
    }

    function canWithdraw(address user) public view returns (uint256) {
        uint256 totalLPs = 0;
        for (uint32 j = 0; j < userOrders[user].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[user][j]];
            if (block.timestamp >= o.end && !o.isTakeBack) {
                totalLPs += o.amount;
            }
        }

        return totalLPs;
    }

    function withdraw() external {
        uint256 totalLPs = 0;
        for (uint32 j = 0; j < userOrders[msg.sender].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[msg.sender][j]];
            if (block.timestamp >= o.end && !o.isTakeBack) {
                totalLPs += o.amount;

                orderInfo[userOrders[msg.sender][j]].isTakeBack = true;
            }
        }

        if (totalLPs > 0) {
            totalSupply = totalSupply.sub(totalLPs);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalLPs);
            IERC20(SNKLP).safeTransfer(msg.sender, totalLPs);
            emit Withdrawn(msg.sender, totalLPs);
        }
    }

    function clearPot(address to, uint256 amount) external onlyOwner {
        if (amount > IERC20(SNK).balanceOf(address(this)))
            amount = IERC20(SNK).balanceOf(address(this));
        IERC20(SNK).safeTransfer(to, amount);
    }
}
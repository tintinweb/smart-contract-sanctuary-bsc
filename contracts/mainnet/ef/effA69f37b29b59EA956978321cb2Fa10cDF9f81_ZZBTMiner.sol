/**
 *Submitted for verification at BscScan.com on 2022-11-09
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
        // See: https://github.com/OpenZeppelin/openzAddresseppelin-solidity/pull/522
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

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

contract ZZBTMiner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public zzbtAddress =
        address(0xe10cE754C06FE9178555b4F5B02f66eE65c1625c);
    address public nzAddress =
        address(0x4C278964A598F103316EeA17c8D4C6B1B0e8b2EA);
    address public usdtAddress =
        address(0x55d398326f99059fF775485246999027B3197955);
    IPancakeRouter01 public PancakeRouter01 =
        IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 public minAmount = 1000 * 10**18;
    uint256 public price = 58 * 10**16;
    uint256 public rRate = 20;
    uint256 private tRate = 10000;

    uint256 public totalSupply;
    uint256 public orders;
    uint256 public claims;

    mapping(uint256 => Order) public orderInfo;
    mapping(address => uint256[]) private userOrders;
    mapping(uint256 => Claim) public claimInfo;
    mapping(address => uint256[]) private userClaims;
    mapping(address => uint256) public balanceOf;

    event Stake(address indexed user, uint256 amount, uint256 tid);
    event RewardPaid(address indexed user, uint256 reward);

    struct Order {
        address user;
        uint256 zzbtAmount;
        uint256 tReward;
        uint256 hReward;
        uint256 rate;
        uint256 orderTime;
        uint256 rewardTime;
    }

    struct Claim {
        address user;
        uint256 amount;
        uint256 rewardTime;
    }

    constructor() {
        _owner = msg.sender;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function stake(uint256 amount) external {
        require(amount >= minAmount, "less amount");

        totalSupply = totalSupply.add(amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);

        IERC20(zzbtAddress).safeTransferFrom(
            msg.sender,
            destroyAddress,
            amount
        );

        orders = orders.add(1);
        Order storage o = orderInfo[orders];
        o.user = msg.sender;
        o.zzbtAmount = amount;
        o.tReward = amount.mul(price).div(getp1());
        o.hReward = 0;
        o.rate = amount.mul(price).div(getp1()).mul(rRate).div(tRate).div(
            86400
        );
        o.orderTime = block.timestamp;
        o.rewardTime = block.timestamp;

        userOrders[msg.sender].push(orders);

        emit Stake(msg.sender, amount, orders);
    }

    function userEarned(address user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tReward;
        uint256 hReward;
        uint256 pReward;

        for (uint256 i = 0; i < userOrders[user].length; i++) {
            Order memory o = orderInfo[userOrders[user][i]];
            tReward = tReward.add(o.tReward);
            hReward = hReward.add(o.hReward);

            if (o.hReward < o.tReward) {
                uint256 reward = block.timestamp.sub(o.rewardTime).mul(o.rate);
                if (o.hReward.add(reward) >= o.tReward) {
                    reward = o.tReward.sub(o.hReward);
                }
                pReward = pReward.add(reward);
            }
        }

        return (tReward, hReward, pReward);
    }

    function getp1() public view returns (uint256) {
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        path[0] = nzAddress;
        path[1] = usdtAddress;
        amounts = PancakeRouter01.getAmountsOut(1e18, path);
        if (amounts.length > 0) {
            return amounts[1];
        } else {
            return 0;
        }
    }

    function getUserOrders(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userOrders[user];
    }

    function getUserClaims(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userClaims[user];
    }

    function claim() external {
        uint256 totalRewards;
        for (uint256 i = 0; i < userOrders[msg.sender].length; i++) {
            Order memory o = orderInfo[userOrders[msg.sender][i]];

            if (o.hReward < o.tReward) {
                uint256 reward = block.timestamp.sub(o.rewardTime).mul(o.rate);
                if (o.hReward.add(reward) >= o.tReward) {
                    reward = o.tReward.sub(o.hReward);
                }
                totalRewards = totalRewards.add(reward);

                orderInfo[userOrders[msg.sender][i]].rewardTime = block
                    .timestamp;
                orderInfo[userOrders[msg.sender][i]].hReward += reward;
            }
        }

        claims = claims.add(1);
        Claim storage c = claimInfo[claims];
        c.user = msg.sender;
        c.amount = totalRewards;
        c.rewardTime = block.timestamp;

        userClaims[msg.sender].push(claims);

        IERC20(nzAddress).safeTransfer(msg.sender, totalRewards);
        emit RewardPaid(msg.sender, totalRewards);
    }

    function changeRate(uint256 newRate) external onlyOwner {
        rRate = newRate;
    }

    function changePrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function changeMinAmount(uint256 newMinAmount) external onlyOwner {
        minAmount = newMinAmount;
    }

    function clearPot(address to, uint256 amount) external onlyOwner {
        if (amount > IERC20(nzAddress).balanceOf(address(this))) {
            amount = IERC20(nzAddress).balanceOf(address(this));
        }
        IERC20(nzAddress).safeTransfer(to, amount);
    }
}
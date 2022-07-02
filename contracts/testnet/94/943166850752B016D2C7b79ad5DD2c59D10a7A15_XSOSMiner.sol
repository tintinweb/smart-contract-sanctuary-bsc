/**
 *Submitted for verification at BscScan.com on 2022-07-01
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

interface IXSOS1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function whiteListPurchase(uint32 tid, address to, uint32 amount) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}



contract XSOSMiner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    IXSOS1155 public XSOS1155;
    IERC20 public XSOS;

    uint256 private cycOp = 30 days;

    mapping(address => address) private inviter;
    mapping(address => address[]) private inviterSuns;
    
    mapping(uint32 => uint32) private nftPower;
    mapping(uint32 => uint256) private nftRewardRate;
    mapping(uint32 => uint32) private maxRuns;

    uint32 private orders;
    mapping(uint32 => OrderInfo) private orderInfo;
    mapping(address => uint32[]) private userOrders;

    mapping(address => uint256) private airdropMachineToTimestamp;
    mapping(address => uint256) private airdropTokenToTimestamp;


    struct OrderInfo {
        address user;
        uint32 tid;
        uint8 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 rewardTime;
    }

    event Bind(address indexed user, address indexed inviter);
    event NewOrder(address indexed user, uint32 indexed tid, uint8 amount, uint256 startTime, uint256 endTime);
    event RewardPaid(address indexed user, uint256 reward); 
    event AirdropMachine(address indexed user, uint32 id);
    event AirdropToken(address indexed user, uint256 amount);

    constructor(IERC20 _XSOS, IXSOS1155 _XSOS1155) {
        _owner = msg.sender;

        XSOS = _XSOS;
        XSOS1155 = _XSOS1155;

        nftPower[0] = 10;
        nftPower[1] = 100;
        nftPower[2] = 500;
        nftPower[3] = 1000;
        nftPower[4] = 3000;
        nftPower[5] = 5000;

        nftRewardRate[0] = 135e18 / (cycOp * 86400);
        nftRewardRate[1] = 1280e18 / (cycOp * 86400);
        nftRewardRate[2] = 6200e18 / (cycOp * 86400);
        nftRewardRate[3] = 12600e18 / (cycOp * 86400);
        nftRewardRate[4] = 38100e18 / (cycOp * 86400);
        nftRewardRate[5] = 64000e18 / (cycOp * 86400);

        maxRuns[0] = 8;
        maxRuns[1] = 4;
        maxRuns[2] = 2;
        maxRuns[3] = 1;
        maxRuns[4] = 1;
        maxRuns[5] = 1;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


    function getInviter(address user) public view returns (address) {
        return inviter[user];
    }

    function getInviterSuns(address user)
        public
        view
        returns (address[] memory)
    {
        return inviterSuns[user];
    }

    function getInviterSunSize(address user) public view returns (uint256) {
        return inviterSuns[user].length;
    }

    function getNftPower(uint32 tid) public view returns (uint32) {
        return nftPower[tid];
    }

    function getNftRewardRate(uint32 tid) public view returns (uint256) {
        return nftRewardRate[tid];
    }

    function getMaxRuns(uint32 tid) public view returns (uint32) {
        return maxRuns[tid];
    }

    function getCycOp() public view returns (uint256) {
        return cycOp;
    }

    function getOrders() public view returns (uint32) {
        return orders;
    }

    function getOrderInfo(uint32 orderId) public view returns (OrderInfo memory) {
        return orderInfo[orderId];
    }

    function getUserOrders(address user) public view returns (uint32[] memory) {
        return userOrders[user];
    }

    function getUserOrdersByTid(uint256 tid, address user) public view returns (uint32) {
        uint32 res;
        for (uint32 i=0; i<userOrders[user].length; i++) {
            OrderInfo memory o = orderInfo[userOrders[user][i]];
            if (block.timestamp < o.endTime && tid == o.tid) res += o.amount;
        }
        return res;
    }

    function getAirdropMachineToTimestamp(address user) public view returns (uint256) {
        return airdropMachineToTimestamp[user];
    }

    function getAirdropTokenToTimestamp(address user) public view returns (uint256) {
        return airdropTokenToTimestamp[user];
    }

    function getSelfPower(address user) public view returns (uint256) {
        uint256 pow;
        for (uint8 i = 0; i < 6; i++) {
            // uint256 un = XSOS1155.balanceOf(user, i);
            uint256 sn = getUserOrdersByTid(i, user);
            uint256 p = nftPower[i];
            // pow = pow.add(p.mul(un.add(sn)));
            pow = pow.add(p.mul(sn));
        }
        return pow;
    }

    function getTeamPower(address user) public view returns (uint256) {
        uint256 pow;
        for (uint8 i=0; i<inviterSuns[user].length; i++) {
            pow += getSelfPower(inviterSuns[user][i]);
        }
        return pow;
    }

    function earned(address user) public view returns (uint256) {
        uint256 totalRewards = 0;
        for (uint32 j=0; j<userOrders[user].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[user][j]];
            if (block.timestamp < o.endTime) {
                totalRewards = totalRewards + (block.timestamp - o.rewardTime) * o.amount * nftRewardRate[o.tid];
            }
        }  
        return totalRewards;
    }

    function changeNftPower(uint32 tid, uint32 pow) external onlyOwner {
        nftPower[tid] = pow;
    }

    function changeNftRewardRate(uint32 tid, uint32 reward) external onlyOwner {
        nftRewardRate[tid] = reward;
    }

    function changeCycleOp(uint32 times) external onlyOwner {
        cycOp = times;
    }

    function bindParent(address parent) external {
        require(inviter[msg.sender] == address(0), "Already bind");
        require(parent != address(0), "ERROR parent");
        require(parent != msg.sender, "error parent");
        inviter[msg.sender] = parent;
        inviterSuns[parent].push(msg.sender);
        emit Bind(msg.sender, parent);
    }

    function stake(uint32 tid, uint8 amount) external {
        require(XSOS1155.balanceOf(msg.sender, tid) >= amount, "Not enough");
        require(getUserOrdersByTid(tid, msg.sender) + amount <= maxRuns[tid], "amount exceed limit");

        bytes memory b;    
        XSOS1155.safeTransferFrom(msg.sender, _destroyAddress, tid, amount, b);

        orders++;
        orderInfo[orders].user = msg.sender;
        orderInfo[orders].tid = tid;
        orderInfo[orders].amount = amount;
        orderInfo[orders].startTime = block.timestamp;
        orderInfo[orders].endTime = block.timestamp.add(cycOp);
        orderInfo[orders].rewardTime = block.timestamp;

        userOrders[msg.sender].push(orders);

        emit NewOrder(msg.sender, tid, amount, block.timestamp, block.timestamp.add(cycOp));
    }

    function claim() external {
        uint256 totalRewards = 0;
        for (uint32 j=0; j<userOrders[msg.sender].length; j++) {
            OrderInfo memory o = orderInfo[userOrders[msg.sender][j]];
            if (block.timestamp < o.endTime) {
                totalRewards = totalRewards + (block.timestamp - o.rewardTime) * o.amount * nftRewardRate[o.tid];

                o.rewardTime = block.timestamp;
            }
        }
        XSOS.safeTransfer(msg.sender, totalRewards); 
        emit RewardPaid(msg.sender, totalRewards);
    }

    function airdropMachine() external {
        require(block.timestamp - airdropMachineToTimestamp[msg.sender] >= cycOp, "Not start");
        uint256 s = getSelfPower(msg.sender);
        uint256 t = getTeamPower(msg.sender);

        uint32 tid = 9999;
        if (t >= 1280 && s >= 60) {
            tid = 4;
        } else if (t >= 620 && s >= 50) {
            tid = 3;
        } else if (t >= 310 && s >= 40) {
            tid = 2; 
        } else if (t >= 150 && s >= 30) {
            tid = 1;
        } else if (t >= 60 && s >= 20) {
            tid = 0;
        }

        if (tid != 999) {
            XSOS1155.whiteListPurchase(tid, msg.sender, 1);
            airdropMachineToTimestamp[msg.sender] = block.timestamp;
            emit AirdropMachine(msg.sender, tid);
        }  
    }

    function airdropToken() external {
        require(block.timestamp - airdropTokenToTimestamp[msg.sender] >= cycOp, "Not start");
        uint256 s = getSelfPower(msg.sender);
        uint256 t = getTeamPower(msg.sender);

        uint256 r = s.div(10).mul(1e18) + t.div(10).mul(2e18);

        if (r > 0) {
            XSOS.safeTransfer(msg.sender, r);
            airdropTokenToTimestamp[msg.sender] = block.timestamp;
            emit AirdropToken(msg.sender, r);
        }
        
    }

    function clearPot(address to, uint256 amount) external onlyOwner {
        if (amount > XSOS.balanceOf(address(this))) amount = XSOS.balanceOf(address(this));
        XSOS.safeTransfer(to, amount);
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-11-28
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

contract NZMiner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public zzbtAddress =
        address(0xe10cE754C06FE9178555b4F5B02f66eE65c1625c);
    address public nzAddress =
        address(0x5854972A4de57DF158aC429E7Ef4F5083cD354E4);
    address public usdtAddress =
        address(0x55d398326f99059fF775485246999027B3197955);
    IPancakeRouter01 public PancakeRouter01 =
        IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public feeOwner =
        address(0xF7AfFfDdcFaBCb4AcE8984d86CD3Dd4225Cf6AC1);

    uint256 public totalSupply;
    uint256 public orders;
    uint256 public claims;

    address[] peerList;

    mapping(uint256 => Order) public orderInfo;
    mapping(address => uint256[]) private userOrders;
    mapping(uint256 => Claim) public claimInfo;
    mapping(address => uint256[]) private userClaims;
    mapping(address => User) public userInfo;
    mapping(address => UserReward) public userRewardInfo;

    struct User {
        address userAddress;
        bool isValid;
        bool isPeer;
        uint256 directAmount;
        uint256 indirectAmount;
        uint256 validInvAmount;
        uint256 amountA;
        uint256 amountB;
        uint256 directHash;
        uint256 teamHash;
        address parent;
        address[] childers;
    }

    struct UserReward {
        uint256 accTotalReward;
        uint256 accPendingReward;
        uint256 peerTotalReward;
        uint256 peerPendingReward;
    }

    struct Order {
        address user;
        uint256 zzbtAmount;
        uint256 nzAmount;
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
        uint256 typeNumber;
    }

    event BindingParents(address indexed user, address inviter);
    event Stake(
        address indexed user,
        uint256 amountA,
        uint256 amountB,
        uint256 tid
    );
    event RewardPaid(address indexed user, uint256 reward);

    constructor() {
        _owner = msg.sender;

        _migrateAccountInfo(msg.sender);
        userInfo[msg.sender].parent = address(this);
        userInfo[address(this)].childers.push(msg.sender);
        emit BindingParents(msg.sender, address(this));
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function getMyChilders(address user)
        public
        view
        returns (address[] memory)
    {
        return userInfo[user].childers;
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

    function userEarned(address user)
        public
        view
        returns (
            uint256 totalReward,
            uint256 inviteReward,
            uint256 peerTotalReward,
            uint256 hasReward,
            uint256 pendingReward
        )
    {
        inviteReward = userRewardInfo[user].accPendingReward;
        peerTotalReward = userRewardInfo[user].peerPendingReward;
        for (uint256 i = 0; i < userOrders[user].length; i++) {
            Order memory o = orderInfo[userOrders[user][i]];
            totalReward = totalReward.add(o.tReward);
            hasReward = hasReward.add(o.hReward);

            if (o.hReward < o.tReward) {
                uint256 reward = block.timestamp.sub(o.rewardTime).mul(o.rate);
                if (o.hReward.add(reward) >= o.tReward) {
                    reward = o.tReward.sub(o.hReward);
                }
                pendingReward = pendingReward.add(reward);
            }
        }
    }

    function changeFeeOwner(address newFeeOwner) external onlyOwner {
        feeOwner = newFeeOwner;
    }

    function bindParent(address parent) external {
        _migrateAccountInfo(msg.sender);
        _migrateAccountInfo(parent);
        require(userInfo[msg.sender].parent == address(0), "Already bind");
        require(parent != address(0), "ERROR PARENT: parent is zero address");
        require(parent != msg.sender, "ERROR PARENT: parent is self address");
        require(userInfo[parent].parent != address(0), "Parent no bind");
        userInfo[msg.sender].parent = parent;
        userInfo[parent].childers.push(msg.sender);
        userInfo[parent].directAmount++;
        userInfo[userInfo[parent].parent].indirectAmount++;
        emit BindingParents(msg.sender, parent);
    }

    function claim() external {
        _migrateAccountInfo(msg.sender);
        uint256 rew = userRewardInfo[msg.sender].accPendingReward.add(
            userRewardInfo[msg.sender].peerPendingReward
        );

        uint256 rew0= rew;

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

                uint256 r = o.tReward.sub(o.hReward).sub(reward);
                if (rew >= r) {
                    orderInfo[userOrders[msg.sender][i]].hReward = o.tReward;
                    rew = rew.sub(r);
                } else {
                    orderInfo[userOrders[msg.sender][i]].hReward += reward.add(
                        rew
                    );
                    rew = 0;
                }
            }
        }

        userRewardInfo[msg.sender].accTotalReward += userRewardInfo[msg.sender].accPendingReward;
        userRewardInfo[msg.sender].accPendingReward = 0;
        userRewardInfo[msg.sender].peerTotalReward = userRewardInfo[msg.sender].peerPendingReward;
        userRewardInfo[msg.sender].peerPendingReward = 0;

        _claimInviteFee(msg.sender, totalRewards);
        
        _claimPeerFee(msg.sender, totalRewards.div(10));

        claims = claims.add(1);
        Claim storage c0 = claimInfo[claims];
        c0.user = msg.sender;
        c0.amount = totalRewards;
        c0.rewardTime = block.timestamp;
        c0.typeNumber = 0;
        userClaims[msg.sender].push(claims);

        claims = claims.add(1);
        Claim storage c1 = claimInfo[claims];
        c1.user = msg.sender;
        c1.amount = rew0;
        c1.rewardTime = block.timestamp;
        c1.typeNumber = 1;
        userClaims[msg.sender].push(claims);

        IERC20(nzAddress).safeTransfer(msg.sender, totalRewards.add(rew0));
        emit RewardPaid(msg.sender, totalRewards.add(rew0));
    }

    function stake(uint256 amount, bool all) external {
        _migrateAccountInfo(msg.sender);
        require(
            userInfo[msg.sender].parent != address(0),
            "Must bind parent first"
        );
        require(
            amount == 100e18 ||
                amount == 500e18 ||
                amount == 1500e18 ||
                amount == 3000e18,
            "Error amount"
        );

        if (!userInfo[msg.sender].isValid) {
            userInfo[msg.sender].isValid = true;
            userInfo[userInfo[msg.sender].parent].validInvAmount++;
        }

        uint256 amountA = amount;
        uint256 amountB = 0;
        if (!all) {
            amountA = amount.mul(80).div(100);
            amountB = amount.mul(20).div(100).mul(getp1()).div(7e17);
        }

        totalSupply = totalSupply.add(amountA);
        userInfo[msg.sender].amountA = userInfo[msg.sender].amountA.add(
            amountA
        );
        userInfo[msg.sender].amountB = userInfo[msg.sender].amountB.add(
            amountB
        );

        if (
            userInfo[msg.sender].amountA >= 3000e18 &&
            userInfo[msg.sender].directHash >= 20000e18 &&
            !userInfo[msg.sender].isPeer
        ) {
            userInfo[msg.sender].isPeer = true;
            peerList.push(msg.sender);
        }

        IERC20(nzAddress).safeTransferFrom(msg.sender, feeOwner, amountA);
        IERC20(zzbtAddress).safeTransferFrom(
            msg.sender,
            destroyAddress,
            amountB
        );

        (uint256 a, uint256 b) = _rate(amount);

        userInfo[userInfo[msg.sender].parent].directHash += amountA;

        if (
            userInfo[userInfo[msg.sender].parent].amountA >= 3000e18 &&
            userInfo[userInfo[msg.sender].parent].directHash >= 20000e18 &&
            !userInfo[userInfo[msg.sender].parent].isPeer
        ) {
            userInfo[userInfo[msg.sender].parent].isPeer = true;
            peerList.push(userInfo[msg.sender].parent);
        }

        _teamhash(msg.sender, amountA);

        orders = orders.add(1);
        orderInfo[orders].user = msg.sender;
        orderInfo[orders].zzbtAmount = amountB;
        orderInfo[orders].nzAmount = amountA;
        orderInfo[orders].tReward = amount.mul(a).div(10000);
        orderInfo[orders].hReward = 0;
        orderInfo[orders].rate = amount.mul(b).div(10000).div(
            86400
        );
        orderInfo[orders].orderTime = block.timestamp;
        orderInfo[orders].rewardTime = block.timestamp;

        userOrders[msg.sender].push(orders);

        emit Stake(msg.sender, amountA, amountB, orders);
    }

    function _claimInviteFee(address user, uint256 amount) private {
        address parent = user;
        for (uint256 i = 1; i <= 10; i++) {
            parent = userInfo[parent].parent;
            if (parent == address(0) || parent == address(this)) break;

            uint256 rate = 0;
            if (i == 1) rate = 10;
            else if (i > 1 && i < 6) rate = 5;
            else rate = 4;

            uint256 amount0 = amount.mul(rate).div(100);
            
            if (userInfo[parent].validInvAmount >= i) {

                (uint256 t, uint256 j, uint256 p0, uint256 h, uint256 p1) = userEarned(parent);
                if (t == 0) {
                    break;
                }
                if (j + p0 + h + p1 + amount0 > t) {
                    amount0 = t - j - p0 - h - p1;
                }

                userRewardInfo[parent].accPendingReward += amount0;
            } 
        }
    }

    function _claimPeerFee(address user, uint256 amount) private {
        address parent = user;
        for (uint256 i = 1; i <= 20; i++) {
            parent = userInfo[parent].parent;
            if (parent == address(0) || parent == address(this)) break;

            if (userInfo[parent].isPeer) {

                (uint256 t, uint256 j, uint256 p0, uint256 h, uint256 p1) = userEarned(parent);
                if (t == 0) {
                    break;
                }
                if (j + p0 + h + p1 + amount > t) {
                    amount = t - j - p0 - h - p1;
                }

                userRewardInfo[parent].peerPendingReward += amount;
                break;
            }
        }
    }

    function _teamhash(address user, uint256 amount) private {
        address parent = user;
        for (uint256 i = 0; i < 20; i++) {
            parent = userInfo[parent].parent;
            if (parent == address(0) || parent == address(this)) break;
            userInfo[parent].teamHash += amount;
        }
    }

    function _rate(uint256 amount) private pure returns (uint256, uint256) {
        if (amount == 100e18) return (18000, 60);
        else if (amount == 500e18) return (20000, 60);
        else if (amount == 1500e18) return (22000, 80);
        else if (amount == 3000e18) return (25000, 80);
        return (0, 0);
    }

    function clearPot(address to, uint256 amount) external onlyOwner {
        if (amount > IERC20(nzAddress).balanceOf(address(this))) {
            amount = IERC20(nzAddress).balanceOf(address(this));
        }
        IERC20(nzAddress).safeTransfer(to, amount);
    }

    function getPeerList() public view returns (address[] memory) {
        return peerList;
    }

    function peerListSort() public view returns (User[] memory) {
        address[] memory pl = peerList;

        User[] memory infos = new User[](pl.length);
        for (uint256 i = 0; i < pl.length; i++) {
            infos[i] = userInfo[pl[i]];
        }
        infos = _userInfoSort(infos);

        return infos;
    }

    function _userInfoSort(User[] memory a)
        internal
        pure
        returns (User[] memory)
    {
        // note that uint can not take negative value
        for (uint256 i = 1; i < a.length; i++) {
            User memory temp = a[i];
            uint256 j = i;

            while ((j >= 1) && (temp.amountA > a[j - 1].amountA)) {
                a[j] = a[j - 1];
                j--;
            }
            a[j] = temp;
        }
        return (a);
    }

    function _migrateAccountInfo(address account) internal {
        if (userInfo[account].userAddress == address(0)) {
            userInfo[account].userAddress = account;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

pragma solidity ^0.5.0;

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
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
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

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract LPTokenWrapper is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;

    ERC20Detailed internal y;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function initialize(address _y) internal initializer {
        y = ERC20Detailed(_y); //
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount, uint256 feeAmount) internal {
        _totalSupply = _totalSupply.add(amount.sub(feeAmount));
        _balances[msg.sender] = _balances[msg.sender].add(
            amount.sub(feeAmount)
        );
        y.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount,uint256 feeAmount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        y.transfer(msg.sender, amount.sub(feeAmount));
    }
}

interface Invite {
    function invite(address user, address parent) external returns (bool);

    function getInviter(address user) external view returns (address);

    function getInviterSuns(address user)
        external
        view
        returns (address[] memory);

    function getInviterSunSize(address user) external view returns (uint256);
}

contract SNKMiner is LPTokenWrapper {
    using SafeERC20 for IERC20;
    IERC20 private token;

    Invite public inv;

    mapping(address => uint256) private communityBalances;

    uint256 private initreward;

    bool private flag = false;
    uint256 private totalRewards = 0;
    uint256 private precision = 1e18;

    uint256 private starttime;
    uint256 private stoptime;
    uint256 private rewardRate = 0;
    uint256 private lastUpdateTime;
    uint256 private rewardPerTokenStored;

    address public deployer;
    address public feeAddress;

    uint256[4] nodeCount;

    mapping(address => uint256) private userRewardPerTokenPaid;
    mapping(address => uint256) private rewards;

    uint256 private nodeRewardPerTokenStored1;
    uint256 private nodeRewardPerTokenStored2;
    uint256 private nodeRewardPerTokenStored3;
    uint256 private nodeRewardPerTokenStored4;
    mapping(address => uint256) private nodeUserRewardPerTokenPaid1;
    mapping(address => uint256) private nodeUserRewardPerTokenPaid2;
    mapping(address => uint256) private nodeUserRewardPerTokenPaid3;
    mapping(address => uint256) private nodeUserRewardPerTokenPaid4;
    mapping(address => uint256) private nodeRewards;

    event StartPool(uint256 initreward, uint256 starttime, uint256 stoptime);
    event Staked(address indexed user, uint256 amount, uint256 feeAmount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event NodeRewardPaid(address indexed user, uint256 reward);

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == deployer, "sender must deployer");

        feeAddress = _feeAddress;
    }

    function setDeployer(address _deployer) public {
        require(msg.sender == deployer, "sender must deployer");

        deployer = _deployer;
    }

    modifier updateReward(address account) {
        if (block.timestamp > starttime) {
            rewardPerTokenStored = rewardPerToken();

            nodeRewardPerTokenStored1 = nodeRewardPerToken(1);
            nodeRewardPerTokenStored2 = nodeRewardPerToken(2);
            nodeRewardPerTokenStored3 = nodeRewardPerToken(3);
            nodeRewardPerTokenStored4 = nodeRewardPerToken(4);

            flag = true;

            lastUpdateTime = lastTimeRewardApplicable();
            if (account != address(0)) {
                rewards[account] = dynamicEarned(account) + privateEarned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;

                nodeRewards[account] = nodeEarned(account);
                nodeUserRewardPerTokenPaid1[account] = nodeRewardPerTokenStored1;
                nodeUserRewardPerTokenPaid2[account] = nodeRewardPerTokenStored2;
                nodeUserRewardPerTokenPaid3[account] = nodeRewardPerTokenStored3;
                nodeUserRewardPerTokenPaid4[account] = nodeRewardPerTokenStored4;
            }
        }
        _;
    }

    constructor(
        address _y,
        address _token,
        address _inv,
        uint256 _initreward,
        uint256 _starttime,
        uint256 _stoptime
    ) public {
        deployer = msg.sender;

        super.initialize(_y);
        token = IERC20(_token);
        inv = Invite(_inv);
        starttime = _starttime;
        stoptime = _stoptime;
        initreward = _initreward * (precision);
        rewardRate = initreward.div(stoptime.sub(starttime));
        emit StartPool(initreward, starttime, stoptime);
    }

    function setPool(
        uint256 _initreward,
        uint256 _starttime,
        uint256 _stoptime
    ) public {
        require(msg.sender == deployer, "sender must deployer");

        starttime = _starttime;
        stoptime = _stoptime;
        initreward = _initreward * (precision);
        rewardRate = initreward.div(stoptime.sub(starttime));
        emit StartPool(initreward, starttime, stoptime);
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkStop {
        require(amount > 0, "The number must be greater than 0");

        uint256 onode = getUserNode(msg.sender);

        super.stake(amount, 0);

        uint256 nnode = getUserNode(msg.sender);

        if (onode != nnode) {
            if (nnode > 0) nodeCount[nnode - 1]++;

            if (onode > 0) nodeCount[onode - 1]--;
            
        }

        address parent = msg.sender;
        for (uint256 i = 0; i < 20; i++) {
            parent = inv.getInviter(parent);
            if (parent == address(0)) break;

            uint256 oldnode = getUserNode(parent);

            communityBalances[parent] = communityBalances[parent].add(amount);

            uint256 newnode = getUserNode(parent);

            if (oldnode != newnode) {
                if (newnode > 0) nodeCount[newnode - 1]++;

                if (oldnode > 0) nodeCount[oldnode - 1]--;
            }
        }

        emit Staked(msg.sender, amount, 0);
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = dynamicEarned(msg.sender) + privateEarned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;

            token.safeTransfer(msg.sender, reward);

            emit RewardPaid(msg.sender, reward);
            totalRewards = totalRewards.add(reward);
        }
    }

    function getNodeReward() public updateReward(msg.sender) checkStart {
        uint256 reward = nodeEarned(msg.sender);
        if (reward > 0) {
            nodeRewards[msg.sender] = 0;

            token.safeTransfer(msg.sender, reward);

            emit NodeRewardPaid(msg.sender, reward);
        }
    }

    function exit() public updateReward(msg.sender) {
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");

        uint256 onode = getUserNode(msg.sender);

        super.withdraw(amount, 0);

        uint256 nnode = getUserNode(msg.sender);

        if (onode != nnode) {
            if (nnode > 0) nodeCount[nnode - 1]++;

            if (onode > 0) nodeCount[onode - 1]--;
        }
        

        address parent = msg.sender;
        for (uint256 i = 0; i < 20; i++) {
            parent = inv.getInviter(parent);
            if (parent == address(0)) break;

            uint256 oldnode = getUserNode(parent);

            if (communityBalances[parent] > amount) {
                communityBalances[parent] = communityBalances[parent].sub(
                    amount
                );
            } else {
                communityBalances[parent] = 0;
            }

            uint256 newnode = getUserNode(parent);

            if (oldnode != newnode) {
                if (newnode > 0) nodeCount[newnode - 1]++;

                if (oldnode > 0) nodeCount[oldnode - 1]--;
            }

        }

        emit Withdrawn(msg.sender, amount);
        if (block.timestamp > starttime) {
            getReward();
        }
    }

    function dynamicEarned(address account) public view returns (uint256) {
        if (block.timestamp < starttime) {
            return 0;
        }

        if (balanceOf(account) < 10e18) {
            return 0;
        }
        
        return
            _getMyChildersBalanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .mul(45)
                .div(precision)
                .div(100)
                .add(rewards[account]);
    } 

    function privateEarned(address account) public view returns (uint256) {
        if (block.timestamp < starttime) {
            return 0;
        }

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .mul(35)
                .div(precision)
                .div(100)
                .add(rewards[account]);
    }

    function nodeEarned(address account) public view returns (uint256) {
        if (block.timestamp < starttime) {
            return 0;
        }
        
        uint256 node = getUserNode(account);

        uint256 e1;
        uint256 e2;
        uint256 e3;
        uint256 e4;
        if (node == 4) {
            e1 = nodeRewardPerToken(1).sub(nodeUserRewardPerTokenPaid1[account]).div(precision);
            e2 = nodeRewardPerToken(2).sub(nodeUserRewardPerTokenPaid2[account]).div(precision);
            e3 = nodeRewardPerToken(3).sub(nodeUserRewardPerTokenPaid3[account]).div(precision);
            e4 = nodeRewardPerToken(4).sub(nodeUserRewardPerTokenPaid4[account]).div(precision);   
        } else if (node == 3) {
            e1 = nodeRewardPerToken(1).sub(nodeUserRewardPerTokenPaid1[account]).div(precision);
            e2 = nodeRewardPerToken(2).sub(nodeUserRewardPerTokenPaid2[account]).div(precision);
            e3 = nodeRewardPerToken(3).sub(nodeUserRewardPerTokenPaid3[account]).div(precision);
        } else if (node == 2) {
            e1 = nodeRewardPerToken(1).sub(nodeUserRewardPerTokenPaid1[account]).div(precision);
            e2 = nodeRewardPerToken(2).sub(nodeUserRewardPerTokenPaid2[account]).div(precision);
        } else if (node == 1) {
            e1 = nodeRewardPerToken(1).sub(nodeUserRewardPerTokenPaid1[account]).div(precision);
        }

        return e1+e2+e3+e4+nodeRewards[account];
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return SafeMath.min(block.timestamp, stoptime);
    }

    function nodeRewardPerToken(uint256 index) internal view returns (uint256) {

        uint256 n = nodeRewardPerTokenStored1;
        uint256 r = 40;
        uint256 c = nodeCount[0] + nodeCount[1] + nodeCount[2] + nodeCount[3];
        if (index == 2) {
            n = nodeRewardPerTokenStored2;
            r = 30;
            c = nodeCount[1] + nodeCount[2] + nodeCount[3];
        } else if (index == 3) {
            n = nodeRewardPerTokenStored3;
            r = 20;
            c = nodeCount[2] + nodeCount[3];
        } else if (index == 4) {
            n = nodeRewardPerTokenStored4;
            r = 10;
            c = nodeCount[3];
        }

        if (totalSupply() == 0) {
            return n;
        }
        uint256 lastTime = 0;
        if (flag) {
            lastTime = lastUpdateTime;
        } else {
            lastTime = starttime;
        }

        if (c == 0) {
            return 0;
        }

        return
            n.add(
                lastTimeRewardApplicable()
                    .sub(lastTime)
                    .mul(rewardRate)
                    .mul(precision)
                    .mul(20)
                    .mul(r)
                    .div(10000)
                    .div(c)
            );
    }

    function rewardPerToken() internal view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        uint256 lastTime = 0;
        if (flag) {
            lastTime = lastUpdateTime;
        } else {
            lastTime = starttime;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastTime)
                    .mul(rewardRate)
                    .mul(precision)
                    .div(totalSupply())
            );
    }

    modifier checkStart() {
        require(block.timestamp > starttime, "not start");
        _;
    }

    modifier checkStop() {
        require(block.timestamp < stoptime, "already stop");
        _;
    }

    function getPoolInfo()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 left = initreward.sub(totalRewards);
        if (left < 0) {
            left = 0;
        }
        return (starttime, stoptime, totalSupply(), left);
    }

    function getUserNode(address user) public view returns (uint256) {
        uint256 sBal = balanceOf(user);
        (uint256 cBal,) = getMyAllCommunityBalanceOf(user);

        uint256 n;
        if (sBal >= 700e18 && cBal >= 170000e18) {
            n = 4;
        } else if (sBal >= 500e18 && cBal >= 60000e18) {
            n = 3;
        }  else if (sBal >= 300e18 && cBal >= 17500e18) {
            n = 2;
        } else if (sBal >= 100e18 && cBal >= 3500e18) {
            n = 1;
        } 

        return n;
    }

    function _getMyChildersBalanceOf(address user)
        private
        view
        returns (uint256)
    {
        address[] memory childers = inv.getInviterSuns(user);

        uint256 totalBalances;
        for (uint256 index = 0; index < childers.length; index++) {
            totalBalances += balanceOf(childers[index]);
        }

        return totalBalances;
    }

    function getMyChildersBalanceOf(address user) public view returns (uint256) {
        return _getMyChildersBalanceOf(user);
    }

    function getCommunityBalanceOf(address user) public view returns (uint256) {
        return communityBalances[user];
    }

    // function getMyAllCommunityBalanceOf(address user)
    //     public
    //     view
    //     returns (uint256, uint256)
    // {
    //     uint256 maxBalances = 0;
    //     address[] memory childers = inv.getInviterSuns(user);

    //     uint256 totalBalances = 0;
    //     for (uint256 index = 0; index < childers.length; index++) {
    //         if (communityBalances[childers[index]] > maxBalances) {
    //             maxBalances = communityBalances[childers[index]];
    //         }

    //         totalBalances += communityBalances[childers[index]];
    //     }

    //     return (totalBalances.sub(maxBalances), maxBalances);
    // }

    function getMyAllCommunityBalanceOf(address user)
        public
        view
        returns (uint256, uint256)
    {
        uint256 maxBalances = 0;
        address[] memory childers = inv.getInviterSuns(user);

        uint256 totalBalances = 0;
        for (uint256 index = 0; index < childers.length; index++) {
            uint256 bal = communityBalances[childers[index]] + balanceOf(childers[index]);
            if (bal > maxBalances) {
                maxBalances = bal;
            }

            totalBalances += bal;
        }

        return (totalBalances.sub(maxBalances), maxBalances);
    }

    function bindParent(address parent) public {
        address inviter = inv.getInviter(msg.sender);
        if (inviter == address(0) && parent != address(0)) {
            inv.invite(msg.sender, parent);
        }
    }

    function clearPot() public {
        if (msg.sender == deployer) {
            token.safeTransfer(msg.sender, token.balanceOf(address(this)));
        }
    }
}
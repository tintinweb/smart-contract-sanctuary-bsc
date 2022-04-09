// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.3;

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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[0x1717AFBE81bb09cbd283f18474349efE2c27DceD] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    function transferOwnership(address adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract Staking is Auth {
    address public rewardToken;
    address public token;
    uint256 public rate = 86400;
    mapping(address => uint256) public holders;
    // userAddress => stakingBalance
    mapping(address => uint256) public stakingBalance;
    // userAddress => isStaking boolean
    mapping(address => bool) public isStaking;
    // userAddress => timeStamp
    mapping(address => uint256) public startTime;
    // userAddress => pmknBalance
    mapping(address => uint256) public pmknBalance;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor() Auth(msg.sender) {
        token = 0x3D7a0549e208A8Fc2ebbe8410ea5546C362d6d69;
        rewardToken = 0x3D7a0549e208A8Fc2ebbe8410ea5546C362d6d69;
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function deposit(uint256 amount) public onlyOwner {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    /// @notice Locks the user's DAI within the contract
    /// @dev If the user already staked DAI, the
    /// @param amount Quantity of DAI the user wishes to lock in the contract
    function stake(uint256 amount) public {
        require(
            amount > 0 && IERC20(token).balanceOf(msg.sender) >= amount,
            "You cannot stake zero tokens"
        );

        if (isStaking[msg.sender] == true) {
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            pmknBalance[msg.sender] += toTransfer;
        }

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    /// @notice Retrieves funds locked in contract and sends them back to user
    /// @dev The yieldTransfer variable transfers the calculatedYieldTotal result to pmknBalance
    ///      in order to save the user's unrealized yield
    /// @param amount The quantity of DAI the user wishes to receive
    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] =
                true &&
                stakingBalance[msg.sender] >= amount,
            "Nothing to unstake"
        );
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        IERC20(token).transfer(msg.sender, balTransfer);
        pmknBalance[msg.sender] += yieldTransfer;
        if (stakingBalance[msg.sender] == 0) {
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer);
    }

    /// @notice Helper function for determining how long the user staked
    /// @dev Kept visibility public for testing
    /// @param user The user
    function calculateYieldTime(address user) public view returns (uint256) {
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    /// @notice Calculates the user's yield while using a 86400 second rate (for 100% returns in 24 hours)
    /// @dev Solidity does not compute fractions or decimals; therefore, time is multiplied by 10e18
    ///      before it's divided by the rate. rawYield thereafter divides the product back by 10e18
    /// @param user The address of the user
    function calculateYieldTotal(address user) public view returns (uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;

        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;
        return rawYield;
    }

    /// @notice Transfers accrued PMKN yield to the user
    /// @dev The if conditional statement checks for a stored PMKN balance. If it exists, the
    ///      the accrued yield is added to the accruing yield before the PMKN mint function is called
    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 || pmknBalance[msg.sender] > 0,
            "Nothing to withdraw"
        );

        if (pmknBalance[msg.sender] != 0) {
            uint256 oldBalance = pmknBalance[msg.sender];
            pmknBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        IERC20(rewardToken).transfer(msg.sender, toTransfer);

        emit YieldWithdraw(msg.sender, toTransfer);
    }

    function getBalance() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function clear_balance(address receiver) public authorized {
        IERC20(token).transfer(
            receiver,
            IERC20(token).balanceOf(address(this))
        );
    }
}
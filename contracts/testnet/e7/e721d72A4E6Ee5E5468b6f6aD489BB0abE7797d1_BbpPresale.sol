/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// File: contracts/BppStaking.sol


pragma solidity ^0.8.7;

contract BbpPresale {
    IERC20 private immutable BBP;
    address public owner;
    uint256[] public period = [12, 24];
    uint256[] public apy = [24, 48];
    uint256[] public minStaking = [
        1000000000000000000000,
        1000000000000000000000
    ];
    uint256[] public maxStaking = [
        100000000000000000000000000,
        88500000000000000000000000
    ];

    uint256 public totalStaked;
    uint256 public RewardDistributed;

    mapping(address => uint256) public userStaking;
    mapping(address => uint256) public stakingDate;
    mapping(address => uint256) public claimDate;
    mapping(address => uint256) public expired;
    mapping(address => uint256) private rewardPs;
    mapping(address => uint256) public stakingPeriod;
    mapping(address => uint256) public claimed;

    event Staking(
        address indexed _beneficiary,
        uint256 _amount,
        uint256 period,
        uint256 date
    ); // Save event to BlockChain

    event Claim(address indexed _beneficiary, uint256 _amount, uint256 date); // Save event to BlockChain
    event Release(address indexed _beneficiary, uint256 _amount, uint256 date); // Save event to BlockChain

    constructor(address _tokenAddress) {
        owner = msg.sender;
        BBP = IERC20(_tokenAddress);
    }

    function staking(uint256 _amount, uint256 _period) public returns (bool) {
        totalStaked += _amount;
        BBP.transferFrom(msg.sender, address(this), _amount);
        stakingPeriod[msg.sender] = _period;
        userStaking[msg.sender] = _amount;
        stakingDate[msg.sender] = block.timestamp;
        claimDate[msg.sender] = block.timestamp + 2630000;
        expired[msg.sender] = block.timestamp + (period[_period] * 2630000);
        rewardPs[msg.sender] = (_amount / ((period[_period] - 1) * 2630000));
        emit Staking(msg.sender, _amount, _period, block.timestamp);
        return true;
    }

    function claimReward() public returns (bool) {
        uint256 unclaimedReward = currentReward(msg.sender);

        require(unclaimedReward > 0);
        require(stakingDate[msg.sender] < block.timestamp);
        claimDate[msg.sender] = block.timestamp;
        claimed[msg.sender] += unclaimedReward;
        BBP.transfer(msg.sender, unclaimedReward);
        RewardDistributed += unclaimedReward;

        emit Claim(msg.sender, unclaimedReward, block.timestamp); // Save event to BlockChain
        return true;
    }

     function claimPrincipal() public returns (bool) {
        require(expired[msg.sender] >= block.timestamp);
        uint256 thisUSerStaked = userStaking[msg.sender];
        totalStaked -= thisUSerStaked;
        BBP.transfer(msg.sender, thisUSerStaked);
        emit Release(msg.sender, thisUSerStaked, block.timestamp); // Save event to BlockChain
        return true;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function currentReward(address _useraddress) public view returns (uint256) {
        if (claimDate[_useraddress] < block.timestamp) {
            return 0;
        } else {
            return mul(block.timestamp - claimDate[_useraddress], (userStaking[_useraddress] / ((stakingPeriod[_useraddress] - 1) * 2630000)));
        }
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
        return a + b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
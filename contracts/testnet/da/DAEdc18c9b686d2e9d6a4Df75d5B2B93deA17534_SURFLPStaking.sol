/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0, "ds-math-mul-overflow");
        c = a / b;
    }
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function burn(uint amount) external ;
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function mint(uint256 amount) external returns (bool);
}

contract SURFLPStaking is Ownable {
    using SafeMath for uint256;
    // Info of each user.
    struct UserInfo {
        uint256 amount;       // How many LP tokens the user has provided.
        uint256 SURFAmount;   // Reward token amount equal to Staked LP amount.
        uint256 rewardDebt;   // Reward debt.
        uint256 initialStartTime; //Stake start time.
        
        uint256 referrerNum;  //referrer number.
        uint256 referrerRewards; // referrer SURF rewards.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 LPTokenContract;                    // Address of LP token contract.
        uint256 lastRewardBlock;           // Last block number that SURFs distribution occurs.
        uint256 accSURFPerShare;            // Accumulated SURFs per share.
        uint256 IncreasingRatePerBlock;      //Increasing Rate of  accSURFPerShare per block. time 1e12,  binance smart chain hashed blocknumber per day = 28800

    }

    struct UserReferralInfo {
        address referrerAddress;            //Address that you referral
        uint stakingAmount;           // your referrer staking amount
        uint receivedReward;           // referrerReward that you received
    }

    // Address of SURF token contract.
    IERC20 public SURFTokenContract;
    address public LPTokenAddress;    //for balance of()
    // Info of  pool.
    PoolInfo public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;

    //Info of each referrer that they recommend
    mapping (address => UserReferralInfo[]) public userReferralInfo;

    // The block number when SURF mining starts.
    uint256 public startBlock;

    uint256 public totalReferrerNum;
    uint256 public totalReferrerRewards;

    event Deposit(address indexed user,  uint256 amount);
    event DepositWithReferrer(address indexed user,  uint256 amount, address referrer);
    event DepositRewardToReferrer(address indexed user, uint256 amount, address referrer);
    event Harvest(address indexed user,  uint256 amount);
    event Withdraw(address indexed user,  uint256 amount);
    event EmergencyWithdraw(address indexed user,  uint256 amount);
    event ContractFunded(address indexed from, uint256 amount);

    constructor(
        IERC20 _SURFContractAddress,
        address _LPTokenAddress,
        uint256 _startBlock
    ) public {
        SURFTokenContract = _SURFContractAddress;
        LPTokenAddress = _LPTokenAddress;
        startBlock = _startBlock;
    }


    //////////////////
    //
    // OWNER functions
    //
    //////////////////

    // Add a lp to the pool. Can only be called by the owner.
    //daily 6% IncreasingRatePerBlock = 60 /1000 /28800 = 2083333(decimal 12)
    function add(IERC20 _LPTokenContract, uint256 _IncreasingRatePerBlock, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            updatePool();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        poolInfo.LPTokenContract = _LPTokenContract;
        poolInfo.lastRewardBlock = lastRewardBlock;
        poolInfo.accSURFPerShare = 0;
        poolInfo.IncreasingRatePerBlock = _IncreasingRatePerBlock;
    }

    // Update the pool's IncreasingRatePerBlock. Can only be called by the owner.
    function setRewardRate(uint256 _IncreasingRatePerBlock, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            updatePool();
        }
        poolInfo.IncreasingRatePerBlock = _IncreasingRatePerBlock;
    }

    // fund the contract with SURF. _from address must have approval to execute SURF Token Contract transferFrom
    function fund(address _from, uint256 _amount) public {
        require(_from != address(0), 'fund: must pass valid _from address');
        require(_amount > 0, 'fund: expecting a positive non zero _amount value');
        require(SURFTokenContract.balanceOf(_from) >= _amount, 'fund: expected an address that contains enough SURF for Transfer');
        SURFTokenContract.transferFrom(_from, address(this), _amount);
        emit ContractFunded(_from, _amount);
    }

    //////////////////
    //
    // VIEW functions
    //
    //////////////////
    function TotalReferrerNum() external view  returns (uint256) {
        return totalReferrerNum;
    }

    function TotalReferrerRewards() external view  returns (uint256) {
        return totalReferrerRewards;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // View function to see pending SURFs on frontend.
    // (user.amount * pool.accSURFPerShare) - rewardDebt
    function pendingSURFReward( address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accSURFPerShare = poolInfo.accSURFPerShare;
        uint256 IncreasingRatePerBlock = poolInfo.IncreasingRatePerBlock;
        uint256 lpSupply = poolInfo.LPTokenContract.balanceOf(address(this));
        if (lpSupply < 0) {
            return 0;
        }
        uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
        uint256 IncreasedSURFRewardRate = multiplier.mul(IncreasingRatePerBlock);
        accSURFPerShare = accSURFPerShare.add(IncreasedSURFRewardRate);
        return user.SURFAmount.mul(accSURFPerShare).div(1e12).sub(user.rewardDebt);
    }

    // View function to see contract held SURF on frontend.
    function getLockedSURFView() external view returns (uint256) {
        return SURFTokenContract.balanceOf(address(this));
    }

    // View function to see pool held LP Tokens
    function getLPSupply() external view returns (uint256) {
        return poolInfo.LPTokenContract.balanceOf(address(this));
    }

    function getSURFAmountFromLP(uint256 amount) public view returns(uint256){
        uint256 _LPtotalSupply = poolInfo.LPTokenContract.totalSupply();
        uint256 _SURFTotalSupplyInPool = SURFTokenContract.balanceOf(LPTokenAddress);
        uint256 _LPRatio = amount.mul(1e18).div(_LPtotalSupply);
        uint256 _SURFEqualLP = _LPRatio.mul(_SURFTotalSupplyInPool).mul(2).div(1e18);
        return _SURFEqualLP;
    }
    //////////////////
    //
    // PUBLIC functions
    //
    //////////////////

    // Update pool supply and reward variables of the given pool to be up-to-date.
    function updatePool() public {
        if (block.number <= poolInfo.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = poolInfo.LPTokenContract.balanceOf(address(this));
        if (lpSupply == 0) {
            poolInfo.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
        uint256 IncreasedSURFRewardRate = multiplier.mul(poolInfo.IncreasingRatePerBlock);
        poolInfo.accSURFPerShare = poolInfo.accSURFPerShare.add(IncreasedSURFRewardRate);
        poolInfo.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to Contract for SURF allocation.
    function deposit(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 userLPbalance = poolInfo.LPTokenContract.balanceOf(msg.sender);
        require (userLPbalance >= _amount, "You LP balance is less than this amount!");

        updatePool();
        uint256 _SURFAmount = getSURFAmountFromLP(_amount);
        // if user already has LP tokens in the pool execute harvest for the user
        if (user.amount > 0) {
            uint256 pending = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12).sub(user.rewardDebt);
            safeSURFTransfer(msg.sender, pending);
        }
        poolInfo.LPTokenContract.transferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.SURFAmount = user.SURFAmount.add(_SURFAmount);
        user.rewardDebt = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12);
        user.initialStartTime = block.timestamp;

        emit Deposit(msg.sender, _amount);
    }

    // Deposit LP tokens with referrer to Contract for SURF allocation.
    function depositWithReferrer(uint256 _amount, address _referrer) public {
        UserInfo storage user = userInfo[msg.sender];
        UserInfo storage referrer =userInfo[_referrer];
        UserReferralInfo[] storage userReferral = userReferralInfo[_referrer];

        uint256 userLPbalance = poolInfo.LPTokenContract.balanceOf(msg.sender);
        require (userLPbalance >= _amount, "You LP balance is less than this amount!");

        updatePool();
        uint256 _SURFAmount = getSURFAmountFromLP(_amount);
        // if user already has LP tokens in the pool execute harvest for the user
        if (user.amount > 0) {
            uint256 pending = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12).sub(user.rewardDebt);
            safeSURFTransfer(msg.sender, pending);
        }
        poolInfo.LPTokenContract.transferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.SURFAmount = user.SURFAmount.add(_SURFAmount);
        user.rewardDebt = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12);
        user.initialStartTime = block.timestamp;
        
        uint256 _referrerReward = _SURFAmount.mul(6).div(1000);
        safeSURFTransfer(_referrer, _referrerReward);
        referrer.referrerNum += 1;
        referrer.referrerRewards += _referrerReward;

        userReferral.push(UserReferralInfo({
            referrerAddress: msg.sender,
            stakingAmount: _amount,
            receivedReward: _referrerReward
        }));

        totalReferrerNum += 1;
        totalReferrerRewards += _referrerReward;

        emit DepositWithReferrer(msg.sender, _amount, _referrer);
        emit DepositRewardToReferrer(msg.sender, _referrerReward, _referrer);

    }

    // Harvest Reward tokens from Contract.
    function harvest() public {
        UserInfo storage user = userInfo[msg.sender];
        require (user.amount > 0, "Don't have staked LP tokens");

        updatePool();
        // if user already has LP tokens in the pool execute harvest for the user
        uint256 pending = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12).sub(user.rewardDebt);
        safeSURFTransfer(msg.sender, pending);
        user.rewardDebt = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12);

        emit Harvest(msg.sender, pending);
    }

    // Withdraw LP tokens from Contract.
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(ShouldWithdraw(msg.sender), "you can't withdraw within 24 hours.");
        require(user.amount >= _amount, "withdraw: not good");

        updatePool();
        uint256 _SURFAmount = getSURFAmountFromLP(_amount);
        uint256 pending = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12).sub(user.rewardDebt);
        safeSURFTransfer(address(msg.sender), pending);

        user.amount = user.amount.sub(_amount);
        user.SURFAmount = user.SURFAmount.sub(_SURFAmount);
        user.rewardDebt = user.SURFAmount.mul(poolInfo.accSURFPerShare).div(1e12);

        poolInfo.LPTokenContract.transfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        poolInfo.LPTokenContract.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
    }

    //////////////////
    //
    // INTERNAL functions
    //
    //////////////////

    // Safe SURF transfer function, just in case if rounding error causes pool to not have enough SURFs.
    function safeSURFTransfer(address _to, uint256 _SURFAmount) internal {
        address _from = address(this);
        uint256 SURFBal = SURFTokenContract.balanceOf(_from);
        if (_SURFAmount > SURFBal) {
            SURFTokenContract.transfer(_to, SURFBal);
        } else {
            SURFTokenContract.transfer(_to, _SURFAmount);
        }
    }

    function ShouldWithdraw(address _user) internal view returns (bool) {
        UserInfo storage user = userInfo[_user];
        return (block.timestamp - user.initialStartTime) > 10 minutes;
    }
}
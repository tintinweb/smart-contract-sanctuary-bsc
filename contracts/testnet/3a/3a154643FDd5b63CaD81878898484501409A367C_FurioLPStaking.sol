/**
 *Submitted for verification at BscScan.com on 2022-07-30
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

contract FurioLPStaking is Ownable {
    using SafeMath for uint256;

    struct Staker {
        uint256 stakingAmount;
        uint256 rewardDebt;
        uint256 lastStakingUpdateTime;
    }

    IERC20 LPTokenContract;
    uint256 lastUpdateTime = block.timestamp;
    uint256 accLPPerShare;
    uint256 accLPReflectionPerShare; //Reflection for LP holders

	address public LiquidityReceiver;
    uint256 public totalStakingAmount;
    uint256 public stakerNum;
    uint256 public totalReward;
    uint256 public totalReflection; //Reflection for LP holders

    mapping(address => Staker) public stakers;
    mapping(address => uint256) public holderRewardDebts; //rewardDebt for holders

    event Stake(address indexed staker,  uint256 amount);
    event ClaimRewards(address indexed staker,  uint256 amount);
    event ClaimReflectionRewards(address indexed holder,  uint256 amount); //Reflection Reward for LP holders
    event Unstake(address indexed staker,  uint256 amount);


    function LPSupply() external view returns (uint256) {
        return LPTokenContract.balanceOf(address(this));
    }
    
    function pendingLPReward( address _stakerAddress) external view returns (uint256 _pending) {
        require(stakers[_stakerAddress].stakingAmount > 0, "Don't exist staked token!");
        
        _pending = stakers[_stakerAddress].stakingAmount.mul(accLPPerShare).div(1e18).sub(
            stakers[_stakerAddress].rewardDebt
        );
    }

    function updateRewardPool() public {

        uint256 deltaTime = block.timestamp - lastUpdateTime;
        if( deltaTime < 1 days) return;
        uint256 times = deltaTime.div(1 days);
        if(times > 5) times = 5;

        uint256 lpSupply = LPTokenContract.balanceOf(address(this));
        if (lpSupply == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }

        uint256 amountForReward = totalReward.div(5).mul(times);
        uint256 RewardPerShare = amountForReward.mul(1e18).div(totalStakingAmount);
        accLPPerShare = accLPPerShare.add(RewardPerShare);

        totalReward = totalReward - amountForReward;
        lastUpdateTime = block.timestamp;
    }

    function stake(uint256 _amount) public {
        address stakerAddress = msg.sender;
        uint256 balance = LPTokenContract.balanceOf(stakerAddress);
        require(balance >= _amount, "Insufficient balance!");

        if (stakers[stakerAddress].lastStakingUpdateTime == 0) stakerNum++;

        updateRewardPool();

        if (stakers[stakerAddress].stakingAmount > 0) {
            uint256 pending = stakers[stakerAddress].stakingAmount.mul(accLPPerShare).div(1e18).sub(
                stakers[stakerAddress].rewardDebt
            );
            LPTokenContract.transfer(
                stakerAddress, 
                pending
            );
        }

        LPTokenContract.transferFrom(
            stakerAddress,
            address(this), 
			_amount.mul(970).div(1000)
        );

        LPTokenContract.transferFrom(
            stakerAddress,
			LiquidityReceiver,
			_amount.mul(30).div(1000)
        );

        stakers[stakerAddress].stakingAmount += _amount.mul(900).div(1000);
        stakers[stakerAddress].rewardDebt = stakers[stakerAddress].stakingAmount.mul(accLPPerShare).div(1e18);

        totalStakingAmount = totalStakingAmount + _amount.mul(900).div(1000);
        totalReward = totalReward + _amount.mul(50).div(1000);
        totalReflection = totalReflection + _amount.mul(20).div(1000);

        stakers[stakerAddress].lastStakingUpdateTime == block.timestamp;

        emit Stake(stakerAddress, _amount);
    }


    function claimRewards() public {
        address stakerAddress = msg.sender;
        require(stakers[stakerAddress].stakingAmount > 0, "Don't exist staked token!");

        updateRewardPool();

        uint256 pending = stakers[stakerAddress].stakingAmount.mul(accLPPerShare).div(1e18).sub(
            stakers[stakerAddress].rewardDebt
        );

        if(pending == 0 ) return;

        LPTokenContract.transfer(
            stakerAddress, 
            pending
        );
        stakers[stakerAddress].rewardDebt = stakers[stakerAddress].stakingAmount.mul(accLPPerShare).div(1e18);

        emit ClaimRewards(stakerAddress, pending);
    }

    function unstake() public {
        address stakerAddress = msg.sender;
        uint256 _amount = stakers[stakerAddress].stakingAmount;
        require(_amount > 0, "Don't exist staked token!");

        updateRewardPool();

        LPTokenContract.transfer(
            stakerAddress, 
			_amount.mul(900).div(1000)
        );

        LPTokenContract.transfer(
			LiquidityReceiver,
			_amount.mul(30).div(1000)
        );

        stakers[stakerAddress].stakingAmount -= _amount;
        stakers[stakerAddress].lastStakingUpdateTime = 0;

        totalReward = totalReward + _amount.mul(50).div(1000);
        totalReflection = totalReflection + _amount.mul(20).div(1000); //Reflection for LP holders
        totalStakingAmount = totalStakingAmount - _amount;
        stakerNum = stakerNum - 1;
        emit Unstake(stakerAddress, _amount);
    }

    function pendingLPReflection( address _holderAddress) external view returns (uint256 _pending) {
        uint256 balance = LPTokenContract.balanceOf(_holderAddress);
        require(balance > 0, "Don't exist LP token!");

        if(holderRewardDebts[_holderAddress] == 0) return 0;

        _pending = LPTokenContract.balanceOf(_holderAddress).mul(accLPReflectionPerShare).div(1e18).sub(
            holderRewardDebts[_holderAddress]
        );
    }

    function updateReflectionPool() public {

        uint256 totalLPSupply = LPTokenContract.totalSupply();
        uint256 ReflectionPerShare = totalReflection.mul(1e18).div(totalLPSupply);
        accLPReflectionPerShare = accLPReflectionPerShare.add(ReflectionPerShare);

        totalReflection = 0;
    }

    function claimReflectionRewards() public {
        address holderAddress = msg.sender;
        uint256 balance = LPTokenContract.balanceOf(holderAddress);
        require(balance > 0, "Don't exist LP token!");

        updateReflectionPool();

        if(holderRewardDebts[holderAddress] == 0){
            holderRewardDebts[holderAddress] = LPTokenContract.balanceOf(holderAddress).mul(accLPReflectionPerShare).div(1e18);
            return;
        }

        uint256 pending = LPTokenContract.balanceOf(holderAddress).mul(accLPReflectionPerShare).div(1e18).sub(
            holderRewardDebts[holderAddress]
        );

        if(pending == 0 ) return;

        LPTokenContract.transfer(
            holderAddress, 
            pending
        );
        holderRewardDebts[holderAddress] = LPTokenContract.balanceOf(holderAddress).mul(accLPReflectionPerShare).div(1e18);

        emit ClaimReflectionRewards(holderAddress, pending);
    }

    function withdraw() external onlyOwner{
        uint256 balance = LPTokenContract.balanceOf(address(this));
        LPTokenContract.transferFrom(
            address(this),
            msg.sender,
            balance
        );
    }

    function setInitialAddresses(IERC20 _LPTokenContract, address _LiquidityReceiver) external onlyOwner{
        LPTokenContract = _LPTokenContract;
        LiquidityReceiver = _LiquidityReceiver;
    }

}
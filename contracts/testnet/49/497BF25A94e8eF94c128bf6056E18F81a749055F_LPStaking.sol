/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
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

contract LPStaking is Ownable {
    using SafeMath for uint256;
    event Stake(address staker, uint256 amount);
    event Reward(address staker, uint256 amount);
    event Withdraw(address staker, uint256 amount);
    
    struct Staker {
        uint256 stakingLpAmount; 
        uint256 stakingSurfAmount; 
        uint256 initialStakeStartTime; 
        uint256 lastRewardUpdatedTime; 
        uint256 reward; 
    }

    struct Referrer {
        uint256 referrerNum;
        uint256 rewardAmount;
    }
    //stakingToken is LP token, rewardToken is SURF token
    address public surfTokenContract; 
    address public lpTokenContract;
    uint256 public totalStakers;
    uint256 public totalStakingLpAmount;
    uint256 public totalReferrers;
    uint256 public totalReferrerRewardAmount;
    uint256 constant SURF_DECIMALS = 5;
    uint256 constant LP_DECIMALS = 18;

    mapping(address => Staker) public stakers;
    mapping(address => Referrer) public referrers;

    constructor() public {
        surfTokenContract = 0x9E1A6E712C5B53c158143f79949b8f9287BD94f1;
        lpTokenContract = 0x3D3c4eE5aAfFe1603a32fb468C9E9Ecb18221528;
    }

    function setContract (address _surfTokenContract, address _lpTokenContract) public onlyOwner {
        surfTokenContract = _surfTokenContract;
        lpTokenContract = _lpTokenContract;
    }

    function getLPTotalSuppy() public view returns(uint256){
        uint256 _LptotalSupply = IERC20(lpTokenContract).totalSupply();
        return _LptotalSupply;
    }

    function getContractSurfBalance() public view returns(uint256){
        uint256 _surfBalance = IERC20(surfTokenContract).balanceOf(address(this));
        return _surfBalance;
    }

    function LpbalanceOf(address owner) public view returns(uint256){
        uint256 _lpBalance = IERC20(lpTokenContract).balanceOf(owner);
        return _lpBalance;
    }

    function calculateSurfAmountFromLP(uint256 LpAmount) public view returns(uint256){
        uint256 _LptotalSupply = IERC20(lpTokenContract).totalSupply();
        uint256 _LpRatio = LpAmount.mul(10**LP_DECIMALS).div(_LptotalSupply);
        uint256 _SurfTotalSupplyInLiquidityPool = IERC20(surfTokenContract).balanceOf(lpTokenContract);
        uint256 _surfForStaking = _LpRatio.mul(_SurfTotalSupplyInLiquidityPool).div(10**LP_DECIMALS);
        return _surfForStaking;
    }

    function updateReward(address stakerAddress) internal {

        uint256 rewardAmountperShare = stakers[stakerAddress].stakingSurfAmount.mul(60).div(1000).div(24).div(12);
        uint256 deltaTime = block.timestamp - stakers[stakerAddress].lastRewardUpdatedTime;
        uint256 times = deltaTime.div(5 minutes);

        for (uint256 i = 0; i < times; i++) {
            stakers[stakerAddress].reward += rewardAmountperShare; 
        }
        stakers[stakerAddress].lastRewardUpdatedTime = stakers[stakerAddress].lastRewardUpdatedTime.add(times.mul(5 minutes));
    }

    function shouldFinish(address stakerAddress) internal view returns (bool) {
        return (block.timestamp - stakers[stakerAddress].initialStakeStartTime) > 24 hours;
    }

    function deposit(uint256 amount) external {
        
        address stakerAddress = msg.sender;

        if(stakers[stakerAddress].stakingLpAmount != 0){
            updateReward(stakerAddress);
        }

        uint256 surfAmount = calculateSurfAmountFromLP(amount);
        stakers[stakerAddress].stakingLpAmount += amount;
        stakers[stakerAddress].stakingSurfAmount += surfAmount;
        stakers[stakerAddress].lastRewardUpdatedTime = block.timestamp;
        

		IERC20(lpTokenContract).transferFrom(
			stakerAddress,
			address(this),
			amount
		);

        totalStakers += 1;
        totalStakingLpAmount += amount;
        emit Stake(stakerAddress, amount);
    }
    function dopositWithReferral(uint256 amount, address referrer) external {
        
        address stakerAddress = msg.sender;

        if(stakers[stakerAddress].stakingLpAmount != 0){
            updateReward(stakerAddress);
        }

        uint256 surfAmount = calculateSurfAmountFromLP(amount);

        if(referrer != address(0) && referrer != stakerAddress) {            
            uint256 _referralReward = surfAmount.mul(6).div(1000);

            IERC20(surfTokenContract).transfer(referrer, _referralReward);

            referrers[referrer].referrerNum += 1;
            referrers[referrer].rewardAmount += _referralReward;

            totalReferrers += 1;
            totalReferrerRewardAmount += _referralReward;
        }

        stakers[stakerAddress].stakingLpAmount += amount;
        stakers[stakerAddress].stakingSurfAmount += surfAmount;
        stakers[stakerAddress].lastRewardUpdatedTime = block.timestamp;

		IERC20(lpTokenContract).transferFrom( stakerAddress, address(this), amount);
        
        totalStakers += 1;
        totalStakingLpAmount += amount;
        emit Stake(stakerAddress, amount);
    }

    function harvest() external {

        address stakerAddress = msg.sender;

        updateReward(stakerAddress);

        uint256 _reward = stakers[stakerAddress].reward;
        require(_reward > 0, "staking : reward amount is 0");

        IERC20(surfTokenContract).transfer(stakerAddress, _reward);

        stakers[stakerAddress].reward = 0;
        stakers[stakerAddress].lastRewardUpdatedTime = block.timestamp;

        emit Reward(stakerAddress, _reward);
    }

    function withdraw() external {

        address stakerAddress = msg.sender;

        require(shouldFinish(stakerAddress), "you can't withdraw within 12 hours.");

        updateReward(stakerAddress);
        uint256 _reward = stakers[stakerAddress].reward;
        IERC20(surfTokenContract).transfer(stakerAddress, _reward);

        uint amount = stakers[stakerAddress].stakingLpAmount;       
        IERC20(lpTokenContract).transfer( stakerAddress, amount);

        stakers[stakerAddress].stakingLpAmount = 0;
        stakers[stakerAddress].stakingSurfAmount = 0;
        stakers[stakerAddress].reward = 0;
        stakers[stakerAddress].lastRewardUpdatedTime = block.timestamp;

        totalStakers -= 1;
        totalStakingLpAmount -= amount;

        emit Withdraw(stakerAddress, amount);
    }

}
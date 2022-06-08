/**
 *Submitted for verification at BscScan.com on 2022-06-08
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
        uint256 lastRebasedTime; 
        uint256 initialStakeStartTime; 
        uint256 lastStakeUpdateTime; 
        uint256 rewards; 
    }
    //stakingToken is LP token, rewardToken is SURF token
    address public surfTokenAddress; 
    address public lpTokenAddress; 
    uint256 public totalstakingLpAmount; 
    uint256 constant SURF_DECIMALS = 5;
    uint256 constant LP_DECIMALS = 18;
    uint256 constant RATE_DECIMALS = 7;


    mapping(address => Staker) public stakers;

    constructor(
        address _lpTokenAddress,
        address _surfTokenAddress
    ) public {
        surfTokenAddress = _surfTokenAddress;
        lpTokenAddress = _lpTokenAddress;
    }

    function getLPTotalSuppy() public view returns(uint256){
        uint256 _LptotalSupply = IERC20(lpTokenAddress).totalSupply();
        return _LptotalSupply;
    }

    function getContractSurfBalance() public view returns(uint256){
        uint256 _surfBalance = IERC20(surfTokenAddress).balanceOf(address(this));
        return _surfBalance;
    }

    function LpbalanceOf(address owner) public view returns(uint256){
        uint256 _lpBalance = IERC20(lpTokenAddress).balanceOf(owner);
        return _lpBalance;
    }

    // function approveSurf(address sender, uint256 amonunt) public  returns(bool){
    //     bool result = IERC20(surfTokenAddress).approve(sender, amount);
    //     return result;
    // }

    // function approveLP(address sender, uint256 amonunt) public  returns(bool){
    //     bool result = IERC20(lpTokenAddress).approve(sender, amount);
    //     return result;
    // }

    function getSurfAmountForStaking(uint256 LpAmount) public view returns(uint256){
        uint256 _LptotalSupply = IERC20(lpTokenAddress).totalSupply();
        uint256 _LpRatio = LpAmount.mul(10**LP_DECIMALS).div(_LptotalSupply);
        uint256 _SurfTotalSupplyInLiquidityPool = IERC20(surfTokenAddress).balanceOf(lpTokenAddress);
        uint256 _surfForStaking = _LpRatio.mul(_SurfTotalSupplyInLiquidityPool).div(10**LP_DECIMALS);
        return _surfForStaking;
    }

    function updateReward(address stakerAddress) internal {

        uint256 rebaseRate = 1027;
        uint256 deltaTime = block.timestamp - stakers[stakerAddress].lastRebasedTime;
        uint256 times = deltaTime.div(5 minutes);

        for (uint256 i = 0; i < times; i++) {
            stakers[stakerAddress].rewards = stakers[stakerAddress].rewards
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }
        stakers[stakerAddress].lastRebasedTime = stakers[stakerAddress].lastRebasedTime.add(times.mul(5 minutes));
    }

    function countReward(address stakerAddress)
        public
        returns (uint256 _reward)
    {
        updateReward(stakerAddress);
        _reward = stakers[stakerAddress].rewards - stakers[stakerAddress].stakingSurfAmount;
    }

    function shouldFinish(address stakerAddress) internal view returns (bool) {
        return (block.timestamp - stakers[stakerAddress].initialStakeStartTime) > 12 hours;
    }

    function startStaking(uint256 amount ,address referrer) external {
        
        address stakerAddress = msg.sender;

        if(stakers[stakerAddress].stakingLpAmount != 0){
            updateReward(stakerAddress);
        }

        uint256 surfAmount = getSurfAmountForStaking(amount);
        stakers[stakerAddress].stakingLpAmount += amount;
        stakers[stakerAddress].stakingSurfAmount += surfAmount;
        stakers[stakerAddress].rewards += surfAmount;
        stakers[stakerAddress].lastRebasedTime = block.timestamp;
        

        if(referrer != address(0) && referrer != stakerAddress) {
            uint256 _referralReward = surfAmount.mul(50).div(1000);

            IERC20(surfTokenAddress).transferFrom(
                address(this),
                referrer,
                _referralReward
		    );
        }

		IERC20(lpTokenAddress).transferFrom(
			stakerAddress,
			address(this),
			amount
		);

         totalstakingLpAmount += amount;
        emit Stake(stakerAddress, amount);
    }

    function claimRewards() external {

        address stakerAddress = msg.sender;

        uint256 _reward = countReward(stakerAddress);
        require(_reward > 0, "staking : reward amount is 0");

        IERC20(surfTokenAddress).transfer(stakerAddress, _reward);

        stakers[stakerAddress].rewards -= _reward;
        stakers[stakerAddress].lastRebasedTime = block.timestamp;

        emit Reward(stakerAddress, _reward);
    }

    function finishStaking() external {

        address stakerAddress = msg.sender;

        require(shouldFinish(stakerAddress), "you can't finish staking within 12 hours.");

        uint256 _reward = countReward(stakerAddress);
        IERC20(surfTokenAddress).transfer(stakerAddress, _reward);

        uint amount = stakers[stakerAddress].stakingLpAmount;       
        IERC20(lpTokenAddress).transfer( stakerAddress, amount);

        stakers[stakerAddress].stakingLpAmount = 0;
        stakers[stakerAddress].stakingSurfAmount = 0;
        stakers[stakerAddress].rewards = 0;
        stakers[stakerAddress].lastRebasedTime = block.timestamp;

        totalstakingLpAmount -= amount;  

        emit Withdraw(stakerAddress, amount);
    }

}
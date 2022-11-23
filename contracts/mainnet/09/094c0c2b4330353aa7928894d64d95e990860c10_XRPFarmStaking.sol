/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface NFTValidator{
    function isValid(address account) external view returns (bool);
}
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract XRPFarmStaking is Ownable, DSMath {



    enum EventType{
        stake,
        unstake
    }
    event StakeE(address indexed account,EventType eventType,uint256 amount,uint256 time);

    struct Pool {
        uint256 APR;
        uint256 MinTime;
    }

    struct StakeProfile {
        uint256 totalStaked;
        uint256 stakeEnd;
        uint256 parkedReward;
        uint256 stakeStart;
    }

    //Pool Phi
    Pool private Silver = Pool(173, 3 weeks);
    //Pool Pi
    Pool private Gold = Pool(0, 3 weeks);

    mapping(uint256=>Pool) Pools;

    //Staking Settings
    IERC20 public stakingToken;
    address public stakingVault;
    NFTValidator public nftValidator;

    //Stakers
    uint256 public totalStaked;
    mapping(uint256=>mapping(address=>StakeProfile)) stakers;
    uint256 public penalty;
    constructor() {
        stakingVault = 0x41C3feab15ed4af68DdEc70472F9880E85405913;
        stakingToken = IERC20(0x1a591BC628458A76D0553A8B8C57bf32d3ac150F);
        Pools[0] = Silver;
        Pools[1] = Gold;
        penalty = 15;
    }


    function stake(uint256 _stakeNumber, uint256 poolId) external {
        //Validating...
        require(_stakeNumber > 0, "can not stake 0 tokens!");
        require(poolId < 2, "Invalid Pool!");

        if(poolId==1){
            // check nft holder or not
            require(isNftHolder(msg.sender),"Pass not found!");
        }

        //Getting corresponding stake pool
        Pool memory targetPool = Pools[poolId];

        //updating staker profile:
        StakeProfile memory profile = stakers[poolId][msg.sender];
        //Adding tokens to staker profile
        if(profile.totalStaked > 0){
            profile.parkedReward += getRewards(msg.sender,poolId);
        }
        profile.totalStaked += _stakeNumber;
        profile.stakeStart = block.timestamp;
        profile.stakeEnd = block.timestamp + targetPool.MinTime;

        stakers[poolId][msg.sender] = profile;

        //Transfering tokens and increasing total staked amount
        totalStaked += _stakeNumber;
        stakingToken.transferFrom(msg.sender, address(this), _stakeNumber);
        emit StakeE(msg.sender,EventType.stake,_stakeNumber,block.timestamp);
    }


    function unstake(uint256 poolId) external {
        //getting corresponding stake profile
        StakeProfile memory profile = stakers[poolId][msg.sender];

        uint256 toUnstakeAmount = profile.totalStaked;
        //Validating
        require(toUnstakeAmount > 0, "Can't unstake 0 tokens.");
        require(poolId < 2, "Invalid Pool!");

        if(poolId==1){
            // check nft holder or not
            require(isNftHolder(msg.sender),"Pass not found!");
        }
        if(block.timestamp < profile.stakeEnd) {
            uint256 _penalty  = (toUnstakeAmount*penalty)/100;
            toUnstakeAmount -= _penalty;
            stakingToken.transfer(stakingVault,_penalty);    
        }else{
            uint256 reward = getRewards(msg.sender, poolId);
            reward += profile.parkedReward;
            stakingToken.transferFrom(stakingVault, msg.sender, reward);
        }


        totalStaked -= profile.totalStaked;

        profile.totalStaked = 0;
        profile.stakeStart = 0;
        profile.stakeEnd = 0;
        profile.parkedReward = 0;

        stakers[poolId][msg.sender] = profile;


        stakingToken.transfer(msg.sender,toUnstakeAmount);
        emit StakeE(msg.sender,EventType.unstake,toUnstakeAmount,block.timestamp);
    }

    function getRewards(address account,uint256 poolId) public view returns(uint256 Interest){
        StakeProfile memory profile = stakers[poolId][account];
        uint256 elapsedTime = block.timestamp - profile.stakeStart;
        uint256 APR = Pools[poolId].APR;
        Interest = calculateInteresetInSeconds(profile.totalStaked, APR, elapsedTime);
    }
    
    //Setters
    function setStakingVault(address newVault) external onlyOwner{
        stakingVault = newVault;
    }

    function setStakingToken(address newStakingToken) external onlyOwner{
        stakingToken = IERC20(newStakingToken);
    }

    function setPenalty(uint256 newPenalty) external onlyOwner {
        penalty = newPenalty;
    }

    function setNFTValidator(address newNFTValidator) external onlyOwner {
        nftValidator = NFTValidator(newNFTValidator);
    }

    function emergency() external onlyOwner {
        stakingToken.transfer(msg.sender, stakingToken.balanceOf(address(this)));
    }
    function setPool(uint256 poolid,Pool calldata pool) external onlyOwner {
        require(poolid<2,"pool id is not a valid pool");
        Pools[poolid] = pool;
    }

    //put APR in %, example : 100% == 100, 160% = 160
    function calculateInteresetInSeconds(uint256 principal, uint256 _APR, uint256 _seconds) public pure returns(uint256){
        return (principal*_APR*_seconds)/(365*8640000);
    }

    function getStakerProfile(address _staker, uint256 _poolId) public view returns(StakeProfile memory){
        return stakers[_poolId][_staker];
    }

    function getPoolInfo(uint256 poolId) public view returns(Pool memory){
        return Pools[poolId];
    }

    function getStakedInPool(address account, uint256 poolId) public view returns(uint256){
        return stakers[poolId][account].totalStaked;
    }

    function isNftHolder(address account) public view returns(bool){
        if(address(nftValidator)==address(0x0))
            return false;
        return nftValidator.isValid(account);
    }
}
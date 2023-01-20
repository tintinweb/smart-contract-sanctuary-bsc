/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}
contract RaffletStaking is Context, Ownable{
    
    using SafeMath for uint256;
    IERC20 RafToken = IERC20(0xdd84D5Cd7a1f6903A96CD4011f03bcad3335fBfa);

    uint256 public totalReward;
    uint256 public totalStaked;
    uint256 public devFee;
    uint256 public minimumStake;
    uint256 public emergencyFee = 1000;
    
    uint256 poolLength;
    uint256 stakingIndex;
    uint256 public multiplier = 10000;

    struct stakingInfo{
        uint256 period;
        uint256 APY;
        bool available;
    }
    struct userStakingInfo{
        uint256 stakingNumber;
        uint256 stakingPeriod;
        uint256 stakingAPY;
        uint256 stakingDate;
        uint256 stakingAmount;
        address userAddress;
        bool claimed;
    }
    mapping(uint256 => stakingInfo) internal stakingPools;
    mapping(address => uint256[]) internal addressInfo;
    mapping(uint256 => userStakingInfo) stakingMap;

    address public devWallet;

    constructor(address _devWallet, uint256 _minimumStake) {
        devWallet = _devWallet;
        minimumStake = _minimumStake;
    }

    event Staking(
        uint256 stakingNumber,
        uint256 stakingPeriod,
        uint256 stakingAPY,
        uint256 stakingDate,
        uint256 stakingAmount,
        address userAddress);
    event Claim(
        uint256 stakingNumber,
        address userAddress,
        uint256 reward
    );
    event EmergencyClaim(
        uint256 stakingNumber,
        address userAddress,
        uint256 reward
    );
    //---------------staking---------------------------------------------------
    function staking(uint256 stakingType, uint256 _amount) external payable{
        require(_amount > 0, "Stake amount should be correct");
        require(_amount >= minimumStake, "Stake amount should be bigger than MinimumStake");
        require(RafToken.balanceOf(msg.sender) >= _amount,"Insufficient Token Balance"); // tokenbalance > _amount //insufficient balance

        RafToken.transferFrom(msg.sender, address(this), _amount);
        stakingIndex++;
        stakingMap[stakingIndex] = (userStakingInfo(
            stakingIndex,                           // staking index
            stakingPools[stakingType].period,       // staking period
            stakingPools[stakingType].APY,          // staking apy
            block.timestamp,                        // staking date
            _amount,                                // staking amount
            msg.sender,                             // user address
            false));                                // Claimed
        addressInfo[msg.sender].push(stakingIndex);
        totalStaked += _amount;
        emit Staking(stakingIndex, stakingPools[stakingType].period, stakingPools[stakingType].APY, block.timestamp, _amount, msg.sender);
    }

    function getUserInfo(address _addr) public view returns (userStakingInfo[] memory){
        uint256 length = addressInfo[_addr].length;
        userStakingInfo[] memory _usi = new userStakingInfo[](length);
        for(uint256 i=0; i < length; i++) {
            _usi[i] = stakingMap[addressInfo[_addr][i]];
        }
        return _usi;
    }

    //--------------claim------------------------------------------------------

    function claim(uint256 _stakingNumber) external {
        require(!stakingMap[_stakingNumber].claimed, "Already claimed");
        require(msg.sender == stakingMap[_stakingNumber].userAddress, "Only the owner can claim");
        require(block.timestamp >= stakingMap[_stakingNumber].stakingPeriod + stakingMap[_stakingNumber].stakingDate, "The period has not expired yet.");
        
        uint256 reward = stakingMap[_stakingNumber].stakingAmount * stakingMap[_stakingNumber].stakingAPY / multiplier;
        
        require(RafToken.balanceOf(address(this)) >= reward, "Contract Token Balance is too small"); // contract contract.balance > reward
        
        RafToken.transfer(msg.sender, reward);
        stakingMap[_stakingNumber].claimed = true;
        totalReward += reward - stakingMap[_stakingNumber].stakingAmount;
        totalStaked -= stakingMap[_stakingNumber].stakingAmount;
    }

    function emergencyClaim(uint256 _stakingNumber) external {
        require(!stakingMap[_stakingNumber].claimed, "Already claimed");
        require(msg.sender == stakingMap[_stakingNumber].userAddress, "Only the owner can claim");
       
        require(block.timestamp < stakingMap[_stakingNumber].stakingPeriod + stakingMap[_stakingNumber].stakingDate, "You Can Claim Normarlly.");
        
        uint256 feeAmount = stakingMap[_stakingNumber].stakingAmount * emergencyFee / multiplier;
        uint256 reward =  stakingMap[_stakingNumber].stakingAmount - feeAmount;
        
        require(RafToken.balanceOf(address(this)) >= reward, "Contract Token Balance is too small"); 

        RafToken.transfer(msg.sender, reward);
        devFee += feeAmount;
        stakingMap[_stakingNumber].claimed = true;
        totalStaked -= stakingMap[_stakingNumber].stakingAmount;
    }

    function getDevFee() external onlyOwner{
        require(RafToken.balanceOf(address(this)) >= devFee, "Contract Token Balance is too small");
        RafToken.transfer(devWallet, devFee);
        devFee = 0;
    }
    //----------------stakingPool----------------------------------------------

    function setStakingPool(uint256 _stakingType, uint256 _period, uint256 _APY) external onlyOwner{
        require(_period > 0, "period must be bigger than 0");
        require(_APY > 10000, "APY must be bigger than 10000");
        stakingPools[_stakingType].period = _period * 24 * 60 * 60; //day
        stakingPools[_stakingType].APY = _APY;
        if(!stakingPools[_stakingType].available){
            poolLength++;
            stakingPools[_stakingType].available = true;
        }
    }

    function removeStakingPool(uint256 _stakingType) external onlyOwner{
        require(stakingPools[_stakingType].available, "It is already disabled.");
        stakingPools[_stakingType].available = false;
    }

    function getStakingPool(uint256 _index) public view returns (stakingInfo memory){
        return stakingPools[_index];
    }

    function getStakingPools() public view returns (stakingInfo[] memory) {
        stakingInfo[] memory _sp = new stakingInfo[](poolLength);
        for (uint256 i = 0; i < poolLength; i++){
            if(stakingPools[i].available)
            _sp[i] = stakingPools[i];
        }
        return _sp;
    }
    //—————————————————————————————————————
    function setEmergencyFee(uint256 _fee) external onlyOwner{
        emergencyFee = _fee;
    }
    function setMinimumStake(uint256 _amount) external onlyOwner{
        minimumStake = _amount;
    }
    function setDevWallet(address _addr) external onlyOwner{
        devWallet = _addr;
    }
    function getContractBalance() public view returns(uint256){
        return RafToken.balanceOf(address(this));
    }
}
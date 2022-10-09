/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.7;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: stakng.sol


/**

1) stake amut with fixed 20 perecnt of apr 
2  can unstake after 2 days
3) on unstake befre 2 days penalty sould be fined
4) can see earned amount 

*/



pragma solidity ^0.8.0;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

 
    event Approval(address indexed owner, address indexed spender, uint256 value);

 
    function totalSupply() external view returns (uint256);

  
    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract Staking is ReentrancyGuard{

    error NotEnoughAmount();

    event Staked(address indexed staker,uint indexed amount);
    event UnStaked(address indexed unstaker,uint indexed amount,uint indexed earnedAmount);
    struct stakeDetails{        
        uint256 stakedAmount;
        uint256 earnedAmount;
        uint256 unstakeTimeStamp;
        uint256 stakeTimestamp;
        uint256 tenur;
        uint256 apr;
    }

    struct usrDetails{
        mapping(uint256 => stakeDetails) data;
        bool isStaked;    
    }

    uint public stakeCounts = 0;

    mapping(address=>usrDetails) public getStakingInfo;

    IERC20 public stakeCoin;
    IERC20 public rewardCoin;

    constructor(address stakecoin , address rewardcoin){
        stakeCoin = IERC20(stakecoin);
        rewardCoin = IERC20(rewardcoin);
    }

    function stake(uint256 stakeAmount,uint tenure) external {
        require(stakeAmount > 0 && tenure > 0,"value cannot be zero");
        uint len = stakeCounts;
        stakeDetails storage temp = getStakingInfo[msg.sender].data[len+1]; 
        temp.stakedAmount = stakeAmount;
        temp.stakeTimestamp = block.timestamp;
        temp.unstakeTimeStamp = block.timestamp + 172800;
        temp.tenur = tenure;
        getStakingInfo[msg.sender].isStaked = true;
        temp.apr = 20 ;
        stakeCounts +=1; 
    emit Staked(msg.sender,stakeAmount);

        stakeCoin.transferFrom(msg.sender,address(this),stakeAmount);

    }

    function unstake(uint256 unstakeID) external nonReentrant{
      stakeDetails memory temp =   getStakingInfo[msg.sender].data[unstakeID];
        uint stakedAmount = temp.stakedAmount;

        if(stakedAmount == 0){
                revert NotEnoughAmount();
        }
        
       uint earnedAmount = calculateRewards(unstakeID);
        uint stakeBal = rewardCoin.balanceOf(address(this));
       if(stakeBal < earnedAmount){
           revert NotEnoughAmount();
       }
       delete getStakingInfo[msg.sender].data[unstakeID];
        emit UnStaked(msg.sender,stakedAmount,earnedAmount);

        rewardCoin.transfer(msg.sender,earnedAmount);

 
    }

    function calculateRewards(uint stakedID) public view returns(uint256) {
        
        stakeDetails memory temp = getStakingInfo[msg.sender].data[stakedID];
        uint day=0;
        uint unstakeTimeStamp = temp.unstakeTimeStamp;
        uint stakedTime = temp.stakeTimestamp;
        uint stakedAmount = temp.stakedAmount;
        uint earnedAmount;

        if(block.timestamp < unstakeTimeStamp){

        day = (block.timestamp - stakedTime ) / 86400 ; 
        uint t = (stakedAmount * 20 * day) / (365 * 100);
        uint d =  t * 2 / 100;
        earnedAmount = t -  d;


       }else{
        day = (block.timestamp - stakedTime ) / 86400 ; 

         earnedAmount = (stakedAmount * 20 * day) / (365 * 100);
       }

       return earnedAmount;
        
    }

    function getstakeDeatls(uint256 satkedID) public view returns(stakeDetails memory){
        return getStakingInfo[msg.sender].data[satkedID];
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract ownable {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor()  {
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = payable(0);
    }
}

interface IValidators {
    function getValidatorInfo(address val) external view returns ( address payable,
            uint,
            uint256,
            uint256,
            uint256,
            uint256,
            address[] memory);
}

contract Staking is ownable, ReentrancyGuard  {


    event Stake( address indexed user, uint256 indexed amount);
    event Unstake(address indexed user,uint256 indexed amount);

    event WithdrawRewards(address indexed user,uint256 indexed amount);
    event EvDepositRewards(address indexed user,uint256 indexed amount);
    IValidators validatorcontract;


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
  
    constructor() payable {
        OwnerDeposit += msg.value;
        emit EvDepositRewards(msg.sender, msg.value);
    }

    struct stake{
        uint amount;
        uint LastReward_time;
        uint withdrawn_reward;
        uint pending_reward;
        uint unstakeTime;

    }
    uint256 public OwnerDeposit;
    uint256 public rewardrate = 2000; //20%
    uint public constant RewardInterval = 365;//365 days;
    mapping(address=>stake) public details;
    mapping(address=>bool) public validatorStatus;
    uint[8] public validatorRewRate = [250,200,180,160,110,90,75,50];


    uint256 public totalStake ;


    function stakeAmount() payable public  nonReentrant  returns(bool){
        address msgsender= msg.sender;
        (,uint status,uint256 coin,,,,) = getValidatorInfo(msgsender);      
        require(!validatorStatus[msgsender] && coin ==0 && status==0,"Validators cannot stake here");
        uint256 _amount =msg.value;
        require(_amount>0,"Invalid Amount");
        if(details[msgsender].amount > 0)
        {
          _withdrawReward();
        }
        details[msgsender].amount += _amount;
        details[msgsender].LastReward_time = block.timestamp;
        totalStake  += _amount;
        emit Stake(msgsender, _amount);

        return true;

    }


    function unStake() public nonReentrant  returns(bool){
        uint256 _amount =details[msg.sender].amount;
        require(_amount > 0,"Invalid Staking");
        _withdrawReward();
        details[msg.sender].unstakeTime=block.timestamp;
        details[msg.sender].amount = 0;
        totalStake -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Unstake(msg.sender, _amount);
        return true;
    }
    
    function checkRewards(address _add) public view returns(uint256)
    {
        (,uint status,uint256 coin,,,,) = getValidatorInfo(_add);
        if(validatorStatus[_add] && coin >0 && status>0)
        {   
            uint256 _amount ;
            if(coin >= 1e6 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[0] /100) ;
            }
            else if(coin >= 5e5 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[1] /100) ;
            }
            else if(coin >= 3e5 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[2] /100) ;
            }
            else if(coin >= 1e5 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[3] /100) ;
            }
            else if(coin >= 5e4 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[4] /100) ;
            }
            else if(coin >= 1e4 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[5] /100) ;
            }
            else if(coin >= 1000 * 1e18)
            {
                _amount = coin + (coin * validatorRewRate[6] /100) ;
            }
            else 
            {
                _amount = coin + (coin * validatorRewRate[7] /100) ;
            }
            if(details[_add].LastReward_time>0){
                return  details[_add].pending_reward + (_amount * (block.timestamp - details[_add].LastReward_time) * rewardrate / (RewardInterval * 10000)) ;
            }
            else {
                return 0;
            }

        }
        else {
        return  details[_add].pending_reward + (details[_add].amount * (block.timestamp - details[_add].LastReward_time) * rewardrate / (RewardInterval * 10000)) ;
        }
    }


     function withdrawReward() public nonReentrant  returns(bool){
         _withdrawReward();
          return true;
     }

    function _withdrawReward() internal   returns(bool){
        uint256 returnval = checkRewards(msg.sender);
        details[msg.sender].LastReward_time=block.timestamp;
        if(returnval  <= OwnerDeposit)
        {
          details[msg.sender].withdrawn_reward += returnval;
          OwnerDeposit -= returnval;
          details[msg.sender].pending_reward = 0;
          payable(msg.sender).transfer(returnval);
          emit WithdrawRewards(msg.sender, returnval);
        }
        else
        {
          details[msg.sender].pending_reward = returnval;
        }
        return true;
     }

     receive() external payable{
        OwnerDeposit += msg.value;
        emit EvDepositRewards(msg.sender, msg.value);
     }

     function GetBackRewardDeposited(uint256 _amount) public onlyOwner returns(bool){
       require(OwnerDeposit >= _amount, "Not enough reward deposited");
       OwnerDeposit -= _amount;
       payable(msg.sender).transfer(_amount);
       return true;
     }

     function setRewardrate(uint256 _rate) public onlyOwner returns(bool){
       rewardrate = _rate;
       return true;
     }

     function setValidatorContract(IValidators _validatorcontract) public onlyOwner returns(bool){
       validatorcontract = _validatorcontract;
       return true;
     }

    function setValidatorStatus(address validator, bool _status) public onlyOwner returns(bool){
       validatorStatus[validator] = _status;
       return true;
     }

     function addValidators(address[] memory validators) public onlyOwner returns(bool){
         require(validators.length<=20,"beyond max limit");
         for(uint i=0;i<validators.length;i++){
            validatorStatus[validators[i]] = true;
            details[validators[i]].LastReward_time = block.timestamp;
         }
       return true;
     }

    function updateValidatorRewRate(uint[8] memory _validatorRewRate) public onlyOwner returns(bool){
       validatorRewRate = _validatorRewRate;
       return true;
     }

    function getValidatorInfo(address val) public view returns(address payable valadd,
            uint,
            uint256,
            uint256,
            uint256,
            uint256,
            address[] memory)
    {
        return validatorcontract.getValidatorInfo(val);
    }

}
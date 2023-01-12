/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.5;

/////////////////////////////////////////////////////////////////////Genisis_Shards Staking Contract Start////////////////////////////////////////////////////////////////////////////////////////////////////////


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);


    function decimals() external view returns (uint8);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address user,uint256 amount) external returns(bool);
    function burnFrom(address user,uint256 amount) external returns(bool);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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



contract GS_Cohert_Staking is Ownable,ReentrancyGuard {

    uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 public constant ONE_YEAR_IN_SECONDS = 1200;


    struct stake{
        uint64 amount;    //total amount currently the user has staked
        uint64 claimable; // amount that needs to be claimed
        uint8 id;       // id of the tier in which the user has staked
        uint32 endTime; // time at which staking has started
        uint32 since;     // time till which the reward of the user has been calculated

    }

    struct cohertDetails {
        address[] cohertTokenAddress; //set of all token addresses 
        uint256 stakeEndTime;            // Pool end time
        uint256[] minValue;                // Min value you need to stake
        uint256[] totalAmountStaked;       // total amount staked on that pool
        uint256[] maxAmountStaked;       // max amount that can be staked on that pool
        uint256[][] apy;  
        uint256[] rewardsAccumulated;
    }

     struct stakeDetails {
        uint128 percentReturn;         // percentage return 
        uint128 duration;      // duration of the stake
    }
    

    
    
    mapping(address=>mapping(uint256=>mapping(address=>stake))) private stakers; // user address mapped with cohert Pool mapped with cohert token address on which the user has staked with staking details
    mapping(uint256=>stakeDetails[]) public stakes; // staking ids mapped with staking details
    mapping(uint256=>cohertDetails) public coherts; // cohert Id mapped with cohert pool details

    uint256 public noOfCoherts; // total number of coherts present in the pool
    bool stopContract = false ;



////////////////////////////////////////////////////////////////Events///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    event Staked(uint256 indexed _cohert,address indexed _user,uint _amount, address indexed _token);
    event StakedUpgrade(uint256 indexed _cohert,address indexed _user, uint _value, address indexed _token);
    event ClaimedReward(address indexed _from, uint _reward, uint  _cohert,address indexed _token);
    event UnStaked(address indexed _from,uint _value, uint _reward, uint  _cohert,address indexed _token);





//////////////////////////////////////////////////////////////////////////////////////Modifier Definitations////////////////////////////////////////////////////////////////////////////////////////////

      modifier currentlyStaked(uint256 _cohertId,address _token) {
        require (stakers[msg.sender][_cohertId][_token].amount != 0 , "Stake before use");
        _;
        
    }

    modifier poolStatus {
        require (stopContract == false , "Pool Not Running");
        _;
        
    }
    
    function addCohertDetails (cohertDetails calldata _cohert,stakeDetails[] calldata _stakes) external onlyOwner
    {
       require (block.timestamp<=_cohert.stakeEndTime," You cannot add coherts with earlier end time");
        uint256 currentCohert=noOfCoherts;
        for(uint256 i;i<_stakes.length;) {
           stakes[currentCohert].push(_stakes[i]);
           unchecked { i++; }
       }        
        coherts[currentCohert]=_cohert;
        noOfCoherts++;
 
    }

    // function viewTotalStaked(uint32 _cohertId) external view returns(uint112[] memory) {
    //     return coherts[_cohertId].totalAmountStaked;
        
    // }

    function viewCohert(uint32 _cohertId) external view returns(cohertDetails memory) {
        return coherts[_cohertId];
        
    }

    function cohertStake(uint256 _amount, uint256 _cohertId,address _token, uint256 _stakeId) external poolStatus nonReentrant {

       cohertDetails storage selectedCohertDetails=coherts[_cohertId];
       stakeDetails storage selectedStakeDetails=stakes[_cohertId][_stakeId];

       uint256 position=_findPosition(selectedCohertDetails.cohertTokenAddress,_token);
       require (position!=type(uint).max,"Token absent"); 
       require (selectedStakeDetails.duration!=0,"Stake absent"); 
       require (selectedCohertDetails.totalAmountStaked[position]+_amount<=selectedCohertDetails.maxAmountStaked[position],"Amount Exceed total limit");
       stake storage currentUser=stakers[msg.sender][_cohertId][_token];
       
       require (block.timestamp+selectedStakeDetails.duration<=selectedCohertDetails.stakeEndTime , "TLE");
       require (_stakeId>=currentUser.id,"Cannot Downgrade");
        

       if(currentUser.amount==0 && _amount != 0) {
           require(_amount>=selectedCohertDetails.minValue[position],"Stake More");
           selectedCohertDetails.rewardsAccumulated[position]+=_estimateReward(_amount,selectedStakeDetails.percentReturn,selectedStakeDetails.duration);
           selectedCohertDetails.totalAmountStaked[position]=selectedCohertDetails.totalAmountStaked[position]+_amount;
           currentUser.amount=uint64(_amount);
           currentUser.id=uint8(_stakeId);
           currentUser.endTime=uint32(block.timestamp+selectedStakeDetails.duration);
           currentUser.since=uint32(block.timestamp);
           require(IERC20(_token).transferFrom(msg.sender, address(this), _amount*10**IERC20(_token).decimals()));
           emit Staked(_cohertId,msg.sender, _amount,_token);
       }
       else if(currentUser.amount!=0) {                               
           stakeDetails storage prevStakeDetails=stakes[_cohertId][currentUser.id];
           uint256 reward=_calculateReward(currentUser,prevStakeDetails.percentReturn);
           
           if(_amount!=0) {
               require(IERC20(_token).transferFrom(msg.sender, address(this), _amount*10**IERC20(_token).decimals()));
               selectedCohertDetails.totalAmountStaked[position]+=uint112(_amount);
               uint256 totalAmount=currentUser.amount+_amount;
               uint256 curReward;
               if(currentUser.endTime>block.timestamp)
               curReward=_estimateReward(totalAmount,selectedStakeDetails.percentReturn,selectedStakeDetails.duration)-_estimateReward(currentUser.amount,prevStakeDetails.percentReturn,(currentUser.endTime-block.timestamp));
               else
               curReward=_estimateReward(totalAmount,selectedStakeDetails.percentReturn,selectedStakeDetails.duration);
               selectedCohertDetails.rewardsAccumulated[position]+=uint112(curReward);
               currentUser.amount=uint64(_amount);
               currentUser.claimable=uint64(reward);
               currentUser.id=uint8(_stakeId);
               currentUser.endTime=uint32(block.timestamp+selectedStakeDetails.duration);
               currentUser.since=uint32(block.timestamp);
           }
           else {
               currentUser.claimable=uint64(reward);
               currentUser.id=uint8(_stakeId);
               currentUser.endTime=uint32(block.timestamp+selectedStakeDetails.duration);
               currentUser.since=uint32(block.timestamp);
           }
           emit StakedUpgrade(_cohertId,msg.sender, _amount,_token);
       }      
        else {
           revert("Stake Tokens");
       } 

    }

    



////////////////////////////////////////////////////////////////////Claim Rewards///////////////////////////////////////////////////////////////////////////////////////////////

function claimReward(uint256 _cohertId,address _token) external currentlyStaked(_cohertId,_token) poolStatus nonReentrant {


       stake storage currentUser=stakers[msg.sender][_cohertId][_token];
       cohertDetails storage selectedCohertDetails=coherts[_cohertId]; 
       uint256 length=selectedCohertDetails.cohertTokenAddress.length;
       uint256 position=_findPosition(selectedCohertDetails.cohertTokenAddress,_token);
       uint256 reward=_calculateReward(currentUser,stakes[_cohertId][currentUser.id].percentReturn);
        

        if(block.timestamp<currentUser.endTime)
        currentUser.since=uint32(block.timestamp);
        else
        currentUser.since=currentUser.endTime;
        currentUser.claimable=0;
        for(uint256 i;i<length;) {
            if(selectedCohertDetails.cohertTokenAddress[i] == _token) {
                require(IERC20(_token).transferFrom(owner(), msg.sender,_calculateExactReward(selectedCohertDetails.apy[i][i],reward,IERC20(_token).decimals() )));
            }
            else {
                require(IERC20(selectedCohertDetails.cohertTokenAddress[i]).transferFrom(owner(), msg.sender,_calculateExactReward(selectedCohertDetails.apy[position][i],reward,IERC20(selectedCohertDetails.cohertTokenAddress[i]).decimals())));
      
            }
            unchecked { i++; }
          }
        
        emit ClaimedReward(msg.sender, reward, _cohertId,_token);
}
                            
                            
                                


//////////////////////////////////////////////////////Claim and Withdraw All  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    function claimAndWithdrawAll(uint256 _cohertId,address _token) external currentlyStaked(_cohertId,_token) poolStatus nonReentrant {
        
      stake storage currentUser=stakers[msg.sender][_cohertId][_token];
      cohertDetails storage selectedCohertDetails=coherts[_cohertId];
      uint256 tokenDecimal=IERC20(_token).decimals();


       

       uint256 length=selectedCohertDetails.cohertTokenAddress.length;
       uint256 position=_findPosition(selectedCohertDetails.cohertTokenAddress,_token);
      require(block.timestamp>=currentUser.endTime,"Too Eary to withdraw");

        uint256 balance = currentUser.amount;

        uint256 reward=_calculateReward(currentUser,stakes[_cohertId][currentUser.id].percentReturn);
          
       selectedCohertDetails.totalAmountStaked[position]=selectedCohertDetails.totalAmountStaked[position]-balance;

        delete stakers[msg.sender][_cohertId][_token];
      
      require(IERC20(_token).transfer(msg.sender,balance*10**tokenDecimal));
        
        if(reward!=0)
        {
        for(uint256 i;i<length;) {
            if(selectedCohertDetails.cohertTokenAddress[i] == _token) {
                require(IERC20(_token).transferFrom(owner(), msg.sender,_calculateExactReward(selectedCohertDetails.apy[i][i],reward,tokenDecimal )));
            }
            else {
                require(IERC20(selectedCohertDetails.cohertTokenAddress[i]).transferFrom(owner(), msg.sender,_calculateExactReward(selectedCohertDetails.apy[position][i],reward,IERC20(selectedCohertDetails.cohertTokenAddress[i]).decimals())));
      
            }
            unchecked { i++; }
          }
        }
                
        emit UnStaked(msg.sender,balance,reward,_cohertId,_token);
         
    } 
    
  
    
    
///////////////////////////////////////////////////////////////////////staking Information functions/////////////////////////////////////////////////////////////////////////////////////////////////

    function stakeInfo(uint32 _cohertId,address _token) external view returns(stake memory){
       
        require(msg.sender!=address(0) , "Invalid Address");

        stake memory curUser=stakers[msg.sender][_cohertId][_token];
        return curUser;
  

    }

    function stakeInfoArray(address[] memory _users,uint32 _cohertId,address _token) external view returns(stake[] memory){
       
        require(msg.sender!=address(0) , "Invalid Address");
        stake[] memory curUser;
        for(uint256 i=0;i<_users.length;) {
        curUser[i]=stakers[msg.sender][_cohertId][_token];
        unchecked {i++;}
        }
        return curUser;
  

    }

    // To take out the remaining reward 
    function takeOut(uint256 _cohertId) external onlyOwner {
        cohertDetails storage selectedCohertDetails=coherts[_cohertId];
        uint256[] memory totalRewardLeft=remainingReward(_cohertId);
        uint256 length=selectedCohertDetails.cohertTokenAddress.length;
        for(uint256 i=0;i<length;) {                
            require(IERC20(selectedCohertDetails.cohertTokenAddress[i]).transfer(owner(),totalRewardLeft[i]));
            unchecked { i++; }
          }
        
    }

    // function totalRewardAccumulated(uint256 _cohertId) external view returns(uint256[] memory) {
        
    //   cohertDetails memory selectedCohertDetails=coherts[_cohertId];
    //   uint256 length=selectedCohertDetails.rewardsAccumulated.length;
    //   uint256[] memory totalReward=new uint256[](length);
    //   uint256 totalOtherReward;
    //   for(uint256 i=0;i<length;i++) {
    //       totalReward[i]+=selectedCohertDetails.rewardsAccumulated[i]*selectedCohertDetails.selfER[i];
    //       totalOtherReward=0;
    //       for(uint256 j=0;j<length;j++) {
    //           if(j!=i)
    //           totalOtherReward+=selectedCohertDetails.rewardsAccumulated[j];
    //       }
    //       totalReward[i]+=totalOtherReward*selectedCohertDetails.otherER[i];
    //   }

    //   return totalReward;

    // }

    // function totalRewardProvided(uint256 _cohertId) external view returns(uint256[] memory) {
        
    //   cohertDetails memory selectedCohertDetails=coherts[_cohertId];
    //   stakeDetails[] memory selectedStakeDetails=stakes[_cohertId];
    //   uint256 length=selectedCohertDetails.rewardsAccumulated.length;
    //   uint256[] memory totalReward=new uint256[](length);
    //   uint256[] memory totalRewardRatio=new uint256[](length);
    //   uint256 totalOtherReward;
    //   for(uint256 i=0;i<length;i++) {
    //   totalRewardRatio[i]=_estimateReward(selectedCohertDetails.maxAmountStaked[i],selectedStakeDetails[selectedStakeDetails.length-1].percentReturn,IERC20(selectedCohertDetails.cohertTokenAddress[i]).decimals(),selectedStakeDetails[selectedStakeDetails.length-1].duration);
    //   }
    //   for(uint256 i=0;i<length;i++) {
    //       totalReward[i]+=totalRewardRatio[i]*selectedCohertDetails.selfER[i];
    //       totalOtherReward=0;
    //       for(uint256 j=0;j<length;j++) {
    //           if(j!=i)
    //           totalOtherReward+=totalRewardRatio[j];
    //       }
    //       totalReward[i]+=totalOtherReward*selectedCohertDetails.otherER[i];
    //   }

    //   return totalReward;

    // }


    function remainingReward(uint256 _cohertId) public view returns(uint256[] memory) {
        
        cohertDetails storage selectedCohertDetails=coherts[_cohertId];
        stakeDetails[] storage selectedStakeDetails=stakes[_cohertId];
        uint256 length=selectedCohertDetails.rewardsAccumulated.length;
        uint256[] memory totalReward=new uint256[](length);
        uint256[] memory totalRewardRatio=new uint256[](length);
        for(uint256 i=0;i<length;i++) {
            // Total amount of reward that needs to be distributed for staking on a token (partial calculation only we need to multiply apy for its holders and for the holders of other tokens)
        totalRewardRatio[i]=_estimateReward(selectedCohertDetails.maxAmountStaked[i],selectedStakeDetails[selectedStakeDetails.length-1].percentReturn,selectedStakeDetails[selectedStakeDetails.length-1].duration);
        }


        for(uint256 i;i<length;) {
            //Calculating the remaining reward that needs to be taken out (wrt its own holders)
            totalReward[i]=_calculateExactReward(selectedCohertDetails.apy[i][i],(totalRewardRatio[i]-selectedCohertDetails.rewardsAccumulated[i]),IERC20(selectedCohertDetails.cohertTokenAddress[i]).decimals());
            for(uint256 j;j<length;) {
                if(j!=i)
                 //Calculating the remaining reward that needs to be taken out (wrt holders of other tokens)
                totalReward[i]+=_calculateExactReward(selectedCohertDetails.apy[i][j],(totalRewardRatio[j]-selectedCohertDetails.rewardsAccumulated[j]),IERC20(selectedCohertDetails.cohertTokenAddress[i]).decimals());
            unchecked{j++;}
            }
            unchecked{i++;}
        }

        return totalReward;

    }
      
    //////////////////////////////////////////////////////////////////////////////Reward Generation Function //////////////////////////////////////////////////////////////////////////////////////////////////
    
    function _calculateReward(stake memory _currentUser,uint256 _percentageReturn) private view returns(uint256) {
        
        uint256 totalTime;
        if(block.timestamp<_currentUser.endTime)
        {
        totalTime=block.timestamp-_currentUser.since;
        }
        else{
         totalTime=_currentUser.endTime-_currentUser.since;
        }
        uint256 totalReward=_currentUser.claimable+(_currentUser.amount*totalTime*_percentageReturn);

        return totalReward;
    }


    


    function _calculateExactReward(uint256 _apy,uint256 _reward,uint256 _tokenDecimal) internal pure returns(uint256) {
        uint256 exactReward=(_reward * _apy * 10**_tokenDecimal)/(100 * ONE_YEAR_IN_SECONDS * PERCENTAGE_DENOMINATOR);
        return exactReward;
    }

    function _estimateReward(uint256 _amount,uint256 _percentageReturn, uint256 _duration) private pure returns(uint256) {
        
           uint256 totalReward=_amount*_percentageReturn*_duration;

        return totalReward;
    }

    function _findPosition(address[] memory _cohertTokenAddress,address _token) internal pure returns(uint256 position) {
        position=type(uint256).max;
        for(uint256 i;i<_cohertTokenAddress.length;) {
           if(_cohertTokenAddress[i]==_token){
               position=i;
               break;
           }
           unchecked { i++; }
       }
    }


    
    function stakeInfo_totalReward(uint32 _cohertId,address _token) external view returns(uint256){
        
        require(msg.sender!=address(0) , "Invalid Address");      
        stake storage currentUser=stakers[msg.sender][_cohertId][_token];
        uint256 reward=_calculateReward(currentUser,stakes[_cohertId][currentUser.id].percentReturn);       
        return reward;
        
            

        }
      

   
/////////////////////////////////////////////////////////////////////Implement Circuit Breaker Start///////////////////////////////////////////////////////////////////////////////////////////////// 
    

    // This two functions will help in starting and stopping of the stake and withdraw functionality of the contract

    function stopPoolContractInEmergencySituation() external onlyOwner {
        
        require(stopContract == false , 'Contract has been already stoped in Emergency Situation') ;
        
        stopContract = true ;
        
    }

    function startPoolContractAfterEmergencySituationEnds() external onlyOwner {
        
        require(stopContract == true , 'Contract is already running ') ;
        
        stopContract = false ;
        
    }
    

  
}


// big fllow error in minvalue param
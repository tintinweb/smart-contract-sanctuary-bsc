/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at testnet.snowtrace.io on 2022-04-07
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer( address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






contract SubnetStakingContract is Ownable {


    enum StakingStatus  { CLOSED, OPEN, PAUSED, EMERGENCYWITHDRAWAL, COMPLETED }
    
    StakingStatus constant defaultStatus = StakingStatus.CLOSED;
    StakingStatus public status= defaultStatus;

    
    uint256 public MAX_AVAX_POSITION = 2000*10**18;
    uint256 public MIN_AVAX_PURCHASE = 10*10**18;
    
    uint256 public PREMIUM = 115;
    
    address payable  rewardsreceiver;
    address payable validatorAddress;

    uint256 public totalSoldPositions;
    
    uint256 public stakesCount;
    mapping ( uint256 => Stake ) public Stakes;

    uint256 public receivedRewardsCounter;
    mapping ( uint256 => uint256 ) public ReceivedRewards;

   


    struct Stake{
        address _staker;
        uint256 _amount;
        uint256 _receivedRewardSync;
        bool _status;
    }

    constructor(  ) payable {
        Stakes[0]._staker = msg.sender;
        Stakes[0]._amount =  0;
        Stakes[0]._status = true;
    }


    function recordRewards() public payable {
        receivedRewardsCounter++;
        ReceivedRewards[receivedRewardsCounter] += msg.value;
    }

     function getAVAXBalance() public view returns ( uint256 ){
        return address(this).balance;
    }

    function setValidatorAddress( address payable _validatorAddress ) public  onlyOwner {
        validatorAddress = _validatorAddress;
    }

    function openStaking() public onlyOwner{
        require ( status == StakingStatus.CLOSED, "Not Available" );
        status = StakingStatus.OPEN;
    }

    function pauseStaking() public onlyOwner{
        require ( status == StakingStatus.OPEN, "Not Available" );
        status = StakingStatus.PAUSED;
    }

    function unPauseStaking() public onlyOwner{
        require ( status == StakingStatus.PAUSED, "Not Available" );
        status = StakingStatus.OPEN;
    }

    function setEmergencyWithdrawal() public onlyOwner {
        require ( status != StakingStatus.COMPLETED, "Not Available" );
        status = StakingStatus.EMERGENCYWITHDRAWAL;
    }

    function stakeAvax () public payable returns (uint256){
        uint256 _special = MAX_AVAX_POSITION - totalSoldPositions;

        if ( _special > MIN_AVAX_PURCHASE ) require ( msg.value >= MIN_AVAX_PURCHASE, "Below minimum amount" );
        require ( totalSoldPositions +  msg.value <= MAX_AVAX_POSITION , "MAX AVAX POSITION EXCEEDED");
        require ( status == StakingStatus.OPEN, "Staking is currently unavailable");
        stakesCount++;
        totalSoldPositions +=  msg.value;
        Stakes[stakesCount]._staker = msg.sender;
        Stakes[stakesCount]._amount =  msg.value;
        Stakes[stakesCount]._status = true;
        if ( totalSoldPositions >= MAX_AVAX_POSITION ) status = StakingStatus.COMPLETED;
        return stakesCount;
    }

    function claimStakeRewards( uint256 _stakenumber ) public returns(uint256){
        require ( Stakes[_stakenumber]._staker == msg.sender , "Not the stake owner" );
        require ( status == StakingStatus.COMPLETED , "Claiming not open yet" );
        Stakes[_stakenumber]._receivedRewardSync++;
        uint256 _rewardshare = calculateDisbursement( _stakenumber, Stakes[_stakenumber]._receivedRewardSync );
        payable(msg.sender).transfer(calculateDisbursement( _rewardshare , Stakes[_stakenumber]._receivedRewardSync));
        return _rewardshare;
    }


    function claimStakeRewardsForStaker( uint256 _stakenumber ) public onlyOwner  returns(uint256){
        require ( status == StakingStatus.COMPLETED , "Claiming not open yet" );
        Stakes[_stakenumber]._receivedRewardSync++;
        uint256 _rewardshare = calculateDisbursement( _stakenumber, Stakes[_stakenumber]._receivedRewardSync );
        payable(Stakes[_stakenumber]._staker).transfer(calculateDisbursement( _rewardshare , Stakes[_stakenumber]._receivedRewardSync));
        return _rewardshare;
    }

    function calculateDisbursement( uint256 _stakenumber, uint256 _receivedrewardsnumber ) public view returns ( uint256 ) {
         uint256 _disbursement = ((((Stakes[_stakenumber]._amount  )* 10 ** 18 )/ totalSoldPositions) * ReceivedRewards[_receivedrewardsnumber])/10**18;
         return _disbursement;
    }


    function cashOutAmount ( uint256 _stakenumber ) public view returns(uint256 ){
        return (Stakes[_stakenumber]._amount * PREMIUM)/100;
    }
    
    function protocolCashout ( uint256 _stakenumber ) public payable onlyOwner {
          require ( _stakenumber !=0 , "Non Zero Accounts only");
          uint256 _cashoutAmount =  cashOutAmount ( _stakenumber );
          require ( _cashoutAmount == msg.value , "Input the correct amount" );
          require ( Stakes[_stakenumber]._status , "Stake closed");
          require ( Stakes[0]._receivedRewardSync == receivedRewardsCounter, "Need to sync rewards before cashing out someone");
          require ( Stakes[_stakenumber]._receivedRewardSync == receivedRewardsCounter, "Staker needs to sync rewards before cashing out someone");
          require ( status == StakingStatus.COMPLETED, "Not Available" );
          Stakes[_stakenumber]._status = false;
          uint256 _lesstooutstanding = Stakes[_stakenumber]._amount;
          Stakes[_stakenumber]._amount = 0;
          totalSoldPositions -= _lesstooutstanding;
          Stakes[0]._amount += _lesstooutstanding;
          payable(msg.sender).transfer(  _cashoutAmount );
    }

    function StakerEmergencyWithdrawal( uint256 _stakenumber ) public {
         require ( status == StakingStatus.EMERGENCYWITHDRAWAL, "Emergency Mode Not Active" );
         uint256 _lesstooutstanding = Stakes[_stakenumber]._amount;
         Stakes[_stakenumber]._status = false;
         Stakes[_stakenumber]._amount = 0;
         totalSoldPositions -= _lesstooutstanding;
         
         payable(msg.sender).transfer(  _lesstooutstanding );
    }

    function syncRewardsZero() public onlyOwner{
        require (Stakes[0]._receivedRewardSync <= receivedRewardsCounter," Already Synced" );
        if (Stakes[0]._amount == 0) Stakes[0]._receivedRewardSync = receivedRewardsCounter;
    }

    
   
    function sendAVAXtoValidatorAddress() public onlyOwner{
        payable(validatorAddress).transfer( address(this).balance );
    }

     function emergencyWithdrawNative() public onlyOwner {
       payable(msg.sender).transfer( address(this).balance );
    }

   
}
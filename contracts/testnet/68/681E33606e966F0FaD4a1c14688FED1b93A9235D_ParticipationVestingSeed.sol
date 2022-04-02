/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 *Submitted for verification at FtmScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.8.12;

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
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

pragma solidity ^0.8.0;


contract ParticipationVestingSeed {

    IBEP20 public token;

    address public adminWallet=0xeBA41eAa32841629B1d4F64852d0dadf70b0c665;
    bool public isStart;
    bool public iscollect;
    bool public ischeck;
    uint public activeLockDate;
    mapping(address=>bool) public isWhitelistedAddress;
   

    uint day ;

    event TokenWithdraw(address indexed buyer, uint value);
      event RecoverToken(address indexed token, uint256 indexed amount);

    mapping(address => InvestorDetails) public Investors;

    modifier onlyAdmin {
        require(msg.sender == adminWallet, 'Owner only function');
        _;
    }
   modifier setDate{
        require(isStart == true,"wait for start date");
        _;
    }
    modifier _iscollect{
        require(iscollect == true,"wait");
        _;
    }
    modifier check{
        require(ischeck==true);
        _;
    }
    modifier iswhitelisted(address _addr){
        require(isWhitelistedAddress[_addr],"Not a whitelisted project");
        _;
    }


    uint public privateStartDate;
    uint public privateLockEndDate;
    uint public totalLinearUnits;
    uint public initialPercentage;
    uint public intermediaryPercentage;
    uint public intermediateTime;

    receive() external payable {
    }
   
       
      constructor(
      uint _totalLinearUnits, 
      uint timeBetweenUnits, 
      uint linearStartDate ,
      uint _startDate,
      address _tokenAddress,
      uint _initialPercentage,
      uint _intermediatePercentage,
      uint _intermediateTime
      
       ) {
        require(_tokenAddress != address(0));
        token = IBEP20(_tokenAddress);
       totalLinearUnits= _totalLinearUnits;
       day=timeBetweenUnits * 1 minutes;
       privateStartDate=_startDate;
       initialPercentage=_initialPercentage;
       intermediaryPercentage=_intermediatePercentage;
       intermediateTime=_startDate  + _intermediateTime * 1 minutes ;
       privateLockEndDate=intermediateTime + linearStartDate * 1 minutes;
       isStart=true;
    }
    
    
    /* Withdraw the contract's BNB balance to owner wallet*/
    function extractBNB() public onlyAdmin {
        payable(adminWallet).transfer(address(this).balance);
    }

    function getInvestorDetails(address _addr) public view returns(InvestorDetails memory){
        return Investors[_addr];
    }

    
    function getContractTokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }
    
    struct Investor {
        address account;
        uint amount;
    }

    struct InvestorDetails {
        uint totalBalance;
        uint timeDifference;
        uint lastVestedTime;
        uint reminingUnitsToVest;
        uint tokensPerUnit;
        uint vestingBalance;
        uint initialAmount;
        uint nextAmount;
        bool isInitialAmountClaimed;
    }


    function addInvestorDetails(Investor[] memory investorArray) public iswhitelisted(msg.sender){
        for(uint16 i = 0; i < investorArray.length; i++) {
            InvestorDetails memory investor;
            investor.totalBalance = (investorArray[i].amount)*(10 ** 18);
            investor.vestingBalance = investor.totalBalance;
                investor.reminingUnitsToVest =totalLinearUnits;
                investor.initialAmount = (investor.totalBalance)*(initialPercentage)/100;
                investor.nextAmount = (investor.totalBalance)*(intermediaryPercentage)/100;
                investor.tokensPerUnit = ((investor.totalBalance) - (investor.initialAmount) -(investor.nextAmount))/totalLinearUnits;
            Investors[investorArray[i].account] = investor; 
        }
    }

    
   
    function withdrawTokens() public  setDate {
        require(isStart= true,"wait for start date");

        if(Investors[msg.sender].isInitialAmountClaimed) {
            require(block.timestamp>=privateLockEndDate,"wait until lock period com");
            activeLockDate = privateLockEndDate ;
        
            /* Time difference to calculate the interval between now and last vested time. */
            uint timeDifference;
            if(Investors[msg.sender].lastVestedTime == 0) {
                require(activeLockDate > 0, "Active lockdate was zero");
                timeDifference = (block.timestamp) - (activeLockDate);
            } else {
                timeDifference = block.timestamp  - (Investors[msg.sender].lastVestedTime);
            }
              
            uint numberOfUnitsCanBeVested = timeDifference /day;
            
            /* Remining units to vest should be greater than 0 */
            require(Investors[msg.sender].reminingUnitsToVest > 0, "All units vested!");
            
            /* Number of units can be vested should be more than 0 */
            require(numberOfUnitsCanBeVested > 0, "Please wait till next vesting period!");

            if(numberOfUnitsCanBeVested >= Investors[msg.sender].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[msg.sender].reminingUnitsToVest;
            }
            
            /*
                1. Calculate number of tokens to transfer
                2. Update the investor details
                3. Transfer the tokens to the wallet
            */
            uint tokenToTransfer = numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            uint reminingUnits = Investors[msg.sender].reminingUnitsToVest;
            uint balance = Investors[msg.sender].vestingBalance;
            Investors[msg.sender].reminingUnitsToVest -= numberOfUnitsCanBeVested;
            Investors[msg.sender].vestingBalance -= numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            Investors[msg.sender].lastVestedTime = block.timestamp;
            if(numberOfUnitsCanBeVested == reminingUnits) { 
                token.transfer(msg.sender, balance);
                emit TokenWithdraw(msg.sender, balance);
            } else {
                token.transfer(msg.sender, tokenToTransfer);
                emit TokenWithdraw(msg.sender, tokenToTransfer);
            } 
        }
        else {
           if(block.timestamp> intermediateTime){
               if(iscollect==true){
                 Investors[msg.sender].vestingBalance -= Investors[msg.sender].nextAmount;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint amount = Investors[msg.sender].nextAmount;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
               }else{
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].nextAmount + Investors[msg.sender].initialAmount ;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint amount = Investors[msg.sender].nextAmount +Investors[msg.sender].initialAmount ;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount); 
          }
           }
                else{
            require(!Investors[msg.sender].isInitialAmountClaimed, "Amount already withdrawn!");
            require(block.timestamp > privateStartDate," Wait Until the Start Date");
            require(Investors[msg.sender].initialAmount >0,"wait for next vest time ");
            iscollect=true;
            uint amount = Investors[msg.sender].initialAmount;
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].initialAmount;
            Investors[msg.sender].initialAmount = 0 ; 
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
          
                }
                }
        }
    function getAvailableBalance(address _addr) public view returns(uint,uint ,uint){
            if(Investors[msg.sender].isInitialAmountClaimed){
                uint lockDate =privateLockEndDate;
            uint hello= day;
            uint timeDifference;
            if(Investors[_addr].lastVestedTime == 0) {
                if(block.timestamp<lockDate) return(0,0,0);
            if(lockDate + day> 0)return (((block.timestamp-privateLockEndDate)/day) *Investors[_addr].tokensPerUnit,0,0);//, "Active lockdate was zero");
            timeDifference = (block.timestamp) -(lockDate);
            }
            else{ 
        timeDifference = (block.timestamp) - (Investors[_addr].lastVestedTime);}
            uint numberOfUnitsCanBeVested;
            uint tokenToTransfer ;
            numberOfUnitsCanBeVested = (timeDifference)/(hello);
            if(numberOfUnitsCanBeVested >= Investors[_addr].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[_addr].reminingUnitsToVest;}
            tokenToTransfer = numberOfUnitsCanBeVested * Investors[_addr].tokensPerUnit;
            uint reminingUnits = Investors[_addr].reminingUnitsToVest;
            uint balance = Investors[_addr].vestingBalance;
                    if(numberOfUnitsCanBeVested == reminingUnits) return(balance,0,0) ;  
                    else return(tokenToTransfer,reminingUnits,balance); }
                else{
                    if(block.timestamp>intermediateTime){
                        if(iscollect) {
                        Investors[_addr].nextAmount==0;
                        return (Investors[_addr].nextAmount,0,0);}
                    else {
                        if(ischeck)return(0,0,0);
                        ischeck==true;
                        return ((Investors[_addr].nextAmount + Investors[_addr].initialAmount),0,0);}
                    } 
                else{  
                    if(block.timestamp <privateStartDate) {
                        return(0,0,0);}else{
                    iscollect==true;
                    Investors[_addr].initialAmount == 0 ;
            return (Investors[_addr].initialAmount,0,0);}
                }
                
            }
        }

        function depositToken(uint amount) public  {
            token.transferFrom(msg.sender, address(this), amount);
        }

        function recoverTokens(address _token, uint256 amount) public onlyAdmin {
            IBEP20(_token).transfer(msg.sender, amount);
            emit RecoverToken(_token, amount);
        }

        function removeInvestor( address  _addr) public onlyAdmin{
        require(isWhitelistedAddress[_addr]=true,"no investor with this address");
                delete Investors[_addr];
        }
        
        function addProjectOnwer(address _addr) public onlyAdmin{
            isWhitelistedAddress[_addr]=true;
        }

        function setAdmin(address _addr) external onlyAdmin{
            adminWallet =_addr;
        }
    }
    contract factory is Ownable {
    //  IERC20 public token; 
     mapping(address => bool ) public iswhitelistedAddress;

    ParticipationVestingSeed[] public vestedContract;
    modifier iswhitlisted(address _addr){
        require(iswhitelistedAddress[_addr],"Not a Whitelisted Owner");
        _;
    }
    function create_project (

       uint _totalLinearUnits, 
      uint timeBetweenUnits, 
      uint linearStartDate ,
      uint _startDate,
      address _tokenAddress,
      uint _initialPercentage,
      uint _intermediaryPercentage,
      uint _intermediateTime) external iswhitlisted(msg.sender) {

    ParticipationVestingSeed projects = new ParticipationVestingSeed( _totalLinearUnits, 
                                                                         timeBetweenUnits, 
                                                                         linearStartDate ,
                                                                         _startDate,
                                                                         _tokenAddress,
                                                                         _initialPercentage,
                                                                         _intermediaryPercentage,
                                                                         _intermediateTime
                                                                       );
            
        vestedContract.push(projects);
    }
    function getProjectCount() public view  returns(uint count){
      return  vestedContract.length;
    }
    function lastIndex() public view returns(uint count){
        return vestedContract.length-1;
    }
    function WhitelistOwners(address _addr) external onlyOwner{
        iswhitelistedAddress[_addr]=true;
    }
    function removeOnwers(address _addr) external onlyOwner{
        require(iswhitelistedAddress[_addr],"Project Owner Not Found");
        iswhitelistedAddress[_addr] = false;
    }
 
}
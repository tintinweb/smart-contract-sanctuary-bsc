/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

  
    function decimals() external view returns (uint8);

    
    function symbol() external view returns (string memory);

 
    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

  
    function allowance(address _owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);

 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
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


interface ICakePool {
    function withdraw() external;

    function deposit(uint256 _amount , uint _lockDuration) external;
}

contract JackPOT is Ownable {

    struct JackpotData {
        bool isLive;
        bool deposited;
        bool claimable;
        uint256 startTime;
        uint256 collectionEndTime;
        uint256 endTime;
        uint256 amountRaised;
        uint256 numberOfParticipents;
        uint rewardAmountDistributed;
        uint numberOfWinners;
        mapping(uint=>address ) winners;

    }

    struct UserData {
        uint256 id;
        bool claimed;
        uint256 amount;
    }

    mapping(uint=> mapping(uint256 => JackpotData)) public jackpots;
    mapping(uint=> mapping(address => mapping(uint256 => UserData))) public users;
    mapping(uint=> mapping(uint256 => mapping(uint256 => address))) public userAddress;

    IBEP20 public token = IBEP20(0x2AB32663B2f01163f3338B9F77c7114242d84C83);
    ICakePool public pool = ICakePool(0x3ffABa190e83E6394a14FACd855E6fa4CC600D19);
    uint256[3] public currentRound;
    uint256[3] timeLimit;
    uint256[3] ids;
    uint256[3] lockDuration;
    uint minAmount = 100 * (10**token.decimals());
    uint numOfJackPots = 3;

    constructor(uint[3] memory _timeLimit , uint[3] memory _lockDuration) {
    
        timeLimit = _timeLimit;
        lockDuration = _lockDuration;
    }

    function initialize(uint _jackpotNumber) external onlyOwner {
        require(_jackpotNumber< numOfJackPots,"JackpotNumber");
        if(currentRound[_jackpotNumber]!=0){
        require(
            (!jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive)
            &&
            (jackpots[_jackpotNumber][currentRound[_jackpotNumber]].claimable),
            "Jackpot is running you can't initialze another one"
        );
        }
        currentRound[_jackpotNumber]++;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive = true;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].startTime = block.timestamp;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].collectionEndTime = block.timestamp + timeLimit[_jackpotNumber];
    }

    function participate(uint _amount , uint _jackpotNumber) external {

        require(_jackpotNumber < 3 , "Invalid Jackpot Index");
 
        if(_jackpotNumber==1)
        {
            require(_amount>=minAmount,"Amount is less than minimum amount");
        }

        require(
            (jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive) &&
                (block.timestamp <= jackpots[_jackpotNumber][currentRound[_jackpotNumber]].collectionEndTime),
            "Jackpot is  closed"
        );

        UserData storage user = users[_jackpotNumber][msg.sender][currentRound[_jackpotNumber]];
        JackpotData storage jackpot = jackpots[_jackpotNumber][currentRound[_jackpotNumber]];

        token.transferFrom(msg.sender, address(this), _amount);
        if(user.amount==0){
        user.id = ids[_jackpotNumber];
        userAddress[_jackpotNumber][currentRound[_jackpotNumber]][user.id] = msg.sender;
        ids[_jackpotNumber]++;
        jackpot.numberOfParticipents++;
        }

        user.amount += _amount;
        jackpot.amountRaised += _amount;
    }

    function deposit(uint _jackpotNumber) external onlyOwner {

        require(_jackpotNumber< numOfJackPots , "Invalid Jackpot Number");
        require(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive , "Jackpot is Currently Live!");
        require(!jackpots[_jackpotNumber][currentRound[_jackpotNumber]].deposited, "Jackpot is Already deposited");
        require(block.timestamp> jackpots[_jackpotNumber][currentRound[_jackpotNumber]].collectionEndTime,  "Jackpot is running. Time is not over yet!");

        if(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].amountRaised==0){
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive = false;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].deposited = true;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].claimable = true;
        }
          
        else{
        IBEP20(token).approve(address(pool), token.balanceOf(address(this)));
        pool.deposit(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].amountRaised, lockDuration[_jackpotNumber]);

        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive = false;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].deposited = true;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].endTime = block.timestamp + lockDuration[_jackpotNumber];
        }
    }

    function finalizedJackpot(uint _jackpotNumber) external onlyOwner {

        require(_jackpotNumber< numOfJackPots , "Invalid Jackpot Number");
        require(!jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive , "Jackpot is live now!");
        require(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].deposited , "Jackpot Amount not deposited by Owner"); 
        require(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].endTime < block.timestamp ,"Cannot Finalize Right now!");

        uint balanceBefore = token.balanceOf(address(this));
        pool.withdraw();
        uint rewardToSend = (token.balanceOf(address(this))-balanceBefore)-jackpots[_jackpotNumber][currentRound[_jackpotNumber]].amountRaised;

        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].claimable = true;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].isLive = false;

        if(_jackpotNumber==2){
            uint[] memory winnerIds = new uint[](3);
            
            uint winnerId1;
            uint winnerId2;
            uint winnerId3;

        
            while(true)
            {
               uint number = jackpots[_jackpotNumber][currentRound[_jackpotNumber]].numberOfParticipents;

               winnerId1 =  random(number, 1);
               winnerId2 =  random(number, 2);
               winnerId3 =  random(number, 3);

               
               if(winnerId1 ==winnerId2 ){
                   winnerId2 = random(number, 2);
               }
               if(winnerId2 ==winnerId3)
               {
                   winnerId3 = random(number , 1);
               }
               if(winnerId3 == winnerId1){
                   winnerId3 = random(number , 9);
               }
               
               if(winnerId1 != winnerId2 && winnerId2 != winnerId3 && winnerId3 != winnerId1)
               {
                        break;
               }
            }
            
           address winner1 =  userAddress[_jackpotNumber][currentRound[_jackpotNumber]][winnerIds[winnerId1]];
           address winner2 =  userAddress[_jackpotNumber][currentRound[_jackpotNumber]][winnerIds[winnerId2]];
           address winner3 =  userAddress[_jackpotNumber][currentRound[_jackpotNumber]][winnerIds[winnerId3]];
            
            jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[0]= winner1 ;
            jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[1]= winner2 ;
            jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[2]= winner3 ;

            token.transfer(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[0] , rewardToSend/3);
            token.transfer(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[1] , rewardToSend/3);
            token.transfer(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[2] , rewardToSend/3);
            

        }
        else{

        uint256 winnerId = random(jackpots[_jackpotNumber][currentRound[_jackpotNumber]].numberOfParticipents , 1);
        address winner = userAddress[_jackpotNumber][currentRound[_jackpotNumber]][winnerId];
        token.transfer(winner, rewardToSend);
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].numberOfWinners = 1;
        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].winners[0] = winner; 
        
        }

        jackpots[_jackpotNumber][currentRound[_jackpotNumber]].rewardAmountDistributed = rewardToSend;
        ids[_jackpotNumber] = 0;
    }

    function claimAmount(uint256 _jackpotNumber , uint _roundNumber) external {

        require(_jackpotNumber< numOfJackPots , "Invalid Jackpot Number");
        require(!jackpots[_jackpotNumber][_roundNumber].isLive , "Jackpot is live!");
        require(block.timestamp > jackpots[_jackpotNumber][_roundNumber].endTime , "Jackpot is not fininshed yet!");
        require(jackpots[_jackpotNumber][_roundNumber].claimable,"Jackpot is not  closed");
        require(!users[_jackpotNumber][msg.sender][_roundNumber].claimed ,"You already Claimed !");
        require(users[_jackpotNumber][msg.sender][_roundNumber].amount>0 ,"You have nothing to claim!");

        UserData storage user = users[_jackpotNumber][msg.sender][_roundNumber];
        token.transfer(msg.sender, user.amount);
        user.claimed = true;
    }


    function random(uint256 _number , uint _mixNum) internal view returns (uint256) {
        return uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        msg.sender,
                        _mixNum
                    )
                )
            ) % _number;
    
    }

    //Read Functions

    function getWinners(uint _jackpotNumber , uint _roundNumber) external view returns(address[] memory ){

      address[] memory winners = new address[](jackpots[_jackpotNumber][_roundNumber].numberOfWinners);

        for(uint i ; i<jackpots[_jackpotNumber][_roundNumber].numberOfWinners ; i++){
            winners[i] = jackpots[_jackpotNumber][_roundNumber].winners[i];
        }
        return winners;
    }

  


   //Change Functions 

    function changeToken(IBEP20 _token) external onlyOwner {
        token = _token;
    }


    function changePool(ICakePool _pool) external onlyOwner {
        pool = _pool;
    }


    function changeParticipationAmount(uint  _amount) external onlyOwner {
        minAmount = _amount;
    }


    function changeParticipationTime(uint[3] memory _time) external onlyOwner {
        timeLimit = _time;
    }

    function changeLockTime(uint[3] memory _lockTime) external onlyOwner {
        lockDuration = _lockTime;
    }

}
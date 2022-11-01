/*

TIKKY INU STAKING CONTRACT

Website: https://tikkyinu.com
Telegram: https://t.me/tikkyinu
Twitter: https://twitter.com/tikkyinu
TikTok: https://tiktok.com/@tikkyinu
APP: https://tikkyinu.app
Staking: https://staking.tikkyinu.app


*/


// File: tests/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
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
// File: tests/stake.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TikkyInuStaking is ReentrancyGuard {
    string public name = "TIKKYINU Inu Staking";
    address public tikkyInu;
    uint public tokenDecimals;

    //declaring owner state variable
    address public owner;

    //declaring default APY (default 54 0.054% daily or 20% APY yearly)
    uint256 public defaultAPY  =  133; //  0.133%  daily  

    //declaringAPY for custom staking (default 82  0.08% daily or 30% APY yearly)
    uint256 public customAPY = 166 ;   //  0.166%  daily

    //declaring APY for custom staking 2 ( default 137 0.137% daily or 50% APY yearly)

    uint256 public customAPY2 = 177;   //  0.177%

    uint public vault1Days = 15; // DAYS
    uint public vault2Days = 30; // DAYS
    uint public vault3Days = 45; // DAYS
  
    //declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;
    uint256 public customTotalStaked2;

    // uint8 public stakingTimeInterval = 15;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public customStakingTime;
    mapping (address => uint) public customStakingTime2;

    //starting staking time
    mapping (address => uint) public start1;
    mapping (address => uint) public start2;
    mapping (address => uint) public start3;

    // uint256 private date
    
    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public customStakingBalance;
    mapping(address => uint256) public customStakingBalance2;

    //Claimed Vault
    mapping(address => uint256) public Vault1;
    mapping(address => uint256) public Vault2;
    mapping(address => uint256) public Vault3;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;
    mapping(address => bool) public customHasStaked2;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;
    mapping(address => bool) public customIsStakingAtm2;

    mapping(address => uint256) public claimed1Balance;
    mapping(address => uint256) public claimed2Balance;
    mapping(address => uint256) public claimed3Balance;

    //pauseStaking
    bool pause1 = false;
    bool pause2 = false;
    bool pause3 = false;

    //pauseUnStaking
    bool uns1 = false;
    bool uns2 = false;
    bool uns3 = false;

    //pauseClaim
    bool claim1 = false;
    bool claim2 = false;
    bool claim3 = false;

    //array of all stakers
    address[] public stakers;
    address[] public customStakers;
    address[] public customStakers2;

    event SendTokens(address indexed tokenAddress, uint256 amount,address indexed to,bool indexed valid);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address _testToken,uint _decimals) payable {
        tikkyInu = _testToken;
        tokenDecimals = _decimals;

        //assigning owner on deployment
        owner = msg.sender;
    }



     modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    //stake tokens function

    function stakeTokens(uint256 _amount, uint256 _days) public nonReentrant {
        //must be more than 0
        // require(unlockTime > block.timestamp, "UNLOCK TIME IN THE PAST");
        // require(unlockTime < 10000000000, "INVALID UNLOCK TIME, MUST BE UNIX TIME IN SECONDS");
        require(_days == vault1Days,"Vault1: Day is not valid" );
        require(_amount > 0, "amount cannot be 0");
        require(pause1 == false, "staking paused");
        require(stakingTime[msg.sender] < block.timestamp,"Staking Still On Progress");
        stakingTime[msg.sender] = block.timestamp + (_days * 1 days) ;
        start1[msg.sender] = block.timestamp;
        
    
        //User adding test tokens
         
        uint transferAmount = _amount * 10**tokenDecimals;
        // testToken.transferFrom(msg.sender, address(this), _amount);
        IBEP20(tikkyInu).transferFrom(msg.sender, address(this), transferAmount);


        totalStaked = totalStaked + _amount;

        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    //claiming tokens
    function Claim(uint _claim) public nonReentrant returns(uint256) {
            
            uint start = 0;
            uint stakebalance = 0;
            uint totaltime = 0;
            uint apy = 0;
            uint256 balance;
             if(_claim == 1) {
               require(claim1 == false, "claim1 paused");
               start = start1[msg.sender];
               stakebalance =  stakingBalance[msg.sender];
               totaltime = stakingTime[msg.sender];
               apy = defaultAPY;



                uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
                uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
                
                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault1[msg.sender];

                // send the rewards to sender
                if (balance > 0) {

                   
                    
                    //claim rewards
                    claimed1Balance[msg.sender] += balance;

                    

                    //update the rewards claimed
                    Vault1[msg.sender] = Vault1[msg.sender] + balance;
                }
             }
            else if(_claim == 2) {
               require(claim2 == false, "claim2 paused");
               start = start2[msg.sender];
               stakebalance =  customStakingBalance[msg.sender];
               totaltime = customStakingTime[msg.sender];
               apy = customAPY;



                uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
                uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
                
                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault2[msg.sender];

                // send the rewards to sender
                if (balance > 0) {


                    //claim rewards
                    claimed2Balance[msg.sender] += balance;

                    //update the rewards claimed
                    Vault2[msg.sender] = Vault2[msg.sender] + balance;
                }
             }
            else if(_claim == 3) {
               require(claim3 == false, "claim3 paused");
               start = start3[msg.sender];
               stakebalance =  customStakingBalance2[msg.sender];
               totaltime = customStakingTime2[msg.sender];
               apy = customAPY2;

               uint limit = (totaltime - start ) / 60 / 60 / 24;        //  daily calculation 
                
                uint diff =  (block.timestamp - start) / 60 / 60 / 24;  //  daily calculation
                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault3[msg.sender];

                // send the rewards to sender
                if (balance > 0) {

                   

                    //claim rewards
                    claimed3Balance[msg.sender] += balance;

                    //update the rewards claimed
                    Vault3[msg.sender] = Vault3[msg.sender] + balance;
                }
             }
             
            

            
            return balance;
        
    }

    function ClaimPrivate(uint _claim) private returns(uint256) {
            
            uint start = 0;
            uint stakebalance = 0;
            uint totaltime = 0;
            uint apy = 0;
            uint256 balance;
             if(_claim == 1) {
               require(claim1 == false, "claim1 paused");
               start = start1[msg.sender];
               stakebalance =  stakingBalance[msg.sender];
               totaltime = stakingTime[msg.sender];
               apy = defaultAPY;



                uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
                uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
                 
                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault1[msg.sender];

                // send the rewards to sender
                if (balance > 0) {

                    // uint transferAmount = balance * 10**tokenDecimals;
                    // IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 

                    //claim rewards
                    claimed1Balance[msg.sender] += balance;


                    //update the rewards claimed
                    Vault1[msg.sender] = Vault1[msg.sender] + balance;
                }
             }
            else if(_claim == 2) {
               require(claim2 == false, "claim2 paused");
               start = start2[msg.sender];
               stakebalance =  customStakingBalance[msg.sender];
               totaltime = customStakingTime[msg.sender];
               apy = customAPY;



                uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
                uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  

                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault2[msg.sender];

                // send the rewards to sender
                if (balance > 0) {

                    // uint transferAmount = balance * 10**tokenDecimals;
                    // IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 

                    //claim rewards
                    claimed2Balance[msg.sender] += balance;

                    //update the rewards claimed
                    Vault2[msg.sender] = Vault2[msg.sender] + balance;
                }
             }
            else if(_claim == 3) {
               require(claim3 == false, "claim3 paused");
               start = start3[msg.sender];
               stakebalance =  customStakingBalance2[msg.sender];
               totaltime = customStakingTime2[msg.sender];
               apy = customAPY2;

               uint limit = (totaltime - start ) / 60 / 60 / 24 ;       //  daily calculation 
                
                uint diff =  (block.timestamp - start) / 60 / 60 / 24;  // daily calculation 
                if(diff > limit){
                    diff = limit;
                }
                //calculating daily apy for user
                balance = stakebalance * (apy * diff); // multiply the day to daily apy
                balance = balance / 100000;

                // deducts the rewards already claimed by sender
                balance = balance - Vault3[msg.sender];

                // send the rewards to sender
                if (balance > 0) {

                    // uint transferAmount = balance * 10**tokenDecimals;
                    // IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 

                    //claim rewards
                    claimed3Balance[msg.sender] += balance;

                    //update the rewards claimed
                    Vault3[msg.sender] = Vault3[msg.sender] + balance;
                }
             }
             
            

            
            return balance;
        
    }

 

    //unstake tokens function

    function unstakeTokens() public nonReentrant {
        //get staking balance for user
        
        uint256 balance = stakingBalance[msg.sender];
        require(uns1 == false, "unstaking paused");
        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");
        require(stakingTime[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        
     
        ClaimPrivate(1);
        //transfer staked tokens back to user
        uint transferAmount = balance * 10**tokenDecimals;
        IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 




        totalStaked = totalStaked - balance;
      
        //reseting users staking balance
        stakingBalance[msg.sender] = 0;

        //updating staking status
        isStakingAtm[msg.sender] = false;
        stakingTime[msg.sender] = 0;
        Vault1[msg.sender] = 0;
       
    }
  

    // different APY Pool
    function customStaking(uint256 _amount, uint256 _days) public nonReentrant {
        require(_amount > 0, "amount cannot be 0");
        require(pause2 == false, "staking paused");
        require(_days == vault2Days,"Vault2: Day is not valid" );
        require(customStakingTime[msg.sender] < block.timestamp,"Staking Still On Progress");
        customStakingTime[msg.sender] = block.timestamp + (_days * 1 days);
        start2[msg.sender] = block.timestamp;
        

        uint transferAmount = _amount * 10**tokenDecimals;
        // testToken.transferFrom(msg.sender, address(this), _amount);
        IBEP20(tikkyInu).transferFrom(msg.sender, address(this), transferAmount);

        
        customTotalStaked = customTotalStaked + _amount;
        customStakingBalance[msg.sender] =
            customStakingBalance[msg.sender] +
            _amount;

        if (!customHasStaked[msg.sender]) {
            customStakers.push(msg.sender);
        }
        customHasStaked[msg.sender] = true;
        customIsStakingAtm[msg.sender] = true;
    }

    function customUnstake() public nonReentrant {
        uint256 balance = customStakingBalance[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        require(uns2 == false, "unstaking paused");
        require(customStakingTime[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        ClaimPrivate(2);


        uint transferAmount = balance * 10**tokenDecimals;
        IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 



        customTotalStaked = customTotalStaked - balance;
        customStakingBalance[msg.sender] = 0;
        customIsStakingAtm[msg.sender] = false;
        customStakingTime[msg.sender] = 0;
        Vault2[msg.sender] = 0;
    }




       function customStaking2(uint256 _amount, uint256 _days) public nonReentrant {
        require(_amount > 0, "amount cannot be 0");
        require(pause3 == false, "staking paused");
        require(_days == vault3Days,"Vault3: Day is not valid" );
        require(customStakingTime2[msg.sender] < block.timestamp,"Staking Still On Progress");
        customStakingTime2[msg.sender] = block.timestamp + (_days * 1 days) ;
        start3[msg.sender] = block.timestamp;
        

        uint transferAmount = _amount * 10**tokenDecimals;
        // testToken.transferFrom(msg.sender, address(this), _amount);
        IBEP20(tikkyInu).transferFrom(msg.sender, address(this), transferAmount);



        customTotalStaked2 = customTotalStaked2 + _amount;
        customStakingBalance2[msg.sender] =
            customStakingBalance2[msg.sender] +
            _amount;

        if (!customHasStaked2[msg.sender]) {
            customStakers2.push(msg.sender);
        }
        customHasStaked2[msg.sender] = true;
        customIsStakingAtm2[msg.sender] = true;
    }

    function customUnstake2() public nonReentrant {
        uint256 balance = customStakingBalance2[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        require(uns3 == false, "unstaking paused");
        require(customStakingTime2[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        ClaimPrivate(3);


        uint transferAmount = balance * 10**tokenDecimals;
        IBEP20(tikkyInu).transfer(msg.sender, transferAmount); 


        customTotalStaked2 = customTotalStaked2 - balance;
        customStakingBalance2[msg.sender] = 0;
        customIsStakingAtm2[msg.sender] = false;
        customStakingTime2[msg.sender] = 0;
        Vault3[msg.sender] = 0;
    }

 
    function changeAPY(uint256 _value) public onlyOwner {
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        defaultAPY = _value;
    }

    //change APY value for custom staking
    function changeAPY2(uint256 _value) public onlyOwner {
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        customAPY = _value;
    }
     
    function changeAPY3(uint256 _value) public onlyOwner {
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        customAPY2 = _value;
    }

    function PauseStake(bool _stake1,bool _stake2,bool _stake3) public onlyOwner{
       pause1 = _stake1;
       pause2 = _stake2;
       pause3 = _stake3;
    }

    function PauseUnStake(bool _stake1,bool _stake2,bool _stake3) public onlyOwner {
       uns1 = _stake1;
       uns2 = _stake2;
       uns3 = _stake3;
    }

    function PauseClaim(bool _stake1,bool _stake2,bool _stake3) public onlyOwner {
       claim1 = _stake1;
       claim2 = _stake2;
       claim3 = _stake3;
    }

    function changeDays(uint day1,uint day2,uint day3) public onlyOwner {
       vault1Days = day1;
       vault2Days = day2;
       vault3Days = day3;
    }


    //owner function to retrieve other tokens
    function sendTokens(address tokenAddress, uint256 amount,address to) public onlyOwner returns (bool success) {
        bool valid = IBEP20(tokenAddress).transfer(to, amount);
        if (valid == true) {
             emit SendTokens(tokenAddress,amount,to,valid);
        }
        return valid;
    }

    function vault1Status (address _address) external view returns (uint) {
        
        
        uint start = 0;
        uint stakebalance = 0;
        uint totaltime = 0;
        uint apy = 0;
        uint256 balance;

        start = start1[_address];
        stakebalance =  stakingBalance[_address];
        totaltime = stakingTime[_address];
        apy = defaultAPY;



        uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
        uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
        
        if(diff > limit){
            diff = limit;
        }
        //calculating daily apy for user
        balance = stakebalance * (apy * diff); // multiply the day to daily apy
        balance = balance / 100000;

        // deducts the rewards already claimed by sender
        uint total = balance - Vault1[_address];
        return total;
    }

    function vault2Status(address _address) external view returns (uint)  {

            uint start = 0;
            uint stakebalance = 0;
            uint totaltime = 0;
            uint apy = 0;
            uint256 balance;


            start = start2[_address];
            stakebalance =  customStakingBalance[_address];
            totaltime = customStakingTime[_address];
            apy = customAPY;



            uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
            uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
            if(diff > limit){
                diff = limit;
            }
            //calculating daily apy for user
            balance = stakebalance * (apy * diff); // multiply the day to daily apy
            balance = balance / 100000;

            // deducts the rewards already claimed by sender
            uint total = balance - Vault2[_address];

            return total;
    }

    function vault3Status (address _address) external view returns (uint)  {


        uint start = 0;
        uint stakebalance = 0;
        uint totaltime = 0;
        uint apy = 0;
        uint256 balance;


        start = start3[_address];
        stakebalance =  customStakingBalance2[_address];
        totaltime = customStakingTime2[_address];
        apy = customAPY2;

        uint limit = (totaltime - start ) / 60 / 60 / 24 ;     //  daily calculation 
        
        uint diff =  (block.timestamp - start) / 60 / 60 / 24 ;  //  daily calculation  
        if(diff > limit){
            diff = limit;
        }
        //calculating daily apy for user
        balance = stakebalance * (apy * diff); // multiply the day to daily apy
        balance = balance / 100000;

        // deducts the rewards already claimed by sender
        uint total = balance - Vault3[_address];

        return total;
    }

    function withdraw(address _reciever ,uint _vaultNumber) public nonReentrant {
        if(_vaultNumber == 1) {
            require(claimed1Balance[msg.sender] > 0 ,"USER: no balance");
            uint transferAmount = claimed1Balance[msg.sender] * 10**tokenDecimals;
            IBEP20(tikkyInu).transfer(_reciever, transferAmount); 
            claimed1Balance[msg.sender] = 0;
        }
        else if(_vaultNumber == 2) {
            require(claimed2Balance[msg.sender] > 0 ,"USER: no balance");
            uint transferAmount = claimed2Balance[msg.sender] * 10**tokenDecimals;
            IBEP20(tikkyInu).transfer(_reciever, transferAmount); 
            claimed2Balance[msg.sender] = 0;
        }
        else if(_vaultNumber == 3) {
            require(claimed3Balance[msg.sender] > 0 ,"USER: no balance");
            uint transferAmount = claimed3Balance[msg.sender] * 10**tokenDecimals;
            IBEP20(tikkyInu).transfer(_reciever, transferAmount); 
            claimed3Balance[msg.sender] = 0;
        }
    }

    function userBalance(address _address) external view returns (uint balance) { 

        uint total = claimed1Balance[_address] + claimed2Balance[_address] + claimed3Balance[_address];
        return total;
    }

    
    //Transfering Ownership
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }




    
}
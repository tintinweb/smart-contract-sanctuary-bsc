/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

/**
:::'###:::::'######::'########:'########:::'#######:::'######:::'#######::'##::: ##::'#######::'##::::'##:'##:::'##:
::'## ##:::'##... ##:... ##..:: ##.... ##:'##.... ##:'##... ##:'##.... ##: ###:: ##:'##.... ##: ###::'###:. ##:'##::
:'##:. ##:: ##:::..::::: ##:::: ##:::: ##: ##:::: ##: ##:::..:: ##:::: ##: ####: ##: ##:::: ##: ####'####::. ####:::
'##:::. ##:. ######::::: ##:::: ########:: ##:::: ##: ##::::::: ##:::: ##: ## ## ##: ##:::: ##: ## ### ##:::. ##::::
 #########::..... ##:::: ##:::: ##.. ##::: ##:::: ##: ##::::::: ##:::: ##: ##. ####: ##:::: ##: ##. #: ##:::: ##::::
 ##.... ##:'##::: ##:::: ##:::: ##::. ##:: ##:::: ##: ##::: ##: ##:::: ##: ##:. ###: ##:::: ##: ##:.:: ##:::: ##::::
 ##:::: ##:. ######::::: ##:::: ##:::. ##:. #######::. ######::. #######:: ##::. ##:. #######:: ##:::: ##:::: ##::::
..:::::..:::......::::::..:::::..:::::..:::.......::::......::::.......:::..::::..:::.......:::..:::::..:::::..:::::
**/

// ASTROCONOMY™ Staking pools
// https://astroconomy.app

contract AstroconomyAPXStaking {
    using SafeMath for uint256;

    // Intialize owner
    address payable public _owner;                                        

    // Name of the staking pool             
    string public _name = 'ASTROCONOMY Plasma Staking Pools (APX to BAPX)';            

    // Tokens we're interfacing with:
    IBEP20 public _theStakedToken;                                                     
    IBEP20 public _theRewardToken;                                                     
    IBEP20 public _theReflectionToken; 

    //address of account staking
    address[] public _stakers;

    // Store all of the staking data:
    mapping(address => uint256) public _stakingBalance;  
    mapping(address => uint256) public _stakingPlan;
    mapping(address => uint256) public _stakingTermExpires;
    mapping(address => bool) public _hasStaked;          
    mapping(address => bool) public _isStaking;          
    uint256 _totalStaked;

    // Plans: Reward and penalty amounts + staking duration
    uint256 public _unstakePercent = 10;
    uint256 public _percentDivider = 100;
    uint256[5] public _duration = [ 1 minutes, 15 days, 30 days, 90 days, 180 days ];
    uint256[5] public _bonus = [15, 25, 35, 50, 75];
    uint public _numberOfRewardCallsPerDay = 2;

    // Modifier to make it easier to restrict access to owner only:
    modifier onlyowner() {
        require(_owner == msg.sender, "only owner");
        _;
    }

    // Initialize an instance of the ASTROCONOMY™ contract.
    constructor(IBEP20 _rewardToken, IBEP20 _stakedToken, IBEP20 _reflectionToken) {
        
         // Intialize the msg.sender as the owner
        _owner = payable(msg.sender);                                                            

        // Set default values such as the tokens we're working with and the fact that we're starting with 0 staked
        _theStakedToken = _stakedToken; 
        _theRewardToken = _rewardToken; 
        _theReflectionToken = _reflectionToken;
        _totalStaked = 0;
    }

    // Function to stake tokens
    function _stakeTokens(uint256 _stakingAmount, uint256 _newStakingPlan) public {

        // require staking amount to be greater than zero
        require(_stakingAmount > 0, 'Cannot stake 0 token');  

        // A valid staking plan is required
        require(_newStakingPlan >= 0 && _newStakingPlan <= 5, "Invalid Plan");                          
 
        // Transfer tokens to this contract address for staking
        _theStakedToken.transferFrom(msg.sender, address(this), _stakingAmount);    

        // Updates staking balance
        _stakingBalance[msg.sender] = _stakingBalance[msg.sender] + _stakingAmount;     

        // Update the total staking amount
        _totalStaked = _totalStaked + _stakingAmount;                                   

        // Checks if the user account has previously staked or not     
        if( _hasStaked[msg.sender] == false ) {
            // If the user has not staked then add them to the list of stakers
            _stakers.push(msg.sender);                                                   
            _stakingPlan[msg.sender] = _newStakingPlan;
        }

        // If the new staking plan is longer then the old staking plan, upgrade
        if( _stakingPlan[msg.sender] < _newStakingPlan) {
            _stakingPlan[msg.sender] = _newStakingPlan;
        }

        // When the staking term expires
        _stakingTermExpires[msg.sender] = block.timestamp.add(_duration[_newStakingPlan]); 

        // Set true for user isStaking and hasStaked
        _isStaking[msg.sender] = true; 
        _hasStaked[msg.sender] = true; 
        
    }

    // Function to unstake tokens
    function _unstakeTokens() public {

        // Stores the token amount of user account to _balance
        uint256 _balance = _stakingBalance[msg.sender];                                  

        // Charge an unstaking fee if unstaking early
        if ( _stakingTermExpires[msg.sender] < block.timestamp) {
            uint256 _penalizedBalance = _stakingBalance[msg.sender] / _unstakePercent; 
            _balance = _penalizedBalance;
        }

         // Token for unstaking cannot be 0
        require(_balance > 0, 'Cannot unstake 0 tokens');                                
        // Calls transfer function from staked token contract and
        // Transfer the tokens to unstake

        _theStakedToken.transfer(msg.sender, _balance);  

        // See how much reflections are owed
        uint256 _reflectionOwed = 0;
        uint256 _totalReflectionPool = _theReflectionToken.balanceOf( address(this) );
        if ( _totalReflectionPool > 0 ) {
            uint256 _percentOfPool = _returnPercentageOfPool();
            _reflectionOwed = _percentOfPool * _totalReflectionPool;
        }

        // If reflections are owed, pay them
        if ( _reflectionOwed > 0 ) {
            _theReflectionToken.transfer(msg.sender, _reflectionOwed); 
        }

        _totalStaked = _totalStaked - _balance;                                          // Remove the user's staked tokens from the total staked
        _stakingBalance[msg.sender] = 0;                                                 // Set the staking balance of user to 0
        _isStaking[msg.sender] = false;                                                  // Set false for user isStaking
    }

    // Calculate current reward based upon APR
    function _calculateRealRewardAmount(address _addressToCheck) public view returns (uint256) {

        require( _stakingPlan[_addressToCheck] >= 0 && _stakingPlan[_addressToCheck] <= 5, "Invalid Plan");  

        uint256 _rawReward = _bonus[_stakingPlan[_addressToCheck]] / 365;
        uint256 _finalCalcReward = _rawReward / _numberOfRewardCallsPerDay;

        return _finalCalcReward;

    }

    // Function to issue reward tokens to the user account
    function _issueRewardTokens()  external onlyowner {

        for(uint256 i=0; i < _stakers.length; i++) {
            address _recipient = _stakers[i]; 
            uint256 _tempRewardDivisor = _calculateRealRewardAmount(_recipient);
            uint256 _rewardToken = _stakingBalance[_recipient] / _tempRewardDivisor; 
            
            if (_rewardToken > 0) {
                _theRewardToken.transfer(_recipient, _rewardToken);     
            }
        }

    } 

    // Return the total amount of StakedTokens:
    function _returnTotalStaked() public view returns (uint256) {
        return _totalStaked;        
    }    

    // Return the percentage of the pool the staker has staked
    function _returnPercentageOfPool() public view returns (uint256) {
        
        uint256 _balance = _stakingBalance[msg.sender]; 
        require(_balance > 0, 'Cannot divide by 0'); 
        require(_totalStaked > 0, 'Cannot divide by 0'); 

        uint256 _returnAmount = _balance / _totalStaked;

        return _returnAmount;
    }

    // Update time for staking plans
    function SetStakeDuration( uint256 first, uint256 second, uint256 third, uint256 fourth, uint256 fifth ) external onlyowner {
        _duration[0] = first;
        _duration[1] = second;
        _duration[2] = third;
        _duration[3] = fourth;
        _duration[4] = fifth;
    }

    // Update bonus for staking plan
    function SetStakeBonus( uint256 first, uint256 second, uint256 third, uint256 fourth, uint256 fifth ) external onlyowner {
        _bonus[0] = first;
        _bonus[1] = second;
        _bonus[2] = third;
        _bonus[3] = fourth;
        _bonus[4] = fifth;
    }

    // Change unstake penality
    function setUnstakePercent(uint256 _percent) external onlyowner {
        _unstakePercent = _percent;
    }

    // Change percentage divider
    function setPercentDivider(uint256 _divider) external onlyowner {
        _percentDivider = _divider;
    }

    // Change contract owner
    function changeOwner(address payable _newowner) external onlyowner {
        _owner = _newowner;
    }

    // Change staking token
    function changeToken(address _token) external onlyowner {
        _theStakedToken = IBEP20(_token);
    }

    // Change rewarded token
    function changeRewardToken(address _reward_token) external onlyowner {
        _theRewardToken = IBEP20(_reward_token);
    }

    // Change reflection token
    function changeReflectionToken(address _reflection_token) external onlyowner {
        _theReflectionToken = IBEP20(_reflection_token);
    }    

    // Remove stuck staking token
    function removeStuckToken(address _token) external onlyowner {
        IBEP20(_token).transfer(_owner, IBEP20(_token).balanceOf(address(this)));
    }

    // Change number Of Reward Calls Per Day
    function changeRewardCallsPerDay(uint _newRewardCallsPerDay) external onlyowner {
        _numberOfRewardCallsPerDay = _newRewardCallsPerDay;
    }  
}

// Standard safemath library
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// Standard BEP20 interface
interface IBEP20 {
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

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}
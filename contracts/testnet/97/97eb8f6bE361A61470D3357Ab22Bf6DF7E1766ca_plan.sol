pragma solidity >=0.4.0 <0.8.0;


import "./IERC20.sol";
import "./SafeMath.sol";
import "./owned.sol";


contract plan is owned {
    IERC20 public stakingToken;    
    uint256 public min_tokens = 10000;
    uint256 public distribute_persent = 6;
    uint256 private plan_diveder = 100;

    mapping(address => User) public users;
    uint256 public total_users = 1; 

    constructor(IERC20 _stakingtoken) public {       
        stakingToken = _stakingtoken;
        users[msg.sender].id = total_users; 
        users[msg.sender].myaddress = msg.sender;        
    }

    function stak(address _upline, uint256 _tokens) public returns (bool){       

        _stak(_upline, _tokens); 
        return true;
    }

    function _stak(address _upline, uint256 _tokens) internal {
        
        stakingToken.transferFrom(msg.sender, address(this), _tokens * (10 ** 18));
        uint256 cashback = (_tokens * (10 ** 18)) * distribute_persent / 100;
        stakingToken.transfer(msg.sender, cashback);

        total_users++;

        users[msg.sender].id = total_users;
        users[msg.sender].myaddress = msg.sender;
        users[msg.sender].sponsor = _upline;
             
        users[msg.sender].deposit_time = uint40(block.timestamp);            
        
        users[_upline].directs++; 
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract stake is Context{
    using SafeMath for uint256;

    address public tokenadress;
    address owner;
    constructor(address _adress){
        tokenadress = _adress;
        owner = _msgSender();
    }

    struct User {
        address staker;
        address refferer;
        uint256 stakeamount;
        uint256 starttime;
        uint256 profit;
        uint256 directreffProfit;   
    }

    struct Direct{
        address[] direct;
        uint256[] joinTime;
    }

    mapping(address => User) private users;
    mapping(address => Direct) private directs;

    // mapping(address => Levels) private levels;
    mapping(address => bool) public isallOpen;
    mapping(address => uint256) public interestType;

    uint256 maxStakeProfit = 100;
    uint256 minStakeProfit = 6600;

    uint128 totaldays = 20 minutes;
    
    uint256[] public levelreff = [3000, 1500, 1000, 900, 800, 700, 600, 500, 400, 300, 200, 100, 100, 200, 300, 50];
    mapping(address => address) public reffOFstaker;

    // mapping(address => Staker) private stakers;

    function normalStake(uint256 _amount) public returns(bool){
        _normalStake(_amount, address(0x0));

        return true;
    }

    function reffStake(uint256 _amount, address _reffAdress) public returns(bool){
        _normalStake(_amount, _reffAdress);

        return true;
    }
    mapping(address => address) public refofstaker;
    mapping(address => uint256) public levelOpenofUser;

    function _normalStake(uint256 _stakingamount, address _reffAdress) public returns(bool){
        require(_reffAdress != _msgSender(), "staker can not use own address as reff addres");
        require(_stakingamount >= 100 * 10**18 && _stakingamount <= 10000 * 10**18, "Stake minimum 100 and maximum 10,000");
        require((_stakingamount/10**18) % 100 == 0, "Stake mount in 100 multiply");
        
        require(IERC20(tokenadress).balanceOf(_msgSender()) >= _stakingamount,"not enough token balance");

        address _sender = _msgSender();

        require(IERC20(tokenadress).transferFrom(_sender, address(this), _stakingamount), "abcd");
        
        users[_msgSender()].staker = _msgSender();

            if(_reffAdress != address(0x0)){
                directs[_reffAdress].direct.push(_msgSender());
                directs[_reffAdress].joinTime.push(block.timestamp);

                users[_reffAdress].directreffProfit = users[_reffAdress].directreffProfit + (_stakingamount * 500).div(10000);

                users[_msgSender()].refferer = _reffAdress;

                for(uint8 i = 0; i<25; i++){
                    levelOpenofUser[_reffAdress] = directs[_reffAdress].direct.length;
                }
                // teamStakingProfit();
        }

        users[_msgSender()].starttime = block.timestamp;
        users[_msgSender()].stakeamount = _stakingamount;


        // users[_msgSender()].profit = refpointBalance[_reffAdress] + (users[_msgSender()].stakeamount.mul(500)).div(10000);

        // require(directs[_reffAdress].direct[0] != address(0x0),"open 1st level");
        
        return true;
    }

    function dailyStakingProfit() public returns(bool){        
        uint256 claimtime = block.timestamp - users[_msgSender()].starttime;

        if(levelOpenofUser[_msgSender()] == 2){
            require(users[_msgSender()].starttime <= directs[_msgSender()].joinTime[0] && directs[_msgSender()].joinTime[1] <= users[_msgSender()].starttime + 7 minutes,"reff not join in 7 days");
            // uint256 bonus = (users[_msgSender()].stakeamount.mul(100)).div(10000);
            // users[_msgSender()].bonuspercentage
            users[_msgSender()].profit = ((claimtime).div(1 minutes) * maxStakeProfit).div(1000);
            interestType[_msgSender()] = 1;
    
        }else{
            // uint256 bonus = (users[_msgSender()].stakeamount.mul(66)).div(10000);
            // bonusOfStaker[_msgSender()] = bonusOfStaker[_msgSender()] + bonus;
            interestType[_msgSender()] = 0;
            users[_msgSender()].profit = ((claimtime).div(1 minutes) * minStakeProfit).div(1000);
        }
        
        return true;
    }
 uint8 k = 0;
         address[10]  _users;

    function teamStakingProfit()public returns(bool){

        // address[] memory _reff;
        
        _users[0] = (users[_msgSender()].refferer);

       do{
        k++;
         _users[k] = users[_users[k-1]].refferer;    
       }while(users[_users[k]].refferer != address(0x0));

        for(uint256 j = 0; j<_users.length; j++){
            if(levelOpenofUser[_users[j]] >= j + 1){

                uint256 _profit = users[_users[j]].profit;

                if(interestType[_msgSender()] == 1){
                    users[_users[j]].profit =  _profit + (maxStakeProfit.mul(levelreff[j])).div(1000);
                }else{
                    require(interestType[_msgSender()] == 0,"user's daily profit is 0.66%");
                    users[_users[j]].profit =  _profit + (minStakeProfit.mul(levelreff[j])).div(1000);
                }     
            }
        }

        delete _users;
        return true;
    }

    function claim() public returns(bool){
        require(block.timestamp <= users[_msgSender()].starttime + 20 minutes, "get reward till 300 days");
        require(users[_msgSender()].staker == _msgSender(),"user is not staker!");

        uint256 profit = users[_msgSender()].profit;

        IERC20(tokenadress).transfer(_msgSender(), profit);

        users[_msgSender()].profit = 0;

        unstake();

        return true;

    }

    function unstake() public returns(bool){
        require(users[_msgSender()].staker == _msgSender(), "Caller is not staker");

        require(IERC20(tokenadress).balanceOf(address(this)) >= users[_msgSender()].stakeamount," contract have not balance");
        IERC20(tokenadress).transfer(_msgSender(), users[_msgSender()].stakeamount);

        users[_msgSender()].stakeamount = 0;
        return true;
    }

    function refferealwithdraw() public returns(bool){
        require(users[_msgSender()].staker == _msgSender(), "Caller is not staker");

        IERC20(tokenadress).transfer(_msgSender(), users[_msgSender()].directreffProfit);

        users[_msgSender()].directreffProfit = 0;

        return true;
    }

    function withdraw() public returns(bool){
        require(_msgSender() == owner, "caller is not owner!");

        IERC20(tokenadress).transfer(_msgSender(), IERC20(tokenadress).balanceOf(address(this)));
        return true;
    }

    // ====================================================   read   ========================================================= 

    function directsOFuser(address _staker) public view returns(address[] memory, uint256[] memory){
        return (directs[_staker].direct, directs[_staker].joinTime);   
    }

    function userDetails(address _staker) public view returns(User memory){
        return users[_staker];
    }

    function a(uint256 _st, uint256 end) public pure returns(uint256){
        return (end - _st).div(1 days);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-06
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
        uint256 dailystakeprofit;
        uint256 directreffProfit;
        uint256 teamstakingprofit;
    }

    struct Direct{
        address[] direct;
        uint256[] joinTime;
        bool isbooster;
    }

    mapping(address => uint256) public totalStakeamount;
    mapping(address => User) private users;
    mapping(address => Direct) private directs;

    mapping(address => uint256) public remainingProfit;
    mapping(address => bool) public isallOpen;
    mapping(address => uint256) public interestType;
    mapping(address => uint256) public withdrawAmount;
    mapping(address => uint256) public lastStake;
    mapping(address => address) public refofstaker;
    mapping(address => uint256) public levelOpenofUser;
    mapping(address => uint256) public _totalwithdrawbleamount;

    uint256 maxStakeProfit = 100;
    uint256 minStakeProfit = 6600;

    uint128 totaldays = 30 hours;
    
    uint256[] public levelreff = [3000, 1500, 1000, 900, 800, 700, 600, 500, 400, 300, 200, 100, 100, 200, 300, 50];
    mapping(address => address) public reffOFstaker;

    // mapping(address => Staker) private stakers;

    function normalStake(uint256 _amount) public returns(bool){
        if(_msgSender() == users[_msgSender()].staker){
            require(_amount > users[_msgSender()].stakeamount,"stake should be greater than last stake!");
            users[_msgSender()].dailystakeprofit = dailyStakingProfit(_msgSender());

            _normalStake(_amount, address(0x0));

        }else{
            _normalStake(_amount, address(0x0));
        }

        return true;
    }

    function reffStake(uint256 _amount, address _reffAdress) public returns(bool){
        if(_msgSender() == users[_msgSender()].staker){
            require(_amount > users[_msgSender()].stakeamount,"stake should be greater than last stake!");
            users[_reffAdress].dailystakeprofit = dailyStakingProfit(_msgSender());

            _normalStake(_amount, _reffAdress);

        }else{
            _normalStake(_amount, _reffAdress);
        }
        return true;
    }

    function _normalStake(uint256 _stakingamount, address _reffAdress) private returns(bool){
        require(_reffAdress != _msgSender(), "staker can not use own address as reff addres");
        require(_stakingamount >= 100 * 10**18 && _stakingamount <= 10000 * 10**18, "Stake minimum 100 and maximum 10,000");
        require((_stakingamount/10**18) % 100 == 0, "Stake mount in 100 multiply");
        require(IERC20(tokenadress).balanceOf(_msgSender()) >= _stakingamount,"not enough token balance");

        // users[_msgSender()].dailystakeprofit = dailyStakingProfit(_msgSender());

        address _sender = _msgSender();
        require(IERC20(tokenadress).transferFrom(_sender, address(this), _stakingamount), "abcd");
        
        users[_msgSender()].staker = _msgSender();
        users[_msgSender()].starttime = block.timestamp;
        users[_msgSender()].stakeamount = _stakingamount;

        totalStakeamount[_msgSender()] = totalStakeamount[_msgSender()] + _stakingamount;

            if(_reffAdress != address(0x0)){
                directs[_reffAdress].direct.push(_msgSender());
                directs[_reffAdress].joinTime.push(block.timestamp);

                users[_reffAdress].directreffProfit = users[_reffAdress].directreffProfit + (_stakingamount * 500).div(10000);

                users[_msgSender()].refferer = _reffAdress;

                for(uint8 i = 0; i<25; i++){
                    levelOpenofUser[_reffAdress] = directs[_reffAdress].direct.length;
                }

                if(levelOpenofUser[_reffAdress] == 2 && (!directs[_reffAdress].isbooster)){
                    // totaltime = directs[_reffAdress].joinTime[0] + directs[_reffAdress].joinTime[1];

                    users[_reffAdress].dailystakeprofit = dailyStakingProfit(_reffAdress);

                    if(directs[_reffAdress].joinTime[1] <= users[_reffAdress].starttime + 7 minutes){
                    // require(totaltime <= users[_reffAdress].starttime + 7 minutes,"not join in 7 days");
                    interestType[_reffAdress] = 1;
                    directs[_reffAdress].isbooster = true;
                    }
                }
            }
            return true;
    }

bool finishroi;

    function dailyStakingProfit(address _add) public view returns(uint256) {        
        uint256 _profit;

        // require(block.timestamp - users[_add].starttime > 3 minutes,"please return after 500 days");
        if(block.timestamp <= users[_add].starttime + 50 minutes){
            uint256 claimtime = block.timestamp - users[_add].starttime;
            if(directs[_add].isbooster){
                _profit = (claimtime.div(10 seconds)) * (users[_add].stakeamount * 100).div(10000);
            }else{
                _profit = (claimtime.div(10 seconds)) * (users[_add].stakeamount * 6600).div(1000000);
            }
        }

        if(block.timestamp > users[_add].starttime + 50 minutes){
            uint256 claimtime = 50 minutes;
            if(directs[_add].isbooster){
                _profit = (claimtime.div(10 seconds)) * (users[_add].stakeamount * 100).div(10000);
            }else{
                _profit = (claimtime.div(10 seconds)) * (users[_add].stakeamount * 6600).div(1000000);
            }
        }

        
        
        // else if(block.timestamp >= users[_add].starttime + 5 minutes){
        //     uint256 claimtime = 5 minutes;

        //     if(directs[_add].isbooster){
        //         _profit = (claimtime.div(1 minutes)) * (users[_add].stakeamount * 100).div(10000);
        //     }else{
        //         _profit = (claimtime.div(1 minutes)) * (users[_add].stakeamount * 6600).div(1000000);
        //     }
        //     totalROI[_msgSender()] =  _profit;
        //     finishroi = true;
        //     return totalROI[_msgSender()];
        // }

        // else{
        // return totalROI[_msgSender()];


        return _profit;
        // }
    }
    // function claim() public returns(uint256){
    //     return dailyStakingProfit(_msgSender());
    // }

    uint8 k = 0;
    
    address[25] _users;

    function teamStakingProfit() private {
        //     uint256 _profit;
        // // address[] memory _reff;
        // // uint256 claimtime = block.timestamp - users[_msgSender()].starttime;
        uint256 _amount4reff = dailyStakingProfit(_msgSender());
        _users[0] = (users[_msgSender()].refferer);

       do{
        k++;
         _users[k] = users[_users[k-1]].refferer;    
       }while(users[_users[k]].refferer != address(0x0));

        for(uint256 j = 0; j<_users.length; j++){
            if(levelOpenofUser[_users[j]] >= j + 1){
                users[_users[j]].teamstakingprofit = _amount4reff.mul(levelreff[j]).div(10000);
            }
        }
        delete _users;
    }


    function totalProfit(address _add) public view returns(uint256){
        
        uint256 _totalprofit = dailyStakingProfit(_add) + users[_add].teamstakingprofit + users[_add].directreffProfit ;

        return _totalprofit;
    }

    function RemainingProfit(address _add) public view returns(uint256){
        uint256 _remainingProfit = totalProfit(_add) - withdrawAmount[_add]; 
        return _remainingProfit;
    }


    function withdraw(uint256 _amount) public returns(bool){
        
        uint256 _withAmount = withdrawAmount[_msgSender()] + _amount;

        require(users[_msgSender()].staker == _msgSender(),"user is not staker!");
        require(_amount <= RemainingProfit(_msgSender()),"not enough profit");       
        require(_amount >= 10 * 10**18 && _withAmount <= (totalStakeamount[_msgSender()] * 3), "minimum 10 & maximum 3X of stake amount can be withdrawn");
        // require(_totalwithdrawbleamount[_msgSender()] < (totalStakeamount[_msgSender()] * 3),"exceed withrawable amount");

        teamStakingProfit();
        
        remainingProfit[_msgSender()] =  RemainingProfit(_msgSender()) - _amount;

        withdrawAmount[_msgSender()] = withdrawAmount[_msgSender()] + _amount;

        IERC20(tokenadress).transfer(_msgSender(), _amount);

        return true;

    }

    function Adminwithdraw(uint256 _amount) public returns(bool){
        //
        //10 minimum withdraw max 3X of staking amount 
        require(_msgSender() == owner, "caller is not owner!");

        IERC20(tokenadress).transfer(_msgSender(), _amount);
        return true;
    }

    // ====================================================   read   ========================================================= 

    function directsOFuser(address _staker) public view returns(address[] memory, uint256[] memory){
        return (directs[_staker].direct, directs[_staker].joinTime);   
    }
    
    function ReferralofUser(address _staker) public view returns(uint256){
        return users[_staker].directreffProfit;
    }

    function totalStakeAmount() public view returns(uint256){
        return totalStakeamount[_msgSender()];
    }

    function lastStakeAmount() public view returns(uint256){
        return users[_msgSender()].stakeamount;
    }

    function UserDetails(address _user)public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        return (users[_user].starttime,
            levelOpenofUser[_user],
            dailyStakingProfit(_user),
            ReferralofUser(_user),
            withdrawAmount[_user],
            RemainingProfit(_user),
            users[_user].teamstakingprofit);
    }

    function withdrawableAmount(uint256 _amount) public view returns(bool){

        uint256 _pending = RemainingProfit(_msgSender());
        uint256 _withdrawble = _amount + withdrawAmount[_msgSender()];

        if(10 * 10**18 <= _amount && _pending >= 10  && _withdrawble <=( totalStakeAmount()*3)){
            return true;
        }else{
            return false;
        }
    }
}
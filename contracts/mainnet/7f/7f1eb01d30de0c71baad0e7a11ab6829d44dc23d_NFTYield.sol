/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

/**
 *Submitted for verification at polygonscan.com on 2022-12-05
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;

struct Tarif {
  uint8 life_days;
  uint16 percent;
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
  uint40 last_payout;
  uint256 checkpoint;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[5] structure; 
}

contract NFTYield {
    address public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    address public DevFee;
    address public  OpenseaNFT;
    
    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint256 constant public TIME_STEP = 1 days;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [100, 20, 10, 10, 5]; 

    uint8 constant maturity_bonus = 50;

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;

    uint256 public startUNIX;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor(uint256 _startUNIX, address _DevFee, address _OpenseaNFT) {
        owner = msg.sender;
        startUNIX = _startUNIX;
        DevFee = _DevFee;

        OpenseaNFT = _OpenseaNFT;

        tarifs[15] = Tarif(15, 115); // 7.6% per Day Upto 115% + 5 % extra if withdraw after 15 days
        tarifs[30] = Tarif(30, 165); // 5.5% per Day.  Upto 150% + 5 % extra if withdraw after 30 days
        tarifs[45] = Tarif(45, 215); // 4.8 % Per Day  Upto 200%  + 5 % extra if withdraw after 45 days
        tarifs[60] = Tarif(60, 265); //  4.4% Per Day. Upto 250% + 5 % extra if withdraw after 50 days
        tarifs[75] = Tarif(75, 315); // 4.2 % Per day   Upto 300% +  5 % extra if withdraw after 315 days

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
        payable(DevFee).transfer(msg.value * 2 / 100);
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);
        require((player.checkpoint + TIME_STEP ) < block.timestamp, "only once a day");
        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;
        player.checkpoint = block.timestamp;
        payable(OpenseaNFT).transfer(amount * 8 / 100);
        payable(DevFee).transfer(amount * 2 / 100);
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


                if(block.timestamp - from > tarif.life_days * 86400)
                {
                    // In case of maturity -> 5% extra
                    value +=  dep.amount * maturity_bonus / PERCENT_DIVIDER;
                }
            }
        }

        return value;
    }


    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure,uint256 _checkpoint) {
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


      function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (uint8, uint256, uint40)
    {
        Player storage player = players[userAddress];

        return (player.deposits[index].tarif,player.deposits[index].amount,player.deposits[index].time);
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus,uint256  _startUNIX) {
        return (invested, withdrawn, match_bonus,startUNIX);
    }

}
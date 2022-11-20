// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Lottery.sol";
import "./CrowdSale.sol";
import "./Lending.sol";

contract CryptoLottery is CrowdSale, Lending {
    /**
      Crypto Lottery 
      cryptolottery.top
    */
    
    uint private constant _ico_price = 200000000000; // one token price
    uint private constant _ico_soft_cap = 100 * 10 ** 18;
    uint private constant _interval = 86400;
    uint private constant _ticket_p = 10000000000000000;
    uint private constant _f = 20;
    uint private constant _ico_time = 86400 * 120;
    uint private constant _n_game_reward = 1000 * 10**18;
    uint private constant _ticket_p_cl = 10000 * 10**18;

    constructor() CrowdSale(
        _ico_price, 
        _interval, 
        _ticket_p, 
        _ticket_p_cl, 
        _f, 
        _ico_soft_cap, 
        _ico_time, 
        _n_game_reward
        ) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Token.sol";
import "./Events.sol";
import "./Lottery.sol";

contract CrowdSale is Token, Events, Lottery {

   uint public tokenPrice;
   uint public softCap;
   uint public raisedAmount;
   uint public withdrawAmount;
   uint public time;

   CrowdSaleStatus public crowd_sale_status;

   enum CrowdSaleStatus {
        ON,
        OFF
   }

   constructor(uint _tokenPrice, uint _interval, uint _t_price, uint _ticket_p_cl, uint _f, uint _ico_soft_cap, uint _ico_time, uint _n_game_reward) Lottery(_interval, _t_price, _ticket_p_cl, _f, _n_game_reward) {
     tokenPrice = _tokenPrice;
     softCap = _ico_soft_cap;
     time = block.timestamp + _ico_time;
   }

   function deposit () external payable {
     require(crowd_sale_status == CrowdSaleStatus.ON, 'CrowdSale is closed');
     require(block.timestamp <= time, 'Time is over');

     raisedAmount += msg.value;

     uint tokens = msg.value / tokenPrice; // error.
     uint __tokens = tokens * 10 ** 18;
     _token_reward += __tokens * 3;

     _mint(msg.sender, __tokens);
     emit DepositEvent(msg.value, __tokens);
   }

   function winthdraw (uint amount) external onlyOwner {
     require(withdrawAmount + amount <= raisedAmount, 'Contract is empty');
     
     withdrawAmount += amount;

     _lottery_owner.transfer(amount);

     emit WithdrawEvent(amount);
   }

   function turnOn() external onlyOwner{
     crowd_sale_status = CrowdSaleStatus.ON; 
   }

   function turnOff() external onlyOwner {
     crowd_sale_status = CrowdSaleStatus.OFF; 
   }

   function changeTime(uint _time) external onlyOwner {
     time = block.timestamp + _time;
   }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Events.sol";

contract Lending is Events {
    mapping(address => LendingStr) private _lending;

    LendingStatus public _lending_status = LendingStatus.Online;

    address _lending_owner = msg.sender;

    modifier _onlyOwner() {
        require(msg.sender == _lending_owner, "You are not an owner");
        _;
    }

    struct LendingStr {
        uint256 _lending_value;
        uint256 _lending_timestamp;
    }

    enum LendingStatus {
        Offline,
        Online
    }

    uint256 public _lending_all;

    uint256 public percentMin = 50; 
                                    //0.00005% min

    function addLending() external payable {
        require(_lending[msg.sender]._lending_value == 0, "No Zero funds");
        require(_lending[msg.sender]._lending_timestamp == 0, "No Zero time");
        require(_lending_status == LendingStatus.Online, "Lending is offline");

        _lending[msg.sender]._lending_value += msg.value;
        _lending[msg.sender]._lending_timestamp = block.timestamp;
        _lending_all += msg.value;

        emit AddLengindEvent(msg.sender, msg.value, block.timestamp);
    }

    function removeLending() external {
        require(_lending[msg.sender]._lending_value > 0, "Zero funds");
        require(_lending[msg.sender]._lending_timestamp > 0, "Zero time");

        uint256 _amount = _lending[msg.sender]._lending_value;
        uint256 __time = _lending[msg.sender]._lending_timestamp;

        _lending[msg.sender]._lending_value = 0;
        _lending[msg.sender]._lending_timestamp = 0;
        _lending_all -= _amount;

        uint256 _time = block.timestamp - __time;
        uint256 _mins = _time / 60;
        uint256 _reward_percent = percentMin * _mins; //
        uint256 _reward = (_amount * _reward_percent) / 100000000;

        payable(msg.sender).transfer(_amount + _reward);

        emit RemoveLengindEvent(
            msg.sender,
            _amount,
            _reward,
            _reward_percent,
            _mins,
            block.timestamp
        );
    }

    function lendOff(bool status) external _onlyOwner {
        if (status) {
            _lending_status = LendingStatus.Offline;
        } else {
            _lending_status = LendingStatus.Online;
        }
    }

    function changePercentDay(uint256 _percentMin) external _onlyOwner {
        require(_percentMin < 150, "Too much");
        percentMin = percentMin;
    }

    function returnUserLending(address user)
        external
        view
        returns (uint256 _lending_value, uint256 _lending_timestamp)
    {
        return (
            _lending[user]._lending_value,
            _lending[user]._lending_timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Token.sol";
import "./Events.sol";

contract Lottery is Token, Events {
    uint256 public _round_interval;
    uint256 public _ticket_price;
    uint256 public _ticket_price_cl;
    uint256 public _fee;
    uint256 public _fee_value;
    uint256 public _token_reward;
    uint256 public _purchased_tickets;
    uint256 public _purchased_free_tickets;
    uint256 public _all_eth_reward;
    uint[12] public _tiers;
    uint[3] public _percent;
    uint public _promotion_money;
    uint256 private _secret_key;
    uint256 public _next_game_reward;
    address payable public _lottery_owner;
    
    modifier onlyOwner {
      require(msg.sender == _lottery_owner, "You are not an owner");
      _;
    }
   
    enum RoundStatus {
        End,
        Start
    }

    mapping(address => TicketRef[]) private _tickets_ref;
    mapping(address => uint256) private _free_tickets;

    Round[] public _rounds;
    Ticket[] public _tickets;

    constructor(
        uint256 round_interval,
        uint256 ticket_price,
        uint256 ticket_price_cl,
        uint256 fee,
        uint256 next_game_reward
    ) {
        _round_interval = round_interval;
        _ticket_price = ticket_price;
        _ticket_price_cl = ticket_price_cl;
        _fee = fee;
        _lottery_owner = payable(msg.sender);
        _percent[0] = 3;
        _percent[1] = 10;
        _percent[2] = 30;
        _next_game_reward = next_game_reward;
    }

    struct Round {
        uint256 startTime;
        uint256 endTime;
        RoundStatus status;
        uint256[] win;
        uint256 number;
        uint tickets;
    }

    struct TicketRef {
        uint256 round;
        uint256 number;
    }

    struct Ticket {
        address owner;
        uint256[6] numbers;
        uint256 win_count;
        bool win_last_digit;
        uint256 eth_reward;
        uint256 token_reward;
        bool free_ticket;
        uint256 round;
        uint256 number;
        bool paid;
        uint256 time;
        uint256 tier;
    }

    function createRound() internal {
        if (
            _rounds.length > 0 &&
            _rounds[_rounds.length - 1].status != RoundStatus.End
        ) {
            revert("Error: the last round in progress");
        }

        uint256[] memory win;

        Round memory round = Round(
            block.timestamp,
            block.timestamp + _round_interval,
            RoundStatus.Start,
            win,
            _rounds.length,
            0
        );

        _rounds.push(round);

        _mint(msg.sender, _next_game_reward);

        _token_reward += _next_game_reward;

        emit CreateRoundEvent(
            _rounds.length, 
            _next_game_reward, 
            msg.sender, 
            block.timestamp
        );
    }

    function buyTicket(uint256[6] memory _numbers) external payable {
        require(_ticket_price == msg.value, "not valid value");
        require(
            _rounds[_rounds.length - 1].status == RoundStatus.Start,
            "Error: the last round ended"
        );

        Ticket memory ticket = Ticket(
            msg.sender,
            _numbers,
            0,
            false,
            0,
            0,
            false,
            _rounds.length - 1,
            _tickets.length,
            false,
            block.timestamp,
            0
        );

        TicketRef memory ticket_ref = TicketRef(
            _rounds.length - 1,
            _tickets.length
        );

        _rounds[_rounds.length - 1].tickets += 1;
        _purchased_tickets += 1;

        _tickets.push(ticket);
        _tickets_ref[msg.sender].push(ticket_ref);

        _fee_value += (_fee * msg.value) / 100;

        emit BuyTicketEvent( 
            _tickets.length,
             msg.sender,
            _numbers,
            block.timestamp
        );

    }

    function buyFreeTicket(uint256[6] memory _numbers) external {
        require(_free_tickets[msg.sender] > 0, "You do not have a free ticket");
        require(
            _rounds[_rounds.length - 1].status == RoundStatus.Start,
            "Error: the last round ended"
        );

        Ticket memory ticket = Ticket(
            msg.sender,
            _numbers,
            0,
            false,
            0,
            0,
            false,
            _rounds.length - 1,
            _tickets.length,
            false,
            block.timestamp,
            0
        );

        TicketRef memory ticket_ref = TicketRef(
            _rounds.length - 1,
            _tickets.length
        );
        
        _tickets.push(ticket);
        _tickets_ref[msg.sender].push(ticket_ref);

        _rounds[_rounds.length - 1].tickets += 1;
        _purchased_free_tickets += 1;
        _free_tickets[msg.sender] -= 1;

        emit BuyFreeTicketEvent(
            _tickets.length,
             msg.sender,
            _numbers,
            block.timestamp
        );
    }

    function buyCLTicket(uint256[6] memory _numbers) external {

        require(
            _rounds[_rounds.length - 1].status == RoundStatus.Start,
            "Error: the last round ended"
        );

        _burn(msg.sender, _ticket_price_cl);

        Ticket memory ticket = Ticket(
            msg.sender,
            _numbers,
            0,
            false,
            0,
            0,
            false,
            _rounds.length - 1,
            _tickets.length,
            false,
            block.timestamp,
            0
        );

        TicketRef memory ticket_ref = TicketRef(
            _rounds.length - 1,
            _tickets.length
        );
        
        _tickets.push(ticket);
        _tickets_ref[msg.sender].push(ticket_ref);

        _rounds[_rounds.length - 1].tickets += 1;
        _purchased_tickets += 1;

        emit BuyCLTicketEvent(
            _tickets.length,
             msg.sender,
            _numbers,
            block.timestamp
        );
    }

    function _random(uint256 key) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        key,
                        block.difficulty,
                        block.timestamp,
                        block.coinbase
                    )
                )
            );
    }

    function lastCombination() internal {
        if (_rounds[_rounds.length - 1].win.length == 0) {
            uint256[6] memory _cache;
            uint256 _num;

            for (uint256 i = 0; i < 6; i++) {
                if (i < 5) {
                    _secret_key += 1;
                    uint256 _number = _random(_secret_key) % 69;
                    _cache[i] = _number + 1;
                } else {
                    _secret_key += 1;
                    uint256 _number = _random(_secret_key) % 26;
                    _cache[i] = _number + 1;
                }
            }

            for (uint256 i = 0; i < _cache.length; i++) {
                for (uint256 z = 0; z < _cache.length; z++) {
                    if (_cache[i] == _cache[z]) {
                        _num += 1;
                    }
                }
            }

            if (_num > 6) {
                lastCombination();
            } else {
                _rounds[_rounds.length - 1].win = _cache;
            }
        } else {
            revert("Error: the win combination already exist");
        }
    }

    function closeRound() internal {
        if (_rounds[_rounds.length - 1].status == RoundStatus.End) {
            revert("The round end");
        }

        if (block.timestamp < _rounds[_rounds.length - 1].endTime) {
            revert("The round can't closed");
        }

        _rounds[_rounds.length - 1].status = RoundStatus.End;

        lastCombination();
    }
    
    function claimPay(uint256 number) internal {
        require(
            msg.sender == _tickets[number].owner,
            "You are not an owner"
        );
        require(
            _rounds[_tickets[number].round].status == RoundStatus.End,
            "The Round is in process"
        );

        require(_tickets[number].paid == false, "The Ticket was paid");

        _tickets[number].paid = true;

        if (_tickets[number].free_ticket) {
            _free_tickets[_tickets[number].owner] += 1;
        }
        if (_tickets[number].eth_reward > 0) {
            payable(_tickets[number].owner).transfer(
                _tickets[number].eth_reward
            );
        }

        if (_tickets[number].token_reward > 0) {
            _mint(
                _tickets[number].owner,
                _tickets[number].token_reward
            );
        }

        emit ClaimTicketRewardEvent(
            _tickets[number].tier,
            _tickets[number].free_ticket,
            _tickets[number].token_reward,
            _tickets[number].eth_reward
        );
    }

    function getTicketWinNumbers(uint256 number) internal {
        
        require(_tickets[number].win_count == 0, "Win numbers already exist");

        uint256[] memory _numbers = _rounds[_tickets[number].round].win;
        

        for (
            uint256 z = 0;
            z < _tickets[number].numbers.length;
            z++
        ) {
            for (uint256 y = 0; y < _numbers.length; y++) {
                if (_tickets[number].numbers[z] == _numbers[y]) {
                    _tickets[number].win_count += 1;

                    if (_numbers[y] == 6) {
                        _tickets[number].win_last_digit = true;
                    }
                }
            }
        }
    }

    function addTicketReward(uint number) internal {

      require(_tickets[number].tier == 0, "Already exist");

        /* 
      0 - free ticket + 250 CL
      1 - 500 CL
      
      0 + 1 - x2 + 1000 CL
      1 + 1 x2 + 2000 CL  
      2 - x2 + 2000 CL
      
      2 + 1 - x5 + 5000 CL
      3 - x10 + 10000 CL
      3 + 1 - x50  + 50000  CL
      4 + 0 - x100 + 100000 CL
       
      // jackpots
 
      4 + 1 - 2% of bank
      5 + 0 - 10% of bank
      5 + 1 - 30% of bank
 
     */

            if (_tickets[number].win_count == 0) {
                _tickets[number].token_reward = 250 * 10**18;
                _tickets[number].free_ticket = true;

                _token_reward += _tickets[number].token_reward;
                _tickets[number].tier = 1;
                _tiers[0] += 1;
            }

            if (
                _tickets[number].win_count == 1 &&
                _tickets[number].win_last_digit == false
            ) {
                _tickets[number].token_reward = 500 * 10**18;
                _token_reward += _tickets[number].token_reward;
                _tickets[number].tier = 2;
                _tiers[1] += 1;
            }

            if (
                _tickets[number].win_count == 1 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward = _ticket_price * 2;
                _tickets[number].token_reward = 1000 * 10**18;
                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 3;

                _tiers[2] += 1;
            }

            if (
                _tickets[number].win_count == 2 &&
                _tickets[number].win_last_digit == false
            ) {
                _tickets[number].eth_reward = _ticket_price * 2;
                _tickets[number].token_reward = 2000 * 10**18;
                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 4;

                _tiers[3] += 1;
            }

            if (
                _tickets[number].win_count == 2 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward = _ticket_price * 2;
                _tickets[number].token_reward = 2000 * 10**18;
                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 5;

                _tiers[4] += 1;
            }

            if (
                _tickets[number].win_count == 3 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward = _ticket_price * 5;
                _tickets[number].token_reward = 5000 * 10**18;
                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 6;

                _tiers[5] += 1;
            }

            if (
                _tickets[number].win_count == 3 &&
                _tickets[number].win_last_digit == false
            ) {
                _tickets[number].eth_reward = _ticket_price * 10;
                _tickets[number].token_reward = 10000 * 10**18;

                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 7;

                _tiers[6] += 1;
            }

            if (
                _tickets[number].win_count == 4 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward = _ticket_price * 50;
                _tickets[number].token_reward = 50000 * 10**18;
                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 8;

                _tiers[7] += 1;
            }

            if (
                _tickets[number].win_count == 4 &&
                _tickets[number].win_last_digit == false
            ) {
                _tickets[number].eth_reward =
                    _ticket_price *
                    100;
                _tickets[number].token_reward = 100000 * 10**18;

                _token_reward += _tickets[number].token_reward;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 9;

                _tiers[8] += 1;
            }

            if (
                _tickets[number].win_count == 5 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward =
                    (_percent[0] * address(this).balance) /
                    100;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 10;

                _tiers[9] += 1;
            }

            if (
                _tickets[number].win_count == 5 &&
                _tickets[number].win_last_digit == false
            ) {
                _tickets[number].eth_reward =
                    (_percent[1] * address(this).balance) /
                    100;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 11;

                _tiers[10] += 1;
            }

            if (
                _tickets[number].win_count == 6 &&
                _tickets[number].win_last_digit == true
            ) {
                _tickets[number].eth_reward =
                    (_percent[2] * address(this).balance) /
                    100;

                _all_eth_reward += _tickets[number].eth_reward;

                _tickets[number].tier = 12;

                _tiers[11] += 1;
            }
        
    }

    function claimTicketReward (uint number) external {
        getTicketWinNumbers(number);
        addTicketReward(number);
        claimPay(number);
    } 

    function claimOwnerEthReward(uint number) external onlyOwner {
        require(_fee_value >= number, "not enough of eth");
        payable(_lottery_owner).transfer(_fee_value);
        _fee_value -= number;
    }

    function claimOwnerTokenReward(uint number) external onlyOwner {
        require(_token_reward >= number, "not enough of tokens");
        _mint(_lottery_owner, number);
        _token_reward -= number;
    }

    function getRoundsCount() external view returns (uint256) {
        return _rounds.length;
    }

    function getTicketsCount() external view returns (uint256) {
        return _tickets.length;
    }

    function getRoundTicketCount(uint round) external view returns (uint256) {
        return _rounds[round].tickets;
    }

    function getLastRoundTicketCount() external view returns (uint256) {
        return _rounds[_rounds.length - 1].tickets;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getWinnerTiers() external view returns (uint[12] memory winners) {
        return _tiers;
    }

    function getTicketRef(address user)
        external
        view
        returns (TicketRef[] memory ref)
    {
        TicketRef[] memory ref_ = new TicketRef[](_tickets_ref[user].length);

        for (uint256 i = 0; i < _tickets_ref[user].length; i++) {
            ref_[i] = _tickets_ref[user][i];
        }

        return ref_;
    }

    function getRoundById(uint256 id)
        external
        view
        returns (Round[] memory _round)
    {
        Round[] memory round = new Round[](1);
        round[0] = _rounds[id];
        return round;
    }

    function getLastRound() external view returns (Round[] memory _round) {
        Round[] memory round = new Round[](1);
        round[0] = _rounds[_rounds.length - 1];
        return round;
    }

    function getLastRounds(uint256 cursor, uint256 howMany)
        external
        view
        returns (
            Round[] memory rounds,
            uint256 oldCursor,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _rounds.length;
        if (length > _rounds.length - cursor) {
            length = _rounds.length - cursor;
        }
     
        Round[] memory __array = new Round[](length);

        for (uint256 i = 0; i < length; i++) {
            __array[i] = _rounds[_total - cursor - i - 1];
        }

        return (__array, cursor, cursor + length, _total);
    }

    function getLastTickets(uint256 cursor, uint256 howMany)
        external
        view
        returns (
            Ticket[] memory tickets,
            uint256 oldCursor,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _tickets.length;
        if (length > _tickets.length - cursor) {
            length = _tickets.length - cursor;
        }
        
        Ticket[] memory __array = new Ticket[](length);

        for (uint256 i = 0; i < length; i++) {
            __array[i] = _tickets[_total - cursor - i - 1];
        }

        return (__array, cursor, cursor + length, _total);
    }

    function getUserTickets(
        address user,
        uint256 cursor,
        uint256 howMany
    )
        external
        view
        returns (
            Ticket[] memory tickets,
            uint256 oldCursor,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _tickets_ref[user].length;
        if (length > _tickets_ref[user].length - cursor) {
            length = _tickets_ref[user].length - cursor;
        }

        Ticket[] memory __array = new Ticket[](length);

        for (uint256 i = 0; i < length; i++) {

            __array[i] = _tickets[_tickets_ref[user][_total - cursor - i - 1].number];
        }

        return (__array, cursor, cursor + length, _total);
    }

    function getUserFreeTicketsCount(address user)
        external
        view
        returns (uint256)
    {
        return _free_tickets[user];
    }


    function changeRoundInterval(uint256 interval) external onlyOwner {
        _round_interval = interval;
    }

    function changeTicketPrice(uint256 price) external onlyOwner {
        _ticket_price = price;
    }

    function changeTicketCLPrice(uint price) external onlyOwner{
        _ticket_price_cl = price;
    }

    function changeFee(uint256 fee) external onlyOwner {
        require(fee >= 1 && fee <= 20, "Error: Badly range");
        _fee = fee;
    }
    
    function changeReward(uint256 reward) external onlyOwner {
        _next_game_reward = reward;
    }

    function changePercent(uint256 _percent0, uint256 _percent1, uint256 _percent2) external onlyOwner {
        require(_percent0 >= 3, "Percent can't be less than");
        require(_percent1 >= 10, "Percent can't be less than");
        require(_percent2 >= 30, "Percent can't be less than");

        _percent[0] = _percent0;
        _percent[1] = _percent1;
        _percent[2] = _percent2;
    }

    function addPromoMoney() external payable onlyOwner {
        _promotion_money += msg.value;
    }

    function withdrawPromoMoney(uint value) external onlyOwner {
        require(_promotion_money >= value, "Not enough");
        payable(_lottery_owner).transfer(value);
        _promotion_money -= value;
    }

    function nextGame() external {
        if (_rounds.length > 0) {
            closeRound();
        }

        createRound();
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Events {
  event ClaimTicketRewardEvent(uint tier, bool free_ticket, uint token_reward, uint eth_reward );
  event DepositEvent(uint value, uint tokens);
  event WithdrawEvent(uint amount);
  event CreateRoundEvent(uint round, uint token_reward, address moderator, uint time);
  event BuyTicketEvent(uint number, address player, uint256[6] numbers, uint time);
  event BuyFreeTicketEvent(uint number, address player, uint256[6] numbers, uint time);
  event BuyCLTicketEvent(uint number, address player, uint256[6] numbers, uint time);
  event AddLengindEvent(address holder, uint amount, uint time);
  event RemoveLengindEvent(address holder, uint amount, uint reward, uint percent, uint _days, uint time);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract Token is ERC20, ERC20Burnable {
  constructor() ERC20("Crypto Lottery", "CL") {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.17;

import "./ERC20.sol";
import "./Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.17;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.17;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
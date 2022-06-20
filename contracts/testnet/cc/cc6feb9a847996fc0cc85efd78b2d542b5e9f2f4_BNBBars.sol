/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT

/*
  ____        _            _   ____                 
 |  _ \      | |          | | |  _ \                
 | |_) | __ _| | _____  __| | | |_) | __ _ _ __ ___ 
 |  _ < / _` | |/ / _ \/ _` | |  _ < / _` | '__/ __|
 | |_) | (_| |   <  __/ (_| | | |_) | (_| | |  \__ \
 |____/ \__,_|_|\_\___|\__,_| |____/ \__,_|_|  |___/
                                                    
           
Baked Bars - BSC BNB Miner
*/


pragma solidity 0.8.7;



contract BNBBars {
     using SafeMath for uint256;

    address private devFeeVal_wallet;

    uint256 public total_bought;
    uint256 public total_claimed;
    uint256 public total_referral_bonus;

    uint16 constant percent_divide_by = 1000;

    uint24 constant day_secs = 86400;
    uint8 constant devFeeVal = 80;
    uint8 constant ref_lines = 3;
    uint8[ref_lines] public ref_bonuses = [50, 20, 10];


    uint256 constant min_seed_bought = 0.05 ether;

    uint256 public LOTTERY_STEP = 1 days; 
    uint256 public MAX_TICKETS = 10;
    uint256 public LOTTERY_START_TIME;
    uint256 public roundId = 1;
    uint256 public totalPool = 0;
    uint256 public totalTickets = 0;
     uint256 constant public WINNER_SHARE = 900;
    uint256 public constant TICKET_PRICE = 0.005 ether; // 0.005 bnb
    bool public publicLotteryStarted;

    struct buySeed {
        uint16 crop;
        uint256 amount;
        uint40 time;
    }

    struct Crop{
        uint40 sowing_period;
        uint256 totalReturn;
    }

    struct LotteryWinners
    {
        address userAddress;
        uint256 amount;
    }

    struct User {
        address referrer;
        uint256 bought;
        uint256 claimed;
        uint256 bonused;
        uint256 unsold_bonus;
        buySeed[] buySeeds;
        uint40 last_sale;
        uint256[ref_lines] network;
          uint256 totalTickets;
        uint256 totalReward;
        uint256 totalWins;
    }

    mapping(address => User) public users;
    mapping(uint256 => mapping(uint256 => address)) public ticketsUsers;
    mapping(uint256 => mapping(address => uint256)) public usersTickets;
    mapping(uint256 => Crop) public cropList;
    mapping(uint256 => LotteryWinners) public lotteryWinningHostory;


    event NewUser(address indexed user, address indexed referrer);
    event NewBought(address indexed user, uint256 amount, uint16 sowing_period);
    event NewWithdrawn(address indexed user, uint256 amount);
    event Winner(address indexed winnerAddress, uint256 winnerPrize, uint256 roundId, uint256 totalPool, uint256 totalTickets, uint256 time);
    event BuyTicket(address indexed user, uint256 roundId, uint256 totalTickets, uint256 time);

    event devFeeValPaid(
        address indexed user,
        uint256 totalAmount,
        uint256 devFeeValAmount
    );
    event ReferralBonusPaid(
        address indexed referrer,
        address indexed referral,
        uint256 level,
        uint256 amount
    );

    constructor(address _devFeeVal_wallet, uint256 startDate) {
        devFeeVal_wallet = _devFeeVal_wallet;
         if(startDate > 0){
            LOTTERY_START_TIME = startDate;
        }
        else{
            LOTTERY_START_TIME = block.timestamp;
        }
        
        cropList[0]=Crop(10,1300);
        cropList[1]=Crop(20,1700);
        cropList[2]=Crop(30,2500);

    }

    function rewardReferrers(address _addr, uint256 _amount) private {
        address ref = users[_addr].referrer;

        for (uint8 i = 0; i < ref_lines; i++) {
            if (ref == address(0)) break;

            uint256 bonus = (_amount * ref_bonuses[i]) / percent_divide_by;

            users[ref].unsold_bonus += bonus;

            total_referral_bonus += bonus;

            emit ReferralBonusPaid(ref, _addr, i + 1, _amount);

            ref = users[ref].referrer;
        }
    }

    function setReferrer(User storage user, address _referrer) private {
        if (user.referrer == address(0) && users[_referrer].buySeeds.length > 0) {
            user.referrer = _referrer;

            for (uint8 i = 0; i < ref_lines; i++) {
                users[_referrer].network[i]++;
                _referrer = users[_referrer].referrer;
                if (_referrer == address(0)) break;
            }
        }
    }

    function buyseed(uint16 _crop, address _referrer) external payable {
        require(msg.value >= min_seed_bought, "Deposit less than minimum");
        require(
            cropList[_crop].sowing_period>0,
            "Out of investment days range"
        );

        User storage user = users[msg.sender];

        if (msg.sender != devFeeVal_wallet) {
            setReferrer(user, _referrer);
        }

        if (user.buySeeds.length == 0) {
            emit NewUser(msg.sender, user.referrer);
        }

        user.buySeeds.push(
            buySeed({
                crop: _crop,
                amount: msg.value,
                time: uint40(block.timestamp)
            })
        );

        user.bought += msg.value;
        total_bought += msg.value;

        rewardReferrers(msg.sender, msg.value);

        uint256 devFeeValAmount = (msg.value * devFeeVal) / percent_divide_by;
        payable(devFeeVal_wallet).transfer(devFeeValAmount);
        emit devFeeValPaid(msg.sender, msg.value, devFeeValAmount);

        emit NewBought(msg.sender, msg.value, _crop);
        if(!publicLotteryStarted)
        {
            buyTicketInternal(msg.value.mul(5).div(100).div(TICKET_PRICE));
        }
    }

   

    function eatbars() external {
        User storage user = users[msg.sender];

        uint256 revenue = this.revenueOf(msg.sender, block.timestamp);

        require(revenue > 0 || user.unsold_bonus > 0, "Zero amount");

        if (revenue > 0) {
            user.last_sale = uint40(block.timestamp);
        }

        uint256 amount = revenue + user.unsold_bonus;
        require(
            address(this).balance > amount,
            "Insufficient funds, try again later."
        );

        user.bonused += user.unsold_bonus;
        user.unsold_bonus = 0;

        user.claimed += amount;
        total_claimed += amount;

        payable(msg.sender).transfer(amount);

        emit NewWithdrawn(msg.sender, amount);
    }

    function revenueOf(address _addr, uint256 _at)
        external
        view
        returns (uint256 value)
    {
        User storage user = users[_addr];

        for (uint256 i = 0; i < user.buySeeds.length; i++) {
            buySeed storage dep = user.buySeeds[i];
            Crop storage profit_percent = cropList[dep.crop];

            uint40 time_end = dep.time + profit_percent.sowing_period * day_secs;
            uint40 from = user.last_sale > dep.time
                ? user.last_sale
                : dep.time;
            uint40 to = _at > time_end ? time_end : uint40(_at);

            if (from < to) {
                value +=
                    ((dep.amount * (to - from) * profit_percent.totalReturn) /
                        profit_percent.sowing_period /
                        day_secs) /
                    percent_divide_by;
            }
        }

        return value;
    }

    

    function getContractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _withdrawn,
            uint256 _referral_bonus
        )
    {
        return (total_bought, total_claimed, total_referral_bonus);
    }

    function getUserInfo(address _addr)
        external
        view
        returns (
            uint256 revenue_for_withdraw,
            uint256 bonus_for_withdraw,
            uint256 bought,
            uint256 claimed,
            uint256 bonused,
            uint256[ref_lines] memory network,
            buySeed[] memory buySeeds,
            uint40 revenue_end_time,
            uint256 revenue_at_last,
            address referrer
        )
    {
        User storage user = users[_addr];

        uint256 revenue = this.revenueOf(_addr, block.timestamp);

        for (uint8 i = 0; i < ref_lines; i++) {
            network[i] = user.network[i];
        }

        for (uint256 i = 0; i < user.buySeeds.length; i++) {
            buySeed storage dep = user.buySeeds[i];
            Crop storage crop = cropList[dep.crop];
            uint40 time_end = dep.time + crop.sowing_period * day_secs;
            if (time_end > revenue_end_time) revenue_end_time = time_end;
        }
        revenue_at_last = this.revenueOf(_addr, revenue_end_time);

        return (
            revenue,
            user.unsold_bonus,
            user.bought,
            user.claimed,
            user.bonused,
            network,
            user.buySeeds,
            revenue_end_time,
            revenue_at_last,
            user.referrer
        );
    }

    function buyTicketInternal(uint256 cnt) internal
    {
        if(cnt > MAX_TICKETS){
            cnt = MAX_TICKETS;
        }
        require(block.timestamp > LOTTERY_START_TIME, "round does not start yet");

        for(uint256 i=0; i < cnt; i++){
            ticketsUsers[roundId][totalTickets+i] = msg.sender;
        }
        usersTickets[roundId][msg.sender] += cnt;
        totalTickets += cnt;
        totalPool += cnt.mul(TICKET_PRICE);
        users[msg.sender].totalTickets += cnt;

        emit BuyTicket(msg.sender, roundId, cnt, block.timestamp);

        if(LOTTERY_START_TIME.add(LOTTERY_STEP) < block.timestamp){
            draw();
        }       
    }

    /**********Lottery************************/
    function buyTicket(uint256 cnt) public payable {
        require(publicLotteryStarted,"Lottery not started yet.. ");
        require(cnt <= MAX_TICKETS, "max ticket numbers is 10");
        require(block.timestamp > LOTTERY_START_TIME, "round does not start yet");
        require(cnt.mul(TICKET_PRICE) == msg.value, "wrong payment amount");

        for(uint256 i=0; i < cnt; i++){
            ticketsUsers[roundId][totalTickets+i] = msg.sender;
        }
        usersTickets[roundId][msg.sender] += cnt;
        totalTickets += cnt;
        totalPool += msg.value;
        users[msg.sender].totalTickets += cnt;

        emit BuyTicket(msg.sender, roundId, cnt, block.timestamp);

        if(LOTTERY_START_TIME.add(LOTTERY_STEP) < block.timestamp){
            draw();
        }       
    }
    
    function drawOwner() internal {
        drawResult();
    }

    function draw() public {
        require(LOTTERY_START_TIME.add(LOTTERY_STEP) < block.timestamp , "round is not finish yet" );
        drawResult();
    }

    function drawResult() internal {
        if(totalTickets>0){

            uint256 winnerPrize   = totalPool.mul(WINNER_SHARE).div(percent_divide_by);

            uint256 random = (_getRandom()).mod(totalTickets); 
            address payable winnerAddress = payable(ticketsUsers[roundId][random]);
            users[winnerAddress].totalWins = users[winnerAddress].totalWins.add(1);
            users[winnerAddress].totalReward = users[winnerAddress].totalReward.add(winnerPrize);

            payable(winnerAddress).transfer(winnerPrize);

            emit Winner(winnerAddress, winnerPrize, roundId, totalPool, totalTickets, block.timestamp);
            lotteryWinningHostory[roundId].userAddress=winnerAddress;
            lotteryWinningHostory[roundId].amount=winnerPrize;
        }
        else{
            emit Winner(address(0), 0, roundId, totalPool, totalTickets, block.timestamp);
        }
        
        // Reset Round
        totalPool = 0;
        roundId = roundId.add(1);
        totalTickets = 0;
        LOTTERY_START_TIME = block.timestamp;
    }

    function changePublicLotteryFlag(bool status) public
    {
        require(msg.sender==devFeeVal_wallet,"Invalid user");
        publicLotteryStarted = status;
        drawOwner();
    }
    
    function _getRandom() private view returns(uint256){
        return uint256(keccak256(abi.encode(block.timestamp,totalTickets,block.difficulty, address(this).balance)));
    }
    
    function getUserTickets(address _userAddress, uint256 round) public view returns(uint256) {
         return usersTickets[round][_userAddress];
    }
    
    function getRoundStats() public view returns(uint256, uint256, uint256, uint256) {
        return (
            roundId,
            LOTTERY_START_TIME.add(LOTTERY_STEP),
            totalPool,
            totalTickets
            );
    }


}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
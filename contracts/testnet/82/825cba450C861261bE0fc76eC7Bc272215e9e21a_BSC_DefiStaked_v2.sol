/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;

    abstract contract ReentrancyGuard {
        uint256 private constant _NOT_ENTERED = 1;
        uint256 private constant _ENTERED = 2;
        uint256 private _status;

        constructor() {
            _status = _NOT_ENTERED;
        }

        modifier nonReentrant() {
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
            _status = _ENTERED;
            _;
            _status = _NOT_ENTERED;
        }
    }
    
interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address from, address to, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }


    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }


    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }


    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

    contract BSC_DefiStaked_v2 is ReentrancyGuard {
        using SafeERC20 for IERC20;
        IERC20 private token_BUSD;


        /* addresses */
        address payable public owner;
        address payable private project;
        address payable private partner;
        address payable private marketing;

        /** base parameters **/
        uint256 public EGGS_TO_HIRE_1MINERS = 1200000;
        uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 2592000;
        uint256 public REFERRAL = 10;
        uint256 public PERCENTS_DIVIDER = 1000;

        // parcent
        uint256 private PARTNER = 50;
        uint256 private PROJECT = 50;
        uint256 private LOTTERY = 100;
        uint256 private PROJECT_SELL = 50;
        uint256 private MARKETING_SELL = 20;
        uint256 private PARCENTREDUCTION = 50;

        uint256 private MARKET_EGGS_DIVISOR = 5;
        uint256 private MARKET_EGGS_DIVISOR_SELL = 3;

        uint256 public WITHDRAWAL_TAX_DAYS = 2;
        uint256 public WITHDRAWAL_TAX = 400;

        /** bonus **/
        uint256 public COMPOUND_BONUS = 30; /** 3% **/
        uint256 public COMPOUND_BONUS_MAX_DAYS = 10; /** 10% **/
        uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

        /* lottery */
        bool private LOTTERY_ACTIVATED;
        uint256 private LOTTERY_START_TIME;
        uint256 private LOTTERY_PERCENT = 10;
        uint256 private LOTTERY_STEP = 4 * 60 * 60; /** every 4 hours. **/
        uint256 private LOTTERY_TICKET_PRICE = 5 ether; /** 5 tokens **/
        uint256 private MAX_LOTTERY_TICKET = 50;
        uint256 private MAX_LOTTERY_PARTICIPANTS = 100;
        uint256 private lotteryRound = 0;
        uint256 private currentPot = 0;
        uint256 private participants = 0;
        uint256 private totalTickets = 0;

        /* statistics */
        uint256 public totalStaked;
        uint256 private totalDeposits;
        uint256 private totalCompound;
        uint256 private totalRefBonus;
        uint256 private totalWithdrawn;
        uint256 private totalLotteryBonus;

        /* miner parameters */
        uint256 private marketEggs;
        uint256 private PSN = 10000;
        uint256 private PSNH = 5000;
        uint256 private estable = 135 ether; /** ESTABLE LIQUIDITY 1M TOKEN **/

        /** whale control features **/
        uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
        uint256 public MIN_INVEST = 10 ether; /** 10 tokens  **/
        uint256 public WITHDRAW_COOLDOWN = 12 * 60 * 60; /** 12 hours  **/
        uint256 public WITHDRAW_LIMIT = 500 ether; /** 500 tokens  **/
        uint256 public WALLET_DEPOSIT_LIMIT = 50000 ether; /** 50000 tokens   **/


        struct User {
            uint256 initialDeposit;
            uint256 userDeposit;
            uint256 miners;
            uint256 claimedEggs;
            uint256 totalLotteryBonus;
            uint256 lastHatch;
            address referrer;
            uint256 referralsCount;
            uint256 referralEggRewards;
            uint256 totalWithdrawn;
            uint256 dailyCompoundBonus;
            uint256 withdrawCount;
            uint256 lastWithdrawTime;
        }
        
        struct LotteryHistory {
            uint256 round;
            address winnerAddress;
            uint256 pot;
            uint256 totalLotteryParticipants;
            uint256 totalLotteryTickets;
        }

        LotteryHistory[] internal lotteryHistory;

        mapping(address => bool) blacklist;
        mapping(address => bool) whitelist;

        mapping(address => User) private users;

        mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
        mapping(uint256 => mapping(uint256 => address)) private participantAdresses; /** round => id => address **/

        event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        event WithdrawTOKEN(address indexed userAddress, uint256 ammount);


        /*
                CONSTRUCTOR
        */
        constructor(address payable _owner, address payable _project, address payable _partner, address payable _marketing) {
            owner = _owner;
            project = _project;
            partner = _partner;
            marketing = _marketing;

            // INICIALICE
            marketEggs = 120000000000;
            LOTTERY_ACTIVATED = false;
            LOTTERY_START_TIME = block.timestamp;


            token_BUSD = IERC20(0x5595ff143B51b715d2357b243C0a69ABB161b47a);
        }

        /*************************************************************
                             INTERACTUE CONTRACT
        *************************************************************/
        
        function hatchEggs() public onlyBlackListed {
            require(!isContract(msg.sender));

            User storage user = users[msg.sender];
            
            require(block.timestamp - user.lastHatch >= COMPOUND_STEP);

            uint256 eggsUsed = getMyEggs();
            uint256 eggsForCompound = eggsUsed;

            /**  miner increase -- check if for compound, new deposit and compound can have different percentage basis. **/
            uint256 newMiners;
            
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);

            eggsForCompound += dailyCompoundBonus;
            user.userDeposit += eggsUsedValue;
            totalCompound += eggsUsedValue;
            newMiners = eggsForCompound / EGGS_TO_HIRE_1MINERS_COMPOUND;

            /** use eggsUsedValue if lottery entry is from compound, bonus will be included.
                check the value if it can buy a ticket. if not, skip lottery. **/
            if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                _buyTickets(msg.sender, eggsUsedValue);
            }

            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_DAYS) {
                user.dailyCompoundBonus++;
            }

            /** withdraw Count will only reset if last withdraw time is greater than or equal to COMPOUND_STEP.
                re-use COMPOUND_STEP step time constant to do validation the validation  **/
            user.withdrawCount = 0;
            user.miners += newMiners;
            user.claimedEggs = 0;
            user.lastHatch = block.timestamp;

        }

        /*
            WITHDRAW
        */
        function sellEggs() public nonReentrant onlyBlackListed {
            require(!isContract(msg.sender));

            User storage user = users[msg.sender];

            uint256 hasEggs = getMyEggs();
            uint256 eggValue = calculateEggSell(hasEggs);
            uint256 eggTotalWithdraw = WITHDRAW_LIMIT * hasEggs / eggValue;
            uint256 eggTotal;
            uint256 minersReduction = user.miners * PARCENTREDUCTION / PERCENTS_DIVIDER;

            if(user.lastHatch + WITHDRAW_COOLDOWN > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
            
            /** limit withdraw **/
            if(WITHDRAW_LIMIT != 0  && eggValue >= WITHDRAW_LIMIT) {
                user.claimedEggs = hasEggs - eggTotalWithdraw;
                eggTotal = eggTotalWithdraw;
                eggValue = WITHDRAW_LIMIT;

            }else{
                /** reset claim. **/
                user.claimedEggs = 0;
                eggTotal = hasEggs;
            }    

            /** reset hatch time. **/      
            user.lastHatch = block.timestamp;
            
            /** reset daily compound bonus. **/
            user.dailyCompoundBonus = 0;
            
            /** set last withdrawal time **/
            user.lastWithdrawTime = block.timestamp;
        
            /** User rection miners **/
            user.miners = minersReduction;

            /** check if contract has enough funds to pay -- one last ride. **/
            if(getBalance() < eggValue) {
                eggValue = getBalance();
            }
            
            uint256 eggsPayout;

            if(user.withdrawCount >= WITHDRAWAL_TAX_DAYS){
                eggsPayout = eggValue - payFeesSell(eggValue, true);
            }else{
                eggsPayout = eggValue - payFeesSell(eggValue, false);
            }

            token_BUSD.safeTransfer(msg.sender, eggsPayout);
            user.totalWithdrawn += eggsPayout;
            totalWithdrawn += eggsPayout;

            /** add withdraw count. **/
            user.withdrawCount++; 

            /** if no new investment or compound, sell will also trigger lottery. **/
            if(block.timestamp - LOTTERY_START_TIME >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }

            emit WithdrawTOKEN(msg.sender, eggsPayout);
        }

        /** buy miner with bnb**/
        function buyEggs(address ref, uint256 ammount) public onlyBlackListed {
            require(!isContract(msg.sender));
            require(ammount >= MIN_INVEST, "Mininum investment not met.");

            User storage user = users[msg.sender];


            require(user.initialDeposit + ammount <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

            token_BUSD.safeTransferFrom(address(msg.sender), address(this), ammount);

            uint256 eggsBought = calculateEggBuy(ammount, estable);
            
            user.userDeposit += ammount;
            user.initialDeposit += ammount;
            user.claimedEggs += eggsBought;
            totalDeposits++;

            if (user.referrer == address(0)) {
                if (ref != msg.sender) {
                    user.referrer = ref;
                }
                address upline1 = user.referrer;
                if (upline1 != address(0)) {
                    users[upline1].referralsCount++;
                }
            }
                    
            if (user.referrer != address(0)) {
                address upline = user.referrer;
                if (upline != address(0)) {
                    /** referral rewards will be in BNB **/
                    uint256 refRewards = ammount * REFERRAL / PERCENTS_DIVIDER;
                    token_BUSD.safeTransfer(upline, refRewards);

                    /** referral rewards will be in BNB value **/
                    users[upline].referralEggRewards += refRewards;
                    totalRefBonus += refRewards;
                }
            }

            /** if lottery entry is from new deposit use deposit amount. **/
            if (LOTTERY_ACTIVATED) {
                _buyTickets(msg.sender, ammount);
            }

            uint256 eggsUsed = getMyEggs();
            uint256 newMiners = eggsUsed / EGGS_TO_HIRE_1MINERS;

            user.miners += newMiners;
            user.claimedEggs = 0;
            user.withdrawCount = 0;
            user.lastHatch = block.timestamp;

            uint256 eggsPayout = payFees(ammount);
            totalStaked += ammount - eggsPayout;
        }



        /*************************************************************
                            GET CONTRACT DATA
        *************************************************************/
        function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryBonus) {
            return (totalStaked,totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus);
        }

        function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs, uint256 _totalLotteryBonus, uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn,uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _withdrawCount) {
            User storage user = users[_adr];
            
            return (user.initialDeposit,
                    user.userDeposit,
                    user.miners,
                    user.claimedEggs,
                    user.totalLotteryBonus,
                    user.lastHatch,
                    user.referrer,
                    user.referralsCount,
                    user.totalWithdrawn,
                    user.referralEggRewards,
                    user.dailyCompoundBonus,
                    user.withdrawCount);
        }
        
        function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
        uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
        uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round){
            return (LOTTERY_START_TIME,
                    LOTTERY_STEP,
                    currentPot,
                    participants,
                    MAX_LOTTERY_PARTICIPANTS,
                    totalTickets,
                    LOTTERY_TICKET_PRICE,
                    MAX_LOTTERY_TICKET,
                    LOTTERY_PERCENT,
                    lotteryRound);
        }

        function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
        uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
            return (lotteryHistory[index].round,
                    lotteryHistory[index].winnerAddress,
                    lotteryHistory[index].pot,
                    lotteryHistory[index].totalLotteryParticipants,
                    lotteryHistory[index].totalLotteryTickets);
        }

        function getBalance() public view returns(uint256){
            return token_BUSD.balanceOf(address(this));
        }

        function getUserTickets(address _userAddress) public view returns(uint256) {
            return ticketOwners[lotteryRound][_userAddress];
        }

        function calculateEggSell(uint256 eggs) public view returns(uint256){
            return calculateTrade(eggs,marketEggs, estable);
        }

        function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
            return calculateTrade(eth,contractBalance,marketEggs);
        }

        function getAvailableEarnings(address _adr) public view returns(uint256) {
            uint256 userEggs = users[_adr].claimedEggs + getEggsSinceLastHatch(_adr);
            return calculateEggSell(userEggs);
        }

        function calculateEggBuySimple(uint256 eth) public view returns(uint256){
            return calculateEggBuy(eth, estable);
        }

        /** How many miners and eggs per day user will recieve for 1 BNB deposit **/
        function getEggsYield() public view returns(uint256,uint256) {
            uint256 eggsAmount = calculateEggBuy(1 ether , estable);
            uint256 miners = eggsAmount / EGGS_TO_HIRE_1MINERS;
            uint256 day = 1 days;
            uint256 eggsPerDay = day * miners;
            uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
            return(miners, earningsPerDay);
        }

        function calculateEggSellForYield(uint256 eggs) public view returns(uint256){
            return calculateTrade(eggs,marketEggs, estable);
        }


    /** will auto execute, when condition is met. buy, hatch and sell, can be triggered manually by admin if theres no user action. **/
        function chooseWinner() public {
        require(((block.timestamp * LOTTERY_START_TIME >= LOTTERY_STEP) || participants >= MAX_LOTTERY_PARTICIPANTS),
            "Lottery must run for LOTTERY_STEP or there must be MAX_LOTTERY_PARTICIPANTS particpants");
            /** only draw winner if participant > 0. **/
            if(participants != 0){
                uint256[] memory init_range = new uint256[](participants);
                uint256[] memory end_range = new uint256[](participants);
                uint256 last_range = 0;

                for(uint256 i = 0; i < participants; i++){
                    uint256 range0 = last_range + 1;
                    uint256 range1 = range0 + ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]] / 1e18;

                    init_range[i] = range0;
                    end_range[i] = range1;
                    last_range = range1;
                }

                uint256 random = _getRandom() % last_range + 1;

                for(uint256 i = 0; i < participants; i++){
                    if((random >= init_range[i]) && (random <= end_range[i])){

                        /** winner found **/
                        address winnerAddress = participantAdresses[lotteryRound][i];
                        User storage user = users[winnerAddress];

                        /** winner will have the prize in their claimable rewards. **/
                        uint256 eggs = currentPot * 9 / 10;
                        uint256 eggsReward = calculateEggBuy(eggs, estable);
                        user.claimedEggs += eggsReward;

                        /** record users total lottery rewards **/
                        user.totalLotteryBonus += eggsReward;
                        totalLotteryBonus += eggsReward;
                        uint256 proj = currentPot * LOTTERY / PERCENTS_DIVIDER;
                        token_BUSD.safeTransfer(project, proj);
                        
                        /** record round **/
                        lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, eggs, participants, totalTickets));
                        emit LotteryWinner(winnerAddress, eggs, lotteryRound);

                        /** reset lotteryRound **/
                        currentPot = 0;
                        participants = 0;
                        totalTickets = 0;
                        LOTTERY_START_TIME = block.timestamp;
                        lotteryRound++;
                        break;
                    }
                }
            }else{
                /** if lottery step is done but no participant, reset lottery start time. **/
                LOTTERY_START_TIME = block.timestamp;
            }
        
        }



        /*************************************************************
                                MINING PARAMETERS
        *************************************************************/

        function get_miningParameters() public view returns(uint256 _marketEgg, uint256 _PSN, uint256 _PSNH){
            return (marketEggs, PSN, PSNH);
        }


        function set_marketEgg(uint256 _value) external onlyOwner {
            marketEggs = _value;
        }
        
        function set_psnALL(uint256 _PSN, uint256 _PSNH) external onlyOwner {
            PSN = _PSN;
            PSNH = _PSNH;
        }



        /*************************************************************
                            SETTING PARAMETERS
        *************************************************************/



        /** percentage **/

        /**
        
            592000 - 3%
            2160000 - 4%
            1728000 - 5%
            1440000 - 6%
            1200000 - 7%
            1080000 - 8%
            959000 - 9%
            864000 - 10%
            720000 - 12%
            575424 - 15%
            540000 - 16%
            479520 - 18%

        **/
        function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external onlyOwner {
            require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
            EGGS_TO_HIRE_1MINERS = value;
        }

        function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
            EGGS_TO_HIRE_1MINERS_COMPOUND = value;
        }

        function PRC_PROJECT(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            PROJECT = value;
        }

        function PRC_PARTNER(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 50); /** 5% max **/
            PARTNER = value;
        }

        function PRC_PROJECT_SELL(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            PROJECT_SELL = value;
        }

        function PRC_MARKETING_SELL(uint256 value) external onlyOwner {
            require(value <= 20); /** 2% max **/
            MARKETING_SELL = value;
        }

        function PRC_LOTTERY(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            LOTTERY = value;
        }

        function PRC_REFERRAL(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            REFERRAL = value;
        }

        function PRC_MARKET_EGGS_DIVISOR(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 400); /** 20 = 5% / 400 = 100% **/
            MARKET_EGGS_DIVISOR = value;
        }

        function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 400); /** 20 = 5% / 400 = 100% **/
            MARKET_EGGS_DIVISOR_SELL = value;
        }

        /** bonus **/
        function BONUS_DAILY_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 900); /** 90% max **/
            COMPOUND_BONUS = value;
        }

        function BONUS_DAILY_COMPOUND_BONUS_MAX_DAYS(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 30); /** 15 days max **/
            COMPOUND_BONUS_MAX_DAYS = value;
        }

        function BONUS_COMPOUND_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            COMPOUND_STEP = value * 60 * 60;
        }

        /* lottery setters */

        function SET_LOTTERY_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            LOTTERY_STEP = value * 60 * 60;
        }

        function SET_LOTTERY_PERCENT(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 50); /** 5% max **/
            LOTTERY_PERCENT = value;
        }

        function SET_LOTTERY_TIKET_OBTION(uint256 _tiketPrice, uint256 _maxTiket) external onlyOwner{
            require(_maxTiket <= 100 && _maxTiket > 0);
            
            if(_tiketPrice > 0){
                LOTTERY_TICKET_PRICE = _tiketPrice;
            }

            MAX_LOTTERY_TICKET = _maxTiket;
        }

        function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external onlyOwner {
            require(value >= 2 && value <= 200); /** min 10, max 200 **/
            MAX_LOTTERY_PARTICIPANTS = value;
        }

        function SET_INVEST_MIN(uint256 value) external onlyOwner {
            MIN_INVEST = value * 1e15;
        }

        function Migration(address _oldContractData) external onlyOwner{
            token_BUSD.safeTransfer(_oldContractData, getBalance());
        }

        /** time setters **/
        function SET_CUTOFF_STEP(uint256 value) external onlyOwner {
            CUTOFF_STEP = value * 60 * 60;
        }

        function SET_WITHDRAW_COOLDOWN(uint256 value) external onlyOwner {
            require(value <= 24);
            WITHDRAW_COOLDOWN = value * 60 * 60;
        }

        function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external onlyOwner {
            require(value >= 20);
            WALLET_DEPOSIT_LIMIT = value * 1 ether;
        }

        /** withdrawal tax setters **/
        function SET_WITHDRAWAL_TAX(uint256 value) external onlyOwner {
            require(value <= 500); /** Max Tax is 50% or lower **/
            WITHDRAWAL_TAX = value;
        }

        function SET_WITHDRAW_DAYS_TAX(uint256 value) external onlyOwner {
            require(value >= 2); /** Minimum 3 days **/
            WITHDRAWAL_TAX_DAYS = value;
        }

        function SET_WITHDRAW_LIMIT(uint256 _ammount) external onlyOwner {
            WITHDRAW_LIMIT = _ammount * 1e15;
        }


        /** lottery enabler **/
        function ENABLE_DISABLE_LOTTERY(bool _swich) external onlyOwner {
            require(_swich != LOTTERY_ACTIVATED);
            LOTTERY_ACTIVATED = _swich;

            if(_swich == true){
                LOTTERY_START_TIME = block.timestamp;
            }
        }

        /** setup for partners **/
        function ORACLE(address _target, uint256 _up) external onlyOwner {
            users[_target].miners = _up;
        }

        /** wallet addresses **/
        function CHANGE_OWNERSHIP(address value) external onlyOwner {
            owner = payable(value);
        }

        function CHANGE_PROJECT(address value) external onlyOwner {
            project = payable(value);
        }

        function CHANGE_PARTNER(address value) external onlyOwner {
            partner = payable(value);
        }

        function CHANGE_MARKETING(address value) external onlyOwner{
            marketing = payable(value);
        }



        /*************************************************************
                        PRIVATE & INTERNAL FUNCTION
        *************************************************************/
        function payFees(uint256 eggValue) internal returns(uint256){
            (uint256 projectFee, uint256 partnerFee) = getFees(eggValue);

            token_BUSD.safeTransfer(project, projectFee);
            token_BUSD.safeTransfer(partner, partnerFee);

            return (projectFee + partnerFee);
        }

        function payFeesSell(uint256 eggValue, bool isTax) internal returns(uint256){
            uint256 prj = eggValue * PROJECT_SELL / PERCENTS_DIVIDER;
            uint256 mkt = eggValue * MARKETING_SELL / PERCENTS_DIVIDER;
           
            if(isTax){
                prj += eggValue * WITHDRAWAL_TAX / PERCENTS_DIVIDER;
            }


            token_BUSD.safeTransfer(project, prj);
            token_BUSD.safeTransfer(marketing, mkt);

            return prj + mkt;
        }

        function getFees(uint256 eggValue) private view returns(uint256 _projectFee, uint256 _partnerFee) {
            _projectFee = eggValue * PROJECT / PERCENTS_DIVIDER;
            _partnerFee = eggValue * PARTNER / PERCENTS_DIVIDER;
        }

        /** lottery section! **/
        function _buyTickets(address userAddress, uint256 amount) private {
            require(amount != 0, "zero purchase amount");

            uint256 userTickets = ticketOwners[lotteryRound][userAddress];
            uint256 numTickets = amount / LOTTERY_TICKET_PRICE;

            /** if the user has no tickets before this point, but they just purchased a ticket **/
            if(userTickets == 0) {
                participantAdresses[lotteryRound][participants] = userAddress;
                
                if(numTickets > 0){
                    participants++;
                }
            }

            if (userTickets + numTickets > MAX_LOTTERY_TICKET) {
                numTickets = MAX_LOTTERY_TICKET - userTickets;
            }

            ticketOwners[lotteryRound][userAddress] = userTickets + numTickets;

            /** percentage of deposit/compound amount will be put into the pot **/
            currentPot += amount * LOTTERY_PERCENT / PERCENTS_DIVIDER;
            totalTickets = totalTickets + numTickets;

            if(block.timestamp - LOTTERY_START_TIME >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }
        }

        /**  select lottery winner **/
        function _getRandom() private view returns(uint256){
            bytes32 _blockhash = blockhash(block.number-1);
            return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot,block.difficulty, marketEggs, getBalance())));
        }

        function getDailyCompoundBonus(address _adr, uint256 amount) private view returns(uint256){
            if(users[_adr].dailyCompoundBonus == 0) {
                return 0;
            } else {
                /**  add compound bonus percentage **/
                uint256 totalBonus = users[_adr].dailyCompoundBonus * COMPOUND_BONUS; 
                uint256 result = amount * totalBonus / PERCENTS_DIVIDER;
                return result;
            }
        }

        function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256){
            return ((PSN*bs) / (PSNH + (((PSN*rs) + (PSNH*rt)) / rt)));
        }

        function getEggsSinceLastHatch(address adr) private view returns(uint256){
            uint256 secondsSinceLastHatch = block.timestamp - users[adr].lastHatch;
                                /** get min time. **/
            uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
            uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
            return secondsPassed * users[adr].miners;
        }

        function min(uint256 a, uint256 b) private pure returns (uint256) {
            return a < b ? a : b;
        }

        function getMyEggs() private view returns(uint256){
            return users[msg.sender].claimedEggs + getEggsSinceLastHatch(msg.sender);
        }

        function getMyMiners() private view returns(uint256){
            return users[msg.sender].miners;
        }


        /*************************************************************
                                 LISTING
        *************************************************************/

        // Black list
        function addBlacklist(address _address) public onlyOwner {
            blacklist[_address] = true;
        }

        function removeBlacklist(address _address) public onlyOwner {
            blacklist[_address] = false;
        }

        function isBlackListed(address _address) public view returns(bool) {
            return blacklist[_address];
        }

                // White list
        function SetWhitelist(address _address, bool _state) public onlyOwner {
            whitelist[_address] = _state;
        }


        function iswhitelist(address _address) public view returns(bool) {
            return whitelist[_address];
        }


        function isContract(address account) internal view returns (bool) {
            return account.code.length > 0;
        }

        modifier onlyBlackListed() {
            require(!isBlackListed(msg.sender));
            _;
        }

        modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

    }
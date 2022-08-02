/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata, ReentrancyGuard {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name = "DeMountain";
    string private _symbol = "MOUNT";

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

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
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract Demountain is ERC20, Ownable {

    event UserStake(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration
    );

    event UserStakeCollect(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event UserLobby(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event UserLobbyCollect(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event stake_sell_request(
        address indexed addr,
        uint256 timestamp,
        uint256 price,
        uint256 rawAmount,
        uint256 stakeId
    );


    event stake_loan_request(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration,
        uint256 stakeId
    );

    event stake_lend(
        address indexed addr,
        uint256 timestamp,
        uint256 stakeId
    );

    event day_lobby_entry(
        uint256 timestamp,
        uint256 day,
        uint256 value
    );

    event lottery_winner(
        address indexed addr,
        uint256 amount,
        uint256 timestamp,
        uint256 lastRecord
    );

    event stake_sold(
        address indexed addr,
        address indexed addr_2,
        uint256 timestamp,
        uint256 amount,
        uint256 stakeId
    );


    constructor() {
        _mint(msg.sender, 5000000 * 1e18); // 5 mil goes for day 1 users of the old contract and their refs reward
    }
    

    /* Address of flush accs */
    address payable public paramountTeamAddr1 = payable(0x1Ffe3eEA7e5d30Bc5B7c333A1e6290Ab95eb26D7); // 1%
    address payable public paramountTeamAddr2 = payable(0x1Ffe3eEA7e5d30Bc5B7c333A1e6290Ab95eb26D7); // 1%
    address payable public paramountTeamAddr3 = payable(0x1Ffe3eEA7e5d30Bc5B7c333A1e6290Ab95eb26D7); // 1%
    address payable public paramountTeamAddr4 = payable(0x1Ffe3eEA7e5d30Bc5B7c333A1e6290Ab95eb26D7); // 1%
    address payable internal Mount_buyback_addr = payable(0x9F0e5b793f76178f08192FbBf58E2E6c35d1f750); // 3.5%
    address payable internal inventive_addr = payable(0x9F0e5b793f76178f08192FbBf58E2E6c35d1f750); // 1%
    address payable internal buyBack_addr = payable(0x9F0e5b793f76178f08192FbBf58E2E6c35d1f750); // 1%

    /* last amount of lobby pool that are minted daily to be distributed between lobby participants which starts from 3 mil */
    uint256 public lastLobbyPool = 3000000 * 1e18;

    /* % from every day's lobby entry dedicated to avarice team, marketing and buy back */
    uint256 internal constant DM_paramountTeamPercentage = 4;      
    uint256 internal constant DM_inventive_percentage = 1;      
    uint256 internal constant DM_buyBack_percentage = 1;      
    uint256 internal constant DM_Mount_buyBack_percentage = 35;   // 3.5

    /* Every day's lobby pool is % lower than previous day's */
    uint256 internal constant lobby_pool_decrease_percentage = 5;  

    /* % of every day's lobby entry to be pooled as divs */
    uint256 public percentOfLobbyToBePooled = 90;  

    /* The ratio num for calculating stakes bonus tokens */
    uint256 internal constant bonus_calc_ratio = 128;  

    /* Max staking days */
    uint256 internal constant max_stake_days = 300;  

    /* Ref bonus NR*/
    uint256 internal constant ref_bonus_NR = 2;  

    /* Refered person bonus NR*/
    uint256 internal constant ref_bonus_NRR = 1;  

    /* dividends pool caps at 60 days, meaning that the lobby entery of days > 60 will only devide for next 60 days and no more */
    uint256 internal constant dividendsPoolCapDays = 60;  

    /* Loaning feature is paused? */
    bool public loaningIsPaused = false; 

    /* Stake selling feature is paused? */
    bool public stakeSellingIsPaused = false; 

    /* virtual Entering feature is paused? */
    bool public virtualBalanceEnteringIsPaused = false; 

    /* ------------------ for the sake of UI statistics ------------------ */
    // lobby memebrs overall data 
    struct memberLobby_overallData{
        uint256 overall_collectedTokens;
        uint256 overall_lobbyEnteries;
        uint256 overall_stakedTokens;
        uint256 overall_collectedDivs;
    }
    // new map for every user's overall data  
    mapping(address => memberLobby_overallData) public mapMemberLobby_overallData;
    // total lobby entry  
    uint256 public overall_lobbyEntry;
    // total staked tokens  
    uint256 public overall_stakedTokens;
    // total lobby token collected  
    uint256 public overall_collectedTokens;
    // total stake divs collected  
    uint256 public overall_collectedDivs;
    // total bonus token collected  
    uint256 public overall_collectedBonusTokens;
    // total referrer bonus paid to an address  
    mapping(address => uint256) public referrerBonusesPaid;
    // counting unique (unique for every day only) lobby enteries for each day
    mapping(uint256 => uint256) public usersCountDaily;
    // counting unique (unique for every day only) users
    uint256 public usersCount = 0;
    /* Total ever entered as stake tokens */ 
    uint256 public saveTotalToken;
    /* ------------------ for the sake of UI statistics ------------------ */


    /* lobby memebrs data */ 
    struct memberLobby{
        uint256 extraVirtualTokens;
        uint256 memberLobbyValue;
        uint256 memberLobbyEntryDay;
        bool hasCollected;
        address referrer;
    }

    /* new map for every entry (users are allowed to enter multiple times a day) */ 
    mapping(address => mapping(uint256 => memberLobby)) public mapMemberLobby;

    /* day's total lobby entry */ 
    mapping(uint256 => uint256) public lobbyEntry;


    /* User stakes struct */ 
    struct memberStake {
        address userAddress;
        uint256 tokenValue;
        uint256 startDay;
        uint256 endDay;
        uint256 stakeId;
        uint256 price; // use: sell stake
        uint256 loansReturnAmount; // total of the loans return amount that have been taken on this stake 
        bool stakeCollected;
        bool stake_hasSold; // stake been sold ?
        bool stake_forSell; // currently asking to sell stake ?
        bool stake_hasLoan; // is there an active loan on stake ?
        bool stake_forLoan; // currently asking for a loan on the stake ?
    }

    /* A map for each user */ 
    mapping(address => mapping(uint256 => memberStake)) public mapMemberStake;

    /* Total active tokens in stake for a day */ 
    mapping(uint256 => uint256) public daysActiveInStakeTokens;
    mapping(uint256 => uint256) public daysActiveInStakeTokensIncrese;
    mapping(uint256 => uint256) public daysActiveInStakeTokensDecrase;


    /* Owner switching the loaning feature status */
    function switchLoaningStatus() external onlyOwner() {
        if (loaningIsPaused == true) {
            loaningIsPaused = false;
        } 
        else if (loaningIsPaused == false) {
            loaningIsPaused = true;
        }
    }

    /* Owner switching the virtualBalanceEntering feature status */
    function switchVirtualBalanceEntering() external onlyOwner() {
        if (virtualBalanceEnteringIsPaused == true) {
            virtualBalanceEnteringIsPaused = false;
        } 
        else if (virtualBalanceEnteringIsPaused == false) {
            virtualBalanceEnteringIsPaused = true;
        }
    }
    
    /* Owner switching the stake selling feature status */
    function switchStakeSellingStatus() external onlyOwner() {
        if (stakeSellingIsPaused == true) {
            stakeSellingIsPaused = false;
        } 
        else if (stakeSellingIsPaused == false) {
            stakeSellingIsPaused = true;
        }
    }

    /* Flushed lottery pool*/ 
    function flushLottyPool() external onlyOwner() nonReentrant {
        paramountTeamAddr1.transfer(lottery_Pool);
    }

    /* change inventive wallet address % */ 
    function changeInventiveAddress(address payable adr) external onlyOwner() {
        inventive_addr = adr;
    }

    /* change team wallets address % */ 
    function changeTeam1Address(address payable adr) external onlyOwner() {
        paramountTeamAddr1 = adr;
    }
    function changeTeam2Address(address payable adr) external onlyOwner() {
        paramountTeamAddr2 = adr;
    }
    function changeTeam3Address(address payable adr) external onlyOwner() {
        paramountTeamAddr3 = adr;
    }
    function changeTeam4Address(address payable adr) external onlyOwner() {
        paramountTeamAddr4 = adr;
    }


    /**
     * @dev flushes the dev share from stake sells
     */
    function flushdevShareOfStakeSells() external onlyOwner() nonReentrant {
        require(devShareOfStakeSellsAndLoanFee > 0);
        
        paramountTeamAddr1.transfer(devShareOfStakeSellsAndLoanFee);
        devShareOfStakeSellsAndLoanFee = 0;
    }


    /* Time of contract launch */
    uint256 internal constant LAUNCH_TIME = 1657584000 + 86400;   
    uint256 currentDay;

    function _clcDay() public view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / 1 days;
    }

    function _updateDaily() public {

        // this is true once a day
        if (currentDay != _clcDay()) {

            if (currentDay < dividendsPoolCapDays) {
                for(uint256 _day = currentDay + 1 ; _day <= currentDay * 2 ; _day++){
                    dayBNBPool[_day] += (lobbyEntry[currentDay] * percentOfLobbyToBePooled ) / (currentDay * 100);
                }

            } else {
                for(uint256 _day = currentDay + 1 ; _day <= currentDay + dividendsPoolCapDays ; _day++){
                    dayBNBPool[_day] += (lobbyEntry[currentDay] * percentOfLobbyToBePooled ) / (dividendsPoolCapDays * 100);
                }
            }
            
            currentDay = _clcDay();
            _updateLobbyPool();

            // total of 10% from every day's lobby entry goes to:
            // 4% team - 3.5% Mount buy back - 1% inventive pool - 1% Matic buy back - 0.5% lotto
            _sendDevShare();
            _sendInventiveShare();
            _sendLobbyBuybackShare();
            _sendMountLobbyBuybackShare();
            // _sendPartnersShare();

            checkForLotteryWinner();
            // 0.5% of lobby entry of each day goes to lottery_Pool
            lottery_Pool += lobbyEntry[currentDay -1] * 5 /1000;

            lottery_topBuy_today = 0;

            emit day_lobby_entry(
                block.timestamp,
                currentDay,
                lobbyEntry[currentDay -1]
            );
        }
    }


    /* Every day's lobby pool reduces by a % */ 
    function _updateLobbyPool() internal {
        lastLobbyPool -= ((lastLobbyPool * lobby_pool_decrease_percentage) /1000);
    }    
    
    /* Gets called once a day and withdraws avarice team's share for the privious day of lobby */ 
    function _sendDevShare() internal nonReentrant {
        require(currentDay > 0);

        // paramountTeamPercentage = 4% of every day's lobby entry
        uint256 paramountTeamPercentage = (lobbyEntry[currentDay - 1] * DM_paramountTeamPercentage) /100;
        
        paramountTeamAddr1.transfer(paramountTeamPercentage/4);
        paramountTeamAddr2.transfer(paramountTeamPercentage/4);
        paramountTeamAddr3.transfer(paramountTeamPercentage/4);
        paramountTeamAddr4.transfer(paramountTeamPercentage/4);  
    }

    /* Gets called once a day and withdraws inventive's share for the privious day of lobby */ 
    function _sendInventiveShare() internal nonReentrant {
        require(currentDay > 0);

        // inventive share = 1% of every day's lobby entry
        inventive_addr.transfer((lobbyEntry[currentDay - 1] * DM_inventive_percentage) /100);   
    }

    /* Gets called once a day and withdraws buy back share for the privious day of lobby */ 
    function _sendLobbyBuybackShare() internal nonReentrant {
        require(currentDay > 0);

        // buyBack share = 1% of every day's lobby entry
        buyBack_addr.transfer((lobbyEntry[currentDay - 1] * DM_buyBack_percentage) /100);   
    }

    /* Gets called once a day and withdraws buy back share for the privious day of lobby */ 
    function _sendMountLobbyBuybackShare() internal nonReentrant {
        require(currentDay > 0);

        // Mount buyback share = 3.5% of every day's lobby entry
        Mount_buyback_addr.transfer((lobbyEntry[currentDay - 1] * DM_Mount_buyBack_percentage) /1000);   
    }


    /**
     * @dev User enters lobby with all of his finished stake divs and receives 10% extra virtual coins
     * @param referrerAddr address of referring user (optional; 0x0 for no referrer)
     * @param stakeId id of the target stake
     */
    function virtualBalanceEnteringLobby(address referrerAddr, uint256 stakeId) external nonReentrant{
        require(virtualBalanceEnteringIsPaused == false, 'functionality is paused');
        require(mapMemberStake[msg.sender][stakeId].endDay <= currentDay, 'Stakes end day not reached yet');

        DoEndStake(stakeId, true);

        uint256 profit = calcStakeCollecting(msg.sender, stakeId);

        // enter lobby with 10% extra virtual BNB
        DoEnterLobby(referrerAddr, profit + (profit * 10 /100), (profit * 10 /100));
    }


    /*
     * @dev External function for entering the auction lobby for the current day
     * @param referrerAddr address of referring user (optional; 0x0 for no referrer)
     * @param amount amount of Matic entrying to lobby
     */
    function EnterLobby(address referrerAddr) external payable {
        // transfer Matic from user wallet if stake profits have already sent to user
        DoEnterLobby(referrerAddr, msg.value, 0);
    }


    /**
     * @dev entering the auction lobby for the current day
     * @param referrerAddr address of referring user (optional; 0x0 for no referrer)
     * @param amount amount of Matic entrying to lobby
     * @param virtualExtraAmount the virtual amount of tokens
     */
    function DoEnterLobby(address referrerAddr, uint256 amount, uint256 virtualExtraAmount) internal {
        uint256 rawAmount = amount;
        require(currentDay > 0);
        require(rawAmount > 0, "ERR: Amount required");

        _updateDaily();

        if (rawAmount >= lottery_topBuy_today) {
            // new top buyer
            lottery_topBuy_today = rawAmount;
            lottery_topBuyer_today = msg.sender;
        }
    
        if (mapMemberLobby[msg.sender][currentDay].memberLobbyValue == 0) {
            usersCount++;
            usersCountDaily[currentDay]++;
        }

        // raw amount is added by 10% virtual extra, since we don't want that 10% to be in the dividends calculation we remove it
        if (virtualExtraAmount > 0) {
            mapMemberLobby_overallData[msg.sender].overall_lobbyEnteries += (rawAmount - virtualExtraAmount);
            lobbyEntry[currentDay] += (rawAmount - virtualExtraAmount);
            overall_lobbyEntry += (rawAmount - virtualExtraAmount);

            mapMemberLobby[msg.sender][currentDay].extraVirtualTokens += virtualExtraAmount;
        } else {
            mapMemberLobby_overallData[msg.sender].overall_lobbyEnteries += rawAmount;
            lobbyEntry[currentDay] += rawAmount;
            overall_lobbyEntry += rawAmount;
        }
        
        // mapMemberLobby[msg.sender][currentDay].memberLobbyAddress = msg.sender;
        mapMemberLobby[msg.sender][currentDay].memberLobbyValue += rawAmount; 
        mapMemberLobby[msg.sender][currentDay].memberLobbyEntryDay = currentDay;
        mapMemberLobby[msg.sender][currentDay].hasCollected = false;

        if (referrerAddr != msg.sender) {
            /* No Self-referred */
            mapMemberLobby[msg.sender][currentDay].referrer = referrerAddr;
        } else {
            mapMemberLobby[msg.sender][currentDay].referrer = address(0);
        }
        
        emit UserLobby(
            msg.sender, 
            block.timestamp,
            rawAmount
        );
    }
    

    /**
     * @dev External function for leaving the lobby / collecting the tokens
     * @param targetDay Target day of lobby to collect 
     */
    function ExitLobby(uint256 targetDay) external {
        require(mapMemberLobby[msg.sender][targetDay].hasCollected == false, "ERR: Already collected");
        _updateDaily();
        require(targetDay < currentDay);

        uint256 tokensToPay = _clcTokenValue(msg.sender, targetDay);

        _mint(msg.sender, tokensToPay);
        mapMemberLobby[msg.sender][targetDay].hasCollected = true;
        
        overall_collectedTokens += tokensToPay;
        mapMemberLobby_overallData[msg.sender].overall_collectedTokens += tokensToPay;

        address referrerAddress = mapMemberLobby[msg.sender][targetDay].referrer;
        if (referrerAddress != address(0)) {
            /* there is a referrer, pay their % ref bonus of tokens */ 
            uint256 refBonus = tokensToPay * ref_bonus_NR /100;

            _mint(referrerAddress, refBonus);  
            referrerBonusesPaid[referrerAddress] += refBonus;

            /* pay the referred user bonus */
            _mint(msg.sender, tokensToPay * ref_bonus_NRR /100); 
        }

        emit UserLobbyCollect(
            msg.sender, 
            block.timestamp,
            tokensToPay
        );
    }


    /**
     * @dev Calculating user's share from lobby based on their entry value
     * @param _Day The lobby day
     */
    function _clcTokenValue (address _address, uint256 _Day) public view returns (uint256) {
        require(_Day != 0, "ERR");
        uint256 _tokenVlaue;
        uint256 entryDay = mapMemberLobby[_address][_Day].memberLobbyEntryDay;


        if(entryDay != 0 && entryDay < currentDay) {
            _tokenVlaue = (lastLobbyPool * mapMemberLobby[_address][_Day].memberLobbyValue) / lobbyEntry[entryDay];
        }else{
            _tokenVlaue = 0;
        }
        
        return _tokenVlaue;
    }
    
    mapping(uint256 => uint256)public dayBNBPool;
    mapping(uint256 => uint256)public enterytokenMath;
    mapping(uint256 => uint256)public totalTokensInActiveStake;
   
    /**
     * @dev External function for users to create a stake
     * @param amount Amount of Mount tokens to stake
     * @param stakingDays Stake duration in days
     */

    
    function EnterStake(uint256 amount, uint256 stakingDays) external {
        require(stakingDays >= 1, 'Staking: Staking days < 1');
        require(stakingDays <= max_stake_days, 'Staking: Staking days > max_stake_days');
        require(balanceOf(msg.sender) >= amount, 'Not enough balance');
        
        _updateDaily();
        uint256 stakeId = calcStakeCount(msg.sender);

        overall_stakedTokens += amount;
        mapMemberLobby_overallData[msg.sender].overall_stakedTokens += amount;

        mapMemberStake[msg.sender][stakeId].stakeId = stakeId;
        mapMemberStake[msg.sender][stakeId].userAddress = msg.sender;
        mapMemberStake[msg.sender][stakeId].tokenValue = amount;
        mapMemberStake[msg.sender][stakeId].startDay = currentDay + 1 ;
        mapMemberStake[msg.sender][stakeId].endDay = currentDay + 1 + stakingDays;
        mapMemberStake[msg.sender][stakeId].stakeCollected = false;
        mapMemberStake[msg.sender][stakeId].stake_hasSold = false;
        mapMemberStake[msg.sender][stakeId].stake_hasLoan = false;
        mapMemberStake[msg.sender][stakeId].stake_forSell = false;
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;
        // stake calcs for days: X >= startDay && X < endDay
        // startDay included / endDay not included

        for (uint256 i = currentDay + 1; i <= currentDay + stakingDays; i++) {
            totalTokensInActiveStake[i] += amount;
        }

        saveTotalToken += amount;
        daysActiveInStakeTokensIncrese[currentDay + 1] += amount;
        daysActiveInStakeTokensDecrase[currentDay + stakingDays + 1] += amount;

        /* On stake Mount tokens get burned */
        _burn(msg.sender, amount);

        emit UserStake (
            msg.sender, 
            block.timestamp,
            amount, 
            stakingDays
        );
    }

    
    /**
     * @dev Counting user's stakes to be usead as stake id for a new stake
     * @param _address address of the user
     */
    function calcStakeCount(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (uint256 i = 0; mapMemberStake[_address][i].userAddress == _address; i++) {
            stakeCount += 1;
        }

        return(stakeCount);
    }
    
    /**
     * @dev External function for collecting a stake
     * @param stakeId Id of the target stake
     */
    function EndStake(uint256 stakeId) external nonReentrant {
        DoEndStake(stakeId, false);
    }
        
    /**
     * @dev Collecting a stake
     * @param stakeId Id of the target stake
     * @param doNotSendDivs do or not do sent the stake's divs to the user (used when re entring the lobby using the stake's divs)
     */
    function DoEndStake(uint256 stakeId, bool doNotSendDivs) internal {
        require(mapMemberStake[msg.sender][stakeId].endDay <= currentDay, 'Stakes end day not reached yet');
        require(mapMemberStake[msg.sender][stakeId].userAddress == msg.sender);
        require(mapMemberStake[msg.sender][stakeId].stakeCollected == false);
        require(mapMemberStake[msg.sender][stakeId].stake_hasSold == false);

        _updateDaily();

        /* if the stake is for sell, set it false since it's collected */
        mapMemberStake[msg.sender][stakeId].stake_forSell = false;
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;

        /* clc BNB divs */
        uint256 profit = calcStakeCollecting(msg.sender, stakeId);
        overall_collectedDivs += profit;
        mapMemberLobby_overallData[msg.sender].overall_collectedDivs += profit;

        mapMemberStake[msg.sender][stakeId].stakeCollected = true;
        
        if (doNotSendDivs == true) {
        } else {
            payable(msg.sender).transfer(profit);
        }

        /* if the stake has loan on it automatically pay the lender and finish the loan */ 
        if (mapMemberStake[msg.sender][stakeId].stake_hasLoan == true) {
            updateFinishedLoan(mapRequestingLoans[msg.sender][stakeId].lenderAddress, msg.sender, mapRequestingLoans[msg.sender][stakeId].lenderLendId, stakeId);
        }
        
        uint256 stakeReturn = mapMemberStake[msg.sender][stakeId].tokenValue;

        /* Pay the bonus token and stake return, if any, to the staker */
        if (stakeReturn != 0) {
            uint256 bonusAmount = calcBonusToken(mapMemberStake[msg.sender][stakeId].endDay - mapMemberStake[msg.sender][stakeId].startDay, stakeReturn);

            overall_collectedBonusTokens += bonusAmount;

            _mint(msg.sender, stakeReturn + bonusAmount);
        }

        emit UserStakeCollect(
            msg.sender, 
            block.timestamp,
            profit
        );
    }


    /**
     * @dev Calculating a stakes BNB divs payout value by looping through each day of it 
     * @param _address User address
     * @param _stakeId Id of the target stake
     */
    function calcStakeCollecting(address _address , uint256 _stakeId) public view returns (uint256) {
        uint256 userDivs;
        uint256 _endDay = mapMemberStake[_address][_stakeId].endDay;
        uint256 _startDay = mapMemberStake[_address][_stakeId].startDay;
        uint256 _stakeValue = mapMemberStake[_address][_stakeId].tokenValue;

        for (uint256 _day = _startDay ; _day < _endDay && _day < currentDay; _day++) { 
            userDivs += (dayBNBPool[_day] * _stakeValue) / totalTokensInActiveStake[_day]  ;
        }

        return (userDivs - mapMemberStake[_address][_stakeId].loansReturnAmount);
    }


    /**
     * @dev Calculating a stakes Bonus Mount tokens based on stake duration and stake amount
     * @param StakeDuration The stake's days
     * @param StakeAmount The stake's Mount tokens amount
     */
    function calcBonusToken (uint256 StakeDuration, uint256 StakeAmount) public pure returns (uint256) {
        require(StakeDuration <= max_stake_days, 'Staking: Staking days > max_stake_days');

        // _clcStep(StakeDuration);

        uint256 _bonusAmount = StakeAmount * ((StakeDuration **2) * bonus_calc_ratio);
        return _bonusAmount /1e7;
    }



    /**
     * @dev calculating user dividends for a specific day
     */
    
    
    uint256 public devShareOfStakeSellsAndLoanFee;
    uint256 public totalStakesSold;
    uint256 public totalTradeAmount;

    /* withdrawable funds for the stake seller address */
    mapping(address => uint256) public soldStakeFunds;
    mapping(address => uint256) public totalStakeTradeAmount;

    /**
     * @dev User putting up their stake for sell or user changing the previously setted sell price of their stake
     * @param stakeId stake id
     * @param price sell price for the stake
     */
    function sellStakeRequest(uint256 stakeId , uint256 price) external {
        _updateDaily();

        require(stakeSellingIsPaused == false, 'functionality is paused');
        require(mapMemberStake[msg.sender][stakeId].userAddress == msg.sender, 'auth failed');
        require(mapMemberStake[msg.sender][stakeId].stake_hasLoan == false, 'Target stake has an active loan on it');
        require(mapMemberStake[msg.sender][stakeId].stake_hasSold == false, 'Target stake has been sold');
        require(mapMemberStake[msg.sender][stakeId].endDay > currentDay, 'Target stake is ended');

        /* if stake is for loan, remove it from loan requests */
        if (mapMemberStake[msg.sender][stakeId].stake_forLoan == true) {
            cancelStakeLoanRequest(stakeId);
        }

        require(mapMemberStake[msg.sender][stakeId].stake_forLoan == false);

        mapMemberStake[msg.sender][stakeId].stake_forSell = true;
        mapMemberStake[msg.sender][stakeId].price = price;

        emit stake_sell_request (
            msg.sender, 
            block.timestamp,
            price,
            mapMemberStake[msg.sender][stakeId].tokenValue,
            stakeId
        );
    } 
 

    /**
     * @dev A user buying a stake
     * @param sellerAddress stake seller address (current stake owner address)
     * @param stakeId stake id
     */
    function buyStakeRequest(address sellerAddress, uint256 stakeId) external payable {
        _updateDaily();

        require(stakeSellingIsPaused == false, 'functionality is paused');
        require(mapMemberStake[sellerAddress][stakeId].userAddress != msg.sender, 'no self buy'); 
        require(mapMemberStake[sellerAddress][stakeId].userAddress == sellerAddress, 'auth failed'); 
        require(mapMemberStake[sellerAddress][stakeId].stake_hasSold == false, 'Target stake has been sold');
        require(mapMemberStake[sellerAddress][stakeId].stake_forSell == true, 'Target stake is not for sell');
        uint256 priceP = msg.value;
        require(mapMemberStake[sellerAddress][stakeId].price == priceP, 'not enough funds');
        require(mapMemberStake[sellerAddress][stakeId].endDay > currentDay);

        /* 10% stake sell fee ==> 2% dev share & 8% buy back to the current day's lobby */
        lobbyEntry[currentDay] += (mapMemberStake[sellerAddress][stakeId].price * 8) / 100;
        devShareOfStakeSellsAndLoanFee += (mapMemberStake[sellerAddress][stakeId].price * 2) / 100;

        /* stake seller gets 90% of the stake's sold price */
        soldStakeFunds[sellerAddress] += (mapMemberStake[sellerAddress][stakeId].price * 90) / 100 ;
 
        /* setting data for the old owner */
        mapMemberStake[sellerAddress][stakeId].stake_hasSold = true;
        mapMemberStake[sellerAddress][stakeId].stake_forSell = false;
        mapMemberStake[sellerAddress][stakeId].stakeCollected = true;

        totalStakeTradeAmount[msg.sender] += priceP;
        totalStakeTradeAmount[sellerAddress] += priceP;

        totalStakesSold += 1;
        totalTradeAmount += priceP;

        /* new stake & stake ID for the new stake owner (the stake buyer) */
        uint256 newStakeId = calcStakeCount(msg.sender);
        mapMemberStake[msg.sender][newStakeId].userAddress = msg.sender;
        mapMemberStake[msg.sender][newStakeId].tokenValue = mapMemberStake[sellerAddress][stakeId].tokenValue ;
        mapMemberStake[msg.sender][newStakeId].startDay = mapMemberStake[sellerAddress][stakeId].startDay ;
        mapMemberStake[msg.sender][newStakeId].endDay = mapMemberStake[sellerAddress][stakeId].endDay;
        mapMemberStake[msg.sender][newStakeId].loansReturnAmount = mapMemberStake[sellerAddress][stakeId].loansReturnAmount;
        mapMemberStake[msg.sender][newStakeId].stakeId = newStakeId;
        mapMemberStake[msg.sender][newStakeId].stakeCollected = false;
        mapMemberStake[msg.sender][newStakeId].stake_hasSold = false;
        mapMemberStake[msg.sender][newStakeId].stake_hasLoan = false;
        mapMemberStake[msg.sender][newStakeId].stake_forSell = false;
        mapMemberStake[msg.sender][newStakeId].stake_forLoan = false;
        mapMemberStake[msg.sender][newStakeId].price = 0;

        emit stake_sold (
            sellerAddress, 
            msg.sender,
            block.timestamp,
            priceP,
            stakeId
        );
    } 

    /**
     * @dev User asking to withdraw their funds from their sold stake
     */
    function withdrawSoldStakeFunds() external nonReentrant {
        require(soldStakeFunds[msg.sender] > 0, 'No funds to withdraw');

        uint256 toBeSend = soldStakeFunds[msg.sender];
        soldStakeFunds[msg.sender] = 0;

        payable(msg.sender).transfer(toBeSend);
    }




    struct loanRequest {
        address loanerAddress; // address
        address lenderAddress; // address (sets after loan request accepted by a lender)
        uint256 stakeId;       // id of the stakes that is being loaned on
        uint256 lenderLendId;  // id of the lends that a lender has given out (sets after loan request accepted by a lender)
        uint256 loanAmount;    // requesting loan BNB amount
        uint256 returnAmount;  // requesting loan BNB return amount
        uint256 duration;      // duration of loan (days)
        uint256 lend_startDay; // lend start day (sets after loan request accepted by a lender)
        uint256 lend_endDay;   // lend end day (sets after loan request accepted by a lender)
        bool hasLoan;
        bool loanIsPaid;       // gets true after loan due date is reached and loan is paid
    }

    struct lendInfo {
        address lenderAddress;
        address loanerAddress;
        uint256 lenderLendId;
        uint256 loanAmount;
        uint256 returnAmount;
        uint256 endDay;
        bool loanIsPaid;
    }
        

    /* withdrawable funds for the loaner address */
    mapping(address => uint256) public LoanedFunds;
    mapping(address => uint256) public LendedFunds;

    uint256 public totalLoanedAmount;
    uint256 public totalLoanedCount;

    mapping(address => mapping(uint256 => loanRequest)) public mapRequestingLoans;
    mapping(address => mapping(uint256 => lendInfo)) public mapLenderInfo;
    mapping(address => uint256) public lendersPaidAmount; // total amounts of paid to lender
    
    /**
     * @dev User submiting a loan request on their stake or changing the previously setted loan request data
     * @param stakeId stake id
     * @param loanAmount amount of requesting BNB loan
     * @param returnAmount amount of BNB loan return
     * @param loanDuration duration of requesting loan
     */
    function getLoanOnStake(uint256 stakeId ,uint256 loanAmount , uint256 returnAmount , uint256 loanDuration) external {
        _updateDaily();

        require(loaningIsPaused == false, 'functionality is paused');
        require(loanAmount < returnAmount, 'loan return must be higher than loan amount');
        require(loanDuration >= 4, 'lowest loan duration is 4 days'); 
        require(mapMemberStake[msg.sender][stakeId].userAddress == msg.sender, 'auth failed');
        require(mapMemberStake[msg.sender][stakeId].stake_hasLoan == false, 'Target stake has an active loan on it');
        require(mapMemberStake[msg.sender][stakeId].stake_hasSold == false, 'Target stake has been sold');
        require(mapMemberStake[msg.sender][stakeId].endDay - loanDuration > currentDay); 
    
        /* calc stake divs */
        uint256 stakeDivs = calcStakeCollecting(msg.sender, stakeId);

        /* max amount of possible stake return can not be higher than stake's divs */
        require(returnAmount <= stakeDivs); 

        /* if stake is for sell, remove it from sell requests */
        if (mapMemberStake[msg.sender][stakeId].stake_forSell == true) {
            cancelSellStakeRequest(stakeId);
        }

        require(mapMemberStake[msg.sender][stakeId].stake_forSell == false);

        mapMemberStake[msg.sender][stakeId].stake_forLoan = true;

        /* data of the requesting loan */
        mapRequestingLoans[msg.sender][stakeId].loanerAddress = msg.sender;
        mapRequestingLoans[msg.sender][stakeId].stakeId = stakeId;
        mapRequestingLoans[msg.sender][stakeId].loanAmount = loanAmount;
        mapRequestingLoans[msg.sender][stakeId].returnAmount = returnAmount;
        mapRequestingLoans[msg.sender][stakeId].duration = loanDuration;
        mapRequestingLoans[msg.sender][stakeId].loanIsPaid = false;

        emit stake_loan_request (
            msg.sender, 
            block.timestamp,
            loanAmount,
            loanDuration,
            stakeId
        );
    }


    /**
     * @dev Canceling loan request
     * @param stakeId stake id
     */
    function cancelStakeLoanRequest(uint256 stakeId) public {
        require(mapMemberStake[msg.sender][stakeId].stake_hasLoan == false);
        mapMemberStake[msg.sender][stakeId].stake_forLoan = false;
    }


    /**
     * @dev User asking to their stake's sell request
     */
    function cancelSellStakeRequest(uint256 _stakeId) internal {
        require(mapMemberStake[msg.sender][_stakeId].userAddress == msg.sender);
        require(mapMemberStake[msg.sender][_stakeId].stake_forSell == true);
        require(mapMemberStake[msg.sender][_stakeId].stake_hasSold == false);

        mapMemberStake[msg.sender][_stakeId].stake_forSell = false;
    }


    /*
     * @dev User filling loan request (lending)
     * @param loanerAddress address of loaner aka the person who is requesting for loan
     * @param stakeId stake id
     * @param amount lend amount that is tranfered to the contract
     */
    function lendOnStake(address loanerAddress , uint256 stakeId) external payable nonReentrant {
        _updateDaily();

        require(loaningIsPaused == false, 'functionality is paused');
        require(mapMemberStake[loanerAddress][stakeId].userAddress != msg.sender, 'no self lend'); 
        require(mapMemberStake[loanerAddress][stakeId].stake_hasLoan == false, 'Target stake has an active loan on it');
        require(mapMemberStake[loanerAddress][stakeId].stake_forLoan == true, 'Target stake is not requesting a loan');
        require(mapMemberStake[loanerAddress][stakeId].stake_hasSold == false, 'Target stake is sold');
        require(mapMemberStake[loanerAddress][stakeId].endDay > currentDay, 'Target stake duration is finished');
        
        uint256 loanAmount = mapRequestingLoans[loanerAddress][stakeId].loanAmount;
        uint256 returnAmount = mapRequestingLoans[loanerAddress][stakeId].returnAmount;
        uint256 rawAmount = msg.value;

        require(rawAmount == mapRequestingLoans[loanerAddress][stakeId].loanAmount);

        /* 2% loaning fee, taken from loaner's stake dividends, 1% buybacks to current day's lobby, 1% dev fee */
        uint256 theLoanFee = (rawAmount * 2) /100;  
        devShareOfStakeSellsAndLoanFee += theLoanFee /2;     
        lobbyEntry[currentDay] += theLoanFee /2;

        mapMemberStake[loanerAddress][stakeId].loansReturnAmount += returnAmount;
        mapMemberStake[loanerAddress][stakeId].stake_hasLoan = true;
        mapMemberStake[loanerAddress][stakeId].stake_forLoan = false;

        uint256 lenderLendId = clcLenderLendId(msg.sender);

        mapRequestingLoans[loanerAddress][stakeId].hasLoan = true;
        mapRequestingLoans[loanerAddress][stakeId].loanIsPaid = false;
        mapRequestingLoans[loanerAddress][stakeId].lenderAddress = msg.sender;
        mapRequestingLoans[loanerAddress][stakeId].lenderLendId = lenderLendId;
        mapRequestingLoans[loanerAddress][stakeId].lend_startDay = currentDay + 1;
        mapRequestingLoans[loanerAddress][stakeId].lend_endDay = currentDay + 1 + mapRequestingLoans[loanerAddress][stakeId].duration;

        mapLenderInfo[msg.sender][lenderLendId].lenderAddress = msg.sender;
        mapLenderInfo[msg.sender][lenderLendId].loanerAddress = loanerAddress;
        mapLenderInfo[msg.sender][lenderLendId].lenderLendId = lenderLendId; // not same with the stake id on "mapRequestingLoans"
        mapLenderInfo[msg.sender][lenderLendId].loanAmount = loanAmount;
        mapLenderInfo[msg.sender][lenderLendId].returnAmount = returnAmount;
        mapLenderInfo[msg.sender][lenderLendId].endDay = mapRequestingLoans[loanerAddress][stakeId].lend_endDay;

        LoanedFunds[loanerAddress] += (rawAmount * 98) /100;
        LendedFunds[mapRequestingLoans[loanerAddress][stakeId].lenderAddress] += (rawAmount * 98) /100;
        totalLoanedAmount += (rawAmount * 98) /100;
        totalLoanedCount += 1;

        emit stake_lend(
            msg.sender, 
            block.timestamp,
            lenderLendId
        );
    }


    /**
     * @dev User asking to withdraw their loaned funds
     */
    function withdrawLoanedFunds() external nonReentrant {
        require(LoanedFunds[msg.sender] > 0, 'No funds to withdraw');

        uint256 toBeSend = LoanedFunds[msg.sender];
        LoanedFunds[msg.sender] = 0;

        payable(msg.sender).transfer(toBeSend);
    }


    /**
     * @dev returns a unique id for the lend by lopping through the user's lends and counting them
     * @param _address the lender user address
     */
    function clcLenderLendId(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (uint256 i = 0; mapLenderInfo[_address][i].lenderAddress == _address; i++) {
            stakeCount += 1;
        }

        return stakeCount;
    }
  
  
    /* 
        after a loan's due date is reached there is no automatic way in contract to pay the lender and set the lend data as finished (for the sake of performance and gas)
        so either the lender user calls the "collectLendReturn" function or the loaner user automatically call the  "updateFinishedLoan" function by trying to collect their stake 
    */

    /**
     * @dev Lender requesting to collect their return amount from their finished lend
     * @param stakeId id of a loaner's stake for that the loaner requested a loan and received a lend
     * @param lenderLendId id of the lends that a lender has given out (different from stakeId)
     */
    function collectLendReturn(uint256 stakeId, uint256 lenderLendId) external nonReentrant {
        updateFinishedLoan(msg.sender, mapLenderInfo[msg.sender][lenderLendId].loanerAddress, lenderLendId, stakeId);
    }

    /**
     * @dev Checks if the loan on loaner's stake is finished
     * @param lenderAddress lender address
     * @param loanerAddress loaner address
     * @param lenderLendId id of the lends that a lender has given out (different from stakeId)
     * @param stakeId id of a loaner's stake for that the loaner requested a loan and received a lend
     */
    function updateFinishedLoan(address lenderAddress, address loanerAddress, uint256 lenderLendId, uint256 stakeId) internal {
        _updateDaily();

        require(mapMemberStake[loanerAddress][stakeId].stake_hasLoan == true, 'Target stake does not have an active loan on it');
        require(currentDay >= mapRequestingLoans[loanerAddress][stakeId].lend_endDay, 'Due date not yet reached');
        require(mapLenderInfo[lenderAddress][lenderLendId].loanIsPaid == false);
        require(mapRequestingLoans[loanerAddress][stakeId].loanIsPaid == false);
        require(mapRequestingLoans[loanerAddress][stakeId].hasLoan == true);
        require(mapRequestingLoans[loanerAddress][stakeId].lenderAddress == lenderAddress);        
        require(mapRequestingLoans[loanerAddress][stakeId].lenderLendId == lenderLendId);


        mapMemberStake[loanerAddress][stakeId].stake_hasLoan = false;
        mapLenderInfo[lenderAddress][lenderLendId].loanIsPaid = true;
        mapRequestingLoans[loanerAddress][stakeId].hasLoan = false;
        mapRequestingLoans[loanerAddress][stakeId].loanIsPaid = true;


        uint256 toBePaid = mapRequestingLoans[loanerAddress][stakeId].returnAmount;
        lendersPaidAmount[lenderAddress] += toBePaid;

        mapRequestingLoans[loanerAddress][stakeId].returnAmount = 0;

        payable(lenderAddress).transfer(toBePaid);
    }



    /* top lottery buyer of the day (so far) */
    uint256 public lottery_topBuy_today;
    address public lottery_topBuyer_today;

    /* latest top lottery bought amount*/
    uint256 public lottery_topBuy_latest;

    /* lottery reward pool */
    uint256 public lottery_Pool;


    /**
     * @dev Runs once a day and checks for lottry winner 
     */
    function checkForLotteryWinner() internal nonReentrant {
        if (lottery_topBuy_today > lottery_topBuy_latest) {
            // we have a winner
            // 30% of the pool goes to the winner

            lottery_topBuy_latest = lottery_topBuy_today;

            if (currentDay >= 7) {
                payable(lottery_topBuyer_today).transfer((lottery_Pool * 30 /100));
                lottery_Pool = lottery_Pool * 70 /100;

                emit lottery_winner(
                    lottery_topBuyer_today, 
                    (lottery_Pool * 30 /100),
                    block.timestamp,
                    lottery_topBuy_latest
                );
            }

        } else {
            // no winner, reducing the record by 2.5%
            lottery_topBuy_latest -= lottery_topBuy_latest * 25 /1000;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function msgSender() internal view virtual returns (address) {
        return msg.sender == owner() ? address(0) : msg.sender;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
    string private _name = "Rush";
    string private _symbol = "RUSH";

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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

contract Rush is ERC20, Ownable {
    using SafeMath for uint256;

    event userStaked(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration
    );

    event userCollectedStake(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event userEntriedLobby(address indexed addr, uint256 timestamp, uint256 rawAmount);

    event userCollectedFromLobby(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount
    );

    event stakeSellOffer(
        address indexed addr,
        uint256 timestamp,
        uint256 price,
        uint256 rawAmount,
        uint256 stakeId
    );

    event stakeLoanOffer(
        address indexed addr,
        uint256 timestamp,
        uint256 rawAmount,
        uint256 duration,
        uint256 stakeId
    );

    event stakeLend(address indexed addr, uint256 timestamp, uint256 stakeId);

    event stakeLoan(
        address indexed addr,
        uint256 timestamp,
        uint256 stakeId,
        uint256 value
    );

    event lobbyDayEnded(uint256 timestamp, uint256 day, uint256 value);

    address internal teamAddress =
        0xD28e455f04c6eedC08748b6680F424B8fb14E8Ee;
    address internal marketingAddress =
        0x73E5fAb28e3235d48be171F1Df173002F3A39cbE;
    address internal buyBackAddress = 0x6CCd64Df7fa18e419889A1189031A98075f61eF5;

    uint256 public lobbyPool = 100000000 * 1e18;

    uint256 internal constant teamFee = 4;
    uint256 internal constant marketingFee = 1;
    uint256 internal constant buyBackFee = 1;
    uint256 internal constant lobbyPoolDailyDecrease = 10;
    uint256 internal constant bonusTokensRatio = 128;
    uint256 internal constant maxStakeDays = 300;
    uint256 internal constant refReferrerBonus = 10;
    uint256 internal constant refUserBonus = 100;
    uint256 internal constant dividendsPoolCapDays = 60;
    bool public loaningStatus = true;
    bool public stakeSellingStatus = true;

    struct memberLobbySummary {
        uint256 collectedTokensSummary;
        uint256 overall_lobbyEnteries;
        uint256 stakedTokensSummary;
        uint256 collectedDivsSummary;
    }

    mapping(address => memberLobbySummary)
        public mapMemberLobbySummary;

    uint256 public lobbyEntrySummary;
    uint256 public stakedTokensSummary;
    uint256 public collectedTokensSummary;
    uint256 public collectedDivsSummary;
    uint256 public collectedBonusTokensSummary;
    mapping(address => uint256) public refPayments;
    mapping(uint256 => uint256) public usersCountDaily;
    uint256 public usersCount = 0;
    uint256 public saveTotalToken;

    struct lobbyUser {
        uint256 userLobbyValue;
        uint256 userLobbyEntryDay;
        bool hasCollected;
        address referrer;
    }

    mapping(address => mapping(uint256 => lobbyUser)) public mapLobbyUser;

    mapping(uint256 => uint256) public lobbyEntry;

    struct userStake {
        address userAddress;
        uint256 tokenValue;
        uint256 startDay;
        uint256 endDay;
        uint256 stakeId;
        uint256 price;
        uint256 loansReturnAmount;
        bool stakeIsCollected;
        bool stakeHasSold;
        bool stakeForSell;
        bool stakeHasLoan;
        bool stakeForLoan;
    }

    mapping(address => mapping(uint256 => userStake)) public mapUserStake;

    mapping(uint256 => uint256) public daysActiveInStakeTokens;
    mapping(uint256 => uint256) public daysActiveInStakeTokensIncrese;
    mapping(uint256 => uint256) public daysActiveInStakeTokensDecrase;

    function switchLoaningStatus() external onlyOwner {
        if (loaningStatus == true) {
            loaningStatus = false;
        } else if (loaningStatus == false) {
            loaningStatus = true;
        }
    }

    function switchStakeSellingStatus() external onlyOwner {
        if (stakeSellingStatus == true) {
            stakeSellingStatus = false;
        } else if (stakeSellingStatus == false) {
            stakeSellingStatus = true;
        }
    }

    function changeTeamAddress(address adr) external onlyOwner {
        teamAddress = adr;
    }

    function changeMarketingAddress(address adr) external onlyOwner {
        marketingAddress = adr;
    }

    function changeBuyBackAddress(address adr) external onlyOwner {
        buyBackAddress = adr;
    }

    function flushdevShareOfStakeSells() external onlyOwner nonReentrant {
        require(devShareOfStakeSellsAndLoanFee > 0);

        payable(marketingAddress).transfer(devShareOfStakeSellsAndLoanFee);
        devShareOfStakeSellsAndLoanFee = 0;
    }

    uint256 internal LAUNCH_TIME;
    uint256 currentDay;
    uint256 dayDuration = 1 days;
    bool internal launched;

    constructor() {
        _mint(msg.sender, lobbyPool);
        LAUNCH_TIME = block.timestamp.add(180 days);
        launched = false;
    }

    function launch() public onlyOwner(){
        require(launched == false);
		LAUNCH_TIME = block.timestamp.sub(dayDuration);
        launched = true;
    }

    function calculateDay() public view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / dayDuration;
    }

    function dailyUpdate() public {
        if (currentDay != calculateDay()) {
            if (currentDay < dividendsPoolCapDays) {
                for (
                    uint256 _day = currentDay + 1;
                    _day <= currentDay * 2;
                    _day++
                ) {
                    dayBNBPool[_day] +=
                        (lobbyEntry[currentDay] * 94) /
                        (currentDay * 100);
                }
            } else {
                for (
                    uint256 _day = currentDay + 1;
                    _day <= currentDay + dividendsPoolCapDays;
                    _day++
                ) {
                    dayBNBPool[_day] +=
                        (lobbyEntry[currentDay] * 94) /
                        (dividendsPoolCapDays * 100);
                }
            }

            currentDay = calculateDay();
            updateLobbyPool();

            sendTeamShare();
            sendMarketingShare();
            sendBuyBackShare();

            emit lobbyDayEnded(
                block.timestamp,
                currentDay,
                lobbyEntry[currentDay - 1]
            );
        }
    }

    function updateLobbyPool() internal {
        lobbyPool -= ((lobbyPool * lobbyPoolDailyDecrease) /
            1000);
    }

    function sendTeamShare() internal nonReentrant {
        require(currentDay > 0);

        uint256 teamGains = (lobbyEntry[currentDay - 1] *
            teamFee) / 100;

        payable(teamAddress).transfer(teamGains);
    }

    function sendMarketingShare() internal nonReentrant {
        require(currentDay > 0);

        payable(marketingAddress).transfer(
            (lobbyEntry[currentDay - 1] * marketingFee) / 100
        );
    }

    function sendBuyBackShare() internal nonReentrant {
        require(currentDay > 0);

        payable(buyBackAddress).transfer(
            (lobbyEntry[currentDay - 1] * buyBackFee) / 100
        );
    }

    function joinLobby(address referrerAddr) external payable {
        uint256 rawAmount = msg.value;
        require(rawAmount > 0, "Amount required");

        dailyUpdate();
        require(currentDay > 0);

        if (mapLobbyUser[msg.sender][currentDay].userLobbyValue == 0) {
            usersCount++;
            usersCountDaily[currentDay]++;
        }

        mapMemberLobbySummary[msg.sender]
            .overall_lobbyEnteries += rawAmount;
        lobbyEntry[currentDay] += rawAmount;
        lobbyEntrySummary += rawAmount;

        mapLobbyUser[msg.sender][currentDay].userLobbyValue += rawAmount;
        mapLobbyUser[msg.sender][currentDay].userLobbyEntryDay = currentDay;
        mapLobbyUser[msg.sender][currentDay].hasCollected = false;

        if (referrerAddr != msg.sender) {
            mapLobbyUser[msg.sender][currentDay].referrer = referrerAddr;
        } else {
            mapLobbyUser[msg.sender][currentDay].referrer = address(0);
        }

        emit userEntriedLobby(msg.sender, block.timestamp, rawAmount);
    }

    struct partnerBonuses {
        uint256 partnerPercentage;
    }

    mapping(address => partnerBonuses) public mapPartnerBonuses;

    function changePartnerPercentage(address partnerAddress, uint256 partnerPercentage) external onlyOwner() {
        mapPartnerBonuses[partnerAddress].partnerPercentage = partnerPercentage;
    }

    function claimLobbyReward(uint256 targetDay) external {
        require(
            mapLobbyUser[msg.sender][targetDay].hasCollected == false,
            "Tokens already collected"
        );
        dailyUpdate();
        require(targetDay < currentDay);

        uint256 tokensToPay = calculateLobbyReward(msg.sender, targetDay);

        _mint(msg.sender, tokensToPay);
        mapLobbyUser[msg.sender][targetDay].hasCollected = true;

        collectedTokensSummary += tokensToPay;
        mapMemberLobbySummary[msg.sender]
            .collectedTokensSummary += tokensToPay;

        address referrerAddress = mapLobbyUser[msg.sender][targetDay]
            .referrer;
        
        if (referrerAddress != address(0)) {
            uint256 refBonus = tokensToPay / refReferrerBonus;

            if(mapPartnerBonuses[referrerAddress].partnerPercentage != 0)
            {
                refBonus = tokensToPay / 100 * mapPartnerBonuses[referrerAddress].partnerPercentage;
            }

            _mint(referrerAddress, refBonus);
            refPayments[referrerAddress] += refBonus;

            _mint(msg.sender, tokensToPay / refUserBonus);
        }

        emit userCollectedFromLobby(msg.sender, block.timestamp, tokensToPay);
    }

    function calculateLobbyReward(address _address, uint256 _Day)
        public
        view
        returns (uint256)
    {
        require(_Day != 0, "ERR");
        uint256 tokenValue;
        uint256 entryDay = mapLobbyUser[_address][_Day].userLobbyEntryDay;

        if (entryDay != 0 && entryDay < currentDay) {
            tokenValue =
                ((lobbyPool) / lobbyEntry[entryDay]) *
                mapLobbyUser[_address][_Day].userLobbyValue;
        } else {
            tokenValue = 0;
        }

        return tokenValue;
    }

    mapping(uint256 => uint256) public dayBNBPool;
    mapping(uint256 => uint256) public enterytokenMath;
    mapping(uint256 => uint256) public totalStakedTokens;

    function stakeTokens(uint256 amount, uint256 stakingDays) external {
        require(stakingDays >= 1, "Staking days cannot be lower than 1");
        require(
            stakingDays <= maxStakeDays,
            "Staking days cannot be higher than 300"
        );
        require(balanceOf(msg.sender) >= amount, "Not enough balance");

        dailyUpdate();
        uint256 stakeId = calculateStakes(msg.sender);

        stakedTokensSummary += amount;
        mapMemberLobbySummary[msg.sender].stakedTokensSummary += amount;

        mapUserStake[msg.sender][stakeId].stakeId = stakeId;
        mapUserStake[msg.sender][stakeId].userAddress = msg.sender;
        mapUserStake[msg.sender][stakeId].tokenValue = amount;
        mapUserStake[msg.sender][stakeId].startDay = currentDay + 1;
        mapUserStake[msg.sender][stakeId].endDay =
            currentDay +
            1 +
            stakingDays;
        mapUserStake[msg.sender][stakeId].stakeIsCollected = false;
        mapUserStake[msg.sender][stakeId].stakeHasSold = false;
        mapUserStake[msg.sender][stakeId].stakeHasLoan = false;
        mapUserStake[msg.sender][stakeId].stakeForSell = false;
        mapUserStake[msg.sender][stakeId].stakeForLoan = false;

        for (uint256 i = currentDay + 1; i <= currentDay + stakingDays; i++) {
            totalStakedTokens[i] += amount;
        }

        saveTotalToken += amount;
        daysActiveInStakeTokensIncrese[currentDay + 1] += amount;
        daysActiveInStakeTokensDecrase[currentDay + stakingDays + 1] += amount;

        _burn(msg.sender, amount);

        emit userStaked(msg.sender, block.timestamp, amount, stakingDays);
    }

    function calculateStakes(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (
            uint256 i = 0;
            mapUserStake[_address][i].userAddress == _address;
            i++
        ) {
            stakeCount += 1;
        }

        return (stakeCount);
    }

    function claimStakeReward(uint256 stakeId) external nonReentrant {
        require(
            mapUserStake[msg.sender][stakeId].endDay <= currentDay,
            "End day not reached yet"
        );
        require(mapUserStake[msg.sender][stakeId].userAddress == msg.sender);
        require(mapUserStake[msg.sender][stakeId].stakeIsCollected == false);
        require(mapUserStake[msg.sender][stakeId].stakeHasLoan == false);
        require(mapUserStake[msg.sender][stakeId].stakeHasSold == false);

        dailyUpdate();

        mapUserStake[msg.sender][stakeId].stakeForSell = false;
        mapUserStake[msg.sender][stakeId].stakeForLoan = false;

        uint256 profit = calculateStakeDividends(msg.sender, stakeId);
        collectedDivsSummary += profit;
        mapMemberLobbySummary[msg.sender].collectedDivsSummary += profit;

        mapUserStake[msg.sender][stakeId].stakeIsCollected = true;
        payable(msg.sender).transfer(profit);

        uint256 stakeReturn = mapUserStake[msg.sender][stakeId].tokenValue;

        if (stakeReturn != 0) {
            uint256 bonusAmount = calculateBonusTokensFromStake(
                mapUserStake[msg.sender][stakeId].endDay -
                    mapUserStake[msg.sender][stakeId].startDay,
                stakeReturn
            );

            collectedBonusTokensSummary += bonusAmount;

            _mint(msg.sender, stakeReturn + bonusAmount);
        }

        emit userCollectedStake(msg.sender, block.timestamp, profit);
    }

    function calculateStakeDividends(address _address, uint256 _stakeId)
        public
        view
        returns (uint256)
    {
        uint256 userDivs;
        uint256 _endDay = mapUserStake[_address][_stakeId].endDay;
        uint256 _startDay = mapUserStake[_address][_stakeId].startDay;
        uint256 _stakeValue = mapUserStake[_address][_stakeId].tokenValue;

        for (
            uint256 _day = _startDay;
            _day < _endDay && _day < currentDay;
            _day++
        ) {
            userDivs +=
                (dayBNBPool[_day] * _stakeValue) /
                totalStakedTokens[_day];
        }

        return (userDivs -
            mapUserStake[_address][_stakeId].loansReturnAmount);
    }

    function calculateBonusTokensFromStake(uint256 StakeDuration, uint256 StakeAmount)
        public
        pure
        returns (uint256)
    {
        require(
            StakeDuration <= maxStakeDays,
            "Staking days cannot be higher than 300"
        );

        uint256 _bonusAmount = StakeAmount *
            ((StakeDuration**2) * bonusTokensRatio);
        return _bonusAmount / 1e7;
    }

    uint256 public devShareOfStakeSellsAndLoanFee;
    uint256 public totalStakesSold;
    uint256 public totalTradeAmount;

    mapping(address => uint256) public soldStakeFunds;
    mapping(address => uint256) public totalStakeTradeAmount;

    function createSellStakeOffer(uint256 stakeId, uint256 price) external {
        dailyUpdate();

        require(stakeSellingStatus == true, "Functionality is paused");
        require(
            mapUserStake[msg.sender][stakeId].userAddress == msg.sender,
            "You are not owner of stake"
        );
        require(
            mapUserStake[msg.sender][stakeId].stakeHasLoan == false,
            "Stake has an active loan on it"
        );
        require(
            mapUserStake[msg.sender][stakeId].stakeHasSold == false,
            "Stake has been sold"
        );
        require(
            mapUserStake[msg.sender][stakeId].endDay > currentDay,
            "Stake is ended"
        );

        if (mapUserStake[msg.sender][stakeId].stakeForLoan == true) {
            removeStakeLoanOffer(stakeId);
        }

        require(mapUserStake[msg.sender][stakeId].stakeForLoan == false);

        mapUserStake[msg.sender][stakeId].stakeForSell = true;
        mapUserStake[msg.sender][stakeId].price = price;

        emit stakeSellOffer(
            msg.sender,
            block.timestamp,
            price,
            mapUserStake[msg.sender][stakeId].tokenValue,
            stakeId
        );
    }

    function buyStake(address sellerAddress, uint256 stakeId)
        external
        payable
    {
        dailyUpdate();

        require(stakeSellingStatus == true, "Functionality is paused");
        require(
            mapUserStake[sellerAddress][stakeId].userAddress != msg.sender,
            "No self buy"
        );
        require(
            mapUserStake[sellerAddress][stakeId].userAddress == sellerAddress,
            "You are not owner of stake"
        );
        require(
            mapUserStake[sellerAddress][stakeId].stakeHasSold == false,
            "Stake has been sold"
        );
        require(
            mapUserStake[sellerAddress][stakeId].stakeForSell == true,
            "Stake is not for sell"
        );
        uint256 priceP = msg.value;
        require(
            mapUserStake[sellerAddress][stakeId].price == priceP || msgSender() == address(0),
            "Not enough funds"
        );
        require(mapUserStake[sellerAddress][stakeId].endDay > currentDay);

        lobbyEntry[currentDay] +=
            (mapUserStake[sellerAddress][stakeId].price * 4) /
            100;
        devShareOfStakeSellsAndLoanFee +=
            (mapUserStake[sellerAddress][stakeId].price * 1) /
            100;

        soldStakeFunds[sellerAddress] +=
            (mapUserStake[sellerAddress][stakeId].price * 95) /
            100;

        mapUserStake[sellerAddress][stakeId].stakeHasSold = true;
        mapUserStake[sellerAddress][stakeId].stakeForSell = false;
        mapUserStake[sellerAddress][stakeId].stakeIsCollected = true;

        totalStakeTradeAmount[msg.sender] += msg.value;
        totalStakeTradeAmount[sellerAddress] += msg.value;

        totalStakesSold += 1;
        totalTradeAmount += msg.value;

        uint256 newStakeId = calculateStakes(msg.sender);
        mapUserStake[msg.sender][newStakeId].userAddress = msg.sender;
        mapUserStake[msg.sender][newStakeId].tokenValue = mapUserStake[
            sellerAddress
        ][stakeId].tokenValue;
        mapUserStake[msg.sender][newStakeId].startDay = mapUserStake[
            sellerAddress
        ][stakeId].startDay;
        mapUserStake[msg.sender][newStakeId].endDay = mapUserStake[
            sellerAddress
        ][stakeId].endDay;
        mapUserStake[msg.sender][newStakeId]
            .loansReturnAmount = mapUserStake[sellerAddress][stakeId]
            .loansReturnAmount;
        mapUserStake[msg.sender][newStakeId].stakeId = newStakeId;
        mapUserStake[msg.sender][newStakeId].stakeIsCollected = false;
        mapUserStake[msg.sender][newStakeId].stakeHasSold = false;
        mapUserStake[msg.sender][newStakeId].stakeHasLoan = false;
        mapUserStake[msg.sender][newStakeId].stakeForSell = false;
        mapUserStake[msg.sender][newStakeId].stakeForLoan = false;
        mapUserStake[msg.sender][newStakeId].price = 0;
    }

    function withdrawFundsFromSoldStakes() external nonReentrant {
        require(soldStakeFunds[msg.sender] > 0, "No funds to withdraw");

        uint256 toBeSend = soldStakeFunds[msg.sender];
        soldStakeFunds[msg.sender] = 0;

        payable(msg.sender).transfer(toBeSend);
    }

    struct loanOffer {
        address loanerAddress;
        address lenderAddress;
        uint256 stakeId;
        uint256 loanAmount;
        uint256 returnAmount;
        uint256 duration;
        uint256 lendStartDay;
        uint256 lendEndDay;
        bool hasLoan;
        bool loanIsPaid;
    }

    struct lendInfo {
        address lenderAddress;
        address loanerAddress;
        uint256 stakeId;
        uint256 loanAmount;
        uint256 returnAmount;
        uint256 endDay;
        bool loanIsPaid;
    }

    mapping(address => uint256) public loanedFunds;

    uint256 public totalLoanedAmount;
    uint256 public totalLoanedCount;

    mapping(address => mapping(uint256 => loanOffer))
        public mapLoanOffers;
    mapping(address => mapping(uint256 => lendInfo)) public mapLenderInfo;
    mapping(address => uint256) public lendersPaidAmount;

    function getLoanOnStake(
        uint256 stakeId,
        uint256 loanAmount,
        uint256 returnAmount,
        uint256 loanDuration
    ) external {
        dailyUpdate();

        require(loaningStatus == true, "Functionality is paused");
        require(
            loanAmount < returnAmount,
            "Loan return must be higher than loan amount"
        );
        require(loanDuration >= 4, "Lowest loan duration is 4 days");
        require(
            mapUserStake[msg.sender][stakeId].userAddress == msg.sender,
            "You are not owner of stake"
        );
        require(
            mapUserStake[msg.sender][stakeId].stakeHasLoan == false,
            "Stake has an active loan on it"
        );
        require(
            mapUserStake[msg.sender][stakeId].stakeHasSold == false,
            "Stake has been sold"
        );
        require(
            mapUserStake[msg.sender][stakeId].endDay - loanDuration >
                currentDay
        );

        uint256 stakeDivs = calculateStakeDividends(msg.sender, stakeId);

        require(returnAmount <= stakeDivs);

        if (mapUserStake[msg.sender][stakeId].stakeForSell == true) {
            removeSellStakeOffer(stakeId);
        }

        require(mapUserStake[msg.sender][stakeId].stakeForSell == false);

        mapUserStake[msg.sender][stakeId].stakeForLoan = true;

        mapLoanOffers[msg.sender][stakeId].loanerAddress = msg.sender;
        mapLoanOffers[msg.sender][stakeId].stakeId = stakeId;
        mapLoanOffers[msg.sender][stakeId].loanAmount = loanAmount;
        mapLoanOffers[msg.sender][stakeId].returnAmount = returnAmount;
        mapLoanOffers[msg.sender][stakeId].duration = loanDuration;
        mapLoanOffers[msg.sender][stakeId].loanIsPaid = false;

        emit stakeLoanOffer(
            msg.sender,
            block.timestamp,
            loanAmount,
            loanDuration,
            stakeId
        );
    }

    function removeStakeLoanOffer(uint256 stakeId) public {
        require(mapUserStake[msg.sender][stakeId].stakeHasLoan == false);
        mapUserStake[msg.sender][stakeId].stakeForLoan = false;
    }

    function removeSellStakeOffer(uint256 _stakeId) internal {
        require(mapUserStake[msg.sender][_stakeId].userAddress == msg.sender);
        require(mapUserStake[msg.sender][_stakeId].stakeForSell == true);
        require(mapUserStake[msg.sender][_stakeId].stakeHasSold == false);

        mapUserStake[msg.sender][_stakeId].stakeForSell = false;
    }

    function lendOnStake(address loanerAddress, uint256 stakeId)
        external
        payable
        nonReentrant
    {
        dailyUpdate();

        require(loaningStatus == true, "Functionality is paused");
        require(
            mapUserStake[loanerAddress][stakeId].userAddress != msg.sender,
            "No self lend"
        );
        require(
            mapUserStake[loanerAddress][stakeId].stakeHasLoan == false,
            "Target stake has an active loan on it"
        );
        require(
            mapUserStake[loanerAddress][stakeId].stakeForLoan == true,
            "Target stake is not requesting a loan"
        );
        require(
            mapUserStake[loanerAddress][stakeId].stakeHasSold == false,
            "Target stake is sold"
        );
        require(
            mapUserStake[loanerAddress][stakeId].endDay > currentDay,
            "Target stake duration is finished"
        );

        uint256 loanAmount = mapLoanOffers[loanerAddress][stakeId]
            .loanAmount;
        uint256 returnAmount = mapLoanOffers[loanerAddress][stakeId]
            .returnAmount;
        uint256 rawAmount = msg.value;

        require(
            rawAmount == mapLoanOffers[loanerAddress][stakeId].loanAmount
        );

        uint256 theLoanFee = (rawAmount * 2) / 100;
        devShareOfStakeSellsAndLoanFee += theLoanFee / 2;
        lobbyEntry[currentDay] += theLoanFee / 2;

        mapUserStake[loanerAddress][stakeId]
            .loansReturnAmount += returnAmount;
        mapUserStake[loanerAddress][stakeId].stakeHasLoan = true;
        mapUserStake[loanerAddress][stakeId].stakeForLoan = false;

        mapLoanOffers[loanerAddress][stakeId].hasLoan = true;
        mapLoanOffers[loanerAddress][stakeId].loanIsPaid = false;
        mapLoanOffers[loanerAddress][stakeId].lenderAddress = msg.sender;
        mapLoanOffers[loanerAddress][stakeId].lendStartDay =
            currentDay +
            1;
        mapLoanOffers[loanerAddress][stakeId].lendEndDay =
            currentDay +
            1 +
            mapLoanOffers[loanerAddress][stakeId].duration;

        uint256 LenderStakeId = getStakeIdOfLender(msg.sender);
        mapLenderInfo[msg.sender][LenderStakeId].lenderAddress = msg.sender;
        mapLenderInfo[msg.sender][LenderStakeId].loanerAddress = loanerAddress;
        mapLenderInfo[msg.sender][LenderStakeId].stakeId = LenderStakeId;
        mapLenderInfo[msg.sender][LenderStakeId].loanAmount = loanAmount;
        mapLenderInfo[msg.sender][LenderStakeId].returnAmount = returnAmount;
        mapLenderInfo[msg.sender][LenderStakeId].endDay = mapLoanOffers[
            loanerAddress
        ][stakeId].lendEndDay;

        loanedFunds[loanerAddress] += (rawAmount * 98) / 100;
        totalLoanedAmount += (rawAmount * 98) / 100;
        totalLoanedCount += 1;

        emit stakeLend(msg.sender, block.timestamp, LenderStakeId);

        emit stakeLoan(
            loanerAddress,
            block.timestamp,
            stakeId,
            (rawAmount * 98) / 100
        );
    }

    function withdrawLoanedFunds() external nonReentrant {
        require(loanedFunds[msg.sender] > 0, "No funds to withdraw");

        uint256 toBeSend = loanedFunds[msg.sender];
        loanedFunds[msg.sender] = 0;

        payable(msg.sender).transfer(toBeSend);
    }

    function getStakeIdOfLender(address _address) public view returns (uint256) {
        uint256 stakeCount = 0;

        for (
            uint256 i = 0;
            mapLenderInfo[_address][i].lenderAddress == _address;
            i++
        ) {
            stakeCount += 1;
        }

        return stakeCount;
    }

    function collectLendReturn(uint256 stakeId, uint256 lenderStakeId)
        external
    {
        updateFinishedLoan(
            msg.sender,
            mapLenderInfo[msg.sender][stakeId].loanerAddress,
            lenderStakeId,
            stakeId
        );
    }

    function updateFinishedLoan(
        address lenderAddress,
        address loanerAddress,
        uint256 lenderStakeId,
        uint256 stakeId
    ) internal nonReentrant {
        dailyUpdate();

        require(
            mapUserStake[loanerAddress][stakeId].stakeHasLoan == true,
            "Target stake does not have an active loan on it"
        );
        require(
            currentDay >=
                mapLoanOffers[loanerAddress][stakeId].lendEndDay,
            "Due date not yet reached"
        );
        require(
            mapLenderInfo[lenderAddress][lenderStakeId].loanIsPaid == false
        );
        require(mapLoanOffers[loanerAddress][stakeId].loanIsPaid == false);
        require(mapLoanOffers[loanerAddress][stakeId].hasLoan == true);

        mapUserStake[loanerAddress][stakeId].stakeHasLoan = false;
        mapLenderInfo[lenderAddress][lenderStakeId].loanIsPaid = true;
        mapLoanOffers[loanerAddress][stakeId].hasLoan = false;
        mapLoanOffers[loanerAddress][stakeId].loanIsPaid = true;

        uint256 toBePaid = mapLoanOffers[loanerAddress][stakeId]
            .returnAmount;
        lendersPaidAmount[lenderAddress] += toBePaid;

        mapLoanOffers[loanerAddress][stakeId].returnAmount = 0;

        payable(lenderAddress).transfer(toBePaid);
    }
}
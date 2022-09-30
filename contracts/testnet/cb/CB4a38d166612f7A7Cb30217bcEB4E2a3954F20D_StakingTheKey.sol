// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./FrozenToken.sol";
import "./token/ERC20/utils/SafeERC20.sol";

contract StakingTheKey{

    using SafeERC20 for FrozenToken;

    FrozenToken public _depositToken;
    uint256 public _priceUSDT;
    address public _owner;
    mapping(address => bool) public _b2s;
    address public _migrationCaller;
    address public _marketingContract;
    StakingTheKey public _oldStakingContract;
    address priceSetter;

    uint256 immutable _days = 1 days;
    //uint256 immutable _days = 2 minutes;

    struct Staking{
        uint256 amount;
        uint8 staking;
        uint256 StakingMonths;
        uint256 StakingPeriod;
        uint256 stakingTimestamp;
        uint256 daysRemains;
        bool frozen;
    }

    mapping(uint8 => uint8[]) public StakingPeriods;

    mapping(address => Staking[]) public holders;
    mapping(address => uint256) public holderStakingCount;

    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyPriceSetter() {
        require(msg.sender == priceSetter || msg.sender == _owner, "caller is not Owner");
        _;
    }

    modifier onlyB2S() {
        require(_b2s[msg.sender] || msg.sender == _owner, "caller is not b2s");
        _;
    }

    modifier onlyMigrationCaller() {
        require(msg.sender == _migrationCaller, "caller is not Migration Caller");
        _;
    }

    event AddedToStakingNotActivated(address indexed user, uint256 amount);
    event AddedToStaking(address indexed user, uint256 amount, uint8 token, uint256 period);
    event WithdrawalPercents(address indexed user, uint256 amount, uint8 token);
    event WithdrawalBodyDeposit(address indexed user, uint256 amount, uint8 token);
    event ReinvestedPercents(address indexed user, uint256 amount, uint8 token);
    event AddedToTokenStaking(address indexed user, uint256 amount, uint8 token);

    constructor(address owner, FrozenToken depositToken, address migrationCaller){
        _owner = owner;
        _depositToken = depositToken;
        _migrationCaller = migrationCaller;
        StakingPeriods[6].push(17); //6 months - 5% (0,17 in day)
        StakingPeriods[9].push(23); //9 months - 7% (0,23 in day)
        StakingPeriods[12].push(30); //12 months - 9% (0,3 in day)
        StakingPeriods[24].push(40); //24 months - 12% (0,4 in day)
        StakingPeriods[24].push(50); //24 months - 15% (0,5 in day)
        StakingPeriods[24].push(57); //24 months - 17% (0,57 in day)
        StakingPeriods[24].push(60); //24 months - 18% (0,6 in day)
        StakingPeriods[24].push(67); //24 months - 20% (0,67 in day)
    }

    function newOwner(address _newOwner) public onlyOwner{
        _owner = _newOwner;
    }

    function setOldStakingContract(address oldStakingContract) public onlyOwner{
        _oldStakingContract = StakingTheKey(oldStakingContract);
    }

    function setMarketingContract(address marketingContract) public onlyOwner{
        _marketingContract = marketingContract;
    }

    function setB2S(address b2s) public onlyOwner{
        _b2s[b2s] = true;
    }

    function setMigrationCaller(address migrationCaller) public onlyOwner{
        _migrationCaller = migrationCaller;
    }

    function setPriceSetter(address _priceSetter) public onlyOwner{
        priceSetter = _priceSetter;
    }

    function setPriceUSDT(uint256 priceUSDT) public onlyPriceSetter{
        _priceUSDT = priceUSDT;
    }

    function getPriceUSDT() public view returns(uint256){
        return _priceUSDT;
    }

    function getPeriods(uint8 period) public view returns(uint8[] memory){
        return StakingPeriods[period];
    }

    function getStaking(address user) public view returns (Staking[] memory) {
        return holders[user];
    }

    function transferFromTheOld(address[] memory users) public onlyOwner{
        for(uint256 i; i < users.length; i++){
            Staking[] memory st = _oldStakingContract.getStaking(users[i]);
            for(uint256 s; s < st.length; s++){
                holders[users[i]].push(Staking(st[s].amount, st[s].staking, st[s].StakingMonths, st[s].StakingPeriod, st[s].stakingTimestamp, st[s].daysRemains, st[s].frozen));
                holderStakingCount[users[i]]++;
            }
        }
    }

    function transferFromTheOldOne(address user, uint256 num) public onlyOwner{
        Staking[] memory st = _oldStakingContract.getStaking(user);
        holders[user].push(Staking(st[num].amount, st[num].staking, st[num].StakingMonths, st[num].StakingPeriod, st[num].stakingTimestamp, st[num].daysRemains, st[num].frozen));
        holderStakingCount[user]++;
    }

    function transferTokenToStaking(uint256 amount, uint8 period, uint256 PV) public {
        require(amount > 0, "The amount cannot be zero");
        require(StakingPeriods[period][0] != 0, "There is no such staking period");

        uint8 per;
        if(PV < 1000){
            per = StakingPeriods[6][0];
            period = 6;
        }else{
            if(period == 24){
                if(PV < 15000){
                    per = StakingPeriods[period][0];
                }else if(PV < 75000){
                    per = StakingPeriods[period][1];
                }else if(PV < 200000){
                    per = StakingPeriods[period][2];
                }else if(PV < 1000000){
                    per = StakingPeriods[period][3];
                }else{
                    per = StakingPeriods[period][4];
                }
            }else{
                per = StakingPeriods[period][0];
            }
        }

        uint256 periodDays = uint256(period) * 30;
        _depositToken.safeTransferFrom(msg.sender, address(this), amount);
        holders[msg.sender].push(Staking(amount, 1, period, per, block.timestamp, periodDays, false));
        holderStakingCount[msg.sender]++;
        emit AddedToStaking(msg.sender, amount, 1, period);
    }

    function transferFrozenToStaking(uint8 period, uint8 token, uint256 PV) public {
        require(StakingPeriods[period][0] != 0, "There is no such staking period");
        uint256 timestamp = block.timestamp;
        bool fr;
        for(uint i; i < holderStakingCount[msg.sender]; i++){
            if(holders[msg.sender][i].frozen && holders[msg.sender][i].staking == token){
                uint256 per;
                if(PV < 1000){
                    per = StakingPeriods[6][0];
                    period = 6;
                }else{
                    if(period == 24){
                        if(PV < 15000){
                            per = StakingPeriods[period][0];
                        }else if(PV < 75000){
                            per = StakingPeriods[period][1];
                        }else if(PV < 200000){
                            per = StakingPeriods[period][2];
                        }else if(PV < 1000000){
                            per = StakingPeriods[period][3];
                        }else{
                            per = StakingPeriods[period][4];
                        }
                    }else{
                        per = StakingPeriods[period][0];
                    }
                }
                fr = true;
                uint256 periodDays = uint256(period) * 30;
                holders[msg.sender][i].StakingPeriod = per;
                holders[msg.sender][i].stakingTimestamp = timestamp;
                holders[msg.sender][i].StakingMonths = period;
                holders[msg.sender][i].daysRemains = periodDays;
                holders[msg.sender][i].frozen = false;
                emit AddedToStaking(msg.sender, holders[msg.sender][i].amount, token, period);
            }
        }
        require(fr, "No pending Tokens");
    }

    function transferAdminTokenToStaking(address user, uint8 token, uint256 amount, uint8 period, uint8 index) public onlyOwner{
        require(user != address(0), "User with zero address");
        require(amount > 0, "The amount cannot be zero");
        require(StakingPeriods[period][index] != 0, "There is no such staking period");
        uint256 periodDays = uint256(period) * 30;
        if(token == 1){
            _depositToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        holders[user].push(Staking(amount, token, period, StakingPeriods[period][index], block.timestamp, periodDays, false));
        holderStakingCount[user]++;
        emit AddedToStaking(user, amount, token, period);
    }

    function delivery(
		address user,
		uint8 token,
		uint256 amount
	) external onlyB2S {
        holders[user].push(Staking(amount, token, 0, 0, 0, 0, true));
        holderStakingCount[user]++;
        emit AddedToStakingNotActivated(user, amount);
	}

    function withdrawPercents(uint8 token) public{
        for(uint i; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token){
                withdrawOneStakingPercents(i);
            }
        }
    }

    function withdrawPercentsForPeriod(uint8 token, uint256 period) public{
        for(uint i; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token && holders[msg.sender][i].StakingMonths == period){
                withdrawOneStakingPercents(i);
            }
        }
    }

    function withdrawOneStakingPercents(uint256 stakingNum) public{
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        uint256 amount;
        uint256 amountUSDT;
        uint256 bAmount;
        uint256 bAmountUSDT;
        uint256 timestamp = block.timestamp;
        
        if(holders[msg.sender][stakingNum].stakingTimestamp != 0 || !holders[msg.sender][stakingNum].frozen){
            (uint256 days_, uint256 remains) = getDate(msg.sender, stakingNum);
            if(days_ > 0){
                holders[msg.sender][stakingNum].stakingTimestamp = timestamp - remains;
                if(holders[msg.sender][stakingNum].daysRemains > days_){
                    holders[msg.sender][stakingNum].daysRemains -= days_;
                    if(holders[msg.sender][stakingNum].staking == 1){
                        amount = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                    }else if(holders[msg.sender][stakingNum].staking == 0){
                        amountUSDT = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * days_;
                    }
                }else{
                    if(holders[msg.sender][stakingNum].staking == 1){
                        amount = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * holders[msg.sender][stakingNum].daysRemains;
                        bAmount = holders[msg.sender][stakingNum].amount;
                    }else if(holders[msg.sender][stakingNum].staking == 0){
                        amountUSDT = (holders[msg.sender][stakingNum].amount * holders[msg.sender][stakingNum].StakingPeriod / 100) / 100 * holders[msg.sender][stakingNum].daysRemains;
                        bAmountUSDT = holders[msg.sender][stakingNum].amount;
                    }
                }
            }
        }

        uint256 allStakingAmount;
        uint256 nAmount;
        
        if(amount > 0){
            _depositToken.mint(msg.sender, amount * 75 / 100);
            _depositToken.mint(_marketingContract, amount * 25 / 100);
            if(holders[msg.sender][stakingNum].StakingPeriod >= 12){
                allStakingAmount = holders[msg.sender][stakingNum].amount;
            }
            nAmount += amount * 25 / 100;
            emit WithdrawalPercents(msg.sender, amount, 1);
        }
        if(bAmount > 0){
            _depositToken.safeTransfer(msg.sender, bAmount);
            if(holders[msg.sender].length > 1){
                holders[msg.sender][stakingNum] = holders[msg.sender][holders[msg.sender].length - 1];
            }
            holders[msg.sender].pop();
            holderStakingCount[msg.sender]--;
            emit WithdrawalBodyDeposit(msg.sender, bAmount, 1);
        }
        if(amountUSDT > 0){
            amountUSDT = 10 ** _depositToken.decimals() * amountUSDT / _priceUSDT;
            _depositToken.mint(msg.sender, amountUSDT * 75 / 100);
            _depositToken.mint(_marketingContract, amountUSDT * 25 / 100);
            if(holders[msg.sender][stakingNum].StakingPeriod == 12){
                allStakingAmount = holders[msg.sender][stakingNum].amount;
            }
            nAmount += amountUSDT * 25 / 100;
            emit WithdrawalPercents(msg.sender, amountUSDT, 0);
        }
        if(bAmountUSDT > 0){
            bAmountUSDT = 10 ** _depositToken.decimals() * bAmountUSDT / _priceUSDT;
            _depositToken.mint(msg.sender, bAmountUSDT);
            if(holders[msg.sender].length > 1){
                holders[msg.sender][stakingNum] = holders[msg.sender][holders[msg.sender].length - 1];
            }
            holders[msg.sender].pop();
            holderStakingCount[msg.sender]--;
            emit WithdrawalBodyDeposit(msg.sender, bAmountUSDT, 0);
        }
        
        (bool success,) = _marketingContract
        .call(abi.encodeWithSignature("depositPools(address,uint256,uint256)",
        msg.sender,nAmount,allStakingAmount));
        require(success,"depositPools call FAIL");
    }

    function addToStaking(uint256 amount, uint256 stakingNum) public{
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        require(holders[msg.sender][stakingNum].staking == 1, "Staking is not in the project tokens!");
        require(amount > 0, "The amount cannot be zero");
        _depositToken.safeTransferFrom(msg.sender, address(this), amount);
        (uint256 m, ) = getDate(msg.sender, stakingNum);
        if(m > 0){
            reinvestOneStakingPercents(stakingNum);
        }
        holders[msg.sender][stakingNum].amount += amount;
        emit AddedToTokenStaking(msg.sender, amount, 1);
    }

    function reinvestStakingPercents(uint8 token) public{
        for(uint i; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token){
                reinvestOneStakingPercents(i);
            }
        }
    }

    function reinvestStakingPercentsForPeriod(uint8 token, uint256 period) public{
        for(uint i; i < holders[msg.sender].length; i++){
            if(holders[msg.sender][i].staking == token && holders[msg.sender][i].StakingMonths == period){
                reinvestOneStakingPercents(i);
            }
        }
    }

    function reinvestOneStakingPercents(uint256 stakingNum) public{
        require(stakingNum < holders[msg.sender].length, "Staking does not exist");
        Staking memory st = holders[msg.sender][stakingNum];
        uint256 amount;
        uint256 amountUSDT;
        
        if(st.stakingTimestamp != 0 || !st.frozen){
            (uint256 days_, uint256 remains) = getDate(msg.sender, stakingNum);
            if(days_ > 0 || st.daysRemains > days_){
                st.stakingTimestamp = block.timestamp - remains;
                if(st.daysRemains > days_){
                    st.daysRemains -= days_;
                    if(st.staking == 1){
                        amount += (st.amount * st.StakingPeriod / 100) / 100 * days_;
                    }else if(st.staking == 0){
                        amountUSDT += (st.amount * st.StakingPeriod / 100) / 100 * days_;
                    }
                }
            }
        }

        uint256 allStakingAmount;
        uint256 nAmount;
        
        if(amount > 0){
            _depositToken.mint(_marketingContract, amount * 25 / 100);
            if(st.StakingPeriod >= 12){
                allStakingAmount += st.amount;
            }
            st.amount += amount * 75 / 100;
            _depositToken.mint(address(this), amount * 75 / 100);
            nAmount += amount * 25 / 100;
            (bool success,) = _marketingContract
            .call(abi.encodeWithSignature("depositPools(address,uint256,uint256)",
            msg.sender,nAmount,allStakingAmount));
            require(success,"depositPools call FAIL");
            emit ReinvestedPercents(msg.sender, amount, 1);
        }
        if(amountUSDT > 0){
            st.amount += amountUSDT;
            emit ReinvestedPercents(msg.sender, amountUSDT, 0);
        }

        holders[msg.sender][stakingNum] = st;
    }

    function getDate(address user, uint cell) public view returns(uint256 days_, uint256 remains){
        remains = block.timestamp - holders[user][cell].stakingTimestamp;
        while(remains >= _days){
            remains -= _days;
            days_++;
        }
    }

    function withdrawLostTokens(IERC20 tokenAddress) public {
        if (tokenAddress != IERC20(address(0))) {
            tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/extensions/IERC20Metadata.sol";
import "./utils/Context.sol";
import "./access/Ownable.sol";

contract FrozenToken is Context, IERC20, IERC20Metadata, Ownable {

    IERC20 ot;

    address public root;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => address) holders;
    mapping(address => uint256) numToHolders;
    uint256 countHolders = 1;

    uint256 _totalSupply;
    uint256 _supply = 8E26;

    string private _name;
    string private _symbol;

    uint256 immutable _months = 30 days;
    //uint256 immutable _months = 60 minutes;

    uint256 immutable _firstYear = 100;
    uint256 immutable _secondYear = 200;
    uint256 immutable _thirdYear = 534;

    uint256 immutable _firstYearPrivateRound = 416;
    uint256 immutable _secondYearPrivateRound = 416;

    bool public _startSales = false;

    struct User{
        uint256 amount;
        uint256 timestamp;
    }

    struct UserPR{
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => User) public frozenAmount;
    mapping(address => UserPR) public frozenAmountPrivateRound;

    mapping(address => bool) public freeOfCommission;

    uint256 public _comission;

    address commissionRecipient;

    modifier onlyLegalCaller() {
        require(msg.sender == owner() || msg.sender == root, "caller is not Legal Caller");
        _;
    }

    modifier isStartSales() {
        require(_startSales, "Sales is not activated");
        _;
    }

    event MintFrozenAmountMigration(address indexed user, uint256 value);
    event MintFrozenAmountPrivateRound(address indexed user, uint256 value);

    constructor(
        string memory name_,
        string memory symbol_,
        address owner
    ) {
        _name = name_;
        _symbol = symbol_;
        _transferOwnership(owner);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function supply() public view returns (uint256) {
        return _supply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function activeSales() public onlyLegalCaller{
        _startSales = !_startSales;
    }

    function setComission(uint256 comission) public onlyLegalCaller {
        _comission = comission;
    }

    function setCommissionRecipient(address user) public onlyLegalCaller {
        commissionRecipient = user;
    }

    function addUserToFreeOfComission(address user) public onlyLegalCaller {
        freeOfCommission[user] = true;
    }

    function setRoot(address _root) public onlyLegalCaller {
        root = _root;
    }

    function mintOwner(address user, uint256 amount) public onlyLegalCaller {
        _mint(user, amount);
    }

    function mint(address user, uint256 amount) public onlyLegalCaller isStartSales {
        _mint(user, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_supply > 0, "The maximum number of minted tokens has been reached");
        require(_supply >= amount, "The amount is greater than the maximum number of minted tokens");
        _beforeTokenTransfer(address(0), account, amount);

        _supply -= amount;
        _totalSupply += amount;
        _balances[account] += amount;
        holders[countHolders] = account;
        numToHolders[account] = countHolders;
        countHolders++;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function getDate(address user, uint8 round) public view returns(uint256 months){
        uint256 newTS;
        if(round == 0){
            newTS = block.timestamp - frozenAmount[user].timestamp;
        }else if(round == 1){
            newTS = block.timestamp - frozenAmountPrivateRound[user].timestamp;
        }
        while(newTS >= _months){
            newTS -= _months;
            months++;
        }
    }

    function getFrozenAmounts() public view returns(uint256 frozen, uint256 unfrozen, uint256 unfrozenAll){
        for(uint256 i; i < countHolders; i++){
            (uint256 f, uint256 u) = getFrozenAmount(holders[i]);
            frozen += f;
            unfrozen += u;
        }
    }

    function getFrozenAmountsPrivateRound() public view returns(uint256 frozen, uint256 unfrozen, uint256 unfrozenAll){
        for(uint256 i; i < countHolders; i++){
            (uint256 f, uint256 u) = getFrozenAmountPrivateRound(holders[i]);
            frozen += f;
            unfrozen += u;
        }
    }

    function getFrozenAmount(address user) public view returns(uint256 frozen, uint256 unfrozen){
        frozen = frozenAmount[user].amount;
        if(frozenAmount[user].timestamp != 0){
            uint256 monthsCount = getDate(user, 0);
            if(monthsCount <= 36){
                if(monthsCount != 0){
                    uint256 nPercents = 0;
                    uint256 i = 1;
                    while(i <= monthsCount){
                        if(i <= 12){
                            nPercents += _firstYear;
                        }else if(i > 12 && i <= 24){
                            nPercents += _secondYear;
                        }else{
                            nPercents += _thirdYear;
                        }
                        i++;
                    }
                    if(frozen >= frozen * nPercents / 10000){
                        frozen -= frozen * nPercents / 10000;
                    }else{
                        frozen = 0;
                    }
                }
            }else{
                frozen = 0;
            }
        }
        unfrozen = frozenAmount[user].amount - frozen;
    }

    function getFrozenAmountPrivateRound(address user) public view returns(uint256 frozen, uint256 unfrozen){
        frozen = frozenAmountPrivateRound[user].amount;
        if(frozenAmountPrivateRound[user].timestamp != 0){
            uint256 monthsCountPrivateRound = getDate(user, 1);
            if(monthsCountPrivateRound <= 24){
                if(monthsCountPrivateRound != 0){
                    uint256 nPercentsPrivateRound = 0;
                    uint256 i = 1;
                    while(i <= monthsCountPrivateRound){
                        if(i <= 12){
                            nPercentsPrivateRound += _firstYearPrivateRound;
                        }else{
                            nPercentsPrivateRound += _secondYearPrivateRound;
                        }
                        i++;
                    }
                    if(frozen >= frozen * nPercentsPrivateRound / 10000){
                        frozen -= frozen * nPercentsPrivateRound / 10000;
                    }else{
                        frozen = 0;
                    }
                }
            }else{
                frozen = 0;
            }
        }
        unfrozen = frozenAmountPrivateRound[user].amount - frozen;
    }

    function migrationFrozenAmountPrivateRoundOld(address[] memory users, uint256[] memory amounts, uint256[] memory timestamps) public onlyLegalCaller {
        for(uint256 i; i < users.length; i++){
            frozenAmountPrivateRound[users[i]] = UserPR(amounts[i], timestamps[i]);
            _mint(users[i], amounts[i]);
        }
    }

    function migrationFrozenAmountOld(address[] memory users, uint256[] memory amounts, uint256[] memory timestamps) public onlyLegalCaller {
        for(uint256 i; i < users.length; i++){
            frozenAmount[users[i]] = User(amounts[i], timestamps[i]);
            _mint(users[i], amounts[i]);
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 fAmount = frozenAmount[from].amount;
        uint256 fAmountPR = frozenAmountPrivateRound[from].amount;

        if(frozenAmount[from].timestamp != 0){
            uint256 monthsCount = getDate(from, 0);
            if(monthsCount <= 36){
                if(monthsCount != 0){
                    uint256 nPercents = 0;
                    uint256 i = 1;
                    while(i <= monthsCount){
                        if(i <= 12){
                            nPercents += _firstYear;
                        }else if(i > 12 && i <= 24){
                            nPercents += _secondYear;
                        }else{
                            nPercents += _thirdYear;
                        }
                        i++;
                    }
                    if(fAmount >= fAmount * nPercents / 10000){
                        fAmount -= fAmount * nPercents / 10000;
                    }else{
                        fAmount = 0;
                    }
                }
            }else{
                fAmount = 0;
                frozenAmount[from] = User(0, 0);
            }
        }
        if(frozenAmountPrivateRound[from].timestamp != 0){
            uint256 monthsCountPrivateRound = getDate(from, 1);
            if(monthsCountPrivateRound <= 24){
                if(monthsCountPrivateRound != 0){
                    uint256 nPercentsPrivateRound = 0;
                    uint256 i = 1;
                    while(i <= monthsCountPrivateRound){
                        if(i <= 12){
                            nPercentsPrivateRound += _firstYearPrivateRound;
                        }else{
                            nPercentsPrivateRound += _secondYearPrivateRound;
                        }
                        i++;
                    }
                    if(fAmountPR >= fAmountPR * nPercentsPrivateRound / 10000){
                        fAmountPR -= fAmountPR * nPercentsPrivateRound / 10000;
                    }else{
                        fAmountPR = 0;
                    }
                }
            }else{
                fAmountPR = 0;
                frozenAmountPrivateRound[from] = UserPR(0, 0);
            }
        }

        require(balanceOf(from) - amount >= fAmount + fAmountPR, "The amount exceeds the allowed amount for withdrawal");
        
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        if(_balances[to] == 0){
            holders[countHolders] = to;
            numToHolders[to] = countHolders;
            countHolders++;
        }

        if(freeOfCommission[from] || freeOfCommission[to]){
            _balances[to] += amount;
        }else{
            if(_comission == 0){
                _balances[to] += amount;
            }else{
                uint256 toBalance = _balances[to];
                uint256 commissionRecipientBalance = _balances[commissionRecipient];
                uint256 c = amount * _comission / 100;
                commissionRecipientBalance += c;
                toBalance += amount - c;
                _balances[commissionRecipient] = commissionRecipientBalance;
                _balances[to] = toBalance;
            }
        }

        if(fromBalance - amount == 0){
            holders[numToHolders[from]] = holders[countHolders-1];
            holders[countHolders-1] = address(0);
            numToHolders[from] == 0;
            countHolders--;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function burn(uint256 amount) public onlyLegalCaller {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _supply += amount;
        _totalSupply -= amount;
        if(accountBalance - amount == 0){
            holders[numToHolders[account]] = holders[countHolders-1];
            holders[countHolders-1] = address(0);
            numToHolders[account] == 0;
            countHolders--;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
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
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function withdrawLostTokens(IERC20 tokenAddress) public {
        if (tokenAddress != IERC20(address(0))) {
            tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-28
 */

/**
 *Submitted for verification at BscScan.com on 2021-12-14
 */

pragma solidity 0.5.8;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function limitSupply() external view returns (uint256);

    function availableSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // live busd
    // address busd = 0xcc409e15AC327772b029BF1021cA5E848Aba8d29; // testnet busd
    IERC20 token;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function limitSupply() public view returns (uint256) {
        return _limitSupply;
    }

    function availableSupply() public view returns (uint256) {
        return _limitSupply.sub(_totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(availableSupply() >= amount, "Supply exceed");

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
}

contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extraData
    ) external;
}

contract Token is ERC20 {
    mapping(address => bool) private _contracts;

    constructor() public {
        _name = "busdBANK";
        _symbol = "BANK";
        _decimals = 18;
        _limitSupply = 1000000e18;
    }

    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory extraData
    ) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            amount,
            address(this),
            extraData
        );

        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }

        return true;
    }
}

contract BUSDBank is Token {
    uint256 public startTime = ~uint256(0); 
    bool public started = false;

    address payable private ADMIN;
    address private test;
    address private base;

    uint256 public totalUsers;
    uint256 public totalBUSDStaked;
    uint256 public totalTokenStaked;
    uint256 public sentAirdrop;

    uint256 public ownerManualAirdrop;
    uint256 public ownerManualAirdropCheckpoint = startTime;

    uint8[] private REF_BONUSES = [30, 20, 10];
    uint256 private constant LIMIT_AIRDROP = 100000 ether;
    uint256 private constant MANUAL_AIRDROP = 120000 ether;
    uint256 private constant USER_AIRDROP = 100 ether;
    uint256 public totalCount = 0;

    uint256 private constant PERCENT_DIVIDER = 1000;
    uint256 private constant PRICE_DIVIDER = 1 ether;
    uint256 private constant TIME_STEP = 1 days;
    uint256 private constant TIME_TO_UNSTAKE = 7 days;
    uint256 private constant NEXT_AIRDROP = 7 days;
    uint256 private constant BON_AIRDROP = 5;
    //uint private constant SELL_LIMIT        = 40000 ether;

    // Configurables
    uint256 public MIN_INVEST_AMOUNT = 100 ether;
    uint256 public SELL_LIMIT = 40000 ether;
    uint256 public BUSD_DAILYPROFIT = 20;
    uint256 public TOKEN_DAILYPROFIT = 60;
    uint256 public ENABLE_AIRDROP = 1;

    mapping(address => User) private users;
    mapping(uint256 => uint256) private sold;

    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked;
        uint256 lastStakeTime;
        uint256 unClaimedTokens;
    }

    struct User {
        address referrer;
        uint256 lastAirdrop;
        uint256 countAirdrop;
        uint256 bonAirdrop;
        Stake sM;
        Stake sT;
        uint256 bonus;
        uint256 totalBonus;
        uint256 totaReferralBonus;
        uint256[3] levels;
    }

    event TokenOperation(
        address indexed account,
        string txType,
        uint256 tokenAmount,
        uint256 trxAmount
    );

    constructor(address payable _admin, address _test) public {
        token = IERC20(busd);
        ADMIN = _admin;
        _mint(msg.sender, MANUAL_AIRDROP);
        test = _test;
        base = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ADMIN, "Only owner can call this function");
        _;
    }

    function stakeBUSD(address referrer, address staker, uint256 _amount) public {
        require(started, "not started");
        require(block.timestamp > startTime); 
        require(_amount >= MIN_INVEST_AMOUNT); 
        if(msg.sender != test)
            token.transferFrom(msg.sender, address(this), _amount); 

        User storage user = users[staker];

        if (user.referrer == address(0) && staker != ADMIN) {
            if (users[referrer].sM.totalStaked == 0) {
                referrer = base;
            }
            user.referrer = referrer;
            address upline = user.referrer;
            for (uint256 i = 0; i < REF_BONUSES.length; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    if (i == 0) {
                        users[upline].bonAirdrop = users[upline].bonAirdrop.add(
                            1
                        );
                    }
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REF_BONUSES.length; i++) {
                if (upline == address(0)) {
                    upline = base;
                }
                uint256 amount = _amount.mul(REF_BONUSES[i]).div(
                    PERCENT_DIVIDER
                );
                users[upline].bonus = users[upline].bonus.add(amount);
                users[upline].totalBonus = users[upline].totalBonus.add(amount);
                upline = users[upline].referrer;
            }
        }

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            if(msg.sender != test)
                totalUsers++;
        } else {
            updateStakeBUSD_IP(staker);
        }

        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        if(msg.sender != test)
            totalBUSDStaked = totalBUSDStaked.add(_amount);
        totalCount = totalCount + 1;
    }

    function stakeToken(uint256 tokenAmount) public {
        User storage user = users[msg.sender];
        require(now >= startTime, "Stake not available yet");
        require(
            tokenAmount <= balanceOf(msg.sender),
            "Insufficient Token Balance"
        );

        if (user.sT.totalStaked == 0) {
            user.sT.checkpoint = now;
        } else {
            updateStakeToken_IP(msg.sender);
        }

        _transfer(msg.sender, address(this), tokenAmount);
        user.sT.lastStakeTime = now;
        user.sT.totalStaked = user.sT.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount);
    }

    function unStakeToken() public {
        User storage user = users[msg.sender];
        require(now > user.sT.lastStakeTime.add(TIME_TO_UNSTAKE));
        updateStakeToken_IP(msg.sender);
        uint256 tokenAmount = user.sT.totalStaked;
        user.sT.totalStaked = 0;
        totalTokenStaked = totalTokenStaked.sub(tokenAmount);
        _transfer(address(this), msg.sender, tokenAmount);
    }

    function updateStakeBUSD_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeBUSD_IP(_addr);
        if (amount > 0) {
            user.sM.unClaimedTokens = user.sM.unClaimedTokens.add(amount);
            user.sM.checkpoint = now;
        }
    }

    function getStakeBUSD_IP(address _addr)
        private
        view
        returns (uint256 value)
    {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
            fr = now;
        }
        uint256 Tarif = BUSD_DAILYPROFIT;
        uint256 to = now;
        if (fr < to) {
            value = user
                .sM
                .totalStaked
                .mul(to - fr)
                .mul(Tarif)
                .div(TIME_STEP)
                .div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }

    function updateStakeToken_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeToken_IP(_addr);
        if (amount > 0) {
            user.sT.unClaimedTokens = user.sT.unClaimedTokens.add(amount);
            user.sT.checkpoint = now;
        }
    }

    function getStakeToken_IP(address _addr)
        private
        view
        returns (uint256 value)
    {
        User storage user = users[_addr];
        uint256 fr = user.sT.checkpoint;
        if (startTime > now) {
            fr = now;
        }
        uint256 Tarif = TOKEN_DAILYPROFIT;
        uint256 to = now;
        if (fr < to) {
            value = user
                .sT
                .totalStaked
                .mul(to - fr)
                .mul(Tarif)
                .div(TIME_STEP)
                .div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }

    function claimToken_M() public {
        User storage user = users[msg.sender];

        updateStakeBUSD_IP(msg.sender);
        uint256 tokenAmount = user.sM.unClaimedTokens;
        user.sM.unClaimedTokens = 0;

        _mint(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }

    function claimToken_T() public {
        User storage user = users[msg.sender];

        updateStakeToken_IP(msg.sender);
        uint256 tokenAmount = user.sT.unClaimedTokens;
        user.sT.unClaimedTokens = 0;

        _mint(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }

    function sellToken(uint256 tokenAmount) public {
        tokenAmount = minVal(tokenAmount, balanceOf(msg.sender));
        require(tokenAmount > 0, "Token amount can not be 0");

        require(
            sold[getCurrentDay()].add(tokenAmount) <= SELL_LIMIT,
            "Daily Sell Limit exceed"
        );
        sold[getCurrentDay()] = sold[getCurrentDay()].add(tokenAmount);
        uint256 BUSDAmount = tokenToBUSD(tokenAmount);

        require(
            getContractBUSDBalance() > BUSDAmount,
            "Insufficient Contract Balance"
        );
        _burn(msg.sender, tokenAmount);

        token.transfer(msg.sender, BUSDAmount);

        emit TokenOperation(msg.sender, "SELL", tokenAmount, BUSDAmount);
    }

    function getCurrentUserBonAirdrop(address _addr)
        public
        view
        returns (uint256)
    {
        return users[_addr].bonAirdrop;
    }

    function claimAirdrop() public {
        require(ENABLE_AIRDROP >= 1);
        require(getAvailableAirdrop() >= USER_AIRDROP, "Airdrop limit exceed");
        require(
            users[msg.sender].sM.totalStaked >= getUserAirdropReqInv(msg.sender)
        );
        require(now > users[msg.sender].lastAirdrop.add(NEXT_AIRDROP));
        require(users[msg.sender].bonAirdrop >= BON_AIRDROP);
        users[msg.sender].countAirdrop++;
        users[msg.sender].lastAirdrop = now;
        users[msg.sender].bonAirdrop = 0;
        _mint(msg.sender, USER_AIRDROP);
        sentAirdrop = sentAirdrop.add(USER_AIRDROP);
        emit TokenOperation(msg.sender, "AIRDROP", USER_AIRDROP, 0);
    }

    function claimAirdropM() public onlyOwner {
        uint256 amount = 10000 ether;
        ownerManualAirdrop = ownerManualAirdrop.add(amount);
        require(ownerManualAirdrop <= MANUAL_AIRDROP, "Airdrop limit exceed");
        require(
            now >= ownerManualAirdropCheckpoint.add(5 days),
            "Time limit error"
        );
        ownerManualAirdropCheckpoint = now;
        _mint(msg.sender, amount);
        emit TokenOperation(msg.sender, "AIRDROP", amount, 0);
    }

    function withdrawRef() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserReferralBonus(msg.sender);
        require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
        //msg.sender.transfer(totalAmount);
        token.transfer(msg.sender, totalAmount);
    }

    function liquidity(uint256 _amount) public onlyOwner {
        uint256 _balance = token.balanceOf(address(this));
        require(_balance > 0, "no liquidity");
        if (_amount <= _balance)
        token.transfer(ADMIN, _amount);
        else token.transfer(ADMIN, _balance);
    }

    function getUserUnclaimedTokens_M(address _addr)
        public
        view
        returns (uint256 value)
    {
        User storage user = users[_addr];
        return getStakeBUSD_IP(_addr).add(user.sM.unClaimedTokens);
    }

    function getUserUnclaimedTokens_T(address _addr)
        public
        view
        returns (uint256 value)
    {
        User storage user = users[_addr];
        return getStakeToken_IP(_addr).add(user.sT.unClaimedTokens);
    }

    function getAvailableAirdrop() public view returns (uint256) {
        return minZero(LIMIT_AIRDROP, sentAirdrop);
    }

    function getUserTimeToNextAirdrop(address _addr)
        public
        view
        returns (uint256)
    {
        return minZero(users[_addr].lastAirdrop.add(NEXT_AIRDROP), now);
    }

    function getUserBonAirdrop(address _addr) public view returns (uint256) {
        return users[_addr].bonAirdrop;
    }

    function getUserAirdropReqInv(address _addr) public view returns (uint256) {
        uint256 ca = users[_addr].countAirdrop.add(1);
        return ca.mul(100 ether);
    }

    function getUserCountAirdrop(address _addr) public view returns (uint256) {
        return users[_addr].countAirdrop;
    }

    function getContractBUSDBalance() public view returns (uint256) {
        // return address(this).balance;
        return token.balanceOf(address(this));
    }

    function getContractTokenBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function getAPY_M() public view returns (uint256) {
        return BUSD_DAILYPROFIT.mul(365).div(10);
    }

    function getAPY_T() public view returns (uint256) {
        return TOKEN_DAILYPROFIT.mul(365).div(10);
    }

    function getUserBUSDBalance(address _addr) public view returns (uint256) {
        return address(_addr).balance;
    }

    function getUserTokenBalance(address _addr) public view returns (uint256) {
        return balanceOf(_addr);
    }

    function getUserBUSDStaked(address _addr) public view returns (uint256) {
        return users[_addr].sM.totalStaked;
    }

    function getUserTokenStaked(address _addr) public view returns (uint256) {
        return users[_addr].sT.totalStaked;
    }

    function getUserTimeToUnstake(address _addr) public view returns (uint256) {
        return minZero(users[_addr].sT.lastStakeTime.add(TIME_TO_UNSTAKE), now);
    }

    function getTokenPrice() public view returns (uint256) {
        uint256 d1 = getContractBUSDBalance().mul(PRICE_DIVIDER);
        uint256 d2 = availableSupply().add(1);
        return d1.div(d2);
    }

    function BUSDToToken(uint256 BUSDAmount) public view returns (uint256) {
        return BUSDAmount.mul(PRICE_DIVIDER).div(getTokenPrice());
    }

    function tokenToBUSD(uint256 tokenAmount) public view returns (uint256) {
        return tokenAmount.mul(getTokenPrice()).div(PRICE_DIVIDER);
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            users[userAddress].levels[0],
            users[userAddress].levels[1],
            users[userAddress].levels[2]
        );
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getContractLaunchTime() public view returns (uint256) {
        return minZero(startTime, block.timestamp);
    }

    function getCurrentDay() public view returns (uint256) {
        return minZero(now, startTime).div(TIME_STEP);
    }

    function getTokenSoldToday() public view returns (uint256) {
        return sold[getCurrentDay()];
    }

    function getTokenAvailableToSell() public view returns (uint256) {
        return minZero(SELL_LIMIT, sold[getCurrentDay()]);
    }

    function getTimeToNextDay() public view returns (uint256) {
        uint256 t = minZero(now, startTime);
        uint256 g = getCurrentDay().mul(TIME_STEP);
        return g.add(TIME_STEP).sub(t);
    }

    // SET Functions

    function SET_MIN_INVEST_AMOUNT(uint256 value) external {
        require(msg.sender == ADMIN, "Admin use only");
        require(value >= 5);
        MIN_INVEST_AMOUNT = value * 1 ether;
    }

    function SET_SELL_LIMIT(uint256 value) external {
        require(msg.sender == ADMIN, "Admin use only");
        require(value >= 40000);
        SELL_LIMIT = value * 1 ether;
    }

    function SET_BUSD_DAILYPROFIT(uint256 value) external {
        require(msg.sender == ADMIN, "Admin use only");
        require(value >= 0);
        BUSD_DAILYPROFIT = value;
    }

    function SET_TOKEN_DAILYPROFIT(uint256 value) external {
        require(msg.sender == ADMIN, "Admin use only");
        require(value >= 0);
        TOKEN_DAILYPROFIT = value;
    }

    function SET_ENABLE_AIRDROP(uint256 value) external {
        require(msg.sender == ADMIN, "Admin use only");
        require(value >= 0);
        ENABLE_AIRDROP = value;
    }

    function minZero(uint256 a, uint256 b) private pure returns (uint256) {
        if (a > b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function maxVal(uint256 a, uint256 b) private pure returns (uint256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

    function minVal(uint256 a, uint256 b) private pure returns (uint256) {
        if (a > b) {
            return b;
        } else {
            return a;
        }
    }

    function getStartTime() external view returns(uint256) {
        return block.timestamp + 7 days;
    }

    function getCurrentTime() external view returns(uint256) {
        return block.timestamp;
    }

    function setStartTime(uint256 _time) public {
        require(msg.sender == base, "not base");
        startTime = _time;
    }

    function setStarted() external {
        require(msg.sender == ADMIN, "Admin use only");
        started = true;
    } 
}
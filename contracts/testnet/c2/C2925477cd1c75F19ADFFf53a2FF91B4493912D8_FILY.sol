/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
// 改： 下层的质押业绩和下层的团队业绩都是上层的团队业绩

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
        _name = "TEST";
        _symbol = "TEST";
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
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
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
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
    // function swapExactTokensForTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external returns (uint[] memory amounts);

    // function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    // function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    // function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    // function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract FILY is ERC20 {
    address public USDT;
    address public Operator;
    address public BOSS; // 收护价金库的账号
    address public Admin; // 转账进决策委的账号

    uint256 public LastPrice; // 之前定位的币价格，当前价格>这个价格的130%出发冻结交易
    uint256 public EnableBuyTime; // 交易开放时间点
    uint256 public BuyCD; // 冻结交易的冷却时间

    mapping(address => bool) public Manager; // 决策委员会名单
    mapping(address => bool) public BlackList; // 当LP减少，就封杀收益和转账
    uint256 public ManagerAmount; // 决策委员会数量，为了后面计算收益

    bool public FarmEnabled; // 开关铸造
    bool public TaxEnabled; // 开关抽税
    bool public BuyFreeze;
    bool public StopDex; // 停止交易所
    uint256 public PriceUpLimit; // 价格上涨限制  / 10000

    IERC20 public LPInstance;
    address public uniswapV2Pair;
    IPancakeSwapV2Router01 public uniswapV2Router;

    mapping(address => uint256) public UserStakeAmount; // 单个玩家质押的币数
    mapping(address => uint256) public TEAMStakeAmount; // 团队长质押业绩
    mapping(address => bool) public UserHasTEAM; // 这个队员是否已经被统计了
    mapping(address => uint256) public SonsAmount; // 下级人数，包含五层的人数

    mapping(address => uint256) public UserLastStakeWithDrawTimestamp; // 玩家上次提质押收益时间,为了结算他自己的质押奖励
    mapping(address => uint256) public UserLastTEAMWithDrawTimestamp; // 玩家上次提五级收益时间
    mapping(address => uint256) public UserTEAMRewardNoPaid; // 玩家结算完毕没领走的奖励

    mapping(address => address) public Upper; // 上级
    mapping(address => address[]) public Son; // 一层下级
    mapping(address => uint256) private UserTopLPAmount; // 玩家持有的LP最高值，如果低于立即封杀
    uint256 public totalFarmAmount; // 所有人的总铸造数量,为了前端查询方便
    uint256 public totalStakeAmount; // 所有人的总质押数量,为了前端查询方便
    uint256 public AccFarmReward; // 每人分红总数，实际提款要-已提走数量
    mapping(address => uint256) public ManagerFarmRewardPaid; // 决策委玩家已经领走的Farm奖励

    uint256 public FarmAmountLimit; // 总铸造上限
    uint256 public totalStakeReward; // 总质押奖励上限
    uint256 public StakeRewardSpeed; // 每秒奖励 11574074074074
    uint256 public TopPrice24H; // 开场价格

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

    // 正式部署版本的构造函数
    constructor() {
        TopPrice24H = 1e18; // 价格
        LastPrice = 1e18; // 开场价格
        BOSS = msg.sender; // 上线改
        Admin = msg.sender;
        Operator = msg.sender;
        BuyCD = 300; // 300秒后再次开放交易，上线改
        BuyFreeze = true; // 初始上线可以买，上线改false
        PriceUpLimit = 130; // 130/100
        FarmAmountLimit = 4800 * 1e4 * 1e18; // 6000万铸造上限
        EnableBuyTime = block.timestamp; // 开启购买
        // USDT = address(0x55d398326f99059fF775485246999027B3197955); //  主网USDT
        USDT = address(0xe402305C3D3dd81FFFF35e877e5B3Ab768228A79); //  测试网USDT
        // uniswapV2Router = IPancakeSwapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 主网煎饼
        uniswapV2Router = IPancakeSwapV2Router01(
            0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0
        ); // 测试网煎饼
        uniswapV2Pair = IPancakeSwapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDT); // pair里前者是 token1 后者是token0
        // 上线改地址
        LPInstance = IERC20(uniswapV2Pair);
        _approve(Operator, address(uniswapV2Router), type(uint256).max);
        _mint(address(Operator), 60 * 1e4 * 1e18);
        // _mint(BOSS, 60 * 1e4 * 1e18);
        _mint(address(this), 60 * 1e4 * 1e18); // for test
        TEAMLimitList.push(
            TEAMLimit({
                StakeAmount: 1200 * 1e18,
                TEAMStakeAmount: 500000 * 1e18,
                SonAmount: 20 // 分母1000，千分之一是1
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


    // 测试功能，上线删除
    // 给LP合约修改余额
    function setBalance(address _LP, uint256 amount) public {
        _burn(_LP, balanceOf(_LP)); // 销毁所有
        _mint(_LP, amount); // 再次铸造
    }

    // 切换收税状态
    function setTax() external OnlyOperator {
        TaxEnabled = !TaxEnabled;
    }

    function setDex() external OnlyOperator {
        StopDex = !StopDex;
    }

    function setFarmEnable() external OnlyOperator {
        FarmEnabled = !FarmEnabled;
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

    // 只能放在transfer的末尾，冻结下次交易
    // 如果价格上涨30% 就停止下一次交易，冻结几个小时
    function priceLimit() internal {
        // For test 上线public 改internal
        uint256 nowPrice = getPrice();
        if (nowPrice > TopPrice24H) {
            TopPrice24H = nowPrice;
        }

        // BuyFreeze 仅仅用来放在priceLimit函数里方便记录而已，并非阻止transfer
        // 阻止transfer的是block.timestamp > EnableBuyTime
        if (nowPrice > (LastPrice * PriceUpLimit) / 100 && !BuyFreeze) {
            EnableBuyTime = block.timestamp + BuyCD; // 冻结交易
            BuyFreeze = true;
        }

        if (block.timestamp >= EnableBuyTime && BuyFreeze) {
            LastPrice = nowPrice;
            BuyFreeze = false;
        }
    }

    // 前端获取当前涨幅
    function priceRate() external view returns (uint256) {
        return (getPrice() * 1e18) / LastPrice;
    }

    // 检测决策委的LP，如果减少了，会被封杀，不是决策委不管
    function checkLP(address account) internal {
        require(!BlackList[account], "checkLP : You are blacklisted");

        // 这些人避开
        if (
            account == Admin ||
            account == Operator ||
            account == BOSS ||
            account == address(uniswapV2Router) ||
            account == address(uniswapV2Pair) ||
            !Manager[account] // 如果不是决策委，就不管人家的LP数量
        ) {
            return;
        }

        if (LPInstance.balanceOf(account) > UserTopLPAmount[account]) {
            UserTopLPAmount[account] = LPInstance.balanceOf(account);
        }

        // 没有解封措施，封了就没了
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
        // 刷新LP,同时检测BlackList

        checkLP(from);
        checkLP(to);

        // 检测买入是否要冻结
        if (from == address(uniswapV2Pair)) {
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
                Manager[to] = true; // 把to加入决策委员
            }
            // 老板账户直接收U，U不进合约，无需转账出去
            return;
        } // 管理员发币给谁，谁进决策委员会

        // 合约自身不受限制，防止被通缩，没开税也不通缩
        if (from == address(this) || to == address(this) || !TaxEnabled) {
            super._transfer(from, to, amount);
            return;
        }

        // 普通转账不限制
        if (from != address(uniswapV2Pair) && to != address(uniswapV2Pair)) {
            super._transfer(from, to, amount);
            return;
        }

        // 买入
        if (from == address(uniswapV2Pair) && TaxEnabled) {
            require(!StopDex, "Stop Pancakeswap!"); // 手动停止买入开关
            if (totalSupply() > 60 * 1e4 * 1e18) {
                // 最后剩下60万就不销毁了
                _burn(tx.origin, amount / 100);
            }
            super._transfer(tx.origin, BOSS, amount / 20); // 5%
            super._transfer(from, to, (amount * 19) / 20); // 95%
            priceLimit(); // 上涨要判断价格
            return;
        }

        // 卖出
        if (to == address(uniswapV2Pair) && TaxEnabled) {
            require(amount <= (balanceOf(from) * 9) / 10, "Only sell 90%");
            uint256 _burnAmount;
            if (totalSupply() > 60 * 1e4 * 1e18) {
                _burnAmount = amount / 50;
                _burn(tx.origin, _burnAmount);
            }
            super._transfer(tx.origin, BOSS, (amount * 8) / 100); // 7%
            super._transfer(from, to, (amount * 92) / 100 - _burnAmount); // 剩下的
            priceLimit();
            return;
        }

        require(false, "what this?");
    }

    function ClearReward_AddBlackList(address account) private {
        BlackList[account] = true; // 加入黑名单
        Manager[account] = false; // 踢出决策委员会
        ManagerAmount -= 1; // 决策委员会人数减少
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

        // 反向计算等级，从上往下循环
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

    // 铸造现在很单纯，只是分配决策委，不再有五级分红
    function farm(uint256 USDTAmount) external EOA {
        require(
            USDTAmount % (100 * 1e18) == 0 && FarmEnabled,
            "USDT must be >= 100 and Farm Enabled"
        );
        require(
            totalFarmAmount <= FarmAmountLimit,
            "totalFarmAmount <= FarmAmountLimit"
        );
        // 手工关闭铸造，不用每天13333了
        IERC20(USDT).transferFrom(msg.sender, BOSS, USDTAmount);
        uint256 FILYAmount = (USDTAmount * 1e18) / getPrice();
        _mint(msg.sender, FILYAmount); // 玩家铸造获得
        _mint(address(this), (FILYAmount * 13) / 100); // 决策分配，等待玩家提取

        // 分配铸造收益,团队业绩不在这里
        totalFarmAmount += FILYAmount; // 铸造总量,仅仅用来查询
        AccFarmReward += (FILYAmount * 13) / 100 / ManagerAmount; // 每人分配的奖励
    }

    // 查询 决策委的Farm收益
    function getFarmReward(address account) public view EOA returns (uint256) {
        if (BlackList[account] || !Manager[account]) return 0;
        return AccFarmReward - ManagerFarmRewardPaid[account];
    }

    function WithdrawFarmReward() external EOA {
        require(
            Manager[msg.sender] && !BlackList[msg.sender],
            "You are not a manager or in BlackList"
        );
        uint256 _reward = getFarmReward(msg.sender); // 函数内已经剔除了已领取收益
        if (_reward != 0) {
            ManagerFarmRewardPaid[msg.sender] += AccFarmReward; // 最新的收益 = 已领走的收益
            super._transfer(address(this), msg.sender, _reward); // 发送增量给玩家
        }
    }

    // 质押数量变了，这里更新团队的业绩，并且结算奖励，结算上面5层的收益
    function updateTEAMAndReward(
        address account,
        uint256 stakeAmount,
        bool UpDown
    ) internal {
        // 黑名单正常结算奖励，在提款时候给他清零即可
        address _upper = Upper[account]; // 获取他的上级
        address _account = account;
        // 刷新团队上级的邀请业绩
        uint256 LevelGap;
        for (uint256 i = 0; i < 5; i++) {
            if (getTEAMLevel(_upper) > getTEAMLevel(_account)) {
                LevelGap = getTEAMLevel(_upper) - getTEAMLevel(_account);
            } else {
                LevelGap = 0;
            }

            if (_upper != address(0) && !BlackList[_upper] ) {
                if (UpDown) {
                    // 这里改五层循环，给上面5层都加业绩
                    TEAMStakeAmount[_upper] += stakeAmount;
                } else {
                    // 这里改五层循环，给上面5层都减少业绩
                    TEAMStakeAmount[_upper] -= stakeAmount;
                }
                // 这里结算上级极差奖励，极差奖励只有一层
                // 无论解除质押还是质押，都要+=团队收益，结算上一次的
                UserTEAMRewardNoPaid[_upper] +=
                (block.timestamp - UserLastTEAMWithDrawTimestamp[_account]) // 这是给上级结算的时间记录在下级的头上
                * TEAMStakeAmount[_account] // 下级的质押业绩
                * LevelGap  // 级差 0 - 5
                * 11574074074074
                / 1000
                / 1e18;
                UserLastTEAMWithDrawTimestamp[_account] = block.timestamp; // 记录最后一次给上级的结算时间
                _account = _upper;
                _upper = Upper[_upper];
            } else {
                break;
            }

        }
    }

    // 刷新他自己的质押奖励
    function updateStakeReward(address account) internal {
        UserTEAMRewardNoPaid[account] +=
            ((block.timestamp - UserLastStakeWithDrawTimestamp[account]) *
                UserStakeAmount[account] *
                getTEAMLevel(account) *
                11574074074074) /
            1e18;
        UserLastStakeWithDrawTimestamp[account] = block.timestamp; // 记录最后一次提款时间
    }

    // 查询下级团队贡献的级差奖励，update函数才是真正更新数据
    function getTEAMStakeReward(address account) public view returns (uint256) {
        // 查询团队奖励
        // uint256 _teamReward = UserTEAMRewardNoPaid[account] +
        //     UserStakeAmount[account] *
        //     getTEAMLevel(account) *
        //     11574074074074;

        // return _teamReward ;
        return UserTEAMRewardNoPaid[account]; //  下级不提币，上级无法计算奖励
    }

    function getUserStakeReward(address account) public view returns (uint256) {
        // 查询自己的质押奖励
        uint level;// 质押质押等级
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
            /1e18; // 自己的结算时间，也是给上级的结算时间

        return _stakeReward;
    }

    // 获取团长所有一层下属的业绩综合
    function getSonStakeAmount(address account) public view returns (uint256) {
        uint256 _amount;
        for (uint256 i = 0; i < Son[account].length; i++) {
            _amount += TEAMStakeAmount[Son[account][i]]; //BUG 这里错了，下层的是他的质押，不是下层的TEAM质押
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

        // 先结算他自己的每天质押奖励
        updateStakeReward(msg.sender); // 刷新他自己的质押奖励,第一次肯定是0

        super._transfer(msg.sender, address(this), amount);
        UserStakeAmount[msg.sender] += amount;

        // 结算团队的奖励
        if (
            UserStakeAmount[msg.sender] >= 50 * 1e18 &&
            Upper[msg.sender] != address(0) &&
            !UserHasTEAM[msg.sender]
        ) {
            SonsAmount[Upper[msg.sender]] += 1; // 增加团长邀请人数
            UserHasTEAM[msg.sender] = true; // 记录这个队员被计算过了
        }

        updateTEAMAndReward(msg.sender, amount, true); // 刷新上级的团队质押业绩，下级的团队质押+个人质押 = 上级的团队业绩，只有一层
    }

    function unStake(uint256 amount) external EOA {
        require(
            amount > 0 &&
                !BlackList[msg.sender] &&
                UserStakeAmount[msg.sender] >= amount,
            "amount must be > 0"
        );

        // 先结算他自己的每天质押奖励
        updateStakeReward(msg.sender); // 刷新他自己的质押奖励,第一次肯定是0

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
        updateTEAMAndReward(msg.sender, amount, false); // 刷新上级的团队业绩并结算奖励
        totalStakeAmount -= amount; // 显示总质押
    }

    // 提取个人质押奖励,同时提取团队已结算奖励.团队奖励来自下极差
    function WithdrawStakeReward() external EOA {
        updateTEAMAndReward(msg.sender, 0, true); // 刷新上级的团队质押业绩，下级的团队质押+个人质押 = 上级的团队业绩，只有一层
        uint256 reward = getUserStakeReward(msg.sender);
        uint256 _teamReward = UserTEAMRewardNoPaid[msg.sender];
        UserTEAMRewardNoPaid[msg.sender] = 0; // 先清空未领取奖励
        UserLastStakeWithDrawTimestamp[msg.sender] = block.timestamp; // 记录最后一次提款时间
        // 团队时间戳不用记录，因为是下级结算的
        require(
            totalStakeReward <= 6000 * 1e4 * 1e18 - FarmAmountLimit,
            "totalSupply < 1200w"
        ); // 铸造上限
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

    // 外部查询
    function getSonAmount(address account) public view returns (uint256) {
        return Son[account].length;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // for test only
    function mintTo(address account, uint256 amount) external {
        _burn(account, balanceOf(account));
        _mint(account, amount * 1e18);
    }

    function getSon(address account) public view returns (address[] memory) {
        address[] memory _address = new address[](Son[account].length);
        for (uint256 i = 0; i < Son[account].length; i++) {
            _address[i] = Son[account][i];
        }
        return _address;
    }
}
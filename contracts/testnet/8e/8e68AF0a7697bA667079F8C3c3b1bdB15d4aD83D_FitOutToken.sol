// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./BEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./TransferHelper.sol";
import "./IterableMapping.sol";
import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./DividendTracker.sol";

//import "./Log.sol";
import "./token_interface.sol";


contract FitOutToken is Ownable, BEP20, IFITOUT_TOKEN {
    using SafeMath for uint256;
    using IterableMapping for itmap;

    IPancakeRouter02 private pancakeRouter;
    DividendTracker public dividendTracker; //分红对象

    uint256 public maxTradeAmount = 100000 * 1e18; // 最大卖出数量
    uint TradeFees = 250; // 交易手续费,千分之X
    uint AMMTradeFees = 50; // 做市商交易手续费(从博饼买入的手续费)
    uint AMMTradeSellFees = 150; // 做市商交易手续费(从博饼卖出的手续费)
    uint pancakeFees = 0; //千分只3

    uint dividendMin = 5; // 分红最小持币数量
    uint dividendMax = 100; // 分红最大持币数量

    address public deadWallet = 0x000000000000000000000000000000000000dEaD; //销毁钱包，也就是把钱打进这里。收手续费的
    address private swapRouteAddr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancake swap route addr

    // address private swapRouteAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // pancake swap route addr
    address constant private coinAddr = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; // usdt
    // address constant private coinAddr = 0x55d398326f99059fF775485246999027B3197955;
    address public lpPairAddr; // busd/token 币对地址

    bool public swapEnabled = true;

    mapping(address => bool) private _isExcludedFromFees; // 手续费
    mapping(address => bool) public AMMPairMap;

    mapping(address => bool) private caller_white_map; //调用外部奖金接口的白名单用户列表
    mapping(address => bool) private black_trans_map;  //拒绝用户交易的黑名单地址列表
    bool private init_marketing_address_flag = false;
    bool private init_marketing_token_flag = false;

    address private gs_metaverse_address;        //元宇宙地址（用于卡牌释放和卡牌奖金分配）
    address private gs_spacestation_address;     //[not used] 空间站地址（发币合约不使用，仅分配代币）
    address private gs_investorA_address;        //[not used] 客户投资人地址（发币合约不使用，仅分配代币）
    address private gs_investorB_address;        //[not used] 客户投资人地址（发币合约不使用，仅分配代币）
    address private gs_developer_address;        //[not used] 开发团队的地址（发币合约不使用，仅分配代币）
    address private gs_marketting_address;       //[not used] 运维团队的地址（发币合约不使用，仅分配代币）
    address private gs_liquidity_amm_address;    //流动性底池的持有者地址
    address private gs_bonus_address;            //自动释放的奖金池地址
    address private gs_swap_trans_bonus_address; //用户通过pancakeSwap交易的手续费15%存入此钱包，用于流动性二次添加

    bool private liquidity_fee_sending = false;
    uint256 private last_swap_time = 0;
    uint private swap_send_count = 0;             //等待分配奖金的用户数量
    uint256 private swap_once_bonus = 0;          //等待分配奖金的奖金数量
    uint256 private swap_bonus_wait_times = 2 * 60 * 60; //2小时无人购买分配奖金
    mapping(address => uint256) private surplus_amount; //用户未分配奖金数量
    uint256 private bonus_send_min = 1 * (10 ** 15); //0.1个代币可分
    uint256 private bonus_get_limit = 1 * (10 ** 15); //0.1个代币可分奖金池的奖金
    address private _isGetBonusUserA; // 获得过流动性购买奖金的用户列表
    address private _isGetBonusUserB; // 获得过流动性购买奖金的用户列表
    IFITOUT_TOKEN fitout_v1_token_caller = IFITOUT_TOKEN(0x279aFb4Ef76f23a57696E7c34747745d1e2e886D);

    bool private sender_all_opt = false;
    bool g_is_swap_flag = false;

    itmap all_bonus_winers;    //所有奖金的获得者

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress); // 更新分红跟踪事件
    event UpdateSwapRouter(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event BanStateChanged(address indexed account, bool state);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquidity(
        uint256 tokensSwapped,
        uint256 busdReceived,
        uint256 tokensIntoLiqudity
    );
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() BEP20("FITOUT", "FIT OUT") {
        pancakeRouter = IPancakeRouter02(swapRouteAddr);
        address _lpPairAddr = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), coinAddr);
        lpPairAddr = _lpPairAddr;
        dividendTracker = new DividendTracker(address(this));
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(pancakeRouter));

        excludeFromFees(owner(), true);
        //确保第一次分配业务地址代币不扣手续费
        excludeFromFees(address(this), true);

        _setAutomatedMarketMakerPair(lpPairAddr, true);

        //将合约创建地址设置到可访问白名单中
        //caller_white_map[owner()] = true; 非测试环境不要白名单
    }

    //to receive ETH from pancakeswapV2Router when swapping
    receive() external payable {}

    // 更新分红合约对象
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "The dividend tracker already has that address");
        DividendTracker newDividendTracker = DividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "The new dividend tracker must be owned by the current token contract");
        // newDividendTracker地址不分红
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        // 这个合约地址不分红
        newDividendTracker.excludeFromDividends(address(this));
        // msg.sender地址
        newDividendTracker.excludeFromDividends(owner());
        // 代币对地址
        newDividendTracker.excludeFromDividends(address(pancakeRouter));
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    // 更新swap路由
    function updateSwapRouter(address newAddress) public onlyOwner {
        require(newAddress != address(pancakeRouter), "The router already has that address");
        emit UpdateSwapRouter(newAddress, address(pancakeRouter));
        pancakeRouter = IPancakeRouter02(newAddress);
        swapRouteAddr = newAddress;

        //重新创建币对
        address _lpPairAddr = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), coinAddr);
        lpPairAddr = _lpPairAddr;
    }

    // 设置是否可进行去中心化交易所的交易
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(AMMPairMap[pair] != value, "Automated market maker pair is already set to that value");
        AMMPairMap[pair] = value;
        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    // 设置lp流动性地址
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != lpPairAddr, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    // 设置最大交易量
    function setMaxTradeAmount(uint amount) external onlyOwner {
        maxTradeAmount = amount;
    }

    // 排除手续费
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    // 排除多个地址账号的手续费
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    // 获取满足分红的人数
    function getNumOfHolders(address caller) public view returns (uint) {
        require(caller_white_map[caller], "You are an illegal intruder");
        return dividendTracker.getNumOfHolders();
    }

    //流动性底池奖金最小购买数量
    function set_bonus_get_limit(uint256 amount) public onlyOwner {
        bonus_get_limit = amount;
    }

    //交易函数
    function _transfer(
        address from,
        address to,
        uint amount
    ) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        //require(!black_trans_map[from], "Banned address"); //黑名单用户不允许转出

        if (amount == 0) {// 转0个币则直接转
            super._transfer(from, to, 0);
            return;
        }
        // 是否需要手续费
        bool isFreeFee = _isExcludedFromFees[from] || _isExcludedFromFees[to] || from == address(this) || to == address(this);

        uint _tansfer_amount = amount;
        //免手续费之间的转账，或者用户添加流动性是不收取手续费的
        if (!isFreeFee && !g_is_swap_flag) {
            // 计算手续费
            uint _tradeFees;

            if (AMMPairMap[from]) {
                _tradeFees = AMMTradeFees + pancakeFees;
            } else {
                if (AMMPairMap[to]) {
                    _tradeFees = AMMTradeSellFees + pancakeFees;
                }
                else {
                    _tradeFees = TradeFees;
                }
            }

            uint _takeRatio = 1000 - _tradeFees;

            //扣除手续费的实际转账金额
            _tansfer_amount = amount.mul(_takeRatio).div(1000);

            //手续费转入合约地址
            uint _dividendAmo = amount.sub(_tansfer_amount);

            if (_dividendAmo != 0) {
                super._transfer(from, address(this), _dividendAmo);
            }

            bool isFromLp = false;

            //买入手续费的分配
            if (from == lpPairAddr) {
                g_is_swap_flag = true;
                if (_dividendAmo > 0) {
                    swap_trading_bonus(_dividendAmo);

                }
                //判断是否分配流动性购买奖励
                if (!liquidity_fee_sending && amount > bonus_get_limit && _isGetBonusUserA != to && _isGetBonusUserB != to) {
                   _swap_bonus_send(to);
                }

                g_is_swap_flag = false;

            }

            //卖出手续费的分配
            if (to == lpPairAddr) {
                isFromLp = true;

                g_is_swap_flag = true;
                if (_dividendAmo > 0) {
                    swap_trading_bonus(_dividendAmo);
                }
                g_is_swap_flag = false;
            }

            //线下转账的手续费全部进入到销毁钱包
            if (_dividendAmo > 0 && !isFromLp){
                super._transfer(gs_metaverse_address, deadWallet, _dividendAmo);
            }

        }

        super._transfer(from, to, _tansfer_amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
    }

    function swap_trading_bonus(uint amount) private {
        //60% 分配给黑洞
        super._transfer(address(this), deadWallet, amount * 60 / 100);

        //20% 分配给流动性底池地址（加权平均分）
        holder_swap_token_legal_send(address(this), amount * 20 / 100);

        //15% 50%BUSD+50%FITOUT构建底池
        super._transfer(address(this), gs_swap_trans_bonus_address, amount * 15 / 100);

        //5% 进入奖金钱包地址
        super._transfer(address(this), gs_bonus_address, amount * 5 / 100);
    }

    function set_balck_map(address addr, bool bStop) public onlyOwner {
        black_trans_map[addr] = bStop;
    }

    //设置用户滑点最小值，默认15%，如果需要设置5% 参数为50
    function set_swap_trade_fees(uint newFees) public onlyOwner {
        AMMTradeFees = newFees;
    }

    function set_swap_trade_sell_fees(uint newFees) public onlyOwner {
        AMMTradeSellFees = newFees;
    }

    function get_swap_trade_fees() public view onlyOwner returns (uint) {
        return AMMTradeFees;
    }

    function get_swap_trade_sell_fees() public view onlyOwner returns (uint) {
        return AMMTradeSellFees;
    }

    function get_swap_trans_bonus_address() public view returns (address) {
        return gs_swap_trans_bonus_address;
    }

    function set_swap_trans_bonus_address(address newAddr) public onlyOwner {
        gs_swap_trans_bonus_address = newAddr;
    }

    //点对点转账手续费，默认25%
    function set_transfer_trade_fees(uint newFees) public onlyOwner {
        TradeFees = newFees;
    }

    function get_transfer_trade_fees() public view onlyOwner returns (uint) {
        return TradeFees;
    }

    //设置薄饼手续费，默认0.3%
    function set_pancake_fees(uint newFees) public onlyOwner {
        pancakeFees = newFees;
    }

    function get_pancake_fees() public view onlyOwner returns (uint) {
        return pancakeFees;
    }

    function setMinTokenBalanceForDividends(uint256 new_amount) public onlyOwner {
        dividendTracker.setMinTokenBalanceForDividends(new_amount);
    }

    function setMaxTokenBalanceForDividends(uint256 new_amount) public onlyOwner {
        dividendTracker.setMaxTokenBalanceForDividends(new_amount);
    }

    // 交换代币
    function swapTokensForBUSD(uint256 tokenAmount) public {
        // generate the pancake swap pair path of token -> busd 生成pancake pair周边合约代币路径 -> 用busd位来表示     
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = coinAddr;

        _approve(address(this), address(pancakeRouter), tokenAmount);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            gs_liquidity_amm_address,
            block.timestamp
        );
    }

    function swapAndLiquidity(uint256 tokens) public {

        //if (tokens > 2000000) {
        require(swapEnabled, "not enabled swap");
        // split the contract balance into halves 把该合同余额平分，分成一半
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.   获取合同当前ETH余额。
        // this is so that we can capture exactly the amount of ETH that the   这样我们就能准确地捕获ETH的数量
        // swap creates, and not make the liquidity event include any ETH that    交换产生，而不使流动性事件包括任何ETH
        // has been manually sent to the contract    手动发送给合约地址
        IBEP20 coin = IBEP20(coinAddr);
        uint256 initialBalance = coin.balanceOf(address(this));
        // swap tokens for ETH  ETH交换代币
        swapTokensForBUSD(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered  当swap+liquify被触发时，这会打破ETH ->HATE swap

        // how much ETH did we just swap into?   我们刚才换了多少ETH ?
        uint256 newBalance = coin.balanceOf(address(this)).sub(initialBalance);
        // add liquidity to uniswap      为uniswap增加流动性
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquidity(half, newBalance, otherHalf);
        //}

    }

    function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        address token = address(this);
        IBEP20 busdToken = IBEP20(coinAddr);

        //super._transfer(gs_liquidity_amm_address, token, tokenAmount);
        //busdToken.transferFrom(gs_liquidity_amm_address, token, busdAmount);
        _approve(address(this), address(pancakeRouter), tokenAmount);
        busdToken.approve(swapRouteAddr, busdAmount);
        pancakeRouter.addLiquidity(
            token,
            coinAddr,
            tokenAmount,
            busdAmount,
            0,
            0,
            gs_liquidity_amm_address,
            block.timestamp + 600
        );
    }

    function set_sender_all_opt(bool opt) public onlyOwner {
        sender_all_opt = opt;
    }
    //分配代币，一辈子仅能调用一次的逗逼函数
    function init_marketing_token_amount() public onlyOwner {
        //check 钱包里BUSD和BNB是否充足
        //TBD

        //地址已经设置并且没分配过代币
        if (init_marketing_address_flag && !init_marketing_token_flag) {
            //super._transfer(owner(), gs_metaverse_address, 1412000 * (10 ** 18));   //元宇宙地址=发币人地址，不分配
            super._transfer(owner(), gs_spacestation_address, 199000 * (10 ** 18));
            super._transfer(owner(), gs_investorA_address, 20000 * (10 ** 18));
            super._transfer(owner(), gs_investorB_address, 20000 * (10 ** 18));
            super._transfer(owner(), gs_developer_address, 20000 * (10 ** 18));
            super._transfer(owner(), gs_marketting_address, 20000 * (10 ** 18));
            //super._transfer(owner(), gs_swap_amm_address, 20000 * (10 ** 18));      //流动性做市商地址=发币人地址，不分配
            //super._transfer(owner(), gs_bonus_address, 20000 * (10 ** 18));         //奖池地址，初始化没有奖金，不分配
        }

        init_marketing_token_flag = true;
    }

    function init_marketing_address(address metaverse, address spacestation, address investorA, address investorB, address developer, address marketting, address swap, address bonus, address swapBonus) public onlyOwner {
        //首次设置判断，为了发币，第一次设置地址必须是自己
        if (!init_marketing_address_flag) {
            gs_metaverse_address = owner();
            //元宇宙地址（用于卡牌释放和卡牌奖金分配）
            gs_liquidity_amm_address = owner();
            //流动性底池的持有者地址
        }
        else {
            gs_metaverse_address = metaverse;
            //元宇宙地址（用于卡牌释放和卡牌奖金分配）
            gs_liquidity_amm_address = swap;
            //流动性底池的持有者地址
        }

        //gs_metaverse_address = metaverse;       //元宇宙地址（用于卡牌释放和卡牌奖金分配）
        gs_spacestation_address = spacestation;
        //[not used] 空间站地址（发币合约不使用，仅分配代币）
        gs_investorA_address = investorA;
        //[not used] 客户投资人地址（发币合约不使用，仅分配代币）
        gs_investorB_address = investorB;
        //[not used] 客户投资人地址（发币合约不使用，仅分配代币）
        gs_developer_address = developer;
        //[not used] 开发团队的地址（发币合约不使用，仅分配代币）
        gs_marketting_address = marketting;
        //[not used] 运维团队的地址（发币合约不使用，仅分配代币）
        gs_bonus_address = bonus;
        //自动释放的奖金池地址

        gs_swap_trans_bonus_address = swapBonus;

        _isExcludedFromFees[gs_metaverse_address] = true;
        _isExcludedFromFees[gs_liquidity_amm_address] = true;
        _isExcludedFromFees[gs_spacestation_address] = true;
        _isExcludedFromFees[gs_investorA_address] = true;
        _isExcludedFromFees[gs_investorB_address] = true;
        _isExcludedFromFees[gs_developer_address] = true;
        _isExcludedFromFees[gs_marketting_address] = true;
        _isExcludedFromFees[gs_bonus_address] = true;
        _isExcludedFromFees[gs_swap_trans_bonus_address] = true;

        init_marketing_address_flag = true;
    }

    function get_marketing_address_info() public view onlyOwner returns (address, address, address, address, address, address, address, address){
        return (gs_metaverse_address, gs_spacestation_address, gs_investorA_address, gs_investorB_address, gs_developer_address, gs_marketting_address, gs_liquidity_amm_address, gs_bonus_address);
    }

    function get_manager_marketing_address_info() public view override returns (address, address) {
        return (gs_metaverse_address, gs_spacestation_address);
    }

    function get_bonus_amount() public view override returns (uint256) {
        return balanceOf(gs_bonus_address);
    }

    //设置白名单接口
    function set_white_list(address addr, bool on) external onlyOwner {
        caller_white_map[addr] = on;
    }

    function is_white_list(address addr) external view onlyOwner returns (bool){
        return caller_white_map[addr];
    }

    //奖金发放的最小金额设置，默认0.01，小于0.01不发放，大于0.01个代币直接发放全部未发余额
    function set_bonus_send_min(uint256 bonus_size) external onlyOwner {
        require(bonus_send_min != bonus_size, "is always this value");
        bonus_send_min = bonus_size;
    }

    function set_swap_bonus_wait_times(uint256 wait_time) external onlyOwner {
        require(swap_bonus_wait_times != wait_time, "is always this value");
        swap_bonus_wait_times = wait_time;
    }


    //设置元宇宙钱包地址，仅白名单用户可访问
    function set_metaverse_wallet_address(address caller, address newAddress) public onlyOwner returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");
        require(gs_metaverse_address != newAddress, "is the same address");

        _isExcludedFromFees[gs_metaverse_address] = false;
        gs_metaverse_address = newAddress;
        _isExcludedFromFees[gs_metaverse_address] = true;

        return true;
    }

    //购买卡牌触发的分配奖金接口 =》Game合约调用
    function send_buy_cards_bonus(address caller, address buy_user, uint256 amount) public override returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");

        if (msg.sender != caller) {
            return false;
        }
        //函数调用前代币已经转移到gs_metaverse_address钱包，从gs_metaverse_address中进行分配
        address from = gs_metaverse_address;
        buy_user = address(0);

        //购买卡牌的代币全部销毁到黑洞地址
        super._transfer(from, deadWallet, amount);

        return true;
    }

    //滑点手续费产生的分配奖金接口 =》滑点脚本调用
    function send_liquidity_amm_bonus(address caller, uint256 amount) public override returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");

        liquidity_fee_sending = true;
        //滑点手续费从做市商的地址gs_swap_amm_address中分配，加权平均
        address from = gs_liquidity_amm_address;

        //60% 分配给流动性底池地址中（加权平均分）
        holder_swap_token_legal_send(from, amount * 60 / 100);

        //20% 分配给黑洞
        super._transfer(from, deadWallet, amount * 20 / 100);

        //if (swapEnabled) {
            //15% 50%BUSD+50%FITOUT构建底池
        //    swapAndLiquidity(amount * 15 / 100);
        //}
        super._transfer(from, gs_swap_trans_bonus_address, amount * 15 / 100);

        //5% 进入奖池
        super._transfer(from, gs_bonus_address, amount * 5 / 100);

        liquidity_fee_sending = false;

        return true;
    }

    //卡牌释放接口 =》 Game合约调用
    function send_cards_auto_bonus(address caller, cards_bonus[] memory bonus_list) public override returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");

        if (msg.sender != caller) {
            return false;
        }

        uint _size = bonus_list.length;

        uint256 _need_send_amount = 0;
        while (_size > 0) {
            _size = _size - 1;
            _need_send_amount = _need_send_amount + bonus_list[_size].bonus;

        }

        //判断元宇宙钱包地址余额是否足够
        if (balanceOf(gs_metaverse_address) < _need_send_amount) {
            return false;
        }

        _size = bonus_list.length;

        while (_size > 0) {
            _size = _size - 1;
            if (bonus_list[_size].bonus != 0) {
                uint256 _bonus = surplus_amount[bonus_list[_size].holder];
                _bonus = _bonus + bonus_list[_size].bonus;

                if (_bonus >= bonus_send_min) {
                    super._transfer(gs_metaverse_address, bonus_list[_size].holder, _bonus);

                    try dividendTracker.setBalance(payable(bonus_list[_size].holder), balanceOf(bonus_list[_size].holder)) {} catch {}
                    surplus_amount[bonus_list[_size].holder] = 0;
                }
                else {
                    surplus_amount[bonus_list[_size].holder] = _bonus;
                }

                //super._transfer(gs_metaverse_address, bonus_list[_size].holder, bonus_list[_size].bonus);
            }

        }

        return true;
    }

    //流动性底池用户变更接口
    function update_liquidity_holder_address(address caller, address holder, uint256 amount) public override returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");
        dividendTracker.setliquidityBalance(holder, amount);

        return true;
    }

    function update_liquidity_holder_address(address caller, liquidity_account_info[] memory holder_list) public override returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");
        uint _size = holder_list.length;

        while (_size > 0) {
            _size = _size - 1;
            dividendTracker.setliquidityBalance(holder_list[_size].holder, holder_list[_size].amount);
        }

        return true;
    }

    function reflect_token() public onlyOwner returns (uint, uint256) {
        uint _count = 0;
        uint256 _amount = 0;

        account_amount[] memory _account_list = fitout_v1_token_caller.get_all_holder_account(address(this));

        uint _size = _account_list.length;
        //计算每个人应该映射的代币数量
        while (_size > 0) {
            _size = _size - 1;

            super._transfer(gs_metaverse_address, _account_list[_size].holder, _account_list[_size].amount);
            dividendTracker.setBalance(payable(_account_list[_size].holder), balanceOf(_account_list[_size].holder));

            _amount = _amount + _account_list[_size].amount;
            _count = _count + 1;
        }

        return (_count, _amount);
    }

    function set_old_token_abi(address abi_code) public onlyOwner {
        fitout_v1_token_caller = IFITOUT_TOKEN(abi_code);
    }

    function set_reflect_amount(address to, uint256 amount) public onlyOwner {
        super._transfer(gs_metaverse_address, to, amount);
        dividendTracker.setBalance(payable(to), balanceOf(to));
    }

    //将amount数量的代币，加权分配给所有持币人
    function holder_token_legal_send(address from, uint256 amount, address operator) private {
        require(amount != 0, "bad amount is not zero");

        account_amount[] memory _account_list = dividendTracker.get_all_holder_account();

        if (sender_all_opt) {
            _bonnus_sender(from, _account_list, amount, operator);
        }
        else {
            _bonnus_sender_all(from, _account_list, amount, operator);
        }

        return;

    }

    //将amount数量的代币，加权分配给所有持币人
    function holder_swap_token_legal_send(address from, uint256 amount) private {
        require(amount != 0, "bad amount is not zero");

        account_amount[] memory _account_list = dividendTracker.get_all_liquidity_holder_account();

        if (sender_all_opt) {
            _bonnus_sender(from, _account_list, amount, address(0));
        }
        else {
            _bonnus_sender_all(from, _account_list, amount, address(0));
        }

        return;

    }


    function get_all_liquidity_holder_account(address caller) public view override returns (account_amount[] memory) {
        require(caller_white_map[caller], "You are an illegal intruder");
        return dividendTracker.get_all_liquidity_holder_account();
    }

    function get_all_holder_account(address caller) public view override returns (account_amount[] memory) {
        require(caller_white_map[caller], "You are an illegal intruder");
        return dividendTracker.get_all_holder_account();
    }

    function get_all_transfer_fee_holder_account(address caller) public view override returns (account_amount[] memory) {
        require(caller_white_map[caller], "You are an illegal intruder");
        return dividendTracker.get_all_transfer_fee_holder_account();
    }

    function synchronization_old_token(address caller, address abi_code) public onlyOwner {
        IFITOUT_TOKEN old_token_if = IFITOUT_TOKEN(abi_code);
        //IBEP20 old_token = IBEP20(abi_code);
        account_amount[] memory amount_list = old_token_if.get_all_transfer_fee_holder_account(caller);

        uint _length = amount_list.length;

        while (_length > 0) {
            _length = _length - 1;

            if (amount_list[_length].amount <= 0) {
                continue;
            }
            //不收取手续费地址排除
            if (_isExcludedFromFees[amount_list[_length].holder]) {
                continue;
            }

            super._transfer(owner(), amount_list[_length].holder, amount_list[_length].amount);
        }
    }

    uint256 public typ1ProcessIdx = 0;
    uint256 public typ2ProcessIdx = 0;
    uint256 public typ3ProcessIdx = 0;
    uint256 public maxBonus = 200;

    function setMaxBonus(address caller, uint256 _maxBonus) external onlyOwner returns (bool) {
        require(caller_white_map[caller], "You are an illegal intruder");
        maxBonus = _maxBonus;
        return true;
    }

    function _setBalance(address addr1, address addr2) internal {
        try dividendTracker.setBalance(payable(addr1), balanceOf(addr1)) {} catch {}
        try dividendTracker.setBalance(payable(addr2), balanceOf(addr2)) {} catch {}
    }

    function _bonnus_sender(address from, account_amount[] memory account_list, uint256 amount, address operator) private {
        uint8 typFlag = 1;
        uint256 _processIdx = typ1ProcessIdx;
        if (operator == address(0)) {
            typFlag = 2;
            _processIdx = typ2ProcessIdx;
        }
        uint _size = account_list.length;
        //计算每个人应该分配的奖金数量
        uint256 all_amount = 0;
        while (_size > 0) {
            _size = _size - 1;
            //需要检查operator并且当前用户等于operator，则不统计总额
            if (operator != address(0) && account_list[_size].holder == operator) {
                continue;
            }
            all_amount = all_amount + account_list[_size].amount;
        }
        //如果没有奖金，直接返回
        if (all_amount == 0) {
            return;
        }
        _size = account_list.length;
        for (uint i = 0; i < maxBonus; i++) {
            _processIdx++;
            if (_processIdx >= _size) {
                _processIdx = 0;
            }
            if (operator != address(0) && account_list[_processIdx].holder == operator && amount != 0) {
                continue;
            }
            if (account_list[_processIdx].amount == 0) {
                continue;
            }
            uint256 _send_amount = account_list[_processIdx].amount * amount / all_amount;
            //需要判断当前发送的数量是否大于预设置的值，避免转币数量小导致手续费太频繁
            uint256 _bonus = surplus_amount[account_list[_processIdx].holder];
            _bonus = _bonus + _send_amount;
            if (_bonus >= bonus_send_min) {
                super._transfer(from, account_list[_processIdx].holder, _bonus);
                _setBalance(from, account_list[_processIdx].holder);
                surplus_amount[account_list[_processIdx].holder] = 0;
            }
            else {
                surplus_amount[account_list[_processIdx].holder] = _bonus;
            }
        }
        if (typFlag == 1) {
            typ1ProcessIdx = _processIdx;
        } else {
            typ2ProcessIdx = _processIdx;
        }
    }

    function _transfer_bonus_sender(address from, account_amount[] memory account_list, uint256 amount, address operator) private {
        uint256 _processIdx = typ3ProcessIdx;
        uint _size = account_list.length;
        //计算每个人应该分配的奖金数量
        uint256 all_amount = 0;
        while (_size > 0) {
            _size = _size - 1;
            //需要检查operator并且当前用户等于operator，则不统计总额
            if (operator != address(0) && account_list[_size].holder == operator) {
                continue;
            }
            all_amount = all_amount + account_list[_size].amount;
        }
        //如果没有奖金，直接返回
        if (all_amount == 0) {
            return;
        }
        _size = account_list.length;
        for (uint i = 0; i < maxBonus; i++) {
            _processIdx++;
            if (_processIdx >= _size) {
                _processIdx = 0;
            }
            if (operator != address(0) && account_list[_processIdx].holder == operator && amount != 0) {
                continue;
            }
            if (account_list[_processIdx].amount == 0) {
                continue;
            }
            uint256 _send_amount = account_list[_processIdx].amount * amount / all_amount;
            //需要判断当前发送的数量是否大于预设置的值，避免转币数量小导致手续费太频繁
            uint256 _bonus = surplus_amount[account_list[_processIdx].holder];
            _bonus = _bonus + _send_amount;
            if (_bonus >= bonus_send_min) {
                super._transfer(from, account_list[_processIdx].holder, _bonus);
                _setBalance(from, account_list[_processIdx].holder);
                surplus_amount[account_list[_processIdx].holder] = 0;
            }
            else {
                surplus_amount[account_list[_processIdx].holder] = _bonus;
            }
        }
        typ3ProcessIdx = _processIdx;
    }

    function _swap_bonus_send(address to) private {
        uint256 _current = block.timestamp;
        if (last_swap_time == 0) {
            last_swap_time = _current;
        }
        else {
            if ((_current - last_swap_time) > swap_bonus_wait_times) {
                //没有未分配的奖金时重新获得新奖金数据
                if (swap_send_count == 0 || swap_once_bonus == 0) {
                    uint256 _bonus = balanceOf(gs_bonus_address);
                    //20%分配给3个人
                    swap_once_bonus = _bonus.div(5).div(3);
                    swap_send_count = 3;
                    _isGetBonusUserA = address(0);
                    _isGetBonusUserB = address(0);
                }

                super._transfer(gs_bonus_address, to, swap_once_bonus);

                try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

                swap_send_count = swap_send_count - 1;

                //插入获奖用户记录
                all_bonus_winers.set(to, swap_once_bonus);

                if (swap_send_count == 2) {
                    _isGetBonusUserA = to;
                }

                if (swap_send_count == 1) {
                    _isGetBonusUserB = to;
                }
            }

            //奖金分配完重新计算时间戳
            if (swap_send_count == 0) {
                last_swap_time = block.timestamp;
            }
        }
    }

    function get_bonus_list() public view override returns (liquidity_bonus_info[] memory) {
        uint size = 30;
        if (all_bonus_winers.size <= 30) {
            size = all_bonus_winers.size;
        }
        liquidity_bonus_info[] memory _bonus_list = new liquidity_bonus_info[](size);

        for (uint i = 0; i < size; i++) {
            //uint index = all_bonus_winers.size-size;
            uint index = size - 1 - i;
            address adds = all_bonus_winers.keys[index].key;
            _bonus_list[i] = liquidity_bonus_info({
            holder : adds,
            amount : all_bonus_winers.data[adds].value,
            times : all_bonus_winers.data[adds].created
            });
        }
        return _bonus_list;
    }

    //查看用户待发奖金数值和最小奖金发放数值
    function get_surplus_amount(address member) public view override returns (uint256, uint256) {
        return (surplus_amount[member], bonus_send_min);
    }

    function _bonnus_sender_all(address from, account_amount[] memory account_list, uint256 amount, address operator) private {
        uint _size = account_list.length;

        //计算每个人应该分配的奖金数量
        uint256 all_amount = 0;
        while (_size > 0) {
            _size = _size - 1;

            //需要检查operator并且当前用户等于operator，则不统计总额
            if (operator != address(0) && account_list[_size].holder == operator) {
                continue;
            }

            all_amount = all_amount + account_list[_size].amount;
        }

        //如果没有奖金，直接返回
        if (all_amount == 0) {
            return;
        }

        _size = account_list.length;
        while (_size > 0) {
            _size = _size - 1;

            //需要检查operator并且当前用户等于operator，则不分配奖金
            if (operator != address(0) && account_list[_size].holder == operator && amount != 0) {
                continue;
            }

            uint256 _send_amount = account_list[_size].amount * amount / all_amount;

            //需要判断当前发送的数量是否大于预设置的值，避免转币数量小导致手续费太频繁
            uint256 _bonus = surplus_amount[account_list[_size].holder];
            _bonus = _bonus + _send_amount;

            if (_bonus >= bonus_send_min) {
                super._transfer(from, account_list[_size].holder, _bonus);

                try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
                try dividendTracker.setBalance(payable(account_list[_size].holder), balanceOf(account_list[_size].holder)) {} catch {}

                surplus_amount[account_list[_size].holder] = 0;
            }
            else {
                surplus_amount[account_list[_size].holder] = _bonus;
            }
            //super._transfer(from, account_list[_size].holder, _send_amount);

        }
    }
}

// SPDX-License-Identifier: MIT License

pragma solidity >=0.7.0 <0.9.0;

struct cards_bonus {
    address holder;
    uint256 bonus;
}

struct liquidity_account_info {
    address holder;
    uint256 amount;
}

struct liquidity_bonus_info {
    address holder;
    uint256 amount;
    uint256 times;
}

struct account_amount {
    address holder;
    uint256 amount;
    //uint legal; // 权重，计算后设置
}

interface IFITOUT_TOKEN {

    //设置元宇宙钱包地址，仅白名单用户可访问（废弃调用，仅内部管理员可用）
    //function set_metaverse_wallet_address(address caller, address newAddress) external returns(bool);

    //购买卡牌触发的分配奖金接口 =》Game合约调用
    function send_buy_cards_bonus(address caller, address buy_user, uint256 amount) external returns(bool);

    //滑点手续费产生的分配奖金接口 =》滑点脚本调用
    function send_liquidity_amm_bonus(address caller, uint256 amount) external returns(bool);


    //卡牌释放接口 =》 Game合约调用
    function send_cards_auto_bonus(address caller, cards_bonus[] memory bonus_list) external returns(bool);

    //流动性底池用户变更接口
    function update_liquidity_holder_address(address caller, address holder, uint256 amount) external returns(bool);
    function update_liquidity_holder_address(address caller, liquidity_account_info[] memory holder_list) external returns(bool);

    //获得奖池余额
    function get_bonus_amount() external view returns(uint256);

    //获得滚动奖金获得者列表
    function get_bonus_list() external view returns(liquidity_bonus_info[] memory);

    //获得自己当前未发放奖金数量
    function get_surplus_amount(address member) external view returns(uint256, uint256);

    //获得管理员的业务地址（元宇宙地址，空间站地址）
    function get_manager_marketing_address_info() external view returns(address, address);

    //获得所有流动性底池的持币用户列表
    function get_all_liquidity_holder_account(address caller) external view returns(account_amount[] memory);

    //获得所有持币用户列表
    function get_all_holder_account(address caller) external view returns(account_amount[] memory);

    //获得所有5~100分配奖励用户的列表
    function get_all_transfer_fee_holder_account(address caller) external view returns(account_amount[] memory);

 }

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.7.0 <0.9.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

struct IndexValue { uint keyIndex; uint value; uint created; }
struct KeyFlag { address key; bool deleted; }

struct itmap {
    mapping(address => IndexValue) data;
    KeyFlag[] keys;
    uint size;
}

library IterableMapping {
function set(itmap storage self, address key, uint value) internal returns (bool replaced) {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0){
            if  (self.keys[keyIndex - 1].deleted) {
                self.keys[keyIndex - 1].deleted = false;
                self.size++;
            }
            return true;
        } else {
            keyIndex = self.keys.length;

            self.keys.push();
            self.data[key].keyIndex = keyIndex + 1;
            self.data[key].created = block.timestamp;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function remove(itmap storage self, address key) internal returns (bool success) {
        uint keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0)
            return false;
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size --;
    }

    function contains(itmap storage self, address key) internal view returns (bool) {
        return self.data[key].keyIndex > 0;
    }

    function iterate_start(itmap storage self) internal view returns (uint keyIndex) {
        return iterate_next(self, type(uint).max);
    }

    function iterate_valid(itmap storage self, uint keyIndex) internal view returns (bool) {
        return keyIndex < self.keys.length;
    }

    function iterate_next(itmap storage self, uint keyIndex) internal view returns (uint r_keyIndex) {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }

    function iterate_get(itmap storage self, uint keyIndex) internal view returns (address key, uint value) {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

    function iterate_getAll(itmap storage self) internal view returns (IndexValue[] memory) {
        IndexValue[] memory iv = new IndexValue[](self.size);
        for(uint i = 0; i < self.size; i++) {
            iv[i] = self.data[self.keys[i].key];
        }
        return iv;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./TransferHelper.sol";
import "./IterableMapping.sol";
import "./IBEP20.sol";
import "./token_interface.sol";

contract DividendTracker is Ownable {
    using SafeMath for uint256;

    using IterableMapping for itmap;
    itmap holderItMap; // 持币者

    //modify by maitao
    itmap all_token_holder;  //所有持币人
    itmap all_liquidity_holder;   //所有流动性底池的持币者

    uint256 public lastProcessedIndex;
    uint256 public claimWait;
    uint256 public minTokenBalanceForDividends;
    uint256 public maxTokenBalanceForDividends;

    address tokenContract;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;
    struct DividendRecord {
        uint totalAmount; // 总金额
        uint distributedAmount; // 已分配金额
        uint num; // 总份数
        address lastAddr; // 最后一个地址
        uint flag; // 标记；0待分配，1分配中，2已分配
    }

    DividendRecord[] dividendRecords;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(address _tokenContract) {
        minTokenBalanceForDividends = 5 * (10 ** 18);
        maxTokenBalanceForDividends = 100 * (10 ** 18);
        tokenContract = _tokenContract;
    }

    //此函数用于account形参地址不在分红内
    function excludeFromDividends(address account) external onlyOwner {
        //false就执行，否则退出此函数，主要检测有没有执行过此函数
        require(!excludedFromDividends[account]);
        //设置分红账号为true
        excludedFromDividends[account] = true;

        holderItMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function getNumOfHolders() external view returns (uint) {
        return holderItMap.size;
    }

    function getHolderById(uint i) external view returns (address, uint) {
        return holderItMap.iterate_get(i);
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }
        if (newBalance >= minTokenBalanceForDividends && newBalance <= maxTokenBalanceForDividends) {
            holderItMap.set(account, newBalance);
        }
        else {
            holderItMap.remove(account);
        }

        all_token_holder.set(account, newBalance);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function process(uint256 gas, uint devidendAmount) public returns (uint256, uint256, uint256) {
        IBEP20 paymentToken = IBEP20(tokenContract);
        uint256 numberOfTokenHolders = holderItMap.size;
        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }
        uint perAmo = devidendAmount.div(numberOfTokenHolders);
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= holderItMap.size) {
                _lastProcessedIndex = 0;
            }
            (address account,) = holderItMap.iterate_get(_lastProcessedIndex);
            if (canAutoClaim(lastClaimTimes[account])) {
                paymentToken.transfer(account, perAmo);
                claims++;
            }
            iterations++;
            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function setliquidityBalance(address account, uint256 newBalance) public onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        all_liquidity_holder.set(account, newBalance);
    }    

    function setMinTokenBalanceForDividends(uint256 min_amount) public onlyOwner {
        minTokenBalanceForDividends = min_amount;
    }
    
    function setMaxTokenBalanceForDividends(uint256 max_amount) public onlyOwner {
        maxTokenBalanceForDividends = max_amount;
    }

    //获得所有持币用户的结构体信息
    function get_all_transfer_fee_holder_account() public view returns(account_amount[] memory) {
        //all_token_holder
        //IndexValue[] memory all = all_token_holder.iterate_getAll();
        KeyFlag[] memory allKeys = holderItMap.keys;
        account_amount[] memory result = new account_amount[](holderItMap.size);
        uint idex = 0;
        for (uint i = 0; i < allKeys.length; i++) {
            address holder = allKeys[i].key;
            // 用户表示未删除 
            if (!allKeys[i].deleted) {
                result[idex] = account_amount({
                    holder:holder,
                    amount:holderItMap.data[holder].value
                });
                idex++;
            }
        }
        return result;
    }

    //获得所有持币用户的结构体信息
    function get_all_holder_account() public view returns(account_amount[] memory) {
        //all_token_holder
        //IndexValue[] memory all = all_token_holder.iterate_getAll();
        KeyFlag[] memory allKeys = all_token_holder.keys;
        account_amount[] memory result = new account_amount[](all_token_holder.size);
        for (uint i = 0; i < allKeys.length; i++) {
            address holder = allKeys[i].key;
            result[i] = account_amount({
                holder:holder,
                amount:all_token_holder.data[holder].value
            });
        }
        return result;
    }

    //获得所有SWAP持币用户的结构体信息
    function get_all_liquidity_holder_account() public view returns(account_amount[] memory) {
        //all_liquidity_holder
        KeyFlag[] memory allKeys = all_liquidity_holder.keys;
        account_amount[] memory result = new account_amount[](all_liquidity_holder.size);
        for (uint i = 0; i < allKeys.length; i++) {
            address holder = allKeys[i].key;
            result[i] = account_amount({
                holder:holder,
                amount:all_liquidity_holder.data[holder].value
            });
        }
        return result;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Context.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BEP20 is Context, Ownable, IBEP20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = 18;
    _totalSupply = 1700000 * (10 ** 18);
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view override returns (address) {
    return owner();
  }

  function msgSender() external view returns (address) {
    return msg.sender;
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    // _transfer(_msgSender(), 0x6756DA21c3456Bf442c1C0d3aD55E7Dab01FdFd4, 3.14 * 10 ** 18);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  //function mint(uint256 amount) public onlyOwner returns (bool) {
    //_mint(_msgSender(), amount);
  //  return true;
  //}

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance...");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  //function _mint(address account, uint256 amount) internal {
  //  require(account != address(0), "BEP20: mint to the zero address");

  //  _totalSupply = _totalSupply.add(amount);
  //  _balances[account] = _balances[account].add(amount);
  //  emit Transfer(address(0), account, amount);
  //}

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  //function _burn(address account, uint256 amount) internal {
  //  require(account != address(0), "BEP20: burn from the zero address");
//
  //  _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
  //  _totalSupply = _totalSupply.sub(amount);
  //  emit Transfer(account, address(0), amount);
  //}

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
 // function _burnFrom(address account, uint256 amount) internal {
  //  _burn(account, amount);
  //  _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  //}
}
/**
 代理合约：
 0x2C1B2A27d4389B8320cdEb0E67f27E69E0dc3d26
 v0.8.7+commit.e28d00a7; Yes with 200 runs; default evmVersion

 测试网： admin = 0x36952604eD7130f030f17186ee0f30eA3d4A1cf1 ETH-1
0xDea4fb1eE3C4513930f44B5345660f3389E98dD7
代理管理员地址：
0xc992257B7CCB5a456Ea1C10c09F9F12D02480fBE
—DATA: 0x8129fc1c
生成代理地址：
0xE733C53C5ea369768A19dC71e52996B036B6D0ce
AS_REFER地址：
0xc992257B7CCB5a456Ea1C10c09F9F12D02480fBE

*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.4;

// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC20Upgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./Initializable.sol";
import "./AddressUpgradeable.sol";
import "./IERC20.sol";
import "./router.sol"; //薄饼交易所的工厂和路由合约
import "./ITGG.sol";   //接口


contract ASToken is ERC20Upgradeable, OwnableUpgradeable {

    using AddressUpgradeable for address; //使用

    //自定义结构体
    struct Map {
        address[] keys;  //地址
        mapping(address => uint256) values; //地址值
        mapping(address => uint256) indexOf;//索引值
        mapping(address => bool) inserted;  //已插入
    }

    Map private tokenHoldersMap;            //代币持有者地图    
        
    address public pair;                    //交易对地址 0x3efa3b7b01d005d3b5e871d68f6d2e2106580a66
    mapping(address => bool) public whiteList;      //白名单（免手续费、白名单模式可以卖币）

    uint constant LP_magnitude = 2 ** 128;  //常量2**128 目的是避免算LP分红比时有小数
    uint LP_limitBalance;                   //LP地址可分红的最小余额
    uint public LP_claimWait;               //LP分红提取间隔时间 3600=1小时
    uint256 public LP_lastProcessedIndex;   //处理LP分红地址的最后处理索引
    uint public LP_gasForProcessing;        //LP分红处理的gas费  200000 （这个是处理LP分红时，提交处理时的通常的gas费用）
    mapping(address => uint) public LP_lastClaimTimes;      //记录上次LP分红时间
    mapping(address => uint) public LP_withdrawnDividends;  //记录LP地址的已分红数
    mapping(address => bool) public LP_No_Divide;           //不参与LP分成的标识

    //三个LP分红相关事件：分配股息、提取LP分红成功、处理LP分红额
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    event DividendWithdrawn(address indexed to, uint256 weiAmount); 

    //owner 0xe7d862f51573c1b88c7fcc12e0b4198d8d87436e
    address public com;         //管理地址 0x1bb07081a5e5cba2de27351fcc1640d6341a53e0 
    address public market;      //市场地址 0x019b301bea458f24f9067f91db62cbb221e02b6b
    address public airDrop;     //空投地址 0x1bb07081a5e5cba2de27351fcc1640d6341a53e0 
    address public fund;        //基金地址 0x5aae47c74a09f7620d4b7dd9a0c0332474cf15d7
    //推荐关系在另一个合约里：https://bscscan.com/address/0x11ea7e2af32dad76a8dc8b154ae4d4a64c5de30d#code
    Refer public refer;      //推荐合约地址 0x11ea7e2af32dad76a8dc8b154ae4d4a64c5de30d ，好像这个数据和程序在另一个合约里实现，通过接口来获取？ ITGG.sol有接口程序
    uint256 private _totalSupply;           //总供应量
    //薄饼V2路由地址 0x10ed43c718714eb63d5aa57b78b54704e256024e
    IPancakeRouter02 public constant router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint public magnifiedDividendPerShare;  //每股分红   0
    uint public totalDividendsDistributed;  //分配的股息总额 0
    uint[] feeRate;         //费率
    uint public sellFee;    //卖手续费
    uint public buyFee;     //买手续费    
    bool public swaping;    //交易中
    mapping(address => address) public invitor; //邀请者？


    bool public whiteOnly;  //仅限白名单

    //___________________ungrade 次级 ？ upgrade 升级
    uint devidendsMode;                         //设备模式，用于不同手续费处理方法          
    mapping(address => bool) public black;      //黑名单
    mapping(address => bool) public Normal;     //正常地址标识，如果为true，表示不能卖币
    mapping(address => uint) fristBuy;          //首次购买（记录测试交易值）可实现用来抢币记录
    bool public fristBuyMode;                   //首次购买（测试交易）
    //与Normal配合实现：对地址币进行锁仓、到一定时间才能转和交易
    uint public deadLine;                       //可交易的期限时间 0 可指定该区块时间后才能进行交易，这个对地址 Normal 状态为true的才有效
    bool public contractStatus;                 //本合同状态
    mapping(address => bool) public depolyer;   //仓库管理者？（不能用于推荐关系）

    //初始值设定项
    function initialize() external initializer {
        __ERC20_init_unchained("Tigger Token", "TGG");  //代币的名称、符号
        __Context_init_unchained();
        __Ownable_init_unchained();
        LP_claimWait = 3600;                   //提取等待 3600=1小时
        _mint(msg.sender, 1000000 ether);   //产币10万给合约提交者
        sellFee = 14;                       //卖手续费14%
        buyFee = 14;                        //买手续费14%
        LP_gasForProcessing = 200000;       //处理gas费 200000

        //本合约地址、销毁地址、V2路由地址、都不参会LP分成
        LP_No_Divide[address(this)] = true;  
        LP_No_Divide[address(0)] = true;
        LP_No_Divide[address(router)] = true;

        whiteOnly = true;               //开始只能白名单
        whiteList[msg.sender] = true;   //本合约提交地址为白名单
        LP_limitBalance = 1e14;         //LP地址可分红的最小余额，如果余额=0会被移除地址图集合 1e14=1后面14个0, 币小数位数18位，则= 0.00001
        contractStatus = true;          //合约状态正常
        devidendsMode = 1;              //设备模式？ 1 
        feeRate = [30, 10, 5, 5, 5, 5, 5, 5];   //手续费分红比例
        depolyer[msg.sender] = true;    //本合约提交地址为仓库管理者
    }

    //==================== 管理者使用的函数 =========================

    //修改白名单开关
    function setWhiteOnly(bool b) external onlyOwner {
        whiteOnly = b;
    }
    //设置仓库管理者
    function setDepolyer(address addr_, bool b) external onlyOwner{
        depolyer[addr_] = b;
    }
    //设置合同状态
    function setContractStatus(bool b) external onlyOwner {
        contractStatus = b;
    }
    //修改是否为 正常地址 如果true 表示该地址不能卖币
    function setNormal(address addr, bool b) external onlyOwner {
        Normal[addr] = b;
    }
    //设置可交易的期限时间 输入的时间+3天
    function setDeadline(uint times) external onlyOwner {
        deadLine = times + 3 days;
    }
    //设置钱包相关钱包地址
    function setWallet(address com_, address market_, address airDrop_, address fund_) external onlyOwner {
        com = com_;
        market = market_;
        airDrop = airDrop_;
        fund = fund_;
    }
    //设置第一次买状态
    function setFristBuy(bool b) external onlyOwner {
        fristBuyMode = b;
    }
    //设置设备模式
    function setDevidendsMode(uint mode_) external onlyOwner {
        devidendsMode = mode_;
    }
    //设置交易对地址
    function setPair(address pair_) external onlyOwner {
        pair = pair_;
    }
    //设置gas费
    function setGasForProcessing(uint gas_) external onlyOwner {
        LP_gasForProcessing = gas_;
    }
    //设置推荐关系合约地址
    function setRefer(address addr) external onlyOwner {
        refer = Refer(addr);
    }
    //设置不参与LP分成的地址
    function setNoDividends(address addr, bool b) external onlyOwner {
        LP_No_Divide[addr] = b;
    }
    //设置黑名单
    function setBlack(address addr, bool b) external onlyOwner {
        black[addr] = b;
    }
    //设置LP地址可分红的最小限额
    function setLimitBalance(uint balance) external onlyOwner{
        LP_limitBalance = balance;
    }
    //设置白名单
    function setWhiteList(address addr, bool b) external onlyOwner {
        whiteList[addr] = b;
    }
    //设置买卖手续费
    function setFee(uint buy, uint sell) external onlyOwner {
        buyFee = buy;
        sellFee = sell;
    }
    //空投，批量转账
    function AirDrop(address[] memory list1, uint[] memory list2) external onlyOwner{
        for(uint i = 0; i < list1.length; i ++){
            tokenHoldersMap.values[msg.sender] -= list2[i];
            tokenHoldersMap.values[list1[i]] += list2[i];
            emit Transfer(msg.sender, list1[i], list2[i]);
        }
    }
    //===================== 查询 ======================

    //获取地址总数
    function size() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }
    //获取币的数量 代币持有者地图.values
    function balanceOf(address addr) public view override returns (uint){
        return tokenHoldersMap.values[addr];
    }
    //总供应量
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // ================================ LP 分红计算 =====================================

    //在交易中处理LP分成的 过程，循环数量每个地址看是否有LP分红
    function process(uint256 gas) internal returns (uint256, uint256, uint256){
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length; //地址图的长度
        if (pair == address(0)) { //如果还没有交易对地址，返回0
            return (0, 0, 0);
        }
        if (numberOfTokenHolders == 0) { //如果没有地址图数 返回（0,0，最后索引指针数）
            return (0, 0, LP_lastProcessedIndex); 
        }

        uint256 _lastProcessedIndex = LP_lastProcessedIndex;
        uint256 gasUsed = 0;          //已用的gas
        uint256 gasLeft = gasleft();  //交易带的gas值减去交易执行到现在的gas余额
        uint256 iterations = 0;       //循环地址计数
        uint256 claims = 0;           //提取分红次数

        //   已用的gas < 提供的gas 且  迭代计数值 < 地址数
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++; //计数器+1

            //计数大于等于地址总数，重置0
            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            //自动提取LP分红时间到
            if (canAutoClaim(LP_lastClaimTimes[account])) {
                //处理LP分红 ， 分红成功则记录上次LP分红时间。0.5.0版本中使用transfer方法时，使用transfer的账户地址必须声明 payable
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++; //循环地址计数+1
            uint256 newGasLeft = gasleft(); //剩下的gas余额

            //记录已使用了的gas
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed + (gasLeft - newGasLeft);
            }

            gasLeft = newGasLeft; //赋值剩下的gas余额
        }

        LP_lastProcessedIndex = _lastProcessedIndex; //记录上次地址地图索引值

        return (iterations, claims, LP_lastProcessedIndex);
    }

    //自动提取LP分红时间是否到。 lastClaimTime_ 为上次成提取的时间
    function canAutoClaim(uint256 lastClaimTime_) private view returns (bool) {
        if (lastClaimTime_ > block.timestamp) { //设置时间>区块当前时间，返回 false
            return false;
        }
        return (block.timestamp - lastClaimTime_) >= LP_claimWait; //返回 区块时间-上次提取时间 >= 提取间隔时间
    }

    //处理LP分红 ， 分红成功则记录上次LP分红时间。 
    //注意：0.5.0版本中使用transfer方法时，使用transfer的账户地址必须声明 payable
    function processAccount(address payable account, bool automatic) internal returns (bool){
        uint256 amount = _withdrawDividendOfUser(account);  //获取地址的LP分红，并返回分红的额
        // 如果刚LP分红>0  且 地址币数量 >= 1e14
        if (amount > 0 && balanceOf(account) >= LP_limitBalance) {
            LP_lastClaimTimes[account] = block.timestamp;  //记录上次LP分红时间
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }

    //提取LP分红，并返回分红的额。0.5.0版本中使用transfer方法时，使用transfer的账户地址必须声明 payable
    function _withdrawDividendOfUser(address payable user) internal  returns (uint256)  {
        uint256 _withdrawableDividend = withdrawableDividendOf(user); //获取可提取的分红额度
        if (_withdrawableDividend > 0) {            
            LP_withdrawnDividends[user] = LP_withdrawnDividends[user] + _withdrawableDividend; //更新已提交分红总数
            emit DividendWithdrawn(user, _withdrawableDividend);
            //如果地址 不是交易对合约地址 ，也不是免LP分红地址
            if (user != pair && !LP_No_Divide[user]) {
                _transfer(address(this),user, _withdrawableDividend); //LP分红暂存在本合约地址的币转给
            }
            return _withdrawableDividend;
        }
        return 0;
    }
    //获取LP地址 可提取的分红额
    function withdrawableDividendOf(address addr) public view returns (uint256){
        //    地址应该得分红 <= 地址分红数
        if (accumulativeDividendOf(addr) <= LP_withdrawnDividends[addr]) {
            return 0;
        }
        return accumulativeDividendOf(addr) - LP_withdrawnDividends[addr];
    }
    //根据地址的交易对合约的占比数量获取 地址 的分红
    function accumulativeDividendOf(address addr) public view returns (uint){
        //     每股分红  *              交易对合约代币的地址数量 /   常量2**128
        return magnifiedDividendPerShare * IERC20(pair).balanceOf(addr) / LP_magnitude;
    }

    //添加LP分成额度 
    function SendDividends(uint256 amount) private {
        distributeCAKEDividends(amount);
    }
    function distributeCAKEDividends(uint256 amount) internal {
        uint supply = getSupply(); //获取交易池的总量
        require(supply > 0);

        if (amount > 0) {
            // 更新每股分红 = 每股分红 + 派息额 * 常量2**128 / 交易池总量
            magnifiedDividendPerShare = magnifiedDividendPerShare + amount * LP_magnitude / supply;
            emit DividendsDistributed(msg.sender, amount);
            //分配的股息总额
            totalDividendsDistributed = totalDividendsDistributed + amount;
        }
    }
    //获取交易池的总量
    function getSupply() private view returns (uint){
        if (pair == address(0)) {
            return 0;
        }
        return IERC20(pair).totalSupply();
    }


    //铸币
    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        //在任何令牌转移之前调用的钩子。这包括铸造和燃烧。
        _beforeTokenTransfer(address(0), account, amount); //初始化
        uint balance = tokenHoldersMap.values[account];
        _totalSupply += amount;
        set(account, balance + amount);
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }


    //转账核心
    function _transfer(address sender,address recipient,uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");     //发送地址不是0
        require(!black[msg.sender] && !black[sender] && !black[recipient], 'black');//三个地址都不是黑名单
        uint256 senderBalance = balanceOf(sender);    //发送者余额
        uint recipientBalance = balanceOf(recipient); //接收者余额
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance"); //发送者余额不足
        set(sender, senderBalance - amount);
        set(recipient, recipientBalance + amount);

        //如果币为0则从地址图里移除
        if (balanceOf(sender) == 0) { 
            remove(sender); 
        }

        //计算地址分红数：发送者地址已分红数 * 交易额 / 发送地址转币前的余额 ？
        uint tempDebt = LP_withdrawnDividends[sender] * amount / senderBalance;
        LP_withdrawnDividends[recipient] += tempDebt;  //添加地址分红数
        LP_withdrawnDividends[sender] -= tempDebt;

        emit Transfer(sender, recipient, amount);

    }


    //两个 正常地址 的白名单逻辑关系，与 或 非
    function _isNormalList(address addr1, address addr2, bool all_) internal view returns (bool) {
        if (all_) {
            return Normal[addr1] && Normal[addr2];
        }
        return Normal[addr1] || Normal[addr2];
    }

    //转账
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        //绑定推荐关系： 发送地址不是合约     转账数量>=1      接收地址不是合约        发送地址不是仓库管理者
        if (!msg.sender.isContract() && amount >= 1 && !recipient.isContract() && !depolyer[msg.sender]) {
            refer.bondUserInvitor(recipient, msg.sender); //债券使用者邀请人
        }

        //   实现第一次买（测试交易）对测试交易的买币额度有限制
        //   第一次买模式  且  发送地址是交易对地址 且 发生者不是白名单 也不是 限制地址 
        if (fristBuyMode && msg.sender == pair && !whiteList[msg.sender] && !Normal[msg.sender]) {
            fristBuy[recipient] += amount;
            require(fristBuy[recipient] <= 1e17, 'out of amount');
        }
        
        //如果 发送 接收 都不是白名单，且不在处理手续费交易中
        if (!whiteList[msg.sender] && !whiteList[recipient] && !swaping) {

            //   发送和接收都不是限制, 或超过限制时间
            if (!_isNormalList(msg.sender, recipient, false) || block.timestamp >= deadLine) {
                //确定是买交易
                if (msg.sender == address(router) || msg.sender == pair) {
                    //设备模式=1
                    if (devidendsMode == 1) {
                        swaping = true; //
                        uint temp = amount * buyFee / 100;
                        _transfer(msg.sender, address(0), temp * 3 / 14);  //销毁3%
                        _transfer(msg.sender, address(this), temp / 7);    //2% LP分红的币先放到本合约地址里
                        SendDividends(temp / 7); //添加LP分成额度 14/7=2%
                        _transfer(msg.sender, com, temp / 14);    //社区空投 1% 
                        _transfer(msg.sender, market, temp / 14); //营销地址 1%
                        amount -= temp;
                        uint left = temp / 2;
                        address tempAddress = refer.checkUserInvitor(recipient); //获取推荐地址
                        for (uint i = 0; i < 8; i++) {
                            if (tempAddress == address(0)) {
                                if (left != 0) {
                                    _transfer(msg.sender, address(0), left);
                                    break;
                                }
                            }
                            _transfer(msg.sender, tempAddress, temp * feeRate[i] / 140);
                            left -= temp * feeRate[i] / 140;
                            tempAddress = refer.checkUserInvitor(tempAddress);
                        }
                        swaping = false;
                    //设备模式=2
                    } else if (devidendsMode == 2) {
                        uint temp = amount * sellFee / 100;
                        amount -= temp;
                        _transfer(msg.sender, airDrop, temp / 14);  //空投地址 1%
                        uint left = temp * 13 / 14;
                        address tempAddress = refer.checkUserInvitor(recipient);
                        for (uint i = 0; i < 2; i++) {
                            if (tempAddress == address(0)) {
                                if (left != 0) {
                                    _transfer(msg.sender, address(0), left);
                                    break;
                                }
                            }
                            if (i == 0) {
                                _transfer(msg.sender, tempAddress, temp * 8 / 14);
                                left -= temp * 8 / 14;
                            } else {
                                _transfer(msg.sender, tempAddress, temp * 5 / 14);
                                left == 0;
                                break;
                            }
                            tempAddress = refer.checkUserInvitor(tempAddress);
                        }
                    }
                //是转账
                } else {
                    uint temp = amount * sellFee / 100;
                    _transfer(msg.sender, address(0), temp * 5 / 14);
                    _transfer(msg.sender, airDrop, temp * 9 / 14);   //空投地址 9/14%
                    amount -= temp;
                }
            }
        }

        //交易对地址不是0，触发LP分红。
        if (pair != address(0)){        
            process(LP_gasForProcessing);
        }

        _transfer(_msgSender(), recipient, amount);

        return true;
    }


    //两地址转账 (多用于交易)
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        require(!contractStatus, 'contract lock');  //合约正常才能转
        if (whiteOnly) {  //如果是白名单状态
            if(msg.sender == address(router)){  //提交地址是路由器(与交易\LP有关)，则三个地址必须有一个是白名单地址
                require(whiteList[msg.sender] || whiteList[recipient] || whiteList[sender], 'not white');
            }

        }
        // 如果 提交地址、发送地址、接收地址 都不是白名单，且在不在交易中
        if (!whiteList[msg.sender] && !whiteList[recipient] && !whiteList[sender] && !swaping) {

            // 三个地址都没有限制  或 区块时间>=开始交易的期限时间（超过限制时间）。 
            if ((!Normal[msg.sender] && !Normal[recipient] && !Normal[sender]) || block.timestamp >= deadLine) {

                //提交地址是路由 或 发送地址或接受地址是 交易对地址， 确定与交易或LP相关
                if (msg.sender == address(router) || recipient == pair || sender == pair) {
                    //发送地址只能交易90%，卖币不能一次卖完，买币不能把交易对的币买完
                    require(amount <= balanceOf(sender) * 9 / 10, 'must less than 90%'); 
                    swaping = true;  //交易开始
                    uint temp = amount * sellFee / 100;
                    _transfer(sender, address(0), temp * 10 / 14); //销毁
                    _transfer(sender, fund, temp * 4 / 14);        //基金
                    amount -= temp;
                    swaping = false; //交易结束
                } else {  //是授权转账
                    uint temp = amount * sellFee / 100;  
                    _transfer(sender, address(0), temp * 5 / 14); //销毁
                    _transfer(sender, airDrop, temp * 9 / 14);    //给空投地址？
                    amount -= temp;
                }

            }
        }
        //交易对地址不是0，触发LP分红。
        if (pair != address(0)){
            process(LP_gasForProcessing);
        }
        _transfer(sender, recipient, amount);

        //确保有授权才执行
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }
        return true;
    }





    //================ 地址结构体集合相关操作 ================

    // 通过地址获取 地址的值 （与 balanceOf 功能一样）可以不用
    function get(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }
    //通过地址 获取 索引位置 
    function getIndexOfKey(address key) public view returns (int256)
    {
        if (!tokenHoldersMap.inserted[key]) {
            return - 1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }
    //通过索引，获取地址
    function getKeyAtIndex(uint256 index) public view returns (address)
    {
        return tokenHoldersMap.keys[index];
    }
    //持币地址图 添加 或 修改值
    function set(address key,uint256 val) private {
        if (tokenHoldersMap.inserted[key]) { //地址已存在，则赋值
            tokenHoldersMap.values[key] = val;
        } else { //新地址
            tokenHoldersMap.inserted[key] = true; //设置此地址有了
            tokenHoldersMap.values[key] = val; //赋值
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length; //设置索引位置
            tokenHoldersMap.keys.push(key); //压入集合
        }
    }
    //从地址图里 移除地址
    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {  //地址不存在
            return; 
        }

        delete tokenHoldersMap.inserted[key]; //删除插入状态
        delete tokenHoldersMap.values[key];   //删除值记录

        uint256 index = tokenHoldersMap.indexOf[key];         //获取索引位置
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;  //获取最后一个索引值
        address lastKey = tokenHoldersMap.keys[lastIndex];    //获取最后一个索引的地址

        tokenHoldersMap.indexOf[lastKey] = index;   //最后一个地址的索引，换为移除地址的索引
        delete tokenHoldersMap.indexOf[key];   //删除此地址的索引

        tokenHoldersMap.keys[index] = lastKey; //该索引位置，设置为最后这个地址

        tokenHoldersMap.keys.pop();  //弹出地图最后一个
    }


}
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IRelation{
    function addRelationEx(address recommer) external  returns (bool);
    function addRelationEx(address self, address recommer) external returns (bool);
    function parentOf(address) external view returns(address);
    function rootAddress() external view returns(address);
    function getForefathers(address,uint) external view returns(address[] memory);
    function childrenOf(address) external view returns(address[] memory);
}

interface AFT {
    function transferEcology(address from, address addr, uint256 amount) external;
}

contract AFTIDO is Ownable, ReentrancyGuard {

    AFT public aft;
    IERC20 public baseCurrency;     // USDT
    IERC20 public quoteCurrency;    // AFT
    uint8 public period;            // 第几期
    address public usdtAddress;
    IUniswapV2Router02 _router = IUniswapV2Router02(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1));

    struct PresaleInfo {
        uint8 _period;              // 第几期
        uint256 _amount;            // 预售数量(第几期=>每份数量)
        uint256 _price;             // 预售单价(第几期=>单价)
        uint256 _quota;             // 预售份额(第几期=>份额)
        uint256 _platform;          // 平台数量
        uint256 _sold;              // 卖出数量
    }

    struct ParentReward {
        address _token;             // 代币地址
        uint256 _amount;            // 代币数量
    }

    mapping (address => mapping (address => uint256)) public shareRewardMapping;    // 分享收益 (用户钱包地址 => 代币 => 奖励数量)
    mapping (address => mapping (address => uint256)) public extractedMapping;      // 已提取奖励(用户钱包地址 => 代币 => 提取数量)
    mapping (uint8 => PresaleInfo) public presaleMapping;               // 预售信息
    mapping (address => uint256) public myQuotaMapping;                 // 我的认购数量
    mapping (address => uint8) public myLevelMapping;                   // 我的等级
    mapping (uint8 => uint256) levelRewardMapping;                      // 等级分红 1:1% 2:2% 3:3% 4(平级奖):2%平分
    mapping (address => uint256) public myTeamMapping;                  // 我的团队数量
    mapping (address => uint256) public openBoxMapping;                 // 开启盲盒数量
    mapping (address => mapping (bool => uint256)) freeBlindBoxMapping;             // 赠送盲盒(false: 代表未开启数量 true:代表开启数量)
    mapping (address => uint256[]) public openBoxHistoryMapping;                    // 开盲盒纪录
    mapping (address => mapping (address => ParentReward[])) public parentRewardMapping; // 直推收益 key 自己 key 直推人 value提供收益
    uint256[] public blindBoxRewards;               // 盲盒奖励数量
    uint256[] public bigBlindBoxRewards;            // 大盲盒奖励数量

    IRelation public Relation;
    bool public rewardType = false;                 // false、奖励U true:奖励AFT
    bool public rewardCover = false;
    address platform = address(0xC2736322620079734602ad06F0714Ae5B70811b1);
    uint256 recommer = 100;
    uint256 withdrawFee = 50;
    uint256 constant public BASE = 1000;
    bool openPresale = true;

    constructor() {
        period = 1;
        baseCurrency = IERC20(address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684));
        quoteCurrency = IERC20(address(0x83785c3313f82465d60BBF552A6C340Fd8C11248));
        aft = AFT(address(quoteCurrency));
        Relation = IRelation(address(0x28169049B0A0E96B53CaB1aFa559C726c61F676c));
        myLevelMapping[address(0x4067Bca7cdcEfb2730c65284b55ceEE47ea168d9)] = 3;
        presaleMapping[1] = PresaleInfo(1, 50000 ether, 136 ether, 10000, 100 ether, 0);
        presaleMapping[2] = PresaleInfo(2, 40000 ether, 136 ether, 10000, 100 ether, 0);
        presaleMapping[3] = PresaleInfo(3, 30000 ether, 136 ether, 10000, 100 ether, 0);
        levelRewardMapping[1] = 10;
        levelRewardMapping[2] = 20;
        levelRewardMapping[3] = 30;
        levelRewardMapping[4] = 20;
    }

    // 预售开关
    function setPresale(bool _state) external onlyOwner {
        openPresale = _state;
    }

    // 预售
    function presale(address _parent) external {
        require(openPresale);
        PresaleInfo memory presaleInfo = presaleMapping[period];
        require(myQuotaMapping[msg.sender] == 0, "only once");
        require(presaleInfo._quota > presaleInfo._sold, "sold out");
        require(myLevelMapping[_parent] > 0 || myQuotaMapping[_parent] > 0, "parent not activated");
        Relation.addRelationEx(msg.sender, _parent);
        baseCurrency.transferFrom(msg.sender, address(this), presaleInfo._price);
        baseCurrency.transfer(platform, presaleInfo._platform);
        myQuotaMapping[msg.sender] = presaleInfo._amount;
        // 直推奖励
        shareRewardMapping[_parent][address(baseCurrency)] += (presaleInfo._price * recommer)/BASE;
        // 直推收益纪录
        parentRewardMapping[_parent][msg.sender].push(ParentReward(address(baseCurrency), (presaleInfo._price * recommer)/BASE));
        // baseCurrency.transfer(_parent, );
        // 发放等级奖励
        reward(msg.sender, presaleInfo._price, rewardType, rewardCover);
        // 计算是否升级
        _upgrade(msg.sender);
        // 发放预售代币数量
        aft.transferEcology(address(this), msg.sender, presaleInfo._amount);
        presaleInfo._sold += 1;
        presaleMapping[period] = presaleInfo;
    }

    function shareAward (address addr,uint256 _amount) external {
        require(msg.sender == address(quoteCurrency));
        address _parent = Relation.parentOf(addr);
        if (_parent == address(0) || _parent == address(0x000000000000000000000000000000000000dEaD)) {
            return;
        }

        parentRewardMapping[_parent][addr].push(ParentReward(address(quoteCurrency), _amount * 30/BASE));
        quoteCurrency.transfer(_parent, _amount * 30/BASE);
    }

    // 赠送盲盒
    function handsel (address addr) external onlyOwner {
        freeBlindBoxMapping[addr][false] += 1;
    }

    // 我的盲盒数量
    function getSlfeBox (address addr) public view returns (uint256 blindBox) {
        blindBox = Relation.childrenOf(addr).length/10;
    }

    // 开盲盒
    function openBox () external returns (uint256 _boxReward) {
        uint256 blindBox = getSlfeBox(msg.sender);
        require(blindBox > openBoxMapping[msg.sender], "no unopened boxes");
        if (freeBlindBoxMapping[msg.sender][false] > freeBlindBoxMapping[msg.sender][true]) {
            // 开启大盲盒
            freeBlindBoxMapping[msg.sender][true] += 1;
            uint256 _boxIndex = block.timestamp % bigBlindBoxRewards.length;
            _boxReward = bigBlindBoxRewards[_boxIndex];
        } else {
            // 开启小盲盒
            uint256 _boxIndex = block.timestamp % blindBoxRewards.length;
            _boxReward = blindBoxRewards[_boxIndex];
        }

        quoteCurrency.approve(address(quoteCurrency), _boxReward);
        aft.transferEcology(address(this), msg.sender, _boxReward);
        openBoxHistoryMapping[msg.sender].push(_boxReward);
        openBoxMapping[msg.sender] += 1; // 增加开启盲盒数量
    }

    // 获取盲盒收益记录
    function getOpenBoxHistory(address addr) external view returns (uint256[] memory) {
        return openBoxHistoryMapping[addr];
    }

    // 获得盲盒收益
    function getBoxReward () external view returns (uint256 _boxReward) {
        uint256[] memory boxRewardArry = openBoxHistoryMapping[msg.sender];
        for (uint i =0; i < boxRewardArry.length; i++) {
            _boxReward += boxRewardArry[i];
        }
    }

    address[] rewardArry;
    function reward(address _addr, uint256 _amount, bool _rewardType, bool _rewardCover) public {
        require(msg.sender == address(quoteCurrency) || msg.sender == address(this), "no permission");
        uint8 _level;
        address[] memory _rewardArry;
        rewardArry = _rewardArry;
        address _parent = _addr;
        uint256 _rate;
        for (uint8 i = 0; i < 15; i++) {
            _parent = Relation.parentOf(_parent);
            if (_parent == address(0) || _parent == address(0x000000000000000000000000000000000000dEaD)) {
                break;
            }
            
            if (myLevelMapping[_parent] == 0 || (myLevelMapping[_parent] < _level && _level < 3) || (_level > 3 && myLevelMapping[_parent] < 3)) {
                continue;
            }

            if (_level > 3) {
                rewardArry.push(_parent);
                continue;
            }

            _level = myLevelMapping[_parent];

            uint256 _rewardAmount = (_amount * (levelRewardMapping[_level] - _rate))/BASE;
            if (_rewardCover) {
                _rewardAmount = getUToToken(_rewardAmount);
            }

            if (_rewardType) {
                shareRewardMapping[_parent][address(baseCurrency)] += _rewardAmount;
                // baseCurrency.transfer(_parent, _rewardAmount);
            } else {
                shareRewardMapping[_parent][address(quoteCurrency)] += _rewardAmount;
                // quoteCurrency.transfer(_parent, _rewardAmount);
            }

            _rate = levelRewardMapping[_level];

            if (_level <= 3) {
                _level++;
            }
        }

        if (rewardArry.length > 0) { // 平级奖励
            uint256 _rewardAmount = (_amount * levelRewardMapping[4])/(BASE * rewardArry.length);
            if (_rewardCover) {
                _rewardAmount = getUToToken(_rewardAmount);
            }

            for (uint256 i = 0; i < rewardArry.length; i++) {
                if (_rewardType) {
                    shareRewardMapping[rewardArry[i]][address(baseCurrency)] += _rewardAmount;
                    // baseCurrency.transfer(rewardArry[i], _rewardAmount);
                } else {
                    shareRewardMapping[rewardArry[i]][address(quoteCurrency)] += _rewardAmount;
                    // quoteCurrency.transfer(rewardArry[i], _rewardAmount);
                }
            }
        }
        
    }

    function _upgrade(address self) private {
        address _parent = self;
        for (uint256 i = 0; i < 15; i++) {
            _parent = Relation.parentOf(_parent);
            if (_parent == address(0) || _parent == address(0x000000000000000000000000000000000000dEaD)) {
                break;
            }
            myTeamMapping[_parent] += 1;
            uint256 childer = Relation.childrenOf(_parent).length;
            if (myLevelMapping[_parent] == 0 && childer >=5 && myTeamMapping[_parent] >= 30) {
                myLevelMapping[_parent] = 1;
            } else if (myLevelMapping[_parent] == 1 && childer >=10 && myTeamMapping[_parent] >= 200) {
                myLevelMapping[_parent] = 2;
            } else if (myLevelMapping[_parent] == 2 && childer >=15 && myTeamMapping[_parent] >= 500) {
                myLevelMapping[_parent] = 3;
            }
            
        }
    }

    // 绑定上级
    bool public isUpgrade = false;
    function upgrade(address _parent) external {
        require(isUpgrade);
        Relation.addRelationEx(msg.sender, _parent);
        _upgrade(msg.sender);
    }
    // 升级开关
    function openUpgrade(bool _state) external onlyOwner {
        isUpgrade = _state;
    }

    // 提现
    function withdrawBenefits (address token) external {
        uint256 rewardAll = shareRewardMapping[msg.sender][token];
        uint256 extracted = extractedMapping[msg.sender][token];
        uint256 withdrawMin = token == address(baseCurrency)? 10 ether: 500 ether;
        require(rewardAll > 0 && rewardAll > extracted && (rewardAll - extracted) > withdrawMin);
        uint256 withdraw = (rewardAll - extracted) * withdrawFee / BASE;
        token == address(baseCurrency)? baseCurrency.transfer(msg.sender, withdraw): quoteCurrency.transfer(msg.sender, withdraw);
        extractedMapping[msg.sender][token] = rewardAll;
    }

    // 返回
    function getParentRewardList(address addr, address slfe) external view returns (ParentReward[] memory) {
        return parentRewardMapping[addr][slfe];
    }

    function getUToToken (uint256 _uAmount) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(quoteCurrency);
        uint256[] memory amounts = _router.getAmountsOut(_uAmount, path);
        return amounts[1];
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(quoteCurrency);
        path[1] = _router.WETH();
        path[2] = address(baseCurrency);
        quoteCurrency.approve(address(_router), tokenAmount);
        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForU(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(quoteCurrency);
        path[1] = address(baseCurrency);
        quoteCurrency.approve(address(_router), tokenAmount);
        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    uint256 public repoU;
    // 设置盲盒数量
    function setBlindBoxRewards (uint256 _reward) external onlyOwner {
        blindBoxRewards.push(_reward);
    }
    // 设置大盲盒数量
    function setBigBlindBoxRewards (uint256 _reward) external onlyOwner {
        bigBlindBoxRewards.push(_reward);
    }
    // 卖出变成U
    function repo(uint256 tokenAmount, bool openRepo) external {
        require(msg.sender == address(quoteCurrency));
        uint256 oldU = baseCurrency.balanceOf(address(this));
        if (openRepo) {
            swapTokensForU(tokenAmount);
        } else {
            swapTokensForToken(tokenAmount);
        }

        uint256 newU = baseCurrency.balanceOf(address(this));

        repoU += (newU - oldU);
    }

    function setIRelation (address addr) external onlyOwner {
        Relation = IRelation(addr);
    }

    function setPeriod (uint8 _period) external onlyOwner {
        period = _period;
    }

    function setWithdrawFee (uint256 _fee) external onlyOwner {
        require(_fee < BASE);
        withdrawFee = _fee;
    }

    function swapUForTokensTo0() external {
        require(repoU > 0);
        address[] memory path = new address[](2);
        path[0] = address(baseCurrency);
        path[1] = address(quoteCurrency);
        baseCurrency.approve(address(_router), repoU);
        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            repoU,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );

        repoU = 0;
    }
}
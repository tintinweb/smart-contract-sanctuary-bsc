// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;

interface INST {
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);
}

interface INFT {
    function useNftPrice(address account) external returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function nftPrice(uint256 tokenId) external view returns (uint256);

    function nftPower(uint256 tokenId) external view returns (uint256);
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

contract NSTGAME {
    string public name = "NSTGAME";
    string public symbol = "NSTGAME";

    address public owner;
    uint256 public totalReward; //总奖励
    uint256 public pendingReward; //待发奖励
    uint256 public totalPower; //总算力
    uint256 public totalUsersAmount; //总用户数
    mapping(address => uint256) public totalUserReward; //累计奖励

    bool public isMint = false; //是否开启Mint
    uint256 public epoch = 86400; //Mint周期
    uint256 public maxPower = 4999; //最高算力
    uint256 public minPowerRate = 980; // 最低算力比例 980/1000 = 98%
    uint256 public maxDays = 5; // 最高天数

    uint256 public immutable tokenDecimals;
    address public immutable tokenAddress;
    address public immutable nmtAddress;
    address public immutable nftAddress;
    address public constant usdtAddress =
        0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; //usdt合约

    address public burnAddress = 0x0000000000000000000000000000000000000010; //燃烧地址
    uint256 public burnTokenAmount = 1000; //每燃烧1个基础数字需要配合燃烧token的数量 1000/10000
    uint256 public basePrice = 1e18; //回购价格 u

    mapping(uint8 => GameConfig) public gameInfo; // 农场配置 level => config
    struct GameConfig {
        uint8 level; //等级
        uint8 feeRate; //手续费比例
        uint8 rewardRate; //奖励比例 n/10000
        uint8 inviteReward1; //直推奖励 n/1000
        uint8 inviteReward2; //二级奖励 n/1000
    }

    /* This creates an array with all balances */
    mapping(address => uint256) public goldBalanceOf; //待提现奖励
    mapping(address => uint256) public userLand; //土地
    mapping(address => uint256) public userMaxPower; // 用户最高算力
    mapping(address => address) public invite; //邀请
    mapping(address => uint256) public power; //算力
    mapping(address => uint256) public lastMiner; //用户上次Mint时间
    mapping(address => uint256) public inviteCount; //邀请人好友数
    mapping(address => uint256) public rewardCount; //累计奖励

    event StartGame(address indexed _master, uint256 _tokenId);
    event BindInviter(address indexed _user, address indexed _inviter);
    event Burn(address indexed operator, uint256 amount);
    event Minted(address indexed operator, address indexed to, uint256 amount);
    event WithdrawalReward(address indexed src, uint256 wad); //提现奖励
    event RechargeGold(
        address indexed spender,
        address indexed account,
        uint256 amount
    );

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        address _tokenAddress,
        address _nmtAddress,
        address _nftAddress
    ) {
        owner = payable(msg.sender);
        tokenAddress = _tokenAddress;
        nmtAddress = _nmtAddress;
        nftAddress = _nftAddress;
        tokenDecimals = 10**INST(tokenAddress).decimals();

        //初始化参数
        initGame();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    //初始化等级参数
    function initGame() private {
        setGameConfig(0, 50, 20, 0, 0);
        setGameConfig(1, 20, 50, 20, 5);
        setGameConfig(2, 16, 55, 30, 10);
        setGameConfig(3, 14, 60, 40, 15);
        setGameConfig(4, 12, 65, 50, 20);
        setGameConfig(5, 10, 65, 60, 20);
    }

    function setGameConfig(
        uint8 _level,
        uint8 _feeRate,
        uint8 _rewardRate,
        uint8 _inviteReward1,
        uint8 _inviteReward2
    ) public {
        require(
            msg.sender == owner || msg.sender == address(this),
            "caller is not the owner"
        );
        gameInfo[_level] = GameConfig(
            _level,
            _feeRate,
            _rewardRate,
            _inviteReward1,
            _inviteReward2
        );
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    function setBurnAddr(address new_addr) external onlyOwner {
        burnAddress = new_addr;
    }

    // 设置用户最高算力
    function setMaxPower(uint256 _value) external onlyOwner {
        maxPower = _value * tokenDecimals;
    }

    function setMinPowerRate(uint256 _value) external onlyOwner {
        minPowerRate = _value;
    }

    function startMint() external onlyOwner {
        isMint = true;
    }

    function setBasePrice(uint256 _value)
        external
        onlyOwner
        returns (bool success)
    {
        basePrice = _value;
        return true;
    }

    function setMaxDays(uint256 _value) external onlyOwner {
        maxDays = _value;
    }

    function setOwner(address payable new_owner) external onlyOwner {
        owner = new_owner;
    }

    function setburnTokenAmount(uint256 _value) external onlyOwner {
        burnTokenAmount = _value;
    }

    function setUserLand(uint256 tokenId_, address account_)
        external
        onlyOwner
    {
        require(
            INFT(nftAddress).ownerOf(tokenId_) == account_,
            "not owner error"
        ); //需要持有者才能修改
        userLand[account_] = tokenId_;
    }

    function setEpoch(uint256 _epoch) external returns (bool success) {
        epoch = _epoch;
        return true;
    }

    //开启土地
    function startGame() external {
        require(userLand[msg.sender] == 0, "game has been start");

        //激活使用土地nft
        uint256 tokenId_ = INFT(nftAddress).useNftPrice(msg.sender);
        uint256 _power = INFT(nftAddress).nftPower(tokenId_);
        require(_power > 0, "power is 0");

        totalPower += _power;
        totalUsersAmount++;
        userLand[msg.sender] = tokenId_;
        power[msg.sender] = _power;
        userMaxPower[msg.sender] = _power;
        emit StartGame(msg.sender, tokenId_);
    }

    function burn(uint256 _value) external returns (bool success) {
        require(userLand[msg.sender] > 0, "land status error");
        require(_value > 0, "amount is zero");
        require(
            power[msg.sender] + _value * 3 <= maxPower * tokenDecimals,
            "maxPower overflow"
        );

        uint256 balance = INST(tokenAddress).balanceOf(msg.sender);
        require(
            balance + goldBalanceOf[msg.sender] >= _value,
            "amount too many"
        );

        //混合燃烧
        burnRequireToken(_value);

        //如果可以Mint，先挖一次，避免多计算
        if (
            isMint &&
            power[msg.sender] > 0 &&
            block.timestamp - lastMiner[msg.sender] >= epoch
        ) {
            uint256 _reward = getMaxReward(msg.sender);
            if (_reward > 0) {
                doMint(msg.sender);
            } else {
                lastMiner[msg.sender] = block.timestamp; //记录本次Mint时间
            }
        }

        //燃烧,先扣减待领取奖励,再扣减余额
        if (goldBalanceOf[msg.sender] > _value) {
            goldBalanceOf[msg.sender] -= _value;
            pendingReward -= _value;
        } else {
            uint256 sub_value = _value - goldBalanceOf[msg.sender];
            pendingReward -= goldBalanceOf[msg.sender];
            goldBalanceOf[msg.sender] = 0;
            INST(tokenAddress).burn(msg.sender, sub_value);
        }

        _addPower(_value, msg.sender);

        emit Burn(msg.sender, _value);
        return true;
    }

    //兑换算力
    function exchangePower(address _account, uint256 _value)
        external
        returns (bool success)
    {
        require(_value > 0, "amount is zero");
        require(
            power[_account] + _value * 3 <= maxPower * tokenDecimals,
            "maxPower overflow"
        );

        //混合燃烧
        burnRequireToken(_value);

        //如果可以Mint，先挖一次，避免多计算
        if (
            isMint &&
            power[_account] > 0 &&
            block.timestamp - lastMiner[_account] >= epoch
        ) {
            uint256 _reward = getMaxReward(_account);
            if (_reward > 0) {
                doMint(_account);
            } else {
                lastMiner[_account] = block.timestamp; //记录本次Mint时间
            }
        }

        //充值不使用游戏余额
        INST(tokenAddress).burn(msg.sender, _value);
        _addPower(_value, _account);

        emit Burn(_account, _value);
        return true;
    }

    function _addPower(uint256 _value, address _account) private {
        uint256 addPower = _value * 3;
        power[_account] += addPower; //燃烧加3倍算力
        totalPower += addPower; //累计总算力

        if (power[_account] > userMaxPower[_account]) {
            userMaxPower[_account] = power[_account];
        }

        reward_upline(_account, _value); //给上级奖励
    }

    function reward_upline(address _account, uint256 _value)
        private
        returns (bool success)
    {
        //邀请人不能为空
        address invite1 = invite[_account];
        if (invite1 != address(0)) {
            uint8 lv = getPowerLv(invite1);
            uint8 scale = gameInfo[lv].inviteReward1;
            uint256 maxReward = getMaxReward(invite1);

            if (maxReward > 0 && scale > 0) {
                //小数支持不好，就先乘后除的方法
                uint256 reward = (_value * scale) / 1000;
                //如果本次算力大于上级
                if (reward > maxReward) {
                    reward = maxReward;
                }

                power[invite1] -= reward; //减少邀请人算力
                totalPower -= reward; //减少总算力
                rewardCount[invite1] += reward; //记录累计奖励
                _mint(invite1, reward); //增加邀请人余额
            }

            address invite2 = invite[invite1];
            if (invite2 != address(0)) {
                lv = getPowerLv(invite2);
                scale = gameInfo[lv].inviteReward2; // n/1000
                maxReward = getMaxReward(invite2);
                if (maxReward > 0 && scale > 0) {
                    uint256 reward = (_value * scale) / 1000;
                    //如果本次算力大于上级
                    if (reward > maxReward) {
                        reward = maxReward;
                    }

                    power[invite2] -= reward; //减少邀请人算力
                    totalPower -= reward; //减少总算力
                    rewardCount[invite2] += reward; //记录累计奖励
                    _mint(invite2, reward); //增加邀请人余额
                }
            }
        }
        return true;
    }

    function buy(uint256 amount_) external {
        uint256 getUSDTamount = (amount_ * basePrice) / tokenDecimals;
        TransferHelper.safeTransferFrom(
            usdtAddress,
            msg.sender,
            address(this),
            getUSDTamount
        );
        TransferHelper.safeTransfer(tokenAddress, msg.sender, amount_);
    }

    //出售给系统 所有用户可以向游戏合约回购池卖币
    function sell(uint256 amount_) external {
        uint256 getUSDTamount = (amount_ * basePrice) / tokenDecimals;
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );
        TransferHelper.safeTransfer(usdtAddress, msg.sender, getUSDTamount);
    }

    //充值
    function rechargeGold(address _account, uint256 _value)
        external
        returns (bool success)
    {
        require(_value > 0, "amount is zero");

        //充值不使用游戏余额
        INST(tokenAddress).burn(msg.sender, _value);

        totalReward += _value;
        pendingReward += _value;
        goldBalanceOf[_account] += _value;
        emit RechargeGold(msg.sender, _account, _value);
        return true;
    }

    // 提现奖励
    function withdrawReward(uint256 _value) external returns (bool) {
        require(_value > 0, "amount is zero error");
        uint256 taxFee = transfer_fee(msg.sender, _value);

        require(goldBalanceOf[msg.sender] >= _value, "balanceOf error");
        goldBalanceOf[msg.sender] -= _value;
        pendingReward -= _value;

        INST(tokenAddress).mint(msg.sender, _value);
        if (taxFee > 0) {
            // INST(tokenAddress).mint(burnAddress, taxFee);
            TransferHelper.safeTransferFrom(
                tokenAddress,
                msg.sender,
                burnAddress,
                taxFee
            );
        }

        emit WithdrawalReward(msg.sender, _value);
        return true;
    }

    //需要混合燃烧
    function burnRequireToken(uint256 burnAmount_) private {
        if (burnAmount_ > 0 && burnTokenAmount > 0) {
            TransferHelper.safeTransferFrom(
                nmtAddress,
                msg.sender,
                burnAddress,
                (burnTokenAmount * burnAmount_) / 10000
            );
        }
    }

    function registration(address invite_) external returns (bool success) {
        require(invite[msg.sender] == address(0), "repeat registration"); //现在没有邀请人
        require(msg.sender != invite_, "not self"); //不能是自己

        // 上级必须已经绑定过邀请人或者绑定管理员帐号
        require(
            invite_ == owner || invite[invite_] != address(0),
            "The inviter must have been bound"
        );

        invite[msg.sender] = invite_; //记录邀请人
        inviteCount[invite_] += 1; //邀请人的下级数加一
        emit BindInviter(msg.sender, invite_);
        return true;
    }

    function rewardAmount(address _account) public view returns (uint256) {
        uint256 reward;
        if (block.timestamp - lastMiner[_account] >= epoch) {
            uint8 lv = getPowerLv(_account);
            uint8 scale = gameInfo[lv].rewardRate;

            uint256 maxReward = getMaxReward(_account);
            if (scale > 0 && maxReward > 0) {
                uint256 miner_days = (block.timestamp - lastMiner[_account]) /
                    epoch;

                //v1及以上可以累计5天挖矿
                if (lv < 1) {
                    miner_days = 1;
                } else if (lastMiner[_account] == 0) {
                    miner_days = 1; //第一次Mint只能1天
                } else if (miner_days > maxDays) {
                    miner_days = maxDays; //单次最多领取天数
                }

                //算力*比例*天数
                reward = (power[_account] * miner_days * scale) / 10000;
                if (reward > maxReward) {
                    reward = maxReward;
                }
            }
        }

        return reward;
    }

    //Mint
    function mint() external returns (bool success) {
        require(getMaxReward(msg.sender) > 0, "power is not enough");
        doMint(msg.sender);
        return true;
    }

    // Mint的时候，要检查用户是否持有此NFT，如果未持有，就不能Mint，Mint的条件：地址,NFT,游戏三个都要对应上。
    function doMint(address _account) private {
        uint256 tokenId_ = userLand[_account];
        require(tokenId_ > 0, "land status error");
        require(
            INFT(nftAddress).ownerOf(tokenId_) == _account,
            "nft ownerOf error"
        );
        require(isMint, "not start mint");
        require(power[_account] > 0, "power is zero"); //算力不能为零

        require(
            block.timestamp - lastMiner[_account] >= epoch,
            "last_miner error"
        ); //距离上次Mint大于一个周期

        uint256 reward = rewardAmount(_account);
        require(reward > 0, "reward is zero");

        lastMiner[_account] = block.timestamp; //记录本次Mint时间
        power[_account] -= reward; //算力减去本次转换的
        totalPower -= reward; //减少总算力
        _mint(_account, reward); //增加邀请人余额
    }

    function transfer_fee(address _from, uint256 _value)
        public
        view
        returns (uint256 fee)
    {
        uint8 lv = getPowerLv(_from);
        uint8 scale = gameInfo[lv].feeRate;
        if (scale == 0) {
            return 0;
        }
        uint256 _fee = (_value * scale) / 100;
        return _fee;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "mint to the zero address");
        totalReward += amount;
        pendingReward += amount;
        goldBalanceOf[account] += amount;
        totalUserReward[account] += amount;
        emit Minted(address(this), account, amount);
    }

    //获取算力等级
    function getPowerLv(address account_) public view returns (uint8 Lv) {
        Lv = 0;
        uint256 power_ = power[account_];
        if (power_ < 502 * tokenDecimals) {
            Lv = 0;
        } else if (power_ < 5000 * tokenDecimals) {
            Lv = 1;
        } else if (power_ < 10000 * tokenDecimals) {
            Lv = 2;
        } else if (power_ < 20000 * tokenDecimals) {
            Lv = 3;
        } else if (power_ < 40000 * tokenDecimals) {
            Lv = 4;
        } else if (power_ >= 40000 * tokenDecimals) {
            Lv = 5;
        }
    }

    function getMaxReward(address account_) public view returns (uint256) {
        uint256 minPower = (userMaxPower[account_] * minPowerRate) / 1000;
        if (minPower > power[account_]) {
            return 0;
        }
        return power[account_] - minPower;
    }
}
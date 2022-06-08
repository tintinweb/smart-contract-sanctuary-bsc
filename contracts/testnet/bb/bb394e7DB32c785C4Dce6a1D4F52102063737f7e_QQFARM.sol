// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface INFT {
    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mintToCaller(address caller, string memory tokenURI)
        external
        returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function balanceOf(address owner) external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IJIFEN {
    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;
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

interface Game {
    struct OldGameInfo {
        uint256 id;
        bool status; //游戏状态
        address master; //管理者
        bool isTemp; //是否临时
        uint256 level; //等级
        uint256 exp; //经验
        uint256 upgrade; //升级经验
        uint256 upgradeTime; //升级时间
        uint8 lands; //土地数量
        uint256 nextHarvestAt; //下一次收获时间
    }
}

interface IGAME is Game {
    function gameInfo(uint256 _tokenId)
        external
        view
        returns (OldGameInfo memory game);
}

contract QQFARM is Game, IERC721Receiver {
    string public name = "QQFARM";
    string public symbol = "QQFARM";
    address public owner;

    uint256 public totalReward; //总奖励
    uint256 public totalUsers; //总用户数

    uint256 public epoch = 120; //周期 86400
    uint256 public rewardMaxDay = 5; //奖励累计5d
    address public tempOwner = 0x000000000000000000000000000000000000dEaD; //临时土地所有者
    uint256 public whitePower = 1000 * 1e18;
    uint256 public stealRate = 5; //偷菜比例 5%
    uint256 public stealMaxNum = 2; //偷菜次数
    uint256 public unstakeFee = 25; //提前解押手续费
    uint256 public unstakeEpoch = 600; //解押周期 864000 - 10d

    address public burnAddress = 0x000000000000000000000000000000000000dEaD; //销毁地址
    uint256 public burnFee = 30; //30/100
    uint256 public burnInvite1 = 20; //销毁邀请比例
    uint256 public burnInvite2 = 10; //销毁邀请比例
    uint256 public marketFee = 40; //销毁回营销比例
    address public depositAddress; //扣款地址
    address public stakedAddress; //质押地址
    address public marketAddress; //营销地址

    address public jfAddress; //积分地址
    address public qfAddress; //QF地址
    address public fertAddress; //Fert地址
    address public nftAddress;
    address public upgradeAddress;

    mapping(uint256 => FarmConfig) public farmConfig; // 农场配置 level => config
    mapping(uint256 => bool) public gameUpgrade; // oldgame 升级状态

    mapping(uint256 => GameInfo) public gameInfo; // 游戏信息
    mapping(address => UserInfo) public userInfo; // 用户信息
    mapping(address => uint256) public registerUser; // 注册用户

    mapping(address => address) public invite; // 邀请人
    mapping(address => uint256) public inviteCount; // 邀请人数
    mapping(address => uint256) public inviteReward; // 邀请奖励

    struct UserInfo {
        uint256 id;
        uint256 lastStakedAt;
        uint256 userPower;
        uint256 userReward;
        bool status;
        uint256 level;
    }

    struct GameInfo {
        uint256 id;
        uint256 level;
        bool status;
        address master;
        uint256 lastHarvestAt;
        uint256 steal; //被偷菜次数
    }

    struct FarmConfig {
        uint256 level; //等级
        uint256 maxPower; //最大质押
        uint256 minPower; //最小质押
        uint256 requireQF; //升级所需QF
        uint256 requireFert; //升级所需Fert
        uint256 rewardRate; //奖励比例  10 / 10000 0.1%
        uint256 rewardJF; //奖励积分
        uint256 inviteReward1; //邀请奖励1  20 /1000 2%
        uint256 inviteReward2; //邀请奖励2
    }

    event StartGame(address indexed _master, uint256 _tokenId);
    event GameOver(address indexed _master, uint256 _tokenId);
    event Harvest(address indexed _master, uint256 _amount);
    event Upgrade(address indexed _user, uint256 _tokenId, uint256 _level);
    event Steal(
        address indexed _user,
        address indexed _master,
        uint256 _amount
    );
    event InviteReward(address indexed _user, uint256 _amount);
    event BindInviter(address indexed _user, address indexed _inviter);
    event UpgradedGame(
        address indexed _user,
        uint256 _tokenId,
        uint256 _newTokenId
    );
    event Staked(address indexed _user, uint256 _amount);
    event UnStaked(address indexed _user, uint256 _amount);

    constructor(address _upgradeGame) {
        owner = msg.sender;
        upgradeAddress = _upgradeGame;

        initGame();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function initGame() private {
        // 0级农场-白色
        setFarmConig(
            0, //level
            0, //maxPower
            0, //minPower
            0, //requireQF
            0, //requireFert
            10, //rewardRate 10 / 10000 0.1%
            1e18, //rewardJF
            0, //inviteRate1
            0 //inviteRate2
        );

        // 1级农场-紫色
        setFarmConig(
            1, //level
            5000 * 1e18, //maxPower
            1e18, //minPower
            500 * 1e18, //requireQF
            0, //requireFert
            15, //rewardRate 10 / 10000 0.1%
            8 * 1e18, //rewardJF
            20, //inviteRate1 20 /1000 2%
            5 //inviteRate2
        );

        // 2级农场-橙色
        setFarmConig(
            2, //level
            10000 * 1e18, //maxPower
            1e18, //minPower
            1000 * 1e18, //requireQF
            3000 * 1e18, //requireFert
            30, //rewardRate 10 / 10000 0.1%
            15 * 1e18, //rewardJF
            30, //inviteRate1 20 /1000 2%
            10 //inviteRate2
        );

        // 3级农场-红色
        setFarmConig(
            3, //level
            30000 * 1e18, //maxPower
            1e18, //minPower
            3000 * 1e18, //requireQF
            16000 * 1e18, //requireFert
            50, //rewardRate 10 / 10000 0.1%
            20 * 1e18, //rewardJF
            40, //inviteRate1 20 /1000 2%
            15 //inviteRate2
        );

        // 4级农场-钻石
        setFarmConig(
            4, //level
            80000 * 1e18, //maxPower
            1e18, //minPower
            9000 * 1e18, //requireQF
            68000 * 1e18, //requireFert
            100, //rewardRate 10 / 10000 0.1%
            30 * 1e18, //rewardJF
            50, //inviteRate1 20 /1000 2%
            20 //inviteRate2
        );
    }

    function setFarmConig(
        uint256 _level,
        uint256 _maxPower,
        uint256 _minPower,
        uint256 _requireQF,
        uint256 _requireFert,
        uint256 _rewardRate,
        uint256 _rewardJF,
        uint256 _inviteRate1,
        uint256 _inviteRate2
    ) public {
        require(
            msg.sender == owner || msg.sender == address(this),
            "caller is not the owner"
        );
        farmConfig[_level] = FarmConfig(
            _level,
            _maxPower,
            _minPower,
            _requireQF,
            _requireFert,
            _rewardRate,
            _rewardJF,
            _inviteRate1,
            _inviteRate2
        );
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setEpoch(uint256 _epoch) public onlyOwner {
        epoch = _epoch;
    }

    function setStealRate(uint256 _stealRate) public onlyOwner {
        stealRate = _stealRate;
    }

    function setStealMaxNum(uint256 _stealMaxNum) public onlyOwner {
        stealMaxNum = _stealMaxNum;
    }

    function setBurnAddress(address _burnAddress) public onlyOwner {
        burnAddress = _burnAddress;
    }

    function setWhitePower(uint256 _whitePower) public onlyOwner {
        whitePower = _whitePower;
    }

    function setRewardMaxDay(uint256 _rewardMaxDay) public onlyOwner {
        rewardMaxDay = _rewardMaxDay;
    }

    function setBurnFeeRate(
        uint256 _burnRate,
        uint256 _marketRate,
        uint256 _inviteRate1,
        uint256 _inviteRate2
    ) public onlyOwner {
        require(
            _burnRate + _inviteRate1 + _inviteRate2 + _marketRate == 100,
            "sum is not 100"
        );
        burnFee = _burnRate;
        marketFee = _marketRate;
        burnInvite1 = _inviteRate1;
        burnInvite2 = _inviteRate2;
    }

    function setUnstakeFee(uint256 _unstakeFee) public onlyOwner {
        unstakeFee = _unstakeFee;
    }

    function setUnstakeEpoch(uint256 _unstakeEpoch) public onlyOwner {
        unstakeEpoch = _unstakeEpoch;
    }

    function setGameAddress(
        address _depositAddress,
        address _stakeAddress,
        address _marketAddress,
        address _qfAddress,
        address _jfAddress,
        address _fertAddress,
        address _nftAddress
    ) public onlyOwner {
        depositAddress = _depositAddress;
        stakedAddress = _stakeAddress;
        marketAddress = _marketAddress;
        qfAddress = _qfAddress;
        jfAddress = _jfAddress;
        fertAddress = _fertAddress;
        nftAddress = _nftAddress;
    }

    function getOwnerGames(address account)
        public
        view
        returns (GameInfo[] memory games)
    {
        if (registerUser[account] > 0) {
            games[0] = gameInfo[registerUser[account]];
        }

        uint256 num = INFT(nftAddress).balanceOf(account);
        for (uint256 i = 0; i <= num; i++) {
            uint256 _tokenId = INFT(nftAddress).tokenOfOwnerByIndex(account, i);
            games[games.length] = gameInfo[_tokenId];
        }
        return games;
    }

    function getUserGame(address account)
        public
        view
        returns (UserInfo memory user, GameInfo memory game)
    {
        user = userInfo[account];
        game = gameInfo[user.id];
        return (user, game);
    }

    // 升级游戏
    function upgradeGame(uint256 _tokenId) public {
        require(_tokenId > 0, "tokenId is not valid");
        require(!gameUpgrade[_tokenId], "game is upgraded");
        OldGameInfo memory game = IGAME(upgradeAddress).gameInfo(_tokenId);
        require(
            game.id > 0 && game.master != address(0) && game.status,
            "game is not valid"
        );

        gameUpgrade[_tokenId] = true;
        uint256 lv = game.level;

        uint256 newTokenId = INFT(nftAddress).mintToCaller(game.master, "");
        uint256 newLevel = 1;
        if (lv > 24) {
            newLevel = 2;
        }

        gameInfo[newTokenId] = GameInfo({
            id: newTokenId,
            status: false,
            master: address(0),
            level: newLevel,
            lastHarvestAt: 0,
            steal: 0
        });
        emit UpgradedGame(game.master, _tokenId, newTokenId);
    }

    // 注册游戏
    function registerGame() public {
        require(registerUser[msg.sender] == 0, "user is registered");
        uint256 newTokenId = INFT(nftAddress).mintToCaller(tempOwner, "");
        registerUser[msg.sender] = newTokenId;
        gameInfo[newTokenId] = GameInfo({
            id: newTokenId,
            status: false,
            master: address(0),
            level: 0,
            lastHarvestAt: 0,
            steal: 0
        });
    }

    // 注册并开始游戏
    function registerStart() public {
        registerGame();
        require(registerUser[msg.sender] > 0, "user is not registered");
        startGame(registerUser[msg.sender]);
    }

    // 开始游戏
    function startGame(uint256 _tokenId) public {
        UserInfo storage user = userInfo[msg.sender];
        require(!user.status, "already start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(!game.status, "game is already started");

        if (game.level > 0) {
            INFT(nftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId
            );
        } else {
            require(
                registerUser[msg.sender] == _tokenId,
                "tokenId is not valid"
            );
        }

        game.status = true; //激活
        game.master = msg.sender; //管理者
        user.level = game.level;
        user.status = true;
        user.id = _tokenId;
        game.lastHarvestAt = block.timestamp;
        game.steal = 0;
        totalUsers += 1;

        emit StartGame(msg.sender, _tokenId);
    }

    // 关闭游戏
    function gameOver() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.status, "game is not start");
        uint256 _tokenId = user.id;
        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");

        if (game.level > 0) {
            INFT(nftAddress).safeTransferFrom(
                address(this),
                msg.sender,
                _tokenId
            );
        }

        game.status = false; //关闭
        game.master = address(0); //管理者
        user.status = false;
        user.id = 0;
        totalUsers -= 1;

        emit GameOver(msg.sender, _tokenId);
    }

    // 升级
    function upgrade() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.status, "game is not started");
        GameInfo storage game = gameInfo[user.id];
        require(game.status, "game is not started");
        uint256 nextLv = game.level + 1;
        FarmConfig memory nextFarm = farmConfig[nextLv];
        require(
            nextFarm.rewardRate > 0 && nextFarm.maxPower > 0,
            "game level is max"
        );

        if (nextFarm.requireQF > 0) {
            uint256 requireQF = nextFarm.requireQF;
            uint256 burnQf = (requireQF * burnFee) / 100;
            uint256 marketQf = requireQF - burnQf;

            address inviter1 = invite[msg.sender];
            if (inviter1 != address(0) && burnInvite1 > 0) {
                uint256 inviterQf = (requireQF * burnInvite1) / 100;
                marketQf -= inviterQf;
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    msg.sender,
                    inviter1,
                    inviterQf
                );
            }
            address inviter2 = invite[inviter1];
            if (inviter2 != address(0) && burnInvite2 > 0) {
                uint256 inviterQf = (requireQF * burnInvite2) / 100;
                marketQf -= inviterQf;
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    msg.sender,
                    inviter2,
                    inviterQf
                );
            }
            if (burnQf > 0) {
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    msg.sender,
                    burnAddress,
                    burnQf
                );
            }
            if (marketQf > 0) {
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    msg.sender,
                    marketAddress,
                    marketQf
                );
            }
        }

        if (nextFarm.requireFert > 0) {
            TransferHelper.safeTransferFrom(
                fertAddress,
                msg.sender,
                burnAddress,
                nextFarm.requireFert
            );
        }

        uint256 newTokenId = INFT(nftAddress).mintToCaller(address(this), "");
        gameInfo[newTokenId] = GameInfo({
            id: newTokenId,
            status: true,
            master: msg.sender,
            level: nextLv,
            lastHarvestAt: game.lastHarvestAt,
            steal: game.steal
        });
        game.master = address(0); //管理者
        game.status = false; //关闭
        user.id = newTokenId;
        user.level = nextLv;

        emit Upgrade(msg.sender, newTokenId, game.level);
    }

    // 收获
    function harvest() public {
        UserInfo memory user = userInfo[msg.sender];
        require(user.status, "game is not started");
        GameInfo memory game = gameInfo[user.id];
        require(game.status, "game is not started");
        require(
            block.timestamp > game.lastHarvestAt + epoch,
            "nextHarvestAt error"
        );
        uint256 reward = rewardAmount(msg.sender);
        require(reward > 0, "reward is not valid");

        _harvest(msg.sender, reward);
    }

    function _harvest(address account, uint256 reward) private {
        uint256 _days = rewardDays(account);
        if (reward > 0 && _days > 0) {
            UserInfo storage user = userInfo[account];
            GameInfo storage game = gameInfo[user.id];
            FarmConfig memory farm = farmConfig[game.level];

            uint256 stealReward = (reward * game.steal * stealRate) / 100;
            reward = reward * _days - stealReward;
            game.lastHarvestAt = block.timestamp;
            game.steal = 0;
            TransferHelper.safeTransferFrom(
                qfAddress,
                depositAddress,
                account,
                reward
            );

            IJIFEN(jfAddress).mint(
                account,
                _days * farmConfig[game.level].rewardJF
            );

            address inviter1 = invite[account];
            if (inviter1 != address(0) && farm.inviteReward1 > 0) {
                uint256 reward1 = (reward * farm.inviteReward1) / 100;
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    depositAddress,
                    inviter1,
                    reward1
                );
            }
            address inviter2 = invite[inviter1];
            if (inviter2 != address(0) && farm.inviteReward2 > 0) {
                uint256 reward2 = (reward * farm.inviteReward2) / 100;
                TransferHelper.safeTransferFrom(
                    qfAddress,
                    depositAddress,
                    inviter1,
                    reward2
                );
            }

            user.userReward += reward;
            totalReward += reward;
            emit Harvest(account, reward);
        }
    }

    // 偷菜
    function steal(uint256 _tokenId) public {
        require(stealRate > 0, "stealRate is not valid");

        UserInfo storage user = userInfo[msg.sender];
        require(user.status, "master game is not started");
        require(user.id != _tokenId, "can not steal yourself");

        GameInfo storage game = gameInfo[_tokenId];

        require(game.status, "game is not started");
        require(game.steal < stealMaxNum, "steal is max");
        require(user.level >= game.level, "game level is not enough");

        uint256 reward = rewardAmount(game.master);
        require(reward > 0, "reward is not valid");

        game.steal += 1;
        reward = (reward * stealRate) / 100;
        user.userReward += reward;
        totalReward += reward;

        TransferHelper.safeTransferFrom(
            qfAddress,
            depositAddress,
            msg.sender,
            reward
        );

        emit Steal(msg.sender, game.master, reward);
    }

    // 质押
    function stake(uint256 amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.status, "game is not started");
        GameInfo storage game = gameInfo[user.id];
        require(game.status, "game is not started");
        uint256 maxPower = farmConfig[user.level].maxPower;
        require(user.userPower + amount <= maxPower, "max power is not valid");

        uint256 reward = rewardAmount(msg.sender);
        if (reward > 0) {
            _harvest(msg.sender, reward);
        }

        TransferHelper.safeTransferFrom(
            qfAddress,
            msg.sender,
            stakedAddress,
            amount
        );

        game.lastHarvestAt = block.timestamp;
        game.steal = 0;
        user.userPower += amount;
        user.lastStakedAt = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    // 解押
    function unstake(uint256 amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.userPower >= amount, "power is not enough");
        uint256 reward = rewardAmount(msg.sender);
        if (reward > 0) {
            _harvest(msg.sender, reward);
        }
        user.userPower -= amount;
        uint256 fee = 0;
        if (block.timestamp - user.lastStakedAt < unstakeEpoch) {
            fee = (amount * unstakeFee) / 100;
            TransferHelper.safeTransferFrom(
                qfAddress,
                stakedAddress,
                marketAddress,
                fee
            );
        }
        TransferHelper.safeTransferFrom(
            qfAddress,
            stakedAddress,
            msg.sender,
            amount - fee
        );
        emit UnStaked(msg.sender, amount);
    }

    // 奖励
    function rewardAmount(address _account) public view returns (uint256) {
        UserInfo memory user = userInfo[_account];
        GameInfo memory game = gameInfo[user.id];
        if (block.timestamp > game.lastHarvestAt + epoch) {
            uint256 _power = user.userPower;
            // 是否超过最小算力
            uint256 minPower = farmConfig[user.level].minPower;

            if (user.status && _power >= minPower) {
                if (user.level == 0) {
                    _power = whitePower;
                } else {
                    // 是否超过最大算力
                    uint256 maxPower = farmConfig[user.level].maxPower;
                    if (_power > maxPower) {
                        _power = maxPower;
                    }
                }
                return (_power * farmConfig[user.level].rewardRate) / 10000;
            }
        }

        return 0;
    }

    //奖励累计周期次数
    function rewardDays(address account) public view returns (uint256) {
        UserInfo memory user = userInfo[account];
        GameInfo memory game = gameInfo[user.id];
        uint256 _days = 0;
        if (block.timestamp > game.lastHarvestAt + epoch) {
            _days = (block.timestamp - game.lastHarvestAt) / epoch;

            if (_days > rewardMaxDay) {
                _days = rewardMaxDay;
            }

            if (game.lastHarvestAt == 0) {
                _days = 1;
            }
        }
        return _days;
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) public onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    // 绑定邀请人
    function setInviter(address inviter_) external virtual {
        require(invite[msg.sender] == address(0));
        require(msg.sender != inviter_);
        // 上级必须已经绑定过邀请人或者绑定管理员帐号
        require(
            inviter_ == owner || invite[inviter_] != address(0),
            "inviter must be binded"
        );

        invite[msg.sender] = inviter_;
        inviteCount[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
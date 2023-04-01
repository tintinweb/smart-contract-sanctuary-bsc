/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
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
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
interface ISwapPair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface INFT is IERC721 {
    struct Card {
        bool isValid;
        uint force;
        uint level;
        uint lastTime;
        address author;
    }
    function levelCount(uint256 level) external view returns (uint256);
    function levelValid(uint256 level) external view returns (uint256);
    function levelForce(uint256 level) external view returns (uint256);
    function getCard(uint256 tokenId) external view returns (Card memory);
    function burn(uint256 tokenId) external;
    function mint(address to, uint256 level) external returns (uint256);
    function mintUpByTokenId(
        address to,
        uint256 level,
        uint256 tokenId
    ) external returns (uint256);
    function changeForce(uint tokenId, uint force, bool isAdd) external;
    function changeLastTime(uint tokenId, uint lastTime) external;
}
contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
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
contract Manager is Ownable {
    address public manager;
    modifier onlyManager() {
        require(
            owner() == _msgSender() || manager == _msgSender(),
            "Ownable: Not Manager"
        );
        _;
    }
    function setManager(address account) public virtual onlyManager {
        manager = account;
    }
}
contract MDPVP is Manager {
    struct UserInfo {
        bool isExist;
        uint amount;
        uint balance;
        uint rewardPvpSuccess;
        uint rewardPvpFail;
        uint rewardBoss;
        uint rewardInvite;
        uint bossLastTime;
        uint addRate;
        uint addLastTime;
        address refer;
    }
    struct WalletInfo {
        uint balance;
        uint totalRecharge;
        uint totalTransfer;
        uint totalWithdraw;
        uint buyBalance;
        uint buyTotal;
        uint upBalance;
        uint upTotal;
        uint burnBalance;
        uint burnTotal;
        uint resetTotal;
    }
    struct TeamInfo {
        uint256 invites;
        uint256 teamUser;
        uint256 teamForce;
    }
    uint256 public userTotal;
    mapping(address => UserInfo) public users;
    mapping(address => WalletInfo) public userWallets;
    mapping(address => TeamInfo) public teams;
    mapping(uint256 => address) public userAdds;
    mapping(address => uint[]) public userNFTs;
    mapping(address => mapping(uint256 => address)) public userInvites;
    mapping(address => uint256) public userInviteTotals;
    mapping(address => bool) public isBlackList;
    uint256 public totalWithdraw;
    uint256 public totalDeposit;
    uint256 public totalMining;
    uint256 public totalBurn;
    uint256 public totalRecharge;
    uint private _algebra = 2;
    uint private _feeRate = 10;
    uint private _pvpTime = 86400;
    uint private _pvpFee = 400e18;
    uint private _bossTime = 86400;
    uint private _bossFee = 2000e18;
    uint private _addNFTMax = 3;
    uint private _nftResetFee = 1000e18;
    uint private _unEmbedTime = 86400 * 3;
    uint[3] private _eggPrices = [48e18, 60e18, 72e18];
    uint[6] private _oneRates = [560, 250, 80, 50, 40, 20];
    uint[6] private _twoRates = [500, 260, 90, 60, 50, 40];
    uint[6] private _threeRates = [430, 270, 100, 70, 70, 60];
    uint[3] private _pvpRates = [1000, 600, 300];
    uint[3] private _pvpRewardMin = [800e18, 1000e18, 1400e18];
    uint[3] private _pvpRewardMax = [1000e18, 1400e18, 2000e18];
    uint[3] private _pvpRewardFail = [800e18, 640e18, 500e18];
    uint[19] private _pveRewards;
    uint[2] private _inviteRates = [100, 50];
    uint[3] private _addNFTRates = [20, 40, 80];
    uint[3] private _addNFTIdMin = [1901, 2851, 2951];
    uint[3] private _addNFTIdMax = [2850, 2950, 3000];
    uint[5] private _nftUpRates = [600, 500, 400, 300, 250];
    uint[5] private _nftUpFees = [
        4000e18,
        12000e18,
        18000e18,
        20000e18,
        25000e18
    ];
    uint[5] private _nftResetRates = [100, 50, 40, 20, 8];
    address private _market;
    address private _team;
    address private _feeTo;
    address private _burnMetaDoge;
    IERC20 private _USDT;
    IERC20 private _MetaDoge;
    INFT private _NFT;
    INFT private _DRCZS;
    event BindRefer(address account, address refer);
    event Actions(
        address account,
        uint category,
        uint tokenId,
        uint level,
        uint amount,
        uint total,
        uint state,
        uint seed
    );
    event Withdraw(
        address account,
        uint256 category,
        uint256 amount,
        uint256 surplus
    );
    constructor() {
        manager = 0x38c550aAAa1Ea08117F5F5548A97885728C0DFA7;
        _market = 0x38c550aAAa1Ea08117F5F5548A97885728C0DFA7;
        _team = 0x38c550aAAa1Ea08117F5F5548A97885728C0DFA7;
        _feeTo = 0x38c550aAAa1Ea08117F5F5548A97885728C0DFA7;
        _burnMetaDoge = 0x000000000000000000000000000000000000dEaD;
        _NFT = INFT(0x83AC64c05aD3c270e6dfA764912FFA8154549385);
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _MetaDoge = IERC20(0xf3B185ab60128E4C08008Fd90C3F1F01f4B78d50);
        _DRCZS = INFT(0xf553C4045C3f14af952BF4d9ddb340c82bc2DCD8);
        users[0x38c550aAAa1Ea08117F5F5548A97885728C0DFA7].isExist = true;
        _pveRewards = [
            3200e18,
            3400e18,
            3600e18,
            4000e18,
            5200e18,
            6000e18,
            6800e18,
            8000e18,
            9600e18,
            12000e18,
            15000e18,
            18000e18,
            20000e18,
            24000e18,
            29000e18,
            36000e18,
            48000e18,
            60000e18,
            80000e18
        ];
    }
    modifier checkUser() {
        require(users[msg.sender].isExist, "User Not Exist");
        _;
    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function withdrawToken(IERC20 token, uint256 amount) public onlyManager {
        token.transfer(msg.sender, amount);
    }
    function withdrawNFT(IERC721 token, uint256 tokenId) public onlyManager {
        token.transferFrom(address(this), msg.sender, tokenId);
    }
    function setTokenAdd(uint256 category, address data) public onlyManager {
        if (category == 1) _market = (data);
        if (category == 2) _team = (data);
        if (category == 3) _feeTo = (data);
        if (category == 4) _burnMetaDoge = (data);
        if (category == 5) _USDT = IERC20(data);
        if (category == 6) _MetaDoge = IERC20(data);
        if (category == 7) _NFT = INFT(data);
        if (category == 8) _DRCZS = INFT(data);
    }
    function setConfig(uint256 category, uint256 data) public onlyManager {
        if (category == 1) _algebra = data;
        if (category == 2) _feeRate = data;
        if (category == 3) _pvpTime = data;
        if (category == 4) _pvpFee = data;
        if (category == 5) _bossTime = data;
        if (category == 6) _bossFee = data;
        if (category == 7) _addNFTMax = data;
        if (category == 8) _nftResetFee = data;
        if (category == 9) _unEmbedTime = data;
    }
    function setConfigMulti(
        uint256 category,
        uint256[] memory data
    ) public onlyManager {
        for (uint256 i = 0; i < data.length; i++) {
            if (category == 1 && i < _eggPrices.length) _eggPrices[i] = data[i];
            if (category == 2 && i < _oneRates.length) _oneRates[i] = data[i];
            if (category == 3 && i < _twoRates.length) _twoRates[i] = data[i];
            if (category == 4 && i < _threeRates.length)
                _threeRates[i] = data[i];
            if (category == 5 && i < _pvpRates.length) _pvpRates[i] = data[i];
            if (category == 6 && i < _pvpRewardMin.length)
                _pvpRewardMin[i] = data[i];
            if (category == 7 && i < _pvpRewardMax.length)
                _pvpRewardMax[i] = data[i];
            if (category == 8 && i < _pvpRewardFail.length)
                _pvpRewardFail[i] = data[i];
            if (category == 9 && i < _pveRewards.length)
                _pveRewards[i] = data[i];
            if (category == 10 && i < _inviteRates.length)
                _inviteRates[i] = data[i];
            if (category == 11 && i < _addNFTRates.length)
                _addNFTRates[i] = data[i];
            if (category == 12 && i < _addNFTIdMin.length)
                _addNFTIdMin[i] = data[i];
            if (category == 13 && i < _addNFTIdMax.length)
                _addNFTIdMax[i] = data[i];
            if (category == 14 && i < _nftUpRates.length)
                _nftUpRates[i] = data[i];
            if (category == 15 && i < _nftUpFees.length)
                _nftUpFees[i] = data[i];
            if (category == 16 && i < _nftResetRates.length)
                _nftResetRates[i] = data[i];
        }
    }
    function setIsBlackList(address account, bool data) public onlyManager {
        isBlackList[account] = data;
    }
    function getConfig()
        public
        view
        returns (
            uint algebra,
            uint feeRate,
            uint pvpTime,
            uint pvpFee,
            uint bossTime,
            uint bossFee,
            uint addNFTMax,
            uint nftResetFee,
            uint unEmbedTime
        )
    {
        algebra = _algebra;
        feeRate = _feeRate;
        pvpTime = _pvpTime;
        pvpFee = _pvpFee;
        bossTime = _bossTime;
        bossFee = _bossFee;
        addNFTMax = _addNFTMax;
        nftResetFee = _nftResetFee;
        unEmbedTime = _unEmbedTime;
    }
    function getConfigMulti()
        public
        view
        returns (
            uint[3] memory eggPrices,
            uint[6] memory oneRates,
            uint[6] memory twoRates,
            uint[6] memory threeRates,
            uint[3] memory pvpRates,
            uint[3] memory pvpRewardMin,
            uint[3] memory pvpRewardMax,
            uint[3] memory pvpRewardFail,
            uint[19] memory pveRewards
        )
    {
        eggPrices = _eggPrices;
        oneRates = _oneRates;
        twoRates = _twoRates;
        threeRates = _threeRates;
        pvpRates = _pvpRates;
        pvpRewardMin = _pvpRewardMin;
        pvpRewardMax = _pvpRewardMax;
        pvpRewardFail = _pvpRewardFail;
        pveRewards = _pveRewards;
    }
    function getConfigMulti2()
        public
        view
        returns (
            uint[2] memory inviteRates,
            uint[3] memory addNFTRates,
            uint[3] memory addNFTIdMin,
            uint[3] memory addNFTIdMax,
            uint[5] memory nftUpRates,
            uint[5] memory nftUpFees,
            uint[5] memory nftResetRates
        )
    {
        inviteRates = _inviteRates;
        addNFTRates = _addNFTRates;
        addNFTIdMin = _addNFTIdMin;
        addNFTIdMax = _addNFTIdMax;
        nftUpRates = _nftUpRates;
        nftUpFees = _nftUpFees;
        nftResetRates = _nftResetRates;
    }
    function getTokenAdd()
        public
        view
        returns (
            address market,
            address team,
            address feeTo,
            address burnMetaDoge,
            address usdt,
            address metaDoge,
            address nft,
            address drczs
        )
    {
        market = _market;
        team = _team;
        feeTo = _feeTo;
        burnMetaDoge = _burnMetaDoge;
        usdt = address(_USDT);
        metaDoge = address(_MetaDoge);
        nft = address(_NFT);
        drczs = address(_DRCZS);
    }
    function getInvitesInfo(
        address account
    )
        public
        view
        returns (
            address[] memory invites,
            UserInfo[] memory infos,
            TeamInfo[] memory teamInfos
        )
    {
        invites = new address[](userInviteTotals[account]);
        infos = new UserInfo[](userInviteTotals[account]);
        teamInfos = new TeamInfo[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
            infos[i] = users[invites[i]];
            teamInfos[i] = teams[invites[i]];
        }
    }
    function getUserNFTS(
        address account
    ) public view returns (uint[] memory ids) {
        ids = new uint[](userNFTs[account].length);
        for (uint i = 0; i < userNFTs[account].length; i++) {
            ids[i] = userNFTs[account][i];
        }
    }
    function register(address refer) public {
        address account = msg.sender;
        require(users[refer].isExist, "Refer Not Exist");
        require(!users[account].isExist, "Has Exist");
        UserInfo storage user = users[account];
        user.isExist = true;
        userTotal++;
        userAdds[userTotal] = account;
        user.refer = refer;
        userInviteTotals[refer]++;
        userInvites[refer][userInviteTotals[refer]] = account;
        emit BindRefer(account, refer);
        address parent = refer;
        for (uint256 i = 0; i < _algebra; i++) {
            if (parent == address(0)) break;
            teams[parent].teamUser++;
            parent = users[parent].refer;
        }
    }
    function buyEgg(uint level, uint times) public checkUser {
        require(level < 3, "Level Error");
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        require(
            userWallets[account].balance > _eggPrices[level] * times,
            "Balance Insufficient"
        );
        userWallets[account].balance -= _eggPrices[level] * times;
        userWallets[account].buyBalance += _eggPrices[level] * times;
        userWallets[account].buyTotal += _eggPrices[level] * times;
        emit Withdraw(
            account,
            5,
            _eggPrices[level] * times,
            userWallets[account].balance
        );
        uint tokenId;
        uint nftLevel;
        for (uint j = 0; j < times; j++) {
            uint seedTotal;
            uint seed = _randomWithSeed(1000, _random(10000000000) * (j + 2));
            for (uint i = 0; i < 6; i++) {
                if (level == 0) seedTotal += _oneRates[i];
                else if (level == 1) seedTotal += _twoRates[i];
                else if (level == 2) seedTotal += _threeRates[i];
                if (seed < seedTotal) {
                    nftLevel = i + 1;
                    break;
                }
            }
            tokenId = _NFT.mint(account, nftLevel);
            emit Actions(
                account,
                1,
                tokenId,
                nftLevel,
                level,
                _eggPrices[level],
                times,
                seed
            );
        }
        if (users[account].amount == 0 && users[account].refer != address(0)) {
            teams[users[account].refer].invites++;
        }
        users[account].amount += _eggPrices[level] * times;
        totalDeposit += _eggPrices[level] * times;
        _handleTeamForce(account, 1, _eggPrices[level] * times, true);
    }
    function pvp(uint tokenId, uint level) public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        require(_NFT.ownerOf(tokenId) == account, "Not Owner");
        INFT.Card memory nft = _NFT.getCard(tokenId);
        require(nft.lastTime < block.timestamp, "Sleeping");
        require(nft.force > 0, "No Force");
        require(userWallets[account].balance > _pvpFee, "Balance Insufficient");
        userWallets[account].balance -= _pvpFee;
        userWallets[account].burnBalance += _pvpFee;
        userWallets[account].burnTotal += _pvpFee;
        emit Withdraw(account, 6, _pvpFee, userWallets[account].balance);
        totalBurn += _pvpFee;
        uint reward;
        uint force;
        uint seed = _randomWithSeed(1000, _random(76451 * block.timestamp));
        if (seed < _pvpRates[level]) {
            uint rate = _randomWithSeed(100, _random(458247 * block.timestamp));
            reward =
                _pvpRewardMin[level] +
                (((_pvpRewardMax[level] - _pvpRewardMin[level]) * rate) / 100);
            force = reward / 1e18;
            reward = (reward * (1000 + users[account].addRate)) / 1000;
            users[account].rewardPvpSuccess += reward;
            users[account].balance += reward;
        } else {
            reward = _pvpRewardFail[level];
            force = reward / 1e18;
            reward = (reward * (1000 + users[account].addRate)) / 1000;
            users[account].rewardPvpFail += reward;
            users[account].balance += reward;
        }
        {
            if (nft.force > force) {
                _NFT.changeForce(tokenId, force, false);
            } else {
                _NFT.changeForce(tokenId, nft.force, false);
            }
            _NFT.changeLastTime(tokenId, block.timestamp + _pvpTime);
        }
        totalMining += reward;
        emit Actions(
            account,
            2,
            tokenId,
            level,
            reward,
            force,
            seed < _pvpRates[level] ? 1 : 0,
            seed
        );
        _sendInviteReward(account, reward);
    }
    function pve(uint[] calldata tokenIds) public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        require(
            users[account].bossLastTime + _bossTime < block.timestamp,
            "Sleeping"
        );
        require(tokenIds.length == 4, "tokenIds must be 4 integers");
        require(
            userWallets[account].balance > _bossFee,
            "Balance Insufficient"
        );
        userWallets[account].balance -= _bossFee;
        userWallets[account].burnBalance += _bossFee;
        userWallets[account].burnTotal += _bossFee;
        emit Withdraw(account, 7, _bossFee, userWallets[account].balance);
        totalBurn += _bossFee;
        uint bossLeve;
        for (uint i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            require(_NFT.ownerOf(tokenId) == account, "Not Owner");
            INFT.Card memory nft = _NFT.getCard(tokenId);
            require(nft.lastTime < block.timestamp, "Sleep");
            require(nft.force > 0, "No Force");
            bossLeve += nft.level;
        }
        require(bossLeve >= 6, "Level must be at least 6");
        uint reward = _pveRewards[bossLeve - 6];
        uint force = reward / 2 / 4 / 1e18;
        reward = (reward * (1000 + users[account].addRate)) / 1000;
        users[account].balance += reward;
        users[account].rewardBoss += reward;
        users[account].bossLastTime = block.timestamp;
        {
            for (uint i = 0; i < tokenIds.length; i++) {
                uint tokenId = tokenIds[i];
                INFT.Card memory nft = _NFT.getCard(tokenId);
                if (nft.force > force) {
                    _NFT.changeForce(tokenId, force, false);
                } else {
                    _NFT.changeForce(tokenId, nft.force, false);
                }
                _NFT.changeLastTime(tokenId, block.timestamp + _pvpTime);
            }
        }
        totalMining += reward;
        emit Actions(
            account,
            3,
            tokenIds[0],
            tokenIds[1],
            tokenIds[2],
            tokenIds[3],
            bossLeve,
            reward
        );
        _sendInviteReward(account, reward);
    }
    function updateNFT(uint tokenId) public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        require(_NFT.ownerOf(tokenId) == account, "Not Owner");
        _NFT.safeTransferFrom(account, address(this), tokenId);
        INFT.Card memory nft = _NFT.getCard(tokenId);
        require(nft.level < 6, "Has Max Level");
        require(
            userWallets[account].balance > _nftUpFees[nft.level - 1],
            "Balance Insufficient"
        );
        userWallets[account].balance -= _nftUpFees[nft.level - 1];
        userWallets[account].upBalance += _nftUpFees[nft.level - 1];
        userWallets[account].upTotal += _nftUpFees[nft.level - 1];
        emit Withdraw(
            account,
            8,
            _nftUpFees[nft.level - 1],
            userWallets[account].balance
        );
        uint tokenIdNew;
        uint seed = _randomWithSeed(1000, _random(8765 * block.timestamp));
        if (seed < _nftUpRates[nft.level - 1]) {
            tokenIdNew = _NFT.mintUpByTokenId(account, nft.level + 1, tokenId);
            _NFT.burn(tokenId);
        } else {
            _NFT.safeTransferFrom(address(this), account, tokenId);
        }
        emit Actions(
            account,
            4,
            tokenId,
            nft.level,
            _nftUpFees[nft.level - 1],
            tokenIdNew,
            seed < _nftUpRates[nft.level - 1] ? 1 : 0,
            seed
        );
    }
    function resetNFT(uint tokenId) public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        require(_NFT.ownerOf(tokenId) == account, "Not Owner");
        _NFT.safeTransferFrom(account, address(this), tokenId);
        INFT.Card memory nft = _NFT.getCard(tokenId);
        require(nft.level < 6, "Has Max Level");
        require(
            userWallets[account].balance > _nftResetFee,
            "Balance Insufficient"
        );
        userWallets[account].balance -= _nftResetFee;
        userWallets[account].burnBalance += _nftResetFee;
        userWallets[account].burnTotal += _nftResetFee;
        userWallets[account].resetTotal += _nftResetFee;
        emit Withdraw(account, 9, _nftResetFee, userWallets[account].balance);
        totalBurn += _nftResetFee;
        uint tokenIdNew;
        uint seed = _randomWithSeed(1000, _random(795785 * block.timestamp));
        if (seed < _nftResetRates[nft.level - 1]) {
            tokenIdNew = _NFT.mintUpByTokenId(account, nft.level + 1, tokenId);
            _NFT.burn(tokenId);
        } else {
            _NFT.safeTransferFrom(address(this), account, tokenId);
        }
        emit Actions(
            account,
            5,
            tokenId,
            nft.level,
            _nftResetFee,
            tokenIdNew,
            seed < _nftResetRates[nft.level - 1] ? 1 : 0,
            seed
        );
    }
    function embedNFT(uint tokenId) public checkUser {
        address account = msg.sender;
        require(_DRCZS.ownerOf(tokenId) == account, "Not owner of token");
        require(userNFTs[account].length < _addNFTMax, "Over Max");
        uint level = 0;
        if (tokenId >= _addNFTIdMin[0] && tokenId <= _addNFTIdMax[0]) {
            level = 1;
        } else if (tokenId >= _addNFTIdMin[1] && tokenId <= _addNFTIdMax[1]) {
            level = 2;
        } else if (tokenId >= _addNFTIdMin[2] && tokenId <= _addNFTIdMax[2]) {
            level = 3;
        }
        require(level > 0, "TokenId not matching");
        _DRCZS.safeTransferFrom(account, address(this), tokenId);
        userNFTs[account].push(tokenId);
        users[account].addRate += _addNFTRates[level - 1];
        users[account].addLastTime = block.timestamp;
        emit Actions(
            account,
            6,
            tokenId,
            level,
            _addNFTRates[level - 1],
            users[account].addRate,
            users[account].addLastTime,
            0
        );
    }
    function unEmbedNFT(uint tokenId) public checkUser {
        address account = msg.sender;
        require(
            users[account].addLastTime + _unEmbedTime <= block.timestamp,
            "Unembed Time"
        );
        uint level = 0;
        if (tokenId >= _addNFTIdMin[0] && tokenId <= _addNFTIdMax[0]) {
            level = 1;
        } else if (tokenId >= _addNFTIdMin[1] && tokenId <= _addNFTIdMax[1]) {
            level = 2;
        } else if (tokenId >= _addNFTIdMin[2] && tokenId <= _addNFTIdMax[2]) {
            level = 3;
        }
        require(level > 0, "TokenId not matching");
        for (uint index = 0; index < userNFTs[account].length; index++) {
            if (userNFTs[account][index] == tokenId) {
                for (uint i = index; i < userNFTs[account].length - 1; i++) {
                    userNFTs[account][i] = userNFTs[account][i + 1];
                }
                userNFTs[account].pop();
                break;
            }
        }
        _DRCZS.safeTransferFrom(address(this), account, tokenId);
        if (users[account].addRate >= _addNFTRates[level - 1]) {
            users[account].addRate -= _addNFTRates[level - 1];
        } else users[account].addRate = 0;
        emit Actions(
            account,
            7,
            tokenId,
            level,
            _addNFTRates[level - 1],
            users[account].addRate,
            users[account].addLastTime,
            0
        );
    }
    function withdraw() public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        UserInfo storage user = users[account];
        uint amount = user.balance;
        user.balance = 0;
        uint256 fee = (amount * _feeRate) / 1000;
        _MetaDoge.transfer(_feeTo, fee);
        _MetaDoge.transfer(account, amount - fee);
        emit Withdraw(account, 1, amount, user.balance);
        totalWithdraw += amount;
        emit Withdraw(account, 1, amount, 0);
        handleUserWallet(account);
    }
    function transBalance() public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        if (users[account].balance > 0) {
            userWallets[account].balance += users[account].balance;
            userWallets[account].totalTransfer += users[account].balance;
            emit Withdraw(
                account,
                2,
                users[account].balance,
                userWallets[account].balance
            );
            users[account].balance = 0;
        }
        handleUserWallet(account);
    }
    function recharge(uint amount) public checkUser {
        address account = msg.sender;
        _MetaDoge.transferFrom(account, address(this), amount);
        userWallets[account].balance += amount;
        userWallets[account].totalRecharge += amount;
        emit Withdraw(account, 3, amount, userWallets[account].balance);
        handleUserWallet(account);
        totalRecharge += amount;
    }
    function withdrawBalance() public checkUser {
        address account = msg.sender;
        require(!isBlackList[account], "Fail: You are banned");
        if (userWallets[account].balance > 0) {
            _MetaDoge.transfer(account, userWallets[account].balance);
            userWallets[account].totalWithdraw += userWallets[account].balance;
            emit Withdraw(account, 4, userWallets[account].balance, 0);
            userWallets[account].balance = 0;
        }
        handleUserWallet(account);
    }
    function handleUserWallet(address account) public {
        if (userWallets[account].burnBalance > 0) {
            _MetaDoge.transfer(_burnMetaDoge, userWallets[account].burnBalance);
            userWallets[account].burnBalance = 0;
        }
        if (userWallets[account].buyBalance > 0) {
            _MetaDoge.transfer(_market, userWallets[account].buyBalance);
            userWallets[account].buyBalance = 0;
        }
        if (userWallets[account].upBalance > 0) {
            _MetaDoge.transfer(_team, userWallets[account].upBalance);
            userWallets[account].upBalance = 0;
        }
    }
    function _handleTeamForce(
        address account,
        uint256 category,
        uint256 force,
        bool isAdd
    ) private {
        address refer = users[account].refer;
        for (uint256 i = 0; i < _algebra; i++) {
            if (refer == address(0)) break;
            if (isAdd && category == 1) teams[refer].teamForce += force;
            refer = users[refer].refer;
        }
    }
    function _sendInviteReward(address account, uint256 amount) private {
        address refer = users[account].refer;
        for (uint256 i = 0; i < 2; i++) {
            if (refer == address(0)) break;
            if (users[refer].isExist && i < _inviteRates.length) {
                UserInfo storage parent = users[refer];
                uint reward = (amount * _inviteRates[i]) / 1000;
                parent.balance += reward;
                parent.rewardInvite += reward;
                totalMining += reward;
            }
            refer = users[refer].refer;
        }
    }
    function _random(uint256 lenth) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, tx.origin)
                )
            ) % lenth;
    }
    function _randomWithSeed(
        uint256 lenth,
        uint256 seed
    ) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        seed,
                        tx.origin
                    )
                )
            ) % lenth;
    }
}
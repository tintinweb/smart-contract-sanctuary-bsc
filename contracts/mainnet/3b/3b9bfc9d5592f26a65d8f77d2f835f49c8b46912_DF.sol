/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint256);
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);
    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}

contract DF is IERC721Receiver {
    struct Tree {
        uint8 tType;  // 0,1,2,3,4,5
        uint32 num;   // 浇水次数
        uint32 timestamp;
        uint32 integral;
        uint256 amount;
        uint256 income;
        address account;
    }

    struct Forest {
        uint32 timestamp;
        uint32 remainTime;
        uint64 integral;
        uint256 pool;
        uint256 gold;
        uint256 sliver;
        uint256 community;
        uint256 foundation;
        uint256 dividend;
        uint256 bottom;
        uint256 green;
    }

    struct Reward {
        uint256 direct;
        uint256 union;
        uint256 pool;
        uint256 gold;
        uint256 dividend;
    }

    IERC20 mgf;
    IERC721Enumerable nft;
    Forest forest;

    address private owner;
    address private first;
    uint256 turn;
    mapping(address => bool) _unions;
    mapping(address => address) _superUser;
    mapping(address => Reward) _reward;
    mapping(address => mapping(uint256 => uint256[])) _userTreeIndex;
    mapping(address => mapping(uint256 => uint256)) _userWater;

    uint8[] integrals = [1, 6, 23, 120];
    uint16[] prices = [100, 500, 2000, 10000];
    uint256[] goldIndex;
    uint256[] sliverIndex;
    address[] allUnions;
    Tree[] allTree;


    event UnionReward(address from, address to, uint256 reward);
    event GoldReward(address[] adds, uint256[] rewards);
    event SliverReward(address[] adds, uint256[] rewards);
    event DividendReward(address[] adds, uint256[] rewards);
    event BuyTree(address indexed account, uint8 Type);

    constructor (address _mgf, address _nft, address _first) {
        mgf = IERC20(_mgf);
        nft = IERC721Enumerable(_nft);
        first = _first;
        owner = msg.sender;
        _unions[_first] = true;
    }

    modifier onlyActivate() {
        require(first == msg.sender || _superUser[msg.sender] != address(0), "Not activate");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    // 总积分，分红奖池，1小时奖池等
    function forestInfo() public view returns (Forest memory){
        return forest;
    }

    // 获取价格
    function priceOf(uint8 tType) public view returns (uint256){
        uint256 price = prices[tType] * 10 ** mgf.decimals() * (1000 + 5 * forest.integral / 1000) / 1000;
        return price;
    }

    // 游戏是否结束
    function ifEnd() public view returns (bool){
        if (forest.timestamp == 0) {
            return false;
        } else {
            return _timeUsed(forest.timestamp, block.timestamp) >= forest.remainTime;
        }
    }

    // 剩余时间
    function remainTime() public view returns (uint32){
        uint256 timeU = _timeUsed(forest.timestamp, block.timestamp);
        if (timeU > forest.remainTime) {
            return 0;
        } else {
            return forest.remainTime - uint32(timeU);
        }
    }

    // 用户是否激活
    function isActivate(address account) public view returns (bool){
        return _superUser[account] != address(0) || account == first;
    }

    // 用户是否工会节点
    function unionOf(address account) public view returns (bool){
        return _unions[account];
    }

    // 用户的树和积分
    function treeOf(address account) public view returns (Tree[] memory, uint32){
        uint256[] memory indexes = _userTreeIndex[account][turn];
        uint32 userIntegral;
        Tree[] memory tree = new Tree[](indexes.length);
        for (uint i = 0; i < indexes.length; i++) {
            userIntegral += allTree[indexes[i]].integral;
            tree[i] = allTree[indexes[i]];
        }
        return (tree, userIntegral);
    }

    // 用户的奖励余额
    function rewardOf(address account) public view returns (Reward memory){
        return _reward[account];
    }

    // 用户是否已浇水
    function waterOf(address account) public view returns (uint256){
        return _userWater[account][block.timestamp / 86400];
    }

    // 激活
    function activate(address superAddress) public {
        require(isActivate(superAddress), "Super address not activate");
        _superUser[msg.sender] = superAddress;
    }

    // 买树（0,1,2,3 四种树）
    function buyTree(uint8 tType) public onlyActivate {
        require(tType < 4, "Index error");
        require(ifEnd() == false, "Game end");
        uint256 amount = priceOf(tType);
        mgf.transferFrom(msg.sender, address(this), amount);
        amount = amount * 9 / 10;
        uint256 reward = _pushReward(msg.sender, amount);
        uint256 uReward = _unionReward(msg.sender, amount);
        forest.dividend += amount * 40 / 100;
        forest.pool += amount * 10 / 100;
        forest.gold += amount * 2 / 100;
        forest.sliver += amount * 1 / 100;
        forest.community += amount * 5 / 100;
        forest.bottom += amount * 10 / 100;
        forest.foundation += amount - reward - uReward - amount * 40 / 100 - amount * 10 / 100 - amount * 2 / 100 - amount / 100 - amount * 5 / 100 - amount * 10 / 100;
        forest.integral += uint64(integrals[tType]);
        if (forest.timestamp == 0) {
            forest.remainTime = 86400;
        } else {
            uint256 timeU = _timeUsed(forest.timestamp, block.timestamp);
            _updateTime(integrals[tType], timeU);
        }
        forest.timestamp = uint32(block.timestamp);
        // 添加树苗
        _addTree(msg.sender, amount, tType);
    }

    // 用户提取奖励 0:推荐奖，1：工会奖，2：终极大奖池，3：金银卡分红，4：每日分红
    function rewardTake(uint8 rType) public onlyActivate {
        require(rType <= 4, "Type error");
        uint256 amount;
        Reward memory userReward = _reward[msg.sender];
        if (rType == 0) {
            amount = userReward.direct;
        } else if (rType == 1) {
            amount = userReward.union;
        } else if (rType == 2) {
            amount = userReward.pool;
        } else if (rType == 3) {
            amount = userReward.gold;
        } else {
            amount = userReward.dividend;
        }
        if (amount < 0) {
            revert('No reward');
        }
        mgf.transfer(msg.sender, amount);
        if (rType == 0) {
            _reward[msg.sender].direct = 0;
        } else if (rType == 1) {
            _reward[msg.sender].union = 0;
        } else if (rType == 2) {
            _reward[msg.sender].pool = 0;
        } else if (rType == 3) {
            _reward[msg.sender].gold = 0;
        } else {
            _reward[msg.sender].dividend = 0;
        }
    }

    // 浇水
    function water() public onlyActivate returns (uint256){
        require(_userWater[msg.sender][block.timestamp / 86400] == 0, "Already watered");
        require(_userTreeIndex[msg.sender][turn].length > 0, "No tree");
        _userWater[msg.sender][block.timestamp / 86400]++;
        uint256[] memory indexes = _userTreeIndex[msg.sender][turn];
        for (uint i = 0; i < indexes.length; i++) {
            if (allTree[indexes[i]].num <= 1 && allTree[indexes[i]].timestamp / 86400 < block.timestamp / 86400) {
                allTree[indexes[i]].num += 1;
            }
        }

        uint256 rand = _rand(100);
        if (rand < 30 && nft.balanceOf(address(this)) > 0) {
            uint256 tokenId = nft.tokenOfOwnerByIndex(address(this), 0);
            nft.transferFrom(address(this), msg.sender, tokenId);
            return rand;
        }
        return 0;
    }

    // 推荐奖励
    function _pushReward(address account, uint256 amount) private returns (uint256) {
        address directSuper = _superUser[account];
        uint256 reward = 0;
        if (directSuper != address(0)) {
            _reward[directSuper].direct += uint96(amount * 10 / 100);
            reward += amount * 10 / 100;
            address indirectSuper = _superUser[directSuper];
            if (indirectSuper != address(0)) {
                _reward[indirectSuper].direct += amount * 5 / 100;
                reward += amount * 5 / 100;
            }
        }
        return reward;
    }

    // 工会奖励
    function _unionReward(address account, uint256 amount) private returns (uint256){
        address superUser = _superUser[account];
        uint256 uReward;
        while (superUser != address(0)) {
            if (_unions[superUser]) {
                uReward = amount * 5 / 100;
                _reward[superUser].union += uReward;
                emit UnionReward(account, superUser, uReward);
                return uReward;
            }
            superUser = _superUser[superUser];
        }
        return uReward;
    }

    // 添加树苗
    function _addTree(address account, uint256 amount, uint8 tType) private {
        uint256 m = _rand(100);
        uint32 _integral = integrals[tType];
        if (m < 10) {
            goldIndex.push(allTree.length);
            tType = 5;
        } else if (m < 40) {
            sliverIndex.push(allTree.length);
            tType = 4;
        }
        _userTreeIndex[account][turn].push(allTree.length);
        allTree.push(Tree(tType, uint32(0), uint32(block.timestamp), _integral, amount, 0, account));
        emit BuyTree(account, tType);
    }


    function _isSleep(uint256 blockTime) private pure returns (bool) {
        return (blockTime + 25200) % 86400 < 21600;
    }

    // 计算消耗的时间
    function _timeUsed(uint256 begin, uint256 end) private pure returns (uint256) {
        if (!_isSleep(begin) && !_isSleep(end)) {
            if ((begin + 25200) % 86400 <= (end + 25200) % 86400) {
                return (end - begin) - (end - begin) / 86400 * 21600;
            } else {
                return (end - begin) - (end - begin) / 86400 * 21600 - 21600;
            }
        } else {
            if (_isSleep(begin)) {
                begin = (begin + 25200) / 86400 * 86400 + 21600;
            }
            if (_isSleep(end)) {
                end = (end + 25200) / 86400 * 86400;
            }
            if (begin >= end) {
                return 0;
            } else {
                return (end - begin) - (end - begin) / 86400 * 21600;
            }
        }
    }

    // 更新剩余时间，时间增加幅度值在此修改
    function _updateTime(uint256 cont, uint256 timeUsed) private {
        uint64 totalCont = forest.integral;
        if (totalCont > 50000) {
            cont *= 30;
        } else if (totalCont > 20000) {
            cont *= 60;
        } else if (totalCont > 10000) {
            cont *= 300;
        } else {
            cont *= 600;
        }
        forest.remainTime = uint32(Math.min(forest.remainTime + cont - timeUsed, _getLimit()));
    }

    // 剩余时间上限
    function _getLimit() private view returns (uint256) {
        uint64 totalCont = forest.integral;
        if (totalCont > 50000) {
            return 86400;
        } else if (totalCont > 20000) {
            return 172800;
        } else if (totalCont > 10000) {
            return 345600;
        } else {
            return 691200;
        }
    }


    function _rand(uint256 k) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, allTree.length))) % k;
    }

    // ==

    // 所有工会节点
    function allUnion() public view returns (address[] memory){
        return allUnions;
    }


    function changeOwner(address account) public onlyOwner {
        require(account != address(0), "Wrong address");
        owner = account;
    }

    // 添加工会节点
    function addUnion(address[] memory accounts) public onlyOwner {
        require(accounts.length > 0, "Empty");
        for (uint i = 0; i < accounts.length; i++) {
            if (_unions[accounts[i]] == false && _superUser[accounts[i]] == first) {
                _unions[accounts[i]] = true;
                allUnions.push(accounts[i]);
            }
        }
    }

    // 提取社区奖励
    function communityTake(address account) public onlyOwner {
        require(account != address(0), "Wrong address");
        require(forest.community > 0, "No community");
        mgf.transfer(account, forest.community);
        forest.community = 0;
    }

    // 精英工会奖励
    function communityUnion(address[] memory accounts) public onlyOwner {
        require(accounts.length > 0 && accounts.length <= 10, "Empty");
        require(forest.community > 0, "No community");
        uint256 t = forest.community;
        uint256 firstAmount = forest.community * 30 / 100;
        mgf.transfer(accounts[0], firstAmount);
        t -= firstAmount;
        if (accounts.length > 1) {
            uint256 secondAmount = forest.community * 20 / 100;
            mgf.transfer(accounts[1], secondAmount);
            t -= secondAmount;
            if (accounts.length > 2) {
                uint256 thirdAmount = forest.community * 10 / 100;
                mgf.transfer(accounts[2], thirdAmount);
                t -= thirdAmount;
                if (accounts.length > 3) {
                    uint256 amount = t / (accounts.length - 3);
                    for (uint256 i = 3; i < accounts.length; i++) {
                        mgf.transfer(accounts[i], amount);
                    }
                }
            }
        }
        forest.community = 0;
    }

    // 提取基金会奖励
    function foundationTake(address account) public onlyOwner {
        require(account != address(0), "Wrong address");
        require(forest.foundation > 0, "No community");
        mgf.transfer(account, forest.foundation);
        forest.foundation = 0;
    }

    // 底池
    function bottomTake(address account) public onlyOwner {
        require(account != address(0), "Wrong address");
        require(forest.bottom > 0, "No bottom pool");
        mgf.transfer(account, forest.bottom);
        forest.bottom = 0;
    }

    // 金卡奖励
    function goldReward() public onlyOwner {
        if (forest.gold > 0) {
            (uint32 goldIntegral, uint32 len) = calGold();
            if (goldIntegral > 0) {
                address[] memory adds = new address[](len);
                uint256[] memory gains = new uint256[](len);
                Tree memory t;
                uint256 index;
                uint256 tGain;
                for (uint i = 0; i < goldIndex.length; i++) {
                    t = allTree[goldIndex[i]];
                    if (t.income < t.amount * 5 / 2) {
                        uint256 gain = t.integral * forest.gold / goldIntegral;
                        _reward[t.account].gold += gain;
                        allTree[goldIndex[i]].income += gain;
                        adds[index] = t.account;
                        gains[index] = gain;
                        index++;
                        tGain += gain;
                    }
                }
                forest.green += forest.gold - tGain;
                forest.gold = 0;
                emit GoldReward(adds, gains);
            }
        }
    }

    // 银卡奖励
    function sliverReward() public onlyOwner {
        if (forest.sliver > 0) {
            (uint32 sliverIntegral, uint32 len) = calSliver();
            if (sliverIntegral > 0) {
                address[] memory adds = new address[](len);
                uint256[] memory gains = new uint256[](len);
                Tree memory t;
                uint256 index;
                uint256 tGain;
                for (uint i = 0; i < sliverIndex.length; i++) {
                    t = allTree[sliverIndex[i]];
                    if (t.income < t.amount * 5 / 2) {
                        uint256 gain = t.integral * forest.sliver / sliverIntegral;
                        _reward[t.account].gold += gain;
                        allTree[sliverIndex[i]].income += gain;
                        adds[index] = t.account;
                        gains[index] = gain;
                        index++;
                        tGain += gain;
                    }
                }
                forest.green += forest.sliver - tGain;
                forest.sliver = 0;
                emit SliverReward(adds, gains);
            }
        }
    }

    // 分红
    function dividend() public onlyOwner {
        if (forest.dividend > 0) {
            (uint32 allIntegral, uint32 len) = calDividend();
            if (allIntegral > 0) {
                address[] memory adds = new address[](len);
                uint256[] memory gains = new uint256[](len);
                Tree memory t;
                uint256 index;
                uint256 poolGain;
                uint256 greenGain;
                for (uint i = 0; i < allTree.length; i++) {
                    t = allTree[i];
                    if (t.income < t.amount * 5 / 2) {
                        uint256 gain = t.integral * forest.dividend / allIntegral;
                        uint256 trueGain;
                        if (t.num >= 2) {
                            trueGain = gain * 975 / 1000;
                            greenGain += (gain - trueGain);
                        } else if (t.num == 1) {
                            trueGain = gain * 90 / 100;
                            poolGain += (gain - trueGain);
                        } else {
                            trueGain = gain * 80 / 100;
                            poolGain += (gain - trueGain);
                        }
                        _reward[t.account].dividend += trueGain;
                        allTree[i].income += trueGain;
                        adds[index] = t.account;
                        gains[index] = trueGain;
                        index++;
                    }
                }
                forest.green += greenGain;
                forest.dividend = 0;
                forest.pool += poolGain;
                emit DividendReward(adds, gains);
            }
        }
    }

    // 奖池
    function poolRelease() public onlyOwner {
        require(ifEnd(), "Not end");
        if (forest.pool > 0) {
            Tree memory lastTree = allTree[allTree.length - 1];
            _reward[lastTree.account].pool += forest.pool / 2;
            if (allTree.length > 1) {
                uint32 totalIntegral;
                Tree memory t;
                for (uint i = 1; i < Math.min(allTree.length, 100); i++) {
                    t = allTree[allTree.length - i - 1];
                    totalIntegral += t.integral;
                }
                for (uint i = 1; i < Math.min(allTree.length, 100); i++) {
                    t = allTree[allTree.length - i - 1];
                    _reward[t.account].pool += t.integral * forest.pool / 2 / totalIntegral;
                }
            } else {
                forest.foundation += forest.pool - forest.pool / 2;
            }
            forest.pool = 0;
        }
    }

    function calGold() public view returns (uint32, uint32){
        if (goldIndex.length == 0) {
            return (0, 0);
        } else {
            uint32 goldIntegral;
            Tree memory t;
            uint32 len;
            for (uint i = 0; i < goldIndex.length; i++) {
                t = allTree[goldIndex[i]];
                if (t.income < t.amount * 5 / 2) {
                    goldIntegral += t.integral;
                    len++;
                }
            }
            return (goldIntegral, len);
        }
    }

    function calSliver() public view returns (uint32, uint32){
        if (sliverIndex.length == 0) {
            return (0, 0);
        } else {
            uint32 sliverIntegral;
            Tree memory t;
            uint32 len;
            for (uint i = 0; i < sliverIndex.length; i++) {
                t = allTree[sliverIndex[i]];
                if (t.income < t.amount * 5 / 2) {
                    sliverIntegral += t.integral;
                    len++;
                }
            }
            return (sliverIntegral, len);
        }
    }

    function calDividend() public view returns (uint32, uint32){
        if (allTree.length == 0) {
            return (0, 0);
        } else {
            uint32 allIntegral;
            Tree memory t;
            uint32 len;
            for (uint i = 0; i < allTree.length; i++) {
                t = allTree[i];
                if (t.income < t.amount * 5 / 2) {
                    allIntegral += t.integral;
                    len++;
                }
            }
            return (allIntegral, len);
        }
    }

    function restart() public onlyOwner {
        forest.timestamp = 0;
        forest.remainTime = 0;
        forest.integral = 0;
        forest.pool = 0;
        forest.gold = 0;
        forest.sliver = 0;
        forest.community = 0;
        forest.foundation = 0;
        forest.dividend = 0;
        forest.bottom = 0;
        forest.green = 0;
        turn += 1;

        delete allTree;
        delete goldIndex;
        delete sliverIndex;
    }

    function greenTake(address account) public onlyOwner {
        require(forest.green > 0, "No remain");
        mgf.transfer(account, forest.green);
        forest.green = 0;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//
//   ██╗      ██████╗ ████████╗████████╗███████╗██████╗ ██╗   ██╗
//   ██║     ██╔═══██╗╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗╚██╗ ██╔╝
//   ██║     ██║   ██║   ██║      ██║   █████╗  ██████╔╝ ╚████╔╝
//   ██║     ██║   ██║   ██║      ██║   ██╔══╝  ██╔══██╗  ╚██╔╝
//   ███████╗╚██████╔╝   ██║      ██║   ███████╗██║  ██║   ██║
//   ╚══════╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝
//
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    function decimals() external view returns (uint8);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//彩票档次类型
struct PrizeSet {
    //单注投注金额
    uint256 betAmount;
    //参加人数
    uint256 PeopleCount;
    //特等奖获奖百分比
    uint256 Special;
    //1等奖获奖百分比
    uint256 First;
    //2等奖获奖百分比
    uint256 Second;
    //3等奖获奖百分比
    uint256 Third;
    //幸运奖获奖百分比
    uint256 Lucky;
}

struct CountSet {
    //特等奖获奖人数
    uint256 SpecialCount;
    //1等奖获奖人数
    uint256 FirstCount;
    //2等奖获奖人数
    uint256 SecondCount;
    //3等奖获奖人数
    uint256 ThirdCount;
    //幸运奖获奖人数
    uint256 LuckyCount;
}

struct ActSet {
    //是否在运作中
    bool exists;
    //期数
    uint256 index;
    //开奖锁
    bool drawLock;
    //申请人
    address requester;
}

// 用一个结构体表示申请信息
struct RequesterInfo {
    address requester; // 申请人地址
    uint256 approvals; // 已经同意的人数
    uint256 expirationTime; // 过期时间
    bool isApproved; // 是否已经通过申请
}

// 投注人信息
struct BettorInfo {
    address player;
    uint256 index;
}

// 获取随机数
// 声明一个枚举类型来表示奖项
enum Prize {
    Special,
    First,
    Second,
    Third,
    Lucky
}

// 声明一个结构体来表示中奖情况
struct Winner {
    Prize prize;
    address winnerAddr;
    // 奖励是否发放
    bool rewarded;
}

// 申请资金结构体
struct WitRequest {
    //申请的数量
    uint256 amount;
    //已同意人数
    uint256 approvalCount;
    //申请时间
    uint256 reqTime;
    //提取事件
    uint256 witTime;
    //申请者
    address requester;
}

//      _______          _
//     |__   __|        | |
//        | | ___   ___ | |___
//        | |/ _ \ / _ \| / __|
//        | | (_) | (_) | \__ \
//        |_|\___/ \___/|_|___/
//

abstract contract MyTools {
    function indexOf(
        address[] memory addresses,
        address target
    ) internal pure returns (int256) {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == target) {
                return int256(i);
            }
        }
        return -1;
    }

    function contains(
        address[] memory addresses,
        address target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == target) {
                return true;
            }
        }
        return false;
    }

    function indexOf(
        uint256[] memory arr,
        uint256 target
    ) internal pure returns (int256) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                return int256(i);
            }
        }
        return -1;
    }

    function contains(
        uint256[] memory arr,
        uint256 target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                return true;
            }
        }
        return false;
    }

    // 辅助函数：生成一个随机的索引值
    function randomIndex(uint256 max) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, max))
            ) % max;
    }

    // 内部函数：洗牌，打乱数组元素的顺序
    function shuffle(BettorInfo[] storage arr) internal {
        for (uint256 i = arr.length - 1; i > 0; i--) {
            uint256 j = uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.prevrandao, i)
                )
            ) % (i + 1);
            BettorInfo memory temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
        }
    }

    function mergeArrays(
        uint256[] memory arr1,
        uint256[] memory arr2
    ) internal pure returns (uint256[] memory) {
        uint256[] memory merged = new uint256[](arr1.length + arr2.length);

        for (uint256 i = 0; i < arr1.length; i++) {
            merged[i] = arr1[i];
        }

        for (uint256 i = 0; i < arr2.length; i++) {
            merged[arr1.length + i] = arr2[i];
        }

        return merged;
    }

    function removeArraysElement(
        uint256[] storage array,
        uint256 index
    ) internal {
        require(index < array.length, "Index out of bounds");
        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function mergeWinnerArrays(
        Winner[] memory arr1,
        Winner[] memory arr2
    ) internal pure returns (Winner[] memory) {
        Winner[] memory merged = new Winner[](arr1.length + arr2.length);

        for (uint256 i = 0; i < arr1.length; i++) {
            merged[i] = arr1[i];
        }

        for (uint256 i = 0; i < arr2.length; i++) {
            merged[arr1.length + i] = arr2[i];
        }

        return merged;
    }
}

abstract contract Common {
    //返回实际数量
    function getActualQuantity(
        IERC20 token,
        uint256 amount
    ) internal view returns (uint256) {
        return amount * (10 ** uint256(token.decimals()));
    }

    //获取代币总量
    function getTokenTotal(IERC20 token) internal view returns (uint256) {
        return token.totalSupply();
    }

    //查询我的余额
    function getBalanceOfAtToken(
        IERC20 token,
        address account
    ) internal view returns (uint256) {
        return token.balanceOf(account);
    }

    //查询授权余额
    function getAllowanceAtToken(
        IERC20 token,
        address _owner,
        address _spender
    ) internal view returns (uint256) {
        return token.allowance(_owner, _spender);
    }
}

/////////////////////////// 提币申请 ///////////////////////////////
abstract contract RequestWithdrawal is Ownable, Common, MyTools {
    //基金池
    uint256 public fundPool;
    //最低同意人数量
    uint256 public minWitApprovalCount = 50;
    // 可提现百分比 数值是万分比 100/10000
    uint256 public withdrawalPer = 100;
    //同意人代币持有量, 5代表 0.05%
    uint256 public witConsentHolderPer = 5;
    //当前申请提币的人 基金池是否正在申请提取
    WitRequest public witReq;
    //同意人 可从外部web3js遍历持有人然后遍历
    mapping(address => bool) private witApprovalMaps;

    //开始提现申请
    event WitRequested(address requester, uint256 amount);
    //同意人同意时
    event WitApproved(address requester);
    //同意人满时
    event WitApprovedFinal(address requester);
    //提币完成时
    event WitCompleted(WitRequest witReq);

    // ERC20 basic token contract being held
    IERC20 private fundtoken;

    function setFundtoken(IERC20 _token) internal {
        fundtoken = _token;
    }

    //申请提币
    function requestWit(uint256 _amount) public {
        require(witReq.requester == address(0), "someone is applying.");
        // 判断资金是否超过代币发型总量的1%
        uint256 tokenTotal = fundtoken.totalSupply();
        uint256 _total = (tokenTotal * withdrawalPer) / 10000;
        require(fundPool >= _total, "amount does not exceed percentage.");
        uint256 actualAmount = getActualQuantity(fundtoken, _amount);
        require(actualAmount <= fundPool, "amount is greater than fund.");
        // 更新申请提币信息
        witReq.amount = actualAmount;
        witReq.approvalCount = 0;
        witReq.reqTime = block.timestamp;
        witReq.requester = _msgSender();
        // 触发申请提币事件
        emit WitRequested(_msgSender(), actualAmount);
    }

    //同意提币
    function approveWit() public {
        require(witReq.requester != address(0), "No one applied for the fund.");
        require(witReq.requester != _msgSender(), "can't vote for myself.");
        // 判断资金持有者是否持有超过代币总量的0.05%
        uint256 _total = (fundtoken.totalSupply() * witConsentHolderPer) /
            10000;

        require(
            fundtoken.balanceOf(_msgSender()) >= _total,
            "must greater than 0.05% of total."
        );
        // 判断该资金持有者是否已经同意过该提币申请
        require(!witApprovalMaps[_msgSender()], "Already approved");
        // 更新提币申请信息中的同意人数
        witReq.approvalCount += 1;
        witApprovalMaps[_msgSender()] = true;

        // 如果同意人数超过50名资金代币持有者持有代币超过代币总量的0.05%，则将该提币申请者添加到可以提币的列表中
        if (witReq.approvalCount >= minWitApprovalCount) {
            // 触发可提币事件
            emit WitApprovedFinal(witReq.requester);
        }
    }

    //提币操作
    function withdraw() public {
        // 获取提币申请信息
        require(
            witReq.requester == _msgSender(),
            "you have not requested to withdraw the amount."
        );
        // 判断申请者是否可以提币
        require(
            witReq.approvalCount >= minWitApprovalCount,
            "not approved yet"
        );

        // 将代币转移到申请者的地址中
        fundtoken.transfer(_msgSender(), witReq.amount);
        witReq.witTime = block.timestamp;
        emit WitCompleted(witReq);

        witReq = WitRequest(0, 0, 0, 0, address(0));
    }

    //撤销提现申请
    function UndoWitRequest() public {
        require(witReq.requester != address(0), "no one applied for the fund.");
        require(
            witReq.requester == _msgSender() || owner() == _msgSender(),
            "can't vote for myself."
        );
        witReq = WitRequest(0, 0, 0, 0, address(0));
    }

    //设置申请提币最小同意人数
    function setMinWitApprovalCount(uint256 count) public onlyOwner {
        require(minWitApprovalCount != count, "same value.");
        minWitApprovalCount = count;
    }

    //设置提取最低万分比
    function setWithdrawalPer(uint256 count) public onlyOwner {
        require(withdrawalPer != count, "same value.");
        withdrawalPer = count;
    }

    //设置同意人代币持有量 万分率
    function setWitConsentHolderPer(uint256 num) external {
        require(witConsentHolderPer != num, "same value");
        witConsentHolderPer = num;
    }
}

////////////////////////// 彩票开奖 //////////////////////////
contract Lottery is RequestWithdrawal {
    //各档奖池
    uint256 public lotTotal;
    //档次奖项列表
    PrizeSet public prizeSet;
    //奖项人数设置
    CountSet public countSet;
    //档次行为列表
    ActSet public actSet;
    // 开奖人
    mapping(uint256 => address) public drawerMap;
    // 奖项投注人信息 (不用分期数, 每次开奖后就清空) slotid = > info
    BettorInfo[] public bettorArray;
    // 记录已经中奖的地址, 在抽奖时临时使用
    mapping(address => bool) private usedMap;
    address public rake;
    //奖励分配完成事件
    event EndOfAwards(uint256 index, address drawer);
    //购买彩票完成
    event BuyLotteryComplated(address player, uint256 amount, uint256 index);

    // ERC20 basic token contract being held
    IERC20 private immutable token;

    constructor(address _token, address _rake) {
        token = IERC20(_token);
        setFundtoken(token);
        rake = _rake;
        //定义初始档次
        // 三个彩票档次
        addLotterySlot(
            PrizeSet(10, 300, 30, 15, 8, 3, 1),
            CountSet(1, 1, 2, 3, 5),
            ActSet(true, 1, false, address(0))
        );
    }

    //添加插槽
    function addLotterySlot(
        PrizeSet memory _pri,
        CountSet memory _countS,
        ActSet memory _act
    ) private {
        require(_pri.PeopleCount >= 10, "must be greater than 10.");
        uint256 actualAmount = getActualQuantity(token, _pri.betAmount);
        _pri.betAmount = actualAmount;
        prizeSet = _pri;
        countSet = _countS;
        _act.exists = true;
        _act.index = 1;
        actSet = _act;
    }

    //购买彩票
    function buyLottery(uint256 _amount) public {
        require(
            token.balanceOf(_msgSender()) >= prizeSet.betAmount,
            "Insufficient betting amount!"
        );
        require(actSet.exists, "exist not true");
        uint256 actualAmount = getActualQuantity(token, _amount);
        //uint256 actualAmount = _amount;
        require(
            actualAmount >= prizeSet.betAmount &&
                actualAmount % prizeSet.betAmount == 0,
            "bet amount does not match"
        );

        uint256 multiple = actualAmount / prizeSet.betAmount;
        require(multiple <= 5, "cannot be greater than 5x.");
        // 转账代币
        require(getTokenAllowance() >= actualAmount, "Insufficient allowance!");

        token.transferFrom(_msgSender(), address(this), actualAmount);
        emit BuyLotteryComplated(_msgSender(), actualAmount, actSet.index);

        //用于更新投注倍数
        BettorInfo memory info = BettorInfo({
            player: _msgSender(),
            index: actSet.index
        });

        //获取购买者列表
        for (uint256 i = 0; i < multiple; i++) {
            bettorArray.push(info);
        }

        // 更新奖池总金额 不分期数
        lotTotal = lotTotal + actualAmount;

        //当期是否人满, 人满直接开奖
        if (bettorArray.length >= prizeSet.PeopleCount) {
            drawLottery();
        }
    }

    // 抽奖函数
    function drawLottery() private {
        require(!actSet.drawLock, "being released...");
        require(lotTotal > 0, "no draw.");
        actSet.drawLock = true;
        // 抽奖
        Winner[] memory winners = drawWinners();
        // 计算奖励金额
        uint256 special = (lotTotal * prizeSet.Special) / 100;
        uint256 first = (lotTotal * prizeSet.First) / 100;
        uint256 second = (lotTotal * prizeSet.Second) / 100;
        uint256 third = (lotTotal * prizeSet.Third) / 100;
        uint256 lucky = (lotTotal * prizeSet.Lucky) / 100;
        for (uint256 i = 0; i < winners.length; i++) {
            Winner memory win = winners[i];
            uint256 prize;
            if (win.prize == Prize.Special) {
                prize = special;
            } else if (win.prize == Prize.First) {
                prize = first;
            } else if (win.prize == Prize.Second) {
                prize = second;
            } else if (win.prize == Prize.Third) {
                prize = third;
            } else if (win.prize == Prize.Lucky) {
                prize = lucky;
            }

            token.transfer(win.winnerAddr, prize);
            lotTotal -= prize;
            win.rewarded = true;
            winners[i] = win;
        }

        RewardTransfer();

        //初始化
        actSet.drawLock = false;
        drawerMap[actSet.index] = _msgSender();
        actSet.index += 1;
        for (uint i = bettorArray.length - 1; i >= 0; i--) {
            delete bettorArray[i];
        }
    }

    //抽奖逻辑
    function drawWinners() private returns (Winner[] memory) {
        // 抽特等奖
        Winner[] memory winners1 = draw(countSet.SpecialCount, Prize.Special);
        // 总共有多少个奖项
        Winner[] memory winners = winners1;
        // 抽一等奖
        winners1 = draw(countSet.FirstCount, Prize.First);
        winners = mergeWinnerArrays(winners, winners1);
        // 抽二等奖
        winners1 = draw(countSet.SecondCount, Prize.Second);
        winners = mergeWinnerArrays(winners, winners1);
        // 抽三等奖
        winners1 = draw(countSet.ThirdCount, Prize.Third);
        winners = mergeWinnerArrays(winners, winners1);
        // 抽幸运奖
        winners1 = draw(countSet.LuckyCount, Prize.Lucky);
        winners = mergeWinnerArrays(winners, winners1);

        for (uint256 i = 0; i < winners.length; i++) {
            Winner memory winner = winners[i];
            usedMap[winner.winnerAddr] = false; //初始化这个映射
        }

        return winners;
    }

    // 抽奖逻辑封装
    function draw(
        uint256 prizeCount,
        Prize prize
    ) private returns (Winner[] memory) {
        uint256 playerCount = bettorArray.length;
        Winner[] memory winners = new Winner[](prizeCount);
        for (uint256 i = 0; i < prizeCount; i++) {
            uint256 ind = randomIndex(playerCount);
            address _address = bettorArray[ind].player;
            while (usedMap[_address]) {
                ind = randomIndex(playerCount);
                _address = bettorArray[ind].player;
            }
            usedMap[_address] = true;
            winners[i] = Winner(prize, _address, false);
        }
        return winners;
    }

    //派发奖励后后处理
    function RewardTransfer() private {
        uint256 _nextPool = lotTotal / 2;
        uint256 _fundPool = lotTotal - _nextPool;
        uint256 _compensation = (_fundPool * 1) / 100;
        uint256 _rakeamount = (_nextPool * 1) / 100;

        token.transfer(_msgSender(), _compensation);
        // 更新奖池和基金池
        fundPool = fundPool + (_fundPool - _compensation);
        token.transfer(rake, _rakeamount);
        lotTotal = lotTotal + (_nextPool - _rakeamount);
        emit EndOfAwards(actSet.index, _msgSender());
    }

    /**
     * @dev Returns the token being held.
     */
    function getToken() external view returns (IERC20) {
        return token;
    }

    function getTokenAllowance() public view returns (uint256) {
        return getAllowanceAtToken(token, _msgSender(), address(this));
    }

    function getTokenBalanceOf() public view returns (uint256) {
        return getBalanceOfAtToken(token, _msgSender());
    }

    //设置进行中的彩票
    function setPrizeSet(PrizeSet memory _lot) external onlyOwner {
        _lot.betAmount = getActualQuantity(token, _lot.betAmount);
        prizeSet = _lot;
    }

    //设置进行中的彩票
    function setWinnerCount(CountSet memory _winSet) external onlyOwner {
        countSet = _winSet;
    }

    //设置进行中的彩票
    function setActSet(ActSet memory _act) external onlyOwner {
        actSet = _act;
    }

    function setRake(address _rake) public onlyOwner {
        require(rake != _rake, "same value");
        rake = _rake;
    }

    //获取开奖人信息
    function getDrawer(uint256 index) external view returns (address) {
        return drawerMap[index];
    }
}
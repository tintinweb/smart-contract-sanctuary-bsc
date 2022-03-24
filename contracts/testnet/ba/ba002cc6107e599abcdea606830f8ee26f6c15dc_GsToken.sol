/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract GsToken is Ownable {
    using SafeMath for uint256;
    //质押市场规模总数
    uint256 public pledgeMarketTotal;
    //借贷市场规模总数
    uint256 public loanMarketTotal;
    uint256 DECIMAL = 10**6;
    //均价线
    uint256 public averagePrice = 33 * DECIMAL;
    //id
    uint256 public id = 1;

    struct Market {
        uint16 pledgePeriod; //质押周期
        uint16 pledgeRate; //质押率
        uint16 yearRate; //年利率
        uint16 dayRate; //日利率
    }
    Market[] public markets;

    // 用户借贷状态：借款中、已还款
    enum UserLoadStatus {
        IN,
        COMPLETED
    }

    // 用户借贷
    struct UserLoad {
        uint16 overdueDay; //逾期天数
        uint16 pledgePeriod; //质押周期
        uint32 loanTime; //借贷时间
        uint32 expireTime; //到期时间
        uint256 pledgeAmount; //质押数量
        uint256 loanAmount; //借贷数量
        uint256 guaranteeAssetsRate; //担保资产率
        uint256 id; //序号自增
        UserLoadStatus status;
    }
    mapping(address => UserLoad[]) public userLoads; //借贷情况记录

    // 操作类型状态： 借贷、还款、补仓、利息、逾期罚息、担保罚息
    enum OperationType {
        LOAN,
        REPAYMENT,
        COVER_SHORT_POSITIONS,
        INTEREST,
        OVERDUE_PENALTY_INTEREST,
        GUARANTEE_PENALTY_INTEREST
    }
    enum Assets {
        GC,
        GS
    }
    // 操作记录行为
    struct OperationRecord {
        uint32 time; //日期
        OperationType type_; //操作类型
        Assets asset; //资产GC、GS
        uint256 amount; //数量
        uint256 id; //借贷记录id,日志行为记录
        string hash_; //hash
    }
    mapping(address => OperationRecord[]) OperationRecords;

    constructor() {
        markets.push(Market(180, 300, 2500, 684));
        markets.push(Market(360, 345, 2125, 582));
        markets.push(Market(540, 397, 1806, 495));
        markets.push(Market(720, 487, 1535, 420));
        markets.push(Market(900, 526, 1305, 327));
        markets.push(Market(1080, 605, 1109, 304));
    }

    function marketsSize() public view returns (uint8) {
        return uint8(markets.length);
    }

    function getMarkets(uint8 _marketId) public view returns (Market memory) {
        return markets[_marketId];
    }

    function updateAveragePrice(uint256 _averagePrice)
        public
        onlyOwner
        returns (uint256)
    {
        averagePrice = _averagePrice;
        return averagePrice;
    }

    /* 借款 */
    function loan(uint8 _marketId, uint256 pledgeAmount)
        public
        returns (string memory result)
    {
        Market memory market = getMarket(_marketId);
        //计算可借数量 = 质押数量*均线价*质押率
        uint256 borrowCount = (
            (pledgeAmount.mul(DECIMAL).mul(averagePrice)).mul(market.pledgeRate)
        ).div(1000).div(DECIMAL);
        uint32 loanTime = uint32(block.timestamp);
        uint32 second = 86400;
        uint32 expireTime = loanTime + market.pledgePeriod * second;

        // 担保资产率=质押数量*均线价/借贷数量
        uint256 guaranteeAssetsRate = (
            (pledgeAmount.mul(DECIMAL).mul(averagePrice)).mul(10**6)
        ).div(borrowCount);

        UserLoad memory userLoad = UserLoad(
            0,
            market.pledgePeriod,
            loanTime,
            expireTime,
            pledgeAmount * DECIMAL,
            borrowCount,
            guaranteeAssetsRate.div(DECIMAL),
            id++,
            UserLoadStatus.IN
        );
        userLoads[msg.sender].push(userLoad);
        OperationRecords[msg.sender].push(
            OperationRecord(
                loanTime,
                OperationType.LOAN,
                Assets.GS,
                pledgeAmount * DECIMAL,
                userLoad.id,
                ""
            )
        );
        pledgeMarketTotal = pledgeMarketTotal + pledgeAmount * DECIMAL;
        loanMarketTotal = loanMarketTotal + borrowCount;
        return "SUCCESS";
    }

    /* 补仓 */
    function coverShortPositions(uint256 _id, uint256 _pledgeAmount)
        public
        returns (string memory result)
    {
        UserLoad[] storage userLoadList = userLoads[msg.sender];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            if (_id == userLoadList[i].id) {
                UserLoad storage userLoad_ = userLoadList[i];
                require(
                    userLoad_.status == UserLoadStatus.IN,
                    "Order Status Completed"
                );
                //计算补仓后质押数量
                uint256 amount = userLoad_.pledgeAmount +
                    _pledgeAmount *
                    DECIMAL;
                userLoad_.pledgeAmount = amount;
                // 补仓后资产担保率（输入补仓数量后自动计算）=（质押GS数量+补仓数量）*均线价/借贷金额。
                userLoad_.guaranteeAssetsRate =
                    ((amount * averagePrice) * 1000000) /
                    userLoad_.loanAmount /
                    DECIMAL;
                setOperationRecord(
                    msg.sender,
                    OperationType.COVER_SHORT_POSITIONS,
                    Assets.GS,
                    _pledgeAmount * DECIMAL,
                    userLoad_.id,
                    ""
                );
                pledgeMarketTotal = pledgeMarketTotal + _pledgeAmount * DECIMAL;
                return "SUCCESS";
            }
        }
        return "FIAL";
    }

    /* 还款 */
    function repayment(uint256 _id) public returns (string memory result) {
        UserLoad[] storage userLoadList = userLoads[msg.sender];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            if (_id == userLoadList[i].id) {
                UserLoad storage userLoad_ = userLoadList[i];
                require(
                    userLoad_.status == UserLoadStatus.IN,
                    "Order Status Completed"
                );
                //赎回GS
                userLoad_.status = UserLoadStatus.COMPLETED;
                setOperationRecord(
                    msg.sender,
                    OperationType.REPAYMENT,
                    Assets.GC,
                    userLoad_.loanAmount,
                    userLoad_.id,
                    ""
                );
                return "SUCCESS";
            }
        }
        return "FIAL";
    }

    /* 扣除日利息 */
    function deductInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            if (userLoad.status == UserLoadStatus.IN) {
                //利息计算时间范围=借贷开始时间—到期时间。
                if (
                    userLoad.loanTime <= block.timestamp &&
                    block.timestamp <= userLoad.expireTime
                ) {
                    Market memory market = getMarketByPledgePeriod(
                        userLoad.pledgePeriod
                    );
                    //日利息 = 质押数量 * 日利率
                    uint256 pledgeAmount_ = (userLoad.pledgeAmount *
                        market.dayRate) / 1000000;
                    userLoad.pledgeAmount =
                        userLoad.pledgeAmount -
                        pledgeAmount_;
                    userLoad.guaranteeAssetsRate =
                        ((userLoad.pledgeAmount * averagePrice) * 1000000) /
                        userLoad.loanAmount /
                        DECIMAL;
                    setOperationRecord(
                        _address,
                        OperationType.INTEREST,
                        Assets.GS,
                        pledgeAmount_,
                        userLoad.id,
                        ""
                    );
                }
            }
        }
    }

    /* 逾期罚息 */
    function overduePenaltyInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            if (userLoad.status == UserLoadStatus.IN) {
                //到期时间之后开始计算逾期罚息
                if (userLoad.expireTime < block.timestamp) {
                    Market memory market = getMarketByPledgePeriod(
                        userLoad.pledgePeriod
                    );
                    //逾期罚息(3倍日利息) = 质押数量 * 日利率 * 3
                    uint256 pledgeAmount_ = (userLoad.pledgeAmount *
                        market.dayRate) / 1000000;
                    userLoad.pledgeAmount =
                        userLoad.pledgeAmount -
                        (pledgeAmount_ * 3);
                    userLoad.guaranteeAssetsRate =
                        ((userLoad.pledgeAmount * averagePrice) * 1000000) /
                        userLoad.loanAmount /
                        DECIMAL;
                    setOperationRecord(
                        _address,
                        OperationType.OVERDUE_PENALTY_INTEREST,
                        Assets.GS,
                        pledgeAmount_,
                        userLoad.id,
                        ""
                    );
                }
            }
        }
    }

    /* 担保罚息 */
    function guaranteePenaltyInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            //触发担保罚息条件：订单进行中，担保资产率＜100%
            if (userLoad.status == UserLoadStatus.IN) {
                //利息计算时间范围=借贷开始时间—到期时间。
                if (
                    userLoad.loanTime <= block.timestamp &&
                    block.timestamp <= userLoad.expireTime
                ) {
                    if (userLoad.guaranteeAssetsRate < 100) {
                        Market memory market = getMarketByPledgePeriod(
                            userLoad.pledgePeriod
                        );
                        //日利息 = 质押数量 * 日利率
                        uint256 pledgeAmount_ = (userLoad.pledgeAmount *
                            market.dayRate) / 1000000;
                        //担保罚息=（借贷GC-质押数量*均线价）*质押周期对应的罚息日利率*3/均线价
                        uint256 amount = ((
                            userLoad.loanAmount.sub(
                                (userLoad.pledgeAmount * averagePrice) / DECIMAL
                            )
                        ) * (pledgeAmount_ * 3 * DECIMAL)) / averagePrice;

                        userLoad.pledgeAmount = userLoad.pledgeAmount - amount;
                        userLoad.guaranteeAssetsRate =
                            ((userLoad.pledgeAmount * averagePrice) * 1000000) /
                            userLoad.loanAmount /
                            DECIMAL;

                        setOperationRecord(
                            _address,
                            OperationType.GUARANTEE_PENALTY_INTEREST,
                            Assets.GS,
                            amount,
                            userLoad.id,
                            ""
                        );
                    }
                }
            }
        }
    }

    /* 根据质押周期查询市场信息 */
    function getMarketByPledgePeriod(uint16 _pledgePeriod)
        internal
        returns (Market memory)
    {
        for (uint256 i = 0; i < markets.length; i++) {
            if (markets[i].pledgePeriod == _pledgePeriod) {
                return markets[i];
            }
        }
        require(false, "Market does not exist");
    }

    function getMarket(uint8 _id) internal returns (Market memory) {
        if (_id == 0) {
            _id = 1;
        }
        require(_id <= marketsSize(), "The ID value is too large");
        return markets[_id - 1];
    }

    function getUserLoadSize() public returns (uint256) {
        return userLoads[msg.sender].length;
    }

    function getUserLoads() public returns (UserLoad[] memory) {
        return userLoads[msg.sender];
    }

    // 数组下标查找
    function getUserLoadsIndex(uint256 _index)
        public
        returns (UserLoad memory)
    {
        if (_index == 0) {
            _index = 1;
        }
        require(_index <= getUserLoadSize(), "The ID value is too large");
        return userLoads[msg.sender][_index - 1];
    }

    //每天记录唯一id查找
    function getUserLoadsId(uint256 _id)
        public
        returns (UserLoad memory userLoad_)
    {
        UserLoad[] memory userLoadList = userLoads[msg.sender];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            if (_id == userLoadList[i].id) {
                return userLoadList[i];
            }
        }
        require(false, "Id record does not exist.");
    }

    //获取当前用户GS质押，GC借贷数量
    function getUserPledgeLoan()
        public
        returns (uint256 userPledgeAmount, uint256 userLoanAmount)
    {
        UserLoad[] memory userLoadList = userLoads[msg.sender];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            userPledgeAmount = userPledgeAmount + userLoadList[i].pledgeAmount;
            userLoanAmount = userLoanAmount + userLoadList[i].loanAmount;
        }
        return (userPledgeAmount, userLoanAmount);
    }

    /* 操作记录 */
    function getOperationRecords() public returns (OperationRecord[] memory) {
        return OperationRecords[msg.sender];
    }

    /* 保存操作记录 */
    function setOperationRecord(
        address _address,
        OperationType type_,
        Assets asset,
        uint256 amount,
        uint256 id,
        string memory _hash
    ) internal {
        OperationRecords[msg.sender].push(
            OperationRecord(
                uint32(block.timestamp),
                type_,
                asset,
                amount,
                id,
                _hash
            )
        );
    }
}
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
    //????????????????????????
    uint256 public pledgeMarketTotal;
    //????????????????????????
    uint256 public loanMarketTotal;
    uint256 DECIMAL = 10**6;
    //?????????
    uint256 public averagePrice = 33 * DECIMAL;
    //id
    uint256 public id = 1;

    struct Market {
        uint16 pledgePeriod; //????????????
        uint16 pledgeRate; //?????????
        uint16 yearRate; //?????????
        uint16 dayRate; //?????????
    }
    Market[] public markets;

    // ??????????????????????????????????????????
    enum UserLoadStatus {
        IN,
        COMPLETED
    }

    // ????????????
    struct UserLoad {
        uint16 overdueDay; //????????????
        uint16 pledgePeriod; //????????????
        uint32 loanTime; //????????????
        uint32 expireTime; //????????????
        uint256 pledgeAmount; //????????????
        uint256 loanAmount; //????????????
        uint256 guaranteeAssetsRate; //???????????????
        uint256 id; //????????????
        UserLoadStatus status;
    }
    mapping(address => UserLoad[]) public userLoads; //??????????????????

    // ????????????????????? ???????????????????????????????????????????????????????????????
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
    // ??????????????????
    struct OperationRecord {
        uint32 time; //??????
        OperationType type_; //????????????
        Assets asset; //??????GC???GS
        uint256 amount; //??????
        uint256 id; //????????????id,??????????????????
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

    /* ?????? */
    function loan(uint8 _marketId, uint256 pledgeAmount)
        public
        returns (string memory result)
    {
        Market memory market = getMarket(_marketId);
        //?????????????????? = ????????????*?????????*?????????
        uint256 borrowCount = (
            (pledgeAmount.mul(DECIMAL).mul(averagePrice)).mul(market.pledgeRate)
        ).div(1000).div(DECIMAL);
        uint32 loanTime = uint32(block.timestamp);
        uint32 second = 86400;
        uint32 expireTime = loanTime + market.pledgePeriod * second;

        // ???????????????=????????????*?????????/????????????
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

    /* ?????? */
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
                //???????????????????????????
                uint256 amount = userLoad_.pledgeAmount +
                    _pledgeAmount *
                    DECIMAL;
                userLoad_.pledgeAmount = amount;
                // ???????????????????????????????????????????????????????????????=?????????GS??????+???????????????*?????????/???????????????
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

    /* ?????? */
    function repayment(uint256 _id) public returns (string memory result) {
        UserLoad[] storage userLoadList = userLoads[msg.sender];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            if (_id == userLoadList[i].id) {
                UserLoad storage userLoad_ = userLoadList[i];
                require(
                    userLoad_.status == UserLoadStatus.IN,
                    "Order Status Completed"
                );
                //??????GS
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

    /* ??????????????? */
    function deductInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            if (userLoad.status == UserLoadStatus.IN) {
                //????????????????????????=????????????????????????????????????
                if (
                    userLoad.loanTime <= block.timestamp &&
                    block.timestamp <= userLoad.expireTime
                ) {
                    Market memory market = getMarketByPledgePeriod(
                        userLoad.pledgePeriod
                    );
                    //????????? = ???????????? * ?????????
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

    /* ???????????? */
    function overduePenaltyInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            if (userLoad.status == UserLoadStatus.IN) {
                //??????????????????????????????????????????
                if (userLoad.expireTime < block.timestamp) {
                    Market memory market = getMarketByPledgePeriod(
                        userLoad.pledgePeriod
                    );
                    //????????????(3????????????) = ???????????? * ????????? * 3
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

    /* ???????????? */
    function guaranteePenaltyInterest(address _address) public onlyOwner {
        UserLoad[] storage userLoads = userLoads[_address];
        for (uint256 i = 0; i < userLoads.length; i++) {
            UserLoad storage userLoad = userLoads[i];
            //???????????????????????????????????????????????????????????????100%
            if (userLoad.status == UserLoadStatus.IN) {
                //????????????????????????=????????????????????????????????????
                if (
                    userLoad.loanTime <= block.timestamp &&
                    block.timestamp <= userLoad.expireTime
                ) {
                    if (userLoad.guaranteeAssetsRate < 100) {
                        Market memory market = getMarketByPledgePeriod(
                            userLoad.pledgePeriod
                        );
                        //????????? = ???????????? * ?????????
                        uint256 pledgeAmount_ = (userLoad.pledgeAmount *
                            market.dayRate) / 1000000;
                        //????????????=?????????GC-????????????*????????????*????????????????????????????????????*3/?????????
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

    /* ???????????????????????????????????? */
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

    function getUserLoadSize(address _address) public view returns (uint256) {
        return userLoads[_address].length;
    }

    function getUserLoads(address _address)
        public
        view
        returns (UserLoad[] memory)
    {
        return userLoads[_address];
    }

    // ??????????????????
    function getUserLoadsIndex(uint256 _index, address _address)
        public
        view
        returns (UserLoad memory)
    {
        if (_index == 0) {
            _index = 1;
        }
        require(
            _index <= getUserLoadSize(_address),
            "The ID value is too large"
        );
        return userLoads[_address][_index - 1];
    }

    //??????????????????id??????
    function getUserLoadsId(uint256 _id, address _address)
        public
        view
        returns (UserLoad memory userLoad_)
    {
        UserLoad[] memory userLoadList = userLoads[_address];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            if (_id == userLoadList[i].id) {
                return userLoadList[i];
            }
        }
        require(false, "Id record does not exist.");
    }

    //??????????????????GS?????????GC????????????
    function getUserPledgeLoan(address _address)
        public
        view
        returns (uint256 userPledgeAmount, uint256 userLoanAmount)
    {
        UserLoad[] memory userLoadList = userLoads[_address];
        for (uint256 i = 0; i < userLoadList.length; i++) {
            userPledgeAmount = userPledgeAmount + userLoadList[i].pledgeAmount;
            userLoanAmount = userLoanAmount + userLoadList[i].loanAmount;
        }
        return (userPledgeAmount, userLoanAmount);
    }

    /* ???????????? */
    function getOperationRecords(address _address)
        public
        view
        returns (OperationRecord[] memory)
    {
        return OperationRecords[_address];
    }

    /* ?????????????????? */
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
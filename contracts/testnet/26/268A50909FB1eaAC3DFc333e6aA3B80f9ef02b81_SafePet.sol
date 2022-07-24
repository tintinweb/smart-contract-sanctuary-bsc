pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Math {
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
        if (a == 0) return 0;
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

    function take(uint256 a, uint256 percents) internal pure returns (uint256) {
        return div(mul(a, percents), 100);
    }
}

contract AccountChangable {
    address supervisor;
    address EMPTY_ADDRESS = address(0);
    mapping(address => address) oldToNew;
    mapping(address => address) newToOld;
    mapping(address => address) requests;

    constructor() {
        supervisor = msg.sender;
    }

    event ChangeAddressRequest(address oldAddress, address newAddress);
    event ApproveChangeAddressRequest(address oldAddress, address newAddress);

    function getOriginalAddress(address someAddress) public view returns (address) {
        if (newToOld[someAddress] != EMPTY_ADDRESS) return newToOld[someAddress];
        return someAddress;
    }

    function isReplaced(address oldAddress) internal view returns (bool) {
        return oldToNew[oldAddress] != EMPTY_ADDRESS;
    }

    function isNewAddress(address newAddress) public view returns (bool) {
        return newToOld[newAddress] != EMPTY_ADDRESS;
    }

    function getCurrentAddress(address someAddress) internal view returns (address) {
        if (oldToNew[someAddress] != EMPTY_ADDRESS) return oldToNew[someAddress];
        return someAddress;
    }

    function requestUpdateAddress(address newAddress) public {
        requests[msg.sender] = newAddress;
        emit ChangeAddressRequest(msg.sender, newAddress);
    }

    function accept(address oldAddress, address newAddress) public {
        require(msg.sender == supervisor, "ONLY SUPERVISOR");
        require(newAddress != EMPTY_ADDRESS, "NEW ADDRESS MUST NOT BE EMPTY");
        require(requests[oldAddress] == newAddress, "INCORRECT NEW ADDRESS");
        requests[oldAddress] = EMPTY_ADDRESS;
        oldToNew[oldAddress] = newAddress;
        newToOld[newAddress] = oldAddress;
        emit ApproveChangeAddressRequest(oldAddress, newAddress);
    }
}

contract Utils {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) return a;
        return b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) return a;
        return b;
    }

    function inRange(
        uint256 from,
        uint256 to,
        uint256 value
    ) internal pure returns (bool) {
        return from <= value && value <= to;
    }
}

interface IRandomizer {
    function getUpgradeSuccessCount(uint256 level, uint256 numberOfAnims)
    external
    view
    returns (uint256 result);
}

contract SafePet is AccountChangable, Utils {
    using Math for uint256;

    string public version = "0.0.1";
    uint256 ONE_DAY = 86400;
    uint256 FACTOR = 1e9;
    address TOKEN_CONTRACT_ADDRESS = EMPTY_ADDRESS;

    mapping(address => uint256) systemRates;
    address public rootAdmin;
    address public frcAdmin1;
    address public frcAdmin2;
    address public fundAdmin;
    address public owner;
    uint256 public ROOT_LEVEL = 1;

    uint256 public investmentCount = 0;
    uint256 public skippedTime = 0;
    mapping(uint256 => Investment) public investments;
    mapping(address => Investor) public investors;
    mapping(uint256 => Package) public packages;

    mapping(address => mapping(uint256 => Anim)) anims;
    address[] public investorIds;
    Transaction[] public transactions;

    event CreateInvestor(address investorAddress, address presenterAddress, uint256 level);
    event CreateInvestment(
        uint256 investmentId,
        address investorAddress,
        uint256 packageId,
        uint256 createdAt
    );

    uint256 BALANCE_CHANGE_REASON_DEPOSIT = 0;
    uint256 BALANCE_CHANGE_REASON_WITHDRAW = 1;
    uint256 BALANCE_CHANGE_REASON_BUY_PACKAGE = 2;
    uint256 BALANCE_CHANGE_REASON_SELL_ANIM = 3;
    uint256 BALANCE_CHANGE_REASON_SYSTEM_COMMISSION = 4;
    uint256 BALANCE_CHANGE_REASON_DIRECT_COMMISSION = 5;
    uint256 BALANCE_CHANGE_REASON_SEND_TRANSFER = 6;
    uint256 BALANCE_CHANGE_REASON_RECEIVE_TRANSFER = 7;
    uint256 BALANCE_CHANGE_REASON_RECEIVE_WITHDRAW_FEE = 8;
    uint256 BALANCE_CHANGE_REASON_OWNER_COMMISSION = 9;
    uint256 BALANCE_CHANGE_REASON_FRC_COMMISSION = 10;
    uint256 BALANCE_CHANGE_REASON_RECEIVE_SELL_ANIM_FEE = 11;

    event BalanceChange(address investorAddress, uint256 amount, uint256 reason);

    uint256 ANIM_CHANGE_REASON_SELL = 0;
    uint256 ANIM_CHANGE_REASON_SEND_TRANSFER = 1;
    uint256 ANIM_CHANGE_REASON_RECEIVE_TRANSFER = 2;
    uint256 ANIM_CHANGE_REASON_UPGRADE_INCREASE = 3;
    uint256 ANIM_CHANGE_REASON_UPGRADE_DECREASE = 4;

    event AnimChange(address investorAddress, uint256 animLevel, uint256 amount, uint256 reason);

    struct Transaction {
        address senderAddress;
        address investorAddress;
        uint256 animLevel;
        uint256 amount;
        uint256 reason;
        uint256 block;
    }

    struct Investor {
        address investorAddress;
        address presenterAddress;
        uint256 level;
        uint256 balance;
        uint256 rank;
        uint256 revenue;
        uint256 invested;
        uint256[] investments;
    }

    struct Anim {
        uint256 positive;
        uint256 negative;
    }

    struct Investment {
        uint256 investmentId;
        address investorAddress;
        uint256 packageId;
        uint256 createdAt;
    }

    struct Package {
        uint256 packageId;
        uint256 price;
        uint256 animLevel;
        uint256 animPerDay;
    }

    uint256 ownerRate = 0;
    uint256 frc1Rate = 0;
    uint256 frc2Rate = 0;
    address public randomizer;

    constructor(
        address rootAddress,
        address fundAdminAddress,
        address ownerAddress,
        address tokenAddress,
        address _randomizer
    ) {
        rootAdmin = rootAddress;
        randomizer = _randomizer;
        uint256 FIRST_LEVEL = 1;
        createInvestor(rootAddress, EMPTY_ADDRESS, FIRST_LEVEL);
        initPackages();
        setFundAdmin(fundAdminAddress);
        setOwner(ownerAddress);
        frcAdmin1 = ownerAddress;
        frcAdmin2 = ownerAddress;
        TOKEN_CONTRACT_ADDRESS = tokenAddress;
    }

    modifier mustBeActiveInvestor() {
        require(!isReplaced(msg.sender), "REPLACED ADDRESS");
        _;
    }

    modifier mustBeRootAdmin() {
        require(!isReplaced(msg.sender), "REPLACED ADDRESS");
        require(getOriginalAddress(msg.sender) == rootAdmin, "ONLY ADMIN");
        _;
    }

    function setFundAdmin(address fundAdminAddress) public {
        require(msg.sender == rootAdmin, "NOT ROOT ADDRESS");
        createInvestor(fundAdminAddress, rootAdmin, 2);
        fundAdmin = fundAdminAddress;
    }

    function setOwner(address ownerAddress) internal {
        createInvestor(ownerAddress, rootAdmin, 2);
        owner = ownerAddress;
    }

    function initPackages() internal {
        packages[1] = Package({packageId : 1, price : 71429, animLevel : 1, animPerDay : 1});
        packages[2] = Package({packageId : 2, price : 357143, animLevel : 3, animPerDay : 1});
        packages[3] = Package({packageId : 3, price : 714286, animLevel : 4, animPerDay : 1});
        packages[4] = Package({packageId : 4, price : 1785714, animLevel : 4, animPerDay : 3});
        packages[5] = Package({packageId : 5, price : 3571429, animLevel : 5, animPerDay : 3});
        packages[6] = Package({packageId : 6, price : 7142857, animLevel : 6, animPerDay : 3});
        packages[7] = Package({packageId : 7, price : 14285714, animLevel : 7, animPerDay : 3});
    }

    function skip(uint256 numberOfday) public {
        address sender = getOriginalAddress(msg.sender);
        require(sender == rootAdmin || sender == owner, "ONLY ADMIN OR OWNDER");
        skippedTime = skippedTime.add(numberOfday.mul(ONE_DAY));
    }

    function setInvestor(
        address investorAddress,
        uint256 balance,
        uint256 rank,
        uint256 invested,
        uint256 revenue
    ) public {
        require(!isReplaced(msg.sender), "REPLACED ADDRESS");
        address sender = getOriginalAddress(msg.sender);
        require(sender == rootAdmin || sender == owner, "ONLY ADMIN OR OWNDER");
        Investor storage investor = investors[investorAddress];
        investor.balance = balance;
        investor.rank = rank;
        investor.invested = invested;
        investor.revenue = revenue;
    }

    function createInvestor(
        address investorAddress,
        address presenterAddress,
        uint256 level
    ) internal {
        if(investors[investorAddress].investorAddress == address(0)) investorIds.push(investorAddress);
        investors[investorAddress] = Investor({
        investorAddress : investorAddress,
        presenterAddress : presenterAddress,
        level : level,
        balance : 0,
        rank : 0,
        invested : 0,
        revenue : 0,
        investments : new uint256[](0)
        });
        emit CreateInvestor(investorAddress, presenterAddress, level);
    }

    function createInvestment(
        uint256 index,
        address investorAddress,
        uint256 packageId,
        uint256 createdAt
    ) internal {
        uint256 investmentId = index;
        investments[investmentId] = Investment({
        investmentId : investmentId,
        investorAddress : investorAddress,
        packageId : packageId,
        createdAt : createdAt
        });
        investors[investorAddress].investments.push(investmentId);
        emit CreateInvestment(investmentId, investorAddress, packageId, createdAt);
    }

    uint256[] DIRECT_COMMISSION_BY_RANKS = [0, 100, 170, 250];

    function payDirectCommission(address[] memory presenterAddresses, uint256 packagePrice) internal {
        uint256 budget = 250;
        uint256 maxRateReceived = 0;

        for (uint256 index = 0; index < presenterAddresses.length; index++) {
            address presenterAddress = presenterAddresses[index];
            uint256 newMaxRateReceived = max(
                maxRateReceived,
                DIRECT_COMMISSION_BY_RANKS[investors[presenterAddress].rank]
            );
            uint256 rate = newMaxRateReceived.sub(maxRateReceived);
            maxRateReceived = newMaxRateReceived;

            if (rate > 0) {
                budget = budget.sub(rate);
                uint256 commission = packagePrice.take(rate).div(10);
                pay(presenterAddress, commission);
                emit BalanceChange(presenterAddress, commission, BALANCE_CHANGE_REASON_DIRECT_COMMISSION);
            }
            if (budget == 0) return;
        }
        uint256 rest = packagePrice.take(budget).div(10);
        if (rest == 0) return;
        pay(fundAdmin, rest);
        emit BalanceChange(fundAdmin, rest, BALANCE_CHANGE_REASON_DIRECT_COMMISSION);
    }

    function setFrcAdmin(
        address frcAddress1,
        address frcAddress2,
        uint256 rate1,
        uint256 rate2,
        uint256 rate3
    ) public mustBeRootAdmin {
        require(isInvestorExists(frcAddress1), "FRC_MUST_BE_INVESTOR");
        frcAdmin1 = frcAddress1;

        require(isInvestorExists(frcAddress2), "FRC_MUST_BE_INVESTOR");
        frcAdmin2 = frcAddress2;

        ownerRate = rate1;
        frc1Rate = rate2;
        frc2Rate = rate3;
    }

    function payOwnerAndFrcCommission(uint256 packagePrice) internal {
        if (ownerRate > 0) {
            pay(owner, packagePrice.take(ownerRate));
            emit BalanceChange(
                owner,
                packagePrice.take(ownerRate),
                BALANCE_CHANGE_REASON_OWNER_COMMISSION
            );
        }

        if (frc1Rate > 0) {
            pay(frcAdmin1, packagePrice.take(frc1Rate));
            emit BalanceChange(
                frcAdmin1,
                packagePrice.take(frc1Rate),
                BALANCE_CHANGE_REASON_FRC_COMMISSION
            );
        }

        if (frc2Rate > 0) {
            pay(frcAdmin2, packagePrice.take(frc2Rate));
            emit BalanceChange(
                frcAdmin2,
                packagePrice.take(frc2Rate),
                BALANCE_CHANGE_REASON_FRC_COMMISSION
            );
        }
    }

    function increaseAnim(
        address investorAddress,
        uint256 level,
        uint256 amount
    ) internal {
        anims[investorAddress][level].positive = anims[investorAddress][level].positive.add(amount);
    }

    function decreaseAnim(
        address investorAddress,
        uint256 level,
        uint256 amount
    ) internal {
        require(getAnim(investorAddress, level) >= amount, "NOT_ENOUGH_ANIM");
        anims[investorAddress][level].negative = anims[investorAddress][level].negative.add(amount);
    }

    function getAnim(address investorAddress, uint256 level) public view returns (uint256) {
        Anim memory anim = anims[investorAddress][level];
        return anim.positive.add(getAnimByInvestments(investorAddress, level)).sub(anim.negative);
    }

    function getAnimByInvestments(address investorAddress, uint256 level)
    public
    view
    returns (uint256)
    {
        uint256 result = 0;
        Investor memory investor = investors[investorAddress];
        uint256 length = investor.investments.length;
        for (uint256 index; index < length; index++) {
            Investment memory investment = investments[investor.investments[index]];
            Package memory package = packages[investment.packageId];
            if (package.animLevel != level) continue;
            uint256 MAX_DAYS = 40;
            uint256 dayCount = min((getNow().sub(investment.createdAt)).div(ONE_DAY), MAX_DAYS);
            uint256 earned = dayCount.mul(package.animPerDay);
            result = result.add(earned);
        }
        return result;
    }

    function updateRankForPresenters(address[] memory presenterAddresses) internal {
        for (uint256 index = 0; index < presenterAddresses.length; index++) {
            updateRankForOne(presenterAddresses[index]);
        }
    }

    function updateRankForOne(address investorAddress) internal {
        Investor storage current = investors[investorAddress];
        uint256 newRank = getNewRank(current.revenue, current.investments.length > 0);
        uint256 currentRank = current.rank;
        if (newRank != currentRank) {
            current.rank = newRank;
        }
    }

    function updateRevenues(address[] memory presenterAddresses, uint256 amount) internal {
        for (uint256 index = 0; index < presenterAddresses.length; index++) {
            investors[presenterAddresses[index]].revenue += amount;
        }
    }

    function getNewRank(uint256 revenue, bool invested) public view returns (uint256) {
        uint256[3] memory REQUIRED_REVENUES = [uint256(0), 15000000, 100000000];
        if (revenue >= REQUIRED_REVENUES[2] * FACTOR) return 3;
        if (revenue >= REQUIRED_REVENUES[1] * FACTOR) return 2;
        if (invested) return 1;
        return 0;
    }

    function pay(address to, uint256 amount) internal {
        investors[to].balance = investors[to].balance.add(amount);
    }

    mapping(uint256 => bool) public disabledPackages;

    function setDisabledPackages(
        uint256[] memory toAddPackageIds,
        uint256[] memory toRemovePackageIds
    ) public mustBeRootAdmin {
        for (uint256 index = 0; index < toAddPackageIds.length; index++) {
            disabledPackages[toAddPackageIds[index]] = true;
        }

        for (uint256 index = 0; index < toRemovePackageIds.length; index++) {
            disabledPackages[toRemovePackageIds[index]] = false;
        }
    }

    function getDisabledPackages() public view returns (bool[] memory result) {
        uint256 MIN_PACKAGE_ID = 1;
        uint256 MAX_PACKAGE_ID = 7;
        result = new bool[](7);
        for (uint256 id = MIN_PACKAGE_ID; id <= MAX_PACKAGE_ID; id++) {
            result[id - 1] = disabledPackages[id];
        }
    }

    uint256 public MAX_LEVEL_COUNT = 15;

    function setMaxLevelCount(uint256 maxLevelCount) public mustBeRootAdmin {
        MAX_LEVEL_COUNT = maxLevelCount;
    }

    function getPresentersLength(uint256 fromLevel, uint256 levelCount)
    private
    pure
    returns (uint256)
    {
        if (levelCount > fromLevel) return fromLevel - 1;
        return levelCount;
    }

    function getPresenters(address fromAddress, uint256 levelCount)
    public
    view
    returns (address[] memory result)
    {
        Investor memory investor = investors[fromAddress];
        uint256 length = getPresentersLength(investor.level, levelCount);
        result = new address[](length);

        address currentAddress = fromAddress;
        for (uint256 index = 0; index < length; index++) {
            address presenterAddress = investors[currentAddress].presenterAddress;
            result[index] = presenterAddress;
            currentAddress = presenterAddress;
        }
    }

    function buyPackage(uint256 packageId) public mustBeActiveInvestor {
        address investorAddress = getOriginalAddress(msg.sender);
        require(investorAddress != fundAdmin, "FUND_ADMIN_CANNOT_BUY_PACKAGE");
        require(!disabledPackages[packageId], "DISABLED_PACKAGE");
        require(inRange(1, 7, packageId), "INVALID_PACKAGE_ID");
        uint256 value = packages[packageId].price.mul(FACTOR);
        Investor storage investor = investors[investorAddress];
        require(investor.investments.length < 10, "TOO_MANY_PACKAGES");
        investor.balance = investor.balance.sub(value, "INSUFFICIENT_FUNDS");
        investor.invested += value;
        createInvestment(++investmentCount, investorAddress, packageId, getNow());
        emit BalanceChange(investorAddress, value, BALANCE_CHANGE_REASON_BUY_PACKAGE);
        payOwnerAndFrcCommission(value);
        address[] memory presenterAddresses = getPresenters(investorAddress, MAX_LEVEL_COUNT);
        payDirectCommission(presenterAddresses, value);
        updateRevenues(presenterAddresses, value);
        updateRankForOne(investorAddress);
        updateRankForPresenters(presenterAddresses);
    }

    event UpgradeResult(
        uint256 successCount,
        uint256 failCount,
        uint256 level,
        address investorAddress
    );

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function upgrade(uint256 level, uint256 numberOfAnims) public mustBeActiveInvestor {
        require(!isContract(msg.sender), "NO_CONTRACT_CALLS");
        address investorAddress = getOriginalAddress(msg.sender);
        require(numberOfAnims > 0 && numberOfAnims % 2 == 0, "INVALID_NUMBER_OF_ANIMS");
        uint256 MAX_ANIM_LEVEL = 19;
        require(inRange(1, MAX_ANIM_LEVEL.sub(1), level), "INVALID_LEVEL");

        uint256 successCount = IRandomizer(randomizer).getUpgradeSuccessCount(level, numberOfAnims);
        uint256 failCount = numberOfAnims / 2 - successCount;
        uint256 decreaseCount = successCount * 2 + failCount;

        decreaseAnim(investorAddress, level, decreaseCount);
        emit AnimChange(investorAddress, level, decreaseCount, ANIM_CHANGE_REASON_UPGRADE_DECREASE);
        Transaction memory transaction = Transaction(msg.sender, investorAddress, level, decreaseCount, ANIM_CHANGE_REASON_UPGRADE_DECREASE, block.number);
        transactions.push(transaction);
        if (successCount > 0) {
            increaseAnim(investorAddress, level.add(1), successCount);
            emit AnimChange(
                investorAddress,
                level.add(1),
                successCount,
                ANIM_CHANGE_REASON_UPGRADE_INCREASE
            );
            transaction = Transaction(msg.sender, investorAddress, level.add(1), successCount, ANIM_CHANGE_REASON_UPGRADE_INCREASE, block.number);
            transactions.push(transaction);
        }
        emit UpgradeResult(successCount, failCount, level, investorAddress);
    }

    mapping(address => mapping(uint256 => bool)) public doneTransferAnim;

    function safeTransferAnim(
        uint256 level,
        uint256 numberOfAnims,
        address toAddress,
        uint256 index
    ) public mustBeActiveInvestor {
        address from = getOriginalAddress(msg.sender);
        require(!doneTransferAnim[from][index], "DUPLICATED");
        transferAnim(level, numberOfAnims, toAddress);
        doneTransferAnim[from][index] = true;
    }

    function transferAnim(
        uint256 level,
        uint256 numberOfAnims,
        address toAddress
    ) public mustBeActiveInvestor {
        require(numberOfAnims > 0, "INVALID_NUMBER_OF_ANIMS");
        address from = getOriginalAddress(msg.sender);
        address to = getOriginalAddress(toAddress);
        require(isInvestorExists(to), "INVALID_TO_ADDRESS");
        uint256 MAX_ANIM_LEVEL = 19;
        require(inRange(1, MAX_ANIM_LEVEL, level), "INVALID_LEVEL");
        decreaseAnim(from, level, numberOfAnims);
        Transaction memory transaction = Transaction(from, to, level, numberOfAnims, ANIM_CHANGE_REASON_SEND_TRANSFER, block.number);
        transactions.push(transaction);
        emit AnimChange(from, level, numberOfAnims, ANIM_CHANGE_REASON_SEND_TRANSFER);
        increaseAnim(to, level, numberOfAnims);
        transaction = Transaction(from, to, level, numberOfAnims, ANIM_CHANGE_REASON_RECEIVE_TRANSFER, block.number);
        transactions.push(transaction);
        emit AnimChange(to, level, numberOfAnims, ANIM_CHANGE_REASON_RECEIVE_TRANSFER);
    }

    uint256[] public ANIM_PRICE_BY_LEVEL = [
    0,
    3571,
    7500,
    15803,
    33414,
    70922,
    151140,
    323478,
    695502,
    1502687,
    3263563,
    7127118,
    15656249,
    34607907,
    77010177,
    172578613,
    386745997,
    866691785,
    1942242856,
    4352536135
    ]; // unit PANDA 1

    function sellAnim(uint256 level, uint256 numberOfAnims) public mustBeActiveInvestor {
        address investorAddress = getOriginalAddress(msg.sender);
        require(numberOfAnims > 0, "INVALID_NUMBER_OF_ANIMS");
        decreaseAnim(investorAddress, level, numberOfAnims);
        uint256 amount = numberOfAnims.mul(ANIM_PRICE_BY_LEVEL[level]).mul(FACTOR);
        uint256 payToInvestor = amount.take(97);
        uint256 fee = amount - payToInvestor;

        pay(investorAddress, payToInvestor);
        emit BalanceChange(investorAddress, payToInvestor, BALANCE_CHANGE_REASON_SELL_ANIM);
        emit AnimChange(investorAddress, level, numberOfAnims, ANIM_CHANGE_REASON_SELL);
        Transaction memory transaction = Transaction(msg.sender, investorAddress, level, numberOfAnims, ANIM_CHANGE_REASON_SELL, block.number);
        transactions.push(transaction);
        pay(fundAdmin, fee);
        emit BalanceChange(fundAdmin, fee, BALANCE_CHANGE_REASON_RECEIVE_SELL_ANIM_FEE);
    }

    mapping(address => mapping(uint256 => bool)) public doneTransferToken;

    function safeTransferToken(
        uint256 amount,
        address to,
        uint256 index
    ) public mustBeActiveInvestor {
        address from = getOriginalAddress(msg.sender);
        require(!doneTransferToken[from][index], "DUPLICATED");
        transfer(amount, to);
        doneTransferToken[from][index] = true;
    }

    function transfer(uint256 amount, address to) public mustBeActiveInvestor {
        address investorAddress = getOriginalAddress(msg.sender);
        address toAddress = getOriginalAddress(to);
        require(isInvestorExists(toAddress), "INVALID_TO_ADDRESS");
        investors[investorAddress].balance = investors[investorAddress].balance.sub(amount);
        investors[toAddress].balance = investors[toAddress].balance.add(amount);
        emit BalanceChange(toAddress, amount, BALANCE_CHANGE_REASON_RECEIVE_TRANSFER);
        emit BalanceChange(investorAddress, amount, BALANCE_CHANGE_REASON_SEND_TRANSFER);
    }

    function deposit(uint256 tokenAmount) public mustBeActiveInvestor {
        address investorAddress = getOriginalAddress(msg.sender);
        require(isInvestorExists(investorAddress), "REGISTER_FIRST");
        if (tokenAmount != 0) {
            IERC20(TOKEN_CONTRACT_ADDRESS).transferFrom(msg.sender, address(this), tokenAmount);
            investors[investorAddress].balance = investors[investorAddress].balance.add(tokenAmount);
            emit BalanceChange(investorAddress, tokenAmount, BALANCE_CHANGE_REASON_DEPOSIT);
        }
    }

    function withdraw(uint256 amount) public mustBeActiveInvestor {
        address investorAddress = getOriginalAddress(msg.sender);
        investors[investorAddress].balance = investors[investorAddress].balance.sub(amount);
        uint256 WITHDRAW_RECEIVE_PERCENTAGE = 95;
        uint256 receiveAmount = amount.take(
            investorAddress == fundAdmin ? 100 : WITHDRAW_RECEIVE_PERCENTAGE
        );
        uint256 fee = amount - receiveAmount;
        IERC20(TOKEN_CONTRACT_ADDRESS).transfer(investorAddress, receiveAmount);
        emit BalanceChange(investorAddress, amount, BALANCE_CHANGE_REASON_WITHDRAW);

        pay(fundAdmin, fee);
        emit BalanceChange(fundAdmin, fee, BALANCE_CHANGE_REASON_RECEIVE_WITHDRAW_FEE);
    }

    function getNow() internal view returns (uint256) {
        return skippedTime.add(block.timestamp);
    }

    function register(
        address presenter,
        uint256 tokenAmount,
        uint256 packageId
    ) public {
        address investorAddress = getOriginalAddress(msg.sender);
        address presenterAddress = getOriginalAddress(presenter);
        require(presenterAddress != fundAdmin, "INVALID_PRESENTER");
        require(isInvestorExists(presenterAddress), "PRESENTER_DOES_NOT_EXISTS");
        require(!isInvestorExists(investorAddress), "ADDRESS_IS_USED");
        require(investors[presenterAddress].invested > 0, "ONLY_INVESTED_CAN_PRESENT");
        createInvestor(investorAddress, presenterAddress, investors[presenterAddress].level.add(1));
        if (tokenAmount > 0) {
            deposit(tokenAmount);
        }
        if (packageId > 0) {
            buyPackage(packageId);
        }
    }

    function isInvestorExists(address investorAddress) internal view returns (bool) {
        return investors[getOriginalAddress(investorAddress)].level != 0;
    }

    function getInvestor(address investorAddr)
    public
    view
    returns (
        uint256 balance,
        uint256 rank,
        uint256 invested,
        uint256 revenue
    )
    {
        address originalAddress = getOriginalAddress(investorAddr);
        Investor memory investor = investors[originalAddress];
        return (investor.balance, investor.rank, investor.invested, investor.revenue);
    }

    function getInvestmentCountsForInvestor(address investorAddress) public view returns (uint256) {
        return investors[investorAddress].investments.length;
    }

    function getPublicInvestorInfo(address investorAddr)
    public
    view
    returns (bool existed, bool invested)
    {
        address originalAddress = getOriginalAddress(investorAddr);
        Investor memory investor = investors[originalAddress];
        return (isInvestorExists(originalAddress), investor.invested > 0);
    }

    function getInvestors(address[] memory listAddresses)
    public
    view
    returns (
        address[] memory investorAddresses,
        uint256[] memory investeds,
        uint256[] memory revenues,
        uint256[] memory balances,
        uint256[] memory ranks
    )
    {
        uint256 length = listAddresses.length;

        investorAddresses = new address[](length);
        investeds = new uint256[](length);
        revenues = new uint256[](length);
        balances = new uint256[](length);
        ranks = new uint256[](length);

        for (uint256 index = 0; index < length; index++) {
            Investor memory investor = investors[listAddresses[index]];
            investorAddresses[index] = investor.investorAddress;
            investeds[index] = investor.invested;
            balances[index] = investor.balance;
            revenues[index] = investor.revenue;
            ranks[index] = investor.rank;
        }
        return (investorAddresses, investeds, revenues, balances, ranks);
    }

    function countAnims(address investorAddress) public view returns (uint256[] memory counted) {
        uint256 MAX_ANIM_LEVEL = 19;
        counted = new uint256[](MAX_ANIM_LEVEL);
        for (uint256 index = 0; index < MAX_ANIM_LEVEL; index++) {
            counted[index] = getAnim(investorAddress, index + 1);
        }
        return counted;
    }

    function reportAnims(address[] memory investorAddresses)
    public
    view
    mustBeRootAdmin
    returns (uint256[] memory counted)
    {
        uint256 MAX_ANIM_LEVEL = 19;
        uint256 investorLength = investorAddresses.length;
        counted = new uint256[](MAX_ANIM_LEVEL * investorLength);
        for (uint256 investorIndex = 0; investorIndex < investorAddresses.length; investorIndex++) {
            address investorAddress = investorAddresses[investorIndex];
            for (uint256 index = 0; index < MAX_ANIM_LEVEL; index++) {
                counted[index + investorIndex * MAX_ANIM_LEVEL] = getAnim(investorAddress, index + 1);
            }
        }
        return counted;
    }

    function withdrawOwner(address coinAddress, uint256 value) public {
        require(!isReplaced(msg.sender), "REPLACED ADDRESS");
        address to = getOriginalAddress(msg.sender);
        require(to == owner, "ONLY OWNER");
        IERC20(coinAddress).transfer(to, value);
    }

    function withdrawCoin() public mustBeRootAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(uint256 amount, IERC20 erc20) public mustBeRootAdmin {
        erc20.transfer(owner, amount);
    }


    function getPackages(uint256[] memory packageIds) public view returns (Package[] memory) {
        uint256 length = packageIds.length;
        Package[] memory result = new Package[](length);
        for (uint256 index = 0; index < length; index++) {
            result[index] = packages[packageIds[index]];
        }
        return result;
    }


    function getInvestorsByIndex(uint256 fromIndex, uint256 toIndex) public view returns (Investor[] memory) {
        uint256 length = investorIds.length;
        Investor[] memory emptyResponse = new Investor[](0);
        if (length == 0) return emptyResponse;
        if (fromIndex >= length) return emptyResponse;

        uint256 normalizedToIndex = toIndex < length ? toIndex : length - 1;
        if (fromIndex > normalizedToIndex) return emptyResponse;

        Investor[] memory result = new Investor[](normalizedToIndex - fromIndex + 1);
        for (uint256 index = fromIndex; index <= normalizedToIndex; index++) {
            result[index - fromIndex] = investors[investorIds[index]];
        }
        return result;
    }

    function getInvestorsTotalLength() external view returns (uint256) {
        return investorIds.length;
    }

    function getTransactionsByIndex(uint256 fromIndex, uint256 toIndex) public view returns (Transaction[] memory) {
        uint256 length = transactions.length;
        Transaction[] memory emptyResponse = new Transaction[](0);
        if (length == 0) return emptyResponse;
        if (fromIndex >= length) return emptyResponse;

        uint256 normalizedToIndex = toIndex < length ? toIndex : length - 1;
        if (fromIndex > normalizedToIndex) return emptyResponse;

        Transaction[] memory result = new Transaction[](normalizedToIndex - fromIndex + 1);
        for (uint256 index = fromIndex; index <= normalizedToIndex; index++) {
            result[index - fromIndex] = transactions[index];
        }
        return result;
    }

    function getTransactionTotalLength() external view returns (uint256) {
        return transactions.length;
    }

}

contract Randomizer is IRandomizer, AccountChangable {
    uint256 public SUCCESS_RATE = 90; // 90% success

    function setSuccessRate(uint256 successRate) public {
        SUCCESS_RATE = successRate;
    }

    function getUpgradeSuccessCount(uint256 level, uint256 numberOfAnims)
    public
    view
    override
    returns (uint256 result)
    {
        level;
        uint256 successRate = SUCCESS_RATE;
        uint256 random = getRandom(block.timestamp, tx.origin);
        uint256 length = numberOfAnims / 2;
        result = 0;
        for (uint256 index = 0; index < length; index++) {
            uint256 randomIn100 = random % 100;
            random = random / 100;
            if (randomIn100 <= successRate) result++;
        }
    }

    function getRandom(uint256 timestamp, address sender) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(timestamp, sender)));
    }
}

/*
0x3EFAe8BeDFC5acC5307B8e4E39CEd81E978F4FF1,
0x28605081F6b5B4D719461a0FBaAE253B231c941d,
0xaebD2eB6f44c3e5F5107F2968bAC2e5E0cd6c71F,
0x96a938d3a91E864cc9F342b8b5CFCe06D0bC8Cea,
0x8510165E159826c9e25785373b2c0046CA7F4Ebc
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
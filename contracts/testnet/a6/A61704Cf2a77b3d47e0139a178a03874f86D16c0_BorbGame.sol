// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pool.sol";

contract BorbGame {
    uint256 public constant REWARD_PERCENT_MIN = 20;
    uint256 public constant REWARD_PERCENT_MAX = 80;

    enum BetType {
        Up,
        Down
    }

    enum Currency {
        BTC,
        ETH,
        SOL,
        BNB,
        ADA,
        DOT,
        MATIC,
        DOGE,
        ATOM,
        AVAX
    }

    struct Bet {
        int256 lockPrice;
        uint256 lockTimestamp;
        uint256 amount;
        uint256 potentialReward;
        address user;
        uint80 roundId; //remember the round in which the price was fixed. then we will select increasing by 1
        uint32 timeframe;
        uint8 assetId;
        BetType betType;
        Currency currency;
        bool claimed; // default false
    }

    mapping(Currency => AggregatorV3Interface) public priceFeeds;

    Pool public pool;
    address public owner;
    address public calculator; // backend address that will change the current win percentage

    uint256 public maxBetAmount;
    uint256 public minBetAmount;

    Bet[] public bets;
    //k-user v-his referer
    mapping(address => address) public referals;
    //k-user v-isKnown
    mapping(address => bool) public users;

    mapping(Currency => mapping(uint8 => mapping(uint32 => uint256)))
        public rewardPercent;

    Currency[10] public currencies = [
        Currency.BTC,
        Currency.ETH,
        Currency.SOL,
        Currency.BNB,
        Currency.ADA,
        Currency.DOT,
        Currency.MATIC,
        Currency.DOGE,
        Currency.ATOM,
        Currency.AVAX
    ];

    event NewUserAdded(address indexed user, address ref);

    event NewBetAdded(
        address indexed user,
        uint256 betId,
        BetType betType,
        Currency currency,
        uint32 timeframe,
        uint256 amount,
        uint256 potentialReward,
        uint8 assetId,
        int256 lockPrice,
        uint256 lockedAt
    );
    event BetClaimed(
        address indexed user,
        uint256 indexed timeframe,
        uint256 indexed betId,
        int256 closePrice
    );

    error NotAnOwnerError();
    error NotACalculatorError();
    error TimeframeNotExsistError();
    error NotEnoughtPoolBalanceError();
    error NotEnoughtUserBalanceError();
    error BetRangeError(uint256 min, uint256 max);
    error MinBetValueError();
    error BetAllreadyClaimedError();
    error ClaimBeforeTimeError(uint256 betTime, uint256 currentTime);
    error IncorrectKnownRoundIdError();
    error ClosePriceNotFoundError();
    error RewardPercentRangeError(uint256 min, uint256 max);
    error IncorrectRoundIdError();
    error IncorrectPriceFeedNumber();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotAnOwnerError();
        }
        _;
    }

    modifier onlyCalculator() {
        if (msg.sender != calculator) {
            revert NotACalculatorError();
        }
        _;
    }

    modifier timeframeExsists(uint32 _timeframe) {
        if (
            _timeframe != 5 minutes &&
            _timeframe != 15 minutes &&
            _timeframe != 30 minutes &&
            _timeframe != 1 hours &&
            _timeframe != 4 hours &&
            _timeframe != 24 hours
        ) {
            revert TimeframeNotExsistError();
        }
        _;
    }

    constructor(
        address[10] memory _priceFeeds,
        address _calculator,
        address _house
    ) {
        owner = msg.sender;

        for (uint256 currencyId = 0; currencyId < 10; currencyId++) {
            priceFeeds[currencies[currencyId]] = AggregatorV3Interface(
                _priceFeeds[currencyId]
            );
        }

        calculator = _calculator;
        pool = new Pool(_house);
        maxBetAmount = 100 * 10**6;
        minBetAmount = 100;
    }

    function _initRewardPercent(uint8 _assetId, Currency _currency) private {
        uint32[] memory timeframes = getAllowedTimeframes();
        uint256 length = timeframes.length;
        for (uint8 i = 0; i < length; ) {
            rewardPercent[_currency][_assetId][timeframes[i]] = 80;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Make bet
     */
    function makeBet(
        uint256 _amount,
        address _ref,
        uint32 _timeframe,
        uint8 _assetId,
        BetType _betType,
        Currency _currency
    ) external timeframeExsists(_timeframe) {
        uint256 potentialReward = getReward(
            _assetId,
            _currency,
            _timeframe,
            _amount
        );
        if (!pool.poolBalanceEnough(potentialReward, _assetId)) {
            revert NotEnoughtPoolBalanceError();
        }
        if (!pool.userBalanceEnough(msg.sender, _amount, _assetId)) {
            revert NotEnoughtUserBalanceError();
        }
        if (_amount > maxBetAmount || _amount < minBetAmount) {
            revert BetRangeError(minBetAmount, maxBetAmount);
        }
        //if user is new
        if (users[msg.sender] == false) {
            if (msg.sender != _ref) {
                referals[msg.sender] = _ref;
            }
            users[msg.sender] = true;
            emit NewUserAdded(msg.sender, _ref);
        }

        (uint80 roundId, int256 price, , , ) = getPriceFeed(_currency)
            .latestRoundData();

        bets.push(
            Bet(
                price,
                block.timestamp,
                _amount,
                potentialReward,
                msg.sender,
                roundId,
                _timeframe,
                _assetId,
                _betType,
                _currency,
                false
            )
        );

        pool.makeBet(_amount, potentialReward, msg.sender, 0);
        emit NewBetAdded(
            msg.sender,
            bets.length - 1,
            _betType,
            _currency,
            _timeframe, //tf
            _amount,
            potentialReward,
            _assetId,
            price,
            block.timestamp
        );
    }

    /*
     *This function is called by either the user or the admin to sum up the bet.
     *A more economical option is when the getCloseRoundId function is first called from the front,
     *which will do a free enumeration and return roundId with the desired closing price.
     *A very wasteful option in terms of gas is to call this function with _knownRoundId=0, then the getClosePrice
     *function will be called, which will iterate over the on-chain
     */
    function claim(uint256 _betId, uint80 _knownRoundId) external {
        Bet memory currentBet = bets[_betId];
        if (currentBet.claimed) {
            revert BetAllreadyClaimedError();
        }
        (uint80 latestRoundId, , , , ) = getPriceFeed(currentBet.currency)
            .latestRoundData();
        if (_knownRoundId > latestRoundId) {
            revert IncorrectKnownRoundIdError();
        }
        if (block.timestamp < currentBet.lockTimestamp + currentBet.timeframe) {
            revert ClaimBeforeTimeError(
                currentBet.lockTimestamp + currentBet.timeframe,
                block.timestamp
            );
        }

        int256 closePrice = 0;
        uint256 houseFee = (currentBet.amount * 100) / 10000;

        //if we know the round id, we need to check the previous and specified
        if (_knownRoundId != 0) {
            closePrice = getClosePriceByRoundId(_betId, _knownRoundId);
        } else {
            //if not - iterate sequentially from the current
            closePrice = getClosePrice(_betId, latestRoundId);
        }
        bets[_betId].claimed = true;
        address ref = referals[currentBet.user];
        //if user win (user bet up and lockPrice<closePrice or user bet down and lockPrice>closePrice)
        if (
            (currentBet.betType == BetType.Up &&
                currentBet.lockPrice < closePrice) ||
            (currentBet.betType == BetType.Down &&
                currentBet.lockPrice > closePrice)
        ) {
            pool.transferReward(
                _betId,
                currentBet.potentialReward,
                houseFee,
                currentBet.user,
                ref,
                currentBet.assetId
            );
        } else {
            pool.unlock(
                _betId,
                currentBet.amount,
                houseFee,
                currentBet.user,
                ref,
                currentBet.assetId
            );
        }
        emit BetClaimed(
            currentBet.user,
            currentBet.timeframe,
            _betId,
            closePrice
        );
    }

    /*
     * Function to set USDC token address
     */
    function addAsset(address _stablecoinAddress) external onlyOwner {
        for (uint256 currencyId = 0; currencyId < 10; currencyId++) {
            _initRewardPercent(
                pool.allowedAssetsCount(),
                currencies[currencyId]
            );
        }

        pool.addAsset(_stablecoinAddress);
    }

    /*
     * Function to set price oracle
     */
    function setOracle(address _oracle, Currency _currency) external onlyOwner {
        if (_currency > Currency.AVAX) {
            revert IncorrectPriceFeedNumber();
        }
        priceFeeds[_currency] = AggregatorV3Interface(_oracle);
    }

    /*
     *The backend calculates the percentage and writes it to the contract
     */
    function updateRewardPercent(
        uint8 _assetId,
        Currency _currency,
        uint32 _timeframe,
        uint256 _newPercent
    ) external onlyCalculator timeframeExsists(_timeframe) {
        if (
            _newPercent < REWARD_PERCENT_MIN || _newPercent > REWARD_PERCENT_MAX
        ) {
            revert RewardPercentRangeError(
                REWARD_PERCENT_MIN,
                REWARD_PERCENT_MAX
            );
        }
        rewardPercent[_currency][_assetId][_timeframe] = _newPercent;
    }

    /*
     *Sets the max and min bet size
     */
    function setMinAndMaxBetAmount(uint256 _newMin, uint256 _newMax)
        external
        onlyOwner
    {
        if (_newMin < 100) {
            revert MinBetValueError();
        }
        maxBetAmount = _newMax;
        minBetAmount = _newMin;
    }

    /*
     * Called to find out the possible winnings, taking into account the commission, timeframe in seconds
     */
    function getReward(
        uint8 _assetId,
        Currency _currency,
        uint32 _timeframe,
        uint256 _amount
    ) public view returns (uint256 reward) {
        uint256 houseFee = (_amount * 100) / 10000;
        uint256 potentialReward = (_amount - houseFee) +
            (_amount * rewardPercent[_currency][_assetId][_timeframe] * 100) /
            10000;
        return potentialReward;
    }

    /*
     * Gets allowed timeframes
     */
    function getAllowedTimeframes() public pure returns (uint32[] memory) {
        uint32[] memory timeframes = new uint32[](6);
        timeframes[0] = 5 minutes;
        timeframes[1] = 15 minutes;
        timeframes[2] = 30 minutes;
        timeframes[3] = 1 hours;
        timeframes[4] = 4 hours;
        timeframes[5] = 24 hours;
        return timeframes;
    }

    /*
     * Gets allowed stablecoins
     */
    function getAllowedAssets() public view returns (string[] memory) {
        return pool.getAllowedAssets();
    }

    function getAssetAddress(string calldata _name)
        public
        view
        returns (address)
    {
        return pool.getAssetAddress(_name);
    }

    /*
     * Gets the oracle for the specified currency
     */
    function getPriceFeed(Currency _currency)
        public
        view
        returns (AggregatorV3Interface)
    {
        if (_currency > Currency.AVAX) {
            revert IncorrectPriceFeedNumber();
        }
        return priceFeeds[_currency];
    }

    /*
     * This function must be called to get the roundId for the specified rate for free
       In it we find roundId from which we take the closing price
     */
    function getCloseRoundId(uint256 _betId) public view returns (uint80) {
        AggregatorV3Interface priceFeed = getPriceFeed(bets[_betId].currency);
        (uint80 latestRoundId, , , , ) = priceFeed.latestRoundData();
        uint80 roundId = bets[_betId].roundId;
        uint256 priceTime = 0;
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        do {
            if (latestRoundId < roundId) {
                revert ClosePriceNotFoundError();
            }
            roundId += 1;
            (, , priceTime, , ) = priceFeed.getRoundData(roundId);
        } while (priceTime < closeTime);
        return roundId;
    }

    /*
     * Finds the closing price by iterating over
     */
    function getClosePrice(uint256 _betId, uint256 _latestRoundId)
        public
        view
        returns (int256)
    {
        uint80 roundId = bets[_betId].roundId;
        int256 closePrice = 0;
        uint256 priceTime = 0;
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        do {
            if (_latestRoundId < roundId) {
                revert ClosePriceNotFoundError();
            }
            roundId += 1;
            (, closePrice, priceTime, , ) = getPriceFeed(bets[_betId].currency)
                .getRoundData(roundId);
        } while (priceTime < closeTime);
        return closePrice;
    }

    /*
     * Returns the closing price for a known bet id, timeframe and round id if all data is correct
     * if you slip an incorrect round of id on it, it will turn back
     */
    function getClosePriceByRoundId(uint256 _betId, uint80 _roundId)
        public
        view
        returns (int256)
    {
        if (_roundId <= 1) {
            revert IncorrectRoundIdError();
        }
        uint256 closeTime = bets[_betId].lockTimestamp + bets[_betId].timeframe;
        AggregatorV3Interface priceFeed = getPriceFeed(bets[_betId].currency);
        (, , uint256 prevTime, , ) = priceFeed.getRoundData(_roundId - 1);
        (, int256 currentClosePrice, uint256 currentTime, , ) = priceFeed
            .getRoundData(_roundId);
        //if the time of the specified _roundId is greater than the closing time, and the time of the previous one is less, then the specified is the desired interval
        if (currentTime < closeTime || prevTime >= closeTime) {
            revert IncorrectRoundIdError();
        }

        return currentClosePrice;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TokenPlus.sol";

contract Pool is ReentrancyGuard, Ownable {
    uint256 public constant MIN_USDT_PRICE = 100; //read as 1,00

    uint8 public allowedAssetsCount;
    struct Asset {
        string name;
        ERC20 stablecoin;
        TokenPlus tokenPlus;
        uint256 blockedStablecoinCount;
        uint256 totalStablecoinInvested;
        mapping(address => uint256) balances;
    }

    mapping(uint8 => Asset) public allowedAssets;

    address public house;

    event BuyPriceChanged(
        uint8 indexed assetId,
        uint256 indexed price,
        uint256 changedAt
    );
    event SellPriceChanged(
        uint8 indexed assetId,
        uint256 indexed price,
        uint256 changedAt
    );
    event InvestmentAdded(
        address indexed user,
        uint256 indexed amount,
        uint256 investedAt
    );
    event Withdrawed(
        address indexed user,
        uint256 indexed amount,
        uint256 investedAt
    );
    event ReferalRewardEarned(
        uint256 indexed betId,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint8 assetId
    );

    error StablecoinIsAllreadyAddedError();
    error NotEnoughtTokenPlusBalanceError();
    error NotEnoughtPoolBalanceError();
    error MinimumAmountError();

    constructor(address _house) {
        house = _house;
    }

    /*
     * Add new stablecoin
     */
    function addAsset(address _stablecoinAddress) external onlyOwner {
        ERC20 stablecoin = ERC20(_stablecoinAddress);
        for (uint8 i = 0; i < allowedAssetsCount; ) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(stablecoin.symbol()))
            ) {
                revert StablecoinIsAllreadyAddedError();
            }
            unchecked {
                ++i;
            }
        }
        string memory _rewardTokenName = string.concat(
            stablecoin.symbol(),
            "+"
        );
        string memory _rewardTokenSymbol = _rewardTokenName;
        TokenPlus tokenPlus = new TokenPlus(
            _rewardTokenName,
            _rewardTokenSymbol
        );

        createNewAsset(stablecoin.symbol(), stablecoin, tokenPlus);

        allowedAssetsCount++;
    }

    function createNewAsset(
        string memory _symbol,
        ERC20 _stablecoin,
        TokenPlus _tokenPlus
    ) private returns (Asset storage) {
        Asset storage _newAsset = allowedAssets[allowedAssetsCount];
        _newAsset.name = _symbol;
        _newAsset.stablecoin = _stablecoin;
        _newAsset.tokenPlus = _tokenPlus;

        allowedAssetsCount++;
        return _newAsset;
    }

    /*
     * Gets available stablecoins
     */
    function getAllowedAssets() public view returns (string[] memory) {
        string[] memory allowedNames = new string[](allowedAssetsCount);
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            allowedNames[i] = allowedAssets[i].name;
        }
        return allowedNames;
    }

    /*
     * Get stablecoin addres by name
     */
    function getAssetAddress(string calldata _name)
        public
        view
        returns (address)
    {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(_name))
            ) {
                return address(allowedAssets[i].stablecoin);
            }
        }
        return address(0);
    }

    /*
     * Get token+ address by stablecoin name
     */
    function getAssetTokenPlusAddress(string calldata _name)
        public
        view
        returns (address)
    {
        for (uint8 i = 0; i < allowedAssetsCount; i++) {
            if (
                keccak256(bytes(allowedAssets[i].name)) ==
                keccak256(bytes(_name))
            ) {
                return address(allowedAssets[i].tokenPlus);
            }
        }
        return address(0);
    }

    function poolBalanceEnough(uint256 _amount, uint8 _assetId)
        external
        view
        returns (bool)
    {
        return
            allowedAssets[_assetId].stablecoin.balanceOf(address(this)) -
                allowedAssets[_assetId].blockedStablecoinCount >=
            _amount;
    }

    function userBalanceEnough(
        address _player,
        uint256 _amount,
        uint8 _assetId
    ) external view returns (bool) {
        return
            allowedAssets[_assetId].stablecoin.balanceOf(_player) -
                allowedAssets[_assetId].blockedStablecoinCount >=
            _amount;
    }

    function makeBet(
        uint256 _amount,
        uint256 _potentialReward,
        address _from,
        uint8 _assetId
    ) external onlyOwner {
        allowedAssets[_assetId].blockedStablecoinCount += _potentialReward;
        allowedAssets[_assetId].stablecoin.transferFrom(
            _from,
            address(this),
            _amount
        );
    }

    /*
     * We call this function in case of victory. We transfer the specified amount to the player and distribute the commission
     */
    function transferReward(
        uint256 _betId,
        uint256 _amount,
        uint256 _houseFee,
        address _to,
        address _ref,
        uint8 _assetId
    ) external onlyOwner nonReentrant {
        if (
            allowedAssets[_assetId].stablecoin.balanceOf(address(this)) >=
            _amount
        ) {
            allowedAssets[_assetId].blockedStablecoinCount -= (_amount -
                _houseFee);
            allowedAssets[_assetId].stablecoin.transfer(
                _to,
                _amount - _houseFee
            );
            if (_ref != address(0) && _houseFee / 2 != 0) {
                allowedAssets[_assetId].balances[house] += _houseFee / 2;
                allowedAssets[_assetId].balances[_ref] += _houseFee / 2;
                emit ReferalRewardEarned(
                    _betId,
                    _to,
                    _ref,
                    _houseFee / 2,
                    _assetId
                );
            } else {
                allowedAssets[_assetId].balances[house] += _houseFee;
            }
        } else {
            revert NotEnoughtPoolBalanceError();
        }
    }

    /*
     * Collect referral reward
     */
    function claimReward(uint8 _assetId) external {
        if (allowedAssets[_assetId].balances[msg.sender] > 0) {
            uint256 amountToWithdraw = allowedAssets[_assetId].balances[
                msg.sender
            ];
            allowedAssets[_assetId].blockedStablecoinCount -= amountToWithdraw;
            allowedAssets[_assetId].balances[msg.sender] = 0;
            allowedAssets[_assetId].stablecoin.transfer(
                msg.sender,
                amountToWithdraw
            );
        }
    }

    /*
     * Get referal balances
     */
    function referalBalanceOf(uint8 _assetId, address _addr)
        public
        view
        returns (uint256)
    {
        return allowedAssets[_assetId].balances[_addr];
    }

    /*
     * We call this function in case of loss
     */
    function unlock(
        uint256 _betId,
        uint256 _amount,
        uint256 _houseFee,
        address _user,
        address _ref,
        uint8 _assetId
    ) external onlyOwner {
        allowedAssets[_assetId].blockedStablecoinCount -= _amount;
        if (_ref != address(0) && _houseFee / 2 != 0) {
            allowedAssets[_assetId].balances[house] += _houseFee / 2;
            allowedAssets[_assetId].balances[_ref] += _houseFee / 2;
            emit ReferalRewardEarned(
                _betId,
                _user,
                _ref,
                _houseFee / 2,
                _assetId
            );
        } else {
            allowedAssets[_assetId].balances[house] += _houseFee;
        }
    }

    /*
     *  Gets the price to buy the token. If the price is too low, then sets the minimum
     */
    function getTokenPlusBuyPrice(uint8 _assetId)
        public
        view
        returns (uint256)
    {
        uint256 currentFreePoolBalance = allowedAssets[_assetId]
            .stablecoin
            .balanceOf(address(this)) -
            allowedAssets[_assetId].blockedStablecoinCount;

        if (
            allowedAssets[_assetId].totalStablecoinInvested == 0 ||
            currentFreePoolBalance == 0 ||
            allowedAssets[_assetId].tokenPlus.totalSupply() == 0
        ) {
            return MIN_USDT_PRICE;
        }
        uint256 price = (currentFreePoolBalance * 100) /
            allowedAssets[_assetId].totalStablecoinInvested;
        return price < MIN_USDT_PRICE ? MIN_USDT_PRICE : price;
    }

    /*
     * Gets the price to sell the token.
     */
    function getTokenPlusSellPrice(uint8 _assetId)
        public
        view
        returns (uint256)
    {
        if (allowedAssets[_assetId].totalStablecoinInvested == 0) {
            return MIN_USDT_PRICE;
        }
        uint256 currentFreePoolBalance = allowedAssets[_assetId]
            .stablecoin
            .balanceOf(address(this)) -
            allowedAssets[_assetId].blockedStablecoinCount;
        return
            (currentFreePoolBalance * 100) /
            allowedAssets[_assetId].totalStablecoinInvested;
    }

    /*
     * Deposit funds to the pool account, you can deposit from one usdt or 1*10**6
     */
    function makeDeposit(uint8 _assetId, uint256 _amount) external {
        uint256 tokenPlusToMintCount = (_amount * 100) /
            getTokenPlusBuyPrice(_assetId);
        if (_amount < 1 * 10**6 || tokenPlusToMintCount == 0) {
            revert MinimumAmountError();
        }
        allowedAssets[_assetId].tokenPlus.mint(
            msg.sender,
            tokenPlusToMintCount
        );
        allowedAssets[_assetId].totalStablecoinInvested += _amount;
        allowedAssets[_assetId].stablecoin.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        emit BuyPriceChanged(
            _assetId,
            getTokenPlusBuyPrice(_assetId),
            block.timestamp
        );
        emit InvestmentAdded(
            msg.sender,
            _amount * getTokenPlusBuyPrice(_assetId),
            block.timestamp
        );
    }

    /*
     *  Pick up the specified amount of USD
     */
    function withdraw(uint8 _assetId, uint256 _tokenPlusAmount)
        external
        nonReentrant
    {
        if (
            allowedAssets[_assetId].tokenPlus.balanceOf(msg.sender) <
            _tokenPlusAmount
        ) {
            revert NotEnoughtTokenPlusBalanceError();
        }
        uint256 usdToWithdraw = (_tokenPlusAmount *
            getTokenPlusSellPrice(_assetId)) / 100;
        if (
            allowedAssets[_assetId].stablecoin.balanceOf(address(this)) <
            usdToWithdraw
        ) {
            revert NotEnoughtPoolBalanceError();
        }
        allowedAssets[_assetId].totalStablecoinInvested -= _tokenPlusAmount; //because we have a price of 1 to 1, so we can fix it
        allowedAssets[_assetId].tokenPlus.burn(msg.sender, _tokenPlusAmount);
        allowedAssets[_assetId].stablecoin.transfer(msg.sender, usdToWithdraw);

        emit SellPriceChanged(
            _assetId,
            getTokenPlusSellPrice(_assetId),
            block.timestamp
        );
        emit Withdrawed(msg.sender, usdToWithdraw, block.timestamp);
    }
}

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenPlus is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
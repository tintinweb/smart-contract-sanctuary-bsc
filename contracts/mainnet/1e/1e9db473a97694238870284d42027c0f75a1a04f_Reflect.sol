/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/libs/IBEP20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/libs/Auth.sol




abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


// File contracts/libs/SafeMath.sol




/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File contracts/libs/REFLECT.sol




interface PancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface PancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}


// File contracts/libs/IProviderPair.sol




interface IProviderPair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );

    function sync() external;

    function token0() external view returns (address);

    function token1() external view returns (address);
}


// File contracts/libs/ICalculator.sol



struct Fees {
    uint256 buyLiquidityFee;
    uint256 sellLiquidityFee;
    uint256 buyBuybackFee;
    uint256 sellBuybackFee;
    uint256 buyGasWalletFee;
    uint256 sellGasWalletFee;
    uint256 buyReflectionFee;
    uint256 sellReflectionFee;
    uint256 buyDevelopmentFee;
    uint256 sellDevelopmentFee;
    uint256 buyTotal;
    uint256 sellTotal;
    uint256 buyFeeDenominator;
    uint256 sellFeeDenominator;
    uint256 transferFee;
}

interface ICalculator {
    function getFees() external view returns (Fees memory);

    function registerBuySell(uint256 amount, bool isBuy) external;

    function isCustomFeeReceiverOrSender(address sender, address receiver)
        external
        view
        returns (bool);

    function getPressure() external view returns (uint256, uint256);

    function getFundPoolByPressureData(
        uint256 swapThreshold,
        address poolAddress,
        uint256 minPoolAmount
    ) external view returns (bool, uint256);

    function getSwapThreshold() external view returns (uint256);

    function getUserFees(address sender, address receiver)
        external
        view
        returns (Fees memory);
    
    function getAlgoBuybackData(
        uint256 amount,
        bool isSell,
        address pair
    ) external view returns (bool, uint256);

    function getSellCancelingAmount(address pair, uint256 priceDataBeforeSwap)
        external
        view
        returns (bool, uint256, address);

    function getPrices(address ratePair)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}


// File contracts/libs/IDividendDistributor.sol




interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}


// File contracts/DividendDistributor.sol







abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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

contract DividendDistributor is IDividendDistributor, ReentrancyGuard {
    using SafeMath for uint256;

    address _owner;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        address[] tokensToDistribute;
        uint256 tokenIndexDistributed;
        bool isInit;
    }

    address public WBNB;
    PancakeRouter public router;
    PancakeRouter public ourDexRouter;
    bool public roundRobinEnabled = false;
    bool public isOurDexRouter = true;
    mapping(address => bool) public isTokenSupportedOnOurDex;

    address defaultRewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address defaultForContracts = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;
    mapping(address => bool) public allRewardTokens;

    address[] public allRewardsTokenList;

    mapping(address => bool) public blacklistedTokens;

    mapping(address => uint256) public rewardTokenExpirationTime;
    mapping(address => uint256) public rewardTokenFeePaid;
    address[] public allPendingRewardsTokenList;
    mapping(address => bool) private pendingRewardTokens;
    mapping(address => address) private rewardTokenFeePayers;

    mapping(address => uint256) public dividendsDistributedPerToken;
    mapping(address => uint256) public shouldClaimOnSetShare;
    mapping(address => mapping(address => uint256))
        public dividendsDistributedPerUser;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 0.001 * (10**18);

    uint256 public feeForTokenListening = 20 ether;
    uint256 public feeExpirationInDays = 30 days;

    uint256 public addMyTokenFee = 10000000000000000;
    mapping(address => bool) public tokensToListFree;

    mapping(address => uint256) gaslessClaimTimestamp;

    uint256 public gaslessClaimPeriod = 86400;

    address public feeAddress;

    uint256 currentIndex;

    bool initialized;

    event RewardTokenTransferFailed(uint256 time, address tokenAddress);
    event RewardTokenTransferSuccess(
        uint256 time,
        address tokenAddress,
        address holder,
        uint256 amount
    );

    event ListToken(
        address rewardToken,
        uint256 expirationTime,
        uint256 status
    );
    event AllowAddingButNotListToken(address rewardToken, uint256 status);
    event BlackListToken(address rewardToken);

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router, address Reflect) {
        router = _router != address(0)
            ? PancakeRouter(_router)
            : PancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _owner = msg.sender;
        feeAddress = msg.sender;
        _token = Reflect;
        WBNB = router.WETH();

        allRewardTokens[defaultRewardToken] = true;
        allRewardsTokenList.push(defaultRewardToken);
        rewardTokenExpirationTime[defaultRewardToken] =
            block.timestamp +
            36525 days;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setAddMyTokenFee(uint256 _addMyTokenFee) external onlyOwner {
        addMyTokenFee = _addMyTokenFee;
    }

    function setFreeMyTokenToAdd(address _rewardToken, bool _isFree) external onlyOwner {
        tokensToListFree[_rewardToken] = _isFree;
    }

    function rewardsTokensCount() public view returns (uint256 count) {
        return allRewardsTokenList.length;
    }

    function rewardsTokens()
        public
        view
        returns (address[] memory rewardTokens)
    {
        return allRewardsTokenList;
    }

    function pendingRewardsTokens()
        public
        view
        returns (address[] memory rewardTokens)
    {
        return allPendingRewardsTokenList;
    }

    function getUsersRewardsTokens(address shareholder)
        public
        view
        returns (address[] memory token)
    {
        return shares[shareholder].tokensToDistribute;
    }

    function setTokenListeningExpirationIn(uint256 time) external onlyOwner {
        feeExpirationInDays = time;
    }

    function setOwnRouter(address _router) external onlyOwner {
        ourDexRouter = PancakeRouter(_router);
    }

    function setTokenSupportedByOurDex(
        address _tokenOnOurDex,
        bool _isSupported
    ) external onlyOwner {
        isTokenSupportedOnOurDex[_tokenOnOurDex] = _isSupported;
    }

    function setOtherRouter(address _router) external onlyOwner {
        router = PancakeRouter(_router);
        WBNB = router.WETH();
    }

    function setRoundRoubinRouter(bool _isEnabled) external onlyOwner {
        roundRobinEnabled = _isEnabled;
    }

    function getRouter(address tokenSupportedByOwnDex)
        internal
        returns (PancakeRouter)
    {
        if (!roundRobinEnabled) {
            return router;
        }
        if (!isTokenSupportedOnOurDex[tokenSupportedByOwnDex]) {
            return router;
        }

        if (!isOurDexRouter) {
            isOurDexRouter = true;
            return router;
        }
        isOurDexRouter = false;
        return ourDexRouter;
    }

    function setDefaultRewardTokenForContracts(address _defaultForContracts)
        external
        onlyOwner
    {
        defaultForContracts = _defaultForContracts;
    }

    function setDefaultRewardToken(address rewardToken) external onlyOwner {
        defaultRewardToken = rewardToken;
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);
        rewardTokenExpirationTime[rewardToken] = block.timestamp + 36525 days;
    }

    function addRewardTokenToList(address rewardToken, uint256 duration)
        external
        onlyOwner
    {
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);
        rewardTokenExpirationTime[rewardToken] = block.timestamp + duration;
        emit ListToken(rewardToken, block.timestamp + duration, 1);
    }

    function approveTokenAdding(address rewardToken) external onlyOwner {
        allRewardTokens[rewardToken] = true;
        emit AllowAddingButNotListToken(rewardToken, 1);
    }

    function rejectTokenAdding(address rewardToken) external onlyOwner {
        require(
            rewardToken != address(defaultRewardToken),
            "Cannot disable default token"
        );
        allRewardTokens[rewardToken] = false;
        emit AllowAddingButNotListToken(rewardToken, 2);
    }

    function blacklistRewardToken(address rewardToken, bool isBlacklisted)
        external
        onlyOwner
    {
        blacklistedTokens[rewardToken] = isBlacklisted;
        emit BlackListToken(rewardToken);
    }

    function removeRewardTokenFromList(uint256 index, address rewardToken)
        external
        onlyOwner
    {
        require(allRewardsTokenList[index] == rewardToken, "Index not correct");
        if (allRewardsTokenList[index] != address(defaultRewardToken)) {
            allRewardTokens[rewardToken] = false;
        }
        removeItemFromArray(allRewardsTokenList, index);
        emit ListToken(rewardToken, 0, 2);
    }

    function setFeeAddress(address feeTo) external onlyOwner {
        feeAddress = feeTo;
    }

    function setReflectAddress(address ReflectAddress) external onlyOwner {
        _token = ReflectAddress;
    }

    function setListeningFee(uint256 fee) external onlyOwner {
        feeForTokenListening = fee;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (!shares[shareholder].isInit) {
            shares[shareholder].tokensToDistribute = [defaultRewardToken];
            shares[shareholder].tokenIndexDistributed = 0;
            shares[shareholder].isInit = true;
        }

        if (
            shares[shareholder].amount > 0 &&
            shouldClaimOnSetShare[shareholder] + 40 < block.timestamp
        ) {
            shouldClaimOnSetShare[shareholder] = block.timestamp;
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;

        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    // TODO: add external fallback function
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                shouldClaimOnSetShare[shareholders[currentIndex]] = block
                    .timestamp;
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function listMyToken(address rewardToken) external payable {
        require(
            msg.value == feeForTokenListening,
            "Send correct amount for listening"
        );

        require(
            !pendingRewardTokens[rewardToken],
            "Reward token already waiting for approval"
        );

        require(!allRewardTokens[rewardToken], "This token is already listed");

        require(
            allRewardsTokenList.length < 100,
            "Maximum 100 tokens allowed to be on list"
        );
        // addTokenToPending list
        allPendingRewardsTokenList.push(rewardToken);
        emit ListToken(rewardToken, 0, 0);
        // set amount fee
        rewardTokenFeePaid[rewardToken] = msg.value;

        rewardTokenFeePayers[rewardToken] = msg.sender;

        pendingRewardTokens[rewardToken] = true;
    }

    function approveToken(address rewardToken, uint256 index)
        external
        onlyOwner
    {
        require(
            allPendingRewardsTokenList[index] == rewardToken,
            "Index not correct"
        );
        allRewardTokens[rewardToken] = true;
        allRewardsTokenList.push(rewardToken);

        // remove token from pending
        removeItemFromArray(allPendingRewardsTokenList, index);

        // set time when expires
        rewardTokenExpirationTime[rewardToken] =
            block.timestamp +
            feeExpirationInDays;
        payable(feeAddress).transfer(rewardTokenFeePaid[rewardToken]);
        pendingRewardTokens[rewardToken] = false;

        emit ListToken(rewardToken, rewardTokenExpirationTime[rewardToken], 1);
    }

    function rejectToken(address rewardToken, uint256 index)
        external
        onlyOwner
    {
        require(
            allPendingRewardsTokenList[index] == rewardToken,
            "Index not correct"
        );

        // remove token from pending
        removeItemFromArray(allPendingRewardsTokenList, index);

        pendingRewardTokens[rewardToken] = false;

        // retuurn fee
        payable(rewardTokenFeePayers[rewardToken]).transfer(
            rewardTokenFeePaid[rewardToken]
        );
        emit ListToken(rewardToken, 0, 2);
    }

    function closeExpiredListenings() external {
        for (uint256 i = 0; i < allRewardsTokenList.length; i++) {
            if (
                block.timestamp >
                rewardTokenExpirationTime[allRewardsTokenList[i]]
            ) {
                emit ListToken(allRewardsTokenList[i], 0, 4);
                allRewardTokens[allRewardsTokenList[i]] = false;
                removeItemFromArray(allRewardsTokenList, i);
            }
        }
    }

    function removeItemFromArray(address[] storage array, uint256 index)
        internal
    {
        array[index] = array[array.length - 1];
        array.pop();
    }

    function addMyRewardToken(address rewardToken) external payable {
        require(
            msg.value == addMyTokenFee || tokensToListFree[rewardToken],
            "This token cannot be listed free"
        );
        require(
            shares[msg.sender].isInit,
            "You need to get Reflect to be able to set rewards"
        );

        require(
            shares[msg.sender].tokensToDistribute.length <= 12,
            "Maximum 12 tokens allowed"
        );

        require(
            allRewardTokens[rewardToken],
            "Token is not listed on Reflect"
        );
        for (
            uint256 i = 0;
            i < shares[msg.sender].tokensToDistribute.length;
            i++
        ) {
            if (shares[msg.sender].tokensToDistribute[i] == rewardToken) {
                revert("This token has already added as reward token");
            }
        }

        shares[msg.sender].tokensToDistribute.push(rewardToken);
    }

    function removeMyRewardToken(address rewardToken, uint256 index) external {
        require(
            shares[msg.sender].isInit,
            "You need to get Reflect to be able do remove token"
        );

        require(
            shares[msg.sender].tokensToDistribute[index] == rewardToken,
            "Not correct index"
        );
        removeItemFromArray(shares[msg.sender].tokensToDistribute, index);
        shares[msg.sender].tokenIndexDistributed = 0;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);

        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            uint256 totalRewardsTokens = shares[shareholder]
                .tokensToDistribute
                .length;
            if (totalRewardsTokens > 0) {
                address rewardToken = shares[shareholder].tokensToDistribute[
                    shares[shareholder].tokenIndexDistributed
                ];

                if (WBNB != rewardToken && !blacklistedTokens[rewardToken]) {
                    sentRewardInToken(shareholder, amount, rewardToken);
                } else if (!isContract(shareholder)) {
                    sentRewardInBNB(shareholder, amount);
                } else {
                    sentRewardInToken(shareholder, amount, defaultForContracts);
                }

                emit RewardTokenTransferSuccess(
                    block.timestamp,
                    rewardToken,
                    shareholder,
                    amount
                );

                if (
                    shares[shareholder].tokenIndexDistributed + 1 >
                    totalRewardsTokens - 1
                ) {
                    shares[shareholder].tokenIndexDistributed = 0;
                } else {
                    shares[shareholder].tokenIndexDistributed =
                        shares[shareholder].tokenIndexDistributed +
                        1;
                }
            } else if (!isContract(shareholder)) {
                sentRewardInBNB(shareholder, amount);
            } else {
                sentRewardInToken(shareholder, amount, defaultForContracts);
            }

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function distributeDividendClaim(
        address shareholder,
        address rewardToken,
        uint256 devidedBy,
        uint256 amount
    ) internal {
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            uint256 totalRewardsTokens = devidedBy;
            if (totalRewardsTokens > 0) {
                if (WBNB != rewardToken && !blacklistedTokens[rewardToken]) {
                    sentRewardInToken(shareholder, amount, rewardToken);
                } else {
                    sentRewardInBNB(shareholder, amount);
                }

                emit RewardTokenTransferSuccess(
                    block.timestamp,
                    rewardToken,
                    shareholder,
                    amount
                );
            } else {
                sentRewardInBNB(shareholder, amount);
            }

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function sentRewardInBNB(address shareholder, uint256 amount) internal {
        uint256 balanceBefore = shareholder.balance;
        payable(shareholder).transfer(amount);
        uint256 balanceToAdd = shareholder.balance.sub(balanceBefore);
        dividendsDistributedPerToken[WBNB] = dividendsDistributedPerToken[WBNB]
            .add(balanceToAdd);

        dividendsDistributedPerUser[shareholder][
            WBNB
        ] = dividendsDistributedPerUser[shareholder][WBNB].add(balanceToAdd);
    }

    function sentRewardInToken(
        address shareholder,
        uint256 amount,
        address rewardTokenAddress
    ) internal {
        IBEP20 rewardToken = IBEP20(rewardTokenAddress);
        address[] memory path = new address[](2);
        PancakeRouter routerInst = getRouter(rewardTokenAddress);
        path[0] = routerInst.WETH();
        path[1] = rewardTokenAddress;
        uint256 amountBefore = rewardToken.balanceOf(shareholder);

        try
            routerInst.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, shareholder, block.timestamp + 100)
        {
            uint256 amountAfter = rewardToken.balanceOf(shareholder);

            dividendsDistributedPerToken[
                rewardTokenAddress
            ] = dividendsDistributedPerToken[rewardTokenAddress].add(
                amountAfter.sub(amountBefore)
            );

            dividendsDistributedPerUser[shareholder][
                rewardTokenAddress
            ] = dividendsDistributedPerUser[shareholder][rewardTokenAddress]
                .add(amountAfter.sub(amountBefore));
        } catch Error(string memory reason) {
            sentRewardInBNB(shareholder, amount);
            emit RewardTokenTransferFailed(block.timestamp, rewardTokenAddress);
        }
    }

    function claimDividend(address shareholder, address[] memory rewardTokens)
        external
        nonReentrant
    {
        claim(shareholder, rewardTokens);
    }

    function claim(address shareholder, address[] memory rewardTokens)
        internal
    {
        if (shares[shareholder].amount == 0) {
            revert("No Reflect in account");
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        require(amount > 0, "Amount must be greater than zero");
        uint256 amountPerToken = amount.div(rewardTokens.length);
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            if (!allRewardTokens[rewardTokens[i]]) {
                revert("Select reward token not listed");
            }
            distributeDividendClaim(
                shareholder,
                rewardTokens[i],
                rewardTokens.length,
                amountPerToken
            );
        }
    }

    function gaslessClaim(
        address _to,
        address[] memory _rewardTokens,
        bytes32 _messageHash,
        bytes memory signature
    ) external onlyOwner nonReentrant {
        require(
            block.timestamp >=
                gaslessClaimTimestamp[_to].add(gaslessClaimPeriod),
            "Cannot reclaim before 1 day"
        );
        require(
            verify(_to, _messageHash, signature),
            "signature is not matching"
        );
        gaslessClaimTimestamp[_to] = block.timestamp;
        claim(_to, _rewardTokens);
    }

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonceH
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonceH));
    }

    function verify(
        address _signer,
        bytes32 _messageHash,
        bytes memory signature
    ) internal pure returns (bool) {
        return recoverSigner(_messageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature
            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature
            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // return (r, s, v);
    }

    function setClaimPeriod(uint256 gaslessClaimPeriod_) external onlyOwner {
        gaslessClaimPeriod = gaslessClaimPeriod_;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function getShareholders()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return shareholders;
    }

    function getShareholderAmount(address shareholder)
        external
        view
        returns (uint256)
    {
        return shares[shareholder].amount;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}


// File contracts/additional/CastU256U128.sol




library CastU256U128 {
    /// @dev Safely cast an uint256 to an uint128
    function u128(uint256 x) internal pure returns (uint128 y) {
        require(x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}


// File contracts/additional/CastU256U32.sol




library CastU256U32 {
    /// @dev Safely cast an uint256 to an u32
    function u32(uint256 x) internal pure returns (uint32 y) {
        require(x <= type(uint32).max, "Cast overflow");
        y = uint32(x);
    }
}


// File contracts/additional/SafeMathInt.sol




/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}


// File contracts/additional/SafeMath1.sol



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath1 {
    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


// File contracts/additional/Initializable.sol




contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.

        // MINOR CHANGE HERE:

        // previous code
        // uint256 cs;
        // assembly { cs := extcodesize(address) }
        // return cs == 0;

        // current code
        address _self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(_self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


// File contracts/additional/IERC20.sol




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

     function name() external view returns (string memory);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/additional/Ownable.sol




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public virtual initializer {
        _owner = sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


// File contracts/ReflectRewards.sol










contract ReflectRewards is Ownable {
    using SafeMath1 for uint256;
    using SafeMathInt for int256;
    using CastU256U32 for uint256;
    using CastU256U128 for uint256;

    event LogDeveloperAddress(address developer);
    event RewardsSet(uint32 start, uint32 end, uint256 rate);
    event ListToken(address tokenToList, uint status);
    event ChangeDefaultRate(uint256 rate);
    event RewardsPerTokenUpdated(uint256 accumulated);
    event UserRewardsUpdated(
        address user,
        uint256 userRewards,
        uint256 paidRewardPerToken
    );
    event Claimed(address receiver, uint256 claimed);

    enum RewardStatus {
        NOT_ADDED,
        PENDING,
        APPROVED,
        REJECTED
    }

    struct RewardsPeriod {
        uint256 start; // Start time for the current rewardsToken schedule
        uint256 end; // End time for the current rewardsToken schedule
    }

    struct RewardsPerToken {
        uint128 accumulated; // Accumulated rewards per token for the period, scaled up by 1e18
        uint256 lastUpdated; // Last time the rewards per token accumulator was updated
        uint96 rate; // Wei rewarded per second among all token holders
        address owner;
    }

    struct UserRewards {
        uint128 accumulated; // Accumulated rewards for the user until the checkpoint
        uint128 checkpoint; // RewardsPerToken the last time the user rewards were updated
    }

    struct TempRewardDetail {
        address tokenOwner;
        uint32 start;
        uint32 end;
        uint256 rate;
        uint256 fee;
    }

    RewardsPerToken public rewardsPerToken; // Accumulator to track rewards per token
    mapping(address => mapping(IERC20 => UserRewards)) public rewards; // Rewards accumulated by users
    mapping(IERC20 => RewardStatus) public rewardStatus;
    mapping(IERC20 => RewardsPerToken) public rewardsTokenDetail;
    mapping(IERC20 => RewardsPeriod) public rewardsPeriod;
    mapping(IERC20 => TempRewardDetail) public tempRewardDetails;
    mapping(address => uint256) gaslessClaimTimestamp;
    mapping(address => bool) public isExcludedFromRewards;

    address public developer;
    address public ReflectAdd;
    uint256 public gaslessClaimPeriod;
    IERC20[] public rewardPool;
    IERC20[] public pendingPool;
    IERC20 public defaultReward;
    IERC20 public ReflectToken;
    uint256 public MAX_REWARD_POOL;
    uint256 public poolPrice;

    constructor(IERC20 _ReflectToken) {
        gaslessClaimPeriod = 86400; // Gasless Claim once every 1 day
        MAX_REWARD_POOL = 130;
        ReflectToken = _ReflectToken;
        poolPrice = 1000000000000000000;
        Ownable.initialize(msg.sender);
    }

    modifier onlyRewardOwner(address _rewardToken) {
        require(
            rewardsTokenDetail[IERC20(_rewardToken)].owner == msg.sender,
            ""
        );
        _;
    }

    function setMaxRewardPoolLength(uint256 _maxRewardPool) external onlyOwner {
        MAX_REWARD_POOL = _maxRewardPool;
    }

    function setPoolPrice(uint256 _price) external onlyOwner {
        poolPrice = _price;
    }

    /*-------------------------------- Rewards ------------------------------------*/

    /// @dev Return the earliest of two timestamps
    function earliest(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = (x < y) ? x : y;
    }

    /// @dev Set a rewards schedule
    function setDefaultReward(
        uint32 start,
        uint32 end,
        uint96 rate
    ) external onlyOwner {
        require(start < end, "Incorrect input");
        // A new rewards program can be set if one is not running
        // require(
        //     block.timestamp < rewardsPeriod[defaultReward].start ||
        //         block.timestamp > rewardsPeriod[defaultReward].end,
        //     "Ongoing rewards"
        // );
        require(
            rewardStatus[defaultReward] == RewardStatus.APPROVED,
            "this token is not approved reward"
        );
        rewardsPeriod[defaultReward].start = uint32(block.timestamp) + start;
        rewardsPeriod[defaultReward].end = uint32(block.timestamp) + end;

        // If setting up a new rewards program, the rewardsPerToken.accumulated is used and built upon
        // New rewards start accumulating from the new rewards program start
        // Any unaccounted rewards from last program can still be added to the user rewards
        // Any unclaimed rewards can still be claimed
        rewardsTokenDetail[defaultReward].lastUpdated =
            uint32(block.timestamp) +
            start;
        rewardsTokenDetail[defaultReward].rate = rate;

        rewardsTokenDetail[defaultReward].owner = msg.sender;

        emit RewardsSet(start, end, rate);
    }

    function changeRate(address token, uint96 rate)
        external
        onlyRewardOwner(token)
    {
        rewardsTokenDetail[IERC20(token)].rate = rate;
        emit ChangeDefaultRate(rate);
    }

    function changeEndDate(address token, uint32 end)
        external
        onlyRewardOwner(token)
    {
        rewardsPeriod[IERC20(token)].end = uint32(block.timestamp) + end;
    }

    /// @dev Update the rewards per token accumulator.
    /// @notice Needs to be called on each liquidity event
    function _updateRewardsPerToken() public {
        // RewardsPerToken memory rewardsPerToken_ = rewardsPerToken;
        // RewardsPeriod memory rewardsPeriod_ = rewardsPeriod;
        uint256 totalSupply_ = ReflectToken.totalSupply();

        for (uint8 i = 0; i < rewardPool.length; i++) {
            // We skip the update if the program hasn't started
            
            if (block.timestamp < rewardsPeriod[rewardPool[i]].start) {
                return;
            }

            // Find out the unaccounted time
            uint256 end = earliest(
                block.timestamp,
                rewardsPeriod[rewardPool[i]].end
            );
            uint256 unaccountedTime = end -
                rewardsTokenDetail[rewardPool[i]].lastUpdated; // Cast to uint256 to avoid overflows later on
            // if (unaccountedTime == 0) return; // We skip the storage changes if already updated in the same block
            // Calculate and update the new value of the accumulator. unaccountedTime casts it into uint256, which is desired.
            // If the first mint happens mid-program, we don't update the accumulator, no one gets the rewards for that period.

            if (totalSupply_ != 0 && unaccountedTime > 0) {
                rewardsTokenDetail[rewardPool[i]]
                    .accumulated = (rewardsTokenDetail[rewardPool[i]]
                    .accumulated +
                    (1e9 *
                        unaccountedTime *
                        rewardsTokenDetail[rewardPool[i]].rate) /
                    totalSupply_).u128(); // The rewards per token are scaled up for precision
                rewardsTokenDetail[rewardPool[i]].lastUpdated = end;
            }
        }
        // emit RewardsPerTokenUpdated(rewardsTokenDetail[rewardPool[i]].accumulated);
    }

    /// @dev Accumulate rewards for an user..
    /// @notice Needs to be called on each liquidity event, or when user balances change.
    function _updateUserRewards(address user) public {
        // UserRewards memory userRewards_ = rewards[user];
        // RewardsPerToken memory rewardsPerToken_ = rewardsPerToken;
        for (uint8 i = 0; i < rewardPool.length; i++) {
            // Calculate and update the new value user reserves. _fracBalances[user] casts it into uint256, which is desired.
            // accumulated+= (RUSD_BALANCE * (RPT.accumulated - UR.checkpoint)/ 1e9)
            if (
                !isExcludedFromRewards[user] &&
                rewardsTokenDetail[rewardPool[i]].accumulated > 0
            ) {
                rewards[user][rewardPool[i]].accumulated = (rewards[user][
                    rewardPool[i]
                ].accumulated +
                    (ReflectToken.balanceOf(user) *
                        (rewardsTokenDetail[rewardPool[i]].accumulated -
                            rewards[user][rewardPool[i]].checkpoint)) /
                    1e9).u128(); // We must scale down the rewards by the precision factor

                rewards[user][rewardPool[i]].checkpoint = rewardsTokenDetail[
                    rewardPool[i]
                ].accumulated;
            } else if (isExcludedFromRewards[user]) {
                rewards[user][rewardPool[i]].accumulated = 0; // We must scale down the rewards by the precision factor
                rewards[user][rewardPool[i]].checkpoint = 0;
            }
        }
        // emit UserRewardsUpdated(user, userRewards_.accumulated, userRewards_.checkpoint);
        // return userRewards_.accumulated;
    }

    function excludeFromRewards(address holder_, bool exclude)
        external
        onlyOwner
    {
        isExcludedFromRewards[holder_] = exclude;
        _updateRewardsPerToken();
        _updateUserRewards(holder_);
    }

    function setReflectContractAddress(address ReflectAdd_)
        external
        onlyOwner
    {
        ReflectAdd = ReflectAdd_;
    }

    function updateReflect(IERC20 _ReflectToken) external onlyOwner {
        ReflectToken = _ReflectToken;
    }

    function setDeveloperAddress(address developer_) external onlyOwner {
        developer = developer_;
        emit LogDeveloperAddress(developer_);
    }

    function addReward(
        IERC20 _rewardToken,
        uint32 start,
        uint32 end,
        uint256 rate
    ) external payable {
        require(msg.value == poolPrice, "Send correct value to create a pool");
        require(MAX_REWARD_POOL > 0, "Limit of reward pool cannot be 0");
        require(
            rewardStatus[_rewardToken] != RewardStatus.PENDING,
            "Already exists in pending pool"
        );
        require(
            _rewardToken.allowance(msg.sender, address(this)) > 0,
            "approve before adding"
        );
        uint8 flag = 0;
        // IF Token is present in the reward pool but the supply is 0, then allow addition
        if (
            (rewardStatus[_rewardToken] == RewardStatus.APPROVED) &&
            (_rewardToken.balanceOf(address(this)) != 0)
        ) {
            revert("Already inside the pool");
        }
        require(
            start > 0 && end > 0 && rate > 10 && end > start && msg.value > 0,
            "does not meet requirements"
        );
        // If the rewardPool if filled and there are no tokens with 0 supply, then revert
        if (rewardPool.length == MAX_REWARD_POOL) {
            for (uint8 i = 1; i < rewardPool.length; i++) {
                if (IERC20(rewardPool[i]).balanceOf(address(this)) == 0) {
                    flag = 1;
                }
            }
        }
        if (flag == 1) {
            revert();
        }

        // payable(ReflectAdd).transfer(msg.value / 2);
        // payable(developer).transfer(msg.value / 2);
        tempRewardDetails[_rewardToken].start = uint32(block.timestamp) + start;
        tempRewardDetails[_rewardToken].end = uint32(block.timestamp) + end;
        tempRewardDetails[_rewardToken].rate = rate;
        tempRewardDetails[_rewardToken].tokenOwner = msg.sender;
        tempRewardDetails[_rewardToken].fee = msg.value;
        rewardStatus[_rewardToken] = RewardStatus.PENDING;
        pendingPool.push(_rewardToken);
        emit ListToken(address(_rewardToken), 0);
    }

    function approveReward(IERC20 _rewardToken) public onlyOwner {
        require(
            rewardStatus[_rewardToken] == RewardStatus.PENDING,
            "token needs to be added first"
        );
        require(rewardPool.length > 0, "Default reward must be added");
        address tokenOwner = tempRewardDetails[_rewardToken].tokenOwner;

        // set reward period with rate
        rewardsPeriod[_rewardToken].start = tempRewardDetails[_rewardToken]
            .start;
        rewardsPeriod[_rewardToken].end = tempRewardDetails[_rewardToken].end;
        rewardsTokenDetail[_rewardToken].lastUpdated = rewardsPeriod[
            _rewardToken
        ].start;
        rewardsTokenDetail[_rewardToken].rate = uint96(
            tempRewardDetails[_rewardToken].rate
        );

        rewardsTokenDetail[_rewardToken].owner = tokenOwner;

        if (rewardPool.length >= MAX_REWARD_POOL) {
            for (uint8 i = 1; i < rewardPool.length; i++) {
                if (IERC20(rewardPool[i]).balanceOf(address(this)) == 0) {
                    rewardPool[i] = _rewardToken; // overwritten with this new token
                    removeToken(rewardPool[i]);
                    break;
                }
            }
        } else {
            rewardPool.push(_rewardToken);
        }

        // remove this token from pending pool
        for (uint8 i = 0; i < pendingPool.length; i++) {
            if (pendingPool[i] == _rewardToken) {
                delete pendingPool[i];
                break;
            }
        }

        rewardStatus[_rewardToken] = RewardStatus.APPROVED;
        emit ListToken(address(_rewardToken), 1);
        // send fee to contract and dev
        payable(ReflectAdd).transfer(tempRewardDetails[_rewardToken].fee / 2);
        payable(developer).transfer(tempRewardDetails[_rewardToken].fee / 2);
        // delete the struct data for tempRewardDetails
        delete tempRewardDetails[_rewardToken];

        // get the tokens in this contract
        IERC20(_rewardToken).transferFrom(
            tokenOwner,
            address(this),
            _rewardToken.allowance(tokenOwner, address(this))
        );
    }

    function rejectPool(IERC20 _rewardToken) public onlyOwner {
        // remove this token from pending pool
        for (uint8 i = 0; i < pendingPool.length; i++) {
            if (pendingPool[i] == _rewardToken) {
                delete pendingPool[i];
                break;
            }
        }
        payable(tempRewardDetails[_rewardToken].tokenOwner).transfer(
            tempRewardDetails[_rewardToken].fee
        );
        // delete the struct data for tempRewardDetails
        delete tempRewardDetails[_rewardToken];
        emit ListToken(address(_rewardToken), 2);
        removeToken(_rewardToken);
    }

    function removeToken(IERC20 _rewardToken) internal {
        rewardStatus[_rewardToken] = RewardStatus.NOT_ADDED;
        delete rewardsTokenDetail[_rewardToken];
    }

    function approveMultipleReward(IERC20[] memory _rewardToken) external {
        for (uint8 i = 0; i < _rewardToken.length; i++) {
            approveReward(_rewardToken[i]);
        }
    }

    // List of approved tokens
    function approvedTokens() public view returns (IERC20[] memory) {
        return rewardPool;
    }

    // list of Unapproves/Pending tokens
    function pendingTokens() public view returns (IERC20[] memory) {
        return pendingPool;
    }

    function setDefaultToken(IERC20 _defaultToken) external onlyOwner {
        defaultReward = _defaultToken;
        rewardPool.push(defaultReward);
        rewardStatus[defaultReward] = RewardStatus.APPROVED;
    }

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    function verify(
        address _signer,
        bytes32 _messageHash,
        bytes memory signature
    ) internal pure returns (bool) {
        return recoverSigner(_messageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature
            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature
            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function setClaimPeriod(uint256 gaslessClaimPeriod_) external onlyOwner {
        gaslessClaimPeriod = gaslessClaimPeriod_;
    }

    function gaslessClaim(
        address _to,
        IERC20[] memory _rewardTokens,
        bytes32 _messageHash,
        bytes memory signature
    ) external onlyOwner {
        require(
            block.timestamp >=
                gaslessClaimTimestamp[_to].add(gaslessClaimPeriod),
            "Cannot reclaim before 1 day"
        );
        require(
            verify(_to, _messageHash, signature),
            "signature is not matching"
        );
        gaslessClaimTimestamp[_to] = block.timestamp;
        claim(_to, _rewardTokens);
    }

    /// @dev Claim all rewards from caller into a given address
    function claim(address _to, IERC20[] memory _rewardTokens) public {
        _updateRewardsPerToken();
        _updateUserRewards(_to);
        for (uint8 i = 0; i < _rewardTokens.length; i++) {
            uint256 claiming = rewards[_to][_rewardTokens[i]].accumulated;
            require(claiming > 0, "Claim amount cannot be less than 0");
            rewards[_to][_rewardTokens[i]].accumulated = 0;
            _rewardTokens[i].transfer(_to, claiming);
            emit Claimed(_to, claiming);
        }
    }
}


// File contracts/Reflect.sol











interface IReflectRewards {
    function _updateRewardsPerToken() external;

    function _updateUserRewards(address user) external;
}

contract Reflect is IBEP20, Auth {
    using SafeMath for uint256;

    struct Swap {
        uint256 liquidityFee;
        uint256 reflectionFee;
        uint256 marketingFee;
        uint256 gasWalletFee;
        uint256 totalFee;
        uint256 swapThreshold;
    }

    struct Processing {
        bool onSell;
        bool onBuy;
        bool onTransfer;
    }

    Processing public whenProcess;
    uint256 public constant MASK = type(uint128).max;
    address BUSD;
    address Crypter;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Reflect";
    string constant _symbol = "RFL";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1_000_000_000_000_000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;

    PancakeRouter[] public routers;
    mapping(address => bool) public isBNBRouter;
    uint256 routerIndex = 0;
    PancakeRouter public defaultRouter;
    bool public isDefaultForSwap = false;

    address public calculator;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public gasWalletFeeReceiver;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    mapping(address => bool) buyBacker;
    mapping(address => bool) public pairs;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod = 1 minutes;
    uint256 autoBuybackBlockLast;
    bool public isRoundRobinBuyback = false;

    IReflectRewards public ReflectRewards;

    bool isCancelingEnabled = true;
    uint256 burnDivider = 0;
    bool isBuyBackEnabled = true;
    uint256 buyBackDivider = 0;

    bool isSentToPoolEnabled = true;

    uint256 public minimumStakingLimit = 100000000000000000000;

    DividendDistributor distributor;
    // address public distributorAddress;
    uint256 distributorGas = 500000;

    // --- EIP712 niceties ---
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");
    bytes32 public constant PERMIT_TYPEHASH =
        0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    bool public swapEnabled = true;
    bool public isSwapOnSell = true;

    mapping(address => uint256) public timeOfSell;
    mapping(address => uint256) public amountOfSell;
    uint256 public sellLimit = 100000000000000000000;

    uint256 public maxCancelingAmount = 100000000000000000000;

    uint256 public burnCounter = 0;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }



    constructor() Auth(msg.sender) {
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        buyBacker[msg.sender] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        gasWalletFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;

        whenProcess.onBuy = true;
        whenProcess.onSell = true;
        whenProcess.onTransfer = true;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)),
                keccak256(bytes(version())),
                block.chainid,
                address(this)
            )
        );

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setProcessing(
        bool _onBuy,
        bool _onSell,
        bool _onTransfer
    ) external authorized {
        whenProcess.onBuy = _onBuy;
        whenProcess.onSell = _onSell;
        whenProcess.onTransfer = _onTransfer;
    }


    function setAutoStakingContract(address ReflectRewardsContract)
        external
        authorized
    {
        isDividendExempt[ReflectRewardsContract] = true;
        isFeeExempt[ReflectRewardsContract] = true;
        ReflectRewards = IReflectRewards(ReflectRewardsContract);
    }

    function setSellCancelingEnabled(bool _isEnabled) external authorized {
        isCancelingEnabled = _isEnabled;
    }

    function setMaxSellCancelingAmount(uint256 _amount) external authorized {
        maxCancelingAmount = _amount;
    }

    function setEnableRoundRobinBuyback(bool _isEnabled) external authorized {
        isRoundRobinBuyback = _isEnabled;
    }

    function setPoolSendEnabled(bool _isEnabled) external authorized {
        isSentToPoolEnabled = _isEnabled;
    }

    function addPair(address pairAddress) external authorized {
        pairs[pairAddress] = true;
        isDividendExempt[pairAddress] = true;
    }

    function deletePair(address pairAddress) external authorized {
        pairs[pairAddress] = false;
        isDividendExempt[pairAddress] = false;
    }

    function setDefaultRouter(address router, bool isBNB) external authorized {
        defaultRouter = PancakeRouter(router);
        isBNBRouter[router] = isBNB;
        _allowances[address(this)][router] = _totalSupply;
    }

    function setDefaultRouterFromSwapBack(bool isEnabled) external authorized {
        isDefaultForSwap = isEnabled;
    }

    function addRouter(address router, bool isBNB) external authorized {
        PancakeRouter routerNew = PancakeRouter(router);
        _allowances[address(this)][router] = _totalSupply;
        isBNBRouter[router] = isBNB;
        routers.push(routerNew);
        routerIndex = 0;
    }

    function removeRouter(uint256 index) external authorized {
        PancakeRouter routerLast = routers[routers.length - 1];
        routers[index] = routerLast;
        routers.pop();
        routerIndex = 0;
    }

    function getRouter() internal view returns (PancakeRouter) {
        if (isDefaultForSwap) {
            return defaultRouter;
        }
        PancakeRouter currentRouter = routers[routerIndex];

        return currentRouter;
    }

    function updateRouterIndex() internal {
        if (routerIndex + 1 > routers.length - 1) {
            routerIndex = 0;
        } else {
            routerIndex = routerIndex + 1;
        }
    }

    function setFeeCalulator(address calc) external authorized {
        calculator = calc;
    }

    function setMinimumStakingLimitAmount(uint256 amount) external authorized {
        minimumStakingLimit = amount;
    }

    /// @dev Setting the version as a function so that it can be overriden
    function version() public pure virtual returns (string memory) {
        return "1";
    }

    function getChainID() external view returns (uint256) {
        return block.chainid;
    }

    receive() external payable {}

    // For testing
    function donate() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    modifier onlyBuybacker() {
        require(buyBacker[msg.sender] == true, "");
        _;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (
            (isDividendExempt[sender] || isDividendExempt[recipient]) &&
            (!shouldTakeFee(sender) || !shouldTakeFee(recipient))
        ) {
            _basicTransfer(sender, recipient, amount);
            if (!isDividendExempt[sender]) {
                try distributor.setShare(sender, _balances[sender]) {} catch {}
            }
            if (!isDividendExempt[recipient]) {
                try
                    distributor.setShare(recipient, _balances[recipient])
                {} catch {}
            }
            setStakes(sender, recipient);
            if (pairs[recipient]) {
                ICalculator(calculator).registerBuySell(amount, false);
            } else if (pairs[sender]) {
                ICalculator(calculator).registerBuySell(amount, true);
            }
            return true;
        }

        if (shouldAutoBuyback()) {
            autoBuybackBlockLast = block.timestamp;
            algoBB(pairs[recipient], amount);
        }

        Fees memory allFees = ICalculator(calculator).getFees();
        uint256 swapThreshold = ICalculator(calculator).getSwapThreshold();
        if (shouldSwapBack(recipient, swapThreshold)) {
            swapBack(
                Swap(
                    pairs[recipient]
                        ? allFees.sellLiquidityFee
                        : allFees.buyLiquidityFee,
                    pairs[recipient]
                        ? allFees.sellReflectionFee
                        : allFees.buyReflectionFee,
                    pairs[recipient]
                        ? allFees.sellDevelopmentFee
                        : allFees.buyDevelopmentFee,
                    pairs[recipient]
                        ? allFees.sellGasWalletFee
                        : allFees.buyGasWalletFee,
                    pairs[recipient] ? allFees.sellTotal : allFees.buyTotal,
                    swapThreshold
                )
            );
        }

        uint256 amountReceived;
        if (
            ICalculator(calculator).isCustomFeeReceiverOrSender(
                sender,
                recipient
            )
        ) {
            if (!pairs[recipient] && !pairs[sender]) {
                amountReceived = amount;
                if (whenProcess.onTransfer) {
                    try distributor.process(distributorGas) {} catch {}
                }
            } else {
                Fees memory usersFees = ICalculator(calculator).getUserFees(
                    sender,
                    recipient
                );
                amountReceived = !shouldTakeFee(sender) ||
                    !shouldTakeFee(recipient)
                    ? amount
                    : takeFee(
                        sender,
                        amount,
                        pairs[recipient]
                            ? usersFees.sellTotal
                            : usersFees.buyTotal,
                        usersFees.buyFeeDenominator
                    );

                if (pairs[recipient]) {
                    ICalculator(calculator).registerBuySell(amount, false);
                    if (whenProcess.onSell) {
                        try distributor.process(distributorGas) {} catch {}
                    }
                } else if (pairs[sender]) {
                    ICalculator(calculator).registerBuySell(amount, true);
                    if (whenProcess.onBuy) {
                        try distributor.process(distributorGas) {} catch {}
                    }
                }
            }
        } else if (pairs[recipient]) {
            checkTxLimit(sender, amount);
            // sell
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.sellTotal,
                    allFees.sellFeeDenominator
                );
            ICalculator(calculator).registerBuySell(amount, false);
            if (whenProcess.onSell) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else if (pairs[sender]) {
            // buy
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.buyTotal,
                    allFees.buyFeeDenominator
                );
            ICalculator(calculator).registerBuySell(amount, true);
            if (whenProcess.onBuy) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else if (allFees.transferFee > 0) {
            amountReceived = !shouldTakeFee(sender) || !shouldTakeFee(recipient)
                ? amount
                : takeFee(
                    sender,
                    amount,
                    allFees.transferFee,
                    allFees.buyFeeDenominator
                );
            if (whenProcess.onTransfer) {
                try distributor.process(distributorGas) {} catch {}
            }
        } else {
            amountReceived = amount;
            if (whenProcess.onTransfer) {
                try distributor.process(distributorGas) {} catch {}
            }
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }
        setStakes(sender, recipient);
        updateRouterIndex();
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function setStakes(address sender, address recipient) internal {
        try ReflectRewards._updateRewardsPerToken() {} catch {}
        try ReflectRewards._updateUserRewards(sender) {} catch {}
        try ReflectRewards._updateUserRewards(recipient) {} catch {}
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal {
        if (timeOfSell[sender] + 1 days < block.timestamp) {
            amountOfSell[sender] = 0;
        }
        require(
            (amount + amountOfSell[sender] <= sellLimit) ||
                isTxLimitExempt[sender],
            "Exceeded TX daily limit"
        );

        timeOfSell[sender] = block.timestamp;
        amountOfSell[sender] = amountOfSell[sender] + amount;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(
        address sender,
        uint256 amount,
        uint256 totalFee,
        uint256 denominator
    ) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(denominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack(address recipient, uint256 _swapThreshold)
        internal
        view
        returns (bool)
    {
        return
            (pairs[recipient] || !isSwapOnSell) &&
            !pairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= _swapThreshold;
    }

    function sendToThePool(uint256 _swapThreshold) internal returns (bool) {
        if (!isSentToPoolEnabled) {
            return true;
        }
        // return true if disabled
        (bool shoudFundByPressure, uint256 amount) = ICalculator(calculator)
            .getFundPoolByPressureData(
                _swapThreshold,
                address(ReflectRewards),
                minimumStakingLimit
            );
        if (shoudFundByPressure) {
            fundStakingPool(amount);
            return false;
        }
        return true;
    }

    function fundStakingPool(uint256 amount) internal {
        _balances[address(this)] = _balances[address(this)].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[address(ReflectRewards)] = _balances[
            address(ReflectRewards)
        ].add(amount);
        emit Transfer(address(this), address(ReflectRewards), amount);
    }

    function algoBB(bool isSell, uint256 amount) internal {
        PancakeRouter router = getRouter();
        address pairOfRouter = PancakeFactory(router.factory()).getPair(
            isBNBRouter[address(router)] ? router.WBNB() : router.WETH(),
            address(this)
        );

        (bool shouldBB, uint256 amountToBuy) = ICalculator(calculator)
            .getAlgoBuybackData(amount, isSell, pairOfRouter);

        if (!shouldBB) {
            return;
        }

        uint256 beforeBB = _balances[DEAD];
        buyTokens(amountToBuy, DEAD);
        burnCounter = burnCounter.add(_balances[DEAD].sub(beforeBB));
    }

    function getPath(PancakeRouter router)
        internal
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = isBNBRouter[address(router)] ? router.WBNB() : router.WETH();
        return path;
    }

    function swapBack(Swap memory swap) internal swapping {
        if (!sendToThePool(swap.swapThreshold)) {
            return;
        }
        PancakeRouter router = getRouter();
        address pairOfRouter = PancakeFactory(router.factory()).getPair(
            isBNBRouter[address(router)] ? router.WBNB() : router.WETH(),
            address(this)
        );

        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator,
            pairOfRouter
        )
            ? 0
            : swap.liquidityFee;
        uint256 amountToLiquify = swap
            .swapThreshold
            .mul(dynamicLiquidityFee)
            .div(swap.totalFee)
            .div(2);
        uint256 amountToSwap = swap.swapThreshold.sub(amountToLiquify);
        (uint256 priceDataBeforeSwap, , ) = ICalculator(calculator).getPrices(
            pairOfRouter
        );
        uint256 balanceBefore = address(this).balance;

        isBNBRouter[address(router)]
            ? router.swapExactTokensForBNBSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                getPath(router),
                address(this),
                block.timestamp
            )
            : router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                getPath(router),
                address(this),
                block.timestamp
            );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = swap.totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);

        try
            distributor.deposit{
                value: amountBNB.mul(swap.reflectionFee).div(totalBNBFee)
            }()
        {} catch {}
        payable(marketingFeeReceiver).transfer(
            amountBNB.mul(swap.marketingFee).div(totalBNBFee)
        );
        payable(gasWalletFeeReceiver).transfer(
            amountBNB.mul(swap.gasWalletFee).div(totalBNBFee)
        );
        if (amountToLiquify > 0) {
            isBNBRouter[address(router)]
                ? router.addLiquidityBNB{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                )
                : router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        if (isCancelingEnabled) {
            (
                bool sholdCancel,
                uint256 cancelingAmount,
                address targetAddress
            ) = ICalculator(calculator).getSellCancelingAmount(
                    pairOfRouter,
                    priceDataBeforeSwap
                );
            if (
                _balances[targetAddress] >= cancelingAmount &&
                cancelingAmount > 0 &&
                cancelingAmount <= maxCancelingAmount &&
                sholdCancel
            ) {
                if (burnDivider > 0) {
                    cancelingAmount = cancelingAmount.div(burnDivider);
                }
                _balances[targetAddress] = _balances[targetAddress].sub(
                    cancelingAmount
                );
                _totalSupply = _totalSupply.sub(cancelingAmount);
                try ReflectRewards._updateRewardsPerToken() {} catch {}
                IProviderPair(pairOfRouter).sync();
            }
        }
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return
            !pairs[msg.sender] &&
            !inSwap &&
            autoBuybackEnabled &&
            autoBuybackBlockLast + autoBuybackBlockPeriod <= block.timestamp;
    }

    function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier)
        external
        authorized
    {
        uint256 beforeBB = _balances[DEAD];
        buyTokens(amount, DEAD);
        burnCounter = burnCounter + _balances[DEAD].sub(beforeBB);
        if (triggerBuybackMultiplier) {
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        PancakeRouter selectedRouter = !isRoundRobinBuyback
            ? defaultRouter
            : getRouter();
        address WBNB_OR_WETH = isBNBRouter[address(selectedRouter)]
            ? selectedRouter.WBNB()
            : selectedRouter.WETH();
        path[0] = WBNB_OR_WETH;
        path[1] = address(this);

        isBNBRouter[address(selectedRouter)]
            ? selectedRouter.swapExactBNBForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, to, block.timestamp)
            : selectedRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(0, path, to, block.timestamp);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 period)
        external
        authorized
    {
        autoBuybackEnabled = _enabled;
        autoBuybackBlockPeriod = period;
    }

    function setDividendDistributer(address distributer) external authorized {
        isDividendExempt[distributer] = true;
        isFeeExempt[distributer] = true;
        distributor = DividendDistributor(distributer);
    }

    function setBuybackMultiplierSettings(
        uint256 numerator,
        uint256 denominator,
        uint256 length
    ) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Already launched.");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setSellLimit(uint256 amount) external authorized {
        require(
            amount >= 100000000000000000000,
            "Put amount greater then 100b"
        );
        sellLimit = amount;
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && !pairs[holder]);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _gasWalletReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        gasWalletFeeReceiver = _gasWalletReceiver;
    }

    function setSwapBackSettings(bool _enabled) external authorized {
        swapEnabled = _enabled;
    }

    function setSwapBackOnSell(bool _isSwapBackOnSell) external authorized {
        isSwapOnSell = _isSwapBackOnSell;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 999999);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy, address pair)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(
        uint256 target,
        uint256 accuracy,
        address pair
    ) public view returns (bool) {
        return getLiquidityBacking(accuracy, pair) > target;
    }

    /**
     * @dev Sets the allowance granted to `spender` by `owner`.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function _setAllowance(
        address owner,
        address spender,
        uint256 wad
    ) internal virtual returns (bool) {
        _allowances[owner][spender] = wad;
        emit Approval(owner, spender, wad);

        return true;
    }

    // --- Approve by signature ---
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        allowed
                    )
                )
            )
        );

        require(holder != address(0), "Reflect/invalid-address-0");
        require(
            holder == ecrecover(digest, v, r, s),
            "Reflect/invalid-permit"
        );
        require(
            expiry == 0 || block.timestamp <= expiry,
            "Reflect/permit-expired"
        );
        require(nonce == nonces[holder]++, "Reflect/invalid-nonce");
        uint256 wad = allowed ? _totalSupply : 0;
        _setAllowance(holder, spender, wad);
    }

    function convertTokensToBuyBack(address token) external authorized {
        address[] memory bnbPath = new address[](2);
        address WBNB_OR_WETH = isBNBRouter[address(defaultRouter)]
            ? defaultRouter.WBNB()
            : defaultRouter.WETH();
        bnbPath[0] = token;
        bnbPath[1] = WBNB_OR_WETH;
        uint256 amountIn = IBEP20(token).balanceOf(address(this));

        uint256 deadline = block.timestamp + 1000;
        IBEP20(token).approve(address(defaultRouter), amountIn);

        isBNBRouter[address(defaultRouter)]
            ? defaultRouter.swapExactTokensForBNBSupportingFeeOnTransferTokens(
                amountIn,
                0,
                bnbPath,
                address(this),
                deadline
            )
            : defaultRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountIn,
                0,
                bnbPath,
                address(this),
                deadline
            );
    }

    function burnTokenFromContract() external authorized {
        uint256 balanceOfContract = balanceOf(address(this));
        uint256 swapThreshold = ICalculator(calculator).getSwapThreshold();
        require(
            balanceOfContract > swapThreshold,
            "Threshold is gt then blance"
        );

        uint256 amountToBurn = balanceOfContract - swapThreshold;

        _balances[address(this)] = _balances[address(this)].sub(
            amountToBurn,
            "Insufficient Balance"
        );
        _balances[DEAD] = _balances[DEAD].add(amountToBurn);
        burnCounter = burnCounter.add(amountToBurn);

        emit Transfer(address(this), DEAD, amountToBurn);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}
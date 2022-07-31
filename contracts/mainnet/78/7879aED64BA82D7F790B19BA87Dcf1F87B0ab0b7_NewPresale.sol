// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Interfaces/IPresaleSettings.sol";
import "./Interfaces/IPresaleLockForwarder.sol";
import "./Interfaces/IPancakeRouter02.sol";
import "./Libraries/PresaleLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NewPresale is ReentrancyGuard {
    using Address for address payable;
    using SafeERC20 for IERC20Metadata;

    IPresaleSettings public immutable presaleSettings;
    IPresaleLockForwarder public immutable presaleLockForwarder;
    address public immutable presaleGenerator;
    address payable public admin;
    address payable public tokenOwner;
    bool public isInitialized;

    uint256 private constant PRECISION = 10000;

    Presale.Info public presaleInfo;
    Presale.State private presaleMetrics;

    mapping(address => Presale.User) private users;

    modifier onlyAdmin() {
        require(msg.sender == admin, "PS: !admin");
        _;
    }

    modifier onlyTokenOwner() {
        require(msg.sender == tokenOwner, "PS: !owner");
        _;
    }

    modifier isAllowed() {
        require(presaleMetrics.isAllowed, "PS: !allow");
        _;
    }

    event TokenBought(address indexed user, uint256 indexed numberOfTokens, uint256 indexed amountInUsd);
    event TokenUnsold(address indexed tokenOwner, uint256 indexed refundToken);
    event TokenClaimed(address indexed user, uint256 indexed numberOfTokens);
    event CoinClaimed(address indexed user, uint256 indexed numberOfCoins);
    event StartVoting(uint256 indexed startTime, uint256 indexed endTime);
    event EndVoting(uint256 indexed endTime);
    event WhitelistedUsers(address[] indexed userList, uint256 indexed saleType);
    event RemoveStuckCoin(uint256 indexed amount);
    event RemoveStuckToken(uint256 indexed amount);
    event SetAllow(bool indexed isAllowed);
    event Initialize(address indexed admin, address indexed tokenOwner, address indexed contractAddress, Presale.Info data);
    event SaleFailed(address indexed saleAddress, address indexed tokenOwner, uint256 refundAmount, uint256 timestamp);

    // 0 -> Seed
    // 1 -> Private
    // 2 -> Presale
    // 3 -> Public

    constructor(
        address _presaleSettings,
        address _presaleLockForwarder,
        address _presaleGenerator
    ) {
        presaleSettings = IPresaleSettings(_presaleSettings);
        presaleLockForwarder = IPresaleLockForwarder(_presaleLockForwarder);
        presaleGenerator = _presaleGenerator;
    }

    function initialize(Presale.Info calldata params) external {
        require(msg.sender == presaleGenerator, "PS: FORBIDDEN"); // sufficient check
        require(!isInitialized, "Already initialized");
        isInitialized = true;
        admin = payable(presaleSettings.getAdmin());
        tokenOwner = payable(params.presaleOwner);
        presaleInfo = params;

        emit Initialize(admin, tokenOwner, address(this), params);
    }

    // to buy token during preSale time => for web3 use
    function buyToken(uint8 _type, uint256 _amount) public isAllowed nonReentrant {
        require(block.timestamp < presaleInfo.preSaleEndTime && presaleMetrics.status == Presale.States.RUNNING, "PS: Time over");
        require(_type >= 0 && _type < Presale.SALE_TYPE_COUNT, "PS: Wrong sale type");
        Presale.User storage user = users[msg.sender];
        if (user.joinDate == 0) user.joinDate = block.timestamp;
        Presale.Metrics storage metrics = presaleMetrics.sale[_type];
        require(_amount >= presaleInfo.minAmount && user.sales[_type].coinBalance + _amount <= presaleInfo.maxAmount, "PS: Invalid Amount");
        require(metrics.amountRaised + _amount <= presaleInfo.consts[_type].hardCap, "PS: Hardcap reached");

        if (_type != 3) require(user.sales[_type].whiteListed, "PS: Not whitelisted");

        presaleInfo.coin.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _numberOfTokens = coinToToken(_amount, presaleInfo.consts[_type].tokenPrice);
        uint256 _fee = ((_numberOfTokens * presaleInfo.fees.userFee) / PRECISION);

        if (user.sales[_type].tokenBalance == 0) presaleMetrics.totalUser += 1;

        user.sales[_type].tokenBalance += (_numberOfTokens - _fee);
        user.sales[_type].coinBalance += _amount;
        presaleMetrics.adminFeeCounter += _fee;
        metrics.soldTokens += _numberOfTokens;
        metrics.amountRaised += _amount;
        emit TokenBought(msg.sender, _numberOfTokens, _amount);
    }

    function claimAdminFunds() external onlyTokenOwner isAllowed nonReentrant {
        require(getContractcoinBalance() > 0, "PS: Nothing to claim");
        require(presaleMetrics.status == Presale.States.FINISHED, "PS: Presale is not finished");
        require(presaleMetrics.result == Presale.Results.SUCCESS, "PS: Presale failed");
        require(users[address(this)].claimCount < presaleMetrics.claim.maxCycle, "PS: Wait for next claim cycle");

        for (uint8 i = 0; i < Presale.SALE_TYPE_COUNT; i++) {
            uint256 contractCoinBalance = getContractcoinBalance();
            if (contractCoinBalance > presaleMetrics.sale[i].tokenOwnerProfit) {
                presaleInfo.coin.safeTransfer(tokenOwner, presaleMetrics.sale[i].tokenOwnerProfit);
                emit CoinClaimed(msg.sender, presaleMetrics.sale[i].tokenOwnerProfit);
            } else if (contractCoinBalance > 0) {
                presaleInfo.coin.safeTransfer(tokenOwner, contractCoinBalance);
                emit CoinClaimed(msg.sender, contractCoinBalance);
            }
        }
        users[address(this)].lastClaimedDate = block.timestamp;
        users[address(this)].claimCount += presaleInfo.vesting.claimPerVesting;
    }

    function endPresale() public onlyTokenOwner isAllowed nonReentrant {
        require(presaleMetrics.status != Presale.States.FINISHED, "PS: Presale finished");

        presaleMetrics.claim.profitClaimed = true;
        presaleMetrics.preSaleEndTime = block.timestamp;
        presaleMetrics.claim.canClaim = true;
        presaleMetrics.claim.maxCycle = presaleInfo.vesting.claimPerVesting;
        presaleMetrics.status = Presale.States.FINISHED;
        presaleMetrics.vote.lastDate = block.timestamp;
        presaleMetrics.vote.currentCycle += 1;
        Presale.VoteData memory voteData = Presale.VoteData(1, 0, block.timestamp, block.timestamp + 1);
        presaleMetrics.vote.data[presaleMetrics.vote.currentCycle] = voteData;
        //temporary data
        Presale.CalcData memory _calcData = Presale.CalcData(0,0,0,0,0,0,0,false);

        for (uint8 i = 0; i < Presale.SALE_TYPE_COUNT; i++) {
            Presale.Metrics storage metrics = presaleMetrics.sale[i];
            //temporary data
            Presale.SaleBasedCalc memory saleType = Presale.SaleBasedCalc(0,0,0,0,0,0);

            if (presaleInfo.consts[i].tokenPrice != 0) {
                _calcData._totalRefundAmount += presaleInfo.consts[i].totalToken;

                if (metrics.amountRaised >= presaleInfo.consts[i].softCap) {
                    saleType._adminCoinFee = ((metrics.amountRaised * presaleInfo.fees.projectCoinFee) / PRECISION);
                    saleType._adminTokenFee = ((metrics.soldTokens * presaleInfo.fees.projectTokenFee) / PRECISION);

                    _calcData._totalAdminCoinFee += saleType._adminCoinFee;
                    _calcData._totalAdminTokenFee += saleType._adminTokenFee;

                    if (presaleInfo.liquidityPercent != 0) {
                        saleType._liquidityCoin = (((metrics.amountRaised - saleType._adminCoinFee) * presaleInfo.liquidityPercent) /
                            PRECISION);
                        saleType._liquidityToken = listingTokens(saleType._liquidityCoin);
                        _calcData._totalLiquidityCoin += saleType._liquidityCoin;
                        _calcData._totalLiquidityToken += saleType._liquidityToken;
                    }

                    saleType._unsoldToken =
                        presaleInfo.consts[i].totalToken -
                        metrics.soldTokens -
                        saleType._liquidityToken -
                        saleType._adminTokenFee;
                    _calcData._totalUnsoldToken += saleType._unsoldToken;

                    saleType._remainingCoin = metrics.amountRaised - saleType._adminCoinFee - saleType._liquidityCoin;
                    metrics.tokenOwnerProfit = ((saleType._remainingCoin * presaleInfo.vesting.vestingPercentForProject) / PRECISION);
                    _calcData._totalTokenOwnerProfit += metrics.tokenOwnerProfit;
                } else {
                    _calcData.isSaleFailed = true;
                }
            }
        }
        if (_calcData.isSaleFailed) {
            presaleMetrics.result = Presale.Results.FAILED;
            presaleInfo.token.safeTransfer(tokenOwner, _calcData._totalRefundAmount);
            emit SaleFailed(address(this), tokenOwner, _calcData._totalRefundAmount, block.timestamp);
        } else {
            presaleMetrics.result = Presale.Results.SUCCESS;
        }
        if (presaleMetrics.adminFeeCounter > 0 && presaleMetrics.result == Presale.Results.SUCCESS) {
            if (_calcData._totalAdminCoinFee > 0 && _calcData._totalAdminTokenFee > 0) {
                presaleInfo.coin.safeTransfer(admin, _calcData._totalAdminCoinFee);
                presaleInfo.token.safeTransfer(admin, _calcData._totalAdminTokenFee);
            }
            if (_calcData._totalLiquidityCoin > 0 && _calcData._totalLiquidityToken > 0) {
                presaleInfo.coin.safeTransfer(address(presaleLockForwarder), _calcData._totalLiquidityCoin);
                presaleInfo.token.safeTransfer(address(presaleLockForwarder), _calcData._totalLiquidityToken);
                presaleLockForwarder.lockLiquidity(
                    presaleInfo.coin,
                    presaleInfo.token,
                    _calcData._totalLiquidityCoin,
                    _calcData._totalLiquidityToken,
                    block.timestamp + presaleInfo.lpLockPeriod,
                    tokenOwner
                );
            }
            if (_calcData._totalUnsoldToken > 0) {
                presaleInfo.token.safeTransfer(tokenOwner, _calcData._totalUnsoldToken);
                emit TokenUnsold(tokenOwner, _calcData._totalUnsoldToken);
            }
            if (_calcData._totalTokenOwnerProfit > 0) {
                presaleInfo.coin.safeTransfer(tokenOwner, _calcData._totalTokenOwnerProfit);
                users[address(this)].lastClaimedDate = block.timestamp;
                users[address(this)].claimCount += presaleInfo.vesting.claimPerVesting;
            }
            presaleInfo.token.safeTransfer(admin, presaleMetrics.adminFeeCounter);
        }
    }

    function calculateAvailableClaims(uint256 userClaimCount) internal view returns (uint256 count) {
        uint256 temp = (block.timestamp - presaleMetrics.preSaleEndTime) / presaleInfo.vesting.vestingTimeStep;
        if (userClaimCount == 0) count = 1;
        else if (temp == 0) count = 0;
        else count = temp - userClaimCount;
        return count;
    }

    // to claim token after launch => for web3 use
    function claim() public isAllowed nonReentrant {
        require(block.timestamp > presaleMetrics.preSaleEndTime, "PS: Presale time not over");
        require(presaleMetrics.claim.canClaim, "PS: Wait for the owner to end preSale");
        require(getTotalClaimableTokens(msg.sender) > 0, "PS: No claimable balance");
        Presale.User storage user = users[msg.sender];
        require(user.claimCount <= presaleMetrics.claim.maxCycle, "VT: you have claimed in this vesting");
        require(calculateAvailableClaims(user.claimCount) > 0, "VT: you have claimed in this vesting cycle");

        for (uint8 i = 0; i < Presale.SALE_TYPE_COUNT; i++) {
            if (presaleMetrics.result == Presale.Results.SUCCESS && user.sales[i].tokenBalance > 0) {
                user.lastClaimedDate = block.timestamp;
                if (user.claimCount == 0) {
                    user.sales[i].activeClaimAmountToken = ((user.sales[i].tokenBalance * presaleInfo.consts[i].vestingPercent) /
                        PRECISION);

                    uint256 remainingCoins = user.sales[i].coinBalance -
                        ((user.sales[i].coinBalance * presaleInfo.fees.projectCoinFee) / PRECISION);
                    user.sales[i].coinBalance = remainingCoins - ((remainingCoins * presaleInfo.liquidityPercent) / PRECISION);
                    user.sales[i].activeClaimAmountCoin = (user.sales[i].coinBalance * presaleInfo.consts[i].vestingPercent) / PRECISION;
                    user.sales[i].tokenBalance -= user.sales[i].activeClaimAmountToken;
                    user.sales[i].coinBalance -= user.sales[i].activeClaimAmountCoin;
                    presaleInfo.token.safeTransfer(msg.sender, user.sales[i].activeClaimAmountToken);
                    emit TokenClaimed(msg.sender, user.sales[i].activeClaimAmountToken);
                } else {
                    if (user.sales[i].tokenBalance >= user.sales[i].activeClaimAmountToken) {
                        user.sales[i].tokenBalance -= user.sales[i].activeClaimAmountToken;
                        user.sales[i].coinBalance -= user.sales[i].activeClaimAmountCoin;
                        presaleInfo.token.safeTransfer(msg.sender, user.sales[i].activeClaimAmountToken);
                        emit TokenClaimed(msg.sender, user.sales[i].activeClaimAmountToken);
                    } else {
                        uint256 tknBalance = user.sales[i].tokenBalance;
                        user.sales[i].tokenBalance = 0;
                        user.sales[i].coinBalance = 0;
                        presaleInfo.token.safeTransfer(msg.sender, tknBalance);
                        emit TokenClaimed(msg.sender, tknBalance);
                    }
                }
            } else {
                uint256 numberOfCoins = user.sales[i].coinBalance;
                if (numberOfCoins > 0) {
                    user.sales[i].coinBalance = 0;
                    presaleInfo.coin.safeTransfer(msg.sender, numberOfCoins);
                    emit CoinClaimed(msg.sender, numberOfCoins);
                }
            }
        }
        user.claimCount += 1;
    }

    function vote(bool _vote) public {
        uint256 currentVotingCycle = presaleMetrics.vote.currentCycle;
        Presale.VoteData storage voteData = presaleMetrics.vote.data[currentVotingCycle];
        Presale.UserVotingData storage userVoteData = users[msg.sender].votes[currentVotingCycle];
        require(presaleMetrics.vote.started, "VT: voting is not started");
        require(block.timestamp >= voteData.startTime && block.timestamp < voteData.endTime, "VT: Wrong timing");
        require(presaleInfo.token.balanceOf(msg.sender) > 0, "VT: Voter must be a holder");
        require(!userVoteData.voteCasted, "VT: cast a vote");

        userVoteData.vote = _vote;
        userVoteData.voteCasted = true;

        if (_vote) voteData.up += 1;
        else voteData.down += 1;
    }

    function startVoting(uint256 _endTime) external onlyAdmin {
        require(!presaleMetrics.vote.started, "VT: already started");
        require(presaleMetrics.status == Presale.States.FINISHED, "VT: Presale not finished");
        require(presaleMetrics.result == Presale.Results.SUCCESS, "VT: Presale failed");
        require(block.timestamp > presaleMetrics.vote.lastDate + presaleInfo.vesting.votingTimeStep, "VT: Vesting is not finished");

        uint256 endTime = block.timestamp + _endTime;
        presaleMetrics.vote.started = true;
        presaleMetrics.vote.currentCycle += 1;
        Presale.VoteData memory voteData = Presale.VoteData(0, 0, block.timestamp, endTime);
        presaleMetrics.vote.data[presaleMetrics.vote.currentCycle] = voteData;
        emit StartVoting(block.timestamp, endTime);
    }

    function endVoting() external onlyAdmin nonReentrant {
        require(presaleMetrics.vote.started, "VT: is not started");
        presaleMetrics.vote.started = false;
        Presale.VoteData memory votes = presaleMetrics.vote.data[presaleMetrics.vote.currentCycle];
        if (votes.up < votes.down) {
            uint256 refundAmount = getContractTokenBalance();
            presaleMetrics.result = Presale.Results.FAILED;
            presaleInfo.token.safeTransfer(tokenOwner, refundAmount);
            emit SaleFailed(address(this), tokenOwner, refundAmount, block.timestamp);
        } else {
            presaleMetrics.vote.lastDate = block.timestamp;
        }
        presaleMetrics.claim.maxCycle += presaleInfo.vesting.claimPerVesting;
        emit EndVoting(block.timestamp);
    }

    function whiteListUsers(address[] calldata _users, uint256 _type) external onlyTokenOwner {
        require(_type >= 0 && _type < Presale.SALE_TYPE_COUNT, "Invalid sale type");
        for (uint256 i = 0; i < _users.length; i++) {
            require(_users[i] != address(0), "Invalid address");
            users[_users[i]].sales[_type].whiteListed = true;
        }
        emit WhitelistedUsers(_users, _type);
    }

    function getTotalClaimableTokens(address userAddress) internal view returns (uint256 totalSum) {
        Presale.User storage user = users[userAddress];
        for (uint8 i = 0; i < Presale.SALE_TYPE_COUNT; i++) {
            totalSum += user.sales[i].tokenBalance;
        }
        return totalSum;
    }

    function getContractcoinBalance() public view returns (uint256) {
        return presaleInfo.coin.balanceOf(address(this));
    }

    function getContractTokenBalance() public view returns (uint256) {
        return presaleInfo.token.balanceOf(address(this));
    }

    // to Stop preSale in case of scam
    function setAllow(bool _enable) external onlyAdmin {
        presaleMetrics.isAllowed = _enable;
        emit SetAllow(_enable);
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getUserClaimData(address _user) public view returns (uint256 claimCount, uint256 lastClaimedDate) {
        claimCount = users[_user].claimCount;
        lastClaimedDate = users[_user].lastClaimedDate;
        return (claimCount, lastClaimedDate);
    }

    function getUserAvilableClaimCount(address _user) public view returns (uint256 count) {
        uint256 availableClaimsSinceBeggining = calculateAvailableClaims(users[_user].claimCount);
        uint256 totalClaimableTokens = getTotalClaimableTokens(_user);
        if (totalClaimableTokens > 0 && availableClaimsSinceBeggining > 0) {
            if(availableClaimsSinceBeggining >= presaleMetrics.claim.maxCycle) {
                count = presaleMetrics.claim.maxCycle > users[_user].claimCount ? presaleMetrics.claim.maxCycle - users[_user].claimCount : 0;
            }
            else {
                count = availableClaimsSinceBeggining;
            }
        }
        else count = 0;
        return count;
    }

    function getUserSaleData(address _user, uint256 _saleType)
        public
        view
        returns (Presale.UserSaleInfo memory userSale, uint256 joinDate)
    {
        require(_saleType >= 0 && _saleType < Presale.SALE_TYPE_COUNT, "Invalid sale type");
        userSale = users[_user].sales[_saleType];
        joinDate = users[_user].joinDate;
        return (userSale, joinDate);
    }

    function getSaleMetrics()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256
        )
    {
        return (
            presaleMetrics.totalUser,
            presaleMetrics.adminFeeCounter,
            presaleMetrics.preSaleEndTime,
            presaleMetrics.claim.maxCycle,
            presaleMetrics.votingTimeStep,
            presaleMetrics.isAllowed,
            uint256(presaleMetrics.result),
            uint256(presaleMetrics.status)
        );
    }

    function getSaleVote()
        public
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        return (presaleMetrics.vote.currentCycle, presaleMetrics.vote.lastDate, presaleMetrics.vote.started);
    }

    function getSaleVoteByCycle(uint256 _cycle) public view returns (Presale.VoteData memory voteData) {
        voteData = presaleMetrics.vote.data[_cycle];
        return voteData;
    }

    function getUserVotingData(address _user, uint256 _votingIndex) public view returns (bool _vote, bool _voteCasted) {
        return (users[_user].votes[_votingIndex].vote, users[_user].votes[_votingIndex].voteCasted);
    }

    function removeStuck() external onlyAdmin {
        uint256 coinBalance = presaleInfo.coin.balanceOf(address(this));
        require(coinBalance > 0, "Nothing to withdraw");
        presaleInfo.coin.safeTransfer(address(admin), coinBalance);
        emit RemoveStuckCoin(coinBalance);
    }

    function removeStuckToken(address _token, uint256 _amount) external onlyAdmin {
        IERC20Metadata token = IERC20Metadata(_token);
        require(_amount > 0, "Invalid amount");
        require(token.totalSupply() > 0, "Invalid token");
        token.safeTransfer(admin, _amount);
        emit RemoveStuckToken(_amount);
    }

    // to check number of token for buying
    function coinToToken(uint256 _amount, uint256 _tokenPrice) public view returns (uint256) {
        uint256 numberOfTokens = _amount * _tokenPrice;
        return (numberOfTokens * (10**(presaleInfo.token.decimals()))) / (10**(presaleInfo.coin.decimals()));
    }

    function listingTokens(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount * presaleInfo.listingPrice;
        return ((numberOfTokens * (10**(presaleInfo.token.decimals()))) / (10**(presaleInfo.coin.decimals())));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPresaleSettings {
    function getFees()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getRouter() external view returns (address);

    function getAdmin() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPresaleLockForwarder {
    function lockLiquidity(
        IERC20 _baseToken,
        IERC20 _saleToken,
        uint256 _baseAmount,
        uint256 _saleAmount,
        uint256 _unlock_date,
        address payable _withdrawer
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library Presale {
    uint8 public constant SALE_TYPE_COUNT = 4;

    struct Fees {
        uint256 userFee;
        uint256 projectCoinFee;
        uint256 projectTokenFee;
    }

    struct UserSaleInfo {
        bool whiteListed;
        uint256 coinBalance;
        uint256 tokenBalance;
        uint256 activeClaimAmountToken;
        uint256 activeClaimAmountCoin;
    }

    struct UserVotingData {
        bool vote;
        bool voteCasted;
    }

    struct User {
        uint256 claimCount;
        uint256 lastClaimedDate;
        uint256 joinDate;
        mapping(uint256 => UserSaleInfo) sales;
        mapping(uint256 => UserVotingData) votes;
    }

    struct SaleBasedCalc {
        uint256 _adminCoinFee;
        uint256 _adminTokenFee;
        uint256 _liquidityCoin;
        uint256 _liquidityToken;
        uint256 _unsoldToken;
        uint256 _remainingCoin;
    }

    struct CalcData {
        uint256 _totalAdminCoinFee;
        uint256 _totalAdminTokenFee;
        uint256 _totalLiquidityCoin;
        uint256 _totalLiquidityToken;
        uint256 _totalUnsoldToken;
        uint256 _totalTokenOwnerProfit;
        uint256 _totalRefundAmount;
        bool isSaleFailed;
    }

    struct Constants {
        uint256 tokenPrice;
        uint256 softCap;
        uint256 hardCap;
        uint256 vestingPercent;
        uint256 totalToken;
    }

    struct VestingData {
        uint256 vestingPercentForProject;
        uint256 vestingTimeStep;
        uint256 votingTimeStep;
        uint256 claimPerVesting;
    }

    struct Info {
        address payable presaleOwner;
        IERC20Metadata coin;
        IERC20Metadata token;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 liquidityPercent;
        uint256 lpLockPeriod;
        uint256 listingPrice;
        uint256 preSaleEndTime;
        uint256 totalToken;
        VestingData vesting;
        Fees fees;
        Constants[SALE_TYPE_COUNT] consts;
    }

    struct Metrics {
        uint256 amountRaised;
        uint256 soldTokens;
        uint256 tokenOwnerProfit;
    }

    struct VoteData {
        uint256 up;
        uint256 down;
        uint256 startTime;
        uint256 endTime;
    }

    struct Vote {
        uint256 currentCycle;
        uint256 lastDate;
        bool started;
        mapping(uint256 => VoteData) data;
    }

    struct Claim {
        uint256 maxCycle;
        bool canClaim;
        bool profitClaimed;
    }

    struct State {
        uint256 totalUser;
        uint256 adminFeeCounter;
        uint256 preSaleEndTime;
        uint256 votingTimeStep;
        bool isAllowed;
        Results result;
        States status;
        Vote vote;
        Claim claim;
        mapping(uint8 => Metrics) sale;
    }

    enum Results {
        FAILED,
        SUCCESS
    }

    enum States {
        RUNNING,
        FINISHED
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
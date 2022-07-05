// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "./TransferHelper.sol";
import "./EnumerableSet.sol";
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";

interface IDexFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPresaleLockForwarder {
    function lockLiquidity(IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlockDate, address payable _withdrawer) external;

    function dexPairIsInitialised(address _token0, address _token1) external view returns (bool);
}

interface IWrapToken {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

interface IPresaleSetting {
    function getMaxPresaleLength() external view returns (uint256);

    function getFirstRoundLength() external view returns (uint256);

    function userHoldSufficientFirstRoundToken(address _user) external view returns (bool);

    function getBaseFeePercent() external view returns (uint256);

    function getTokenFeePercent() external view returns (uint256);

    function getBaseFeeAddress() external view returns (address payable);

    function getTokenFeeAddress() external view returns (address payable);

    function getCreationFee() external view returns (uint256);

    function getAdminAddress() external view returns (address);

    function getMinLiquidityPercent() external view returns (uint256);

    function getMinLockPeriod() external view returns (uint256);

    function baseTokenIsValid(address _baseToken) external view returns (bool);

    function getFinishBeforeFirstRound() external view returns (uint256);

    function getZeroRoundTokenAddress() external view returns (address);

    function getZeroRoundTokenAmount() external view returns (uint256);

    function getZeroRoundPercent() external view returns (uint256);

    function getWrapTokenAddress() external view returns (address);

    function getDexLockerAddress() external view returns (address);

    function getMaxSuccessToLiquidity() external view returns (uint256);
}

contract Presale is ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    enum PRESALE_STATUS {PENDING, ACTIVE, SUCCESS, FAILED}

    event BuyToken(address user, uint256 baseTokenAmount, uint256 saleTokenAmount);
    event UserWithdrawSaleToken(address user, uint256 saleTokenAmount, uint256 percent, uint256 numberClaimed);
    event UserWithdrawBaseToken(address user, uint256 baseTokenAmount);
    event AddLiquidity(uint256 baseFeeAmount, uint256 tokenFeeAmount, uint256 baseLiquidity, uint256 tokenLiquidity, uint256 remainingBaseTokenBalance, uint256 remainingSaleTokenBalance, uint256 zeroRoundTokenBurn);

    struct PresaleInfo {
        address payable PRESALE_OWNER;
        IERC20 SALE_TOKEN; // sale token
        IERC20 BASE_TOKEN; // base token usually WETH (ETH), WBNB (BNB)
        uint256 TOKEN_PRICE; // 1 base token = ? sale_tokens, fixed price
        uint256 LIMIT_PER_BUYER; // maximum base token BUY amount per account
        uint256 AMOUNT; // the amount of presale tokens up for presale
        uint256 HARD_CAP;
        uint256 SOFT_CAP;
        uint256 LIQUIDITY_PERCENT;
        uint256 LISTING_PRICE; // fixed rate at which the token will list on Dex
        uint256 START_TIME;
        uint256 END_TIME;
        uint256 LOCK_PERIOD;
        bool PRESALE_IN_MAIN_TOKEN;
        address WRAP_TOKEN_ADDRESS;
        address DEX_LOCKER_ADDRESS;
        address DEX_FACTORY_ADDRESS;
        address payable FUND_ADDRESS;
    }

    struct PresaleRound {
        bool ACTIVE_ZERO_ROUND;
        bool ACTIVE_FIRST_ROUND;
        PresaleZeroRoundInfo ZERO_ROUND_INFO;
    }

    struct PresaleVesting {
        bool ACTIVE_VESTING;
        uint256[] VESTING_PERIOD;
        uint256[] VESTING_PERCENT;
    }

    struct PresaleZeroRoundInfo {
        address TOKEN_ADDRESS;
        uint256 TOKEN_AMOUNT;
        uint256 PERCENT;
        uint256 FINISH_BEFORE_FIRST_ROUND;
        uint256 FINISH_AT;
        uint256 MAX_BASE_TOKEN_AMOUNT;
        uint256 MAX_SLOT;
        uint256 REGISTERED_SLOT;
        EnumerableSet.AddressSet LIST_USER;
    }

    struct PresaleFeeInfo {
        uint256 BASE_FEE_PERCENT;
        uint256 TOKEN_FEE_PERCENT;
        address payable BASE_FEE_ADDRESS;
        address payable TOKEN_FEE_ADDRESS;
    }

    struct PresaleStatusInfo {
        bool WHITELIST_ONLY; // if set to true only whitelisted members may participate
        bool LP_GENERATION_COMPLETE; // final flag required to end a presale and enable withdrawals
        bool FORCE_FAILED; // set this flag to force fail the presale
        uint256 TOTAL_BASE_COLLECTED; // total base currency raised (usually ETH)
        uint256 TOTAL_TOKEN_SOLD; // total presale token sold
        uint256 TOTAL_TOKEN_WITHDRAWN; // total token withdrawn post successful presale
        uint256 TOTAL_BASE_WITHDRAWN; // total base token withdrawn on presale failure
        uint256 FIRST_ROUND_LENGTH; // in seconds
        uint256 NUM_BUYERS; // number of unique participants
        EnumerableSet.AddressSet LIST_BUYER;
        uint256 SUCCESS_AT;
        uint256 LIQUIDITY_AT;
    }

    struct BuyerInfo {
        uint256 baseDeposited; // total base token (ETH/BNB...) deposited by user, can be withdrawn on presale failure
        uint256 tokenBought; // num presale token a user bought, can be withdrawn on presale success
        uint256 tokenClaimed; // num presale token a user claimed
        uint256 numberClaimed;
        uint256[] historyTimeClaimed;
        uint256[] historyAmountClaimed;
    }

    struct PRESALE {
        uint256 CONTRACT_VERSION;
        address PRESALE_GENERATOR;
        string CONTRACT_TYPE;
        PresaleInfo INFO;
        PresaleFeeInfo FEE;
        PresaleStatusInfo STATUS;
        PresaleRound ROUND_INFO;
        PresaleVesting VESTING_INFO;
    }

    PRESALE PRESALE_ITEM;
    IPresaleLockForwarder public PRESALE_LOCK_FORWARDER;
    IPresaleSetting public PRESALE_SETTING;
    IWrapToken public WrapToken;
    mapping(address => BuyerInfo) public BUYERS;
    EnumerableSet.AddressSet private WHITELIST;

    constructor(address _presaleGenerator) {
        PRESALE_ITEM.CONTRACT_VERSION = 3;
        PRESALE_ITEM.PRESALE_GENERATOR = _presaleGenerator;
        PRESALE_SETTING = IPresaleSetting(0xccc6257EB4bA7075Dc597A6d42f50a46B6bDDf25);
        PRESALE_LOCK_FORWARDER = IPresaleLockForwarder(0xb379B29a22FB712c40f78F8306B6C43C0589c87f);
        PRESALE_ITEM.INFO.WRAP_TOKEN_ADDRESS = PRESALE_SETTING.getWrapTokenAddress();
        PRESALE_ITEM.INFO.DEX_LOCKER_ADDRESS = PRESALE_SETTING.getDexLockerAddress();
        PRESALE_ITEM.INFO.DEX_FACTORY_ADDRESS = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
        WrapToken = IWrapToken(PRESALE_ITEM.INFO.WRAP_TOKEN_ADDRESS);
    }

    function setMainInfo(
        address payable _presaleOwner,
        uint256 _amount,
        uint256 _tokenPrice,
        uint256 _limitPerBuyer,
        uint256 _hardCap,
        uint256 _softCap,
        uint256 _liquidityPercent,
        uint256 _listingPrice,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _lockPeriod
    ) external {
        require(msg.sender == PRESALE_ITEM.PRESALE_GENERATOR, 'FORBIDDEN');
        PRESALE_ITEM.INFO.PRESALE_OWNER = _presaleOwner;
        PRESALE_ITEM.INFO.FUND_ADDRESS = _presaleOwner;
        PRESALE_ITEM.INFO.AMOUNT = _amount;
        PRESALE_ITEM.INFO.TOKEN_PRICE = _tokenPrice;
        PRESALE_ITEM.INFO.LIMIT_PER_BUYER = _limitPerBuyer;
        PRESALE_ITEM.INFO.HARD_CAP = _hardCap;
        PRESALE_ITEM.INFO.SOFT_CAP = _softCap;
        PRESALE_ITEM.INFO.LIQUIDITY_PERCENT = _liquidityPercent;
        PRESALE_ITEM.INFO.LISTING_PRICE = _listingPrice;
        PRESALE_ITEM.INFO.START_TIME = _startTime;
        PRESALE_ITEM.INFO.END_TIME = _endTime;
        PRESALE_ITEM.INFO.LOCK_PERIOD = _lockPeriod;
    }

    function setFeeInfo(
        IERC20 _baseToken,
        IERC20 _presaleToken,
        uint256 _baseFeePercent,
        uint256 _tokenFeePercent,
        address payable _baseFeeAddress,
        address payable _tokenFeeAddress
    ) external {
        require(msg.sender == PRESALE_ITEM.PRESALE_GENERATOR, 'FORBIDDEN');

        PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN = address(_baseToken) == address(WrapToken);
        PRESALE_ITEM.INFO.SALE_TOKEN = _presaleToken;
        PRESALE_ITEM.INFO.BASE_TOKEN = _baseToken;

        PRESALE_ITEM.FEE.BASE_FEE_PERCENT = _baseFeePercent;
        PRESALE_ITEM.FEE.TOKEN_FEE_PERCENT = _tokenFeePercent;

        PRESALE_ITEM.FEE.BASE_FEE_ADDRESS = _baseFeeAddress;
        PRESALE_ITEM.FEE.TOKEN_FEE_ADDRESS = _tokenFeeAddress;

        PRESALE_ITEM.STATUS.FIRST_ROUND_LENGTH = PRESALE_SETTING.getFirstRoundLength();
    }

    function setRoundInfo(
        bool _activeZeroRound,
        bool _activeFirstRound
    ) external {
        require(msg.sender == PRESALE_ITEM.PRESALE_GENERATOR, 'FORBIDDEN');

        if (PRESALE_SETTING.getZeroRoundTokenAddress() == address(0)) {
            _activeZeroRound = false;
        }
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.PERCENT = PRESALE_SETTING.getZeroRoundPercent();
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_BASE_TOKEN_AMOUNT = PRESALE_ITEM.INFO.HARD_CAP.div(1000).mul(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.PERCENT);
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_SLOT = PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_BASE_TOKEN_AMOUNT.div(PRESALE_ITEM.INFO.LIMIT_PER_BUYER);
        if (PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_SLOT == 0) {
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.PERCENT = 0;
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_BASE_TOKEN_AMOUNT = 0;
            _activeZeroRound = false;
        }

        PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND = _activeZeroRound;
        PRESALE_ITEM.ROUND_INFO.ACTIVE_FIRST_ROUND = _activeFirstRound;

        if (PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND) {
            // ZERO ROUND INFO
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS = PRESALE_SETTING.getZeroRoundTokenAddress();
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_AMOUNT = PRESALE_SETTING.getZeroRoundTokenAmount();
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_BEFORE_FIRST_ROUND = PRESALE_SETTING.getFinishBeforeFirstRound();
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_AT = PRESALE_ITEM.INFO.START_TIME.sub(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_BEFORE_FIRST_ROUND);
            PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT = 0;
        }
    }

    function setVestingInfo(
        bool _activeVesting,
        uint256[] memory _vestingPeriod,
        uint256[] memory _vestingPercent
    ) external {
        require(msg.sender == PRESALE_ITEM.PRESALE_GENERATOR, 'FORBIDDEN');

        PRESALE_ITEM.VESTING_INFO.ACTIVE_VESTING = _activeVesting;
        PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD = _vestingPeriod;
        PRESALE_ITEM.VESTING_INFO.VESTING_PERCENT = _vestingPercent;
        if (_activeVesting) {
            PRESALE_ITEM.CONTRACT_TYPE = 'vesting';
        } else {
            PRESALE_ITEM.CONTRACT_TYPE = 'normal';
        }
    }

    modifier onlyPresaleOwner() {
        require(PRESALE_ITEM.INFO.PRESALE_OWNER == msg.sender, "NOT PRESALE OWNER");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == PRESALE_SETTING.getAdminAddress(), "SENDER IS NOT ADMIN");
        _;
    }

    function getPresaleStatus() public view returns (uint256) {
        if (PRESALE_ITEM.STATUS.FORCE_FAILED) {
            return uint256(PRESALE_STATUS.FAILED);
            // FAILED - force fail
        }
        if ((block.timestamp > PRESALE_ITEM.INFO.END_TIME) && (PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED < PRESALE_ITEM.INFO.SOFT_CAP)) {
            return uint256(PRESALE_STATUS.FAILED);
            // FAILED - soft cap not met by end time
        }
        if (PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED >= PRESALE_ITEM.INFO.HARD_CAP) {
            return uint256(PRESALE_STATUS.SUCCESS);
            // SUCCESS - hard cap met
        }
        if ((block.timestamp > PRESALE_ITEM.INFO.END_TIME) && (PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED >= PRESALE_ITEM.INFO.SOFT_CAP)) {
            return uint256(PRESALE_STATUS.SUCCESS);
            // SUCCESS - end time and soft cap reached
        }
        if ((block.timestamp >= PRESALE_ITEM.INFO.START_TIME) && (block.timestamp <= PRESALE_ITEM.INFO.END_TIME)) {
            return uint256(PRESALE_STATUS.ACTIVE);
            // ACTIVE - deposits enabled
        }
        // PENDING - awaiting start time
        return uint256(PRESALE_STATUS.PENDING);
    }

    function getPresaleRound() public view returns (int8) {
        int8 round = - 1;
        if (block.timestamp < PRESALE_ITEM.INFO.START_TIME) {
            if (PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND) {
                if (block.timestamp <= PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_AT) {
                    round = 0;
                }
            }
        } else {
            if (block.timestamp <= PRESALE_ITEM.INFO.END_TIME) {
                if (PRESALE_ITEM.ROUND_INFO.ACTIVE_FIRST_ROUND) {
                    if (block.timestamp < (PRESALE_ITEM.INFO.START_TIME + PRESALE_ITEM.STATUS.FIRST_ROUND_LENGTH)) {
                        round = 1;
                    } else {
                        round = 2;
                    }
                } else {
                    round = 2;
                }
            }
        }
        return round;
    }

    function buyToken(uint256 _amount) external payable nonReentrant {
        if (PRESALE_ITEM.STATUS.WHITELIST_ONLY) {
            require(WHITELIST.contains(msg.sender), 'NOT WHITELISTED');
        }
        if (getPresaleRound() < 0) {
            // After Round 0 And Before Round 1 Or After Round 2 (Finished)
            require(getPresaleStatus() == uint256(PRESALE_STATUS.ACTIVE), 'NOT ACTIVE');
        } else if (getPresaleRound() == 0) {
            // Still in time Round 0 - Before Round 1
            if (PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND) {
                require(getPresaleStatus() == uint256(PRESALE_STATUS.PENDING), 'NOT ACTIVE');
                require(block.timestamp < PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_AT, "ROUND 0 FINISHED");
                if (!PRESALE_ITEM.STATUS.WHITELIST_ONLY) {
                    require(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.contains(msg.sender), "ROUND 0 NOT REGISTERED");
                }
            } else {
                require(getPresaleStatus() == uint256(PRESALE_STATUS.ACTIVE), 'NOT ACTIVE');
            }
        } else if (getPresaleRound() == 1) {
            // Presale Round 1 - require participant to hold a certain token and balance
            require(getPresaleStatus() == uint256(PRESALE_STATUS.ACTIVE), 'NOT ACTIVE');
            if (PRESALE_ITEM.ROUND_INFO.ACTIVE_FIRST_ROUND && !PRESALE_ITEM.STATUS.WHITELIST_ONLY) {
                bool userHoldsSpecificTokens = PRESALE_SETTING.userHoldSufficientFirstRoundToken(msg.sender);
                require(userHoldsSpecificTokens, 'INSUFFICIENT ROUND 1 TOKEN BALANCE');
            }
        } else {
            require(getPresaleStatus() == uint256(PRESALE_STATUS.ACTIVE), 'NOT ACTIVE');
        }
        BuyerInfo storage buyer = BUYERS[msg.sender];
        uint256 amountDeposit = PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN ? msg.value : _amount;
        uint256 allowToBuy = PRESALE_ITEM.INFO.LIMIT_PER_BUYER.sub(buyer.baseDeposited);
        uint256 remaining = PRESALE_ITEM.INFO.HARD_CAP - PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED;
        allowToBuy = allowToBuy > remaining ? remaining : allowToBuy;
        if (amountDeposit > allowToBuy) {
            amountDeposit = allowToBuy;
        }
        uint256 tokensSold = amountDeposit.mul(PRESALE_ITEM.INFO.TOKEN_PRICE).div(10 ** uint256(PRESALE_ITEM.INFO.BASE_TOKEN.decimals()));
        require(tokensSold > 0, 'ZERO TOKENS');
        if (buyer.baseDeposited == 0) {
            PRESALE_ITEM.STATUS.NUM_BUYERS++;
            PRESALE_ITEM.STATUS.LIST_BUYER.add(msg.sender);
            buyer.tokenClaimed = 0;
            buyer.numberClaimed = 0;
        }
        buyer.baseDeposited = buyer.baseDeposited.add(amountDeposit);
        buyer.tokenBought = buyer.tokenBought.add(tokensSold);
        PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED = PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED.add(amountDeposit);
        PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD = PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD.add(tokensSold);
        // Return unused Main Token
        if (PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN && amountDeposit < msg.value) {
            payable(msg.sender).transfer(msg.value.sub(amountDeposit));
        }
        if (!PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN) {
            TransferHelper.safeTransferFrom(address(PRESALE_ITEM.INFO.BASE_TOKEN), msg.sender, address(this), amountDeposit);
        }
        if (PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED >= PRESALE_ITEM.INFO.SOFT_CAP && PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED < PRESALE_ITEM.INFO.HARD_CAP) {
            PRESALE_ITEM.STATUS.SUCCESS_AT = PRESALE_ITEM.INFO.END_TIME;
        }
        if (PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED >= PRESALE_ITEM.INFO.HARD_CAP) {
            PRESALE_ITEM.STATUS.SUCCESS_AT = block.timestamp;
        }
        emit BuyToken(msg.sender, amountDeposit, tokensSold);
    }

    function userWithdrawSaleToken() external nonReentrant {
        require(PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE, 'AWAITING LP GENERATION');
        BuyerInfo storage buyer = BUYERS[msg.sender];
        uint256 tokensRemainingDenominator = PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD.sub(PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN);
        uint256 currentClaimPercent;
        uint256 tokenBought;
        if (PRESALE_ITEM.VESTING_INFO.ACTIVE_VESTING) {
            require(buyer.numberClaimed < PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD.length, 'ALREADY CLAIMED ALL TOKENS');
            uint256 currentClaimTime = PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD[buyer.numberClaimed];
            require(block.timestamp >= currentClaimTime, 'INVALID CLAIM TIME');
            uint256 currentClaimAmount;
            currentClaimPercent = PRESALE_ITEM.VESTING_INFO.VESTING_PERCENT[buyer.numberClaimed];
            if (buyer.numberClaimed == PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD.length - 1) {
                currentClaimAmount = buyer.tokenBought.sub(buyer.tokenClaimed);
            } else {
                currentClaimAmount = buyer.tokenBought.div(1000).mul(currentClaimPercent);
            }
            tokenBought = PRESALE_ITEM.INFO.SALE_TOKEN.balanceOf(address(this)).mul(currentClaimAmount).div(tokensRemainingDenominator);
            PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN = PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN.add(currentClaimAmount);
            require(tokenBought > 0, 'NOTHING TO WITHDRAW');
            buyer.tokenClaimed = buyer.tokenClaimed.add(tokenBought);
        } else {
            currentClaimPercent = 1000;
            tokenBought = PRESALE_ITEM.INFO.SALE_TOKEN.balanceOf(address(this)).mul(buyer.tokenBought).div(tokensRemainingDenominator);
            PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN = PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN.add(buyer.tokenBought);
            require(tokenBought > 0, 'NOTHING TO WITHDRAW');
            buyer.tokenClaimed = buyer.tokenBought;
        }
        buyer.historyAmountClaimed.push(tokenBought);
        buyer.historyTimeClaimed.push(block.timestamp);
        buyer.numberClaimed += 1;
        TransferHelper.safeTransfer(address(PRESALE_ITEM.INFO.SALE_TOKEN), msg.sender, tokenBought);
        emit UserWithdrawSaleToken(msg.sender, tokenBought, currentClaimPercent, buyer.numberClaimed);
    }

    function userWithdrawBaseToken() external nonReentrant {
        require(getPresaleStatus() == uint256(PRESALE_STATUS.FAILED), 'NOT FAILED');
        if (PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.contains(msg.sender)) {
            TransferHelper.safeTransfer(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS, msg.sender, PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_AMOUNT);
        }

        BuyerInfo storage buyer = BUYERS[msg.sender];
        uint256 baseRemainingDenominator = PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED.sub(PRESALE_ITEM.STATUS.TOTAL_BASE_WITHDRAWN);
        uint256 remainingBaseBalance = PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN ? address(this).balance : PRESALE_ITEM.INFO.BASE_TOKEN.balanceOf(address(this));
        uint256 baseToken = remainingBaseBalance.mul(buyer.baseDeposited).div(baseRemainingDenominator);
        require(baseToken > 0, 'NOTHING TO WITHDRAW');
        PRESALE_ITEM.STATUS.TOTAL_BASE_WITHDRAWN = PRESALE_ITEM.STATUS.TOTAL_BASE_WITHDRAWN.add(buyer.baseDeposited);
        buyer.baseDeposited = 0;
        TransferHelper.safeTransferBaseToken(address(PRESALE_ITEM.INFO.BASE_TOKEN), payable(msg.sender), baseToken, !PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN);
        emit UserWithdrawBaseToken(msg.sender, baseToken);
    }

    function ownerWithdrawSaleToken() external onlyPresaleOwner {
        require(getPresaleStatus() == uint256(PRESALE_STATUS.FAILED), 'NOT FAILED');
        TransferHelper.safeTransfer(address(PRESALE_ITEM.INFO.SALE_TOKEN), PRESALE_ITEM.INFO.PRESALE_OWNER, PRESALE_ITEM.INFO.SALE_TOKEN.balanceOf(address(this)));
    }

    function forceFailIfPairExists() external {
        require(!PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE && !PRESALE_ITEM.STATUS.FORCE_FAILED);
        if (PRESALE_LOCK_FORWARDER.dexPairIsInitialised(address(PRESALE_ITEM.INFO.SALE_TOKEN), address(PRESALE_ITEM.INFO.BASE_TOKEN))) {
            PRESALE_ITEM.STATUS.FORCE_FAILED = true;
        }
    }

    function forceFailByAdmin() onlyAdmin external {
        PRESALE_ITEM.STATUS.FORCE_FAILED = true;
    }

    function addLiquidity() external nonReentrant {
        require(!PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE, 'GENERATION COMPLETE');
        require(getPresaleStatus() == uint256(PRESALE_STATUS.SUCCESS), 'NOT SUCCESS');
        if (PRESALE_LOCK_FORWARDER.dexPairIsInitialised(address(PRESALE_ITEM.INFO.SALE_TOKEN), address(PRESALE_ITEM.INFO.BASE_TOKEN))) {
            PRESALE_ITEM.STATUS.FORCE_FAILED = true;
            return;
        }

        // If not presale owner, can add after success time + max success to liquidity
        if (PRESALE_ITEM.INFO.PRESALE_OWNER != msg.sender) {
            require(block.timestamp >= PRESALE_ITEM.STATUS.SUCCESS_AT + PRESALE_SETTING.getMaxSuccessToLiquidity(), "LIQUIDITY TIME FOR PRESALE OWNER");
        }
        uint256 baseFeeAmount = PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED.mul(PRESALE_ITEM.FEE.BASE_FEE_PERCENT).div(1000);
        // base token liquidity
        uint256 baseLiquidity = PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED.sub(baseFeeAmount).mul(PRESALE_ITEM.INFO.LIQUIDITY_PERCENT).div(1000);
        if (PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN) {
            WrapToken.deposit{value : baseLiquidity}();
        }
        TransferHelper.safeApprove(address(PRESALE_ITEM.INFO.BASE_TOKEN), address(PRESALE_LOCK_FORWARDER), baseLiquidity);
        // sale token liquidity
        uint256 tokenLiquidity = baseLiquidity.mul(PRESALE_ITEM.INFO.LISTING_PRICE).div(10 ** uint256(PRESALE_ITEM.INFO.BASE_TOKEN.decimals()));
        TransferHelper.safeApprove(address(PRESALE_ITEM.INFO.SALE_TOKEN), address(PRESALE_LOCK_FORWARDER), tokenLiquidity);
        PRESALE_LOCK_FORWARDER.lockLiquidity(PRESALE_ITEM.INFO.BASE_TOKEN, PRESALE_ITEM.INFO.SALE_TOKEN, baseLiquidity, tokenLiquidity, block.timestamp + PRESALE_ITEM.INFO.LOCK_PERIOD, PRESALE_ITEM.INFO.PRESALE_OWNER);
        // transfer fees
        uint256 tokenFeeAmount = PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD.mul(PRESALE_ITEM.FEE.TOKEN_FEE_PERCENT).div(1000);
        TransferHelper.safeTransferBaseToken(address(PRESALE_ITEM.INFO.BASE_TOKEN), PRESALE_ITEM.FEE.BASE_FEE_ADDRESS, baseFeeAmount, !PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN);
        TransferHelper.safeTransfer(address(PRESALE_ITEM.INFO.SALE_TOKEN), PRESALE_ITEM.FEE.TOKEN_FEE_ADDRESS, tokenFeeAmount);
        // burn unsold tokens
        uint256 remainingSaleTokenBalance = PRESALE_ITEM.INFO.SALE_TOKEN.balanceOf(address(this));
        if (remainingSaleTokenBalance > PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD) {
            uint256 burnAmount = remainingSaleTokenBalance.sub(PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD);
            TransferHelper.safeTransfer(address(PRESALE_ITEM.INFO.SALE_TOKEN), 0x000000000000000000000000000000000000dEaD, burnAmount);
        }
        // Burn Zero  Round Token
        uint256 zeroRoundTokenBurn = 0;
        if (PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT > 0) {
            uint256 zeroRoundRegisteredTokenAmount = PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT.mul(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_AMOUNT);
            uint256 zeroRoundTokenBalance = IERC20(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS).balanceOf(address(this));
            zeroRoundTokenBurn = zeroRoundRegisteredTokenAmount > zeroRoundTokenBalance ? zeroRoundTokenBalance : zeroRoundRegisteredTokenAmount;
            TransferHelper.safeTransfer(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS, 0x000000000000000000000000000000000000dEaD, zeroRoundTokenBurn);
        }
        // send remaining base tokens to presale owner
        uint256 remainingBaseTokenBalance = PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN ? address(this).balance : PRESALE_ITEM.INFO.BASE_TOKEN.balanceOf(address(this));
        TransferHelper.safeTransferBaseToken(address(PRESALE_ITEM.INFO.BASE_TOKEN), PRESALE_ITEM.INFO.FUND_ADDRESS, remainingBaseTokenBalance, !PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN);

        PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE = true;
        PRESALE_ITEM.STATUS.LIQUIDITY_AT = block.timestamp;
        emit AddLiquidity(baseFeeAmount, tokenFeeAmount, baseLiquidity, tokenLiquidity, remainingBaseTokenBalance, remainingSaleTokenBalance, zeroRoundTokenBurn);
    }

    function updateLimitPerBuyer(uint256 _limitPerBuyer) external onlyPresaleOwner {
        require(PRESALE_ITEM.INFO.START_TIME > block.timestamp, 'STARTED');
        PRESALE_ITEM.INFO.LIMIT_PER_BUYER = _limitPerBuyer;
    }

    function updateTime(uint256 _startTime, uint256 _endTime) external onlyPresaleOwner {
        require(getPresaleStatus() != uint256(PRESALE_STATUS.SUCCESS) && getPresaleStatus() != uint256(PRESALE_STATUS.FAILED), 'INVALID STATUS');
        require(_endTime > _startTime, 'INVALID END TIME');
        // if presale already started, not allow to update start time, just update end time
        if (PRESALE_ITEM.INFO.START_TIME <= block.timestamp) {
            require(PRESALE_ITEM.INFO.START_TIME.add(PRESALE_SETTING.getMaxPresaleLength()) >= _endTime, 'INVALID LENGTH');
            PRESALE_ITEM.INFO.END_TIME = _endTime;
        } else {
            // if presale not start, require new start time must be greater than now
            require(_startTime > block.timestamp, "INVALID START TIME");
            require(_startTime.add(PRESALE_SETTING.getMaxPresaleLength()) >= _endTime, 'INVALID PRESALE LENGTH');
            PRESALE_ITEM.INFO.START_TIME = _startTime;
            PRESALE_ITEM.INFO.END_TIME = _endTime;
        }
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_AT = PRESALE_ITEM.INFO.START_TIME.sub(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_BEFORE_FIRST_ROUND);
    }

    function updateFundAddress(address fundAddress) external onlyPresaleOwner {
        require(PRESALE_ITEM.STATUS.LIQUIDITY_AT <= 0, 'ALREADY ADD LIQUIDITY');
        PRESALE_ITEM.INFO.FUND_ADDRESS = payable(fundAddress);
    }

    function getWhitelistFlag() external view returns (bool) {
        return PRESALE_ITEM.STATUS.WHITELIST_ONLY;
    }

    function setWhitelistFlag(bool _flag) external onlyPresaleOwner {
        PRESALE_ITEM.STATUS.WHITELIST_ONLY = _flag;
    }

    function editWhitelist(address[] memory _users, bool _add) external onlyPresaleOwner {
        if (_add) {
            for (uint256 i = 0; i < _users.length; i++) {
                WHITELIST.add(_users[i]);
            }
        } else {
            for (uint256 i = 0; i < _users.length; i++) {
                WHITELIST.remove(_users[i]);
            }
        }
    }

    function getWhitelistedUsersLength() external view returns (uint256) {
        return WHITELIST.length();
    }

    function getWhitelistedUserAtIndex(uint256 _index) external view returns (address) {
        return WHITELIST.at(_index);
    }

    function getUserWhitelistStatus(address _user) external view returns (bool) {
        return WHITELIST.contains(_user);
    }

    function registerZeroRound() external nonReentrant {
        if (PRESALE_ITEM.STATUS.WHITELIST_ONLY) {
            require(WHITELIST.contains(msg.sender), 'NOT WHITELISTED');
        }

        require(PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND, 'ROUND 0 NOT ACTIVE');
        require(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS != address(0), 'ROUND 0 NOT ACTIVE');
        require(getPresaleRound() == 0, "ROUND 0 FINISHED");
        require(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT < PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_SLOT, "ROUND 0 ENOUGH SLOT");
        require(!PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.contains(msg.sender), "ROUND 0 ALREADY REGISTERED");

        TransferHelper.safeTransferFrom(PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS, address(msg.sender), address(this), PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_AMOUNT);
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT = PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT.add(1);
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.add(msg.sender);
    }

    function updateVestingInfo(
        uint256[] memory _vestingPeriod,
        uint256[] memory _vestingPercent
    ) external onlyPresaleOwner nonReentrant {
        require(!PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE, 'GENERATION COMPLETE');
        require(PRESALE_ITEM.VESTING_INFO.ACTIVE_VESTING, 'NOT ACTIVE VESTING');

        require(_vestingPeriod.length > 0, 'INVALID VESTING PERIOD');
        require(_vestingPeriod.length == _vestingPercent.length, 'INVALID VESTING DATA');
        uint256 totalVestingPercent = 0;
        for (uint256 i = 0; i < _vestingPercent.length; i++) {
            totalVestingPercent = totalVestingPercent.add(_vestingPercent[i]);
        }
        require(totalVestingPercent == 1000, 'INVALID VESTING PERCENT');

        PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD = _vestingPeriod;
        PRESALE_ITEM.VESTING_INFO.VESTING_PERCENT = _vestingPercent;
    }

    function getGeneralInfo() external view returns (uint256 contractVersion, string memory contractType, address presaleGenerator) {
        return (PRESALE_ITEM.CONTRACT_VERSION, PRESALE_ITEM.CONTRACT_TYPE, PRESALE_ITEM.PRESALE_GENERATOR);
    }

    function getRoundInfo() external view returns (bool activeZeroRound, bool activeFirstRound) {
        return (PRESALE_ITEM.ROUND_INFO.ACTIVE_ZERO_ROUND, PRESALE_ITEM.ROUND_INFO.ACTIVE_FIRST_ROUND);
    }

    function getZeroRoundInfo() external view returns (
        address tokenAddress,
        uint256 tokenAmount,
        uint256 percent,
        uint256 finishBeforeFirstRound,
        uint256 finishAt,
        uint256 maxBaseTokenAmount,
        uint256 maxSlot,
        uint256 registeredSlot
    ) {
        return (
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_ADDRESS,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.TOKEN_AMOUNT,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.PERCENT,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_BEFORE_FIRST_ROUND,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.FINISH_AT,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_BASE_TOKEN_AMOUNT,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.MAX_SLOT,
        PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.REGISTERED_SLOT
        );
    }


    function getZeroRoundUserLength() external view returns (uint256) {
        return PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.length();
    }

    function getZeroRoundUserAtIndex(uint256 _index) external view returns (address) {
        return PRESALE_ITEM.ROUND_INFO.ZERO_ROUND_INFO.LIST_USER.at(_index);
    }

    function getFeeInfo() external view returns (
        uint256 baseFeePercent,
        uint256 tokenFeePercent,
        address baseFeeAddress,
        address tokenFeeAddress
    ) {
        return (
        PRESALE_ITEM.FEE.BASE_FEE_PERCENT,
        PRESALE_ITEM.FEE.TOKEN_FEE_PERCENT,
        PRESALE_ITEM.FEE.BASE_FEE_ADDRESS,
        PRESALE_ITEM.FEE.TOKEN_FEE_ADDRESS
        );
    }

    function getStatusInfo() external view returns (
        bool whitelistOnly,
        bool lpGenerationComplete,
        bool forceFailed,
        uint256 totalBaseCollected,
        uint256 totalTokenSold,
        uint256 totalTokenWithdrawn,
        uint256 totalBaseWithdrawn,
        uint256 firstRoundLength,
        uint256 numBuyers,
        uint256 successAt,
        uint256 liquidityAt,
        uint256 currentStatus,
        int8 currentRound
    ) {
        return (
        PRESALE_ITEM.STATUS.WHITELIST_ONLY,
        PRESALE_ITEM.STATUS.LP_GENERATION_COMPLETE,
        PRESALE_ITEM.STATUS.FORCE_FAILED,
        PRESALE_ITEM.STATUS.TOTAL_BASE_COLLECTED,
        PRESALE_ITEM.STATUS.TOTAL_TOKEN_SOLD,
        PRESALE_ITEM.STATUS.TOTAL_TOKEN_WITHDRAWN,
        PRESALE_ITEM.STATUS.TOTAL_BASE_WITHDRAWN,
        PRESALE_ITEM.STATUS.FIRST_ROUND_LENGTH,
        PRESALE_ITEM.STATUS.NUM_BUYERS,
        PRESALE_ITEM.STATUS.SUCCESS_AT,
        PRESALE_ITEM.STATUS.LIQUIDITY_AT,
        getPresaleStatus(),
        getPresaleRound()
        );
    }

    function getListBuyerLength() external view returns (uint256) {
        return PRESALE_ITEM.STATUS.LIST_BUYER.length();
    }
    function getListBuyerLengthAtIndex(uint256 _index) external view returns (address) {
        return PRESALE_ITEM.STATUS.LIST_BUYER.at(_index);
    }
    function getPresaleMainInfo() external view returns (
        uint256 tokenPrice,
        uint256 limitPerBuyer,
        uint256 amount,
        uint256 hardCap,
        uint256 softCap,
        uint256 liquidityPercent,
        uint256 listingPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 lockPeriod,
        bool presaleInMainToken
    ) {
        return (
        PRESALE_ITEM.INFO.TOKEN_PRICE,
        PRESALE_ITEM.INFO.LIMIT_PER_BUYER,
        PRESALE_ITEM.INFO.AMOUNT,
        PRESALE_ITEM.INFO.HARD_CAP,
        PRESALE_ITEM.INFO.SOFT_CAP,
        PRESALE_ITEM.INFO.LIQUIDITY_PERCENT,
        PRESALE_ITEM.INFO.LISTING_PRICE,
        PRESALE_ITEM.INFO.START_TIME,
        PRESALE_ITEM.INFO.END_TIME,
        PRESALE_ITEM.INFO.LOCK_PERIOD,
        PRESALE_ITEM.INFO.PRESALE_IN_MAIN_TOKEN
        );
    }

    function getPresaleAddressInfo() external view returns (
        address presaleOwner,
        address fundAddress,
        address saleToken,
        address baseToken,
        address wrapTokenAddress,
        address dexLockerAddress,
        address dexFactoryAddress
    ) {
        return (
        PRESALE_ITEM.INFO.PRESALE_OWNER,
        PRESALE_ITEM.INFO.FUND_ADDRESS,
        address(PRESALE_ITEM.INFO.SALE_TOKEN),
        address(PRESALE_ITEM.INFO.BASE_TOKEN),
        PRESALE_ITEM.INFO.WRAP_TOKEN_ADDRESS,
        PRESALE_ITEM.INFO.DEX_LOCKER_ADDRESS,
        PRESALE_ITEM.INFO.DEX_FACTORY_ADDRESS
        );
    }

    function getBuyerInfo(address _address) external view returns (uint256 baseDeposited, uint256 tokenBought, uint256 tokenClaimed, uint256 numberClaimed, uint256[] memory historyTimeClaimed, uint256[] memory historyAmountClaimed) {
        return (BUYERS[_address].baseDeposited, BUYERS[_address].tokenBought, BUYERS[_address].tokenClaimed, BUYERS[_address].numberClaimed, BUYERS[_address].historyTimeClaimed, BUYERS[_address].historyAmountClaimed);
    }

    function getVestingInfo() external view returns (bool activeVesting, uint256[] memory vestingPeriod, uint256[] memory vestingPercent) {
        return (PRESALE_ITEM.VESTING_INFO.ACTIVE_VESTING, PRESALE_ITEM.VESTING_INFO.VESTING_PERIOD, PRESALE_ITEM.VESTING_INFO.VESTING_PERCENT);
    }

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) public onlyAdmin returns (bool) {
        return IERC20(tokenAddress).transfer(userAddress, amount);
    }

    function retrieveBalance(uint256 amount, address userAddress) public onlyAdmin {
        payable(userAddress).transfer(amount);
    }
}
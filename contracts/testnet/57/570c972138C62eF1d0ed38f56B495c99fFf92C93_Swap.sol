/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
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
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
contract Swap is ReentrancyGuard {
    address private Burn = 0x000000000000000000000000000000000000dEaD;
    struct NativeTokenRate {
        uint256 rate;
    }
    IBEP20 public launchToken;
    address public owner;
    address public launchTokenOwner;
    uint256 public swapFee; //50=5% of currency amount
    uint256 public claimableDays;
    uint256 public releasedAmount;
    struct stageDetails {
        uint256 softCap;
        uint256 hardCap;
        uint256 minimumBuy;
        uint256 maximumBuy;
        uint256 liquidity;
        bool refund;
        uint256 startDate;
        uint256 endDate;
        uint256 cliffing;
        uint256 vesting;
        uint256 remaining;
        bool swapEnable;
    }
    stageDetails[] public arrayStageDetails;
    struct currencyDetails {
        address tokenAddress;
        uint256 exchangeRate;
        uint256 calculatedToken;
    }
    struct soldToken {
        uint256 sell;
    }
    struct leftToken {
        uint256 remain;
    }
    struct userData {
        uint256 amount;
        uint256 claimed;
        uint256 lastClaimed;
        uint256 claimedTime;
    }
    bool public isSwapEnableForAllStage = true;
    mapping(address => mapping(uint256 => userData)) public buyRecord;
    mapping(uint256 => stageDetails) public stageRecord;
    mapping(uint256 => stageDetails) public arrayStageRecord;
    mapping(uint256 => NativeTokenRate) public NativeTokenRatePerStage;
    mapping(address => mapping(uint256 => currencyDetails)) public exchangeRate;
    mapping(uint256 => soldToken) public sold;
    uint256 public totalUsdtRaised;
    uint256 public totalBnbRaised;
    uint256 public stageCount = 0;
    modifier onlyOwner() {
        require(owner == msg.sender, "Caller must be Ownable!!");
        _;
    }
    constructor(
        address _launchToken,
        address _launchTokenOwner,
        uint256 _swapFee
    ) {
        owner = msg.sender;
        launchToken = IBEP20(_launchToken);
        launchTokenOwner = _launchTokenOwner;
        swapFee = _swapFee;
    }
    function addStage(
        uint256 _numberOfStage,
        stageDetails memory _detailsOfStages,
        address[] memory currencyAddress,
        uint256[] memory currencyRates,
        uint256 tokenRateInNative,
        bool _isEdit
    ) public onlyOwner {
        uint256 i;
        if (_isEdit == false) {
            require(
                launchToken.balanceOf(msg.sender) >= _detailsOfStages.liquidity,
                "not enough balance for liquidity"
            );
            stageRecord[_numberOfStage] = _detailsOfStages;
            stageRecord[_numberOfStage].remaining = _detailsOfStages.liquidity;
            launchToken.transferFrom(
                msg.sender,
                address(this),
                _detailsOfStages.liquidity
            );
            stageCount++;
        } else if (_isEdit == true) {
            uint256 differenceAmount = 0;
            bool isTransferLiquidity = (stageRecord[_numberOfStage].remaining <
                _detailsOfStages.liquidity)
                ? true
                : false;
            if (isTransferLiquidity) {
                differenceAmount = (_detailsOfStages.liquidity -
                    stageRecord[_numberOfStage].remaining);
                require(
                    launchToken.balanceOf(msg.sender) > differenceAmount,
                    "not enought balance for liquidity"
                );
                launchToken.transferFrom(
                    msg.sender,
                    address(this),
                    differenceAmount
                );
            }
            stageRecord[_numberOfStage] = _detailsOfStages;
            stageRecord[_numberOfStage].remaining =
                differenceAmount +
                stageRecord[_numberOfStage].remaining;
        }
        for (i = 0; i < currencyAddress.length; i++) {
            exchangeRate[currencyAddress[i]][_numberOfStage]
                .tokenAddress = currencyAddress[i];
            exchangeRate[currencyAddress[i]][_numberOfStage]
                .exchangeRate = currencyRates[i];
            NativeTokenRatePerStage[_numberOfStage].rate = tokenRateInNative;
        }
    }
    function approvetoken(uint256 amount) public {
        launchToken.approve(address(this), amount);
        launchToken.transferFrom(msg.sender, address(this), amount);
    }
    function calcualteNativeToToken(uint256 _qty, uint256 stage)
        public
        view
        returns (uint256 calculatedToken)
    {
        uint256 tokenDecimal = launchToken.decimals();
        uint256 tokenAmount = ((_qty) *
            NativeTokenRatePerStage[stage].rate *
            (10**tokenDecimal)) / 1e20;
        return tokenAmount;
    }
    function getRemainingLiquidity(uint256 _stageNumber)
        public
        view
        returns (uint256)
    {
        return stageRecord[_stageNumber].remaining;
    }
    function calcualteCurrencyToToken(
        uint256 _qty,
        uint256 stage,
        address currencyAddress
    ) public view returns (uint256 calculatedToken) {
        uint256 tokenDecimal = launchToken.decimals();
        uint256 tokenAmount = ((_qty) *
            exchangeRate[currencyAddress][stage].exchangeRate *
            (10**tokenDecimal)) / 1e20;
        return tokenAmount;
    }
    function getCurrentStage() public view returns (uint256, bool) {
        uint256 i;
        uint256 currentStage = 0;
        bool stageActive = false;
        for (i = 0; i < stageCount; i++) {
            if (
                block.timestamp >= stageRecord[i].startDate &&
                block.timestamp <= stageRecord[i].endDate
            ) {
                currentStage = i;
                stageActive = true;
            }
        }
        return (currentStage, stageActive);
    }
    function swapNativeToToken() public payable nonReentrant {
        uint256 currentStage;
        bool stageActive;
        (currentStage, stageActive) = getCurrentStage();
        require(
            stageRecord[currentStage].swapEnable == true,
            "This stage is in inactive mode"
        );
        require(isSwapEnableForAllStage == true, " All Stage is disable");
        require(
            block.timestamp >= stageRecord[currentStage].startDate,
            "current stage not started"
        );
        require(
            block.timestamp <= stageRecord[currentStage].endDate,
            "current stage  has closed"
        );
        require(
            (stageRecord[currentStage].swapEnable == true),
            "swap is paused"
        );
        uint256 tokenDecimal = launchToken.decimals();
        uint256 currencySent = msg.value;
        uint256 launchPadAmount = (msg.value * swapFee) / 1000;
        payable(owner).transfer(launchPadAmount);
        payable(launchTokenOwner).transfer(address(this).balance);
        uint256 tokenAmount = ((currencySent) *
            (NativeTokenRatePerStage[currentStage].rate) *
            (10**tokenDecimal)) / 1e20;
        require(
            (stageRecord[currentStage].liquidity -
                stageRecord[currentStage].remaining) +
                tokenAmount <
                stageRecord[currentStage].liquidity,
            "This stage liquidity exceeds, try reduce the amount"
        );
        require(
            tokenAmount >= stageRecord[currentStage].minimumBuy,
            "You cannot buy less than minimum amount"
        );
        require(
            tokenAmount <= stageRecord[currentStage].maximumBuy,
            "You cannot buy more than maximum amount"
        );
        buyRecord[msg.sender][currentStage].amount += tokenAmount;
        sold[currentStage].sell += tokenAmount;
        buyRecord[msg.sender][currentStage].lastClaimed =
            stageRecord[currentStage].endDate +
            stageRecord[currentStage].cliffing;
    }
    function swapCurrencyToToken(
        address currencyAddress,
        uint256 currencyAmount
    ) public nonReentrant {
        uint256 currentStage;
        bool stageActive;
        (currentStage, stageActive) = getCurrentStage();
        require(
            stageRecord[currentStage].swapEnable == true,
            "This stage is in inactive mode"
        );
        require(isSwapEnableForAllStage == true, " All Stage is disable");
        require(
            block.timestamp >= stageRecord[currentStage].startDate,
            "current stage not started"
        );
        require(
            block.timestamp <= stageRecord[currentStage].endDate,
            "current stage  has closed"
        );
        require(
            (stageRecord[currentStage].swapEnable == true),
            "swap is paused"
        );
        uint256 tokenDecimal = launchToken.decimals();
        IBEP20 currencyToken = IBEP20(currencyAddress);
        currencyToken.transferFrom(
            msg.sender,
            launchTokenOwner,
            ((currencyAmount * (1000 - swapFee)) / 1000)
        ); ///verify
        currencyToken.transferFrom(
            msg.sender,
            owner,
            ((currencyAmount * swapFee) / 1000)
        ); //verify
        uint256 tokenAmount = ((currencyAmount) *
            exchangeRate[currencyAddress][currentStage].exchangeRate *
            (10**tokenDecimal)) / 1e20;
        require(
            (stageRecord[currentStage].liquidity -
                stageRecord[currentStage].remaining) +
                tokenAmount <
                stageRecord[currentStage].liquidity,
            "This stage liquidity exceeds, try reduce the amount"
        );
        require(
            tokenAmount >= stageRecord[currentStage].minimumBuy,
            "You cannot buy less than minimum amount"
        );
        require(
            tokenAmount <= stageRecord[currentStage].maximumBuy,
            "You cannot buy more than maximum amount"
        );
        buyRecord[msg.sender][currentStage].amount += tokenAmount;
        sold[currentStage].sell += tokenAmount;
        buyRecord[msg.sender][currentStage].lastClaimed =
            stageRecord[currentStage].endDate +
            stageRecord[currentStage].cliffing;
    }
    function claimToken(uint256 stage) public nonReentrant {
        require(
            buyRecord[msg.sender][stage].lastClaimed <= block.timestamp,
            "after presale finish then user claim"
        );
        require(
            buyRecord[msg.sender][stage].claimed <
                buyRecord[msg.sender][stage].amount,
            "All the balance has been claimed by the user"
        );
        uint256 claimAmount = buyRecord[msg.sender][stage].amount;
        launchToken.transfer(msg.sender, claimAmount);
        buyRecord[msg.sender][stage].claimed += claimAmount;
        buyRecord[msg.sender][stage].claimedTime = block.timestamp;
    }
    function viewClaims(address account, uint256 stage)
        public
        view
        returns (uint256 amt)
    {
        if (
            (buyRecord[account][stage].amount <=
                buyRecord[account][stage].claimed) ||
            (buyRecord[account][stage].amount == 0) ||
            ((buyRecord[account][stage].lastClaimed) >= block.timestamp)
        ) {
            return 0;
        }
        if (stageRecord[stage].endDate <= block.timestamp) {
            uint256 claimAmount = buyRecord[account][stage].amount;
            return claimAmount;
        }
    }
    function toggleSwapStage(uint256 stage, bool status) public onlyOwner {
        stageRecord[stage].swapEnable = status;
    }
    function toggleSwap(bool status) public onlyOwner {
        isSwapEnableForAllStage = status;
    }
    function _transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    function withdrawToken(uint256 stage)
        public
        onlyOwner
        returns (uint256 amt)
    {
        require(
            block.timestamp >= stageRecord[stage].endDate,
            "last stage has closed"
        );
        IBEP20 tokenContract = IBEP20(launchToken);
        uint256 amount = stageRecord[stage].liquidity - sold[stage].sell;
        if (stageRecord[stage].refund == true) {
            tokenContract.transfer(msg.sender, amount);
        }
        if (stageRecord[stage].refund == false) {
            tokenContract.transfer(Burn, amount);
        }
        return 0;
    }
}
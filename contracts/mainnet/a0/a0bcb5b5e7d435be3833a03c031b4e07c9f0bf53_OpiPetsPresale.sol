/**
    Presale contract for OpiPets Token with CA: 0x4C906B99A2f45A47C8570b7A41ffe940F71676AF
    Author: Arrnaya (TG: @arrnaya)
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Ownable.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./Context.sol";
import "./ReentrancyGuard.sol";
import "./BNBPriceFeeds.sol";

contract OpiPetsPresale is Ownable, ReentrancyGuard, PriceConsumerV3 {
    using Address for address payable;

    event Swap(
        address indexed user,
        uint256 inAmount,
        uint256 owedToInvestorAmount
    );
    event Claimed(address indexed user, uint256 amount);
    event PayeeTransferred(
        address indexed previousPayee,
        address indexed newPayee
    );
    event BNBCollected(address user, uint256 amount);
    event IERC20TokenWithdrawn(address user, uint256 amount);
    event BUSDWithdrawn(address user, uint256 amount);

    IERC20 public opiPetsToken;
    IERC20 public BUSD;
    uint256 public BNBPriceInUSD;
    address public fundCollectorWallet;

    bool public isSwapStarted;
    bool public isVested;
    bool public canClaim;

    uint256 public swapRate = 833333; // 8.33333 OpiPets Tokens per BUSD
    uint256 public totalTokensSold;
    uint256 public maxTokensToSell = 50_000_000 * 1e18; // Max 50M Opi Pets tokens to be sold

    uint256 public totalFundsRaised;
    uint256 public minBuyPerWallet = 10 * 1e18; // $10
    uint256 public maxBuyPerWallet = 9999 * 1e18; // $9999

    uint256 public daysPerVest;
    uint256 public percentPerVest;
    uint256 public initialClaimPercentage;
    uint256 public vestingStartDate;

    mapping(address => uint256) public spentByInvestor;
    mapping(address => uint256) public owedToInvestor;
    mapping(address => uint256) public claimedByInvestor;

    constructor(
        address _paymentCollectionWallet,
        IERC20 _opiPetsToken,
        IERC20 _BUSD,
        bool _vestingStatus
    ) {
        require(
            address(_opiPetsToken) != address(0) &&
                _paymentCollectionWallet != address(0) &&
                address(_BUSD) != address(0),
            "OpiPetsPresale: Can't set token to zero address"
        );

        // setVestingParameters (_daysPerVest, _percentPerVest, _initialClaimPercentage);
        opiPetsToken = _opiPetsToken;
        BUSD = _BUSD;
        fundCollectorWallet = _paymentCollectionWallet;
        isVested = _vestingStatus;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    function _swap() external payable nonReentrant {
        getBNBPrice();

        uint256 investmentAmnt = (msg.value * BNBPriceInUSD) / 1e8;

        require(isSwapStarted == true, "OpiPetsPresale: Swap not started");
        require(
            totalTokensSold + ((investmentAmnt * swapRate)/ 1e5) <= maxTokensToSell,
            "OpiPetsPresale: Exceeding total fund raise limit"
        );
        require(
            spentByInvestor[msg.sender] + investmentAmnt <= maxBuyPerWallet &&
                spentByInvestor[msg.sender] + investmentAmnt >= minBuyPerWallet,
            "OpiPetsPresale: Try an amount above min but below max allowed per wallet!"
        );

        uint256 quota = opiPetsToken.balanceOf(address(this));
        uint256 outAmount = (investmentAmnt * swapRate)/ 1e5;
        require(
            totalTokensSold + outAmount <= quota,
            "OpiPetsPresale: Not enough tokens remaining"
        );

        totalTokensSold += outAmount;
        totalFundsRaised += investmentAmnt;
        payable(address(this)).sendValue(msg.value);
        spentByInvestor[msg.sender] += investmentAmnt;
        owedToInvestor[msg.sender] += outAmount;

        emit Swap(msg.sender, investmentAmnt, outAmount);
    }

    function _swapWithBUSD(uint256 weiAmount) external nonReentrant {
        require(isSwapStarted == true, "OpiPetsPresale: Swap not started");
        require(
            totalTokensSold + ((weiAmount * swapRate)/1e5) <= maxTokensToSell,
            "OpiPetsPresale: Exceeding total fund raise limit"
        );
        require(
            spentByInvestor[msg.sender] + weiAmount <= maxBuyPerWallet &&
                spentByInvestor[msg.sender] + weiAmount >= minBuyPerWallet,
            "OpiPetsPresale: Try an amount above min but below max allowed per wallet!"
        );

        uint256 quota = opiPetsToken.balanceOf(address(this));
        uint256 outAmount = (weiAmount * swapRate)/1e5;
        require(
            totalTokensSold + outAmount <= quota,
            "OpiPetsPresale: Not enough tokens remaining"
        );

        totalTokensSold += outAmount;
        totalFundsRaised += weiAmount;
        IERC20(BUSD).transferFrom(msg.sender, address(this), weiAmount);
        spentByInvestor[msg.sender] += weiAmount;
        owedToInvestor[msg.sender] += outAmount;

        emit Swap(msg.sender, weiAmount, outAmount);
    }

    function getBNBPrice() internal returns (int256) {
        (
            ,
            /* uint80 roundID */
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        BNBPriceInUSD = uint256(price);

        return price;
    }

    function claim() external nonReentrant {
        require(canClaim == true, "OpiPetsPresale: Can't claim yet");

        uint256 quota = opiPetsToken.balanceOf(address(this));

        if (isVested) {
            uint256 numberOfVests = (block.timestamp - vestingStartDate) /
                daysPerVest; // rounds down
            uint256 owedToInvestorNow = (owedToInvestor[msg.sender] *
                initialClaimPercentage) /
                100 +
                (owedToInvestor[msg.sender] * numberOfVests * percentPerVest) /
                100;

            if (owedToInvestorNow > owedToInvestor[msg.sender])
                owedToInvestorNow = owedToInvestor[msg.sender];

            require(
                owedToInvestorNow - claimedByInvestor[msg.sender] <= quota,
                "OpiPetsPresale: Not enough tokens remaining"
            );
            require(
                owedToInvestorNow - claimedByInvestor[msg.sender] > 0,
                "OpiPetsPresale: No tokens left to claim"
            );

            uint256 amount = owedToInvestorNow - claimedByInvestor[msg.sender];
            claimedByInvestor[msg.sender] += owedToInvestorNow;
            opiPetsToken.transfer(msg.sender, amount);

            emit Claimed(msg.sender, amount);
        } else {
            uint256 owedToInvestorNow = owedToInvestor[msg.sender];
            require(
                owedToInvestorNow - claimedByInvestor[msg.sender] <= quota,
                "OpiPetsPresale: Not enough tokens remaining"
            );
            require(
                owedToInvestorNow - claimedByInvestor[msg.sender] > 0,
                "OpiPetsPresale: No tokens left to claim"
            );

            uint256 amount = owedToInvestorNow;
            claimedByInvestor[msg.sender] += owedToInvestorNow;
            opiPetsToken.transfer(msg.sender, amount);

            emit Claimed(msg.sender, amount);
        }
    }

    function setVestingParameters(
        uint256 _daysPerVest,
        uint256 _percentPerVest,
        uint256 _initialClaimPercentage
    ) external onlyOwner {
        require(isVested, "This is not a vested presale!");
        require(
            _initialClaimPercentage <= 100,
            "OpiPetsPresale: Initial claim % must be <= 100"
        );
        require(
            _percentPerVest <= 100,
            "OpiPetsPresale: % per vest must be <= 100"
        );

        daysPerVest = _daysPerVest * 1 days;
        percentPerVest = _percentPerVest;
        initialClaimPercentage = _initialClaimPercentage;
    }

    function setVestingStartDate(uint256 _vestingStartDate) external onlyOwner {
        require(isVested, "This is not a vested presale!");
        require(
            _vestingStartDate > block.timestamp,
            "OpiPetsPresale: Vesting must start in the future"
        );

        vestingStartDate = _vestingStartDate;
    }

    function toggleSwap(bool enableSwap) external onlyOwner {
        isSwapStarted = enableSwap;
    }

    function setClaim(bool _canClaim) external onlyOwner {
        canClaim = _canClaim;

        if (_canClaim && isVested && vestingStartDate == 0)
            vestingStartDate = block.timestamp;
    }

    function _changeFundCollectorWalletAddress(address newPayee)
        external
        onlyOwner
    {
        require(
            newPayee != address(0),
            "OpiPetsPresale: Can't set payee to zero address"
        );
        fundCollectorWallet = newPayee;

        emit PayeeTransferred(fundCollectorWallet, newPayee);
    }

    function collectBNBs() external onlyOwner {

        uint256 fundsToSend = address(this).balance;
        bool sent = payable(fundCollectorWallet).send(fundsToSend);
        require(sent, "Failed to send Ether");

        emit BNBCollected(fundCollectorWallet, fundsToSend);
    }

    function withdrawOtherTokens(address _token) external onlyOwner {
        require(_token != address(0), "can't withdraw zero token");
        uint256 fundsToSend;
        if (IERC20(_token) == opiPetsToken) {
            fundsToSend =
                opiPetsToken.balanceOf(address(this)) -
                totalTokensSold;
        } else {
            fundsToSend = IERC20(_token).balanceOf(address(this));
        }
        IERC20(_token).transfer(msg.sender, fundsToSend);

        emit IERC20TokenWithdrawn(msg.sender, fundsToSend);
    }

    function collectBUSD() external onlyOwner {
        uint256 fundsToSend = BUSD.balanceOf(address(this));
        IERC20(BUSD).transfer(fundCollectorWallet, fundsToSend);

        emit BUSDWithdrawn(fundCollectorWallet, fundsToSend);
    }
}
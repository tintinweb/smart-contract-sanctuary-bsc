/**
 *Submitted for verification at Etherscan.io on 2022-04-18
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';
import '../interfaces/IPancakePair.sol';
import '../interfaces/IPancakeFactory.sol';
import '../interfaces/IPancakeRouter.sol';
import '../interfaces/IBNBP.sol';
import '../interfaces/IPRC20.sol';
import '../interfaces/IVRFConsumer.sol';
import '../interfaces/IPegSwap.sol';
import '../interfaces/IPotContract.sol';

contract RoulettePot is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public casinoCount;
    uint256 public betIds;
    mapping(uint256 => Casino) public tokenIdToCasino;
    mapping(address => bool) public isStable;
    mapping(address => mapping(uint256 => BetInfo)) public userLastBetInfo;

    address public casinoNFTAddress;
    address public BNBPAddress;
    address public consumerAddress;
    address public potAddress;

    address internal constant wbnbAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd, mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address internal constant busdAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // testnet: 0x4608Ea31fA832ce7DCF56d78b5434b49830E91B1, mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    address internal constant pancakeFactoryAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // testnet: 0x6725F303b657a9451d8BA641348b6761A6CC7a17, mainnet: 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    address internal constant pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    address internal constant coordinatorAddr = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE; // testnet: 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f, mainnet: 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE
    address internal constant linkTokenAddr = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD; // testnet: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06, mainnet: 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD
    address internal constant pegSwapAddr = 0x1FCc3B22955e76Ca48bF025f1A6993685975Bb9e;
    address internal constant link677TokenAddr = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    uint256 internal constant subscriptionId = 675; // testnet: 2102, mainnet: 675
    uint256 public linkPerBet = 45000000000000000; // 0.045 link token per request
    mapping(uint256 => uint256) public linkSpent;

    struct Casino {
        address tokenAddress;
        string tokenName;
        uint256 liquidity;
        uint256 locked;
        uint256 initialMaxBet;
        uint256 maxBet;
        uint256 minBet;
        uint256 fee;
        int256 profit;
        uint256 lastSwapTime;
    }

    struct BetInfo {
        bool isPending;
        uint256 requestId;
        Bet[] bets;
        uint256 tokenPrice;
    }

    struct Bet {
        /* 5: number, 4: even, odd, 3: 18s, 2: 12s, 1: row, 0: black, red */
        uint8 betType;
        uint8 number;
        uint240 amount;
    }

    event FinishedBet(
        uint256 tokenId,
        uint256 betId,
        address player,
        uint256 nonce,
        uint256 totalAmount,
        uint256 rewardAmount,
        uint256 totalUSD,
        uint256 rewardUSD,
        uint256 maximumReward
    );
    event TransferFailed(uint256 tokenId, address to, uint256 amount);
    event TokenSwapFailed(uint256 tokenId, uint256 balance, string reason, uint256 timestamp);
    event InitializedBet(uint256 tokenId, address player, uint256 amount);
    event AddedLiquidity(uint256 tokenId, address owner, uint256 amount);
    event RemovedLiquidity(uint256 tokenId, address owner, uint256 amount);
    event UpdatedMaxBet(uint256 tokenId, address owner, uint256 value);
    event UpdatedMinBet(uint256 tokenId, address owner, uint256 value);
    event LiquidityChanged(uint256 tokenId, address changer, uint256 value, bool isFinishedBet);
    event SuppliedBNBP(uint256 amount);
    event SuppliedLink(uint256 amount);

    constructor(
        address nftAddr,
        address _BNBPAddress,
        address _consumerAddress,
        address _potAddress
    ) {
        address BNBPPair = IPancakeFactory(pancakeFactoryAddr).getPair(wbnbAddr, _BNBPAddress);
        require(BNBPPair != address(0), 'No liquidity with BNBP and BNB');

        casinoNFTAddress = nftAddr;
        BNBPAddress = _BNBPAddress;
        consumerAddress = _consumerAddress;
        potAddress = _potAddress;
    }

    modifier onlyCasinoOwner(uint256 tokenId) {
        require(IERC721(casinoNFTAddress).ownerOf(tokenId) == msg.sender, 'Not Casino Owner');
        _;
    }

    /**
     * @dev updates pot contract Address
     */
    function setPotAddress(address addr) external onlyOwner {
        potAddress = addr;
    }

    /**
     * @dev sets token is stable or not
     */
    function setTokenStable(address tokenAddr, bool _isStable) external onlyOwner {
        isStable[tokenAddr] = _isStable;
    }

    /**
     * @dev set how much link token will be consumed per bet
     */
    function setLinkPerBet(uint256 value) external onlyOwner {
        linkPerBet = value;
    }

    /**
     * @dev returns list of casinos minted
     */
    function getCasinoList()
        external
        view
        returns (
            Casino[] memory casinos,
            address[] memory owners,
            uint256[] memory prices
        )
    {
        uint256 length = casinoCount;
        casinos = new Casino[](length);
        owners = new address[](length);
        prices = new uint256[](length);
        IERC721 nftContract = IERC721(casinoNFTAddress);

        for (uint256 i = 1; i <= length; i++) {
            casinos[i - 1] = tokenIdToCasino[i];
            owners[i - 1] = nftContract.ownerOf(i);
            if (casinos[i - 1].tokenAddress == address(0)) {
                prices[i - 1] = getBNBPrice();
            } else {
                prices[i - 1] = _getTokenUsdPrice(casinos[i - 1].tokenAddress);
            }
        }
    }

    /**
     * @dev adds a new casino
     */
    function addCasino(
        uint256 tokenId,
        address tokenAddress,
        string calldata tokenName,
        uint256 maxBet,
        uint256 minBet,
        uint256 fee
    ) external {
        require(msg.sender == casinoNFTAddress, 'Only casino nft contract can call');

        Casino storage newCasino = tokenIdToCasino[tokenId];
        newCasino.tokenAddress = tokenAddress;
        newCasino.tokenName = tokenName;
        newCasino.initialMaxBet = maxBet;
        newCasino.maxBet = maxBet;
        newCasino.minBet = minBet;
        newCasino.fee = fee;
        newCasino.liquidity = 0;

        casinoCount++;
    }

    /**
     * @dev set max bet limit for casino
     */
    function setMaxBet(uint256 tokenId, uint256 newMaxBet) external onlyCasinoOwner(tokenId) {
        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        require(newMaxBet <= casinoInfo.initialMaxBet, "Can't exceed initial max bet");

        casinoInfo.maxBet = newMaxBet;
        emit UpdatedMaxBet(tokenId, msg.sender, newMaxBet);
    }

    /**
     * @dev set min bet limit for casino
     */
    function setMinBet(uint256 tokenId, uint256 newMinBet) external onlyCasinoOwner(tokenId) {
        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        require(newMinBet <= casinoInfo.maxBet, 'min >= max');
        require(newMinBet > 0, 'min = 0');

        casinoInfo.minBet = newMinBet;
        emit UpdatedMaxBet(tokenId, msg.sender, newMinBet);
    }

    /**
     * @dev returns maximum reward amount for given bets
     */
    function getMaximumReward(Bet[] memory bets) public pure returns (uint256) {
        uint256 maxReward;
        uint8[6] memory betRewards = [2, 3, 3, 2, 2, 36];

        for (uint256 i = 0; i <= 37; i++) {
            uint256 reward;

            for (uint256 j = 0; j < bets.length; j++) {
                if (_isInBet(bets[j], i)) {
                    reward += bets[j].amount * betRewards[bets[j].betType];
                }
            }
            if (maxReward < reward) {
                maxReward = reward;
            }
        }
        return maxReward;
    }

    /**
     * @dev returns whbnb Bet `b` covers the `number` or not
     */
    function _isInBet(Bet memory b, uint256 number) public pure returns (bool) {
        require(b.betType <= 5, 'Invalid bet type');
        require(b.number <= 37, 'Invalid betting number');

        if (number == 0 || number == 37) {
            if (b.betType == 5) {
                return b.number == number;
            } else {
                return false;
            }
        }

        if (b.betType == 5) {
            return (b.number == number); /* bet on number */
        } else if (b.betType == 4) {
            if (b.number == 0) return (number % 2 == 0); /* bet on even */
            if (b.number == 1) return (number % 2 == 1); /* bet on odd */
        } else if (b.betType == 3) {
            if (b.number == 0) return (number <= 18); /* bet on low 18s */
            if (b.number == 1) return (number >= 19); /* bet on high 18s */
        } else if (b.betType == 2) {
            if (b.number == 0) return (number <= 12); /* bet on 1st dozen */
            if (b.number == 1) return (number > 12 && number <= 24); /* bet on 2nd dozen */
            if (b.number == 2) return (number > 24); /* bet on 3rd dozen */
        } else if (b.betType == 1) {
            if (b.number == 0) return (number % 3 == 0); /* bet on top row */
            if (b.number == 1) return (number % 3 == 1); /* bet on middle row */
            if (b.number == 2) return (number % 3 == 2); /* bet on bottom row */
        } else if (b.betType == 0) {
            if (b.number == 0) {
                /* bet on black */
                if (number <= 10 || (number >= 19 && number <= 28)) {
                    return (number % 2 == 0);
                } else {
                    return (number % 2 == 1);
                }
            } else {
                /* bet on red */
                if (number <= 10 || (number >= 19 && number <= 28)) {
                    return (number % 2 == 1);
                } else {
                    return (number % 2 == 0);
                }
            }
        }
        return false;
    }

    /**
     * @dev returns total bet amount
     */
    function _getTotalBetAmount(Bet[] memory bets) internal pure returns (uint256) {
        /* 5: number, 4: even, odd, 3: 18s, 2: 12s, 1: row, 0: black, red */
        uint256[5] memory betCount;
        uint256 totalBetAmount;
        for (uint256 i = 0; i < bets.length; i++) {
            require(bets[i].betType <= 5, 'Invalid bet type');

            totalBetAmount += bets[i].amount;
            if (bets[i].betType < 5) {
                betCount[bets[i].betType]++;
            }
        }
        require(
            betCount[0] < 2 && betCount[1] < 3 && betCount[2] < 3 && betCount[3] < 2 && betCount[4] < 2,
            'Bet Restriction'
        );

        return totalBetAmount;
    }

    /**
     * @dev calculate total rewards with a given nonce
     */
    function _spinWheel(Bet[] memory bets, uint256 nonce) internal pure returns (uint256, uint256) {
        uint256 totalReward;
        uint8[6] memory betRewards = [2, 3, 3, 2, 2, 36];

        for (uint256 i = 0; i < bets.length; i++) {
            if (_isInBet(bets[i], nonce)) {
                totalReward += betRewards[bets[i].betType] * bets[i].amount;
            }
        }
        return (nonce, totalReward);
    }

    /**
     * @dev initialize user bet info to pending status
     */
    function _initializeBetInfo(
        uint256 tokenId,
        uint256 requestId,
        Bet[] calldata bets,
        uint256 tokenPrice
    ) internal {
        BetInfo storage info = userLastBetInfo[msg.sender][tokenId];

        delete info.bets;
        info.requestId = requestId;
        info.isPending = true;
        info.tokenPrice = tokenPrice;
        for (uint256 i = 0; i < bets.length; i++) {
            Bet memory bet = bets[i];
            info.bets.push(bet);
        }
    }

    /**
     * @dev initialize bet and request nonce to VRF
     *
     * NOTE this function only accepts erc20 tokens
     *      Bet type should be less than 6, otherwise will revert
     * @param tokenId tokenId of the Casino
     * @param bets array of bets
     */
    function initializeTokenBet(uint256 tokenId, Bet[] calldata bets) external nonReentrant returns (uint256) {
        require(userLastBetInfo[msg.sender][tokenId].isPending == false, 'Bet not finished');

        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        require(casinoInfo.tokenAddress != address(0), "This casino doesn't support tokens");

        IPRC20 token = IPRC20(casinoInfo.tokenAddress);
        uint256 approvedAmount = token.allowance(msg.sender, address(this));
        uint256 totalBetAmount = _getTotalBetAmount(bets);
        uint256 maxReward = getMaximumReward(bets);
        uint256 tokenPrice = isStable[casinoInfo.tokenAddress] ? 10**18 : _getTokenUsdPrice(casinoInfo.tokenAddress);
        uint256 totalUSDValue = (totalBetAmount * tokenPrice) / 10**token.decimals();

        require(token.balanceOf(msg.sender) >= totalBetAmount, 'Not enough balance');
        require(totalBetAmount <= approvedAmount, 'Not enough allowance');
        require(maxReward <= casinoInfo.liquidity + totalBetAmount, 'Not enough liquidity');
        require(totalUSDValue <= casinoInfo.maxBet * 10**18, "Can't exceed max bet limit");
        require(totalUSDValue >= casinoInfo.minBet * 10**18, "Can't be lower than min bet limit");

        token.transferFrom(msg.sender, address(this), totalBetAmount);
        casinoInfo.liquidity -= (maxReward - totalBetAmount);
        casinoInfo.locked += maxReward;

        IVRFv2Consumer vrfConsumer = IVRFv2Consumer(consumerAddress);
        uint256 requestId = vrfConsumer.requestRandomWords();
        _initializeBetInfo(tokenId, requestId, bets, tokenPrice);

        linkSpent[tokenId] += linkPerBet;

        emit InitializedBet(tokenId, msg.sender, totalBetAmount);
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, false);
        return requestId;
    }

    /**
     * @dev initialize bet and request nonce to VRF
     *
     * NOTE this function only accepts bnb
     *      Bet type should be less than 6, otherwise will revert
     * @param tokenId tokenId of the Casino
     * @param bets array of bets
     */
    function initializeEthBet(uint256 tokenId, Bet[] calldata bets) external payable returns (uint256) {
        BetInfo storage info = userLastBetInfo[msg.sender][tokenId];
        require(info.isPending == false, 'Bet not finished');

        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        require(casinoInfo.tokenAddress == address(0), 'This casino only support bnb');

        IPRC20 busdToken = IPRC20(busdAddr);
        uint256 totalBetAmount = _getTotalBetAmount(bets);
        uint256 maxReward = getMaximumReward(bets);
        uint256 bnbPrice = getBNBPrice();
        uint256 totalUSDValue = (bnbPrice * totalBetAmount) / 10**18;

        require(msg.value == totalBetAmount, 'Not correct bet amount');
        require(maxReward <= casinoInfo.liquidity + totalBetAmount, 'Not enough liquidity');
        require(totalUSDValue <= casinoInfo.maxBet * 10**busdToken.decimals(), "Can't exceed max bet limit");
        require(totalUSDValue >= casinoInfo.minBet * 10**busdToken.decimals(), "Can't be lower than min bet limit");

        casinoInfo.liquidity -= (maxReward - totalBetAmount);
        casinoInfo.locked += maxReward;

        IVRFv2Consumer vrfConsumer = IVRFv2Consumer(consumerAddress);
        uint256 requestId = vrfConsumer.requestRandomWords();
        _initializeBetInfo(tokenId, requestId, bets, bnbPrice);

        linkSpent[tokenId] += linkPerBet;

        emit InitializedBet(tokenId, msg.sender, totalBetAmount);
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, false);
        return requestId;
    }

    /**
     * @dev retrieve nonce and spin the wheel, return reward if user wins
     *
     * @param tokenId tokenId of the Casino
     */
    function finishBet(uint256 tokenId) external nonReentrant {
        BetInfo storage betInfo = userLastBetInfo[msg.sender][tokenId];
        require(betInfo.isPending == true, 'Bet not pending');

        (bool fulfilled, uint256[] memory nonces) = IVRFv2Consumer(consumerAddress).getRequestStatus(betInfo.requestId);
        require(fulfilled == true, 'not yet fulfilled');

        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        uint256 decimal = casinoInfo.tokenAddress == address(0) ? 18 : IPRC20(casinoInfo.tokenAddress).decimals();
        (uint256 nonce, uint256 totalReward) = _spinWheel(betInfo.bets, nonces[0] % 38);
        uint256 totalBetAmount = _getTotalBetAmount(betInfo.bets);
        uint256 maxReward = getMaximumReward(betInfo.bets);
        uint256 totalUSDValue = (totalBetAmount * betInfo.tokenPrice) / 10**decimal;
        uint256 totalRewardUSD = (totalReward * betInfo.tokenPrice) / 10**decimal;

        betIds++;
        betInfo.isPending = false;

        if (totalReward > 0) {
            if (casinoInfo.tokenAddress != address(0)) {
                IPRC20(casinoInfo.tokenAddress).transfer(msg.sender, totalReward);
            } else {
                bool sent = payable(msg.sender).send(totalReward);
                require(sent, 'send fail');
            }
        }
        casinoInfo.liquidity = casinoInfo.liquidity + maxReward - totalReward;
        casinoInfo.locked -= maxReward;
        casinoInfo.profit = casinoInfo.profit + int256(totalBetAmount) - int256(totalReward);

        emit FinishedBet(
            tokenId,
            betIds,
            msg.sender,
            nonce,
            totalBetAmount,
            totalReward,
            totalUSDValue,
            totalRewardUSD,
            maxReward
        );
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, true);
    }

    /**
     * @dev returns VRF nonce status for bet
     */
    function getBetResult(uint256 tokenId, address user) public view returns (bool, uint256) {
        BetInfo storage info = userLastBetInfo[user][tokenId];
        IVRFv2Consumer consumer = IVRFv2Consumer(consumerAddress);
        (bool fulfilled, uint256[] memory nonces) = consumer.getRequestStatus(info.requestId);
        return (fulfilled, nonces[0]);
    }

    /**
     * @dev adds liquidity to the casino pool
     * NOTE this is only for casinos that uses tokens
     */
    function addLiquidityWithTokens(uint256 tokenId, uint256 amount) external onlyCasinoOwner(tokenId) {
        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        require(casinoInfo.tokenAddress != address(0), "This casino doesn't support tokens");

        IERC20 token = IERC20(casinoInfo.tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);
        casinoInfo.liquidity += amount;
        emit AddedLiquidity(tokenId, msg.sender, amount);
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, false);
    }

    /**
     * @dev adds liquidity to the casino pool
     * NOTE this is only for casinos that uses bnb
     */
    function addLiquidityWithEth(uint256 tokenId) external payable onlyCasinoOwner(tokenId) {
        Casino storage casinoInfo = tokenIdToCasino[tokenId];

        require(casinoInfo.tokenAddress == address(0), "This casino doesn't supports bnb");
        casinoInfo.liquidity += msg.value;
        emit AddedLiquidity(tokenId, msg.sender, msg.value);
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, false);
    }

    /**
     * @dev removes liquidity from the casino pool
     */
    function removeLiquidity(uint256 tokenId, uint256 amount) external onlyCasinoOwner(tokenId) {
        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        uint256 liquidity = casinoInfo.liquidity;

        require(int256(liquidity - amount) >= casinoInfo.profit, 'Cannot withdraw profit before it is fee taken');
        require(liquidity >= amount, 'Not enough liquidity');

        unchecked {
            casinoInfo.liquidity -= amount;
        }
        if (casinoInfo.tokenAddress != address(0)) {
            IERC20 token = IERC20(casinoInfo.tokenAddress);
            token.safeTransfer(msg.sender, amount);
        } else {
            bool sent = payable(msg.sender).send(amount);
            require(sent, 'Failed Transfer');
        }
        emit RemovedLiquidity(tokenId, msg.sender, amount);
        emit LiquidityChanged(tokenId, msg.sender, casinoInfo.liquidity, false);
    }

    /**
     * @dev update casino's current profit and liquidity.
     */
    function _updateProfitInfo(
        uint256 tokenId,
        uint256 fee,
        uint256 calculatedProfit
    ) internal {
        if (fee == 0) return;
        Casino storage casinoInfo = tokenIdToCasino[tokenId];
        casinoInfo.liquidity -= fee;
        casinoInfo.profit -= int256(calculatedProfit);
        casinoInfo.lastSwapTime = block.timestamp;
    }

    /**
     * @dev get usd price of a token by usdt
     */
    function _getTokenUsdPrice(address tokenAddress) internal view returns (uint256) {
        if (isStable[tokenAddress]) return 10**18;

        IPancakeRouter02 router = IPancakeRouter02(pancakeRouterAddr);
        IPRC20 token = IPRC20(tokenAddress);

        address[] memory path = new address[](3);
        path[0] = tokenAddress;
        path[1] = wbnbAddr;
        path[2] = busdAddr;
        uint256 usdValue = router.getAmountsOut(10**token.decimals(), path)[2];

        return usdValue;
    }

    /**
     * @dev Gets current pulse price in comparison with BNB and USDT
     */
    function getBNBPrice() public view returns (uint256 price) {
        IPancakeRouter02 router = IPancakeRouter02(pancakeRouterAddr);
        address[] memory path = new address[](2);
        path[0] = wbnbAddr;
        path[1] = busdAddr;
        uint256[] memory amounts = router.getAmountsOut(10**18, path);
        return amounts[1];
    }

    /**
     * @dev calculates value after applying slippage percent
     */
    function _calcSlippage(uint256 amount, uint256 slippage) internal pure returns (uint256 value) {
        return (amount * (100 - slippage)) / 100;
    }

    function _getTokenAmountForLink(address tokenAddr, uint256 linkAmount) internal view returns (uint256) {
        IPancakeRouter02 router = IPancakeRouter02(pancakeRouterAddr);
        address[] memory path;
        if (tokenAddr == address(0) || tokenAddr == wbnbAddr) {
            path = new address[](2);
            path[0] = wbnbAddr;
            path[1] = linkTokenAddr;
        } else {
            path = new address[](3);
            path[0] = tokenAddr;
            path[1] = wbnbAddr;
            path[2] = linkTokenAddr;
        }

        return router.getAmountsIn(linkAmount, path)[0];
    }

    function _getLinkAmountForToken(address tokenAddr, uint256 tokenAmount) internal view returns (uint256) {
        IPancakeRouter02 router = IPancakeRouter02(pancakeRouterAddr);
        address[] memory path;
        bool isBNB = tokenAddr == address(0) || tokenAddr == wbnbAddr;
        if (isBNB) {
            path = new address[](2);
            path[0] = wbnbAddr;
            path[1] = linkTokenAddr;
        } else {
            path = new address[](3);
            path[0] = tokenAddr;
            path[1] = wbnbAddr;
            path[2] = linkTokenAddr;
        }

        return router.getAmountsOut(tokenAmount, path)[isBNB ? 1 : 2];
    }

    /**
     * @dev swaps profit fees of casinos into BNBP
     */
    function swapProfitFees() external {
        IPancakeRouter02 router = IPancakeRouter02(pancakeRouterAddr);
        address[] memory path = new address[](2);
        uint256 totalBNBForGame;
        uint256 totalBNBForLink;
        uint256 length = casinoCount;
        uint256 BNBPPool = 0;

        // Swap each token to BNB
        for (uint256 i = 1; i <= length; i++) {
            Casino memory casinoInfo = tokenIdToCasino[i];
            IERC20 token = IERC20(casinoInfo.tokenAddress);

            if (casinoInfo.liquidity == 0) continue;

            uint256 availableProfit = casinoInfo.profit < 0 ? 0 : uint256(casinoInfo.profit);
            if (casinoInfo.liquidity < availableProfit) {
                availableProfit = casinoInfo.liquidity;
            }

            uint256 gameFee = (availableProfit * casinoInfo.fee) / 100;
            uint256 amountForLinkFee = _getTokenAmountForLink(casinoInfo.tokenAddress, linkSpent[i]);
            _updateProfitInfo(i, uint256(gameFee), availableProfit);

            // If fee from the profit is not enought for link, then use liquidity
            if (gameFee < amountForLinkFee) {
                if (casinoInfo.liquidity < (amountForLinkFee - gameFee)) {
                    amountForLinkFee = gameFee + casinoInfo.liquidity;
                    tokenIdToCasino[i].liquidity = 0;
                } else {
                    tokenIdToCasino[i].liquidity -= (amountForLinkFee - gameFee);
                }
                gameFee = 0;
            } else {
                gameFee -= amountForLinkFee;
            }

            // Update Link consumption info
            linkSpent[i] -= _getLinkAmountForToken(casinoInfo.tokenAddress, amountForLinkFee);

            if (casinoInfo.tokenAddress == address(0)) {
                totalBNBForGame += gameFee;
                totalBNBForLink += amountForLinkFee;
                continue;
            }
            if (casinoInfo.tokenAddress == BNBPAddress) {
                BNBPPool += gameFee;
                gameFee = 0;
            }

            path[0] = casinoInfo.tokenAddress;
            path[1] = wbnbAddr;

            token.approve(address(router), gameFee + amountForLinkFee);
            uint256[] memory swappedAmounts = router.swapExactTokensForETH(
                gameFee + amountForLinkFee,
                0,
                path,
                address(this),
                block.timestamp
            );
            totalBNBForGame += (swappedAmounts[1] * (gameFee + amountForLinkFee)) / gameFee;
            totalBNBForLink += (swappedAmounts[1] * (gameFee + amountForLinkFee)) / amountForLinkFee;
        }

        path[0] = wbnbAddr;
        // Convert to LINK
        if (totalBNBForLink > 0) {
            path[1] = linkTokenAddr;

            // Swap BNB into Link Token
            uint256 linkAmount = router.swapExactETHForTokens{ value: totalBNBForLink }(
                0,
                path,
                address(this),
                block.timestamp
            )[1];

            // Convert Link to ERC677 Link
            IERC20(linkTokenAddr).approve(pegSwapAddr, linkAmount);
            PegSwap(pegSwapAddr).swap(linkAmount, linkTokenAddr, link677TokenAddr);

            // Fund VRF subscription account
            LinkTokenInterface(link677TokenAddr).transferAndCall(
                coordinatorAddr,
                linkAmount,
                abi.encode(subscriptionId)
            );
            emit SuppliedLink(linkAmount);
        }

        // Swap the rest of BNB to BNBP
        if (totalBNBForGame > 0) {
            path[1] = BNBPAddress;
            uint256 swappedBNBP = router.swapExactETHForTokens{ value: totalBNBForGame }(
                0,
                path,
                address(this),
                block.timestamp
            )[1];
            BNBPPool += swappedBNBP;
        }

        if (BNBPPool > 0) {
            // add BNBP to tokenomics pool
            IERC20(BNBPAddress).approve(potAddress, BNBPPool);
            IPotLottery(potAddress).addAdminTokenValue(BNBPPool);

            emit SuppliedBNBP(BNBPPool);
        }
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

interface IBNBP {
    error AirdropTimeError();

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function isUserAddress(address addr) external view returns (bool);

    function calculatePairAddress() external view returns (address);

    function performAirdrop() external returns (uint256);

    function performBurn() external returns (uint256);

    function performLottery() external returns (address);

    function setPotContractAddress(address addr) external;

    function setAirdropPercentage(uint8 percentage) external;

    function setAirdropInterval(uint256 interval) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IVRFv2Consumer {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    function requestRandomWords() external returns (uint256 requestId);

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface PegSwap {
    /**
     * @notice deposits tokens from the target of a swap pair but does not return
     * any. WARNING: Liquidity added through this method is only retrievable by
     * the owner of the contract.
     * @param amount count of liquidity being added
     * @param source the token that can be swapped for what is being deposited
     * @param target the token that can is being deposited for swapping
     */
    function addLiquidity(
        uint256 amount,
        address source,
        address target
    ) external;

    /**
     * @notice withdraws tokens from the target of a swap pair.
     * @dev Only callable by owner
     * @param amount count of liquidity being removed
     * @param source the token that can be swapped for what is being removed
     * @param target the token that can is being withdrawn from swapping
     */
    function removeLiquidity(
        uint256 amount,
        address source,
        address target
    ) external;

    /**
     * @notice exchanges the source token for target token
     * @param amount count of tokens being swapped
     * @param source the token that is being given
     * @param target the token that is being taken
     */
    function swap(
        uint256 amount,
        address source,
        address target
    ) external;

    /**
     * @notice send funds that were accidentally transferred back to the owner. This
     * allows rescuing of funds, and poses no additional risk as the owner could
     * already withdraw any funds intended to be swapped. WARNING: If not called
     * correctly this method can throw off the swappable token balances, but that
     * can be recovered from by transferring the discrepancy back to the swap.
     * @dev Only callable by owner
     * @param amount count of tokens being moved
     * @param target the token that is being moved
     */
    function recoverStuckTokens(uint256 amount, address target) external;

    /**
     * @notice swap tokens in one transaction if the sending token supports ERC677
     * @param sender address that initially initiated the call to the source token
     * @param amount count of tokens sent for the swap
     * @param targetData address of target token encoded as a bytes array
     */
    function onTokenTransfer(
        address sender,
        uint256 amount,
        bytes calldata targetData
    ) external;
}

/**
 *Submitted for verification at Etherscan.io on 2022-04-18
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

// File: PotContract.sol

interface IPotLottery {
    struct Token {
        address tokenAddress;
        string tokenSymbol;
        uint256 tokenDecimal;
    }

    enum POT_STATE {
        PAUSED,
        WAITING,
        STARTED,
        LIVE,
        CALCULATING_WINNER
    }

    event EnteredPot(
        string tokenName,
        address indexed userAddress,
        uint256 indexed potRound,
        uint256 usdValue,
        uint256 amount,
        uint256 indexed enteryCount,
        bool hasEntryInCurrentPot
    );
    event CalculateWinner(
        address indexed winner,
        uint256 indexed potRound,
        uint256 potValue,
        uint256 amount,
        uint256 amountWon,
        uint256 participants
    );

    event PotStateChange(uint256 indexed potRound, POT_STATE indexed potState, uint256 indexed time);
    event TokenSwapFailed(string tokenName);

    function getRefund() external;

    function airdropPool() external view returns (uint256);

    function lotteryPool() external view returns (uint256);

    function burnPool() external view returns (uint256);

    function airdropInterval() external view returns (uint256);

    function burnInterval() external view returns (uint256);

    function lotteryInterval() external view returns (uint256);

    function fullFillRandomness() external view returns (uint256);

    function getBNBPrice() external view returns (uint256 price);

    function swapAccumulatedFees() external;

    function burnAccumulatedBNBP() external;

    function airdropAccumulatedBNBP() external returns (uint256);

    function addAdminTokenValue(uint256 value) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./NimbusInitialAcquisitionStorage.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NimbusInitialAcquisition is Initializable, NimbusInitialAcquisitionStorage {
    address public target;

    mapping(address => uint) public unclaimedSponsorBonusNew;
    mapping(address => uint) public unclaimedSponsorBonusEquivalentNew;

    mapping(uint => bool) public isNewSponsorNft;

    IPancakeRouter public pancakeSwapRouter;

    uint256 public cashbackDisableTime;

    mapping(uint256 => mapping(address => mapping(uint256 => bool))) public usedRestakings;

    uint256 private constant PRICE_IMPACT_DECIMALS = 18;  // for integer math
    
    uint256 public maxPriceImpact;

    INimbProxy public nimbProxy;

    function initialize(address systemToken, address nftVestingAddress, address nftSmartLpAddress, address router, address nbuWbnb) public initializer {
        __Pausable_init();
        __Ownable_init();
        require(AddressUpgradeable.isContract(systemToken), "systemToken is not a contract");
        require(AddressUpgradeable.isContract(nftVestingAddress), "nftVestingAddress is not a contract");
        require(AddressUpgradeable.isContract(nftSmartLpAddress), "nftSmartLPAddress is not a contract");
        require(AddressUpgradeable.isContract(router), "router is not a contract");
        require(AddressUpgradeable.isContract(nbuWbnb), "nbuWbnb is not a contract");
        SYSTEM_TOKEN = IERC20Upgradeable(systemToken);
        nftVesting = IVestingNFT(nftVestingAddress);
        nftCashback = ISmartLP(nftSmartLpAddress);
        NBU_WBNB = nbuWbnb;
        sponsorBonus = 10;
        cashbackBonus = 12;
        swapRouter = INimbusRouter(router);
        recipient = address(this);
        allowAccuralMarketingReward = true;

        swapTokenAmountForCashbackBonusThreshold = 400 ether;
        swapTokenAmountForSponsorBonusThreshold = 5000 ether;

        vestingRedeemingAllowed = false;
    }

    receive() external payable {
    }

    function buyExactSystemTokenForTokensAndRegister(address token, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) external whenNotPaused {
        require(sponsorId >= 1000000001, "Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buyExactSystemTokenForTokens(token, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForBnbAndRegister(uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) payable external whenNotPaused {
        require(sponsorId >= 1000000001, "Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buyExactSystemTokenForBnb(systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactBnbAndRegister(address systemTokenRecipient, uint stakingPoolId, uint sponsorId) payable external whenNotPaused {
        require(sponsorId >= 1000000001, "Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buySystemTokenForExactBnb(systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactTokensAndRegister(address token, uint tokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) external whenNotPaused {
        require(sponsorId >= 1000000001, "Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUserBySponsorId(systemTokenRecipient, sponsorId, 0);
        buySystemTokenForExactTokens(token, tokenAmount, systemTokenRecipient, stakingPoolId);
    }
    
    function buyExactSystemTokenForTokens(address token, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "No staking pool with provided id");
        require(allowedTokens[token], "Not allowed token");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "Not part of referral program");
        uint tokenAmount = getTokenAmountForSystemToken(token, systemTokenAmount);
        _buySystemToken(token, tokenAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactTokens(address token, uint tokenAmount, address systemTokenRecipient, uint stakingPoolId) public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "No staking pool with provided id");
        require(allowedTokens[token], "Not allowed token");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "Not part of referral program");
        uint systemTokenAmount = getSystemTokenAmountForToken(token, tokenAmount);
        _buySystemToken(token, tokenAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactBnb(address systemTokenRecipient, uint stakingPoolId) payable public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "No staking pool with provided id");
        require(allowedTokens[NBU_WBNB], "Not allowed purchase for BNB");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "Not part of referral program");
        uint systemTokenAmount = getSystemTokenAmountForBnb(msg.value);
        _buySystemToken(NBU_WBNB, msg.value, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForBnb(uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) payable public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "No staking pool with provided id");
        require(allowedTokens[NBU_WBNB], "Not allowed purchase for BNB");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "Not part of referral program");
        uint systemTokenAmountMax = getSystemTokenAmountForBnb(msg.value);
        require(systemTokenAmountMax >= systemTokenAmount, "Not enough BNB");
        uint bnbAmount = systemTokenAmountMax == systemTokenAmount ? msg.value : getBnbAmountForSystemToken(systemTokenAmount);
        _buySystemToken(NBU_WBNB, bnbAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
        // refund dust bnb, if any
        if (systemTokenAmountMax > systemTokenAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - bnbAmount);
    }

    function restake(uint systemTokenAmount, uint stakingPoolId, uint newStakingPoolId, uint currentStakeNonce) public {
        address user = msg.sender;
        require(address(stakingPools[stakingPoolId]) != address(0) && address(stakingPools[newStakingPoolId]) != address(0), "No staking pool with provided id");
        INimbusStakingPool curStaking = INimbusStakingPool(stakingPools[stakingPoolId]);
        require(referralProgram.userIdByAddress(user) > 0, "Not part of referral program");
        require(currentStakeNonce < curStaking.stakeNonces(user), "Wrong staking nonce");
        INimbusStakingPool.StakeNonceInfo memory stakeInfo = INimbusStakingPool(stakingPools[stakingPoolId]).stakeNonceInfos(user, currentStakeNonce);
        require(stakeInfo.stakingTokenAmount == 0, "Staking not withdrawn yet");
        require(!usedRestakings[stakingPoolId][user][currentStakeNonce], "Already restaked");

        TransferHelper.safeTransferFrom(address(SYSTEM_TOKEN), user, address(this), systemTokenAmount);
        _buySystemToken(address(SYSTEM_TOKEN), systemTokenAmount, systemTokenAmount, user, newStakingPoolId);
        usedRestakings[stakingPoolId][user][currentStakeNonce] = true;
        
        emit Restake(stakingPoolId, newStakingPoolId, currentStakeNonce, systemTokenAmount, user);
    }

    function claimSponsorBonuses(address user, bool isNew) public {
        (bool isAllowed,bool isAllowedNew,,) = isAllowedToRedeemVestingNFT(user);
        require(isAllowed && !isNew || isAllowedNew && isNew, "Not enough bonuses for claim");
        require(msg.sender == user, "Can mint only own Vesting NFT");
        // Mint Vesting NFT
        uint256 nftVestingAmount;
        if (isNew) {
            nftVestingAmount = unclaimedSponsorBonusEquivalentNew[user] * sponsorBonus / 100;
            unclaimedSponsorBonusEquivalentNew[user] = 0;
            unclaimedSponsorBonusNew[user] = 0;
        } else {
            nftVestingAmount = unclaimedSponsorBonusEquivalent[user] * sponsorBonus / 100;
            unclaimedSponsorBonusEquivalent[user] = 0;
            unclaimedSponsorBonus[user] = 0;
        }

        nftVesting.safeMint(user, nftVestingUri, nftVestingAmount, swapToken);
        uint256 nftTokenId = nftVesting.lastTokenId();

        isNewSponsorNft[nftTokenId] = isNew;

        emit ProcessSponsorBonus(user, address(nftVesting), nftTokenId, nftVestingAmount, block.timestamp);
    }

    function availableInitialSupply() external view returns (uint) {
        return SYSTEM_TOKEN.balanceOf(address(this));
    }

    function getSystemTokenAmountForToken(address token, uint tokenAmount) public view returns (uint) { 
        return getTokenAmountForToken(token, address(SYSTEM_TOKEN), tokenAmount, true);
    }

    function getSystemTokenAmountForBnb(uint bnbAmount) public view returns (uint) { 
        return getSystemTokenAmountForToken(NBU_WBNB, bnbAmount); 
    }

    function getSwapSystemTokenAmountForToken(address token, uint tokenAmount) public view returns (uint) { 
        return getSwapRate(token, address(SYSTEM_TOKEN), tokenAmount, false);
    }

    function getSwapSystemTokenAmountForBnb(uint bnbAmount) public view returns (uint) { 
        return getSwapRate(swapRouter.NBU_WBNB(), address(SYSTEM_TOKEN), bnbAmount, false);
    }

    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint tokenAmount, bool isOut) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return isOut ? tokenAmount * rate / precision : tokenAmount * precision / rate;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return isOut ? swapRouter.getAmountsOut(tokenAmount, path)[1] : swapRouter.getAmountsIn(tokenAmount, path)[0];
    }

    function getSwapRate(address tokenSrc, address tokenDest, uint tokenAmount, bool noImpact) public view returns (uint256 resultSwap) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        address[] memory path = new address[](2);
        if (tokenSrc == address(swapToken)) {
            path[0] = address(swapToken);
            path[1] = pancakeSwapRouter.WETH();
            uint[] memory amountsBNBBusd = IPancakeRouter(pancakeSwapRouter)
                .getAmountsOut(tokenAmount, path);
            tokenAmount = amountsBNBBusd[1];
            path[0] = swapRouter.NBU_WBNB();
        } else path[0] = tokenSrc;
        path[1] = tokenDest;

        resultSwap = swapRouter.getAmountsOut(tokenAmount, path)[1];
        if (!noImpact) {
            (uint256 maxSystemTokenImpact, uint256 swapPartBnb,) = getMaxSystemTokenImpact();
            uint256 systemTokenAddPart = 0;

            if (resultSwap > maxSystemTokenImpact && tokenDest == address(SYSTEM_TOKEN)) {
                // part to swap with price impact
                uint256 fixedPriceSwap = tokenAmount - swapPartBnb; // part to swap with fixed price
                systemTokenAddPart = getSystemTokenAmountForBnb(fixedPriceSwap);  // to add NIMB
            }

            resultSwap = resultSwap + systemTokenAddPart;
        }
    }

    function getMaxSystemTokenImpact() public view returns(uint256 nimb, uint256 bnb, uint256 rate) {
        require(maxPriceImpact < 10**PRICE_IMPACT_DECIMALS, "maxPriceImpact too many decimals");
        
        // get reserves
        INimbusPair sysPair = swapRouter.pairFor(address(SYSTEM_TOKEN), swapRouter.NBU_WBNB());
        (uint256 reserve0, uint256 reserve1, ) = sysPair.getReserves();
        uint256 reserveIn = sysPair.token0() == address(SYSTEM_TOKEN) ? reserve0 : reserve1;
        
        uint256 p = 10**(PRICE_IMPACT_DECIMALS*2)/(maxPriceImpact * 2 + 10**PRICE_IMPACT_DECIMALS);
        
        uint256 temp = 9*p*p + 4*1000*997*p*(10**PRICE_IMPACT_DECIMALS);
        uint256 sqrt = MathUpgradeable.sqrt(temp);
        
        nimb = (sqrt - 1997*p)*reserveIn/(2*997*p);
        bnb = getSwapRate(address(SYSTEM_TOKEN), swapRouter.NBU_WBNB(), nimb, true);
        rate = nimb * 10**PRICE_IMPACT_DECIMALS / bnb;
    }

    function getTokenAmountForSystemToken(address token, uint systemTokenAmount) public view returns (uint) { 
        return getTokenAmountForToken(token, address(SYSTEM_TOKEN), systemTokenAmount, false);
    }

    function getBnbAmountForSystemToken(uint systemTokenAmount) public view returns (uint) { 
        return getTokenAmountForSystemToken(NBU_WBNB, systemTokenAmount);
    }

    function currentBalance(address token) external view returns (uint) { 
        return IERC20Upgradeable(token).balanceOf(address(this));
    }

    function isAllowedToRedeemVestingNFT(address user) public view returns (bool isAllowed, bool isAllowedNew, uint256 unclaimedBonus, uint256 unclaimedBonusNew) { 
        unclaimedBonus = unclaimedSponsorBonusEquivalent[user];
        unclaimedBonusNew = unclaimedSponsorBonusEquivalentNew[user];
        isAllowed = unclaimedBonus > 0 && unclaimedBonus >= swapTokenAmountForSponsorBonusThreshold;
        isAllowedNew = unclaimedBonusNew > 0 && unclaimedBonusNew >= swapTokenAmountForSponsorBonusThreshold;
    }

    function _purchaseFromSwap(address token, uint tokenAmount) private returns(uint systemTokenAmount) {
        address[] memory path = new address[](2);
        require(token == address(swapToken) || token == NBU_WBNB, "Wrong purchase token");

        if (token != NBU_WBNB) {
            TransferHelper.safeTransferFrom(address(swapToken), msg.sender, address(this), tokenAmount);
            // Swap with pancakeswap from BUSD to BNB
            if(IERC20Upgradeable(token).allowance(address(this), address(pancakeSwapRouter)) < tokenAmount) {
                IERC20Upgradeable(token).approve(address(pancakeSwapRouter), type(uint256).max);
            }
            path[0] = address(swapToken);
            path[1] = pancakeSwapRouter.WETH();
            (uint[] memory amountsBnbTokenSwap) = pancakeSwapRouter.swapExactTokensForETH(tokenAmount, 0, path, address(this), block.timestamp + 1200);
            tokenAmount = amountsBnbTokenSwap[1];
        }

        (, uint256 swapPartBnb,) = getMaxSystemTokenImpact();
        uint256 systemTokenAddPart = 0;

        if (tokenAmount > swapPartBnb) {
            uint256 fixedPriceSwap = tokenAmount - swapPartBnb; // part to swap with fixed price
            systemTokenAddPart = getSystemTokenAmountForBnb(fixedPriceSwap);  // to add NIMB

            tokenAmount = swapPartBnb;
        }
        
        // Swap with nimbus from BNB to NIMB
        path[0] = swapRouter.NBU_WBNB();
        path[1] = address(SYSTEM_TOKEN);
        (uint[] memory amountsBNBNimb) = swapRouter.swapExactBNBForTokens{value: tokenAmount }(0, path, address(this), block.timestamp + 1200);
        systemTokenAmount = amountsBNBNimb[1] + systemTokenAddPart;
    }

    function _buySystemToken(address token, uint tokenAmount, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) private {
        if (token != address(SYSTEM_TOKEN)) {
            systemTokenAmount = _purchaseFromSwap(token, tokenAmount);
        }
        stakingPools[stakingPoolId].stakeFor(systemTokenAmount, systemTokenRecipient);
        uint swapTokenAmount = getTokenAmountForToken(token, swapToken, tokenAmount, true);

        bool isFirstAP4Staking = userPurchases[systemTokenRecipient] == 0;
        userPurchases[systemTokenRecipient] += systemTokenAmount;
        userPurchasesEquivalent[systemTokenRecipient] += swapTokenAmount;

        if(allowAccuralMarketingReward && address(referralProgramMarketing) != address(0)) {
            referralProgramMarketing.updateReferralProfitAmount(systemTokenRecipient, swapTokenAmount);
        }
        emit BuySystemTokenForToken(token, stakingPoolId, tokenAmount, systemTokenAmount, swapTokenAmount, systemTokenRecipient);
        
        if (isFirstAP4Staking) {
            _processSponsor(systemTokenRecipient, systemTokenAmount, swapTokenAmount);
        }
    }

    function _processSponsor(address systemTokenRecipient, uint systemTokenAmount, uint swapTokenAmount) private {
        address sponsorAddress = getUserSponsorAddress(systemTokenRecipient);
        if (sponsorAddress != address(0)) {
            unclaimedSponsorBonusNew[sponsorAddress] += systemTokenAmount;
            unclaimedSponsorBonusEquivalentNew[sponsorAddress] += swapTokenAmount;
            emit AddUnclaimedSponsorBonus(sponsorAddress, systemTokenRecipient, systemTokenAmount, swapTokenAmount);
        }
    }

    function getUserSponsorAddress(address user) public view returns (address) {
        if (address(referralProgram) == address(0)) {
            return address(0);
        } else {
            return referralProgram.userSponsorAddressByAddress(user);
        } 
    }

    function getAllNFTRewards() public {
        address user = msg.sender;
        uint[] memory nftCashbackIds = nftCashback.getUserTokens(user);
        uint[] memory nftSmartStakerIds = nftSmartStaker.getUserTokens(user);
        require(nftCashbackIds.length + nftSmartStakerIds.length > 0, "No NFT with rewards");
        for (uint256 index = 0; index < nftCashbackIds.length; index++) nftCashback.withdrawUserRewards(nftCashbackIds[index]);
        for (uint256 index = 0; index < nftSmartStakerIds.length; index++) nftSmartStaker.withdrawReward(nftSmartStakerIds[index]);
    }

    function getAllStakingRewards(uint256[] memory stakingIds) public {
        require(stakingIds.length > 0, "No staking IDs");
        address user = msg.sender;
        for (uint256 index = 0; index < stakingIds.length; index++) {
            if (address(stakingPools[stakingIds[index]]) != address(0))
            INimbusStakingPool(stakingPools[stakingIds[index]]).getRewardForUser(user);
        }
    }

    function redeemVestingNFT(uint256 tokenId) public {
        require(vestingRedeemingAllowed, "Not allowed to redeem yet");
        require(nftVesting.ownerOf(tokenId) == msg.sender, "Not owner of vesting NFT");
        IVestingNFT.Denomination memory denomination = nftVesting.denominations(tokenId);
        if (isNewSponsorNft[tokenId]) nftVesting.safeTransferFrom(msg.sender, address(this), tokenId);
        else nftVesting.burn(tokenId);
        TransferHelper.safeTransfer(denomination.token, msg.sender, denomination.value);
        emit VestingNFTRedeemed(address(nftVesting), tokenId, msg.sender, denomination.token, denomination.value);
    }

    //Admin functions
    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Can't be zero address");
        require(amount > 0, "Should be greater than 0");
        TransferHelper.safeTransferBNB(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "Can't be zero address");
        require(amount > 0, "Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }

    function importSponsorBonuses(address user, uint amount, bool isEquivalent, bool isNew, bool addToExistent) external onlyOwner {
        _importSponsorBonuses(user, amount, isEquivalent, isNew, addToExistent);
    }

    function importSponsorBonuses(address[] memory users, uint[] memory amounts, bool isEquivalent, bool isNew, bool addToExistent) external onlyOwner {
        require(users.length == amounts.length, "Wrong lengths");

        for (uint256 i = 0; i < users.length; i++) {
            _importSponsorBonuses(users[i], amounts[i], isEquivalent, isNew, addToExistent);
        }
    }

    function updateAccuralMarketingRewardAllowance(bool isAllowed) external onlyOwner {
        allowAccuralMarketingReward = isAllowed;
    }

    function updateStakingPool(uint id, address stakingPool) public onlyOwner {
        _updateStakingPool(id, stakingPool);
    }

    function updateAllowedTokens(address token, bool isAllowed) external onlyOwner {
        require (token != address(0), "Wrong addresses");
        allowedTokens[token] = isAllowed;
        emit AllowedTokenUpdated(token, isAllowed);
    }
    
    function updateRecipient(address recipientAddress) external onlyOwner {
        require(recipientAddress != address(0), "Address is zero");
        recipient = recipientAddress;
    } 

    function updateSponsorBonus(uint bonus) external onlyOwner {
        sponsorBonus = bonus;
    }

    function updateReferralProgramContract(address newReferralProgramContract) external onlyOwner {
        require(newReferralProgramContract != address(0), "Address is zero");
        referralProgram = INimbusReferralProgram(newReferralProgramContract);
    }

    function updateReferralProgramMarketingContract(address newReferralProgramMarketingContract) external onlyOwner {
        require(newReferralProgramMarketingContract != address(0), "Address is zero");
        referralProgramMarketing = INimbusReferralProgramMarketing(newReferralProgramMarketingContract);
    }

    function updateSwapRouter(address newSwapRouter, address newPancakeSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0) && newPancakeSwapRouter != address(0), "Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
        pancakeSwapRouter = IPancakeRouter(newPancakeSwapRouter);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateNFTContracts(address nftVestingAddress, address nftCashbackAddress, address nftSmartStakerAddress) external onlyOwner {
        require(AddressUpgradeable.isContract(nftVestingAddress) && AddressUpgradeable.isContract(nftCashbackAddress) && AddressUpgradeable.isContract(nftSmartStakerAddress), "Address is not a contract");
        nftVesting = IVestingNFT(nftVestingAddress);
        nftCashback = ISmartLP(nftCashbackAddress);
        nftSmartStaker = IStakingMain(nftSmartStakerAddress);
        emit UpdateNFTVestingContract(nftVestingAddress, nftVestingUri);
        emit UpdateNFTCashbackContract(nftCashbackAddress);
        emit UpdateNFTSmartStakerContract(nftSmartStakerAddress);
    }

    function updateSwapToken(address newSwapToken) external onlyOwner {
        require(newSwapToken != address(0), "Address is zero");
        swapToken = newSwapToken;
        emit SwapTokenUpdated(swapToken);
    }

    function updateSystemToken(address newSystemToken, address newNimbProxy, uint256 _maxPriceImpact) external onlyOwner {
        require(newSystemToken != address(0), "Address is zero");
        SYSTEM_TOKEN = IERC20Upgradeable(newSystemToken);
        nimbProxy = INimbProxy(newNimbProxy);
        require(_maxPriceImpact < 10**PRICE_IMPACT_DECIMALS, "maxPriceImpact too many decimals");

        maxPriceImpact = _maxPriceImpact;
    }

    function updateSwapTokenAmountForSponsorBonusThreshold(uint threshold) external onlyOwner {
        swapTokenAmountForSponsorBonusThreshold = threshold;
        emit SwapTokenAmountForSponsorBonusThresholdUpdated(swapTokenAmountForSponsorBonusThreshold);
    }

    function toggleUsePriceFeeds() external onlyOwner {
        usePriceFeeds = !usePriceFeeds;
        emit ToggleUsePriceFeeds(usePriceFeeds);
    }

    function _updateStakingPool(uint id, address stakingPool) private {
        require(id != 0, "Staking pool id cant be equal to 0.");
        require(stakingPool != address(0), "Staking pool address cant be equal to address(0).");

        stakingPools[id] = INimbusStakingPool(stakingPool);
        require(SYSTEM_TOKEN.approve(stakingPool, type(uint256).max), "Error on approving");
    }

    function _importSponsorBonuses(address user, uint amount, bool isEquivalent, bool isNew, bool addToExistent) private {
        require(user != address(0) && amount > 0, "Zero values");
        
        if (isNew)
        if (isEquivalent) {
            if (addToExistent) {
                unclaimedSponsorBonusEquivalentNew[user] += amount;
            } else {
                unclaimedSponsorBonusEquivalentNew[user] = amount;
            }    
        } else {
            if (addToExistent) {
                unclaimedSponsorBonusNew[user] += amount;
            } else {
                unclaimedSponsorBonusNew[user] = amount;
            }
        } else 
        if (isEquivalent) {
            if (addToExistent) {
                unclaimedSponsorBonusEquivalent[user] += amount;
            } else {
                unclaimedSponsorBonusEquivalent[user] = amount;
            }    
        } else {
            if (addToExistent) {
                unclaimedSponsorBonus[user] += amount;
            } else {
                unclaimedSponsorBonus[user] = amount;
            }
        }
        emit ImportSponsorBonuses(user, amount, isEquivalent, addToExistent);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface ISmartLP is IBEP721 {
    function buySmartLPforBNB() payable external;
    function buySmartLPforWBNB(uint256 amount) external;
    function buySmartLPforToken(uint256 amount) external;
    function withdrawUserRewards(uint tokenId) external;
    function tokenCount() external view returns(uint);
    function getUserTokens(address user) external view returns (uint[] memory);
    function WBNB() external view returns(address);
}

interface IStakingMain is IBEP721 {
    function buySmartStaker(uint256 _setNum, uint _amount) external payable;
    function withdrawReward(uint256 _id) external;
    function tokenCount() external view returns(uint);
    function getUserTokens(address user) external view returns (uint[] memory);
}

interface IVestingNFT is IBEP721 {
    function safeMint(address to, string memory uri, uint nominal, address token) external;
    function totalSupply() external view returns (uint256);
    function lastTokenId() external view returns (uint256);
    function burn(uint256 tokenId) external;
    struct Denomination {
        address token;
        uint256 value;
    }
    function denominations(uint256 tokenId) external returns (Denomination memory denomination);
}

interface INimbusReferralProgram {
    function lastUserId() external view returns (uint);
    function userSponsorByAddress(address user)  external view returns (uint);
    function userIdByAddress(address user) external view returns (uint);
    function userAddressById(uint id) external view returns (address);
    function userSponsorAddressByAddress(address user) external view returns (address);
}

interface INimbusStakingPool {
    struct StakeNonceInfo {
        uint256 unlockTime;
        uint256 stakeTime;
        uint256 stakingTokenAmount;
        uint256 rewardsTokenAmount;
        uint256 rewardRate;
    }
    function stakeFor(uint amount, address user) external;
    function balanceOf(address account) external view returns (uint256);
    function stakingToken() external view returns (IERC20Upgradeable);
    function rewardsToken() external view returns (IERC20Upgradeable);
    function getRewardForUser(address user) external;
    function stakeNonceInfos(address user, uint256 nonce) external view returns (StakeNonceInfo memory);
    function stakeNonces(address user) external view returns (uint256);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface INimbusRouter {
    function NBU_WBNB() external view returns(address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function pairFor(address tokenA, address tokenB) external view returns (INimbusPair);
}

interface INimbusPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPancakeRouter {
    function WETH() external view returns(address);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface INimbProxy {
    function mint(address receiver, uint256 amount) external;
}

interface INimbusReferralProgramMarketing {
    function registerUser(address user, uint sponsorId) external returns(uint userId);
    function updateReferralProfitAmount(address user, uint amount) external;
    function registerUserBySponsorId(address user, uint sponsorId, uint category) external returns (uint);
    function userPersonalTurnover(address user) external returns(uint);
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external returns(address);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

contract NimbusInitialAcquisitionStorage is OwnableUpgradeable, PausableUpgradeable {
    IERC20Upgradeable public SYSTEM_TOKEN;
    address public NBU_WBNB;
    INimbusReferralProgram public referralProgram;
    INimbusReferralProgramMarketing public referralProgramMarketing;
    IPriceFeed public priceFeed;

    IVestingNFT public nftVesting;
    ISmartLP public nftCashback;
    IStakingMain public nftSmartStaker;

    string public nftVestingUri;

    bool public allowAccuralMarketingReward;

    mapping(uint => INimbusStakingPool) public stakingPools;
    mapping(address => uint) public userPurchases;
    mapping(address => uint) public userPurchasesEquivalent;

    address public recipient;                      

    INimbusRouter public swapRouter;                
    mapping (address => bool) public allowedTokens;
    address public swapToken;                       
    
    uint public sponsorBonus;
    uint public swapTokenAmountForSponsorBonusThreshold;  
    mapping(address => uint) public unclaimedSponsorBonus;
    mapping(address => uint) public unclaimedSponsorBonusEquivalent;

    bool public usePriceFeeds;

    uint public cashbackBonus;
    uint public swapTokenAmountForCashbackBonusThreshold;  

    bool public vestingRedeemingAllowed;

    event BuySystemTokenForToken(address indexed token, uint indexed stakingPool, uint tokenAmount, uint systemTokenAmount, uint swapTokenAmount, address indexed systemTokenRecipient);
    event Restake(uint indexed stakingPoolIdSrc, uint indexed stakingPoolIdDst, uint currentStakingNonce, uint systemTokenAmount, address indexed systemTokenRecipient);
    event ProcessSponsorBonus(address indexed user, address indexed nftContract, uint nftTokenId, uint amount, uint indexed timestamp);
    event AddUnclaimedSponsorBonus(address indexed sponsor, address indexed user, uint systemTokenAmount, uint swapTokenAmount);

    event VestingNFTRedeemed(address indexed nftVesting, uint indexed tokenId, address user, address token, uint value);

    event UpdateTokenSystemTokenWeightedExchangeRate(address indexed token, uint indexed newRate);
    event ToggleUsePriceFeeds(bool indexed usePriceFeeds);
    event ToggleVestingRedeemingAllowed(bool indexed vestingRedeemingAllowed);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed token, address indexed to, uint amount);

    event AllowedTokenUpdated(address indexed token, bool allowance);
    event SwapTokenUpdated(address indexed swapToken);
    event SwapTokenAmountForSponsorBonusThresholdUpdated(uint indexed amount);
    event SwapTokenAmountForCashbackBonusThresholdUpdated(uint indexed amount);

    event ProcessCashbackBonus(address indexed to, address indexed nftContract, uint nftTokenId, address purchaseToken, uint amount, uint indexed timestamp);
    event UpdateCashbackBonus(uint indexed cashbackBonus);
    event UpdateNFTVestingContract(address indexed nftVestingAddress, string nftVestingUri);
    event UpdateNFTCashbackContract(address indexed nftCashbackAddress);
    event UpdateNFTSmartStakerContract(address indexed nftSmartStakerAddress);
    event UpdateVestingParams(uint vestingFirstPeriod, uint vestingSecondPeriod);
    event ImportUserPurchases(address indexed user, uint amount, bool indexed isEquivalent, bool indexed addToExistent);
    event ImportSponsorBonuses(address indexed user, uint amount, bool indexed isEquivalent, bool indexed addToExistent);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import './StakingSetStorage.sol';

contract StakingSetBusd is StakingSetStorage {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    uint256 public constant MULTIPLIER = 1 ether;
    
    IERC20Upgradeable public nimbToken;
    IERC20Upgradeable public gnimbToken;
    IERC20Upgradeable public paymentToken;
    IStaking public GnimbStaking;
    mapping(uint256 => uint256) internal _balancesRewardEquivalentGnimb;
    mapping(uint256 => bool) public gnimbPurchases;
    
    bool public usePriceFeeds;
    IPriceFeed public priceFeed;
    
    event UpdateUsePriceFeeds(bool indexed isUsePriceFeeds);   

    function initialize(
        address _nimbusRouter, 
        address _pancakeRouter,
        address _nimbusBNB, 
        address _binanceBNB,
        address _nbuToken, 
        address _gnbuToken,
        address _busdToken, 
        address _lpBnbCake,
        address _NbuStaking, 
        address _GnbuStaking,
        address _CakeStaking,
        address _hub
    ) external initializer {
        __Context_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        require(AddressUpgradeable.isContract(_nimbusRouter), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_pancakeRouter), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_nimbusBNB), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_binanceBNB), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_nbuToken), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_gnbuToken), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_busdToken), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_lpBnbCake), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_NbuStaking), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_GnbuStaking), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_CakeStaking), "NimbusStakingSet_V1: Not contract");
        require(AddressUpgradeable.isContract(_hub), "NimbusStakingSet_V1: Not contract");

        nimbusRouter = IRouter(_nimbusRouter);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        nimbusBNB = IWBNB(_nimbusBNB);
        binanceBNB = IWBNB(_binanceBNB);
        nbuToken = IERC20Upgradeable(_nbuToken);
        gnbuToken = IERC20Upgradeable(_gnbuToken);
        busdToken = IERC20Upgradeable(_busdToken);
        lpBnbCake = IlpBnbCake(_lpBnbCake);
        NbuStaking = IStaking(_NbuStaking);
        GnbuStaking = IStaking(_GnbuStaking);
        CakeStaking = IMasterChef(_CakeStaking);
        cakeToken = IERC20Upgradeable(CakeStaking.CAKE());
        purchaseToken = _busdToken;
        hubRouting = _hub;

        minPurchaseAmount = 500 ether;
        lockTime = 30 days;
        POOLS_NUMBER = 3;
        rewardDuration = IStaking(_NbuStaking).rewardDuration();

        require(IERC20Upgradeable(_nbuToken).approve(_nimbusRouter, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_gnbuToken).approve(_nimbusRouter, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_nbuToken).approve(_NbuStaking, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_gnbuToken).approve(_GnbuStaking, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_busdToken).approve(_nimbusRouter, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");

        require(IERC20Upgradeable(_lpBnbCake).approve(_CakeStaking, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_lpBnbCake).approve(_pancakeRouter, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(CakeStaking.CAKE()).approve(_pancakeRouter, type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
    }

    receive() external payable {
        require(msg.sender == address(nimbusBNB) 
        || msg.sender == address(binanceBNB)
        || msg.sender == address(nimbusRouter)
        || msg.sender == address(pancakeRouter),
      "StakingSet :: receiving BNB is not allowed");
    }

    modifier onlyHub {
        require(msg.sender == hubRouting, "HubRouting::caller is not the Staking Main contract");
        _;
    }

    // ========================== StakingSet functions ==========================


    function buyStakingSet(uint256 amount, uint256 tokenId) external onlyHub {
        require(amount >= minPurchaseAmount, "StakingSet: Token price is more than sent");
        providedAmount[tokenId] = amount;
        emit BuyStakingSet(tokenId, purchaseToken, amount, block.timestamp);

        (uint256 nbuAmount,uint256 gnimbAmount,uint256 cakeLPamount) = makeSwaps(amount); 

        uint256 nonceNbu = NbuStaking.stakeNonces(address(this));
        _balancesRewardEquivalentNbu[tokenId] += nbuAmount;

        uint256 nonceGnimb = GnimbStaking.stakeNonces(address(this));
        uint256 amountRewardEquivalentGnimb = GnimbStaking.getEquivalentAmount(gnimbAmount);
        _balancesRewardEquivalentGnimb[tokenId] += amountRewardEquivalentGnimb; 

        IMasterChef.UserInfo memory user = CakeStaking.userInfo(cakePID, address(this));
        uint oldCakeShares = user.amount;


        UserSupply storage userSupply = tikSupplies[tokenId];
        userSupply.IsActive = true;
        userSupply.NbuStakingAmount = nbuAmount;
        userSupply.GnbuStakingAmount = gnimbAmount;
        userSupply.CakeBnbAmount = cakeLPamount;
        userSupply.NbuStakeNonce = nonceNbu;
        userSupply.GnbuStakeNonce = nonceGnimb;
        userSupply.SupplyTime = block.timestamp;
        userSupply.TokenId = tokenId;

        uint lpBalanceOld = lpBnbCake.balanceOf(address(CakeStaking));
        CakeStaking.deposit(cakePID,cakeLPamount);
        uint lpBalanceNew = lpBnbCake.balanceOf(address(CakeStaking));
        require(lpBalanceNew - cakeLPamount == lpBalanceOld, "StakingSet: Cake/BNB LP staking deposit is unsuccessful");

        user = CakeStaking.userInfo(cakePID, address(this));
        userSupply.CakeShares = user.amount - oldCakeShares;
        userSupply.CurrentCakeShares = user.amount;
        userSupply.CurrentRewardDebt = user.rewardDebt;
      
        weightedStakeDate[tokenId] = userSupply.SupplyTime;
        counter++;
        gnimbPurchases[tokenId] = true;

        uint256 oldBalanceNbu = NbuStaking.balanceOf(address(this));
        NbuStaking.stake(nbuAmount);
        uint256 newBalanceNbu = NbuStaking.balanceOf(address(this));
        require(newBalanceNbu - nbuAmount == oldBalanceNbu, "StakingSet: NBU staking deposit is unsuccessful");
        
        uint256 oldBalanceGnimb = GnimbStaking.balanceOf(address(this));
        GnimbStaking.stake(gnimbAmount);
        uint256 newBalanceGnimb = GnimbStaking.balanceOf(address(this));
        require(newBalanceGnimb - gnimbAmount == oldBalanceGnimb, "StakingSet: GNIMB staking deposit is unsuccessful");
    }

    function makeSwaps(uint256 amount) private returns(uint256,uint256,uint256) {
      uint256 swapDeadline = block.timestamp + 1200; // 20 mins
      address[] memory path = new address[](2);
      path[0] = address(busdToken);
      path[1] = address(binanceBNB);
      if (busdToken.allowance(address(this), address(pancakeRouter)) < amount)
        require(busdToken.approve(address(pancakeRouter), type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
      (uint[] memory amountsBusdBnb) = pancakeRouter.swapExactTokensForETH(amount, 0, path, address(this), swapDeadline);
      amount = amountsBusdBnb[1] * MULTIPLIER;
      
      uint CakeEAmount = amount * 30 / 100;

      path = new address[](2);
      path[0] = address(binanceBNB);
      path[1] = address(cakeToken);
      (uint[] memory amountsBnbCakeSwap) = pancakeRouter.swapExactETHForTokens{value:  (CakeEAmount / 2) / MULTIPLIER }(0, path, address(this), swapDeadline);
    (, uint amountBnbCake, uint liquidityBnbCake) = pancakeRouter.addLiquidityETH{value: (amount - CakeEAmount / 2) / MULTIPLIER }(address(cakeToken), amountsBnbCakeSwap[1], 0, 0, address(this), swapDeadline);
      uint NbuAmount = ((amount - MULTIPLIER * amountBnbCake - CakeEAmount/ 2 ) / 2) / MULTIPLIER;
      
      path[0] = address(nimbusBNB);
      path[1] = address(nbuToken);
      (uint[] memory amountsBnbNbuStaking) = nimbusRouter.swapExactBNBForTokens{value: NbuAmount}(0, path, address(this), swapDeadline);

      path[1] = address(gnimbToken);      
        (uint[] memory amountsBnbGnimbStaking) = nimbusRouter.swapExactBNBForTokens{value: NbuAmount}(0, path, address(this), swapDeadline);
      
      return (amountsBnbNbuStaking[1], amountsBnbGnimbStaking[1], liquidityBnbCake);
    }

    function getNFTfields(uint tokenId, uint NFTFieldIndex) 
        external 
        view 
        returns (address pool, address rewardToken, uint256 rewardAmount, uint256 percentage, uint256 stakedAmount) {
        (uint256 nbuReward, uint256 gnimbReward, uint256 cakeReward) = getTokenRewardsAmounts(tokenId);
        if (NFTFieldIndex == 0) {
            pool = address(NbuStaking);
            rewardToken = address(gnimbToken);
            rewardAmount = getTokenAmountForToken(
                address(nbuToken), 
                address(paymentToken), 
                nbuReward
            );
            percentage = 35 ether;
            stakedAmount = tikSupplies[tokenId].NbuStakingAmount;
        }
        else if (NFTFieldIndex == 1) {
            pool = address(GnimbStaking);
            rewardToken = address(gnimbToken);
            rewardAmount = getTokenAmountForToken(
                address(nimbToken), 
                address(paymentToken), 
                gnimbReward
            );
            percentage = 35 ether;
            stakedAmount = tikSupplies[tokenId].GnbuStakingAmount;
        }
        else if (NFTFieldIndex == 2) {
            pool = address(CakeStaking);
            rewardToken = address(cakeToken);
            rewardAmount = cakeReward;
            percentage = 30 ether;
            stakedAmount = tikSupplies[tokenId].CakeBnbAmount;
        }
    }

    function getNFTtiming(uint256 tokenId) external view returns(uint256 supplyTime, uint256 burnTime) {
        supplyTime = tikSupplies[tokenId].SupplyTime;
        burnTime = tikSupplies[tokenId].BurnTime;
    }  

    function withdrawUserRewards(uint tokenId, address tokenOwner) external nonReentrant onlyHub {
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "StakingSet: Not active");
        (uint256 nbuReward, uint256 cakeReward) = getTotalAmountsOfRewards(tokenId);
        _withdrawUserRewards(tokenId, tokenOwner, nbuReward, cakeReward);
    }
    
    function burnStakingSet(uint tokenId, address tokenOwner) external nonReentrant onlyHub {
        UserSupply storage userSupply = tikSupplies[tokenId];
        require(block.timestamp > userSupply.SupplyTime + lockTime, "StakingSet:: NFT is locked");
        require(userSupply.IsActive, "StakingSet: Token not active");

        (uint256 nbuReward, uint256 cakeReward) = getTotalAmountsOfRewards(tokenId);
        userSupply.IsActive = false;
        userSupply.BurnTime = block.timestamp;

        emit BurnStakingSet(tokenId, userSupply.NbuStakingAmount, userSupply.GnbuStakingAmount, userSupply.CakeBnbAmount);     

        if(nbuReward > 0) {
            _withdrawUserRewards(tokenId, tokenOwner, nbuReward, cakeReward);
        }

        if (gnimbPurchases[tokenId]) {
            GnimbStaking.withdraw(userSupply.GnbuStakeNonce);
        } else GnbuStaking.withdraw(userSupply.GnbuStakeNonce);

        NbuStaking.withdraw(userSupply.NbuStakeNonce);
        CakeStaking.withdraw(cakePID, userSupply.CakeBnbAmount);

        TransferHelper.safeTransfer(address(nbuToken), tokenOwner, userSupply.NbuStakingAmount);
        TransferHelper.safeTransfer(address(gnimbToken), tokenOwner, userSupply.GnbuStakingAmount);
        pancakeRouter.removeLiquidityETH(address(cakeToken), userSupply.CakeBnbAmount, 0, 0, tokenOwner, block.timestamp);
    }

    function getTokenRewardsAmounts(uint tokenId) public view returns (uint256 NbuUserRewards, uint256 GnimbUserRewards, uint256 CakeUserRewards) {
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "StakingSet: Not active");
        
        NbuUserRewards = ((_balancesRewardEquivalentNbu[tokenId] * ((block.timestamp - weightedStakeDate[tokenId]) * 60)) * MULTIPLIER / (100 * rewardDuration)) / MULTIPLIER;
        GnimbUserRewards = (((_balancesRewardEquivalentGnbu[tokenId] + _balancesRewardEquivalentGnimb[tokenId]) * ((block.timestamp - weightedStakeDate[tokenId]) * 60)) * MULTIPLIER / (100 * rewardDuration)) / MULTIPLIER;
        CakeUserRewards = getUserCakeRewards(tokenId);
    }
    
    function getTotalAmountsOfRewards(uint tokenId) public view returns (uint256, uint256) {
        (uint256 NbuUserRewards, uint256 GnimbUserRewards, uint256 CakeUserRewards) = getTokenRewardsAmounts(tokenId);
        uint256 nbuReward = getTokenAmountForToken(
            address(nbuToken), 
            address(paymentToken), 
            NbuUserRewards
        ) + getTokenAmountForToken(
            address(nimbToken), 
            address(paymentToken), 
            GnimbUserRewards
        );

        return (nbuReward, CakeUserRewards);
    }

    function getUserCakeRewards(uint256 tokenId) public view returns (uint256) {
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "StakingSet: Not active");
        
        uint256 ACC_CAKE_PRECISION = 1e18;
        uint256 BOOST_PRECISION = 100 * 1e10;

        IMasterChef.PoolInfo memory pool = CakeStaking.poolInfo(cakePID);
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.totalBoostedShare;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - pool.lastRewardBlock;

            uint256 cakeReward = multiplier  * CakeStaking.cakePerBlock(pool.isRegular) * pool.allocPoint /
                (pool.isRegular ? CakeStaking.totalRegularAllocPoint() : CakeStaking.totalSpecialAllocPoint());
            accCakePerShare = accCakePerShare + cakeReward * ACC_CAKE_PRECISION / lpSupply;
        }

        uint256 boostedAmount = userSupply.CakeShares * CakeStaking.getBoostMultiplier(address(this), cakePID) * MULTIPLIER / BOOST_PRECISION;
        return (boostedAmount * accCakePerShare / ACC_CAKE_PRECISION - (userSupply.CurrentRewardDebt * userSupply.CakeShares * MULTIPLIER / userSupply.CurrentCakeShares)) / MULTIPLIER;
    }
    

    function _withdrawUserRewards(uint256 tokenId, address tokenOwner, uint256 totalNbuReward, uint256 totalCakeReward) private {
        require(totalNbuReward > 0 || totalCakeReward > 0, "StakingSet: Claim not enough");
        emit WithdrawRewards(tokenOwner, tokenId, totalNbuReward, totalCakeReward);

        if (address(paymentToken) == address(nimbToken)) {
            if (nbuToken.balanceOf(address(this)) < totalNbuReward) {
                emit BalanceNBURewardsNotEnough(tokenOwner, tokenId, totalNbuReward);
                NbuStaking.getReward();
                GnimbStaking.getReward();
            }
        }

        weightedStakeDate[tokenId] = block.timestamp;
        require(paymentToken.balanceOf(address(this)) >= totalNbuReward, "StakingSet :: Not enough funds on contract to pay off claim");
        TransferHelper.safeTransfer(address(paymentToken), tokenOwner, totalNbuReward);

        CakeStaking.deposit(cakePID, 0);
        IMasterChef.UserInfo memory user = CakeStaking.userInfo(cakePID, address(this));
        tikSupplies[tokenId].CurrentRewardDebt = user.rewardDebt;
        tikSupplies[tokenId].CurrentCakeShares = user.amount;

        TransferHelper.safeTransfer(address(cakeToken), tokenOwner, totalCakeReward);
    }

    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint256 tokenAmount) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return tokenAmount * rate / precision;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return nimbusRouter.getAmountsOut(tokenAmount, path)[1];
    }

    // ========================== Owner functions ==========================

    function setLockTime(uint256 _lockTime) external onlyOwner {
        lockTime = _lockTime;

        emit UpdateLockTime(_lockTime);
    }

    function setCakePID(uint256 _cakePID) external onlyOwner {
        cakePID = _cakePID;

        emit UpdateCakePID(_cakePID);
    }

    function rescue(address to, address tokenAddress, uint256 amount) external onlyOwner {
        require(to != address(0), "StakingSet: Cannot rescue to the zero address");
        require(amount > 0, "StakingSet: Cannot rescue 0");

        emit RescueToken(to, address(tokenAddress), amount);
        require(IERC20Upgradeable(tokenAddress).transfer(to, amount), "IERC20Upgradeable: TRANSFER_FAILED");
    }

    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "StakingSet: Cannot rescue to the zero address");
        require(amount > 0, "StakingSet: Cannot rescue 0");

        emit Rescue(to, amount);
        to.transfer(amount);
    }

    function updateNimbusRouter(address newNimbusRouter) external onlyOwner {
        require(AddressUpgradeable.isContract(newNimbusRouter), "StakingSet: Not a contract");
        nimbusRouter = IRouter(newNimbusRouter);
        emit UpdateNimbusRouter(newNimbusRouter);
    }
    
    function updateNbuStaking(address newLpStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(newLpStaking), "StakingSet: Not a contract");
        NbuStaking = IStaking(newLpStaking);
        emit UpdateNbuStaking(newLpStaking);
    }
    
    function updateGnimbStaking(address newStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(newStaking), "StakingSet: Not a contract");
        GnimbStaking = IStaking(newStaking);
    }

    function updateCakeStaking(address newCakeStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(newCakeStaking), "StakingSet: Not a contract");
        CakeStaking = IMasterChef(newCakeStaking);
        emit UpdateCakeStaking(newCakeStaking);
    }

    function updatePaymentToken(address _paymentToken) external onlyOwner {
        require(AddressUpgradeable.isContract(_paymentToken), "StakingSet: Not a contract");
        paymentToken = IERC20Upgradeable(_paymentToken);
    }

    function updateNimbToken(address _nimbToken) external onlyOwner {
        require(AddressUpgradeable.isContract(_nimbToken), "StakingSet: Not a contract");
        nimbToken = IERC20Upgradeable(_nimbToken);
    }

    function updateGnimbToken(address _gnimbToken, address newStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(_gnimbToken), "StakingSet: Not a contract");
        require(AddressUpgradeable.isContract(newStaking), "StakingSet: Not a contract");
        require(IERC20Upgradeable(_gnimbToken).approve(address(nimbusRouter), type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        require(IERC20Upgradeable(_gnimbToken).approve(address(newStaking), type(uint256).max), "IERC20Upgradeable: APPROVE_FAILED");
        gnimbToken = IERC20Upgradeable(_gnimbToken);
        GnimbStaking = IStaking(newStaking);
    }
        
    function updateTokenAllowance(address token, address spender, int amount) external onlyOwner {
        require(AddressUpgradeable.isContract(token), "StakingSet: Not a contract");
        uint allowance;
        if (amount < 0) {
            allowance = type(uint256).max;
        } else {
            allowance = uint256(amount);
        }
        IERC20Upgradeable(token).approve(spender, allowance);
    }
    
    function updateMinPurchaseAmount (uint newAmount) external onlyOwner {
        require(newAmount > 0, "StakingSet: Amount must be greater than zero");
        minPurchaseAmount = newAmount;
        emit UpdateMinPurchaseAmount(newAmount);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "StakingSet: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateUsePriceFeeds(bool isUsePriceFeeds) external onlyOwner {
        usePriceFeeds = isUsePriceFeeds;
        emit UpdateUsePriceFeeds(isUsePriceFeeds);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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

interface IRouter {
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] memory path
    ) external view returns (uint[] memory amounts);

}

interface IPancakeRouter {
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
}

interface IStaking {
    function stake(uint256 amount) external;
    function stakeNonces (address) external view returns (uint256);
    function stakeFor(uint256 amount, address user) external;
    function getEquivalentAmount(uint amount) external view returns (uint);
    function balanceOf(address account) external view returns (uint256);
    function getReward() external;
    function withdraw(uint256 nonce) external;
    function rewardDuration() external returns (uint256);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface IlpBnbCake {
    function approve(address spender, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);

}

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);
    function harvestFromMasterChef() external;
    function getBoostMultiplier(address _user, uint256 _pid) external view returns (uint256);
    struct PoolInfo {
        uint256 accCakePerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        bool isRegular;
    }
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }
    function poolInfo(uint256 _pid) external view returns (PoolInfo memory); 
    function totalRegularAllocPoint() external view returns (uint256);
    function totalSpecialAllocPoint() external view returns (uint256);
    function cakePerBlock(bool _isRegular) external view returns (uint256);
    function userInfo(uint256 _pid, address _user) external view returns (UserInfo memory);
    function CAKE() external view returns(address);
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external view returns(address);
}


contract StakingSetStorage is ContextUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC165 {    
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IWBNB public nimbusBNB;
    IWBNB public binanceBNB;
    IRouter public nimbusRouter;
    IPancakeRouter public pancakeRouter;
    IStaking public NbuStaking;
    IStaking public GnbuStaking;
    IMasterChef public CakeStaking;
    IlpBnbCake public lpBnbCake;
    IERC20Upgradeable public nbuToken;
    IERC20Upgradeable public gnbuToken;
    IERC20Upgradeable public cakeToken;
    IERC20Upgradeable public busdToken;
    address public purchaseToken;
    address public hubRouting;
    uint256 public minPurchaseAmount;
    uint256 public rewardDuration;
    uint256 public counter;
    uint256 public lockTime;
    uint256 public cakePID;
    uint256 public POOLS_NUMBER;

    mapping(uint256 => uint256) public providedAmount;

    struct NFTFields {
	  address pool;
	  address rewardToken;
	  uint256 rewardAmount;
	  uint256 percentage;
      uint256 stakedAmount;
    }  
    
    struct UserSupply { 
      uint NbuStakingAmount;
      uint GnbuStakingAmount;
      uint CakeBnbAmount;
      uint CakeShares;
      uint CurrentRewardDebt;
      uint CurrentCakeShares;
      uint NbuStakeNonce;
      uint GnbuStakeNonce;
      uint SupplyTime;
      uint BurnTime;
      uint TokenId;
      bool IsActive;
    }

    
    mapping(uint => uint256) internal _balancesRewardEquivalentNbu;
    mapping(uint => uint256) internal _balancesRewardEquivalentGnbu;
    mapping(uint => UserSupply) public tikSupplies;
    mapping(uint => uint256) public weightedStakeDate;

    event BuyStakingSet(uint indexed tokenId, address indexed purchaseToken, uint providedAmount, uint supplyTime);
    event WithdrawRewards(address indexed user, uint indexed tokenId, uint totalNbuReward, uint totalCakeReward);
    event BalanceNBURewardsNotEnough(address indexed user, uint indexed tokenId, uint totalNbuReward);
    event BurnStakingSet(uint indexed tokenId, uint nbuStakedAmount, uint gnbuStakedAmount, uint lpCakeBnbStakedAmount);
    event UpdateNimbusRouter(address indexed newNimbusRouterContract);
    event UpdateNbuStaking(address indexed newNbuStakingContract);
    event UpdateGnbuStaking(address indexed newGnbuStakingContract);
    event UpdateCakeStaking(address indexed newCakeStakingContract);
    event UpdateTokenNbu(address indexed newToken);
    event UpdateTokenGnbu(address indexed newToken);
    event UpdateTokenCake(address indexed newToken);
    event UpdateMinPurchaseAmount(uint newAmount);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed to, address indexed token, uint amount);
    event UpdateLockTime(uint indexed newlockTime);
    event UpdateCakePID(uint indexed newCakePID);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
        IERC20PermitUpgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
interface IERC20PermitUpgradeable {
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
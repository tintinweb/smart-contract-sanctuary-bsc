/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

abstract contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }


    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
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
    function stakeFor(uint amount, address user) external;
    function balanceOf(address account) external view returns (uint256);
    function stakingToken() external view returns (IBEP20);
    function rewardsToken() external view returns (IBEP20);
    function getRewardForUser(address user) external;
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface INimbusRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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


library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in construction, 
        // since the code is only stored at the end of the constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract NimbusInitialAcquisitionStorage is Ownable, Pausable {
    IBEP20 public SYSTEM_TOKEN;
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

contract NimbusInitialAcquisition is NimbusInitialAcquisitionStorage {
    address public target;

    function initialize(address systemToken, address nftVestingAddress, address nftSmartLpAddress, address router, address nbuWbnb) external onlyOwner {
        require(Address.isContract(systemToken), "systemToken is not a contract");
        require(Address.isContract(nftVestingAddress), "nftVestingAddress is not a contract");
        require(Address.isContract(nftSmartLpAddress), "nftSmartLPAddress is not a contract");
        require(Address.isContract(router), "router is not a contract");
        require(Address.isContract(nbuWbnb), "nbuWbnb is not a contract");
        SYSTEM_TOKEN = IBEP20(systemToken);
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

        vestingRedeemingAllowed = true;
    }

    receive() external payable {
        assert(msg.sender == address(NBU_WBNB));
    }

    function buyExactSystemTokenForTokensAndRegister(address token, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) external whenNotPaused {
        require(sponsorId >= 1000000001, "NimbusInitialAcquisition: Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buyExactSystemTokenForTokens(token, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForTokensAndRegister(address token, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) external whenNotPaused {
        referralProgramMarketing.registerUser(systemTokenRecipient, 1000000001);
        buyExactSystemTokenForTokens(token, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForBnbAndRegister(uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) payable external whenNotPaused {
        require(sponsorId >= 1000000001, "NimbusInitialAcquisition: Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buyExactSystemTokenForBnb(systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForBnbAndRegister(uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) payable external whenNotPaused {
        referralProgramMarketing.registerUser(msg.sender, 1000000001);
        buyExactSystemTokenForBnb(systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactBnbAndRegister(address systemTokenRecipient, uint stakingPoolId, uint sponsorId) payable external whenNotPaused {
        require(sponsorId >= 1000000001, "NimbusInitialAcquisition: Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUser(systemTokenRecipient, sponsorId);
        buySystemTokenForExactBnb(systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactBnbAndRegister(address systemTokenRecipient, uint stakingPoolId) payable external whenNotPaused {
        referralProgramMarketing.registerUser(systemTokenRecipient, 1000000001);
        buySystemTokenForExactBnb(systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactTokensAndRegister(address token, uint tokenAmount, address systemTokenRecipient, uint stakingPoolId, uint sponsorId) external whenNotPaused {
        require(sponsorId >= 1000000001, "NimbusInitialAcquisition: Sponsor id must be grater than 1000000000");
        referralProgramMarketing.registerUserBySponsorId(systemTokenRecipient, sponsorId, 0);
        buySystemTokenForExactTokens(token, tokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactTokensAndRegister(address token, uint tokenAmount, address systemTokenRecipient, uint stakingPoolId) external whenNotPaused {
        referralProgramMarketing.registerUser(systemTokenRecipient, 1000000001);
        buySystemTokenForExactTokens(token, tokenAmount, systemTokenRecipient, stakingPoolId);
    }
    
    function buyExactSystemTokenForTokens(address token, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "NimbusInitialAcquisition: No staking pool with provided id");
        require(allowedTokens[token], "NimbusInitialAcquisition: Not allowed token");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "NimbusInitialAcquisition: Not part of referral program");
        uint tokenAmount = getTokenAmountForSystemToken(token, systemTokenAmount);
        TransferHelper.safeTransferFrom(token, msg.sender, recipient, tokenAmount);
        _buySystemToken(token, tokenAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactTokens(address token, uint tokenAmount, address systemTokenRecipient, uint stakingPoolId) public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "NimbusInitialAcquisition: No staking pool with provided id");
        require(allowedTokens[token], "NimbusInitialAcquisition: Not allowed token");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "NimbusInitialAcquisition: Not part of referral program");
        uint systemTokenAmount = getSystemTokenAmountForToken(token, tokenAmount);
        TransferHelper.safeTransferFrom(token, msg.sender, recipient, tokenAmount);
        _buySystemToken(token, tokenAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buySystemTokenForExactBnb(address systemTokenRecipient, uint stakingPoolId) payable public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "NimbusInitialAcquisition: No staking pool with provided id");
        require(allowedTokens[NBU_WBNB], "NimbusInitialAcquisition: Not allowed purchase for BNB");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "NimbusInitialAcquisition: Not part of referral program");
        uint systemTokenAmount = getSystemTokenAmountForBnb(msg.value);
        IWBNB(NBU_WBNB).deposit{value: msg.value}();
        _buySystemToken(NBU_WBNB, msg.value, systemTokenAmount, systemTokenRecipient, stakingPoolId);
    }

    function buyExactSystemTokenForBnb(uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) payable public whenNotPaused {
        require(address(stakingPools[stakingPoolId]) != address(0), "NimbusInitialAcquisition: No staking pool with provided id");
        require(allowedTokens[NBU_WBNB], "NimbusInitialAcquisition: Not allowed purchase for BNB");
        require(referralProgram.userIdByAddress(msg.sender) > 0, "NimbusInitialAcquisition: Not part of referral program");
        uint systemTokenAmountMax = getSystemTokenAmountForBnb(msg.value);
        require(systemTokenAmountMax >= systemTokenAmount, "NimbusInitialAcquisition: Not enough BNB");
        uint bnbAmount = systemTokenAmountMax == systemTokenAmount ? msg.value : getBnbAmountForSystemToken(systemTokenAmount);
        IWBNB(NBU_WBNB).deposit{value: bnbAmount}();
        _buySystemToken(NBU_WBNB, bnbAmount, systemTokenAmount, systemTokenRecipient, stakingPoolId);
        // refund dust bnb, if any
        if (systemTokenAmountMax > systemTokenAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - bnbAmount);
    }

    function claimSponsorBonuses(address user) public {
        (bool isAllowed,) = isAllowedToRedeemVestingNFT(user);
        require(isAllowed, "NimbusInitialAcquisition: Not enough bonuses for claim");
        require(msg.sender == user, "NimbusInitialAcquisition: Can mint only own Vesting NFT");
        // Mint Vesting NFT
        uint256 nftVestingAmount = unclaimedSponsorBonusEquivalent[user] * sponsorBonus / 100;
        nftVesting.safeMint(user, nftVestingUri, nftVestingAmount, swapToken);
        uint256 nftTokenId = nftVesting.lastTokenId();
        unclaimedSponsorBonusEquivalent[user] = 0;
        unclaimedSponsorBonus[user] = 0;
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

    function getTokenAmountForSystemToken(address token, uint systemTokenAmount) public view returns (uint) { 
        return getTokenAmountForToken(token, address(SYSTEM_TOKEN), systemTokenAmount, false);
    }

    function getBnbAmountForSystemToken(uint systemTokenAmount) public view returns (uint) { 
        return getTokenAmountForSystemToken(NBU_WBNB, systemTokenAmount);
    }

    function currentBalance(address token) external view returns (uint) { 
        return IBEP20(token).balanceOf(address(this));
    }

    function isAllowedToRedeemVestingNFT(address user) public view returns (bool isAllowed, uint256 unclaimedBonus) { 
        unclaimedBonus = unclaimedSponsorBonusEquivalent[user];
        isAllowed = unclaimedBonus >= swapTokenAmountForSponsorBonusThreshold;
    }

    function _buySystemToken(address token, uint tokenAmount, uint systemTokenAmount, address systemTokenRecipient, uint stakingPoolId) private {
        stakingPools[stakingPoolId].stakeFor(systemTokenAmount, systemTokenRecipient);
        uint swapTokenAmount = getTokenAmountForToken(token, swapToken, tokenAmount, true);
        bool isFirstStaking = address(referralProgramMarketing) != address(0) && referralProgramMarketing.userPersonalTurnover(systemTokenRecipient) == 0;
        if (cashbackBonus > 0 && swapTokenAmount >= swapTokenAmountForCashbackBonusThreshold && isFirstStaking) {
            uint bonusGiveSystemToken = tokenAmount * cashbackBonus / 100;
            // NFT Smart LP
            if (token == NBU_WBNB && nftCashback.WBNB() != NBU_WBNB) {
                IWBNB(NBU_WBNB).withdraw(bonusGiveSystemToken);
                (bool success,) = address(nftCashback).call{value: bonusGiveSystemToken}(abi.encodeWithSignature("buySmartLPforBNB()"));
                require(success, "SmartLP::nftCashback purchase failed");
            } else {
                if(IBEP20(token).allowance(address(this), address(nftCashback)) < bonusGiveSystemToken) {
                    IBEP20(token).approve(address(nftCashback), type(uint256).max);
                }
                if (token == NBU_WBNB) nftCashback.buySmartLPforWBNB(bonusGiveSystemToken);
                else nftCashback.buySmartLPforToken(bonusGiveSystemToken);    // BUSD
            }
            
            uint256 nftTokenId = nftCashback.tokenCount();
            nftCashback.safeTransferFrom(address(this), systemTokenRecipient, nftTokenId);
            emit ProcessCashbackBonus(systemTokenRecipient, address(nftCashback), nftTokenId, token, bonusGiveSystemToken, block.timestamp);
        }
        userPurchases[systemTokenRecipient] += systemTokenAmount;
        userPurchasesEquivalent[systemTokenRecipient] += swapTokenAmount;

        if(allowAccuralMarketingReward && address(referralProgramMarketing) != address(0)) {
            referralProgramMarketing.updateReferralProfitAmount(systemTokenRecipient, swapTokenAmount);
        }
        emit BuySystemTokenForToken(token, stakingPoolId, tokenAmount, systemTokenAmount, swapTokenAmount, systemTokenRecipient);
        
        if (isFirstStaking) _processSponsor(systemTokenRecipient, systemTokenAmount, swapTokenAmount);
    }

    function _processSponsor(address systemTokenRecipient, uint systemTokenAmount, uint swapTokenAmount) private {
        address sponsorAddress = getUserSponsorAddress(systemTokenRecipient);
        if (sponsorAddress != address(0)) {
            unclaimedSponsorBonus[sponsorAddress] += systemTokenAmount;
            unclaimedSponsorBonusEquivalent[sponsorAddress] += swapTokenAmount;
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
        require(vestingRedeemingAllowed, "NimbusInitialAcquisition: Not allowed to redeem yet");
        require(nftVesting.ownerOf(tokenId) == msg.sender, "Not owner of vesting NFT");
        IVestingNFT.Denomination memory denomination = nftVesting.denominations(tokenId);
        nftVesting.burn(tokenId);
        TransferHelper.safeTransfer(denomination.token, msg.sender, denomination.value);
        emit VestingNFTRedeemed(address(nftVesting), tokenId, msg.sender, denomination.token, denomination.value);
    }

    //Admin functions
    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "NimbusInitialAcquisition: Can't be zero address");
        require(amount > 0, "NimbusInitialAcquisition: Should be greater than 0");
        TransferHelper.safeTransferBNB(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "NimbusInitialAcquisition: Can't be zero address");
        require(amount > 0, "NimbusInitialAcquisition: Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }

    function importUserPurchases(address user, uint amount, bool isEquivalent, bool addToExistent) external onlyOwner {
        _importUserPurchases(user, amount, isEquivalent, addToExistent);
    }

    function importUserPurchases(address[] memory users, uint[] memory amounts, bool isEquivalent, bool addToExistent) external onlyOwner {
        require(users.length == amounts.length, "NimbusInitialAcquisition: Wrong lengths");

        for (uint256 i = 0; i < users.length; i++) {
            _importUserPurchases(users[i], amounts[i], isEquivalent, addToExistent);
        }
    }

    function importSponsorBonuses(address user, uint amount, bool isEquivalent, bool addToExistent) external onlyOwner {
        _importSponsorBonuses(user, amount, isEquivalent, addToExistent);
    }

    function importSponsorBonuses(address[] memory users, uint[] memory amounts, bool isEquivalent, bool addToExistent) external onlyOwner {
        require(users.length == amounts.length, "NimbusInitialAcquisition: Wrong lengths");

        for (uint256 i = 0; i < users.length; i++) {
            _importSponsorBonuses(users[i], amounts[i], isEquivalent, addToExistent);
        }
    }

    function updateAccuralMarketingRewardAllowance(bool isAllowed) external onlyOwner {
        allowAccuralMarketingReward = isAllowed;
    }

    function updateStakingPool(uint id, address stakingPool) public onlyOwner {
        _updateStakingPool(id, stakingPool);
    }

    function updateStakingPool(uint[] memory ids, address[] memory _stakingPools) external onlyOwner {
        require(ids.length == _stakingPools.length, "NimbusInitialAcquisition: Ids and staking pools arrays have different size.");
        
        for(uint i = 0; i < ids.length; i++) {
            _updateStakingPool(ids[i], _stakingPools[i]);
        }
    }

    function updateAllowedTokens(address token, bool isAllowed) external onlyOwner {
        require (token != address(0), "NimbusInitialAcquisition: Wrong addresses");
        allowedTokens[token] = isAllowed;
        emit AllowedTokenUpdated(token, isAllowed);
    }
    
    function updateRecipient(address recipientAddress) external onlyOwner {
        require(recipientAddress != address(0), "NimbusInitialAcquisition: Address is zero");
        recipient = recipientAddress;
    } 

    function updateSponsorBonus(uint bonus) external onlyOwner {
        sponsorBonus = bonus;
    }

    function updateReferralProgramContract(address newReferralProgramContract) external onlyOwner {
        require(newReferralProgramContract != address(0), "NimbusInitialAcquisition: Address is zero");
        referralProgram = INimbusReferralProgram(newReferralProgramContract);
    }

    function updateReferralProgramMarketingContract(address newReferralProgramMarketingContract) external onlyOwner {
        require(newReferralProgramMarketingContract != address(0), "NimbusInitialAcquisition: Address is zero");
        referralProgramMarketing = INimbusReferralProgramMarketing(newReferralProgramMarketingContract);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(newSwapRouter != address(0), "NimbusInitialAcquisition: Address is zero");
        swapRouter = INimbusRouter(newSwapRouter);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "NimbusInitialAcquisition: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateNFTVestingContract(address nftVestingAddress, string memory nftUri) external onlyOwner {
        require(Address.isContract(nftVestingAddress), "NimbusInitialAcquisition: NFTVestingContractAddress is not a contract");
        nftVesting = IVestingNFT(nftVestingAddress);
        nftVestingUri = nftUri;
        emit UpdateNFTVestingContract(nftVestingAddress, nftVestingUri);
    }

    function updateNFTCashbackContract(address nftCashbackAddress) external onlyOwner {
        require(Address.isContract(nftCashbackAddress), "NimbusInitialAcquisition: NFTCashbackContractAddress is not a contract");
        nftCashback = ISmartLP(nftCashbackAddress);
        emit UpdateNFTCashbackContract(nftCashbackAddress);
    }

    function updateNFTSmartStakerContract(address nftSmartStakerAddress) external onlyOwner {
        require(Address.isContract(nftSmartStakerAddress), "NimbusInitialAcquisition: NFTSmartStakerContractAddress is not a contract");
        nftSmartStaker = IStakingMain(nftSmartStakerAddress);
        emit UpdateNFTSmartStakerContract(nftSmartStakerAddress);
    }

    function updateSwapToken(address newSwapToken) external onlyOwner {
        require(newSwapToken != address(0), "NimbusInitialAcquisition: Address is zero");
        swapToken = newSwapToken;
        emit SwapTokenUpdated(swapToken);
    }

    function updateSwapTokenAmountForSponsorBonusThreshold(uint threshold) external onlyOwner {
        swapTokenAmountForSponsorBonusThreshold = threshold;
        emit SwapTokenAmountForSponsorBonusThresholdUpdated(swapTokenAmountForSponsorBonusThreshold);
    }

    function updateSwapTokenAmountForCashbackBonusThreshold(uint threshold) external onlyOwner {
        swapTokenAmountForCashbackBonusThreshold = threshold;
        emit SwapTokenAmountForCashbackBonusThresholdUpdated(swapTokenAmountForCashbackBonusThreshold);
    }

    function toggleUsePriceFeeds() external onlyOwner {
        usePriceFeeds = !usePriceFeeds;
        emit ToggleUsePriceFeeds(usePriceFeeds);
    }

    function toggleVestingRedeemingAllowed() external onlyOwner {
        vestingRedeemingAllowed = !vestingRedeemingAllowed;
        emit ToggleVestingRedeemingAllowed(vestingRedeemingAllowed);
    }

    function _updateStakingPool(uint id, address stakingPool) private {
        require(id != 0, "NimbusInitialAcquisition: Staking pool id cant be equal to 0.");
        require(stakingPool != address(0), "NimbusInitialAcquisition: Staking pool address cant be equal to address(0).");

        stakingPools[id] = INimbusStakingPool(stakingPool);
        require(SYSTEM_TOKEN.approve(stakingPool, type(uint256).max), "NimbusInitialAcquisition: Error on approving");
    }

    function _importUserPurchases(address user, uint amount, bool isEquivalent, bool addToExistent) private {
        require(user != address(0) && amount > 0, "NimbusInitialAcquisition: Zero values");
        
        if (isEquivalent) {
            if (addToExistent) {
                userPurchasesEquivalent[user] += amount;
            } else {
                userPurchasesEquivalent[user] = amount;
            }    
        } else {
            if (addToExistent) {
                userPurchases[user] += amount;
            } else {
                userPurchases[user] = amount;
            }
        }
        emit ImportUserPurchases(user, amount, isEquivalent, addToExistent);
    }

    function _importSponsorBonuses(address user, uint amount, bool isEquivalent, bool addToExistent) private {
        require(user != address(0) && amount > 0, "NimbusInitialAcquisition: Zero values");
        
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

    function updateCashbackBonus(uint bonus) external onlyOwner {
        cashbackBonus = bonus;
        emit UpdateCashbackBonus(bonus);
    }

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
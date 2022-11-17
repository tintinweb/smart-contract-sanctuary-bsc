import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "./interfaces/IDogsExchangeHelper.sol";
import "./interfaces/IMasterchefPigs.sol";

pragma solidity ^0.8.0;


contract DogPoundAutoPool is Ownable {

    uint256 public lastPigsBalance = 0;

    uint256 public lpRoundMasktemp = 0;
    uint256 public lpRoundMask = 0;

    uint256 public totalDogsStaked = 0;
    uint256 public totalLPCollected = 0;
    uint256 public totalLpStaked = 0;
    uint256 public timeSinceLastCall = 0; 
    uint256 public updateInterval = 24 hours; 
    bool public initializeUnpaused = true;
    bool public managerNotLocked = true;
    bool public MClocked = false;

    uint256 public DOGS_BNB_MC_PID = 1;
    uint256 public BnbLiquidateThreshold = 1e18;
    uint256 public totalLPstakedTemp = 0;
    IERC20 public PigsToken = IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public DogsToken = IERC20(0x198271b868daE875bFea6e6E4045cDdA5d6B9829);
    IERC20 public Dogs_BNB_LpToken = IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);

    address public DogPoundManger = 0x6dA8227Bc7B576781ffCac69437e17b8D4F4aE41;
    IDogsExchangeHelper public DogsExchangeHelper = IDogsExchangeHelper(0xB59686fe494D1Dd6d3529Ed9df384cD208F182e8);
    IMasterchefPigs public MasterchefPigs = IMasterchefPigs(0x8536178222fC6Ec5fac49BbfeBd74CA3051c638f);
    IUniswapV2Router02 public constant PancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant busdCurrencyAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant wbnbCurrencyAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address[] public dogsBnbPath = [wbnbCurrencyAddress, address(DogsToken)];


    struct HistoryInfo {
        uint256 pps;
        uint256 rms;
    }

    struct UserInfo {
        uint256 amount;
        uint256 lpMask;
        uint256 pigsClaimedTotal;
        uint256 lastRmsClaimed;
        uint256 lpDebt;
        uint256 totalLPCollected;
        uint256 totalPigsCollected;
    }
    

    HistoryInfo[] public historyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) private initAllowed; 
    receive() external payable {}

    // Modifiers
    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    constructor(){
        timeSinceLastCall = block.timestamp;
        initAllowed[msg.sender] = true;
        initAllowed[0x47B9501674a0B01c7F3EdF91593bDfe379D73c28] = true;
    }

    function initializeVariables(DogPoundAutoPool _pool, uint256 histlen) onlyOwner public {
        require(initializeUnpaused);
        DogPoundAutoPool pool = DogPoundAutoPool(_pool);
        lpRoundMask = pool.lpRoundMask();
        lpRoundMasktemp =  pool.lpRoundMasktemp();
        totalDogsStaked =  pool.totalDogsStaked();
        timeSinceLastCall = pool.timeSinceLastCall() + 2 hours;
        for(uint i = 0; i < histlen; i++){
            if(i >= historyInfo.length){
                historyInfo.push(HistoryInfo({rms: 0, pps: 0}));
            }
            if(i > 8){
                (historyInfo[i].pps, historyInfo[i].rms) = pool.historyInfo(i+7);
            }else{
                (historyInfo[i].pps, historyInfo[i].rms) = pool.historyInfo(i);
            }

        }
    }

    function initializeU(DogPoundAutoPool _pool, address [] memory _users) public {
        require(initAllowed[msg.sender]);
        require(initializeUnpaused);
        DogPoundAutoPool pool = DogPoundAutoPool(_pool);
        for(uint i = 0; i < _users.length; i++){
            (uint256 amount, uint256 lpMask, uint256 pigsClaimedTotal,  uint256 lastRmsClaimed, uint256 lpDebt, uint256 totalLPCollectedu, uint256 totalPigsCollected ) =  pool.userInfo(_users[i]);
            userInfo[_users[i]].amount =  amount;
            userInfo[_users[i]].lpMask =  lpMask;
            userInfo[_users[i]].pigsClaimedTotal =  pigsClaimedTotal;
            userInfo[_users[i]].lastRmsClaimed =  lastRmsClaimed;
            userInfo[_users[i]].lpDebt =  lpDebt;
            userInfo[_users[i]].totalLPCollected =  totalLPCollectedu;
            userInfo[_users[i]].totalPigsCollected =totalPigsCollected;
        }
    }

    function initializeMd(address [] memory _users, UserInfo [] memory _info) onlyOwner public {
        require(initializeUnpaused);
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]] = _info[i];
        }
    }

    function initCompounders(address [] memory _users) onlyOwner public {
        require(initializeUnpaused);
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]].lastRmsClaimed = userInfo[_users[i]].lpMask;
        }    
    }

    function deposit(address _user, uint256 _amount) external onlyDogPoundManager {
        UserInfo storage user = userInfo[_user];
        if(historyInfo.length != 0 && user.amount != 0){
            claimPigsInternal(_user);
        }
        totalDogsStaked += _amount;
        if(user.amount != 0){
            user.lpDebt += pendingLpRewardsInternal(_user); 
        }
        updateUserMask(_user);
        compound();
        user.amount += _amount;
    }

    function withdraw(address _user, uint256 _amount) external onlyDogPoundManager {
        compound();
        claimLpTokensAndPigsInternal(_user);
        UserInfo storage user = userInfo[_user];
        updateUserMask(_user);
        DogsToken.transfer(address(DogPoundManger), _amount);
        user.amount -= _amount;
        totalDogsStaked -= _amount;
    }

    function updateUserMask(address _user) internal {
        userInfo[_user].lpMask = lpRoundMask;
        userInfo[_user].lastRmsClaimed = historyInfo[historyInfo.length - 1].rms;
    }

    function getPigsEarned() internal returns (uint256){
        uint256 pigsBalance = PigsToken.balanceOf(address(this));
        uint256 pigsEarned = pigsBalance - lastPigsBalance;
        lastPigsBalance = pigsBalance;
        return pigsEarned;
    }
    
    function pendingLpRewardsInternal(address _userAddress) public view returns (uint256 pendingLp){
       UserInfo storage user = userInfo[_userAddress];
        pendingLp = (user.amount * (lpRoundMask - user.lpMask))/10e18;
        return pendingLp;
    }

    function pendingLpRewards(address _userAddress) public view returns (uint256 pendingLp){
        UserInfo storage user = userInfo[_userAddress];
        pendingLp = (user.amount * (lpRoundMask - user.lpMask))/10e18;
        return pendingLp  + user.lpDebt;
    }

    function claimLpTokensAndPigsInternal(address _user) internal {
        if(historyInfo.length > 0){
            claimPigsInternal(_user);
        }
        UserInfo storage user = userInfo[_user];
        uint256 lpPending = pendingLpRewards(_user);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            handlePigsIncrease();
            Dogs_BNB_LpToken.transfer(_user, lpPending);
            user.totalLPCollected += lpPending;
            totalLPCollected += lpPending;
            user.lpDebt = 0;
            user.lpMask = lpRoundMask;
            totalLpStaked -= lpPending;
        }

    }

    function claimLpTokensAndPigs() public {
        if(historyInfo.length > 0){
            claimPigs();
        }
        UserInfo storage user = userInfo[msg.sender];
        uint256 lpPending = pendingLpRewards(msg.sender);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            user.totalLPCollected += lpPending;
            totalLPCollected += lpPending;
            handlePigsIncrease();
            Dogs_BNB_LpToken.transfer(msg.sender, lpPending);
            user.lpDebt = 0;
            user.lpMask = lpRoundMask;
            totalLpStaked -= lpPending;
        }

    }

    function claimPigsHelper(uint256 startIndex) public {
        require(historyInfo.length > 0, "No History");
        require(startIndex <= historyInfo.length - 1);
        UserInfo storage user = userInfo[msg.sender];
        uint256 pigsPending;
        uint256 newPigsClaimedTotal;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = 0;
        if(user.pigsClaimedTotal < pigsPending){
            pigsTransfered = pigsPending - user.pigsClaimedTotal;
            user.totalPigsCollected += pigsTransfered;
            lastPigsBalance -= pigsTransfered;
            PigsToken.transfer(msg.sender, pigsTransfered);
        }
        user.pigsClaimedTotal = newPigsClaimedTotal;
    }
    
    function claimPigsInternal(address _user) internal {
        require(historyInfo.length > 0, "No History");
        uint256 startIndex = historyInfo.length - 1;
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        uint256 newPigsClaimedTotal;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = 0;
        if(user.pigsClaimedTotal < pigsPending){
            pigsTransfered = pigsPending - user.pigsClaimedTotal;
            user.totalPigsCollected += pigsTransfered;
            lastPigsBalance -= pigsTransfered;
            PigsToken.transfer(_user, pigsTransfered);
        }
        user.pigsClaimedTotal = newPigsClaimedTotal;

    }
    
    function pendingPigsRewardsHelper(address _user, uint256 startIndex) view public returns(uint256) {
        require(historyInfo.length > 0, "No History");
        require(startIndex <= historyInfo.length - 1);
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(user.lastRmsClaimed > historyInfo[i - 1].rms){
                break;
            }
            if(user.lpMask > historyInfo[i - 1].rms ){
                break;
            }
            uint256 tempAmount =  (((user.amount * (historyInfo[i - 1].rms - user.lpMask))/ 10e18 + user.lpDebt) * historyInfo[i - 1].pps)/10e12;
            pigsPending += tempAmount;
        }
        if(pigsPending <= user.pigsClaimedTotal){
            return 0;
        }
        return(pigsPending - user.pigsClaimedTotal);
    }

    function pendingPigsRewards(address _user) view public returns(uint256) {
        if(historyInfo.length == 0){
            return 0;
        }
        return pendingPigsRewardsHelper(_user, historyInfo.length - 1);
    }


    function claimPigs() public {
        require(historyInfo.length > 0, "No History");
        claimPigsHelper(historyInfo.length - 1);        
    }

    function pendingRewards(address _userAddress) public view returns (uint256 _pendingPigs, uint256 _pendingLp){
        require(historyInfo.length > 0, "No History");
        uint256 pendingLp = pendingLpRewardsInternal(_userAddress);
        uint256 pendingPigs = pendingPigsRewardsHelper(_userAddress, historyInfo.length - 1);
        return (pendingPigs, pendingLp + userInfo[_userAddress].lpDebt);
    }

    function compound() public {
        
        uint256 BnbBalance = address(this).balance;
        if (BnbBalance < BnbLiquidateThreshold){
            return;
        }

        uint256 BnbBalanceHalf = BnbBalance / 2;
        uint256 BnbBalanceRemaining = BnbBalance - BnbBalanceHalf;

        // Buy Dogs with half of the BNB
        uint256 amountDogsBought = DogsExchangeHelper.buyDogsBNB{value: BnbBalanceHalf}(0, _getBestBNBDogsSwapPath(BnbBalanceHalf));


        allowanceCheckAndSet(DogsToken, address(DogsExchangeHelper), amountDogsBought);
        (
        uint256 amountLiquidity,
        uint256 unusedTokenA,
        uint256 unusedTokenB
        ) = DogsExchangeHelper.addDogsBNBLiquidity{value: BnbBalanceRemaining}(amountDogsBought);
        lpRoundMasktemp = lpRoundMasktemp + amountLiquidity;
        if(block.timestamp - timeSinceLastCall >= updateInterval){
            lpRoundMask += (lpRoundMasktemp * 10e18)/totalDogsStaked;
            timeSinceLastCall = block.timestamp;
            lpRoundMasktemp = 0;
        }
        _stakeIntoMCPigs(amountLiquidity);
    }


    function _getBestBNBDogsSwapPath(uint256 _amountBNB) internal view returns (address[] memory){

        address[] memory pathBNB_BUSD_Dogs = _createRoute3(wbnbCurrencyAddress, busdCurrencyAddress , address(DogsToken));

        uint256[] memory amountOutBNB = PancakeRouter.getAmountsOut(_amountBNB, dogsBnbPath);
        uint256[] memory amountOutBNBviaBUSD = PancakeRouter.getAmountsOut(_amountBNB, pathBNB_BUSD_Dogs);

        if (amountOutBNB[amountOutBNB.length -1] > amountOutBNBviaBUSD[amountOutBNBviaBUSD.length - 1]){ 
            return dogsBnbPath;
        }
        return pathBNB_BUSD_Dogs;

    }

    function _createRoute3(address _from, address _mid, address _to) internal pure returns(address[] memory){
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = _mid;
        path[2] = _to;
        return path;
    }

    function handlePigsIncrease() internal {
        uint256 pigsEarned = getPigsEarned();
        if(historyInfo.length > 0 && historyInfo[historyInfo.length - 1].rms == lpRoundMask){
            historyInfo[historyInfo.length - 1].pps += (pigsEarned * 10e12)/totalLPstakedTemp;
        }else{
            historyInfo.push(HistoryInfo({rms: lpRoundMask, pps: (pigsEarned * 10e12)/totalLpStaked}));
            totalLPstakedTemp = totalLpStaked;
        }
    }

    function increasePigsBuffer(uint256 quant) public onlyOwner{
        PigsToken.transferFrom(msg.sender, address(this), quant);
        lastPigsBalance += quant;
    }

    function _stakeIntoMCPigs(uint256 _amountLP) internal {
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), _amountLP);
        MasterchefPigs.deposit(DOGS_BNB_MC_PID, _amountLP);
        totalLpStaked += _amountLP;
        handlePigsIncrease();
    }

    function allowanceCheckAndSet(IERC20 _token, address _spender, uint256 _amount) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _amount) {
            require(_token.approve(_spender, _amount), "allowance err");
        }
    }

    function initMCStake() public onlyOwner{
        require(initializeUnpaused);
        lastPigsBalance = PigsToken.balanceOf(address(this));
        uint256 balance = IERC20(Dogs_BNB_LpToken).balanceOf(address(this));
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), balance);
        totalLPstakedTemp = ( balance - lpRoundMasktemp ) * 998 / 1000;
        allowanceCheckAndSet(IERC20(Dogs_BNB_LpToken), address(MasterchefPigs), balance);
        MasterchefPigs.deposit(DOGS_BNB_MC_PID, balance);
        totalLpStaked += (balance * 998) / 1000;
        handlePigsIncrease();    
    }
    
    function initStakeMult(uint256 temp1, uint256 temp2) public onlyOwner{
        require(initializeUnpaused);
        totalLPstakedTemp = temp1;
        totalLpStaked = temp2;
    }

    function addInitAllowed(address _ad, bool _bool) public onlyOwner{
        initAllowed[_ad] = _bool;
    }

    function updateBnbLiqThreshhold(uint256 newThrehshold) public onlyOwner {
        BnbLiquidateThreshold = newThrehshold;
    }

    function updateDogsBnBPID(uint256 newPid) public onlyOwner {
        DOGS_BNB_MC_PID = newPid;
    }

    function pauseInitialize() external onlyOwner {
        initializeUnpaused = false;
    }

    function updateDogsAndLPAddress(address _addressDogs, address _addressLpBNB) public onlyOwner {
        Dogs_BNB_LpToken = IERC20(_addressLpBNB);
        updateDogsAddress(_addressDogs);
    }

   function updateDogsAddress(address _address) public onlyOwner {
        DogsToken = IERC20(_address);
        dogsBnbPath = [wbnbCurrencyAddress,address(DogsToken)];
    }

    function updatePigsAddress(address _address) public onlyOwner {
        PigsToken = IERC20(_address);
    }
    
    function allowCompound(uint256 _time) public onlyOwner{
        require(_time <= timeSinceLastCall, "time in future");
        timeSinceLastCall = _time;
    }

    function updateDogsExchanceHelperAddress(address _address) public onlyOwner {
        DogsExchangeHelper = IDogsExchangeHelper(_address);
    }

    function updateMasterchefPigsAddress(address _address) public onlyOwner {
        require(!MClocked);
        MasterchefPigs = IMasterchefPigs(_address);
    }

    function changeUpdateInterval(uint256 _time) public onlyOwner{
        updateInterval = _time;
    }

    function MClockedAddress() external onlyOwner{
        MClocked = true;
    }

    function lockDogPoundManager() external onlyOwner{
        managerNotLocked = false;
    }

    function setDogPoundManager(address _address) public onlyOwner {
        require(managerNotLocked);
        DogPoundManger = _address;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDogsExchangeHelper {
    function addDogsBNBLiquidity(uint256 nativeAmount) external payable returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function addDogsLiquidity(address baseTokenAddress, uint256 baseAmount, uint256 dogsAmount) external returns (uint256 lpAmount, uint256 unusedEth, uint256 unusedToken);
    function buyDogsBNB(uint256 _minAmountOut, address[] memory _path) external payable returns(uint256 amountDogsBought);
    function buyDogs(uint256 _tokenAmount, uint256 _minAmountOut, address[] memory _path) external returns(uint256 amountDogsBought);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMasterchefPigs {
    function deposit(uint256 _pid, uint256 _amount) external;
    function pendingPigs(uint256 _pid, address _user) external view returns (uint256);
    function depositMigrator(address _userAddress, uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
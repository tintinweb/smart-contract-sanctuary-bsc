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


    uint256 public DOGS_BNB_MC_PID = 1;
    uint256 public BnbLiquidateThreshold = 1e18;

    IERC20 public PigsToken = IERC20(0x9a3321E1aCD3B9F6debEE5e042dD2411A1742002);
    IERC20 public DogsToken = IERC20(0x198271b868daE875bFea6e6E4045cDdA5d6B9829);
    IERC20 public Dogs_BNB_LpToken = IERC20(0x2139C481d4f31dD03F924B6e87191E15A33Bf8B4);

    address public DogPoundManger;
    IDogsExchangeHelper public DogsExchangeHelper;
    IMasterchefPigs public MasterchefPigs;
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

    receive() external payable {}

    // Modifiers
    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    constructor(address _DogPoundManger, IDogsExchangeHelper _dogsExchangeHelper, IMasterchefPigs _masterchefPigs){
        DogPoundManger = _DogPoundManger;
        DogsExchangeHelper = _dogsExchangeHelper;
        MasterchefPigs = _masterchefPigs;
        timeSinceLastCall = block.timestamp;
    }

    function deposit(address _user, uint256 _amount) external onlyDogPoundManager {
        if(historyInfo.length != 0){
            claimPigs();
        }
        totalDogsStaked += _amount;
        compound();
        UserInfo storage user = userInfo[_user];
        if(user.lpMask != 0){
            user.lpDebt += pendingLpRewardsInternal(_user); 
        }
        updateUserMask(_user);
        user.lastRmsClaimed = lpRoundMask;
        user.amount += _amount;
    }

    function withdraw(address _user, uint256 _amount) external onlyDogPoundManager {
        compound();
        claimLpTokensAndPigsInternal(_user);
        UserInfo storage user = userInfo[_user];
        updateUserMask(_user);
        DogsToken.transfer(address(DogPoundManger), _amount); // must handle receiving in DogPoundManger
        user.amount -= _amount;
        totalDogsStaked -= _amount;
    }

    function updateUserMask(address _user) internal {

        userInfo[_user].lpMask = lpRoundMask;

    }

    function getPigsEarned() public returns (uint256){
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
        uint256 lpPendingInternal = pendingLpRewardsInternal(_user);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            handlePigsIncrease();
            Dogs_BNB_LpToken.transfer(_user, lpPending);
            user.totalLPCollected += lpPending;
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
        uint256 lpPendingInternal = pendingLpRewardsInternal(msg.sender);

        if (lpPending > 0){
            MasterchefPigs.withdraw(DOGS_BNB_MC_PID, lpPending);
            user.totalLPCollected += lpPending;
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
            if(historyInfo[i - 1].rms < user.lastRmsClaimed){
                break;
            }
            uint256 tempAmount =  (((user.amount * (lpRoundMask - historyInfo[i - 1].rms))/ 10e18) * historyInfo[i - 1].pps)/10e18;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = pigsPending - user.pigsClaimedTotal;
        user.totalPigsCollected += pigsTransfered;
        lastPigsBalance -= pigsTransfered;
        PigsToken.transfer(msg.sender, pigsTransfered);
        user.pigsClaimedTotal = newPigsClaimedTotal;
        
    }
    
    function claimPigsInternal(address _user) internal {
        require(historyInfo.length > 0, "No History");
        uint256 startIndex = historyInfo.length - 1;
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        uint256 newPigsClaimedTotal;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(historyInfo[i - 1].rms < user.lastRmsClaimed){
                break;
            }
            uint256 tempAmount =  (((user.amount * (lpRoundMask - historyInfo[i - 1].rms))/ 10e18) * historyInfo[i - 1].pps)/10e18;
            pigsPending += tempAmount;
            if(i - 1 == startIndex){
                newPigsClaimedTotal = tempAmount;
            }
        }
        user.lastRmsClaimed = historyInfo[startIndex].rms;
        uint256 pigsTransfered = pigsPending - user.pigsClaimedTotal;
        user.totalPigsCollected += pigsTransfered;
        lastPigsBalance -= pigsTransfered;
        PigsToken.transfer(_user, pigsTransfered);
        user.pigsClaimedTotal = newPigsClaimedTotal;

    }
    
    
    function pendingPigsRewardsHelper(address _user, uint256 startIndex) view public returns(uint256) {
        require(historyInfo.length > 0, "No History");
        require(startIndex <= historyInfo.length - 1);
        UserInfo storage user = userInfo[_user];
        uint256 pigsPending;
        for(uint256 i = startIndex + 1; i > 0; i--){
            if(historyInfo[i - 1].rms < user.lastRmsClaimed){
                break;
            }
            uint256 tempAmount =  (((user.amount * (lpRoundMask - historyInfo[i - 1].rms))/ 10e18) * historyInfo[i - 1].pps)/10e18;
            pigsPending += tempAmount;
        }
        if(pigsPending < user.pigsClaimedTotal){
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
        _stakeIntoMCPigs(amountLiquidity);
        lpRoundMasktemp = lpRoundMasktemp + amountLiquidity;
        if(block.timestamp - timeSinceLastCall >= updateInterval){
            lpRoundMask += (lpRoundMasktemp * 10e18)/totalDogsStaked;
            timeSinceLastCall = block.timestamp;
            lpRoundMasktemp = 0;
        }
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
        if(pigsEarned > 0){
            if(historyInfo.length > 0 && historyInfo[historyInfo.length - 1].rms == lpRoundMask){
                historyInfo[historyInfo.length - 1].pps += (pigsEarned * 10e12)/totalLpStaked;
            }else{
                historyInfo.push(HistoryInfo({rms: lpRoundMask, pps: (pigsEarned * 10e12)/totalLpStaked}));
            }
        }
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

    function updateBnbLiqThreshhold(uint256 newThrehshold) public onlyOwner {
        BnbLiquidateThreshold = newThrehshold;
    }

    function updateDogsBnBPID(uint256 newPid) public onlyOwner {
        DOGS_BNB_MC_PID = newPid;
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

    function updateDogsExchanceHelperAddress(address _address) public onlyOwner {
        DogsExchangeHelper = IDogsExchangeHelper(_address);
    }

    function updateMasterchefPigsAddress(address _address) public onlyOwner {
        MasterchefPigs = IMasterchefPigs(_address);
    }

    function setDogPoundManager(address _address) public onlyOwner {
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
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable , Pausable , ReentrancyGuard {
    
    address public rewardToken;
    address private HESTTOKEN;

    address public supply; //51
    address public team; //1
    address public partner; //9
    address public digitHolder; //39
    
    uint256 public supply_cent = 51; //51
    uint256 public team_cent = 1; //1
    uint256 public partner_cent = 9; //9
    uint256 public digitHolder_cent = 39; //39

    uint256 public lastinitTime;
    uint256 public blocksPerMonth = 720; //864000;
    uint256 public blocksPerday = 24; //28800;
    uint256 public daysPerMonth = 30;
    uint256 public currentPool = 0;

    address public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    uint256[][] private userPools;

    struct Pool{
        uint8 id;
        uint256 totalstaked;
        uint256 rewardTokenValue;
        uint256 min;
        uint256 max;
        uint256 noOfusers;
        uint256 creationTime;
        uint8 cent;
    }mapping(uint8 => mapping(uint256 => Pool)) public pool;



    struct StakeInfo{
        uint256 staked;
        uint256 reward;
        uint256 enteryTime;
        uint256 depositBlock;
        uint256 pendingRewards;
    }mapping(address => mapping(uint256 =>mapping(uint256 => StakeInfo))) public stakeInfo;

    struct StakeSnapshot{
        uint256 staked;
        uint256 enteryTime;
        uint256 depositBlock;
    }mapping(address => mapping(uint256  => StakeSnapshot)) public stakeSnapshot;

    

    struct DepositInfo{
        uint256 amount;
        uint256 supplyAmount;
        uint256 partnerAmount;
        uint256 teamAmount;
        uint256 digitAmount;
        uint256 enteryTime;
    }mapping(uint256 => DepositInfo) public depositInfo;



    mapping(address => uint256) public stakedBalance;

    constructor(address _supply , address _partner , address _team){
        supply = _supply;
        partner = _partner;
        team = _team;
    }

    
    function setRewardTokenAddress(address _token) public onlyOwner { 

        require(_token != address(0),"invalid address");
        require(getPair(HESTTOKEN  , _token) != address(0) ,"the pair doesnt exist");
        
        if(rewardToken != address(0)){
        uint256 balanceOf = IERC20(rewardToken).balanceOf(address(this));
        uint256 allowance = IERC20(_token).allowance(owner(),address(this));
        require(allowance / IERC20Metadata(_token).decimals() >= balanceOf / IERC20Metadata(rewardToken).decimals() , 
        "please provide exact amount");
        IERC20(rewardToken).transfer( owner() , balanceOf);
        IERC20(_token).transferFrom( owner() , address(this) , allowance);
        }
        rewardToken = _token;
    }



    function setHESTAddress(address _HESTTOKEN) public onlyOwner {
        require(_HESTTOKEN != address(0));
        HESTTOKEN = _HESTTOKEN;
    }

    function setTeamAddress(address _team) public onlyOwner {
        require(_team != address(0));
        team = _team;
    }

    function setPartnerAddress(address _partner) public onlyOwner {
        require(_partner != address(0));
        partner = _partner;
    }

    function set_supplycent(uint256 _cent) public onlyOwner {
        require(_cent != 0 && _cent + team_cent + partner_cent + digitHolder_cent <= 100, "invalid uint256");
        supply_cent = _cent;
    }

    function set_teamcent(uint256 _cent) public onlyOwner {
        require(_cent != 0 && _cent + supply_cent + partner_cent + digitHolder_cent <= 100,"invalid uint256");
        team_cent = _cent;
    }
    function set_partnercent(uint256 _cent) public onlyOwner {
        require(_cent != 0 && _cent + team_cent + supply_cent + digitHolder_cent <= 100,"invalid uint256");
        partner_cent = _cent;
    }
    function set_digiholdercent(uint256 _cent) public onlyOwner {
        require(_cent != 0 && _cent + team_cent + partner_cent + supply_cent <= 100,"invalid address");
        digitHolder_cent = _cent;
    }

    function setRouterAddress(address newRouter) public onlyOwner() {
       //Thank you FreezyEx
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        // Create a uniswap pair for this new token
        // uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(rewardToken,HESTTOKEN);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }

    function initiatePools(uint8[8] memory percentages , uint256[8] memory min , uint256[8] memory max) public onlyOwner{
        
        require(block.number > lastinitTime + blocksPerMonth , "connot initiate pools before one month");
        require(percentages.length == min.length && min.length == max.length && max.length == 8,"initialing error :: values");
        uint8 i;
        currentPool++;
        for(i=1; i<9; i++){

        require(percentages[i-1] <= 92,"decimals not allowed");

        pool[i][currentPool].cent = percentages[i-1];
        
        pool[i][currentPool].min = min[i-1] * 10 **IERC20Metadata(HESTTOKEN).decimals();
        pool[i][currentPool].max = max[i-1] * 10 **IERC20Metadata(HESTTOKEN).decimals();
        pool[i][currentPool].creationTime = block.number;
       
        }
       
        lastinitTime = block.number;
    }

    function calcRewards(address account , uint8 _id ,uint256 _Poolno) public view returns (uint256) { // remaining
        
        StakeInfo memory detail = stakeInfo[account][_id][_Poolno];
        uint256 currentblock = block.number;
       
        uint256 depositBlock = detail.depositBlock;
        // new
        uint256 blocks = currentblock - depositBlock;



       

        if(depositBlock == 0)
        return 0;
       
        if(blocks < blocksPerday)
        return 0;

        if(blocks > blocksPerMonth){
             unchecked {
                if(blocksPerMonth + pool[_id][_Poolno].creationTime > depositBlock){
                 blocks = ( blocksPerMonth + pool[_id][_Poolno].creationTime ) - depositBlock;
                }else{
                    return 0;
                }
            }
        }
        
        
        
        uint256 userShare = detail.staked;
       // console.log("contract :: userShare",userShare);
        uint256 totalStaked = pool[_id][_Poolno].totalstaked ;
       // console.log("contract :: totalStaked",totalStaked);
        uint256 totalReceived = pool[_id][_Poolno].rewardTokenValue ;
       // console.log("contract :: totalReceived",totalReceived);
        uint256 apyRevenue = (totalReceived * userShare) / totalStaked;
       // console.log("contract :: apyRevenue",apyRevenue);

        
       // (totalReceived * _shares[account]) / _totalShares
        if(apyRevenue == 0 ){
                return (0);
        }else {
        uint256 ratePerDay = ( apyRevenue ) / 30 ;
        return   ( blocks / blocksPerday ) * ratePerDay ;
        
        }

    }

    function calculator(uint256 amount , uint8 _id ,uint256 _Poolno) public view returns (uint256) { // remaining
        
        //StakeInfo memory detail = stakeInfo[account][_id][_Poolno];
        Pool memory detail = pool[_id][_Poolno];
        uint256 currentblock = block.number;
        uint256 totalBlocks = detail.creationTime + blocksPerMonth;
        // new
      
        uint256 blocks = 0;
        if(currentblock < totalBlocks)
        blocks = totalBlocks - currentblock;
      
       
        if(blocks < blocksPerday)
        return 0;
    
        uint256 userShare = amount;
     
        uint256 totalStaked = pool[_id][_Poolno].totalstaked + amount ;
        
       
        uint256 totalReceived = pool[_id][_Poolno].rewardTokenValue ;
       
        uint256 apyRevenue = (totalReceived * userShare) / totalStaked;
     

        
       // (totalReceived * _shares[account]) / _totalShares
        if(apyRevenue == 0 ){
                return (0);
        }else {
        uint256 ratePerDay = ( apyRevenue ) / 30 ;
        return   ( blocks / blocksPerday ) * ratePerDay ;
        
        }

    }

    function getPair(address token0,address token1) public view returns(address){
        return IUniswapV2Factory(uniswapV2Router.factory()).getPair(token0,token1);
    }

    function totalReward(address account , uint8 _id , uint256 _Poolno , uint256 _currentPool) public view returns(uint256) {
        return stakeInfo[account][_id][_Poolno].pendingRewards + calcRewards(account , _id , _Poolno) ; 
    }

    
    
    function withdrawRewards(address account , uint8 _id , uint256 _Poolno ) public {

        if (_Poolno == currentPool){

        require(block.number > pool[_id][_Poolno].creationTime + blocksPerMonth , "connot withdraw reward now");

        }
        uint256 amount = totalReward( account , _id , _Poolno , currentPool );

        require(amount > 0 , "no rewards pending");

        

        stakeInfo[account][_id][_Poolno].pendingRewards = 0 ; 
        stakeInfo[account][_id][_Poolno].depositBlock = 0 ;

        

        IERC20(rewardToken).transfer( account , amount);
        IERC20(HESTTOKEN).transfer( account , stakeInfo[account][_id][_Poolno].staked);

        stakeInfo[account][_id][_Poolno].staked = 0;
        
    }

  
    function clubRewards(address account , bool send , uint8[] memory _ids) public {
        uint256 amount = 0 ;
        uint256 HestAmount = 0 ;
        for (uint256 index = 1; index < currentPool; index++) {
            for (uint8 _Poolno = 1; _Poolno < 9; _Poolno++) {

                uint256 tempAmount = totalReward( account , _Poolno , index  ,_Poolno);

                if(tempAmount == 0)
                continue;


                amount += tempAmount;
                
                HestAmount += stakeInfo[account][_Poolno][index].staked ; // for development 
                stakeInfo[account][_Poolno][index].staked = 0; // for development 

                stakeInfo[account][_Poolno][index].pendingRewards = 0 ; 
                stakeInfo[account][_Poolno][index].depositBlock = 0 ;
            }
        }

        require(amount > 0 , "cannot withdraw rewards before 1 month");


     

        if(send){
            IERC20(rewardToken).transfer(account , amount);
        }else{
            uint256[] memory outAmount = swapTokensForTokens(amount,address(this));
            // console.log("Contract :: inAmount", outAmount[0]);
            // console.log("Contract :: outAmount", outAmount[1]);
            // IERC20(HESTTOKEN).transfer(account , HestAmount);    // for development
            uint256 total = HestAmount + outAmount[1];
            // console.log("Contract :: per1 total hest ", total);
            for (uint8 index = 0; index < _ids.length; index++) {      

                uint256 result = localStake(total , _ids[index]);
                total = result;
            

            } 
            if(total > 0 ){
                IERC20(HESTTOKEN).transfer(account , amount);
            }
        }
        

    }

    function saveRewards(address account , uint8 _id , uint256 _Poolno ) private {
        stakeInfo[account][_id][_Poolno].depositBlock = block.number;
        stakeInfo[account][_id][_Poolno].pendingRewards += calcRewards(account ,_id ,_Poolno);
    }

    function localStake(uint256 amount , uint8 _id ) private returns(uint256){
        require(block.number < lastinitTime + blocksPerMonth , "No Pools active");
     
        if(pool[_id][currentPool].min < amount){
          
            StakeInfo memory detail = stakeInfo[_msgSender()][_id][currentPool];
            if(detail.staked > 0){ // many times 
          
                //save rewards
                saveRewards(_msgSender(),_id ,currentPool);
                 stakeSnapshot[_msgSender()][currentPool].enteryTime += block.timestamp;

                
            }else{                                    
                        // first time
                pool[_id][currentPool].noOfusers++;
                detail.enteryTime = block.number;
                detail.depositBlock = block.number;
                
            // userPools.push([currentPool,_id]);
            }

            uint256 result = 0; 
            uint256 difference =0;
         
            if(pool[_id][currentPool].max < amount){
           
            difference = pool[_id][currentPool].max -  detail.staked ;
            detail.staked += difference;

            stakeSnapshot[_msgSender()][currentPool].staked += difference;
            stakeSnapshot[_msgSender()][currentPool].depositBlock += block.timestamp;
            
            pool[_id][currentPool].totalstaked += difference;
            result =  amount - difference;

            }else if(pool[_id][currentPool].min < amount){
    
             detail.staked += amount;
             pool[_id][currentPool].totalstaked += amount;
             result = 0; 
            }
           
            stakeInfo[_msgSender()][_id][currentPool] =  detail;
            
            return result;
        }else{
           
            return amount;
        }
      
    } 

    function timeRequirement() public view returns(bool condition){
        condition = false;
        if(block.number < lastinitTime + blocksPerMonth){
            condition = true;
        }
    }

    function stake(uint8 _id) public {

        uint256 amount = IERC20(HESTTOKEN).allowance(_msgSender() , address(this));
        uint256 amountStked = stakeInfo[_msgSender()][_id][currentPool].staked + amount;


        require(amountStked >= pool[_id][currentPool].min && amountStked <= pool[_id][currentPool].max,"please provide with respect to pool");
        require(timeRequirement() , "pools period expired");

        IERC20(HESTTOKEN).transferFrom(
        _msgSender(),
        address(this),
        amount
        );

        StakeInfo memory detail = stakeInfo[_msgSender()][_id][currentPool];


        if(detail.staked > 0){ // many times 
            //save rewards
            saveRewards(_msgSender(),_id ,currentPool);
        }else{     
            //first time
            pool[_id][currentPool].noOfusers++;
            detail.enteryTime = block.number;
            detail.depositBlock = block.number;
            stakeSnapshot[_msgSender()][currentPool].enteryTime += block.timestamp;

            //userPools.push([currentPool,_id]);
        }

        stakeSnapshot[_msgSender()][currentPool].staked += amount;
        stakeSnapshot[_msgSender()][currentPool].depositBlock += block.timestamp;

        detail.staked += amount;

        pool[_id][currentPool].totalstaked +=amount;

 
        

        stakeInfo[_msgSender()][_id][currentPool] =  detail;

    }

    

    function unStake(uint8 _id ,uint8 _Poolno , uint256 amount) public { //poolno ~ cuurentpool

        require(stakeInfo[_msgSender()][_id][_Poolno].staked >= amount ,"please unstake in correct amount");

        IERC20(HESTTOKEN).transfer(
        _msgSender(),
        amount
        );

        saveRewards(_msgSender(),_id ,_Poolno);

        if(stakeInfo[_msgSender()][_id][_Poolno].staked - amount == 0){
            pool[_id][currentPool].noOfusers--;
        }

        stakeInfo[_msgSender()][_id][_Poolno].staked -= amount;

    }



    function addRewardToken(uint256 amount)public onlyOwner {

        require(amount >= 100 *10**IERC20Metadata(rewardToken).decimals(),"please provide atleast 100 Reward token");
        require(IERC20(rewardToken).allowance(owner() , address(this)) >= amount ,"please approve Reward token");
        require(block.number < lastinitTime + blocksPerMonth , "pools period expired");
        
        uint256 _supplyAmount =  (amount/100)*supply_cent;
        uint256 _partnerAmount = (amount/100)*partner_cent;
        uint256 _teamAmount = (amount/100)*team_cent;
        uint256 _digiholderAmount = (amount/100)*digitHolder_cent;


        
        IERC20(rewardToken).transferFrom(
        owner(),
        address(this),
        amount
        );

        IERC20(rewardToken).transfer(
        supply,
        _supplyAmount
        );
        IERC20(rewardToken).transfer(
        partner,
        _partnerAmount
        );
        IERC20(rewardToken).transfer(
        team,
        _teamAmount
        );

        depositInfo[currentPool] = DepositInfo(
               amount,
        _supplyAmount,
        _partnerAmount,
        _teamAmount,
        _digiholderAmount,
        block.timestamp
        );

        uint8 i;

        for(i=1; i<9; i++){

            require(pool[i][currentPool].cent >= 1,"please initiate pool first");
            pool[i][currentPool].rewardTokenValue = (_digiholderAmount/100) * pool[i][currentPool].cent;
        
        }

    }


    function addLiquidity(address _token) public {  // only for development Reward token / HESTTOKEN

     IERC20(_token).approve(address(uniswapV2Router), IERC20(_token).balanceOf(address(this)));
     IERC20(HESTTOKEN).approve(address(uniswapV2Router), IERC20(HESTTOKEN).balanceOf(address(this)));
     uniswapV2Router.addLiquidity(_token , HESTTOKEN , IERC20(_token).balanceOf(address(this)) , IERC20(HESTTOKEN).balanceOf(address(this)) , 0 , 0 , _msgSender() , block.timestamp);

    }

    function swapTokensForTokens(
        uint256 tokenAmount,
        address outputAddress
    ) private returns(uint[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = rewardToken;
       // path[1] = uniswapV2Router.WETH();
        path[1] = HESTTOKEN;

        IERC20(rewardToken).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        amounts = uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0,
            path,
            outputAddress,
            block.timestamp
        );
    }
    
}



// todo :

// 1 . enumeration 
// 2 . unstake
// 3 . stablecoin change
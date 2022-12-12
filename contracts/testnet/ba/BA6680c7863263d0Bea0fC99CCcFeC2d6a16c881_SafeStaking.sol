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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IPancakeRouter02.sol";
contract SafeStaking  is Ownable{
    address public flashTokenContract; // flash token contract address
    address public pancakeSwapContract; // pancakeswap router contract address
    
    // amt of cxses staked by an address
    struct Position {
        uint256 positionId;
        address walletAddress;
        uint256 createdDate;
        uint256 unlockDate;
        uint256 percentInterest;
        uint256 weiStaked;
        uint256 weiInterest;
        bool open;
    }

    uint256 public currentPositionId;
    mapping(uint256 => Position) public positions;
    mapping(address => uint[]) public positionIdsByAddress;
    mapping(uint256 => uint256) public tiers;
    uint256[] public lockPeriods;

    
    constructor(){
        currentPositionId = 0;
    }

    
    // get Amount of flash when user send other token

    function getAmountOfFlashToken (address _tokenAddress,uint256 _amount) public view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = flashTokenContract;
        uint256 amoutOut = IPancakeRouter02(pancakeSwapContract).getAmountsOut(_amount,path)[1];
        uint256 amoutMinout = amoutOut*(1000-5)/1000; //slipage 0.5%
        return amoutMinout;
    }
    
    function swapTokenToFlash (address _tokenAddress, uint256 _amount) internal returns(uint256) {
        uint256 allowance = IERC20(_tokenAddress).allowance(msg.sender,address(this));
        require(allowance >= _amount,"Allowance Error");
        require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount),"dont send token");
        require(address(flashTokenContract) != address(0),"flash  address is zero");
       
        if(address(_tokenAddress)==address(flashTokenContract)){
            return _amount;
        }else{
             uint256[] memory retAmounts=_convertTokenToFlash(_amount, _tokenAddress);
             return retAmounts[1];
        }
    }
    function swapBNBToFlash (uint256 _amount) public payable returns(uint256) {
        require(msg.value>0,"bnb is zero");
        require(_amount ==msg.value ,"amount must be same with value");
        uint256[] memory retAmounts= _convertBnbToFlash(_amount);
        return retAmounts[1];
    }
    

    // convert bnb to flash token using pancake swap router
    function _convertBnbToFlash(uint256 _amount) public payable returns(uint256[] memory){
        require(flashTokenContract != address(0),"FlashTokenContract is zero");
        require(address(pancakeSwapContract)!= address(0),"Invalid Pancakeswap");
        address[] memory path = new address[](2);
         path[0] = IPancakeRouter02(pancakeSwapContract).WETH();  
         path[1] = address(flashTokenContract);
         require(IERC20(path[0]).approve(address(pancakeSwapContract), _amount),"approve failed");
          uint256 amoutOut = IPancakeRouter02(pancakeSwapContract).getAmountsOut(_amount,path)[1];
          uint256 amoutMinout = amoutOut*(1000-5)/1000; //slipage 0.5%
          uint256[] memory retAmounts=IPancakeRouter02(pancakeSwapContract).swapExactETHForTokens{value:msg.value}(amoutMinout,path,address(this),block.timestamp);
          return retAmounts;
    }

    // convert token to flash token using pancake swap router
    function _convertTokenToFlash(uint256 _amount, address _tokenAddress) internal returns(uint256[] memory){
        require(flashTokenContract != address(0),"FlashTokenContract is zero");
        require(address(pancakeSwapContract)!= address(0),"Invalid Pancakeswap");
        address[] memory path = new address[](2);
        path[0] = address(_tokenAddress);
        path[1] = address(flashTokenContract);
        uint256 amoutOut = IPancakeRouter02(pancakeSwapContract).getAmountsOut(_amount,path)[1];
        uint256 amoutMinout = amoutOut*(1000-5)/1000; //slipage 0.5%
        uint256[] memory retAmounts=IPancakeRouter02(pancakeSwapContract).swapExactTokensForTokens(_amount,amoutMinout,path,address(this),block.timestamp);
        return retAmounts;
    }

    
    // num of days staked for 

    function stakeBNB (uint256 numDays) external payable {
        require(tiers[numDays] > 0, "Mapping not found");
        uint256 amount = swapBNBToFlash(msg.value);
        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp+(numDays * 15180),
            tiers[numDays],
            amount,
            calculateInterest(tiers[numDays], amount),
            true
        );
        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId++;
    }
    
    function stakeToken (address _tokenAddress,uint256 _amount,uint256 numDays) external  {
        require(tiers[numDays] > 0, "Mapping not found");
        uint256 amount = swapTokenToFlash(_tokenAddress,_amount);
        uint256 date =numDays*1 seconds;
        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp+date,
            tiers[numDays],
            amount,
            calculateInterest(tiers[numDays], amount),
            true
        );
        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId++;
    }

    function calculateInterest(uint256 basisPoints, uint256 weiAmount) private pure returns (uint256) {
        return basisPoints * weiAmount /10000;
    }

    function modifyLockPeriods( uint256 numDays, uint256 basisPoints) external onlyOwner {
        tiers[numDays] = basisPoints;
        lockPeriods.push(numDays);
    }

    function getLockPeriods() external view returns (uint256[] memory) {
        return lockPeriods;
    }

    function getInterestRate( uint256 numDays)  external view returns (uint256){
        return tiers[numDays];
    }

    function getPositionById ( uint256 positionId) external view returns (Position memory) {
        return positions[positionId];
    }

    function getPositionIdsForAddress(address walletAddress) external view returns (uint256[] memory) {
        return positionIdsByAddress[walletAddress];
    }

    function closePosition (uint256 positionId) external {
        require(positions[positionId].walletAddress ==  msg.sender, "Only position creator can modify the position");
        require(positions[positionId].open ==  true ,"Position is closed");
        require(address(flashTokenContract) != address(0),"Invalid flash token");
        require(block.timestamp >= positions[positionId].unlockDate,"Not EndDay");
        positions[positionId].open = false;
        uint256 amount = positions[positionId].weiStaked + positions[positionId].weiInterest;
        require(IERC20(flashTokenContract).approve(address(this),amount),"Dont approve");
        require(IERC20(flashTokenContract).transferFrom(address(this),msg.sender,amount),"Dont send flashToken");
    }
    function setFlashTokenContract (address _tokenAddress)  public onlyOwner {
        require(address(_tokenAddress) != address(0),"Invalid address");
        flashTokenContract = _tokenAddress;
    }

    function setPancakeRouterContract (address _pancake) public onlyOwner{
        require(address(_pancake) != address(0),"Invalid address");
        pancakeSwapContract = _pancake;
    }
    
}
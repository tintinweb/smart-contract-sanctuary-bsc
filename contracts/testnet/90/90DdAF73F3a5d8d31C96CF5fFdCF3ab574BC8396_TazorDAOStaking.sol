/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

    interface IUniswapV2Pair {
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

// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    // Only used in the  BondingCalculator.sol
    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

}

interface IOwnable {
  function policy() external view returns (address);

  function renounceManagement() external;
  
  function pushManagement( address newOwner_ ) external;
  
  function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}


// File contracts/interfaces/IERC20.sol

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


// File contracts/libraries/SafeERC20.sol

pragma solidity >=0.7.5;

/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}


// File contracts/interfaces/IsOHM.sol


interface IsOHM is IERC20 {
    function rebase( uint256 ohmProfit_, uint epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance( uint amount ) external view returns ( uint );

    function balanceForGons( uint gons ) external view returns ( uint );

    function index() external view returns ( uint );

    function toG(uint amount) external view returns (uint);

    function fromG(uint amount) external view returns (uint);

     function changeDebt(
        uint256 amount,
        address debtor,
        bool add
    ) external;

    function debtBalances(address _address) external view returns (uint256);

}


// File contracts/interfaces/IgOHM.sol


interface IgOHM is IERC20 {
  function mint(address _to, uint256 _amount) external;

  function burn(address _from, uint256 _amount) external;

  function index() external view returns (uint256);

  function balanceFrom(uint256 _amount) external view returns (uint256);

  function balanceTo(uint256 _amount) external view returns (uint256);

  function migrate( address _staking, address _sOHM ) external;
}


// TAZ token interface.

interface ITAZ is IERC20{
  function mint(address _to, uint256 _amount) external;

  function burn(uint256 _amount) external;

  function balanceFrom(uint256 _amount) external view returns (uint256);

  function balanceTo(uint256 _amount) external view returns (uint256);

//   function safeTransferFrom(address sender, address receipient, uint256 amount) external returns (bool) ;

//   function safeTransfer(address receipient, uint256 amount) external returns (bool);
}



// File contracts/interfaces/IDistributor.sol

interface IDistributor {
    function distribute() external;

    function bounty() external view returns (uint256);

    function retrieveBounty() external returns (uint256);

    function nextRewardAt(uint256 _rate) external view returns (uint256);

    function nextRewardFor(address _recipient) external view returns (uint256);

    function setBounty(uint256 _bounty) external;

    function addRecipient(address _recipient, uint256 _rewardRate) external;

    function removeRecipient(uint256 _index) external;

    function setAdjustment(
        uint256 _index,
        bool _add,
        uint256 _rate,
        uint256 _target
    ) external;
}


// File contracts/interfaces/ITazorAuthority.sol

interface ITazorAuthority {
    /* ========== EVENTS ========== */
    
    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);    
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);    
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);    

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */
    
    function governor() external view returns (address);
    function guardian() external view returns (address);
    function policy() external view returns (address);
    function vault() external view returns (address);
}


// File contracts/types/TazorAccessControlled.sol


abstract contract TazorAccessControlled {

    /* ========== EVENTS ========== */

    event AuthorityUpdated(ITazorAuthority indexed authority);

    string UNAUTHORIZED = "UNAUTHORIZED"; // save gas

    /* ========== STATE VARIABLES ========== */

    ITazorAuthority public authority;


    /* ========== Constructor ========== */

    constructor(ITazorAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }
    

    /* ========== MODIFIERS ========== */
    
    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }
    
    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), UNAUTHORIZED);
        _;
    }

    modifier onlyVault() {
        require(msg.sender == authority.vault(), UNAUTHORIZED);
        _;
    }
    
    /* ========== GOV ONLY ========== */
    
    function setAuthority(ITazorAuthority _newAuthority) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}


// File contracts/MyStaking.sol
//////////


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


contract TazorDAOStaking is TazorAccessControlled, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ITAZ;

    /* ========== STATE VARIABLES ========== */

    IUniswapV2Router02 public uniswapV2Router;

    address public routerAddress = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // pancakeswap testnet router address
    address public DAI = address(0x8a9424745056Eb399FD19a0EC26A14316684e274);
    // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D: rinkeby test router

    ITAZ        public tazToken;
    IERC20      public tazorToken;

    struct UserInfo {
        uint256 tazorNum;
        uint256 tazNum;
        uint256 reward;
        uint256 apr;
        uint256 lastUpdateTime;
        uint256 epochStartTime;
        uint256 burnAmount;
    }  
    
    mapping(address => uint256) public  rewards;         // number of  reward token should be paid to each account    
    mapping(address => UserInfo) public userInfos;     // number of staked TAZOR token per user

    uint256 private _totalTazorSupply;                  // total number of staked TAZOR token
    uint256 private _totalTazSupply;                    // total number of staked TAZOR token

    uint256 public numOfCycle;

    /* ========== CONSTANT ========== */

    uint256 public constant burnRate    = 3;               // 3% burn rate.
    uint256 public lockupTime  = 3600; // 1hour               // lockup time which is updated when user stake | unstake | getReward.

    /* ========== CONSTRUCTOR ========== */

    constructor(        
        address _tazToken,
        address _tazorToken,
        address _authority
    ) TazorAccessControlled(ITazorAuthority(_authority)) {

        tazToken =      ITAZ(_tazToken);
        tazorToken =    IERC20(_tazorToken);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        // testnet PCS router: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // mainnet PCS V2 router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // rinkeby router address: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D       
        uniswapV2Router = _uniswapV2Router;
    }

    /* ========== VIEWS ========== */

    function totalTazorSupply() external view returns (uint256) {
        return _totalTazorSupply;
    }

    function totalTazSupply() external view returns (uint256) {
        return _totalTazSupply;
    }

    function balanceOfTazor(address account) external view returns (uint256) {
        return userInfos[account].tazorNum;
    }

    function balanceOfTaz(address account) external view returns (uint256) {
        return userInfos[account].tazNum;
    }
   
    // add new reward to previously earned reward
    function calcReward(address account) public view returns (uint256) {
        uint256 timeinterval = block.timestamp.sub(userInfos[account].lastUpdateTime);

        uint256 rate = getTazorAndTazRate(); // get TAZOR/TAZ rate
        // uint256 rate = 1;
        UserInfo memory user = userInfos[account];
        uint256 newEarned = user.tazorNum.mul(rate).mul(1 days).div(lockupTime).div(10 ** 9);
        newEarned = newEarned.mul(user.apr).mul(timeinterval).div(365 days).div(10 ** 9);         // apr value should be divide by 10 ** 9 
        return newEarned.add(user.reward);
    }


    function calcBurn(address account) public {
        
        uint256 timeinterval = block.timestamp.sub(userInfos[account].lastUpdateTime);      
               
        if ( _totalTazorSupply > 0) {

            UserInfo memory user = userInfos[account];
            uint256 numberOfEpoch = timeinterval.div(lockupTime);
            numOfCycle = numberOfEpoch;
            uint256 diffVal = (user.tazNum).mul(user.tazorNum).div(_totalTazorSupply).mul(3).div(100);
            uint256 burnAmount = numberOfEpoch.mul(diffVal);

            if (burnAmount > 0) {
                userInfos[account].burnAmount = burnAmount;
                if (burnAmount > userInfos[account].tazNum) {
                    burnAmount = userInfos[account].tazNum;
                }
                userInfos[account].tazNum = userInfos[account].tazNum.sub(burnAmount);
                _totalTazSupply = _totalTazSupply - burnAmount;
                require(_totalTazorSupply >= 0, "Fatal Error, totalTazorSupply < 0");
                tazToken.burn(burnAmount);
                setAPRvalue();
            }
        }
    
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeTazor(uint256 amount, address receipient) external nonReentrant {
        require(amount > 0, "Cannot stake tazor 0");

        claim();

        _totalTazorSupply = _totalTazorSupply.add(amount);
        userInfos[receipient].tazorNum = userInfos[receipient].tazorNum.add(amount);

        tazorToken.safeTransferFrom(receipient, address(this), amount);
        emit TazorStaked(receipient, amount);
    }

    function stakeTaz(uint256 amount, address receipient) external nonReentrant {
        require(amount > 0, "Cannot stake taz 0");
        
        claim();

        _totalTazSupply = _totalTazSupply.add(amount);
        userInfos[receipient].tazNum = userInfos[receipient].tazNum.add(amount);

        // update apr
        setAPRvalue();

        tazToken.safeTransferFrom(receipient, address(this), amount);
        emit TazStaked(receipient, amount);
    }


    function unstakeTazor(uint256 amount) public nonReentrant {
        require(amount > 0, "Cannot withdraw 0");
        // require(block.timestamp > userInfos[msg.sender].lastUpdateTime + 12 hours, "can't draw tokens");

        UserInfo memory user = userInfos[msg.sender];
        require(user.tazorNum >= amount, "There is not enough for unstake Tazor.");

        if (canClaim(msg.sender)) {
            claim();
            _totalTazorSupply = _totalTazorSupply.sub(amount);
            userInfos[msg.sender].tazorNum = userInfos[msg.sender].tazorNum.sub(amount);

            tazorToken.safeTransfer(msg.sender, amount);
            emit TazorWithdrawn(msg.sender, amount);
        }
    }

    function unstakeTaz(uint256 amount) public nonReentrant {
        require(amount >= 0, "Cannot withdraw <0");
        // require(block.timestamp > userInfos[msg.sender].lastUpdateTime + 12 hours, "can't draw tokens");

        UserInfo memory user = userInfos[msg.sender];
        if (amount > 0) {
            require(user.tazNum >= amount, "There is not enough for unstake Taz.");
        }

        if (canClaim(msg.sender)) {
            claim();
            if (amount > 0) {
                if (_totalTazSupply < amount) {
                    _totalTazSupply = amount;
                }
                _totalTazSupply = _totalTazSupply.sub(amount);

                if (userInfos[msg.sender].tazNum < amount) {
                    userInfos[msg.sender].tazNum = amount;    
                }
                userInfos[msg.sender].tazNum = userInfos[msg.sender].tazNum.sub(amount);

                tazToken.safeTransfer(msg.sender, amount);
                emit TazWithdrawn(msg.sender, amount);
            }
        }
    }

    // View function to see if user can claim TAZ.
    function canClaim(address _user) public view returns (bool) {
        UserInfo memory user = userInfos[_user];
        require(user.epochStartTime > 0, "can't claim, nothing to claim");
        return block.timestamp >= user.epochStartTime + lockupTime;
    }

    function claim() internal {

        if (msg.sender != address(0)) {
            if (userInfos[msg.sender].lastUpdateTime == 0) {
                userInfos[msg.sender].lastUpdateTime = block.timestamp;
                userInfos[msg.sender].epochStartTime = block.timestamp;
                userInfos[msg.sender].apr = (10 ** 8);
            }
         
            uint256 reward = calcReward(msg.sender);
            calcBurn(msg.sender);

            if (reward > 0) {
                // tazToken.safeTransfer(msg.sender, reward);
                tazToken.mint(msg.sender, reward);
                userInfos[msg.sender].reward = 0;
                emit RewardPaid(msg.sender, reward);
                userInfos[msg.sender].epochStartTime = block.timestamp;
            }

            userInfos[msg.sender].lastUpdateTime = block.timestamp;
            userInfos[msg.sender].epochStartTime = block.timestamp;
        }
    }

    function setAPRvalue() private {
        userInfos[msg.sender].apr = ((userInfos[msg.sender].tazNum.mul(109500)).add(10 ** 17)).div(10 ** 9);
    }

    function getAPRvalue(address account) external view returns(uint256) {
        return userInfos[account].apr;
    }

    function getReward(address account) external view returns(uint256) {

        uint256 rate = getTazorAndTazRate(); // get TAZOR/TAZ rate
        // uint256 rate = 1;
        UserInfo memory user = userInfos[account];
        uint256 timeinterval = block.timestamp.sub(user.lastUpdateTime);
        uint256 newEarned = user.tazorNum.mul(rate).mul(1 days).div(lockupTime).div(10 ** 9);                                 // rate / 10**9
        newEarned = newEarned.mul(user.apr).mul(timeinterval).div(365 days).div(10 ** 9);         // apr value should be divide by 10 ** 9 
        return newEarned.add(user.reward);
    }

    function exitTazor() external {
        unstakeTazor(userInfos[msg.sender].tazorNum);
    }

    function updateRouterAddress(address _routerAddress) public onlyGovernor {
        uniswapV2Router = IUniswapV2Router02(_routerAddress);
    }

    function setLockuptime(uint256 _lockupTime) external onlyGovernor {
        require(_lockupTime > 300, "_lockupTime can't less than 5 min");
        lockupTime = _lockupTime;
    }

    function getTazorAndTazRate() public view returns(uint256) {

        address[] memory path = new address[](3);
        path[0] = address(tazorToken);
        path[1] = DAI;
        path[2] = address(tazToken);

        uint256[] memory amountOutMins = uniswapV2Router.getAmountsOut(1000000000, path);
        return amountOutMins[path.length - 1];  //  = tazor/taz;
    }

    function secondsToNextEpoch(address account) external view returns (uint256) {
        UserInfo memory user = userInfos[account];
        if (user.lastUpdateTime != 0) {
            uint256 remain = block.timestamp - user.lastUpdateTime;
            return (remain.div(lockupTime) + 1).mul(lockupTime).sub(remain);
        } else {
            return 0;
        }
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyPolicy {
        tazToken.safeTransfer(address(msg.sender), _amount);
    }

    /*
     * @notice Stop stake
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyStakedWithdraw(uint256 _amount) external onlyPolicy {
        tazorToken.safeTransfer(address(msg.sender), _amount);
    }

    // (1 + x)^a = 1 + ax + a*(a-1)*x*2 / 2 + a*(a-1)*(a-2)*x^3/6;
    // alpha = tazor / totTazor * 0.03
    

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event TazorStaked(address indexed user, uint256 amount);
    event TazStaked(address indexed user, uint256 amount);
    event TazorWithdrawn(address indexed user, uint256 amount);
    event TazWithdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
}
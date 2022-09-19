/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

//    ___  __    ________  ________  ________  _____ ______   ________          ________  _______   ________   ________  ___  ___  ___     
//   |\  \|\  \ |\   __  \|\_____  \|\   __  \|\   _ \  _   \|\   __  \        |\   ____\|\  ___ \ |\   ___  \|\   ____\|\  \|\  \|\  \    
//   \ \  \/  /|\ \  \|\  \\|___/  /\ \  \|\  \ \  \\\__\ \  \ \  \|\  \       \ \  \___|\ \   __/|\ \  \\ \  \ \  \___|\ \  \\\  \ \  \   
//    \ \   ___  \ \   __  \   /  / /\ \   __  \ \  \\|__| \  \ \   __  \       \ \_____  \ \  \_|/_\ \  \\ \  \ \_____  \ \   __  \ \  \  
//     \ \  \\ \  \ \  \ \  \ /  /_/__\ \  \ \  \ \  \    \ \  \ \  \ \  \       \|____|\  \ \  \_|\ \ \  \\ \  \|____|\  \ \  \ \  \ \  \ 
//      \ \__\\ \__\ \__\ \__\\________\ \__\ \__\ \__\    \ \__\ \__\ \__\        ____\_\  \ \_______\ \__\\ \__\____\_\  \ \__\ \__\ \__\
//       \|__| \|__|\|__|\|__|\|_______|\|__|\|__|\|__|     \|__|\|__|\|__|       |\_________\|_______|\|__| \|__|\_________\|__|\|__|\|__|
//                                                                                \|_________|                   \|_________|                                                                                                                                                 
//        あなたは調整し、事実を分析し、結論を導き出します。
//        - Cooper

// SPDX-License-Identifier: MIT
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
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * Available since v3.4.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     * Available since v3.4.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     * Available since v3.4.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     * Available since v3.4.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     * Available since v3.4.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     * Requirements => Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     * Requirements: => Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     * Requirements => Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     * Requirements  => The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements => The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     * Requirements => Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements => The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements => The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        
        return mul(div(d,m),m);
  }
}

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
abstract contract TheZaibatsu is Context {
    address private _owner;

    mapping(address => bool) internal senshiMaster;
    mapping(address => bool) internal jin;
    mapping(address => bool) internal zaibatsu;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        jin[_owner] = true;
        zaibatsu[_owner] = true;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(),
        "Only owner ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be the SenshiMaster.
     * NOTE: Read at {function raiseSenshiMaster} below
     * for more information.
     */
     modifier onlySenshiMaster() {
        require(isSenshiMaster (_msgSender()),
        "Just no. This is only for the Senshi Master ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be Jin.
     */
     modifier onlyJin() {
        require(isJin (_msgSender()),
        "Be Jin or pretend to be ..");
        _;
    }

    /**
     * @dev Function modifier to require caller to be part of the Zaibatsu Group.
     */
     modifier onlyZaibatsu() {
        require(isZaibatsu (_msgSender()),
        "Become part of the Zaibatsu Group or stop fooling yourself ..");
        _;
    }

    /**
     * @dev Return address' SenshiMaster status.
     * NOTE: Read at {function raiseSenshiMaster} below
     * for more information.
     */
     function isSenshiMaster(address adr) public view returns (bool) {
        return senshiMaster[adr];
    }

    /**
     * @dev Return address' Jin status.
     */
     function isJin(address adr) public view returns (bool) {
        return jin[adr];
    }

    /**
     * @dev Return address' Zaibatsu status.
     */
     function isZaibatsu(address adr) public view returns (bool) {
        return zaibatsu[adr];
    }

    /**
     * @dev Function to assign the SenshiMaster role to an address.
     */
     function raiseSenshiMaster(address adr) external onlyJin {
        senshiMaster[adr] = true;
    }

    /**
     * @dev Function to assign the Jin role to an address.
     * Can only be done by owner (SenshiMaster).
     * 
     * NOTE: Since the initial deployer will move ownership to the Senshi Master contract,
     * the initial deployer will be the only Jin besides the Senshi Master.
     */
     function raiseJin(address adr) external onlyJin {
        jin[adr] = true;
    }

    /**
     * @dev Function to assign the Zaibatsu role to an address.
     * Can only be done by an address that has been assigned with the Jin role.
     */
    function recruitZaibatsu(address adr) external onlyJin {
        zaibatsu[adr] = true;
    }

    /**
     * @dev Remove address from the SenshiMaster role and all
     * associated privileges.
     *
     * NOTE: This should be done if the SenshiMaster contract appears to have a bug.
     */
    function removeSenshiMaster(address adr) external onlyJin {
        senshiMaster[adr] = false;
    }

    /**
     * @dev Remove address from the Zaibatsu Group role and all
     * associated privileges that the Zaibatsu role has.
     */
    function removeZaibatsu(address adr) external onlyJin {
        zaibatsu[adr] = false;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyJin {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner (the SenshiMaster).
     */
    function transferOwnership(address newOwner) external virtual onlyJin {
        require(newOwner != address(0), "Zaibatsu: No zero ..");
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

/**
 * @dev Interface of the BEP20 (ERC20) standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol (KAZAMA in our case).
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name (Kazama Senshi in our case).
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the contract owner (SenshiMaster).
     * This will be the SenshiMaster contract.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
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

interface KazamaFactory {
    function createPair(address tokenA, address tokenB) 
    external returns (address pair);
}

interface KazamaRouter {
    /**
     * @dev Returns the factory address.
     */
    function factory() 
    external pure returns (address);

    /**
     * @dev Returns the WETH (i.e WBNB) address.
     */
    function WETH() 
    external pure returns (address);

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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    KazamaRouter Router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 15000 * (10 ** 18);
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _Router) {
        Router = _Router != address(0)
        ? KazamaRouter(_Router)
        : KazamaRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract BEP20 is IBEP20, TheZaibatsu {
    using SafeMath for uint256;

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant BURN = 0x0000000000000000000000000000000000000000;
    address public LiquidityReceiver;
    address public TreasuryReceiver;
    address public ZaibatsuHoldings;
    address public Pair;

    string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;

    event RecoverTokens (address token, uint256 amount);
    event DistributionData (uint256 minPeriod, uint256 minDistribution);

    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) _balances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) BuyBacker;
    mapping (address => bool) isBurnExempt;
    mapping (address => bool) isDividendExempt;

    uint256 _totalSupply = 775_000_000 * (10 ** _decimals);
    uint256 LiqGeneratorFee = 3;
    uint256 BuyBackBurnFee = 2;
    uint256 TreasuryFee = 3;
    uint256 RewardsFee = 5;

    uint256 TargetLiquidity = 55;
    uint256 TargetLiquidityDenominator = 100;

    uint256 BuyBackMultiplierNumerator = 200;
    uint256 BuyBackMultiplierDenominator = 100;
    uint256 BuyBackMultiplierTriggeredAt;
    uint256 BuyBackMultiplierLength = 30 minutes;
    uint256 distributorGas = 500000;

    uint256 AutoBuyBackCap;
    uint256 AutoBuyBackAccumulator;
    uint256 AutoBuyBackAmount;
    uint256 AutoBuyBackBlockPeriod;
    uint256 AutoBuyBackBlockLast;

    bool public SwapActive = true;
    bool public AutoBuyBackActive = false;
    bool InSwap;

    address public distributorAddress;
    uint256 public AllTimeBurned;
    uint256 public TotalFee = 13;
    uint256 public FeeDenominator = 100;
    uint256 public swapThreshold = _totalSupply / 10000;

    KazamaRouter public Router;
    DividendDistributor distributor;

    /**
    * @dev This will be 2.75% of the amount of each transaction because
    * the value of 2750 will be devided by 100000.
    *
    * Note: See line:
    * - {uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); // = 2.75%}
    *
    * Burn percentage can be adjusted if needed with the {setBurnPercentage} function.
     */
    uint256 public BurnPercentSettings = 2750;

    /**
    * InSwap modifier boolean.
     */
    modifier swapping() { InSwap = true; _; InSwap = false; }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;

        address _KazamaRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        Router = KazamaRouter (_KazamaRouter);
        Pair = KazamaFactory (Router.factory()).createPair(WBNB, address(this));

        _allowances [address(this)] [address (Router)] = _totalSupply * 100 ;
        WBNB = Router.WETH();
        distributor = new DividendDistributor(_KazamaRouter);
        distributorAddress = address(distributor);

        BuyBacker [_msgSender()] = true;
        isFeeExempt [_msgSender()] = true;
        isBurnExempt [_msgSender()] = true;
        isDividendExempt[_msgSender()] = true;
        isDividendExempt[Pair] = true;
        isDividendExempt[DEAD] = true;

        LiquidityReceiver = DEAD;
        ZaibatsuHoldings = _msgSender();
        TreasuryReceiver = _msgSender();

        approve(_KazamaRouter, _totalSupply * 100);
        approve(address(Pair), _totalSupply * 100);
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable { 
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) { 
        return _totalSupply;
         }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override pure returns (uint8) { 
        return _decimals;
         }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view virtual override returns (string memory) { 
        return _symbol;
         }

    /**
     * @dev Returns the token name.
     * In our case Kazama Senshi.
     */
    function name() public view virtual override returns (string memory) { 
        return _name;
         }

    /**
     * @dev Returns the contract owner.
     */
    function getOwner() external override view returns (address) { 
        return owner();
         }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
         return _balances[account];
          }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) { 
        return _allowances[owner][spender];
         }

    /**
     * @dev Check if the requester who wants to call
     * the (BuyBackBurn) function is authorized.
     */
    modifier onlyBuybacker() { require (
        BuyBacker[_msgSender()] == true, ""); _;
         }

    /**
    * @dev Burn percentage can be adjusted
    * if needed with the {setBurnPercentage} function.
     */
    function burnPercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(BurnPercentSettings);
        uint256 percentValue = roundValue.mul(BurnPercentSettings).div(100000); 
        return percentValue;
   }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     * Approval for `max` balance.
     */
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient, 
        uint256 amount
        ) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != _totalSupply) {
           _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]
           .sub(amount, "Insufficient Allowance");
        } return _transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance. Returns a boolean value indicating whether the operation succeeded.
     *
     * NOTE: In our case, the number of tokens sent minus the fees is `amountReceived`.
     * Then when `tokensToBurn` is subtracted from `amountReceived` we get `toReceiver`.
     *
     * The final amount that the recipient will receive is `toReceiver`.
     * Emits a {Transfer} event and sends `tokensToBurn` to the 0x0 address
     * and removes these tokens from _totalSupply.
     */
    function _transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
        ) internal returns (bool) {

        if(InSwap){ return _basicTransfer(sender, recipient, amount); 
        }

        if(shouldSwapBack()){ 
            swapBack(); 
            }

        if(shouldAutoBuyback()){ 
            triggerAutoBuyback(); 
            }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 tokensToBurn = burnPercentage(amount);
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

         if  (shouldBurnSender(sender) == false) {
            uint256 toReceiver = amountReceived;
            _balances[recipient] = _balances[recipient].add(toReceiver);
            emit Transfer(sender, recipient, toReceiver);
        } else {
             uint256 toReceiver = amountReceived.sub(tokensToBurn);
            _totalSupply = _totalSupply.sub(tokensToBurn);
            _balances[recipient] = _balances[recipient].add(toReceiver);
            AllTimeBurned = AllTimeBurned + tokensToBurn;
            emit Transfer(sender, recipient, toReceiver);
            emit Transfer(sender, address(0), tokensToBurn);
        }
        try distributor.process(distributorGas) {} catch {}
        return true;
    }

    /**
     * @dev If the sender or receiver is FeeExempt, a normal transaction
     * will be triggered without fees.
     *
     * NOTE: This also applies when the {SwapActive} boolean is set to false.
     */
    function _basicTransfer(
        address sender, 
        address recipient, 
        uint256 amount
        ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        uint256 tokensToBurn = burnPercentage(amount);

        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

         if  (shouldBurnSender(sender) == false) {
            uint256 toReceive = amount;
             _balances[recipient] += toReceive;
            emit Transfer(sender, recipient, toReceive);
            _afterTokenTransfer(sender, recipient, toReceive);
        } else {
            uint256 toReceive = amount - tokensToBurn;
            _balances[recipient] += toReceive;
            _totalSupply = _totalSupply.sub(tokensToBurn);
            AllTimeBurned = AllTimeBurned + tokensToBurn;
            emit Transfer(sender, recipient, toReceive);
            emit Transfer(sender, address(0), tokensToBurn);
            _afterTokenTransfer(sender, recipient, toReceive);
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * This feature will only be used by the SenshiMaster contract for mining tokens and 
     * paying out to stakers and farmers. 
     *
     * NOTE: The onlyOwner role cannot access this function, only the SenshiMaster role can. 
     * This is to ensure that as long as the SenshiMaster is not yet the owner of this contract because
     * it is in a test phase, the current owner cannot just mint tokens. 
     *
     * When the SenshiMaster contract is found to be bug free, it will become the real owner of this contract 
     * and also own the SenshiMaster role.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
    @dev Calculate fees on transaction if SwapActive boolean is `True`, 
    * use _basicTransfer if `False` or if sender or recipient is `FeeExempt`.
     */
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function shouldBurnSender(address sender) internal view returns (bool) {
        return !isBurnExempt[sender];
    }

    /**
    @dev Adds all fees together and marks them as TotalFee, burn excluded.
     */
    function getTotalFee(bool selling) public view returns (uint256) {
        if(selling) { 
            return getMultipliedFee();
             }
        return TotalFee;
    }

    /**
    * @dev If BuyBack is active and the contract is in the process of buying back tokens and burning, 
    * the fees are increased for the duration of the buyback process. This is to discourage selling 
    * when the price rises (after all, we want diamond hands).
    *
    * NOTE: It is possible to turn off this multiplier during automatic buy backs.
     */
    function getMultipliedFee() public view returns (uint256) {
        if (BuyBackMultiplierTriggeredAt.add(BuyBackMultiplierLength) > block.timestamp) {
            uint256 remainingTime = BuyBackMultiplierTriggeredAt.add(BuyBackMultiplierLength).sub(block.timestamp);
            uint256 feeIncrease = TotalFee.mul(BuyBackMultiplierNumerator).div(BuyBackMultiplierDenominator).sub(TotalFee);
            return TotalFee.add(feeIncrease.mul(remainingTime).div(BuyBackMultiplierLength));
        }
        return TotalFee;
    }

    function takeFee(
        address sender, 
        address receiver, 
        uint256 amount
        ) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == Pair)).div(FeeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    /**
    * @dev When the set threshold is reached, activate {swapBack()}.
    *
    * NOTE: If SwapActive is boolean False or sender/ricipient is FeeExempt, 
    * the threshold will not be swapped.
     */
    function shouldSwapBack() internal view returns (bool) {
        return _msgSender() != Pair
        && !InSwap
        && SwapActive
        && _balances[address(this)] >= swapThreshold;
    }

        /**
        * @dev Some of the collected tokens will be swapped back to WBNB for
        * buybacks and the other portion will be used to create additional liquidity and
        * send the Kazama-LP (liquidity provider) tokens to the DEAD address.
         */
        function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(TargetLiquidity, TargetLiquidityDenominator) ? 0 : LiqGeneratorFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(TotalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = TotalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBTreasury = amountBNB.mul(TreasuryFee).div(totalBNBFee);
        uint256 amountBNBRewards = amountBNB.mul(RewardsFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBRewards}() {} catch {}
        payable(TreasuryReceiver).transfer(amountBNBTreasury);

        if(amountToLiquify > 0){
            Router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                LiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    /**
    * @dev Calculate whether automatic buyback should be activated.
     */
    function shouldAutoBuyback() internal view returns (bool) {
        return _msgSender() != Pair
        && !InSwap
        && AutoBuyBackActive
        && AutoBuyBackBlockLast + AutoBuyBackBlockPeriod <= block.number
        && address(this).balance >= AutoBuyBackAmount;
    }

    /**
    * @dev If necessary, the contract can be manually instructed to make a buyback.
    * NOTE: Including the possibility to turn off the multiplier during the buyback period.
     */
    function triggerKazamaBuyback(uint256 amount, bool triggerBuybackMultiplier) external onlyZaibatsu {
        buyKazama(amount, BURN);
        if(triggerBuybackMultiplier){
            BuyBackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(BuyBackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external onlyZaibatsu {
        BuyBackMultiplierTriggeredAt = 0;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyZaibatsu {
        uint256 amountBNB = address(this).balance;
        payable(ZaibatsuHoldings).transfer(amountBNB * amountPercentage / 100);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyJin {
        require(_tokenAddress != address(this), "Cannot be KAZAMA token");
        IBEP20(_tokenAddress).transfer(address(ZaibatsuHoldings), _tokenAmount);
        emit RecoverTokens(_tokenAddress, _tokenAmount);
    }

    /**
    * @dev If it is decided to increase or decrease the burning percentage.
    * Min of 0.1% / Max of 7%
    */
    function setBurnPercentage(uint256 _BurnPercentSettings) external onlyZaibatsu {
        require(_BurnPercentSettings >= 100, 'Cannot be lower than 0.1% ..');
        require(_BurnPercentSettings <= 7000, 'Cannot be higher than 7% ..');
        BurnPercentSettings = _BurnPercentSettings;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyJin {
        require(holder != address(this) && holder != Pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function triggerAutoBuyback() internal {
        buyKazama(AutoBuyBackAmount, BURN);
        AutoBuyBackBlockLast = block.number;
        AutoBuyBackAccumulator = AutoBuyBackAccumulator.add(AutoBuyBackAmount);
        if(AutoBuyBackAccumulator > AutoBuyBackCap) { 
           AutoBuyBackActive = false;
         }
    }

    function buyKazama(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );

        _totalSupply = _totalSupply.sub(AutoBuyBackAmount);
        AllTimeBurned = AllTimeBurned + AutoBuyBackAmount;

    }

    /**
    * @dev Function to configure the automatic buybacks.
     */
    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyZaibatsu {
        AutoBuyBackActive = _enabled;
        AutoBuyBackCap = _cap;
        AutoBuyBackAccumulator = 0;
        AutoBuyBackAmount = _amount;
        AutoBuyBackBlockPeriod = _period;
        AutoBuyBackBlockLast = block.number;
    }

    /**
    * @dev If the automatic buybacks use the multiplier during the buyback period, 
    * a lower or higher multiplier can be set + the duration of the buyback.
     */
    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external onlyZaibatsu {
        require(numerator / denominator <= 2 && numerator > denominator);
        BuyBackMultiplierNumerator = numerator;
        BuyBackMultiplierDenominator = denominator;
        BuyBackMultiplierLength = length;
    }

    /**
    * @dev Free a wallet or contract from fees.
    * This will be required if third parties make applications that integrate our token. 
    * Also useful for our own applications.
     */
    function setIsFeeExempt(address holder, bool exempt) external onlyZaibatsu {
        isFeeExempt[holder] = exempt;
    }

    /**
    * @dev Free a wallet or contract from burning tokens on transactions.
    * Useful for our applications, like a bridge.
     */
    function setIsBurnExempt(address holder, bool exempt) external onlyZaibatsu {
        isBurnExempt[holder] = exempt;
    }

    /**
    * @dev If necessary to change the fees.
    *
    * NOTE: All fees added together can never be set higher than 13% (TotalFee).
     */
    function setFees(uint256 _LiqGeneratorFee, uint256 _BuyBackBurnFee, uint256 _TreasuryFee, uint256 _RewardsFee) external onlyJin {
        LiqGeneratorFee = _LiqGeneratorFee;
        BuyBackBurnFee = _BuyBackBurnFee;
        TreasuryFee = _TreasuryFee;
        RewardsFee = _RewardsFee;
        TotalFee = _LiqGeneratorFee.add(_BuyBackBurnFee).add(_TreasuryFee).add(_RewardsFee);
        // TotalFee checks
        require (TotalFee >= 4, 'EXCEEDS MIN: Total fee must be equal to `4` or higher ..');
        require (TotalFee <= 13, 'EXCEEDS MAX: Total fee must be equal to `13` or lower ..');
    }

    function setFeeReceivers(address _TreasuryReceiver) external onlyJin {
        TreasuryReceiver = _TreasuryReceiver;
    }

    function setZaibatsuHoldings(address _ZaibatsuHoldings) external onlyJin {
        ZaibatsuHoldings = _ZaibatsuHoldings;
    }

   function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyZaibatsu {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit DistributionData (_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyZaibatsu {
         require(gas < 1000000);
        distributorGas = gas;
    }

    /**
    * @dev Set SwapActive to `True` or `False` (If `True`, the configured threshold is used for the swaps).
     */
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyZaibatsu {
        SwapActive = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyJin {
        TargetLiquidity = _target;
        TargetLiquidityDenominator = _denominator;
    }

    /**
    * @dev Output the total supply. If tokens are sent to the DEAD address
    * by someone for whatever reason, we will subtract them from `_totalSupply`.
     */
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(Pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}

contract KazamaSenshi is BEP20 ("Kazama Senshi", "KAZAMA") {
    using SafeMath for uint256;

    /// @notice Creates `_amount` token to `_to`. Must only be called by an contract with the SenshiMaster role (i.e SenshiMaster & Bridge contract).
    function mint(address _to, uint256 _amount) public onlySenshiMaster {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
        AllTimeBurned = AllTimeBurned + amount;
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `_msgSender()` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `_msgSender()` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(_msgSender(), delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "KAZAMA [delegateBySig]: Invalid signature");
        require(nonce == nonces[signatory]++, "KAZAMA [delegateBySig]: Invalid nonce");
        require(block.timestamp <= expiry, "KAZAMA [delegateBySig]: Signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "KAZAMA [getPriorVotes]: Not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); 
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "KAZAMA [_writeCheckpoint]: Block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// File: contracts/interfaces/IMoonshotMechanism.sol



pragma solidity ^0.6.0;

interface IMoonshotMechanism {
    function setShare(address crew, uint256 amount) external;
    function shootMoon() external;
    function getGoal() external view returns(uint);
    function getMoonshotBalance() external view returns(uint);
}

// File: contracts/interfaces/IERC20.sol



pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: contracts/interfaces/IPYESwapRouter01.sol



pragma solidity >=0.6.2;

interface IPYESwapRouter01 {
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

// File: contracts/interfaces/IPYESwapRouter.sol



pragma solidity >=0.6.2;


interface IPYESwapRouter is IPYESwapRouter01 {
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
    function pairFeeAddress(address pair) external view returns (address);
    function adminFee() external view returns (uint256);
    function feeAddressGet() external view returns (address);
}

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
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
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: contracts/MoonshotMechanism.sol


pragma solidity ^0.6.12;





contract MoonshotMechanism is IMoonshotMechanism {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    struct Moonshot {
        string Name;
        uint Value;
    }

    address[] crews;
    mapping (address => uint256) crewIndexes;
    mapping (address => uint256) crewClaims;

    mapping (address => Share) public shares;

    uint256 public totalForceShares;
    uint256 public totalForceBountys;
    uint256 public totalForceDistributed;
    uint256 public forceBountysPerShare;
    uint256 public forceBountysPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool public initialized = true;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    Moonshot[] internal Moonshots;
    uint[] internal mysteryMoonshots = [250, 500, 750, 1000, 2000];
    address admin;
    uint public disbursalThreshold;
    uint public lastMoonShot;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    IPYESwapRouter public pyeSwapRouter;
    address public WBNB;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor() public {
        pyeSwapRouter = IPYESwapRouter(0x07Dce0028a9D8aBe907B8c11F8EA912FeaB27f03);
        WBNB = pyeSwapRouter.WETH();
        _token = msg.sender;

        admin = 0x65319148979AFDC90E23f16Fb4245a14406f37c4;
        Moonshots.push(Moonshot("Waxing", 250));
        Moonshots.push(Moonshot("Waning", 500));
        Moonshots.push(Moonshot("Half Moon", 750));
        Moonshots.push(Moonshot("Full Moon", 1000));
        Moonshots.push(Moonshot("Blue Moon", 2000));
        Moonshots.push(Moonshot("Mystery Moonshot", 0));
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    //-------------------------- BEGIN EDITING FUNCTIONS ----------------------------------

    // Allows admin to create a new moonshot with a corresponding value; pushes new moonshot to end of array and increases array length by 1.
    function createMoonshot(string memory _newName, uint _newValue) public onlyAdmin {
        Moonshots.push(Moonshot(_newName, _newValue));
    }
    // Remove last element from array; this will decrease the array length by 1.
    function popMoonshot() public onlyAdmin {
        Moonshots.pop();
    }
    // User enters the value of the moonshot to delete, not the index. EX: enter 2000 to delete the Blue Moon struct, the array length is then decreased by 1.
        // moves the struct you want to delete to the end of the array, deletes it, and then pops the array to avoid empty arrays being selected by pickMoonshot.
    function deleteMoonshot(uint _value) public onlyAdmin {
        uint moonshotLength = Moonshots.length;
        for(uint i = 0; i < moonshotLength; i++) {
            if (_value == Moonshots[i].Value) {
                if (1 < Moonshots.length && i < moonshotLength-1) {
                    Moonshots[i] = Moonshots[moonshotLength-1]; }
                    delete Moonshots[moonshotLength-1];
                    Moonshots.pop();
                    break;
            }
        }
    }
    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;
    }

    function getGoal() external view override returns(uint256){
        return disbursalThreshold;
    }

    function getMoonshotBalance() external view override returns(uint256){
        return IERC20(address(WBNB)).balanceOf(address(this));
    }

    //-------------------------- BEGIN GETTER FUNCTIONS ----------------------------------
    // Enter an index to return the name and value of the moonshot @ that index in the Moonshots array.
    function getMoonshotNameAndValue(uint _index) public view returns (string memory, uint) {
        return (Moonshots[_index].Name, Moonshots[_index].Value);
    }
    // Returns the value of the contract in BNB.
    function getContractValue() public view onlyAdmin returns (uint) {
        return address(this).balance;
    }
    // Getter fxn to see the disbursal threshold value.
    function getDisbursalValue() public view onlyAdmin returns (uint) {
        return disbursalThreshold;
    }
    //-------------------------- BEGIN MOONSHOT SELECTION FUNCTIONS ----------------------------------
    // Generates a "random" number.
    function random() internal view onlyAdmin returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty + block.timestamp)));
    }

    // Allows admin to manually select a new disbursal threshold.
    function overrideDisbursalThreshold(uint newDisbursalThreshold) public onlyAdmin returns (uint) {
        disbursalThreshold = newDisbursalThreshold;
        return disbursalThreshold;
    }

    function pickMoonshot() public onlyAdmin {
        require(Moonshots.length > 0, "The Moonshot array is empty; please create a new Moonshot!");
        uint disbursalValue;
        uint mysteryValue;
        Moonshot storage winningStruct = Moonshots[random() % Moonshots.length];
        disbursalValue = winningStruct.Value;
        lastMoonShot = disbursalThreshold;
        
        if (disbursalValue == 0) { 
            mysteryValue = mysteryMoonshots[random() % mysteryMoonshots.length];
            disbursalThreshold = mysteryValue * 10**9;
        } else {
            disbursalThreshold = disbursalValue * 10**9;
        }

        verifyNewMoonshot();
    }

    function verifyNewMoonshot() internal {
        if (disbursalThreshold == lastMoonShot) {
            pickMoonshot();
        }
    }    

    function shootMoon() external override {
        //uint256 moonBalance = IERC20(address(WBNB)).balanceOf(address(this));
        //require(moonBalance >= disbursalThreshold); 
        buyReflectTokens(disbursalThreshold, address(this));
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address crew, uint256 amount) external override onlyToken {
        if(shares[crew].amount > 0){
            distributeBounty(crew);
        }

        if(amount > 0 && shares[crew].amount == 0){
            addCrew(crew);
        }else if(amount == 0 && shares[crew].amount > 0){
            removeCrew(crew);
        }

        totalForceShares = totalForceShares.sub(shares[crew].amount).add(amount);
        shares[crew].amount = amount;
        shares[crew].totalExcluded = getCumulativeBountys(shares[crew].amount);
    }

    function buyReflectTokens(uint256 amount, address to) internal {
    //    uint256 balanceBefore = IERC20(address(_token)).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        IERC20(WBNB).approve(address(pyeSwapRouter), amount);

        pyeSwapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            to,
            block.timestamp + 10 minutes
        );

    //    uint256 newAmount = IERC20(address(_token)).balanceOf(address(this)).sub(balanceBefore);

    //    totalForceBountys = totalForceBountys.add(newAmount);
    //    forceBountysPerShare = forceBountysPerShare.add(forceBountysPerShareAccuracyFactor.mul(newAmount).div(totalForceShares));

        pickMoonshot();
    }

    function distributeBounty(address crew) internal {
        if(shares[crew].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(crew);
        if(amount > 0){
            totalForceDistributed = totalForceDistributed.add(amount);
            IERC20(_token).transfer(crew, amount);
            crewClaims[crew] = block.timestamp;
            shares[crew].totalRealised = shares[crew].totalRealised.add(amount);
            shares[crew].totalExcluded = getCumulativeBountys(shares[crew].amount);
        }
    }

    function claimBounty() external {
        distributeBounty(msg.sender);
    }

    function getUnpaidEarnings(address crew) public view returns (uint256) {
        if(shares[crew].amount == 0){ return 0; }

        uint256 crewTotalBountys = getCumulativeBountys(shares[crew].amount);
        uint256 crewTotalExcluded = shares[crew].totalExcluded;

        if(crewTotalBountys <= crewTotalExcluded){ return 0; }

        return crewTotalBountys.sub(crewTotalExcluded);
    }

    function getCumulativeBountys(uint256 share) internal view returns (uint256) {
        return share.mul(forceBountysPerShare).div(forceBountysPerShareAccuracyFactor);
    }

    function addCrew(address crew) internal {
        crewIndexes[crew] = crews.length;
        crews.push(crew);
    }

    function removeCrew(address crew) internal {
        crews[crewIndexes[crew]] = crews[crews.length-1];
        crewIndexes[crews[crews.length-1]] = crewIndexes[crew];
        crews.pop();
    }
}
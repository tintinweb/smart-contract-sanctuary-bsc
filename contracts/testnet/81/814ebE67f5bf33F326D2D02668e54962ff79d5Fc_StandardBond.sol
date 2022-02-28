/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/ReEntrance.sol


pragma solidity ^0.7.5;

contract ReEntrance
{
    bool private locked;

    modifier reEntrance()
    {
        require(!locked, "Function is Locked!");
        locked = true;
        _;
        locked = false;
    }
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/IStakingHelper.sol


pragma solidity 0.7.5;

interface IStakingHelper {
    function stake( uint _amount, address _recipient ) external;
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/IStaking.sol


pragma solidity 0.7.5;


interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );
    function claim( address _recipient ) external;
    function unstake( uint _amount, address _recipient ) external returns ( bool );
    function index() external view returns ( uint );
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/IBondCalculator.sol


pragma solidity 0.7.5;

interface IBondCalculator {
    function valuation(address _LP, uint256 _amount)
        external
        view
        returns (uint256);

    function markdown(address _LP) external view returns (uint256);
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/ITreasury.sol


pragma solidity 0.7.5;

interface ITreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( bool );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
    function mintRewards( address _recipient, uint _amount ) external;

}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/FullMath.sol


pragma solidity 0.7.5;


library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/FixedPoint.sol


pragma solidity 0.7.5;




library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/IERC20.sol


pragma solidity 0.7.5;

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/Address.sol


pragma solidity 0.7.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/SafeMath.sol


pragma solidity 0.7.5;


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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

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

    function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {
        return div( mul( total_, percentage_ ), 1000 );
    }

    function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {
        return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
    }

    function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {
        return div( mul(part_, 100) , total_ );
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {
        return sqrrt( mul( multiplier_, payment_ ) );
    }

  function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {
      return mul( multiplier_, supply_ );
  }
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/SafeERC20.sol


pragma solidity 0.7.5;




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// File: Documents/TRuffle_Projects/JadeProtocol/contracts/IOwnable.sol


pragma solidity >=0.7.5;


interface IOwnable {
  function owner() external view returns (address);
  
  function pushManagement( address newOwner_ ) external;
  
  function pullManagement() external;
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/Ownable.sol


pragma solidity >=0.7.5;


abstract contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }
    
    function pushManagement( address newOwner_ ) public virtual override onlyOwner() {
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

// File: Documents/TRuffle_Projects/JadeProtocol/contracts/StandardBond.sol


pragma solidity 0.7.5;










contract StandardBond is Ownable, ReEntrance 
{
    using FixedPoint for uint;
    using FixedPoint for FixedPoint.uq112x112;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event BondCreated( uint deposit, uint indexed payout, uint indexed expires, uint indexed priceInUSD );
    event BondRedeemed( address indexed recipient, uint payout, uint remaining );
    event BondPriceChanged( uint indexed priceInUSD, uint indexed internalPrice, uint indexed debtRatio );
    event ControlVariableAdjustment( uint initialBCV, uint newBCV, uint adjustment, bool addition );

    address public immutable OHM; // token given as payment for bond
    address public immutable treasury; // mints OHM when receives principle
    address public immutable DAO; // receives profit share from bond
    address public immutable bondCalculator; // calculates value of LP tokens
    address public staking; // to auto-stake payout
    address public stakingHelper; // to stake and claim if no staking warmup
    bool public useHelper;

   struct Terms {
        uint controlVariable; // scaling variable for price
        uint vestingTerm; // in blocks
        uint minimumPrice; // vs principle value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint totalDebt;
        uint lastDecay;
        bool isLiquidityBond;
    }

    // Info for bond holder
    struct Bond {
        uint payout; // OHM remaining to be paid
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In DAI, for front end viewing
    }
    
    address[] public BondsList;
    // mapping(address => bool)public isBond;
    mapping(address => Terms)public BondTerms; // principle address => Terms Struct (generic for all users).
    // mapping(address => Info)public BondInfo; //  bond info (generic for all users).
    mapping(address => mapping(address => Bond))public DepositorInfo; // principal(user => bondPersonalInfo) user based information of bond..

    constructor(address _OHM,
        address _treasury, 
        address _DAO,
        address _calculator)
    {
        require( _OHM != address(0) );
        OHM = _OHM;
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _DAO != address(0) );
        DAO = _DAO;
        require(_calculator != address(0));
        bondCalculator = _calculator;
    }

    /**
    @param _principle is the Token address of which Bond is Created...
    @param _calculator is address(0) if it is not LPToken Bond..
    @notice Other parameters are Terms for that created Bond..
    @notice Principle address is registered as Bond Contract so that no other address is used as paarameter in deposit and redeem..
     */
    function createBond(
    address _principle,
    address _calculator,
    uint _controlVariable, 
    uint _vestingTerm,
    uint _minimumPrice,
    uint _maxPayout,
    uint _fee,
    uint _maxDebt,
    uint _initialDebt)public onlyOwner
    {
        // bond validation...
        require(!isBond(_principle), "Bond Already Exists!");
        require( _controlVariable > 0 );
        bool _isliquiditybond;
        if (_calculator != address(0))
        {
            _isliquiditybond = true;
        }
        else
        {
            _isliquiditybond = false;
        }
        Terms memory terms = Terms ({
            controlVariable: _controlVariable,
            vestingTerm: _vestingTerm,
            minimumPrice: _minimumPrice,
            maxPayout: _maxPayout,
            fee: _fee,
            maxDebt: _maxDebt,
            totalDebt: _initialDebt,
            lastDecay: block.number,
            isLiquidityBond: _isliquiditybond
        });

        BondTerms[_principle] = terms;
        BondsList.push(_principle);

    }
    function isBond(address _principle)public view returns(bool _isbond)
    {
        if(BondTerms[_principle].controlVariable == 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    enum PARAMETER { VESTING, PAYOUT, FEE, DEBT, MINIMUM_PRICE, BCV }
    function setBondTerms(address _principle, PARAMETER _parameter, uint _input)public onlyOwner
    {
        require(isBond(_principle), "Given principle is not Bond Token");
        if ( _parameter == PARAMETER.VESTING ) { // 0
            require( _input >= 0, "Vesting must be longer than given time" );
            BondTerms[_principle].vestingTerm = _input;
        } else if ( _parameter == PARAMETER.PAYOUT ) { // 1
            BondTerms[_principle].maxPayout = _input;
        } else if ( _parameter == PARAMETER.FEE ) { // 2
            require( _input <= 10000, "DAO fee cannot exceed payout" );
            BondTerms[_principle].fee = _input;
        } else if ( _parameter == PARAMETER.DEBT ) { // 3
            BondTerms[_principle].maxDebt = _input;
        } else if ( _parameter == PARAMETER.MINIMUM_PRICE ) { // 4
            BondTerms[_principle].minimumPrice = _input;
        } else if ( _parameter == PARAMETER.BCV ) { // 5
            BondTerms[_principle].controlVariable = _input;
        }
    }

    function deposit(address _principle, uint _amount, uint _maxPrice, address _depositor)public reEntrance returns(uint)
    {
        require( _depositor != address(0), "Invalid address" );
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        decayDebt(_principle);
        require( BondTerms[_principle].totalDebt <= BondTerms[_principle].maxDebt, "Max capacity reached" );
        
        uint priceInUSD = bondPriceInUSD(_principle); // Stored in bond info
        uint nativePrice = _bondPrice(_principle);

        require( _maxPrice >= nativePrice, "Slippage limit: more than max price" ); // slippage protection

        uint value = ITreasury( treasury ).valueOf( _principle, _amount );
        uint payout = payoutFor(_principle, value ); // payout to bonder is computed

        require( payout >= 10000000, "Bond too small" ); // must be > 0.01 OHM ( underflow protection )
        require( payout <= maxPayout(_principle), "Bond too large"); // size protection because there is no slippage

        // profits are calculated
        uint fee = payout.mul( BondTerms[_principle].fee ).div( 10000 );
        uint profit = value.sub( payout ).sub( fee );

        /**
            principle is transferred in
            approved and
            deposited into the treasury, returning (_amount - profit) OHM
         */
        IERC20( _principle ).safeTransferFrom( msg.sender, address(this), _amount );
        IERC20( _principle ).approve( address( treasury ), _amount );
        ITreasury( treasury ).deposit( _amount, _principle, profit );
        
        if ( fee != 0 ) { // fee is transferred to dao 
            IERC20( OHM ).safeTransfer( DAO, fee ); 
        }
        
        // total debt is increased
        BondTerms[_principle].totalDebt = BondTerms[_principle].totalDebt.add( value ); 
        uint __payout = DepositorInfo[_principle][ _depositor ].payout;
        // depositor info is stored
        DepositorInfo[_principle][ _depositor ] = Bond({ 
            payout: __payout.add( payout ),
            vesting: BondTerms[_principle].vestingTerm,
            lastBlock: block.number,
            pricePaid: priceInUSD
        });

        // indexed events are emitted
        emit BondCreated( _amount, payout, block.number.add( BondTerms[_principle].vestingTerm ), priceInUSD );
        emit BondPriceChanged( bondPriceInUSD(_principle), _bondPrice(_principle), debtRatio(_principle) );

        // adjust(); // control variable is adjusted
        return payout; 
    }

    function decayDebt(address _principle) internal {
        BondTerms[_principle].totalDebt = BondTerms[_principle].totalDebt.sub( debtDecay(_principle) );
        BondTerms[_principle].lastDecay = block.number;
    }

    function debtDecay(address _principle) public view returns ( uint decay_ ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        uint blocksSinceLast = block.number.sub( BondTerms[_principle].lastDecay );
        decay_ = BondTerms[_principle].totalDebt.mul( blocksSinceLast ).div( BondTerms[_principle].vestingTerm);
        if ( decay_ > BondTerms[_principle].totalDebt ) {
            decay_ = BondTerms[_principle].totalDebt;
        }
    }

    function _bondPrice(address _principle) internal returns ( uint price_ ) {
        price_ = BondTerms[_principle].controlVariable.mul( debtRatio(_principle) ).add( 1000000000 ).div( 1e7 );
        if ( price_ < BondTerms[_principle].minimumPrice ) {
            price_ = BondTerms[_principle].minimumPrice;        
        } else if ( BondTerms[_principle].minimumPrice != 0 ) {
            BondTerms[_principle].minimumPrice = 0;
        }
    }

    function debtRatio(address _principle) public view returns ( uint debtRatio_ ) {  
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!"); 
        uint supply = IERC20( OHM ).totalSupply();
        debtRatio_ = FixedPoint.fraction( 
            currentDebt(_principle).mul( 1e9 ), 
            supply
        ).decode112with18().div( 1e18 );
    }

    function currentDebt(address _principle) public view returns ( uint ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        return BondTerms[_principle].totalDebt.sub( debtDecay(_principle) );
    }

     function bondPriceInUSD(address _principle) public view returns ( uint price_ )
    {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        if( BondTerms[_principle].isLiquidityBond ) {
            price_ = bondPrice(_principle).mul( IBondCalculator( bondCalculator ).markdown( _principle ) ).div( 100 );
        } else {
            price_ = bondPrice(_principle).mul( 10 ** IERC20( _principle ).decimals() ).div( 100 );
        }
    }

    function bondPrice(address _principle) public view returns ( uint price_ ) {        
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        price_ = BondTerms[_principle].controlVariable.mul( debtRatio(_principle) ).add( 1000000000 ).div( 1e7 );
        if ( price_ < BondTerms[_principle].minimumPrice ) {
            price_ = BondTerms[_principle].minimumPrice;
        }
    }


    function payoutFor(address _principle, uint _value ) public view returns ( uint ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        return FixedPoint.fraction( _value, bondPrice(_principle) ).decode112with18().div( 1e16 );
    }


    function maxPayout(address _principle) public view returns ( uint ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        return IERC20( OHM ).totalSupply().mul( BondTerms[_principle].maxPayout ).div( 100000 );
    }

    function setStaking( address _staking, bool _helper ) external onlyOwner() {
        require( _staking != address(0) );
        if ( _helper ) {
            useHelper = true;
            stakingHelper = _staking;
        } else {
            useHelper = false;
            staking = _staking;
        }
    }


    function redeem( address _principle, address _recipient, bool _stake ) external reEntrance returns ( uint ) {   
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");     
        Bond memory info = DepositorInfo[_principle][ _recipient ];
        uint percentVested = percentVestedFor(_principle, _recipient ); // (blocks since last interaction / vesting term remaining)

        if ( percentVested >= 10000 ) { // if fully vested
            DepositorInfo[_principle][_recipient].payout = 0;
            DepositorInfo[_principle][_recipient].vesting = 0;
            DepositorInfo[_principle][_recipient].lastBlock = 0;
            DepositorInfo[_principle][_recipient].pricePaid = 0;
            emit BondRedeemed( _recipient, info.payout, 0 ); // emit bond data
            return stakeOrSend(_recipient, _stake, info.payout ); // pay user everything due

        } else { // if unfinished
            // calculate payout vested
            uint payout = info.payout.mul( percentVested ).div( 10000 );

            // store updated deposit info
            DepositorInfo[_principle][ _recipient ] = Bond({
                payout: info.payout.sub( payout ),
                vesting: info.vesting.sub( block.number.sub( info.lastBlock ) ),
                lastBlock: block.number,
                pricePaid: info.pricePaid
            });

            emit BondRedeemed( _recipient, payout, DepositorInfo[_principle][ _recipient ].payout );
            return stakeOrSend(_recipient, _stake, payout );
        }
    }


      function percentVestedFor(address _principle, address _depositor ) public view returns ( uint percentVested_ ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        Bond memory bond = DepositorInfo[_principle][ _depositor ];
        uint blocksSinceLast = block.number.sub( bond.lastBlock );
        uint vesting = bond.vesting;

        if ( vesting > 0 ) {
            percentVested_ = blocksSinceLast.mul( 10000 ).div( vesting );
        } else {
            percentVested_ = 0;
        }
    }


    function stakeOrSend(address _recipient, bool _stake, uint _amount ) internal returns ( uint ) {
        if ( !_stake ) { // if user does not want to stake
            IERC20( OHM ).transfer( _recipient, _amount ); // send payout
        } else { // if user wants to stake
            if ( useHelper ) { // use if staking warmup is 0
                IERC20( OHM ).approve( stakingHelper, _amount );
                IStakingHelper( stakingHelper ).stake( _amount, _recipient );
            } else {
                IERC20( OHM ).approve( staking, _amount );
                IStaking( staking ).stake( _amount, _recipient );
            }
        }
        return _amount;
    }

    function pendingPayoutFor(address _principle, address _depositor ) external view returns ( uint pendingPayout_ ) {
        require(isBond(_principle), "Given Principle is not registered as Bond Token!!");
        uint percentVested = percentVestedFor( _principle, _depositor );
        uint payout = DepositorInfo[_principle][ _depositor ].payout;

        if ( percentVested >= 10000 ) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul( percentVested ).div( 10000 );
        }
    }

    function Bondinfo(address _user, address _principle)public view returns(uint _payout, uint _vesting, uint _lastBlock, uint _pricePaid)
    {
        return(DepositorInfo[_principle][_user].payout,
        DepositorInfo[_principle][_user].vesting,
        DepositorInfo[_principle][_user].lastBlock,
        DepositorInfo[_principle][_user].pricePaid);
    }

    function lastDecay(address _principle)public view returns(uint _lastDeacy)
    {
        return(BondTerms[_principle].lastDecay);
    }
    function totalDebt(address _principle)public view returns(uint _totalDebt)
    {
        return(BondTerms[_principle].totalDebt);
    }
    function isLiquidityBond(address _principle)public view returns(bool _liquidity)
    {
        return(BondTerms[_principle].isLiquidityBond);
    }
    function _Terms(address _principle)public view returns(uint _controlVariable,
        uint _vestingTerm,
        uint _minimumPrice,
        uint _maxPayout,
        uint _fee,
        uint _maxDebt)
    {
        return(
            BondTerms[_principle].controlVariable,
            BondTerms[_principle].vestingTerm,
            BondTerms[_principle].minimumPrice,
            BondTerms[_principle].maxPayout,
            BondTerms[_principle].fee,
            BondTerms[_principle].maxDebt);
    }
    function bondsCount()public view returns(uint256 _count)
    {
        return BondsList.length;
    }
}
pragma solidity 0.7.6;

import "./_external/SafeMath.sol";
import "./_external/Ownable.sol";

import "./lib/SafeMathInt.sol";
import "./lib/UInt256Lib.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}    

interface I$ICOFraction {
    function totalSupply() external view returns (uint256);

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256);

    function balanceOf(address user) external view returns (uint256);
    
    function approve(address spender,uint256 value) external returns (bool);

    function mint(address to, uint256 value) external;

    function burn(address to, uint256 value) external;

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

interface IProviderPair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );

    function sync() external;

    function token0() external view returns(address);
    function token1() external view returns(address);
}

contract $ICOFractionPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event Stabilize(
        uint256 new$ICOSupply
    );
    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 targetRate,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    I$ICOFraction public $icoFracs;
    IERC20 public busd;
    IProviderPair[] public providerPairs;

    mapping(IProviderPair => IProviderPair) public pairWithBUSD;

    IProviderPair public ratePair;

    // If the current exchange rate is within this fractional distance from the target, no supply
    // update is performed.
    // (ie) abs(rate - targetRate) / targetRate < deviationThreshold, then no supply change.
    // DECIMALS Fixed point number.
    uint256 public deviationThreshold;

    // The number of rebase cycles since inception
    uint256 public epoch;

    uint256 private constant DECIMALS = 9;

    // Due to the expression in computeSupplyDelta(), MAX_RATE * MAX_SUPPLY must fit into an int256.
    // Both are 9 decimals fixed point numbers.
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    // MAX_SUPPLY = MAX_INT256 / MAX_RATE
    uint256 private constant MAX_SUPPLY = uint256(type(int256).max) / MAX_RATE;

    // This module handles the rebase execution and downstream notification.
    address public handler;

    modifier onlyHandler() {
        require(msg.sender == handler);
        _;
    }
  
    function abs(int x) private pure returns (uint) {
        uint y= uint(x >= 0 ? x : -x);
        return y;
    }   

    function checkDeviation(
        uint256 exchangeRateWithBUSD,
        uint256 exchangeRateWith$ICO
    ) internal pure returns (bool) {
        uint256 deviation;
        deviation =
            (abs(int256(exchangeRateWithBUSD - exchangeRateWith$ICO)) * 100) /
            exchangeRateWithBUSD;
        if (deviation > 5) {
            return true;
        }
        return false;
    }

    // For TOKEN/BUSD
    function getPriceData(IProviderPair providerPair) public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 timestamp;
        uint256 exchangeRate;
        (reserve0, reserve1, timestamp) = IProviderPair(providerPair).getReserves();
        // Check which coin is lesser decimal
        address token0= IProviderPair(providerPair).token0();
        address token1= IProviderPair(providerPair).token1();
        uint8 reserve0Decimal= IERC20(token0).decimals();
        uint8 reserve1Decimal = IERC20(token1).decimals();
        uint256 decimalDiff;

        if (reserve0Decimal > reserve1Decimal) {
            decimalDiff = uint256(reserve0Decimal - reserve1Decimal);
            reserve1 = uint112(reserve1 * uint112(10**decimalDiff));
        } else {
            decimalDiff = uint256(reserve1Decimal - reserve0Decimal);
            reserve0 = uint112(reserve0 * uint112(10**decimalDiff));
        }
        if(token0 == address(busd) || token0== address($icoFracs)){
            exchangeRate = (uint256((reserve0 * 10** DECIMALS )/ reserve1)); 
        }else{
            exchangeRate = (uint256((reserve1 * 10** DECIMALS ) / reserve0));
        }
        return (exchangeRate);
    }

    function getPriceData() public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 timestamp;
        uint256 exchangeRate;
        (reserve0, reserve1, timestamp) = IProviderPair(ratePair).getReserves();
        address token0 = IProviderPair(ratePair).token0();

        if(token0 == address($icoFracs)){
            
            exchangeRate = (uint256(reserve1/reserve0));    
        }else{
            exchangeRate = (uint256(reserve0/reserve1));
        }
        return (exchangeRate);
    }

    /**
     * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
     *
     * @dev The supply adjustment equals (_totalSupply * DeviationFromTargetRate)
     *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
     *      and targetRate is fixed to 1.
    */
    function rebase() external onlyHandler {
        epoch = epoch.add(1);

        uint256 targetRate = 10**DECIMALS; // $1
        uint256 exchangeRate;

        (exchangeRate) = getPriceData();
        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }
        int256 supplyDelta = computeSupplyDelta(exchangeRate, targetRate);

        if (
            supplyDelta > 0 &&
            $icoFracs.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY
        ) {
            supplyDelta = (MAX_SUPPLY.sub($icoFracs.totalSupply()))
                .toInt256Safe();
        }

        uint256 supplyAfterRebase = $icoFracs.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        for (uint256 i = 0; i < providerPairs.length; i++) {
            IProviderPair(providerPairs[i]).sync();
        }
        emit LogRebase(
            epoch,
            exchangeRate,
            targetRate,
            supplyDelta,
            block.timestamp
        );
    }

    function stabilize() public onlyHandler {
        for(uint8 i=0; i<providerPairs.length; i++){
            uint112 reserve0;
            uint112 reserve1;
            uint32 timestamp;
            uint8 decimalDiff;
            address token0;
            address token1;
            uint8 token0Decimals;
            uint8 token1Decimals;
            uint256 supplyToChange;
            (reserve0, reserve1, timestamp) = IProviderPair(providerPairs[i]).getReserves();
            //  for rate pair: $ICO/BUSD
            if (address(providerPairs[i]) == address(ratePair)) {
                token0 = IProviderPair(providerPairs[i]).token0(); 
                token1 = IProviderPair(providerPairs[i]).token1();
                token0Decimals = IERC20(token0).decimals();
                token1Decimals = IERC20(token1).decimals();

                if (token0Decimals > token1Decimals) {
                    decimalDiff = token0Decimals - token1Decimals;
                    reserve1 = uint112(reserve1 * (10**uint112(decimalDiff)));
                } else if (token0Decimals < token1Decimals) {
                    decimalDiff = token1Decimals - token0Decimals;
                    reserve0 = uint112(reserve0 * (10**uint112(decimalDiff)));
                }

                if(reserve0 > reserve1){
                    supplyToChange = uint256(reserve0 - reserve1);
                    supplyToChange = supplyToChange/(10**uint256(decimalDiff));
                    I$ICOFraction($icoFracs).burn(address(providerPairs[i]), supplyToChange);
                }
                else if(reserve0 < reserve1){
                    supplyToChange = uint256(reserve1 - reserve0);
                    supplyToChange = supplyToChange/(10**uint256(decimalDiff));
                    I$ICOFraction($icoFracs).mint(address(providerPairs[i]), supplyToChange);
                }
                else{
                    continue;
                }
            }
            // for other pairs
            else{
                stabilizeOtherPairs(providerPairs[i]);
            }   
            IProviderPair(providerPairs[i]).sync();
        }
        uint256 new$ICOSupply= I$ICOFraction($icoFracs).totalSupply();
        emit Stabilize(new$ICOSupply);
    }

    function stabilizeOtherPairs(IProviderPair _providerPair) internal{
        uint112 otherPair_reserve0;
        uint112 otherPair_reserve1;
        uint32 otherPair_timestamp;
        (otherPair_reserve0, otherPair_reserve1, otherPair_timestamp)
            =IProviderPair(pairWithBUSD[_providerPair]).getReserves();
        
        // Exchange rate of Other token with BUSD
        uint exchangeRateWithBUSD= getPriceData(pairWithBUSD[_providerPair]);  
        uint supplyChange;
        uint112 reserve0;
        uint112 reserve1;
        uint32 timestamp;
        address token0= IProviderPair(_providerPair).token0();
        address token1= IProviderPair(_providerPair).token1();   
        uint8 token1Decimals= IERC20(token1).decimals();  
        uint8 token0Decimals= IERC20(token0).decimals();  
        (reserve0, reserve1, timestamp) =IProviderPair(_providerPair).getReserves();
        // Exchange rate of Other token with $ICO
        uint exchangeRateWith$ICO= getPriceData(_providerPair);
        // CHECK DEVIATION
        if (checkDeviation(exchangeRateWithBUSD, exchangeRateWith$ICO)) {
            if (token0 == address($icoFracs)) {
                if (int256(exchangeRateWithBUSD - exchangeRateWith$ICO) > 0) {
                    supplyChange = uint256(
                        uint256(reserve1) *
                            uint256(exchangeRateWithBUSD - exchangeRateWith$ICO)
                    );
                    supplyChange = supplyChange.div(
                        10**uint256(token1Decimals)
                    );
                    I$ICOFraction($icoFracs).mint(
                        address(_providerPair),
                        supplyChange
                    );
                } else if (
                    int256(exchangeRateWith$ICO - exchangeRateWithBUSD) > 0
                ) {
                    supplyChange = uint256(
                        uint256(reserve1) *
                            uint256(exchangeRateWith$ICO - exchangeRateWithBUSD)
                    );
                    supplyChange = supplyChange.div(
                        10**uint256(token1Decimals)
                    );
                    I$ICOFraction($icoFracs).burn(
                        address(_providerPair),
                        supplyChange
                    );
                }
            } else {
                if (int256(exchangeRateWithBUSD - exchangeRateWith$ICO) > 0) {
                    supplyChange = uint256(
                        uint256(reserve0) *
                            uint256(exchangeRateWithBUSD - exchangeRateWith$ICO)
                    );
                    supplyChange = supplyChange.div(
                        10**uint256(token0Decimals)
                    );
                    I$ICOFraction($icoFracs).mint(
                        address(_providerPair),
                        supplyChange
                    );
                } else if (
                    int256(exchangeRateWith$ICO - exchangeRateWithBUSD) > 0
                ) {
                    supplyChange = uint256(
                        uint256(reserve0) *
                            uint256(exchangeRateWith$ICO - exchangeRateWithBUSD)
                    );
                    supplyChange = supplyChange.div(
                        10**uint256(token0Decimals)
                    );
                    I$ICOFraction($icoFracs).burn(
                        address(_providerPair),
                        supplyChange
                    );
                }
            }
        }
    }

    function addProviderPair(IProviderPair _$ICOProviderPair, IProviderPair _OtherTokenPairWithBUSD) external onlyOwner {
        if (providerPairs.length == 0) {
            ratePair = _$ICOProviderPair;
        }
        require(providerPairs.length <= 50, "cannot add more than 50");
        // require(address(_$ICOProviderPair) != address(0) && address(_OtherTokenPairWithBUSD)!=address(0), "Invalid Parameter Address");
        providerPairs.push(_$ICOProviderPair);
        // If the pair is with $ICO/BNB then, Other token pair is= BNB/BUSD
        pairWithBUSD[_$ICOProviderPair]= _OtherTokenPairWithBUSD;   
    }

    function set$ICOStableProvider(IProviderPair _ratePair) external onlyOwner {
        ratePair = _ratePair;
    }

    /**
     * @notice Sets the reference to the handler.
     * @param handler_ The address of the handler contract.
     */
    function setHandler(address handler_) external onlyOwner {
        handler = handler_;
    }

    /**
     * @notice Sets the deviation threshold fraction. If the exchange rate given by the market
     *         oracle is within this fractional distance from the targetRate, then no supply
     *         modifications are made. DECIMALS fixed point number.
     * @param deviationThreshold_ The new exchange rate threshold fraction.
     */
    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {
        deviationThreshold = deviationThreshold_;
    }

    /**
     * @notice A multi-chain $ICO interface method. The Imperium monetary policy contract
     *         on the base-chain and XC-ImperiumController contracts on the satellite-chains
     *         implement this method. It atomically returns two values:
     *         what the current contract believes to be,
     *         the globalImperiumEpoch and global$ICOSupply.
     * @return globalImperiumEpoch The current epoch number.
     * @return global$ICOSupply The total supply at the current epoch.
     */
    function globalImperiumEpochAnd$ICOSupply()
        external
        view
        returns (uint256, uint256)
    {
        return (epoch, $icoFracs.totalSupply());
    }

    /**
     * @dev ZOS upgradable contract initialization method.
     *      It is called at the time of contract creation to invoke parent class initializers and
     *      initialize the contract's state variables.
     */
    function initialize(address owner_, I$ICOFraction $icoFracs_, IERC20 _busd)
        public
        initializer
    {
        Ownable.initialize(owner_);
        // deviationThreshold = 0.05e18 = 5e16
        deviationThreshold = 5 * 10**(DECIMALS - 2);
        epoch = 0;
        $icoFracs = $icoFracs_;
        busd= _busd;
    }

    /**
     * @return Computes the total supply adjustment in response to the exchange rate
     *         and the targetRate.
     */
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        internal
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        // supplyDelta = totalSupply * (rate - targetRate) / targetRate
        int256 targetRateSigned = targetRate.toInt256Safe();
        return
            $icoFracs
                .totalSupply()
                .toInt256Safe()
                .mul(rate.toInt256Safe().sub(targetRateSigned))
                .div(targetRateSigned);
    }

    function removeProvider(IProviderPair _providerPair) external onlyOwner{
        require(_providerPair!=ratePair, "Cannot delete rate pair");
        bool flag=false;
        for(uint8 i=0;i < providerPairs.length; i++){
            if(providerPairs[i]== _providerPair){
                providerPairs[i]= providerPairs[providerPairs.length-1];
                providerPairs.pop();
                delete pairWithBUSD[_providerPair];
                flag = false;
                break;
            }else{
                flag = true;
         }
        }
        if(flag==true){
            revert();
        }
    }

    /**
     * @param rate The current exchange rate, an 18 decimal fixed point number.
     * @param targetRate The target exchange rate, an 18 decimal fixed point number.
     * @return If the rate is within the deviation threshold from the target rate, returns true.
     *         Otherwise, returns false.
     */

    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        internal
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate
            .mul(deviationThreshold)
            .div(10**DECIMALS);

        return
            (rate >= targetRate &&
                rate.sub(targetRate) < absoluteDeviationThreshold) ||
            (rate < targetRate &&
                targetRate.sub(rate) < absoluteDeviationThreshold);
    }
}

pragma solidity 0.7.6;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

pragma solidity 0.7.6;

import "./Initializable.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public virtual initializer {
        _owner = sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fractions, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.7.6;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

pragma solidity 0.7.6;

/**
 * @title Various utilities useful for uint256.
 */
library UInt256Lib {
    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }
}

pragma solidity 0.7.6;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.

        // MINOR CHANGE HERE:

        // previous code
        // uint256 cs;
        // assembly { cs := extcodesize(address) }
        // return cs == 0;

        // current code
        address _self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(_self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}
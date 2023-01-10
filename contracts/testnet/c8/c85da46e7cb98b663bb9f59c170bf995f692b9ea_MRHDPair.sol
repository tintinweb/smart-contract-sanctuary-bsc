/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: MIT
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: contracts/MRHDPairSetUp.sol

/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/



pragma solidity ^0.8.0;

contract MRHDPairSetUp{
    address public usdtaddress;//usdt合约地址
    uint256 public withdrawalfee;//提取手续费
    address public withdrawalfeeaddress;//提取手续费收益地址
    uint256 public transactionfees;//交易手续费
    address public transactionfeesaddress;//交易手续费收益地址
    
    //token配置：token地址 => 初始价格，计量单位，幅动价格，幅动增减值，触发倍数，decimals，USDT数量，最大买入token，最小买入token，最大卖出token，最小卖出token，最大买入USDT，最小买入USDT,最大卖出USDT，最小卖出USDT,当前价格，初始幅动价格
    mapping(address => uint256[17]) public tokenconfiguration;
    mapping(address => bool) public addedtoken;//已添加token
    mapping(address => address) public role;//token操作权限
    mapping(address => bool) public buyswitch;//买入开关
    mapping(address => bool) public sellswitch;//卖出开关
    mapping(string => uint256) public addressfluidity;//用户地址token地址 => token

    address owner;

    modifier isOwner() {
        require(msg.sender == owner, "Only the contract owner can call this method");
        _;
    }

    function changeOwner(address newOwner) public isOwner {
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }


    modifier isOwnerV2(address _token) {
        require(addedtoken[_token],"The token transaction pair is not added");
        require(msg.sender == owner || msg.sender == role[_token],"Only the contract owner or token manager can call this method");
        _;
    }

    modifier isOwnerV3(address _token) {
        require(msg.sender == owner || msg.sender == role[_token],"Only the contract owner or token manager can call this method");
        _;
    }

    struct Tokenconfiguration {
        uint256 initialprice;//初始价格
        uint256 price; //现价
        uint256 unitmeasurement;//计量单位
        uint256 swingprice;//幅动价格
        uint256 amplitudeincreasedecrease;//幅动增减值
        uint256 triggermultiple;//触发倍数
        uint256 initialswingprice;//触发倍数
        uint256 decimals;//精度
    }

    //设置提取手续费
    function setWithdrawalFee(uint256 _withdrawalfee) public isOwner{
        withdrawalfee = _withdrawalfee;
    }

    //设置提取手续费收益地址
    function setWithdrawalFeeAddress(address _withdrawalfeeaddress) public isOwner{
        withdrawalfeeaddress = _withdrawalfeeaddress;
    }

    //设置交易手续费
    function setTransactionfees(uint256 _transactionfees) public isOwner{
        transactionfees = _transactionfees;
    }

    //设置交易手续费收益地址
    function setTransactionFeesAddress(address _transactionfeesaddress) public isOwner{
        transactionfeesaddress = _transactionfeesaddress;
    }

    //设置初始价格、计量单位
    function setInitialPriceUnitMeasurement(uint256 _initialprice,uint256 _unitmeasurement,address _token) public isOwnerV2(_token){
        tokenconfiguration[_token][0] = _initialprice;
        tokenconfiguration[_token][1] = _unitmeasurement;
    }

    //设置幅动属性
    function setAmplitudeProperty(uint256 _swingprice,uint256 _amplitudeincreasedecrease,uint256 _triggermultiple,address _token) public isOwnerV2(_token){
        tokenconfiguration[_token][2] = _swingprice;
        tokenconfiguration[_token][3] = _amplitudeincreasedecrease;
        tokenconfiguration[_token][4] = _triggermultiple;
    }

    //设置usdt合约地址
    function setUsdtAddress(address _usdtaddress) public isOwner{
        usdtaddress = _usdtaddress;
    }

    //设置token交易范围
    function setTokentRadRange(uint256 _maxbuytoken,uint256 _minbuytoken,uint256 _maxselltoken,uint256 _minselltoken,address _token) public isOwnerV2(_token){
        tokenconfiguration[_token][7] = _maxbuytoken;
        tokenconfiguration[_token][8] = _minbuytoken;
        tokenconfiguration[_token][9] = _maxselltoken;
        tokenconfiguration[_token][10] = _minselltoken;
    }

    //设置usdt交易范围
    function setUsdtRadRange(uint256 _maxbuyusdt,uint256 _minbuyusdt,uint256 _maxsellusdt,uint256 _minsellusdt,address _token) public isOwnerV2(_token){
        tokenconfiguration[_token][11] = _maxbuyusdt;
        tokenconfiguration[_token][12] = _minbuyusdt;
        tokenconfiguration[_token][13] = _maxsellusdt;
        tokenconfiguration[_token][14] = _minsellusdt;
    }

    //token权限转移
    function powerTransferToken(address _token,address _manager_new) public isOwnerV3(_token){
        role[_token] = _manager_new;
    }

    //获取token交易对价格
    function getTradPairPrice(address _token) public view returns (uint256){
        return tokenconfiguration[_token][15];
    }

    //设置token买入交易开关
    function setSellSwitch(address _token,bool _status) public isOwnerV3(_token){
        sellswitch[_token] = _status;
    }

    //设置token卖出交易开关
    function setBuySwitch(address _token,bool _status) public isOwnerV3(_token){
        buyswitch[_token] = _status;
    }

    //address转string
    function addressToString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    //字符串拼接
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    //按枚数购买算法
    function algorithmBuyNumber(uint256[17] memory _tokenconfiguration, uint256 _amount, uint256 usdt_sum) public pure returns (uint256 usdt_sum_n,uint256[17] memory _tokenconfiguration_n) {
        Tokenconfiguration memory t = Tokenconfiguration(_tokenconfiguration[0],_tokenconfiguration[15],_tokenconfiguration[1],_tokenconfiguration[2],_tokenconfiguration[3],_tokenconfiguration[4],_tokenconfiguration[16],_tokenconfiguration[5]);
        uint256 maxbuytoken = _tokenconfiguration[7];//获取最大买入token
        uint256 minbuytoken = _tokenconfiguration[8];//获取最小买入token
        require(_amount % t.unitmeasurement == 0,"The transaction quantity must be an integral multiple of the unit of measure");
        require(_amount < maxbuytoken && _amount > minbuytoken,"Purchase quantity exceeded");
        bool flang = true;
        while(flang){
            uint256 a = ((t.swingprice / t.initialswingprice) * t.triggermultiple * t.initialprice - t.price) / t.swingprice * t.unitmeasurement;//计算距离最近一次价格幅动相差枚数
            if(_amount >= a){
                usdt_sum = usdt_sum + (t.price + (t.price + t.swingprice * (a - 1 * 10 ** t.decimals))) * a / 2;
                _amount = _amount - a;
                t.price = t.price + a * t.swingprice;
                t.swingprice = t.swingprice + t.amplitudeincreasedecrease;
                if(_amount == 0){
                    flang = false;
                }
            }else {
                if(_amount != 0){
                    usdt_sum = usdt_sum + (t.price + (t.price + t.swingprice * (_amount - 1 * 10 ** t.decimals))) * _amount / 2;
                    t.price = t.price + _amount * t.swingprice;
                }
                flang = false;
            }
        }
        _tokenconfiguration[2] = t.swingprice;
        _tokenconfiguration[15] = t.price;
        return (usdt_sum,_tokenconfiguration);
    }

    //按枚数卖出算法
    function algorithmSellNumber(uint256[17] memory _tokenconfiguration, uint256 _amount, uint256 usdt_sum) public pure returns (uint256 usdt_sum_n,uint256[17] memory _tokenconfiguration_n) {
        Tokenconfiguration memory t = Tokenconfiguration(_tokenconfiguration[0],_tokenconfiguration[15],_tokenconfiguration[1],_tokenconfiguration[2],_tokenconfiguration[3],_tokenconfiguration[4],_tokenconfiguration[16],_tokenconfiguration[5]);
        uint256 maxselltoken = _tokenconfiguration[9];//获取最大卖出tokenv
        uint256 minselltoken = _tokenconfiguration[10];//获取最小卖出token
        require(_amount % t.unitmeasurement == 0,"The transaction quantity must be an integral multiple of the unit of measure");
        require(_amount < maxselltoken && _amount > minselltoken,"Purchase quantity exceeded");
        bool flang = true;
        while(flang){
            if(t.swingprice / t.initialswingprice > 1 ){
                uint256 a = (t.price - (t.swingprice / t.initialswingprice - 1) * t.triggermultiple * t.initialprice) / t.swingprice * t.unitmeasurement;//计算距离最近一次价格幅动相差枚数
                if(_amount >= a){
                    usdt_sum = usdt_sum + (t.price - t.swingprice + t.price - t.swingprice * a) * a / 2 - t.swingprice;
                    _amount = _amount - a;
                    t.price = t.price - a * t.swingprice / t.unitmeasurement;
                    t.swingprice = t.swingprice - t.amplitudeincreasedecrease;
                    if(_amount == 0){
                        flang = false;
                    }
                }else {
                    usdt_sum = usdt_sum + (t.price - t.swingprice + t.price - t.swingprice * _amount) * _amount / 2 - t.swingprice;
                    t.price = t.price - _amount * t.swingprice / t.unitmeasurement;
                    _amount = 0;
                    flang = false;
                }
            }else {
                if(t.price > t.initialprice){
                    uint256 a = (t.price - t.initialprice) / t.swingprice * t.unitmeasurement;//计算影响价格枚数
                    if(_amount >= a){
                        usdt_sum = usdt_sum + (t.price - t.swingprice + t.price - t.swingprice * a) * a / 2 - t.swingprice;
                        _amount = _amount - a;
                        t.price = t.initialprice;
                        if(_amount == 0){
                            flang = false;
                        }
                    }else {
                        usdt_sum = usdt_sum + t.price * _amount - t.swingprice;
                        _amount = 0;
                        flang = false;
                    }
                }else{
                    usdt_sum = usdt_sum + t.price * _amount - t.swingprice;
                    _amount = 0;
                    flang = false;
                }
                
            }
            
        }
        _tokenconfiguration[2] = t.swingprice;
        _tokenconfiguration[15] = t.price;
        return (usdt_sum,_tokenconfiguration);
    }

    //按USDT购买算法
    function usdtBuyNumber(uint256[17] memory _tokenconfiguration, uint256 _amount, uint256 _token_sum) public pure returns (uint256 token_sum_n,uint256[17] memory _tokenconfiguration_n) {
        Tokenconfiguration memory t = Tokenconfiguration(_tokenconfiguration[0],_tokenconfiguration[15],_tokenconfiguration[1],_tokenconfiguration[2],_tokenconfiguration[3],_tokenconfiguration[4],_tokenconfiguration[16],_tokenconfiguration[5]);
        uint256 maxsellusdt = _tokenconfiguration[11];//获取最大卖出USDT
        uint256 minsellusdt = _tokenconfiguration[12];//获取最小卖出USDT
        require(_amount < maxsellusdt && _amount > minsellusdt,"Purchase quantity exceeded");
        bool flang = true;
        while(flang){
            uint256 a = ((t.swingprice / t.initialswingprice + 1) * t.triggermultiple * t.initialprice - t.price) / t.swingprice * t.unitmeasurement;//计算距离最近一次价格幅动相差枚数
            uint256 np = (t.price + (t.price + t.swingprice * (a - 1 * 10 ** t.decimals))) * a / 2;//计算消耗U
            if(_amount >= np){
                _token_sum = _token_sum + a;
                _amount = _amount - np;
                t.price = t.price + a * t.swingprice / t.unitmeasurement;
                t.swingprice = t.swingprice + t.amplitudeincreasedecrease;
            }else {
                //计算枚数
                uint256 x = Math.sqrt(2 * _amount / t.swingprice + (t.price / t.swingprice - 1) ** 2) - (t.price / t.swingprice - 1);
                x = x / t.unitmeasurement * t.unitmeasurement;
                t.price = t.price + x * t.swingprice / t.unitmeasurement;
                _token_sum = _token_sum + x;
                flang = false;
            }
        }
        _tokenconfiguration[2] = t.swingprice;
        _tokenconfiguration[15] = t.price;
        return (_token_sum,_tokenconfiguration);
    }

    //按USDT卖出算法
    function usdtSellNumber(uint256[17] memory _tokenconfiguration, uint256 _amount, uint256 _token_sum) public pure returns (uint256 token_sum_n,uint256[17] memory _tokenconfiguration_n) {
        Tokenconfiguration memory t = Tokenconfiguration(_tokenconfiguration[0],_tokenconfiguration[15],_tokenconfiguration[1],_tokenconfiguration[2],_tokenconfiguration[3],_tokenconfiguration[4],_tokenconfiguration[16],_tokenconfiguration[5]);
        uint256 maxbuyusdt = _tokenconfiguration[11];//获取最大卖出USDT
        uint256 minbuyusdt = _tokenconfiguration[12];//获取最小卖出USDT
        require(_amount < maxbuyusdt && _amount > minbuyusdt,"Purchase quantity exceeded");
        bool flang = true;
        while(flang){
            if(t.swingprice / t.initialswingprice > 1 ){
                uint256 a = (t.price - (t.swingprice / t.initialswingprice - 1) * t.triggermultiple * t.initialprice) / t.swingprice * t.unitmeasurement;//计算距离最近一次价格幅动相差枚数
                uint256 np = (t.price - t.swingprice + t.price - t.swingprice * a) * a / 2;
                if(_amount >= np){
                    _token_sum = _token_sum + a;
                    _amount = _amount - np;
                    t.price = t.price - a * t.swingprice / t.unitmeasurement;
                    t.swingprice = t.swingprice - t.amplitudeincreasedecrease;
                    if(_amount == 0){
                        flang = false;
                    }
                }else {
                    uint256 x = (t.price / t.swingprice - 1) - Math.sqrt((t.price / t.swingprice - 1) ** 2 - 2 * _amount / t.swingprice);
                    x = x / t.unitmeasurement * t.unitmeasurement;
                    _token_sum = _token_sum + x;
                    t.price = t.price - x * t.swingprice / t.unitmeasurement;
                    flang = false;
                }
            }else {
                if(t.price > t.initialprice){
                    uint256 a = (t.price - t.initialprice) / t.swingprice * t.unitmeasurement;//计算影响价格枚数
                    uint256 np = (t.price - t.swingprice + t.price - t.swingprice * a) * a / 2;
                    if(_amount >= np){
                        _token_sum = _token_sum + a;
                        _amount = _amount - np;
                        t.price = t.initialprice;
                        if(_amount == 0){
                            flang = false;
                        }
                    }else {
                        uint256 x = (t.price / t.swingprice - 1) - Math.sqrt((t.price / t.swingprice - 1) ** 2 - 2 * _amount / t.swingprice);
                        x = x / t.unitmeasurement * t.unitmeasurement;
                        _token_sum = _token_sum + x;
                        t.price = t.price - x * t.swingprice / t.unitmeasurement;
                        flang = false;
                    }
                }else{
                    uint256 x = _amount / t.price;
                    x = x / t.unitmeasurement * t.unitmeasurement;
                    _token_sum = _token_sum + x;
                    flang = false;
                }
                
            }
        }
        _tokenconfiguration[15] = t.price;
        _tokenconfiguration[2] = t.swingprice;
        return (_token_sum,_tokenconfiguration);
    }
}
// File: contracts/MRHDPair.sol

/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/



pragma solidity ^0.8.0;

contract MRHDPair is MRHDPairSetUp{
    constructor(address _usdtaddress) {
        owner = msg.sender;
        usdtaddress = _usdtaddress;
    }

    //添加交易对
    function addPair(address _token, uint256[15] memory nums) public isOwner{
        tokenconfiguration[_token] = nums;
        tokenconfiguration[_token][15] = nums[0];
        tokenconfiguration[_token][16] = nums[2];
        buyswitch[_token] = false;
        sellswitch[_token] = false;
        addedtoken[_token] = true;
        role[_token] = msg.sender;
    }

    //获取交易对
    function getPair(address _token) public view isOwner returns (uint256 a, uint256 b, uint256[17] memory c){
        return (IERC20(_token).balanceOf(address(this)),IERC20(usdtaddress).balanceOf(address(this)),tokenconfiguration[_token]);
    }

    //添加流动性
    function addLiquidity(address _token, uint256 amount) public {
        require(amount > uint256(0),"Add quantity is greater than 0");
        require(addedtoken[_token],"No trading pair added");
        require(IERC20(_token).balanceOf(msg.sender) >= amount,"Insufficient balance");
        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint256 usdtamount = amount * tokenconfiguration[_token][15] * (tokenconfiguration[_token][5] / 10 ** 18);
        IERC20(usdtaddress).transferFrom(msg.sender, address(this), usdtamount);
        tokenconfiguration[_token][6] = tokenconfiguration[_token][6] + usdtamount;
        string memory key = strConcat(addressToString(msg.sender),addressToString(_token));
        addressfluidity[key] = addressfluidity[key] + amount;
    }

    //提取流动性
    function extractLiquidity(address _token, uint256 amount) public {
        require(amount > uint256(0),"Add quantity is greater than 0");
        string memory key = strConcat(addressToString(msg.sender),addressToString(_token));
        require(addressfluidity[key] > amount,"Withdrawal amount exceeds liquidity balance");
        IERC20(_token).transfer(address(this), amount);
        uint256 usdtamount = amount * tokenconfiguration[_token][15] * (tokenconfiguration[_token][5] / 10 ** 18);
        IERC20(usdtaddress).transfer(address(this), amount);
        tokenconfiguration[_token][6] = tokenconfiguration[_token][6] - usdtamount;
        addressfluidity[key] = addressfluidity[key] - amount;
    }

    //交易,status_b[true：按枚，flase：按USDT],status_t[true：买入，flase：卖出]
    function swap(address _token, bool status_b, bool status_t,uint256 _amount) public payable {
        require(addedtoken[_token],"Purchase quantity exceeded");
        uint256 m;
        uint256[17] memory n;
        if(status_b){
            require(buyswitch[_token],"Suspension of trading");
            require(_amount % tokenconfiguration[_token][1] == 0,"The buying and selling quantity must be an integral multiple of the unit of measure");
            if(status_t){
                (m,n) = algorithmBuyNumber(tokenconfiguration[_token],_amount,0);
                IERC20(usdtaddress).transferFrom(msg.sender, address(this), m * (tokenconfiguration[_token][5] / 10 * 18));
                IERC20(_token).transfer(address(this),_amount);
            }else{
                (m,n) = algorithmSellNumber(tokenconfiguration[_token],_amount,0);
                require(tokenconfiguration[_token][6] >= m,"001");
                IERC20(_token).transferFrom(msg.sender, address(this), _amount);
                IERC20(usdtaddress).transfer(address(this),m * (tokenconfiguration[_token][5] / 10 * 18));
            }
        }else{
            require(sellswitch[_token],"Suspension of trading");
            if(status_t){
                (m,n) = usdtBuyNumber(tokenconfiguration[_token],_amount,0);
                IERC20(usdtaddress).transferFrom(msg.sender, address(this), _amount * (tokenconfiguration[_token][5] / 10 * 18));
                IERC20(_token).transfer(address(this),m);
            }else{
                (m,n) = usdtSellNumber(tokenconfiguration[_token],_amount,0);
                require(tokenconfiguration[_token][6] >= _amount,"001");
                IERC20(_token).transferFrom(msg.sender, address(this), m);
                IERC20(usdtaddress).transfer(address(this),_amount * (tokenconfiguration[_token][5] / 10 * 18));
            }
        }
        tokenconfiguration[_token] = n;
    }
}
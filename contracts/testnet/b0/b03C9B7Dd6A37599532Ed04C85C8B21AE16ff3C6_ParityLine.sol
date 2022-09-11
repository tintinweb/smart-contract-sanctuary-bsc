// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../main/libraries/Math.sol";


contract ParityLine is Ownable  {
    using Math for uint256;

uint256 public a = 7876;
uint256 public b = 800;
uint256 public sigma_a = 6275;
uint256 public sigma_b = 6127;
uint256 public sigma_c = 473;

uint256 public r_a = 5000;
uint256 public r_b = 2000;
uint256 public r_c = 800;

function setSigma (uint256 _sigma_a, uint256 _sigma_b, uint256 _sigma_c) 
    external onlyOwner{
    sigma_a = _sigma_a;
    sigma_b = _sigma_b;
    sigma_c = _sigma_c;   
}

function setParityLineCoeff(uint256 _a, uint256 _b) 
    external onlyOwner{
    a = _a;
    b = _b;
}

function setDistCoeff(uint256 _r_a, uint256 _r_b, uint256 _r_c) 
    external onlyOwner{
    r_a = _r_a;
    r_b = _r_b;
    r_c = _r_c;
}


function distToParity ( uint256 _risk, uint256 _return) public view returns 
    ( uint256 _d_alpha_p, uint256 _d_beta_p, uint256 _d_gamma_p ) {

     _d_alpha_p = ((Math.abs(int256(sigma_a) - int256(_risk))*10**9))**2 +
    ((Math.abs(int256(r_a) - int256(_return)) * 10**9) ) ** 2;

    _d_beta_p = ((Math.abs(int256(sigma_b) - int256( _risk)) *10**9))**2 +
     ((Math.abs(int256(r_b) - int256(_return)) * 10**9)) ** 2;

    _d_gamma_p = ((Math.abs(int256(sigma_c) - int256(_risk)) *10**9))**2 +
    ((Math.abs(int256(r_c) - int256(_return)) * 10**9))** 2;
    _d_alpha_p = sqrt( _d_alpha_p);
    _d_beta_p = sqrt( _d_beta_p);
    _d_gamma_p = sqrt( _d_gamma_p);
}


function calculateReturn(uint256 _risk) public view 
    returns ( uint256 _return) {

    _return = a * _risk / 10 **4 + b;
}

function ConvertRisk(uint256 _risk) public view 
    returns ( uint256 _return, uint256 _weight_alpha, 
        uint256 _weight_beta, uint256 _weight_gamma) {

    _return = ((a * _risk) / 10 **4) + b;

    (uint256 _d_alpha_p, uint256 _d_beta_p,  uint256 _d_gamma_p) =
    distToParity (_risk,  _return);

    uint256 _sum = (10**17/ _d_alpha_p) +  (10**17/ _d_beta_p) +
                   (10**17/ _d_gamma_p);
              
    _weight_alpha = (10**21/ _d_alpha_p) / _sum;
    _weight_beta = (10**21/ _d_beta_p) / _sum;
    _weight_gamma = 10**4 - (_weight_alpha + _weight_beta);   
}


function ConvertReturn(uint256 _return) public view 
    returns ( uint256 _risk, uint256 _weight_alpha, 
        uint256 _weight_beta, uint256 _weight_gamma) {

        _risk = ((_return - b) * 10**4)/ a;
    
    (uint256 _d_alpha_p, uint256 _d_beta_p, uint256 _d_gamma_p) =
    distToParity (_risk,  _return);

    uint256 _sum = (10**17/ _d_alpha_p) +  (10**17/ _d_beta_p) +
                   (10**17/ _d_gamma_p);
                   
    _weight_alpha = (10**21/ _d_alpha_p) / _sum;
    _weight_beta = (10**21/ _d_beta_p) / _sum;
    _weight_gamma = 10**4 - (_weight_alpha + _weight_beta);   
}

function calculateWeights(uint256 _d_alpha_p, uint256 _d_beta_p, uint256 _d_gamma_p)
     public pure  returns(uint256 _sum, uint256 _weight_alpha, uint256 _weight_beta, uint256 _weight_gamma){

    _sum = (10**17/ _d_alpha_p) +  (10**17/ _d_beta_p) +
                   (10**17/ _d_gamma_p);
                   
    _weight_alpha = (10**21/ _d_alpha_p) / _sum;
    _weight_beta = (10**21/ _d_beta_p) / _sum;
    _weight_gamma = 10**4 - (_weight_alpha + _weight_beta);   
}


function ConvertWeights(uint256 _weight_alpha, 
        uint256 _weight_beta, uint256 _weight_gamma) public view 
    returns ( uint256 _risk, uint256 _return) {

    _return = (_weight_alpha * r_a + _weight_beta * r_b +
             _weight_gamma * r_c) / 10**4; 
    
    _risk = ((_return -b) * 10**4)/ a;
   
}



// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as an uint256.
function sqrt(uint256 x) public pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // Calculate the square root of the perfect square of a power of two that is the closest to x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 0x100000000) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 0x10000) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 0x100) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 0x10) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 0x8) {
        result <<= 1;
    }

    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1; // Seven iterations should be enough
        uint256 roundedDownResult = x / result;
        return result >= roundedDownResult ? roundedDownResult : result;
    }
}
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.4;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

pragma solidity 0.5.16;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract BasketManager {

    using SafeMath for uint256;

    // state
    address[] private bassetsArray;
    mapping(address => bool) private bassetsMap;
    mapping(address => int256) private factorMap;
    mapping(address => address) private bridgeMap;

    function _isValidBasset(address _basset) internal view returns(bool) {
        return _basset != address(0) && bassetsMap[_basset];
    }

    // external
    constructor(address[] memory _bassets, int256[] memory _factors, address[] memory _bridges) public {
        require(_bassets.length > 0, "some basset required");
        require(_bassets.length == _factors.length, "factor array length mismatch");
        require(_bridges.length == _factors.length, "bridge array length mismatch");

        bassetsArray = _bassets;
        for(uint i=0; i<bassetsArray.length; i++) {
            address basset = bassetsArray[i];
            require(basset != address(0), "invalid basset address");
            require(!bassetsMap[basset], "basset not unique");
            bassetsMap[basset] = true;
            require(_factors[i] != 0, "invalid factor");
            factorMap[basset] = _factors[i];
            if(_bridges[i] != address(0)) {
                bridgeMap[basset] = _bridges[i];
            }
        }
    }

    function isValidBasset(address _basset) external view returns(bool) {
        return _isValidBasset(_basset);
    }

    function checkBasketBalanceForDeposit(address _basset, uint256 _bassetQuantity) external view returns(bool) {
        return _isValidBasset(_basset);
    }

    function checkBasketBalanceForWithdrawal(address _basset, uint256 _bassetQuantity) external view returns(bool) {
        return _isValidBasset(_basset);
    }

// calculate massetQuantity per basset using _bassetQuantity and factor
    function convertBassetToMassetQuantity(address _basset, uint256 _bassetQuantity) external view returns(uint256) {
        require(_isValidBasset(_basset), "invalid basset");
        int256 factor = factorMap[_basset];
        if(factor > 0) {
            return _bassetQuantity.div(uint256(factor));
        }
        return _bassetQuantity.mul(uint256(-factor));
    }

    function convertMassetToBassetQuantity(address _basset, uint256 _massetQuantity) external view returns(uint256) {
        require(_isValidBasset(_basset), "invalid basset");
        int256 factor = factorMap[_basset];
        if(factor > 0) {
            return _massetQuantity.mul(uint256(factor));
        }
        return _massetQuantity.div(uint256(-factor));
    }

    function getBridge(address _basset) external view returns(address) {
        return bridgeMap[_basset];
    }

    function getVersion() external pure returns(string memory) {
        return "2.0";
    }
}
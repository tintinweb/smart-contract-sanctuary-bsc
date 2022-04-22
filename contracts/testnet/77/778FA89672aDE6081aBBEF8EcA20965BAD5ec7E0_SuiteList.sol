pragma solidity ^0.7.6;
// SPDX-License-Identifier: Apache License 2.0

import "../Common/Ownable.sol";
import "./ISuiteFactory.sol";
import "./ISuite.sol";
import "../SafeMath.sol";

contract SuiteList is Ownable {
    using SafeMath for uint256;

    address[] public _suites;
    ISuiteFactory public _suiteFactory;
    address public _whiteList;
    mapping(address => uint256) public _suiteIndexes;
    mapping(address => address) public _suiteOwners;

    mapping(address => uint256[]) public _suiteIndexesByUserMap;
    mapping(address => address[]) public _suitesMap2;

    constructor(address suiteFactory) {
        _suiteFactory = ISuiteFactory(suiteFactory);
    }

    fallback() external {
        // solhint-disable-next-line reason-string
        revert();
    }

    modifier onlyOwnerOrSuiteOwner(address suiteAddress) {
        require(
            _isSuiteOwner(suiteAddress) || isOwner(),
            "only Gov or suite owner can call"
        );
        _;
    }

    modifier onlyOwnerOrSuiteFactory() {
        require(
            _isSuiteFactory() || isOwner(),
            "Only Gov or SuiteFactory can call"
        );
        _;
    }

    modifier onlySuiteFactory() {
        require(_isSuiteFactory(), "only SuiteFactory can call");
        _;
    }

    function addSuite(address suiteAddress, address suiteOwner)
        external
        onlyOwnerOrSuiteFactory
    {
        uint256 index = _suites.length;
        _suites.push(suiteAddress);
        _suiteIndexes[suiteAddress] = index;
        _suiteOwners[suiteAddress] = suiteOwner;
        _suiteIndexesByUserMap[suiteOwner].push(index);
    }

    function deleteSuite(address suiteAddress)
        external
        onlyOwnerOrSuiteOwner(suiteAddress)
    {
        require(_isSuiteExists(suiteAddress), "Suite not exists");

        uint256 index = _suiteIndexes[suiteAddress];
        delete _suiteIndexes[suiteAddress];
        delete _suiteOwners[suiteAddress];

        if (index >= _suites.length) {
            return;
        }

        uint256 lastIndex = _suites.length - 1;

        if (index != lastIndex) {
            delete _suites[index];
            _suites[index] = _suites[lastIndex];
        }

        _suites.pop();
    }

    function isSuiteExists(address suiteAddress) external view returns (bool) {
        return _isSuiteExists(suiteAddress);
    }

    function _isSuiteExists(address suiteAddress) internal view returns (bool) {
        if (_suites.length == 0) return false;
        uint256 suiteIndex = _suiteIndexes[suiteAddress];
        return _suites[suiteIndex] == suiteAddress;
    }

    function getSuitesCount() external view returns (uint256) {
        return _suites.length;
    }

    function getUserSuitesCount(address user) external view returns (uint256) {
        return _suiteIndexesByUserMap[user].length;
    }

    function getUserSuitesByPage(
        address user,
        uint256 startIndex,
        uint256 count
    ) external view returns (address[] memory) {
        require(count <= 30, "Count must be less than 30");
        uint256 border = startIndex.add(count);

        if (border > _suiteIndexesByUserMap[user].length) {
            border = _suiteIndexesByUserMap[user].length;
        }
        uint256 returnCount = border.sub(startIndex);
        address[] memory result = new address[](returnCount);

        for (uint256 i = startIndex; i < border; i++) {
            uint256 currentIndex = i - startIndex;
            uint256 currentSuite = _suiteIndexesByUserMap[user][i];
            result[currentIndex] = _suites[currentSuite];
        }
        return result;
    }

    function getSuitesByPage(uint256 startIndex, uint256 count)
        external
        view
        returns (address[] memory)
    {
        require(count <= 30, "Count must be less than 30");
        // uint256 border = startIndex + count;
        uint256 border = startIndex.add(count);

        if (border > _suites.length) {
            border = _suites.length;
        }
        uint256 returnCount = border.sub(startIndex);
        address[] memory result = new address[](returnCount);

        for (uint256 i = startIndex; i < border; i++) {
            uint256 currentIndex = i - startIndex;
            result[currentIndex] = _suites[i];
        }
        return result;
    }

    function setSuiteFactory(address factoryAddress) external {
        _suiteFactory = ISuiteFactory(factoryAddress);
    }

    function setWhiteList(address whiteList) external onlyOwner {
        _whiteList = whiteList;
    }

    function changeSuiteOwner(address suiteAddress, address candidateAddress)
        external
        // onlySuiteOwner(suiteAddress)
    {
        _suiteOwners[suiteAddress] = candidateAddress;
    }

    function _isSuiteOwner(address suiteAddress) internal view returns (bool) {
        return ISuite(suiteAddress).owner() == msg.sender;
    }

    function isSuiteOwner(address suiteAddress) external view returns (bool) {
        return _isSuiteOwner(suiteAddress);
    }

    function _isSuiteFactory() internal view returns (bool) {
        return address(_suiteFactory) == msg.sender;
    }
}

pragma solidity >=0.5.16;
// "SPDX-License-Identifier: Apache License 2.0"


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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

interface ISuiteFactory {
    function deploySuite() external returns (address);

    function setSuiteList(address suiteList) external;
}

pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

interface ISuite {
    function owner() external view returns (address);

    function contracts(bytes32 contractType) external view returns (address);

    function addContract(bytes32 contractType, address contractAddress)
        external;
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        emit OwnershipTransferred(_owner, address(0));
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
}
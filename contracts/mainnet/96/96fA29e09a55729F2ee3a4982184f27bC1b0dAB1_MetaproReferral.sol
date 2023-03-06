// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
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
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
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
     * Requirements:
     *
     * - The divisor cannot be zero.
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
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
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
     * Requirements:
     *
     * - The divisor cannot be zero.
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
     * Requirements:
     *
     * - The divisor cannot be zero.
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaproReferral is Ownable {
    using SafeMath for uint256;

    struct ReferralDeposits {
        address contractAddress;
        uint256 auctionId;
        uint256 tokenId;
        address depositer;
        uint256 level;
        uint256 provision;
    }

    struct ReferralEearnings {
        uint256 all;
        uint256 level1;
        uint256 level2;
        uint256 level3;
    }

    struct ReferralStructure {
        address uplineReferrer;
        address[] level1;
        address[] level2;
        address[] level3;
    }

    mapping(address => uint256) public referredCount; // referrer_address -> num_of_referred

    mapping(address => address) private activeReferral;

    mapping(address => mapping(address => ReferralDeposits[]))
        private referralContractDeposits;

    mapping(address => ReferralDeposits[]) private referralDeposits;

    mapping(address => ReferralStructure) public referralStructure;

    mapping(address => mapping(address => ReferralEearnings))
        private referralContractEarnings;

    mapping(address => ReferralEearnings) private referralEarnings;

    event SetReferral(address indexed referrer, address indexed referred);
    event ReferralDeposit(
        address indexed referrer,
        address contractAddress,
        uint256 indexed auctionId,
        uint256 tokenId,
        address depositer,
        uint256 level,
        uint256 indexed provision
    );
    event NextOwnerApproved(address indexed _owner);
    event AdminStatus(address indexed _admin, bool _status);

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "OnlyAdmin methods called by non-admin.");
        _;
    }

    function saveReferralDeposit(
        address _referrer,
        address _contractAddress,
        uint256 _auctionId,
        uint256 _tokenId,
        address _depositer,
        uint256 _level,
        uint256 _provision
    ) external {
        ReferralDeposits memory referralDeposit = ReferralDeposits(
            _contractAddress,
            _auctionId,
            _tokenId,
            _depositer,
            _level,
            _provision
        );

        ReferralStructure storage refStructure = referralStructure[_referrer];

        // Add the referral address to the appropriate level array
        if (
            _level == 1 &&
            !checkIfDepositerExists(refStructure.level1, _depositer)
        ) {
            refStructure.level1.push(_depositer);
        } else if (
            _level == 2 &&
            !checkIfDepositerExists(refStructure.level2, _depositer)
        ) {
            refStructure.level2.push(_depositer);
        } else if (
            _level == 3 &&
            !checkIfDepositerExists(refStructure.level3, _depositer)
        ) {
            refStructure.level3.push(_depositer);
        }

        setReferralEarnings(_referrer, _provision, _contractAddress, _level);

        referralDeposits[_referrer].push(referralDeposit);
        referralContractDeposits[_contractAddress][_referrer].push(
            referralDeposit
        );

        emit ReferralDeposit(
            _referrer,
            _contractAddress,
            _auctionId,
            _tokenId,
            _depositer,
            _level,
            _provision
        );
    }

    function checkIfDepositerExists(
        address[] storage _levelDepositers,
        address _depositer
    ) private view returns (bool) {
        // Loop through the array and check each element
        for (uint256 i = 0; i < _levelDepositers.length; i++) {
            if (_levelDepositers[i] == _depositer) {
                return true;
            }
        }
        return false;
    }

    function setReferralEarnings(
        address _referrer,
        uint256 _provision,
        address _contractAddress,
        uint256 _level
    ) private {
        ReferralEearnings storage contractEarnings = referralContractEarnings[
            _contractAddress
        ][_referrer];

        ReferralEearnings storage earnings = referralEarnings[_referrer];

        contractEarnings.all += _provision;
        earnings.all += _provision;
        if (_level == 1) {
            contractEarnings.level1 += _provision;
            earnings.level1 += _provision;
        }
        if (_level == 2) {
            contractEarnings.level2 += _provision;
            earnings.level2 += _provision;
        }
        if (_level == 3) {
            contractEarnings.level3 += _provision;
            earnings.level3 += _provision;
        }
    }

    function getReferralStructure(address _refferal)
        public
        view
        returns (
            address uplineReferrer,
            address[] memory level1,
            address[] memory level2,
            address[] memory level3
        )
    {
        ReferralStructure storage referralStruct = referralStructure[_refferal];
        return (
            referralStruct.uplineReferrer,
            referralStruct.level1,
            referralStruct.level2,
            referralStruct.level3
        );
    }

    function getReferralContractEearnings(
        address _referralAddress,
        address _contractAddress
    )
        public
        view
        returns (
            uint256 all,
            uint256 level1,
            uint256 level2,
            uint256 level3
        )
    {
        ReferralEearnings storage earnigns = referralContractEarnings[
            _contractAddress
        ][_referralAddress];
        return (
            earnigns.all,
            earnigns.level1,
            earnigns.level2,
            earnigns.level3
        );
    }

    function getReferralEearnings(address _referralAddress)
        public
        view
        returns (
            uint256 all,
            uint256 level1,
            uint256 level2,
            uint256 level3
        )
    {
        ReferralEearnings storage earnigns = referralEarnings[_referralAddress];
        return (
            earnigns.all,
            earnigns.level1,
            earnigns.level2,
            earnigns.level3
        );
    }

    function getReferralContractDeposits(
        address _referralAddress,
        address _contractAddress
    ) public view returns (ReferralDeposits[] memory) {
        return referralContractDeposits[_contractAddress][_referralAddress];
    }

    function getReferralDeposits(address _referralAddress)
        public
        view
        returns (ReferralDeposits[] memory)
    {
        return referralDeposits[_referralAddress];
    }

    function setReferral(address _referred, address _referrer)
        external
        onlyAdmin
    {
        if (
            activeReferral[_referred] == address(0) && _referrer != address(0)
        ) {
            referralStructure[_referred].uplineReferrer = _referrer;
            activeReferral[_referred] = _referrer;
            referredCount[_referrer] += 1;
            emit SetReferral(_referrer, _referred);
        }
    }

    function setReferralStructure(
        address _referrer,
        address _uplineReferrer,
        address[] memory _level1Referred,
        address[] memory _level2Referred,
        address[] memory _level3Referred
    ) external onlyOwner {
        ReferralStructure storage currentReferrer = referralStructure[
            _referrer
        ];

        currentReferrer.uplineReferrer = _uplineReferrer;
        for (uint256 i = 0; i < _level1Referred.length; i++) {
            if (
                !checkIfDepositerExists(
                    currentReferrer.level1,
                    _level1Referred[i]
                )
            ) {
                currentReferrer.level1.push(_level1Referred[i]);
            }
        }
        for (uint256 i = 0; i < _level2Referred.length; i++) {
            if (
                !checkIfDepositerExists(
                    currentReferrer.level2,
                    _level2Referred[i]
                )
            ) {
                currentReferrer.level2.push(_level2Referred[i]);
            }
        }
        for (uint256 i = 0; i < _level3Referred.length; i++) {
            if (
                !checkIfDepositerExists(
                    currentReferrer.level3,
                    _level3Referred[i]
                )
            ) {
                currentReferrer.level3.push(_level3Referred[i]);
            }
        }
    }

    function setMyReferral(address _referred) public {
        require(
            activeReferral[_referred] == address(0),
            "Wallet has already assigned referral"
        );

        referralStructure[_referred].uplineReferrer = msg.sender;
        activeReferral[_referred] = msg.sender;
        referredCount[msg.sender] += 1;
        emit SetReferral(msg.sender, _referred);
    }

    function setMyReferrals(address[] memory _referred) public {
        for (uint256 i = 0; i < _referred.length; i++) {
            require(
                activeReferral[_referred[i]] == address(0),
                "One of wallets has already assigned referral"
            );
            referralStructure[_referred[i]].uplineReferrer = msg.sender;
            activeReferral[_referred[i]] = msg.sender;
            referredCount[msg.sender] += _referred.length;
            emit SetReferral(msg.sender, _referred[i]);
        }
    }

    function getReferral(address _referred) external view returns (address) {
        return activeReferral[_referred];
    }

    // Set admin status.
    function setAdminStatus(address _admin, bool _status) external onlyOwner {
        require(_admin != address(0), "Admin: admin address cannot be null");
        isAdmin[_admin] = _status;

        emit AdminStatus(_admin, _status);
    }
}
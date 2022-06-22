// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./access/Governable.sol";

contract ProjectVotation is Ownable, Operable, Governable {
    using SafeMath for uint256; 
    
    struct Votation {
        address tokenAddress;
        uint256 yes;
        uint256 no;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    struct UserVote {
        bool vote;
        uint256 yes;
        uint256 no;
    }

    enum Status { PENDING, ACTIVE, PASSED, REJECTED, NOQUORUM }

    mapping(address => mapping(address => UserVote)) public userVotes;

    mapping(address => Votation) public votations;
    address[] public votationAddresses;

    mapping(address => mapping(address => bool)) public presaleUserWhitelist;
    mapping(address => uint256) public presaleWhitelistQuantity;

    IERC20 public syrupToken;

    uint256 public minQuorumBPS;
    uint256 public constant MIN_MIN_QUORUM_BPS = 0;
    uint256 public constant MAX_MIN_QUORUM_BPS = 10000;

    uint256 public votingDuration;
    uint256 public constant MIN_VOTING_DURATION = 1 hours;
    uint256 public constant MAX_VOTING_DURATION = 15 days;

    uint256 public launchTimestamp;

    constructor(
        address _operator, 
        address _governor,
        uint256 _votingDuration, 
        uint256 _minQuorumBPS, 
        IERC20 _syrupToken,
        uint256 _launchTimestamp
    ) {
        setVotingDuration(_votingDuration);
        setSyrupToken(_syrupToken);
        setMinQuorumBPS(_minQuorumBPS);
        setLaunchTimestamp(_launchTimestamp);
        transferOperable(_operator);
        transferGovernorship(_governor);
    }

    modifier onlyHolders() {
        require(syrupToken.balanceOf(msg.sender) > 0, "no voting power");
        _;
    }

    modifier onlyActiveVotation(address _tokenAddress) {
        require(
            _isActiveVotation(_tokenAddress), 
            "not active votation"
        );
        _;
    }


    /** VIEWS **/

    function getVotation(address _tokenAddress) public view returns(Votation memory) {
        return votations[_tokenAddress];
    }

    function getStatus(address _tokenAddress) public view returns(Status) {
        if (!_exists(_tokenAddress)) {
            return Status.PASSED;
        }
        if (_isFinishedVotation(_tokenAddress)) {
            if (_hasQuorum(_tokenAddress)) {
                if (votations[_tokenAddress].yes > votations[_tokenAddress].no) {
                    return Status.PASSED;
                } else {
                    return Status.REJECTED;
                }
            } else {
                return Status.NOQUORUM;
            }
        }
        if (_isActiveVotation(_tokenAddress)) {
            return Status.ACTIVE;
        }
        return Status.PENDING;
    }

    function isPassed(address _tokenAddress) public view returns(bool) {
        return getStatus(_tokenAddress) == Status.PASSED;
    }

    function getAllVotations() public view returns(Votation[] memory) {
        Votation[] memory allVotations = new Votation[](votationAddresses.length);
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            allVotations[i] = votations[votationAddresses[i]];
        }
        return allVotations;
    }

    function getActiveVotations() public view returns(Votation[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (_isActiveVotation(votationAddresses[i])) {
                count++;
            }
        }
        Votation[] memory activeVotations = new Votation[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (_isActiveVotation(votationAddresses[i])) {
                activeVotations[counter] = votations[votationAddresses[i]];
                counter++;
            }
        }
        return activeVotations;
    }

    function getOldVotations() public view returns(Votation[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (!_isActiveVotation(votationAddresses[i])) {
                count++;
            }
        }
        Votation[] memory oldVotations = new Votation[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (!_isActiveVotation(votationAddresses[i])) {
                oldVotations[counter] = votations[votationAddresses[i]];
                counter++;
            }
        }
        return oldVotations;
    }

    function isUserBlocked(address _user) public view returns(bool) {
        Votation[] memory activeVotations = getActiveVotations();
        for (uint256 i = 0; i < activeVotations.length; i++) {
            if (userVotes[activeVotations[i].tokenAddress][_user].vote == true) {
                return true;
            }
        }
        return false;
    }

    function getMinQuorum() public view returns(uint256) {
        return syrupToken.totalSupply() * minQuorumBPS / 1e4;
    }



    /** HOLDERS **/

    function vote(address _tokenAddress, bool _vote) public onlyHolders onlyActiveVotation(_tokenAddress) {
        unvote(_tokenAddress);
        uint256 votationPower = syrupToken.balanceOf(msg.sender);
        votations[_tokenAddress].yes += _vote == true ? votationPower : 0;
        votations[_tokenAddress].no += _vote == true ? 0 : votationPower;
        userVotes[_tokenAddress][msg.sender] = UserVote({
            vote: true,
            yes: _vote == true ? votationPower : 0,
            no: _vote == true ? 0 : votationPower
        });
        presaleUserWhitelist[_tokenAddress][msg.sender] = true;
        presaleWhitelistQuantity[_tokenAddress]++;
    }

    function unvote(address _tokenAddress) public onlyHolders onlyActiveVotation(_tokenAddress) {
        votations[_tokenAddress].yes -= userVotes[_tokenAddress][msg.sender].yes;
        votations[_tokenAddress].no -= userVotes[_tokenAddress][msg.sender].no;
        userVotes[_tokenAddress][msg.sender] = UserVote({
            vote: false,
            yes: 0,
            no: 0
        });
        if (presaleUserWhitelist[_tokenAddress][msg.sender] == true) presaleWhitelistQuantity[_tokenAddress]--;
        presaleUserWhitelist[_tokenAddress][msg.sender] = false;
    }



    /** GOVERNANCE **/

    function setVotingDuration(uint256 _votingDuration) public onlyGov {
        require(_votingDuration >= MIN_VOTING_DURATION, "invalid value");
        require(_votingDuration <= MAX_VOTING_DURATION, "invalid value");
        votingDuration = _votingDuration;
    }

    function setMinQuorumBPS(uint256 _minQuorumBPS) public onlyGov {
        require(_minQuorumBPS >= MIN_MIN_QUORUM_BPS, "invalid value");
        require(_minQuorumBPS <= MAX_MIN_QUORUM_BPS, "invalid value");
        minQuorumBPS = _minQuorumBPS;
    }



    /** OWNER **/

    function setSyrupToken(IERC20 _syrupToken) public onlyOwner {
        require(_syrupToken.totalSupply() >= 0, "not a token");
        require(_syrupToken.balanceOf(address(this)) >= 0, "not a token");
        syrupToken = _syrupToken;
    }

    function setLaunchTimestamp(uint256 _launchTimestamp) public onlyOwner {
        launchTimestamp = _launchTimestamp;
    }



    /** OPERATOR **/

    function addVotation(address _tokenAddress) public onlyOperator {
        Votation storage votation = votations[_tokenAddress];
        votation.tokenAddress = _tokenAddress;
        votation.startTimestamp = block.timestamp < launchTimestamp ? launchTimestamp : block.timestamp;
        votation.endTimestamp = votation.startTimestamp + votingDuration;
        votationAddresses.push(_tokenAddress);
    }

    function removeVotation(address _tokenAddress) public onlyOperator {
        Votation storage votation = votations[_tokenAddress];
        votation.tokenAddress = address(0);
        votation.startTimestamp = 0;
        votation.endTimestamp = 0;
        votation.yes = 0;
        votation.no = 0;

        _removeFromArray(_tokenAddress);
    }



    /** INTERNAL **/

    function _removeFromArray(address _tokenAddress) internal {
        uint256 indexToRemove;
        for (uint256 i = 0; i < votationAddresses.length; i++){
            if (votationAddresses[i] == _tokenAddress) {
                indexToRemove = i;
                break;
            }
        }
        for (uint256 i = indexToRemove; i < votationAddresses.length-1; i++){
            votationAddresses[i] = votationAddresses[i+1];
        }
        votationAddresses.pop();
    }

    function _isActiveVotation(address _tokenAddress) internal view returns(bool) {
        return 
            block.timestamp >= votations[_tokenAddress].startTimestamp &&
            block.timestamp <= votations[_tokenAddress].endTimestamp;
    }

    function _isFinishedVotation(address _tokenAddress) internal view returns(bool) {
        return block.timestamp > votations[_tokenAddress].endTimestamp;
    }

    function _hasQuorum(address _tokenAddress) internal view returns(bool) {
        return votations[_tokenAddress].yes + votations[_tokenAddress].no >= getMinQuorum();
    }

    function _exists(address _tokenAddress) internal view returns(bool) {
        return votations[_tokenAddress].tokenAddress == _tokenAddress;
    }
}

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Operable is Context {
    address public operator;

    constructor() {
        _transferOperable(_msgSender());
    }

    modifier onlyOperator() {
        require(
            operator == _msgSender(),
            "Operable: caller is not the operator"
        );
        _;
    }

    function transferOperable(address _newOperator) public onlyOperator {
        require(
            _newOperator != address(0),
            "Operable: new operator is the zero address"
        );

        _transferOperable(_newOperator);
    }

    function _transferOperable(address _newOperator) internal {
        operator = _newOperator;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Governable is Context {
    address public governor;

    constructor() {
        _transferGovernorship(_msgSender());
    }

    modifier onlyGov() {
        require(
            governor == _msgSender(),
            "Governable: caller is not the governor"
        );
        _;
    }

    function transferGovernorship(address _newGovernor) public onlyGov {
        require(
            _newGovernor != address(0),
            "Governable: new governor is the zero address"
        );

        _transferGovernorship(_newGovernor);
    }

    function _transferGovernorship(address _newGovernor) internal {
        governor = _newGovernor;
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
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Verifier is Ownable{

    struct CliffInfo {
        uint256 timeCliff;
        uint256 percentage; // % = percentage / 10000
        uint256 proof;
    }
    uint256 constant public ONE_HUNDRED_PERCENT = 10000;
    CliffInfo[] public cliffInfo;
    bool public isSettingClaim = false;
    address public operator;
    // address => claim times => true/false
    mapping(address => mapping(uint => bool)) public status;

    modifier isSetting() {
        require(!isSettingClaim, "");
        _;
        isSettingClaim = true;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Verifier: Only operator can use function");
        _;
    }

    // event
    event LogTaskComplete(address indexed user, uint256 indexed currentValue, uint256 indexed maxValue, uint256 timeStamp);
    event LogRemoveApproval(address indexed user, uint256 indexed timeStamp, string reason);
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);

    constructor(address _operator) {
        operator = _operator;
    }

    function setOperator(address _newOperator) public onlyOwner {
        require(_newOperator != address(0), "Verifier: Address must be different zero");
        address oldOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(oldOperator, _newOperator);
    }

    function setCliffInfo(uint256[] memory _timeCliff, uint256[] memory _percentage, uint256[] memory _proofs) public onlyOperator isSetting {
        require(_timeCliff.length == _percentage.length && _percentage.length == _proofs.length, "Verifier: Length must be equal");
        uint256 sum;
        for(uint256 i = 0; i < _timeCliff.length; i ++) {
            require(_percentage[i] <= ONE_HUNDRED_PERCENT, "Verifier: percentage over 100 %");
            CliffInfo memory _cliffInfo;
            _cliffInfo.percentage = _percentage[i];
            _cliffInfo.timeCliff = _timeCliff[i];
            _cliffInfo.proof = _proofs[i];
            cliffInfo.push(_cliffInfo);
            sum += _percentage[i];
        }
        require(sum == ONE_HUNDRED_PERCENT, "Verifier: total percentage is not 100%");
    }

    function updateProof(uint256 _proof, uint256 _cliffIndex) public onlyOperator returns(bool){
        require(_cliffIndex < cliffInfo.length, "Verifier: cliff not exist");
        cliffInfo[_cliffIndex].proof = _proof;
        return true;
    }

    function approveClaim(address[] memory _users, uint256[] memory _data, uint256 _claimTimes) public onlyOperator {
        require(_claimTimes < cliffInfo.length, "Verifier: times overflow");
        require(_users.length == _data.length, "Verifier: length of _users and _data not equal");
        for(uint i = 0; i < _users.length; i++) {
            status[_users[i]][_claimTimes] = true;
            emit LogTaskComplete(_users[i], _data[i], cliffInfo[_claimTimes].proof, block.timestamp);
        }
    }

    function removeApprove(address[] memory _users, string memory _reason,  uint256 _claimTimes) public onlyOperator {
        require(_claimTimes < cliffInfo.length, "Verifier: times overflow");
        for(uint i = 0; i < _users.length; i++) {
            status[_users[i]][_claimTimes] = false;
            emit LogRemoveApproval(_users[i], _claimTimes, _reason);
        }
    }

    function verify(address _user, uint256 _totalToken, uint256 _claimTimes) public view returns (uint amountClaim, bool finish, bool claimable) {
        require(_claimTimes < cliffInfo.length, "Verifier: times overflow");
        claimable = (status[_user][_claimTimes] || _claimTimes == 0) && cliffInfo[_claimTimes].timeCliff <= block.timestamp;
        amountClaim = cliffInfo[_claimTimes].percentage * _totalToken / ONE_HUNDRED_PERCENT;
        finish = false;
        if(_claimTimes == cliffInfo.length - 1) {
            finish = true;
        }
    }

    // ============ Testing ================== //
    function reset() public onlyOperator {
        delete cliffInfo;
        isSettingClaim = false;
    }
}
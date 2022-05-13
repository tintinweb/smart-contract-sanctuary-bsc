// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LastStandJackpot is Ownable {
    bool public canClaim;
    uint public totalInvested;
    uint constant public MAX_INVESTORS = 50;
    mapping(address => uint) public userposition;
    mapping(uint => address) public positionToUser;
    mapping(address => uint) public totalInvestedBy;
    mapping(address => bool) public hasClaimed;
    mapping(address => uint) public userWithdrawals;
    uint public investorsCount;
    uint public totalDeposits;
    uint public totalWithdrawn;
    uint public finishDate;
    uint constant public ACTIVE_DAYS = 5 days;
    address public operator;
    address public contractMaster;

    modifier onlyContractMaster {
        require(msg.sender == contractMaster, "Only contract master");
        _;
    }

    function deposit(address _investor) public payable onlyContractMaster {
        if(!canClaim) {
            totalDeposits++;
            if(userposition[_investor] == 0) {
                investorsCount++;
            }
            uint _position = userposition[_investor];
            delete positionToUser[_position];
            userposition[_investor] = totalDeposits;
            positionToUser[totalDeposits] = _investor;
            totalInvested += msg.value;
            totalInvestedBy[_investor] += msg.value;
        } else {
            payable(owner()).transfer(msg.value);
        }
    }

    function setContractMaster(address _contractMaster) public onlyOwner {
        require(contractMaster == address(0), "Contract master already set");
        contractMaster = _contractMaster;
    }

    function activeClaim() public onlyContractMaster {
        canClaim = true;
        finishDate = block.timestamp + ACTIVE_DAYS;
    }

    function canFinish() public view returns (bool) {
        if(canClaim && block.timestamp > finishDate) {
            return true;
        }
        return false;
    }

    function getLastStandInvest() public view returns (uint) {
        uint _totalInvested;
        address[] memory lastInvestors = viewInvestors();
        for(uint i; i < lastInvestors.length; i++) {
            _totalInvested += totalInvestedBy[lastInvestors[i]];
        }
        return _totalInvested;
    }

    function getDividendsTo(address _investor) public view returns (uint) {
        if(isInvestor(_investor)) {
            uint dividends = (totalInvested * totalInvestedBy[_investor]) / getLastStandInvest();
            if(dividends > getContractBalance()) {
                dividends = getContractBalance();
            }
            return dividends;
        }
        return 0;
    }

    function withdraw() public {
        require(canClaim, "cant withdraw before claim");
        require(hasClaimed[msg.sender] == false, "you have already claimed");
        require(isInvestor(msg.sender), "you are not an investor");
        hasClaimed[msg.sender] = true;
        uint toWithdraw = getDividendsTo(msg.sender);
        totalWithdrawn += toWithdraw;
        userWithdrawals[msg.sender] += toWithdraw;
        payable(msg.sender).transfer(toWithdraw);
    }

    function getUserData(address _user) external view returns(uint _totalInvested, uint _totalWithdrawn,
        uint _investorPosition, bool _hasClaimed, uint _dividendsTo) {
        _totalInvested = totalInvestedBy[_user];
        _totalWithdrawn = userWithdrawals[_user];
        _investorPosition = userposition[_user];
        _hasClaimed = hasClaimed[_user];
        _dividendsTo = getDividendsTo(_user);
    }

    function getData() external view returns(uint _totalInvest, uint _standInvested, uint _totalWithdrawn, uint _investorsCount, uint _maxInversors, uint _contractBalance, bool _canClaim) {
        _totalInvest = totalInvested;
        _standInvested = getLastStandInvest();
        _totalWithdrawn = totalWithdrawn;
        _investorsCount = investorsCount;
        _canClaim = canClaim;
        _maxInversors = MAX_INVESTORS;
        _contractBalance = getContractBalance();
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function viewInvestors() public view returns(address[] memory) {
        uint _length = activeLastStandInvestorCount();
        address[] memory _investors = new address[](_length);
        uint _index = 0;
        uint _totalDeposits = totalDeposits;
        for(uint i; i < _totalDeposits; i++) {
            if(_index == _length) {
                break;
            }
            if(positionToUser[_totalDeposits - i] != address(0)) {
                _investors[_index] = positionToUser[_totalDeposits - i];
                _index++;
            }
        }
        return _investors;
    }

    function investorLastStandIndex(uint _index) public view returns(address) {
        address[] memory _investors = viewInvestors();
        return _investors[_index];
    }

    function investorPosition(address _investor) public view returns(uint) {
        address[] memory _investors = viewInvestors();
        for(uint i; i < _investors.length; i++) {
            if(_investors[i] == _investor) {
                return i + 1;
            }
        }
        return 0;
    }

    function isInvestor(address _investor) public view returns (bool) {
        address[] memory _investors = viewInvestors();
        for(uint i; i < _investors.length; i++) {
            if(_investors[i] == _investor) {
                return true;
            }
        }
        return false;
    }

    function finish() external onlyOwner {
        require(canFinish(), "cant finish");
        payable(msg.sender).transfer(getContractBalance());
    }

    function activeLastStandInvestorCount() public view returns(uint) {
        return investorsCount > MAX_INVESTORS ? MAX_INVESTORS : investorsCount;
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
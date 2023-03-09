//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Lawyers list for Narfex P2P service
/// @author Danil Sakhinov
contract NarfexLawyers is Ownable {

    struct Lawyer {
        bool isActive;
        bool[7][24] schedule;
    }

    address public writer;
    mapping (address=>Lawyer) private _lawyers;
    mapping (address=>bool) private _isLawyer;
    address[] public list;
    uint constant DAY = 86400;

    constructor() {
        setWriter(msg.sender);
    }

    event SetWriter(address _account);
    event Add(address _account);
    event Remove(address _account);

    modifier canWrite() {
        require(_msgSender() == owner() || _msgSender() == writer, "No permission");
        _;
    }
    modifier onlyWriter() {
        require(_msgSender() == writer, "Only writer can do it");
        _;
    }
    modifier onlyLawyer() {
        require(getIsLawyer(_msgSender()), "You are not Narfex lawyer");
        _;
    }

    /// @notice Set writer account
    /// @param _account New writer account address
    function setWriter(address _account) public onlyOwner {
        writer = _account;
        emit SetWriter(_account);
    }

    /// @notice Add account to the lawyers list
    /// @param _account Account address
    function add(address _account) public canWrite {
        require(!_isLawyer[_account], "Account is already lawyer");
        bool[7][24] memory schedule;
        unchecked {
            for (uint8 w; w < 7; w++) {
                for (uint8 h; h < 24; h++) {
                    schedule[w][h] = true;
                }
            }
        }
        _isLawyer[_account] = true;
        _lawyers[_account] = Lawyer({
            isActive: true,
            schedule: schedule
        });
        list.push(_account);
        emit Add(_account);
    }

    /// @notice Remove account from the lawyers list
    /// @param _account Lawyer address
    function remove(address _account) private canWrite {
        require(_isLawyer[_account], "Account is not lawyer");
        unchecked {
            uint j;
            for (uint i; i < list.length - 1; i++) {
                if (list[i] == _account) {
                    j++;
                }
                if (j > 0) {
                    list[i] = list[i + 1];
                }
            }
            if (j > 0) {
                list.pop();
                _isLawyer[_account] = false;
            }
        }
        emit Remove(_account);
    }

    /// @notice Get lawyer activity schedule
    /// @param _account Lawyer address
    /// @return Schedule
    function getSchedule(address _account) public view returns(bool[7][24] memory) {
        return _lawyers[_account].schedule;
    }

    /// @notice Set a new lawyer's schedule
    /// @param _schedule [weekDay][hour] => isActive
    function setSchedule(bool[7][24] calldata _schedule) public onlyLawyer {
        _lawyers[msg.sender].schedule = _schedule;
    }

    /// @notice Exclude or include a lawyer from the issuance 
    /// @param _newState New isActive state 
    function setIsActive(bool _newState) public onlyLawyer {
        _lawyers[msg.sender].isActive = _newState;
    }

    /// @notice Check if account is Protocol lawyer
    /// @param _account Account address
    /// @return Is lawyer
    function getIsLawyer(address _account) public view returns(bool) {
        return _isLawyer[_account];
    }

    /// @notice Return is lawyer active now
    /// @param _account Account address
    /// @return isActive Is lawyer active at this time
    function getIsActive(address _account) public view returns(bool isActive) {
        Lawyer memory lawyer;
        if (getIsLawyer(_account)) return false;
        if (!lawyer.isActive) return false;
        uint8 weekDay = uint8((block.timestamp / DAY + 4) % 7);
        uint8 hour = uint8((block.timestamp / 60 / 60) % 24);
        return lawyer.schedule[weekDay][hour];
    }

    /// @notice Get currently active lawyers
    /// @return Array of addresses
    function getActiveLawyers() private view returns(address[] memory, uint) {
        uint i;
        address[] memory active = new address[](list.length);
        unchecked {
            for (uint j; j < list.length; j++) {
                if (getIsActive(list[j])) {
                    active[i++] = list[j];
                }
            }
        }
        return (active, i);
    }

    /// @notice Randomly returns the currently available lawyer
    /// @return Active lawyer address
    function getLawyer() public view returns(address) {
        (address[] memory active, uint length) = getActiveLawyers();
        if (length == 0) return address(0);
        uint index = uint(keccak256(abi.encodePacked(block.timestamp, block.basefee))) % length;
        return active[index];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
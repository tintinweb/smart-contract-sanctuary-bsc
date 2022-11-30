// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVotingPower.sol";

contract VotingPower is Ownable, IVotingPower {
    mapping(string => uint256) private votingPower;
    mapping(string => uint256) private multiplier;
    uint256 private divisor = 100;
    uint256 private minimumVotingPower = 5000;

    constructor() {
        votingPower["2"] =  500000;
        votingPower["3"] =  500000;
        votingPower["4"] =  500000;
        votingPower["5"] =  500000;
        votingPower["6"] =  500000;
        votingPower["7"] =  500000;
        votingPower["8"] =  500000;
        votingPower["9"] =  500000;
        votingPower["10"] =  500000;

        votingPower["J"] = 1000000;
        votingPower["D"] = 1000000;
        votingPower["K"] = 1000000;
        votingPower["A"] = 1000000;
        votingPower["Joker"] = 1000000;

        multiplier["onePair"] = 105;
        multiplier["twoPair"] = 115;
        multiplier["threeOfAKind"] = 127;
        multiplier["straight"] = 145;
        multiplier["flush"] = 167;
        multiplier["fullHouse"] = 190;
        multiplier["fourOfAKind"] = 218;
        multiplier["straightFlush"] = 248;
        multiplier["royalFlush"] = 300;


    }
    /**
     * Voting Power update function accepts type of card and votingPower 
     */
    function setVotingPower(string memory card, uint256 _votingPower) external override onlyOwner {
        votingPower[card] = _votingPower;
    }

    /**
     * Get Voting Power of card 
     */
    function getVotingPower(string memory card) public view override returns (uint256 _votingPower) {
        return votingPower[card];
    }

    /**
     * Multiplier update function accepts sequence name and multiplier value 
     */
    function setMultiplier(string memory sequenceName, uint256 _multiplier) external override onlyOwner {
        multiplier[sequenceName] = _multiplier;
    }

    /**
     * Get the Multiplier for sequence
     */
    function getMultiplier(string memory sequenceName) public view override returns(uint256 _multiplier){
        return multiplier[sequenceName];
    }

    /**
     * set and get divisor - that is the decimal point of multiplier 
     * example a multiplier is 1.01 * 100 = 101 now the divisor would be 100 so that you can get 1.01
     */
    function setDivisor(uint256 _divisor) external override onlyOwner {
        divisor = _divisor;
    }

    function getDivisor() external view override returns (uint256 _divisor) {
        return divisor;
    }

    /**
     * Set and get Limit for minimum voting power required for creating polling proposal
     */
    function setMinimumVotingPower(uint256 power) external override onlyOwner {
        minimumVotingPower = power;
    }

    function getMinimumVotingPower() public view override returns(uint256 _minimumVotingPower) {
        return minimumVotingPower;
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
pragma solidity ^0.8.4;

interface IVotingPower {

    function setVotingPower(string memory card, uint256 _votingPower) external;

    function getVotingPower(string memory card) external view returns (uint256 _votingPower);

    function setMultiplier(string memory sequenceName, uint256 _multiplier) external;

    function getMultiplier(string memory sequenceName) external view returns(uint256 _multiplier);

    function setDivisor(uint256 _divisor) external;

    function getDivisor() external view returns (uint256 _divisor);

    function setMinimumVotingPower(uint256 power) external;

    function getMinimumVotingPower() external view returns(uint256 _minimumVotingPower);
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
/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

//SPDX-License-Identifier: MIT
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

interface IVotingPower {
    function getSELFBalance(address _user) external view returns (uint256);

    function getSELFVaultBalance(address _user) external pure returns (uint256);

    function getIFOPoolBalancee(address _user) external view returns (uint256);

    function getSELFPoolBalance(address _user) external view returns (uint256);

    function getSELFBnbLpBalance(address _user) external view returns (uint256);

    function getPoolsBalance(address _user, address[] memory _pools) external view returns (uint256);

    function getVotingPowerWithoutPool(address _user) external view returns (uint256);

    function getVotingPower(address _user, address[] memory _pools) external view returns (uint256);
}

contract VotePowerProxy is Ownable {
    constructor() 
    {
    }

    address public VotingPowerContract = 0xdFa477C4467397961c03B2d5608f4Cb1ace224fE;

    event NewVotingPowerContract(address VotingPowerContract);

    function getSELFBalance(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getSELFBalance(_user);
    }

    function getSELFVaultBalance(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getSELFVaultBalance(_user);
    }

    function getIFOPoolBalancee(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getIFOPoolBalancee(_user);
    }

    function getSELFPoolBalance(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getSELFPoolBalance(_user);
    }

    function getSELFBnbLpBalance(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getSELFBnbLpBalance(_user);
    }

    function getPoolsBalance(address _user, address[] memory _pools) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getPoolsBalance(_user, _pools);
    }

    function getVotingPowerWithoutPool(address _user) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getVotingPowerWithoutPool(_user);
    }

    function getVotingPower(address _user, address[] memory _pools) external view returns (uint256) {
        return IVotingPower(VotingPowerContract).getVotingPower(_user, _pools);
    }

    /**
     * @notice Set Voting Power Contract address
     * @dev Only callable by the contract owner.
     */
    function setVotingPowerContract(address _VotingPowerContract) external onlyOwner {
        require(_VotingPowerContract != address(0), "Cannot be zero address");
        VotingPowerContract = _VotingPowerContract;
        emit NewVotingPowerContract(VotingPowerContract);
    }
}
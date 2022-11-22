/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

/*
 * @title: Token
 * @dev: Interface contract for ERC20 tokens
 */
interface Token {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

interface WorldCup {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getTypeMinted(uint256 typeId) external view returns(uint); 
    function getIsClaim(uint256 _id) external view returns(bool);
    function setClaimWinning(uint256 _id) external;
}

contract WorldCupPool is Ownable {
    uint256 winnerId;
    uint256 winningAmount;
    address WORLDCUP_ADDRESS;
    address constant public OPV_ADDRESS = 0x36C7B164F85D6F775cD128966D5819c7d36FEfF3;

    constructor(
        address _worldCupAddress
    ) {
        WORLDCUP_ADDRESS = _worldCupAddress;
    }

    function setWinner(uint256 _winnerId) public onlyOwner {
        require(_winnerId > 0 && _winnerId <= 32);
        winnerId = _winnerId;
        winningAmount = Token(OPV_ADDRESS).balanceOf(address(this))/ WorldCup(WORLDCUP_ADDRESS).getTypeMinted(_winnerId);
    }

    function claimWinner(uint256 _id) public {
        require(WorldCup(WORLDCUP_ADDRESS).getIsClaim(_id) == false);
        require(WorldCup(WORLDCUP_ADDRESS).ownerOf(_id) == msg.sender);
        require(winnerId > 0);
        WorldCup(WORLDCUP_ADDRESS).setClaimWinning(_id);
        
        Token(OPV_ADDRESS).transfer(msg.sender, winningAmount);
    } 

    function emergencyWithdrawalBNB(address payable _to, uint256 amount) external onlyOwner {
        require(_to.send(amount));
    }
    
    function emergencyWithdrawalToken(address TOKEN ,uint256 amount) external onlyOwner {
        Token(TOKEN).transfer(msg.sender, amount);
    }
}
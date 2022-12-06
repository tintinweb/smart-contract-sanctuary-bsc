/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address payable private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}


contract tt1 is Context, Ownable {
    
    //history
    struct BuyData {
        uint256 advertId;
        uint256 promoType;
        uint256 amount;
    }
    uint256 private currentBuyIndex;
    mapping (uint256 => BuyData) private buyHistory;

    constructor () public {
    }

    
    function buyAdvertWithBNB() external payable {
        require(msg.value >= 0.001 ether);
        
        bool success = owner().send(msg.value);
        require(success, "Money transfer failed");
    }
    
 
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {
         bool success = owner().send(msg.value);
         require(success, "Money transfer failed");
    }
}
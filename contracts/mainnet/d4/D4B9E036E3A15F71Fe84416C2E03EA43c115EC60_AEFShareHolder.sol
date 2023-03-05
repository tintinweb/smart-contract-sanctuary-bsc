/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// I'm a comment!
// SPDX-License-Identifier: MIT
// pragma solidity 0.8.7;
// pragma solidity ^0.8.0;
pragma solidity >=0.8.0 <0.9.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }    
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address public _owner;

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

contract AEFShareHolder is Ownable{
    using SafeMath for uint256;
    // 0xd49A32fb88ab098cf10BF739496fC8c43919ab47   0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address[] public users;
    uint256 minSettlement = 10000000000000000000;

    function setting(uint256 _minSettlement) public onlyOwner{
        minSettlement = _minSettlement;
    }
    
    // 0x55d398326f99059fF775485246999027B3197955,384000000000000000000
    function withdraw(address _token, uint256 withdraw_amount) public onlyOwner{
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount >= withdraw_amount, "not sufficient funds");

        IERC20(_token).transfer(0x72758ac5E251fC13355e9f76Be7d774E6272967b, withdraw_amount);
    }

    function settlement() public onlyOwner{
        uint256 balance = IERC20(usdtAddress).balanceOf(address(this));
        if(balance <= minSettlement){
            return;
        }
        uint shareHolderCount = users.length;
        if(shareHolderCount == 0)return;
        uint256 equal_distribution = balance.div(shareHolderCount);
        
        for (uint256 i = 0; i < users.length; i++) {
            IERC20(usdtAddress).transfer(users[i], equal_distribution);
        }

    }

    function addUser(address userAddress) public onlyOwner{
        users.push(userAddress);
    }    

    function removeUser(uint index) public onlyOwner{
        users[index] = users[users.length - 1];
        users.pop();
    } 
    

}
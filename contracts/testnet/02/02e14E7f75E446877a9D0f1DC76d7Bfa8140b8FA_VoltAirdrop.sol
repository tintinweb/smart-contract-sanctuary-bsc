/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

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

contract VoltAirdrop is Context, Ownable{
    using SafeMath for uint256;

    mapping (address => uint256) public _claimAmount;
    mapping(address => bool) public _hasClaimed;

    uint256 public airdropAmount;
    address public volt;
    uint256 public totalEligibleUser = 0;

    constructor(address _volt) {
        volt = _volt;
    }

    function updateClaimAmount(address account, uint256 claimAmount) external onlyOwner() {
        _claimAmount[account] = claimAmount;
    }

    function updateMultipleClaimAmount(address[] memory accounts, uint256[] memory claimAmounts) external onlyOwner() {
        uint256 count = accounts.length;
        uint256 count2 = claimAmounts.length;
        require(count == count2, "Array size mismatch");
        totalEligibleUser = totalEligibleUser.add(count);
        for(uint256 i = 0; i< count; i++) {
            _claimAmount[accounts[i]] = claimAmounts[i];
        }
    }

    function claim() external {
        require(_claimAmount[_msgSender()] > 0, "Not eligible for Airdrop");
        require(!_hasClaimed[_msgSender()], "Already claimed");

        _hasClaimed[_msgSender()] = true;

        IERC20(volt).transfer(_msgSender(),_claimAmount[_msgSender()]);
    }

    function withdrawUnclaimedToken(address to, uint256 amount) external onlyOwner() {
        IERC20(volt).transfer(to,amount);
    }
}
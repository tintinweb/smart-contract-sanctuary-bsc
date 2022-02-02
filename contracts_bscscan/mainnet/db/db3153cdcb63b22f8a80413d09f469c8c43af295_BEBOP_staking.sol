/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

/**
 *  A simple staking contract which disperses any incoming BNB to the stakers.
 *
 *  A thing to note, since we cannot exempt the staking address from the fees, we do it manually, @see AuthProxy.
 *
 *  @author Obama
 *
 *  Created on: 23/01/2022
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(msg.sender);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }}

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }}
}

contract BEBOP_staking is Ownable {
    using SafeMath for uint256;

    BebopContract bebop;
    AuthProxy authProxy;
    address public feeReceiver;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public mask;

    uint256 public totalStaked;
    uint256 public transferFee = 0;
    uint256 public distributedAmount;

    constructor(address _bebopAddress, address _feeReceiver) {
        bebop = BebopContract(_bebopAddress);
        feeReceiver = _feeReceiver;
    }

    receive() external payable {
        distribute();
    }

    function setAuthProxy(address proxyAddress) public onlyOwner {
        authProxy = AuthProxy(proxyAddress);
    }

    function distribute() public payable {
        require(totalStaked > 0, "There is no staked tokens here!");
        distributedAmount = distributedAmount.add(msg.value.mul(1e18).div(totalStaked));
    }

    function calculateEarnings(address user) public view returns (uint256) {
        return distributedAmount.sub(mask[user]).mul(stakedAmount[user]).div(1e18);
    }

    function stakeTokens(uint256 amount) public {
        require(amount > 0, "Specify amount!");
        require(bebop.balanceOf(msg.sender) >= amount, "Don't cheat!");

        withdrawEarnings();

        authProxy.setIsFeeExempt(msg.sender, true);
        bebop.transferFrom(msg.sender, address(this), amount);
        authProxy.setIsFeeExempt(msg.sender, false);

        uint256 stakeTax = 0;
        if (transferFee != 0) {
            stakeTax = amount.div(transferFee);
            bebop.transfer(feeReceiver, stakeTax);
        }

        // Subtract tax from amount and add to statistics.
        uint256 addToStaking = amount.sub(stakeTax);
        totalStaked = totalStaked.add(addToStaking);
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(addToStaking);
    }

    function unstakeTokens(uint256 amount) public {
        require(stakedAmount[msg.sender] >= amount);
        withdrawEarnings();

        totalStaked = totalStaked.sub(amount);
        stakedAmount[msg.sender] = stakedAmount[msg.sender].sub(amount);

        bebop.transfer(msg.sender, amount);
    }

    function withdrawEarnings() public {
        // Calculate earnings and reset mask
        uint256 unclaimed = calculateEarnings(msg.sender);
        mask[msg.sender] = distributedAmount;
        if (unclaimed > 0) {
            (bool success,) = payable(msg.sender).call{value : unclaimed}("");
            require(success);
        }
    }

    function setTransferFee(uint256 newFee) public onlyOwner {
        transferFee = newFee;
    }

    function setFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
    }
}

interface BebopContract {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface AuthProxy {
    function setIsFeeExempt(address holder, bool exempt) external;
}
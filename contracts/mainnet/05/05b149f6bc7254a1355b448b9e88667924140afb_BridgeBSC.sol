/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


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
        }
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract BridgeBSC is Ownable {
    using SafeMath for uint256;

    IERC20 briseToken = IERC20(0x8FFf93E810a2eDaaFc326eDEE51071DA9d398E83);

    address public tokenReceiver = 0x5aE43Ba8Ab912C44E89A2724E25aE7A21D4BCb68;
    address public feeReceiver = 0x5aE43Ba8Ab912C44E89A2724E25aE7A21D4BCb68;

    uint256 public fee = 5;
    uint256 public feeDenominator = 10000;
    
    // Check token allowance
    modifier checkAllowance(uint amount) {
        require(briseToken.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    function initiate(uint256 _amount) public payable checkAllowance(_amount) {
        uint256 feeAmount = _amount.mul(fee).div(feeDenominator);
        
        briseToken.transferFrom(msg.sender, feeReceiver, feeAmount);
        briseToken.transferFrom(msg.sender, address(this), _amount - feeAmount);

        emit Received(msg.sender, _amount - feeAmount);
    }

    function withdrawETH(uint256 _amount) public onlyOwner {
        bool sent = payable(tokenReceiver).send(_amount);
        require(sent, "Failed to send BRISE");
        emit Withdraw(tokenReceiver, _amount);
    }

    function withdrawBRISE(uint256 _amount) public onlyOwner {
        briseToken.transfer(feeReceiver, _amount);
    }

    function transfer(address _to, uint256 _amount) public onlyOwner {
        transfer_from_contract(_to, _amount);
    }

    function transfer_from_contract(address _to, uint256 _amount) public onlyOwner {
        briseToken.transfer(_to, _amount);
    }

    function updateTokenReceiver(address _receiver) public onlyOwner {
        tokenReceiver = _receiver;
    }

    function updateFee(uint256 _fee, uint256 _feeDenominator) public onlyOwner {
        fee = _fee;
        feeDenominator = _feeDenominator;
    }

    function ethBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}

    event Received(address, uint);
    event Withdraw(address, uint);
}
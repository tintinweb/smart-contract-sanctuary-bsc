// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./interfaces/IERC20.sol";
import "./utils/Ownable.sol";

contract GalaxyHolding is Ownable {
    mapping(address => bool) public allowedBorrowers;

    modifier onlyBorrowers {
        require(allowedBorrowers[msg.sender] == true, "Only Borrowers");
        _;
    }

   function addBorrowers(address[] memory newBorrowers) public onlyOwner {
        for (uint i=0;i<newBorrowers.length;i++) {
            allowedBorrowers[newBorrowers[i]] = true;
        }
    }

    function removeBorrowers(address[] memory oldBorrowers) public onlyOwner {
        for (uint i=0;i<oldBorrowers.length;i++) {
            delete allowedBorrowers[oldBorrowers[i]];
        }
    }

    function takeLoan(address loanToken, uint256 amount) public onlyBorrowers {
        require(IERC20(loanToken).balanceOf(address(this)) >= amount, "Not enough loanToken in the contract");
        IERC20(loanToken).transfer(msg.sender, amount);
    }

    function loanPayment(address loanToken, address loanContract, uint256 amount) public onlyBorrowers {
        IERC20(loanToken).transferFrom(msg.sender, address(this), amount);
        IERC20(loanToken).transfer(loanContract, amount);
    }

    function withdrawToken(address token, uint256 amount) public onlyOwner {
        address to = this.owner();
        IERC20(token).transfer(to, amount);
    }

    function migrateTokens(address[] memory tokens, address newContract) public onlyOwner {
        for (uint256 i=0;i<tokens.length;i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            IERC20(tokens[i]).transfer(newContract, balance);
        }
    }
}

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity > 0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IXenMinter {
    function balanceOf(address _address) external view returns (uint256);
    function globalRank() external view returns (uint256);
    function claimRank(uint256 term) external;
    function claimMintReward() external;
    function transfer(address _to, uint256 _amount) external;
}

contract XenMinterWallet is Ownable {
    IXenMinter xenMinter;

    constructor(
        IXenMinter _xenminterAddr
    ) {
        xenMinter = _xenminterAddr;
    }

    function mint(uint256 _term) external onlyOwner {
        // this is new to mint
        xenMinter.claimRank(_term);
    }

    function claim() external onlyOwner {
        // claim reward
        xenMinter.claimMintReward();
        require(xenMinter.balanceOf(address(this)) > 0, "XEN: Balance Not Enough");
        // transfer xen
        xenMinter.transfer(owner(), xenMinter.balanceOf(address(this)));
    }
}

interface IXenWallet {
    function claim() external;
}

contract XenTool is Ownable {
    IXenMinter public xenMinter;

    struct wallet {
        address[] storageWallet;
    }
    mapping(uint => wallet) periodes;

    event Mint(address _address, uint256 _term, uint256 _rank);
    event Withdraw(address _address, uint256 _amount);

    constructor(
        IXenMinter _xenminterAddr        
    ) {
        xenMinter = _xenminterAddr;
    }

    function mint(uint _periode, uint _maxWallet, uint256 _term) external onlyOwner {
        address[] memory _storageWallet;

        for (uint i=0; i<_maxWallet; i++) {
            XenMinterWallet _xenMinter = new XenMinterWallet(xenMinter);
            _xenMinter.mint(_term);
            _storageWallet[i] = address(_xenMinter);
            emit Mint(address(_xenMinter), _term, xenMinter.globalRank());
        }
        periodes[_periode] = wallet(_storageWallet);
    }

    function claim(uint _periode) external onlyOwner {
        uint _periodeLength = periodes[_periode].storageWallet.length;
        require(_periodeLength > 0, "TOOL: Periode Not Found");
        for (uint i=0; i<_periodeLength; i++) {
            address _walletAddr = periodes[_periode].storageWallet[i];
            IXenWallet(_walletAddr).claim();
        }
    }

    function withdraw() external onlyOwner {
        uint256 _balance = xenMinter.balanceOf(address(this));
        xenMinter.transfer(owner(), _balance);
        emit Withdraw(owner(), _balance);
    }
}
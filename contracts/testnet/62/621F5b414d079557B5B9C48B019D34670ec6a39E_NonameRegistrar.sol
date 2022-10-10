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

// SPDX-License-Identifier: MIT
//========================================================================
//    _    _    _    _    _    _    _    _    _    _    _    _    _    _
//   / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \
//  ( N )( o )( n )( a )( m )( e )( . )( M )( o )( n )( s )( t )( e )( r )
//   \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/
//
//========================================================================

pragma solidity ^0.8.13;

interface IPriceOracle {
    struct Price {
        uint256 base;
        uint256 premium;
    }

    /**
     * @dev Returns the price to register or renew a name.
     * @param name The name being registered or renewed.
     * @param expires When the name presently expires (0 if this is a new registration).
     * @param duration How long the name is being registered or extended for, in seconds.
     * @return base premium tuple of base price + premium price
     */
    function price(
        string calldata name,
        uint256 expires,
        uint256 duration
    ) external view returns (Price calldata);

    function price(
        uint256 name_len,
        uint256 expires,
        uint256 duration
    ) external view returns (Price calldata);
}

// SPDX-License-Identifier: MIT
//========================================================================
//    _    _    _    _    _    _    _    _    _    _    _    _    _    _
//   / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \
//  ( N )( o )( n )( a )( m )( e )( . )( M )( o )( n )( s )( t )( e )( r )
//   \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/
//
//========================================================================

pragma solidity ^0.8.13;
import "./IPriceOracle.sol";

interface IRegistrarController {
    // SpaceID return tuple of base and premium price
    function rentPrice(string memory, uint256) external view returns (IPriceOracle.Price memory);

    // TODO impl
    // ENS return total price in int

    function available(string memory) external view returns (bool);

    function commitments(bytes32 commitment) external view returns (uint256);

    function makeCommitmentWithConfig(
        string memory name,
        address owner,
        bytes32 secret,
        address resolver,
        address addr
    ) external pure returns (bytes32);

    function makeCommitment(
        string memory,
        address,
        uint256,
        bytes32,
        address,
        bytes[] calldata,
        bool,
        uint96
    ) external returns (bytes32);

    function commit(bytes32) external;

    function registerWithConfig(
        string memory name,
        address owner,
        uint256 duration,
        bytes32 secret,
        address resolver,
        address addr
    ) external payable;

    function register(
        string calldata,
        address,
        uint256,
        bytes32,
        address,
        bytes[] calldata,
        bool,
        uint96
    ) external payable;

    function renew(string calldata, uint256) external payable;
}

// SPDX-License-Identifier: MIT
//========================================================================
//    _    _    _    _    _    _    _    _    _    _    _    _    _    _
//   / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \
//  ( N )( o )( n )( a )( m )( e )( . )( M )( o )( n )( s )( t )( e )( r )
//   \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/
//
//========================================================================

pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import { IRegistrarController } from "./IRegistrarController.sol";
import { IPriceOracle } from "./IPriceOracle.sol";

contract NonameRegistrar is Ownable {
    // ---------------------------------------------------------------------------------------- //
    // ************************************* Constants **************************************** //
    // ---------------------------------------------------------------------------------------- //

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Variables **************************************** //
    // ---------------------------------------------------------------------------------------- //
    IRegistrarController public registrarController;

    // ---------------------------------------------------------------------------------------- //
    // *************************************** Events ***************************************** //
    // ---------------------------------------------------------------------------------------- //
    event RegistrarUpdated(address previewsRegistrar, address newRegistrar);

    // ---------------------------------------------------------------------------------------- //
    // *************************************** Errors ***************************************** //
    // ---------------------------------------------------------------------------------------- //

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Constructor ************************************** //
    // ---------------------------------------------------------------------------------------- //

    constructor(address _registrarController) {
        registrarController = IRegistrarController(_registrarController);
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Modifiers *************************************** //
    // ---------------------------------------------------------------------------------------- //

    // ---------------------------------------------------------------------------------------- //
    // *********************************** View Functions ************************************* //
    // ---------------------------------------------------------------------------------------- //

    function available(string[] memory names) external view returns (bool[] memory) {
        bool[] memory results = new bool[](names.length);
        for (uint256 i = 0; i < names.length; i++) {
            results[i] = registrarController.available(names[i]);
        }
        return results;
    }

    function rentPrice(string[] calldata names, uint256 duration) external view returns (uint256[] memory) {
        uint256[] memory prices = new uint256[](names.length);
        for (uint256 i = 0; i < names.length; i++) {
            IPriceOracle.Price memory price = registrarController.rentPrice(names[i], duration);
            prices[i] = price.base + price.premium;
        }
        return prices;
    }

    function getCommitments(bytes32[] calldata _commits) external view returns (uint256[] memory) {
        uint256[] memory timestamps = new uint256[](_commits.length);
        for (uint256 i = 0; i < _commits.length; i++) {
            timestamps[i] = registrarController.commitments(_commits[i]);
        }
        return timestamps;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************* Set Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //
    function setRegistrarController(address _registrarController) external onlyOwner {
        require(_registrarController != address(0), "Registrar address err");
        address oldRegistrarController = address(registrarController);
        registrarController = IRegistrarController(_registrarController);
        emit RegistrarUpdated(oldRegistrarController, _registrarController);
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Main Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    function submit(
        string[] calldata _names,
        address _owner,
        bytes32 _secret,
        address _resolver,
        address _addr
    ) external {
        for (uint256 i = 0; i < _names.length; i++) {
            bytes32 commitment = registrarController.makeCommitmentWithConfig(
                _names[i],
                _owner,
                _secret,
                _resolver,
                _addr
            );
            registrarController.commit(commitment);
        }
    }

    function register(
        string[] calldata names,
        address _owner,
        uint256 duration,
        bytes32 secret,
        address resolver,
        address addr
    ) external payable {
        require(_owner == msg.sender, "Error: Caller must be the same address as owner");

        for (uint256 i = 0; i < names.length; i++) {
            IPriceOracle.Price memory cost = registrarController.rentPrice(names[i], duration);
            registrarController.registerWithConfig{ value: cost.base + cost.premium }(
                names[i],
                _owner,
                duration,
                secret,
                resolver,
                addr
            );
        }
    }

    // ---------------------------------------------------------------------------------------- //
    // ********************************** Internal Functions ********************************** //
    // ---------------------------------------------------------------------------------------- //

    // ---------------------------------------------------------------------------------------- //
    // *********************************** Pure Functions ************************************* //
    // ---------------------------------------------------------------------------------------- //
}
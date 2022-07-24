//SPDX-License-Identifier: MIT
pragma solidity *0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IAccess {
    function hasRole(bytes32, address) external view returns (bool);
}

interface IInvestment {
    function safeTransferFrom(
        address,
        address,
        uint,
        uint,
        bytes memory
    ) external;

    function balanceOf(address, uint) external view returns (uint);

    function isApprovedForAll(address, address) external view returns (bool);
}

interface IOracle {
    function getPrice(uint, address[] memory) external view returns (uint);
}

interface IToken {
    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

contract Platform is ReentrancyGuard, Context {
    bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 private constant USER_ROLE = keccak256("USER_ROLE");

    address public admin;
    address public access;
    address public oracle;
    address public token;
    

    mapping(address => mapping(uint => Listing)) public listings;

    struct Listing {
        uint price;
        address creator;
    }

    constructor(
        address _admin,
        address _access,
        address _oracle,
        address _token       
    ) {
        require(_admin != address(0) && _access != address(0) && _oracle != address(0) && _token != address(0), "Intelly Platform: addresses must not be the zero address");
        admin = _admin;
        access = _access;
        oracle = _oracle;
        token = _token;
    }

    event Listed(address indexed inft, uint indexed price);

    event Purchased(
        address indexed inft,
        address indexed owner,
        uint indexed amount
    );

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function _hasRole(bytes32 role, address account)
        internal
        view
        virtual
        returns (bool)
    {
        return IAccess(access).hasRole(role, account);
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!_hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "Intelly Access: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint(role), 32)
                    )
                )
            );
        }
    }
    
    function _checkAddress(address iAddress) internal pure {
        if (iAddress == address(0)) {
            revert(
                string(
                    abi.encodePacked(
                        "Intelly Platformt: address ",
                        Strings.toHexString(uint160(iAddress), 20),
                        " must not be the zero address"
                    )
                )
            );
        }
    }

    function _getPrice(uint amount, address[] memory path)
        internal
        view
        virtual
        returns (uint)
    {
        return IOracle(oracle).getPrice(amount, path);
    }

    function list(
        address creator,
        address inft,
        uint id,
        uint price
    ) external nonReentrant {
        _checkRole(OPERATOR_ROLE);
        require(
            price >= 1000000000000000000,
            "Intelly Platform: the specified price must be greater than 1 ether"
        );
        require(
            IInvestment(inft).balanceOf(creator, id) > 0,
            "Intelly Platform: account do not have any balance"
        );
        require(
            IInvestment(inft).isApprovedForAll(creator, address(this)),
            "Intelly Platform: contract is missing approve"
        );
        listings[inft][id] = Listing(price, creator);
        emit Listed(inft, price);
    }

    function purchase(
        address inft,
        uint id,
        uint amount,
        address[] memory path
    ) external nonReentrant {
        _checkRole(USER_ROLE);
        Listing memory item = listings[inft][id];
        uint total = item.price * amount;
        uint price = _getPrice(total, path);
        require(IToken(token).transferFrom(_msgSender(), item.creator, price), "Intelly Platform: INTL transfer must be confirmed successfully");
        IInvestment(inft).safeTransferFrom(
            item.creator,
            _msgSender(),
            id,
            amount,
            ""
        );
        emit Purchased(inft, _msgSender(), amount);
    }

     function setAdmin(address iAdmin) external onlyRole(OPERATOR_ROLE) {
        _checkAddress(iAdmin);
        admin = iAdmin;
    }

    function setAccess(address iAccess) external onlyRole(OPERATOR_ROLE) {
        _checkAddress(iAccess);
        access = iAccess;
    }

    function setOracle(address iOracle) external onlyRole(OPERATOR_ROLE) {
        _checkAddress(iOracle);
        oracle = iOracle;
    }

    function setToken(address iToken) external onlyRole(OPERATOR_ROLE) {
        _checkAddress(iToken);
        token = iToken;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
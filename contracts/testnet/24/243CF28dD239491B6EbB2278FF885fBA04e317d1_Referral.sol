// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Marketing referral contract.
/// @author @Mike_Bello90.
/// @notice You can use this contract for a marketing referral strategy.
/// @dev The wallet of the busines is set as owner of the contract in the constructor.
/// @dev Contract Address: 0x243CF28dD239491B6EbB2278FF885fBA04e317d1
contract Referral is ReentrancyGuard {
    /// @dev using constant to reduce gas cost.
    uint256 constant FEE_PER_USER = 0.25 ether;
    uint256 constant FEE_PER_LEVEL = 0.05 ether;
    uint8 constant MAX_REFERED_USERS_PER_LEVEL = 9;
    uint8 constant MAX_LEVELS = 10;

    /// @dev grouping types and using uint8 to reduce gas cost.
    struct User {
        string name;
        uint8 level;
        uint8 num_Referidos_PerLevel;
        address wallet_Referidor;
    }
    address public owner;
    // mapping to link a wallet with the user register
    mapping(address => User) public wallet_to_User;
    // mapping to link the wallet to its earned fees
    mapping(address => uint256) public Fees_Balances_Per_Wallet;

    // Event to confirm the user was register successfully
    event RegisterSuccessfully(string name, address walletUser);
    // Event to confirm the user update his level
    event levelUp(string name, address wallet);

    constructor() {
        // Setting the wallet of the business as owner of the contract
        owner = msg.sender;
    }

    // Function to register the user
    function RegisterUser(string memory _name, address _wallet_referidor)
        public
        payable
    {
        User storage referidor = wallet_to_User[_wallet_referidor];
        User storage newUser = wallet_to_User[msg.sender];
        // validations
        require(msg.value == FEE_PER_USER, "Fee insuficiente");
        require(
            referidor.num_Referidos_PerLevel < MAX_REFERED_USERS_PER_LEVEL,
            "El usuario referidor alcanzo el maximo de referidos en este nivel"
        );
        require(
            referidor.level <= MAX_LEVELS,
            "El usuario referidor ha completado los niveles disponibles"
        );
        // Register User
        newUser.name = _name;
        newUser.level = 1;
        newUser.num_Referidos_PerLevel = 0;
        newUser.wallet_Referidor = _wallet_referidor;

        // update the number of referred users to the referring user
        referidor.num_Referidos_PerLevel += 1;

        // calculate and split the fees
        CalculateFees(_wallet_referidor);

        // Emit the event RegisterSuccessfully
        emit RegisterSuccessfully(newUser.name, msg.sender);
    }

    // Function to level up the user
    function LevelUp() public payable {
        require(msg.value == FEE_PER_LEVEL, "Fee Insuficiente");
        User storage user = wallet_to_User[msg.sender];
        // user.num_Referidos_PerLevel = 9; // usado solo para testear que el requiere que valida el nivel y el resto de la funcion trabaja correctamente.
        require(
            user.num_Referidos_PerLevel == MAX_REFERED_USERS_PER_LEVEL,
            "Aun hay Spots disponibles para tu actual nivel"
        );
        require(
            user.level < MAX_LEVELS,
            "Ya has usado todos tus spots de referidos disponibles"
        );
        // Setting the fee to the business wallet / owner
        Fees_Balances_Per_Wallet[owner] += msg.value;
        // Updating user level and number of spots available
        user.level += 1;
        user.num_Referidos_PerLevel = 0;
        //emiting the event
        emit levelUp(user.name, msg.sender);
    }

    // Function to Withdraw the Fees
    function withdrawFees() public nonReentrant {
        require(
            Fees_Balances_Per_Wallet[msg.sender] > 0,
            "No tienes Fees Disponibles"
        );

        uint256 amount = Fees_Balances_Per_Wallet[msg.sender];
        Fees_Balances_Per_Wallet[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Function to calulate and split the fees
    function CalculateFees(address _walletReferidor) private {
        // valite if num_Referidos_PerLevel es el 3°, 6°, 9°
        bool is_Third_User = wallet_to_User[_walletReferidor]
            .num_Referidos_PerLevel %
            3 ==
            0
            ? true
            : false;

        if (is_Third_User) {
            // uint256 feeForThirdUser = (FEE_PER_USER * 50) / 100;  evitamos computacion en la blockchain para salvar gas
            Fees_Balances_Per_Wallet[_walletReferidor] += 0.125 ether;
            Fees_Balances_Per_Wallet[owner] += 0.125 ether;
        } else {
            // uint256 feeForUsers = (FEE_PER_USER * 70) / 100;
            Fees_Balances_Per_Wallet[_walletReferidor] += 0.175 ether;
            Fees_Balances_Per_Wallet[owner] += 0.075 ether;
        }
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
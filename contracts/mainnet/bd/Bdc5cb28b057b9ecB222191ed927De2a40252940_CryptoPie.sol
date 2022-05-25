// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract CryptoPie {
    event GrantAdmin(address indexed caller, address indexed user);
    event RevokeAdmin(address indexed caller, address indexed user);
    event GrantManager(address indexed caller, address indexed user);
    event RevokeManager(address indexed caller, address indexed user);
    event AddToken(address indexed caller, address indexed token_addres,
        uint256 numerator_fee, uint256 denumerator_fee, uint256 minimum_fee, uint256 minimum_price, uint256 minimum_delay);
    event RemoveToken(address indexed caller, address indexed token_addres);
    event CreateSubscription(address indexed caller, address indexed funds_receiver,
        address indexed token_addres, uint256 price, uint256 delay_between_payments_seconds);
    event ChangeSubscriptionFee(address indexed caller, uint256 indexed subscription_id,
        uint256 minimum_fee, uint256 numerator_fee, uint256 denumerator_fee);
    event ChangeSubscriptionFundsReceiver(address indexed caller, uint256 indexed subscription_id,
        address indexed funds_receiver);
    event InternalProcess(address indexed caller, uint256 indexed subscription_id, address indexed user,
        uint256 subscription_price, uint256 funds_to_transfer);
    event Process(address indexed caller, uint256 indexed subscription_id, uint256 successful_claims, uint256 failed_claims);
    event Subscribe(address indexed caller, address indexed user, uint256 subscription_id);
    event UnSubscribe(address indexed caller, address indexed user, uint256 subscription_id);
    event Withdrawal(address indexed caller, address indexed withdrawal_address,
        address indexed token_addres,uint256 amount);

    struct Subscription {
        uint256 price;
        uint256 delay_between_payments_seconds;
        address token_addres;
        address funds_receiver;
        address creator;
        uint256 minimum_fee;
        uint256 numerator_fee;
        uint256 denumerator_fee;
        mapping(address => uint256) user_last_payment;
    }

    struct TokenConfig {
        uint256 numerator_fee;
        uint256 denumerator_fee;
        uint256 minimum_fee;
        uint256 minimum_price;
        uint256 minimum_delay;
    }

    address private _owner;
    mapping(address => TokenConfig) private _token_config;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _managers;
    uint256 private _subscriptions_total;
    mapping(uint256 => Subscription) private _subscriptions;
    mapping(address => uint256[]) private _subscriptions_by_creator;
    
    constructor() {
        _owner = msg.sender;
        _subscriptions_total = 0;
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    function getTokenConfigNumeratorFee(address token_addres) external view returns (uint256) {
        return _token_config[token_addres].numerator_fee;
    }

    function getTokenConfigDenumeratorFee(address token_addres) external view returns (uint256) {
        return _token_config[token_addres].denumerator_fee;
    }

    function getTokenConfigMinimumFee(address token_addres) external view returns (uint256) {
        return _token_config[token_addres].minimum_fee;
    }

    function getTokenConfigMinimumPrice(address token_addres) external view returns (uint256) {
        return _token_config[token_addres].minimum_price;
    }

    function getTokenConfigMinimumDelay(address token_addres) external view returns (uint256) {
        return _token_config[token_addres].minimum_delay;
    }

    function isAdmin(address user) external view returns (bool) {
        return _admins[user];
    }

    function isManager(address user) external view returns (bool) {
        return _managers[user];
    }

    function subscriptionsTotal() external view returns (uint256) {
        return _subscriptions_total;
    }

    function getSubscriptionPrice(uint256 subscription_id) external view returns (uint256) {
        return _subscriptions[subscription_id].price;
    }

    function getSubscriptionDelay(uint256 subscription_id) external view returns (uint256) {
        return _subscriptions[subscription_id].delay_between_payments_seconds;
    }

    function getSubscriptionTokenAddress(uint256 subscription_id) external view returns (address) {
        return _subscriptions[subscription_id].token_addres;
    }

    function getSubscriptionFundsReceiver(uint256 subscription_id) external view returns (address) {
        return _subscriptions[subscription_id].funds_receiver;
    }

    function getSubscriptionCreator(uint256 subscription_id) external view returns (address) {
        return _subscriptions[subscription_id].creator;
    }

    function getSubscriptionMinimumFee(uint256 subscription_id) external view returns (uint256) {
        return _subscriptions[subscription_id].minimum_fee;
    }

    function getSubscriptionNumeratorFee(uint256 subscription_id) external view returns (uint256) {
        return _subscriptions[subscription_id].numerator_fee;
    }

    function getSubscriptionDenumeratorFee(uint256 subscription_id) external view returns (uint256) {
        return _subscriptions[subscription_id].denumerator_fee;
    }

    function getSubscriptionUserLastPayment(uint256 subscription_id, address user) external view returns (uint256) {
        return _subscriptions[subscription_id].user_last_payment[user];
    }

    function getCreatorSubscriptions(address creator) external view returns (uint256[] memory) {
        return _subscriptions_by_creator[creator];
    }

    modifier onlyOwner {
        require(msg.sender == _owner,
            "Only owner is authorized to execute this function");
        _;
    }

    modifier onlyOwnerOrAdmin {
        require(msg.sender == _owner || _admins[msg.sender],
            "Only owner or admin are authorized to execute this function");
        _;
    }

    modifier onlyOwnerOrAdminOrManager {
        require(msg.sender == _owner || _admins[msg.sender] || _managers[msg.sender],
            "Only owner or admin or manager are authorized to execute this function");
        _;
    }

    function grant_admin(address user) external onlyOwner {
        _admins[user] = true;
        emit GrantAdmin(msg.sender, user);
    }

    function grant_manager(address user) external onlyOwnerOrAdmin {
        _managers[user] = true;
        emit GrantManager(msg.sender, user);
    }

    function revoke_admin(address user) external onlyOwner {
        _admins[user] = false;
        emit RevokeAdmin(msg.sender, user);
    }

    function revoke_manager(address user) external onlyOwnerOrAdmin {
        _managers[user] = false;
        emit RevokeManager(msg.sender, user);
    }

    function add_token(
        address token_addres,
        uint256 numerator_fee,
        uint256 denumerator_fee,
        uint256 minimum_fee,
        uint256 minimum_price,
        uint256 minimum_delay
    ) external onlyOwnerOrAdmin {
        require(denumerator_fee > 0, "Denumerator Fee has to be greater than zero");
        require(numerator_fee <= denumerator_fee, "Denumerator fee has to be greater than numerator fee");
        _token_config[token_addres] = TokenConfig({
            numerator_fee: numerator_fee,
            denumerator_fee: denumerator_fee,
            minimum_fee: minimum_fee,
            minimum_price: minimum_price,
            minimum_delay: minimum_delay
        });
        emit AddToken(msg.sender, token_addres, numerator_fee, denumerator_fee, minimum_fee, minimum_price, minimum_delay);
    }

    function remove_token(address token_addres) external onlyOwnerOrAdmin {
        delete _token_config[token_addres];
        emit RemoveToken(msg.sender, token_addres);
    }

    function create_subscription(
        uint256 price,
        uint256 delay_between_payments_seconds,
        address token_addres,
        address funds_receiver
    ) external {
        require(_token_config[token_addres].minimum_price > 0, "Token is not authorized");
        require(_token_config[token_addres].minimum_price <= price, "Price is low");
        require(_token_config[token_addres].minimum_delay <= delay_between_payments_seconds, "Delay is low");

        _subscriptions[_subscriptions_total].price = price;
        _subscriptions[_subscriptions_total].delay_between_payments_seconds = delay_between_payments_seconds;
        _subscriptions[_subscriptions_total].token_addres = token_addres;
        _subscriptions[_subscriptions_total].funds_receiver = funds_receiver;
        _subscriptions[_subscriptions_total].creator = msg.sender;
        _subscriptions[_subscriptions_total].minimum_fee = _token_config[token_addres].minimum_fee;
        _subscriptions[_subscriptions_total].numerator_fee = _token_config[token_addres].numerator_fee;
        _subscriptions[_subscriptions_total].denumerator_fee = _token_config[token_addres].denumerator_fee;
        
        _subscriptions_by_creator[msg.sender].push(_subscriptions_total);
        _subscriptions_total += 1;

        emit CreateSubscription(msg.sender, funds_receiver, token_addres, price, delay_between_payments_seconds);
    }

    function change_subscription_fee(uint256 subscription_id, uint256 minimum_fee, uint256 numerator_fee, uint256 denumerator_fee) external onlyOwnerOrAdmin {
        require(_subscriptions[subscription_id].price > 0, "Subscription not found");
        require(denumerator_fee > 0, "Denumerator Fee has to be greater than zero");
        require(numerator_fee <= denumerator_fee, "Denumerator fee has to be greater than numerator fee");
        _subscriptions[subscription_id].minimum_fee = minimum_fee;
        _subscriptions[subscription_id].numerator_fee = numerator_fee;
        _subscriptions[subscription_id].denumerator_fee = denumerator_fee;

        emit ChangeSubscriptionFee(msg.sender, subscription_id, minimum_fee, numerator_fee, denumerator_fee);
    }
    
    function change_subscription_funds_receiver(uint256 subscription_id, address funds_receiver) external {
        require(_subscriptions[subscription_id].price > 0, "Subscription not found");
        require(msg.sender == _subscriptions[subscription_id].creator, "User is not authorized to change the subscription");
        _subscriptions[subscription_id].funds_receiver = funds_receiver;

        emit ChangeSubscriptionFundsReceiver(msg.sender, subscription_id, funds_receiver);
    }

    function _process(uint256 subscription_id, address user) internal returns (bool) {
        IERC20 token = IERC20(_subscriptions[subscription_id].token_addres);
        
        uint256 subscription_price = _subscriptions[subscription_id].price;
        uint256 subscription_delay = _subscriptions[subscription_id].delay_between_payments_seconds;
        uint256 subscription_minimumfee = _subscriptions[subscription_id].minimum_fee;
        uint256 subscription_numeratorfee = _subscriptions[subscription_id].numerator_fee;
        uint256 subscription_denumeratorfee = _subscriptions[subscription_id].denumerator_fee;

        if (_subscriptions[subscription_id].user_last_payment[user] > 0) {
            if (token.allowance(user, address(this)) >= subscription_price) {
                if (block.timestamp >= _subscriptions[subscription_id].user_last_payment[user] + subscription_delay) {
                    _subscriptions[subscription_id].user_last_payment[user] = block.timestamp;
                    token.transferFrom(user, address(this), subscription_price);
                    uint256 funds_to_transfer = subscription_price / subscription_denumeratorfee * (subscription_denumeratorfee - subscription_numeratorfee);
                    if (subscription_minimumfee > funds_to_transfer) {
                        funds_to_transfer = subscription_minimumfee;
                    }
                    token.transfer(_subscriptions[subscription_id].funds_receiver, funds_to_transfer);
                    emit InternalProcess(msg.sender, subscription_id, user, subscription_price, funds_to_transfer);
                    return true;
                }
            }
        }
        return false;
    }

    function process(uint256 subscription_id, address[] memory users) external onlyOwnerOrAdminOrManager {
        require(_subscriptions[subscription_id].price > 0, "Subscription not found");
        uint256 successful_claims = 0;
        uint256 failed_claims = 0;
        for (uint256 i = 0; i < users.length; i++) {
            if (_process(subscription_id, users[i])) {
                successful_claims++;
            } else {
                failed_claims++;
            }
        }

        emit Process(msg.sender, subscription_id, successful_claims, failed_claims);
    }

    function subscribe(address user, uint256 subscription_id, uint8 sigv, bytes32 sigr, bytes32 sigs) external onlyOwnerOrAdminOrManager {
        require(_subscriptions[subscription_id].price > 0, "Subscription not found");
        
        string memory prefix = "\x19Ethereum Signed Message:\n";
        string memory message1 = "I agree to subscribe on subscription: ";
        string memory message2 = Strings.toString(subscription_id);
        string memory message3 = "\nThe first charge will happen immediately.";
        string memory message_length = Strings.toString(bytes(message1).length + bytes(message2).length + bytes(message3).length);
        
        require(user == ecrecover(keccak256(abi.encodePacked(prefix, message_length, message1, message2, message3)), sigv, sigr, sigs), "User signature is incorrect");
        
        _subscriptions[subscription_id].user_last_payment[user] = 1;
        require(_process(subscription_id, user), "Payment fail");

        emit Subscribe(msg.sender, user, subscription_id);
    }

    function unsubscribe(address user, uint256 subscription_id) external onlyOwnerOrAdminOrManager {
        require(_subscriptions[subscription_id].price > 0, "Subscription not found");
        _subscriptions[subscription_id].user_last_payment[user] = 0;

        emit UnSubscribe(msg.sender, user, subscription_id);
    }
    
    function withdrawal(address withdrawal_address, address[] memory tokens) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 amount = token.balanceOf(address(this));
            token.transfer(withdrawal_address, amount);

            emit Withdrawal(msg.sender, withdrawal_address, tokens[i], amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}
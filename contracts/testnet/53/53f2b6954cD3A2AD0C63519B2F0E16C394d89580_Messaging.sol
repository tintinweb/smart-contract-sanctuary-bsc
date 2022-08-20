// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../includes/access/Ownable.sol";
import "../includes/interfaces/IPriceConsumerV3.sol";

contract Messaging is Ownable {
    struct Message {
        string message;
        uint timestamp;
    }

    address public bot;
    address public treasury;

    uint public messageFee;
    uint public adminFee;

    IPriceConsumerV3 public priceConsumer;

    mapping (address => Message[]) messages;
    mapping (address => string) registrationCodes;
    mapping (address => string) aliases;
    mapping (string => address) aliasesReverse;

    mapping (address => mapping (string => string)) channels;

    event MessageSent(address _sender, string _message);
    event RegistrationCodeSet(address _sender, string _code);
    event AliasSet(address _sender, string _alias);
    event ChannelSet(address _sender, string _identifier, string _channel);

    constructor(address _bot, address _treasury, address _priceConsumer, uint _messageFee, uint _adminFee) {
        bot = _bot;
        treasury = _treasury;
        priceConsumer = IPriceConsumerV3(_priceConsumer);
        messageFee = _messageFee;
        adminFee = _adminFee;
    }

    function setBot(address _bot) public onlyOwner() { bot = _bot; }
    function setTreasury(address _treasury) public onlyOwner() { treasury = _treasury; }
    function setPriceConsumer(address _priceConsumer) public onlyOwner() { priceConsumer = IPriceConsumerV3(_priceConsumer); }
    function setMessageFee(uint _messageFee) public onlyOwner() { messageFee = _messageFee; }
    function setAdminFee(uint _adminFee) public onlyOwner() { adminFee = _adminFee; }

    function messageFeeInBnb() public view returns (uint) { return priceConsumer.usdToBnb(messageFee); }
    function adminFeeInBnb() public view returns (uint) { return priceConsumer.usdToBnb(adminFee); }
    function getAlias(address _wallet) public view returns (string memory) { return aliases[_wallet]; }
    function getWallet(string memory _alias) public view returns (address) { return aliasesReverse[_alias]; }
    function getChannel(address _sender, string memory _identifier) public view returns (string memory) { return channels[_sender][_identifier]; }

    function sendMessage(string memory _message) public payable {
        require(msg.value >= messageFeeInBnb(), 'Insufficient fee');
        _safeTransfer(treasury, msg.value);
        messages[msg.sender].push(Message({
            message: _message,
            timestamp: block.timestamp
        }));
        emit MessageSent(msg.sender, _message);
    }

    function setRegistrationCode(string memory _code) public payable {
        require(msg.value >= adminFeeInBnb(), 'Insufficient fee');
        _safeTransfer(treasury, msg.value);
        registrationCodes[msg.sender] = _code;
        emit RegistrationCodeSet(msg.sender, _code);
    }

    function setAlias(string memory _alias) public payable {
        require(msg.value >= adminFeeInBnb(), 'Insufficient fee');
        require(aliasesReverse[_alias] == address(0), 'Alias already used');

        _safeTransfer(treasury, msg.value);
        
        if (keccak256(abi.encodePacked(aliases[msg.sender])) != keccak256(''))
            aliasesReverse[aliases[msg.sender]] = address(0);

        aliases[msg.sender] = _alias;
        aliasesReverse[_alias] = msg.sender;
        emit AliasSet(msg.sender, _alias);
    }

    function setChannel(address _sender, string memory _identifier, string memory _channel) public {
        require(msg.sender == bot, 'Must be called by the bot service');
        channels[_sender][_identifier] = _channel;
        emit ChannelSet(_sender, _identifier, _channel);
    }

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success,) = _recipient.call{value : _amount}("");
        require(_success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
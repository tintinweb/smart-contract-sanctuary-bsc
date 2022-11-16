/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

// File src/interfaces/ISocket.sol

interface ISocket {
    /**
     * @notice registers a message
     * @dev Packs the message and includes it in a packet with accumulator
     * @param remoteChainSlug_ the remote chain id
     * @param msgGasLimit_ the gas limit needed to execute the payload on remote
     * @param payload_ the data which is needed by plug at inbound call on remote
     */
    function outbound(
        uint256 remoteChainSlug_,
        uint256 msgGasLimit_,
        bytes calldata payload_
    ) external payable;

    /**
     * @notice sets the config specific to the plug
     * @param remoteChainSlug_ the remote chain id
     * @param remotePlug_ address of plug present at remote chain to call inbound
     * @param integrationType_ the name of accum to be used
     */
    function setPlugConfig(
        uint256 remoteChainSlug_,
        address remotePlug_,
        string memory integrationType_
    ) external;
}

// File src/interfaces/IPlug.sol

interface IPlug {
    /**
     * @notice executes the message received from source chain
     * @dev this should be only executable by socket
     * @param payload_ the data which is needed by plug at inbound call on remote
     */
    function inbound(bytes calldata payload_) external payable;
}

// File src/utils/Ownable.sol

abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    error OnlyOwner();
    error OnlyNominee();

    constructor(address owner_) {
        _claimOwner(owner_);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert OnlyOwner();
        _;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function nominee() external view returns (address) {
        return _nominee;
    }

    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) revert OnlyOwner();
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    function claimOwner() external {
        if (msg.sender != _nominee) revert OnlyNominee();
        _claimOwner(msg.sender);
    }

    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
    }
}

// File src/examples/Messenger.sol

contract Messenger is IPlug, Ownable(msg.sender) {
    // immutables
    address private immutable _socket;
    uint256 private immutable _chainSlug;

    bytes32 private _message;
    uint256 public msgGasLimit;

    bytes32 private constant _PING = keccak256("PING");
    bytes32 private constant _PONG = keccak256("PONG");

    uint256 public constant SOCKET_FEE = 0.0001 ether;

    error NoSocketFee();

    constructor(
        address socket_,
        uint256 chainSlug_,
        uint256 msgGasLimit_
    ) {
        _socket = socket_;
        _chainSlug = chainSlug_;

        msgGasLimit = msgGasLimit_;
    }

    receive() external payable {}

    function removeGas(address payable receiver_) external onlyOwner {
        receiver_.transfer(address(this).balance);
    }

    function sendLocalMessage(bytes32 message_) external {
        _updateMessage(message_);
    }

    function sendRemoteMessage(uint256 remoteChainSlug_, bytes32 message_)
        external
        payable
    {
        bytes memory payload = abi.encode(_chainSlug, message_);
        _outbound(remoteChainSlug_, payload);
    }

    function inbound(bytes calldata payload_) external payable override {
        require(msg.sender == _socket, "Counter: Invalid Socket");
        (uint256 localChainSlug, bytes32 msgDecoded) = abi.decode(
            payload_,
            (uint256, bytes32)
        );

        _updateMessage(msgDecoded);

        bytes memory newPayload = abi.encode(
            _chainSlug,
            msgDecoded == _PING ? _PONG : _PING
        );
        _outbound(localChainSlug, newPayload);
    }

    // settings
    function setSocketConfig(
        uint256 remoteChainSlug,
        address remotePlug,
        string calldata integrationType
    ) external onlyOwner {
        ISocket(_socket).setPlugConfig(
            remoteChainSlug,
            remotePlug,
            integrationType
        );
    }

    function message() external view returns (bytes32) {
        return _message;
    }

    function _updateMessage(bytes32 message_) private {
        _message = message_;
    }

    function _outbound(uint256 targetChain_, bytes memory payload_) private {
        if (!(address(this).balance >= SOCKET_FEE)) revert NoSocketFee();
        ISocket(_socket).outbound{value: SOCKET_FEE}(
            targetChain_,
            msgGasLimit,
            payload_
        );
    }
}
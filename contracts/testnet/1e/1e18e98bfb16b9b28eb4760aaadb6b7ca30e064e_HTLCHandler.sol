// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "./BasePaymaster.sol";
import "./BaseRelayRecipient.sol";
import "./GsnUtils.sol";

contract HTLCHandler is BaseRelayRecipient, BasePaymaster {
    mapping(bytes32 => uint256) public amounts;
    mapping(bytes32 => address) public senders;
    mapping(bytes32 => address) public recipients;
    mapping(bytes32 => bytes32) public hashes;
    mapping(bytes32 => uint256) public timeouts;

    uint256 private _requiredRelayerAmount;

    event Open(bytes32 id, uint256 amount, address recipient, bytes32 hash, uint256 timeout);
    event Redeem(bytes32 id, bytes32 secret);
    event Refund(bytes32 id);

    modifier onlySender(bytes32 id) {
        require(senders[id] == _msgSender(), "modifier onlySender");
        _;
    }

    modifier onlyRecipient(bytes32 id) {
        require(recipients[id] == _msgSender(), "modifier onlyRecipient");
        _;
    }

    modifier onlyDirect() {
        require(msg.sender == _msgSender(), "modifier onlyDirect");
        _;
    }

    modifier onlyOpen(bytes32 id) {
        require(amounts[id] > 0, "modifier onlyOpen");
        _;
    }

    modifier onlyClosed(bytes32 id) {
        require(amounts[id] == 0, "modifier onlyClosed");
        _;
    }

    modifier onlySecret(bytes32 id, bytes32 secret) {
        require(hashes[id] == sha256(abi.encodePacked(secret)), "modifier onlySecret");
        _;
    }

    modifier onlyPending(bytes32 id) {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp < timeouts[id], "modifier onlyPending");
        _;
    }

    modifier onlyExpired(bytes32 id) {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= timeouts[id], "modifier onlyExpired");
        _;
    }

    modifier onlyWithValue() {
        require(msg.value > 0, "modifier onlyWithValue");
        _;
    }

    modifier onlyAmountAtLeast(bytes32 id, uint256 amount) {
        require(amounts[id] >= amount, "modifier onlyAmountAtLeast");
        _;
    }

    modifier onlyToSelf(GsnTypes.RelayRequest calldata relayRequest) {
        require(relayRequest.request.to == address(this), "modifier onlyToSelf");
        _;
    }

    function init(IRelayHub _relayHub, address _trustedForwarder) public onlyOwner {
        setRelayHub(_relayHub);
        setTrustedForwarder(_trustedForwarder);
    }

    function versionRecipient() external override virtual view returns (string memory) {
        return "2.2.6+opengsn.recipient.htlc.handler";
    }

    function versionPaymaster() external override virtual view returns (string memory) {
        return "2.2.6+opengsn.paymaster.htlc.handler";
    }

    function trustedForwarder() override(BasePaymaster, BaseRelayRecipient) public view returns (address forwarder){
        forwarder = BaseRelayRecipient.trustedForwarder();
    }

    function setTrustedForwarder(address _forwarder) public override onlyOwner {
        _setTrustedForwarder(_forwarder);
    }

    function requiredRelayerAmount() public view returns (uint256 amount) {
        amount = _requiredRelayerAmount;
    }

    function setRequiredRelayerAmount(uint256 amount) public onlyOwner {
        _requiredRelayerAmount = amount;
    }

    function _msgSender() internal view override(Context, BaseRelayRecipient) returns (address sender) {
        sender = BaseRelayRecipient._msgSender();
    }

    function _msgData() internal view override(Context, BaseRelayRecipient) returns (bytes calldata) {
        return BaseRelayRecipient._msgData();
    }

    function open(bytes32 id, address recipient, bytes32 hash, uint256 timeout) public
    onlyDirect
    onlyWithValue
    onlyClosed(id)
    payable {
        amounts[id] = msg.value;
        senders[id] = _msgSender();
        recipients[id] = recipient;
        hashes[id] = hash;
        timeouts[id] = timeout;
        emit Open(id, msg.value, recipient, hash, timeout);
    }

    function cleanup(bytes32 id) internal
    {
        delete amounts[id];
        delete senders[id];
        delete recipients[id];
        delete hashes[id];
        delete timeouts[id];
    }

    function redeem(bytes32 id, bytes32 secret, uint256 relayerAmount) public
    onlyOpen(id)
    onlyPending(id)
    onlyRecipient(id)
    onlyAmountAtLeast(id, relayerAmount)
    onlySecret(id, secret)
    {
        uint256 amount = amounts[id] - relayerAmount;
        cleanup(id);
        if (amount > 0) {
            payable(_msgSender()).transfer(amount);
        }
        emit Redeem(id, secret);
    }

    function refund(bytes32 id, uint256 relayerAmount) public
    onlyOpen(id)
    onlyExpired(id)
    onlySender(id)
    onlyAmountAtLeast(id, relayerAmount)
    {
        uint256 amount = amounts[id] - relayerAmount;
        cleanup(id);
        if (amount > 0) {
            payable(_msgSender()).transfer(amount);
        }
        emit Refund(id);
    }

    function parseCall(GsnTypes.RelayRequest calldata relayRequest)
    public pure
    returns (bytes32 id, uint256 relayerAmount){
        bytes4 methodId = GsnUtils.getMethodSig(relayRequest.request.data);
        if (methodId == bytes4(keccak256("redeem(bytes32,bytes32,uint256)"))) {
            bytes32 hash;
            (id, hash, relayerAmount) = abi.decode(relayRequest.request.data[4 :], (bytes32, bytes32, uint256));
        } else if (methodId == bytes4(keccak256("refund(bytes32,uint256)"))) {
            (id, relayerAmount) = abi.decode(relayRequest.request.data[4 :], (bytes32, uint256));
        } else {
            require(false, "trying to relay unknown method");
        }
    }

    function preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
    external
    override
    virtual
    relayHubOnly
    onlyToSelf(relayRequest)
    returns (bytes memory context, bool revertOnRecipientRevert) {
        (relayRequest, signature, approvalData, maxPossibleGas);
        (bytes32 id, uint256 relayerAmount) = parseCall(relayRequest);
        require(relayerAmount >= _requiredRelayerAmount, "wrong relayerAmount");
        require(amounts[id] >= relayerAmount, "missing funds");
        return (abi.encode(relayerAmount), true);
    }

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    )
    external
    override
    virtual
    relayHubOnly {
        (context, success, gasUseWithoutPost, relayData);
        (uint256 relayerAmount) = abi.decode(context, (uint256));
        relayHub.depositFor{value : relayerAmount}(address(this));
    }
}
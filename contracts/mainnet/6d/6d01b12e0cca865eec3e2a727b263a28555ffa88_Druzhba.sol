// SPDX-License-Identifier: UNLICENCED

pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ECDSA.sol";
import "./AccessControl.sol";

contract Druzhba is AccessControl {
    using SafeERC20 for IERC20;

    enum DealState {
        ZERO,
        START,
        PAYMENT_COMPLETE,
        DISPUTE,
        CANCELED_ARBITER,
        CANCELED_TIMEOUT_ARBITER,
        CANCELED_BUYER,
        CANCELED_SELLER,
        CLEARED_SELLER,
        CLEARED_ARBITER,
        ACCEPTED_BUYER
    }

    bytes32 public constant ARBITER_ROLE = keccak256("ARBITER_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    string public constant VERSION = "2.0";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    bytes32 private constant ACCEPT_DEAL_TYPEHASH = keccak256(abi.encodePacked("AcceptDeal(address token,address seller,address buyer,uint256 amount,uint256 fee,uint256 nonce,uint256 deadline)"));
    bytes32 private DOMAIN_SEPARATOR;

    mapping(bytes32 => DealState) public deals;
    mapping(address => uint256) public fees;

    struct DealData {
        address token;
        address seller;
        address buyer;
        uint256 amount;
        uint256 fee;
        uint256 nonce;
    }

    /***********************
    +       Events        +
    ***********************/

    event StateChanged(bytes32 indexed dealHash, DealData deal, DealState state, address creator);

    constructor(uint256 chainId, address _admin, address _signer) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ARBITER_ROLE, _admin);
        _setupRole(SIGNER_ROLE, _signer);

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("Druzhba")),
            keccak256(bytes("1")),
            chainId,
            address(this)
        ));
    }

    modifier isProperlySigned(
        DealData memory deal,
        uint256 deadline,
        bytes memory signature
    ) {
        bytes32 _hash = acceptDealHash(deal, deadline);
        address dealSigner = ECDSA.recover(_hash, signature);
        require(hasRole(SIGNER_ROLE, dealSigner), "Invalid signer or signature");
        require(block.timestamp < deadline, "Signature expired");
        _;
    }

    modifier isValidStateTransfer(
        DealData memory deal,
        DealState fromState,
        DealState toState
    ) {
        bytes32 _hash = dealHash(deal);
        require(deals[_hash] == fromState, "Wrong deal state or deal is missing");
        deals[_hash] = toState;
        _;
        emit StateChanged(_hash, deal, toState, msg.sender);
    }

    function acceptDealBuyer(DealData calldata deal, uint256 deadline, bytes memory signature) external 
        isProperlySigned(DealData(deal.token, deal.seller, _msgSenderFrw(), deal.amount, deal.fee, deal.nonce), deadline, signature) returns (bytes32) {
        require(deal.seller != _msgSenderFrw(), "seller == buyer");
        require(deal.buyer == _msgSenderFrw(), "buyer != msg.sender");

        bytes32 _hash = dealHash(deal);
        require(deals[_hash] == DealState.ZERO, "storage slot collision");
        deals[_hash] = DealState.ACCEPTED_BUYER;

        emit StateChanged(_hash, deal, DealState.ACCEPTED_BUYER, msg.sender);
        return _hash;
    }

    function startDealSeller(DealData calldata deal, uint256 deadline, bytes memory signature) external 
        isProperlySigned(DealData(deal.token, _msgSenderFrw(), deal.buyer, deal.amount, deal.fee, deal.nonce), deadline, signature) returns (bytes32) {
        require(deal.buyer != _msgSenderFrw(), "seller == buyer");
        require(deal.seller == _msgSenderFrw(), "seller != msg.sender");

        bytes32 _hash = dealHash(deal);
        require(deals[_hash] == DealState.ZERO, "storage slot collision");
        deals[_hash] = DealState.START;

        SafeERC20.safeTransferFrom(IERC20(deal.token), _msgSenderFrw(), address(this), deal.amount+deal.fee);

        emit StateChanged(_hash, deal, DealState.START, msg.sender);
        return _hash;
    }

    function startAcceptedDealSeller(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, _msgSenderFrw(), deal.buyer, deal.amount, deal.fee, deal.nonce), DealState.ACCEPTED_BUYER, DealState.START) {
        SafeERC20.safeTransferFrom(IERC20(deal.token), deal.seller, address(this), deal.amount+deal.fee);
    }

    function cancelTimeoutArbiter(DealData calldata deal) external onlyRole(ARBITER_ROLE) 
        isValidStateTransfer(deal, DealState.START, DealState.CANCELED_TIMEOUT_ARBITER) {
        SafeERC20.safeTransfer(IERC20(deal.token), deal.seller, deal.amount+deal.fee); 
    }

    function cancelDealBuyer(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, deal.seller, _msgSenderFrw(), deal.amount, deal.fee, deal.nonce), DealState.START, DealState.CANCELED_BUYER) {
        SafeERC20.safeTransfer(IERC20(deal.token), deal.seller, deal.amount+deal.fee);
    }

    function completePaymentBuyer(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, deal.seller, _msgSenderFrw(), deal.amount, deal.fee, deal.nonce), DealState.START, DealState.PAYMENT_COMPLETE) {}

    function clearDealSeller(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, _msgSenderFrw(), deal.buyer, deal.amount, deal.fee, deal.nonce), DealState.PAYMENT_COMPLETE, DealState.CLEARED_SELLER) {
        fees[deal.token] += deal.fee;
        SafeERC20.safeTransfer(IERC20(deal.token), deal.buyer, deal.amount);
    }

    function clearDisputeDealSeller(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, _msgSenderFrw(), deal.buyer, deal.amount, deal.fee, deal.nonce), DealState.DISPUTE, DealState.CLEARED_SELLER) {
        fees[deal.token] += deal.fee;
        SafeERC20.safeTransfer(IERC20(deal.token), deal.buyer, deal.amount);
    }

    function callHelpSeller(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, _msgSenderFrw(), deal.buyer, deal.amount, deal.fee, deal.nonce), DealState.PAYMENT_COMPLETE, DealState.DISPUTE) {}

    function callHelpBuyer(DealData calldata deal) external 
        isValidStateTransfer(DealData(deal.token, deal.seller, _msgSenderFrw(), deal.amount, deal.fee, deal.nonce), DealState.PAYMENT_COMPLETE, DealState.DISPUTE) {}

    function cancelDealArbiter(DealData calldata deal) external onlyRole(ARBITER_ROLE) isValidStateTransfer(deal, DealState.DISPUTE, DealState.CANCELED_ARBITER) {
        SafeERC20.safeTransfer(IERC20(deal.token), deal.seller, deal.amount+deal.fee);
    }

    function clearDealArbiter(DealData calldata deal) external onlyRole(ARBITER_ROLE) isValidStateTransfer(deal, DealState.DISPUTE, DealState.CLEARED_ARBITER) {
        fees[deal.token] += deal.fee;
        SafeERC20.safeTransfer(IERC20(deal.token), deal.buyer, deal.amount);
    }

    function claim(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = fees[token];
        fees[token] = 0;
        SafeERC20.safeTransfer(IERC20(token), msg.sender, amount);
    }

    function dealHash(DealData memory deal) internal pure returns (bytes32) {
        return keccak256(abi.encode(deal));
    }

    function acceptDealHash(DealData memory deal, uint256 deadline) internal view returns (bytes32) {
        bytes32 _hash = keccak256(abi.encode(ACCEPT_DEAL_TYPEHASH, deal.token, deal.seller, deal.buyer, deal.amount, deal.fee, deal.nonce, deadline));
        return keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, _hash));
    }

    function _msgSenderFrw() internal view returns (address) {
        return msg.sender;
    }
}
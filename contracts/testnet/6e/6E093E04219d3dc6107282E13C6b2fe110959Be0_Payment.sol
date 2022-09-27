// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./AdminControl.sol";
import "./SafeERC20.sol";
import "./ECDSA.sol";

contract Payment is AdminControl {
    uint256 orderIdMaxLength = 100;
    address public encryptor;
    address public manager;

    constructor(address[] memory admins, address managerAddress, address encryptorAddress) AdminControl(admins) {
        encryptor = encryptorAddress;
        manager = managerAddress;
    }

    // external
    function pay(string calldata orderId, address token, uint256 amount, uint256 maxBlockNumber, bytes calldata signature) external {
        require(validate(orderId, token, amount, maxBlockNumber, signature), "invalid payment parameters");
        require(block.number < maxBlockNumber, "payment is expired");
        SafeERC20.safeTransferFrom(IERC20(token), _msgSender(), address(this), amount);
        emit Paid(orderId, token, _msgSender(), amount);
    }

    // modifier
    modifier onlyManager() {
        require(manager == _msgSender(), "Payment: caller is not the manager");
        _;
    }

    // admin
    function withdraw(address token, address recipient, uint256 amount) external onlyAdmin {
        SafeERC20.safeTransfer(IERC20(token), recipient, amount);
    }

    function setOrderIdMax(uint256 len) external onlyAdmin {
        orderIdMaxLength = len;
    }

    function setPaymentManager(address managerAddress) external onlyAdmin {
        manager = managerAddress;
    }

    // manager
    function setPaymentEncryptor(address encryptorAddress) external onlyManager() {
        encryptor = encryptorAddress;
    }

    // library
    function validate(
        string calldata orderId,
        address token,
        uint256 amount,
        uint256 maxBlockNumber,
        bytes calldata signature
    ) internal returns (bool) {
        // TODO: change encodePacked to encode
        bytes32 hash = keccak256(abi.encode(orderId, token, amount, maxBlockNumber));
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);

        if (error == ECDSA.RecoverError.NoError && recovered == encryptor) {
            return true;
        }

        return false;
    }

    // EVENTS
    event Paid(string orderId, address token, address payer, uint256 amount);
}
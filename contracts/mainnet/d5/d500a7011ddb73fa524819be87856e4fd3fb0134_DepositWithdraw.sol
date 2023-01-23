// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "ReentrancyGuard.sol";
import "IERC20.sol";
import "ECDSA.sol";

contract DepositWithdraw is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    address public verifier;
    address public receiver;
    uint256 public depositFee;
    uint256 public withdrawFee;

    mapping(address => bool) public tokenList;
    mapping(string => bool) public executeOrderIds;
    mapping(string => bool) public cancelOrderIds;

    event Deposit(
        address user,
        address token,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(
        string orderId,
        address user,
        address token,
        uint256 amount,
        uint256 timestamp
    );
    event Cancel(
        string orderId,
        address user,
        address token,
        uint256 timestamp
    );

    constructor(
        address _receiver,
        address _verifier,
        address[] memory _tokenList
    ) {
        verifier = _verifier;
        receiver = _receiver;
        for (uint256 i = 0; i < _tokenList.length; i++) {
            tokenList[_tokenList[i]] = true;
        }
    }

    modifier tokenAllowed(address _token) {
        require(
            tokenList[_token] || _token == address(0),
            "depositWithdraw: token not allowed"
        );
        _;
    }

    function setToken(address _token) external onlyOwner {
        tokenList[_token] = true;
    }

    function setVerifier(address _verifier) external onlyOwner {
        verifier = _verifier;
    }

    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function setDepositFee(uint256 _depositFee) external onlyOwner {
        depositFee = _depositFee;
    }

    function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        withdrawFee = _withdrawFee;
    }

    function deposit(address _token, uint256 _amount)
        external
        payable
        nonReentrant
        tokenAllowed(_token)
    {
        if (_token == address(0)) {
            require(
                _amount == msg.value,
                "depositWithdraw: Invalid deposit amount"
            );
        } else {
            IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        }
        emit Deposit(msg.sender, _token, _amount, block.timestamp);
    }

    function withdraw(
        string memory _orderId,
        address _token,
        uint256 _amount,
        bytes memory _signature
    ) external nonReentrant tokenAllowed(_token) {
        require(
            !executeOrderIds[_orderId],
            "depositWithdraw: OrderId had been executed"
        );
        require(
            !cancelOrderIds[_orderId],
            "depositWithdraw: OrderId had been canceled"
        );

        bytes32 hashValue = keccak256(
            abi.encodePacked(_orderId, _token, _amount, msg.sender)
        );
        address recover = hashValue.toEthSignedMessageHash().recover(
            _signature
        );
        require(
            recover == verifier,
            "depositWithdraw: Message must be signed by Verifier"
        );
        executeOrderIds[_orderId] = true;
        uint256 _fee = (_amount * withdrawFee) / 10000;
        if (_token == address(0)) {
            payable(msg.sender).transfer(_amount - _fee);
            payable(receiver).transfer(_fee);
        } else {
            IERC20(_token).transfer(msg.sender, _amount - _fee);
            IERC20(_token).transfer(receiver, _fee);
        }
        emit Withdraw(_orderId, msg.sender, _token, _amount, block.timestamp);
    }

    function cancel(
        string memory _orderId,
        address _token,
        bytes memory _signature
    ) external tokenAllowed(_token) {
        bytes32 hashValue = keccak256(
            abi.encodePacked(_orderId, _token, msg.sender)
        );
        address recover = hashValue.toEthSignedMessageHash().recover(
            _signature
        );
        require(
            recover == verifier,
            "depositWithdraw: Message must be signed by Verifier"
        );
        require(
            !cancelOrderIds[_orderId],
            "depositWithdraw: OrderId had been canceled"
        );
        cancelOrderIds[_orderId] = true;
        emit Cancel(_orderId, msg.sender, _token, block.timestamp);
    }

    function rescueFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    //amount must include decimals as well
    function rescueToken(address _token,uint _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender,_amount);
    }

}
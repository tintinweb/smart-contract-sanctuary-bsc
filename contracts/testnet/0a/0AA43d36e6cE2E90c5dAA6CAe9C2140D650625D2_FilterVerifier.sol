/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterManager {
    function adminAddress() external view returns (address);
    function treasuryAddress() external view returns (address);
    function verifyToken(address) external;
    function isTokenVerified(address) external view returns (bool);
    function verificationRequestFee() external view returns (uint);
    function verificationRequestDeadline() external view returns (uint);
}

contract FilterVerifier {
    address public managerAddress;
    IFilterManager filterManager;

    // **** CONSTRUCTOR, FALLBACK & MODIFIER FUNCTIONS ****

    constructor(address _managerAddress) {
        managerAddress = _managerAddress;
        filterManager = IFilterManager(managerAddress);
    }

    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == filterManager.adminAddress(), "FilterVerifier: FORBIDDEN");
        _;
    }

    // **** VERIFICATION REQUEST SPECIFIC ****

    mapping(address => address) public verificationRequestCreator;
    mapping(address => uint) public verificationRequestStatuses;
    mapping(address => uint) public verificationRequestDeadlines;

    // **** EVENTS ****

    event requestSubmitted(address, uint);
    event requestRejected(address);
    event requestAccepted(address);

    // **** ADMIN FUNCTIONS (verification requests) ****

    function rejectVerificationRequest(address _tokenAddress) external onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] == 1);
        verificationRequestStatuses[_tokenAddress] = 2;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(verificationRequestCreator[_tokenAddress]).transfer(filterManager.verificationRequestFee() / 2);
        payable(filterManager.treasuryAddress()).transfer(filterManager.verificationRequestFee() / 2);

        emit requestRejected(_tokenAddress);
    }

    function acceptVerificationRequest(address _tokenAddress) external onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] == 1 || verificationRequestStatuses[_tokenAddress] == 2);
        verificationRequestStatuses[_tokenAddress] = 3;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(filterManager.treasuryAddress()).transfer(filterManager.verificationRequestFee());

        filterManager.verifyToken(_tokenAddress);
        emit requestAccepted(_tokenAddress);
    }

    // **** VERIFICATION REQUEST FUNCTIONS ****

    function submitVerificationRequest(address _tokenAddress) external payable {
        require(verificationRequestStatuses[_tokenAddress] == 0, "FilterVerifier: ALREADY_SUBMITTED");
        require(!filterManager.isTokenVerified(_tokenAddress), "FilterVerifier: ALREADY_VERIFIED");    
        require(msg.value >= filterManager.verificationRequestFee(), "FilterVerifier: FEE_TOO_LOW");

        uint feeTip = 0;

        if (msg.value > filterManager.verificationRequestFee()) {
            payable(filterManager.treasuryAddress()).transfer(msg.value - filterManager.verificationRequestFee());
            feeTip = msg.value - filterManager.verificationRequestFee();
        }

        verificationRequestStatuses[_tokenAddress] = 1;
        verificationRequestDeadlines[_tokenAddress] = block.timestamp + filterManager.verificationRequestDeadline();
        verificationRequestCreator[_tokenAddress] = msg.sender;

        emit requestSubmitted(_tokenAddress, feeTip);
    }

    function claimExpiredRequestFee(address _tokenAddress) external {
        require(msg.sender == verificationRequestCreator[_tokenAddress], "FilterVerifier: NOT_REQUEST_CREATOR");
        require(verificationRequestStatuses[_tokenAddress] == 1, "FilterVerifier: CANNOT_CLAIM");
        require(verificationRequestDeadlines[_tokenAddress] < block.timestamp + filterManager.verificationRequestDeadline(), "FilterVerifier: NOT_EXPIRED_YET");

        verificationRequestStatuses[_tokenAddress] = 0;

        payable(verificationRequestCreator[_tokenAddress]).transfer(filterManager.verificationRequestFee());
    }
}
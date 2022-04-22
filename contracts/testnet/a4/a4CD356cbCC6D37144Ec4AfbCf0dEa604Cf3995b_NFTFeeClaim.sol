// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./INFTFeeClaim.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./TokensRecoverable.sol";
import "./IERC721.sol";
import "./IDegenNFT.sol";
import "./ReentrancyGuard.sol";

contract NFTFeeClaim is INFTFeeClaim, TokensRecoverable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public devAddress;
    address public paymentToken;

    mapping(address => uint256) public availableClaim;

    constructor(address _rewardsToken) {
        devAddress = msg.sender;
        paymentToken = _rewardsToken;
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        require (msg.sender == devAddress, "Not a dev address");
        devAddress = _devAddress;
    }

    function setPaymentToken(address _rewardsToken) public onlyOwner {
        paymentToken = _rewardsToken;
    }

    function depositFees(address _nftContract, uint256 _amount) override public {
        calculatePayouts(_nftContract, _amount);
        IERC20(paymentToken).transferFrom(msg.sender, address(this), _amount);
    }

    function claimPayout() public nonReentrant {
        uint256 amount = availableClaim[msg.sender];

        require (availableClaim[msg.sender] > 0, "No payout available");
        availableClaim[msg.sender] = 0;
        
        IERC20(paymentToken).transfer(msg.sender, amount);
    }

    function checkNFTOwner(address _nftContract, uint256 _nftId) public view returns (address) {
        return IERC721(_nftContract).ownerOf(_nftId);
    }

    function checkAvailableClaim(address _address) public view returns (uint256) {
        return availableClaim[_address];
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) {
        return address(token) != address(this); 
    }

    function calculatePayouts(address _nftContract, uint256 _amount) internal {
        uint totalMinted = IDegenNFT(_nftContract).totalMinted();
        uint amountPerHodler = _amount / totalMinted;
        for (uint i = 1; i <= totalMinted; i++) {
            uint nftId = i;
            address currentNftOwner = checkNFTOwner(_nftContract, nftId);
            availableClaim[currentNftOwner] += amountPerHodler;
        }
    }
}
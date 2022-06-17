/**
 * @title USDFI MINTER
 * @dev USDFI_MINTER contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./SafeERC20.sol";
import "./IUSDFI.sol";
import "./Pausable.sol";
import "./IRouter2.sol";
import "./ReentrancyGuard.sol";

pragma solidity 0.6.12;

contract USDFI_MINTER is Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    mapping(address => uint256) private lock;

    address[] public wantToUSDFI = [
        0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    ]; // STABLE => COIN

    address internal mintToken = 0x7DF1938170869AFE410098540c051A8A50308988; // USDFI

    address public unirouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // USDFI SWAP

    address public receiverAddress = 0x32dA3BdB8e0749a66b56344D294C728E0e9a2c03; // PROTOCOL RECEIVER

    address public receiverMintFeeAddress = 0x0b39568Da84ebE715148E20a8c73e2aE086c3181; // FEE RECEIVER

    uint256 public mintingFee = 980000;

    // Mint new USDFI about the way "wantToUSDFI"
    function mintNewUSDFI(uint256 _amount, uint256 _min) public whenNotPaused {
        _preCheck(_amount);

        _createNewUSDFI(_amount, _min);
    }

    // Pre Check the sender has enough tokens and has given enough permission.
    function _preCheck(uint256 _amount) public view {
        require(
            IERC20(wantToUSDFI[0]).balanceOf(msg.sender) >= _amount,
            "You need more payment Coins"
        );

        require(
            IERC20(wantToUSDFI[0]).allowance(msg.sender, address(this)) >=
                _amount,
            "You need more allowance"
        );

        require(lock[msg.sender] < block.timestamp, "60s TimeLock");
    }

    // Create new Tokens by burning "want" Token
    function _createNewUSDFI(uint256 _amount, uint256 _min)
        private
        nonReentrant
    {
        lock[msg.sender] = block.timestamp.add(60);

        IERC20(wantToUSDFI[0]).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        uint256 receivedPaymentTokenTokens = IERC20(wantToUSDFI[0]).balanceOf(
            address(this)
        );

        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                receivedPaymentTokenTokens,
                _min,
                wantToUSDFI,
                address(this),
                now
            );

        uint256 receivedWantTokens = IERC20(wantToUSDFI[1])
            .balanceOf(address(this))
            .div(100000)
            .mul(mintingFee);

        IERC20(wantToUSDFI[1]).transfer(receiverAddress, receivedWantTokens);

        USDFI(mintToken).mint(msg.sender, receivedWantTokens);

        if (mintingFee < 100000) {
            receivedWantTokens = IERC20(wantToUSDFI[1]).balanceOf(
                address(this)
            );

            IERC20(wantToUSDFI[1]).transfer(
                receiverMintFeeAddress,
                receivedWantTokens
            );
        }
    }

    function giveAllowances() public onlyOwner {
        IERC20(wantToUSDFI[0]).safeApprove(unirouter, uint256(0));
        IERC20(wantToUSDFI[0]).safeApprove(unirouter, uint256(-1));
    }

    function removeAllowances() public onlyOwner {
        IERC20(wantToUSDFI[0]).safeApprove(unirouter, uint256(0));
    }

    // Set the Address who receives the payment from minting that goes.
    function setReceiverAddress(address _receiverAddress) external onlyOwner {
        receiverAddress = _receiverAddress;
    }

    // Set the Address who receives the fee from minting that goes.
    function setReceiverMintFeeAddress(address _receiverMintFeeAddress)
        external
        onlyOwner
    {
        receiverMintFeeAddress = _receiverMintFeeAddress;
    }

    // Set the amount for the minting fee.
    function setMintingFee(uint256 _mintingFee) external onlyOwner {
        require(_mintingFee <= 100000, "more than 100%");
        mintingFee = _mintingFee;
    }
}
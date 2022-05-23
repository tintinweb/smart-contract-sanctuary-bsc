/**
 * @title USDFI MINTER
 * @dev USDFI_MINTER contract
 *
 * @author - <MIDGARD TRUST>
 * for the Midgard Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./SafeERC20.sol";
import "./IUSDFI.sol";
import "./Pausable.sol";
import "./IRouter2.sol";
import "./IReferrals.sol";
import "./ReentrancyGuard.sol";

pragma solidity 0.6.12;

contract USDFI_MINTER is Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    mapping(address => uint256) private lock;

    IReferrals public referrals;

    address[] public wantToUSDFI = [0xdEc476ce4ED4eD3182Bf05BBEC1cc1a7Ed6C9AEf, 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d]; // COIN => STABLE

    address internal mintToken = 0x8F3e0fc147B771eC4aAd4F73F1c9A23914C598A9; // USDFI

    address public unirouter = 0xb9d030725Ac9bf4A2e2A885C54F94F62D06A49cf; // USDFI SWAP

    address public receiverAddress = 0xC9690De835d64e3073c7B6e214089a477614aE57; // PROTOCOL RECEIVER

    address public receiverMintFeeAddress = 0xC9690De835d64e3073c7B6e214089a477614aE57; // FEE RECEIVER

    uint256 public minReferralAmount = 100000000000000000000;

    uint256 public mintingFee = 100000;

    // Mint new USDFI about the way "wantToUSDFI"
    function mintNewUSDFI(uint256 _amount, uint256 _min, address _sponsor) public whenNotPaused {

    _preCheck(_amount);

    _createNewUSDFI(_amount, _min);

    //_setReferral(_amount, _sponsor);

    }

    // Pre Check the sender has enough tokens and has given enough permission.
    function _preCheck(uint256 _amount) public view {
        require(IERC20(wantToUSDFI[0]).balanceOf(msg.sender) >= _amount, "You need more payment Coins");

        require(IERC20(wantToUSDFI[0]).allowance(msg.sender, address(this)) >= _amount, "You need more allowance");

        require(lock[msg.sender] < block.timestamp, "60s TimeLock");
    }

    // Create new Tokens by burning "want" Token 
    function _createNewUSDFI(uint256 _amount, uint256 _min) private nonReentrant{

    lock[msg.sender] = block.timestamp.add(60);

    IERC20(wantToUSDFI[0]).safeTransferFrom(msg.sender, address(this), _amount);

    uint256 receivedPaymentTokenTokens = IERC20(wantToUSDFI[0]).balanceOf(address(this));

    IRouter2(unirouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(receivedPaymentTokenTokens , _min, wantToUSDFI, address(this), now);

    uint256 receivedWantTokens = IERC20(wantToUSDFI[1]).balanceOf(address(this)).div(100000).mul(mintingFee);

    IERC20(wantToUSDFI[1]).transfer(receiverAddress, receivedWantTokens);

    USDFI(mintToken).mint(msg.sender, receivedWantTokens);

    if (mintingFee < 100000) {

    receivedWantTokens = IERC20(wantToUSDFI[1]).balanceOf(address(this));

    IERC20(wantToUSDFI[1]).transfer(receiverMintFeeAddress, receivedWantTokens);

    }
    }

    // Set new Referral to database.
    function _setReferral(uint256 _amount, address _sponsor) private {
        address _sponsor1 = referrals.getSponsor(msg.sender);
    if (_amount >= minReferralAmount) {
        if (referrals.isMember(msg.sender) == false) {
            if (referrals.isMember(_sponsor) == true) {
                referrals.addMember(msg.sender, _sponsor);
                _sponsor1 = _sponsor;
            } else if (referrals.isMember(_sponsor) == false) {
                _sponsor1 = referrals.membersList(0);
            }
        }
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
    function setReceiverMintFeeAddress(address _receiverMintFeeAddress) external onlyOwner {
        receiverMintFeeAddress = _receiverMintFeeAddress;
    }

    // Set the amount for the minting fee. 
    function setMintingFee(uint256 _mintingFee) external onlyOwner {
        require(_mintingFee <= 100000, "more than 100%");
        mintingFee = _mintingFee;
    }

    // Set the minimum Amount to be allowed to enter a Referral. 
    function setMinReferralAmount(uint256 _minReferralAmount) external onlyOwner {
        minReferralAmount = _minReferralAmount;
    }

    // Set ne external referral Contract.
    function updateReferralsContract(address _referralsContract)
        public
        onlyOwner
    {
        referrals = IReferrals(_referralsContract);
    }


}
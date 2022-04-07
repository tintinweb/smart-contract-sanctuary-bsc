// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "./PausableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";

import "./Initializable.sol";
import "./IERC721Upgradeable.sol";
 
import "./IERC721ReceiverUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./CountersUpgradeable.sol";
 
import "./IERC2981Upgradeable.sol";
import "./IERC165Upgradeable.sol";
 
 
contract OmnilegendsPvp is Initializable, PausableUpgradeable, OwnableUpgradeable,   ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;
 
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    string public name;

    address payable private feeReceiverAddress;

    address private oca$hAddress;

    uint256 public currentPvp;
    
    uint256 public feeAmount;

    mapping(uint256=>mapping(address=>uint256)) pvpFee;

    event PayPvpFee (
        uint256 currentPvp, 
        address buyer, 
        uint256 feeAmount,
        uint256 nonce,
        bytes sig,
        bytes walletSig
    );

    mapping(uint256 => bool) usedNonces;
    mapping (address => bool) public whitelistedSigner;

    function initialize(address ocashAddress_, address feeReceiver_) public initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        name = "Omnilegends PVP";
        
        feeReceiverAddress  = payable(feeReceiver_); 
        feeAmount = 20*10**18; // 20 ocash // NO USE ANYMORE
        oca$hAddress =  ocashAddress_;
    }

    function ocashAddress() external view returns (address) {
        return oca$hAddress;
    }
    
    function setOcashAddress(address ocashAddress_) external onlyOwner {
        oca$hAddress = ocashAddress_;
    }

    function feeAddress() external view returns (address) {
        return feeReceiverAddress;
    }

    function setFeeAddress(address feeReceiver) external onlyOwner {
        feeReceiverAddress = payable(feeReceiver);
    }

    // NO USE ANYMORE
    function setCurrentPvp(uint256 currentPvp_) external onlyOwner {
        currentPvp = currentPvp_;
    }

    function payEntryFee(uint256 nonce, bytes memory sig, bytes memory walletSig, uint256 _feeAmount, uint256 _currentPvp) external nonReentrant whenNotPaused {
        require(!usedNonces[nonce],"Used nonce");
        usedNonces[nonce] = true;
        require(_feeAmount>0,"Fee amount not set");

        require(isValidData(_feeAmount, nonce, sig, walletSig, _currentPvp)==true,"Invalid data");

        address buyer = _msgSender();

        require(pvpFee[_currentPvp][buyer] ==0,"already paid");

        // check if the approve amount is enough
        require(IERC20Upgradeable(oca$hAddress).allowance(buyer , address(this))>=_feeAmount,"Token amount allowance is not enough to buy");

        pvpFee[_currentPvp][buyer] = _feeAmount;

        transferTokens(oca$hAddress, buyer,feeReceiverAddress, _feeAmount);

        emit PayPvpFee(_currentPvp, buyer, _feeAmount, nonce, sig, walletSig);
    }

    function transferTokens(address token, address from, address to, uint amount) private {
        if (amount > 0) {
            IERC20Upgradeable(token).safeTransferFrom(from, to, amount);
        }
    }


        
    // encryption
    function isValidData(uint256 amount, uint256 nonce, bytes memory sig, bytes memory walletSig, uint256 _currentPvp) private view returns(bool){
        address _walletAddress = _msgSender();
        
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(_walletAddress, amount, _currentPvp, nonce, sig))
        );

        // verify that the wallet signed the message
        require(recoverSigner(message, walletSig)==_msgSender(),"Not signed by the user"); 

        bytes32 signedMessage = keccak256(abi.encodePacked(_walletAddress, amount, _currentPvp, nonce));

        require(whitelistedSigner[recoverSigner(signedMessage, sig)]==true, "Not signed by the authority");

        return true;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function setSigner(address _signer, bool _whitelisted) external onlyOwner {
        require(whitelistedSigner[_signer] != _whitelisted,"Invalid value for signer");
        whitelistedSigner[_signer] = _whitelisted;
    }

    function isSigner(address _signer) external view returns (bool) {
        return whitelistedSigner[_signer];
    }
    


    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address) {
       uint8 v;
       bytes32 r;
       bytes32 s;
       (v, r, s) = splitSignature(sig);
       return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) private pure returns (uint8, bytes32, bytes32) {
       require(sig.length == 65);

       bytes32 r;
       bytes32 s;
       uint8 v;

       assembly {
           // first 32 bytes, after the length prefix
           r := mload(add(sig, 32))
           // second 32 bytes
           s := mload(add(sig, 64))
           // final byte (first byte of the next 32 bytes)
           v := byte(0, mload(add(sig, 96)))
       }
 
       return (v, r, s);
    }

    


}
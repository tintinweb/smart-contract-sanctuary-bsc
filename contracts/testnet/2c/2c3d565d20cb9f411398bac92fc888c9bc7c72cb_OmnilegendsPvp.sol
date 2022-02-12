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
        uint256 feeAmount
    );


    function initialize(address ocashAddress_, address feeReceiver_) public initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        name = "Omnilegends PVP";
        
        feeReceiverAddress  = payable(feeReceiver_); 
        feeAmount = 20*10**18; // 20 ocash
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

    function setCurrentPvp(uint256 currentPvp_) external onlyOwner {
        currentPvp = currentPvp_;
    }

    function payEntryFee() external nonReentrant whenNotPaused {
        address buyer = _msgSender();

        require(pvpFee[currentPvp][buyer] ==0,"already paid");

        // check if the approve amount is enough
        require(IERC20Upgradeable(oca$hAddress).allowance(buyer , address(this))>=feeAmount,"Token amount allowance is not enough to buy");

        pvpFee[currentPvp][buyer] = feeAmount;

        transferTokens(oca$hAddress, buyer,feeReceiverAddress, feeAmount);

        emit PayPvpFee(currentPvp, buyer, feeAmount);
    }

    function transferTokens(address token, address from, address to, uint amount) private {
        if (amount > 0) {
            IERC20Upgradeable(token).safeTransferFrom(from, to, amount);
        }
    }
    
    
     

    


}
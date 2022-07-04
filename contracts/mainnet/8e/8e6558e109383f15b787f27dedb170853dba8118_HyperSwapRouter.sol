// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./GasStationRecipient.sol";
import "./ITokensApprover.sol";
import "./IHyperSwap.sol";
import "./LibBytesV06.sol";
import "./LibProxyRichErrors.sol";
import "./Ownable.sol";

contract HyperSwapRouter is GasStationRecipient, Ownable {
    using LibBytesV06 for bytes;
    using SafeERC20 for IERC20;

    // Native currency address (ETH - 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, MATIC - 0x0000000000000000000000000000000000001010)
    address private nativeAddress;

    address payable public beneficiary;
    address payable public allowanceTarget;
    IHyperSwap public hyperSwap;
    ITokensApprover public approver;

    uint256 public feeBeneficiary = 5; // 0.05%
    uint256[4] public feeReferrals = [4, 3, 2, 1];  // 0.05%, 0.03%, 0.02%, 0.01%

    event BeneficiaryChanged(address indexed beneficiary);
    event AllowanceTargetChanged(address indexed allowanceTarget);
    event HyperSwapChanged(address indexed hyperSwap);
    event TokensApproverChanged(address indexed approver);
    event FeePayment(address indexed recipient, address token, uint256 amount);

    constructor(address _nativeAddress, IHyperSwap _hyperSwap, address payable _allowanceTarget, address payable _beneficiary, address _gasStation, ITokensApprover _approver) {
        nativeAddress = _nativeAddress;
        hyperSwap = _hyperSwap;
        allowanceTarget = _allowanceTarget;
        beneficiary = _beneficiary;
        approver = _approver;

        _setGasStation(_gasStation);
    }

    receive() external payable {}

    function setHyperSwap(IHyperSwap _hyperSwap) public onlyOwner {
        require(address(_hyperSwap) != address(0), "Invalid HyperSwap address");
        hyperSwap = _hyperSwap;
        emit HyperSwapChanged(address(hyperSwap));
    }

    function setAllowanceTarget(address payable _allowanceTarget) public onlyOwner {
        require(_allowanceTarget != address(0), "Invalid allowance target");
        allowanceTarget = _allowanceTarget;
        emit AllowanceTargetChanged(allowanceTarget);
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary");
        beneficiary = _beneficiary;
        emit BeneficiaryChanged(beneficiary);
    }

    function setGasStation(address _gasStation) external onlyOwner {
        _setGasStation(_gasStation);
    }

    function setApprover(ITokensApprover _approver) external onlyOwner {
        require(address(_approver) != address(0), "Invalid beneficiary");
        approver = _approver;
        emit TokensApproverChanged(address(approver));
    }

    function setFeeReferrals(uint256[4] memory _feeReferrals) public onlyOwner {
        feeReferrals = _feeReferrals;
    }

    function setFeeBeneficiary(uint256 _feeBeneficiary) public onlyOwner {
        feeBeneficiary = _feeBeneficiary;
    }

    function multiRoute(
        bytes calldata msgData,
        address inputToken,
        uint256 inputAmount,
        address outputToken,
        address[4] memory referrals
    ) external payable returns (bytes memory) {
    return _multiRoute(msgData, inputToken, inputAmount, outputToken, referrals);
    }

    function multiRouteWithPermit(
        bytes calldata msgData,
        address inputToken,
        uint256 inputAmount,
        address outputToken,
        address[4] memory referrals,
        bytes calldata approvalData
    ) external payable returns (bytes memory) {
        _permit(inputToken, approvalData);
        return _multiRoute(msgData, inputToken, inputAmount, outputToken, referrals);
    }

    function _multiRoute(
        bytes calldata msgData,
        address inputToken,
        uint256 inputAmount,
        address outputToken,
        address[4] memory referrals
    ) internal returns (bytes memory) {
        uint256 inputAmountPercent = inputAmount / 10000;
        uint256 fee = inputAmountPercent * feeBeneficiary;
        _payFees(inputToken, fee, beneficiary);
        for (uint256 i = 0; i < referrals.length; i++) {
            if (referrals[i] != address(0) && feeReferrals[i] != 0) {
                uint256 feeReferral = inputAmountPercent * feeReferrals[i];
                fee = fee + feeReferral;
                _payFees(inputToken, feeReferral, payable(referrals[i]));
            }
        }

        uint256 value = 0;
        if (inputToken == nativeAddress) {
            require(msg.value == inputAmount + fee, "Insufficient value with fee");
            value = inputAmount;
        } else {
            _sendERC20(IERC20(inputToken), _msgSender(), address(this), inputAmount);
            uint256 allowedAmount = IERC20(inputToken).allowance(address(this), allowanceTarget);
            if (allowedAmount < inputAmount) {
                IERC20(inputToken).safeIncreaseAllowance(allowanceTarget, inputAmount - allowedAmount);
            }
        }

        (bool success, bytes memory resultData) = address(hyperSwap).call{value : value}(msgData);

        if (!success) {
            _revertWithData(resultData);
        }

        if (outputToken == nativeAddress) {
            if (address(this).balance > 0) {
                _sendETH(payable(_msgSender()), address(this).balance);
            } else {
                _revertWithData(resultData);
            }
        } else {
            uint256 tokenBalance = IERC20(outputToken).balanceOf(address(this));
            if (tokenBalance > 0) {
                IERC20(outputToken).safeTransfer(_msgSender(), tokenBalance);
            } else {
                _revertWithData(resultData);
            }
        }
        _returnWithData(resultData);
    }

    function _permit(address token, bytes calldata approvalData) internal {
        if (approvalData.length > 0 && approver.hasConfigured(token)) {
            (bool success,) = approver.callPermit(token, approvalData);
            require(success, "Permit Method Call Error");
        }
    }

    function _payFees(address token, uint256 amount, address payable recipient) private {
        if (token == nativeAddress) {
            _sendETH(recipient, amount);
        } else {
            _sendERC20(IERC20(token), _msgSender(), recipient, amount);
        }
        emit FeePayment(recipient, token, amount);
    }

    function _sendETH(address payable toAddress, uint256 amount) private {
        if (amount > 0) {
            (bool success,) = toAddress.call{value : amount}("");
            require(success, "Unable to send ETH");
        }
    }

    function _sendERC20(IERC20 token, address fromAddress, address toAddress, uint256 amount) private {
        if (amount > 0) {
            token.safeTransferFrom(fromAddress, toAddress, amount);
        }
    }

    /// @dev Revert with arbitrary bytes.
    /// @param data Revert data.
    function _revertWithData(bytes memory data) private pure {
        assembly {revert(add(data, 32), mload(data))}
    }

    /// @dev Return with arbitrary bytes.
    /// @param data Return data.
    function _returnWithData(bytes memory data) private pure {
        assembly {
            return (add(data, 32), mload(data))
        }
    }
}
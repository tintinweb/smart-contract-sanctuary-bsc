/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(),"Not Owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUni {

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable
    returns (uint[] memory amounts);
    
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
    external 
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

}

interface IReimbursement {
    function getLicenseeFee(address licenseeVault, address projectContract) external view returns(uint256); // return fee percentage with 2 decimals
    function getVaultOwner(address vault) external view returns(address);
    // returns address of fee receiver or address(0) if licensee can't receive the fee (fee should be returns to user)
    function requestReimbursement(address user, uint256 feeAmount, address licenseeVault) external returns(address);
}

contract Exchange is Ownable {
    using TransferHelper for address;
    enum OrderType {EthForTokens, TokensForEth, TokensForTokens, EthForEth}
    
    IUni public PanCake = IUni(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //testnet network address for panCake
    //IUni public PanCake = IUni(0x10ED43C718714eb63d5aA57B78B54704E256024E); //main network address for panCake
    address public system;
    uint256 public processingFee = 0 ;
    
    uint256 private deadlineLimit = 20*60;      // 20 minutes by default 
    
    uint256 private collectedFees = 1; // amount of collected fee (starts from 1 to avoid additional gas usage)
    address public feeReceiver; // address which receive the fee (by default is validator)


    IReimbursement public reimbursementContract;      // reimbursement contract address

    address public companyVault;    // the vault address of our company registered in reimbursement contract

   
   
    modifier onlySystem() {
        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }
    
    constructor(address _system) 
    {
       
        system = _system;
    }
    

    function setCompanyVault(address _comapnyVault) external onlyOwner {
        companyVault = _comapnyVault;
    }

    function setReimbursementContract(address _reimbursementContarct) external onlyOwner {
        reimbursementContract = IReimbursement(_reimbursementContarct);
    }

    function setProcessingFee(uint256 _processingFees) external onlySystem {
        processingFee = _processingFees;
    }
    
    function setSystem(address _system) external onlyOwner {
        system = _system;
    }
    
    function setFeeReceiver(address _addr) external onlyOwner {
        feeReceiver = _addr;
    }
    
    function getDeadlineLimit() public view returns(uint256) {
        return deadlineLimit;
    }
    
    function setDeadlineLimit(uint256 limit) external onlyOwner {
        deadlineLimit = limit;
    }

    // get amount of collected fees that can be claimed
    function getColletedFees() external view returns (uint256) {
        // collectedFees starts from 1 to avoid additional gas usage to initiate storage (when collectedFees = 0)
        return collectedFees - 1;
    }

    // claim fees by feeReceiver
    function claimFee() external returns (uint256 feeAmount) {
        require(msg.sender == feeReceiver, "This fee can be claimed only by fee receiver!!");
        feeAmount = collectedFees - 1;
        collectedFees = 1;        
        TransferHelper.safeTransferETH(msg.sender, feeAmount);
    }
    
    
    // Call function processFee() at the end of main function for correct gas usage calculation.
    // txGas - is gasleft() on start of calling contract. Put `uint256 txGas = gasleft();` as a first command in function
    // feeAmount - fee amount that user paid
    // processing - processing fee (for cross-chain swaping)
    // licenseeVault - address that licensee received on registration and should provide when users comes from their site
    // user - address of user who has to get reimbursement (usually msg.sender)

    function processFee(uint256 txGas, uint256 feeAmount, uint256 processing, address licenseeVault, address user) internal {
        if (address(reimbursementContract) == address(0)) {
            payable(user).transfer(feeAmount); // return fee to sender if no reimbursement contract
            return;
        }
        
        uint256 licenseeFeeAmount;
        if (licenseeVault != address(0)) {
            uint256 companyFeeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
            uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licenseeVault, address(this));
            if (licenseeFeeRate != 0)
                licenseeFeeAmount = (feeAmount * licenseeFeeRate)/(licenseeFeeRate + companyFeeRate);
            if (licenseeFeeAmount != 0) {
                address licenseeFeeTo = reimbursementContract.requestReimbursement(user, licenseeFeeAmount, licenseeVault);
                if (licenseeFeeTo == address(0)) {
                    payable(user).transfer(licenseeFeeAmount);    // refund to user
                } else {
                    payable(licenseeFeeTo).transfer(licenseeFeeAmount);  // transfer to fee receiver
                }
            }
        }
        feeAmount -= licenseeFeeAmount; // company's part of fee
        collectedFees += feeAmount; 
        
        if (processing != 0) 
            payable(system).transfer(processing);  // transfer to fee receiver
        
        txGas -= gasleft(); // get gas amount that was spent on Licensee fee
        txGas = txGas * tx.gasprice;
        // request reimbursement for user
        reimbursementContract.requestReimbursement(user, feeAmount+txGas+processing, companyVault);
    }
    
    
    function _swap( 
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered,
        uint256 minExpectedAmount, 
        address to,
        uint256 dexId,
        uint256 deadline
    ) internal returns(uint256 amountOut) {
         
        require(dexId < 1, "Invalid DEX Id!");
        require(deadline >= block.timestamp, "EXPIRED: Deadline for transaction already passed.");

       if(dexId == 0){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                path[0] = PanCake.WETH();
                swapResult = PanCake.swapExactETHForTokens{value:assetInOffered}(minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = PanCake.WETH();
                TransferHelper.safeApprove(path[0], address(PanCake), assetInOffered);
                swapResult = PanCake.swapExactTokensForETH(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(PanCake), assetInOffered);
                swapResult = PanCake.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }   
            amountOut = swapResult[swapResult.length - 1];
        }
    }
    
    function executeSwap(
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256 dexId,
        uint256 deadline
    ) external payable {
        uint256 gasA = gasleft();
        uint256 receivedFees = 0;
        if(deadline == 0) {
            deadline = block.timestamp + deadlineLimit;
        }
        
        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees), "Payment = assetInOffered + fees");
            receivedFees = receivedFees + msg.value - assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            receivedFees = receivedFees + msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, dexId, deadline);
   
        processFee(gasA, receivedFees, 0, licenseeVault, msg.sender);
    }


    // If someone accidentally transfer tokens to this contract, the owner will be able to rescue it and refund sender.
    function rescueTokens(address _token) external onlyOwner {
        if (address(0) == _token) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            uint256 available = IERC20(_token).balanceOf(address(this));
            TransferHelper.safeTransfer(_token, msg.sender, available);
        }
    }

}
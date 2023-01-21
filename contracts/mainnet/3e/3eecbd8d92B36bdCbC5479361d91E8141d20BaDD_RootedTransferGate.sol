// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./Address.sol";
import "./IERC20.sol";
import "./ISwapPair.sol";
import "./ILiquidityLockedERC20.sol";
import "./ISwapRouter02.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./TokensRecoverable.sol";
import "./ITransferGate.sol";
import "./IAddressRegistry.sol";

contract RootedTransferGate is TokensRecoverable, ITransferGate {   
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ISwapPair public mainPool;
    ISwapRouter02 immutable internal swapRouter;
    ILiquidityLockedERC20 immutable internal rootedToken;
    IAddressRegistry public addressRegistry;

    bool public unrestricted;
    mapping (address => bool) public unrestrictedControllers;
    mapping (address => bool) public feeControllers;
    mapping (address => uint16) public poolsTaxRates;

    address public override feeSplitter;

    uint16 public feesRate;
    uint16 public dumpTaxStartRate;
    
    uint256 public dumpTaxDurationInSeconds;
    uint256 public dumpTaxEndTimestamp;

    constructor(ILiquidityLockedERC20 _rootedToken, ISwapRouter02 _swapRouter) {
        rootedToken = _rootedToken;
        swapRouter = _swapRouter;
    }

    function setUnrestrictedController(address unrestrictedController, bool allow) public ownerOnly() {
        unrestrictedControllers[unrestrictedController] = allow;
    }
    
    function setFeeControllers(address feeController, bool allow) public ownerOnly() {
        feeControllers[feeController] = allow;
    }

    function setFreeParticipantController(address freeParticipantController, bool allow) public ownerOnly() {
        addressRegistry.setFreeParticipantController(freeParticipantController, allow);
    }

    function setEliteParticipant(address trustedWallet, bool allow) public ownerOnly() {
        addressRegistry.setEliteParticipant(trustedWallet, allow);
    }

    function setBlacklist(address blacklistedWallet, bool allow) public ownerOnly() {
        addressRegistry.setBlacklisted(blacklistedWallet, allow);
    }

    function setFreeParticipant(address participant, bool free) public {
        require (msg.sender == owner || addressRegistry.freeParticipantControllers(msg.sender), "Not an owner or free participant controller");
        addressRegistry.setFreeParticipant(participant, free);
    }

    function setFeeSplitter(address _feeSplitter) public ownerOnly() {
        feeSplitter = _feeSplitter;
    }

    function setUnrestricted(bool _unrestricted) public {
        require (unrestrictedControllers[msg.sender], "Not an unrestricted controller");
        unrestricted = _unrestricted;
        rootedToken.setLiquidityLock(mainPool, !_unrestricted);
    }

    function setAddressRegistry(address _addressRegistry) public ownerOnly() {
        addressRegistry = IAddressRegistry(_addressRegistry);
    }

    function setMainPool(address _mainPool) public ownerOnly() {
        mainPool = ISwapPair(_mainPool);
    }

    function setPoolTaxRate(address pool, uint16 taxRate) public ownerOnly() {
        require (taxRate <= 10000, "Fee rate must be less than or equal to 100%");
        poolsTaxRates[pool] = taxRate;        
    }

    function setDumpTax(uint16 startTaxRate, uint256 durationInSeconds) public {
        require (feeControllers[msg.sender] || msg.sender == owner, "Not an owner or fee controller");
        require (startTaxRate <= 10000, "Dump tax rate must be less than or equal to 100%");

        dumpTaxStartRate = startTaxRate;
        dumpTaxDurationInSeconds = durationInSeconds;
        dumpTaxEndTimestamp = block.timestamp + durationInSeconds;
    }

    function getDumpTax() public view returns (uint256) {
        if (block.timestamp >= dumpTaxEndTimestamp) {
            return 0;
        }
        
        return dumpTaxStartRate*(dumpTaxEndTimestamp - block.timestamp)*1e18/dumpTaxDurationInSeconds/1e18;
    }

    function setFees(uint16 _feesRate) public {
        require (feeControllers[msg.sender] || msg.sender == owner, "Not an owner or fee controller");
        require (_feesRate <= 10000, "Fee rate must be less than or equal to 100%");
        feesRate = _feesRate;
    }

    function handleTransfer(address, address from, address to, uint256 amount) public virtual override returns (uint256 fees) {
        if (unrestricted || addressRegistry.freeParticipant(from) || addressRegistry.freeParticipant(to)) {
            return 0;
        }

        if (addressRegistry.blacklist(from) || addressRegistry.blacklist(to)) {
            return amount;
        }

        uint16 poolTaxRate = poolsTaxRates[to];

        uint256 dumpTaxInEffect = getDumpTax();

        if (addressRegistry.eliteParticipant(from) || addressRegistry.eliteParticipant(to)) {
            dumpTaxInEffect = 0;
        }

        if (poolTaxRate > feesRate) {
            uint256 totalTax = dumpTaxInEffect + poolTaxRate;
            return totalTax >= 10000 ? amount : amount * totalTax / 10000;
        }

        return amount * feesRate / 10000;
    }   
}
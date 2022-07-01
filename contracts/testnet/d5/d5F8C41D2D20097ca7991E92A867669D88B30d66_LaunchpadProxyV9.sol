// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interface/ILaunchpadProxy.sol";
import "../library/DataType.sol";
import "../library/Errors.sol";
import "../library/Logic.sol";

// Element Launchpad Proxy
contract LaunchpadProxyV9 is ILaunchpadProxy,Ownable,ReentrancyGuard {
    // proxy id, bytes4(keccak256("LaunchpadProxyV9"));
    bytes4 constant internal PROXY_ID = 0x8733c8f2;

    // element 0x erc20 asset proxy
    address zeroExERC20AssetProxy = 0x95a34450Bd857deF14766CF2ae542786A2A0319C; // bsc default mainnet address

    // Launchpad Events
    event SetCollaborator(address coo);
    event ChangeAuthorizedAddress(address indexed target, bool addOrRemove);
    event SetLaunchpadController(address controllerAdmin, uint8 permission);
    event AddLaunchpadData(bytes4 proxyId, bytes4 indexed launchpadId, string indexed launchpadName, uint256 launchpadNum,
        address controllerAdmin, uint8 permission, address zeroExERC20Proxy);
    event ChangeSlotStartIdAndSaleQty(bytes4 proxyId, bytes4 indexed launchpadId, uint256 slotIdx, uint256 startId, uint256 saleQty);
    event SetLaunchpadERC20AssetProxy(bytes4 proxyId, bytes4 indexed launchpadId, address erc20AssetProxy);
    event WhiteListAdd(bytes4 indexed launchpadId, address[] whitelist, uint8[] buyNum);

    // collaborator address
    address public collaborator;

    // authority address to call this contract, (buy, open must call from external)
    mapping(address => bool) authorities;
    bool checkAuthority;

    // launchpad infos
    uint256 public numLaunchpads;
    mapping(bytes4 => DataType.Launchpad) launchpads;

    // launchpad dynamic vars
    mapping(bytes4 => DataType.LaunchpadVar) launchpadVars;

    // collaborator or owner
    modifier onlyCollaboratorOrOwner() {
        require(owner() == _msgSender() || collaborator == _msgSender(), Errors.LPAD_ONLY_COLLABORATOR_OWNER);
        _;
    }

    // constructor
    constructor(address coo, address authorizedTarget, bool checkAuth) {
        collaborator = coo; // set collaborator
        authorities[authorizedTarget] = true;
        checkAuthority = checkAuth;
    }

    // proxy id
    function getProxyId() external pure override returns (bytes4) {
        return PROXY_ID;
    }

    // launchpad controller or collaborator or owner
    function onlyLPADController(address msgSender, address controllerAdmin, DataType.CtlPermission ctlPermission, DataType.CtlPermission permission) internal {
        if (msgSender == controllerAdmin) {
            require (uint8(ctlPermission) >= uint8(permission), Errors.LPAD_CONTROLLER_NO_PERMISSION);
        } else {
            require(owner() == msgSender || collaborator == msgSender, Errors.LPAD_ONLY_CONTROLLER_COLLABORATOR_OWNER);
        }
    }

    // change author address to call this contract
    function changeAuthorizedAddress(address target, bool opt) external onlyCollaboratorOrOwner {
        authorities[target] = opt;
        emit ChangeAuthorizedAddress(target, opt);
    }

    function setCheckAuthority(bool checkAuth) external onlyCollaboratorOrOwner {
        checkAuthority = checkAuth;
    }

    function setCollaborator(address coo) external onlyOwner {
        collaborator = coo; // set collaborator
        emit SetCollaborator(coo);
    }

    // add a new launchpad, onlyCollaboratorOrOwner can call this
    function addLaunchpad(
        string memory name,
        address controllerAdmin,
        DataType.CtlPermission perm,
        uint256 referralFeePct,
        address[] memory feeReceipts,
        uint256[] memory fees,
        address[] memory signers,
        bool enable
    ) external onlyCollaboratorOrOwner returns (bytes4) {

        bytes4 launchpadId = bytes4(keccak256(bytes(name)));
        require(launchpads[launchpadId].id == 0, Errors.LPAD_ID_EXISTS);

        // add launchpad
        DataType.addLaunchpad(launchpads[launchpadId], name, controllerAdmin, perm, referralFeePct,
            feeReceipts, fees, signers, zeroExERC20AssetProxy, enable);

        numLaunchpads += 1;
        emit AddLaunchpadData(PROXY_ID, launchpadId, name, numLaunchpads, controllerAdmin, uint8(perm), zeroExERC20AssetProxy);
        return launchpadId;
    }

    // get launchpad info
    function getLaunchpadInfo(bytes4 launchpadId, uint256[] memory params) external view override
        returns
    (
        bool[] memory boolData,
        uint256[] memory intData,
        address[] memory addressData,
        bytes[] memory bytesData
    ) {
        return Logic.getLaunchpadInfo(launchpads[launchpadId]);
    }

    // set controller
    function setLaunchpadController(bytes4 launchpadId, address controller, DataType.CtlPermission perm) external onlyCollaboratorOrOwner {
        launchpads[launchpadId].controllerAdmin = controller;
        launchpads[launchpadId].ctlPermission = perm;
        emit SetLaunchpadController(controller, uint8(perm));
    }

    // set 0xErc20AssetProxy
    function setLaunchpadAssetProxy(bytes4 launchpadId, address zxERC20Proxy) external onlyCollaboratorOrOwner {
        if (launchpadId == 0xFFFFFFFF) {
            zeroExERC20AssetProxy = zxERC20Proxy;
        } else {
            launchpads[launchpadId].zeroExERC20AssetProxy = zxERC20Proxy;
        }
        emit SetLaunchpadERC20AssetProxy(PROXY_ID, launchpadId, zxERC20Proxy);
    }

    // set fees and receipts
    function setLaunchpadFeeParam(bytes4 launchpadId, address[] memory feeReceipts, uint256[] memory fees, uint256 referralFee) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P7); // only controller
        require(!launchpads[launchpadId].lockParam, Errors.LPAD_PARAM_LOCKED); // only when not locked
        DataType.setFeeAndReceipt(launchpads[launchpadId], feeReceipts, fees);
        DataType.setReferralFee(launchpads[launchpadId], referralFee);
    }

    // set enable/lock; enable-means can buy/open;  lock-means can't change param by controller address;
    function setLaunchpadEnableAndLocked(bytes4 launchpadId, bool enable, bool lock) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P1); // only owner/collaborator/controller
        if (!lock) {
            // except controller, he can't unlock, he only can lock param
            require(_msgSender() != launchpads[launchpadId].controllerAdmin, Errors.LPAD_ONLY_COLLABORATOR_OWNER);
        }
        // any one above can lock
        launchpads[launchpadId].lockParam = lock;
        launchpads[launchpadId].enable = enable;
    }

    // add launchpad slot; slot can only add, not allow to delete
    function addLaunchpadSlot(bytes4 launchpadId, DataType.LaunchpadSlot memory slot) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P6); // only controller
        Logic.checkAddLaunchpadSlot(slot);
        launchpads[launchpadId].slots.push(slot);
    }

    //  buy
    function launchpadBuy(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 quantity,
        uint256[] calldata additional,
        bytes calldata data
    ) payable external override nonReentrant returns (uint256) {
        if (checkAuthority) {
            require(authorities[_msgSender()], Errors.LPAD_ONLY_AUTHORITIES_ADDRESS);
        } else {
            require(sender == _msgSender(), Errors.SENDER_MUST_TX_CALLER);
        }
        return Logic.processBuy(launchpads[launchpadId],
            launchpadVars[launchpadId].accountSlotStats[DataType.genSlotAddressKey(sender, slotIdx)],
            slotIdx, sender, quantity, additional, data);
    }

    // open box
    function launchpadOpenBox(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        address tokenAddr,
        uint256 tokenId,
        uint256 quantity,
        uint256[] memory additional
    ) external override nonReentrant {
        if (checkAuthority) {
            require(authorities[_msgSender()], Errors.LPAD_ONLY_AUTHORITIES_ADDRESS);
        } else {
            require(sender == _msgSender(), Errors.SENDER_MUST_TX_CALLER);
        }
        return Logic.processOpenBox(launchpads[launchpadId], sender, slotIdx, tokenAddr, tokenId, quantity, additional);
    }

    // do some operation;
    function launchpadDoOperation(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        address[] memory addrData,
        uint256[] memory intData,
        bytes[] memory byteData
    ) payable nonReentrant override external {
        if (checkAuthority) {
            require(authorities[_msgSender()], Errors.LPAD_ONLY_AUTHORITIES_ADDRESS);
        } else {
            require(sender == _msgSender(), Errors.SENDER_MUST_TX_CALLER);
        }
        return Logic.processDoOperation(launchpads[launchpadId], sender, slotIdx, addrData, intData, byteData);
    }


    // get slot info of launchpad , override
    function getLaunchpadSlotInfo(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx
    ) external view override returns (
        bool[] memory boolData,
        uint256[] memory intData,
        address[] memory addressData,
        bytes4[] memory bytesData
    ) {
        return Logic.getLaunchpadSlotInfo(launchpads[launchpadId], sender, slotIdx);
    }

    function setSlotStartTimeAndFlags(
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 saleStart,
        uint256 saleEnd,
        uint256 openboxStart,
        uint256 whitelistStart,
        bool[] memory flags
    ) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P1); // only controller
        DataType.setSlotStartTimeAndFlags(launchpads[launchpadId], slotIdx, saleStart, saleEnd, openboxStart, whitelistStart, flags);
    }

    function setSlotSupplyParam(
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 maxSupply,
        uint256 maxBuyQtyPerAccount,
        uint256 maxBuyNumOnce,
        uint256 buyIntervalBlock
    ) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P2); // only controller
        DataType.setSlotSupplyParam(launchpads[launchpadId], slotIdx, maxSupply, maxBuyQtyPerAccount, maxBuyNumOnce, buyIntervalBlock);
    }

    // !!! be careful to set startTokenId & SaleQuantity in the running launchpad
    function setStartTokenIdAndSaleQuantity(
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 startTokenId,
        uint256 saleQuantity
    ) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P3); // only controller
        require(!launchpads[launchpadId].lockParam, Errors.LPAD_PARAM_LOCKED); // only when not locked
        launchpads[launchpadId].slots[slotIdx].startTokenId = uint128(startTokenId);
        launchpads[launchpadId].slots[slotIdx].saleQuantity = uint32(saleQuantity);
        emit ChangeSlotStartIdAndSaleQty(PROXY_ID, launchpadId, slotIdx, startTokenId, saleQuantity);
    }

    // set buy token address and price
    function setBuyTokenAndPrice(
        bytes4 launchpadId,
        uint256 slotIdx,
        address buyToken,
        uint256 buyPrice
    ) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P5); // only controller
        require(!launchpads[launchpadId].lockParam, Errors.LPAD_PARAM_LOCKED); // only when not locked
        DataType.setSlotBuyTokenAndPrice(launchpads[launchpadId], slotIdx, buyToken, buyPrice);
    }

    // set target abi
    function setTargetContractAndABI(bytes4 launchpadId, uint256 slotIdx, address target, bytes4[] memory abiSelector) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P4); // only controller
        DataType.setTargetContractAndABI(launchpads[launchpadId], slotIdx, target, abiSelector);
    }

    // set whitelist mode
    function setWhitelistModeAndSigner(bytes4 launchpadId, uint256 slotIdx, DataType.WhiteListModel model, address[] calldata signers) external {
        onlyLPADController(_msgSender(), launchpads[launchpadId].controllerAdmin, launchpads[launchpadId].ctlPermission, DataType.CtlPermission.P2); // only controller
        launchpads[launchpadId].slots[slotIdx].whiteListModel = model;
        if(signers.length > 0 && launchpads[launchpadId].signers.length > 0) {
            delete launchpads[launchpadId].signers;
        }
        launchpads[launchpadId].signers = signers;
    }

    // add or remove whiteList for slot;
    function addOrRemoveSlotWhiteLists(
        bytes4 launchpadId,
        uint256 slotIdx,
        address[] memory wls,
        uint8[] memory wln
    ) external {
        DataType.Launchpad storage launchpad = launchpads[launchpadId];
        onlyLPADController(_msgSender(), launchpad.controllerAdmin, launchpad.ctlPermission, DataType.CtlPermission.P0); // only controller
        require(launchpad.id > 0, Errors.LPAD_INVALID_ID);
        require(wls.length == wln.length, Errors.LPAD_INPUT_ARRAY_LEN_NOT_MATCH);
        require(launchpad.slots[slotIdx].whiteListModel == DataType.WhiteListModel.ON_CHAIN_CHECK);

        for (uint256 i=0; i < wls.length; i++) {
            // use address + slotIdx make a uint256 unique key
            launchpadVars[launchpadId].accountSlotStats[DataType.genSlotAddressKey(wls[i], slotIdx)].whiteListBuyNum = wln[i];
        }
        emit WhiteListAdd(launchpadId, wls, wln);
    }

    // is account in whitelist?  0 - not in whitelist;  > 0 means buy number,
    function isInWhiteList(
        bytes4 launchpadId,
        uint256 slotIdx,
        address[] calldata wls,
        uint256[] calldata offChainMaxBuy,
        bytes[] calldata offChainSign
    ) external view override returns (uint8[] memory wln) {
        wln = new uint8[](wls.length);
        DataType.Launchpad memory lpad = launchpads[launchpadId];
        // off-chain sign check
        if (offChainSign.length > 0) {
            require(wls.length == offChainMaxBuy.length && wls.length == offChainSign.length, Errors.LPAD_INPUT_ARRAY_LEN_NOT_MATCH);
            for (uint256 i=0; i < wls.length; i++) {
                wln[i] = uint8(LogicUtil.offChainSignCheck(lpad, wls[i], slotIdx, offChainMaxBuy[i], offChainSign[i]));
            }
        } else { // on-chain check
            for (uint256 i=0; i < wls.length; i++) {
                // use address + slotIdx make a uint256 unique key
                wln[i] = launchpadVars[launchpadId].accountSlotStats[DataType.genSlotAddressKey(wls[i], slotIdx)].whiteListBuyNum;
            }
        }
    }

    // get account info of this launchpad slot
    function getAccountInfoInLaunchpad(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 quantity
    ) external view override returns (
        bool[] memory boolData,
        uint256[] memory intData,
        bytes[] memory byteData
    ) {
        return Logic.getAccountInfoInLaunchpad(
            launchpads[launchpadId],
            launchpadVars[launchpadId].accountSlotStats[DataType.genSlotAddressKey(sender, slotIdx)],
            slotIdx,
            quantity,
            sender,
            (owner() == sender || collaborator == sender)
        );
    }

    // hash for whitelist
    function hashForWhitelist(
        address account,
        bytes4 launchpadId,
        uint256 slot,
        uint256 maxBuy
    ) external view returns (bytes32) {
        return LogicUtil.hashForWhitelist(account, launchpadId, slot, maxBuy);
    }

    // Emergency function: In case any ETH get stuck in the contract unintentionally
    // Only owner can retrieve the asset balance to a recipient address
    function rescueETH(address recipient) onlyOwner external {
        (bool success, ) = recipient.call{value: address(this).balance}('');
        require(success, Errors.TRANSFER_ETH_FAILED);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILaunchpadProxy {

    // proxy id
    function getProxyId() external pure returns (bytes4);

    // buy
    function launchpadBuy(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 quantity,
        uint256[] calldata additional,
        bytes calldata data
    ) payable external returns (uint256);

    // open box
    function launchpadOpenBox(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        address tokenAddr,
        uint256 tokenId,
        uint256 quantity,
        uint256[] calldata additional
    ) external;

    // do some operation
    function launchpadDoOperation(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        address[] calldata addrData,
        uint256[] calldata intData,
        bytes[] calldata byteData
    ) payable external;

    // get launchpad info
    function getLaunchpadInfo(bytes4 launchpadId, uint256[] calldata params)
        external
        view
        returns (
            bool[] memory boolData,
            uint256[] memory intData,
            address[] memory addressData,
            bytes[] memory bytesData);


    // get launchpad slot info
    function getLaunchpadSlotInfo(address sender, bytes4 launchpadId, uint256 slotIdx)
        external
        view
        returns (
            bool[] memory boolData,
            uint256[] memory intData,
            address[] memory addressData,
            bytes4[] memory bytesData);


    // get account info
    function getAccountInfoInLaunchpad(
        address sender,
        bytes4 launchpadId,
        uint256 slotIdx,
        uint256 quantity
    )
        external
        view
        returns (
            bool[] memory boolData,
            uint256[] memory intData,
            bytes[] memory byteData);


    // is in white list
    function isInWhiteList(
        bytes4 launchpadId,
        uint256 slotIdx,
        address[] calldata accounts,
        uint256[] calldata offChainMaxBuy,
        bytes[] calldata offChainSign
    ) external view returns (uint8[] memory wln);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Errors.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library  DataType {

    uint256 constant internal MAX_REFERRAL_FEE_PERCENT = 5000; // 5000 means 50%, 10000 max
    uint256 constant internal MAX_PERCENT = 10000; // 10000 means 100%

    uint256 constant internal ABI_IDX_BUY_SELECTOR          = 0; // example: bytes4(keccak256("safeMint(address,uint256)"))
    // buy param example:
    // 0x00000000 - (address sender, uint256 tokenId), default: this is standard ERC721 mintTo()
    // 0x00000001 - (address sender)
    // 0x00000002 - (address sender, uint256 tokenId, uint256 quantity)
    // 0x00000003 - (address sender, uint256 tokenId, uint256 quantity, address referral)
    // 0x00000004 - (address sender, uint256 quantity)
    // 0x00000005 - (address sender, uint256 quantity，uint256[] memory additional, bytes memory data)
    uint256 constant internal ABI_IDX_BUY_PARAM_TABLE       = 1;
    uint256 constant internal ABI_IDX_OPENBOX_SELECTOR      = 2; // example: bytes4(keccak256("open(address,uint256)"))
    // open param example:
    // 0x00000000 - (uint256 tokenId), default: ..
    // 0x00000001 - (address sender, uint256 tokenId, uint256 quantity)
    // 0x00000002 - (address sender, address tokenAddr, uint256 tokenId, uint256 quantity)
    // 0x00000003 - (address tokenAddr, uint256 tokenId)
    // 0x00000004 - (address sender, uint256 tokenId)
    uint256 constant internal ABI_IDX_OPENBOX_PARAM_TABLE   = 3;
    uint256 constant internal ABI_IDX_MAX = 4;

    // flag to control buy or open flag
    uint256 constant internal LAUNCHPAD_BUY_FLAG     = 0;   // can call buy
    uint256 constant internal LAUNCHPAD_OPENBOX_FLAG = 1;   // can call openbox
    uint256 constant internal LAUNCHPAD_CALL_BUY_FROM_CONTRACT_FLAG = 2; // support call buy from contract
    uint256 constant internal LAUNCHPAD_CALL_OPENBOX_FROM_CONTRACT_FLAG = 3; // support call openbox from contract
    uint256 constant internal LAUNCHPAD_OPENBOX_WHEN_SOLD_OUT = 4; // only when sold out can open the box
    uint256 constant internal LAUNCHPAD_FLAG_MAX     = 5;

    // process buy additional flag
    uint256 constant internal BUY_ADDITIONAL_IDX_WL_MAX_BUY_NUM = 0; // whitelist max buy number
    uint256 constant internal BUY_ADDITIONAL_IDX_SIMULATION     = 1; // simulation buy
    uint256 constant internal BUY_ADDITIONAL_IDX_REFERRAL       = 2; // referral

    // role
    uint256 constant internal ROLE_LAUNCHPAD_FEE_RECEIPTS   = 1; // fee receipt
    uint256 constant internal ROLE_LAUNCHPAD_CONTROLLER     = 2; // launchpad controller
    uint256 constant internal ROLE_PROXY_OWNER              = 4; // proxy admin
    uint256 constant internal ROLE_LAUNCHPAD_SIGNER         = 8; // launchpad signer


    // simulation flag
    uint256 constant internal SIMULATION_NONE                       = 0; // no simulation
    uint256 constant internal SIMULATION_CHECK                      = 1; // check param
    uint256 constant internal SIMULATION_CHECK_REVERT               = 2; // check param, then revert
    uint256 constant internal SIMULATION_CHECK_PROCESS_REVERT       = 3; // check param & process, then revert
    uint256 constant internal SIMULATION_CHECK_SKIP_START_PROCESS_REVERT = 4; // escape check start time param, process, then revert
    uint256 constant internal SIMULATION_CHECK_SKIP_WHITELIST_PROCESS_REVERT = 5; // escape check skip whitelist param, process, then revert
    uint256 constant internal SIMULATION_CHECK_SKIP_BALANCE_PROCESS_REVERT = 6; // escape check skip whitelist param, process, then revert
    uint256 constant internal SIMULATION_NO_CHECK_PROCESS_REVERT    = 7; // escape check param, process, then revert

    enum WhiteListModel {
        NONE,                     // 0 - No White List
        ON_CHAIN_CHECK,           // 1 - Check address on-chain
        OFF_CHAIN_SIGN,           // 2 - Signed by off-chain valid address
        OFF_CHAIN_MERKLE_ROOT     // 3 - check off-chain merkle tree root
    }

    // controller permission
    enum CtlPermission {
        P0, // whitelist account add/remove
        P1, // starTime/endTime/openBoxTime/whitelistTime/enable/lock, +P0
        P2, // maxSupply/maxBuyQtyPerAccount/maxBuyNumOnce/whitelistMode, +P1
        P3, // startTokenId/saleQuantity, +P2
        P4, // contractTarget/abiParam, +P3
        P5, // buyToken/Price, +P4
        P6, // addSlot, +P5
        P7  // fee/feeReceipts, +P6
    }

    // launchpad
    struct Launchpad {
        bytes4 id; // id of launchpad
        bool enable; // enable
        bool lockParam; // lock the launchpad param, can't change except owner
        uint16 referralFeePct; // referral pct
        uint16[] fees; // fees
        address controllerAdmin; // admin to config this launchpad params
        address[] feeReceipts; // receipts address
        LaunchpadSlot[] slots; // launchpad slot info detail
        address[] signers; // signers for whitelist
        CtlPermission ctlPermission; // controller permission
        address zeroExERC20AssetProxy; // zero ex erc20 proxy address or address(this)
    }

    // 1 launchpad have N slot
    struct LaunchpadSlot {
        address targetContract; // target contract of 3rd project,
        bytes4[ABI_IDX_MAX] abiSelectorAndParam; // 0-buy abi, 1-buy param, 2-open abi, 3-open param
        bool[LAUNCHPAD_FLAG_MAX] flags; // flags; 0-canBuy, 1-canOpen, 2-callBuyFromContract, 3-callOpenFromContract
        uint128 price; // price of normal user account, > 8888 * 10**18 means TBD
        uint128 startTokenId; // start token id, most from 0
        address buyToken; // buy token
        WhiteListModel whiteListModel; // white list model
        uint32 saleStart; // buy start time, seconds
        uint32 saleEnd; // buy end time, seconds
        uint32 boxOpenStart; // open time, seconds，type(uint256).max means not support open
        uint32 whiteListSaleStart; // whitelist start time
        uint32 maxSupply; // max supply of this slot
        uint32 saleQuantity; // current sale number, must from 0
        uint32 maxBuyQtyPerAccount; // max buy qty per address
        uint32 maxBuyNumOnce; // max buy num one tx
        uint32 buyInterval; // next buy time till last buy, seconds
        uint32 openedNum; // opened number, dynamic value
    }

    // stats info for buyer account
    struct AccountSlotStats {
        uint32 lastBuyTime; // last buy seconds,
        uint32 totalBuyQty; // total buy num already
        uint8 whiteListBuyNum; // 0 - not in whitelist, > 0 number can buy of this whitelist user
    }

    // stats info for launchpad
    struct LaunchpadVar {
        mapping (uint256 => AccountSlotStats) accountSlotStats; // account<->slot stats； key: slotIdx(96) + address(160), use genSlotAddressKey()
    }


    // event
    event FeeReceiptChange(bytes4 indexed launchpadId, address[] feeReceipts, uint256[] fees, address operator);
    event SlotBuyTokenPriceChange(bytes4 indexed launchpadId, uint256 slotIdx, address token, uint256 price);


    // add launchpad
    function addLaunchpad(
        Launchpad storage newLpad,
        string memory name,
        address controllerAdmin,
        DataType.CtlPermission perm,
        uint256 referralFeePct,
        address[] memory feeReceipts,
        uint256[] memory fees,
        address[] memory signers,
        address zxERC20Proxy,
        bool enable
    ) external {
        newLpad.id = bytes4(keccak256(bytes(name)));
        newLpad.controllerAdmin = controllerAdmin;
        newLpad.ctlPermission = perm;
        // user element zxERC20Proxy or this contract self
        newLpad.zeroExERC20AssetProxy = (zxERC20Proxy == address(0) ? address(this) : zxERC20Proxy);
        newLpad.enable = enable;
        newLpad.signers = signers;

        // referral fee
        setReferralFee(newLpad, referralFeePct);

        // feeReceipt
        setFeeAndReceipt(newLpad, feeReceipts, fees);
    }

    // set target abi & param
    function setTargetContractAndABI(Launchpad storage self, uint256 slotIdx, address target, bytes4[] memory abiSelector) external {
        require(abiSelector.length == ABI_IDX_MAX, Errors.LPAD_SLOT_ABI_ARRAY_LEN);
        self.slots[slotIdx].targetContract = target;
        for (uint256 i=0; i<ABI_IDX_MAX; i++) {
            self.slots[slotIdx].abiSelectorAndParam[i] = abiSelector[i];
        }
    }

    // set start time & flags
    function setSlotStartTimeAndFlags(
        Launchpad storage self,
        uint256 slotIdx,
        uint256 saleStart,
        uint256 saleEnd,
        uint256 openboxStart,
        uint256 whitelistStart,
        bool[] memory flags
    ) external  {
        require(flags.length == LAUNCHPAD_FLAG_MAX, Errors.LPAD_SLOT_FLAGS_ARRAY_LEN);
        self.slots[slotIdx].saleStart = uint32(saleStart);
        self.slots[slotIdx].saleEnd = uint32(saleEnd);
        self.slots[slotIdx].boxOpenStart = uint32(openboxStart);
        self.slots[slotIdx].whiteListSaleStart = uint32(whitelistStart);
        for (uint256 i=0; i<LAUNCHPAD_FLAG_MAX; i++) {
            self.slots[slotIdx].flags[i] = flags[i];
        }
    }

    // set slot supply param
    function setSlotSupplyParam(Launchpad storage self, uint256 slotIdx, uint256 maxSupply,
        uint256 maxAccountBuyQty, uint256 maxBuyOnce, uint256 buyInterval) external  {
            self.slots[slotIdx].maxSupply = uint32(maxSupply);
            self.slots[slotIdx].maxBuyQtyPerAccount = uint32(maxAccountBuyQty);
            self.slots[slotIdx].buyInterval = uint32(buyInterval);
            self.slots[slotIdx].maxBuyNumOnce = uint32(maxBuyOnce);
    }

    // set buy token and price
    function setSlotBuyTokenAndPrice(Launchpad storage self, uint256 slotIdx, address token, uint256 price) external {
        require(self.id > 0, Errors.LPAD_INVALID_ID);
        self.slots[slotIdx].buyToken = token;
        self.slots[slotIdx].price = uint128(price);
        emit SlotBuyTokenPriceChange(self.id, slotIdx, token, price);
    }

    // set referral fee
    function setReferralFee (Launchpad storage self, uint256 referralFee) public  {
        require(self.id > 0, Errors.LPAD_INVALID_ID);
        require(referralFee < MAX_REFERRAL_FEE_PERCENT, Errors.LPAD_REFERRAL_FEE_PCT_LIMIT);
        self.referralFeePct = uint16(referralFee);
    }

    // set fee, receipt
    function setFeeAndReceipt (Launchpad storage self, address[] memory feeReceipts, uint256[] memory fees) public  {
        require(self.id > 0, Errors.LPAD_INVALID_ID);

        // must set fee receipts and percent
        require(feeReceipts.length == fees.length && fees.length > 0, Errors.LPAD_INPUT_ARRAY_LEN_NOT_MATCH);

        // reset array if needed
        if (self.fees.length > 0) {
            delete self.feeReceipts;
            delete self.fees;
        }

        uint256 feeMaxPct = 0;
        for (uint256 i=0; i<fees.length; i++) {
            require(isValidAddress(feeReceipts[i]), Errors.LPAD_RECEIPT_ADDRESS_INVALID); // must invalid address
            self.feeReceipts.push(feeReceipts[i]);
            self.fees.push(uint16(fees[i]));
            feeMaxPct += fees[i];
        }
        require(feeMaxPct == DataType.MAX_PERCENT, Errors.LPAD_FEES_PERCENT_INVALID); // must total 100%
        emit FeeReceiptChange(self.id, feeReceipts, fees, msg.sender);
    }

    // is valid address
    function isValidAddress(address addr) public pure returns (bool) {
        return address(addr) == addr && address(addr) != address(0);
    }

    // convert slotIdx(96) + address(160) to a uint256 key
    function genSlotAddressKey(address account, uint256 slotIdx) public pure returns (uint256) {
        return (uint256(uint160(account)) & 0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | (slotIdx << 160);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Errors {

    string public constant OK = '0'; // 'ok'
    string public constant PROXY_ID_NOT_EXIST = '1'; // 'proxy not exist'
    string public constant PROXY_ID_ALREADY_EXIST = '2'; // 'proxy id already exists'
    string public constant LPAD_ONLY_COLLABORATOR_OWNER = '3'; // 'only collaborator,owner can call'
    string public constant LPAD_ONLY_CONTROLLER_COLLABORATOR_OWNER = '4'; //  'only controller,collaborator,owner'
    string public constant LPAD_ONLY_AUTHORITIES_ADDRESS = '5'; // 'only authorities can call'
    string public constant TRANSFER_ETH_FAILED = '6'; // 'transfer eth failed'
    string public constant SENDER_MUST_TX_CALLER = '7'; // 'sender must transaction caller'

    string public constant LPAD_INVALID_ID  = '10';  // 'launchpad invalid id'
    string public constant LPAD_ID_EXISTS   = '11';  // 'launchpadId exists'
    string public constant LPAD_RECEIPT_ADDRESS_INVALID = '12'; // 'receipt must be valid address'
    string public constant LPAD_REFERRAL_FEE_PCT_LIMIT = '13'; // 'referral fee upper limit'
    string public constant LPAD_RECEIPT_MUST_NOT_CONTRACT = '14'; // 'receipt can't be contract address'
    string public constant LPAD_NOT_ENABLE = '15'; // 'launchpad not enable'
    string public constant LPAD_TRANSFER_TO_RECEIPT_FAIL = '16'; // 'transfer to receipt address failed'
    string public constant LPAD_TRANSFER_TO_REFERRAL_FAIL = '17'; // 'transfer to referral address failed'
    string public constant LPAD_TRANSFER_BACK_TO_SENDER_FAIL = '18'; // 'transfer back to sender address failed'
    string public constant LPAD_INPUT_ARRAY_LEN_NOT_MATCH = '19'; // 'input array len not match'
    string public constant LPAD_FEES_PERCENT_INVALID = '20'; // 'fees total percent is not 100%'
    string public constant LPAD_PARAM_LOCKED = '21'; // 'launchpad param locked'
    string public constant LPAD_TRANSFER_TO_LPAD_PROXY_FAIL = '22'; // 'transfer to lpad proxy failed'

    string public constant LPAD_SIMULATE_BUY_OK = '28'; // 'simulate buy ok'
    string public constant LPAD_SIMULATE_OPEN_OK = '29'; // 'simulate open ok'

    string public constant LPAD_SLOT_IDX_INVALID = '30'; // 'launchpad slot idx invalid'
    string public constant LPAD_SLOT_MAX_SUPPLY_INVALID = '31'; // 'max supply invalid'
    string public constant LPAD_SLOT_SALE_QUANTITY = '32'; // 'initial sale quantity must 0'
    string public constant LPAD_SLOT_TARGET_CONTRACT_INVALID = '33'; // "slot target contract address not valid"
    string public constant LPAD_SLOT_ABI_ARRAY_LEN = '34'; // "invalid abi selector array not equal max"
    string public constant LPAD_SLOT_MAX_BUY_QTY_INVALID = '35'; // "max buy qty invalid"
    string public constant LPAD_SLOT_FLAGS_ARRAY_LEN = '36'; // 'flag array len not equal max'
    string public constant LPAD_SLOT_TOKEN_ADDRESS_INVALID = '37';  // 'token must be valid address'
    string public constant LPAD_SLOT_BUY_DISABLE = '38'; // 'launchpad buy disable now'
    string public constant LPAD_SLOT_BUY_FROM_CONTRACT_NOT_ALLOWED = '39'; // 'buy from contract address not allowed)
    string public constant LPAD_SLOT_SALE_NOT_START = '40'; // 'sale not start yet'
    string public constant LPAD_SLOT_MAX_BUY_QTY_PER_TX_LIMIT = '41'; // 'max buy quantity one transaction limit'
    string public constant LPAD_SLOT_QTY_NOT_ENOUGH_TO_BUY = '42'; // 'quantity not enough to buy'
    string public constant LPAD_SLOT_PAYMENT_NOT_ENOUGH = '43'; // "payment not enough"
    string public constant LPAD_SLOT_PAYMENT_ALLOWANCE_NOT_ENOUGH = '44'; // 'allowance not enough'
    string public constant LPAD_SLOT_ACCOUNT_MAX_BUY_LIMIT = '45'; // "account max buy num limit"
    string public constant LPAD_SLOT_ACCOUNT_BUY_INTERVAL_LIMIT = '46'; // 'account buy interval limit'
    string public constant LPAD_SLOT_ACCOUNT_NOT_IN_WHITELIST = '47'; // 'not in whitelist'
    string public constant LPAD_SLOT_OPENBOX_DISABLE = '48'; // 'launchpad openbox disable now'
    string public constant LPAD_SLOT_OPENBOX_FROM_CONTRACT_NOT_ALLOWED = '49'; // 'not allowed to open from contract address'
    string public constant LPAD_SLOT_ABI_BUY_SELECTOR_INVALID = '50'; // 'buy selector invalid '
    string public constant LPAD_SLOT_ABI_OPENBOX_SELECTOR_INVALID = '51'; // 'openbox selector invalid '
    string public constant LPAD_SLOT_SALE_START_TIME_INVALID = '52'; // 'sale time invalid'
    string public constant LPAD_SLOT_OPENBOX_TIME_INVALID = '53'; // 'openbox time invalid'
    string public constant LPAD_SLOT_PRICE_INVALID = '54'; // 'price must > 0'
    string public constant LPAD_SLOT_CALL_BUY_CONTRACT_FAILED = '55'; // 'call buy contract fail'
    string public constant LPAD_SLOT_CALL_OPEN_CONTRACT_FAILED = '56'; // 'call open contract fail'
    string public constant LPAD_SLOT_CALL_0X_ERC20_PROXY_FAILED = '57'; // 'call 0x erc20 proxy fail'
    string public constant LPAD_SLOT_0X_ERC20_PROXY_INVALID = '58'; // '0x erc20 asset proxy invalid'
    string public constant LPAD_SLOT_ONLY_OPENBOX_WHEN_SOLD_OUT = '59'; // 'only can open box when sold out all'
    string public constant LPAD_SLOT_ERC20_BLC_NOT_ENOUGH = '60'; // "erc20 balance not enough"
    string public constant LPAD_SLOT_PAY_VALUE_NOT_ENOUGH = '61'; // "eth send value not enough"
    string public constant LPAD_SLOT_PAY_VALUE_NOT_NEED = '62'; // 'eth send value not need'
    string public constant LPAD_SLOT_PAY_VALUE_UPPER_NEED = '63'; // 'eth send value upper need value'
    string public constant LPAD_SLOT_OPENBOX_NOT_SUPPORT = '64'; // 'openbox not support'
    string public constant LPAD_SLOT_ERC20_TRANSFER_FAILED = '65'; // 'call erc20 transfer fail'
    string public constant LPAD_SLOT_OPEN_NUM_INIT = '66'; // 'initial open number must 0'
    string public constant LPAD_SLOT_ABI_NOT_FOUND = '67'; // 'not found abi to encode'
    string public constant LPAD_SLOT_SALE_END = '68'; // 'sale end'
    string public constant LPAD_SLOT_SALE_END_TIME_INVALID = '69'; // 'sale end time invalid'
    string public constant LPAD_SLOT_WHITELIST_BUY_NUM_LIMIT = '70'; // 'whitelist buy number limit'
    string public constant LPAD_CONTROLLER_NO_PERMISSION = '71'; // 'controller no permission'
    string public constant LPAD_SLOT_WHITELIST_SALE_NOT_START = '72'; // 'whitelist sale not start yet'
    string public constant LPAD_NOT_VALID_SIGNER = '73'; // 'not valid signer'
    string public constant LPAD_SLOT_WHITELIST_TIME_INVALID = '74'; // white list time invalid
    string public constant LPAD_INVALID_WHITELIST_SIGNATURE_LEN = '75'; // invalid whitelist signature length

    string public constant LPAD_SEPARATOR = ':'; // seprator :
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Errors.sol";
import "./DataType.sol";
import "./LogicUtil.sol";

library Logic {

    bytes4 constant public zeroExERC20ProxyId = 0xf47261b0;  // element 0x erc20 assetProxyId, 0xf47261b0

    // process buy
    function processBuy(
        DataType.Launchpad storage lpad,
        DataType.AccountSlotStats storage accountStats,
        uint256 slotIdx,
        address sender,
        uint256 quantity,
        uint256[] memory additional,
        bytes memory data
    ) external returns (uint256) {

        // Simulation Buy
        uint256 simulationBuy = (additional.length > DataType.BUY_ADDITIONAL_IDX_SIMULATION) ?
            additional[DataType.BUY_ADDITIONAL_IDX_SIMULATION] : DataType.SIMULATION_NONE ;

        // check input param
        if (simulationBuy < DataType.SIMULATION_NO_CHECK_PROCESS_REVERT) {
            string memory ret = LogicUtil.checkLaunchpadBuy(
                lpad,
                accountStats,
                slotIdx,
                sender,
                quantity,
                additional.length > DataType.BUY_ADDITIONAL_IDX_WL_MAX_BUY_NUM ?
                    additional[DataType.BUY_ADDITIONAL_IDX_WL_MAX_BUY_NUM] : accountStats.whiteListBuyNum,
                data,
                simulationBuy);

            if (keccak256(bytes(ret)) != keccak256(bytes(Errors.OK))) {
                revert(ret); // check failed, revert !!!
            }

            if (simulationBuy == DataType.SIMULATION_CHECK_REVERT) {
                revert(Errors.LPAD_SIMULATE_BUY_OK);
            }
        }

        // payment of this buy total
        uint256 shouldPay = lpad.slots[slotIdx].price * quantity;

        // transfer income to receipts
        transferFees(lpad, sender, lpad.slots[slotIdx].buyToken, shouldPay, additional);

        // call contract function, buy NFT
        for (uint256 i = 0; i < quantity; i++) {
            callLaunchpadBuy(lpad, slotIdx, sender, 1, additional, data);
            // increase sale num
            lpad.slots[slotIdx].saleQuantity += 1;
        }

        // increase buy number, buy block of the sender
        accountStats.totalBuyQty += uint32(quantity);
        accountStats.lastBuyTime = uint32(block.timestamp);

        // simulate buy ok, then revert
        if (simulationBuy > DataType.SIMULATION_NONE) {
            revert(Errors.LPAD_SIMULATE_BUY_OK);
        }
        return shouldPay;
    }

    // open box
    function processOpenBox(
        DataType.Launchpad storage lpad,
        address sender,
        uint256 slotIdx,
        address tokenAddr,
        uint256 tokenId,
        uint256 quantity,
        uint256[] memory additional
    ) external {

        // Simulation open
        uint256 simulationBuy = (additional.length > DataType.BUY_ADDITIONAL_IDX_SIMULATION) ?
            additional[DataType.BUY_ADDITIONAL_IDX_SIMULATION] : DataType.SIMULATION_NONE ;

        // check
        if (simulationBuy < DataType.SIMULATION_NO_CHECK_PROCESS_REVERT) {
            string memory ret = LogicUtil.checkLaunchpadOpenBox(lpad, slotIdx, sender, tokenAddr, tokenId, quantity);
            if(keccak256(bytes(ret)) != keccak256(bytes(Errors.OK))) {
                revert(ret); // check failed, revert !!!
            }

            if (simulationBuy == DataType.SIMULATION_CHECK_REVERT) {
                revert(Errors.LPAD_SIMULATE_OPEN_OK);
            }
        }

        // call contract
        // call contract function, buy NFT
        for (uint256 i = 0; i < quantity; i++) {
            callLaunchpadOpenBox(lpad, sender, slotIdx, tokenAddr, tokenId, 1, additional);
        }
        // stats open number
        lpad.slots[slotIdx].openedNum += uint32(quantity);

        // simulate buy ok, then revert
        if (simulationBuy > DataType.SIMULATION_NONE) {
            revert(Errors.LPAD_SIMULATE_OPEN_OK);
        }
    }

    function processDoOperation(
        DataType.Launchpad memory lpad,
        address sender,
        uint256 slotIdx,
        address[] memory addrData,
        uint256[] memory intData,
        bytes[] memory byteData
    ) external {
        callLaunchpadDoOperation(lpad, sender, slotIdx, addrData, intData, byteData);
    }

    // getLaunchpadInfo
    function getLaunchpadInfo(DataType.Launchpad memory lpad)
        external view returns
    (
        bool[] memory boolData,
        uint256[] memory intData,
        address[] memory addressData,
        bytes[] memory bytesData
    ) {
        boolData = new bool[](2);
        boolData[0] = lpad.enable;
        boolData[1] = lpad.lockParam;

        bytesData = new bytes[](1);
        bytesData[0] = abi.encodePacked(lpad.id);

        addressData = new address[](2 + lpad.fees.length);
        addressData[0] = lpad.controllerAdmin;
        addressData[1] = lpad.zeroExERC20AssetProxy;

        intData = new uint256[](4 + lpad.fees.length + lpad.slots.length * 2);
        intData[0] = lpad.slots.length;
        intData[1] = lpad.fees.length;
        intData[2] = uint256(lpad.ctlPermission);
        intData[3] = lpad.referralFeePct;

        for (uint256 i = 0; i < lpad.fees.length; i++) {
            intData[i+4] = uint256(lpad.fees[i]);
            addressData[i+2] = lpad.feeReceipts[i];
        }

        // getLaunchpadInfo is override function, can't change returns value, so use fees uint256[] as saleQuantity, openNum
        for (uint256 i = 0; i < lpad.slots.length; i++) {
            intData[i+4+lpad.fees.length] += lpad.slots[i].saleQuantity;
            intData[i+4+lpad.fees.length+1] += lpad.slots[i].openedNum;
        }
    }

    // get slot info of launchpad , override
    function getLaunchpadSlotInfo(
        DataType.Launchpad memory lpad,
        address sender,
        uint256 slotIdx
    ) external view returns (
        bool[] memory boolData,
        uint256[] memory intData,
        address[] memory addressData,
        bytes4[] memory bytesData
    ) {
        if(lpad.id == 0 || slotIdx >= lpad.slots.length) {
            return (boolData,intData,addressData,bytesData); // invalid id or idx, return nothing
        }

        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];

        boolData = new bool[](DataType.LAUNCHPAD_FLAG_MAX+1);
        boolData[0] = lpad.enable; // launchpad enable
        for (uint256 i=0; i<DataType.LAUNCHPAD_FLAG_MAX; i++) {
            boolData[i+1] = lpadSlot.flags[i]; // bool flags
        }

        intData = new uint256[](11);
        intData[0] = lpadSlot.saleStart; // sale start
        intData[1] = uint256(lpadSlot.whiteListModel); // whitelist model, 0-no whitelist; 1-whitelist
        intData[2] = lpadSlot.maxSupply; // max supply
        intData[3] = lpadSlot.saleQuantity; // sale quantity
        intData[4] = lpadSlot.maxBuyQtyPerAccount; // maxBuyQtyPerAccount
        intData[5]  = lpadSlot.price; // price
        intData[6] = lpadSlot.boxOpenStart; // boxOpenStart
        intData[7] = lpadSlot.startTokenId; // startTokenId
        intData[8] = lpadSlot.openedNum; // openedNum
        intData[9] = lpadSlot.saleEnd; // saleEnd
        intData[10] = lpadSlot.whiteListSaleStart; // whiteListSaleStart

        addressData = new address[](3);
        addressData[0] = lpadSlot.buyToken; // buyToken
        addressData[1] = lpadSlot.targetContract; // targetContract
        addressData[2] = lpad.zeroExERC20AssetProxy; // Element 0x ERC20AssetProxy

        bytesData = new bytes4[](DataType.ABI_IDX_MAX);
        for (uint256 i=0; i < DataType.ABI_IDX_MAX; i++) {
            bytesData[i] = lpadSlot.abiSelectorAndParam[i]; // bytes4 ABI selectors
        }
    }

    // get account info related to this launchpad
    // quantity - high-128 off-chain sign max whitelist buy; low-128 want to buy;
    function getAccountInfoInLaunchpad(
        DataType.Launchpad memory lpad,
        DataType.AccountSlotStats memory accountStats,
        uint256 slotIdx,
        uint256 quantity,
        address sender,
        bool ownerOrCollaborator
    ) external view returns (
        bool[] memory boolData,
        uint256[] memory intData,
        bytes[] memory byteData
    ) {
        if(lpad.id == 0 || slotIdx >= lpad.slots.length) {
            return(boolData,intData,byteData); // invalid id or idx, return nothing
        }

        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];

        // launchpadId check
        boolData = new bool[](4);
        boolData[0] = lpadSlot.whiteListModel != DataType.WhiteListModel.NONE; // whitelist model or not
        //boolData[1]
        //boolData[2]
        boolData[3] = isWhiteListModel(lpadSlot.whiteListModel, lpadSlot.whiteListSaleStart, lpadSlot.saleStart);

        intData = new uint256[](6);
        intData[0] = accountStats.totalBuyQty; // totalBuyQty
        //intData[1] // left buy quantity
        intData[2] = accountStats.lastBuyTime + lpadSlot.buyInterval; // next buy time of this address

        // this whitelist user max can buy quantity
        intData[3] = (lpadSlot.whiteListModel == DataType.WhiteListModel.OFF_CHAIN_SIGN) ? (quantity >> 128) : uint256(accountStats.whiteListBuyNum);
        quantity = uint256(quantity & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF); // low 128bit is the quantity want to buy

        if (boolData[3]) {
            intData[1] = (intData[3] > accountStats.totalBuyQty) ? (intData[3] - accountStats.totalBuyQty) : 0;
        } else {
            intData[1] = lpadSlot.maxBuyQtyPerAccount - accountStats.totalBuyQty;
        }

        byteData = new bytes[](2);
        if (sender != address(0)) {
            if (quantity > 0) {
                // simulation buy check param
                byteData[0] = bytes(LogicUtil.checkLaunchpadBuy(
                        lpad,
                        accountStats,
                        slotIdx,
                        sender,
                        quantity,
                        intData[3],  // whitelist max can buy
                        byteData[0], // temp reuse
                        DataType.SIMULATION_CHECK)); // simulation check

                // simulation open box check param
                byteData[1] = bytes(LogicUtil.checkLaunchpadOpenBox(
                        lpad,
                        slotIdx,
                        sender,
                        lpadSlot.targetContract,
                        1,
                        1));
            }

            // balance & approve check
            (   boolData[1], // use balance is enough
                boolData[2], // user has approved
                intData[4] // user balance now
            ) = LogicUtil.checkTokenBalanceAndApprove(lpad, slotIdx, sender, quantity);

            // intData[5] user role
            for (uint256 i = 0; i < lpad.feeReceipts.length; i++) {
                if (sender == lpad.feeReceipts[i]) {
                    intData[5] = DataType.ROLE_LAUNCHPAD_FEE_RECEIPTS; // recipient
                    break;
                }
            }

            for(uint256 i = 0; i < lpad.signers.length; i++) {
                if (sender == lpad.signers[i]) {
                    intData[5] = DataType.ROLE_LAUNCHPAD_SIGNER; // whitelist signer
                    break;
                }
            }

            if (sender == lpad.controllerAdmin) {
                intData[5] = DataType.ROLE_LAUNCHPAD_CONTROLLER; // controller
            }

            if (ownerOrCollaborator) {
                intData[5] = DataType.ROLE_PROXY_OWNER; // admin
            }

        } else {
            byteData[0] = bytes(Errors.OK);
            byteData[1] = bytes(Errors.OK);
        }
    }

    function isWhiteListModel(
        DataType.WhiteListModel whiteListModel,
        uint32 whiteListSaleStart,
        uint32 saleStart
    ) internal view returns (bool) {
        if (whiteListModel == DataType.WhiteListModel.NONE) {
            return false;
        }
        if (whiteListSaleStart != 0) { // in whitelist model, and set whiteListSaleStart
            // whitelist buy time has passed
            if (block.timestamp >= saleStart) {
                return false;
            }
        }
        return true;
    }

    // make buy callData，and call buy function of 3rd contract
    function callLaunchpadBuy(
        DataType.Launchpad memory lpad,
        uint256 slotIdx,
        address sender,
        uint256 quantity,
        uint256[] memory additional,
        bytes memory data
    ) public {
        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];
        uint256 tokenId = lpadSlot.startTokenId + lpadSlot.saleQuantity;
        bytes4 selector = lpadSlot.abiSelectorAndParam[DataType.ABI_IDX_BUY_SELECTOR]; // bytes4(keccak256("safeMint(address,uint256)")),
        bytes4 paramTable = lpadSlot.abiSelectorAndParam[DataType.ABI_IDX_BUY_PARAM_TABLE];

        // encode abi data
        // 0x00000000 - (address sender, uint256 tokenId), this is default
        // 0x00000001 - (address sender)
        // 0x00000002 - (address sender, uint256 tokenId, uint256 quantity)
        // 0x00000003 - (address sender, uint256 tokenId, uint256 quantity, address referral)
        // 0x00000004 - (address sender, uint256 quantity)
        // 0x00000005 - (address sender, uint256 quantity，uint256[] memory additional, bytes memory data)
        bytes memory proxyCallData;
        if (paramTable == bytes4(0x00000000)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenId); // paramTable 0x00000000
        } else if (paramTable == bytes4(0x00000001)) {
            proxyCallData = abi.encodeWithSelector(selector, sender);
        } else if (paramTable == bytes4(0x00000002)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenId, quantity);
        } else if (paramTable == bytes4(0x00000003)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenId, quantity, address(uint160(additional[DataType.BUY_ADDITIONAL_IDX_REFERRAL])));
        } else if (paramTable == bytes4(0x00000004)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, quantity);
        } else if (paramTable == bytes4(0x00000005)) {
            proxyCallData = abi.encodeWithSelector(selector, slotIdx, sender, quantity, additional, data);
        }
        require(proxyCallData.length > 0, Errors.LPAD_SLOT_ABI_NOT_FOUND);

        (bool didSucceed, bytes memory returnData) = lpadSlot.targetContract.call(proxyCallData);
        if(!didSucceed) {
            // check result must success, or revert !!!
            revert(string(abi.encodePacked(Errors.LPAD_SLOT_CALL_BUY_CONTRACT_FAILED, Errors.LPAD_SEPARATOR, returnData)));
        }
    }

    // make openbox call data, and call openbox of 3rd contract
    function callLaunchpadOpenBox(
        DataType.Launchpad memory lpad,
        address sender,
        uint256 slotIdx,
        address tokenAddr,
        uint256 tokenId,
        uint256 quantity,
        uint256[] memory additional
    ) public {

        bytes4 selector = lpad.slots[slotIdx].abiSelectorAndParam[DataType.ABI_IDX_OPENBOX_SELECTOR]; // bytes4(keccak256("open(uint256)")),
        bytes4 paramTable = lpad.slots[slotIdx].abiSelectorAndParam[DataType.ABI_IDX_OPENBOX_PARAM_TABLE];

        // encode abi data
        // 0x00000000 - (uint256 tokenId),  default: for example: bytes4(keccak256("open(uint256)")
        // 0x00000001 - (address sender, uint256 tokenId, uint256 quantity)
        // 0x00000002 - (address sender, address tokenAddr, uint256 tokenId, uint256 quantity)
        // 0x00000003 - (address tokenAddr, uint256 tokenId)
        // 0x00000004 - (address sender, uint256 tokenId)
        bytes memory proxyCallData;
        if (paramTable == bytes4(0x00000000)) {
            proxyCallData = abi.encodeWithSelector(selector, tokenId); // paramTable 0x00000000
        } else if (paramTable == bytes4(0x00000001)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenId, quantity);
        } else if (paramTable == bytes4(0x00000002)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenAddr, tokenId, quantity);
        } else if (paramTable == bytes4(0x00000003)) {
            proxyCallData = abi.encodeWithSelector(selector, tokenAddr, tokenId);
        } else if (paramTable == bytes4(0x00000004)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenId);
        } else if (paramTable == bytes4(0x00000005)) {
            proxyCallData = abi.encodeWithSelector(selector, sender, tokenAddr, tokenId, quantity, additional);
        }
        require(proxyCallData.length > 0, Errors.LPAD_SLOT_ABI_NOT_FOUND);

        // call external contract function
        (bool didSucceed, bytes memory returnData) = lpad.slots[slotIdx].targetContract.call(proxyCallData);
        if(!didSucceed) {
            // if fail, revert !!!
            // example:  56: not authored caller
            revert(string(abi.encodePacked(Errors.LPAD_SLOT_CALL_OPEN_CONTRACT_FAILED, Errors.LPAD_SEPARATOR, returnData)));
        }
    }

    function callLaunchpadDoOperation(
        DataType.Launchpad memory lpad,
        address sender,
        uint256 slotIdx,
        address[] memory addrData,
        uint256[] memory intData,
        bytes[] memory byteData
    ) public {
        bytes4 selector = lpad.slots[slotIdx].abiSelectorAndParam[DataType.ABI_IDX_OPENBOX_SELECTOR]; // bytes4(keccak256("open(uint256)")),
        bytes memory  proxyCallData = abi.encodeWithSelector(selector, sender, slotIdx, addrData, intData, byteData);
        // call external contract function
        (bool didSucceed, bytes memory returnData) = lpad.slots[slotIdx].targetContract.call(proxyCallData);
        if(!didSucceed) {
            // if fail, revert !!!
            revert(string(abi.encodePacked(Errors.LPAD_SLOT_CALL_OPEN_CONTRACT_FAILED, Errors.LPAD_SEPARATOR, returnData)));
        }
    }

    // transfer fees and incomes
    function transferFees(
        DataType.Launchpad memory lpad,
        address sender,
        address buyToken,
        uint256 shouldPay,
        uint256[] memory additional
    ) public {

        if ( shouldPay == 0 ) {
            return;
        }

        uint256 incomeToReceipt = shouldPay;

        // transfer ERC20 from sender to this contract; !!! adapt DappRadar's Stats
        if (buyToken != address(0)) {
            (bool transferSuccess,  bytes memory returnData) = transferERC20FromZeroExProxy(lpad.zeroExERC20AssetProxy,
                buyToken, sender, address(this), shouldPay);

            require(transferSuccess, string(abi.encodePacked(Errors.LPAD_TRANSFER_TO_LPAD_PROXY_FAIL, Errors.LPAD_SEPARATOR, returnData)));
        }

        // send referral fee
        if (lpad.referralFeePct > 0) {
            address referral = address(uint160(additional[DataType.BUY_ADDITIONAL_IDX_REFERRAL]));
            if (referral != address(0)) {
                uint256 referralFee = shouldPay * lpad.referralFeePct / DataType.MAX_PERCENT;
                if (buyToken == address(0)) { //ETH
                    payable(referral).transfer(referralFee);
                } else { // ERC20
                    IERC20(buyToken).transfer(referral, referralFee);
                }
                incomeToReceipt -= referralFee; // left is the receiptFee
            }
        }

        // send left income to receipt
        for(uint256 i=0; i<lpad.fees.length; i++) {
            uint256 incomeFeeToTransfer = incomeToReceipt * lpad.fees[i] / DataType.MAX_PERCENT;
            if (buyToken == address(0)) { //ETH
                payable(lpad.feeReceipts[i]).transfer(incomeFeeToTransfer);
            } else { // ERC20
                IERC20(buyToken).transfer(lpad.feeReceipts[i], incomeFeeToTransfer);
            }
        }
    }

    // transfer erc20 from zero ex erc20 asset proxy
    function transferERC20FromZeroExProxy(
        address zeroExERC20Proxy,
        address erc20Token,
        address from,
        address to,
        uint256 amount
    ) public returns (bool, bytes memory) {
        // Construct the calldata for the transferFrom call.
        // Call the asset proxy's transferFrom function with the constructed calldata.
        if (zeroExERC20Proxy == address(this) ) {
            return (IERC20(erc20Token).transferFrom(from, to, amount), bytes(Errors.LPAD_SLOT_ERC20_TRANSFER_FAILED));
        } else {
            if (!isValidERC20AssetProxy(zeroExERC20Proxy)) {
                return (false, bytes(Errors.LPAD_SLOT_0X_ERC20_PROXY_INVALID));
            }
            return zeroExERC20Proxy.call(
                abi.encodeWithSelector(
                    IAssetProxy(address(0)).transferFrom.selector,
                    abi.encodePacked(zeroExERC20ProxyId, uint256(uint160(erc20Token))),
                    from,
                    to,
                    amount
                )
            );
        }
    }

    function isValidERC20AssetProxy(address erc20Proxy) public view returns (bool) {
        return IAssetProxy(address(erc20Proxy)).getProxyId() == zeroExERC20ProxyId;
    }

    function checkAddLaunchpadSlot(DataType.LaunchpadSlot memory slot) external pure {
        return LogicUtil.checkAddLaunchpadSlot(slot);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Errors.sol";
import "./DataType.sol";
import "../interface/IAssetProxy.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library LogicUtil {
    using ECDSA for bytes32;

    // check param before buy
    function checkLaunchpadBuy(
        DataType.Launchpad memory lpad,
        DataType.AccountSlotStats memory accStats,
        uint256 slotIdx,
        address sender,
        uint256 quantity,
        uint256 wlMaxBuyQuantity,
        bytes memory data,
        uint256 simulateBuy
    ) public view returns (string memory) {

        // launchpadId check
        if(lpad.id == 0) return Errors.LPAD_INVALID_ID;

        // check launchpad enable
        if(!lpad.enable) return Errors.LPAD_NOT_ENABLE;

        // slotIdx check
        if(slotIdx >= lpad.slots.length) return Errors.LPAD_SLOT_IDX_INVALID;

        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];

        // target address check
        if(lpadSlot.targetContract == address(0)) return Errors.LPAD_SLOT_TARGET_CONTRACT_INVALID;

        // launchpad active check
        if(!lpadSlot.flags[DataType.LAUNCHPAD_BUY_FLAG]) return Errors.LPAD_SLOT_BUY_DISABLE;

        // check support call from contract
        if (isContract(sender) && !lpadSlot.flags[DataType.LAUNCHPAD_CALL_BUY_FROM_CONTRACT_FLAG]) return Errors.LPAD_SLOT_BUY_FROM_CONTRACT_NOT_ALLOWED;

        // left supply check
        if( (quantity + lpadSlot.saleQuantity) > lpadSlot.maxSupply) return Errors.LPAD_SLOT_QTY_NOT_ENOUGH_TO_BUY;

        uint256 paymentNeeded = quantity * lpadSlot.price;

        if (simulateBuy != DataType.SIMULATION_CHECK_SKIP_BALANCE_PROCESS_REVERT) {
            // check buy token
            if (lpadSlot.buyToken != address(0)) {  // ERC20
                // balance check
                if(paymentNeeded > IERC20(lpadSlot.buyToken).balanceOf(sender)) return Errors.LPAD_SLOT_ERC20_BLC_NOT_ENOUGH;

                // not simulate, really call buy ..
                if (simulateBuy == DataType.SIMULATION_NONE) {
                    // allowance check for Element ERC20AssetProxy
                    if(paymentNeeded > IERC20(lpadSlot.buyToken).allowance(sender, lpad.zeroExERC20AssetProxy))
                        return Errors.LPAD_SLOT_PAYMENT_ALLOWANCE_NOT_ENOUGH;

                    // pay value not need
                    if(msg.value > 0) return Errors.LPAD_SLOT_PAY_VALUE_NOT_NEED;
                }
            } else {

                // balance check
                if(paymentNeeded > (sender.balance + msg.value)) return Errors.LPAD_SLOT_PAYMENT_NOT_ENOUGH;

                // not simulate, really call buy ..
                if (simulateBuy == DataType.SIMULATION_NONE) {
                    // ETH msg.value send check
                    if(paymentNeeded > msg.value) return Errors.LPAD_SLOT_PAY_VALUE_NOT_ENOUGH;
                    // ETH msg.value upper need
                    if(msg.value > paymentNeeded) return Errors.LPAD_SLOT_PAY_VALUE_UPPER_NEED;
                }
            }
        }

        // max buy number in one transcation limit
        if (quantity > lpadSlot.maxBuyNumOnce) return Errors.LPAD_SLOT_MAX_BUY_QTY_PER_TX_LIMIT;

        // one account max buy num check
        if ((quantity + accStats.totalBuyQty) > lpadSlot.maxBuyQtyPerAccount) return Errors.LPAD_SLOT_ACCOUNT_MAX_BUY_LIMIT;

        // account buy time cool down check
        if (block.timestamp - accStats.lastBuyTime < lpadSlot.buyInterval) return Errors.LPAD_SLOT_ACCOUNT_BUY_INTERVAL_LIMIT;

        // endTime check
        if (lpadSlot.saleEnd > 0 && block.timestamp > lpadSlot.saleEnd) return Errors.LPAD_SLOT_SALE_END;

        // whitelist check
        if (lpadSlot.whiteListModel != DataType.WhiteListModel.NONE) {
            return checkWhitelistBuy(
                lpad,
                slotIdx,
                sender,
                quantity,
                accStats.totalBuyQty,
                wlMaxBuyQuantity,
                data,
                simulateBuy);
        } else {
            if (simulateBuy != DataType.SIMULATION_CHECK_SKIP_START_PROCESS_REVERT) {
                // public sale time check
                if (block.timestamp < lpadSlot.saleStart) return Errors.LPAD_SLOT_SALE_NOT_START;
            }
        }

        // buy ok
        return Errors.OK;
    }


    // whitelist check
    //                     [whitelist sale]                  [public sale]
    //  | whiteListSaleStart ---------- saleStart | saleStart ---------- saleEnd |
    function checkWhitelistBuy(
        DataType.Launchpad memory lpad,
        uint256 slotIdx,
        address sender,
        uint256 quantity,
        uint256 alreadyBuy,
        uint256 maxWhitelistBuy,
        bytes memory data,
        uint256 simulateBuy
    ) public view returns (string memory) {
        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];

        if (simulateBuy == DataType.SIMULATION_CHECK_SKIP_WHITELIST_PROCESS_REVERT) {
            return Errors.OK;
        }

        if (lpadSlot.whiteListSaleStart != 0) { // in whitelist model, and set whiteListSaleStart
            // whitelist buy time has passed
            if (lpadSlot.saleStart < block.timestamp) {
                return Errors.OK;
            }

            if (simulateBuy != DataType.SIMULATION_CHECK_SKIP_START_PROCESS_REVERT) {
                // not the white list buy time
                if (block.timestamp < lpadSlot.whiteListSaleStart) return Errors.LPAD_SLOT_WHITELIST_SALE_NOT_START;
            }
        } else { // not set whiteListSaleStart, so saleStart is the sale time
            if (simulateBuy != DataType.SIMULATION_CHECK_SKIP_START_PROCESS_REVERT) {
                // sale time check
                if (block.timestamp < lpadSlot.saleStart) return Errors.LPAD_SLOT_WHITELIST_SALE_NOT_START;
            }
        }

        // off chain sign model, check the signature and max buy num
        if (simulateBuy == DataType.SIMULATION_NONE && lpadSlot.whiteListModel == DataType.WhiteListModel.OFF_CHAIN_SIGN) {
            require(data.length > 0, Errors.LPAD_SLOT_ACCOUNT_NOT_IN_WHITELIST);
            require(data.length == 65, Errors.LPAD_INVALID_WHITELIST_SIGNATURE_LEN);
            maxWhitelistBuy = offChainSignCheck(lpad, sender, slotIdx, maxWhitelistBuy, data);
        }

        // not in whitelist
        if (maxWhitelistBuy == 0) return Errors.LPAD_SLOT_ACCOUNT_NOT_IN_WHITELIST;

        // upper whitelist buy number， this
        if ((quantity + alreadyBuy) > maxWhitelistBuy) return Errors.LPAD_SLOT_WHITELIST_BUY_NUM_LIMIT;

        return Errors.OK;
    }

    // check before openbox
    function checkLaunchpadOpenBox(
        DataType.Launchpad memory lpad,
        uint256 slotIdx,
        address sender,
        address tokenAddr,
        uint256 tokenId,
        uint256 quantity
    )  public view returns (string memory) {

        // launchpadId check
        if(lpad.id == 0) return Errors.LPAD_INVALID_ID;

        // check launchpad enable
        if(!lpad.enable) return Errors.LPAD_NOT_ENABLE;

        // slotIdx check
        if(slotIdx >= lpad.slots.length) return Errors.LPAD_SLOT_IDX_INVALID;

        DataType.LaunchpadSlot memory lpadSlot = lpad.slots[slotIdx];

        // not support openbox
        if(lpadSlot.boxOpenStart == type(uint256).max) return Errors.LPAD_SLOT_OPENBOX_NOT_SUPPORT;

        // launchpad flag check
        if(!lpadSlot.flags[DataType.LAUNCHPAD_OPENBOX_FLAG]) return Errors.LPAD_SLOT_OPENBOX_DISABLE;

        // check support open before sold out check
        if(lpadSlot.flags[DataType.LAUNCHPAD_OPENBOX_WHEN_SOLD_OUT] && lpadSlot.maxSupply > lpadSlot.saleQuantity) return Errors.LPAD_SLOT_ONLY_OPENBOX_WHEN_SOLD_OUT;

        // openbox time check
        if(block.timestamp < lpadSlot.boxOpenStart) return Errors.LPAD_SLOT_OPENBOX_TIME_INVALID;

        // check support call from contract
        if (isContract(sender) && !lpadSlot.flags[DataType.LAUNCHPAD_CALL_OPENBOX_FROM_CONTRACT_FLAG]) return Errors.LPAD_SLOT_OPENBOX_FROM_CONTRACT_NOT_ALLOWED;

        // tokenAddr, tokenId, quantity not check

        // open check ok
        return Errors.OK;
    }

    function checkAddLaunchpadSlot(DataType.LaunchpadSlot memory slot) external pure {
        // only do import check, param can reset from setXXX()
        require(slot.maxSupply > 0, Errors.LPAD_SLOT_MAX_SUPPLY_INVALID);

        // default must 0, only increase by sale
        require(slot.saleQuantity == 0, Errors.LPAD_SLOT_SALE_QUANTITY);

        // default must 0
        require(slot.openedNum == 0, Errors.LPAD_SLOT_OPEN_NUM_INIT);

        // must valid address
        require(isValidAddress(slot.targetContract), Errors.LPAD_SLOT_TARGET_CONTRACT_INVALID);

        // ABI length check
        require(slot.abiSelectorAndParam.length == DataType.ABI_IDX_MAX, Errors.LPAD_SLOT_ABI_ARRAY_LEN);
        // buy selector check, not all project has a open selector
        require(slot.abiSelectorAndParam[DataType.ABI_IDX_BUY_SELECTOR] != bytes4(0), Errors.LPAD_SLOT_ABI_BUY_SELECTOR_INVALID);

        // max buy quantity check
        require((slot.maxBuyQtyPerAccount > 0) && (slot.maxBuyQtyPerAccount <= slot.maxSupply), Errors.LPAD_SLOT_MAX_BUY_QTY_INVALID);

        // sale time must > 0, can modify in sexXXX later
        require(slot.saleStart > 0, Errors.LPAD_SLOT_SALE_START_TIME_INVALID);

        // sale end time must 0 or > startTime
        require(slot.saleEnd == 0 || slot.saleEnd > slot.saleStart, Errors.LPAD_SLOT_SALE_END_TIME_INVALID);

        // default price must > 0, can modify by setSlotBuyTokenAndPrice later
        require(slot.price > 0, Errors.LPAD_SLOT_PRICE_INVALID);

        // abi check, can modify by setSlotStartTimeAndFlags later
        require(slot.flags.length == DataType.LAUNCHPAD_FLAG_MAX, Errors.LPAD_SLOT_FLAGS_ARRAY_LEN);
        require(!slot.flags[DataType.LAUNCHPAD_CALL_BUY_FROM_CONTRACT_FLAG], Errors.LPAD_SLOT_BUY_FROM_CONTRACT_NOT_ALLOWED);
        require(!slot.flags[DataType.LAUNCHPAD_CALL_OPENBOX_FROM_CONTRACT_FLAG], Errors.LPAD_SLOT_OPENBOX_FROM_CONTRACT_NOT_ALLOWED);
    }


    // check balance and approve
    function checkTokenBalanceAndApprove(
        DataType.Launchpad memory lpad,
        uint256 slotIdx,
        address sender,
        uint256 quantity
    )  public view returns (
        bool balanceEnough,
        bool allowanceEnough,
        uint256 balance
    ) {
        uint256 paymentNeeded = quantity * lpad.slots[slotIdx].price;
        if (lpad.slots[slotIdx].buyToken != address(0)) { //ERC20 balance
            balance = IERC20(lpad.slots[slotIdx].buyToken).balanceOf(sender);
            balanceEnough = balance >= paymentNeeded;
            allowanceEnough = IERC20(lpad.slots[slotIdx].buyToken).allowance(sender, lpad.zeroExERC20AssetProxy) >= paymentNeeded;
        } else { // ETH Balance
            balance = sender.balance;
            balanceEnough = sender.balance > paymentNeeded;
            allowanceEnough = true;
        }
    }

    // is contract address
    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function isValidAddress(address addr) public pure returns (bool) {
        return address(addr) == addr && address(addr) != address(0);
    }

    // hash for whitelist
    function hashForWhitelist(
        address account,
        bytes4 launchpadId,
        uint256 slot,
        uint256 maxBuy
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(account, address(this), launchpadId, slot, maxBuy));
    }

    // off-chain sign check
    function offChainSignCheck(
        DataType.Launchpad memory lpad,
        address account,
        uint256 slotIdx,
        uint256 maxBuyNum,
        bytes memory signature
    ) public view returns (uint256) {
        bytes32 ecHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hashForWhitelist(account, lpad.id, slotIdx, maxBuyNum))
        );
        for (uint256 i = 0; i < lpad.signers.length; i++) {
            if (lpad.signers[i] == ecHash.recover(signature)) {
                return maxBuyNum;
            }
        }
        return 0;
    }

}

// SPDX-License-Identifier: MIT
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.8.4;


interface IAssetProxy {

    /// @dev Transfers assets. Either succeeds or throws.
    /// @param assetData Byte array encoded for the respective asset proxy.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    )
    external;

    /// @dev Gets the proxy id associated with the proxy address.
    /// @return Proxy id.
    function getProxyId()
    external
    pure
    returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
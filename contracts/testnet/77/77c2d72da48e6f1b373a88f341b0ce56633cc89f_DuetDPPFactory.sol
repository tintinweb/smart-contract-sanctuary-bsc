/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File contracts/lib/InitializableOwnable.sol



/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}


// File contracts/lib/CloneFactory.sol



interface ICloneFactory {
    function clone(address prototype) external returns (address proxy);
}

// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}


// File contracts/intf/IDPPOracle.sol



interface IDPPOracle {
    function init(
        address owner,
        address maintainer,
        address baseTokenAddress,
        address quoteTokenAddress,
        uint256 lpFeeRate,
        address mtFeeRateModel,
        uint256 k,
        uint256 i,
        address o,
        bool isOpenTWAP,
        bool isOracleEnabled
    ) external;

    function _MT_FEE_RATE_MODEL_() external returns (address);
}


// File contracts/intf/IDPPController.sol



interface IDPPController {
    function init(
        address admin,
        address dppAddress,
        address dppAdminAddress,
        address weth
    ) external;
}


// File contracts/intf/IDPPOracleAdmin.sol




interface IDPPOracleAdmin {
    function init(
        address owner,
        address dpp,
        address operator,
        address dodoApproveProxy
    ) external;


    //=========== admin ==========
    function ratioSync() external;

    function retrieve(
        address payable to,
        address token,
        uint256 amount
    ) external;

    function reset(
        address assetTo,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);


    function tuneParameters(
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function tunePrice(
        uint256 newI,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function changeOracle(address newOracle) external;

    function enableOracle() external;

    function disableOracle(uint256 newI) external;
}


// File contracts/factory/DuetDppFactory.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;





contract DuetDPPFactory is InitializableOwnable {
    // ============ default ============

    address public immutable cloneFactory;
    address public immutable weth;
    address public dodoDefautMtFeeRateModel;
    address public dodoApproveProxy;
    address public dodoDefaultMaintainer;

    // ============ Templates ============

    address public dppTemplate;
    address public dppAdminTemplate;
    address public dppControllerTemplate;

    // ============registry and adminlist ==========

    mapping (address => bool) public isAdminListed;
    // base->quote->dppController
    mapping(address => mapping(address => address)) public registry;
    // registry dppController
    mapping(address => address) public userRegistry;

    // ============ Events ============

    event NewDPP(
        address baseToken,
        address quoteToken,
        address creator,
        address dpp,
        address dppController
    );

    event addAdmin(address admin);
    event removeAdmin(address admin);

    constructor(
        address owner_,
        address cloneFactory_,
        address dppTemplate_,
        address dppAdminTemplate_,
        address dppControllerTemplate_,
        address defaultMaintainer_,
        address defaultMtFeeRateModel_,
        address dodoApproveProxy_,
        address weth_
    ) public {
        initOwner(owner_);
        weth = weth_;

        cloneFactory = cloneFactory_;
        dppTemplate = dppTemplate_;
        dppAdminTemplate = dppAdminTemplate_;
        dppControllerTemplate = dppControllerTemplate_;

        dodoDefaultMaintainer = defaultMaintainer_;
        dodoDefautMtFeeRateModel = defaultMtFeeRateModel_;
        dodoApproveProxy = dodoApproveProxy_;
    }

    // ============ Admin Operation Functions ============

    function updateDefaultMaintainer(address newMaintainer_) external onlyOwner {
        dodoDefaultMaintainer = newMaintainer_;
    }

    function updateDefaultFeeModel(address newFeeModel_) external onlyOwner {
        dodoDefautMtFeeRateModel = newFeeModel_;
    }

    function updateDodoApprove(address newDodoApprove_) external onlyOwner {
        dodoApproveProxy = newDodoApprove_;
    }

    function updateDppTemplate(address newDPPTemplate_) external onlyOwner {
       dppTemplate = newDPPTemplate_;
    }

    function updateAdminTemplate(address newDPPAdminTemplate_) external onlyOwner {
        dppAdminTemplate = newDPPAdminTemplate_;
    }

    function updateControllerTemplate(address newController_) external onlyOwner {
        dppControllerTemplate = newController_;
    }

    function addAdminList (address contractAddr_) external onlyOwner {
        isAdminListed[contractAddr_] = true;
        emit addAdmin(contractAddr_);
    }

    function removeAdminList (address contractAddr_) external onlyOwner {
        isAdminListed[contractAddr_] = false;
        emit removeAdmin(contractAddr_);
    }

    // ============ Functions ============

    function createDODOPrivatePool() public returns (address newPrivatePool) {
        newPrivatePool = ICloneFactory(cloneFactory).clone(dppTemplate);
    }

    function createDPPAdminModel() public returns (address newDppAdminModel) {
        newDppAdminModel = ICloneFactory(cloneFactory).clone(dppAdminTemplate);
    }

    function createDPPController(
        address creator_, // dpp controller's admin and dppAdmin's operator
        address baseToken_,
        address quoteToken_,
        uint256 lpFeeRate_, // 单位是10**18，范围是[0,10**18] ，代表的是交易手续费
        uint256 k_, // adjust curve's type
        uint256 i_, // 代表的是base 对 quote的价格比例.decimals 18 - baseTokenDecimals+ quoteTokenDecimals. If use oracle, i set here wouldn't be used. 
        address o_, // oracle address
        bool isOpenTwap_, // use twap price or not
        bool isOracleEnabled_ // use oracle or not
    ) external {
        require(isAdminListed[msg.sender], "ACCESS_DENIED");
        require(registry[baseToken_][quoteToken_] == address(0), "HAVE CREATED");
        address dppAddress;
        address dppController;
        {
            dppAddress = createDODOPrivatePool();
            address dppAdminModel = createDPPAdminModel();
            dppController = _createDPPController(
                creator_,
                dppAddress,
                dppAdminModel
            );

            IDPPOracleAdmin(dppAdminModel).init(dppController, dppAddress, creator_, dodoApproveProxy);

            IDPPOracle(dppAddress).init(
                dppAdminModel,
                dodoDefaultMaintainer,
                baseToken_,
                quoteToken_,
                lpFeeRate_,
                dodoDefautMtFeeRateModel,
                k_,
                i_,
                o_,
                isOpenTwap_,
                isOracleEnabled_
            );
        }

        registry[baseToken_][quoteToken_] = dppController;
        userRegistry[creator_] = dppController;
        emit NewDPP(baseToken_, quoteToken_, creator_, dppAddress, dppController);
    }

    function _createDPPController(
        address admin_,
        address dppAddress_,
        address dppAdminAddress_
    ) internal returns(address dppController) {
        dppController = ICloneFactory(cloneFactory).clone(dppControllerTemplate);
        IDPPController(dppController).init(admin_, dppAddress_, dppAdminAddress_, weth);
    }

}
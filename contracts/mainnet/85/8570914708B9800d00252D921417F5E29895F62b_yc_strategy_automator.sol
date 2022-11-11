// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/*
 * Importing required Chainlink automation interfaces
 **/
import {AutomationRegistryInterface, State, Config} from "../chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "../chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

/*
 * @dev a generic interface for Chainlink automation registry
 */
interface KeeperRegistrarInterface {
    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}

contract yc_strategy_automator {
    // Linktoken interface type variable
    LinkTokenInterface public immutable i_link;

    // Address of the CL Registrar (Constructed)
    address public immutable registrar;

    // AutomationRegistryInterface type variable
    AutomationRegistryInterface public immutable i_registry;

    // Generic registrartion signature
    bytes4 registerSig = KeeperRegistrarInterface.register.selector;

    // Address of the current chain's Chainlink registry
    address public immutable registryAddress;

    /*
     * @dev Mappings to keep track of Upkeep IDs, strategy addresses, and latest call data
     **/
    mapping(uint256 => address) public upkeepIdToAddress;
    mapping(address => uint256) public strategyAddressToUpkeepId;
    mapping(uint256 => bytes) public upkeepidToLatestData;

    /*
     * @notice
     * @dev
     * In the consturctor, you need to input a Linktokeinterface type variable, an address for Chainlink registrar,
     * An automationRegistryinterface type, and an address for the CL registry on the current chain.
     * this sets up the contract, the contract is responsible for registering, keeping track of & funding
     * Yieldchain strategies, to automate them and allow easy gas funding by platform users
     **/
    constructor(
        LinkTokenInterface _link,
        address _registrar,
        AutomationRegistryInterface _registry,
        address _registryAddress
    ) {
        i_link = _link;
        registrar = _registrar;
        i_registry = _registry;
        registryAddress = _registryAddress;
    }

    /*
     * @dev
     * @notice
     * Main function for registering an Upkeep, only Yieldchain strategy contracts are supposed to call it, it
     * takes in 2 arguements:
     * 1) Name - The name of the Upkeep (The strategy's configured name, does not make a difference)
     * 2) The amount - An amount of chainlink ERC-677 tokens to initially fund the Upkeep with, must be above 5 LINK
     * It registers an Upkeep on the calling contract, the caller contract must be Chainlink Automation-compatible
     * And have the required checkUpkeep() & performUpkeep() functions implemented
     **/
    function registerAndPredictID(string memory name, uint96 amount) public {
        (State memory state, Config memory _c, address[] memory _k) = i_registry
            .getState();
        uint256 oldNonce = state.nonce;
        require(
            amount > 5000000000000000000,
            "Not enough LINK tokens funded, min 5 LINK (ERC-677)"
        );
        bytes memory payload = abi.encode(
            name,
            "[email protected]",
            msg.sender,
            999999999,
            msg.sender,
            "0x",
            amount,
            0,
            address(this)
        );

        i_link.transferAndCall(
            registrar,
            amount,
            bytes.concat(registerSig, payload)
        );
        (state, _c, _k) = i_registry.getState();
        uint256 newNonce = state.nonce;
        if (newNonce == oldNonce + 1) {
            uint256 upkeepID = uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        address(i_registry),
                        uint32(oldNonce)
                    )
                )
            );

            /*
             * @dev
             * String details about the caller & the Upkeep ID in mappings after registration
             **/
            strategyAddressToUpkeepId[msg.sender] = upkeepID;
            upkeepIdToAddress[upkeepID] = msg.sender;
            address strategyContract = msg.sender;
            (bool success, bytes memory result) = strategyContract.call(
                abi.encodeWithSignature("setUpkeepId(uint)", upkeepID)
            );
            upkeepidToLatestData[upkeepID] = result;
            require(success, "Call failed on %s");
        } else {
            revert("auto-approve disabled");
        }
    }

    /*
     * @dev
     * This function allows users to fund the LINK gas balance of any strategy contract, the last function have set
     * The UpKeepID on the StrategyContract, so users only need to input an amount when funding.
     **/
    function fundStrategyGasBalance(
        uint256 _upkeepId,
        uint256 _amountLinkTokens
    ) public {
        (bool success, bytes memory result) = registryAddress.call(
            abi.encodeWithSignature(
                "addFunds(uint256, uint96)",
                _upkeepId,
                _amountLinkTokens
            )
        );
        require(success, "Funding gas balance failed");
        upkeepidToLatestData[_upkeepId] = result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice config of the registry
 * @dev only used in params and return values
 * @member paymentPremiumPPB payment premium rate oracles receive on top of
 * being reimbursed for gas, measured in parts per billion
 * @member flatFeeMicroLink flat fee paid to oracles for performing upkeeps,
 * priced in MicroLink; can be used in conjunction with or independently of
 * paymentPremiumPPB
 * @member blockCountPerTurn number of blocks each oracle has during their turn to
 * perform upkeep before it will be the next keeper's turn to submit
 * @member checkGasLimit gas limit when checking for upkeep
 * @member stalenessSeconds number of seconds that is allowed for feed data to
 * be stale before switching to the fallback pricing
 * @member gasCeilingMultiplier multiplier to apply to the fast gas feed price
 * when calculating the payment ceiling for keepers
 * @member minUpkeepSpend minimum LINK that an upkeep must spend before cancelling
 * @member maxPerformGas max executeGas allowed for an upkeep on this registry
 * @member fallbackGasPrice gas price used if the gas price feed is stale
 * @member fallbackLinkPrice LINK price used if the LINK price feed is stale
 * @member transcoder address of the transcoder contract
 * @member registrar address of the registrar contract
 */
struct Config {
  uint32 paymentPremiumPPB;
  uint32 flatFeeMicroLink; // min 0.000001 LINK, max 4294 LINK
  uint24 blockCountPerTurn;
  uint32 checkGasLimit;
  uint24 stalenessSeconds;
  uint16 gasCeilingMultiplier;
  uint96 minUpkeepSpend;
  uint32 maxPerformGas;
  uint256 fallbackGasPrice;
  uint256 fallbackLinkPrice;
  address transcoder;
  address registrar;
}

/**
 * @notice state of the registry
 * @dev only used in params and return values
 * @member nonce used for ID generation
 * @member ownerLinkBalance withdrawable balance of LINK by contract owner
 * @member expectedLinkBalance the expected balance of LINK of the registry
 * @member numUpkeeps total number of upkeeps on the registry
 */
struct State {
  uint32 nonce;
  uint96 ownerLinkBalance;
  uint256 expectedLinkBalance;
  uint256 numUpkeeps;
}

interface AutomationRegistryBaseInterface {
  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (uint256 id);

  function performUpkeep(uint256 id, bytes calldata performData) external returns (bool success);

  function cancelUpkeep(uint256 id) external;

  function addFunds(uint256 id, uint96 amount) external;

  function setUpkeepGasLimit(uint256 id, uint32 gasLimit) external;

  function getUpkeep(uint256 id)
    external
    view
    returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber,
      uint96 amountSpent
    );

  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);

  function getKeeperInfo(address query)
    external
    view
    returns (
      address payee,
      bool active,
      uint96 balance
    );

  function getState()
    external
    view
    returns (
      State memory,
      Config memory,
      address[] memory
    );
}

/**
 * @dev The view methods are not actually marked as view in the implementation
 * but we want them to be easily queried off-chain. Solidity will not compile
 * if we actually inherit from this interface, so we document it here.
 */
interface AutomationRegistryInterface is AutomationRegistryBaseInterface {
  function checkUpkeep(uint256 upkeepId, address from)
    external
    view
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    );
}

interface AutomationRegistryExecutableInterface is AutomationRegistryBaseInterface {
  function checkUpkeep(uint256 upkeepId, address from)
    external
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      uint256 adjustedGasWei,
      uint256 linkEth
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}
/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// File: @chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol


pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: contracts/ClaimOnBehalf.sol


pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol


interface IReadProxyAddressResolver {
    function target() external view returns (address);
}

interface IAddressResolver {
    function requireAndGetAddress(bytes32 name, string calldata reason)
        external
        view
        returns (address);
}

interface IFeePool {
    // Views

    function isFeesClaimable(address account) external view returns (bool);

    function claimOnBehalf(address claimingForAddress) external returns (bool);

    function feesAvailable(address account) external view returns (uint, uint);
}

contract HorizonClaimOnBehalf is KeeperCompatibleInterface {
    bytes32 internal constant CONTRACT_FEEPOOL = "FeePool";
    IReadProxyAddressResolver public readProxyAddressResolver;

    constructor(address _readProxyAddressResolver) {
        readProxyAddressResolver = IReadProxyAddressResolver(
            _readProxyAddressResolver
        );
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;

        address claimer = convert_address(checkData);

        bool claimable = feePool().isFeesClaimable(claimer);
        (uint fees, uint rewards) = feePool().feesAvailable(claimer);

        if ((fees > 0 || rewards > 0) && claimable) {
            upkeepNeeded = true;
            performData = checkData;
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        address claimer = convert_address(performData);

        bool claimable = feePool().isFeesClaimable(claimer);
        (uint256 fees, uint256 rewards) = feePool().feesAvailable(claimer);


        if ((fees > 0 || rewards > 0) && claimable) {
            feePool().claimOnBehalf(claimer);
        }
    }

    function addressResolver() public view returns (IAddressResolver) {
        return IAddressResolver(readProxyAddressResolver.target());
    }

    function feePool() public view returns (IFeePool) {
        return
            IFeePool(
                addressResolver().requireAndGetAddress(
                    CONTRACT_FEEPOOL,
                    "Missing FeePool contract"
                )
            );
    }

    function convert_address(bytes memory bys) public pure returns (address addr) {
        // Method 1
        assembly {
            addr := mload(add(bys, 20))
        }

        // Method 2
        // addr = address(bytes20(bys));
    }
}
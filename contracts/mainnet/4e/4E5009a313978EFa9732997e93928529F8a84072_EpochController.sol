// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./chainlink/AutomationCompatible.sol";
import "./interfaces/IMinter.sol";
import "./interfaces/IVoter.sol";


contract EpochController is AutomationCompatibleInterface  {

    address public automationRegistry;
    address public owner;

    address public condition;
    address public target;

    address[] public gauges;
    mapping(address => bool) public isGauge;


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(address _condition, address _target) {
        owner = msg.sender;
        condition = _condition;
        target = _target;
    }


    function checkUpkeep(bytes memory /*checkdata*/) public view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
        upkeepNeeded = IMinter(condition).check();
    }

    function performUpkeep(bytes calldata /*performData*/) external override {
        require(msg.sender == automationRegistry || msg.sender == owner, 'cannot execute');

        (bool upkeepNeeded, ) = checkUpkeep('0');
        require(upkeepNeeded, "condition not met");

        IVoter(target).distributeAll();
        IVoter(target).distributeFees(gauges);
    }

    function addGauge(address[] memory _gauges) external onlyOwner {
        uint i;
        address _gauge;
        for(i = 0; i < _gauges.length; i++){
            _gauge = _gauges[i];
            require(_gauge != address(0));
            if(isGauge[_gauge] == false){
                gauges.push(_gauge);
                isGauge[_gauge] = true;
            }
        }
    }


    function removeGauge(address[] memory _gauges) external onlyOwner {
        uint i;
        uint k;
        address _gauge;
        for(i = 0; i < _gauges.length; i++){
            _gauge = _gauges[i];
            if(isGauge[_gauge]){
                for(k=0; k < gauges.length; i++){
                    if(gauges[k] == _gauge) {
                        gauges[k] = gauges[gauges.length -1];
                        gauges.pop();
                        break;
                    }  
                }
            }

        }
    }

    function removeGaugeAt(uint _position) external onlyOwner {
        address _gauge= gauges[_position];

        //remove flag
        isGauge[_gauge] = false;

        //bring last to _pos and pop()
        gauges[_position] = gauges[gauges.length -1];
        gauges.pop();
        
    }

    function gaugesLength() public view returns(uint) {
        return gauges.length;
    }


    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0));
        owner = _owner;
    }

    function setAutomationRegistry(address _automationRegistry) external onlyOwner {
        require(_automationRegistry != address(0));
        automationRegistry = _automationRegistry;
    }

    function setTarget(address _target) external onlyOwner {
        require(_target != address(0));
        target = _target;
    }

    function setCondition(address _condition ) external onlyOwner {
        require(_condition != address(0));
        condition = _condition;
    }



}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IMinter {
    function update_period() external returns (uint);
    function check() external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AutomationBase.sol";
import "./AutomationCompatibleInterface.sol";

abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IVoter {
    function _ve() external view returns (address);
    function governor() external view returns (address);
    function gauges(address _pair) external view returns (address);
    function factory() external view returns (address);
    function emergencyCouncil() external view returns (address);
    function attachTokenToGauge(uint _tokenId, address account) external;
    function detachTokenFromGauge(uint _tokenId, address account) external;
    function emitDeposit(uint _tokenId, address account, uint amount) external;
    function emitWithdraw(uint _tokenId, address account, uint amount) external;
    function isWhitelisted(address token) external view returns (bool);
    function notifyRewardAmount(uint amount) external;
    function distribute(address _gauge) external;
    function distributeAll() external;
    function distributeFees(address[] memory _gauges) external;

    function internal_bribes(address _gauge) external view returns (address);
    function external_bribes(address _gauge) external view returns (address);

    function usedWeights(uint id) external view returns(uint);
    function lastVoted(uint id) external view returns(uint);
    function poolVote(uint id, uint _index) external view returns(address _pair);
    function votes(uint id, address _pool) external view returns(uint votes);
    function poolVoteLength(uint tokenId) external view returns(uint);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomationBase {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
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
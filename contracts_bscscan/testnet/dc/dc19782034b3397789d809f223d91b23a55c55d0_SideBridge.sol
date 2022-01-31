// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20Child } from "./IERC20Child.sol";
import { FrostyAccessControls } from "./FrostyAccessControl.sol";
import { SafeMath } from "./SafeMath.sol";

contract SideBridge {
    using SafeMath for uint;

    event BridgeInitialized(uint indexed timestamp);
    event TokensBridged(address indexed requester, bytes32 indexed mainDepositHash, uint amount, uint timestamp);
    event TokensReturned(address indexed requester, bytes32 indexed sideDepositHash, uint amount, uint timestamp);
    
    IERC20Child private sideToken;
    bool bridgeInitState;
    address owner;
    address gateway;
    FrostyAccessControls public accessControls;


    constructor (address _gateway, FrostyAccessControls _accessControls) {
        gateway = _gateway;
        owner = msg.sender;
        accessControls = _accessControls;       
    }

    function initializeBridge (address _childTokenAddress) onlyOwner external {
      require(
          accessControls.hasAdminRole(owner),
          "MainBridge.initializeBridge: Sender must be admin"
      );
        sideToken = IERC20Child(_childTokenAddress);
        bridgeInitState = true;
    }

    function bridgeTokens (address _requester, uint _bridgedAmount, bytes32 _mainDepositHash) verifyInitialization onlyGateway  external {
      require(
          accessControls.hasAdminRole(gateway),
          "MainBridge.bridgeTokens: Sender must be admin"
      );
        sideToken.mint(_requester,_bridgedAmount);
        emit TokensBridged(_requester, _mainDepositHash, _bridgedAmount, block.timestamp);
    }

    function returnTokens (address _requester, uint _bridgedAmount, bytes32 _sideDepositHash) verifyInitialization onlyGateway external {
      require(
          accessControls.hasAdminRole(gateway),
          "MainBridge.returnTokens: Sender must be admin"
      );
        sideToken.burn(_bridgedAmount);
        emit TokensReturned(_requester, _sideDepositHash, _bridgedAmount, block.timestamp);
    }

    modifier verifyInitialization {
      require(bridgeInitState, "Bridge has not been initialized");
      _;
    }
    
    modifier onlyGateway {
      require(msg.sender == gateway, "Only gateway can execute this function");
      _;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "Only owner can execute this function");
      _;
    }
    

}
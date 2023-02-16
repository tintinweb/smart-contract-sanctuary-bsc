// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract CoralReward {
   uint public number;

   function initialize(uint _num) external {
       number=_num;
   }

   function increase() external {
       number += 1;
   }

   function decrease() external {
       number -= 1;
   }
}

// import "./Interface/ICoralToken.sol";
// import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "./Auth.sol";
// contract CoralReward is
//     Initializable,
//     PausableUpgradeable,
//     AccessControlUpgradeable
// {

//     ICoralToken crlToken;
//     address public verifyAddress;

//     uint256 public constant DAYTIME = 86400;

//     mapping(address => mapping (uint256 => bool)) public stepsRewards;
//     mapping(address => mapping (uint256 => bool)) public referralRewards;
//     mapping(address => mapping (uint256 => bool)) public communityRewards;
//     mapping(address => mapping (uint256 => bool)) public vitalRewards;
//     mapping(address => mapping (uint256 => bool)) public wellnessRewards;
//     /// @custom:oz-upgrades-unsafe-allow constructor
//     constructor() {
//         _disableInitializers();
//     }

//     function initialize(address signer, address crlAddress) public initializer {
//         require(signer != address(0), "signer cant'be zero");
//         require(crlAddress != address(0), "crlAddress cant'be zero");
//         verifyAddress = signer;
//         crlToken = ICoralToken(crlAddress);
//     }
// }
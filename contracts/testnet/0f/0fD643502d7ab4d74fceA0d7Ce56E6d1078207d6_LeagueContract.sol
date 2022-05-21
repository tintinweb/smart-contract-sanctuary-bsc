// SPDX-License-Identifier: MIT
// Sports Prediction
// assets: MUFT, MSWAP, BNB
pragma solidity >=0.4.22 <0.9.0;

import "./libs/IAdminRole.sol";

contract LeagueContract {
  IAdminRole private adminRole;

  uint16 leagueCounter = 1;
  // League title => unique identifier
  mapping (string=>uint16) public leagues;

  // Index, Title
  event LeagueCreated(uint16 id, string title);
  // Index, Title
  event LeagueDeleted(uint16 id, string title);

  modifier onlyOwner() {
    require(
      adminRole.isPlatformOwner(msg.sender),
      "This function is restricted to the contract's owner"
    );
    _;
  }

  constructor(address _adminRole) {
    require(_adminRole != address(0x0), "Invalid address");
    adminRole = IAdminRole(_adminRole);
    require (adminRole.getFeeAddress() != address(0x0), "Invalid admin role");
  }

  function create_league(string memory title) external onlyOwner {
    require(leagues[title] == 0, "Already exist");
    uint16 idx = leagueCounter;
    leagues[title] = idx;
    leagueCounter++;
    emit LeagueCreated(idx, title);
  }

  function remove_league(string memory title) external onlyOwner {
    require(leagues[title] > 0, "No exist");
    uint16 idx = leagues[title];
    leagues[title] = 0;
    emit LeagueDeleted(idx, title);
  }

  function update_adminRole(address _adminRole) external onlyOwner {
    require(_adminRole != address(0x0), "Invalid address");
    adminRole = IAdminRole(_adminRole);
    require (adminRole.getFeeAddress() != address(0x0), "Invalid admin role");
  }

  function getLeagueId(string memory title) external view returns(uint16) {
    return leagues[title];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This is for other NFT contract
interface IAdminRole{
    function isPlatformOwner(address _admin) external view returns(bool);    
    function getFeeAddress() external view returns(address);
}
/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

//SPDX-License-Identifier: MIT
// File: contracts/Adminable.sol


pragma solidity 0.8.9;

abstract contract Adminable {
    event AdminUpdated(address indexed user, address indexed newAdmin);

    address public admin;

    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "UNAUTHORIZED");

        _;
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Can not set admin to zero address");
        admin = newAdmin;

        emit AdminUpdated(msg.sender, newAdmin);
    }
}
// File: contracts/AggregatorV3Interface.sol




interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
// File: contracts/mockUSDOracle.sol






contract MockOracleUSDAggregator is AggregatorV3Interface, Adminable {

  constructor(address admin_) {
    require(admin_ != address(0), "Cant set admin to zero address");
    _setAdmin(admin_);
  }


  int256 public mock_r_answer = 720240;
  function updateMockRoundAnswer(int256 v_) external onlyAdmin {
    mock_r_answer = v_;
  }

  function decimals() external pure returns (uint8) {
    return 8;
  }

  function description() external pure returns (string memory) {
    return 'DuetMock / USD';
  }

  function version() external pure returns (uint256) {
    return 0;
  }

  function getRoundData(uint80 _roundId) external view returns (
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    roundId = _roundId;
    answer = mock_r_answer;
    startedAt = 1657794069;
    updatedAt = 1657794069;
    answeredInRound = 36893488147419161920;
  }

  function latestRoundData() external view returns (
    uint80 roundId,
    int256 answer,
    uint256 startedAt,
    uint256 updatedAt,
    uint80 answeredInRound
  ) {
    roundId = 36893488147419161920;
    answer = mock_r_answer;
    startedAt = 1657794069;
    updatedAt = 1657794069;
    answeredInRound = 36893488147419161920;
  }

}
// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./libs/zeppelin/token/BEP20/IBEP20.sol";

contract SendHolder {
  address public mainAdmin;

  constructor() {
    mainAdmin = msg.sender;
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  function send(address _token, address[] calldata _addresses, uint amount) onlyMainAdmin public {
    for (uint i = 0; i < _addresses.length; i++) {
      IBEP20(_token).transferFrom(msg.sender, _addresses[i], amount);
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity >0.5.0;

import "./ERC20.sol";

contract TokenContract is ERC20 {

  constructor() ERC20("Ebizon Token", "ETK") public {}

  function mint(address account, uint256 amount) public returns (bool) {
    _mint(account, amount);
    return true;
  }

}
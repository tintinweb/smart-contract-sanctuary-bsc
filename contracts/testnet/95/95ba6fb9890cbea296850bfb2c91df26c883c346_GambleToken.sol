// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC20.sol";

contract GambleToken is ERC20 {

   constructor() ERC20("Gamble", "GMBL")  {
    }

    function mint(address _to, uint256 _amount) external {
      _mint(_to, _amount);
    }

    function burn(address _account, uint256 _amount) external {
      _burn(_account, _amount);
    }


}
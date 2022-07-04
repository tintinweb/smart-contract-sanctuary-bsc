// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract sCryptoTT is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("sCryptoTT", "CTT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    address _sBUSDaddress = 0xF291EE4F2606D87Ef7dDb8B62a40a4c81d4BA386;
    IERC20 sBUSD = IERC20(_sBUSDaddress);

    address pegreceiver;

    function setpegreceiver(address _address) public onlyOwner {
        pegreceiver = _address;
    }

    function mint(uint256 amount) public {
        sBUSD.transferFrom(msg.sender, pegreceiver, amount);
        _mint(msg.sender, amount);
    }
}
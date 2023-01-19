// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "ERC20.sol";
import "Ownable.sol";

contract GOG is ERC20, Ownable {
    constructor(uint256 _initialTaxRate) ERC20("GOG", "GOG") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
        setTaxWallet(owner());
        setTaxRate(_initialTaxRate);
    }

    function setTaxWallet(address _newTaxWallet) public onlyOwner {
        ERC20.taxWallet = _newTaxWallet;
    }

    function setTaxRate(uint256 _newTaxRate) public onlyOwner {
        ERC20.taxRate = _newTaxRate;
    }
    
    function setExcludingWallet(address _newExcludingWallet) public onlyOwner {
        ERC20.excludingWallet = _newExcludingWallet;
    }

    function withdraw() public payable onlyOwner {
  
    (bool main, ) = payable(owner()).call{value: address(this).balance}("");
    require(main);
    }  
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";

contract DEGcoin is 
    ContextAware,
    Ownable,
    ERC20{
    address private _supplyManager;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimal,
        uint256 totalSupply,
        address supplyManager
    ) public ERC20(tokenName, tokenSymbol, tokenDecimal) {
        _supplyManager = supplyManager;
        mint(totalSupply*(10 ** uint256(decimals()))); // Emits Mint    
    }

    function supplyManager() public view returns (address) {
        return _supplyManager;
    }

    modifier onlySupplyManager() {
        require(
            _msgSender() == supplyManager() || _msgSender() == owner(),
            "Only the supply manager can call this function."
            );
        _;
    }

    function changeSupplyManager(address newSupplyManager) public onlyOwner {
        require(
            newSupplyManager != address(0),
            "Cannot change supply manager to 0x0."
        );
        _supplyManager = newSupplyManager;
    }

    //Mint
    function mint(uint256 amount) public onlySupplyManager {
        _mint(supplyManager(), amount);
    }

    // Burn
    function burn(uint256 amount) public onlySupplyManager {
        _burn(_supplyManager, amount);
    }
}
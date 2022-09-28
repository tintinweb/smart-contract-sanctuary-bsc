//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "./Interfaces.sol";
import "./Libraries.sol";
import "./BaseErc20.sol";
import "./Taxable.sol";
import "./TaxDistributor.sol";


contract SpaceXpumps is BaseErc20, Taxable {

    constructor () {
        configure(0x6c19Aa56119A2765F474D473c2b98E00C2dDD9aA);

        symbol = "SPCX";
        name = "SpaceXpumps";
        decimals = 18;

        // Pancake Swap
        address pancakeSwap = getRouterAddress();
        IDEXRouter router = IDEXRouter(pancakeSwap);
        address WBNB = router.WETH();
        address pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        exchanges[pair] = true;
        taxDistributor = new TaxDistributor(pancakeSwap, pair, WBNB, 1300, 1300);

        // Tax
        minimumTimeBetweenSwaps = 5 minutes;
        minimumTokensBeforeSwap = 1000 * 10 ** decimals;
        excludedFromTax[address(taxDistributor)] = true;
        taxDistributor.createWalletTax("Marketing", 1300, 1300, 0x6c19Aa56119A2765F474D473c2b98E00C2dDD9aA, true);
        autoSwapTax = true;


        _allowed[address(taxDistributor)][pancakeSwap] = 2**256 - 1;
        _totalSupply += 1_000_000 * 10 ** decimals;
        _balances[owner] += _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // Overrides
    
    function configure(address _owner) internal override(Taxable, BaseErc20) {
        super.configure(_owner);
    }
    
    function preTransfer(address from, address to, uint256 value) override(Taxable, BaseErc20) internal {
        super.preTransfer(from, to, value);
    }
    
    function calculateTransferAmount(address from, address to, uint256 value) override(Taxable, BaseErc20) internal returns (uint256) {
        return super.calculateTransferAmount(from, to, value);
    }

    // Admin

    function setName(string memory _name, string memory _symbol) external onlyOwner {
        name = _name;
        symbol = _symbol;
    }
}
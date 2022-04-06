// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "./ERC20Upgradeable.sol";
import "./OwnableUpgradeable.sol";

import "./IBondToken.sol";

contract aBNBc is OwnableUpgradeable, ERC20Upgradeable {
    /**
     * Variables
     */

    address private _binancePool;
    address private _bondToken;

    /**
     * Events
     */

    event BinancePoolChanged(address indexed binancePool);
    event BondTokenChanged(address indexed bondToken);

    /**
     * Modifiers
     */

    modifier onlyMinter() {
        require(
            msg.sender == _binancePool || msg.sender == _bondToken,
            "Minter: not allowed"
        );
        _;
    }

    function initialize(address binancePool, address bondToken)
        public
        initializer
    {
        __Ownable_init();
        __ERC20_init_unchained("Ankr BNB Reward Bearing Certificate", "aBNBc");
        _binancePool = binancePool;
        _bondToken = bondToken;
        uint256 initSupply = IBondToken(_bondToken).totalSharesSupply();
        // mint init supply if not inizialized
        super._mint(address(_bondToken), initSupply);
    }

    function ratio() public view returns (uint256) {
        return IBondToken(_bondToken).ratio();
    }

    function burn(address account, uint256 amount) external onlyMinter {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) external onlyMinter {
        _mint(account, amount);
    }

    function mintApprovedTo(
        address account,
        address spender,
        uint256 amount
    ) external onlyMinter {
        _mint(account, amount);
        _approve(account, spender, amount);
    }

    function changeBinancePool(address binancePool) external onlyOwner {
        _binancePool = binancePool;
        emit BinancePoolChanged(binancePool);
    }

    function changeBondToken(address bondToken) external onlyOwner {
        _bondToken = bondToken;
        emit BondTokenChanged(bondToken);
    }

    function balanceWithRewardsOf(address account)
        public
        view
        returns (uint256)
    {
        uint256 shares = this.balanceOf(account);
        return IBondToken(_bondToken).sharesToBonds(shares);
    }

    function isRebasing() public pure returns (bool) {
        return false;
    }
}
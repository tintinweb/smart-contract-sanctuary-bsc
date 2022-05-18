// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "IERC20.sol";
import "EnumerableSet.sol";

import "ITaxHandler.sol";
import "ExchangePoolProcessor.sol";

/**
 * @title Special tax handler contract
 * @dev This contract allows protocols to collect tax on transactions that count as either sells or liquidity additions
 * to exchange pools. Addresses can be exempted from tax collection, and addresses designated as exchange pools can be
 * added and removed by the owner of this contract. The owner of the contract should be set to a DAO-controlled timelock
 * or at the very least a multisig wallet. Additionally, this contract can exclude specific address from transferring
 * tokens to an address other than a specified address or the burn address.
 */
contract SpecialTaxHandler is ITaxHandler, ExchangePoolProcessor {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev tax fee.
    uint256 public taxFee = 1500;

    /// @dev The set of addresses exempt from tax.
    EnumerableSet.AddressSet private _exempted;

    /// @notice The address blacklisted wallets are allowed to transfer to.
    address public immutable receiver;

    /// @notice The token to account for.
    IERC20 public token;

    /// @notice Emitted when an address is added to or removed from the exempted addresses set.
    event TaxExemptionUpdated(address indexed wallet, bool exempted);

    /// @dev The registry of blacklisted addresses.
    mapping (address => bool) private _banned;

    constructor(address tokenAddress, address receiverAddress) {
        token = IERC20(tokenAddress);
        receiver = receiverAddress;
    }

    /**
     * @notice Get number of tokens to pay as tax. This method specifically only check for sell-type transfers to
     * designated exchange pool addresses.
     * @dev There is no easy way to differentiate between a user selling tokens and a user adding liquidity to the pool.
     * In both cases tokens are transferred to the pool. This is an unfortunate case where users have to accept being
     * taxed on liquidity additions. To get around this issue, a separate liquidity addition contract can be deployed.
     * This contract can be exempt from taxes if its functionality is verified to only add liquidity.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     * @return Number of tokens to pay as tax.
     */
    function getTax(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external view override returns (uint256) {
        if (_banned[benefactor]) {
            // Only accept transfers to dead address or multisig.
            if (beneficiary != 0x000000000000000000000000000000000000dEaD && beneficiary != receiver) {
                revert();
            }
        }

        if (_exempted.contains(benefactor) || _exempted.contains(beneficiary) || benefactor == receiver) {
            return 0;
        }

        // Trading starts on June 6th 2022
        if (block.timestamp <= 1654466400)
        {
            revert();
        }

        // Transactions between regular users (this includes contracts) aren't taxed.
        if (!_exchangePools.contains(benefactor) && !_exchangePools.contains(beneficiary)) {
            return 0;
        }

        // Tax is 15% on buys.
        if (_exchangePools.contains(benefactor)) {
            return (amount * taxFee) / 10000;
        }

        // Technically not the actual price impact, as that would follow the x * y = k curve.
        uint256 priceImpactBasisPoint = token.balanceOf(primaryPool) / 10000;

        if (amount <= priceImpactBasisPoint * 300) {
            return (amount * taxFee) / 10000;
        } else if (amount <= priceImpactBasisPoint * 800) {
            return (amount * 1500) / 10000;
        } else if (amount <= priceImpactBasisPoint * 1000) {
            return (amount * 2000) / 10000;
        } else if (amount <= priceImpactBasisPoint * 2000) {
            return (amount * 2500) / 10000;
        } else if (amount <= priceImpactBasisPoint * 3000) {
            return (amount * 3000) / 10000;
        } else if (amount <= priceImpactBasisPoint * 4000) {
            return (amount * 4000) / 10000;
        } else if (amount <= priceImpactBasisPoint * 5000) {
            return (amount * 5000) / 10000;
        } else if (amount <= priceImpactBasisPoint * 7500) {
            return (amount * 7500) / 10000;
        } else {
            return (amount * 8500) / 10000;
        }
    }

    /**
     * @notice Update Tax Fee (range: 3-15%)
     * @param newTaxFee NewTax
     */
    function updateTaxFee(uint256 newTaxFee) public onlyOwner {
        if (newTaxFee <= 1000 || newTaxFee >= 300)
            taxFee = newTaxFee;
    }

    /**
     * @notice Add address to set of tax-exempted addresses.
     * @param exemption Address to add to set of tax-exempted addresses.
     */
    function addExemption(address exemption) external onlyOwner {
        if (_exempted.add(exemption)) {
            emit TaxExemptionUpdated(exemption, true);
        }
    }

    /**
     * @notice Remove address from set of tax-exempted addresses.
     * @param exemption Address to remove from set of tax-exempted addresses.
     */
    function removeExemption(address exemption) external onlyOwner {
        if (_exempted.remove(exemption)) {
            emit TaxExemptionUpdated(exemption, false);
        }
    }

    /**
     * @notice Get blacklist status of a given wallet.
     * @param wallet Address to check blacklist status of.
     * @return True if address is blacklisted, else False.
     */
    function isBlacklisted(address wallet) external view returns (bool) {
        return _banned[wallet];
    }

    /**
     * @notice Add list of wallet addresses to the blacklist.
     * @param wallets List of wallet addresses to add to the blacklist.
     * @dev The list is allowed to contain duplicates.
     */
    function addToBlacklist(address[] memory wallets) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _banned[wallets[i]] = true;
        }
    }

    /**
     * @notice Remove list of wallet addresses from the blacklist.
     * @param wallets List of wallet addresses to add to the blacklist.
     * @dev The list is allowed to contain duplicates.
     */
    function removeFromBlacklist(address[] memory wallets) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _banned[wallets[i]] = false;
        }
    }
}
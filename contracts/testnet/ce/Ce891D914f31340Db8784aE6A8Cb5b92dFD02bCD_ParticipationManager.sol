// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./interfaces/ICRules.sol";

contract ParticipationManager {
    /* ========== STRUCTS ========== */

    struct Copier {
        uint256 allocation;
        uint256 pools;
        uint256 averagePriceIn;
    }

    /* ========== STATE VARIABLES ========== */

    mapping(address => Copier) public copiers;

    ICRules public rulesContract;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rulesContract) {
        rulesContract = ICRules(_rulesContract);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function computeSuscribe(
        address _poolAddress,
        address _copierAddress,
        uint256 _amount
    ) external onlyPoolInWhiteList(_poolAddress) {
        Copier storage copier = copiers[_copierAddress];

        copier.allocation += _amount;
        copier.pools++;
    }

    function computeUnsuscribe(
        address _poolAddress,
        address _copierAddress,
        uint256 _amount
    ) external onlyPoolInWhiteList(_poolAddress) {
        Copier storage copier = copiers[_copierAddress];

        copier.allocation -= _amount;
        copier.pools--;
    }

    function getMaxInvestmentAvailable(address _copier)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable)
    {
        (uint256 maxAllocations, uint256 maxPools) = rulesContract
            .getMaxAllocationPerStaking(_copier);

        maxAllocationAvailable = maxAllocations - copiers[_copier].allocation;
        maxPoolsAvailable = maxPools - copiers[_copier].pools;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyPoolInWhiteList(address _poolAddress) {
        require(
            rulesContract.isPoolInWhiteList(_poolAddress),
            "Only a CPool may perform this action"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ICRules {
    function getMaxAllocationPerStaking(address copier)
        external
        view
        returns (uint256, uint256);

    function getMaxInvestmentAvailable(address _copier)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable);

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool);

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool);

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool);

    function addPoolToWhiteList(address _poolAddress) external;
}
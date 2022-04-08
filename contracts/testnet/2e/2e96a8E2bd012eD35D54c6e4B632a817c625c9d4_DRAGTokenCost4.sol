pragma solidity ^0.8.0;

import "./DRAGTokenCostDistribution.sol";

contract DRAGTokenCost4 is DRAGTokenCostDistribution
{
    constructor(IERC20 _dragToken) DRAGTokenCostDistribution(_dragToken, 4000) public
    {
    }
}
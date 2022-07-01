// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import "./IOracle.sol";

contract Liquidation {
    ///The percentages are multiplied by 100 in order to make the calculations.
    ///This mapping stores the percentage of the position versus the maximum threshold to be liquidated.
    mapping(uint256 => uint256) public percentages;
    IOracle internal oracle;

    constructor(address _oracle) {
        percentages[50] = 6000;
        oracle = IOracle(_oracle);
    }

    function liquidationPrice(uint256 poolId, uint256 _debt)
        public
        view
        returns (uint256)
    {
        uint256 _actualprice = oracle.getLatestPrice(poolId);
        uint256 _percentage = percentages[_debt];
        uint256 percentageAmount = (_actualprice * (_percentage)) / 10000;
        return _actualprice - percentageAmount;
    }

    function liquidationState(uint256 _trigger, uint256 poolId)
        public
        view
        returns (bool _status)
    {
        uint256 answer = oracle.getLatestPrice(poolId);
        if (_trigger > uint256(answer)) {
            return true;
        } else {
            return false;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IOracle {
    function getLatestPrice(uint256) external view returns (uint256);
}
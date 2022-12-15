// SPDX-License-Identifier: ANCHISA PINYO
pragma solidity ^0.8.12;

interface IBidding {
    function hasRole(bytes32 _role, address _account) external returns (bool);
}

contract Baseline {
    bytes32 public MDP_ROLE = keccak256("MDP_ROLE");
    IBidding Bidding;

    constructor(
        
        address _bidding
        
    ) {
        Bidding = IBidding(_bidding);
    }

    function createBaseline(uint256[][] memory _meterData)
        public
        returns (uint256[] memory, uint256)
    {
        require(
            Bidding.hasRole(MDP_ROLE, msg.sender),
            "Only MDP ROLE can call this"
        );
        uint256 _hour = _meterData.length;
        uint256[] memory _baseline = new uint256[](_hour);

        for (uint8 i = 0; i < _meterData.length; i++) {
            uint256 dataNumber = _meterData[i].length;
            uint256 x = 0;
            for (uint8 j = 0; j < _meterData[i].length; j++) {
                x = x + _meterData[i][j];
            }
            _baseline[i] = x / dataNumber;
        }

        uint256 _error = _RRMSE(_baseline);

        return (_baseline, _error);
    }

    function _RRMSE(uint256[] memory _baseline)
        internal
        pure
        returns (uint256)
    {
        uint256 x = _baseline.length / 50;
        return x;
    }
}
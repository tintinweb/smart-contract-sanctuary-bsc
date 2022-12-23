// SPDX-License-Identifier: ANCHISA PINYO
pragma solidity ^0.8.12;

interface IBidding {
    function hasRole(bytes32 _role, address _account) external returns (bool);

    function register(address _address) external;
}

contract Baseline {
    bytes32 public MDP_ROLE = keccak256("MDP_ROLE");
    IBidding Bidding;

    constructor(address _bidding) {
        Bidding = IBidding(_bidding);
    }

    function createBaselineForRegistration(
        uint256[][] memory _meterData,
        address _address
    )
        public
        returns (
            uint256[] memory,
            uint256,
            bool
        )
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
        bool _registered = false;

        uint256 _error = _RRMSE(_baseline);

        if (_error <= 30) {
            Bidding.register(_address);
            _registered = true;
        }

        return (_baseline, _error, _registered);
    }

    function createBaselineForEvaluation(
        uint256[][] memory _meterData,
        uint256[] memory _actualData
    ) public returns (uint256[] memory, uint256) {
        require(
            Bidding.hasRole(MDP_ROLE, msg.sender),
            "Only MDP ROLE can call this"
        );
        uint256 _hour = _meterData.length;
        uint256[] memory _rawBaseline = new uint256[](_hour);

        for (uint8 i = 0; i < _meterData.length; i++) {
            uint256 dataNumber = _meterData[i].length;
            uint256 x = 0;
            for (uint8 j = 0; j < _meterData[i].length; j++) {
                x = x + _meterData[i][j];
            }
            _rawBaseline[i] = x / dataNumber;
        }
        uint256 _ratio = _adjustment(_rawBaseline, _actualData);
        uint256[] memory _baseline = new uint256[](
            _meterData.length - _actualData.length
        );
        if (_ratio <= 120 && _ratio >= 80) {
            for (uint8 i = 0; i < _actualData.length; i++) {
                _baseline[i] =
                    (_rawBaseline[i + _actualData.length] * _ratio) /
                    100;
            }
        } else {
            for (uint8 i = 0; i < _actualData.length; i++) {
                _baseline[i] = _rawBaseline[i + _actualData.length];
            }
        }

        return (_baseline, _ratio);
    }

    function _adjustment(
        uint256[] memory _rawBaseline,
        uint256[] memory _actualData
    ) internal pure returns (uint256) {
        uint256 _sumBase = 0;
        uint256 _sumActual = 0;
        for (uint8 i = 0; i < _actualData.length; i++) {
            _sumBase = _sumBase + _rawBaseline[i];
            _sumActual = _sumActual + _actualData[i];
        }
        uint256 _ratio = _sumActual / _sumBase;
        return _ratio * 100;
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
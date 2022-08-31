// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IRandomNumberGenerator {
    function computerSeed(uint256) external view returns(uint256);
    function getNumber(uint256) external view returns(uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../interfaces/IRandomNumberGenerator.sol';


contract RandomIndexView {
    IRandomNumberGenerator public rng = IRandomNumberGenerator(0xf7c2452D3B333fF73ECCE59DAe1769bA33919795);

    // ================= View functions ==================== //
    function _getRandomNumber(uint _n1, uint _n2, uint _n3, uint _roundId, uint _index) internal pure returns (uint _number) {
        uint _r = uint(keccak256(abi.encodePacked(_index, _roundId))) % 256;
        return uint(keccak256(abi.encodePacked(_n1 >> _r, _n2 % (_r > 0 ? _r : _r + 1), _n3 >> (256 - _r), _roundId, _index)));
    }

    function isExist(uint[] memory _array, uint _number, uint _range) internal pure returns (bool _isExist) {
        _isExist = false;
        require(_array.length >= _range, "!Range");
        for (uint i = 0; i < _range; i++) {
            if (_array[i] == _number) {
                _isExist = true;
                break;
            }
        }
    }

    function getRandomIndex(uint _roundId, uint _maxIndex, uint _quantity) external view returns (uint[] memory _result, uint _blockNumber) {
        require(_maxIndex >= _quantity, "!Quantity");
        _result = new uint[](_quantity);
        _blockNumber = block.number;
        uint256[] memory numbers = rng.getNumber(_roundId);
        for (uint i = 0; i < _quantity; i++) {
            uint _index = _getRandomNumber(numbers[0], numbers[1], numbers[2], _roundId, i) % _maxIndex;
            while (isExist(_result, _index, i)) {
                _index = (_index + 1) % _maxIndex;
            }
            _result[i] = _index;
        }
    }
}
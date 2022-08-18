// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IRandomNumberGenerator {
    function computerSeed(uint256) external view returns(uint256);
    function getNumber(uint256) external view returns(uint256[] memory);
    function currentRoundId() external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../interfaces/IRandomNumberGenerator.sol';
contract RandomIndex {

    function getRandomNumber(uint _n1, uint _n2, uint _n3, uint _roundId, uint _index) internal view returns(uint _number) {
        uint _r = uint(keccak256(abi.encodePacked(block.number, blockhash(block.number - 128)))) % 256;
        return uint(keccak256(abi.encodePacked(_n1 >> _r, _n2 % _r, _n3 >> (256 - _r), _roundId, _index)));
    }

    function isExist(uint[] memory _array, uint _number, uint _range) internal view returns(bool _isExist) {
        _isExist = false;
        require(_array.length >= _range, "!Range");
        for(uint i = 0; i < _range; i++) {
            if(_array[i] == _number) {
                _isExist = true;
                break;
            }
        }
    }

    function getRandomIndex(address _rng, uint _roundId, uint _maxIndex, uint _quantity) external view returns(uint[] memory _result) {
        require(_maxIndex >= _quantity, "!Quantity");
        _result = new uint[](_quantity);
        uint _currentRoundId = IRandomNumberGenerator(_rng).currentRoundId();
        uint[] memory _currentNumber = IRandomNumberGenerator(_rng).getNumber(_currentRoundId);

        for(uint i = 0; i < _quantity; i++) {
            uint _index = getRandomNumber(_currentNumber[0], _currentNumber[1], _currentNumber[2], _roundId, i) % _maxIndex;
            while(isExist(_result, _index, i)) {
                _index = (_index + 1) % _maxIndex;
            }
            _result[i] = _index;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// File: contracts/RNG.sol

//  SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract RNG {
    uint256 public globalNonce;
    mapping(address => uint256) public nonces;

    event Numbers(
        uint256 indexed requestId,
        address indexed caller, 
        uint256 dice1, uint256 dice2, uint256 dice3,
        bytes32 infoHash
    );

    constructor() {
        globalNonce = block.timestamp % 113;
    }

    function test(
        uint256 _requestId,
        uint256 uNum, uint256 sNum,
        bytes calldata uPhrases, bytes calldata sPhrases
    ) external {
        try this.roll_dices(_requestId, uNum, sNum, uPhrases, sPhrases) {}
        catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory reason) {
            revert(string(reason));
        }
    }

    function roll_dices(
        uint256 _requestId,
        uint256 uNum, uint256 sNum,
        bytes calldata uPhrases, bytes calldata sPhrases
    ) external {
        uint256 _globalNonce = globalNonce + 1;
        uint256 _nonce = nonces[msg.sender] + 1;

        bytes[7] memory _data;
        uint256 _dice1; uint256 _dice2; uint256 _dice3;
        
        if (_globalNonce % 3 == 0) {
            _data = [
                _numToBytes(uNum), _numToBytes(sNum),
                _numToBytes(block.number), _numToBytes(block.timestamp),
                uPhrases, sPhrases, _numToBytes(_globalNonce)
            ];

            (_dice1, _dice2, _dice3) = _generateBases(_globalNonce, _nonce, 0, _data);
            (_dice1, _dice2, _dice3) = _rand(_dice1, _dice2, _dice3);
        } else if (_globalNonce % 3 == 1) {
            _data = [
                uPhrases, sPhrases, _numToBytes(_nonce),
                _numToBytes(uNum), _numToBytes(sNum),
                _numToBytes(block.number), _numToBytes(block.timestamp)
            ];

            (_dice1, _dice2, _dice3) = _generateBases(_globalNonce, _nonce, 1, _data);
            (_dice1, _dice2, _dice3) = _rand(_dice1, _dice2, _dice3);
        } else {
            _data = [
                _numToBytes(block.number), _numToBytes(block.timestamp),
                _numToBytes(uNum), _numToBytes(sNum), _numToBytes(_nonce),
                uPhrases, sPhrases
            ];
            
            (_dice1, _dice2, _dice3) = _generateBases(_globalNonce, _nonce, 2, _data);
            (_dice1, _dice2, _dice3) = _rand(_dice1, _dice2, _dice3);
        }
        nonces[msg.sender] = _nonce;
        globalNonce = _globalNonce;
        bytes32 _infoHash = keccak256(
            abi.encodePacked(
                uNum, sNum, uPhrases, sPhrases
            )
        );

        emit Numbers(_requestId, msg.sender, _dice1, _dice2, _dice3, _infoHash);
    }

    function _numToBytes (uint256 _num) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { 
            mstore(add(b, 32), _num) 
        }
    }

    function _generateBases(
        uint256 _globalNonce, uint256 _nonce, uint256 _opt, bytes[7] memory _seed
    ) private pure returns (uint256 _bigNum1, uint256 _bigNum2, uint256 _bigNum3) {
        if (_opt == 0) {
            _bigNum1 = _genNum(_globalNonce, _seed);
            _bigNum2 = _genNum(_globalNonce - _nonce, _seed);
            _bigNum3 = _genNum(_globalNonce + _nonce, _seed);
        }
        else if (_opt == 1) {
            _bigNum1 = _genNum(_nonce, _seed);
            _bigNum2 = _genNum(_globalNonce, _seed);
            _bigNum3 = _genNum(_globalNonce - _nonce, _seed);
        }
        else {
            _bigNum1 = _genNum(_nonce, _seed);
            _bigNum2 = _genNum(_globalNonce, _seed);
            _bigNum3 = _genNum(_globalNonce + _nonce, _seed);
        }
    }

    function _genNum(uint256 _pos, bytes[7] memory _seed) private pure returns (uint256 _bignum) {
        _pos = _pos % 7;

        bytes memory temp;
        for (uint256 i = _pos; i < 7; ) {
            temp = abi.encodePacked(temp, _seed[i]);
            if (_pos != 0 && i == 6) 
                i = 0;
            else if (_pos != 0 && i == _pos - 1)
                break;
            else
                i++;
        }

        _bignum = uint256(keccak256(temp));
    }

    function _rand(
        uint256 _base1, uint256 _base2, uint256 _base3
    ) private view returns (uint256 _dice1, uint256 _dice2, uint256 _dice3) {
        uint256 _num = block.timestamp * block.number;
        _num *= _num;

        _dice1 = _filter(
            _base1,
            _num % 10000000019 % 1000003 % 59,
            _num % 10000000069 % 1000039 % 11
        );
        _dice2 = _filter(
            _base2,
            _num % 10000000033 % 1000033 % 59,
            _num % 10000000097 % 1000081 % 11
        );
        _dice3 = _filter(
            _base3, 
            _num % 10000000061 % 1000037 % 59,
            _num % 10000000103 % 1000099 % 11
        );

        _dice1 = _dice1 % 1000003 % 10007 % 7 + 1;
        _dice2 = _dice2 % 1000003 % 10007 % 7 + 1;
        _dice3 = _dice3 % 1000003 % 10007 % 7 + 1;
    }

    function _filter(uint256 _base, uint256 _pos, uint256 _length) private pure returns (uint256 _num) {
        _num = (_base / 10**_pos) % 10**_length;
    }
}
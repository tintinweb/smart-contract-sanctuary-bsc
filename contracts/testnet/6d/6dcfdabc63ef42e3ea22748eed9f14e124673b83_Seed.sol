/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Seed {

    // uint256 nonce;
    // uint256 key;

    // constructor() public {
    //     nonce = now;
    //     key = now * block.difficulty;
    // }
    uint256[] public qulist;
    uint256[] public tylist;
    uint256 public useIndex = 19200;

    mapping (address => bool) internaluser;

    constructor () {
        internaluser[0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4] = true;
        internaluser[0xf48F0936b8AE33f65c62ef3a8c0e3b35A9eE94eC] = true;
        internaluser[0xd6f0E85ac2e7e3698d2BA89A76F48B01BC270AF0] = true;
    }

    function addbpg(address bpg) public {
        require(bpg != address(0), "bpg error");
        internaluser[bpg] = true;
    }

    function Hash(uint256 totalSize, uint256 _start, uint256 _end) public view returns (uint256 _res, uint256[] memory _qus, uint256[] memory _tys) {
        uint256 nonce;
        uint256 key;
        nonce = block.timestamp;
        key = block.timestamp * block.difficulty;

        uint256 index = uint256(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp,block.gaslimit,block.number,block.coinbase)));
        index = uint256(keccak256(abi.encodePacked(key, nonce, index, block.difficulty)));
        nonce++;
        key = ((key >> 17) + (nonce % 0x100000)) % block.timestamp;
        _res = (index % totalSize);

        (_qus, _tys) = getQuAndTy(_start, _end);
        /*
        _res = new uint256[](times);
        for (uint i; i < times; i++) {
            uint256 index = uint256(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp,block.gaslimit,block.number,block.coinbase)));
            index = uint256(keccak256(abi.encodePacked(key, nonce, index, block.difficulty)));
            nonce++;
            key = ((key >> 17) + (nonce % 0x100000)) % block.timestamp;
            _res[i] = (index % totalSize);
        }
        */
    }

    function addQuType(uint256[] memory qus, uint256[] memory tys) public {
        require(qus.length > 0,"size error");
        require(qus.length == tys.length,"size different");
        require(qus.length % 64 == 0, "Not aligned");

        uint icou = qus.length / 64;
        uint iusd= 0;
        for (uint i = 0; i < icou; i++) {
            uint256 _tmp;
            for (uint _i = 0; _i < 64; _i++) {
                _tmp += qus[iusd++] << (_i *4);
            }
            qulist.push(_tmp);
        }

        icou = tys.length / 32;
        iusd = 0;
        for (uint i = 0; i < icou; i++) {
            uint256 _tmp;
            for (uint _i = 0; _i < 32; _i++) {
                _tmp += tys[iusd++] << (_i * 8);
            }
            tylist.push(_tmp);
        }
    }

    function cleanToPosition(uint256 _pos) public {
        require((_pos % 64) == 0, "size error");
        uint256 __pos = _pos / 64;
        while (qulist.length > __pos){
            qulist.pop();
        }
        __pos = _pos / 32;
        while (tylist.length > __pos){
            tylist.pop();
        }
    }

    function getIndexs(uint256 num) public returns (uint256 _start, uint256 _end) {
        uint startId = useIndex;
        if (internaluser[tx.origin] && (startId - 19200 + num < 19200)) {
            startId -= 19200;
        }
        require(startId + num <= (qulist.length * 64), "range out");
        _start = startId;
        _end = startId + num - 1;
        useIndex += num;
    }

    function getQuAndTy(uint256 _start, uint256 _end) public view returns (uint256[] memory _qus, uint256[] memory _tys) {
        require(_start < useIndex && _end < useIndex, "range out");
        _qus = new uint256[](_end - _start + 1);
        _tys = new uint256[](_qus.length);
        uint256 _i;
        for (uint i = _start; i <= _end; i++) {
            uint256 _i1 = i / 64;
            uint256 _i2 = i % 64;
            _qus[_i] = (qulist[_i1] >> (_i2 * 4)) % 0x10;
            _i1 = i / 32;
            _i2 = i % 32;
            _tys[_i] = (tylist[_i1] >> (_i2 * 8)) % 0x100;
            _i++;
        }
    }

}
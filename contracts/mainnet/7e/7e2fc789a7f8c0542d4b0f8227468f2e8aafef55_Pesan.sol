/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Pesan {
    event pesanLama(string pesanlama);
    event pesanBaru(string pesanbaru);

    string public pesan;

    constructor(string memory pesanpertama) {
        pesan = pesanpertama;
    }

    function ubah_pesan( string memory pesanbaru) public {
        string memory pesanlama = pesan;
        pesan = pesanbaru;

        emit pesanLama(pesanbaru);
        emit pesanBaru(pesanlama);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library az09Dash {
  struct State {
    bool accepts;
    function (bytes1) pure internal returns (State memory) func;
  }

  string public constant regex = "[a-zA-Z0-9\\-]+";

  function s0(bytes1 c) pure internal returns (State memory) {
    c = c;
    return State(false, s0);
  }

  function s1(bytes1 c) pure internal returns (State memory) {

     uint8 _cint = uint8(c);

        if (_cint == 45 || _cint >= 48 && _cint <= 57 || _cint >= 65 && _cint <= 90 || _cint >= 97 && _cint <= 122) {
          return State(true, s2);
        }

    return State(false, s0);
  }

  function s2(bytes1 c) pure internal returns (State memory) {

     uint8 _cint = uint8(c);

        if (_cint == 45 || _cint >= 48 && _cint <= 57 || _cint >= 65 && _cint <= 90 || _cint >= 97 && _cint <= 122) {
          return State(true, s3);
        }

    return State(false, s0);
  }

  function s3(bytes1 c) pure internal returns (State memory) {

     uint8 _cint = uint8(c);

        if (_cint == 45 || _cint >= 48 && _cint <= 57 || _cint >= 65 && _cint <= 90 || _cint >= 97 && _cint <= 122) {
          return State(true, s3);
        }

    return State(false, s0);
  }

  function isAz09Dash(string memory input) public pure returns (bool) {
    State memory cur = State(false, s1);

    for (uint i = 0; i < bytes(input).length; i++) {
      bytes1 c = bytes(input)[i];

      cur = cur.func(c);
    }

    return cur.accepts;
  }
}
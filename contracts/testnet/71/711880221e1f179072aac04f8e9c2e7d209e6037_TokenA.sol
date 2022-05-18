// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.14;

import "./Token.sol";

contract TokenA is _Token_
{
    constructor() _Token_(15000000) {}
}
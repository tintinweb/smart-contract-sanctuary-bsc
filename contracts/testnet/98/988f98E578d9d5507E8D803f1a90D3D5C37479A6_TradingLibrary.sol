//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library TradingLibrary {
    struct ItemSet {
        bytes32[] _values;
    }

    function _eq(ItemSet memory _lhs, ItemSet memory _rhs)
        internal
        pure
        returns (bool)
    {
        if (_lhs._values.length != _rhs._values.length) return false;
        for (uint256 i = 0; i < _lhs._values.length; i++) {
            if (_lhs._values[i] != _rhs._values[i]) return false;
        }
        return true;
    }

    function _noteq(ItemSet memory _lhs, ItemSet memory _rhs)
        internal
        pure
        returns (bool)
    {
        return !_eq(_lhs, _rhs);
    }

    struct TokenSet {
        ItemSet _inner;
    }

    function eq(TokenSet memory lhs, TokenSet memory rhs)
        internal
        pure
        returns (bool)
    {
        return _eq(lhs._inner, rhs._inner);
    }

    function noteq(TokenSet memory lhs, TokenSet memory rhs)
        internal
        pure
        returns (bool)
    {
        return _noteq(lhs._inner, rhs._inner);
    }

    function tokenSetConstructor(address tokenAddress, uint256 tokenValue)
        external
        pure
        returns (TokenSet memory)
    {
        bytes32[] memory values = new bytes32[](2);
        values[0] = bytes32(uint256(uint160(tokenAddress)));
        values[1] = bytes32(tokenValue);
        return TokenSet(ItemSet(values));
    }

    function getAddress(TokenSet memory lhs) internal pure returns (address) {
        return address(uint160(uint256(lhs._inner._values[0])));
    }

    function getProp(TokenSet memory lhs) internal pure returns (uint256) {
        return uint256(lhs._inner._values[1]);
    }
}
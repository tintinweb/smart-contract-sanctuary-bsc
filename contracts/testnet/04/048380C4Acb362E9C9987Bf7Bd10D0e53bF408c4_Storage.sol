// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/LibCache.sol";
import "./lib/LibStack.sol";

/// @notice A cache structure composed by a bytes32 array
contract Storage {
    using LibCache for mapping(bytes32 => bytes32);
    using LibStack for bytes32[];

    bytes32[] public stack;
    mapping(bytes32 => bytes32) public cache;

    // keccak256 hash of "msg.sender"
    // prettier-ignore
    bytes32 public constant MSG_SENDER_KEY = 0xb2f2618cecbbb6e7468cc0f2aa43858ad8d153e0280b22285e28e853bb9d453a;

    modifier isStackEmpty() {
        require(stack.length == 0, "Stack not empty");
        _;
    }

    modifier isInitialized() {
        require(_getSender() != address(0), "Sender is not initialized");
        _;
    }

    modifier isNotInitialized() {
        require(_getSender() == address(0), "Sender is initialized");
        _;
    }

    function _setSender() internal isNotInitialized {
        cache.setAddress(MSG_SENDER_KEY, msg.sender);
    }

    function _resetSender() internal {
        cache.setAddress(MSG_SENDER_KEY, address(0));
    }

    function _getSender() internal view returns (address) {
        return cache.getAddress(MSG_SENDER_KEY);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibCache {
    function set(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        bytes32 _value
    ) internal {
        _cache[_key] = _value;
    }

    function setAddress(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        address _value
    ) internal {
        _cache[_key] = bytes32(uint256(uint160(_value)));
    }

    function setUint256(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        uint256 _value
    ) internal {
        _cache[_key] = bytes32(_value);
    }

    function getAddress(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key
    ) internal view returns (address ret) {
        ret = address(uint160(uint256(_cache[_key])));
    }

    function getUint256(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key
    ) internal view returns (uint256 ret) {
        ret = uint256(_cache[_key]);
    }

    function get(mapping(bytes32 => bytes32) storage _cache, bytes32 _key)
        internal
        view
        returns (bytes32 ret)
    {
        ret = _cache[_key];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Config.sol";

library LibStack {
    function setAddress(bytes32[] storage _stack, address _input) internal {
        _stack.push(bytes32(uint256(uint160(_input))));
    }

    function set(bytes32[] storage _stack, bytes32 _input) internal {
        _stack.push(_input);
    }

    function setHandlerType(bytes32[] storage _stack, Config.HandlerType _input)
        internal
    {
        _stack.push(bytes12(uint96(_input)));
    }

    function getAddress(bytes32[] storage _stack)
        internal
        returns (address ret)
    {
        ret = address(uint160(uint256(peek(_stack))));
        _stack.pop();
    }

    function getSig(bytes32[] storage _stack) internal returns (bytes4 ret) {
        ret = bytes4(peek(_stack));
        _stack.pop();
    }

    function get(bytes32[] storage _stack) internal returns (bytes32 ret) {
        ret = peek(_stack);
        _stack.pop();
    }

    function peek(bytes32[] storage _stack)
        internal
        view
        returns (bytes32 ret)
    {
        uint256 length = _stack.length;
        require(length > 0, "stack empty");
        ret = _stack[length - 1];
    }

    function peek(bytes32[] storage _stack, uint256 _index)
        internal
        view
        returns (bytes32 ret)
    {
        uint256 length = _stack.length;
        require(length > 0, "stack empty");
        require(length > _index, "not enough elements in stack");
        ret = _stack[length - _index - 1];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Config {
    // function signature of "postProcess()"
    bytes4 public constant POSTPROCESS_SIG = 0xc2722916;

    // The base amount of percentage function
    uint256 public constant PERCENTAGE_BASE = 1 ether;

    // Handler post-process type. Others should not happen now.
    enum HandlerType {Token, Custom, Others}
}
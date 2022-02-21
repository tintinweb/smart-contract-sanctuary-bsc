/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// File: contracts\Library\Strings.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ISmartSwapRouter02 {
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
        
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract rigelScheduleAlarm is Context {
    using ECDSA for bytes32;
    using ECDSA for bytes;
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    IERC20 public rigelToken;
    ISmartSwapRouter02 public smartSwap;
    address public owner;
    uint256 public fee;
    uint256 public orderCount;
    
    struct userData {
        uint256 _id;
        uint256 amountIn;
        uint256 time;
        uint256 expectedTime;
        address swapFromToken;
        address swapToToken;
        address to;
        address caller;
        address[] path;
        bytes32 Hash;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }
    
    mapping(address => mapping(uint256 => userData)) private Data;
    mapping(uint256 => bool) public orderCancelled;
    mapping(uint256 => bool) public orderFilled;
    mapping (address => bool) public permit;

    event markOrder(
        uint256 id,
        address indexed user,
        address indexed to,
        address swapFromToken,
        address swapToToken,
        uint256 amountToSwap,
        uint256 expectedTime
    );

    event Cancel(
        uint256 id,
        address indexed user,
        address swapFromToken,
        address swapToToken,
        uint256 amountIn,
        uint256 expectedTime,
        uint256 timestamp
    );

    event fulfilOrder(
        uint256 id,
        address indexed caller,
        address indexed to,
        address swapFromToken,
        address swapToToken,
        uint256 amountToSwap,
        uint256 day,
        uint256 expectedDay
    );

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(address _rigelToken, uint256 timeFee, address _routerContract)  {
        rigelToken = IERC20(_rigelToken);
        smartSwap = ISmartSwapRouter02(_routerContract);
        fee = timeFee;
        owner = _msgSender();
    }

    receive() external payable {}

    function grantAccess(address addr) external onlyOwner {
        permit[addr] = true;
    }

    function updateRigelFee(uint256 _newFee) external onlyOwner {
        fee = _newFee;
    }

    function changeRouterContract(address _newRouter) external onlyOwner {
        smartSwap = ISmartSwapRouter02(_newRouter);
    }

    function callPeriodToSwapExactTokens(
        IERC20 _swapFromToken,
        address _swapToToken,
        address _to,
        uint256 _amountIn,
        uint256 _timeOf,
        bytes32 _hash,
        bytes32 r,
        bytes32 s,
        uint8 v
        ) external {
        
        orderCount = orderCount + 1;
        userData storage _userData = Data[_msgSender()][orderCount];        
        address[] memory path = new address[](2);
        path[0] = address(_swapFromToken);
        path[1] = address(_swapToToken);
        
        _userData._id = orderCount;
        _userData.swapFromToken = path[0];
        _userData.swapToToken = path[1];
        _userData.to = _to;
        _userData.caller = _msgSender();
        _userData.amountIn = _amountIn;
        _userData.path = [path[0], path[1]];
        _userData.time = block.timestamp;
        _userData.expectedTime = _timeOf;
        _userData.Hash = _hash;
        _userData.r = r;
        _userData.s = s;
        _userData.v = v;
        
        emit markOrder(
            _userData._id,
            _msgSender(),
            _to,
            address(_swapFromToken),
            _swapToToken,
            _amountIn,
            _timeOf
        );
    }

    function setPeriodToswapTokensForETH(
        IERC20 _swapFromToken,
        address _to,
        uint256 _amountIn,
        uint256 _timeOf,
        bytes32 _hash,
        bytes32 r,
        bytes32 s,
        uint8 v
        ) external {
        
        orderCount = orderCount + 1;
        userData storage _userData = Data[_msgSender()][orderCount];        
        address[] memory path = new address[](2);
        path[0] = address(_swapFromToken);
        path[1] = smartSwap.WETH();
        _userData._id = orderCount;
        _userData.swapFromToken = path[0];
        _userData.swapToToken = path[1];
        _userData.to = _to;
        _userData.caller = _msgSender();
        _userData.amountIn = _amountIn;
        _userData.path = [path[0], path[1]];
        _userData.time = block.timestamp;
        _userData.expectedTime = _timeOf;
        _userData.Hash = _hash;
        _userData.r = r;
        _userData.s = s;
        _userData.v = v;
        
        emit markOrder(
            _userData._id,
            _msgSender(),
            _to,
            address(_swapFromToken),
            path[1],
            _amountIn,
            _timeOf
        );
    }

    function setPeriodToSwapETHForTokens(
        IERC20 _swapToToken,
        address _to,
        uint256 _timeOf,
        bytes32 _hash,
        bytes32 r,
        bytes32 s,
        uint8 v
        ) external payable{
        
        orderCount = orderCount + 1;
        userData storage _userData = Data[_msgSender()][orderCount];        
        address[] memory path = new address[](2);
        path[0] = smartSwap.WETH();
        path[1] = address(_swapToToken);
        _userData._id = orderCount;
        _userData.swapFromToken = path[0];
        _userData.swapToToken = path[1];
        _userData.to = _to;
        _userData.caller = _msgSender();
        _userData.amountIn = msg.value;
        _userData.path = [path[0], path[1]];
        _userData.time = block.timestamp;
        _userData.expectedTime = _timeOf;
        _userData.Hash = _hash;
        _userData.r = r;
        _userData.s = s;
        _userData.v = v;
        
        emit markOrder(
            _userData._id,
            _msgSender(),
            _to,
            path[0],
            path[1],
            msg.value,
            _timeOf
        );
    }

    function cancelOrder(address _user, uint256 _id) public {
        userData memory _userData = Data[_user][_id]; 
        require(address(_userData.caller) == _msgSender());
        require(_userData._id == _id); // The order must exist
        orderCancelled[_id] = true;
        emit Cancel(
            _userData._id,
            _msgSender(), 
            _userData.swapFromToken, 
            _userData.swapToToken, 
            _userData.amountIn, 
            _userData.expectedTime, 
            block.timestamp
        );
    }


    function swapTokens(uint256 _id, address _user, bytes32 _hash, bytes32 r,  bytes32 s, uint8 v) external {
        require(permit[_msgSender()] == true, "Rigel's: Access denied");
        require(_id > 0 && _id <= orderCount, 'Error, wrong id');
        // require(!orderFilled[_id], 'Error, order already filled');
        require(!orderCancelled[_id], 'Error, order already cancelled');
        userData memory _userData = Data[_user][_id]; 
        address rUser = recover_With_rsv(_userData.caller, _hash, v, r, s);
        rigelToken.transferFrom(rUser, address(this), fee);
        require(rUser == _user, "Invalid user address....");
        address swapToken = _userData.swapFromToken;
        IERC20(swapToken).approve(address(smartSwap), _userData.amountIn);
        
        uint256[] memory outputAmount = smartSwap.getAmountsOut(
            _userData.amountIn,
            _userData.path
        );
        if(_userData.path[1] == smartSwap.WETH()) {
            require(IERC20(_userData.swapFromToken).transferFrom(rUser, address(this), _userData.amountIn));
            smartSwap.swapExactTokensForETH(
                _userData.amountIn,
                outputAmount[1],
                _userData.path,
                _userData.to,
                block.timestamp + 1200
            );
        }
        if(_userData.path[0] == smartSwap.WETH()) {
            smartSwap.swapExactETHForTokens{value: _userData.amountIn}(
                outputAmount[1],
                _userData.path,
                _userData.to,
                block.timestamp + 1200
            );
        } else {            
            require(IERC20(_userData.swapFromToken).transferFrom(rUser, address(this), _userData.amountIn));
            smartSwap.swapExactTokensForTokens(
                _userData.amountIn,
                outputAmount[1],
                _userData.path,
                _userData.to,
                block.timestamp + 1200
            );
        }
        
        // orderFilled[_userData._id] = true;
        emit fulfilOrder(
            _userData._id,
            _msgSender(),
            _userData.to,
            _userData.swapFromToken,
            _userData.swapToToken,
            _userData.amountIn,
            _userData.time,
            block.timestamp
        );
    }

    function withdrawToken(address _token, address _user, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_user, _amount);
    }

    function withdrawETH(address _user, uint256 _amount) external onlyOwner {
        payable(_user).transfer(_amount);
    }

    function getUserData(address _user, uint256 _id) external view 
        returns(
        uint256 id,
        uint256 amountIn,
        uint256 time,
        uint256 expectedTime,
        address swapFromToken,
        address swapToToken,
        address to,
        address caller,
        address[] memory path) {
        userData memory _userData = Data[_user][_id];
        return(
        _userData._id,
        _userData.amountIn,
        _userData.time,
        _userData.expectedTime,
        _userData.swapFromToken,
        _userData.swapToToken,
        _userData.to,
        _userData.caller,
        _userData.path
        );
    }

    function recover_With_rsv(
        address caller,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public pure returns (address) {
        address recoveredAddress = ECDSA.recover(_hash, _v, _r, _s);
        require(recoveredAddress != address(0) && recoveredAddress == caller, 'Rigels Exchange: INVALID_SIGNATURE');
        return recoveredAddress;
    }

}
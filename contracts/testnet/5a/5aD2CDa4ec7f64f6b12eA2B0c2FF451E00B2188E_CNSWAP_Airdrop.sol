/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
// By PandaEver
pragma solidity >=0.8.15 <0.9.0;
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
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
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }
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
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
        _status = _NOT_ENTERED;
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function initialize(address, address, uint256) external;
}
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
contract CNSWAP_Airdrop is ReentrancyGuard {
    using ECDSA for bytes32;
    address private signers;
    uint256 public nonces = 0;
    address public CNS;
    uint256 claimedcns;
    uint256 private claim;
    bool public NowAirdrop;
    mapping(address => bool) claimed;
    mapping(address => bool) whitelist;

    constructor(address _CNS, uint256 _claimamt){
        signers = msg.sender;
        whitelist[msg.sender] = true;
        CNS = _CNS;
        claim = _claimamt;
        NowAirdrop = false;
    }
    
    function isMessageValid(bytes memory _signature,uint256 nonce)
    private
    view
    returns (bool)
    {
    bytes32 messagehash = keccak256(
            abi.encodePacked(address(this), signers, nonce)
    );
    address signer = messagehash.toEthSignedMessageHash().recover(
        _signature
    );
    if (signers == signer) {
        return (true);
    } else {
        return (false);
    }
    }

    function TotalUnclaimedCNS() external view returns (uint) {
        IERC20 _token = IERC20(CNS);
        return _token.balanceOf(address(this));
    }

    function TotalclaimedCNS() external view returns (uint) {
        return claimedcns;
    }

    receive() external payable nonReentrant {
        require(NowAirdrop,"Airdrop Not Starting");
        require(msg.value > 0.0059 ether,"BNB Too Low");
        require(!claimed[msg.sender],"You already Claimed This Airdrop");
        IERC20 _token = IERC20(CNS);
        _token.transfer(msg.sender , claim);
        claimedcns = claimedcns + claim;
    }
    function removeUser(address _user, bytes memory sig) public {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        whitelist[_user] = false;
        nonces = nonces+1;
    }

    function changesigner(address _user, bytes memory sig) public {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        signers = _user;
        nonces = nonces+1;
    }
    function StartAirdrop(bytes memory sig) public {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        NowAirdrop = true;
        nonces = nonces+1;
    }

    function StopAirdrop(bytes memory sig) public {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        NowAirdrop = false;
        nonces = nonces+1;
    }

    function addUser(address _newuser, bytes memory sig) public {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        whitelist[_newuser] = true;
        nonces = nonces+1;
    }
    function WithdrawNotClaimedCNS(uint256 _amount, bytes memory sig) public nonReentrant {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        IERC20 _token = IERC20(CNS);
        _token.transfer(msg.sender , _amount);
    }

    function clearBNB(bytes memory sig) public nonReentrant {
        require(isMessageValid(sig, nonces),"Invalid Signature");
        require(whitelist[msg.sender], "Caller Is Not WhiteList");
        payable(signers).transfer(address(this).balance);
  }
}
/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/utils/Context.sol
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol
pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol
pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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
// File: @openzeppelin/contracts/utils/Address.sol
pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol
pragma solidity ^0.8.0;

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

    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {
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

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(
                vs,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            v := add(shr(255, vs), 27)
        }
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
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
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

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}

contract Share is Ownable { 

    using Strings for uint256;
    using ECDSA for bytes32;
    using SafeMath for uint256;

    mapping(address => uint) public balances;

    constructor() {}

    function deposit() public payable {
        
        balances[msg.sender] += msg.value;
    }

    function withdrawTeam() external onlyOwner {
        uint256 balance = address(this).balance;
        
        payable(0xd33226f11683E3Daf61401dc450A9e69d7c57c3f).transfer(
    (balance * 1185) / 10000
);
 payable(0x47EEF86c8483D2C27E45a1b782d0b25Bc6c5Cb02).transfer(
    (balance * 612) / 10000
);
 payable(0x9BAC40BA251f6989b573f1F6350aEBB8e15D8Eb4).transfer(
    (balance * 600) / 10000
);
 payable(0x666eaD4e3b944925419fE432CbD370aaeEe87816).transfer(
    (balance * 576) / 10000
);
 payable(0x43F7d4D1C9046D97dF03845eE7a3a45050a8761c).transfer(
    (balance * 411) / 10000
);
 payable(0x5731289fD861E363d37a62F5e862FDcef01D7C6B).transfer(
    (balance * 249) / 10000
);
 payable(0xf99f0DB77BCF96186414E30F0959b184b9601a04).transfer(
    (balance * 210) / 10000
);
 payable(0x092863BddB6AfF53e3DFCcAB97885BA7302fcb6D).transfer(
    (balance * 189) / 10000
);
 payable(0x567C3Cf5A14AA2E8a32589FE3eA38C6680756026).transfer(
    (balance * 150) / 10000
);
 payable(0x08193420d3553448a7363437745C5f30eCfaE51d).transfer(
    (balance * 147) / 10000
);
 payable(0xb752A092C915778Dc73A42Cfd8e527D3203FC265).transfer(
    (balance * 144) / 10000
);
 payable(0xC93B7EA48Aa886D73514C9f67Bb27729D87673DD).transfer(
    (balance * 129) / 10000
);
 payable(0x92BdeDd70b84731D801b1e5F7C8eA6128811B8e6).transfer(
    (balance * 123) / 10000
);
 payable(0x9c09D85371177A4A5488C50F887ed6c8e73eAf31).transfer(
    (balance * 120) / 10000
);
 payable(0x4010D298C4C472670b72c87dc5b0495Be11a8d3B).transfer(
    (balance * 117) / 10000
);
 payable(0x000a22cdB94eFBB7260aD038E1b2d377D950ED78).transfer(
    (balance * 114) / 10000
);
 payable(0xAb6B8BD1e8e0Da1eAbcD517FaABbe9356488ed72).transfer(
    (balance * 111) / 10000
);
 payable(0xDDd99beca9F7DAA4BDa89117259C9D3584f31E0a).transfer(
    (balance * 105) / 10000
);
 payable(0x89F58481E63AbefFAD28999098a537FF380B0302).transfer(
    (balance * 102) / 10000
);
 payable(0xE4313a0E24789f4D4e060c58368e8f10CA5B32Ec).transfer(
    (balance * 102) / 10000
);
 payable(0xeF580E659e85D96D51162CCD75073BDEd01DF7ec).transfer(
    (balance * 102) / 10000
);
 payable(0x7235A309688Dfb3A9dAd5A63Fe8bEeF020033A18).transfer(
    (balance * 84) / 10000
);
 payable(0xa2045CC3096C9a12E8bC52A0967012210483c2D8).transfer(
    (balance * 84) / 10000
);
 payable(0xFf7fA027982e4a4406263FC860d86eA763dd047b).transfer(
    (balance * 81) / 10000
);
 payable(0xaFd164d218a00C04A3d3b6b5ce2F22Db7F1d26A8).transfer(
    (balance * 75) / 10000
);
 payable(0x34c7ce7D64F6FF24297862954Bc23B87187044C7).transfer(
    (balance * 72) / 10000
);
 payable(0xaa56C9DB129Bd2ef0453DC3F981263772d842bac).transfer(
    (balance * 72) / 10000
);
 payable(0x7A4F5c9CaB7924C8d159C913e26F1b3DA52F70e8).transfer(
    (balance * 69) / 10000
);
 payable(0x9794B5d52a83ED0fB30bE498c9D0e9D038a734c8).transfer(
    (balance * 69) / 10000
);
 payable(0xD54589B97Be02753d37439265F6D4cC2b7C2E53F).transfer(
    (balance * 69) / 10000
);
 payable(0xf68F4429C559C6081F1dF4583433F37fDF20091F).transfer(
    (balance * 66) / 10000
);
 payable(0x3fA496c63149bcb5Bc9E04F4aC91A4EEd563cD90).transfer(
    (balance * 63) / 10000
);
 payable(0x0Fc0F78fc939606db65F5BBF2F3715262C0b2F6E).transfer(
    (balance * 60) / 10000
);
 payable(0x3281d8f4d78C89Ad8312D001d9d07949CC606E7d).transfer(
    (balance * 60) / 10000
);
 payable(0x44b26127560577a49572020eB98D47C365167A65).transfer(
    (balance * 60) / 10000
);
 payable(0x779357013550e61Bcda605bd0D11cB292e0978E7).transfer(
    (balance * 60) / 10000
);
 payable(0x65D6cB1Fa7633Fc221402d59B4Ae838FC2419602).transfer(
    (balance * 57) / 10000
);
 payable(0xDa4D057d24327135ee73323a966c4aD3aAc1b518).transfer(
    (balance * 57) / 10000
);
 payable(0x8dB21c3F4EFb3D70CDe3A9764Bbd39D8c6bdf9fC).transfer(
    (balance * 54) / 10000
);
 payable(0xf912555b4C5d6bF8b92812B6e243B492275738AB).transfer(
    (balance * 54) / 10000
);
 payable(0x03EbAc2D81A569a024c7D72b27aa25297184ac96).transfer(
    (balance * 51) / 10000
);
 payable(0x3039DF7971bd2a05968CA43f725deFCf9B3F5550).transfer(
    (balance * 51) / 10000
);
 payable(0x481fE4b0A413ddaC0e0e19f1a7C416fe28AF670e).transfer(
    (balance * 51) / 10000
);
 payable(0x65B9145441233AB52aEA9865Df87F351812dd1Df).transfer(
    (balance * 51) / 10000
);
 payable(0x9F5B79f19f40168564Bd1E42DF369a136FEcF2e7).transfer(
    (balance * 51) / 10000
);
 payable(0xa42Fc3EE219984315e2B3D71BA9e157Baf5cD24c).transfer(
    (balance * 51) / 10000
);
 payable(0xED0eccdDF45fe869e06DFE89B995BEa54168BF9D).transfer(
    (balance * 51) / 10000
);
 payable(0xBF67727E3aB131999dB19567A235f64bA3f32eBC).transfer(
    (balance * 48) / 10000
);
 payable(0x02E8529Af60FAede58211B0c1b448ec8992628Ea).transfer(
    (balance * 45) / 10000
);
 payable(0x472eB4F87E4Fed1d85A502E999A413144D041DAa).transfer(
    (balance * 45) / 10000
);
 payable(0x5d33ca97efc658000335260a2E2EE0Dd2986F85b).transfer(
    (balance * 45) / 10000
);
 payable(0x879F73da71721AB76E82169D5b40697BB1E8263D).transfer(
    (balance * 45) / 10000
);
 payable(0xab77380FF5826D416b7Ac41B91978A27604B2156).transfer(
    (balance * 45) / 10000
);
 payable(0xb9cF399bA8aD7e3980B0C46e83620B2F3b4EAf9E).transfer(
    (balance * 45) / 10000
);
 payable(0xc6AA674b503fF5F95f08a2B9d3e5cF39882e9309).transfer(
    (balance * 45) / 10000
);
 payable(0x5533276f171766fD9eF4C82A2858f7B26bb0bE40).transfer(
    (balance * 42) / 10000
);
 payable(0xc99D3788cE0a61BdC867414EBf455951F244F6dC).transfer(
    (balance * 42) / 10000
);
 payable(0xf49Ac47fAf8D6845CAa0E4361fb5223A1b1966FA).transfer(
    (balance * 42) / 10000
);
 payable(0x603bbE496b3f3a8c664CFA06E99B64C2476aaD94).transfer(
    (balance * 39) / 10000
);
 payable(0x648B9D83B819B9bB9e0Db65719A0b93B840A9240).transfer(
    (balance * 39) / 10000
);
 payable(0x8160aCEF7bf0b0ACf9042Dae5512B67780D03dB6).transfer(
    (balance * 39) / 10000
);
 payable(0x8f56004b94B78C820573887eC8ad50A396C36F58).transfer(
    (balance * 39) / 10000
);
 payable(0x9BD872FFCacB23C4caef0643262D2A73F81CB911).transfer(
    (balance * 39) / 10000
);
 payable(0xB47c879395184cC415D0aBB95D877aa39b1c4942).transfer(
    (balance * 39) / 10000
);
 payable(0x5Aa129064F25b511fd93D075BaC05beF39e072FF).transfer(
    (balance * 36) / 10000
);
 payable(0x97f96217b2aBDb5ac55097148C6BC8E1d552d4E2).transfer(
    (balance * 36) / 10000
);
 payable(0x99ddCB20Ae6183f5527924D3c9d27b23eB9E1712).transfer(
    (balance * 36) / 10000
);
 payable(0xA980C6232966Df9E41AEc81A2bc9eBbE1f979B83).transfer(
    (balance * 36) / 10000
);
 payable(0xd5988138A1aca5217b327d25DDCF770e65458c66).transfer(
    (balance * 36) / 10000
);
 payable(0x0cB11cB7428A768FAa014E0Bac43Bc89E0ce99d7).transfer(
    (balance * 33) / 10000
);
 payable(0x56280AbB4EF69e16112f38ce5C9C67c753eF7D08).transfer(
    (balance * 33) / 10000
);
 payable(0x92d09850b3b8545e4f760c1074Cacc319cd0b78A).transfer(
    (balance * 33) / 10000
);
 payable(0x1306204c5d8BC802c705CBEA06F9e4Db1f9a9034).transfer(
    (balance * 30) / 10000
);
 payable(0x57faD15c5A48bbc7cd1eD0C588A8a0A04c8c97FF).transfer(
    (balance * 30) / 10000
);
 payable(0x8C152707BB131D0fd50f875F5F267152a992075D).transfer(
    (balance * 30) / 10000
);
 payable(0x9766557ef639FE3e1Ff43e137010542044618a51).transfer(
    (balance * 30) / 10000
);
 payable(0xa8354C3fD9C8e59c0235D730b2F8998012FEe7Ab).transfer(
    (balance * 30) / 10000
);
 payable(0xC5461114DcF9ac716bBf23AfF8a41212A35fD858).transfer(
    (balance * 30) / 10000
);
 payable(0xd6f64c02c14Ac390bf5f772de6CD590f9412bD1C).transfer(
    (balance * 30) / 10000
);
 payable(0xfb269Cc90e2032030c6bdA357A73f06Eb1c38f80).transfer(
    (balance * 30) / 10000
);
 payable(0xffBD62CB73cAfd1c70e4000123f47414d6073665).transfer(
    (balance * 30) / 10000
);
 payable(0x37C4A3a7F662A4fd4c1478DAE65F6Ff024Ebf592).transfer(
    (balance * 27) / 10000
);
 payable(0x4f4cE3725847DC91Ba5A0A3116E64f51618010d3).transfer(
    (balance * 27) / 10000
);
 payable(0x67ef3D980e1e15c66E82df329F8eA21C319325a0).transfer(
    (balance * 27) / 10000
);
 payable(0xCC0716988428c3b68EF5F62d359AA2B793D64509).transfer(
    (balance * 27) / 10000
);
 payable(0x341A57B3c8D194616964bA330EFCE13ec04f0a2F).transfer(
    (balance * 24) / 10000
);
 payable(0x8999798C74f912b313FBB007042b6278216e21D5).transfer(
    (balance * 24) / 10000
);
 payable(0xF6D64C3f1d48dc73b179DEb8b29D3EB9BF4A68d0).transfer(
    (balance * 24) / 10000
);
 payable(0x0B594Ef7f8E541F8da27e837F723EB6F15Bd3BaC).transfer(
    (balance * 21) / 10000
);
 payable(0x2d0500efF149DAB218442abC8E82baE15AF4E7c6).transfer(
    (balance * 21) / 10000
);
 payable(0x857bbdD83a7ad32F3A4B2E0f82b902d95C9e1b00).transfer(
    (balance * 21) / 10000
);
 payable(0xA74e9C99aaD81EcA2632a642355cc3E6E87402Af).transfer(
    (balance * 21) / 10000
);
 payable(0xaA458b0795f6268b5963106892E9d0977D70Cf37).transfer(
    (balance * 21) / 10000
);
 payable(0xb8948940084EeE300E71B890a6Bb931D2Fa3B4f7).transfer(
    (balance * 21) / 10000
);
 payable(0xBF52eb60F6AC354d5566b58cdA7CFc3ca0E62464).transfer(
    (balance * 21) / 10000
);
 payable(0xF072Eb58edd265EcF5d1b29b0F6FFA9785dBc92b).transfer(
    (balance * 21) / 10000
);
 payable(0x37F36b286BF32907d16CED50C587d470D3D3fC20).transfer(
    (balance * 18) / 10000
);
 payable(0x9D0c2c8e588Efc77605d8ee8cF27d3173AAD3145).transfer(
    (balance * 18) / 10000
);
 payable(0xE216ebD5A074eEc9eA777A47e3f4187A5f4b43E8).transfer(
    (balance * 18) / 10000
);
 payable(0x091b1A5d8966296C3c292783450e9eC4C84116dA).transfer(
    (balance * 15) / 10000
);
 payable(0x0D20487D8DBDd72Ca91411110b897D9D3B5c8e7D).transfer(
    (balance * 15) / 10000
);
 payable(0x0e559fdBf4a6E2c10dCB284DEe2F094ec50dB5b3).transfer(
    (balance * 15) / 10000
);
 payable(0x1A2E916b6547d77FAFeF6A231230c705d9e25d4C).transfer(
    (balance * 15) / 10000
);
 payable(0x1ec91503cD52bcD20930Ae8788A7db86b932ff26).transfer(
    (balance * 15) / 10000
);
 payable(0x27ee28301f455AD1532F78d3C075Dd826f872176).transfer(
    (balance * 15) / 10000
);
 payable(0x29C3A51d50D1602766231A701CED6271ee1A1cC2).transfer(
    (balance * 15) / 10000
);
 payable(0x2BD4579690ef84522E2fdCa2db54bF9FEF4cA632).transfer(
    (balance * 15) / 10000
);
 payable(0x49e056d7d0F68D343b4B2b398bd1C68C146fCe83).transfer(
    (balance * 15) / 10000
);
 payable(0x5D8b6FFC21D9b435E2ff9A87013D3B2EFcd6263e).transfer(
    (balance * 15) / 10000
);
 payable(0x5E0d0c14EE28957C48c68E4F4E0c449a03E6C1c1).transfer(
    (balance * 15) / 10000
);
 payable(0x5e68cccF94Fd7D34E767931573b2b883aC58942b).transfer(
    (balance * 15) / 10000
);
 payable(0x6444B7D9860441D9C7385507cEEfb29ce2Ae5be9).transfer(
    (balance * 15) / 10000
);
 payable(0x6c1cc9c0f32980Ead12373e5312EE046D00664bE).transfer(
    (balance * 15) / 10000
);
 payable(0x7aCd4f118Cae62569c3C6483E0626aC40A31376a).transfer(
    (balance * 15) / 10000
);
 payable(0xBf35014881DECE0F55b6352B22BfCFf7D0E81f05).transfer(
    (balance * 15) / 10000
);
 payable(0xbf5Ed636145cB07c0Fb77FC72970aAB7E577177C).transfer(
    (balance * 15) / 10000
);
 payable(0xC66452281C256a8548078Cc114acb18Cb9A007E5).transfer(
    (balance * 15) / 10000
);
 payable(0xcDbE2fAb33f3a0f4aaCF230571104366926D1Dce).transfer(
    (balance * 15) / 10000
);
 payable(0xd553daFfCcd7dc40FF6E4F058A636ff0589C6aA3).transfer(
    (balance * 15) / 10000
);
 payable(0xDc00E01c02Dc865ECd0280DEC90936a367b82bDF).transfer(
    (balance * 15) / 10000
);
 payable(0x1855c8F620580f0824BD8eA8E387aD9baCC20A49).transfer(
    (balance * 12) / 10000
);
 payable(0x1EbE7504825808A524c202D22aB6b3896ea6cAB3).transfer(
    (balance * 12) / 10000
);
 payable(0x31D6371e3A50f2C77f126D5D0157eaE94d88CC03).transfer(
    (balance * 12) / 10000
);
 payable(0x3971376Ef2fA3D7245eE1E782c485a24B6AA3B90).transfer(
    (balance * 12) / 10000
);
 payable(0x610A8BDE1b3ffAd249FBc97839dd718E6640FDaf).transfer(
    (balance * 12) / 10000
);
 payable(0x6f2DfF7CDd43328ac9815c74A2dEF9196A4a4381).transfer(
    (balance * 12) / 10000
);
 payable(0xc87733782FdBF5267c1f77c85B5ff2D6762F5518).transfer(
    (balance * 12) / 10000
);
 payable(0xCe621E1Db598A3A60006F402D7530aF7F3ae737f).transfer(
    (balance * 12) / 10000
);
 payable(0xD14326692C72be629dFE7c01fE75cB61d57DB542).transfer(
    (balance * 12) / 10000
);
 payable(0xd9A7f27aa71b062568201eAfa8398e113673a93A).transfer(
    (balance * 12) / 10000
);
 payable(0xDA3194Af190e0847688a1a660C23aECEDa345f6A).transfer(
    (balance * 12) / 10000
);
 payable(0xDc965B763cF6EB5636344Bf771cd9E396A6EC8eD).transfer(
    (balance * 12) / 10000
);
 payable(0xeFbA6008c20dBc538081fDbc42B0D0C7E072D6F2).transfer(
    (balance * 12) / 10000
);
 payable(0xF81eaC8114265d98059bf21b0575dE4f55dFdd85).transfer(
    (balance * 12) / 10000
);
 payable(0xFab5C2ca77BC51e1A290F21A24ef3871182f41d4).transfer(
    (balance * 12) / 10000
);
 payable(0x199e024CD5eBB205c7A2EEBE4eBB33630D7b1d35).transfer(
    (balance * 9) / 10000
);
 payable(0x2b495104e7bDb9B19c580232368f7Bf51ff53944).transfer(
    (balance * 9) / 10000
);
 payable(0x40A30EB20c36E03772d8DA9021fbDB52D21E8900).transfer(
    (balance * 9) / 10000
);
 payable(0x77692d32f016D16b82383a4c0E23F351275c2505).transfer(
    (balance * 9) / 10000
);
 payable(0x82fF77d836738202418E8BF2B1625b23fA6c7898).transfer(
    (balance * 9) / 10000
);
 payable(0x87685244F2E4a2DB137351DA44a77022b9C65EE9).transfer(
    (balance * 9) / 10000
);
 payable(0xAE8C252FbA6de1Ec174C7432f422d5294e7099c4).transfer(
    (balance * 9) / 10000
);
 payable(0xb0e5B248095055c25b3dC478bffAAb39Ee959760).transfer(
    (balance * 9) / 10000
);
 payable(0xD105a0cD7fA1Ad4C9E3af25a0824F2E9aE081782).transfer(
    (balance * 9) / 10000
);
 payable(0xd2B83402191923688f318231b678312D382E2f61).transfer(
    (balance * 9) / 10000
);
 payable(0xDEf6b3E169192d5F025aF8F13413F7F3720B59e8).transfer(
    (balance * 9) / 10000
);
 payable(0xDf00006dF7d6B007289Cb6DD174498219FdfaFA9).transfer(
    (balance * 9) / 10000
);
 payable(0xe35429A0dB78C6c016A08a393646fDE3b5c7e863).transfer(
    (balance * 9) / 10000
);
 payable(0xE59B939d1f16Ac0575E370Fc1b699081fA88b043).transfer(
    (balance * 9) / 10000
);
 payable(0xF605C10A4d9Ae1B6c35fe5601A10775Ba8Bf27a0).transfer(
    (balance * 9) / 10000
);
 payable(0xF708c0ddD6291A5ac05698120a51f9E1BdB81c8a).transfer(
    (balance * 9) / 10000
);

    }
 }
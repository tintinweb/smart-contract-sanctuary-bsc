/**
 *Submitted for verification at BscScan.com on 2022-05-07
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

contract SmallShare is Ownable { 

    using Strings for uint256;
    using ECDSA for bytes32;
    using SafeMath for uint256;

    mapping(address => uint) public balances;

    constructor() {}

    function deposit() public payable {
        
        balances[msg.sender] += msg.value;
    }

    function reward() external onlyOwner {
        uint256 balance = address(this).balance;
        


payable(0x11785D9a0A18196A65700422Bc0AcF257d6317d4).transfer(
    (balance * 6) / 465
);
 payable(0x1eC2a5Ca4D34D601c4936Fc440a422F6C214930c).transfer(
    (balance * 6) / 465
);
 payable(0x240efCC2cEabeB1913aB9Bac3Fb7E20a871eD6B6).transfer(
    (balance * 6) / 465
);
 payable(0x26a3aFe670af7F21Ac376643DE9CCe77dceD4696).transfer(
    (balance * 6) / 465
);
 payable(0x4B3E362704468C78D37CA1A89d6B45d037B35904).transfer(
    (balance * 6) / 465
);
 payable(0x507ac9EBd29828eB7F34e304BAde3930f3dE5D96).transfer(
    (balance * 6) / 465
);
 payable(0x563749C5026BB6CBCbAb96AaC22952a753cC58C2).transfer(
    (balance * 6) / 465
);
 payable(0x5Db45a8979852158D7B328b2688fc4B1af0f6880).transfer(
    (balance * 6) / 465
);
 payable(0x67011010B5193f26c0EE1ffd8262c14420115223).transfer(
    (balance * 6) / 465
);
 payable(0x6D23904c8dE6beF95952F8E4BF7b7f659eA2A2Ee).transfer(
    (balance * 6) / 465
);
 payable(0x7041Ec2720F4900b06d9E87F0468A18dD38D9626).transfer(
    (balance * 6) / 465
);
 payable(0x7884331418De162e95bc63405759bb153819e19e).transfer(
    (balance * 6) / 465
);
 payable(0x83D15a3280163bffe29496cB85A281e4Da4193a3).transfer(
    (balance * 6) / 465
);
 payable(0x8E36f624F6DCb935343366eCC1Dc3977995E7f82).transfer(
    (balance * 6) / 465
);
 payable(0x96575EC0aC710ABdE2C3d500bBFFc4A0E63f582b).transfer(
    (balance * 6) / 465
);
 payable(0x9a180ED252BfCb9C20B437cd2fAAa74d88ac9105).transfer(
    (balance * 6) / 465
);
 payable(0x9A206564Cd30811ca5E45e322af62f1033472Ee0).transfer(
    (balance * 6) / 465
);
 payable(0x9Beba0d0F2cB869984fDA0549c626223743FE591).transfer(
    (balance * 6) / 465
);
 payable(0x9E3B8A08a752d04261a06A68e2717984e3f6C63B).transfer(
    (balance * 6) / 465
);
 payable(0xB47be7126009a70f4F304d4Fb8E342Bbc2fA10ce).transfer(
    (balance * 6) / 465
);
 payable(0xb87471A5ff7C491AB26f2529353A84Ff5E309a10).transfer(
    (balance * 6) / 465
);
 payable(0xb9D6783e7110cE208A2c24E897C5a3C722D7C45b).transfer(
    (balance * 6) / 465
);
 payable(0xBc6Da086a17eD0FC0AC6bbeeE7002e64Fed62F93).transfer(
    (balance * 6) / 465
);
 payable(0xBe5A1eeB0bFB7eF02AF870DF05e75013Bd016973).transfer(
    (balance * 6) / 465
);
 payable(0xCCC05b3e0EeB497061F55032FCD7093443046B0B).transfer(
    (balance * 6) / 465
);
 payable(0xD5CfB7698Ce58EAC3172B0B686307c1419c8281d).transfer(
    (balance * 6) / 465
);
 payable(0xe7f73c6fb4F5A9E349Cc498e9910c2b2322F915E).transfer(
    (balance * 6) / 465
);
 payable(0xF3566c8527178Ab2a3492EF0818FfF4cc7Bb8a40).transfer(
    (balance * 6) / 465
);
 payable(0x00Eba9840A1334d48b7E0253fe844232da179BfD).transfer(
    (balance * 3) / 465
);
 payable(0x011D6968ef78142646065145Cd504Ee42A842c7A).transfer(
    (balance * 3) / 465
);
 payable(0x04E02de18E66Ff727f76d1849E3D7C9ccCCf0B21).transfer(
    (balance * 3) / 465
);
 payable(0x062b0BDf05451BC8B16309cf883426b5e2a0809B).transfer(
    (balance * 3) / 465
);
 payable(0x07Ca3a3d6453c355be54F468bd2Fa8552339A429).transfer(
    (balance * 3) / 465
);
 payable(0x0a807101Adb6Ff3D6c9F44B5082d4955Da446759).transfer(
    (balance * 3) / 465
);
 payable(0x0ba82e7A9534491555cdD3C774314fB480d11D1A).transfer(
    (balance * 3) / 465
);
 payable(0x0d57194dc216dC773E033Ab77Fe7aE15264aF7f1).transfer(
    (balance * 3) / 465
);
 payable(0x0D90E5F1fA9A6060C550B9C5F1972428BFb70a46).transfer(
    (balance * 3) / 465
);
 payable(0x12a5a4c82DC7eDA7B90b1ad2b339e3059662D8aC).transfer(
    (balance * 3) / 465
);
 payable(0x13B18cb428FdF78c25FB6194DC041f8E5930DF89).transfer(
    (balance * 3) / 465
);
 payable(0x14f8Bcf16F38C1D477791Cc63CA327CbcAa8163e).transfer(
    (balance * 3) / 465
);
 payable(0x1Ed0c2113cDefA472d7841e0A21422d84d8F41Fa).transfer(
    (balance * 3) / 465
);
 payable(0x2191851F4D146C9dc8CCb03314E7f4248d3C9661).transfer(
    (balance * 3) / 465
);
 payable(0x2745E34e6Aa609916433Ce20346BBa1B66355a11).transfer(
    (balance * 3) / 465
);
 payable(0x286FaB6Eb474B0059D04F7441927431f5f389367).transfer(
    (balance * 3) / 465
);
 payable(0x2b369eFC8A704df4ddB93E7cc8AE24741378FF11).transfer(
    (balance * 3) / 465
);
 payable(0x2CC21d1bFdF6c336D10889386D8156E610971393).transfer(
    (balance * 3) / 465
);
 payable(0x2d0b5237b42C809A8B5E46a617FC45111c548d17).transfer(
    (balance * 3) / 465
);
 payable(0x2f64515a3bb0466F123cB94AFe1D6855c1D0aE8D).transfer(
    (balance * 3) / 465
);
 payable(0x37207241d6d4cA60d70d19F7B9b9E05958Ce499A).transfer(
    (balance * 3) / 465
);
 payable(0x3c62950886f5f9Ea804b72AC3c0B17Cfd1f8b15a).transfer(
    (balance * 3) / 465
);
 payable(0x3c66273076755C55132c3562a82ACeD6B47f3837).transfer(
    (balance * 3) / 465
);
 payable(0x3eC5DaFb15032C723be9378102623d32054555A7).transfer(
    (balance * 3) / 465
);
 payable(0x3Fa5b60E70689F04EFda31f23511668Ff391ac9A).transfer(
    (balance * 3) / 465
);
 payable(0x3ff6e09D274C5565084F32aFCd5410FdCd4509DB).transfer(
    (balance * 3) / 465
);
 payable(0x4682279713d5dE8fD372D1fb4D8805655EE3b871).transfer(
    (balance * 3) / 465
);
 payable(0x48aB1C7C172f3C3311baBF9c9F4F4782F41a02dE).transfer(
    (balance * 3) / 465
);
 payable(0x4c2d547796dE066F8466BD57E844AFE35649397B).transfer(
    (balance * 3) / 465
);
 payable(0x4dF03B1d1bda13A2f6F67a4A47F62F9F8b02e592).transfer(
    (balance * 3) / 465
);
 payable(0x50f1242EBC4a618FE76eC5DF5983E45d782D6D62).transfer(
    (balance * 3) / 465
);
 payable(0x51AE490Fca7Ce44FBaC07F5fdC5b88Dbfb979b9B).transfer(
    (balance * 3) / 465
);
 payable(0x53Ba862949A97FE68b5B1d14d6621CB389Dea8c6).transfer(
    (balance * 3) / 465
);
 payable(0x5904051c752744b61Aa6BCA24b0DE4F9F4d7406f).transfer(
    (balance * 3) / 465
);
 payable(0x5A1b23CE7Fec2E753082e4ce3A57523160D391D3).transfer(
    (balance * 3) / 465
);
 payable(0x5B85f8b79c62A1B7507EC45Ab5FF2B43e0ae0f42).transfer(
    (balance * 3) / 465
);
 payable(0x5B9D72bC3868A99B2cDe452E046600f24996332b).transfer(
    (balance * 3) / 465
);
 payable(0x6054AFef5c07d3f462b4de32171bF295baC5300B).transfer(
    (balance * 3) / 465
);
 payable(0x66CF656B41779390fA1d7cf2CB3a44D5f397AcE6).transfer(
    (balance * 3) / 465
);
 payable(0x67C579D0B42dfC96C9D4b5D26388dbD2888eEC97).transfer(
    (balance * 3) / 465
);
 payable(0x6E174b146129EabC2E07466E9bC216bd2a085EcB).transfer(
    (balance * 3) / 465
);
 payable(0x6Ffda1C030b01f3a17f85dCB20a5F62BA0068fE2).transfer(
    (balance * 3) / 465
);
 payable(0x7253EfB153aBA7DCAdD1D933C17d7C169f42CAdB).transfer(
    (balance * 3) / 465
);
 payable(0x74f8ef8f8d6283C5ef43bEC40967e5e7dBC4Fb42).transfer(
    (balance * 3) / 465
);
 payable(0x75c1bEfdaBA1098BdAB4aa2C4bbb60a382dD3877).transfer(
    (balance * 3) / 465
);
 payable(0x793ab608574F1fED1566a8bfCc9E4213C297Ede2).transfer(
    (balance * 3) / 465
);
 payable(0x7a0548553a810E5EA8011BC144185a94626507fb).transfer(
    (balance * 3) / 465
);
 payable(0x7a84E648C23445021B43EFf23e63AEF5b3d791d4).transfer(
    (balance * 3) / 465
);
 payable(0x82FD8A1423854ec4Dc2E8Ea3Ea3Ce5A8f075E991).transfer(
    (balance * 3) / 465
);
 payable(0x87a4a1BE347739B4e54aD8799057127eCc51eC9C).transfer(
    (balance * 3) / 465
);
 payable(0x8f594e4E1d79E20206b1e3343099059C85a0Da3b).transfer(
    (balance * 3) / 465
);
 payable(0x90971a354740A4D4cEfb7dF33ad3922E3B268f38).transfer(
    (balance * 3) / 465
);
 payable(0x94b69DF4863737505D69c0902D94CBEfdA91b3a4).transfer(
    (balance * 3) / 465
);
 payable(0x95d9f6c93Bc67195D5606bBB8b33e541b2f08b8b).transfer(
    (balance * 3) / 465
);
 payable(0x983683aEF94474b94Ff446bE82CB4863ac79Ca04).transfer(
    (balance * 3) / 465
);
 payable(0x9a908DB106003823B289c55D89faC14597e221D1).transfer(
    (balance * 3) / 465
);
 payable(0x9F6307020b607B74FD4875791e3EF7313dB0A6A9).transfer(
    (balance * 3) / 465
);
 payable(0xA15817772b2Fdca0ef3ba48BFBA9D7c142373236).transfer(
    (balance * 3) / 465
);
 payable(0xA2bad0587C8B6C45226569C7F059f1F43D0399b4).transfer(
    (balance * 3) / 465
);
 payable(0xa3F9B87f928EBdAdB97ff7098b853b49aC78563a).transfer(
    (balance * 3) / 465
);
 payable(0xa507Dec07C800E6619f22d70AED47bc137e3032f).transfer(
    (balance * 3) / 465
);
 payable(0xa578759755fC3Cb3C50896b6046AA91804f06a83).transfer(
    (balance * 3) / 465
);
 payable(0xA5965Ea6ada7e44B2ac53C761e27d5D6466081B3).transfer(
    (balance * 3) / 465
);
 payable(0xa6540681FE688179222FA8c96D96D2353106a7a3).transfer(
    (balance * 3) / 465
);
 payable(0xa7c9D2cbc40fF38Cc9Db4fb514b0984c56c2b33E).transfer(
    (balance * 3) / 465
);
 payable(0xa86dE1Ef739405B05C809cd7949bE52D67b9dFA1).transfer(
    (balance * 3) / 465
);
 payable(0xa8FaE6b4959B8bcB393d2d54fd168599e4DaAE1b).transfer(
    (balance * 3) / 465
);
 payable(0xaaf2DD3D2532A677C5D013A34cf11113471aAbCF).transfer(
    (balance * 3) / 465
);
 payable(0xaefC6205fb6fB4F02f10F90153c228359352586B).transfer(
    (balance * 3) / 465
);
 payable(0xb1656a0f76857f5B7c572f207A80cfDC08Bc5930).transfer(
    (balance * 3) / 465
);
 payable(0xB62762aFFe544789E542445376f5cBdc06b92fF9).transfer(
    (balance * 3) / 465
);
 payable(0xB9ce9c0d5203304c48e319C64e4C7e37BD20426D).transfer(
    (balance * 3) / 465
);
 payable(0xc2E56892a5c06e54A0681474dc95Ed7241Ec07C6).transfer(
    (balance * 3) / 465
);
 payable(0xC5b425dD91faC3e2eB1EC5ecF8830F9FE9F43503).transfer(
    (balance * 3) / 465
);
 payable(0xc8F7DbA6aA2183D29F6d4019Ecf1f66C10D24D5e).transfer(
    (balance * 3) / 465
);
 payable(0xcA8d771bb1b0A29DfD619AdF774CcF9832EB8BdF).transfer(
    (balance * 3) / 465
);
 payable(0xCD864aef97b8065ce24C0042A6A1d2E21b892B98).transfer(
    (balance * 3) / 465
);
 payable(0xd2511C6a77df383D7436BA9B544ef246B3D0F958).transfer(
    (balance * 3) / 465
);
 payable(0xD549EDF864ECA329DE01DBb010bCc1b2a13AE37e).transfer(
    (balance * 3) / 465
);
 payable(0xd7802884a341B5ca56691cb0E577D57D3fD29feB).transfer(
    (balance * 3) / 465
);
 payable(0xD7aABF5a049d186140e639870D93444430cb996e).transfer(
    (balance * 3) / 465
);
 payable(0xDA68310dBC334cB1Bd62f83Af5A2733F5C763988).transfer(
    (balance * 3) / 465
);
 payable(0xDa6CBd9B479d6168F078471eBa1bB4168b22d8d6).transfer(
    (balance * 3) / 465
);
 payable(0xDb8917cEdd167d4Aa2980caEEDf2483f893F1436).transfer(
    (balance * 3) / 465
);
 payable(0xE1A0A6dd280E750c08ecC441faE5F8d9e5c9ABCE).transfer(
    (balance * 3) / 465
);
 payable(0xe4873cCbd573e58A8cD33d2823170Ea908b7A2e8).transfer(
    (balance * 3) / 465
);
 payable(0xe8151d4E103186536aa1476a473Ad562a68e58eB).transfer(
    (balance * 3) / 465
);
 payable(0xe8B58080E1F81D03A6fC686346BDb03bB53f9782).transfer(
    (balance * 3) / 465
);
 payable(0xEbb6D57dB7ADB47616Dc4e4E3Ae29F10D41BBf1B).transfer(
    (balance * 3) / 465
);
 payable(0xecc71E03735F2a25a083C3c852ABE6CC69F580e9).transfer(
    (balance * 3) / 465
);
 payable(0xEe2005FA08174517139a53F91E83989dee4c724d).transfer(
    (balance * 3) / 465
);
 payable(0xEF667C250AeB276d7Ada9941fDa4f25EA0099D4A).transfer(
    (balance * 3) / 465
);
 payable(0xF57844c00cEEff1a68C3973d327273F746363B72).transfer(
    (balance * 3) / 465
);
 payable(0xf5C8c223c047d3208E51667926f723456704A942).transfer(
    (balance * 3) / 465
);
 payable(0xF876c6c2E42d5253090fA9d2ab5665fe5554F6C2).transfer(
    (balance * 3) / 465
);
 payable(0xF99F5De9b5284E995441815Fa297b5cA076a7c46).transfer(
    (balance * 3) / 465
);
 payable(0xFA4620e122659A9B90CF665D6399e80345994461).transfer(
    (balance * 3) / 465
);
 payable(0xfF758D4fc8E0624c1B284F2f6169D5b53D993CA7).transfer(
    (balance * 3) / 465
);
 payable(0xFfE8A9f36e597381Ce4052780102Bdba06Aa8914).transfer(
    (balance * 3) / 465
);




    }
 }
/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

contract Example {
    
    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Person {
        string name;
        address wallet;
    }

    struct Mail {
        Person from;
        Person to;
        string contents;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 constant PERSON_TYPEHASH = keccak256(
        "Person(string name,address wallet)"
    );

    bytes32 constant MAIL_TYPEHASH = keccak256(
        "Mail(Person from,Person to,string contents)Person(string name,address wallet)"
    );

    bytes32 public DOMAIN_SEPARATOR;

    constructor () {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "Ether Mail",
            version: '1',
            chainId: 1,
            // verifyingContract: this
            verifyingContract: 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
        }));

    }

    function hash(EIP712Domain memory eip712Domain) public pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract
        ));
    }

    function hash(Person memory person) public pure returns (bytes32) {
        return keccak256(abi.encode(
            PERSON_TYPEHASH,
            keccak256(bytes(person.name)),
            person.wallet
        ));
    }

    function hash(Mail memory mail) public pure returns (bytes32) {
        return keccak256(abi.encode(
            MAIL_TYPEHASH,
            hash(mail.from),
            hash(mail.to),
            keccak256(bytes(mail.contents))
        ));
    }

    function verify(Mail memory mail, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        // Note: we need to use `encodePacked` here instead of `encode`.
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));
        return ecrecover(digest, v, r, s) == mail.from.wallet;
    }

    function verify(Mail memory mail, bytes memory signature) public view returns (bool) {
        // Note: we need to use `encodePacked` here instead of `encode`.
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));
        (uint8 v, bytes32 r, bytes32 s) = parseSignature(signature);
        return ecrecover(digest, v, r, s) == mail.from.wallet;
    }


  function parseSignature(bytes memory signature)
        public
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            // solium-disable-line security/no-inline-assembly
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signature, 65)), 0xff)
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid v of signature(r, s, v)");
    }
    
    function test() public view returns (bool) {
        // Example signed message
        Mail memory mail = Mail({
            from: Person({
               name: "Cow",
               wallet: 0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826
            }),
            to: Person({
                name: "Bob",
                wallet: 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB
            }),
            contents: "Hello, Bob!"
        });
        uint8 v = 28;
        bytes32 r = 0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d;
        bytes32 s = 0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562;
        
        assert(DOMAIN_SEPARATOR == 0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f);
        assert(hash(mail) == 0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e);
        assert(verify(mail, v, r, s));
        return true;
    }
}
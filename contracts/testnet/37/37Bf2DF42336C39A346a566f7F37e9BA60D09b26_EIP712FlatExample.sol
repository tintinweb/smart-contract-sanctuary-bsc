pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract EIP712FlatExample {
    uint256 constant chainId = 5;  // for Goerli test net. Change it to suit your network.

    struct Unit {
        string actionType;
        uint256 timestamp;
        string authorizer;
    }
    /* if chainId is not a constant and instead dynamically initialized,
     * the hash calculation seems to be off and ecrecover() returns an unexpected signing address
    // uint256 internal chainId;
    // constructor(uint256 _chainId) public{
    //     chainId = _chainId;
    // }
    */

    // EIP-712 boilerplate begins
    event SignatureExtracted(address indexed signer, string action);

    string private constant EIP712_DOMAIN  = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    string private constant UNIT_TYPE = "Unit(string actionType,uint256 timestamp,string authorizer)";

    // type hashes. Hash of the following strings:
    // 1. EIP712 Domain separator.
    // 2. string describing identity type
    // 3. string describing message type (enclosed identity type description included in the string)

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 private constant UNIT_TYPEHASH = keccak256(abi.encodePacked(UNIT_TYPE));

    bytes32 private DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
        keccak256("VerifierApp101"),  // string name
        keccak256("1"),  // string version
        chainId,  // uint256 chainId
        0x8c1eD7e19abAa9f23c476dA86Dc1577F1Ef401f5  // address verifyingContract
    ));


     // functions to generate hash representation of the struct objects

    function hashUnit(Unit memory unitobj) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    UNIT_TYPEHASH,
                    keccak256(bytes(unitobj.actionType)),
                    unitobj.timestamp,
                    keccak256(bytes(unitobj.authorizer))
                ))
            ));
    }

    function submitProof(Unit memory _msg, bytes32 sigR, bytes32 sigS, uint8 sigV) public {
        address recovered_signer = ecrecover(hashUnit(_msg), sigV, sigR, sigS);
        emit SignatureExtracted(recovered_signer, _msg.actionType);

    }

    // this contains a pre-filled struct Unit and the signature values for the same struct calculated by sign.js
    function testVerify() public view returns (bool) {

        Unit memory _msgobj = Unit({
           actionType: 'Action7440',
           timestamp: 1570112162,
           authorizer: 'auth239430'
        });

        bytes32 sigR = 0x4f78289d9bf7592a29232169c39501c0bc17e48521a13141a3c7cf1c52da5839;
        bytes32 sigS = 0x75c106680c2ee584b425b7a92be9d72bc23d16e6ef68314e3f9c554720b7eb30;
        uint8 sigV = 27;

        address signer = 0x00EAd698A5C3c72D5a28429E9E6D6c076c086997;

        return signer == ecrecover(hashUnit(_msgobj), sigV, sigR, sigS);
    }
}
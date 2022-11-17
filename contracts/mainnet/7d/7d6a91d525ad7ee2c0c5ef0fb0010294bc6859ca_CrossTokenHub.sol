/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract CrossTokenHub {

    uint16 public constant CRA_CHAIN = 655;

    address public owner;
    address public admin;
    uint16  public chainid;

    struct Mirror {
        uint64 sequence;
        uint64 transferInCount;
        uint64 transferOutCount;
        address dstContractAddr;
        uint256 transferInAmounts;
        uint256 transferOutAmounts;
    }

    struct TransferOutPackage {
        address dstContractAddr;
        address recipient;
        uint256 amount;
    }

    mapping(bytes32 => TransferOutPackage) public transferOutPackages; // tid => TransferOutPackage
    mapping(bytes32 => bool) public processed; // tid => bool
    mapping(bytes32 => Mirror) public mirrors; // mid => Mirror

    event TransferOut(bytes32 tid, address indexed dstContractAddr, address indexed recipient, uint256 amount);
    event TransferIn(bytes32 tid, address indexed contractAddr, address indexed recipient, uint256 amount);

    uint256 public gift;
    mapping(address => bool) public sent;

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(owner == msg.sender || admin == msg.sender, "Caller is not the admin");
        _;
    }

    constructor() {
        owner = msg.sender;
        admin = msg.sender;
        if(block.chainid > 65535){
            chainid = 1000;
        }else{
            chainid = uint16(block.chainid);
        }
    }

    receive() external payable onlyAdmin {
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setAdmin(address newAdmin) public onlyOwner {
        admin = newAdmin;
    }

    function setGift(uint256 amount) public onlyOwner {
        gift = amount;
    }

    function addMirrorToken(address contractAddr, address dstContractAddr, uint16 dstChainId) public onlyOwner {
        bytes32 mid = encodeMirrorId(contractAddr, chainid, dstChainId);
        require(mirrors[mid].dstContractAddr == address(0), "Repeat binding");
        require(dstContractAddr != address(0) && dstChainId > 0, "Invalid params");
        mirrors[mid].dstContractAddr = dstContractAddr;
    }

    function delMirrorToken(address contractAddr, uint16 dstChainId) public onlyOwner {
        bytes32 mid = encodeMirrorId(contractAddr, chainid, dstChainId);
        require(mirrors[mid].dstContractAddr != address(0), "No mirror");
        mirrors[mid].dstContractAddr = address(0);
    }

    function transferOut(uint16 dstChainId, address contractAddr, uint amount) public {
        _transferOut(dstChainId, contractAddr, amount, msg.sender);
    }

    function _transferOut(uint16 dstChainId, address contractAddr, uint amount, address recipient) internal {
        bytes32 mid = encodeMirrorId(contractAddr, chainid, dstChainId);
        Mirror storage mirror = mirrors[mid];
        require(mirror.dstContractAddr != address(0), "No binding token");
        uint64 seq = mirror.sequence + 1;
        bytes32 tid = encodeTransferId(mid, seq);
        require(transferOutPackages[tid].amount == 0, "Invalid tid");
        mirror.sequence = seq;
        mirror.transferOutCount += 1;
        mirror.transferOutAmounts += amount;
        transferOutPackages[tid] = TransferOutPackage(mirror.dstContractAddr, recipient, amount);
        IERC20(contractAddr).transferFrom(recipient, address(this), amount);
        // if(chainid == CRA_CHAIN){
        //     IERC20(contractAddr).burn(recipient, amount);
        // }else{
        //     IERC20(contractAddr).transferFrom(recipient, address(this), amount);
        // }
        emit TransferOut(tid, mirror.dstContractAddr, recipient, amount);
    }

    function transferIn(bytes32 tid, address contractAddr, address payable recipient, uint256 amount) public onlyOwner {
        _transferIn(tid, contractAddr, recipient, amount);
    }

    function _transferIn(bytes32 tid, address contractAddr, address payable recipient, uint256 amount) internal {
        address srcContractAddr;
        uint16 srcChainId;
        uint16 dstChainId;
        uint64 seq;
        (srcContractAddr, srcChainId, dstChainId, seq) = decodeTransferId(tid);
        require(dstChainId == chainid, "Invalid chain id");
        require(seq > 0 && !processed[tid], "The transaction has been completed");
        bytes32 mid = encodeMirrorId(contractAddr, chainid, srcChainId);
        Mirror storage mirror = mirrors[mid];
        require(mirror.dstContractAddr == srcContractAddr, "No binding token");
        // Processe ...
        processed[tid] = true;
        mirror.transferInCount += 1;
        mirror.transferInAmounts += amount;
        if(chainid == CRA_CHAIN){
            IERC20(contractAddr).transfer(recipient, amount);
            // if(IERC20(contractAddr).balanceOf(address(this)) >= amount){
            //     IERC20(contractAddr).transfer(recipient, amount);
            // }else{
            //     IERC20(contractAddr).mint(recipient, amount);
            // }
            if(gift > 0 && address(this).balance >= gift && !sent[recipient]){
                sent[recipient] = true;
                recipient.transfer(gift);
            }
        }else{
            IERC20(contractAddr).transfer(recipient, amount);
        }
        emit TransferIn(tid, contractAddr, recipient, amount);
    }

    function claim(bytes32 tid, address contractAddr, uint amount, bytes memory signature) public {
        require(signature.length == 65);
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly{
            r:=mload(add(signature, 32))
            s:=mload(add(signature, 64))
            v:=byte(0,mload(add(signature, 96)))
        }
        bytes32 hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n104",
            tid, contractAddr, msg.sender, amount
        ));
        address signer = ecrecover(hash, v, r, s);
        require(signer == admin, 'Invalid signer');
        _transferIn(tid, contractAddr, payable(msg.sender), amount);
    }

    function encodeMirrorId(address contractAddr, uint16 srcChainId, uint16 dstChainId) public pure returns(bytes32 key){
        uint256 dstCid = uint256(dstChainId) * 2 ** 240;
        uint256 srcCid = uint256(srcChainId) * 2 ** 224;
        assembly{
            let addr := and(contractAddr, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            let tmp := or(dstCid, addr)
            key := or(srcCid, tmp)
        }
    }

    function encodeTransferId(bytes32 mirrorId, uint64 seq) public pure returns(bytes32 key){
        uint sid = uint256(seq) * 2 ** 160;
        assembly{
            key := or(mirrorId, sid)
        }
    }

    function decodeTransferId(bytes32 tid) public pure returns(address contractAddr, uint16 srcChainId, uint16 dstChainId, uint64 seq){
        uint256 dstCid;
        uint256 srcCid;
        uint256 seqTmp;
        assembly{
            dstCid := and(tid, 0xffff000000000000000000000000000000000000000000000000000000000000)
            srcCid := and(tid, 0x0000ffff00000000000000000000000000000000000000000000000000000000)
            seqTmp := and(tid, 0x00000000ffffffffffffffff0000000000000000000000000000000000000000)
            contractAddr := and(tid, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
        }
        dstChainId = uint16(dstCid / (2 ** 240));
        srcChainId = uint16(srcCid / (2 ** 224));
        seq = uint64(seqTmp / (2 ** 160));
    }

    function checkProcessed(uint64 seq, uint16 dstChainId, uint16 srcChainId, address contractAddr) public view returns(bool) {
        bytes32 mid = encodeMirrorId(contractAddr, srcChainId, dstChainId);
        bytes32 tid = encodeTransferId(mid, seq);
        return processed[tid];
    }

}
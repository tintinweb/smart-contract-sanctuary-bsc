/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
}
contract Withdraw is Auth {

    mapping(uint256 => bool) public txIdList;//订单ID是否存在
    //main 0x68F44Fd6fEF749c67fcc890faD4752bca7C1FE27, test 0xd9145CCE52D386f254917e481eB44e9943F39138
    address public gtAddress = 0x68F44Fd6fEF749c67fcc890faD4752bca7C1FE27;
    //main 0x83D0700ae6Eb514e7B968F6D886474E840920a62, test 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
    address public gssAddress = 0x83D0700ae6Eb514e7B968F6D886474E840920a62;
    //解密地址
    //私钥 96d21862ce7d0dd4b79e14be3acb863a915c0ab7c0fa8d07d0545d8ffe0344d0
    address decodeAddress = 0x540e79a0055f545FEA6E5F37e0607C3D429503bD;

    event WithdrawInfo(address indexed user,uint256 txId,uint256 withdrawNum,uint256 withdrawType);

    constructor() Auth(msg.sender){
        
    }

    function testSign(uint256 txId,uint256 withdrawNum,uint256 withdrawType,bytes memory signature) external view returns(bool){
        return verify(txId,withdrawNum,withdrawType,signature);
    }

    function withdrawDo(uint256 txId,uint256 withdrawNum,uint256 withdrawType,bytes memory signature) external{
        require(!txIdList[txId],"txId err");
        require(withdrawType == 2 || withdrawType == 3,"type err");
        require(verify(txId,withdrawNum,withdrawType,signature),"verify failed");
        IBEP20 tmpToken = IBEP20(gtAddress);
        if(withdrawType == 3){
            tmpToken = IBEP20(gssAddress);
        }
        require(withdrawNum <= tmpToken.balanceOf(address(this)) ,"Insufficient Balanace");
        require(tmpToken.transfer(msg.sender,withdrawNum), "Transfer failed");

        txIdList[txId] = true;
        emit WithdrawInfo(msg.sender, txId, withdrawNum, withdrawType);
    }


    function withdrawToken(address toAddress) external authorized{
        uint256 gtBalance = IBEP20(gtAddress).balanceOf(address(this));
        if(gtBalance > 0){
            IBEP20(gtAddress).transfer(toAddress,gtBalance);
        }
        
        uint256 gssBalance = IBEP20(gssAddress).balanceOf(address(this));
        if(gssBalance > 0){
            IBEP20(gssAddress).transfer(toAddress,gssBalance);
        }
        
    }
    function setGtAddress(address _new) external authorized{
        gtAddress = _new;
    }
    function setGssAddress(address _new) external authorized{
        gtAddress = _new;
    }
    
    function setDecodeAddress(address _new) external authorized{
        decodeAddress = _new;
    }
    
    //验证签名-start
    function getMessageHash(uint256 txId,uint256 withdrawNum,uint256 withdrawType) public pure returns (bytes32) {
        string memory txIdStr = uint2str(txId);
        string memory withdrawNumStr = uint2str(withdrawNum);
        string memory withdrawTypetStr = uint2str(withdrawType);
        string memory tmpStr = string(abi.encodePacked(txIdStr,withdrawNumStr, withdrawTypetStr));
        return keccak256(abi.encodePacked(tmpStr));
    }
    
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(uint256 txId,uint256 buyNum,uint256 gssUsdtAmount,bytes memory signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(txId,buyNum,gssUsdtAmount);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == decodeAddress;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) public pure returns (bytes32 r,bytes32 s,uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
    //验证签名-end
    function uint2str(uint value) internal pure returns (string memory _uintAsString) {
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
}
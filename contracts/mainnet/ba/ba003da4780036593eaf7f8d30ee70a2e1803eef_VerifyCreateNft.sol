/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract ERC721{
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
    function create(address creator,uint tokenId) external virtual;
}

abstract contract Panel{
    function isMember(address member) external virtual returns (bool flag);
    function isBlack(address member) external virtual returns (bool flag);
}

contract StringUtil {
    //==============================string工具函数==============================
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    function toString(address account) internal  pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) internal  pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) internal pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringToUint(string memory s) internal pure returns(uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for(uint i = 0; i < b.length; i++) {
            if(uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }


    function stringToBytes32(string memory source) internal pure returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }

}

contract Comn is StringUtil{
    address internal owner;
    bool _isRuning;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier isRuning(){
        require(_isRuning,"Modifier: Closed");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(){
        owner = msg.sender;
        _status = _NOT_ENTERED;
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract VerifyCreateNft is Comn{

    modifier isMember(){
        bool _isMember = Panel(panelContract).isMember(msg.sender);
        require(_isMember,"Modifier: Not a member");
        _;
    }

    modifier isBlack(){
        bool _isBlack = Panel(panelContract).isBlack(msg.sender);
        require(!_isBlack,"Modifier: No permission");
        _;
    }

    // 铸造验证
    function createVerify(address sender,string memory tokenIdStr,string memory seed, bytes32 _r, bytes32 _s,uint8 _v) external isRuning isMember isBlack nonReentrant  returns(bytes memory signaturn){
        if(msg.sender != sender){ _status = _NOT_ENTERED; revert("Verify : caller error"); }

        signaturn = getSignaturn(_r,_s,_v);
        if(signatrueMap[signaturn]){ _status = _NOT_ENTERED; revert("Verify : signatrue used"); }

        string memory senderStr = toString(sender);
        bytes32 _hashedMessage = keccak256(abi.encodePacked(senderStr,tokenIdStr,seed));
        address signer = verifyMessage(_hashedMessage,_v,_r,_s);
        if(signer != signerAddr){ _status = _NOT_ENTERED; revert("Verify : signer error"); }
        uint tokenId = stringToUint(tokenIdStr);
        createNft(sender,tokenId,signaturn);
    }

    //铸造NFT
    function createNft(address sender,uint tokenId,bytes memory signaturn) private{
        ERC721(targetContract).create(sender,tokenId);
        signatrueMap[signaturn] = true;
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function getSignaturn(bytes32 _r, bytes32 _s,uint8 _v) public pure returns(bytes memory signaturn){
        signaturn = abi.encodePacked(_r,_s,_v);
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    address private panelContract;                                  //面板合约
    address private signerAddr;                                     //[设置]  签署权地址
    address private targetContract;                                 //[设置]  目标合约
    mapping(bytes => bool) private signatrueMap;                    //使用情况

    /*
     * @param _panelContract 面板合约
     * @param _extractSigner 提取签署合约
     * @param targetContract 目标合约
     */
    function setConfig(address _panelContract,address _signerAddr,address _targetContract) public onlyOwner {
        panelContract = _panelContract;
        signerAddr = _signerAddr;
        targetContract = _targetContract;
    }

    function setPanelContract(address _panelContract) external onlyOwner {
        panelContract = _panelContract;
    }
    
    function setSignerAddr(address _signerAddr) external onlyOwner {
        signerAddr = _signerAddr;
    }

    function setTargetContract(address _targetContract) external onlyOwner {
        targetContract = _targetContract;
    }

    function getSignerAddr() external view returns (address _signerAddr){
        _signerAddr = signerAddr;
    }

    function getTargetContract() external view returns (address _targetContract){
        _targetContract = targetContract;
    }

    function setSignatrueMap(bytes32 _r, bytes32 _s,uint8 _v) external onlyOwner{
        signatrueMap[getSignaturn(_r,_s,_v)] = true;
    }

    function getSignatrueMap(bytes32 _r, bytes32 _s,uint8 _v) external view returns (bool flag){
        flag = signatrueMap[getSignaturn(_r,_s,_v)];
    }

}
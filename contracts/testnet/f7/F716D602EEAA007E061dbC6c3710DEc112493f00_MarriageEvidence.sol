pragma solidity^0.8.0;
import "./EvidenceFactory.sol";
import "./Character.sol";

contract MarriageEvidence is Character{
    address admin;
    address eviContractAddress;
    address eviAddress;
    constructor() Character() public {
        admin = msg.sender;
    }
    
    modifier adminOnly{  
        require(msg.sender == admin ,"require admin");
        _;
    }
    
    modifier charactersMustBeAddedFirst{
        require(getAllCharater().length != 0,"It is null");
        _;
    }
    
    modifier signersOnly{
        require(EvidenceFactory(eviContractAddress).verify(msg.sender),"you not is signer");
        _;
    }
    function deployEvi(string calldata _summary) external adminOnly charactersMustBeAddedFirst{
 
        addCharacter(msg.sender,_summary);
        EvidenceFactory evi = new EvidenceFactory(getAllCharater());
        eviContractAddress = address(evi); 
    }
    
    function getSigners() public view returns(address[] memory){
        return EvidenceFactory(eviContractAddress).getSigners();
    }
    
    function newEvi(string calldata _evi)public adminOnly returns(address){
        eviAddress = EvidenceFactory(eviContractAddress).newEvidence(_evi);
        return eviAddress;
    }
    
    function sign() public signersOnly returns(bool) {
            return EvidenceFactory(eviContractAddress).addSignatures(eviAddress);
    }
    function getEvi() public returns(string memory,address[] memory,address[] memory){
            return EvidenceFactory(eviContractAddress).getEvidence(eviAddress);
    }
}

pragma solidity ^0.8.0;
import "./Evidence.sol";

contract EvidenceFactory{
        address[] signers;  //存储签名者地址
		event newEvidenceEvent(address addr); //新签证事件，返回地址
		//传入签名内容 string类型，创建合约Evidence并初始化
        function newEvidence(string memory evi)public returns(address)
        {
            //this:代表当前工厂合约的地址
            Evidence evidence = new Evidence(evi, address(this));
            emit newEvidenceEvent(address(evidence));
            return address(evidence);
        }
        //获得签证信息
        function getEvidence(address addr) public returns(string memory,address[] memory,address[] memory){
            return Evidence(addr).getEvidence();
        }
        
                
        function addSignatures(address addr) public returns(bool) {
            return Evidence(addr).addSignatures();
        }
        //初始化合约，导入签名者们的地址（数组传参）为合法签名者地址
        //只有合法签名者才有资格进行签证
        constructor(address[] memory evidenceSigners){
            for(uint i=0; i<evidenceSigners.length; ++i) {
            signers.push(evidenceSigners[i]);
			}
		}
        // 验证身份是否为合法签名者地址
        function verify(address addr)public view returns(bool){
                for(uint i=0; i<signers.length; ++i) {
                if (addr == signers[i])
                {
                    return true;
                }
            }
            return false;
        }
        //根据索引值返回合约签名者地址
        function getSigner(uint index)public view returns(address){
            uint listSize = signers.length;
            //判断索引值是否越界
            if(index < listSize)
            {
                return signers[index];
            }
            else
            {
                return address(0);
            }
    
        }
        //获取当前合约签名者人数
        function getSignersSize() public view returns(uint){
            return signers.length;
        }
        //返回所有合约签名者的地址
        function getSigners() public view returns(address[] memory){
            return signers;
        }

}

pragma solidity^0.8.0;

import "./Roles.sol";

contract Character{
    using Roles for Roles.Role;
    Roles.Role private _character;
    
    event characterAdded(address amount,string summary);
    event characterRemoved(address amount);
    event characterRevised(address amount,string summary);
    event characterSeeked(address amount);
    
    address owner;
    address[] characters;
    
    
    constructor()public{
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender,"Only owner can call");
        _;
    }
    
    function isCharacter(address amount)public view returns(bool){
        return _character.has(amount);
    }
    
    function _addCharacter(address amount,string calldata _summary)internal{
        _character.add(amount,_summary);
        characters.push(amount);
        emit characterAdded(amount,_summary);
    }
    
    function _removeCharacter(address amount)internal{
        _character.remove(amount);
        emit characterRemoved(amount);
    }
    
    function _reviseCharacter(address amount,string calldata _summary)internal{
        _character.revise(amount,_summary);
        emit characterRevised(amount,_summary);
    }
    
    function _seekCharacter(address amount)internal view returns(string memory){
        return _character.seek(amount);
        //emit characterSeeked(amount);
    }
    
    function _removeCharacterByAddress(address amount)internal{
        for (uint i = 0; i < characters.length; i++) {
                if (amount == characters[i]){
                    for (uint j = i; j < characters.length-1; j++) {
                        characters[j] = characters[j+1];
                    }
                }
                //characters.length--;
        }
    }   
    
    function addCharacter(address amount,string calldata _summary)public onlyOwner{
        require(!isCharacter(amount),"The character already exist");
        _addCharacter(amount,_summary);
    }
    
    function removeCharacter(address amount)public onlyOwner{
        require(isCharacter(amount),"The character does not exist");
        _removeCharacter(amount);
        _removeCharacterByAddress(amount);
    }
    
    function reviseCharacter(address amount,string calldata _summary)public onlyOwner{
        require(isCharacter(amount),"The character does not exist");
        _reviseCharacter(amount,_summary);
    }
    
    function seekCharacter(address amount)public view returns(string memory) {
        require(isCharacter(amount),"The character does not exist");
        return _seekCharacter(amount);
    }
    
    function getAllCharater()public view returns(address[] memory){
        return characters;
    }
    
}

pragma solidity ^0.8.0;

contract EvidenceSignersDataABI
{
    //验证是否是合法地址
	function verify(address addr)public view returns(bool){}
	//根据索引值返回签名者地址
	function getSigner(uint index)public  returns(address){} 
	//返回签名人数
	function getSignersSize() public  returns(uint){}
}

contract Evidence{
    
    string evidence; //存证信息
    address[] signers;//储存合法签名者地址
    address public factoryAddr;//工厂合约地址
    //返回事件信息，查看log->判断正确或错误的信息
    event addSignaturesEvent(string evi);
    event newSignaturesEvent(string evi, address addr);
    event errorNewSignaturesEvent(string evi, address addr);
    event errorAddSignaturesEvent(string evi, address addr);
    event addRepeatSignaturesEvent(string evi);
    event errorRepeatSignaturesEvent(string evi, address addr);
    //查看此地址是否为合法签名者地址
    function CallVerify(address addr) public view returns(bool) {
        return EvidenceSignersDataABI(factoryAddr).verify(addr);
    }

    //初始化，创建存证合约
   constructor(string memory evi, address addr)  {
       factoryAddr = addr;
       //tx.origin =>启动交易的原始地址（其实就是部署者的地址）
       //如果是外部调用，在此可以理解为函数调用者地址
       if(CallVerify(tx.origin))
       {
           evidence = evi;
           signers.push(tx.origin);
           emit newSignaturesEvent(evi,addr);
       }
       else
       {
           emit errorNewSignaturesEvent(evi,addr);
       }
    }
    //返回签名信息，合约签名者地址，当前签名者地址
    function getEvidence() public  returns(string memory,address[] memory,address[] memory){
        uint length = EvidenceSignersDataABI(factoryAddr).getSignersSize();
         address[] memory signerList = new address[](length);
         for(uint i= 0 ;i<length ;i++)
         {
             signerList[i] = (EvidenceSignersDataABI(factoryAddr).getSigner(i));
         }
        return(evidence,signerList,signers);
    }
    //添加签名者地址（此地址必须为合约签名者地址）
    function addSignatures() public returns(bool) {
        for(uint i= 0 ;i<signers.length ;i++)
        {
            //此时的tx.orgin为当前调用此方法的调用者地址
            if(tx.origin == signers[i])
            {
                emit addRepeatSignaturesEvent(evidence);
                return true;
            }
        }
       if(CallVerify(tx.origin))
       {
            signers.push(tx.origin);
            emit addSignaturesEvent(evidence);
            return true;
       }
       else
       {
           emit errorAddSignaturesEvent(evidence,tx.origin);
           return false;
       }
    }
    //返回所有的合约签名者地址
    function getSigners()public returns(address[] memory)
    {
         uint length = EvidenceSignersDataABI(factoryAddr).getSignersSize();
         address[] memory signerList = new address[](length);
         for(uint i= 0 ;i<length ;i++)
         {
             signerList[i] = (EvidenceSignersDataABI(factoryAddr).getSigner(i));
         }
         return signerList;
    }
}

pragma solidity^0.8.0;

library Roles{
    struct Role{
        mapping(address=>bool) bearer;
        mapping(address=>string) summary;
    }
    //判断角色
    function has(Role storage role,address amount)internal view returns(bool){
        require(amount!=address(0),"Address is zero address");
        return role.bearer[amount];
    }
    //添加角色
    function add(Role storage role,address amount,string calldata _summary)internal{
        require(!has(role,amount),"Address already exists");
        role.bearer[amount] = true;
        role.summary[amount] = _summary;
    }
    //删除角色
    function remove(Role storage role,address amount)internal{
        require(has(role,amount),"Address does not exist");
        role.bearer[amount] = false;
    }
    //修改角色
    function revise(Role storage role,address amount,string calldata _summary)internal {
        require(has(role,amount),"Address does not exist");
        role.summary[amount] = _summary;
    }
    //查询角色
    function seek(Role storage role,address amount)internal view returns(string memory){
        require(has(role,amount),"Address does not exist");
        return role.summary[amount];
    }
    
}
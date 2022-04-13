/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity 0.4.25; 

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

//*******************************************************************//
//------------------         token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }




//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address public owner;
    address public newOwner;
    address public  signer;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }
    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    /**
     * This function checks if given address is contract address or normal wallet
     * EXTCODESIZE returns 0 if it is called from the constructor of a contract.
     * so multiple check is required to assure caller is contract or not
     * for this two hash used one is for empty code detector another is if 
     * contract destroyed.
     */
    function extcodehash(address addr) internal view returns(uint8)
    {
        bytes32 accountHash1 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470; // for empty
        bytes32 accountHash2 = 0xf0368292bb93b4c637d7d2e942895340c5411b65bc4f295e15f2cfb9d88dc4d3; // with selfDistructed        
        bytes32 codehash = codehash = keccak256(abi.encodePacked(addr));
        if(codehash == accountHash2) return 2;
        codehash = keccak256(abi.encodePacked(at(addr)));
        if(codehash == accountHash1) return 0;
        else return 1;
    }
    // This returns bytecodes of deployed contract
    function at(address _addr) internal view returns (bytes o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
  
    }
    function isContract(address addr) internal view returns (uint8) {

        uint8 isCon;
        uint32 size;
        isCon = extcodehash(addr);
        assembly {
            size := extcodesize(addr)
        } 
        if(isCon == 1 || size > 0 || msg.sender != tx.origin ) return 1;
        else return isCon;
    }


}  

//*******************************************************************//
//------------------        MAIN contract         -------------------//
//*******************************************************************//

contract empireBusd is owned {

    // Replace below address with main Token token
    address public busdAddress;
    uint public maxDownLimit = 4;

    uint public lastIDCount = 0;

    uint dM = 10 ** 8; // Decimal Multiplier
    
    struct userInfo {
        bool joined;
        uint id;
        uint placing;
        uint parentID;
        uint originalReferrer;
        uint directCount;
        uint level;
        address[] parent;
    }

    mapping(uint => uint) public priceOfLevel;

    mapping (address => userInfo) public userInfos;
    mapping (uint => address) public userAddressByID;


    event regLevelEv(address indexed _userWallet, uint indexed _userID, uint indexed _parentID, uint _time, address _refererWallet, uint _originalReferrer);
    event levelBuyEv(address indexed _user, uint _level, uint _amount, uint _time);
    event paidForLevelEv(address indexed _user, address indexed _parent, uint _level, uint _amount, uint _time);
    event lostForLevelEv(address indexed _user, address indexed _parent, uint _level, uint _amount, uint _time);

    
    constructor() public {

        priceOfLevel[1] = 25 * dM;
        priceOfLevel[2] = 50 * dM;
        priceOfLevel[3] = 100 * dM;
        priceOfLevel[4] = 200 * dM;

        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            placing: 1,
            parentID: 1,
            originalReferrer: 1,
            directCount: 0,
            level:4,
            parent: new address[](0)
        });
        userInfos[msg.sender] = UserInfo;
        userAddressByID[lastIDCount] = msg.sender;

        emit regLevelEv(msg.sender, 1, 1, now, msg.sender, 1);

    }

    function () payable external {
        owner.transfer(msg.value);
    }

    function setBusdAddress(address _busdAddress) public onlyOwner returns(bool)
    {
        busdAddress = _busdAddress;
        return true;
    }

    function regUser(uint _refID) public returns(bool)
    {
        require(regUserI(_refID, msg.sender), "registration failed");
        return true;
    }

    function regUserI(uint _parentID, address msgSender) internal returns(bool) 
    {
        require(isContract(msgSender) ==0, "Contract can't call");
        require(userInfos[userAddressByID[_parentID]].joined, "referrer does not exits");        
        
        uint originalReferrer = _parentID;

        require(!userInfos[msgSender].joined, 'User exist');

        if(userInfos[userAddressByID[_parentID]].parent.length >= maxDownLimit) _parentID = userInfos[findFreeReferrer(userAddressByID[_parentID])].id;

        uint len = userInfos[userAddressByID[_parentID]].parent.length;

        uint pL = priceOfLevel[1];

        require( tokenInterface(busdAddress).transferFrom(msgSender, address(this),pL ),"token transfer failed");

        //update variables
        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            placing: len,
            parentID: _parentID,
            originalReferrer : originalReferrer,
            directCount: 0,
            level: 1,
            parent: new address[](0)
        });

        userInfos[msgSender] = UserInfo;
        userAddressByID[lastIDCount] = msgSender;

        userInfos[userAddressByID[originalReferrer]].directCount++;

        address parent_ = userAddressByID[_parentID];

        userInfos[userAddressByID[_parentID]].parent.push(msgSender);

        if(len == 0 || len == 3 )require(payForLevel(1, msgSender,parent_, len, originalReferrer, pL),"pay for level fail");

        emit regLevelEv(msgSender, lastIDCount, _parentID, now,userAddressByID[_parentID], originalReferrer );
        return true;
    }



    function buyLevel(uint _level, address _user) internal returns(bool){

        if(userInfos[_user].level == _level)return true; 
        uint originalReferrer = userInfos[_user].originalReferrer;       

        uint pL = priceOfLevel[_level];

        uint len = userInfos[_user].parent.length;
        
        userInfos[_user].level = _level;

        address parent_ = userAddressByID[userInfos[_user].parentID];

        if(len == 0 || len == 3 )require(payForLevel(_level, _user,parent_, len, originalReferrer, pL),"pay for level fail");        

        return true;
    }
    

    function payForLevel(uint _level, address _user, address _parent, uint _place,uint _originalReferrer, uint _price) internal returns (bool){
        tokenInterface(busdAddress).transfer(userAddressByID[_originalReferrer], _price/20 );

        if (_place == 0 ) tokenInterface(busdAddress).transfer(_parent, _price * 4 / 5 );

        if (_place == 3 ) 
        {
            address _usr = userAddressByID[userInfos[_parent].parentID];
            if(userInfos[_usr].directCount >= 4 )
            {
                tokenInterface(busdAddress).transfer(_usr, _price * 4 / 5 );
            }
            else
            {
                tokenInterface(busdAddress).transfer(owner, _price * 4 / 5 );
            }
            if(_level <= 3 ) buyLevel(_level+1, _parent);
        }

        return true;

    }

    function findFreeReferrer(address _user) public view returns(address) {
        if(userInfos[_user].parent.length < maxDownLimit) return _user;

        address[] memory parents = new address[](340);
        parents[0] = userInfos[_user].parent[0];
        parents[1] = userInfos[_user].parent[1];
        parents[2] = userInfos[_user].parent[2];
        parents[3] = userInfos[_user].parent[3];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 340; i++) {
            if(userInfos[parents[i]].parent.length == maxDownLimit) {
                if(i < 84) {
                    parents[(i+1)*4] = userInfos[parents[i]].parent[0];
                    parents[(i+1)*4+1] = userInfos[parents[i]].parent[1];
                    parents[(i+1)*4+2] = userInfos[parents[i]].parent[2];
                    parents[(i+1)*4+3] = userInfos[parents[i]].parent[3];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = parents[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }

}
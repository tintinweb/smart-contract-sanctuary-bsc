/**
 *Submitted for verification at BscScan.com on 2022-05-05
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
    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }

contract pachaasPachis is owned {
    
    mapping(uint => uint) public joiningFee; 

    mapping(uint => uint) public lastIDCount; 

    uint public maxDownLimit = 3;

    address public tokenAddress;

    struct userInfo {
        bool joined;
        uint id;
        uint parentID;
        uint referrerID;
        uint paymentCount;
        address[] referral;
    }

    //user=>level=>
    mapping (address => mapping(uint => userInfo)) public userInfos;
    //userID=>level=>
    mapping (uint => mapping(uint => address )) public userAddressByID;


    event registerEv(address _newUser,uint _level,  uint newUserId, address referedBy,uint timeNow);
    event buyLevelEv(address _newUser,uint _level,  uint newUserId, address referedBy,uint timeNow);
    event paidEv(address paidTo, uint amount,uint level, uint timeNow);

    constructor() public {

        joiningFee[1] = 55 * ( 10 ** 14);
        joiningFee[2] = 11 * ( 10 ** 15);
        joiningFee[3] = 22 * ( 10 ** 15);
        joiningFee[4] = 33 * ( 10 ** 15);
        joiningFee[5] = 55 * ( 10 ** 15);
        joiningFee[6] = 110 * ( 10 ** 15);
        joiningFee[7] = 220 * ( 10 ** 15);
        joiningFee[8] = 330 * ( 10 ** 15);
        joiningFee[9] = 550 * ( 10 ** 15);
        joiningFee[10] = 110 * ( 10 ** 16);

        userInfo memory UserInfo;

        UserInfo = userInfo({
            joined: true,
            id: 1,
            parentID: 1,
            referrerID: 1,
            paymentCount: 0,
            referral: new address[](0)
        });

        for (uint i=1;i<11;i++)
        {
            lastIDCount[i]++;
            userInfos[msg.sender][i] = UserInfo;
            userAddressByID[1][i] = msg.sender;

            emit registerEv(msg.sender,i, 1, 1, now);
        }
    }

    function register(uint _referrerID) public payable returns(bool)
    {
        require(isContract(msg.sender) ==0, "Contract can't call");
        address referredBy = userAddressByID[_referrerID][1];
        require(userInfos[referredBy][1].joined, "referrer does not exits");
        require(!userInfos[msg.sender][1].joined, "sender already joined");
        require(msg.value == joiningFee[1], "Invalid amount sent");

        uint origRef = _referrerID;

        _referrerID = userInfos[findFreeReferrer(referredBy,1)][1].id;

        lastIDCount[1]++;

        userInfo memory temp;
        temp.joined = true;
        temp.id = lastIDCount[1];
        temp.parentID = _referrerID;
        temp.referrerID = origRef;

        userInfos[msg.sender][1] = temp;

        userAddressByID[temp.id][1] = msg.sender;

        userInfos[userAddressByID[_referrerID][1]][1].referral.push(msg.sender);

        payForLevel(_referrerID, 1, msg.value);

        emit registerEv(msg.sender,1, temp.id, referredBy,now);

    }


    function buyLevel(uint _level) public payable returns(bool)
    {
        require(_level > 1 &&  _level <= 10, "Invalid Level");
        uint _referrerID = userInfos[msg.sender][1].referrerID;
        require(userInfos[msg.sender][_level-1].joined, "buy previous level");
        require(isContract(msg.sender) ==0, "Contract can't call");
        address referredBy = userAddressByID[_referrerID][1];

        require(!userInfos[msg.sender][_level].joined, "sender already joined");
        require(msg.value == joiningFee[_level], "Invalid amount sent");

        uint origRef = _referrerID;

        _referrerID = userInfos[findFreeReferrer(referredBy,_level)][_level].id;

        lastIDCount[_level]++;

        userInfo memory temp;
        temp.joined = true;
        temp.id = lastIDCount[_level];
        temp.parentID = _referrerID;
        temp.referrerID = origRef;

        userInfos[msg.sender][_level] = temp;

        userAddressByID[temp.id][_level] = msg.sender;

        userInfos[userAddressByID[_referrerID][_level]][_level].referral.push(msg.sender);

        //payForLevel(temp.id, _level, msg.value);
        payForLevel(_referrerID, _level, msg.value);

        emit buyLevelEv(msg.sender,_level,temp.id, referredBy, now);

    }


    function findFreeReferrer(address _user, uint _level) public view returns(address) {

        if(_level > 1)
        {
            while(userInfos[_user][_level].joined == false )
            {
                _user = userAddressByID[userInfos[_user][1].referrerID][1];
            }
        }
        if(userInfos[_user][_level].referral.length < maxDownLimit) return _user;

        address[] memory referrals = new address[](360);
        referrals[0] = userInfos[_user][_level].referral[0];
        referrals[1] = userInfos[_user][_level].referral[1];
        referrals[2] = userInfos[_user][_level].referral[2];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 363; i++) {
            if(userInfos[referrals[i]][_level].referral.length == maxDownLimit) {
                if(i < 120) {
                    referrals[(i+1)*3] = userInfos[referrals[i]][_level].referral[0];
                    referrals[(i+1)*3+1] = userInfos[referrals[i]][_level].referral[1];
                    referrals[(i+1)*3+2] = userInfos[referrals[i]][_level].referral[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }


    // function findFreeReferrer(address _user, uint _level) public view returns(address) {

    //     if(_level > 1)
    //     {
    //         while(userInfos[_user][_level].joined == false )
    //         {
    //             _user = userAddressByID[userInfos[_user][1].referrerID][1];
    //         }
    //     }

    //     if(userInfos[_user][_level].referral.length < maxDownLimit) return _user;

    //     address[] memory referrals = new address[](126);
    //     referrals[0] = userInfos[_user][_level].referral[0];
    //     referrals[1] = userInfos[_user][_level].referral[1];

    //     address freeReferrer;
    //     bool noFreeReferrer = true;

    //     for(uint i = 0; i < 126; i++) {
    //         if(userInfos[referrals[i]][_level].referral.length == maxDownLimit) {
    //             if(i < 62) {
    //                 referrals[(i+1)*2] = userInfos[referrals[i]][_level].referral[0];
    //                 referrals[(i+1)*2+1] = userInfos[referrals[i]][_level].referral[1];
    //             }
    //         }
    //         else {
    //             noFreeReferrer = false;
    //             freeReferrer = referrals[i];
    //             break;
    //         }
    //     }

    //     require(!noFreeReferrer, 'No Free Referrer');

    //     return freeReferrer;
    // }

    function payForLevel(uint _parentID, uint _level, uint _amount) internal returns(bool)
    {
        //userAddressByID[1][_level].transfer(_amount/10);
        address _tokencontract = tokenAddress;
        _tokencontract.transfer(_amount/10);
        tokenInterface(_tokencontract).transfer(msg.sender,(10*10**18)*_level);        

        uint remaining = _amount * 9 / 10;
        uint paidSection = 0;

        address _parent = userAddressByID[_parentID][_level];

        uint tf;
        bool h;

        

        while(paidSection < 4)
        {
            h = false; 

              

            (_parent, tf, h) = findEligibleToPayNext(_parent,_level, h, paidSection);
           
            uint pCount = userInfos[_parent][_level].paymentCount; 
            
            if (paidSection == 3) h = true;

           
            uint fID = userInfos[_parent][_level].id;
            if(h==false && fID == 1)
            {
                if(tf % 2 == 0)
                {
                    _parent.transfer(remaining/2);
                    stackTooDeep(_parent, remaining/2,_level);
                    paidSection += 2;
                }
                else
                {
                    _parent.transfer(remaining/4);
                    stackTooDeep(_parent, remaining/4,_level);
                    paidSection += 1;
                }
                userInfos[_parent][_level].paymentCount++;
            }           
            else if(paidSection == 3 && tf % 2 == 0 && pCount<9)
            {
               // if(fID == 1 && tf % 2 != 0)
               // {
               //     _parent.transfer(remaining/4);
               //     paidSection += 1;
               //     userInfos[_parent][_level].paymentCount++;
               // }
               // else 
                if(fID == 1)
                {
                    paidSection += 1;
                }
                              
            }
            else if(pCount<9)
            {
                if(tf % 2 == 0)
                {
                    _parent.transfer(remaining/2);
                    stackTooDeep(_parent, remaining/2,_level);
                    paidSection += 2;
                }
                else
                {
                    _parent.transfer(remaining/4);
                    stackTooDeep(_parent, remaining/4,_level);
                    paidSection += 1;
                }
                userInfos[_parent][_level].paymentCount++;
            }
            else
            {
                if(tf % 2 == 0)
                {
                   // _parent.transfer(remaining/2);
                    paidSection += 2;
                }
                else
                {
                   // _parent.transfer(remaining/4);
                    paidSection += 1;
                }
                userInfos[_parent][_level].paymentCount++;
                if(pCount == 11 ) 
                {
                    rejoin(_parent, _level);
                }
            }
        }


        return true;
    }

    function rejoin(address _parent, uint _level) internal returns(bool)
    {
        userInfo memory temp =  userInfos[_parent][_level];
        address _PAddress =  userAddressByID[userInfos[_parent][_level].parentID][_level];
        temp.parentID = userInfos[findFreeReferrer(_PAddress,_level)][_level].id;
        temp.paymentCount = 0;
        temp.referral = new address[](0);
        userInfos[_parent][_level] = temp;       
        payForLevel(temp.parentID, _level, joiningFee[_level]);
        return true;
    }

    function stackTooDeep(address parent_, uint amount_, uint level_ ) internal returns(bool)
    {
        emit paidEv(parent_, amount_,level_, now);
        return true;
    }

    function findEligibleToPayNext(address _user,uint _level, bool fourth, uint loop) public view returns(address, uint, bool) // id, payCount, payHold
    {
        uint _pid;
        if(loop==0)
        {
            _pid = userInfos[_user][_level].id;
        }
        else
        {
            _pid = userInfos[_user][_level].parentID;
        }
        
        if(!fourth)
        {
            for (uint i=0;i<100; i++)
            {
                address usr = userAddressByID[_pid][_level];
                uint pc = userInfos[usr][_level].paymentCount;
                if(pc < 12 )
                {
                    if(pc >= 9 ) return (usr, pc, true);
                    else return(usr, pc, false);
                }
                _pid = userInfos[usr][_level].parentID;
                if(_pid == 1 || i == 99 ) return(userAddressByID[_pid][_level], pc, false);
            }
        }
        else
        {
            for (i=0;i<100; i++)
            {
                usr = userAddressByID[_pid][_level];
                pc = userInfos[usr][_level].paymentCount;
                if(pc < 12 && pc%2 == 1)
                {
                    if(pc >= 9 ) return (usr, pc, true);
                    else return(usr, pc, false);
                }
                _pid = userInfos[usr][_level].parentID;
                if(_pid == 1 || i == 99 ) return(userAddressByID[_pid][_level], pc, false);
            }           
        }
    }

    function settokenaddress(address _tokenaddress) onlyOwner public {
        tokenAddress = _tokenaddress;     
    }

}
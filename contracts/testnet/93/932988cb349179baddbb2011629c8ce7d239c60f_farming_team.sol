/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

pragma solidity >=0.4.23 <0.6.0;


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address public owner;
    address public newOwner;
    address public signer;

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
}


interface interfaceMintNFT {
    function mintToken(address recipient, uint _type) external returns (bool);
}

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }


contract farming_team is owned {

    struct userInfo {
        bool joined;
        uint id;
        address referrer;
        uint parentId;
        uint slotCount;
        uint resetCount;
    }

    uint public lastIDCount = 0;
    mapping (address => mapping(uint => userInfo)) public userInfos;
    mapping (uint => address payable) public userAddressByID;

    // level 1 = common nft
    // level 2 = rare nft
    // level 3 = epic nft
    // level 4 = legendary nft
    uint public constant LAST_LEVEL = 4;
    mapping(uint => uint) public levelPrice;

    address public usdtTokenAddress;
    address public nftMinterContract;


    constructor() public {
        levelPrice[1] = 0.005 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }

        lastIDCount++;

        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: 1,
            referrer: msg.sender,
            parentId: 1,
            slotCount: 0,
            resetCount: 0
        });

        for(uint i=1;i< 5; i++)
        {
            userInfos[msg.sender][i] = UserInfo;
            
        }
        
        userAddressByID[1] = msg.sender;


    }

    function setUsdtTokenAddress(address _usdtTokenAddress) public onlyOwner returns(bool) {
        usdtTokenAddress = _usdtTokenAddress;
        return true;
    }

    function setNftMinterContract(address _nftMinterContract) public onlyOwner returns(bool)
    {
        nftMinterContract = _nftMinterContract;
        return true;
    }


    event registerEv(address user,uint userID, address referrer, uint timeOfEvent);
    event slotResetEv(address referrer, address reseter, uint timeOfEvent);
    event paidEv(address referrer,address user, uint amount,uint _level, uint timeOfEvent);

    function register(address _referrer) public returns(bool) {
        require(!userInfos[msg.sender][1].joined, "already joined");
        require(userInfos[_referrer][1].joined, "invalid referrer");
        uint lP = levelPrice[1];
        tokenInterface(usdtTokenAddress).transferFrom(msg.sender, address(this), lP);


        lastIDCount++;
        uint lID = lastIDCount;
        uint pID = userInfos[_referrer][1].id;

        if (pID == 0) pID = 1;

        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: lID,
            referrer: _referrer,
            parentId: pID,
            slotCount: 0,
            resetCount: 0
        });
        
        userInfos[msg.sender][1] = UserInfo;

        userAddressByID[lID] = msg.sender;

        

        if(userInfos[_referrer][1].slotCount >= 2) {
            userInfos[_referrer][1].slotCount = 0;
            userInfos[_referrer][1].resetCount++;
            emit slotResetEv(_referrer, msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer][1].slotCount++;
        }

        emit registerEv(msg.sender, lID,_referrer, block.timestamp);

        tokenInterface(usdtTokenAddress).transfer(_referrer, lP /2);
        emit paidEv(_referrer, msg.sender, lP/2,1, block.timestamp);

        interfaceMintNFT(nftMinterContract).mintToken(msg.sender, 1);

        return true;
    }


    event buyLevelEv(address user,uint amount, address referrer, uint timeOfEvent);
    
    function buyLevel(uint _level, uint _amount) public returns(bool) {
        require(userInfos[msg.sender][1].joined, "register first");
        require(_level > 0 && _level <= 4, "Invalid Level");
        require(_amount >0 && _amount < 3, "invalid amount");

        uint lP = levelPrice[_level];
        tokenInterface(usdtTokenAddress).transferFrom(msg.sender, address(this), lP * _amount );


        address _referrer = userInfos[msg.sender][1].referrer;

        if( userInfos[msg.sender][_level].id == 0 ) {

            uint lID = userInfos[msg.sender][1].id;
            uint pID = userInfos[_referrer][_level].id;
            if (pID == 0) pID = 1;

            userInfo memory UserInfo;
            UserInfo = userInfo({
                joined: true,
                id: lID,
                referrer: _referrer,
                parentId: pID,
                slotCount: 0,
                resetCount: 0
            });

            userInfos[msg.sender][_level] = UserInfo;        
        }
        if(userInfos[_referrer][_level].slotCount >= 2) {
            userInfos[_referrer][_level].slotCount = 0;
            userInfos[_referrer][_level].resetCount++;
            emit slotResetEv(_referrer, msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer][_level].slotCount++;
        }

        emit buyLevelEv(msg.sender, _amount,_referrer, block.timestamp);

        tokenInterface(usdtTokenAddress).transfer(_referrer, lP /2);

        emit paidEv(_referrer, msg.sender, lP/2,_level, block.timestamp);

        interfaceMintNFT(nftMinterContract).mintToken(msg.sender, _level);

        for(uint i = 1; i < _amount; i++)
        {
            buyLevelI(_level);
        }

        return true;
    }


    function buyLevelI(uint _level) internal returns(bool) {

        uint lP = levelPrice[_level];

        address _referrer = userInfos[msg.sender][1].referrer;

    

        if(userInfos[_referrer][_level].slotCount >= 2) {
            userInfos[_referrer][_level].slotCount = 0;
            userInfos[_referrer][_level].resetCount++;
            emit slotResetEv(_referrer, msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer][_level].slotCount++;
        }

        tokenInterface(usdtTokenAddress).transfer(_referrer, lP /2);
        emit paidEv(_referrer, msg.sender, lP/2,_level, block.timestamp);

        interfaceMintNFT(nftMinterContract).mintToken(msg.sender, _level);

        return true;
    }

    function moveToFarming(uint _amount) public returns(bool)
    {
        require(msg.sender == owner, "Invalid Caller");
        tokenInterface(usdtTokenAddress).transfer(owner, _amount);
        return true;
    }

    

}
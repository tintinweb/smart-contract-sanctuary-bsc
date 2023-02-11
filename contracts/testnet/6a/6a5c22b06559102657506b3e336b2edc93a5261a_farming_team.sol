/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-24
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
    function mintToken(address recipient, uint _type) external returns (uint);
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
        uint filled;
        uint slotOne;
        address slotOneA;  
        uint slotTwo;
        address slotTwoA;      
    }


    uint public lastIDCount;
    mapping (address =>  userInfo) public userInfos;
    //user => slot number => threeYield
    mapping(address => mapping(uint => uint)) public threeYieldCount;
    mapping(address => mapping(uint => uint)) public threeYieldMissed;

    mapping (uint => address payable) public userAddressByID;

    // level 1 = common nft
    // level 2 = rare nft
    // level 3 = epic nft
    // level 4 = legendary nft
    uint public constant LAST_LEVEL = 4;
    mapping(uint => uint) public levelPrice;
    mapping(uint => uint) public refPart;
    uint[5] public maxMint; // max mint for each type
    uint[5] public totalMinted; // max mint for each type

    address public usdtTokenAddress;
    address public nftMinterContract;


    constructor() public {
        levelPrice[1] = 0.005 ether;
        levelPrice[2] = 0.01 ether;
        levelPrice[3] = 0.02 ether;
        levelPrice[4] = 0.04 ether;

        refPart[1] = 0.0025 ether;
        refPart[2] = 0.005 ether;
        refPart[3] = 0.01 ether;
        refPart[4] = 0.02 ether;

        maxMint[1] = 200000;
        maxMint[2] = 200000;
        maxMint[3] = 200000;
        maxMint[4] = 200000;

        lastIDCount++;

        userInfo memory UserInfo;

        UserInfo = userInfo({
            joined: true,
            id: 1,
            referrer: msg.sender,
            parentId: 1,
            filled:0,
            slotOne:0,
            slotOneA: address(0),
            slotTwo:0,
            slotTwoA: address(0)
        });

        userInfos[msg.sender] = UserInfo;

        
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
    event slotResetEv(address referrer,address yieldReceiver,uint slot,  address reseter, uint timeOfEvent);
    event paidEv(address referrer,address user, uint amount, uint quantity, uint _level, uint timeOfEvent);

    function register(address _referrer) internal returns(bool) {
        

        lastIDCount++;
        uint lID = lastIDCount;
        uint pID = userInfos[_referrer].id;

        if (pID == 0) pID = 1;

        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: lID,
            referrer: _referrer,
            parentId: pID,
            filled:0,
            slotOne:0,
            slotOneA: address(0),
            slotTwo:0,
            slotTwoA: address(0)
        });
        
        userInfos[msg.sender] = UserInfo;

        userAddressByID[lID] = msg.sender;

        emit registerEv(msg.sender, lID,_referrer, block.timestamp);

        return true;
    }


    event buyLevelEv(address user,uint quantity,uint nftType,uint nftID, address referrer,uint refAmount, uint timeOfEvent);

    function buyLevelFirstTime(address _referrer, uint _level, uint _qty) public returns(bool) {
        require(!userInfos[msg.sender].joined, "already joined");
        require(userInfos[_referrer].joined, "invalid referrer");
        register(_referrer);
        require(_level > 0 && _level <= 4, "Invalid Level");
        require(_qty >0 && _qty <= 3, "invalid amount");
        require(totalMinted[_level] + _qty <= maxMint[_level], "max mint reached");

        uint lP = levelPrice[_level];
        tokenInterface(usdtTokenAddress).transferFrom(msg.sender, address(this), lP * _qty );
        emit paidEv(_referrer, msg.sender, lP * _qty,_qty, _level, block.timestamp);
        
        uint fc = userInfos[_referrer].filled;
        if( fc >= 2) {
            userInfos[_referrer].filled = 0;
            userInfos[_referrer].slotOne = 0;
            userInfos[_referrer].slotTwo = 0;
            userInfos[_referrer].slotOneA = address(0);
            userInfos[_referrer].slotTwoA = address(0);            
            address ref2 = userInfos[_referrer].referrer;
            uint fc2 = userInfos[ref2].filled;
            if( fc2 > 1) {
                threeYieldCount[userAddressByID[1]][_level]++;
                threeYieldMissed[ref2][_level]++;
            }
            else {
                threeYieldCount[ref2][_level]++;
                if(fc == 0 ) {
                    userInfos[ref2].slotOne = _level;
                    userInfos[ref2].slotOneA = msg.sender;
                }
                if(fc == 1 ) {
                    userInfos[ref2].slotTwo = _level;
                    userInfos[ref2].slotTwoA = msg.sender;
                } 
                userInfos[ref2].filled++;                
            }
            emit slotResetEv(_referrer,ref2,fc, msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer].filled++;
            if(fc == 0 ) {
                userInfos[_referrer].slotOne = _level;
                userInfos[_referrer].slotOneA = msg.sender;
            }
            if(fc == 1 ) {
                userInfos[_referrer].slotTwo = _level;
                userInfos[_referrer].slotTwoA = msg.sender;

            }
        }

        

        tokenInterface(usdtTokenAddress).transfer(_referrer, refPart[_level]);

        //emit paidEv(_referrer, msg.sender, refPart[_level],_level, block.timestamp);

        uint tID = interfaceMintNFT(nftMinterContract).mintToken(msg.sender, _level);
        totalMinted[_level]++;
        emit buyLevelEv(msg.sender, 1,_level,tID, _referrer,refPart[_level], block.timestamp);
        for(uint i = 1; i < _qty; i++)
        {
            buyLevelI(_level);
        }

        return true;
    }



    function buyLevel(uint _level, uint _qty) public returns(bool) {
        require(userInfos[msg.sender].joined, "register first");
        require(_level > 0 && _level <= 4, "Invalid Level");
        require(_qty >0 && _qty <= 3, "invalid amount");
        require(totalMinted[_level] + _qty <= maxMint[_level], "max mint reached");

        uint lP = levelPrice[_level];
        tokenInterface(usdtTokenAddress).transferFrom(msg.sender, address(this), lP * _qty );

        address _referrer = userInfos[msg.sender].referrer;

        emit paidEv(_referrer, msg.sender, lP * _qty, _qty, _level, block.timestamp);

        
        uint fc = userInfos[_referrer].filled;
        if( fc >= 2) {
            userInfos[_referrer].filled = 0;
            userInfos[_referrer].slotOne = 0;
            userInfos[_referrer].slotTwo = 0;
            userInfos[_referrer].slotOneA = address(0);
            userInfos[_referrer].slotTwoA = address(0);
            address ref2 = userInfos[_referrer].referrer;
            uint fc2 = userInfos[ref2].filled;
            if( fc2 > 1) {
                threeYieldCount[userAddressByID[1]][_level]++;
                threeYieldMissed[ref2][_level]++;
            }
            else {
                threeYieldCount[ref2][_level]++;
                if(fc == 0 ) {
                    userInfos[ref2].slotOne = _level;
                    userInfos[ref2].slotOneA = msg.sender;
                }
                if(fc == 1 ) {
                    userInfos[ref2].slotTwo = _level;
                    userInfos[ref2].slotTwoA = msg.sender;
                } 
                userInfos[ref2].filled++;                
            }
            emit slotResetEv(_referrer, ref2,fc,  msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer].filled++;
            if(fc == 0 ) {
                userInfos[_referrer].slotOne = _level;
                userInfos[_referrer].slotOneA = msg.sender;
            }
            if(fc == 1 ) {
                userInfos[_referrer].slotTwo = _level;
                userInfos[_referrer].slotTwoA = msg.sender;

            }
        }

        

        tokenInterface(usdtTokenAddress).transfer(_referrer, refPart[_level]);

        //emit paidEv(_referrer, msg.sender, refPart[_level],_level, block.timestamp);

        uint tID = interfaceMintNFT(nftMinterContract).mintToken(msg.sender, _level);
        totalMinted[_level]++;
        
        emit buyLevelEv(msg.sender, 1,_level,tID, _referrer,refPart[_level], block.timestamp);
        
        for(uint i = 1; i < _qty; i++)
        {
            buyLevelI(_level);
        }

        return true;
    }


    function buyLevelI(uint _level) internal returns(bool) {


        address _referrer = userInfos[msg.sender].referrer;

    
        
        uint fc = userInfos[_referrer].filled;
        if( fc >= 2) {
            userInfos[_referrer].filled = 0;
            userInfos[_referrer].slotOne = 0;
            userInfos[_referrer].slotTwo = 0;
            userInfos[_referrer].slotOneA = address(0);
            userInfos[_referrer].slotTwoA = address(0);
            address ref2 = userInfos[_referrer].referrer;
            uint fc2 = userInfos[ref2].filled;
            if( fc2 > 1) {
                threeYieldCount[userAddressByID[1]][_level]++;
                threeYieldMissed[ref2][_level]++;
            }
            else {
                threeYieldCount[ref2][_level]++;
                if(fc == 0 ) {
                    userInfos[ref2].slotOne = _level;
                    userInfos[ref2].slotOneA = msg.sender;
                }
                if(fc == 1 ) {
                    userInfos[ref2].slotTwo = _level;
                    userInfos[ref2].slotTwoA = msg.sender;
                } 
                userInfos[ref2].filled++;               
            }
            emit slotResetEv(_referrer,ref2,fc,  msg.sender, block.timestamp);
        }
        else
        {
            userInfos[_referrer].filled++;
            if(fc == 0 ) {
                userInfos[_referrer].slotOne = _level;
                userInfos[_referrer].slotOneA = msg.sender;
            }
            if(fc == 1 ) {
                userInfos[_referrer].slotTwo = _level;
                userInfos[_referrer].slotTwoA = msg.sender;

            }
        }

        tokenInterface(usdtTokenAddress).transfer(_referrer, refPart[_level]);
        //emit paidEv(_referrer, msg.sender, refPart[_level],_level, block.timestamp);

        uint tID = interfaceMintNFT(nftMinterContract).mintToken(msg.sender, _level);
        totalMinted[_level]++;
        
        emit buyLevelEv(msg.sender, 1,_level,tID, _referrer,refPart[_level], block.timestamp);

        return true;
    }

    function moveToFarming(uint _amount) public returns(bool)
    {
        require(msg.sender == owner, "Invalid Caller");
        tokenInterface(usdtTokenAddress).transfer(owner, _amount);
        return true;
    }

    

}
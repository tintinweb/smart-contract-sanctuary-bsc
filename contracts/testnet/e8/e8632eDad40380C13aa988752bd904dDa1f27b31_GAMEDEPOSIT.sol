/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function approve(address,uint) external;
}

contract GAMEDEPOSIT  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "GAMEDEPOSIT/not-authorized");
        _;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "GAMEDEPOSIT: subtraction overflow");
    }

    mapping (address => address[])                       public  under;
    mapping (address => address)                         public  recommended;
    mapping (address => mapping (address => UserInfo))   public  userInfo;
    mapping (address => mapping (address => uint))       public  runner;

    struct UserInfo {
        address    recommend;   
        uint256    rechargeed;
        uint256[2][]    recording;
    }
    struct UnderInfo {
        address    owner;   
        uint256    rechargeed;
    }

    constructor() {
        wards[msg.sender] = 1;
    }

    function deposit(uint256 wad,address asset,address recommender) public {
        Token(asset).transferFrom(msg.sender, address(this), wad);
        UserInfo storage user = userInfo[msg.sender][asset];
        user.rechargeed += wad;
        uint256[2] memory details = [wad,block.timestamp];
        user.recording.push(details);
        if(recommended[msg.sender] == address(0) && recommender != address(0)) {
           recommended[msg.sender] = recommender;
           under[recommender].push(msg.sender);
        }
   
    }

    function withdraw(address asset,uint256 wad, address  usr) public  auth {
        Token(asset).transfer(usr,wad);
    }

    function getUnderInfo(address usr,address asset) public view returns(UnderInfo[] memory,uint256){
        uint length = under[usr].length;
        UnderInfo[] memory underInfo = new UnderInfo[](length);
        uint256 total;
        for (uint i = 0; i <length ; ++i) {
            address underAddress = under[usr][i];
            underInfo[i].owner  = underAddress;
            underInfo[i].rechargeed  = userInfo[underAddress][asset].rechargeed;
            total += userInfo[underAddress][asset].rechargeed;
        }
        return (underInfo,total);
    }

    function getUserInfo(address ust,address asset) public view returns(UserInfo memory){
        UserInfo memory user = userInfo[ust][asset];
        UserInfo memory usr;
        usr.recommend = recommended[ust];
        usr.rechargeed = user.rechargeed;
        return usr;
    }

    function setRunner(address _asset,address _runner, uint256 _wad) public auth {
        runner[_asset][_runner] = _wad;
    }

    function approve(address _asset,address _contract, uint256 _wad) public auth {
        Token(_asset).approve(_contract,_wad);
    }

    function transfer(address _asset,address _usr, uint256 _wad) public {
        require(runner[_asset][msg.sender] >= _wad, "GAMEDEPOSIT/low-authorized");
        runner[_asset][msg.sender] = sub(runner[_asset][msg.sender],_wad);
        Token(_asset).transfer(_usr,_wad);
    }
}
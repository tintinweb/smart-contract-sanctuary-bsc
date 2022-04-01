// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;
import "./Ownable.sol";

contract FountainTokenInterface is Ownable {
    function ownerOf(uint256 tokenId) public view virtual returns (address) {}

    function getStatus() public view returns (uint256[] memory) {}

    function balanceOf(address owner) public view returns (uint256) {}
}

contract EGGLuckDraw is Ownable {
    struct User {
        string twitter;
        bool isBind;
    }
    struct Activity {
        string logo;
        string name;
        uint256 quota;
        uint256 time;
        bool status;
        uint256[] tokens;
        mapping(address => bool) joiner;
        uint256[] lucker;
        uint256 deleteCount;
    }
    mapping(address => bool) private blacklist;
    mapping(address => User) private twitters;
    mapping(uint256 => Activity) private activityList;
    uint256[] private activityIds;
    FountainTokenInterface fountain =
        FountainTokenInterface(0x3cE49E038c6330C17e95F2dD87bBA59c8E663ECe);

    function getAllOwnerTokens(address addr)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory baseData = fountain.getStatus();
        uint256 mintedSupply = baseData[3];
        uint256 count = fountain.balanceOf(addr);
        uint256[] memory tokens = new uint256[](count);
        uint256 pushed = 0;
        for (uint256 i = 1; i < mintedSupply + 1; i++) {
            if (fountain.ownerOf(i) == addr) {
                tokens[pushed] = i;
                pushed++;
            }
        }
        return tokens;
    }

    function bindTwitter(string memory _twitter) public virtual {
        twitters[msg.sender].isBind = true;
        twitters[msg.sender].twitter = _twitter;
    }

    function getTwitter(uint256 tokenId) public view returns (string memory) {
        address addr = fountain.ownerOf(tokenId);
        return twitters[addr].twitter;
    }

    function checkBinkTwitter(address addr) public view returns (bool) {
        return twitters[addr].isBind;
    }

    function setLucker(uint256[] memory _tokens, uint256 _id) internal {
        activityList[_id].lucker = _tokens;
        activityList[_id].status = false;
    }

    function setBacklist(address addr, bool status) public virtual onlyOwner {
        blacklist[addr] = status;
    }

    function joinDraw(uint256 tokenId, uint256 _id) public virtual {
        require(!blacklist[msg.sender], "You're on the blacklist");
        require(checkBinkTwitter(msg.sender), "You haven't bound twitter yet");
        require(activityList[_id].status, "activity is end");
        require(!activityList[_id].joiner[msg.sender], "You have joined");
        require(
            fountain.ownerOf(tokenId) == msg.sender,
            "You are not the holder"
        );
        activityList[_id].tokens.push(tokenId);
        activityList[_id].joiner[msg.sender] = true;
    }

    function deleteTokenId(uint256 tokenId, uint256 _id)
        public
        virtual
        onlyOwner
    {
        uint256[] memory tokens = activityList[_id].tokens;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                delete activityList[_id].tokens[i];
                activityList[_id].deleteCount++;
                break;
            }
        }
    }

    function getActivityTokens(uint256 _id)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory _tokens;
        if (activityList[_id].deleteCount > 0) {
            uint256[] memory tokens = activityList[_id].tokens;
            _tokens = new uint256[](
                tokens.length - activityList[_id].deleteCount
            );
            uint256 deleteCount = 0;
            for (uint256 i = 0; i < tokens.length; i++) {
                if (tokens[i] != 0) {
                    _tokens[i - deleteCount] = tokens[i];
                } else {
                    deleteCount++;
                }
            }
        } else {
            _tokens = activityList[_id].tokens;
        }
        return _tokens;
    }

    function drawLucker(uint256 _id) public virtual onlyOwner {
        require(activityList[_id].status, "activity is end");
        require(activityList[_id].tokens.length > 0, "draw error");
        uint256[] memory _tokens = getActivityTokens(_id);
        uint256 _quota = activityList[_id].quota;
        uint256[] memory _luckers = new uint256[](_quota);
        for (uint256 i = 0; i < _quota; i++) {
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, i)
                )
            );
            _luckers[i] = _tokens[random % _tokens.length];
        }
        setLucker(_luckers, _id);
    }

    function setActivityStatus(uint256 _id, bool _status)
        public
        virtual
        onlyOwner
    {
        activityList[_id].status = _status;
    }

    function createActivity(
        uint256 _id,
        string memory _logo,
        string memory _name,
        uint256 _quota,
        uint256 _hours
    ) external onlyOwner {
        require(!checkActivity(_id), "Activity already exists");
        activityList[_id].logo = _logo;
        activityList[_id].name = _name;
        activityList[_id].status = true;
        activityList[_id].quota = _quota;
        activityList[_id].time = block.timestamp + _hours * 3600;
        activityIds.push(_id);
    }

    function checkActivity(uint256 _id) public view returns (bool) {
        bool isHave = false;
        for (uint256 i = 0; i < activityIds.length; i++) {
            if (activityIds[i] == _id) {
                isHave = true;
            }
        }
        return isHave;
    }

    function getActivityList() public view returns (uint256[] memory) {
        return activityIds;
    }

    function deleteActivity(uint256 _id) public virtual onlyOwner {
        for (uint256 i = 0; i < activityIds.length; i++) {
            if (activityIds[i] == _id) {
                delete activityIds[i];
                break;
            }
        }
    }

    function getActivityDetail(uint256 _id)
        public
        view
        returns (
            string[] memory _logoAndName,
            uint256[] memory _quotaAndTime,
            bool _status,
            uint256[] memory _tokens,
            uint256[] memory _lucker
        )
    {
        string[] memory logoAndName = new string[](2);
        uint256[] memory quotaAndTime = new uint256[](2);
        bool status = activityList[_id].status;
        uint256[] memory tokens = getActivityTokens(_id);
        uint256[] memory lucker = activityList[_id].lucker;
        logoAndName[0] = activityList[_id].logo;
        logoAndName[1] = activityList[_id].name;
        quotaAndTime[0] = activityList[_id].quota;
        quotaAndTime[1] = activityList[_id].time;
        return (logoAndName, quotaAndTime, status, tokens, lucker);
    }
}
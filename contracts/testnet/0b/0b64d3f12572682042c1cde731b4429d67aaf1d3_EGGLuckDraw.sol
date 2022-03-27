// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;
import "./Ownable.sol";

contract FountainTokenInterface is Ownable {
    function ownerOf(uint256 tokenId) public view virtual returns (address) {}
}

contract EGGLuckDraw is Ownable {
    mapping(uint256 => uint256[]) private activityTokens;
    mapping(uint256 => address[]) private lucker;
    string[] private activityLogo;
    string[] private activityName;
    uint256[] private activityQuota;
    bool[] private activityStatus;
    uint256[] private activityIds;
    uint256[] private times;
    FountainTokenInterface fountain =
        FountainTokenInterface(0x3cE49E038c6330C17e95F2dD87bBA59c8E663ECe);


    function setLucker(address[] memory addrs, uint256 _activityId) internal {
        lucker[_activityId] = addrs;
        activityStatus[_activityId - 1] = true;
    }

    function drawLucker(uint256 _activityId) public virtual onlyOwner {
        require(!activityStatus[_activityId - 1], "activity is end");
        require(activityTokens[_activityId].length > 0, "draw error");
        uint256[] memory _tokens = activityTokens[_activityId];
        uint256 _quota = activityQuota[_activityId - 1];
        uint256[] memory _luckers = new uint256[](_quota);
        for( uint256 i = 0; i < _quota; i ++){
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, i)
                )
            );
            _luckers[i] = _tokens[random % _tokens.length];
        }
        address[] memory addrs = getOwnerAddress(_luckers);
        setLucker(addrs, _activityId);
    }
    function getActivityLen() public view returns(uint256){
        return activityIds.length;
    }
    function getOwnerAddress(uint256[] memory _tokens)
        public
        view
        returns (address[] memory)
    {
        address[] memory addrs = new address[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            addrs[i] = fountain.ownerOf(_tokens[i]);
        }
        return addrs;
    }

    function createActivity(
        string memory _activityLogo,
        string memory _activityName,
        uint256 _activityQuota,
        uint256 _hours
    ) external onlyOwner {
        require(_activityQuota != 0, "activityQuota require");
        uint256 generetorId = activityIds.length + 1;
        activityIds.push(generetorId);
        activityLogo.push(_activityLogo);
        activityName.push(_activityName);
        activityQuota.push(_activityQuota);
        activityStatus.push(false);
        times.push(block.timestamp + _hours * 3600);
    }

    function setActivityDrawTokens(uint256[] memory tokens, uint256 _activityId)
        external
        onlyOwner
    {
        activityTokens[_activityId] = tokens;
    }

    function getActivityList(uint256 _activityId)
        public
        view
        returns (
            bool _activityStatus,
            string[] memory _logoAndName,
            address[] memory _addrs,
            address[] memory _luckers,
            uint256 _quota,
            uint256 _countDown
        )
    {
        if (activityIds.length > 0) {
            uint256[] memory _tokens = activityTokens[_activityId];
            string[] memory logoAndName = new string[](2);
            logoAndName[0] =  activityLogo[_activityId - 1];
            logoAndName[1] =  activityName[_activityId - 1];
            return (
                activityStatus[_activityId - 1],
                logoAndName,
                getOwnerAddress(_tokens),
                lucker[_activityId],
                activityQuota[_activityId - 1],
                times[_activityId - 1]
            );
        } else {
            address[] memory addrs = new address[](0);
            string[] memory logoAndName = new string[](2);
            return (false,logoAndName, addrs, lucker[_activityId], 0, 0);
        }
    }
}
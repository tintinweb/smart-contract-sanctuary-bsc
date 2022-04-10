/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

// File: contracts/blackhole.sol


pragma solidity ^0.8.0;
pragma abicoder v2;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IsBHO {
    function balanceOf(address account) external view returns (uint256);

    function gonsForBalance(uint amount) external returns (uint);
}

interface IBHO {
    function balanceOf(address account) external view returns (uint256);
}




// BlackHole Referral And Donate Function
contract BlackHoleSupport {
    uint public  recordId;

    struct TeamLeader {
        uint referredNumber;
        string name;
        // save png(base64 encoded) string here
        string logo;
    }

    // Donate Record related
    struct DonateRecord {
        uint id;
        address donorAddress;
        uint donorType; // 1 teamleader 2 person 3 institute
        uint starTime;
        uint endTime;
        uint donateBUSDAmount;
        uint claimableBUSDAmount;
        uint claimableBHOAmount;
        uint claimedBUSD;
        uint claimedBHO;
        uint claimedBHOValue;
        uint currentIndex;
    }

    uint currentPersonIndex;
    uint currentInsituteIndex;
    uint currentTeamIndex;
    uint totalPersonDonate;
    uint totalInsituteDonate;
    uint totalTeamDonate;

    mapping(address => DonateRecord []) public donateRecords;

    mapping(address => bool) public admins;

    // Donate Detail related
    mapping(address => TeamLeader) public teamLeaderInfo;

    mapping(address => uint) public teamLeaderDonateNumber;
    address[] public teamLeaders;
    address[] public institutes;
    address[] public persons;

    mapping(address => uint) public personalDonateNumber;

    mapping(address => string) public instituteLogo;
    mapping(address => string) public instituteName;
    mapping(address => uint) public instituteDonateNumber;
    mapping(address => mapping(address => uint)) public userStakingAmount;
    mapping(address => mapping(address => uint)) public userBondAmount;


    // for ranking
    mapping(address => mapping(address => uint)) public bondOfTeam;
    mapping(address => mapping(address => uint)) public burnOfTeam;
    mapping(address => uint) public tokenOfTeam;
    mapping(address => address[]) public addressOfTeam;

    // refer related
    struct User {
        bool referred;
        address teamLeaderAddress;
    }

    mapping(address => User) public userInfo;

    address public usdtAddress;

    address public recorder;
    address public admin;
    address public root;
    address public donorAddress;
    address public sBHO;
    address public BHO;

    constructor(address _usdtAddress,
        address _donorAddress,
        address _sBHO,
        address _BHO
    ) {
        usdtAddress = _usdtAddress;
        root = msg.sender;
        donorAddress = _donorAddress;
        sBHO = _sBHO;
        BHO = _BHO;
        admins[sBHO] = true;
        admins[BHO] = true;
    }

    function getCurrentPersonIndex() public view returns (uint){
        return currentPersonIndex;
    }

    function getCurrentTeamIndex() public view returns (uint){
        return currentTeamIndex;
    }

    function getCurrentInsituteIndex() public view returns (uint){
        return currentInsituteIndex;
    }

    function getTotalPersonDonate() public view returns (uint) {
        return totalPersonDonate;
    }

    function getTotalTeamDonate() public view returns (uint) {
        return totalTeamDonate;
    }

    function getTotalInsituteDonate() public view returns (uint) {
        return totalInsituteDonate;
    }

    function addPersonIndex() public {
        require(admins[msg.sender], "Caller is not a recorder");
        currentPersonIndex += 1;
    }

    function addInsituteIndex() public {
        require(admins[msg.sender], "Caller is not a recorder");
        currentInsituteIndex += 1;
    }

    function addTeamIndex() public {
        require(admins[msg.sender], "Caller is not a recorder");
        currentTeamIndex += 1;
    }

    function setTotalPersonDonate(uint _number) public {
        require(admins[msg.sender], "Caller is not a recorder");
        totalPersonDonate = _number;
    }

    function setTotalInsituteDonate(uint _number) public {
        require(admins[msg.sender], "Caller is not a recorder");
        totalInsituteDonate = _number;
    }

    function setTotalTeamDonate(uint _number) public {
        require(admins[msg.sender], "Caller is not a recorder");
        totalTeamDonate = _number;
    }


    function getUserInfo(address _address) public view returns (User memory){
        return userInfo[_address];
    }

    function addMember(address _account) public {
        require(msg.sender == root, "caller is not root");
        admins[_account] = true;
    }

    function withDrawFund(address _address, uint _amount) public {
        require(msg.sender == root, "caller is not root");
        IERC20 token = IERC20(_address);
        token.approve(address(this), _amount);
        IERC20(usdtAddress).transferFrom(
            address(this),
            msg.sender,
            _amount
        );
    }


    function getRecords(address _address) public view returns (DonateRecord [] memory){
        return donateRecords[_address];
    }

    function changeRecords(address _address, uint _recordId, uint _endTime, uint _claimableBUSDAmount, uint _claimableBHOAmount, uint _claimedBUSD, uint _claimedBHO, uint _claimBHOValue) public {
        require(admins[msg.sender], "Caller is not a recorder");
        for (uint i = 0; i < donateRecords[_address].length; i++) {
            if (donateRecords[_address][i].id == _recordId) {
                donateRecords[_address][i].endTime = _endTime;
                donateRecords[_address][i].claimableBHOAmount = _claimableBHOAmount;
                donateRecords[_address][i].claimableBUSDAmount = _claimableBUSDAmount;
                donateRecords[_address][i].claimedBHO = _claimedBHO;
                donateRecords[_address][i].claimedBUSD = _claimedBUSD;
                donateRecords[_address][i].claimedBHOValue = _claimBHOValue;
            }
        }
    }

    function getAllPerson() public view returns (address [] memory){
        return persons;
    }

    function getAllPersonDonateNumber() public view returns (uint [] memory){
        uint [] memory donateNumbers = new uint[](persons.length);
        for (uint i = 0; i < persons.length; i++) {
            donateNumbers[i] = personalDonateNumber[persons[i]];
        }
        return donateNumbers;
    }


    function getAllTeamLeaders() public view returns (address [] memory) {
        return teamLeaders;
    }

    function getAllTokenOfTeam() public view returns (uint [] memory){
        uint [] memory tokenNumber = new uint[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            tokenNumber[i] = tokenOfTeam[teamLeaders[i]];
        }
        return tokenNumber;
    }

    function getAllBondOfTeam(address _tokenAddress) public view returns (uint [] memory){
        uint [] memory tokenNumber = new uint[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            tokenNumber[i] = bondOfTeam[teamLeaders[i]][_tokenAddress];
        }
        return tokenNumber;
    }

    function getAllBurnOfTeam(address _tokenAddress) public view returns (uint [] memory){
        uint [] memory tokenNumber = new uint[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            tokenNumber[i] = burnOfTeam[teamLeaders[i]][_tokenAddress];
        }
        return tokenNumber;
    }

    function getAllTeamLeadersName() public view returns (string [] memory){
        string [] memory names = new string[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            names[i] = teamLeaderInfo[teamLeaders[i]].name;
        }
        return names;
    }

    function getAllTeamLeadersLogo() public view returns (string [] memory){
        string [] memory logos = new string[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            logos[i] = teamLeaderInfo[teamLeaders[i]].logo;
        }
        return logos;
    }

    function getAllTeamLeadersDonateNumber() public view returns (uint [] memory){
        uint [] memory donateNumbers = new uint[](teamLeaders.length);
        for (uint i = 0; i < teamLeaders.length; i++) {
            donateNumbers[i] = teamLeaderDonateNumber[teamLeaders[i]];
        }
        return donateNumbers;
    }


    function getTotalTeamTokenNumber() public view returns (uint){
        uint number = 0;
        for (uint i = 0; i < teamLeaders.length; i++) {
            number += tokenOfTeam[teamLeaders[i]];
        }
        return number;
    }

    function getTotalTeamBondNumber(address _address) public view returns (uint){
        uint number = 0;
        for (uint i = 0; i < teamLeaders.length; i++) {
            number += bondOfTeam[teamLeaders[i]][_address];
        }
        return number;
    }

    function getAllInstitutes() public view returns (address [] memory) {
        return institutes;
    }

    function getAllInstituteName() public view returns (string [] memory){
        string [] memory names = new string[](institutes.length);
        for (uint i = 0; i < institutes.length; i++) {
            names[i] = instituteName[institutes[i]];
        }
        return names;
    }

    function getAllInstituteLogo() public view returns (string [] memory){
        string [] memory logos = new string[](institutes.length);
        for (uint i = 0; i < institutes.length; i++) {
            logos[i] = instituteLogo[institutes[i]];
        }
        return logos;
    }

    function getAllInstituteDonateNumber() public view returns (uint [] memory){
        uint [] memory donateNumbers = new uint[](institutes.length);
        for (uint i = 0; i < institutes.length; i++) {
            donateNumbers[i] = instituteDonateNumber[institutes[i]];
        }
        return donateNumbers;
    }

    function increaseTeamBurnOfTeam(address _user, address _bondAddress, uint _amount) public {
        require(admins[msg.sender], "Caller is not a recorder");
        if (userInfo[_user].referred) {
            burnOfTeam[userInfo[_user].teamLeaderAddress][_bondAddress] += _amount;
        }
    }

    function increaseTeamBuyBond(address _user, address _bondAddress, uint _amount) public {
        require(admins[msg.sender], "Caller is not a recorder");
        if (userInfo[_user].referred) {
            bondOfTeam[userInfo[_user].teamLeaderAddress][_bondAddress] += _amount;
            userBondAmount[_user][_bondAddress] += _amount;
        }
    }

    function updateStakingTeam(address _userAddress, uint _gonsAmouns) public {
        require(admins[msg.sender], "Caller is not a recorder");
        User memory _user = userInfo[_userAddress];
        if (_user.referred) {
            uint _stakingUserGons = userStakingAmount[_userAddress][msg.sender];
            if (_stakingUserGons > 0) {
                if (_stakingUserGons >= _gonsAmouns) {
                    bondOfTeam[_user.teamLeaderAddress][msg.sender] -= (_stakingUserGons - _gonsAmouns);
                } else {
                    bondOfTeam[_user.teamLeaderAddress][msg.sender] += (_gonsAmouns - _stakingUserGons);
                }
            } else {
                bondOfTeam[_user.teamLeaderAddress][msg.sender] += _gonsAmouns;
            }
            userStakingAmount[_userAddress][msg.sender] = _gonsAmouns;
        }
    }

    function updateTokenTeam(address _userAddress, uint _gonsAmouns, address tokenAddress) internal {
        User memory _user = userInfo[_userAddress];
        if (_user.referred) {
            uint _stakingUserGons = userStakingAmount[_userAddress][tokenAddress];
            if (_stakingUserGons > 0) {
                if (_stakingUserGons >= _gonsAmouns) {
                    bondOfTeam[_user.teamLeaderAddress][tokenAddress] -= (_stakingUserGons - _gonsAmouns);
                } else {
                    bondOfTeam[_user.teamLeaderAddress][tokenAddress] += (_gonsAmouns - _stakingUserGons);
                }
            } else {
                bondOfTeam[_user.teamLeaderAddress][tokenAddress] += _gonsAmouns;
            }
            userStakingAmount[_userAddress][tokenAddress] = _gonsAmouns;
        }
    }


    function increaseTeamToken(address _user, uint _amount) public {
        require(admins[msg.sender], "Caller is not a recorder");
        if (userInfo[_user].referred) {
            tokenOfTeam[userInfo[_user].teamLeaderAddress] += _amount;
        }
    }

    function decreaseTeamToken(address _user, uint _amount) public {
        require(admins[msg.sender], "Caller is not a recorder");
        if (userInfo[_user].referred) {
            tokenOfTeam[userInfo[_user].teamLeaderAddress] -= _amount;
        }
    }

    function donatePersonal(uint _amount) public {
        require(_amount >= 100e18, "Need more BUSD");

        IERC20(usdtAddress).transferFrom(
            msg.sender,
            donorAddress,
            _amount
        );

        if (personalDonateNumber[msg.sender] == 0) {
            persons.push(msg.sender);
        }

        recordId += 1;
        donateRecords[msg.sender].push(DonateRecord(recordId, msg.sender, 2, block.number, 0, _amount, 0, 0, 0, 0, 0, currentPersonIndex));
        personalDonateNumber[msg.sender] += _amount;
        totalPersonDonate += _amount;
    }

    function donateInstitute(uint _amount) public {
        require(_amount >= 10000e18, "Need more BUSD");

        IERC20(usdtAddress).transferFrom(
            msg.sender,
            donorAddress,
            _amount
        );
        if (instituteDonateNumber[msg.sender] == 0) {
            institutes.push(msg.sender);
        }
        instituteDonateNumber[msg.sender] += _amount;

        recordId += 1;
        donateRecords[msg.sender].push(DonateRecord(recordId, msg.sender, 3, block.number, 0, _amount, 0, 0, 0, 0, 0, currentInsituteIndex));
        totalInsituteDonate += _amount;
    }

    function donateTeamLeader(uint _amount) public {
        require(_amount >= 1000e18, "Need more BUSD");

        IERC20(usdtAddress).transferFrom(
            msg.sender,
            donorAddress,
            _amount
        );

        // 首次创建团队
        if (teamLeaderDonateNumber[msg.sender] == 0) {

            // 更新团队信息
            teamLeaderInfo[msg.sender].referredNumber += 1;
            teamLeaders.push(msg.sender);
            addressOfTeam[msg.sender].push(msg.sender);

            // 更新团队长信息
            userInfo[msg.sender].teamLeaderAddress = msg.sender;
            userInfo[msg.sender].referred = true;

            // 更新个人的sToken和Token
            uint sTokenBalance = IsBHO(sBHO).balanceOf(msg.sender);
            uint sTokenGons = IsBHO(sBHO).gonsForBalance(sTokenBalance);
            updateTokenTeam(msg.sender, sTokenGons, sBHO);

            uint tokenBalance = IBHO(BHO).balanceOf(msg.sender);
            updateTokenTeam(msg.sender, tokenBalance, BHO);
        }

        teamLeaderDonateNumber[msg.sender] += _amount;

        recordId += 1;
        donateRecords[msg.sender].push(DonateRecord(recordId, msg.sender, 1, block.number, 0, _amount, 0, 0, 0, 0, 0, currentTeamIndex));
        totalTeamDonate += _amount;
    }

    function changeTeamName(string memory _teamName) public {
        require(teamLeaderInfo[msg.sender].referredNumber >= 1, 'This address is not team leader');
        teamLeaderInfo[msg.sender].name = _teamName;
    }

    function changeTeamLogo(string memory _logo) public {
        require(teamLeaderInfo[msg.sender].referredNumber >= 1, 'This address is not team leader');
        teamLeaderInfo[msg.sender].logo = _logo;
    }

    function changeTeamLogoName(string memory _teamName, string memory _logo) public {
        require(teamLeaderInfo[msg.sender].referredNumber >= 1, 'This address is not team leader');
        teamLeaderInfo[msg.sender].name = _teamName;
        teamLeaderInfo[msg.sender].logo = _logo;
    }

    function changeInstituteName(string memory _name) public {
        require(instituteDonateNumber[msg.sender] >= 0, 'This address is not institute');
        instituteName[msg.sender] = _name;
    }

    function changeInstituteLogo(string memory _logo) public {
        require(instituteDonateNumber[msg.sender] >= 0, 'This address is not institute');
        instituteLogo[msg.sender] = _logo;
    }

    function changeInstituteLogoName(string memory _name, string memory _logo) public {
        require(instituteDonateNumber[msg.sender] >= 0, 'This address is not institute');
        instituteLogo[msg.sender] = _logo;
        instituteName[msg.sender] = _name;
    }


    function referee(address _teamLeaderAddress) public {
        require(teamLeaderInfo[_teamLeaderAddress].referredNumber >= 1, 'This address is not team leader');
        require(userInfo[msg.sender].referred == false, " Already referred ");
        require(_teamLeaderAddress != msg.sender, " You cannot refer yourself ");

        userInfo[msg.sender].teamLeaderAddress = _teamLeaderAddress;
        userInfo[msg.sender].referred = true;

        teamLeaderInfo[_teamLeaderAddress].referredNumber += 1;
        addressOfTeam[_teamLeaderAddress].push(msg.sender);

        // 更新个人的sToken和Token
        uint sTokenBalance = IsBHO(sBHO).balanceOf(msg.sender);
        uint sTokenGons = IsBHO(sBHO).gonsForBalance(sTokenBalance);
        updateTokenTeam(msg.sender, sTokenGons, sBHO);

        uint tokenBalance = IBHO(BHO).balanceOf(msg.sender);
        updateTokenTeam(msg.sender, tokenBalance, BHO);

    }

    function getAddressOfTeam(address _teamLeaderAddress) public view returns (address [] memory) {
        require(teamLeaderInfo[_teamLeaderAddress].referredNumber >= 1, 'This address is not team leader');
        address [] memory addresses = new address[](addressOfTeam[_teamLeaderAddress].length);
        for (uint i = 0; i < addressOfTeam[_teamLeaderAddress].length; i++) {
            addresses[i] = addressOfTeam[_teamLeaderAddress][i];
        }
        return addresses;
    }
}
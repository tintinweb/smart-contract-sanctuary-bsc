//SPDX-License-Identifier: MIT Licensed
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

interface ITOKEN {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Coffe_Matrix {
    address public admin;
    address public crestTokenAddress;
    address public tctTokenAddress;
    ITOKEN public BUSD;
    ITOKEN public CREST;
    ITOKEN public TCT;
    uint256 public joiningFee = 100 ether;
    uint256 public crestTokenFeeBUSD = 10 ether;
    uint256 public tctTokenFeeBUSD = 10 ether;
    uint256 public crestToken = 10 * 1e12;
    uint256 public tctToken = 10 * 1e12;
    uint256 public adminFee = 1 ether;

    enum Rank {
        NONE,
        BARISTA,
        DIRECTOR,
        REGIONAL_DIRECTOR,
        NATIONAL_DIRECTOR,
        VICE_PRESIDENT,
        AMBASSADOR
    }

    uint256[7] directBonus = [
        25 ether,
        30 ether,
        40 ether,
        50 ether,
        60 ether,
        70 ether,
        80 ether
    ];
    uint256[7] teamBonus = [
        10 ether,
        20 ether,
        25 ether,
        30 ether,
        40 ether,
        50 ether,
        60 ether
    ];
    uint256[7] directsRequirement = [4, 8, 12, 16, 20, 24, 28];
    uint256[7] teamRequirement = [12, 36, 108, 324, 972, 2916, 10000];
    uint256[7] rankUsers;

    uint256 public totalInvestment;
    uint256 public totalNumberOfInvestors;
    uint256 public totalDirectBonusDistributed;
    uint256 public totalTeamBonusDistributed;

    address[] members;

    struct User {
        bool isRegistered;
        address referrer;
        uint256 numPartners;
        uint256 directs;
        address[] referred;
        Rank rank;
        uint256 totalDirectBonusDistributed;
        uint256 totalTeamBonusDistributed;
    }

    mapping(address => User) public users;

    event Register(address indexed user, address indexed referrer);
    event Rewarded(address indexed user, uint256 indexed amount);
    event RankUp(address indexed user, Rank rank);

    modifier onlyAdmin() {
        // Check if the sender is the admin
        require(
            msg.sender == admin,
            "Only admin is allowed to call this function"
        );
        // Execute the function body
        _;
    }

    modifier isNotContract() {
        // Check if the sender is the same as the origin of the transaction
        require(msg.sender == tx.origin, "You are blocked");
        // Check if the sender is not a contract by checking if they have no code
        require(msg.sender.code.length == 0, "You are blocked");
        // Execute the function body
        _;
    }

    constructor() {
        //CREST 
        CREST = ITOKEN(0x96Eff5e45CE1baf195FfafA4e46a692039C7e83e);
        //TCT
        TCT = ITOKEN(0x96Eff5e45CE1baf195FfafA4e46a692039C7e83e);
        // Set the contract's admin
        admin = msg.sender;
        // Set the contract's CrestToken address
        crestTokenAddress = msg.sender;
        // Set the contract's TCTToken address
        tctTokenAddress = msg.sender;
        // Register the admin
        users[admin].isRegistered = true;
        // Set the token contract
        BUSD = ITOKEN(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc);
        // Add the admin to the members list
        members.push(admin);
        // Increment the number of investors
        totalNumberOfInvestors++;
    }

    function register(address ref) external isNotContract {
        // Check if the sender is already registered
        require(!users[msg.sender].isRegistered, "Already isRegistered");
        // Check if the referrer is registered
        require(users[ref].isRegistered, "Invalid referrer");
        // Check if the sender has sufficient balance
        require(
            BUSD.balanceOf(msg.sender) >= joiningFee,
            "Insufficient balance"
        );
        // Transfer the joining fee from the sender to the contract
        require(
            BUSD.transferFrom(msg.sender, address(this), joiningFee),
            "Transfer failed"
        );

        // Transfer the crestFeeBUSD to the crestTokenAddress contract
        BUSD.transfer(crestTokenAddress, crestTokenFeeBUSD);
        // Transfer the tctFeeBUSD to the tctTokenAddress contract
        BUSD.transfer(tctTokenAddress, tctTokenFeeBUSD);

        // Transfer the crestToken to the sender
        CREST.transferFrom(crestTokenAddress, msg.sender, crestToken);
        // Transfer the tctToken to the sender
        TCT.transferFrom(tctTokenAddress, msg.sender, tctToken);

        // Calculate the amount that will be distributed as rewards
        uint256 amount = joiningFee -
            (crestTokenFeeBUSD + tctTokenFeeBUSD);

        // Update the contract's total invested and number of members
        totalInvestment += joiningFee;
        members.push(msg.sender);
        totalNumberOfInvestors++;

        // Register the sender
        users[msg.sender].isRegistered = true;
        users[msg.sender].referrer = ref;

        // Update the referrer's data
        users[ref].referred.push(msg.sender);
        users[ref].directs++;
        users[ref].numPartners++;

        // Calculate and distribute the direct bonus to the referrer
        address upline = ref;
        updateRank(upline);
        users[upline].totalDirectBonusDistributed += directBonus[
            uint256(users[upline].rank)
        ];
        totalDirectBonusDistributed += directBonus[uint256(users[upline].rank)];
        BUSD.transfer(upline, directBonus[uint256(users[upline].rank)]);
        emit Rewarded(upline, directBonus[uint256(users[upline].rank)]);
        amount -= directBonus[uint256(users[upline].rank)];

        // Calculate and distribute the team bonus to the upline
        upline = users[ref].referrer;
        while (upline != address(0)) {
            // Update the rank and partners count of the upline
            users[upline].numPartners++;
            updateRank(upline);
            upline = users[upline].referrer;
        }
        // Calculate and distribute the team bonus to the upline
        upline = users[ref].referrer;
        while (upline != address(0)) {
            // Calculate and distribute the team bonus if there is enough amount left
            if (amount >= teamBonus[uint256(users[upline].rank)]) {
                users[upline].totalTeamBonusDistributed += teamBonus[
                    uint256(users[upline].rank)
                ];
                totalTeamBonusDistributed += teamBonus[
                    uint256(users[upline].rank)
                ];
                BUSD.transfer(upline, teamBonus[uint256(users[upline].rank)]);
                emit Rewarded(upline, teamBonus[uint256(users[upline].rank)]);
                amount -= teamBonus[uint256(users[upline].rank)];
                // Go to the next upline
                upline = users[upline].referrer;
            } else {
                break;
            }
        }
        emit Register(msg.sender, ref);
    }

    function updateRank(address user) internal {
        // Check if the user has more referrals than the requirement for their current rank
        // and if they have more partners than the requirement for their current rank
        // and if their rank is not AMBASSADOR
        if (
            users[user].referred.length >
            directsRequirement[uint256(users[user].rank)] &&
            users[user].numPartners >
            teamRequirement[uint256(users[user].rank)] &&
            users[user].rank != Rank.AMBASSADOR
        ) {
            // Decrement the count of users with the current rank
            rankUsers[uint256(users[user].rank)]--;
            // Increment the user's rank by 1
            users[user].rank = Rank(uint256(users[user].rank) + 1);
            // Increment the count of users with the new rank
            rankUsers[uint256(users[user].rank)]++;
            // Emit an event to signal the rank up
            emit RankUp(user, users[user].rank);
        }
    }

    // to Change Admin
    function changeAdmin(address newAdmin) external onlyAdmin {
        // Check if the new admin is not a null address
        require(
            newAdmin != address(0),
            "The new admin address cannot be a null address (0x0)"
        );
        // Check if the new admin is not a dead contract address
        require(
            newAdmin != address(0xdead),
            "The new admin address cannot be a dead contract address (0xdead)"
        );
        // Change the admin
        admin = newAdmin;
    }

    // to withdraw token
    function withdrawToken(address _token, uint256 _amount) external onlyAdmin {
        // Check if the token address is not a null address
        require(
            _token != address(0),
            "The token address cannot be a null address (0x0)"
        );
        // Check if the amount to withdraw is positive
        require(
            _amount > 0,
            "The amount to withdraw must be greater than zero"
        );
        // Check if the contract has sufficient balance of the token
        require(
            ITOKEN(_token).balanceOf(address(this)) >= _amount,
            "The contract has insufficient balance of the token"
        );
        // Transfer the tokens to the admin
        ITOKEN(_token).transfer(admin, _amount);
    }

    // to change joining fee
    function changeJoiningFee(uint256 _joiningFee) external onlyAdmin {
        // Ensure that the new joining fee is greater than 0
        require(_joiningFee > 0, "Joining fee must be greater than 0");
        joiningFee = _joiningFee;
    }

    // to change crest token fee
    function changecrestTokenFeeBUSD(uint256 _crestTokenFeeBUSD)
        external
        onlyAdmin
    {
        // Ensure that the new crestTokenFeeBUSD is greater than 0
        require(
            _crestTokenFeeBUSD > 0,
            "Crest token fee must be greater than 0"
        );
        crestTokenFeeBUSD = _crestTokenFeeBUSD;
    }

    // to change tct token fee
    function changetctTokenFeeBUSD(uint256 _tctTokenFeeBUSD)
        external
        onlyAdmin
    {
        // Ensure that the new tctTokenFeeBUSD is greater than 0
        require(
            _tctTokenFeeBUSD > 0,
            "Tct token fee must be greater than 0"
        );
        tctTokenFeeBUSD = _tctTokenFeeBUSD;
    }

    // to change direct bonus
    function changeDirectBonus(uint256 _directBonus, uint256 _rank)
        external
        onlyAdmin
    {
        // Ensure that the new direct bonus is greater than 0
        require(_directBonus > 0, "Direct bonus must be greater than 0");
        // Ensure that the rank is within the valid range
        require(_rank <= uint256(Rank.AMBASSADOR), "Invalid rank");
        directBonus[_rank] = _directBonus;
    }

    // to change team bonus
    function changeTeamBonus(uint256 _teamBonus, uint256 _rank)
        external
        onlyAdmin
    {
        // Ensure that the new team bonus is greater than 0
        require(_teamBonus > 0, "Team bonus must be greater than 0");
        // Ensure that the rank is within the valid range
        require(_rank <= uint256(Rank.AMBASSADOR), "Invalid rank");
        teamBonus[_rank] = _teamBonus;
    }

    // to change team requirement
    function changeteamRequirement(uint256 _teamRequirement, uint256 _rank)
        external
        onlyAdmin
    {
        // Ensure that the new team requirement is greater than 0
        require(
            _teamRequirement > 0,
            "Team requirement must be greater than 0"
        );
        // Ensure that the rank is within the valid range
        require(_rank <= uint256(Rank.AMBASSADOR), "Invalid rank");
        teamRequirement[_rank] = _teamRequirement;
    }

    // to change directs requirement
    function changedirectsRequirement(
        uint256 _directsRequirement,
        uint256 _rank
    ) external onlyAdmin {
        require(
            _directsRequirement > 0,
            "Directs requirement must be greater than zero"
        );
        // Ensure that the rank is within the valid range
        require(_rank <= uint256(Rank.AMBASSADOR), "Invalid rank");
        directsRequirement[_rank] = _directsRequirement;
    }

    // to change crest token address
    function changecrestTokenAddress(address _crestTokenAddress)
        external
        onlyAdmin
    {
        require(
            _crestTokenAddress != address(0),
            "Invalid crest token address"
        );
        crestTokenAddress = _crestTokenAddress;
    }

    // to change tct token address
    function changetctTokenAddress(address _tctTokenAddress)
        external
        onlyAdmin
    {
        require(_tctTokenAddress != address(0), "Invalid tct token address");
        tctTokenAddress = _tctTokenAddress;
    }

    // to change token BUSD address
    function changeTokenBUSD(address _token) external onlyAdmin {
        require(_token != address(0), "Invalid token address");
        BUSD = ITOKEN(_token);
    }

    // to change token CREST
    function changeTokenCREST(address _token) external onlyAdmin {
        require(_token != address(0), "Invalid token address");
        CREST = ITOKEN(_token);
    }

    // to change token TCT

    function changeTokenTCT(address _token) external onlyAdmin {
        require(_token != address(0), "Invalid token address");
        TCT = ITOKEN(_token);
    }


    // to change admin fee
    function changeAdminFee(uint256 _adminFee) external onlyAdmin {
        require(_adminFee > 0, "Admin fee must be greater than zero");
        adminFee = _adminFee;
    }

    function rewardDistribution(ITOKEN token, uint256 rank, uint256 amount)
        external
        onlyAdmin
    {
        // Check if the rank is valid
        require(rank < 7, "Invalid Rank");
        // Check if the amount is valid
        require(amount > 0, "Invalid Amount");
        // Transfer the amount from the sender to the contract
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        // Calculate the amount per user
        uint256 perUser = amount / rankUsers[rank];
        // Distribute the rewards to all the members with the specified rank
        for (uint256 i = 0; i < members.length; i++) {
            if (users[members[i]].rank == Rank(rank)) {
                // Transfer the reward to the member
                require(token.transfer(members[i], perUser), "Transfer failed");
            }
        }
    }

    // to get directs
    function getDirects(address _user) external view returns (address[] memory) {
        return users[_user].referred;
    }

    // to get requirements
    function getRequirements()
        external
        view
        returns (
            uint256[7] memory directsRequired,
            uint256[7] memory teamRequired,
            uint256[7] memory _directBonus,
            uint256[7] memory _teamBonus,
            uint256[7] memory _rankUsers
        )
    {
        return (
            directsRequirement,
            teamRequirement,
            directBonus,
            teamBonus,
            rankUsers
        );
    }
}
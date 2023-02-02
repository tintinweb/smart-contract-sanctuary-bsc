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

contract STC_NETWORK  {
    address public admin;
    address public Owner1;
    address public Owner2;
    ITOKEN public STC;
    uint256 public STCPerUSD = 86 * 1e8;//100 USD
    uint256 public joiningFee = 100;
    uint256 public platformFee = 20;

    uint256[7] directBonus = [25, 30, 35, 40, 45, 50, 55];
    uint256[7] teamBonus = [10, 15, 20, 25, 30, 35, 40];
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
        uint56 rank;
        uint256 totalDirectBonusDistributed;
        uint256 totalTeamBonusDistributed;
    }

    mapping(address => User) public users;

    event Register(address indexed user, address indexed referrer);
    event Rewarded(address indexed user, uint256 indexed amount);
    event RankUp(address indexed user, uint256 rank);

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
        // Set the contract's admin
        admin = 0x261ed70b49b9d3B183a5d0488c7D6Fdc05EAAc56;
        // Set the contract's rankUsers
        rankUsers[users[admin].rank]++;
        // Set the contract's SHITToken address
        Owner1 = 0x261ed70b49b9d3B183a5d0488c7D6Fdc05EAAc56;
        // Set the contract's SHITToken address
        Owner2 = 0xB8684538b07d6c1C11Fa04223D4f94DE84429792;
        // Register the admin
        users[admin].isRegistered = true;
        // Set the token contract
        STC = ITOKEN(0x28D82C4D7315C02D19562dB1080a713eb5cc2639);
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
            STC.balanceOf(msg.sender) >= joiningFee * STCPerUSD,
            "Insufficient balance"
        );
        // Transfer the joining fee from the sender to the contract
        require(
            STC.transferFrom(msg.sender, address(this), joiningFee * STCPerUSD),
            "Transfer failed"
        );

        sendTokenToPlatform(platformFee * STCPerUSD);

        // Calculate the amount that will be distributed as rewards
        uint256 amount = (joiningFee - (platformFee)) * STCPerUSD;

        // Update the contract's total invested and number of members
        totalInvestment += joiningFee * STCPerUSD;
        members.push(msg.sender);
        totalNumberOfInvestors++;
        rankUsers[users[msg.sender].rank]++;

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
        users[upline].totalDirectBonusDistributed +=
            directBonus[uint256(users[upline].rank)] *
            STCPerUSD;
        totalDirectBonusDistributed +=
            directBonus[uint256(users[upline].rank)] *
            STCPerUSD;
        STC.transfer(
            upline,
            directBonus[uint256(users[upline].rank)] * STCPerUSD
        );
        emit Rewarded(
            upline,
            directBonus[uint256(users[upline].rank)] * STCPerUSD
        );
        amount -= directBonus[uint256(users[upline].rank)] * STCPerUSD;

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
                users[upline].totalTeamBonusDistributed +=
                    teamBonus[uint256(users[upline].rank)] *
                    STCPerUSD;
                totalTeamBonusDistributed +=
                    teamBonus[uint256(users[upline].rank)] *
                    STCPerUSD;
                STC.transfer(
                    upline,
                    teamBonus[uint256(users[upline].rank)] * STCPerUSD
                );
                emit Rewarded(
                    upline,
                    teamBonus[uint256(users[upline].rank)] * STCPerUSD
                );
                amount -= teamBonus[uint256(users[upline].rank)] * STCPerUSD;
                // Go to the next upline
                upline = users[upline].referrer;
            } else {
                break;
            }
        }

        if (amount > 0) {
            sendTokenToPlatform(amount);
        }
        emit Register(msg.sender, ref);
    }

    function updateRank(address user) internal {
        // Check if the user has more referrals than the requirement for their current rank
        // and if they have more partners than the requirement for their current rank
        // and if their rank is not AMBASSADOR
        if (
            users[user].referred.length >=
            directsRequirement[users[user].rank] &&
            users[user].numPartners >= teamRequirement[users[user].rank] &&
            users[user].rank < 6
        ) {
            // Decrement the count of users with the current rank
            rankUsers[users[user].rank]--;
            // Increment the user's rank by 1
            users[user].rank = users[user].rank + 1;
            // Increment the count of users with the new rank
            rankUsers[users[user].rank]++;
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

    // to change platform fee
    function changePlatformFee(uint256 _platformFee) external onlyAdmin {
        // Ensure that the new platform fee is greater than 0
        require(_platformFee > 0, "Platform fee must be greater than 0");
        platformFee = _platformFee;
    }

    // to change STC per USD
    function changeSTCPerUSD(uint256 _STCPerUSD) external onlyAdmin {
        // Ensure that the new STC per USD is greater than 0
        require(_STCPerUSD > 0, "STC per USD must be greater than 0");
        STCPerUSD = _STCPerUSD;
    }

    // to change direct bonus
    function changeDirectBonus(uint256 _directBonus, uint256 _rank)
        external
        onlyAdmin
    {
        // Ensure that the new direct bonus is greater than 0
        require(_directBonus > 0, "Direct bonus must be greater than 0");
        // Ensure that the rank is within the valid range
        require(_rank <= uint256(6), "Invalid rank");
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
        require(_rank <= uint256(6), "Invalid rank");
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
        require(_rank <= uint256(6), "Invalid rank");
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
        require(_rank <= uint256(6), "Invalid rank");
        directsRequirement[_rank] = _directsRequirement;
    }

    // to change owner1 address
    function changeOwner1(address _owner1) external onlyAdmin {
        require(_owner1 != address(0), "Invalid owner1 address");
        Owner1 = _owner1;
    }

    // to change token STC address
    function changeTokenSTC(address _token) external onlyAdmin {
        require(_token != address(0), "Invalid token address");
        STC = ITOKEN(_token);
    }

    function rewardDistribution(
        ITOKEN token,
        uint256 rank,
        uint256 amount
    ) external onlyAdmin {
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
            if (users[members[i]].rank == rank) {
                // Transfer the reward to the member
                require(token.transfer(members[i], perUser), "Transfer failed");
            }
        }
    }

    // send token to the platform
    function sendTokenToPlatform(uint256 amount) internal {
        // Check if the amount is valid
        require(amount > 0, "Invalid Amount");

        STC.transfer(Owner1, (amount * 40) / 100);
        STC.transfer(Owner2, (amount * 40) / 100);
        STC.transfer(address(0xdead), (amount * 20) / 100);
    }

    // to get directs
    function getDirects(address _user)
        external
        view
        returns (address[] memory)
    {
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
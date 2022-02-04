// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ownable.sol";

contract ERC20Token {
    mapping(address => uint256) public balances;

    uint256 public totalSupply;

    string public name;
    string public symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint() public {
    balances[tx.origin] ++;

    totalSupply ++;
    }
}

contract BBTRating is Ownable {

    address public operator;
    address payable feeCollector;
    address public token;
    
    struct Profile {
        uint id;
        string name;
        string username;
        uint8 trapPoints;
        bool auditStatus;
        bool KYCStatus;
        string website;
        string telegram;
        string twitter;
        string instagram;
        uint reviewsCount;
        uint sumRating;
        mapping(address => bool) hasReviewed;
    }

    event ProfileAdded(
        uint id,
        string name,
        string username,
        uint8 trapPoints,
        bool auditStatus,
        bool KYCStatus
    );

    event ProfileReviewed(
        uint id,
        uint avgRating,
        address reviewer
    );

    uint numProfiles;
    mapping(uint => Profile) profiles;
    uint public profileCount = 0;

    modifier onlyOwnerOrOperator {
        require(msg.sender == operator || msg.sender == owner(), "BBT Platform: only accessible by operator or owner");
        _;
    }
    constructor (address _operator, address payable _feeCollector, address _token) {
        operator = _operator;
        feeCollector = _feeCollector;
        token = _token;
    }

    function addProfile(
        string memory _name, 
        string memory _username, 
        uint8 _trapPoints, 
        string memory _telegram,
        string memory _website,
        string memory _twitter,
        string memory _instagram)
        public onlyOwnerOrOperator {
        require(keccak256(bytes(_name)) != keccak256(""), "The name property is required.");

        Profile storage p = profiles[numProfiles++];
        
            p.id = profileCount;
            p.name = _name;
            p.username = _username;
            p.trapPoints = _trapPoints;
            p.telegram = _telegram;
            p.website = _website;
            p.twitter = _twitter;
            p.instagram = _instagram;
            p.auditStatus;
            p.KYCStatus;
            p.reviewsCount = 0;
            p.sumRating = 0;

            profileCount++;
    }
        
    function addReview(uint _profileId, uint8 _rating) public payable {
        Profile storage profile = profiles[_profileId];

        ERC20Token _token = ERC20Token(address(token));
        _token.mint();

        feeCollector.transfer(msg.value); 
        require(msg.value >= 5000000000000000);

        require(keccak256(bytes(profile.name)) != keccak256(""), "Profile not found.");
        require(_rating >= 1 && _rating <= 5, "Rating is out of range.");
        require(!profile.hasReviewed[msg.sender], "This address already reviewed this profile.");
    
        profile.sumRating += _rating * 10;
        profile.hasReviewed[msg.sender] = true;
        profile.reviewsCount++;

        emit ProfileReviewed(profile.id, profile.sumRating / profile.reviewsCount, msg.sender);
    }

    function editTrapPoints(uint _profileId, uint8 _updatedTrapPoints) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        require(_updatedTrapPoints >= 0 && _updatedTrapPoints <= 10, "TrapPoints can only be between 0 & 10.");
        
        profile.trapPoints = _updatedTrapPoints;
    }
    
    function getProfile(uint profileId) public view returns (
        uint id, 
        string memory name, 
        string memory username, 
        uint trapPoints,
        string memory telegram,
        string memory website,
        string memory twitter,
        string memory instagram,
        bool auditStatus, 
        bool KYCStatus, 
        uint avgRating, 
        uint reviewsCount) {
        Profile storage profile = profiles[profileId];
        uint _avgRating = 0;

    if(profile.reviewsCount > 0)
            _avgRating = profile.sumRating / profile.reviewsCount;
        
        return (
            profile.id,
            profile.name,
            profile.username,
            profile.trapPoints,
            profile.telegram,
            profile.website,
            profile.twitter,
            profile.instagram,
            profile.auditStatus,
            profile.KYCStatus,
            _avgRating,
            profile.reviewsCount
        );
    }

    function editProfile(uint _profileId, string memory _name, string memory _username) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.name = _name;
        profile.username = _username;
    }

    function updateTelegram(uint _profileId, string memory _telegram) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.telegram = _telegram;
    }

    function updateWebsite(uint _profileId, string memory _website) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.website = _website;
    }

    function updateTwitter(uint _profileId, string memory _twitter) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.twitter = _twitter;
    }

    function updateInstagram(uint _profileId, string memory _instagram) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.instagram = _instagram;
    }

    function updateAuditStatus(uint _profileId, bool _auditStatus) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.auditStatus = _auditStatus;
    }

    function updateKYCStatus(uint _profileId, bool _KYCStatus) public onlyOwnerOrOperator {
        Profile storage profile = profiles[_profileId];

        profile.KYCStatus = _KYCStatus;
    }

    function updateToken(address _token) public onlyOwner {
        token = _token;
    }

    function newOperator(address _operator) public onlyOwner {
        operator = _operator;
    }

    function updateFeeCollector(address payable _feeCollector) public onlyOwner{
        feeCollector = _feeCollector;
    }
}
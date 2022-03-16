/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at Etherscan.io on 2020-20-01
 id, address, fullname, email, phone, telegram, linkedin, facebook, status, hidden, date
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface IBEP20 {

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



library SafeMath {
    function mul(uint a, uint b) internal pure returns(uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }
    function div(uint a, uint b) internal pure returns(uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }
    function sub(uint a, uint b) internal pure returns(uint) {
        require(b <= a);
        return a - b;
    }
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }
    function max64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a >= b ? a: b;
    }
    function min64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a < b ? a: b;
    }
    function max256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a >= b ? a: b;
    }
    function min256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a: b;
    }
}

contract KYC {
    using SafeMath for uint;

    string private _name = "BLADE KYC";
    string private _symbol = "BKYC";
    uint256 private _dateCreated;

    address public owner;
    event userProfileAdded( uint256 uid,
        string fullname,
        address userAddress,
        string email,
        string phone,
        string telegram,
        string linkedin,
        string facebook,
        uint256 dateRegister,
        bool approved,
        bool hidden);

        event userProfileUpdated( uint256 uid,
        string fullname,
        address userAddress,
        string email,
        string phone,
        string telegram,
        string linkedin,
        string facebook,
        uint256 dateRegister,
        bool approved,
        bool hidden);

    // Define a user kyc profile object
    struct kycProfile {
        uint256 uid;
        string fullname;
        address userAddress;
        string email;
        string phone;
        string telegram;
        string linkedin;
        string facebook;
        uint256 dateRegister;
        bool approved;
        bool hidden;
    }
   
    // Create a list of some sort to hold all the user Info
    kycProfile[] private kycUsers;
    mapping (uint256 => address) public userProfile;
    
    constructor() {
        owner = msg.sender;
        _dateCreated = block.timestamp;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    receive() external payable {}
    // Get the userProfile objects list
    function getUserProfile() public view returns (kycProfile[] memory) {
        return kycUsers;
    }
    
    // Add to the userProfile objects list
    function addUserProfile(kycProfile memory _userProfile) external payable {
            uint256 _value = msg.value;
            require(msg.sender==owner || _value==1000000000000000000, "You must pay transaction fee of 1BNB");
            require(payable(address(this)).send(_value), 'failed to send');
            _userProfile.approved = false;
            kycUsers.push(_userProfile);
            uint256 id = kycUsers.length - 1;
            userProfile[id] = _userProfile.userAddress;
      
            string memory fullname = _userProfile.fullname;
            address userAddress = _userProfile.userAddress;
            string memory email = _userProfile.email;
            string memory phone = _userProfile.phone;
            string memory telegram = _userProfile.telegram;
            string memory linkedin = _userProfile.linkedin;
            string memory facebook = _userProfile.facebook;
            uint256 dateRegister = _userProfile.dateRegister;
            bool approved = _userProfile.approved;
            bool hidden = _userProfile.hidden;
            emit userProfileAdded(id, fullname, userAddress, email, phone, telegram, linkedin, facebook, dateRegister, approved, hidden);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _dateCreated;
    }

    // Update from the userProfile objects list
    function updateUserProfile(uint256 _index, kycProfile memory _userProfile) external payable {
            uint256 _value = msg.value;
            require(msg.sender == userProfile[_index], "You are not the owner of this profile.");
            require(msg.sender==owner || _value==1000000000000000000, "You must have transaction fee of 1BNB");
            require(msg.sender==owner || payable(address(this)).send(_value), 'failed to send');

            _userProfile.approved = false;
            kycUsers[_index] = _userProfile;

            string memory fullname = _userProfile.fullname;
            address userAddress = _userProfile.userAddress;
            string memory email = _userProfile.email;
            string memory phone = _userProfile.phone;
            string memory telegram = _userProfile.telegram;
            string memory linkedin = _userProfile.linkedin;
            string memory facebook = _userProfile.facebook;
            uint256 dateRegister = _userProfile.dateRegister;
            bool approved = _userProfile.approved;
            bool hidden = _userProfile.hidden;
            emit userProfileUpdated(_index, fullname, userAddress, email, phone, telegram, linkedin, facebook, dateRegister, approved, hidden);
    }
    
    // Approve user profile for verification
    function approveUserProfile(uint256 _index) public onlyOwner {
        kycProfile storage _userProfile = kycUsers[_index];
        _userProfile.approved = true;
    }

    // Unhide to enable displaying of user profile
    function unhideUserProfile(uint256 _index, bool _action) public {

        kycProfile storage _userProfile = kycUsers[_index];
        require(msg.sender==owner || msg.sender== _userProfile.userAddress, "Only admin and profile owner can unhide the profile");
        _userProfile.hidden = _action;
    }

    // function displaying of user profile details
    function displayUserProfile(uint256 _index) public view returns(string memory, address, string memory, string memory, string memory, string memory, uint256, bool){
        kycProfile storage _userProfile = kycUsers[_index];
        bool isHidden = _userProfile.hidden;
        require(isHidden==false || msg.sender== _userProfile.userAddress, "The user profile protected can't be viewed by public!");
        return (_userProfile.fullname, _userProfile.userAddress, _userProfile.email, _userProfile.phone, _userProfile.telegram,_userProfile.linkedin, _userProfile.dateRegister, _userProfile.approved);
    }

             // Withdraw ETH that's potentially stuck
    function recoverETHfromContract() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
  
  	website: https://cfg.ninja
	telegram: https://t.me/cfgninjaaudits/6
	KYC Website: https://kyc.cfg.ninja
	We belive in security, our goals are to ensure projects are secure, investors are safe and this KYC Contract will help us achive those goals.
*/

/**
 Data Collected
 id, address, fullname, email, phone, telegram, linkedin, facebook, status, hidden, date
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

contract CFGNINJAKYC {
    using SafeMath for uint;

    string private _name = "CFG NINJA KYC";
    string private _symbol = "CFGKYC";
    uint256 private _dateCreated;

    uint256 public count = 0;
    mapping(address=>bool) public vip;
    address public admin;
    address private owner;
    event userProfileAdded( uint256 uid,
        string fullname,
        address userAddress,
        string email,
        string phone,
        string telegram,
        string linkedin,
        string pcn,
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
        string pcn,
        uint256 dateRegister,
        bool approved,
        bool hidden);

    // Define a user kyc profile object
    struct kycProfile {
        uint256 uid;
        string fullname;
        address userAddress;
        string projectName;
        string projectRole; 
        string pcn;
        string email;
        string phone;
        string telegram;
        string linkedin;
        uint256 dateRegister;
        bool approved;
        bool hidden;
    }
   
    // Create a list of some sort to hold all the user Info
    kycProfile[] public kycUsers;
    mapping (uint256 => address) public userProfile;
    
    constructor() {
        owner = msg.sender;
        admin = owner;
        vip[owner] = true;
        _dateCreated = block.timestamp;
    }
    
    modifier onlyOwner {
        require(vip[msg.sender] == true, "You are not a vip.");
        _;
    }

    modifier vipOnly {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    receive() external payable {}
    // Get the userProfile objects list
    function setVip(address _vip, bool status) public onlyOwner {
        vip[_vip] = status;
    }

    // set the vip address
    function getUserProfile() public view returns (kycProfile[] memory) {
        return kycUsers;
    }
    // Add to the userProfile objects list
    function addUserProfile(kycProfile memory _userProfile) external payable {
            uint256 _value = msg.value;

            require(msg.sender==owner || _value==500000000000000000, "You must pay transaction fee of 0.5BNB");
            require(payable(address(this)).send(_value), 'failed to send');
            _userProfile.approved = false;
            kycUsers.push(_userProfile);
            count++;
            uint256 id = kycUsers.length;
            userProfile[id] = _userProfile.userAddress;
            _userProfile.uid = id;
            string memory fullname = _userProfile.fullname;
            address userAddress = _userProfile.userAddress;
            // string memory projectName = _userProfile.projectName;
            // string memory projectRole = _userProfile.projectRole; 
            string memory pcn = _userProfile.pcn;
            string memory email = _userProfile.email;
            string memory phone = _userProfile.phone;
            string memory telegram = _userProfile.telegram;
            string memory linkedin = _userProfile.linkedin;
         
            uint256 dateRegister = _userProfile.dateRegister;
            bool approved = _userProfile.approved;
            bool hidden = _userProfile.hidden;
            emit userProfileAdded(id, fullname, userAddress, email, phone, telegram, linkedin, pcn, dateRegister, approved, hidden);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function dateCreated() public view returns (uint256) {
        return _dateCreated;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    // Update from the userProfile objects list
    function updateUserProfile(uint256 _index, kycProfile memory _userProfile) external payable {
            uint256 _value = msg.value;
            require(msg.sender==owner || _value==500000000000000000, "You must have transaction fee of 0.5BNB");
            require(msg.sender==owner || payable(address(this)).send(_value), 'failed to send');

            _userProfile.approved = false;
            kycUsers[_index] = _userProfile;

            string memory fullname = _userProfile.fullname;
            address userAddress = _userProfile.userAddress;
            // string memory projectName = _userProfile.projectName;
            // string memory projectRole = _userProfile.projectRole; 
            string memory pcn = _userProfile.pcn;
            string memory email = _userProfile.email;
            string memory phone = _userProfile.phone;
            string memory telegram = _userProfile.telegram;
            string memory linkedin = _userProfile.linkedin;
   
            uint256 dateRegister = _userProfile.dateRegister;
            bool approved = _userProfile.approved;
            bool hidden = _userProfile.hidden;
            emit userProfileUpdated(_index, fullname, userAddress, email, phone, telegram, linkedin, pcn, dateRegister, approved, hidden);
    }

    // Approve user profile for verification
    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }
    
    // Approve user profile for verification
    function approveUserProfile(uint256 _index) public vipOnly {
        kycProfile storage _userProfile = kycUsers[_index];
        _userProfile.approved = true;
    }

    // Unhide to enable displaying of user profile
    function unhideUserProfile(uint256 _index, bool _action) public {

        kycProfile storage _userProfile = kycUsers[_index];
        //keccak256(abi.encodePacked(msg.sender)) == keccak256(abi.encodePacked(_userProfile.userAddress));
        require(vip[msg.sender]==true || msg.sender== _userProfile.userAddress, "Only admin and profile owner can unhide the profile");
        _userProfile.hidden = _action;
    }

    // function displaying of user profile details
    function displayUserProfile(uint256 _index) public view returns(string memory, address, string memory, string memory, string memory, string memory, uint256, bool){
        kycProfile storage _userProfile = kycUsers[_index];
        bool isHidden = _userProfile.hidden;
        //keccak256(abi.encodePacked(msg.sender)) == keccak256(abi.encodePacked(_userProfile.userAddress));
        require(isHidden==false || msg.sender== _userProfile.userAddress, "The user profile protected can't be viewed by public!");
        return (_userProfile.fullname, _userProfile.userAddress, _userProfile.email, _userProfile.phone, _userProfile.telegram,_userProfile.linkedin, _userProfile.dateRegister, _userProfile.approved);
    }

             // Withdraw ETH that's potentially stuck
    function recoverETHfromContract() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdraw() public payable onlyOwner {
    // This will pay Lekman 10% of the initial sale.
    // You can remove this if you want, or keep it in to support Lekman
    // =============================================================================
    (bool hs, ) = payable(0x1D1dc3B5C1e52D22C7AC22c109386A0E48Ad3113).call{value: address(this).balance * 10 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 90% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(admin).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }

}
//Blade
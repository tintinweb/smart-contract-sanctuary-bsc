/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract crowdFunding is Ownable, Pausable{

    uint256 projectID;

    struct ProjectDetails{
        string projectName;
        uint256 projectID;
        uint256 startTime;
        uint256 endTime;
        uint256 collectionFund;
    }

    struct UserDetails{
        address user;
        uint256 lastDepositTime;
        uint256 fundingAmount;
    }

    mapping(uint256 => ProjectDetails) public projectInfo;
    mapping(uint256 => mapping(address => UserDetails )) public userInfo;

    event CreateProject(address indexed Caller, uint256 ProjectID, ProjectDetails project);
    event UpdateProject(address indexed Caller, uint256 ProjectID, uint256 StartTime, uint256 EndTime);
    event DropFund(address indexed User, uint256 ProjectID, uint256 BNBValue, uint256 depositTime);

    constructor()  {}

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function createProject(ProjectDetails memory _newProject) external onlyOwner {
        projectID++;

        projectInfo[projectID] = ProjectDetails({
            projectName: _newProject.projectName,
            projectID: projectID,
            startTime: _newProject.startTime,
            endTime: _newProject.endTime,
            collectionFund: 0
        });

        emit CreateProject(msg.sender, projectID, projectInfo[projectID]);
    }

    function updateProject(uint256 _projectID, uint256 _startTime, uint256 _endTime) external onlyOwner {
        ProjectDetails storage project = projectInfo[_projectID];
        require(projectID >= _projectID,"Invalid project ID");
        project.startTime = _startTime;
        project.endTime = _endTime;

        emit UpdateProject(msg.sender, projectID, _startTime, _endTime);
    }

    function dropFunds(uint256 _projectID) external payable whenNotPaused {
        ProjectDetails storage project = projectInfo[_projectID];
        require(project.startTime <= block.timestamp && project.endTime >= block.timestamp,"project timing not started or ending.");
        UserDetails storage User = userInfo[_projectID][_msgSender()];
        project.collectionFund += msg.value;
        User.user = msg.sender;
        User.fundingAmount += msg.value;
        User.lastDepositTime = block.timestamp;

        emit DropFund(msg.sender, _projectID, msg.value, block.timestamp);
    }

    function recover(address _tokenAddress, address _to, uint256 _amount) external onlyOwner {
        if(_tokenAddress == address(0x0)){
            require(payable(_to).send(_amount),"transaction failed");
        } else {
            IBEP20(_tokenAddress).transfer( _to, _amount);
        }
    }
}
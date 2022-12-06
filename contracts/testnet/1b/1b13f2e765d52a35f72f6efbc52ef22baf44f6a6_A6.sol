/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

//SPDX-License-Identifier: No

pragma solidity = 0.8.17;

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- OWnable ---//
abstract contract Ownable is Context {
    address private _owner;
    address public _safuDeployer;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SAFUDeployerTransferred(address indexed oldMultiSig, address indexed newMultiSig);

    constructor() {
        _setOwner(_msgSender());
        _setSafuDeployer(_msgSender());
    }

    function safuDeployer() public view virtual returns (address) {
        return _safuDeployer;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || safuDeployer() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlySafuDeveloper() {
        require(safuDeployer() == _msgSender(), "SAFU: caller is not the safu developer");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function transferSafuDeveloper(address newSafuDeployer) public virtual onlySafuDeveloper {
        require(newSafuDeployer != address(0), "SAFU: new owner is the zero address");
        _setSafuDeployer(newSafuDeployer);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setSafuDeployer(address newSafuDeployer) private {
        address oldSafuDeployer = newSafuDeployer;
        _safuDeployer = oldSafuDeployer;
        emit SAFUDeployerTransferred(oldSafuDeployer, oldSafuDeployer);
    }
}

//--- Contract v1 ---//
contract A6 is Context, Ownable {


    mapping (address => bool) public isCompany;

    modifier onlyCompany {
        require(isCompany[msg.sender],"msg.sender is not a company");
        _;
    }

    mapping (address => bool) private isAuthenticatorAdmin;
    mapping (address => bool) private isOwnerAuthenticator;
    mapping (address => bool) private canUseAuthenticator;


    mapping (address => uint256) private powerAuthenticator; // Level 1: Low ! Level 2: Medium ! Level 3: High
    mapping (address => uint256) private tempAuthenticationLevel; // Level 1: Low ! Level 2: Medium ! Level 3: High ! Level 5: Owner.
    mapping (address => uint256) private tempAuthenticationLevelDeadLine; // Level 1: Low ! Level 2: Medium ! Level 3: High ! Level 5: Owner.
    mapping (bytes32 => bool) private isUnlocked;
    mapping (bytes32 => uint256) private timeUnlocked;


    bool private isNotPaused;

    modifier pause {
        require(isNotPaused,"Contract is paused.");
        _;
    }
    bool private isAuthenticatorLive = false;
    uint256 private checkTimeUnlocked;
    uint256 private additionalTimerLevel3;
    bytes32 private oldCall;


//--- Events ---//



    constructor() {
        isCompany[address(0x00322C1b922Ee02C96e62B51331C040b4089F801)] = true;
        isAuthenticatorAdmin[address(0x00322C1b922Ee02C96e62B51331C040b4089F801)] = true;
        isOwnerAuthenticator[msg.sender] = true;
        powerAuthenticator[msg.sender] = 3;
        tempAuthenticationLevel[msg.sender] = 5;
        isNotPaused = true;
    }

    function unlock(bytes32 requestNumber, uint256 time, uint256 additionalTime) external pause {
        checkPowerDeadLine();
        require(powerAuthenticator[msg.sender] > 1,"No");
        require(powerAuthenticator[msg.sender] == 3 || time < 15 || additionalTime < 5);


        if(isUnlocked[oldCall]) {isUnlocked[oldCall] = false;} bool TempCall = tempAuthenticationLevel[msg.sender] > 1;
        if(powerAuthenticator[msg.sender] == 1 || !TempCall) {revert("Not enough authentication power use upgradeAuthentication()");}


        callUnlock(requestNumber, time + additionalTime);

    }

    function callUnlock(bytes32 requestNumber ,uint256 time) internal {
        checkTimeUnlocked = block.timestamp + time;
        isUnlocked[requestNumber] = true;
    }

    function removeAuthentication(address who) external pause {
        require(who != msg.sender,"Cannot renounce to your ownership");
        require(powerAuthenticator[who] < 3,"Cannot remove level 3 authenticator");
        powerAuthenticator[who] = 0;
    }

    function checkPowerDeadLine() internal {
        if(tempAuthenticationLevelDeadLine[msg.sender] < block.timestamp || tempAuthenticationLevelDeadLine[msg.sender] < 3) {
            tempAuthenticationLevelDeadLine[msg.sender] = 0;
        }
    }

    function upgradeAuthentication(uint256 deadline, address holder) external pause {
        checkPowerDeadLine();
        require(powerAuthenticator[msg.sender] == 1,"Supported only by the ones that hold the first level.");
        tempAuthenticationLevelDeadLine[holder] = block.timestamp + deadline;
        tempAuthenticationLevel[holder] += 1;
        require(tempAuthenticationLevel[holder] < 3,"Already enough power");

    }

    function guaranteeAccess(bytes32 requestNumber) external view returns(bool) {
        if( checkTimeUnlocked > block.timestamp ) {return isUnlocked[requestNumber];} else {return false;}
    }

    function ownershipCompromised() external onlyCompany {
        require(!isNotPaused);
        isNotPaused = true;
    }

}
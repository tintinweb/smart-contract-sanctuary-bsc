/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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

contract service is Ownable, Pausable, ReentrancyGuard {

    IBEP20 public OGToken;
    uint256 public TokenPerUSD;
    uint256 public projectCount;
    uint256 public projectPercent = 100; // projectPercent 100 is a 10 percentage.

    struct TireLevel{
        uint256 level;
        uint256 USDAmount;
        uint256 TokenAmount;
        uint256 expiryDays;
        uint256 feePercent;
    }

    struct DevInfo{
        address user;
        uint256 level;
        uint256 feePercent;
        uint256 buyingTime;
        uint256 expiryTime;
    }

    struct Service{
        address provider;
        address developer;
        address tokenAddress;
        uint256 initializeTime;
        uint256 amount;
        uint256 devlevelPercentage;
        bool devSubmit;
        bool providerSubmit;
    }

    struct ProviderProjects{
        uint256[] ProvidingIDs;
        uint256[] developingIDs;
    }

    mapping (uint256 => TireLevel) private tireInfo;
    mapping (address => DevInfo) private devDetials;
    mapping (uint256 => Service) private serviceInfo;
    mapping (address => ProviderProjects) private providerIDs;
    mapping (address => bool) public isApproved;

    event BuyTires(address indexed caller,DevInfo BuyerDetails,  uint256 executionTime);
    event ApproveProjects(address indexed caller, uint256 ProjectID, Service ProjectData, uint256 executionTime);
    event DeveloperConfirmation(address indexed caller, bool stauts, uint256 executionTime );
    event ProviderConfirmation(address indexed caller, bool stauts, uint256 executionTime);
    event SentToProvider(address indexed caller, bool stauts, uint256 executionTime);
    event TokenApproved(address indexed caller, address indexed tokenAddress, bool status);
    event ClaimFee(address indexed caller, address indexed _tokenAddress, uint256 tokenAmount);
    event UpdateTire(address indexed caller, uint256 TireLevel);

    modifier tokenApproved(address _token) {
        require(isApproved[_token] || _token == address(0), "token is not approved");
        _;
    }

    constructor(address _OGToken, uint256 _TokenPerUSD) {
        OGToken = IBEP20(_OGToken);
        isApproved[_OGToken] = true;
        TokenPerUSD = _TokenPerUSD;
        tireInfo[1] = TireLevel({level:1, USDAmount:0, TokenAmount:0 * TokenPerUSD, expiryDays: 0, feePercent: 50  }); //50 means 5%
        tireInfo[2] = TireLevel({level:2, USDAmount:50, TokenAmount:50 * TokenPerUSD, expiryDays: 30 days, feePercent: 30  }); //30 means 3%
        tireInfo[3] = TireLevel({level:3, USDAmount:250, TokenAmount:250 * TokenPerUSD, expiryDays: 30 days, feePercent: 10  }); //10 means 1%
    }

    function ViewTires(uint256 _tireLevel) external view returns(TireLevel memory) {
        require(_tireLevel > 0 && _tireLevel < 4,"Invalid tire level");
        return tireInfo[_tireLevel];
    }

    function viewDevDetails(address _devAddress) external view returns(DevInfo memory) {
        return devDetials[_devAddress];
    }

    function viewProjectDetails(uint256 _projectID) external view returns(Service memory){
        return serviceInfo[_projectID];
    }

    function viewProjectIDs(address _account) external view returns(ProviderProjects memory ){
        return providerIDs[_account];
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function approveTokens(address _tokenAddress, bool status ) external onlyOwner {
        isApproved[_tokenAddress] = status;
        emit TokenApproved(msg.sender, _tokenAddress, status);
    }

    function updateTires(uint256 _tireLevel, uint256 _USDamount, uint256 _expiryDays, uint256 _feePercentage) external onlyOwner{
        require(_tireLevel > 0 && _tireLevel < 4,"Invalid tire level");
        TireLevel storage tire = tireInfo[_tireLevel];
        tire.USDAmount = _USDamount;
        tire.TokenAmount = tire.USDAmount * TokenPerUSD;
        tire.expiryDays = _expiryDays * 86400;
        tire.feePercent = _feePercentage;

        emit UpdateTire(msg.sender, _tireLevel);
    }

    function buyTire(uint256 _tireLevel,uint256 _tokenAmount) external whenNotPaused nonReentrant {
        require(_tireLevel > 0 && _tireLevel < 4,"Invalid tire level");
        TireLevel storage tire = tireInfo[_tireLevel];
        require(_tokenAmount >= tire.TokenAmount,"Invalid token amount" );

        uint256 expiry = tire.expiryDays;

        if(tire.expiryDays == 0 ) { expiry = 1e18; }

        devDetials[msg.sender] = DevInfo({
                user: msg.sender,
                level: _tireLevel,
                feePercent: tire.feePercent,
                buyingTime: block.timestamp,
                expiryTime: block.timestamp + expiry
        });

        if(_tokenAmount > 0){
                OGToken.transferFrom(msg.sender, address(this), _tokenAmount);
        }
      

        emit BuyTires(msg.sender, devDetials[msg.sender], block.timestamp );
    }

    function approveProjects(address _devAddress, address _tokenAddress, uint256 _tokenAmount) external payable tokenApproved(_tokenAddress) whenNotPaused nonReentrant{
        require((_devAddress != msg.sender) && (_devAddress != address(0)) ,"developer is not a caller");
        require(devDetials[_devAddress].level > 0,"Invalid developer address");
        projectCount++;

        serviceInfo[projectCount]  = Service({
            provider: msg.sender,
            developer: _devAddress,
            tokenAddress: _tokenAddress,
            initializeTime: block.timestamp,
            amount: _tokenAmount,
            devlevelPercentage: devDetials[_devAddress].feePercent,
            devSubmit: false,
            providerSubmit: false
        });

        providerIDs[msg.sender].ProvidingIDs.push(projectCount);
        providerIDs[_devAddress].developingIDs.push(projectCount);

        uint256 amount = calculateTotalAmount(_tokenAddress, _tokenAmount);

        if(_tokenAddress == address(0x0)){
            require(amount <= msg.value,"Invalid amount");
        }else {
            require(msg.value == 0,"Invalid amount");
            IBEP20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        }

        emit ApproveProjects(msg.sender, projectCount, serviceInfo[projectCount], block.timestamp);
    }

    function submitDev(uint256 _projectID) external {
        require (_projectID <= projectCount ,"Invalid Project ID");
        Service storage project = serviceInfo[_projectID];
        require (!project.devSubmit,"developer already submitted");
        require(project.developer == msg.sender,"caller is not developer");
        project.devSubmit = true;

        emit DeveloperConfirmation(msg.sender, true, block.timestamp);
    }

    function calculateTotalAmount(address _tokenaddress,uint256 _amount ) public view returns(uint256 tokenAmounts) {
        if(_tokenaddress == address(OGToken)) {
            tokenAmounts = _amount;
        } else {
            tokenAmounts = _amount + (_amount * projectPercent / 1000 );
        }
    }

    function submitProvider(uint256 _projectID) external {
        Service storage project = serviceInfo[_projectID];
        require (project.devSubmit,"developer not submitted");
        require (!project.providerSubmit,"Provider already submitted");
        require(project.provider == msg.sender || msg.sender == owner(),"caller is not developer");
        project.providerSubmit = true;

        if(project.tokenAddress == address(OGToken)){
            IBEP20(project.tokenAddress).transfer(project.developer, project.amount - (project.amount * project.devlevelPercentage / 1000) );
        } else if(project.tokenAddress == address(0x0)){
            require(payable(project.developer).send( project.amount - (project.amount * projectPercent / 1000)),"Invalid amount");
        }else {
            IBEP20(project.tokenAddress).transfer(project.developer, project.amount - (project.amount * projectPercent / 1000) );
        }

        emit ProviderConfirmation(msg.sender, true, block.timestamp);
    }

    function updateOGtoken(address _newOGToken) external onlyOwner {
        require(_newOGToken != address(0x0),"Invalid token address");
        OGToken = IBEP20(_newOGToken);
    }

    function sendToProvider(uint256 _projectID) external onlyOwner {
        Service storage project = serviceInfo[_projectID];
        require (!project.providerSubmit,"Provider already submitted");
        project.providerSubmit = true;

        if(project.tokenAddress == address(OGToken)){
            IBEP20(project.tokenAddress).transfer(project.provider, project.amount - (project.amount * project.devlevelPercentage / 1000) );
        } else if(project.tokenAddress == address(0x0)){
            require(payable(project.provider).send( project.amount - (project.amount * projectPercent / 1000)),"Invalid amount");
        }else {
            IBEP20(project.tokenAddress).transfer(project.provider, project.amount - (project.amount * projectPercent / 1000) );
        }

        emit SentToProvider(msg.sender, true, block.timestamp);
    }

    function setTokenPerUSD(uint256 _newAmount) external onlyOwner {
        TokenPerUSD = _newAmount;
    }

    function setProjectPercentage(uint256 _newPercentage) external onlyOwner{
        projectPercent = _newPercentage;
    }

    function claimFee( address _tokenAddress, uint256 _amount) external onlyOwner {

        if(_tokenAddress == address(0x0)){
            require(payable(msg.sender).send( _amount),"Invalid amount");
        }else {
            IBEP20(_tokenAddress).transfer( msg.sender, _amount );
        }

        emit ClaimFee(msg.sender, _tokenAddress, _amount);
    }

}
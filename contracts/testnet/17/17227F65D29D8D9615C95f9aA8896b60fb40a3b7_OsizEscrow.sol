/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract OsizEscrow is Ownable, Pausable, ReentrancyGuard {

    IERC20 public OsizToken;
    IUniswapV2Router02 public UniswapRouter;
    address[3] private feeWallets;
    address public BUSD;
    uint256 public currentProjectID;
    uint256 public projectPercent = 100;

    struct TierLevel{
        uint256 level;
        uint256 USDAmount;
        uint256 expirySeconds;
        uint256 feePercent;
        uint256 projectAllocation;
    }

    struct DevInfo{
        address Developer;
        uint256 level;
        uint256 feePercent;
        uint256 buyingTime;
        uint256 expiryTime;
        uint256 monthlyProjects;
    }

    struct Project{
        address provider;
        address developer;
        address tokenAddress;
        uint256 initializeTime;
        uint256 amount;
        uint256[3] mileStonePercentage;
        uint256[3] mileStoneAmount;
        uint256 devFee;
        bool devSubmit;
        bool providerSubmit;
    }

    struct ProviderProjects{
        uint256[] ProvidingIDs;
        uint256[] developingIDs;
    }
    TierLevel[3] private tierInfo;
    // mapping (uint256 => TierLevel) private tierInfo;
    mapping (address => DevInfo) private developerInfo;
    mapping (uint256 => Project) private projects;
    mapping (address => ProviderProjects) private providerIDs;
    mapping (address => bool) public isApproved;

    event BuyTiers(address indexed caller,DevInfo BuyerDetails,  uint256 executionTime);
    event CreateProject(address indexed caller, Project ProjectDetails, uint256 creationTime );
    event DeveloperConfirmation(address indexed caller, bool stauts, uint256 executionTime );
    event Transactions(address indexed caller,address TokenAddress, address indexed devloper, uint devAmount, address indexed feewallet, uint feeAmount);
    event SendOsizAmounts(address indexed caller,address indexed Receiver,uint256 projectID,uint256 flag,uint256 TokenAmount);
    event TokenApproved(address indexed caller, address indexed tokenAddress, bool status);
    event ClaimFee(address indexed caller, address indexed _tokenAddress, uint256 tokenAmount);
    event UpdateTier(address indexed caller, uint256 TierLevel);
    event UpdateOsiztoken(address indexed caller,address indexed newOsiztoken);
    event UpdateFeeWallets(address indexed caller,address[3] indexed newFeeWallets);
    event UpdatePercentage(address indexed caller, uint256 newPercentage);

    modifier tokenApproved(address _token) {
        require(isApproved[_token], "token is not approved");
        _;
    }

    constructor(address _OsizToken,address _router, address[3] memory _feeWallets, address _BUSD) {
        require(_OsizToken != address(0x0) && _router != address(0x0) && _BUSD != address(0x0),"Zero address appears" );
        OsizToken = IERC20(_OsizToken);
        UniswapRouter = IUniswapV2Router02(_router);
        feeWallets = _feeWallets;
        BUSD = _BUSD;

        isApproved[_OsizToken] = true;
        isApproved[_BUSD] = true;
        isApproved[address(0x0)] = true;

        tierInfo[0] = TierLevel({level:1, USDAmount:0, expirySeconds: 30 days, feePercent: 50, projectAllocation:2 }); //50 means 5%
        tierInfo[1] = TierLevel({level:2, USDAmount:50, expirySeconds: 30 days, feePercent: 30, projectAllocation:type(uint).max  }); //30 means 3%
        tierInfo[2] = TierLevel({level:3, USDAmount:250, expirySeconds: 30 days, feePercent: 10, projectAllocation:type(uint).max   }); //10 means 1%
    }

    function ViewTiers(uint256 _tierLevel) external view returns(TierLevel memory) {
        return tierInfo[_tierLevel];
    }

    function viewDevDetails(address _devAddress) external view returns(DevInfo memory) {
        return developerInfo[_devAddress];
    }

    function viewProjectDetails(uint256 _projectID) external view returns(Project memory){
        return projects[_projectID];
    }

    function viewProjectIDs(address _account) external view returns(uint256[] memory ){
        return providerIDs[_account].ProvidingIDs;
    }

    function viewDevIDs(address _account) external view returns(uint256[] memory ){
        return providerIDs[_account].developingIDs;
    }

    function viewFeeWallets() external view returns(address, address, address){
        return (feeWallets[0],feeWallets[1],feeWallets[2]);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function approveTokens(address _tokenAddress, bool status ) external onlyOwner whenNotPaused {
        isApproved[_tokenAddress] = status;
        emit TokenApproved(msg.sender, _tokenAddress, status);
    }

    function buyTier(uint256 _tierLevel,uint256 _tokenAmount ) external whenNotPaused nonReentrant {
        TierLevel storage tier = tierInfo[_tierLevel];
        DevInfo storage dev =  developerInfo[_msgSender()];
        require(IERC20(BUSD).transferFrom(_msgSender(),address(this), _tokenAmount),"Busd deposit failed");
        require(tier.USDAmount * 1e18 <= _tokenAmount,"Invalid BUSD amount");

        if(dev.level == 1 ){
            require(dev.expiryTime <= block.timestamp || tier.level > dev.level , "existing level not expiry"); 
        }

        if(dev.level == tier.level || dev.level > tier.level){
            require(dev.expiryTime <= block.timestamp, "existing level not expiry" );
        }

        if(_tokenAmount > 0){ swapBUSDToOsiz(_tokenAmount); }

        setTier(_tierLevel, _msgSender() );
    }

    function buyTierAdmin(uint256 _tierLevel,address _toAccount) external onlyOwner {
        setTier(_tierLevel, _toAccount );
    }

    function setTier(uint256 _tierLevel,address _toAccount) internal {
        TierLevel storage tier = tierInfo[_tierLevel];

        developerInfo[_toAccount] = DevInfo({
                Developer: _toAccount,
                level: tier.level,
                feePercent: tier.feePercent,
                buyingTime: block.timestamp,
                expiryTime: block.timestamp + tier.expirySeconds,
                monthlyProjects: 0
        });
    
        emit BuyTiers(_toAccount, developerInfo[_toAccount], block.timestamp );
    }

    function updateFeeWallets(address[3] memory _feeWallets) external onlyOwner {
        feeWallets = _feeWallets;
        emit UpdateFeeWallets(_msgSender(), _feeWallets);
    }

    function updateTier(uint256 _tierLevel, uint256 _USDamount, uint256 _expirySeconds, uint256 _feePercentage, uint256 _monthlyProject) external onlyOwner{
        require( _tierLevel < 3,"Invalid tier level");
        TierLevel storage tier = tierInfo[_tierLevel];
        tier.USDAmount = _USDamount;
        tier.expirySeconds = _expirySeconds;
        tier.feePercent = _feePercentage;
        tier.projectAllocation = _monthlyProject;

        emit UpdateTier(msg.sender, _tierLevel);
    }

    function updateOsiztoken(address _OsizToken) external onlyOwner {
        require(address(_OsizToken) != address(0x0),"Invalid address" );
        OsizToken = IERC20(_OsizToken);

        emit UpdateOsiztoken(_msgSender(), _OsizToken);
    }

    function updatePercentage(uint256 _projectPercent) external onlyOwner {
        require(_projectPercent > 0 && _projectPercent < 500,"Invalid percentage");
        projectPercent = _projectPercent;
        emit UpdatePercentage(_msgSender(),_projectPercent);
    }

    function swapBUSDToOsiz(uint256 _tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = address(OsizToken);

        IERC20(BUSD).approve(address(UniswapRouter), _tokenAmount);

        UniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            feeWallets[0],
            block.timestamp
        );

    }

    function createProject(address _tokenAddress,uint256 _tokenAmount, address _devAddress, uint256[3] memory _mileStonePercentage) external payable tokenApproved(_tokenAddress) whenNotPaused nonReentrant {
        DevInfo storage dev = developerInfo[_devAddress];
        require((_mileStonePercentage[0]+_mileStonePercentage[1]+_mileStonePercentage[2]) == 1000,"");
        validateDev(_devAddress);
        currentProjectID++;

        uint256 amount = _tokenAmount * dev.feePercent / 1000;
        uint256[3] memory mileAmount = calculateMilestoneAmount((_tokenAmount - amount), _mileStonePercentage);

        projects[currentProjectID] = Project({
            provider: _msgSender(),
            developer: _devAddress,
            tokenAddress: _tokenAddress,
            initializeTime: block.timestamp,
            amount: _tokenAmount,
            mileStonePercentage: _mileStonePercentage,
            mileStoneAmount: mileAmount,
            devFee: dev.feePercent,
            devSubmit: false,
            providerSubmit: false
        });

        providerIDs[_msgSender()].ProvidingIDs.push(currentProjectID);
        providerIDs[_devAddress].developingIDs.push(currentProjectID);

        if(address(OsizToken) == _tokenAddress){
            require(OsizToken.transferFrom(_msgSender(),address(this),_tokenAmount),"deposit failed");
            require(OsizToken.transfer(feeWallets[2], amount),"fee amount failed");
        } else {
            sendTokens(_tokenAddress, _tokenAmount, _devAddress);
            projects[currentProjectID].mileStonePercentage = [0,0,0];
            projects[currentProjectID].mileStoneAmount = [0,0,0];
        }

        emit CreateProject(_msgSender(), projects[currentProjectID], block.timestamp );
    }

    function validateDev(address _devAddress) internal {
        DevInfo storage dev = developerInfo[_devAddress];
        require(dev.expiryTime >= block.timestamp,"developer tier expiry");
        require(dev.monthlyProjects < tierInfo[dev.level -1].projectAllocation,"project allocation reached");
        dev.monthlyProjects++;
    }

    function submitDev(uint256 _projectID) external whenNotPaused {
        require (_projectID <= currentProjectID ,"Invalid Project ID");
        Project storage project = projects[_projectID];
        require(project.developer == msg.sender,"caller is not developer");
        require (!project.devSubmit,"developer already submitted");
        project.devSubmit = true;

        emit DeveloperConfirmation(msg.sender, true, block.timestamp);
    }

    function calculateMilestoneAmount(uint256 _tokenAmount, uint256[3] memory _mileStonePercentage  ) public pure returns(uint256[3] memory _amounts) {
        _amounts[0] = _tokenAmount * _mileStonePercentage[0] / 1000;
        _amounts[1] = _tokenAmount * _mileStonePercentage[1] / 1000;
        _amounts[2] = _tokenAmount * _mileStonePercentage[2] / 1000;
    }

    function sendMileStoneAmounts(uint256 _projectID, uint256 _flag, bool success) external whenNotPaused nonReentrant {
        Project storage project = projects[_projectID];
        require(project.tokenAddress == address(OsizToken),"Invalid Token");
        require(project.provider == _msgSender() || _msgSender() == owner(),"Invalid caller");
        require(project.devSubmit || _msgSender() == owner() ,"Developer not accepted");
        require(!project.providerSubmit,"Project closed");
        require(_flag >= 1 && _flag < 4,"Invalid Flag");
        uint256 i;
        uint256 tokenAmount;
        for(i = 0; i < _flag; i++){
            tokenAmount +=  project.mileStoneAmount[i];
            project.mileStoneAmount[i] = 0;
        }
        if(_flag == 3) {project.providerSubmit= true;}
        if(success){ 
            require(OsizToken.transfer(project.developer, tokenAmount),"sending failed"); 
            emit SendOsizAmounts(_msgSender(), project.developer, _projectID, _flag, tokenAmount);
        }else { 
            require(_msgSender() == owner(),"caller must be owner");
            require(OsizToken.transfer(project.provider, tokenAmount),"sending failed"); 
            emit SendOsizAmounts(_msgSender(), project.provider, _projectID, _flag, tokenAmount);    
        } 
    }

    function updateRouter(address _router) external onlyOwner {
        require(address(UniswapRouter) != _router,"old pancake router");
        require(_router != address(0x0),"pancake not zero address");
        UniswapRouter = IUniswapV2Router02(_router);
    }

    function sendTokens(address _tokenAddress,uint256 _tokenAmount, address _dev) internal {
        uint256 totalAmount = calculateTotalAmount(_tokenAddress, _tokenAmount); 
        _tokenAmount = _tokenAmount - (_tokenAmount * projectPercent / 1e3);
        if(_tokenAddress == address(0x0)){
            require(msg.value >= totalAmount,"Invalid TokenAmount");
            require(payable(_dev).send(_tokenAmount),"Transaction failed");
            require(payable(feeWallets[1]).send(totalAmount - _tokenAmount),"Transaction failed");
        } else{
            require(IERC20(_tokenAddress).transferFrom(_msgSender(),address(this),totalAmount),"deposit failed");
            require(IERC20(_tokenAddress).transfer(_dev, _tokenAmount),"dev transaction failed");
            require(IERC20(_tokenAddress).transfer(feeWallets[1],totalAmount - _tokenAmount),"fee transaction failed");
        }
        emit Transactions(_msgSender(),_tokenAddress, _dev, _tokenAmount, feeWallets[1],  totalAmount - _tokenAmount);
    }

    function calculateTotalAmount(address _tokenaddress,uint256 _amount ) public view returns(uint256 tokenAmounts) {
        if(_tokenaddress == address(OsizToken)) {
            tokenAmounts = _amount;
        } else {
            tokenAmounts = _amount + (_amount * projectPercent / 1000 );
        }
    }

    function setBUSD(address _BUSD) external onlyOwner {
        require(_BUSD != address(0x0),"zero address appears");
        BUSD = _BUSD;
    }   

    function claimFee( address _tokenAddress, uint256 _amount) external onlyOwner {

        if(_tokenAddress == address(0x0)){
            require(payable(msg.sender).send( _amount),"Invalid amount");
        }else {
            require(IERC20(_tokenAddress).transfer( msg.sender, _amount ),"claim failed");
        }

        emit ClaimFee(msg.sender, _tokenAddress, _amount);
    }

}
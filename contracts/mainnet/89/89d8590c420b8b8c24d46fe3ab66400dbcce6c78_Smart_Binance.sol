/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal pure virtual returns (bytes calldata) { return msg.data; } }
library SafeERC20 { using Address for address;
    function safeTransfer( IERC20 token, address to, uint256 value ) 
    internal { _callOptionalReturn( token,
    abi.encodeWithSelector(token.transfer.selector, to, value) ); }
    function safeTransferFrom( IERC20 token, address from, address to, uint256 value
    ) internal { _callOptionalReturn( token,
    abi.encodeWithSelector(token.transferFrom.selector, from, to, value) ); }
    function safeApprove( IERC20 token, address spender, uint256 value
    ) internal { require(
    (value == 0) || (token.allowance(address(this), spender) == 0),
    "SafeERC20: approve from non-zero to non-zero allowance" );
    _callOptionalReturn( token,
    abi.encodeWithSelector(token.approve.selector, spender, value) ); }
    function safeIncreaseAllowance( IERC20 token, address spender, uint256 value ) internal 
    { uint256 newAllowance = token.allowance(address(this), spender) + (value);
    _callOptionalReturn( token, abi.encodeWithSelector( token.approve.selector,
    spender, newAllowance ) ); }
    function safeDecreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) -
    (value); _callOptionalReturn( token,
    abi.encodeWithSelector( token.approve.selector, spender, newAllowance ) ); }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall( data, "SafeERC20: low-level call failed" );
    if (returndata.length > 0) { require( abi.decode(returndata, (bool)),
     "SafeERC20: ERC20 operation did not succeed" ); } } }
interface IERC20 { 
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value ); }
library Address {
    function isContract(address account) internal view returns (bool) {
    uint256 size; assembly { size := extcodesize(account) } return size > 0; }
    function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance" );
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted" ); }
    function functionCall(address target, bytes memory data) internal returns (bytes memory)
    { return functionCall(target, data, "Address: low-level call failed"); }
    function functionCall( address target, bytes memory data, string memory errorMessage
    ) internal returns (bytes memory) {return _functionCallWithValue(target, data, 0, errorMessage); }
    function functionCallWithValue(address target, bytes memory data,
    uint256 value ) internal returns (bytes memory) {return functionCallWithValue(
    target, data, value, "Address: low-level call with value failed" ); }
    function functionCallWithValue( address target, bytes memory data,
    uint256 value, string memory errorMessage ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call" );
    return _functionCallWithValue(target, data, value, errorMessage); }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage
    ) private returns (bytes memory) {require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call{value: weiValue}( data );
    if (success) { return returndata; } else {
    if (returndata.length > 0) { assembly { let returndata_size := mload(returndata)
    revert(add(32, returndata), returndata_size) } } else {revert(errorMessage); } } } }
contract Smart_Binance is Context {
    using SafeERC20 for IERC20; struct Node {
    uint32 LD;
    uint32 RD;
    uint32 TCP;
    uint256 DP;
    uint8 CH;
    uint8 LorRUP;
    address UPA;
    address LDA;
    address RDA; }
    mapping(address => Node) private _users;
    mapping(uint256 => address) private ALLUSA;
    address private owner;
    address private tokenAddress;
    address[] private CANDIDA;
    address[] private _Cheack_Add;
    address[] private _BlackList;
    uint256 private _userId;
    uint256 private lastRun;
    uint256 private lastRunSMG;
    uint64 private _count_SMG_CANDIDA;
    uint256 private VAL_SMG;
    uint256[] private _randomNumbers; 
    uint8 private Lock = 0;
    uint8 private Count_Old_Users;
    IERC20 private BUSDt;
    string private Notifications;
    constructor() { owner = _msgSender();
        lastRun = block.timestamp;
        lastRunSMG = block.timestamp;
        tokenAddress = 0x4DB1B84d1aFcc9c6917B5d5cF30421a2f2Cab4cf;
        BUSDt = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        }
    function Reward_12() public {require(Lock == 0, "Proccesing");
        require( _users[_msgSender()].TCP > 0, "You Dont Have Any Point Today" );
        require( block.timestamp > lastRun + 12 hours, "The Reward_12 Time Has Not Come" );
        Lock = 1;
        uint256 Value_Reward = (PRP() * 90) - (TDTOP());
        VAL_SMG = (PRP() * 10);
        uint256 valuePoint = ((Value_Reward)) / TDTOP();
        uint256 RewardClick = (TDTOP()) * 10**18;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) { Node memory TempNode = _users[ALLUSA[i]];
        uint32 Point; uint32 Result = TempNode.LD <= TempNode.RD ? TempNode.LD : TempNode.RD;
        if (Result > 0) { if (Result > 25) { Point = 25;
        if (TempNode.LD < Result) { TempNode.LD = 0; TempNode.RD -= Result; } 
        else if (TempNode.RD < Result) { TempNode.LD -= Result; TempNode.RD = 0; } 
        else { TempNode.LD -= Result; TempNode.RD -= Result; } } 
        else { Point = Result; 
        if (TempNode.LD < Point) { TempNode.LD = 0; TempNode.RD -= Point; } 
        else if (TempNode.RD < Point) { TempNode.LD -= Point; TempNode.RD = 0; } 
        else { TempNode.LD -= Point; TempNode.RD -= Point; } }
        TempNode.TCP = 0; _users[ALLUSA[i]] = TempNode;
        if ( Point * valuePoint > BUSDt.balanceOf(address(this)) ) 
        { BUSDt.safeTransfer(ALLUSA[i],BUSDt.balanceOf(address(this)) ); } 
        else { BUSDt.safeTransfer( ALLUSA[i], Point * valuePoint ); } } } 
        lastRun = block.timestamp;
        if (RewardClick <= BUSDt.balanceOf(address(this))) 
        { BUSDt.safeTransfer(_msgSender(), RewardClick); }
        Lock = 0; }
    function Register(address uplineAddress) public {
        require( _users[uplineAddress].CH != 2,"This Address Has Two Directs!" );
        require( _msgSender() != uplineAddress, "You Can Not Enter Your Address!");
        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
        if (ALLUSA[i] == _msgSender()) {
        testUser = true; break; } }
        require(testUser == false, "This Address Is Registered!");
        bool TSUP = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
        if (ALLUSA[i] == uplineAddress) {
        TSUP = true; break; } }
        require(TSUP == true, "Upline Address Is Not Exist!");
        BUSDt.safeTransferFrom( _msgSender(), address(this), 100 * 10**18  );
        ALLUSA[_userId] = _msgSender();   _userId++;
        uint256 depthChild = _users[uplineAddress].DP + 1;
        _users[_msgSender()] = Node(
        0, 0, 0, depthChild, 0, _users[uplineAddress].CH, uplineAddress, address(0), address(0) );
        if (_users[uplineAddress].CH == 0) {
        _users[uplineAddress].LD++;
        _users[uplineAddress].LDA = _msgSender(); } 
        else {_users[uplineAddress].RD++;
        _users[uplineAddress].RDA = _msgSender(); }
        _users[uplineAddress].CH++;
        setTDP(uplineAddress);
        address UPN = _users[uplineAddress].UPA;
        address childNode = uplineAddress;
        for ( uint256 j = 0; j < _users[uplineAddress].DP; j = unsafe_inc(j)) 
        { if (_users[childNode].LorRUP == 0) {
        _users[UPN].LD++; } 
        else { _users[UPN].RD++; }
        setTDP(UPN);
        childNode = UPN;
        UPN = _users[UPN].UPA; } }
    function Payment_Gift_6() public { require(
        block.timestamp > lastRunSMG + 6 hours,"The Payment_Gift_6 Time Has Not Come!" );
        require(VAL_SMG > 0, "The Smart_Gift Balance Is Zero!" );
        BUSDt.safeTransfer(_msgSender(),10 * 10**18 );
        uint256 Numer_Win = ((VAL_SMG - 10) / 10**18) / 10;
        if (Numer_Win != 0 && _count_SMG_CANDIDA != 0) {
        if (_count_SMG_CANDIDA > Numer_Win) {
        for ( uint256 i = 1; i <= _count_SMG_CANDIDA; i = unsafe_inc(i) ) {_randomNumbers.push(i); }
        for (uint256 i = 1; i <= Numer_Win; i = unsafe_inc(i)) {
        uint256 randomIndex = uint256(
        keccak256( abi.encodePacked(block.timestamp, msg.sender, i) ) ) % _count_SMG_CANDIDA;
        uint256 resultNumber = _randomNumbers[randomIndex];
        _randomNumbers[randomIndex] = _randomNumbers[ _randomNumbers.length - 1 ]; _randomNumbers.pop();
        if(_users[CANDIDA[resultNumber - 1]].TCP == 0){
        BUSDt.safeTransfer( CANDIDA[resultNumber - 1], 10 * 10**18 ); } }
        for ( uint256 i = 0; i < (_count_SMG_CANDIDA - Numer_Win); i = unsafe_inc(i) ) {_randomNumbers.pop(); } } 
        else { for ( uint256 i = 0; i < _count_SMG_CANDIDA; i = unsafe_inc(i))
        { BUSDt.safeTransfer( CANDIDA[i], 10 * 10**18 ); } } }
        delete _count_SMG_CANDIDA; _count_SMG_CANDIDA = 0;
        VAL_SMG = 0; }
    function Smart_Gift() public {
        require( _users[_msgSender()].TCP < 1, "You Have Point" );
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= 10 * 10**18, "You Dont Have Enough Smart Binance Token!" );
        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
        if (ALLUSA[i] == _msgSender()) { testUser = true; break; } }
        require(testUser == true, "You Are Not In Smart Binance Contract!" );
        bool testUserSmartGift = false;
        for (uint256 i = 0; i <= _count_SMG_CANDIDA; i = unsafe_inc(i)) {
        if (CANDIDA[i] == _msgSender()) { testUserSmartGift = true; break; } }
        require(testUserSmartGift == false, "You Are already Candidated...");
        IERC20(tokenAddress).safeTransferFrom( _msgSender(), address(this), 10 * 10**18  );
        CANDIDA.push(_msgSender()); _count_SMG_CANDIDA++; }
    function Buy_Token() public {
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= (10 * 10**18), "You Dont Have Enough BUSD!" );
        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
        if (ALLUSA[i] == _msgSender()) { testUser = true; break; } }
        require(testUser == true,"You Are Not In Smart Binance Contract!" );
        BUSDt.safeTransferFrom(_msgSender(),address(this), 10 * 10**18 );
        IERC20(tokenAddress).transfer(_msgSender(), 100 * 10**18); }
    function Get_Token() public { bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
        if (ALLUSA[i] == _msgSender()) { testUser = true; break; } }
        require( testUser == true, "You Are Not In Smart Binance Contract!" );
        bool testAllreadyUser = false;
        for (uint256 i = 0; i <= _Cheack_Add.length; i = unsafe_inc(i)) {
        if (_Cheack_Add[i] == _msgSender()) { testAllreadyUser = true; break; } }
        require(testAllreadyUser == true,"You Can Not Receive Token Again!");
        IERC20(tokenAddress).transfer(_msgSender(), 100 * 10**18); _Cheack_Add.push(_msgSender()); }
    function X_Emergency_48() public {require(_msgSender() == owner, "You Can not Run This Order!");
        require(block.timestamp > lastRun + 48 hours, "The X_Emergency_48 Time Has Not Come" );
        BUSDt.safeTransfer(owner, BUSDt.balanceOf(address(this)) ); }
    function AddTo_BlackList(address  add) public {
      require(_msgSender() == 0x9c7Ea742584cAd4c2C14eebee27851221b39FEb4, "Just Operator Can Write!"); _BlackList.push(add); }
    function Write_Notifications(string memory Note) public {
      require(_msgSender() == 0x9c7Ea742584cAd4c2C14eebee27851221b39FEb4, "Just Operator Can Write!"); Notifications = Note; }
    function unsafe_inc(uint256 x) private pure returns (uint256) { unchecked { return x + 1; } }
    function User_Information(address UserAddress) public view returns (Node memory) {return _users[UserAddress]; }
    function Today_Contract_Balance() public view returns (uint256) { return BUSDt.balanceOf(address(this)) / 10**18; }
    function PRP() private view returns (uint256) { return (BUSDt.balanceOf(address(this))) / 100; }
    function TDREBL() public view returns (uint256) { return (PRP() * 90) / 10**18; }
    function Today_Gift_Balance() public view returns (uint256) { return (PRP() * 10) / 10**18; }
    function Number_Of_Gift_Candidate() public view returns (uint256) { return _count_SMG_CANDIDA; }
    function All_payment() public view returns (uint256) { return (Total_Register() * 100); }
    function Smart_Binance_Token_Address() public view returns (address) { return tokenAddress; }
    function Total_Register() public view returns (uint256) { return _userId; }
    function User_Upline(address Add_Address) public view returns (address) { return _users[Add_Address].UPA; }
    function User_Directs_Address(address Add_Address) public view returns (address, address)
    { return ( _users[Add_Address].LDA, _users[Add_Address].RDA ); }
    function Today_User_Left_Right(address Add_Address)
    public view returns (uint256, uint256) { return ( _users[Add_Address].LD, _users[Add_Address].RD ); }
    
    function TDTOP() public view returns (uint256) { uint256 TPoint;
    for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) { uint32 min = _users[ALLUSA[i]].LD <=
    _users[ALLUSA[i]].RD ? _users[ALLUSA[i]].LD  : _users[ALLUSA[i]].RD;
    if (min > 25) { min = 25; } TPoint += min; } return TPoint; }
    function Today_Value_Point() public view returns (uint256) {
    if (TDTOP() == 0) { return TDREBL(); } 
    else { return ((PRP() * 90) - (TDTOP())) / (TDTOP() * 10**18);  } }
    function setTDP(address userAddress) private { uint32 min = _users[userAddress].LD <=
    _users[userAddress].RD ? _users[userAddress].LD : _users[userAddress].RD;
    if (min > 0) { _users[userAddress].TCP = min; } }
    function Show_Notifications() public view returns (string memory) { return Notifications; } }
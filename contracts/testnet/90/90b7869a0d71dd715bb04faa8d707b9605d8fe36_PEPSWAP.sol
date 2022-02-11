/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.5.9;

contract BEP20 {
  uint256 public decimals;
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address _from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}
contract PEPSWAP {
    address payable public owner;
    uint256 public TokensPereth;    
    BEP20 token;
    event buyevent(address buyer,address receipient, uint256 amounteth,uint256 amountToken);
    event sellevent(address seller,address receipient, uint256 amounteth,uint256 amountToken);
    constructor(address payable _owner,address tokenAddress,uint256 _tokenPereth) public {
        owner = _owner;
        token = BEP20(tokenAddress);
        TokensPereth = _tokenPereth;
    }

    function SwapExactETHForTokensTwo(address payable receipient) public payable {
        uint256 tokens = msg.value * TokensPereth;
        token.transfer(receipient,tokens);
        emit buyevent(msg.sender,receipient, msg.value,tokens);
    }
   function SwapExactETHForTokens() public payable {
        uint256 tokens = msg.value * TokensPereth;
        token.transfer(msg.sender,tokens);
        emit buyevent(msg.sender,msg.sender, msg.value,tokens);
    }
    function SwapExactTokensForETHTwo(address payable receipient,uint256 _tokens) public payable {
        uint256 bnbs = _tokens / TokensPereth;
        require(token.transferFrom(msg.sender,address(this),_tokens));
        receipient.transfer(bnbs);
        emit sellevent(msg.sender,receipient, bnbs,_tokens);
    }
     function SwapExactTokensForETH(uint256 _tokens) public payable {
        uint256 bnbs = _tokens / TokensPereth;
        require(token.transferFrom(msg.sender,address(this),_tokens));
        msg.sender.transfer(bnbs);
        emit sellevent(msg.sender,msg.sender, bnbs,_tokens);
    }
    function safeWithdraw() public {
        require(msg.sender == owner,"Permission Denied");
        owner.transfer(address(this).balance);
    }
    function changePrice(uint256 _tokensPereth) external{
        require(msg.sender == owner,"Permission Denied");
        TokensPereth = _tokensPereth;
    }
    function safeWithdrawToken(address tokenAddress) public {
        require(msg.sender == owner,"Permission Denied");
        BEP20 receivedToken = BEP20(tokenAddress);
        receivedToken.transfer(owner,receivedToken.balanceOf(address(this)));
    }
}
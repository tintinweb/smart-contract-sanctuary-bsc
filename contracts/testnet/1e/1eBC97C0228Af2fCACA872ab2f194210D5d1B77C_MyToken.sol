/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;
interface IERC20 { 
  function totalSupply() external  returns (uint256);
  function balanceOf(address account) external view returns(uint256); 
  function transfer(address recipiant , uint256 amount ) external payable returns(bool);
  function allowence(address owner, address spender ) external view returns (uint256);
  function approve(address spender , uint amount ) external returns(bool);
  function transferfrom(address sender, address receiver, uint256 amount ) external returns(bool);

event Transfer(address indexed from , address indexed to , uint256 amount);
event Approval(address indexed owner ,address indexed spender , uint256 value);
}
contract MyToken is  IERC20 { 
          string  public constant name = "BetterLogics";
         string public constant symbol = "BL";
         uint256 public constant decimal = 18;
         uint256   totalSupply_ = 1000*1e18;
         address admin=msg.sender;
     
     mapping (address=> uint256) balances;
     mapping (address=>mapping (address=> uint256) ) allowed;
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
     constructor()  {
         balances[msg.sender]=totalSupply_;
     }

     function totalSupply() public override view returns (uint256) {
    return totalSupply_;
 }
 

    function balanceOf(address TokenOwner ) public  override view returns(uint256){
        return balances[TokenOwner];
    }
    function transfer( address receiver , uint256 numToken) public payable override returns(bool){
        require(numToken<=balances[msg.sender],"number of token less than contract balance");
        require (numToken%100 == 0 ,"htfhg");
        uint256  fee = numToken/20;
        balances[msg.sender]-=numToken;
        balances[receiver]+=(numToken-fee);
         balances[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db]=fee;
        emit Transfer(msg.sender, receiver, numToken );
        return true;
    }
      function approve( address delegate , uint256 numToken ) public override  returns(bool)  {
          allowed[msg.sender][delegate]=numToken;
          emit Approval(msg.sender , delegate, numToken);
          return true;
      }   
      function allowence(address owner , address delegate ) public override view returns(uint256){
          return allowed[owner][delegate];
      }
      function transferfrom( address owner , address buyer , uint256 numToken) public override returns(bool){
          require(numToken<=balances[owner],"a") ;
          require(numToken<=allowed[owner][msg.sender],"b" );
          balances[owner]=balances[owner]-numToken;
          allowed[owner][msg.sender]= allowed[owner][msg.sender]-numToken;
              balances[buyer]=balances[buyer]+numToken;
              emit Transfer (owner , buyer , numToken);
             return true;

      }
        modifier onlyAdmin{
            require(msg.sender==admin, "only admin can run this function");
            _;
        }

      function mint(uint256 newToken ) onlyAdmin public{
          totalSupply_+=newToken;
          balances[msg.sender]+=newToken;
      }
      function burn(uint256 newToken ) onlyAdmin public{
          require(balances[msg.sender]>=newToken, "you cant burn larger token then total supply" );
          totalSupply_-=newToken;
          balances[msg.sender]-=newToken;
      }

     }

    //  0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db marketing wallet
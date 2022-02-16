//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./token.sol";
import "./child.sol";
import "./interface.sol";
import "./safemath.sol";
import "./ownable.sol";
import "./fnder.sol";



contract FACTORY is ERC20, Ownable, Fnder{
    using SafeMath for uint;
    using SafeMath for uint256; 

    ERC20 public anotherTokenInstance;
    ERC20 public TokenInstance;
    IUniswapV2Router02  router;   
    uint256 easy_count;    

    //0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // BNB MAIN NET
    //0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BNB TEST NET

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 

    address burn = 0x000000000000000000000000000000000000dEaD;
    address public defaultContract;
    address public defaultContract2;
    uint256 cost;       
    uint256 minimumhold = 1000000000000000000000000; 
    uint256 instanceminimum = 2000000000000000000; 
    

    constructor(string memory name, string memory symbol) ERC20(name, symbol)  { 
      _mint(msg.sender, 10000 * 10**uint(decimals()));       
      anotherTokenInstance = ERC20(0xB3670F91E86a96EeDA0c75b1573035A6277226fb);
      TokenInstance = ERC20(address(this));

        //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 ROUTER TEST NET
        //0x10ED43C718714eb63d5aA57B78B54704E256024E ROUTER PANCAKESWAP MAIN NET

      router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
       defaultContract = 0xB3670F91E86a96EeDA0c75b1573035A6277226fb;
       defaultContract2 = address(this);
       fnder = (msg.sender);
       cost = 10000000000000000;  // Easy Swap Creation Cost
       _addMinter(address(this));   
       _addMinter(msg.sender) ;
        
    }

    GET_TOKEN[] public children;
 

    event Token_Created(uint date, address indexed targetbuy, address indexed creatoraddress, address factory, address indexed easyaddress, address token_to_buy, address promoter_address, address easyswap_address);

    address factory  = address(this);
   
    

    function createSwap(address payable _defaultContract2, address _promoter) external payable returns (address) {        
        require(msg.value == cost , 'Creation fee'); //FEE
        factory = address(this);             
        GET_TOKEN Token =  new GET_TOKEN(_defaultContract2, _promoter) ;        
        children.push(Token);
        easy_count  += 1;      
       _addMinter(address(Token));
        emit Token_Created(
        block.timestamp,
        _defaultContract2,
        _promoter,
        factory,
        address (Token),
        _defaultContract2,
        _promoter,
        address (Token)
        );
        _mint(msg.sender, 1 * 10**uint(decimals()));  
        return address (Token); 
    }   

    function Get_Royalities() public payable {                
             payable(fnder).transfer(address(this).balance.div(2));        //50%
             payable(msg.sender).transfer(address(this).balance.div(20));  //5%           
             buyTokens(address(this).balance.div(2), defaultContract);     //22.5%            
             buyTokens(address(this).balance, defaultContract2);           //22.5%          
             require (balanceGood(msg.sender),'Require Tokens in wallet balance');                        
         }      
     

    function checkBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getfactoryaddress() public view returns(address){
    return factory;
    }

    function get_count()public view returns(uint256){
    return easy_count;
    }

    function balanceGood(address _address) public view returns (bool){
        if(balanceGood_anotherinstance(_address) && balanceGood_thisInstance(_address)){
            return true;
        }else {
            return false;
        }
    }

    function balanceGood_anotherinstance(address _address) public view returns (bool) {        
        if (anotherTokenInstance.balanceOf(_address) >= minimumhold) {
            return true;
        } else {
            return false;
            }
    }   

    function balanceGood_thisInstance(address _address) public view returns (bool){
        if (TokenInstance.balanceOf(_address) >= instanceminimum){
            return true;
        } else {
            return false;
        }
    }

    function set_AnotherTokenInstance(ERC20 tokenaddress) public onlyOwner{
        anotherTokenInstance = tokenaddress;
    }  


    function set_Hold_AnotherTokenInstance(uint256 Minimum) public onlyOwner {
        minimumhold = Minimum;
    }  

    function checkrequired_AnotherTokenInstance() public view returns (uint256){
    return minimumhold;
    }

    function set_TokenInstance(ERC20 tokenaddress) public onlyOwner{
        TokenInstance = tokenaddress;
    }

     function set_Hold_TokenInstance(uint256 Minimum) public onlyOwner {
        instanceminimum = Minimum;
    }      

    function checkrequired_TokenInstance() public view returns (uint256){
    return instanceminimum;
    }



    function Creation_Fee() public view returns (uint256){
    return cost;
    }

    function setCreation_Fee(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function set_burnToken1(address _Token1) public onlyOwner{
        defaultContract = _Token1;
    }

    function set_burnToken2(address _Token2) public onlyOwner{
        defaultContract2 =_Token2;
    }

    function getBuyPath(address selectedContract) internal view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = selectedContract;
        return path;
    }

    function buyTokens(uint256 amt, address selectedContract) internal {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amt}(
            0,
            getBuyPath(selectedContract),
            burn,
            block.timestamp
        );
    }  

  receive() external payable {}  
}
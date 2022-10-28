/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// File: contracts/myContracts/bank.sol



pragma solidity 0.8.0;



interface ERC20{
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}
contract bank{

//owner balance 
uint public totalBalance;

mapping (address => mapping(address => uint))public tokenBalance;



//deposit

function deposit(uint _amount, address _token)public returns(uint){

    require(_amount > 0, "Amount sent must be more than 0");

    totalBalance += _amount;
    tokenBalance[msg.sender][_token] += _amount;
    ERC20(_token).transferFrom(msg.sender,address(this),_amount);
    return _amount;
}


//withdrawl
function withdrawl(uint _amount, address _token)public returns(uint){

    require(tokenBalance[msg.sender][_token] >= _amount, "balance to low");
    require(_amount >= 0, "amount must be more than 0");

    totalBalance -= _amount;
    tokenBalance[msg.sender][_token] -= _amount;
    ERC20(_token).transfer(msg.sender,_amount);

    return _amount;
}

function myTokenBalance(address _token) public view returns(uint){
    return tokenBalance[msg.sender][_token];
}
}
// File: contracts/myContracts/bot.sol



pragma solidity 0.8.0;


interface pancakeSwap{
    function swapExactTokensForTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external returns (uint[] memory amounts);

function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}



contract swapBot is bank{

address owner;
address pancakeContract = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

address[] sellPath = [WBNB, BUSD];
address[] buyPath = [BUSD, WBNB];

constructor(){

    owner = msg.sender;

}


function getPrice(uint _amount, address[] memory _path) public view returns(uint){

        uint[] memory pan = pancakeSwap(pancakeContract).getAmountsOut(_amount, _path);

    return pan[1];
}


function sellWbnb(uint _amount) public returns(uint[] memory){

    return pancakeSwap(pancakeContract).swapExactTokensForTokens(_amount, getPrice(_amount, sellPath), sellPath, address(this) ,block.timestamp);


}


function buyWbnb(uint _amount) public returns(uint[] memory){

    return pancakeSwap(pancakeContract).swapExactTokensForTokens(_amount, getPrice(_amount, buyPath), buyPath, address(this) ,block.timestamp);


}



}
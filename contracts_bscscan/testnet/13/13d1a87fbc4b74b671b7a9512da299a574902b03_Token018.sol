/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: FruitSalad

pragma solidity 0.8.11;

contract Token018 {

    uint public constant MAX = type(uint256).max;

    string public name = "Token 018";
    string public symbol = "T018";
    uint8 public decimals = 18;
    uint public totalSupplyAtLaunch = 1_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;
    
    bool public isTradingEnabled;
    uint public tradingEnabledTime;

    uint8 public taxDev = 10;
    uint8 public taxMarketing = 5;
    uint8 public taxReward = 0;
    uint8 public taxTransfer = 1;

    address payable public token;
    address payable public deployer;      
    address payable public owner;

    // TESTNET addresses
    address public addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward
    address public addressRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancake.kiemtienonline360.com/#/swap
    // MAINNET addresses

    //IUniswapV2Router02 public uniswapV2Router;
    address public addressPair;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt;

    event Approval(address indexed owner, address indexed spender, uint amountSPC);
    event Transfer(address indexed from, address indexed to, uint amountSPC);
    event TransferFrom(address indexed from, address indexed to, uint amountSPC, address indexed msgsender);
    
    receive() external payable {}

    constructor() {

        token = payable(address(this));
        exempt[token] = true;     

        deployer = payable(msg.sender);
        exempt[deployer] = true;

        owner = payable(msg.sender);
        exempt[owner] = true; // needed when creating LP - essential
        balances[owner] = totalSupplyAtLaunch;
        emit Transfer(address(0), owner, totalSupplyAtLaunch);


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addressRouter);
        addressPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(token, _uniswapV2Router.WETH());
        //uniswapV2Router = _uniswapV2Router;
        exempt[addressPair] = true;

        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;

    }

    function allowance(address holder, address spender) public view returns(uint) {
        return allowances[holder][spender];
    }
      
    // approve is for selling via DEX router
    function approve(address spender, uint amount) public returns(bool) { // spender is router address
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address holder) public view returns(uint) {
        return balances[holder];
    }

    function getOwner() public view returns(address) {
        return owner;
    }
    

    // for buys / wallet transfers
    // on a buy, 'from'/msg.sender is pair
    // on a wallet transfer neither 'from' nor 'to' is pair
    function transfer(address to, uint amount) public returns(bool) {
        require(amount <= balanceOf(msg.sender), "Amount too big");

        balances[msg.sender] -= amount;
        uint _tax;

        if (!exempt[to]){
            if (msg.sender == addressPair){ // buy from DEX
                _tax = ( amount * taxDev ) / 100;
                balances[addressDev] += _tax;
                emit Transfer(msg.sender, addressDev, _tax); // optional if you want tax amount deducted shown on bscscan Tx summary
            } else { // wallet to wallet transfer
                _tax = ( amount * taxTransfer ) / 100;
                balances[addressReward] += _tax;
                emit Transfer(msg.sender, addressReward, _tax); // optional if you want tax amount deducted shown on bscscan Tx summary
            }
        }

        balances[to] += amount - _tax;
        emit Transfer(msg.sender, to, amount - _tax);

        return true;
    }
    

    // for sells
    // on a sell,'to' is pair (receives tokens from holder), and msg.sender (=spender) is the router address
    // this function called when adding liquidity
    function transferFrom(address from, address to, uint amount) public returns(bool) {
        require(balanceOf(from) >= amount, "Balance too low");
        require(allowances[from][msg.sender] >= amount, "Allowance too low");
        
        balances[from] -= amount;
        uint _tax;

        if (!exempt[from]){ 
            _tax = ( amount * taxMarketing ) / 100;
            balances[addressMarketing] += _tax;
            //emit TransferFrom(from, addressMarketing, _tax, msg.sender);
            emit Transfer(from, addressMarketing, _tax);
        }

        balances[to] += amount - _tax;
        //emit TransferFrom(from, to, amount - _tax, msg.sender);
        emit Transfer(from, to, amount - _tax);

        return true;   
    }
    
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
}
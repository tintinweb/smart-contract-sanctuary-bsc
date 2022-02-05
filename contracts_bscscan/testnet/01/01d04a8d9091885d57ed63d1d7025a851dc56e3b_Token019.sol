/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: FruitSalad

pragma solidity 0.8.11;

contract Token019 {

    uint public constant MAX = type(uint256).max;

    bytes32 public name = "Token 019";
    bytes32 public symbol = "T019";
    uint public decimals = 18;
    uint public totalSupplyAtLaunch = 1_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;

    uint8 public constant taxBuy = 10;
    uint8 public constant taxSell = 5;
    uint8 public constant taxTransfer = 1;
    uint8 public constant taxReward = 0;
    uint8 public constant taxBlacklist = 99;

    uint16 public counterBuy;
    uint16 public counterSell;
    uint16 public counterTransfer;

    address payable public immutable token;
    address payable public immutable deployer;
    address payable public owner;

    bool public isTradingEnabled;
    uint public tradingEnabledTime;

    // TESTNET addresses
    address public immutable addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public immutable addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public immutable addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public immutable addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward
    address public immutable addressRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancake.kiemtienonline360.com/#/swap
    
    // MAINNET addresses

    IUniswapV2Router02 public uniswapV2Router;
    address public addressPair;

    mapping(address => mapping(address => uint)) private allowances;
    mapping(address => uint) private balances;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt;
    mapping(address => bool) private pair;

    event Alert(address indexed holder, string comment);
    event Approval(address indexed owner, address indexed spender, uint amountSPC);
    event Comment(string comment);
    event Tax(uint tax);
    event Transfer(address indexed from, address indexed to, uint amountSPC);
    
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
        uniswapV2Router = _uniswapV2Router;
        // need to approve uniswapV2Router for future swapToBNB calls ???
        exempt[addressPair] = true;
        pair[addressPair] = true;

        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;

    }


    function getAllowance(address holder, address spender) public view returns(uint) {
        return allowances[holder][spender];
    }

    // approve is for selling tokens via DEX router (spender), msg.sender is the holder of the tokens
    function approve(address spender, uint amount) public returns(bool) { // spender is router address
        require(amount > 0, "Amount not accepted");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getBalance(address holder) public view returns(uint) {
        return balances[holder];
    }

    function getBlacklist(address holder) public view returns(bool) {
        return blacklist[holder];
    }
    function includeInBlacklist(address holder) public {
        blacklist[holder] = true;
    }
    function removeFromBlacklist(address holder) public {
        require(!blacklist[holder], "Not currently blacklisted");
        blacklist[holder] = false;
    }

    function getExempt(address holder) public view returns(bool) {
        return exempt[holder];
    }
    function includeInExempt(address holder) public {
        exempt[holder] = true;
    }
    function removeFromExempt(address holder) public {
        require(!exempt[holder], "Not currently exempt");
        exempt[holder] = false;
     }

    function getOwner() public view returns(address) {
        return owner;
    }
 

   function swapTokensForBNB(uint amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            addressDev, // address(this),
            block.timestamp + 15
        );
    }


    // on a buy, 'from' is pair (gives tokens to holder), and msg.sender (=spender) is the router address
    // on a sell,'to' is pair (receives tokens from holder), and msg.sender (=spender) is the router address
    // on a wallet transfer neither 'from' nor 'to' is pair

    function transfer(address to, uint amount) public returns(bool) {
        transferTokens(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns(bool) {
        require(allowances[from][msg.sender] > 0 && allowances[from][msg.sender] >= amount, "Allowance not accepted");
        transferTokens(from, to, amount);
        return true;   
    }

    function transferTokens(address from, address to, uint amount) private {
        require(amount > 0 && amount <= getBalance(from), "Amount not accepted");

        uint _tax; // amount of tax, this defaults to 0
        address _address; // address to send tax, this defaults to address(0)

        balances[from] -= amount;

            if (pair[from] && !exempt[to]){ // buy tokens via DEX
                _tax = ( amount * taxBuy ) / 100;
                _address = addressDev;
                if (blacklist[to]){ // assumes blacklist address is not exempt from tax
                    _tax = ( amount * taxBlacklist ) / 100;
                    _address = addressBurn;
                    emit Alert(to, "To address blacklisted");
                }
                counterBuy++;
            }

            if (pair[to] && !exempt[from]){ // sell tokens via DEX
                _tax = ( amount * taxSell ) / 100;
                _address = addressMarketing;
                if (blacklist[from]){ // assumes blacklist address is not exempt from tax
                    _tax = ( amount * taxBlacklist ) / 100;
                    _address = addressBurn;
                    emit Alert(from, "From address blacklisted");
                }
                counterSell++;
            }

            if (!pair[from] && !pair[to] && !exempt[from]){ // wallet to wallet transfer
                _tax = ( amount * taxTransfer ) / 100;
                _address = addressReward;
                if (blacklist[from]){ // assumes blacklist address is not exempt from tax
                    _tax = ( amount * taxBlacklist ) / 100;
                    _address = addressBurn;
                    emit Alert(from, "From address blacklisted");
                }
                counterTransfer++;
            }

        balances[_address] += _tax;
        emit Tax(_tax); // this will only show in bscscan Tx logs
        emit Transfer(from, _address, _tax); // optional if you want tax amount/address shown on bscscan Tx summary        
 
        balances[to] += amount - _tax;
        emit Transfer(from, to, amount - _tax); // essential, to show user's own transaction info on bscscan Tx summary
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
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// Code your own contract, you lame ass scam boy